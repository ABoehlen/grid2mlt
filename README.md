# grid2mlt

## Purpose
grid2mlt is an AWK script which converts a digital elevation model in ESRI ASCII GRID format into an elevation model in the swisstopo MMBL format.

## Background
The Japanese freeware Kashmir3D, developed by Tomohiko Sugimoto, was one of the first applications to calculate photorealistic views using digital elevation models without specialist knowledge. It's still a useful application for many purposes. However, the last version available in English dates from 2004 \[1\]. Therefore, today's common data formats for digital elevation models are not yet supported. However, since 2001 there has been a plug-in for the matrix format MMBL(T), a proprietary development of the Federal Office of Topography swisstopo \[2\]. This pure text format is well documented and its structure easy to understand \[3\].

Among the data formats for digital elevation models in widespread use today, the ESRI ASCII GRID format comes closest to the swisstopo format \[4\]. It can be derived from any elevation data using ArcGIS or QGIS and then converted into a swisstopo MMBL matrix format using grid2mlt.awk. It's important that the data has to be stored in the Swiss coordinate system LV03, because MMBL only support this system.

## System requirements
The programme requires Gawk 4.0 or higher. It has been used and tested on various Linux systems. It's also possible to run it on Windows, but it must be done within _git for Windows_ or _Cygwin_, where Gawk is also available.

## Installation
Download the repository into your desired directory:

```
cd <directory>
git clone https://github.com/ABoehlen/grid2mlt
cd grid2mlt
```

Then you just type…

```
./grid2mlt.awk
```

…for getting the usage:

```
Usage: grid2mlt.awk  <ESRI ASCII GRID File> > <Output MMBL File (*.mlt)>
```

## Usage

The only argument you give is the ESRI ASCII GRID file which extension may be \*.txt or \*.asc. You also have to define the output file, which extension has to be \*.mlt. For example if you use the light version of the digital height model of Switzerland \[5\], you type:

```
./grid2mlt.awk  DHM200.asc > dhm200.mlt
```

To import the resulting file into Kashmir3D, launch the programme, select File –> OpenMap –> Open New Map and choose the freshly generated \*.mlt file. Kashmir3D will convert it into its native format DCM. During this process the coordinates will be transformed from the Swiss coordinate system LV03 into geographic coordinates WGS1984.

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

