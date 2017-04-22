/mob/living/carbon/slime
	name = "baby slime"
	desc = null
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE
	speak_emote = list("hums")
	layer = SLIME_LAYER
	maxHealth = 150
	health = 150
	gender = NEUTER

	update_icon = 0
	nutrition = 700 // 1000 = max

	see_in_dark = 8
	update_slimes = 0

	hasmouth = 0

	can_butcher = 0

	// canstun and CANKNOCKDOWN don't affect slimes because they ignore stun and knockdown variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANPARALYSE|CANPUSH

	var/cores = 1 // the number of /obj/item/slime_extract's the slime has left inside

	var/powerlevel = 0 	// 1-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the slime has been overfed, if 10, grows into an adult
						 // if adult: if 10: reproduces


	var/mob/living/Victim = null // the person the slime is currently feeding on
	var/mob/living/Target = null // AI variable - tells the slime to hunt this down

	var/attacked = 0 // determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/tame = 0 // if set to 1, the slime will not eat humans ever, or attack them

	var/list/Friends = list() // A list of potential friends
	var/list/FriendsWeight = list() // A list containing values respective to Friends. This determines how many times a slime "likes" something. If the slime likes it more than 2 times, it becomes a friend

	var/list/speech_buffer = list()

	// slimes pass on genetic data, so all their offspring have the same "Friends",

	///////////TIME FOR SUBSPECIES

	var/colour = "grey"
	var/primarytype = /mob/living/carbon/slime
	var/adulttype = /mob/living/carbon/slime/adult
	var/coretype = /obj/item/slime_extract/grey
	var/list/slime_mutation[4]

	var/core_removal_stage = 0 //For removing cores
	universal_speak = 1
	universal_understand = 1

/mob/living/carbon/slime/adult
	name = "adult slime"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey adult slime"
	speak_emote = list("telepathically chirps")

	maxHealth = 200
	health = 200
	gender = NEUTER

	update_icon = 0
	nutrition = 800 // 1200 = max

/mob/living/carbon/slime/Destroy()
	..()
	Friends = null
	FriendsWeight = null
	Victim = null
	Target = null


/mob/living/carbon/slime/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	name = text("[colour] slime ([rand(1, 1000)])")
	desc = text("A baby [colour] slime.")
	real_name = name
	spawn (1)
		regenerate_icons()
		to_chat(src, "<span class='notice'>Your icons have been generated!</span>")
	..()

/mob/living/carbon/slime/adult/New()
	//verbs.Remove(/mob/living/carbon/slime/verb/ventcrawl)
	..()
	name = text("[colour] slime ([rand(1,1000)])")
	desc = text("An adult [colour] slime.")
	slime_mutation[1] = /mob/living/carbon/slime/orange
	slime_mutation[2] = /mob/living/carbon/slime/metal
	slime_mutation[3] = /mob/living/carbon/slime/blue
	slime_mutation[4] = /mob/living/carbon/slime/purple

