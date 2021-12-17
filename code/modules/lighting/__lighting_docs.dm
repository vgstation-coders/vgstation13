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
		- In complete darkness, the players can lift byond darkness by their built-in "seeindark" var.
		- On top of that, the dark "Europa" plane is broken with a self-vision circle.

	- The actual lighting effect is handled in light_effect_cast.dm, documented, and divided into easy to edit functions for every bit of interaction.

	- Moody light types and properties are stored in light_types.dm
*/

/*
Relevant vars/procs:

atom: (lighting_atom.dm)
  - var/light_range; range in tiles of the light, used for calculating falloff
  - var/light_power; multiplier for the brightness of lights
  - var/light_color; hex string representing the RGB colour of the light
  - var/light_type; define controlling how the light behaves. Current options are soft or flickering.

  - var/atom/movable/light/light_obj; light source object for this atom, only present if light_range && light_power
  - var/atom/movable/light/shadow/shadow_obj; wall shadow source object for this atom, with TILE_BOUND to prevent it from bleeding over other walls

	NB: this means that the object casts its light twice, one for the people who can see it, another for those who can't.
    NB2: due to additive colour mixing, this means a normal colour would be shifted to white. To prevent this, light atoms have RGB numbers halved.
	.... when they recombine, we see the original light.

  - var/moody_light_type; light type of the "glowing mask" on top of the atom. This mask is in 'icons/lighting/special.dmi'.
    use the icon_sate correspondoing to 'overlay[overlay_state]'. Black pixels are not glowing, transparent pixels (0 alpha) emit light.
	See examples. An object with a non-void moody_light type should not cast light.

  - var/lighting_flags; essentially controlling the behaviour of moody_lights for now.
    FOLLOW_PIXEL_OFFSET means the moody_light will have the same pixel offset as the atom.
	NO_LUMINOSITY means the moody_light will only lift byond darkness on the tile it is illuminating (instead of 3 times that)
	IS_LIGHT_SOURCE is a flag on non-lightbulbs items emitting a large light object.
	An atom with IS_LIGHT_SOURCE or a moody light will create its light object on startup.


  - proc/set_light(l_range, l_power, l_color):
	  - Sets light_range/power/color to non-null args and calls update_light()
  - proc/set_opacity(new_opacity):
	  - Sets opacity to new_opacity.
  - proc/update_light():
	  - Updates the light var on this atom, deleting or creating as needed and calling .update()


turf: (lighting_turf.dm)

  - proc/get_lumcount(var/minlum = 0, var/maxlum = 10)
  	  - Returns an integer according to the amount of lums on a turf's overlay (also averages them)
  	  - With default arguments (based on the fact that 0 = pitch black and 10 = full bright), it will return .5 for a 50% lit tile.
	  - To be checked for bugs.
*/
