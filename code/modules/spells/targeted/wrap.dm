/spell/targeted/wrapping_paper
	name = "Wrap Gift"
	desc = "This spell turns a single person into an inert statue for a long period of time."
	user_type = USER_TYPE_ARTIFACT

	school = "transmutation"
	charge_max = 300
	spell_flags = NEEDSCLOTHES | WAIT_FOR_CLICK
	range = 7
	max_targets = 1
	invocation = "W'APPIN' PR'SN'TS!"
	invocation_type = SpI_SHOUT
	amt_stunned = 5//just exists to make sure the giftwrap "catches" them
	cooldown_min = 30 //100 deciseconds reduction per rank
	compatible_mobs = list(/mob/living)

	hud_state = "wrap"

/spell/targeted/wrapping_paper/cast(var/list/targets, mob/user)
	..()
	for(var/mob/living/target in targets)
		var/obj/present = new /obj/structure/strange_present(target.loc,target)
		if (target.client)
			target.client.perspective = EYE_PERSPECTIVE
			target.client.eye = present
		target.forceMove(present)
	return