/mob/living/carbon/slime/movement_delay()
	var/tally = 0

	var/turf/T = loc
	if(istype(T))
		tally = T.adjust_slowdown(src, tally)

		if(tally == -1)
			return tally

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45)
		tally += (health_deficiency / 25)

	if (bodytemperature < 183.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	if(reagents)
		if(reagents.has_reagent(HYPERZINE)) // hyperzine slows slimes down
			tally *= 2 // moves twice as slow

		if(reagents.has_reagent(FROSTOIL)) // frostoil also makes them move VEEERRYYYYY slow
			tally *= 5

	if(health <= 0) // if damaged, the slime moves twice as slow
		tally *= 2

	if (bodytemperature >= 330.23) // 135 F
		return -1	// slimes become supercharged at high temperatures

	return tally+config.slime_delay


/mob/living/carbon/slime/Bump(atom/movable/AM as mob|obj)
	if(now_pushing)
		return
	now_pushing = 1

	if(isobj(AM))
		if(!client && powerlevel > 0)
			var/probab = 10
			switch(powerlevel)
				if(1 to 2)
					probab = 20
				if(3 to 4)
					probab = 30
				if(5 to 6)
					probab = 40
				if(7 to 8)
					probab = 60
				if(9)
					probab = 70
				if(10)
					probab = 95
			if(prob(probab))


				if(istype(AM, /obj/structure/window) || istype(AM, /obj/structure/grille))
					if(istype(src, /mob/living/carbon/slime/adult))
						if(nutrition <= 600 && !Atkcool)
							AM.attack_slime(src)
							spawn()
								Atkcool = 1
								sleep(15)
								Atkcool = 0
					else
						if(nutrition <= 500 && !Atkcool)
							if(prob(5))
								AM.attack_slime(src)
								spawn()
									Atkcool = 1
									sleep(15)
									Atkcool = 0

	if(ismob(AM))
		var/mob/tmob = AM

		if(istype(src, /mob/living/carbon/slime/adult))
			if(istype(tmob, /mob/living/carbon/human))
				if(prob(90))
					now_pushing = 0
					return
		else
			if(istype(tmob, /mob/living/carbon/human))
				now_pushing = 0
				return

	now_pushing = 0
	..()

/mob/living/carbon/slime/Process_Spacemove()
	return 2


/mob/living/carbon/slime/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Health: [round((health / maxHealth) * 100)]%")

		if(istype(src,/mob/living/carbon/slime/adult))
			stat(null, "Nutrition: [nutrition]/1200")
			if(amount_grown >= 10)
				stat(null, "You can reproduce!")
		else
			stat(null, "Nutrition: [nutrition]/1000")
			if(amount_grown >= 10)
				stat(null, "You can evolve!")

		stat(null,"Power Level: [powerlevel]")


/mob/living/carbon/slime/adjustFireLoss(amount)
	..(-abs(amount)) // Heals them
	return

/mob/living/carbon/slime/bullet_act(var/obj/item/projectile/Proj)
	attacked += 10
	..(Proj)
	return 0


/mob/living/carbon/slime/emp_act(severity)
	for(var/obj/item/stickybomb/B in src)
		if(B.stuck_to)
			visible_message("<span class='warning'>\the [B] stuck on \the [src] suddenly deactivates itself and falls to the ground.</span>")
			B.deactivate()
			B.unstick()

	if(flags & INVULNERABLE)
		return

	powerlevel = 0 // oh no, the power!
	..()

/mob/living/carbon/slime/ex_act(severity)
	if(flags & INVULNERABLE)
		return


	if (stat == 2 && client)
		return

	else if (stat == 2 && !client)
		qdel(src)
		return

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			return

		if (2.0)

			b_loss += 60
			f_loss += 60


		if(3.0)
			b_loss += 30

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()


/mob/living/carbon/slime/blob_act()
	if(flags & INVULNERABLE)
		return
	if (stat == DEAD)
		return
	..()

	playsound(loc, 'sound/effects/blobattack.ogg',50,1)
	var/shielded = 0

	var/damage = null
	if (stat != 2)
		damage = rand(10,30)

	if(shielded)
		damage /= 4

		//paralysis += 1

	show_message("<span class='warning'>The blob attacks you!</span>")

	adjustFireLoss(damage)

	updatehealth()
	return


/mob/living/carbon/slime/u_equip(obj/item/W as obj)
	return


/mob/living/carbon/slime/attack_ui(slot)
	return

/mob/living/carbon/slime/attack_slime(mob/living/carbon/slime/M)
	M.unarmed_attack_mob(src)


/mob/living/carbon/slime/attack_animal(mob/living/simple_animal/M)
	M.unarmed_attack_mob(src)

/mob/living/carbon/slime/attack_paw(mob/living/carbon/monkey/M)
	if(!(istype(M, /mob/living/carbon/monkey)))
		return//Fix for aliens receiving double messages when attacking other aliens.

	..()

	switch(M.a_intent)

		if(I_HELP)
			help_shake_act(M)
		else
			M.unarmed_attack_mob(src)


/mob/living/carbon/slime/attack_hand(mob/living/carbon/human/M as mob)
	..()

	if(Victim)
		if(Victim == M)
			if(prob(60))
				visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				visible_message("<span class='warning'>[M] manages to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				if(prob(90) && !client)
					Discipline++

				spawn()
					SStun = 1
					sleep(rand(45,60))
					if(src)
						SStun = 0

				Victim = null
				anchored = 0
				step_away(src,M)

			return

		else
			if(prob(30))
				visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off of [Victim]!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				visible_message("<span class='warning'>[M] manages to wrestle \the [name] off of [Victim]!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				if(prob(80) && !client)
					Discipline++

					if(!istype(src, /mob/living/carbon/slime/adult))
						if(Discipline == 1)
							attacked = 0

				spawn()
					SStun = 1
					sleep(rand(55,65))
					if(src)
						SStun = 0

				Victim = null
				anchored = 0
				step_away(src,M)

			return


	switch(M.a_intent)

		if (I_HELP)
			help_shake_act(M)

		if (I_GRAB)
			M.grab_mob(src)

		else

			M.do_attack_animation(src, M)
			var/damage = rand(1, 9)

			attacked += 10
			if (prob(90))
				if (M_HULK in M.mutations)
					damage += 5
					if(Victim)
						Victim = null
						anchored = 0
						if(prob(80) && !client)
							Discipline++
					spawn(0)

						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)


				playsound(loc, "punch", 25, 1, -1)
				visible_message("<span class='danger'>[M] has punched [src]!</span>")

				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to punch [src]!</span>")
	return



/mob/living/carbon/slime/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	switch(M.a_intent)
		if (I_HELP)
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")

		if (I_HURT)
			M.unarmed_attack_mob(src)

		if (I_GRAB)
			M.grab_mob(src)

		if (I_DISARM)
			M.do_attack_animation(src, M)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			var/damage = 5
			attacked += 10

			visible_message("<span class='danger'>[M] has tackled [src]!</span>")

			if(Victim)
				Victim = null
				anchored = 0
				if(prob(80) && !client)
					Discipline++

			SStun = 1
			spawn(rand(5,20))
				SStun = 0

			step_away(src,M,15)
			spawn(3)
				step_away(src,M,15)

			adjustBruteLoss(damage)
			updatehealth()
	return


/mob/living/carbon/slime/restrained()
	if(timestopped)
		return 1 //under effects of time magick
	return 0


mob/living/carbon/slime/var/co2overloadtime = null
mob/living/carbon/slime/var/temperature_resistance = T0C+75


/mob/living/carbon/slime/show_inv(mob/user)
	return

	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR><BR>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[name];size=340x480"))
	onclose(user, "mob[name]")
	return

/mob/living/carbon/slime/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		// slimes can't suffocate unless they suicide or they fall into crit. They are also not harmed by fire
		health = maxHealth - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())

/mob/living/carbon/slime/proc/get_obstacle_ok(atom/A)
	var/direct = get_dir(src, A)
	var/obj/item/weapon/dummy/D = new /obj/item/weapon/dummy( src.loc )
	var/ok = 0
	if ( (direct - 1) & direct)
		var/turf/Step_1
		var/turf/Step_2
		switch(direct)
			if(5.0)
				Step_1 = get_step(src, NORTH)
				Step_2 = get_step(src, EAST)

			if(6.0)
				Step_1 = get_step(src, SOUTH)
				Step_2 = get_step(src, EAST)

			if(9.0)
				Step_1 = get_step(src, NORTH)
				Step_2 = get_step(src, WEST)

			if(10.0)
				Step_1 = get_step(src, SOUTH)
				Step_2 = get_step(src, WEST)

			else
		if(Step_1 && Step_2)
			var/check_1 = 0
			var/check_2 = 0
			if(step_to(D, Step_1))
				check_1 = 1
				for(var/obj/border_obstacle in Step_1)
					if(border_obstacle.flags & ON_BORDER)
						if(!border_obstacle.Uncross(D, A))
							check_1 = 0
				for(var/obj/border_obstacle in get_turf(A))
					if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
						if(!border_obstacle.Cross(D, D.loc, 1, 0))
							check_1 = 0

			D.forceMove(src.loc)
			if(step_to(D, Step_2))
				check_2 = 1

				for(var/obj/border_obstacle in Step_2)
					if(border_obstacle.flags & ON_BORDER)
						if(!border_obstacle.Uncross(D, A))
							check_2 = 0
				for(var/obj/border_obstacle in get_turf(A))
					if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
						if(!border_obstacle.Cross(D, D.loc, 1, 0))
							check_2 = 0
			if(check_1 || check_2)
				ok = 1
	else
		if(loc == src.loc)
			ok = 1
		else
			ok = 1

			//Now, check objects to block exit that are on the border
			for(var/obj/border_obstacle in src.loc)
				if(border_obstacle.flags & ON_BORDER)
					if(!border_obstacle.Uncross(D, A))
						ok = 0

			//Next, check objects to block entry that are on the border
			for(var/obj/border_obstacle in get_turf(A))
				if((border_obstacle.flags & ON_BORDER) && (A != border_obstacle))
					if(!border_obstacle.Cross(D, D.loc, 1, 0))
						ok = 0

	//del(D)
	//Garbage Collect Dummy
	D.forceMove(null)
	D = null
	if (!( ok ))

		return 0

	return 1


/obj/item/slime_extract
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey slime extract"
	flags = FPRINT
	force = 1.0
	w_class = W_CLASS_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 6
	origin_tech = Tc_BIOTECH + "=4"
	mech_flags = MECH_SCAN_FAIL
	var/Uses = 1 // uses before it goes inert
	var/enhanced = 0 //has it been enhanced before?
	var/primarytype = /mob/living/carbon/slime

/obj/item/slime_extract/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/slimesteroid2))
		if(enhanced == 1)
			to_chat(user, "<span class='warning'>This extract has already been enhanced!</span>")
			return ..()
		if(Uses == 0)
			to_chat(user, "<span class='warning'>You can't enhance a used extract!</span>")
			return ..()
		to_chat(user, "You apply the enhancer. It now has triple the amount of uses.")
		Uses = 3
		enhanced = 1
		qdel(O)

	//slime res
	if(istype(O, /obj/item/weapon/slimeres))
		if(Uses == 0)
			to_chat(user, "<span class='warning'>The solution doesn't work on used extracts!</span>")
			return ..()
		to_chat(user, "You splash the Slime Resurrection Serum onto the extract causing it to quiver and come to life.")
		new primarytype(get_turf(src))
		Uses--
		qdel(O)

