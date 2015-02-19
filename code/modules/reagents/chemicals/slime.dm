
/datum/reagent/slimejelly
	name = "Slime Jelly"
	id = "slimejelly"
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	reagent_state = LIQUID
	color = "#801E28" // rgb: 128, 30, 40

/datum/reagent/slimejelly/on_mob_life(var/mob/living/M as mob,var/alien)
	if(M.dna.mutantrace != "slime" || !istype(M, /mob/living/carbon/slime))
		if(prob(10))
			M << "\red Your insides are burning!"
			M.adjustToxLoss(rand(20,60)*REM)
	if(prob(40))
		M.heal_organ_damage(5*REM,0)
	..()
	return

/datum/reagent/slimetoxin
	name = "Mutation Toxin"
	id = "mutationtoxin"
	description = "A corruptive toxin produced by slimes."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/slimetoxin/on_mob_life(var/mob/living/M as mob)
	if(!M)
		M = holder.my_atom
	if(istype(M, /mob/living/carbon/human/manifested))
		M << "<span class='warning'> You can feel intriguing reagents seeping into your body, but they don't seem to react at all.</span>"
		M.reagents.del_reagent("mutationtoxin")
		..()
		return
	if(ishuman(M))
		var/mob/living/carbon/human/human = M
		if(human.dna.mutantrace == null)
			M << "\red Your flesh rapidly mutates!"
			human.dna.mutantrace = "slime"
			human.update_mutantrace()
	..()
	return

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	id = "amutationtoxin"
	description = "An advanced corruptive toxin produced by slimes."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/aslimetoxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(istype(M, /mob/living/carbon) && M.stat != DEAD)
		if(istype(M, /mob/living/carbon/human/manifested))
			M << "<span class='warning'> You can feel intriguing reagents seeping into your body, but they don't seem to react at all.</span>"
			M.reagents.del_reagent("amutationtoxin")
			..()
			return
		else
			M << "<span class='warning'> Your flesh rapidly mutates!</span>"
			if(M.monkeyizing)	return
			M.monkeyizing = 1
			M.canmove = 0
			M.icon = null
			M.overlays.len = 0
			M.invisibility = 101
			for(var/obj/item/W in M)
				if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
					del(W)
					continue
				W.layer = initial(W.layer)
				W.loc = M.loc
				W.dropped(M)
			var/mob/living/carbon/slime/new_mob = new /mob/living/carbon/slime(M.loc)
			new_mob.a_intent = I_HURT
			if(M.mind)
				M.mind.transfer_to(new_mob)
			else
				new_mob.key = M.key
			del(M)
	..()
	return