/spell/targeted/flesh_to_stone
	name = "Flesh to Stone"
	desc = "This spell turns a single person into an inert statue for a long period of time."
	abbreviation = "FS"
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	school = "transmutation"
	charge_max = 600
	spell_flags = NEEDSCLOTHES | WAIT_FOR_CLICK | IS_HARMFUL
	range = 1
	max_targets = 1
	invocation = "STAUN EI"
	invocation_type = SpI_SHOUT
	amt_stunned = 5//just exists to make sure the statue "catches" them
	cooldown_min = 200 //100 deciseconds reduction per rank
	compatible_mobs = list(/mob/living)

	hud_state = "wiz_statue"

/spell/targeted/flesh_to_stone/cast(var/list/targets, mob/user)
	..()
	for(var/mob/living/target in targets)
		target.turn_into_statue(FALSE,TRUE)
