#define HOLD_FLASH_ANIM  "hold"
#define PINCH_FLASH_ANIM "pinch"

/proc/flash_object_animation(var/mob/user, var/obj/item/target, var/hand_shape=HOLD_FLASH_ANIM)
	// Credit to pgmzeta of Goonstation for the base hand flash sprite under CC-BY-NC-SA. Modifications made so that
	// the pixels align better with /vg/'s diagonal card as well as to fit other item shapes.
	var/hand_flash_icon_state
	var/skin_color
	var/pixel_x_offset
	var/pixel_y_offset
	if(user.active_hand == 1)
		hand_flash_icon_state = "[hand_shape]_right"
		pixel_x_offset = -7
		pixel_y_offset = 0
	else
		hand_flash_icon_state = "[hand_shape]_left"
		pixel_x_offset = 5
		pixel_y_offset = 1

	if(ishuman(user))
		var/mob/living/carbon/human/h = user
		skin_color = h.get_skin_color()
		var/equipped_gloves = h.gloves
		if(istype(equipped_gloves, /obj/item/clothing/gloves/yellow))
			skin_color = rgb(255,255,0)
		else if(istype(equipped_gloves, /obj/item/clothing/gloves/black))
			skin_color = rgb(0,0,0)
	else
		skin_color = rgb(255, 202, 149)

	var/image/hand_image = image("icon"='icons/effects/effects.dmi', "icon_state"=hand_flash_icon_state, "layer"=MOB_LAYER+1)
	hand_image.color = skin_color
	hand_image.pixel_x += pixel_x_offset
	hand_image.pixel_y += pixel_y_offset
	user.dir = SOUTH

	var/cached_vis_flags = target.vis_flags
	target.vis_flags |= (VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER)
	target.pixel_x += pixel_x_offset
	target.pixel_y += pixel_y_offset

	user.vis_contents += target
	user.overlays += hand_image

	user.delayNextMove(0.5 SECONDS)
	playsound(user, 'sound/weapons/whip_crack.ogg', 40, 1)

	spawn(5)
		if(user != null)
			user.overlays -= hand_image

		if(target != null)
			if(user != null)
				user.vis_contents -= target
			target.vis_flags = cached_vis_flags
			target.pixel_x -= pixel_x_offset
			target.pixel_y -= pixel_y_offset
