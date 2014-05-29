# Mapping with gdal, python, and mapnik
Download SRTM data from [here](http://www.viewfinderpanoramas.org/dem3.html#andes)  

Used info from [thematic mapper](http://blog.thematicmapping.org/2012/06/digital-terrain-modeling-and-mapping.html) blog.


## Create a DEM

	# Merge  all the .hrt files to virtual dataset with gdalbuildvrt

	gdalbuildvrt ./MapSource/SH19/sh19.vrt ./MapSource/SH19/*.hgt

	# Project the DEM to the area of interest using gdalwarp
	# 32719 is the EPSG projection for UTM zone 19S in WGS 84
	# -te option trims the full dem to xy limits of interest

	gdalwarp -t_srs EPSG:32719 -te 462366 6472717 725556 6828061 -r bilinear ./MapSource/SH19/sh19.vrt ./MapFiles/sanjuan.tif

	# See the properties of the DEM with gdalinfo
	
	gdalinfo -mm ./MapFiles/sanjuan.tif

	# Convert to .png to preview the DEM
	# Low and high elevations are 328 6090
	
	gdal_translate -of PNG -ot Byte -scale 328 6090 0 256 ./MapFiles/sanjuan.tif ./MapFiles/sanjuan.png
	

## Convert DEM to Hillshade

	# Create hillshade from DEM with gdaldem
	
	gdaldem hillshade ./MapFiles/sanjuan.tif ./MapFiles/sanjuan_hillshade.tif -co compress=lzw


## Convert DEM to Color Relief

Create a text file to color elevation hypsometric tints `color_relief.txt`.

	# Create color relief from DEM with gdaldem

	gdaldem color-relief ./MapFiles/sanjuan.tif ./MapScripts/color_relief.txt ./MapFiles/sanjuan_color_relief.tif -co compress=lzw


## Convert DEM to Slopeshade

	# Create slope map from DEM
	
	gdaldem slope ./MapFiles/sanjuan.tif ./MapFiles/sanjuan_slope.tif -co compress=lzw

Create a text file to color slope from black to white `color_slope.txt`

	# Slopeshade from slope map	
	
	gdaldem color-relief ./MapFiles/sanjuan_slope.tif ./MapScripts/color_slope.txt ./MapFiles/sanjuan_slopeshade.tif -co compress=lzw


## Create Contour Map
	
	# Contour intervals at 50m	

	gdal_contour -a height ./MapFiles/sanjuan.tif ./MapFiles/sanjuan_contour_50m.shp -i 50.0


## Combined Terrain Map with Mapnik and Python

Define the map styles and layers with in `sanjuan_terrain.xml`  
Get the projection for your EPSG zone from the *proj4* link [here](http://spatialreference.org/ref/epsg/32719/)

	<Map srs="+proj=utm +zone=19 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs">
 
  	<Style name="color relief style">
    	<Rule>
      	<RasterSymbolizer comp-op="src-over"/>
    	</Rule>
  	</Style>

  	<Style name="hillshade style">
    	<Rule>
      	<RasterSymbolizer opacity="0.6" comp-op="multiply" />
    	</Rule>
  	</Style>
 
  	<Layer name="color relief">
    	<StyleName>color relief style</StyleName>
    	<Datasource>
      	<Parameter name="type">gdal</Parameter>
      	<Parameter name="file">../MapFiles/sanjuan_color_relief.tif</Parameter>
    	</Datasource>
  	</Layer>

  	<Layer name="hillshade">
    	<StyleName>hillshade style</StyleName>
    	<Datasource>
      	<Parameter name="type">gdal</Parameter>
      	<Parameter name="file">../MapFiles/sanjuan_hillshade.tif</Parameter>
    	</Datasource>
  	</Layer>
 
	</Map>

Python script to combine layers with mapnik `sanjuan_terrain.py`

	import mapnik
	map = mapnik.Map(3124, 4218)
	mapnik.load_map(map, './MapScripts/sanjuan_terrain.xml')
	map.zoom_all() 
	mapnik.render_to_file(map, './MapFiles/sanjuan_terrain.tif')

Run the script

	python ./MapScripts/sanjuan_terrain.py


