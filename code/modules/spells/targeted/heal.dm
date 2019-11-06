/spell/targeted/heal
	name = "Heal Other"
	desc = "Mends basic wounds in the target."
	abbreviation = "HL"
	user_type = USER_TYPE_WIZARD
	specialization = UTILITY
	spell_levels = list(Sp_SPEED = 0, Sp_POWER = 0, Sp_RANGE = 0)

	school = "transmutation"
	charge_max = 300
	cooldown_reduc = 75
	cooldown_min = 150
	invocation = "DI TIUB SEEL IM"
	invocation_type = SpI_SHOUT
	message = "<span class='sinister'>You feel refreshed.<span>"
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 2, Sp_POWER = 1, Sp_RANGE = 1)

	max_targets = 1

	amt_dam_fire = -15
	amt_dam_brute = -15
	amt_dam_oxy = -15
	amt_dam_tox = -15

	spell_flags = WAIT_FOR_CLICK

	hud_state = "wiz_heal"

/spell/targeted/heal/cast(var/list/targets, mob/user)
	for(var/mob/living/T in targets)
		if(spell_levels[Sp_RANGE])
			for(var/mob/living/M in range(1, T))
				if(M == user || M == T)
					continue
				M.vis_contents += new /obj/effect/overlay/heal(M)
				apply_spell_damage(M)
		T.vis_contents += new /obj/effect/overlay/heal(T)
		apply_spell_damage(T)
		playsound(T, 'sound/effects/aoeheal.ogg', 50, 100, extrarange = 3, gas_modified = 0)
	if(spell_levels[Sp_POWER])
		for(var/mob/living/carbon/human/H in targets)
			for(var/datum/organ/internal/I in H.internal_organs)
				if(prob(50))
					if(I && I.damage > 0)
						I.damage = max(0, I.damage - 4)
					if(I)
						I.status &= ~ORGAN_BROKEN
						I.status &= ~ORGAN_SPLINTED
						I.status &= ~ORGAN_BLEEDING
			for(var/datum/organ/external/O in H.organs)
				if(prob(50))
					O.status &= ~ORGAN_BROKEN
					O.status &= ~ORGAN_SPLINTED
					O.status &= ~ORGAN_BLEEDING

/spell/targeted/heal/apply_upgrade(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return quicken_spell()
		if(Sp_POWER)
			spell_levels[Sp_POWER]++
			name = "Superior " + name
			return "The spell now has a chance to mend internal wounds."
		if(Sp_RANGE)
			spell_levels[Sp_RANGE]++
			name = "Splashing " + name
			return "The spell will now affect a small area around the target."

/spell/targeted/heal/get_upgrade_info(upgrade_type, level)
	switch(upgrade_type)
		if(Sp_SPEED)
			return "Reduce this spell's cooldown."
		if(Sp_POWER)
			return "Grants the spell a chance of mending internal injuries in the primary target."
		if(Sp_RANGE)
			return "Expands the spell's effects to a small area around the target."

/obj/effect/overlay/heal
	name = "sparkles"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	layer = LIGHTING_LAYER

/obj/effect/overlay/heal/New(var/mob/M)
	..()
	animate(src, alpha = 0, time = 10)
	spawn(10)
		M.vis_contents -= src
		qdel(src)