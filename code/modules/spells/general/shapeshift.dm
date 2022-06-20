/spell/shapeshift
	name = "Shapeshift"
	desc = "You change into your true form."
	abbreviation = "SS"
	still_recharging_msg = "<span class='warning'>We are not ready to do that!</span>"
	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_max = 300
	cooldown_min = 30 SECONDS
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
		humanform = FALSE
		user.name = "Nosferatu"
		user.real_name = "Nosferatu"
		user.set_species("Vampire")
		user.UpdateAppearance()
	else
		user.set_species(identity.species, 0)
		user.dna = identity
		user.UpdateAppearance()
		humanform = TRUE
	
	..()