/obj/item/slime_extract/New()
	..()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

/obj/item/slime_extract/grey
	name = "grey slime extract"
	icon_state = "grey slime extract"
	primarytype = /mob/living/carbon/slime/gold

/obj/item/slime_extract/gold
	name = "gold slime extract"
	icon_state = "gold slime extract"
	primarytype = /mob/living/carbon/slime/gold

/obj/item/slime_extract/silver
	name = "silver slime extract"
	icon_state = "silver slime extract"
	primarytype = /mob/living/carbon/slime/silver

/obj/item/slime_extract/metal
	name = "metal slime extract"
	icon_state = "metal slime extract"
	primarytype = /mob/living/carbon/slime/metal

/obj/item/slime_extract/purple
	name = "purple slime extract"
	icon_state = "purple slime extract"
	primarytype = /mob/living/carbon/slime/purple

/obj/item/slime_extract/darkpurple
	name = "dark purple slime extract"
	icon_state = "dark purple slime extract"
	primarytype = /mob/living/carbon/slime/darkpurple

/obj/item/slime_extract/orange
	name = "orange slime extract"
	icon_state = "orange slime extract"
	primarytype = /mob/living/carbon/slime/orange

/obj/item/slime_extract/yellow
	name = "yellow slime extract"
	icon_state = "yellow slime extract"
	primarytype = /mob/living/carbon/slime/yellow

