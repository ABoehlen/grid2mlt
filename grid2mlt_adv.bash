#/bin/bash
################################################################################################
#
# Filename:     grid2mlt_adv.bash
# Author:       Adrian Boehlen
# Date:         05.03.2026
# Version:      1.1
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

timestamp() {
  date +"%T"
}

# Parameter und Voraussetzungen pruefen
if [ $# != 2 ]
then
  echo "*********************************************************************************"
  echo "    Usage: grid2mlt_adv.bash  <ESRI ASCII GRID File> <Lines per partial file>"
  echo "*********************************************************************************"
  exit
fi

# Zeitstempel Beginn
echo ""
echo "Beginn: $(timestamp)"
beginn=$(date +%s)
echo ""

if [ ! -f "$1" ]
then
  echo "angegebenes Hoehenmodell existiert nicht"
  exit
fi

# temporaeres Verzeichnis erstellen
if [ -d "tmp" ]
then
  echo "bereits existierendes temporaeres Verzeichnis wird geloescht"
  rm -rf tmp
fi
mkdir tmp

# Header einlesen
ncols=$(awk '$1 ~ /ncols|NCOLS/ {print $2}' $1)
nrows=$(awk '$1 ~ /nrows|NROWS/ {print $2}' $1)
xllcorner=$(awk '$1 ~ /xllcorner|XLLCORNER/ {print $2}' $1)
yllcorner=$(awk '$1 ~ /yllcorner|YLLCORNER/ {print $2}' $1)
cellsize=$(awk '$1 ~ /cellsize|CELLSIZE/ {print $2}' $1)
NODATA_value=$(awk '$1 ~ /NODATA_value|NODATA_VALUE/ {print $2}' $1)

# ASCII Grid in kleine Dateien zu angegebener Anzahl Zeilen aufsplitten und Anzahl Dateien ermitteln
cd tmp
echo "ASCII Grid aufteilen..."

tail -n +7 ../$1 | awk -v zeile=$2 'NR%zeile==1{x="T"++i;if(i%100==0){printf("\tDatei %d wird geschrieben...\n", i)}}{print > x;}'

# Liste der temporaeren Dateien in numerischer Reihenfolge erstellen
ls -A1v > ../filelist.txt

# Uebersetzung durchfuehren und Ergebnis im Hauptverzeichnis ablegen
echo "ASCII Grid konvertieren..."
awk -v ncols=$ncols -v nrows=$nrows -v xllcorner=$xllcorner -v yllcorner=$yllcorner -v cellsize=$cellsize -v NODATA_value=$NODATA_value -f ../grid2mlt_adv.awk $(<../filelist.txt) > ../out.mlt

# Aufraeumen
echo "Konvertierung beendet. Temporaere Dateien werden geloescht"
cd ..
rm -f filelist.txt
rm -rf tmp

# Zeitstempel Ende und Berechnungsdauer
echo ""
echo "Ende: $(timestamp)"
ende=$(date +%s)
dauer=$((ende-beginn))
echo "Berechnungsdauer: $dauer Sekunden"
echo ""