/spell/shapeshift
	name = "Shapeshift"
	desc = "You change into your true form, granting you better vision, and obfuscating technology."
	abbreviation = "SS"
	still_recharging_msg = "<span class='warning'>We are not ready to do that!</span>"
	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_max = 200
	cooldown_min = 20 SECONDS
	spell_flags = NEEDSHUMAN

	charge_type = Sp_RECHARGE
	invocation_type = SpI_NONE
	range = 0

	override_base = "vamp"
	hud_state = "vamp_shapeshift"
	var/datum/dna/identity = null
	var/datum/human_appearance/appearance = null
	var/humanform = TRUE

/spell/shapeshift/cast_check(skipcharge = 0, mob/user = usr)
	. = ..()
	if (!.)
		return FALSE

/spell/shapeshift/choose_targets(var/mob/user = usr)
	return list(user) // Self-cast

/spell/shapeshift/cast(var/list/targets, var/mob/living/carbon/human/user)
	if(humanform)
		identity = user.dna.Clone()
		appearance = user.my_appearance.Copy()
		user.set_species("Vampire")
		user.name = "Nosferatu"
		user.real_name = "Nosferatu"
		humanform = FALSE
	else
		user.set_species(identity.species, 0)
		user.set_default_language(user.init_language)
		user.name = identity.real_name
		user.real_name = identity.real_name
		user.dna = identity
		humanform = TRUE
	user.UpdateAppearance()
	user.update_perception()
	user.update_name()
	..()