/obj/item/slime_extract/red
	name = "red slime extract"
	icon_state = "red slime extract"
	primarytype = /mob/living/carbon/slime/red

/obj/item/slime_extract/blue
	name = "blue slime extract"
	icon_state = "blue slime extract"
	primarytype = /mob/living/carbon/slime/blue

/obj/item/slime_extract/darkblue
	name = "dark blue slime extract"
	icon_state = "dark blue slime extract"
	primarytype = /mob/living/carbon/slime/darkblue

/obj/item/slime_extract/pink
	name = "pink slime extract"
	icon_state = "pink slime extract"
	primarytype = /mob/living/carbon/slime/pink

/obj/item/slime_extract/green
	name = "green slime extract"
	icon_state = "green slime extract"
	primarytype = /mob/living/carbon/slime/green

/obj/item/slime_extract/lightpink
	name = "light pink slime extract"
	icon_state = "light pink slime extract"
	primarytype = /mob/living/carbon/slime/lightpink

/obj/item/slime_extract/black
	name = "black slime extract"
	icon_state = "black slime extract"
	primarytype = /mob/living/carbon/slime/black

/obj/item/slime_extract/oil
	name = "oil slime extract"
	icon_state = "oil slime extract"
	primarytype = /mob/living/carbon/slime/oil

