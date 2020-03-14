/*This file is a list of all preclaimed planes & layers

All planes & layers should be given a value here instead of using a magic/arbitrary number.

After fiddling with planes and layers for some time, I figured I may as well provide some documentation:

What are planes?
	Think of Planes as a sort of layer for a layer - if plane X is a larger number than plane Y, the highest number for a layer in X will be below the lowest
	number for a layer in Y.
	Planes also have the added bonus of having planesmasters.

What are Planesmasters?
	Planesmasters render all objects of the plane on the one object.
	Planesmasters, when in the sight of a player, will have its appearance properties (for example, colour matrices, alpha, transform, etc)
	applied to all the other objects in the plane. This is all client sided.
	Usually you would want to add the planesmaster as an invisible image in the client's screen.

What can I do with Planesmasters?
	You can: Make certain players not see an entire plane,
	Make an entire plane have a certain colour matrices,
	Make an entire plane transform in a certain way,
	Make players see a plane which is hidden to normal players - I intend to implement this with the antag HUDs for example.
	Planesmasters can be used as a neater way to deal with client images or potentially to do some neat things

How do planes work?
	A plane can be any integer from -100 to 100. (If you want more, bug lummox.)
	SEE_BLACKNESS means that blackness is drawn on plane = 0.
	That's why anything we might feasibly want to have drawn above blackness if the player can see it is above 0, and anything we don't (rare) is drawn below 0.
	Basically, they exist to be manipulated by planesmasters.

How do I add a plane?
	Think of where you want the plane to appear, look through the pre-existing planes and find where it is above and where it is below
	Slot it in in that place, and change the pre-existing planes, making sure no plane shares a number.
	Add a description with a comment as to what the plane does.

How do I make something a planesmaster?
	Add the PLANE_MASTER appearance flag to the appearance_flags variable.

What is the naming convention for planes or layers?
	Make sure to use the name of your object before the _LAYER or _PLANE, eg: [NAME_OF_YOUR_OBJECT HERE]_LAYER or [NAME_OF_YOUR_OBJECT HERE]_PLANE
	Also, as it's a define, it is standard practice to use capital letters for the variable so people know this.

*/



#define CLICKCATCHER_PLANE -99
#define SPACE_BACKGROUND_PLANE -98
#define SPACE_PARALLAX_PLANE (SPACE_BACKGROUND_PLANE + 1) // -97
#define SPACE_DUST_PLANE (SPACE_PARALLAX_PLANE + 1) // -96
#define ABOVE_PARALLAX_PLANE (SPACE_BACKGROUND_PLANE + 3) // -95

/*
	from stddef.dm, planes & layers built into byond.

	FLOAT_LAYER = -1
	AREA_LAYER = 1
	TURF_LAYER = 2
	OBJ_LAYER = 3
	MOB_LAYER = 4
	FLY_LAYER = 5
	EFFECTS_LAYER = 5000
	TOPDOWN_LAYER = 10000
	BACKGROUND_LAYER = 20000
	EFFECTS_LAYER = 5000
	TOPDOWN_LAYER = 10000
	BACKGROUND_LAYER = 20000
	------

	FLOAT_PLANE = -32767
*/

#define PLATING_PLANE 			-4

#define ABOVE_PLATING_PLANE		-3

	#define CATWALK_LAYER			2
	#define DISPOSALS_PIPE_LAYER	3
	#define LATTICE_LAYER			4
	#define PIPE_LAYER				5
	#define WIRE_LAYER				6
	#define VENT_BEZEL_LAYER		7
	#define WIRE_TERMINAL_LAYER		8

#define FLOOR_PLANE -2

#define BELOW_TURF_PLANE 		-1 		// objects that are below turfs and darkness but above platings. Useful for asteroid smoothing or other such magic.
	#define CORNER_LAYER 		2
	#define SIDE_LAYER			3

#define BASE_PLANE 				0		//  this is where darkness is! see "how planes work" - needs SEE_BLACKNESS or SEE_PIXEL (see blackness is better for ss13)

#define TURF_PLANE				1
	#define MAPPING_TURF_LAYER		-999

#define ABOVE_TURF_PLANE 		2			// For items which should appear above turfs but below other objects and hiding mobs, eg: wires & pipes

	#define HOLOMAP_LAYER				1
	#define RUNE_LAYER					2
	#define DECAL_LAYER					3
	#define SNOWPRINT_LAYER				4
	#define TURF_FIRE_LAYER				5
	#define ABOVE_TILE_LAYER			6
	#define UNARY_PIPE_LAYER			7
	#define TRINARY_PIPE_LAYER			8
	#define BINARY_PIPE_LAYER			9
	#define EXPOSED_PIPE_LAYER			10
	#define EXPOSED_UNARY_PIPE_LAYER	11
	#define EXPOSED_TRINARY_PIPE_LAYER	12
	#define EXPOSED_BINARY_PIPE_LAYER	13
	#define SNOW_LAYER					14
	#define MOUSETRAP_LAYER 			15
	#define FIREAXE_LOCKER_LAYER		16
	#define BLOOD_LAYER					17
	#define GIBS_OVERLAY_LAYER			18 //Holy fuck I'm so fucking mad it took me this long to figure it out. If you suspect an overlay isn't showing TRY GIVING IT A REALLY HIGH LAYER
	#define CREEPER_LAYER				19
	#define WEED_LAYER					420

