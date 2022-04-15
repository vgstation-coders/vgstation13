/mob/living/carbon/metroid
	name = "baby metroid"
	icon = 'icons/mob/metroids.dmi'
	icon_state = "standard baby metroid"
	pass_flags = PASSTABLE
	voice_message = "skree!"
	say_message = "hums"

	layer = 5

	maxHealth = 150
	health = 150
	gender = NEUTER

	update_icon = 0
	nutrition = 700 // 1000 = max

	see_in_dark = 8
	update_metroids = 0

	// canstun and canweaken don't affect metroids because they ignore stun and weakened variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANPARALYSE|CANPUSH

	var/cores = 3 // the number of /obj/item/metroid_core's the metroid has left inside

	var/powerlevel = 0 	// 1-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the metroid has been overfed, if 10, grows into an adult
						 // if adult: if 10: reproduces


	var/mob/living/Victim = null // the person the metroid is currently feeding on
	var/mob/living/Target = null // AI variable - tells the Metroid to hunt this down

	var/attacked = 0 // determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/tame = 0 // if set to 1, the Metroid will not eat humans ever, or attack them
	var/rabid = 0 // if set to 1, the Metroid will attack and eat anything it comes in contact with

	var/list/Friends = list() // A list of potential friends
	var/list/FriendsWeight = list() // A list containing values respective to Friends. This determines how many times a Metroid "likes" something. If the Metroid likes it more than 2 times, it becomes a friend

	// Metroids pass on genetic data, so all their offspring have the same "Friends",

	///////////TIME FOR SUBSPECIES

	var/subtype = "standard"
	var/primarytype = /mob/living/carbon/metroid
	// Just so it's more flexible.
	var/mutationtypes=list(
		/mob/living/carbon/metroid/orange,
		/mob/living/carbon/metroid/metal,
		/mob/living/carbon/metroid/blue,
		/mob/living/carbon/metroid/purple
	)
	var/adulttype = /mob/living/carbon/metroid/adult
	var/coretype = /obj/item/metroid_core

/mob/living/carbon/metroid/adult
	name = "adult metroid"
	icon = 'icons/mob/metroids.dmi'
	icon_state = "standard adult metroid"

	health = 200
	gender = NEUTER

	update_icon = 0
	nutrition = 800 // 1200 = max


/mob/living/carbon/metroid/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "baby metroid")
		name = text("[subtype] baby metroid ([rand(1, 1000)])")
	else
		name = text("[subtype] adult metroid ([rand(1,1000)])")
	real_name = name
	spawn (1)
		regenerate_icons()
		src << "\blue Your icons have been generated!"
	..()

/mob/living/carbon/metroid/adult/New()
	verbs.Remove(/mob/living/carbon/metroid/verb/ventcrawl)
	..()

/mob/living/carbon/metroid/movement_delay()
	var/tally = 0

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45) tally += (health_deficiency / 25)

	if (bodytemperature < 183.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	if(reagents)
		if(reagents.has_reagent("hyperzine")) // hyperzine slows Metroids down
			tally *= 2 // moves twice as slow

		if(reagents.has_reagent("frostoil")) // frostoil also makes them move VEEERRYYYYY slow
			tally *= 5

	if(health <= 0) // if damaged, the metroid moves twice as slow
		tally *= 2

	if (bodytemperature >= 330.23) // 135 F
		return -1	// Metroids become supercharged at high temperatures

	return tally+config.metroid_delay


/mob/living/carbon/metroid/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1

		if(isobj(AM))
			if(!client && powerlevel > 0)
				var/probab = 10
				switch(powerlevel)
					if(1 to 2) probab = 20
					if(3 to 4) probab = 30
					if(5 to 6) probab = 40
					if(7 to 8) probab = 60
					if(9) 	   probab = 70
					if(10) 	   probab = 95
				if(prob(probab))


					if(istype(AM, /obj/structure/window) || istype(AM, /obj/structure/grille))
						if(istype(src, /mob/living/carbon/metroid/adult))
							if(nutrition <= 600 && !Atkcool)
								AM.attack_metroid(src)
								spawn()
									Atkcool = 1
									sleep(15)
									Atkcool = 0
						else
							if(nutrition <= 500 && !Atkcool)
								if(prob(5))
									AM.attack_metroid(src)
									spawn()
										Atkcool = 1
										sleep(15)
										Atkcool = 0

		if(ismob(AM))
			var/mob/tmob = AM

			if(istype(src, /mob/living/carbon/metroid/adult))
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
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( now_pushing ))
			now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/structure/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = null
		return
	return