/obj/item/slime_extract/adamantine
	name = "adamantine slime extract"
	icon_state = "adamantine slime extract"
	primarytype = /mob/living/carbon/slime/adamantine

/obj/item/slime_extract/bluespace
	name = "bluespace slime extract"
	icon_state = "bluespace slime extract"
	primarytype = /mob/living/carbon/slime/bluespace

/obj/item/slime_extract/pyrite
	name = "pyrite slime extract"
	icon_state = "pyrite slime extract"
	primarytype = /mob/living/carbon/slime/pyrite

/obj/item/slime_extract/cerulean
	name = "cerulean slime extract"
	icon_state = "cerulean slime extract"
	primarytype = /mob/living/carbon/slime/cerulean

/obj/item/slime_extract/sepia
	name = "sepia slime extract"
	icon_state = "sepia slime extract"
	primarytype = /mob/living/carbon/slime/sepia


////Pet Slime Creation///

/obj/item/weapon/slimepotion
	name = "docility potion"
	desc = "A potent chemical mix that will nullify a slime's powers, causing it to become docile and tame."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"

	attack(mob/living/carbon/slime/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/slime))//If target is not a slime.
			to_chat(user, "<span class='warning'>The potion only works on baby slimes!</span>")
			return ..()
		if(istype(M, /mob/living/carbon/slime/adult)) //Can't tame adults
			to_chat(user, "<span class='warning'>Only baby slimes can be tamed!</span>")
			return..()
		if(M.stat)
			to_chat(user, "<span class='warning'>The slime is dead!</span>")
			return..()
		var/mob/living/simple_animal/slime/pet = new /mob/living/simple_animal/slime(M.loc)
		pet.icon_state = "[M.colour] baby slime"
		pet.icon_living = "[M.colour] baby slime"
		pet.icon_dead = "[M.colour] baby slime dead"
		pet.colour = "[M.colour]"
		to_chat(user, "You feed the slime the potion, removing its powers and calming it.")
		if(M.mind)
			M.mind.transfer_to(pet)
		qdel (M)
		M = null
		var/newname = ""
		if(pet.client)//leaving the player-controlled slimes the ability to choose their new name
			newname = copytext(sanitize(input(pet, "You have been fed a docility potion, what shall we call you?", "Give yourself a new name", "pet slime") as null|text),1,MAX_NAME_LEN)
		else
			newname = copytext(sanitize(input(user, "Would you like to give the slime a name?", "Name your new pet", "pet slime") as null|text),1,MAX_NAME_LEN)

		if (!newname)
			newname = "pet slime"
		pet.name = newname
		pet.real_name = newname
		qdel (src)

