# combined terrain map
./MapFiles/sanjuan_terrain.tif: ./MapScripts/sanjuan_terrain.xml ./MapFiles/sanjuan_color_relief.tif ./MapFiles/sanjuan_hillshade.tif ./MapFiles/sanjuan_slopeshade.tif ./MapFiles/sanjuan_contour_50m.shp
	python ./MapScripts/sanjuan_terrain.py

# 50m contour interval map
./MapFiles/sanjuan_contour_50m.shp: ./MapFiles/sanjuan.tif
	gdal_contour -a height ./MapFiles/sanjuan.tif ./MapFiles/sanjuan_contour_50m.shp -i 50.0

# slopeshade from slope map	
./MapFiles/sanjuan_slopeshade.tif: ./MapFiles/sanjuan_slope.tif ./MapScripts/color_slope.txt
	gdaldem color-relief ./MapFiles/sanjuan_slope.tif ./MapScripts/color_slope.txt ./MapFiles/sanjuan_slopeshade.tif -co compress=lzw

# create slope map from dem
./MapFiles/sanjuan_slope.tif: ./MapFiles/sanjuan.tif	
	gdaldem slope ./MapFiles/sanjuan.tif ./MapFiles/sanjuan_slope.tif -co compress=lzw

# create color relief from dem
./MapFiles/sanjuan_color_relief.tif: ./MapFiles/sanjuan.tif ./MapScripts/color_relief.txt
	gdaldem color-relief ./MapFiles/sanjuan.tif ./MapScripts/color_relief.txt ./MapFiles/sanjuan_color_relief.tif -co compress=lzw

# create hillshade from dem
./MapFiles/sanjuan_hillshade.tif: ./MapFiles/sanjuan.tif
	gdaldem hillshade ./MapFiles/sanjuan.tif ./MapFiles/sanjuan_hillshade.tif -co compress=lzw

# generate DEM from virtual dem
./MapFiles/sanjuan.tif: ./MapSource/SH19/sh19.vrt
	gdalwarp -t_srs EPSG:32719 -te 462366 6472717 725556 6828061 -r bilinear ./MapSource/SH19/sh19.vrt ./MapFiles/sanjuan.tif

# generate virtual dem for all srtm source files
./MapSource/SH19/sh19.vrt: ./MapSource/SH19/*.hgt
	gdalbuildvrt ./MapSource/SH19/sh19.vrt ./MapSource/SH19/*.hgt


