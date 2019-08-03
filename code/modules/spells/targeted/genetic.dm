/*
Other mutation or disability spells can be found in
code\game\\dna\genes\vg_powers.dm //hulk is in this file
code\game\\dna\genes\goon_disabilities.dm
code\game\\dna\genes\goon_powers.dm
*/
/spell/targeted/genetic
	name = "Genetic modifier"
	desc = "This spell inflicts a set of mutations and disabilities upon the target."
	user_type = USER_TYPE_GENETIC

	var/disabilities = 0 //bits
	var/list/mutations = list() //mutation strings
	duration = 100 //deciseconds


/spell/targeted/genetic/cast(list/targets)
	..()
	for(var/mob/living/target in targets)
		for(var/x in mutations)
			target.mutations.Add(x)
		target.disabilities |= disabilities
		target.update_mutations()	//update target's mutation overlays
		spawn(duration)
			for(var/x in mutations)
				target.mutations.Remove(x)
			target.disabilities &= ~disabilities
			target.update_mutations()
	return

/spell/targeted/genetic/blind
	name = "Blind"
	desc = "Temporarily blind a single person."
	abbreviation = "BD"
	specialization = OFFENSIVE
	disabilities = 1
	duration = 300

	charge_max = 300

	spell_flags = WAIT_FOR_CLICK
	invocation = "STI KALY"
	invocation_type = SpI_WHISPER
	message = "<span class='danger'>Your eyes cry out in pain!</span>"
	cooldown_min = 50

	range = 7
	max_targets = 1

	amt_eye_blind = 10
	amt_eye_blurry = 20

	hud_state = "wiz_blind"

	price = 0.5 * Sp_BASE_PRICE //Half of the normal spell price
	user_type = USER_TYPE_WIZARD

/spell/targeted/genetic/mutate
	name = "Mutate"
	desc = "This spell causes you to turn into a hulk and gain laser vision for a short while."
	abbreviation = "MU"
	specialization = UTILITY

	school = "transmutation"
	charge_max = 400
	spell_flags = NEEDSCLOTHES | INCLUDEUSER
	invocation = "BIRUZ BENNAR"
	invocation_type = SpI_SHOUT
	message = "<span class='notice'>You feel strong! You feel a pressure building behind your eyes!</span>"
	range = 0
	max_targets = 1

	mutations = list(M_LASER, M_HULK)
	duration = 300
	cooldown_min = 300 //25 deciseconds reduction per rank

	hud_state = "wiz_hulk"
	user_type = USER_TYPE_WIZARD

/spell/targeted/genetic/mutate/highlander
	name = "Become Highlander"
	desc = "Temporarily turn into a mighty highlander who cannot be stunned."
	invocation = "SCOTLAND FOREVER!"
	mutations = list(M_HULK)
	message = "<span class='notice'>You feel powerful! Nobody can take you down! It's time to take some heads!</span>"
	user_type = USER_TYPE_OTHER

/spell/targeted/genetic/eat_weed
	name = "Eat Weeds"
	desc = "Devour weeds from soil or a hydroponics tray, gaining nutriment."
	spell_flags = INCLUDEUSER
	message = ""
	range = 0
	duration = 0
	max_targets = 1
	//mutations = list(M_EATWEEDS) - Some day, maybe, if this is ported to Diona nymphs instead of a verb
	hud_state = "ambrosiavulgaris"
	override_icon = 'icons/obj/harvest.dmi'

/spell/targeted/genetic/eat_weed/cast(list/targets, var/mob/user)
	..()
	if(!ishuman(user))
		return //We'll have to add an exception for monkeys if this is ported to diona
	var/mob/living/carbon/human/H = user
	var/list/trays = list()
	for(var/obj/machinery/portable_atmospherics/hydroponics/tray in range(1))
		if(tray.weedlevel > 0)
			trays += tray

	var/obj/machinery/portable_atmospherics/hydroponics/target = input(H,"Select a tray:") as null|anything in trays

	if(!isnull(gcDestroyed) || !target || target.weedlevel == 0)
		return

	H.reagents.add_reagent(NUTRIMENT, target.weedlevel)
	target.weedlevel = 0

	user.visible_message("<span class='warning'>[user] begins rooting through [target], ripping out weeds and eating them noisily.</span>","<span class='warning'>You begin rooting through [target], ripping out weeds and eating them noisily.</span>")