#define NOIR_BLOOD_PLANE 		3		 	// For blood which is red, will appear to people under the influence of the noir colour matrix. -if changing this, make sure that the blood layer changes too.

#define HIDING_MOB_PLANE 		4			// for hiding mobs like MoMMIs or spiders or whatever, under most objects but over pipes & such.

#define OBJ_PLANE 				5			// For objects which appear below humans.

	#define BELOW_TABLE_LAYER		0
	#define TABLE_LAYER				0.5
	#define OPEN_DOOR_LAYER			1
	#define BELOW_OBJ_LAYER			2
	#define MACHINERY_LAYER			2.5
	// OBJ_LAYER 	 				3
	#define ABOVE_OBJ_LAYER			4
	#define SIDE_WINDOW_LAYER		5
	#define FULL_WINDOW_LAYER		6
	#define ABOVE_WINDOW_LAYER		7
	#define TURRET_LAYER			8
	#define TURRET_COVER_LAYER		9
	#define BELOW_CLOSED_DOOR_LAYER	10
	#define CLOSED_DOOR_LAYER  		11
	#define ABOVE_DOOR_LAYER		12
	#define CHAIR_LEG_LAYER			13

#define LYING_MOB_PLANE			6			// other mobs that are lying down.

#define LYING_HUMAN_PLANE 		7			// humans that are lying down

#define ABOVE_OBJ_PLANE			8			// for objects that are below humans when they are standing but above them when they are not. - eg, blankets.
	#define BLANKIES_LAYER			0
	#define FACEHUGGER_LAYER		1

#define HUMAN_PLANE 			9			// For Humans that are standing up.

#define VAMP_ANTAG_HUD_PLANE	10

#define METABUDDY_HUD_PLANE	11

#define ANTAG_HUD_PLANE		 	12

//#define THIS_SPACE_FOR_RENT!	13

//#define THIS_SPACE_FOR_RENT! 	14

#define MOB_PLANE 				15			// For Mobs.

//	#define MOB_LAYER				4
	#define SLIME_LAYER				5

#define ABOVE_HUMAN_PLANE 		16			// For things that should appear above humans.

	#define SHADOW_LAYER			0
	#define VEHICLE_LAYER 			0
	#define CHAIR_ARMREST_LAYER 	0
	#define WINDOOR_LAYER 			1
	#define OPEN_CURTAIN_LAYER		2
	// BELOW_OBJ_LAYER				2
	// OBJ_LAYER 	 				3
	// ABOVE_OBJ_LAYER				4
	#define CLOSED_CURTAIN_LAYER	5

#define BLOB_PLANE 				17			// For Blobs, which are above humans.

	#define BLOB_BASE_LAYER			0
	#define BLOB_SHIELD_LAYER		1
	#define BLOB_RESOURCE_LAYER		2
	#define BLOB_FACTORY_LAYER		3
	#define BLOB_NODE_LAYER			4
	#define BLOB_CORE_LAYER			5
	#define BLOB_SPORE_LAYER		6

#define EFFECTS_PLANE 			18			// For special effects.

	#define BELOW_PROJECTILE_LAYER 	3
	#define PROJECTILE_LAYER 		4
	#define ABOVE_PROJECTILE_LAYER 	5
	#define SINGULARITY_LAYER 		6
	#define ABOVE_SINGULO_LAYER 	7
	#define GRAVITYGRID_LAYER 		8
	#define SNOW_OVERLAY_LAYER		9

#define GHOST_PLANE 			19			// Ghosts show up under lighting, HUD etc.

	#define GHOST_LAYER 			1

#define LIGHTING_PLANE 			20

	#define LIGHTBULB_LAYER 		0
	#define POINTER_LAYER 			1
	#define LIGHTING_LAYER 			2
	#define ABOVE_LIGHTING_LAYER 	3
	#define SUPERMATTER_WALL_LAYER 	4
	#define SUPER_PORTAL_LAYER		5
	#define NARSIE_GLOW 			6

#define ABOVE_LIGHTING_PLANE		21
	#define MAPPING_AREA_LAYER	999

#define STATIC_PLANE 			22		// For AI's static.

	#define STATIC_LAYER			1
	#define REACTIVATE_CAMERA_LAYER	2

