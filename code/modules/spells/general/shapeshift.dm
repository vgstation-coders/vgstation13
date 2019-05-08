/spell/shapeshift
	name = "Shapeshift (1)"
	desc = "Changes your name and appearance, either to someone in view or randomly. Has a cooldown of 3 minutes."
	abbreviation = "SS"

	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_type = Sp_RECHARGE
	charge_max = 3 MINUTES
	invocation_type = SpI_NONE
	range = 0
	spell_flags = STATALLOWED | NEEDSHUMAN
	cooldown_min = 3 MINUTES

	override_base = "vamp"
	hud_state = "vamp_shapeshift"

	var/blood_cost = 1

/spell/shapeshift/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE

/spell/shapeshift/choose_targets(var/mob/user = usr)
	return list(user) // Self-cast

/spell/shapeshift/cast(var/list/targets, var/mob/living/carbon/human/user)
	if (!istype(user))
		return FALSE
	var/list/choices = list()
	var/datum/role/vampire/V = isvampire(user)
	choices[V.initial_appearance.name] = V.initial_appearance
	for (var/mob/living/carbon/human/H in view(user) - user)
		choices[H.real_name] = H.my_appearance.Copy()
	for (var/datum/human_appearance/looks in V.saved_appearances)
		choices[looks.name] = looks
	choices["Random"] = ""

	var/choice = input(user, "Which appearance shall we adopt?", "Shapeshift", "Random") as null|anything in choices

	if (!choice)
		return
	else if (choice == "Random")
		var/name = user.generate_name() //random_name(M.current.gender)
		var/datum/human_appearance/new_looks = user.randomise_appearance_for(user.gender)
		new_looks.name = name
		V.saved_appearances += new_looks
	else
		user.switch_appearance(choices[choice])
		user.real_name = choice

	V.remove_blood(blood_cost)