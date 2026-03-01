# grid2mlt

## Purpose
grid2mlt is a shell and/or AWK script that converts a digital elevation model in ESRI ASCII GRID format into an elevation model in swisstopo MMBL format. Two different solutions are available:
- grid2mlt_simple.awk: The conversion takes place within the working memory, so it's very fast, but only works with small elevation model data sets. Too much data will result in error messages such as this: 'Cannot allocate memory'. In this case, use the other solution:
- grid2mlt_adv.bash: This shell script divides the ESRI ASCII GRID into small pieces and converts them one after the other. This is done by the script grid2mlt_adv.awk, which is executed automatically.

## Background
The Japanese freeware Kashmir3D, developed by Tomohiko Sugimoto, was one of the first applications to calculate photorealistic views using digital elevation models without specialist knowledge. It's still a useful application for many purposes. However, the last version available in English dates from 2004 \[1\]. Therefore, today's common data formats for digital elevation models are not yet supported. However, since 2001 there has been a plug-in for the matrix format MMBL(T), a proprietary development of the Federal Office of Topography swisstopo \[2\]. This pure text format is well documented and its structure is easy to understand \[3\].

Among the data formats for digital elevation models in widespread use today, the ESRI ASCII GRID format comes closest to the swisstopo format \[4\]. It can be derived from any elevation data using applications as ArcGIS or QGIS and then converted into a swisstopo MMBL matrix format using grid2mlt. It's important that the data has to be stored in the Swiss coordinate system LV03, because MMBL only support this system.

## System requirements
The programme requires the Bash shell and Gawk 4.0 or higher. It has been used and tested on various Linux systems. It's also possible to run it on Windows, but it must be done within _git for Windows_ or _Cygwin_, where Gawk is also available.

## Installation
Download the repository into your desired directory:

```
cd <directory>
git clone https://github.com/ABoehlen/grid2mlt
cd grid2mlt
```

## Usage

### grid2mlt_simple
As argument you give the ESRI ASCII GRID file which extension may be \*.txt or (typically) \*.asc. You also have to define the output file, which extension has to be \*.mlt. For example if you use the light version of the digital height model of Switzerland \[5\], you type:

```
./grid2mlt_simple.awk  DHM200.asc > dhm200.mlt
```

### grid2mlt_advanced
In this case just specify the ESRI ASCII GRID as the argument. Be sure to start the shell script (extension \*.bash) not the AWK script, which is automatically executed by the shell script during runtime. 

```
./grid2mlt_adv.bash  DHM200.asc
```

Depending on the size of the digital elevation model this process can take quite a long time. You can track the progress in the command window. Once the process is complete, the following message appears in the window:

```
======================================================
Bitte Ergebnisdatei 'out.mlt' wunschgemaess umbenennen
Bitte 'minH' und 'maxH' manuell in Header uebertragen
  minH =     0
  maxH = 44280
======================================================
```

The resulting file has the default name 'out.mlt' so you must assign a suitable name yourself. Open the file with a text editor and replace the placeholders 'minH' and 'maxH' with the correspondig values as specified in the message.

Before:
```
MATRIXDIMENSIONEN WE/NS    385       240       TOTAL     92400 MATRIXPUNKTE
HOEHENBEREICH     [DM]    minH      maxH       (6 CHARACTER PRO HOEHENWERT)
--------------------------------------------------------------------------------
```

After:
```
MATRIXDIMENSIONEN WE/NS    385       240       TOTAL     92400 MATRIXPUNKTE
HOEHENBEREICH     [DM]       0     44280       (6 CHARACTER PRO HOEHENWERT)
--------------------------------------------------------------------------------
```

### Import in Kashmir3D

To import the elevation model into Kashmir3D, start the programme, select _File –> OpenMap –> Open New Map_ and select the newly created \*.mlt file. Kashmir3D will convert it to its native DCM format. During this process the coordinates are transformed from the Swiss coordinate system LV03 to WGS1984 geographic coordinates. Depending on the size of the digital elevation model this process can take quite a long time and the programme may appear unresponsive.

## Test file
You can use the enclosed ASC file dhm1000.asc for testing purposes. This is a version of the DHM25 digital elevation model with a 1000 m grid.

Reference:  
Federal Office of Topography swisstopo  
©swisstopo

## Trivia

If you are looking for a tool that goes the opposite way, there exists a solution using Perl. \[6\]

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Literature
\[1\] Kashmir3D v8.0.9 English version: https://www.kashmir3d.com/index-e.html

\[2\] Rickenbacher, Martin: Unser Mann in Yokohama, 2004 (in German): http://www.martinrickenbacher.ch/publikationen/pdf/Topo107S12-13_A3lr.pdf

\[3\] DHM25, das digitale Höhenmodell der Schweiz, 2005 (in German): https://geofiles.be.ch/geoportal/pub/lpi/DHM2510_LANG_DE.PDF

\[4\] ESRI GRID (Wikipedia): https://en.wikipedia.org/wiki/Esri_grid

\[5\] DHM25/200: The light version of the digital height model of Switzerland: https://www.swisstopo.admin.ch/en/geodata/height/dhm25200.html

\[6\] Translate the DHM25 model of Swisstopo from MMBLT to an ARC/ESRI GRID https://ourednik.info/maps/2015/11/29/translate-the-dhm25-model-of-swisstopo-from-mmblt-to-an-arcesri-grid/

