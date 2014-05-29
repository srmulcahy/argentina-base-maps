import mapnik
map = mapnik.Map(3124, 4218)
mapnik.load_map(map, './MapScripts/sanjuan_terrain.xml')
map.zoom_all() 
mapnik.render_to_file(map, './MapFiles/sanjuan_terrain.tif')
