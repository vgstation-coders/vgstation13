/datum/disease/parrot_possession
	name = "Parrot Possession"
	max_stages = 1
	spread_text = "Paranormal"
	spread_flags = DISEASE_SPREAD_SPECIAL
	disease_flags = CURABLE
	cure_text = "Holy Water."
	cures = list("holywater")
	cure_chance = 20
	agent = "Avian Vengence"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Subject is possesed by the vengeful spirit of a parrot. Call the priest."
	severity = DISEASE_SEVERITY_MEDIUM
	infectable_hosts = list(SPECIES_ORGANIC, SPECIES_UNDEAD, SPECIES_INORGANIC, SPECIES_ROBOTIC)
	bypasses_immunity = TRUE //2spook
	var/mob/living/simple_animal/parrot/Poly/ghost/parrot

/datum/disease/parrot_possession/stage_act()
	..()
	if(!parrot || parrot.loc != affected_mob)
		cure()
	else if(prob(parrot.speak_chance))
		if(parrot.speech_buffer.len)
			affected_mob.say(pick(parrot.speech_buffer))

/datum/disease/parrot_possession/cure()
	if(parrot && parrot.loc == affected_mob)
		parrot.forceMove(affected_mob.drop_location())
		affected_mob.visible_message("<span class='danger'>[parrot] is violently driven out of [affected_mob]!</span>", "<span class='userdanger'>[parrot] bursts out of your chest!</span>")
	..()
