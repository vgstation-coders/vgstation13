/mob/living/carbon/alien/humanoid/drone
	name = "alien drone" //The alien drone, not Alien Drone
	caste = "d"
	maxHealth = 100
	health = 100
	icon_state = "aliend_s"
	plasma_rate = 15

/mob/living/carbon/alien/humanoid/drone/movement_delay()
	var/tally = 2 + move_delay_add + config.alien_delay //Drones are slow

	var/turf/T = loc
	if(istype(T))
		tally = T.adjust_slowdown(src, tally)

	return tally

/mob/living/carbon/alien/humanoid/drone/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(src.name == "alien drone")
		src.name = text("alien drone ([rand(1, 1000)])")
	src.real_name = src.name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/resin,/mob/living/carbon/alien/humanoid/proc/corrosive_acid)
	..()
	add_language(LANGUAGE_XENO)
	default_language = all_languages[LANGUAGE_XENO]

//Drones use the same base as generic humanoids.
//Drone verbs

/mob/living/carbon/alien/humanoid/drone/verb/evolve() // -- TLE
	set name = "Evolve (500)"
	set desc = "Produce an interal egg sac capable of spawning children. Only one queen can exist at a time."
	set category = "Alien"

	if(powerc(500))
		// Queen check
		var/no_queen = 1
		for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
			if(!Q.key && Q.has_brain())
				continue
			no_queen = 0

		if(no_queen)
			adjustToxLoss(-500)
			visible_message("<span class='alien'>[src] begins to violently twist and contort!</span>", "<span class='alien'>You begin to evolve, stand still for a few moments</span>")
			if(do_after(src, src, 50))
				var/mob/living/carbon/alien/humanoid/queen/new_xeno = new(loc)
				mind.transfer_to(new_xeno)
				transferImplantsTo(new_xeno)
				transferBorers(new_xeno)
				qdel(src)
		else
			to_chat(src, "<span class='notice'>We already have an alive queen.</span>")
	return
