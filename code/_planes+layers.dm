//List of all preclaimed planes & layers
//Generally 'arbitrary' planes & layers should be given a constant number
//Planes that are dependent upon another plane or layer value should be defined with that plane or
#define CLICKCATCHER_PLANE -99
#define PLANE_SPACE_BACKGROUND -21
#define PLANE_SPACE_PARALLAX (PLANE_SPACE_BACKGROUND + 1) // -20
#define PLANE_SPACE_DUST (PLANE_SPACE_PARALLAX + 1) // -19

/*
	from stddef.dm

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

#define BELOW_TURF_PLANE -18 			// todo: use this for asteroids to make them be faster

#define TURF_PLANE -17					// For turfs.

#define ABOVE_TURF_PLANE -16				// For items which should appear above turfs but below other objects, eg: wires & pipes

	#define CATWALK_LAYER			0
	#define TURF_FIRE_LAYER			1
	#define DISPOSALS_PIPE_LAYER	2
	#define LATTICE_LAYER			3
	#define PIPE_LAYER				4
	#define WIRE_LAYER				5
	#define RUNE_LAYER				6
	#define WIRE_TERMINAL_LAYER		7
	#define NAV_BEACON_LAYER		8
	#define UNARY_PIPE_LAYER		9
	#define MOUSETRAP_LAYER 		10
	#define FIREAXE_LOCKER_LAYER	11
	#define BED_LAYER				12	// so that hiding mobs are above it.

#define NOIR_BLOOD_PLANE -15			// For blood which is red, will appear to people under the influence of the noir colour matrix.

#define HIDING_MOB_PLANE -14

#define HIDING_HUMAN_PLANE -13

#define OBJ_PLANE -12					// For objects which appear below humans.

	#define DECAL_LAYER				0
	#define TABLE_LAYER				1
	#define BELOW_OBJ_LAYER			2
	// OBJ_LAYER 	 				3
	#define ABOVE_OBJ_LAYER			4
	#define ABOVE_WINDOW_LAYER		5
	#define TURRET_LAYER			6
	#define TURRET_COVER_LAYER		7
	#define DOOR_LAYER  			8
	#define ABOVE_DOOR_LAYER		9
	#define CHAIR_LEG_LAYER			10

#define HUMAN_PLANE 				-11					// For Humans.

// TODO: STOP HUD PLANES BEING CLIENT IMAGES, INSTEAD MAKING THEM CONTROLLED BY PLANESMASTERS

#define VAMP_ANTAG_HUD_PLANE		-10

#define CULT_ANTAG_HUD_PLANE		-9

#define SYNDIE_ANTAG_HUD_PLANE 		-8

#define REV_ANTAG_HUD_PLANE			-7

#define WIZ_ANTAG_HUD_PLANE 		-6

// SERIOUSLY THAT'D BE KINDA COOL - I THINK THAT THE UPDATE PROCS FOR THESE ARE PRETTY HAZARDLY CODED AND THIS'D BE SUPER SIMPLE, CLIENTSIDED AND EFFICIENT.

#define MOB_PLANE 					-5					// For Mobs.
	#define SLIME_LAYER			5

#define ABOVE_HUMAN_PLANE -4			// For things that should appear above humans.
	#define VEHICLE_LAYER 0
	#define CHAIR_ARMREST_LAYER 0

#define BLOB_PLANE 	-3					// For Blobs, which are above humans.
	#define BLOB_SHIELD_LAYER		1
	#define BLOB_RESOURCE_LAYER		2
	#define BLOB_FACTORY_LAYER		3
	#define BLOB_NODE_LAYER			4
	#define BLOB_CORE_LAYER			5
	#define BLOB_SPORE_LAYER		6

#define EFFECTS_PLANE -2				// For special effects.
	#define BELOW_PROJECTILE_LAYER 3
	#define PROJECTILE_LAYER 4
	#define ABOVE_PROJECTILE_LAYER 5
	#define SINGULARITY_LAYER 6
	#define ABOVE_SINGULO_LAYER 7
	#define GRAVITYGRID_LAYER 8
	#define POINTER_LAYER 9

#define LIGHTING_PLANE -1				// For Lighting.
	#define LIGHTBULB_LAYER 0
	#define GHOST_LAYER 2
	#define LIGHTING_LAYER 3
	#define ABOVE_LIGHTING_LAYER 4
	#define SUPERMATTER_WALL_LAYER 5
	#define SUPERMATTER_PORTAL_LAYER 6
	#define NARSIE_GLOW 7

#define BASE_PLANE 0					// Not for anything, but this is the default.

#define STATIC_PLANE 1					// For AI's static.

#define HUD_PLANE 2						// For the Head-Up Display
	#define UNDER_HUD_LAYER 		0
	#define HUD_BASE_LAYER		 	1
	#define HUD_ITEM_LAYER 			2
	#define HUD_ABOVE_ITEM_LAYER 	3
	#define FULLSCREEN_LAYER	 	4
	#define DAMAGE_LAYER 			5
	#define IMPAIRED_LAYER 			6
	#define BLIND_LAYER				7
	#define CRIT_LAYER 				8
	#define HALLUCINATION_LAYER 	9

/image
	plane = FLOAT_PLANE			// this is defunct, lummox fixed this on recent compilers, but it will bug out if I remove it for coders not on the most recent compile.

/atom/proc/hud_layerise()
	plane = HUD_PLANE
	layer = HUD_ITEM_LAYER

/atom/proc/un_hud_layerise()
	plane = initial(plane)
	layer = initial(layer)