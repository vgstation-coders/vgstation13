#define FLASH_ID_ANIM  "flash_id_anim"
#define FLASH_BADGE_ANIM "flash_badge_anim"
#define FLASH_BADGE_CORD_ANIM "flash_badge_cord_anim"


var/flash_pixel_offsets = list(
	"base"=list(
		FLASH_ID_ANIM=list(
			"hand_shape" = "id",
			"left"  = list("x"=  4, "y" =  -3),
			"right" = list("x"= -5, "y" =  0)
		),
		FLASH_BADGE_ANIM=list(
			"hand_shape" = "badge",
			"left"  = list("x"=  7, "y" =  -1),
			"right" = list("x"= -7, "y" =  -2)
		),
		FLASH_BADGE_CORD_ANIM=list(
			"hand_shape" = "badge",
			"left"  = list("x"=  7, "y" =  -1),
			"right" = list("x"= -7, "y" =  -2)
		)
	),
	"vox"=list(
		FLASH_ID_ANIM=list(
			"hand_shape" = "id",
			"left"  = list("x"=  5, "y" =  -3),
			"right" = list("x"= -5, "y" =  -1)
		),
		FLASH_BADGE_ANIM=list(
			"hand_shape" = "badge",
			"left"  = list("x"=  8, "y" =  -2),
			"right" = list("x"= -7, "y" =  -2)
		),
		FLASH_BADGE_CORD_ANIM=list(
			"hand_shape" = "badge",
			"left"  = list("x"=  8, "y" =  -4),
			"right" = list("x"= -7, "y" =  -6)
		)
	)
)

/proc/flash_object_animation(var/mob/user, var/obj/item/target, var/animation_type=FLASH_ID_ANIM)
	// Credit to pgmzeta of Goonstation for the base hand flash sprite under CC-BY-NC-SA. Modifications made so that
	// the pixels align better with /vg/'s diagonal card as well as to fit other item shapes and other species.
	var/hand_flash_icon_state
	var/pixel_x_offset
	var/pixel_y_offset

	var/species_tag = "base"
	if(isvox(user))
		species_tag = "vox"
	var/hand_shape = flash_pixel_offsets[species_tag][animation_type]["hand_shape"]

	if(user.active_hand == 1)
		hand_flash_icon_state = "hold_[hand_shape]_[species_tag]_right"
		pixel_x_offset = flash_pixel_offsets[species_tag][animation_type]["right"]["x"]
		pixel_y_offset = flash_pixel_offsets[species_tag][animation_type]["right"]["y"]
	else
		hand_flash_icon_state = "hold_[hand_shape]_[species_tag]_left"
		pixel_x_offset = flash_pixel_offsets[species_tag][animation_type]["left"]["x"]
		pixel_y_offset = flash_pixel_offsets[species_tag][animation_type]["left"]["y"]

	var/hand_color = rgb(255, 202, 149)
	if(ishuman(user))
		var/mob/living/carbon/human/h = user

		var/obj/item/equipped_external_suit = h.wear_suit
		if(istype(equipped_external_suit) && equipped_external_suit.body_parts_covered & HANDS)

			hand_color = AverageColor(getFlatIcon(equipped_external_suit))
		else
			var/obj/item/equipped_gloves = h.gloves
			if(istype(equipped_gloves) && equipped_gloves.body_parts_covered & HANDS)
				hand_color = AverageColor(getFlatIcon(equipped_gloves))
			else
				hand_color = h.get_skin_color()

	var/image/hand_image = image("icon"='icons/effects/effects.dmi', "icon_state"=hand_flash_icon_state, "layer"=MOB_LAYER+1)
	hand_image.color = hand_color
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
