
/proc/generateHoloMinimaps()
	for (var/z = 1 to world.maxz)
		holominimaps |= z
		generateHoloMinimap(z)

/proc/generateHoloMinimap(var/zLevel=1)
	var/icon/canvas = icon('icons/480x480.dmi', "blank")

	for(var/i = 1 to 480)
		for(var/r = 1 to 480)
			var/turf/tile = locate(i, r, zLevel)
			if(tile && !istype(tile.loc, /area/shuttle) && !istype(tile.loc, /area/vault))
				if((!istype(tile, /turf/space) && istype(tile.loc, /area/mine/unexplored)) || istype(tile, /turf/simulated/wall) || istype(tile, /turf/unsimulated/mineral) || istype(tile, /turf/unsimulated/wall) || (locate(/obj/structure/grille) in tile) || (locate(/obj/structure/window/full) in tile))
					canvas.DrawBox("#FFFFFFDD", i, r)
				else if (istype(tile, /turf/simulated/floor) || istype(tile, /turf/unsimulated/floor) || (locate(/obj/structure/catwalk) in tile))
					canvas.DrawBox("#1C1C1C99", i, r)

	holominimaps[zLevel] = canvas
