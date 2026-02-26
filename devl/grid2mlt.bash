#/bin/bash
################################################################################################
#
# Filename:     grid2mlt.bash
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
#               - Benoetigt grid2mlt_v2.awk im gleichen Verzeichnis
#
################################################################################################

# Parameter und Voraussetzungen pruefen
if [ $# != 1 ]
then
  echo "zu konvertierendes Hoehenmodell angeben"
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
awk 'NR%6==1{x="T"++i;}{print > x}'  ../$1
files=$(ls . | wc -l)

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
awk -v ncols=$ncols -v nrows=$nrows -v xllcorner=$xllcorner -v yllcorner=$yllcorner -v cellsize=$cellsize -v NODATA_value=$NODATA_value -v files=$files -f ../grid2mlt_v2.awk $(<../filelist.txt) > ../out.mlt

echo "Konvertierung beendet. Temporaere Dateien werden geloescht"
cd ..
rm filelist.txt
rm -rf tmp






