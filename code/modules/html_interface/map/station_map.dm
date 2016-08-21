
/proc/generateStationMap()
	var/icon/canvas = icon('icons/256x256.dmi', "blank")

	for(var/i = 128 to 384)
		for(var/r = 128 to 384)
			var/turf/tile = locate(i, r, map.zMainStation)
			if(istype(tile, /turf/simulated/wall) || istype(tile, /turf/unsimulated/wall) || (locate(/obj/structure/grille) in tile))
				canvas.DrawBox("#b6f0ff99", i-128, r-128)
			else if (istype(tile, /turf/simulated/floor) || istype(tile, /turf/unsimulated/floor))
				canvas.DrawBox("#0f9cf149", i-128, r-128)

	station_minimap = canvas
