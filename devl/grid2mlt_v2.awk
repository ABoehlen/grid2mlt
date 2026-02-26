#!/usr/bin/awk -f
################################################################################################
#
# Filename:     grid2mlt_v2.awk
# Author:       Adrian Boehlen
# Date:         26.02.2026
# Version:      0.2
#
# Purpose:      konvertiert ein Hoehenmodell im Format ESRI ASCII GRID in ein Hoehenmodell
#               im Format swisstopo MMBL
#
#               Voraussetzungen:
#               - Das ESRI ASCII GRID muss im Schweizer Landeskoordinatensystem
#                 CH1903 LV03 vorliegen
#               - Wird von grid2mlt_v2.bash im gleichen Verzeichnis aufgerufen
#
################################################################################################

BEGIN {
  # jeder Wert als Record einlesen
  RS = " ";

  # Variablen fuer die minimale und maximale Hoehe initialisieren
  minH = 0;
  maxH = 0;

  # Ableiten der Eckpunktkoordinaten aus den ESRI ASCII GRID Headerdaten
  nwX = xllcorner;
  nwY = yllcorner + (nrows - 1) * cellsize;
  seX = xllcorner + (ncols - 1) * cellsize;
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

  # Header ausgeben
  header = sprintf("NEWHEADER\n");
  header = header sprintf("--------------------------------------------------------------------------------\n");
  header = header sprintf("DHM25-MATRIXMODELL                             (c)BUNDESAMT F. LANDESTOPOGRAPHIE\n");
  header = header sprintf("--------------------------------------------------------------------------------\n");
  header = header sprintf("%-22s%10.1f%10.1f%22s\n", "NORD-WEST ECKE     [M]", nwX, nwY, "ERSTER HOEHENWERT");
  header = header sprintf("%-22s%10.1f%10.1f%23s\n", "SUED-OST ECKE      [M]", seX, seY, "LETZTER HOEHENWERT");
  header = header sprintf("%-22s%10.1f%10.1f\n", "MASCHENWEITE WE/NS [M]", cellsize, cellsize);
  header = header sprintf("%-23s%7d%10d%12s%10d%13s\n", "MATRIXDIMENSIONEN WE/NS", weMp, nsMp, "TOTAL", totMp, "MATRIXPUNKTE");
  header = header sprintf("%-22s%8s%10s%35s\n", "HOEHENBEREICH     [DM]", "minH", "maxH", "(6 CHARACTER PRO HOEHENWERT)");
  header = header sprintf("--------------------------------------------------------------------------------\n");
  header = header sprintf("FORMAT                   ASCII                 L+T-FORMAT DHM25-MATRIXMODELL\n");
  header = header sprintf("%-19s%11d%17s%-6d%23s\n", "RECORDLAENGE(CHAR.)", recLen, " ", proRec, "HOEHENWERTE PRO RECORD");
  header = header sprintf("--------------------------------------------------------------------------------\n");
  header = header sprintf("ENDHEADER");

  print header;

}

# Datenzeilen aufbauen
$1 !~ /^\s*$/{
  count++;
  if (count <= ncols) {
    if ($1 == NODATA_value)
      printf("%6d", 0);
    else
      printf("%6d", $1 * 10);
    if (count == ncols) {
      printf("\n");
      count = 0;
      next;
    }
  }

  # minimalen und maximalen Hoehenwert ermitteln
  if ($1 != NODATA_value && $1 < minH)
    minH = $1;
  if ($1 > maxH)
    maxH = $1;
}

END {
  # Damit diese Informationen auf den Bildschirm gehen und nicht in die Ausgabedatei,
  # wird /dev/stderr zweckentfremdet.
  print "\n====================================================" > "/dev/stderr";
  print "Bitte Ergebnisdatei out.mlt wunschgemaess umbenennen"   > "/dev/stderr";
  print "Bitte minH und maxH manuell in Header uebertragen"      > "/dev/stderr";
  print "minH = " minH                                           > "/dev/stderr";
  print "maxH = " maxH                                           > "/dev/stderr";
  print "====================================================\n" > "/dev/stderr";
}
