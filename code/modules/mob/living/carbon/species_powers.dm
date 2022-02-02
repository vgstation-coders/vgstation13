
/spell/targeted/genetic/invert_eyes
	name = "Invert eyesight"
	desc = "Inverts the colour spectrum you see, letting you see clearly in the dark, but not in the light."
	panel = "Mutant Powers"
	user_type = USER_TYPE_GENETIC
	range = SELFCAST

	charge_type = Sp_RECHARGE

	spell_flags = INCLUDEUSER

	invocation_type = SpI_NONE

	override_base = "genetic"
	hud_state = "wiz_sleepold"


/spell/targeted/genetic/invert_eyes/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/M in targets)
		var/datum/organ/internal/eyes/mushroom/E = M.internal_organs_by_name["eyes"]
		if(istype(E))
			E.dark_mode = !E.dark_mode

/spell/targeted/genetic/fungaltelepathy
	name = "Fungal telepathy"
	desc = "Allows you to remotely speak to another being. You must either hear them speak or examine them to make contact."
	panel = "Mutant Powers"
	user_type = USER_TYPE_GENETIC
	charge_type = Sp_RECHARGE
	charge_max = 50
	invocation_type = SpI_NONE
	range = GLOBALCAST //the world
	max_targets = 1
	selection_type = "view"
	spell_flags = SELECTABLE|TALKED_BEFORE|INCLUDEUSER
	override_base = "genetic"
	hud_state = "gen_project"
	compatible_mobs = list(/mob/living/carbon/human, /datum/mind)
	mind_affecting = 1

/spell/targeted/genetic/fungaltelepathy/cast(var/list/targets, mob/living/carbon/human/user)
	if(!user || !istype(user))
		return

	if(user.mind.miming)
		to_chat(user, "<span class = 'warning'>You find yourself unable to convey your thoughts outside of gestures.</span>")
		return

	for(var/T in targets)
		var/mob/living/target
		if (isliving(T))
			target = T
		if (istype (T, /datum/mind))
			target = user.can_mind_interact(T)
		if(!T || !istype(target) || tinfoil_check(target))
			return
		to_chat(user, "<span class = 'notice'>You orient your mind toward [target].</span>")
		var/datum/species/mushroom/M = user.species
		if(!istype(M))
			return
		M.telepathic_target = target