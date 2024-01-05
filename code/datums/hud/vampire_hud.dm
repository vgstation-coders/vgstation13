//Vampire Powers Vision Modifiers

/datum/visioneffect/vampire_improved
	name = "improved vampirevision hud"

	vision_flags = SEE_MOBS

/datum/visioneffect/vampire_mature
	name = "mature vampire hud"

	vision_flags = SEE_TURFS|SEE_OBJS
	my_dark_plane_alpha_override = "vampire_vision"
	my_dark_plane_alpha_override_value = 255
	see_in_dark = 8
