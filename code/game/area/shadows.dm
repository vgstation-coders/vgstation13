#define SHADOW_DIRECTION 180-25
#define SHADOW_PIXEL_X_DIVISOR 5.1
#define SHADOW_PIXEL_Y_DIVISOR 1.3
#define SHADOW_ALPHA 80

/atom/movable/proc/has_shadow()
	return density // If something has density, we can assume it's A) not on the ground and B) large enough to cast a shadow. Bit of a hacky way to do it, but better than writing an exception for everything

/obj/structure/closet/has_shadow()
	return 1

/mob/living/carbon/has_shadow()
	if(lying)
		return 0
	. = ..()

/atom/movable/proc/update_shadow()
	if(!has_shadow())
		return

	if(shadow)
		underlays -= shadow
	else
		shadow = new

	shadow.appearance = appearance
	shadow.alpha = SHADOW_ALPHA
	shadow.color = "#000000"
	shadow.appearance_flags = KEEP_TOGETHER
	shadow.mouse_opacity = 0

	var/matrix/M = matrix()
	M.Scale(-1,1)
	M.Turn(SHADOW_DIRECTION)
	shadow.transform = M
	apply_shadow()

/atom/movable/proc/apply_shadow() // should work for most standard shaped objects - when it doesn't, override this proc. thanks OOP
	var/icon/I = new/icon(icon,icon_state) //Used to calculate the size of the object
	shadow.pixel_y -= I.Height()/SHADOW_PIXEL_Y_DIVISOR // this should not require pixel multiplier
	shadow.pixel_x += I.Width()/SHADOW_PIXEL_X_DIVISOR // this should not require pixel multiplier
	underlays += shadow

/obj/structure/flora/tree/pine/apply_shadow()
	shadow.pixel_y = -74*PIXEL_MULTIPLIER
	shadow.pixel_x = 16*PIXEL_MULTIPLIER
	underlays += shadow

/obj/shadow
	plane = ABOVE_HUMAN_PLANE
	layer = SHADOW_LAYER
	density = 0