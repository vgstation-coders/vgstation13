/datum/disease/gastric_ejections
	name = "Food Poisoning"
	max_stages = 5
	spread = "Oral"
	cure = "Spaceacillin"
	cure_id = "spaceacillin"
	cure_chance = 80
	spread_type = SPECIAL
	curable = 0
	affected_species = list("Monkey", "Human")
/datum/disease/gastric_ejections/stage_act()
	..()

	switch (src.stage)
		if (2)
			if(affected_mob.sleeping && prob(40))
				affected_mob << "\blue You feel better."
				affected_mob.virus = null
				return
			else if (prob(6))
				affected_mob << "You feel your stomach rumble."
			else if (prob(5))
				affected_mob.emote("shiver")

		if (3)
			if(affected_mob.sleeping && prob(30))
				affected_mob << "\blue You feel better."
				affected_mob.virus = null
				return
			else if (prob(8))
				affected_mob.emote("shiver")
			else if(prob(5))
				new /obj/effect/decal/cleanable/poo/drip(affected_mob.loc)
			else if (prob(10))
				playsound(affected_mob.loc, 'sound/effects/poo2.ogg', 50, 1)
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(text("\red [] lets out a foul-smelling fart!", affected_mob), 1)
					if(prob(5))
						new /obj/effect/decal/cleanable/poo/drip(affected_mob.loc)

		if (4)
			if(affected_mob.sleeping && prob(20))
				affected_mob << "\blue You feel better."
				affected_mob.virus = null
				return
			else if (prob(10))
				affected_mob.emote("groan")
			else if (prob(10))
				affected_mob.emote("vomit")
			else if (prob(8))
				playsound(affected_mob.loc, 'sound/effects/poo2.ogg', 50, 1)
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(text("\red [] farts, leaking diarrhea down their legs!", affected_mob), 1)
				new /obj/effect/decal/cleanable/poo(affected_mob.loc)
			else if (prob(2))
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(text("\red [] keels over in pain!", affected_mob), 1)
					if(prob(5))
						new /obj/effect/decal/cleanable/poo/drip(affected_mob.loc)
			else if(prob(5))
				new /obj/effect/decal/cleanable/poo/drip(affected_mob.loc)
				affected_mob.toxloss += 1
				affected_mob.updatehealth()
				affected_mob.stunned += rand(1,3)
				affected_mob.weakened += rand(1,3)

		if (5)
			if(affected_mob.sleeping && prob(15))
				affected_mob << "\blue You feel better."
				affected_mob.virus = null
				return
			else if (prob(8))
				playsound(affected_mob.loc, 'sound/effects/poo2.ogg', 50, 1)
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(text("\red []'s [] explodes violently with diarrhea!", affected_mob, pick("butt", "ass", "behind", "hindquarters")), 1)
				new /obj/effect/decal/cleanable/poo(affected_mob.loc)
			else if (prob(2))
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(text("\red [] keels over in pain!", affected_mob), 1)
			else if(prob(5))
				new /obj/effect/decal/cleanable/poo/drip(affected_mob.loc)
				affected_mob.toxloss += 1
				affected_mob.updatehealth()
				affected_mob.stunned += rand(2,4)
				affected_mob.weakened += rand(2,4)
			else if (prob(10))
				affected_mob.emote("vomit")
