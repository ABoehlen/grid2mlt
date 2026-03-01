#/bin/bash
################################################################################################
#
# Filename:     grid2mlt_adv.bash
# Author:       Adrian Boehlen
# Date:         27.02.2026
# Version:      0.1
#
# Purpose:      konvertiert ein Hoehenmodell im Format ESRI ASCII GRID in ein Hoehenmodell
#               im Format swisstopo MMBL
#
#               Voraussetzungen:
#               - Das ESRI ASCII GRID muss im Schweizer Landeskoordinatensystem
#                 CH1903 LV03 vorliegen
#               - Benoetigt grid2mlt_adv.awk im gleichen Verzeichnis
#
################################################################################################

# Parameter und Voraussetzungen pruefen
if [ $# != 1 ]
then
  echo "********************************************************"
  echo "    Usage: grid2mlt_adv.bash  <ESRI ASCII GRID File>"
  echo "********************************************************"
  exit
fi

if [ ! -f "$1" ]
then
  echo "angegebenes Hoehenmodell existiert nicht"
  exit
fi

if [ -d "tmp" ]
then
  echo "bereits existierendes temporaeres Verzeichnis wird geloescht"
  rm -rf tmp
fi

# in temporaer erstelltes Verzeichnis wechseln
mkdir tmp
cd tmp

# ASCII Grid in kleine Files zu 6 Zeilen aufsplitten und Anzahl Files ermitteln
echo "ASCII Grid aufteilen..."
awk 'NR%6==1{x="T"++i;if(i%100==0){printf("\tDatei %d wird geschrieben...\n", i)}}{print > x;}'  ../$1


# Header aus dem ersten temporaeren File einlesen
ncols=$(awk '$1 ~ /ncols|NCOLS/ {print $2}' T1)
nrows=$(awk '$1 ~ /nrows|NROWS/ {print $2}' T1)
xllcorner=$(awk '$1 ~ /xllcorner|XLLCORNER/ {print $2}' T1)
yllcorner=$(awk '$1 ~ /yllcorner|YLLCORNER/ {print $2}' T1)
cellsize=$(awk '$1 ~ /cellsize|CELLSIZE/ {print $2}' T1)
NODATA_value=$(awk '$1 ~ /NODATA_value|NODATA_VALUE/ {print $2}' T1)

# Headerdatei wieder loeschen
rm -f T1

# Liste der temporaeren Files in numerischer Reihenfolge erstellen
ls -A1v > ../filelist.txt

# Uebersetzung durchfuehren und Ergebnis im Hauptverzeichnis ablegen
echo "ASCII Grid konvertieren..."
awk -v ncols=$ncols -v nrows=$nrows -v xllcorner=$xllcorner -v yllcorner=$yllcorner -v cellsize=$cellsize -v NODATA_value=$NODATA_value -f ../grid2mlt_adv.awk $(<../filelist.txt) > ../out.mlt

# Aufraeumen
echo "Konvertierung beendet. Temporaere Dateien werden geloescht"
cd ..
rm -f filelist.txt
rm -rf tmp
