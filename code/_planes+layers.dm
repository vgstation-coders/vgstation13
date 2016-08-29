/*This file is a list of all preclaimed planes & layers

All planes & layers should be given a value here instead of using a magic/arbitrary number.

After fiddling with planes and layers for some time, I figured I may as well provide some documentation:

What are planes?
	Think of Planes as a sort of layer for a layer - if plane X is a larger number than plane Y, the highest number for a layer in X will be below the lowest
	number for a layer in Y.
	Planes also have the added bonus of having planesmasters.

What are Planesmasters?
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
	All planes above 0, the 'base plane', are visible even when your character cannot 'see' them, for example, the HUD.
	All planes below 0, the 'base plane', are only visible when a character can see them.

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
#define PLANE_SPACE_BACKGROUND -98
#define PLANE_SPACE_PARALLAX (PLANE_SPACE_BACKGROUND + 1) // -97
#define PLANE_SPACE_DUST (PLANE_SPACE_PARALLAX + 1) // -98

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

#define BELOW_TURF_PLANE 		-20 		// objects that are below turfs. Useful for asteroid smoothing or other such magic.
	// todo: use this for asteroids to make them be faster

#define TURF_PLANE 				-19			// For turfs.

	#define TURF_LAYER_MEME_NAME_BECAUSE_CELT_IS_A_FUCKING_RETARD	-999

#define ABOVE_TURF_PLANE 		-18			// For items which should appear above turfs but below other objects and hiding mobs, eg: wires & pipes

	#define CATWALK_LAYER			0
	#define DECAL_LAYER				1
	#define TURF_FIRE_LAYER			2
	#define DISPOSALS_PIPE_LAYER	3
	#define LATTICE_LAYER			4
	#define PIPE_LAYER				5
	#define WIRE_LAYER				6
	#define RUNE_LAYER				7
	#define WIRE_TERMINAL_LAYER		8
	#define ABOVE_TILE_LAYER		9
	#define UNARY_PIPE_LAYER		10
	#define BINARY_PIPE_LAYER		11
	#define MOUSETRAP_LAYER 		12
	#define FIREAXE_LOCKER_LAYER	13
	#define BLOOD_LAYER				14
	#define WEED_LAYER				15


#define NOIR_BLOOD_PLANE 		-17		 	// For blood which is red, will appear to people under the influence of the noir colour matrix. -if changing this, make sure that the blood layer changes too.

#define HIDING_MOB_PLANE 		-16			// for hiding mobs like MoMMIs or spiders or whatever, under most objects but over pipes & such.

#define OBJ_PLANE 				-15			// For objects which appear below humans.

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

#define LYING_MOB_PLANE			-14			// other mobs that are lying down.

#define LYING_HUMAN_PLANE 		-13			// humans that are lying down

#define ABOVE_OBJ_PLANE			-12			// for objects that are below humans when they are standing but above them when they are not. - eg, blankets.
	#define BLANKIES_LAYER			0
	#define FACEHUGGER_LAYER		1

#define HUMAN_PLANE 			-11			// For Humans that are standing up.

// TODO: STOP HUD PLANES BEING CLIENT IMAGES, INSTEAD MAKING THEM CONTROLLED BY PLANESMASTERS

#define VAMP_ANTAG_HUD_PLANE	-10

#define CULT_ANTAG_HUD_PLANE	-9

#define SYNDIE_ANTAG_HUD_PLANE 	-8

#define REV_ANTAG_HUD_PLANE		-7

#define WIZ_ANTAG_HUD_PLANE 	-6

// SERIOUSLY THAT'D BE KINDA COOL - I THINK THAT THE UPDATE PROCS FOR THESE ARE PRETTY HAZARDLY CODED AND THIS'D BE SUPER SIMPLE, CLIENTSIDED AND EFFICIENT.

#define MOB_PLANE 				-5			// For Mobs.

//	#define MOB_LAYER				4
	#define SLIME_LAYER				5

#define ABOVE_HUMAN_PLANE 		-4			// For things that should appear above humans.

	#define VEHICLE_LAYER 			0
	#define CHAIR_ARMREST_LAYER 	0
	#define OPEN_CURTAIN_LAYER		1
	// BELOW_OBJ_LAYER				2
	// OBJ_LAYER 	 				3
	// ABOVE_OBJ_LAYER				4
	#define CLOSED_CURTAIN_LAYER	5

#define BLOB_PLANE 				-3			// For Blobs, which are above humans.

	#define BLOB_SHIELD_LAYER		1
	#define BLOB_RESOURCE_LAYER		2
	#define BLOB_FACTORY_LAYER		3
	#define BLOB_NODE_LAYER			4
	#define BLOB_CORE_LAYER			5
	#define BLOB_SPORE_LAYER		6

#define EFFECTS_PLANE 			-2			// For special effects.

	#define BELOW_PROJECTILE_LAYER 	3
	#define PROJECTILE_LAYER 		4
	#define ABOVE_PROJECTILE_LAYER 	5
	#define SINGULARITY_LAYER 		6
	#define ABOVE_SINGULO_LAYER 	7
	#define GRAVITYGRID_LAYER 		8

#define LIGHTING_PLANE 			-1			// For Lighting. - The highest plane.

	#define LIGHTBULB_LAYER 		0
	#define POINTER_LAYER 			1
	#define GHOST_LAYER 			2
	#define LIGHTING_LAYER 			3
	#define ABOVE_LIGHTING_LAYER 	4
	#define SUPERMATTER_WALL_LAYER 	5
	#define SUPER_PORTAL_LAYER		6
	#define NARSIE_GLOW 			7

#define BASE_PLANE 				0		// Not for anything, but this is the default.
	#define AREA_LAYER_MEME_NAME_BECAUSE_CELT_IS_A_FUCKING_RETARD 999

#define STATIC_PLANE 			1		// For AI's static.

#define FULLSCREEN_PLANE		2		// for fullscreen overlays that do not cover the hud.

	#define FULLSCREEN_LAYER	 	0
	#define DAMAGE_LAYER 			1
	#define IMPAIRED_LAYER 			2
	#define BLIND_LAYER				3
	#define CRIT_LAYER 				4
	#define HALLUCINATION_LAYER 	5

#define HUD_PLANE 				3		// For the Head-Up Display

	#define UNDER_HUD_LAYER 		0
	#define HUD_BASE_LAYER		 	1
	#define HUD_ITEM_LAYER 			2
	#define HUD_ABOVE_ITEM_LAYER 	3


/image
	plane = FLOAT_PLANE			// this is defunct, lummox fixed this on recent compilers, but it will bug out if I remove it for coders not on the most recent compile.

/atom/proc/hud_layerise()
	plane = HUD_PLANE
	layer = HUD_ITEM_LAYER

/atom/proc/reset_plane_and_layer()
	plane = initial(plane)
	layer = initial(layer)