/mob/living/carbon/metroid/Process_Spacemove()
	return 2


/mob/living/carbon/metroid/Stat()
	..()

	statpanel("Status")
	if(istype(src, /mob/living/carbon/metroid/adult))
		stat(null, "Health: [round((health / 200) * 100)]%")
	else
		stat(null, "Health: [round((health / 150) * 100)]%")


	if (client.statpanel == "Status")
		if(istype(src,/mob/living/carbon/metroid/adult))
			stat(null, "Nutrition: [nutrition]/1200")
			if(amount_grown >= 10)
				stat(null, "You can reproduce!")
		else
			stat(null, "Nutrition: [nutrition]/1000")
			if(amount_grown >= 10)
				stat(null, "You can evolve!")

		stat(null,"Power Level: [powerlevel]")


/mob/living/carbon/metroid/adjustFireLoss(amount)
	..(-abs(amount)) // Heals them
	return

/mob/living/carbon/metroid/bullet_act(var/obj/item/projectile/Proj)
	attacked += 10
	..(Proj)
	return 0


/mob/living/carbon/metroid/emp_act(severity)
	powerlevel = 0 // oh no, the power!
	..()

/mob/living/carbon/metroid/ex_act(severity)

	if (stat == 2 && client)
		return

	else if (stat == 2 && !client)
		del(src)
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


/mob/living/carbon/metroid/blob_act()
	if (stat == 2)
		return
	var/shielded = 0

	var/damage = null
	if (stat != 2)
		damage = rand(10,30)

	if(shielded)
		damage /= 4

		//paralysis += 1

	show_message("\red The blob attacks you!")

	adjustFireLoss(damage)

	updatehealth()
	return


/mob/living/carbon/metroid/u_equip(obj/item/W as obj)
	return


/mob/living/carbon/metroid/attack_ui(slot)
	return

/mob/living/carbon/metroid/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		adjustBruteLoss((istype(O, /obj/effect/meteor/small) ? 10 : 25))
		adjustFireLoss(30)

		updatehealth()
	return


/mob/living/carbon/metroid/attack_metroid(mob/living/carbon/metroid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if(Victim) return // can't attack while eating!

	if (health > -100)

		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>The [M.name] has bit []!</B>", src), 1)

		var/damage = rand(1, 3)
		attacked += 5

		if(istype(src, /mob/living/carbon/metroid/adult))
			damage = rand(1, 6)
		else
			damage = rand(1, 3)

		adjustBruteLoss(damage)


		updatehealth()

	return


/mob/living/carbon/metroid/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[M]</B> [M.attacktext] [src]!", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/carbon/metroid/attack_paw(mob/living/carbon/monkey/M as mob)
	if(!(istype(M, /mob/living/carbon/monkey)))	return//Fix for aliens receiving double messages when attacking other aliens.

	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return
	..()

	switch(M.a_intent)

		if ("help")
			help_shake_act(M)
		else
			if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
				return
			if (health > 0)
				attacked += 10
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M.name] has attacked [src]!</B>"), 1)
				adjustBruteLoss(rand(1, 3))
				updatehealth()
	return


/mob/living/carbon/metroid/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	..()

	if(Victim)
		if(Victim == M)
			if(prob(60))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\red [M] attempts to wrestle \the [name] off!", 1)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\red [M] manages to wrestle \the [name] off!", 1)
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
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\red [M] attempts to wrestle \the [name] off of [Victim]!", 1)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\red [M] manages to wrestle \the [name] off of [Victim]!", 1)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				if(prob(80) && !client)
					Discipline++

					if(!istype(src, /mob/living/carbon/metroid/adult))
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




	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == "hurt")//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.charge -= 2500
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>", 1, "\red You hear someone fall.", 2)
					return
				else
					M << "\red Not enough charge! "
					return

	switch(M.a_intent)

		if ("help")
			help_shake_act(M)

		if ("grab")
			if (M == src)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M, M, src )

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

		else

			var/damage = rand(1, 9)

			attacked += 10
			if (prob(90))
				if (HULK in M.mutations)
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
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)

				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)
	return