/obj/item/weapon/slimepotion2
	name = "advanced docility potion"
	desc = "A potent chemical mix that will nullify a slime's powers, causing it to become docile and tame. This one is meant for adult slimes"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"

	attack(mob/living/carbon/slime/adult/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/slime/adult))//If target is not a slime.
			to_chat(user, "<span class='warning'>The potion only works on adult slimes!</span>")
			return ..()
		if(M.stat)
			to_chat(user, "<span class='warning'>The slime is dead!</span>")
			return..()
		var/mob/living/simple_animal/slime/adult/pet = new /mob/living/simple_animal/slime/adult(M.loc)
		pet.icon_state = "[M.colour] adult slime"
		pet.icon_living = "[M.colour] adult slime"
		pet.icon_dead = "[M.colour] baby slime dead"
		pet.colour = "[M.colour]"
		to_chat(user, "You feed the slime the potion, removing its powers and calming it.")
		if(M.mind)
			M.mind.transfer_to(pet)
		qdel (M)
		M = null
		var/newname = ""
		if(pet.client)//leaving the player-controlled slimes the ability to choose their new name
			newname = copytext(sanitize(input(pet, "You have been fed an advanced docility potion, what shall we call you?", "Give yourself a new name", "pet slime") as null|text),1,MAX_NAME_LEN)
		else
			newname = copytext(sanitize(input(user, "Would you like to give the slime a name?", "Name your new pet", "pet slime") as null|text),1,MAX_NAME_LEN)

		if (!newname)
			newname = "pet slime"
		pet.name = newname
		pet.real_name = newname
		qdel (src)

/obj/item/weapon/slimesteroid
	name = "slime steroid"
	desc = "A potent chemical mix that will cause a slime to generate more extract."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"

	attack(mob/living/carbon/slime/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/slime))//If target is not a slime.
			to_chat(user, "<span class='warning'>The steroid only works on baby slimes!</span>")
			return ..()
		if(istype(M, /mob/living/carbon/slime/adult)) //Can't tame adults
			to_chat(user, "<span class='warning'>Only baby slimes can use the steroid!</span>")
			return..()
		if(M.stat)
			to_chat(user, "<span class='warning'>The slime is dead!</span>")
			return..()
		if(M.cores == 3)
			to_chat(user, "<span class='warning'>The slime already has the maximum amount of extract!</span>")
			return..()

		to_chat(user, "You feed the slime the steroid. It now has triple the amount of extract.")
		M.cores = 3
		qdel (src)


/obj/item/weapon/slimenutrient
	name = "slime nutrient"
	desc = "A potent chemical mix that is a great nutrient for slimes."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle12"
	var/Uses = 2

