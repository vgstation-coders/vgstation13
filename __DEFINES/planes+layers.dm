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

	#define HOLOMAP_LAYER			1 // NOTE: ENSURE this is equal to the one at ABOVE_TURF_PLANE!
	#define CATWALK_LAYER			2
	#define DISPOSALS_PIPE_LAYER	3
	#define LATTICE_LAYER			4
	#define PIPE_LAYER				5
	#define WIRE_LAYER				6
	#define VENT_BEZEL_LAYER		7
	#define WIRE_TERMINAL_LAYER		8

#define FLOOR_PLANE -2

#define BELOW_TURF_PLANE 		-1 		// objects that are below turfs and darkness but above platings. Useful for asteroid smoothing or other such magic.

#define BASE_PLANE 				0		//  this is where darkness is! see "how planes work" - needs SEE_BLACKNESS or SEE_PIXEL (see blackness is better for ss13)

#define TURF_PLANE				1
	#define MAPPING_TURF_LAYER		-999

#define ABOVE_TURF_PLANE 		2			// For items which should appear above turfs but below other objects and hiding mobs, eg: wires & pipes

	#define HOLOMAP_LAYER				1
	#define RUNE_LAYER					2
	#define DECAL_LAYER					3
	#define TURF_FIRE_LAYER				4
	#define ABOVE_TILE_LAYER			5
	#define UNARY_PIPE_LAYER			6
	#define TRINARY_PIPE_LAYER			7
	#define BINARY_PIPE_LAYER			8
	#define EXPOSED_PIPE_LAYER			9
	#define EXPOSED_UNARY_PIPE_LAYER	10
	#define EXPOSED_TRINARY_PIPE_LAYER	11
	#define EXPOSED_BINARY_PIPE_LAYER	12
	#define SNOW_LAYER					13
	#define MOUSETRAP_LAYER 			14
	#define FIREAXE_LOCKER_LAYER		15
	#define BLOOD_LAYER					16
	#define WEED_LAYER					420

#define NOIR_BLOOD_PLANE 		3		 	// For blood which is red, will appear to people under the influence of the noir colour matrix. -if changing this, make sure that the blood layer changes too.

#define HIDING_MOB_PLANE 		4			// for hiding mobs like MoMMIs or spiders or whatever, under most objects but over pipes & such.

#define OBJ_PLANE 				5			// For objects which appear below humans.

	#define BELOW_TABLE_LAYER		0
	#define TABLE_LAYER				0.5
	#define OPEN_DOOR_LAYER			1
	#define BELOW_OBJ_LAYER			2
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

//#define THIS_SPACE_FOR_RENT!	11

#define ANTAG_HUD_PLANE		 	12

//#define THIS_SPACE_FOR_RENT!	13

//#define THIS_SPACE_FOR_RENT! 	14

#define MOB_PLANE 				15			// For Mobs.

//	#define MOB_LAYER				4
	#define SLIME_LAYER				5

#define ABOVE_HUMAN_PLANE 		16			// For things that should appear above humans.

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

#define LIGHTING_PLANE 			19

	#define LIGHTBULB_LAYER 		0
	#define POINTER_LAYER 			1
	#define GHOST_LAYER 			2
	#define LIGHTING_LAYER 			3
	#define ABOVE_LIGHTING_LAYER 	4
	#define SUPERMATTER_WALL_LAYER 	5
	#define SUPER_PORTAL_LAYER		6
	#define NARSIE_GLOW 			7

#define AREA_PLANE				20
	#define MAPPING_AREA_LAYER	999

#define STATIC_PLANE 			21		// For AI's static.

#define FULLSCREEN_PLANE		22		// for fullscreen overlays that do not cover the hud.

	#define FULLSCREEN_LAYER	 	0
	#define DAMAGE_LAYER 			1
	#define IMPAIRED_LAYER 			2
	#define BLIND_LAYER				3
	#define CRIT_LAYER 				4
	#define HALLUCINATION_LAYER 	5

#define HUD_PLANE 				23		// For the Head-Up Display

	#define UNDER_HUD_LAYER 		0
	#define HUD_BASE_LAYER		 	1
	#define HUD_ITEM_LAYER 			2
	#define HUD_ABOVE_ITEM_LAYER 	3

/atom/proc/hud_layerise()
	plane = HUD_PLANE
	layer = HUD_ITEM_LAYER

/atom/proc/reset_plane_and_layer()
	plane = initial(plane)
	layer = initial(layer)

/obj/abstract/screen/plane_master/clickmaster
	plane = BASE_PLANE

var/obj/abstract/screen/plane_master/clickmaster/clickmaster = new()

/obj/abstract/screen/plane_master/clickmaster_dummy
	// this avoids a bug which means plane masters which have nothing to control get angry and mess with the other plane masters out of spite
	alpha = 0
	appearance_flags = 0
	plane = BASE_PLANE

var/obj/abstract/screen/plane_master/clickmaster_dummy/clickmaster_dummy = new()