/mob/living/carbon/metroid/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	switch(M.a_intent)
		if ("help")
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\blue [M] caresses [src] with its scythe like arm."), 1)

		if ("hurt")

			if ((prob(95) && health > 0))
				attacked += 10
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if (damage >= 25)
					damage = rand(20, 40)
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has slashed [name]!</B>", M), 1)
				else
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has wounded [name]!</B>", M), 1)
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to lunge at [name]!</B>", M), 1)

		if ("grab")
			if (M == src)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M, M, src )

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [name] passively!", M), 1)

		if ("disarm")
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			var/damage = 5
			attacked += 10

			if(prob(95))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has tackled [name]!</B>", M), 1)

				if(Victim)
					Victim = null
					anchored = 0
					if(prob(80) && !client)
						Discipline++
						if(!istype(src, /mob/living/carbon/metroid))
							if(Discipline == 1)
								attacked = 0

				spawn()
					SStun = 1
					sleep(rand(5,20))
					SStun = 0

				spawn(0)

					step_away(src,M,15)
					sleep(3)
					step_away(src,M,15)

			else
				drop_item()
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has disarmed [name]!</B>", M), 1)
			adjustBruteLoss(damage)
			updatehealth()
	return


/mob/living/carbon/metroid/restrained()
	return 0


mob/living/carbon/metroid/var/co2overloadtime = null
mob/living/carbon/metroid/var/temperature_resistance = T0C+75


/mob/living/carbon/metroid/show_inv(mob/user as mob)

	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR><BR>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[name];size=340x480"))
	onclose(user, "mob[name]")
	return

/mob/living/carbon/metroid/updatehealth()
	if(status_flags & GODMODE)
		if(istype(src, /mob/living/carbon/metroid/adult))
			health = 200
		else
			health = 150
		stat = CONSCIOUS
	else
		// metroids can't suffocate unless they suicide. They are also not harmed by fire
		if(istype(src, /mob/living/carbon/metroid/adult))
			health = 200 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())
		else
			health = 150 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())


/mob/living/carbon/metroid/proc/get_obstacle_ok(atom/A)
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
						if(!border_obstacle.CheckExit(D, A))
							check_1 = 0
				for(var/obj/border_obstacle in get_turf(A))
					if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
						if(!border_obstacle.CanPass(D, D.loc, 1, 0))
							check_1 = 0

			D.loc = src.loc
			if(step_to(D, Step_2))
				check_2 = 1

				for(var/obj/border_obstacle in Step_2)
					if(border_obstacle.flags & ON_BORDER)
						if(!border_obstacle.CheckExit(D, A))
							check_2 = 0
				for(var/obj/border_obstacle in get_turf(A))
					if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
						if(!border_obstacle.CanPass(D, D.loc, 1, 0))
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
					if(!border_obstacle.CheckExit(D, A))
						ok = 0

			//Next, check objects to block entry that are on the border
			for(var/obj/border_obstacle in get_turf(A))
				if((border_obstacle.flags & ON_BORDER) && (A != border_obstacle))
					if(!border_obstacle.CanPass(D, D.loc, 1, 0))
						ok = 0

	//del(D)
	//Garbage Collect Dummy
	D.loc = null
	D = null
	if (!( ok ))

		return 0

	return 1


// Basically this Metroid Core catalyzes reactions that normally wouldn't happen anywhere
/obj/item/metroid_core
	name = "metroid core"
	desc = "A very slimy and tender part of a metroidbeast. Legends claim these to have \"magical powers\"."
	icon = 'icons/obj/metroids.dmi'
	icon_state = "metroid core"
	flags = TABLEPASS
	force = 1.0
	w_class = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 6
	origin_tech = "biotech=4"
	var/Uses = 1 // uses before it goes inert
	var/enhanced = 0 //has it been enhanced before?
/*
	attackby(obj/item/O as obj, mob/user as mob)
		if(istype(O, /obj/item/weapon/metsteroid2))
			if(enhanced == 1)
				user << "\red This extract has already been enhanced!"
				return ..()
			if(Uses == 0)
				user << "\red You can't enhance a used extract!"
				return ..()
			user <<"You apply the enhancer. It now has triple the amount of uses."
			Uses = 3
			enhanced = 1
			del (O)
*/

