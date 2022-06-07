/mob/living/carbon/monkey/get_unarmed_verb()
	return attack_text

/mob/living/carbon/monkey/get_unarmed_damage()
	return rand(1,3)

/mob/living/carbon/monkey/get_unarmed_hit_sound()
	return 'sound/weapons/bite.ogg'

/mob/living/carbon/monkey/knockout_chance_modifier()
	return 2

/mob/living/carbon/monkey/unarmed_attack_mob(mob/living/)
	if(wear_mask?.is_muzzle)
		to_chat(src, "<span class='notice'>You can't do this with \the [wear_mask] on!</span>")
		return

	return ..()

/mob/living/carbon/monkey/after_unarmed_attack(mob/living/target, damage, damage_type, organ, armor)
	var/datum/organ/external/S = organ
	if (organ)
		S = organ
	else
		S = target.get_organ(zone_sel.selecting)
	var/touch_zone = FULL_TORSO
	if (!(!S || S.status & ORGAN_DESTROYED))
		touch_zone = S.body_part
	var/block = 0
	var/bleeding = 0
	// biting causes the check to consider that both sides are bleeding, allowing for blood-only disease transmission through biting.
	if (target.check_contact_sterility(touch_zone))//only one side has to wear protective clothing to prevent contact infection
		block = 1
	bleeding = 1 // monkeys always bite
	share_contact_diseases(target,block,bleeding)

	if(iscarbon(target))
		for(var/datum/disease/D in viruses)

			if(istype(D, /datum/disease/jungle_fever) && ishuman(target)) //Jungle fever - special case
				var/mob/living/carbon/human/H = target
				var/mob/living/carbon/monkey/M = H.monkeyize()
				M.contract_disease(D, 1, 0)

			else if(D.spread == "Bite")
				target.contract_disease(D, 1, 0)

	return ..()
