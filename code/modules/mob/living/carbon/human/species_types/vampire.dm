/datum/species/vampire
	name = "vampire"
	id = "vampire"
	default_color = "FFFFFF"
	species_traits = list(SPECIES_UNDEAD,EYECOLOR,HAIR,FACEHAIR,LIPS,DRINKSBLOOD)
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_NOBREATH)
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	exotic_bloodtype = "U"
	use_skintones = TRUE
	mutant_heart = /obj/item/organ/heart/vampire
	mutanttongue = /obj/item/organ/tongue/vampire
	blacklisted = TRUE
	limbs_id = "human"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	var/info_text = "You are a <span class='danger'>Vampire</span>. You will slowly but constantly lose blood if outside of a coffin. If inside a coffin, you will slowly heal. You may gain more blood by grabbing a live victim and using your drain ability."

/datum/species/vampire/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return FALSE

/datum/species/vampire/on_species_gain(mob/living/carbon/human/C, datum/species/old_species)
	. = ..()
	to_chat(C, "[info_text]")
	C.skin_tone = "albino"
	C.update_body(0)
	var/obj/effect/proc_holder/spell/targeted/shapeshift/bat/B = new
	C.AddSpell(B)

/datum/species/vampire/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(C.mind)
		for(var/S in C.mind.spell_list)
			var/obj/effect/proc_holder/spell/S2 = S
			if(S2.type == /obj/effect/proc_holder/spell/targeted/shapeshift/bat)
				C.mind.spell_list.Remove(S2)
				qdel(S2)

/datum/species/vampire/spec_life(mob/living/carbon/human/C)
	. = ..()
	if(istype(C.loc, /obj/structure/closet/coffin))
		C.heal_overall_damage(4,4)
		C.adjustToxLoss(-4)
		C.adjustOxyLoss(-4)
		C.adjustCloneLoss(-4)
		return
	C.blood_volume -= 0.75
	if(C.blood_volume <= BLOOD_VOLUME_SURVIVE)
		to_chat(C, "<span class='danger'>You ran out of blood!</span>")
		C.dust()
	var/area/A = get_area(C)
	if(istype(A, /area/chapel))
		to_chat(C, "<span class='danger'>You don't belong here!</span>")
		C.adjustFireLoss(20)
		C.adjust_fire_stacks(6)
		C.IgniteMob()

/obj/item/organ/tongue/vampire
	name = "vampire tongue"
	actions_types = list(/datum/action/item_action/organ_action/vampire)
	color = "#1C1C1C"
	var/drain_cooldown = 0

#define VAMP_DRAIN_AMOUNT 50

/datum/action/item_action/organ_action/vampire
	name = "Drain Victim"
	desc = "Leech blood from any carbon victim you are passively grabbing."

/datum/action/item_action/organ_action/vampire/Trigger()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/H = owner
		var/obj/item/organ/tongue/vampire/V = target
		if(V.drain_cooldown >= world.time)
			to_chat(H, "<span class='notice'>You just drained blood, wait a few seconds.</span>")
			return
		if(H.pulling && iscarbon(H.pulling))
			var/mob/living/carbon/victim = H.pulling
			if(H.blood_volume >= BLOOD_VOLUME_MAXIMUM)
				to_chat(H, "<span class='notice'>You're already full!</span>")
				return
			if(victim.stat == DEAD)
				to_chat(H, "<span class='notice'>You need a living victim!</span>")
				return
			if(!victim.blood_volume || (victim.dna && ((NOBLOOD in victim.dna.species.species_traits) || victim.dna.species.exotic_blood)))
				to_chat(H, "<span class='notice'>[victim] doesn't have blood!</span>")
				return
			V.drain_cooldown = world.time + 30
			if(victim.anti_magic_check(FALSE, TRUE))
				to_chat(victim, "<span class='warning'>[H] tries to bite you, but stops before touching you!</span>")
				to_chat(H, "<span class='warning'>[victim] is blessed! You stop just in time to avoid catching fire.</span>")
				return
			if(!do_after(H, 30, target = victim))
				return
			var/blood_volume_difference = BLOOD_VOLUME_MAXIMUM - H.blood_volume //How much capacity we have left to absorb blood
			var/drained_blood = min(victim.blood_volume, VAMP_DRAIN_AMOUNT, blood_volume_difference)
			to_chat(victim, "<span class='danger'>[H] is draining your blood!</span>")
			to_chat(H, "<span class='notice'>You drain some blood!</span>")
			playsound(H, 'sound/items/drink.ogg', 30, 1, -2)
			victim.blood_volume = CLAMP(victim.blood_volume - drained_blood, 0, BLOOD_VOLUME_MAXIMUM)
			H.blood_volume = CLAMP(H.blood_volume + drained_blood, 0, BLOOD_VOLUME_MAXIMUM)
			if(!victim.blood_volume)
				to_chat(H, "<span class='warning'>You finish off [victim]'s blood supply!</span>")

#undef VAMP_DRAIN_AMOUNT

/obj/item/organ/heart/vampire
	name = "vampire heart"
	actions_types = list(/datum/action/item_action/organ_action/vampire_heart)
	color = "#1C1C1C"

/datum/action/item_action/organ_action/vampire_heart
	name = "Check Blood Level"
	desc = "Check how much blood you have remaining."

/datum/action/item_action/organ_action/vampire_heart/Trigger()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/H = owner
		to_chat(H, "<span class='notice'>Current blood level: [H.blood_volume]/[BLOOD_VOLUME_MAXIMUM].</span>")

/obj/effect/proc_holder/spell/targeted/shapeshift/bat
	name = "Bat Form"
	desc = "Take on the shape a space bat."
	invocation = "Squeak!"
	charge_max = 50
	cooldown_min = 50
	shapeshift_type = /mob/living/simple_animal/hostile/retaliate/bat
