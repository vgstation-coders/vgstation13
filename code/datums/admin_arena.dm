#define ADMIN_ARENA_WIDTH 15
#define ADMIN_ARENA_HEIGHT 9

// Right now for simplicity there's only one admin arena at a time.
var/global/datum/admin_arena/current_admin_arena
var/global/list/active_prep_rooms = list()

/datum/admin_arena
	var/turf/bottom_left

/datum/admin_arena/New(turf/bl)
	. = ..()
	bottom_left = bl
	if(current_admin_arena)
		qdel(current_admin_arena)
	current_admin_arena = src

/datum/admin_arena/Destroy()
	if(current_admin_arena == src)
		current_admin_arena = null
	return ..()

// Loads a map into the arena location. Currently hardcoded to only allow 15x9 arenas, the size of robust tournament arenas.
/datum/admin_arena/proc/load_from_dmm(dmm_file as file)
	var/list/dimensions = maploader.get_map_dimensions(dmm_file)
	if(dimensions[1] != ADMIN_ARENA_WIDTH || dimensions[2] != ADMIN_ARENA_HEIGHT)
		return FALSE

	maploader.load_map(dmm_file, bottom_left.z, bottom_left.x - 1, bottom_left.y - 1, null, 0, TRUE, 0, INFINITY, 0, INFINITY, 0, INFINITY)
	return TRUE

// Marks the given location as a prep room and potentially uses it for future rounds.
/datum/admin_arena/proc/add_prep_room(turf/location)
	var/obj/effect/admin_arena_prep_room_marker/marker = new(location)
	active_prep_rooms += marker
	return marker

/area/admin_arena
	name = "Admin Arena"
	flags = NO_PERSISTENCE|NO_PACIFICATION





// Marks the location of a prep room where contestants are teleported to before fighting.
/obj/effect/admin_arena_prep_room_marker
	name = "admin arena prep room marker"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	invisibility = INVISIBILITY_MAXIMUM + 1

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