/obj/item/metroid_core/New()
		..()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src

/obj/item/metroid_core/grey
	name = "grey metroid core"
	icon_state = "grey metroid core"

/obj/item/metroid_core/gold
	name = "gold metroid core"
	icon_state = "gold metroid core"

/obj/item/metroid_core/silver
	name = "silver metroid core"
	icon_state = "silver metroid core"

/obj/item/metroid_core/metal
	name = "metal metroid core"
	icon_state = "metal metroid core"

/obj/item/metroid_core/purple
	name = "purple metroid core"
	icon_state = "purple metroid core"

/obj/item/metroid_core/darkpurple
	name = "dark purple metroid core"
	icon_state = "dark purple metroid core"

/obj/item/metroid_core/orange
	name = "orange metroid core"
	icon_state = "orange metroid core"

/obj/item/metroid_core/yellow
	name = "yellow metroid core"
	icon_state = "yellow metroid core"

/obj/item/metroid_core/red
	name = "red metroid core"
	icon_state = "red metroid core"

/obj/item/metroid_core/blue
	name = "blue metroid core"
	icon_state = "blue metroid core"

/obj/item/metroid_core/darkblue
	name = "dark blue metroid core"
	icon_state = "dark blue metroid core"

/obj/item/metroid_core/pink
	name = "pink metroid core"
	icon_state = "pink metroid core"

/obj/item/metroid_core/green
	name = "green metroid core"
	icon_state = "green metroid core"

/obj/item/metroid_core/lightpink
	name = "light pink metroid core"
	icon_state = "light pink metroid core"

/obj/item/metroid_core/black
	name = "black metroid core"
	icon_state = "black metroid core"

/obj/item/metroid_core/oil
	name = "oil metroid core"
	icon_state = "oil metroid core"

/obj/item/metroid_core/adamantine
	name = "adamantine metroid core"
	icon_state = "adamantine metroid core"

/obj/item/metroid_core/bluespace
	name = "bluespace metroid core"
	icon_state = "bluespace metroid core"

/obj/item/metroid_core/pyrite
	name = "pyrite metroid core"
	icon_state = "pyrite metroid core"

/obj/item/metroid_core/cerulean
	name = "cerulean metroid core"
	icon_state = "cerulean metroid core"

/obj/item/metroid_core/sepia
	name = "sepia metroid core"
	icon_state = "sepia metroid core"


////Pet metroid Creation///

/obj/item/weapon/metroidpotion
	name = "docility potion"
	desc = "A potent chemical mix that will nullify a metroid's powers, causing it to become docile and tame."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"

	attack(mob/living/carbon/metroid/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/metroid))//If target is not a metroid.
			user << "\red The potion only works on baby metroids!"
			return ..()
		if(istype(M, /mob/living/carbon/metroid/adult)) //Can't tame adults
			user << "\red Only baby metroids can be tamed!"
			return..()
		if(M.stat)
			user << "\red The metroid is dead!"
			return..()
		var/mob/living/simple_animal/metroid/pet = new /mob/living/simple_animal/metroid(M.loc)
		pet.icon_state = "[M.subtype] baby metroid"
		pet.icon_living = "[M.subtype] baby metroid"
		pet.icon_dead = "[M.subtype] baby metroid dead"
		pet.colour = "[M.subtype]"
		user <<"You feed the metroid the potion, removing it's powers and calming it."
		del (M)
		var/newname = copytext(sanitize(input(user, "Would you like to give the metroid a name?", "Name your new pet", "pet metroid") as null|text),1,MAX_NAME_LEN)

		if (!newname)
			newname = "pet metroid"
		pet.name = newname
		pet.real_name = newname
		del (src)

/obj/item/weapon/metroidpotion2
	name = "advanced docility potion"
	desc = "A potent chemical mix that will nullify a metroid's powers, causing it to become docile and tame. This one is meant for adult metroids"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"

	attack(mob/living/carbon/metroid/adult/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/metroid/adult))//If target is not a metroid.
			user << "\red The potion only works on adult metroids!"
			return ..()
		if(M.stat)
			user << "\red The metroid is dead!"
			return..()
		var/mob/living/simple_animal/adultmetroid/pet = new /mob/living/simple_animal/adultmetroid(M.loc)
		pet.icon_state = "[M.subtype] adult metroid"
		pet.icon_living = "[M.subtype] adult metroid"
		pet.icon_dead = "[M.subtype] baby metroid dead"
		pet.colour = "[M.subtype]"
		user <<"You feed the metroid the potion, removing it's powers and calming it."
		del (M)
		var/newname = copytext(sanitize(input(user, "Would you like to give the metroid a name?", "Name your new pet", "pet metroid") as null|text),1,MAX_NAME_LEN)

		if (!newname)
			newname = "pet metroid"
		pet.name = newname
		pet.real_name = newname
		del (src)

