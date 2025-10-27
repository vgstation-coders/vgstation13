/**
 * This system allows turfs to display decorative edges and corners where they meet
 * adjacent turfs of different types or lower priority. This is useful for creating
 * smooth transitions between different floor types, showing borders, etc.
 *
 * HOW TO MAKE A TURF COMPATIBLE WITH THE EDGE SYSTEM:
 *
 * 1. SET EDGE FLAGS:
 *    - EDGE_CARDINAL: Enable cardinal direction edges (NORTH, SOUTH, EAST, WEST)
 *    - EDGE_INNER_DIAGONAL: Show inner diagonal corners (L-shaped corners)
 *    - EDGE_OUTER_DIAGONAL: Show outer diagonal corners (convex corners)
 *    - EDGE_THREEFOLD: Show three-sided corners (U-shaped edges)
 *
 * 2. SET EDGE PRIORITY:
 *    Set the edge_priority variable to determine which turf's edges are shown
 *    when two edge-enabled turfs meet. Higher priority turfs will show their
 *    edges over lower priority turfs.
 *
 * 3. SET EDGE OVERLAY TYPE:
 *    Set the edge_overlay_type variable to the type of edge overlay object to use.
 *    This defaults to /obj/effect/edge_overlay but can be customized.
 *
 * 4. SET BASE ICON STATE:
 *    The base_icon_state variable should be set to the icon state prefix used
 *    for edge sprites in 'icons/turf/edges_corners.dmi'. The system will look for:
 *    - "[base_icon_state]" for cardinal edges
 *    - "[base_icon_state]_corner" for diagonal corners (if flags enabled)
 *
 * EDGE SPRITE REQUIREMENTS:
 * The edge sprites should be in 'icons/turf/edges_corners.dmi' with the following naming:
 * - "[base_icon_state]" - Used for cardinal direction edges AND diagonal (outer) corners.
 * - "[base_icon_state]_corner" - Used for inner diagonal corners and three-sided corners.
 *
 * EXAMPLE:
 * /turf/simulated/floor/grass
 *     edge_flags = EDGE_CARDINAL | EDGE_INNER_DIAGONAL | EDGE_OUTER_DIAGONAL
 *     edge_priority = 3
 *     edge_overlay_type = /obj/effect/edge_overlay
 *     base_icon_state = "grass"
 */

// Returns a list of directions where edges will be placed.
/turf/proc/edge_check()
	var/turf/adj
	var/list/edges = list()
	for(var/direction in alldirs)
		adj = get_step(src, direction)
		if(!istype(adj, src) && adj.edge_priority < edge_priority)
			edges += direction
	return edges

/turf/proc/update_edges()
	if(!(edge_flags & EDGE_CARDINAL))
		return
	var/list/dirs = edge_check()
	for(var/direction in dirs)
		var/obj/effect/edge_overlay/edge
		var/turf/T = get_step(src, direction)
		if(iswall(T) || T.edge_priority > edge_priority)
			continue
		for(var/obj/effect/edge_overlay/E in T.contents)
			if(!istype(E))
				continue
			edge = E
			if(edge.turf_type != src.type)
				edge = null //create another one
				break
		if(!edge)
			edge = new edge_overlay_type(T)
			edge.turf_type = src.type
			edge.priority = edge_priority
			edge.layer += edge_priority
		edge.add_edge_overlay(direction,base_icon_state,edge_flags)
		edge_overlays += makeweakref(edge)

/obj/effect/edge_overlay
	name = "edge overlay"
	mouse_opacity = 0
	layer = EDGE_LAYER
	plane = ABOVE_TURF_PLANE
	var/olay_icon = 'icons/turf/edges_corners.dmi'
	var/olay_layer = EDGE_LAYER
	var/olay_plane = ABOVE_TURF_PLANE
	var/turf_type = null
	var/priority = 0
	var/list/cardinal_dirs = list()
	var/list/diagonal_dirs = list()

/obj/effect/edge_overlay/proc/add_edge_overlay(var/dir_to_use,var/icon_state_to_use,var/flags)
	if((dir_to_use in cardinal_dirs) || (dir_to_use in diagonal_dirs))
		return
	if(dir_to_use in diagonal)
		diagonal_dirs += dir_to_use
	else if(dir_to_use in cardinal)
		cardinal_dirs += dir_to_use
	else
		return // not a valid direction
	overlays.len = 0
	/////CARDINALS/////
	var/edge_count = cardinal_dirs.len
	switch(edge_count)
		if(1) // just one edge
			edge(cardinal_dirs[1],icon_state_to_use)
		if(2) // two directions, could be two edges or one inner corner
			var/dir1 = cardinal_dirs[1]
			var/dir2 = cardinal_dirs[2]
			if(dir1 == opposite_dirs[dir2])
				edge(dir1,icon_state_to_use)
				edge(dir2,icon_state_to_use)
			else
				two_sided_corner(dir1|dir2,icon_state_to_use,flags)
		if(3) // three-sided inner corner
			var/dir1 = cardinal_dirs[1]
			var/dir2 = cardinal_dirs[2]
			var/dir3 = cardinal_dirs[3]
			if(dir1 == opposite_dirs[dir2])
				three_sided_corner(dir3,icon_state_to_use,flags)
			else if(dir1 == opposite_dirs[dir3])
				three_sided_corner(dir2,icon_state_to_use,flags)
			else
				three_sided_corner(dir1,icon_state_to_use,flags)
		if(4) // just use four edges
			for(var/dir in cardinal_dirs)
				edge(dir,icon_state_to_use)
	/////DIAGONALS/////
	for(var/dir in diagonal_dirs)
		if(check_covered(dir))
			outer_corner(dir,icon_state_to_use,flags)

/obj/effect/edge_overlay/proc/check_covered(var/dir_to_check) //check if placing a corner would overlap with an edge
	for(var/cardinal_dir in cardinal_dirs)
		if(dir_to_check & cardinal_dir)
			return FALSE
	return TRUE

/obj/effect/edge_overlay/proc/edge(var/dir_to_use,var/icon_state_to_use)
	create_overlay(image(icon = olay_icon, icon_state = icon_state_to_use, dir = dir_to_use))

/obj/effect/edge_overlay/proc/two_sided_corner(var/dir_to_use,var/icon_state_to_use,var/flags)
	if(!(flags & EDGE_INNER_DIAGONAL))
		var/list/edges = splitdiagonals(dir_to_use)
		edge(edges[1],icon_state_to_use)
		edge(edges[2],icon_state_to_use)
		return
	create_overlay(image(icon = olay_icon, icon_state = icon_state_to_use + "_corner", dir = dir_to_use))

/obj/effect/edge_overlay/proc/three_sided_corner(var/dir_to_use,var/icon_state_to_use,var/flags)
	if(!(flags & EDGE_THREEFOLD))
		edge(dir_to_use,icon_state_to_use)
		edge(clockwise_perpendicular_dirs(dir_to_use),icon_state_to_use)
		edge(counterclockwise_perpendicular_dirs[dir_to_use],icon_state_to_use)
		return
	create_overlay(image(icon = olay_icon, icon_state = icon_state_to_use + "_corner", dir = dir_to_use))

/obj/effect/edge_overlay/proc/outer_corner(var/dir_to_use,var/icon_state_to_use,var/flags)
	if(!(flags & EDGE_OUTER_DIAGONAL))
		return
	create_overlay(image(icon = olay_icon, icon_state = icon_state_to_use, dir = dir_to_use))

/obj/effect/edge_overlay/proc/create_overlay(var/image/I)
	I.plane = olay_plane
	I.layer = olay_layer + priority
	overlays += I
