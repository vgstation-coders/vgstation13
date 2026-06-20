#define ADMIN_ARENA_WIDTH 15
#define ADMIN_ARENA_HEIGHT 9

// Admin arenas specifically refer to specific arenas created by an admin that load specific-sized maps at that location.
// Coded specifically for the robust tournament admin event, but can expanded on in the future.

// Right now for simplicity there's only one admin arena at a time.
var/global/datum/admin_arena/current_admin_arena
// A prep room is a place a contestant is teleported to before the round starts.
var/global/list/active_prep_rooms = list()



/proc/add_prep_room(turf/location)
	var/obj/effect/admin_arena_prep_room_marker/marker = new(location)
	active_prep_rooms += marker
	return marker

/proc/get_available_arena_prep_rooms(count)
	var/list/available = list()
	for(var/obj/effect/admin_arena_prep_room_marker/marker in active_prep_rooms)
		if(QDELETED(marker) || !isturf(marker.loc))
			continue
		available += marker
		if(available.len >= count)
			break
	return available

// Marks the location of a prep room where contestants are teleported to before fighting.
/obj/effect/admin_arena_prep_room_marker
	name = "admin arena prep room marker"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	invisibility = INVISIBILITY_MAXIMUM + 1

/obj/effect/admin_arena_prep_room_marker/Destroy()
	active_prep_rooms -= src
	return ..()







/datum/admin_arena
	var/turf/bottom_left

/datum/admin_arena/New(turf/bl)
	src.bottom_left = bl
	if(current_admin_arena)
		qdel(current_admin_arena)
	current_admin_arena = src

/datum/admin_arena/Destroy()
	if(current_admin_arena == src)
		current_admin_arena = null
	return ..()

// Loads a map into the arena location. Currently hardcoded to only allow 15x9 arenas, the size of robust tournament arenas.
// Returns whether it was successful
/datum/admin_arena/proc/load_from_dmm(dmm_file as file)
	var/list/dimensions = maploader.get_map_dimensions(dmm_file)
	if(dimensions[1] != ADMIN_ARENA_WIDTH || dimensions[2] != ADMIN_ARENA_HEIGHT)
		return FALSE

	clear_arena()
	var/list/spawned_atoms = maploader.load_map(dmm_file, bottom_left.z, bottom_left.x - 1, bottom_left.y - 1, null, 0, TRUE, 0, INFINITY, 0, INFINITY, 0, INFINITY)
	// Calling spawned_by_map_element makes sure we do all initialization.
	for(var/atom/A in spawned_atoms)
		A.spawned_by_map_element(null, spawned_atoms)
	return TRUE

/datum/admin_arena/proc/clear_arena()
	var/list/turfs = get_arena_turfs()
	for(var/turf/T in turfs)
		for(var/atom/movable/AM in T)
			if(istype(AM, /mob/dead/observer))
				continue
			qdel(AM)
		T.ChangeTurf(get_base_turf(T.z))

// Finds the first spawn marker of the given type inside the arena, if any.
/datum/admin_arena/proc/find_spawn_marker(marker_type)
	for(var/turf/T in get_arena_turfs())
		var/obj/effect/admin_arena_spawn/marker = locate(marker_type) in T
		if(marker)
			return marker
	return null

/datum/admin_arena/proc/get_arena_turfs()
	var/turf/top_right = locate(bottom_left.x + ADMIN_ARENA_WIDTH - 1, bottom_left.y + ADMIN_ARENA_HEIGHT - 1, bottom_left.z)
	return block(bottom_left, top_right)










// Marks where a competitor spawns, spawn number tells them apart.
/obj/effect/admin_arena_spawn
	name = "admin arena spawn point"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	invisibility = INVISIBILITY_MAXIMUM + 1
	var/spawn_number

/obj/effect/admin_arena_spawn/one
	spawn_number = 1

/obj/effect/admin_arena_spawn/two
	spawn_number = 2



// Invisible wall blocking competitors before roundstart.
/obj/effect/admin_arena_barrier
	name = "admin arena barrier"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	density = 1
	invisibility = INVISIBILITY_MAXIMUM + 1