/obj/item/weapon/slimenutrient/attack(mob/living/carbon/slime/M as mob, mob/user as mob)
	if(!istype(M))//If target is not a slime.
		to_chat(user, "<span class='warning'>The steroid only works on slimes!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return..()
	if(M.amount_grown == 10)
		to_chat(user, "<span class='warning'>The slime has already fed enough!</span>")
		return..()

	to_chat(user, "You feed the slime the nutrient. It now appears ready to grow.")
	M.amount_grown = 10

	if (Uses > 0)
		Uses -= 1
	if (Uses == 0)
		qdel (src)

/obj/item/weapon/slimesteroid2
	name = "extract enhancer"
	desc = "A potent chemical mix that will give a slime extract three uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"

	/*afterattack(obj/target, mob/user , flag)
		if(istype(target, /obj/item/slime_extract))
			if(target.enhanced == 1)
				to_chat(user, "<span class='warning'>This extract has already been enhanced!</span>")
				return ..()
			if(target.Uses == 0)
				to_chat(user, "<span class='warning'>You can't enhance a used extract!</span>")
				return ..()
			to_chat(user, "You apply the enhancer. It now has triple the amount of uses.")
			target.Uses = 3
			target.enahnced = 1
			del (src)*/

/obj/item/weapon/slimedupe
	name = "slime duplicator"
	desc = "A potent chemical mix that will force a child slime to split in two!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"

/obj/item/weapon/slimedupe/attack(mob/living/carbon/slime/M as mob, mob/user as mob)
	if(!istype(M, /mob/living/carbon/slime))//target is not a slime
		to_chat(user, "<span class='warning'>The solution only works on slimes!</span>")
		return ..()
	if(istype(M, /mob/living/carbon/slime/adult))//don't allow adults because i'm lazy i don't wanna
		to_chat(user, "<span class='warning'>Only baby slimes can be duplicated!</span>")
		return ..()
	if(M.stat)//dunno if this should be allowed but i think it's probably better this way
		to_chat(user, "<span class='warning'>That slime is dead!</span>")
		return ..()

	to_chat(user, "You splash the cloning juice onto the slime.")

	var/mob/living/carbon/slime/S = new M.primarytype // don't let's start
	S.tame = M.tame
	S.forceMove(get_turf(M))
	qdel(src)

/obj/item/weapon/slimeres
	name = "slime resurrection serum"
	desc = "A potent chemical mix that when used on a slime extact, will bring it to life!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle14"

////////Adamantine Golem stuff I dunno where else to put it
/*
/obj/item/clothing/under/golem
	name = "adamantine skin"
	desc = "a golem's skin"
	icon_state = "golem"
	item_state = "golem"
	_color = "golem"
	has_sensor = 0
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	canremove = 0

/obj/item/clothing/suit/golem
	name = "adamantine shell"
	desc = "a golem's thick outer shell"
	icon_state = "golem"
	item_state = "golem"
	w_class = W_CLASS_LARGE//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|HEAD
	slowdown = 1.0
	clothing_flags = ONESIZEFITSALL
	pressure_resistance = 200 * ONE_ATMOSPHERE
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	canremove = 0
	armor = list(melee = 80, bullet = 20, laser = 20, energy = 10, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/shoes/golem
	name = "golem's feet"
	desc = "sturdy adamantine feet"
	icon_state = "golem"
	item_state = null
	canremove = 0
	clothing_flags = NOSLIP
	slowdown = SHOES_SLOWDOWN+1

/obj/item/clothing/mask/gas/golem
	name = "golem's face"
	desc = "the imposing face of an adamantine golem"
	icon_state = "golem"
	item_state = "golem"
	canremove = 0
	siemens_coefficient = 0

/obj/item/clothing/mask/gas/golem/acidable()
	return 0

/obj/item/clothing/gloves/golem
	name = "golem's hands"
	desc = "strong adamantine hands"
	icon_state = "golem"
	item_state = null
	siemens_coefficient = 0
	canremove = 0


/obj/item/clothing/head/space/golem
	icon_state = "golem"
	item_state = "dermal"
	_color = "dermal"
	name = "golem's head"
	desc = "a golem's head"
	canremove = 0
	flags = FPRINT
	pressure_resistance = 200 * ONE_ATMOSPHERE
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	armor = list(melee = 80, bullet = 20, laser = 20, energy = 10, bomb = 0, bio = 0, rad = 0)
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY

/obj/item/clothing/head/space/golem/acidable()
	return 0
*/
/obj/effect/golem_rune
	anchored = 1
	desc = "a strange rune used to create golems. It glows when spirits are nearby."
	name = "rune"
	icon = 'icons/obj/rune.dmi'
	icon_state = "golem"
	plane = ABOVE_TURF_PLANE
	layer = RUNE_LAYER
	var/list/mob/dead/observer/ghosts[0]

/obj/effect/golem_rune/New()
	..()
	processing_objects.Add(src)

/obj/effect/golem_rune/process()
	if(ghosts.len>0)
		icon_state = "golem2"
	else
		icon_state = "golem"

/obj/effect/golem_rune/attack_hand(mob/living/user as mob)
	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in src.loc)
		if(!check_observer(O))
			continue
		ghost = O
		break
	if(!ghost)
		to_chat(user, "The rune fizzles uselessly. There is no spirit nearby.")
		return
	var/mob/living/carbon/human/golem/G = new /mob/living/carbon/human/golem
	G.real_name = G.species.makeName()
	G.forceMove(src.loc) //we use move to get the entering procs - this fixes gravity
	G.key = ghost.key
	to_chat(G, "You are an adamantine golem. You move slowly, but are highly resistant to heat and cold as well as impervious to burn damage. You are unable to wear most clothing, but can still use most tools. Serve [user], and assist them in completing their goals at any cost.")
	qdel (src)
	if(ticker.mode.name == "sandbox")
		G.CanBuild()
		to_chat(G, "Sandbox tab enabled.")


/obj/effect/golem_rune/proc/announce_to_ghosts()
	for(var/mob/dead/observer/O in player_list)
		if(O.client)
			var/area/A = get_area(src)
			if(A)
				to_chat(O, "<span class=\"recruit\">Golem rune created in [A.name]. (<a href='?src=\ref[O];jump=\ref[src]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Sign Up</a>)</span>")

