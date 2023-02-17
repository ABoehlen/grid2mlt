#!/usr/bin/awk -f
################################################################################################
#
# Filename:     grid2mlt.awk
# Author:       Adrian Boehlen
# Date:         17.02.2023
# Version:      1.0
#
# Purpose:      konvertiert ein Hoehenmodell im Format ESRI ASCII GRID in ein Hoehenmodell
#               im Format swisstopo MMBL
#
#               Voraussetzung: Das ESRI ASCII GRID muss im Schweizer Landeskoordinatensystem
#               CH1903 LV03 vorliegen
#
################################################################################################

BEGIN {
  if (ARGC != 2) {
    printf("\n*********************************************************************************\n")   > "/dev/stderr";
    printf("    Usage: grid2mlt.awk  <ESRI ASCII GRID File> > <Output MMBL File (*.mlt)>\n")          > "/dev/stderr";
    printf("*********************************************************************************\n\n")   > "/dev/stderr";
    beende = 1; # um END-Regel zum sofortigen Beenden zu erzwingen
    exit;
  }
}

##### Header einlesen #####
$1 ~ /ncols|NCOLS/ {
  ncols = $2;
}

$1 ~ /nrows|NROWS/ {
  nrows = $2;
}

$1 ~ /xllcorner|XLLCORNER/ {
  xllcorner = $2;
}

$1 ~ /yllcorner|YLLCORNER/ {
  yllcorner = $2;
}

$1 ~ /cellsize|CELLSIZE/ {
  cellsize = $2;
}

$1 ~ /NODATA_value|NODATA_VALUE/ {
  NODATA_value = $2;
}

##### Hoehendaten einlesen #####
$1 ~ /[1-9]/ {
  daten[NR] = $0;
}

END {
  # damit END nicht ausgefuehrt wird, wenn kein File gelesen wurde
  if (beende == 1)
    exit;

  ##### diverse Werte ermitteln #####
  
  # Koordinaten der Eckpunkte
  # da ESRI ASCII GRID die Punkte in der Mitte der Matrix definiert, MMBL hingegen auf den Kreuzungspunkten
  # des Gitters, muss bei den abgeleiteten X/Y Werten der Wert der Maschenweite abgezogen werden
  nwX = xllcorner;
  nwY = (nrows * cellsize + yllcorner) - cellsize;
  seX = (ncols * cellsize + xllcorner) - cellsize;
  seY = yllcorner;
  
  # Abmessungen des Hoehenmodells
  we = seX - nwX;
  ns = nwY - seY;
  
  # Anzahl Matrixpunkte pro Dimension und gesamt 
  weMp = we / cellsize + 1;
  nsMp = ns / cellsize + 1;
  totMp = weMp * nsMp;
  
  # Recordlaenge (fuer jeden Hoehenwert sind 6 Zeichen verfuegbar)
  recLen = weMp * 6;
  proRec = weMp;
  
  ##### Inhalt durchgehen und Hoehenangaben gemaess Matrixformat MMBL formatieren #####
  
  # alle Hoehenwerte in Variable einlesen
  for (i = 7; i <= NR; i++ )
    alleHoehen = alleHoehen daten[i];
 
  totH = split(alleHoehen, hoehenListe);
  
  # pruefen, ob die berechnete Anzahl Hoehenwerte mit der im ESRI ASCII GRID vorhandenen
  # uebereinstimmt, und falls nicht, Programm abbrechen
  if (totMp != totH) {
    printf("\nFehlerhafte Struktur des ESRI ASCII GRIDs\nAbbruch\n") > "/dev/stderr";
    exit;
  }
  
  ##### Datenrecords aufbauen #####
  
  # nodata mit 0 ersetzen
  # Meter in Dezimeter umrechnen
  # jeweils nach einer Matrixzeile eine neue Zeile beginnen
  for (i = 1; i <= totH; i++) {
    if (hoehenListe[i] == NODATA_value)
      hoehenListe[i] = 0;
    hoeheDM = hoehenListe[i] * 10;
    inhalt = inhalt sprintf("%6d", hoeheDM);
    anz += 1;
    if (anz == proRec) {
      inhalt = inhalt "\n";
      anz = 0;
    }
  }
  
  ##### Header aufbauen #####
  
  # minimale und maximale Hoehe bestimmen
  asort(hoehenListe);
  minH = hoehenListe[1];
  maxH = hoehenListe[totH];
  
  header = sprintf("NEWHEADER\n");
  header = header sprintf("--------------------------------------------------------------------------------\n");
  header = header sprintf("DHM25-MATRIXMODELL                             (c)BUNDESAMT F. LANDESTOPOGRAPHIE\n");
  header = header sprintf("--------------------------------------------------------------------------------\n");
  header = header sprintf("%-22s%10.1f%10.1f%22s\n", "NORD-WEST ECKE     [M]", nwX, nwY, "ERSTER HOEHENWERT");
  header = header sprintf("%-22s%10.1f%10.1f%23s\n", "SUED-OST ECKE      [M]", seX, seY, "LETZTER HOEHENWERT");
  header = header sprintf("%-22s%10.1f%10.1f\n", "MASCHENWEITE WE/NS [M]", cellsize, cellsize);
  header = header sprintf("%-23s%7d%10d%12s%10d%13s\n", "MATRIXDIMENSIONEN WE/NS", weMp, nsMp, "TOTAL", totMp, "MATRIXPUNKTE");
  header = header sprintf("%-22s%8d%10d%35s\n", "HOEHENBEREICH     [DM]", minH, maxH, "(6 CHARACTER PRO HOEHENWERT)");
  header = header sprintf("--------------------------------------------------------------------------------\n");
  header = header sprintf("FORMAT                   ASCII                 L+T-FORMAT DHM25-MATRIXMODELL\n");
  header = header sprintf("%-19s%11d%17s%-6d%23s\n", "RECORDLAENGE(CHAR.)", recLen, " ", proRec, "HOEHENWERTE PRO RECORD");
  header = header sprintf("--------------------------------------------------------------------------------\n");
  header = header sprintf("ENDHEADER\n");
  
  ##### MMBL-Datei ausgeben #####
  
  printf(header);
  printf(inhalt);

}


