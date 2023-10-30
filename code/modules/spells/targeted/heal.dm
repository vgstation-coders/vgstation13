/spell/targeted/heal
	name = "Heal Other"
	desc = "Mends basic wounds in the target."
	abbreviation = "HL"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	spell_levels = list(Sp_SPEED = 0, Sp_POWER = 0, Sp_RANGE = 0)

	school = "transmutation"
	charge_max = 300
	cooldown_reduc = 75
	cooldown_min = 150
	invocation = "DI TIUB SEEL IM"
	invocation_type = SpI_SHOUT
	message = "<span class='sinister'>You feel refreshed.<span>"
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 2, Sp_POWER = 1, Sp_RANGE = 1)
	compatible_mobs = list(/mob/living)

	max_targets = 1

	amt_dam_fire = -15
	amt_dam_brute = -15
	amt_dam_oxy = -15
	amt_dam_tox = -15

	spell_flags = WAIT_FOR_CLICK

	hud_state = "wiz_heal"

/spell/targeted/heal/cast(var/list/targets, mob/user)
	for(var/atom/T in targets)
		if(spell_levels[Sp_RANGE])
			if(T != user)
				aoe_heal(T)
		if(istype(T, /mob/living) && T != user)
			var/mob/living/L = T
			L.vis_contents += new /obj/effect/overlay/heal(L)
			apply_spell_damage(L)
			if(spell_levels[Sp_POWER] && istype(L, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = L
				strong_heal(H)
	playsound(user, 'sound/effects/aoeheal.ogg', 50, 100, extrarange = 3, gas_modified = 0)

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
			if(spell_levels[Sp_SPEED] >= level_max[Sp_SPEED])
				return "The spell can't be made any quicker than this!"
			return "Reduce this spell's cooldown by [cooldown_reduc/10] seconds."
		if(Sp_POWER)
			if(spell_levels[Sp_POWER] >= level_max[Sp_POWER])
				return "This spell already has a chance of mending internal injuries!"
			return "Grants the spell a chance of mending internal injuries in the primary target."
		if(Sp_RANGE)
			if(spell_levels[Sp_RANGE] >= level_max[Sp_RANGE])
				return "This spell already affects a small area around the target!"
			return "Expands the spell's effects to a small area around the target."


//50% chance per organ/limb of healing all its internal injuries
/spell/targeted/heal/proc/strong_heal(var/mob/living/carbon/human/H)
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

/spell/targeted/heal/proc/aoe_heal(var/target)
	for(var/mob/living/M in range(1, target))
		if(M == target)
			continue
		M.vis_contents += new /obj/effect/overlay/heal(M)
		apply_spell_damage(M)

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