/obj/effect/golem_rune/Topic(href,href_list)
	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		volunteer(O)

/obj/effect/golem_rune/attack_ghost(var/mob/dead/observer/O)
	if(!O)
		return
	volunteer(O)

/obj/effect/golem_rune/proc/check_observer(var/mob/dead/observer/O)
	if(!O)
		return 0
	if(!O.client)
		return 0
	if(O.mind && O.mind.current && O.mind.current.stat != DEAD)
		return 0
	return 1

/obj/effect/golem_rune/proc/volunteer(var/mob/dead/observer/O)
	if(O in ghosts)
		ghosts.Remove(O)
		to_chat(O, "<span class='warning'>You are no longer signed up to be a golem.</span>")
	else
		if(!check_observer(O))
			to_chat(O, "<span class='warning'>You are not eligable.</span>")
			return
		ghosts.Add(O)
		to_chat(O, "<span class='notice'>You are signed up to be a golem.</span>")


/mob/living/carbon/slime/has_eyes()
	return 0

/mob/living/carbon/slime/proc/rabid()
	if(stat)
		return
	if(client)
		return

	var/rabid_type = /mob/living/simple_animal/hostile/slime
	var/rabid_age = "baby"
	if(isslimeadult(src))
		rabid_type = /mob/living/simple_animal/hostile/slime/adult
		rabid_age = "adult"

	var/mob/living/simple_animal/hostile/slime/rabid = new rabid_type(loc)
	rabid.icon_state = "[colour] [rabid_age] slime eat"
	rabid.icon_living = "[colour] [rabid_age] slime eat"
	rabid.icon_dead = "[colour] baby slime dead"
	rabid.colour = "[colour]"

	for(var/mob/M in Friends)
		rabid.friends += M

	qdel (src)

/mob/living/carbon/slime/IgniteMob()
	return 0

//////////////////////////////Old shit from metroids/RoRos, and the old cores, would not take much work to re-add them////////////////////////

/*
// Basically this slime Core catalyzes reactions that normally wouldn't happen anywhere
/obj/item/slime_core
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "slime extract"
	flags = 0
	force = 1.0
	w_class = W_CLASS_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 6
	origin_tech = Tc_BIOTECH + "=4"
	var/POWERFLAG = 0 // sshhhhhhh
	var/Flush = 30
	var/Uses = 5 // uses before it goes inert

/obj/item/slime_core/New()
		..()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		POWERFLAG = rand(1,10)
		Uses = rand(7, 25)
		//flags |= NOREACT
/*
		spawn()
			Life()

	proc/Life()
		while(src)
			if(timestopped)
				while(timestopped)
					sleep(2)
			sleep(25)
			Flush--
			if(Flush <= 0)
				reagents.clear_reagents()
				Flush = 30
*/



/obj/item/weapon/reagent_containers/food/snacks/egg/slime
	name = "slime egg"
	desc = "A small, gelatinous egg."
	icon = 'icons/mob/mob.dmi'
	icon_state = "slime egg-growing"
	bitesize = 12
	origin_tech = Tc_BIOTECH + "=4"
	var/grown = 0

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(SLIMEJELLY, 1)
	spawn(rand(1200,1500))//the egg takes a while to "ripen"
		Grow()

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/proc/Grow()
	grown = 1
	icon_state = "slime egg-grown"
	processing_objects.Add(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/proc/Hatch()
	processing_objects.Remove(src)
	var/turf/T = get_turf(src)
	src.visible_message("<span class='notice'>The [name] pulsates and quivers!</span>")
	spawn(rand(50,100))
		src.visible_message("<span class='notice'>The [name] bursts open!</span>")
		new/mob/living/carbon/slime(T)
		qdel(src)


/obj/item/weapon/reagent_containers/food/snacks/egg/slime/process()
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	if (environment.toxins > MOLES_PLASMA_VISIBLE)//plasma exposure causes the egg to hatch
		src.Hatch()

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype( W, /obj/item/toy/crayon ))
		return
	else
		..()
*/
