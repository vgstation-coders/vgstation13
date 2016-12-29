/mob/living/carbon/monkey/get_unarmed_verb()
	return attack_text

/mob/living/carbon/monkey/get_unarmed_damage()
	return rand(1,3)

/mob/living/carbon/monkey/get_unarmed_hit_sound()
	return 'sound/weapons/bite.ogg'

/mob/living/carbon/monkey/knockout_chance_modifier()
	return 2

/mob/living/carbon/monkey/unarmed_attack_mob(mob/living/)
	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		to_chat(src, "<span class='notice'>You can't do this with \the [wear_mask] on!</span>")
		return

	return ..()

/mob/living/carbon/monkey/after_unarmed_attack(mob/living/target, damage, damage_type, organ, armor)
	if(iscarbon(target))
		for(var/datum/disease/D in viruses)

			if(istype(D, /datum/disease/jungle_fever) && ishuman(target)) //Jungle fever - special case
				var/mob/living/carbon/human/H = target
				var/mob/living/carbon/monkey/M = H.monkeyize()
				M.contract_disease(D, 1, 0)

			else if(D.spread == "Bite")
				target.contract_disease(D, 1, 0)

	return ..()