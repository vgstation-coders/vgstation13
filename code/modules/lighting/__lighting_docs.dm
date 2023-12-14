/*
BS12 object based lighting system
*/

/*
Changes from Goonlights / TG DAL:
  -	Lighting is done using objects instead of subareas.
  - Animated transitions. (currently, alpha flickering)
  - Full colours with mixing.
  - Support for lights on shuttles.
  - Wall lighting no longer bleeds over walls.

  - Code:
	  - Instead of one flat luminosity var, light is represented by 3 atom vars:
		  - light_range; range in tiles of the light, used for calculating falloff,
		  - light_power; multiplier for the brightness of lights,
		  - light_color; hex string representing the RGB colour of the light.
		  - light_type; for now, if it flickers or no.
	  - SetLuminosity() is now set_light() and takes the three variables above.
		  - Variables can be left as null to not update them.
	  - SetOpacity() is now set_opacity().
	  - Objects inside other objects can have lights and they properly affect the turf. (flashlights)

	- Byond obscurity and Europa Obscurity
		- Byond obscurity is binary. Either the full tile is rendered to the client, or they will see an opaque black square.
		- Byond obscurity is "lifted" using the light obj's "luminosity" variable.
		- This luminosity is set higher than light_range.
		- Indeed, if a turf is not "seen" by any lights - out of range of all light sources, the player will be blind and not see the lights, even though they are in range.
		- In other words, you can't see the light if it can't see you.

		- Once byond darkness is lifted, a dark plane of "Europa obscurity" is lifted.
		- The players' dark_plane alpha value shows how far they can see in the dark.

		- In complete darkness, the players can lift byond darkness by their built-in "seeindark" var.
		- On top of that, the dark "Europa" plane is broken with a self-vision circle.
		- The self-vision circle can be made of different shape for different players; it will never bleed through walls.

		- For big light sources, turfs need to have luminosity = 1. See light_effect_cast.dm

	- The actual lighting effect is handled in light_effect_cast.dm, documented, and divided into easy to edit functions for every bit of interaction.

	- Moody light types and properties are stored in light_types.dm.
*/

/*
Relevant vars/procs:

atom: (light_atom.dm)
  - var/light_range; range in tiles of the light, used for calculating falloff
  - var/light_power; multiplier for the brightness of lights
  - var/light_color; hex string representing the RGB colour of the light
  - var/light_type; define controlling how the light behaves. Current options are soft or flickering.

  - var/atom/movable/light/light_obj; light source object for this atom, only present if light_range && light_power
  - var/atom/movable/light/wall_lighting/wall_lighting_obj; wall lighting source object for this atom, with TILE_BOUND to prevent it from bleeding over other walls

  - var/moody_light_type; light type of the "glowing mask" on top of the atom. This mask is in 'icons/lighting/special.dmi'.
    use the icon_sate correspondoing to 'overlay[overlay_state]'. Black pixels are not glowing, transparent pixels (0 alpha) emit light. In between are semi-transparent.

	See examples. An object with a non-void moody_light_type should not cast light, unless you set lighting_flags MOODY_AND_REGULAR_LIGHT_SOURCE

  - var/lighting_flags; essentially controlling the behaviour of moody_lights for now.
    FOLLOW_PIXEL_OFFSET means the moody_light will have the same pixel offset as the atom.
	NO_LUMINOSITY means the moody_light will only lift byond darkness on the tile it is illuminating (instead of 3 times that)
	IS_LIGHT_SOURCE is a flag on non-lightbulbs items emitting a large light object.
	An atom with IS_LIGHT_SOURCE or a moody light will create its light object on startup.
	MOODY_AND_REGULAR_LIGHT_SOURCE is needed for atoms who both cast a main light and a moody light.
	BLOOM allows you to use BYOND's bloom filter (not a lot of difference)

	Procs: (light_atom_set.dm)

  - proc/set_light(l_range, l_power, l_color, l_type):
	  - Sets light_range/power/color to non-null args and updates them if there's a diffetence.
   - proc/kill_light()
      - removes the light atom.

  - proc/set_opacity(new_opacity):
	  - Sets opacity to new_opacity.
  - proc/update_all_lights():
	  - Updates the lights vars (regular, wall, moody) on this atom, deleting or creating as needed and calling .update()
  - proc/update_contained_lights():
	  - Called on Move(); update the lights held by the player in inventory or in hand. Should not be called explicitly.


turf: (light_turf.dm)

  - proc/get_lumcount(var/minlum = 0, var/maxlum = 10)
  	  - Returns an integer according to the amount of lums on a turf's overlay (also averages them)
  	  - With default arguments (based on the fact that 0 = pitch black and 10 = full bright), it will return .5 for a 50% lit tile.
	  - To be checked for bugs.
  - proc/check_blocks_light()
	 - Checks if the turf contains an opaque object. (Wall, windows, curtains...)

mob: (light_mob., light_planes.dm)

  	- var/obj/abstract/screen/plane/master/master_plane
		- The main plane with MASTER_PLANE serving an holder for the lighting system.
		- blend_mode = BLEND_MULTIPLY, regular lighting
		- BLEND_ADD : grue vision. Lights blind you
		- BLEND_SUBSTRACT : mushroom vision. Inverted colours.
	- var/obj/abstract/screen/backdrop/backdrop
		- Internal: needed as the black "backdrop" on which the light sources are drawn.

	- var/obj/abstract/screen/plane/self_vision/self_vision
		- Semi-transparent circle centered on the player, visible by the player only, lifts a bit of darkness around them to make it easier to navigate

	- var/obj/abstract/screen/plane/dark/dark_plane
		- Semi-transparent dark plane below light sources.
		- var/list/alphas = how transparent it is. The biggest alpha value is picked.
		- Example: zombies have an alpha of 90 and can see in the dark relatively well.

	- var/obj/abstract/screen/plane_master/overdark_planemaster/overdark_planemaster
	- var/obj/abstract/screen/overdark_target/overdark_target
		- Use to mask objects outside of the players' FOV.
		- Done internally by setting it as `plane = 0` to "replace" byond's default darkness.


*/
