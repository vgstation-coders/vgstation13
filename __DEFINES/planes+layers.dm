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

Why is FLOAT_PLANE added to a bunch of these?
	So that it renders nicely when in vis_contents, such as below turfs in multi Z, though there are some bad exceptions like gas overlays, noted below.

*/


#define relative_plane(x) (x - plane + FLOAT_PLANE)

#define relative_plane_to_plane(x,y) (x - y + FLOAT_PLANE)


#define CLICKCATCHER_PLANE (-99 + FLOAT_PLANE)
#define SPACE_BACKGROUND_PLANE (-98 + FLOAT_PLANE)
#define SPACE_PARALLAX_PLANE (-97)
#define SPACE_DUST_PLANE (-96)
#define ABOVE_PARALLAX_PLANE (-95)

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

#define PLATING_PLANE 			(-5 + FLOAT_PLANE)

#define ABOVE_PLATING_PLANE		(-4 + FLOAT_PLANE)

	#define CATWALK_LAYER				2
	#define DISPOSALS_PIPE_LAYER		3
	#define LATTICE_LAYER				4
	#define PIPE_LAYER					5
	#define WIRE_LAYER					6
	#define VENT_BEZEL_LAYER			7
	#define WIRE_TERMINAL_LAYER			8
	#define PULSEDEMON_LAYER			9

#define FLOOR_PLANE 			(-3 + FLOAT_PLANE)

#define BELOW_TURF_PLANE 		(-2 + FLOAT_PLANE)		// objects that are below turfs and darkness but above platings. Useful for asteroid smoothing or other such magic.
	#define CORNER_LAYER 				2
	#define SIDE_LAYER					3

#define TURF_PLANE				(-1 + FLOAT_PLANE)
	#define MAPPING_TURF_LAYER			-999

#define GLASSTILE_PLANE			-1						// Another one that won't behave, since it's an overlay

#define ABOVE_TURF_PLANE 		(0 + FLOAT_PLANE)			// For items which should appear above turfs but below other objects and hiding mobs, eg: wires & pipes

	#define HOLOMAP_LAYER				1 //Note: Holomap images are not actually on ABOVE_TURF_PLANE. They are explicitly one plane above the parent turf.
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

#define NOIR_BLOOD_PLANE 		(1 + FLOAT_PLANE)		 	// Contains BLOOD, (ALSO) will appear to people under the influence of the noir colour matrix. -if changing this, make sure that the blood layer changes too.

#define HIDING_MOB_PLANE 		(2 + FLOAT_PLANE)			// for hiding mobs like MoMMIs or spiders or whatever, under most objects but over pipes & such.

#define OBJ_PLANE 				(3 + FLOAT_PLANE)			// For objects which appear below humans.

	#define BELOW_TABLE_LAYER			0
	#define TABLE_LAYER					0.5
	#define OPEN_DOOR_LAYER				1
	#define BELOW_OBJ_LAYER				2
	#define MACHINERY_LAYER				2.5
	// OBJ_LAYER 	 					3
	#define ABOVE_OBJ_LAYER				4
	#define SIDE_WINDOW_LAYER			5
	#define FULL_WINDOW_LAYER			6
	#define ABOVE_WINDOW_LAYER			7
	#define TURRET_LAYER				8
	#define TURRET_COVER_LAYER			9
	#define BELOW_CLOSED_DOOR_LAYER		10
	#define CLOSED_DOOR_LAYER  			11
	#define ABOVE_DOOR_LAYER			12
	#define CHAIR_LEG_LAYER				13

#define LYING_MOB_PLANE			(4 + FLOAT_PLANE)			// other mobs that are lying down.

#define LYING_HUMAN_PLANE 		(5 + FLOAT_PLANE)			// humans that are lying down

#define ABOVE_OBJ_PLANE			(6 + FLOAT_PLANE)			// for objects that are below humans when they are standing but above them when they are not. - eg, blankets.
	#define BLANKIES_LAYER				0
	#define FACEHUGGER_LAYER			1

#define HUMAN_PLANE 			(7 + FLOAT_PLANE)			// For Humans that are standing up.

#define MOB_PLANE 				(8 + FLOAT_PLANE)			// For Mobs.

//	#define MOB_LAYER					4
	#define SLIME_LAYER					5

#define ABOVE_HUMAN_PLANE 		(9 + FLOAT_PLANE)			// For things that should appear above humans.

	#define SHADOW_LAYER				0
	#define VEHICLE_LAYER 				0
	#define CHAIR_ARMREST_LAYER 		0
	#define WINDOOR_LAYER 				1
	#define OPEN_CURTAIN_LAYER			2
	// BELOW_OBJ_LAYER					2
	// OBJ_LAYER 	 					3
	// ABOVE_OBJ_LAYER					4
	#define CLOSED_CURTAIN_LAYER		5
	#define CHAT_LAYER					6