#define FULLSCREEN_PLANE		23		// for fullscreen overlays that do not cover the hud.

	#define FULLSCREEN_LAYER	 	0
	#define DAMAGE_HUD_LAYER 			1
	#define IMPAIRED_LAYER 			2
	#define BLIND_LAYER				3
	#define CRIT_LAYER 				4
	#define HALLUCINATION_LAYER 	5

#define HUD_PLANE 				24		// For the Head-Up Display

	#define UNDER_HUD_LAYER 		0
	#define HUD_BASE_LAYER		 	1
	#define HUD_ITEM_LAYER 			2
	#define HUD_ABOVE_ITEM_LAYER 	3
	#define ABOVE_HUD_LAYER 		4

#define ABOVE_HUD_PLANE 				25		// For being above the Head-Up Display


/atom/proc/hud_layerise()
	plane = HUD_PLANE
	layer = HUD_ITEM_LAYER

/atom/proc/reset_plane_and_layer()
	plane = initial(plane)
	layer = initial(layer)

// returns a list with the objects sorted depending on their layer, with the lowest objects being the first in the list and the highest objects being last
/proc/plane_layer_sort(var/list/to_sort)
	var/list/sorted = list()
	for(var/current_atom in to_sort)
		var/compare_index
		for(compare_index = sorted.len, compare_index > 0, --compare_index) // count down from the length of the list to zero.
			var/atom/compare_atom = sorted[compare_index] // compare to the next object down the list.
			if(compare_atom.plane < current_atom:plane) // is this object below our current atom?
				break
			else if((compare_atom.plane == current_atom:plane) && (compare_atom.layer <= current_atom:layer))	// is this object below our current atom?
				break
		sorted.Insert(compare_index+1, current_atom) // insert it just above the atom it was higher than - or at the bottom if it was higher than nothing.
	return sorted // return the sorted list.


/obj/abstract/screen/plane_master
	appearance_flags = PLANE_MASTER
	screen_loc = "CENTER,CENTER"
	icon_state = "blank"
	globalscreen = 1

// CLICKMASTER
// Singleton implementation
// One planemaster for everybody, everybody always has it, they gain it during mob/login()
/obj/abstract/screen/plane_master/clickmaster
	plane = BASE_PLANE
	mouse_opacity = 0

var/obj/abstract/screen/plane_master/clickmaster/clickmaster = new()

/obj/abstract/screen/plane_master/clickmaster_dummy
	// this avoids a bug which means plane masters which have nothing to control get angry and mess with the other plane masters out of spite
	alpha = 0
	appearance_flags = 0
	plane = BASE_PLANE

var/obj/abstract/screen/plane_master/clickmaster_dummy/clickmaster_dummy = new()

// NOIR
// Immutable, so we use a singleton implementation
// (only one planemaster for everybody, they gain or lose the unique planemaster depending on whether they want the effect or not)
/obj/abstract/screen/plane_master/noir_master
	plane = NOIR_BLOOD_PLANE
	color = list(1,0,0,0,
				 0,1,0,0,
				 0,0,1,0,
				 0,0,0,1)
	appearance_flags = NO_CLIENT_COLOR|PLANE_MASTER

/obj/abstract/screen/plane_master/noir_dummy
	// this avoids a bug which means plane masters which have nothing to control get angry and mess with the other plane masters out of spite
	alpha = 0
	appearance_flags = 0
	plane = NOIR_BLOOD_PLANE

var/noir_master = list(new /obj/abstract/screen/plane_master/noir_master(),new /obj/abstract/screen/plane_master/noir_dummy())

// GHOST PLANEMASTER
// One planemaster for each client, which they gain during mob/login()
// By default their planemaster has no changes, if we modify a person's planemaster, it will affect only them
/obj/abstract/screen/plane_master/ghost_planemaster
	plane = GHOST_PLANE

/obj/abstract/screen/plane_master/ghost_planemaster_dummy
	// this avoids a bug which means plane masters which have nothing to control get angry and mess with the other plane masters out of spite
	alpha = 0
	appearance_flags = 0
	plane = GHOST_PLANE

/client/proc/initialize_ghost_planemaster()
	//We want to explicitly reset the planemaster's visibility on login() so if you toggle ghosts while dead you can still see cultghosts if revived etc.
	if(ghost_planemaster)
		screen -= ghost_planemaster
		qdel(ghost_planemaster)
	if(ghost_planemaster_dummy)
		screen -= ghost_planemaster_dummy
		qdel(ghost_planemaster_dummy)
	ghost_planemaster = getFromPool(/obj/abstract/screen/plane_master/ghost_planemaster)
	screen |= ghost_planemaster
	ghost_planemaster_dummy = getFromPool(/obj/abstract/screen/plane_master/ghost_planemaster_dummy)
	screen |= ghost_planemaster_dummy
