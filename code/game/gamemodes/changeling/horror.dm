/datum/species/horror // /vg/
	name = "Horror"
	icobase = 'icons/mob/human_races/r_horror.dmi'
	deform = 'icons/mob/human_races/r_horror.dmi'  // TODO: Need deform.
	known_languages = list(LANGUAGE_CLATTER)
	attack_verb = "smashes"
	flags = NO_BREATHE /*| NON_GENDERED*/ | NO_PAIN | HYPOTHERMIA_IMMUNE
	anatomy_flags = HAS_SWEAT_GLANDS
	pressure_resistance = 30 * ONE_ATMOSPHERE /*No longer will our ascent be foiled by depressurization!*/
	//h_style = null

	// Yep.
	default_mutations=list(M_HULK)

	cold_level_1 = 0 //Default 260 - Lower is better
	cold_level_2 = 10 //Default 200
	cold_level_3 = 20 //Default 120

	heat_level_1 = 420 //Default 360 - Higher is better
	heat_level_2 = 480 //Default 400
	heat_level_3 = 1100 //Default 1000


	warning_low_pressure = 50
	hazard_low_pressure = 0

	max_hurt_damage = 30 /*It costs 30 points, it should crit in 3 hits.*/

	// Same as disposal
	punch_throw_speed = 1
	punch_throw_range = 10

	throw_mult = 1.5 // +0.5 for hulk
	fireloss_mult = 2 // double the damage, half the fun

	override_icon = 'icons/mob/horror.dmi'
	has_mutant_race = 0
