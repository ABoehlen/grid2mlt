#/bin/bash

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



awk -v ncols=$ncols -v files=$files -f ../tmp.awk $(<../filelist.txt)