/* Let's just not use this shit at all.

/obj/item/weapon/metroidsteroid
	name = "metroid steroid"
	desc = "A potent chemical mix that will cause a metroid to generate more extract."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"

	attack(mob/living/carbon/metroid/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/metroid))//If target is not a metroid.
			user << "\red The steroid only works on baby metroids!"
			return ..()
		if(istype(M, /mob/living/carbon/metroid/adult)) //Can't tame adults
			user << "\red Only baby metroids can use the steroid!"
			return..()
		if(M.stat)
			user << "\red The metroid is dead!"
			return..()
		if(M.cores == 3)
			user <<"\red The metroid already has the maximum amount of extract!"
			return..()

		user <<"You feed the metroid the steroid. It now has triple the amount of extract."
		M.cores = 3
		del (src)

/obj/item/weapon/metroidsteroid2
	name = "extract enhancer"
	desc = "A potent chemical mix that will give a metroid core three uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"

	afterattack(obj/target, mob/user , flag)
		if(istype(target, /obj/item/metroid_extract))
			if(target.enhanced == 1)
				user << "\red This extract has already been enhanced!"
				return ..()
			if(target.Uses == 0)
				user << "\red You can't enhance a used extract!"
				return ..()
			user <<"You apply the enhancer. It now has triple the amount of uses."
			target.Uses = 3
			target.enahnced = 1
			del (src)
*/

// MAKE THE CORE A DRIED-UP BALL OF USELESSNESS
/obj/item/metroid_core/proc/killCore()
	name = "dead metroid core"
	desc = "It looks like charcoal and smells like burnt flesh."
	icon = 'icons/mob/metroids.dmi'
	icon_state="dead metroid core"
	Uses=0
	origin_tech="" // idfk

/obj/item/weapon/reagent_containers/food/snacks/egg/metroid
	name = "metroid egg"
	desc = "A small, gelatinous egg."
	icon = 'icons/mob/mob.dmi'
	icon_state = "metroid egg-growing"
	bitesize = 12
	origin_tech = "biotech=4"
	var/sentient=0 // Pick a ghost to inhabit this after birth.
	var/hatchedtype=/mob/living/carbon/metroid
	var/grown = 0

/obj/item/weapon/reagent_containers/food/snacks/egg/metroid/New()
	..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("metroid", 1)
	spawn(rand(1200,1500))//the egg takes a while to "ripen"
		Grow()

/obj/item/weapon/reagent_containers/food/snacks/egg/metroid/proc/Grow()
	grown = 1
	icon_state = "metroid egg-grown"
	processing_objects.Add(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/egg/metroid/proc/Hatch()
	processing_objects.Remove(src)
	var/turf/T = get_turf(src)
	src.visible_message("\blue The [name] pulsates and quivers!")
	spawn(rand(50,100))
		src.visible_message("\blue The [name] bursts open!")
		var/mob/living/carbon/metroid/HT = new hatchedtype(T)
		if(sentient)
			findMindForMetroid(HT)
		del(src)


/obj/item/weapon/reagent_containers/food/snacks/egg/metroid/process()
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	if(!environment)
		return

	//var/environment_heat_capacity = environment.heat_capacity()
	var/loc_temp = T0C
	if(istype(get_turf(src), /turf/space))
		//environment_heat_capacity = loc:heat_capacity
		var/turf/heat_turf = get_turf(src)
		loc_temp = heat_turf.temperature
	else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		loc_temp = loc:air_contents.temperature
	else
		loc_temp = environment.temperature


	if(loc_temp >= 290) // Normal heat level is 293.15, so lets allow some wiggle room.
		src.Hatch()

/obj/item/weapon/reagent_containers/food/snacks/egg/metroid/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype( W, /obj/item/toy/crayon ))
		return
	else
		..()