#define BLOB_PLANE 				(10 + FLOAT_PLANE)			// For Blobs, which are above humans.

	#define BLOB_ROOTS_LAYER			-1
	#define BLOB_BASE_LAYER				0
	#define BLOB_SHIELD_LAYER			1
	#define BLOB_RESOURCE_LAYER			2
	#define BLOB_FACTORY_LAYER			3
	#define BLOB_NODE_LAYER				4
	#define BLOB_CORE_LAYER				5
	#define BLOB_SPORE_LAYER			6

#define EFFECTS_PLANE 			(11 + FLOAT_PLANE)			// For special effects.

	#define BELOW_PROJECTILE_LAYER 		3
	#define PROJECTILE_LAYER 			4
	#define ABOVE_PROJECTILE_LAYER 		5
	#define SINGULARITY_LAYER 			6
	#define ABOVE_SINGULO_LAYER 		7
	#define GRAVITYGRID_LAYER 			8
	#define SNOW_OVERLAY_LAYER			9
	#define HORIZON_EXHAUST_LAYER		10
	#define POINTER_LAYER 				11

#define GAS_PLANE 				11					// Gas overlays really hate being in anything except vis_contents when FLOAT_PLANE'D, don't ask

#define GHOST_PLANE 			(12 + FLOAT_PLANE)			// Ghosts show up under lighting, HUD etc.

	#define GHOST_LAYER 				1

								//13	//	THIS PLANE FOR RENT

#define LIGHTING_PLANE 			(14)	// Don't put anything other than lighting_overlays in there please
	#define SELF_VISION_LAYER 		   -1
	#define LIGHTBULB_LAYER 			0
	#define LIGHTING_LAYER 				2
	#define ABOVE_LIGHTING_LAYER 		3
	#define HIGHEST_LIGHTING_LAYER		3.5
	#define ANTI_GLOW_PASS_LAYER		4
	#define ROID_TURF_LIGHT_LAYER 		5

#define ABOVE_LIGHTING_PLANE	(15)
	#define SUPERMATTER_WALL_LAYER 		1
	#define SUPER_PORTAL_LAYER			2
	#define NARSIE_GLOW 				3

	#define MAPPING_AREA_LAYER			999	// Why isn't this a plane exactly?

#define OPEN_OVERLAY_PLANE	(14 + FLOAT_PLANE) // This one won't behave either

#define BASE_PLANE 				(15 + FLOAT_PLANE)		//  this is where darkness is! see "how planes work" - needs SEE_BLACKNESS or SEE_PIXEL (see blackness is better for ss13)

#define LIGHT_SOURCE_PLANE		16	// For Spiders to be able to click them despite being blinded

#define ANTAG_HUD_PLANE		 	17

#define STATIC_PLANE 			18		// For AI's static.

	#define STATIC_LAYER				1
	#define REACTIVATE_CAMERA_LAYER		2

#define FULLSCREEN_PLANE		19		// for fullscreen overlays that do not cover the hud.

	#define FULLSCREEN_LAYER	 		0
	#define DAMAGE_HUD_LAYER 			1
	#define IMPAIRED_LAYER 				2
	#define BLIND_LAYER					3
	#define CRIT_LAYER 					4
	#define HALLUCINATION_LAYER 		5

#define HUD_PLANE 				20		// For the Head-Up Display

	#define UNDER_HUD_LAYER 			0
	#define HUD_BASE_LAYER		 		1
	#define HUD_ITEM_LAYER 				2
	#define HUD_ABOVE_ITEM_LAYER 		3
	#define ABOVE_HUD_LAYER 			4

	#define MIND_UI_BACK 				10
	#define MIND_UI_BUTTON 				11
	#define MIND_UI_FRONT 				12

#define ABOVE_HUD_PLANE 		21		// For being above the Head-Up Display


/atom/proc/hud_layerise()
	plane = HUD_PLANE
	layer = HUD_ITEM_LAYER

/atom/proc/reset_plane_and_layer()
	plane = initial(plane)
	layer = initial(layer)

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
	color = list("#0000",
				 "#0000",
				 "#0000",
				 "#000F",
				 "#A110")//turns everything in the plane to the color human blood. unfortunate side effect is the loss of detail on gibs
	appearance_flags = NO_CLIENT_COLOR|PLANE_MASTER//NO_CLIENT_COLOR sadly doesn't prevent the blood itself from turning grey, which is why it has to be recolored with the above matrix

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
	ghost_planemaster = new /obj/abstract/screen/plane_master/ghost_planemaster
	screen |= ghost_planemaster
	ghost_planemaster_dummy = new /obj/abstract/screen/plane_master/ghost_planemaster_dummy
	screen |= ghost_planemaster_dummy


// OVERDARKNESS PLANEMASTER
// Used to apply darkness over lights that the player isn't supposed to see when the lighting master is set to BLEND_ADD
/obj/abstract/screen/plane_master/overdark_planemaster
	plane = 0

/obj/abstract/screen/plane_master/overdark_planemaster_target
	appearance_flags = 0
	plane = ABOVE_LIGHTING_PLANE
	mouse_opacity = 0
	screen_loc = "CENTER,CENTER"

