/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal and anchored rods used to seperate rooms and keep all but the most equipped crewmen out."
	icon_state = "r_wall"
	opacity = 1
	density = 1

	walltype = "rwall"
	hardness = 90

	var/d_state = 0

/turf/simulated/wall/r_wall/examine(mob/user)
	..()
	if(d_state)
		switch(d_state) //How fucked or unfinished is our wall
			if(1)
				user << "It has no outer grille"
			if(2)
				user << "It has no outer grille and the external reinforced cover is exposed"
			if(3)
				user << "It has no outer grille and the external reinforced cover has been welded into"
			if(4)
				user << "It has no outer grille or no external reinforced cover and the external support rods are exposed"
			if(5)
				user << "It has no outer grille or no external reinforced cover and the external support rods are loose"
			if(6)
				user << "It has no outer grille, external reinforced cover or external support rods and the inner reinforced cover is exposed" //And that's terrible

/turf/simulated/wall/r_wall/proc/update_icon()
	if(!d_state) //Are we under construction or deconstruction ?
		relativewall_neighbours() //Well isn't that odd, let's pass this to smoothwall.dm
		return //Now fuck off
	icon_state = "r_wall-[d_state]"  //You can thank me later

/turf/simulated/wall/r_wall/attackby(obj/item/W as obj, mob/user as mob)

	if(!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	//Get the user's location
	if(!istype(user.loc, /turf))
		return	//Can't do this stuff whilst inside objects and such //Thanks BYOND

	if(rotting)
		if(W.is_hot()) //Yes, you can do it with a welding tool, or a lighter, or a candle, or an energy sword
			user.visible_message("<span class='notice'>[user] burns the fungi away with \the [W].</span>", \
			"<span class='notice'>You burn the fungi away with \the [W].</span>")
			playsound(src, 'sound/items/Welder.ogg', 10, 1)
			for(var/obj/effect/E in src) //WHYYYY
				if(E.name == "Wallrot") //WHYYYYYYYYY
					qdel(E)
			rotting = 0
			return
		if(istype(W,/obj/item/weapon/soap))
			user.visible_message("<span class='notice'>[user] forcefully scrubs the fungi away with \his [W].</span>", \
			"<span class='notice'>You forcefully scrub the fungi away with your [W].</span>")
			for(var/obj/effect/E in src)
				if(E.name == "Wallrot")
					qdel(E)
			rotting = 0
			return
		else if(!W.is_sharp() && W.force >= 10 || W.force >= 20)
			user.visible_message("<span class='warning'>With one strong swing, [user] destroys the rotting [src] with his [W].</span>", \
			"<span class='notice'>With one strong swing, the rotting [src] crumbles away under your [W].</span>")
			src.dismantle_wall()

			var/pdiff = performWallPressureCheck(src.loc)
			if(pdiff)
				message_admins("[user.real_name] ([formatPlayerPanel(user,user.ckey)]) broke a rotting reinforced wall with a pdiff of [pdiff] at [formatJumpTo(loc)]!")
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite)
		if(W.is_hot()) //HEY CAN THIS SET THE THERMITE ON FIRE ?
			thermitemelt(user) //There, I just saved you fifty lines of redundant typechecks and awful snowflake coding
			user.visible_message("<span class='warning'>[user] sets \the [src] ablaze with a swing of \his [W]</span>", \
			"<span class='warning'>You set \the [src] ablaze with a swing of your [W]</span>")
			return

	//Deconstruction and reconstruction
	switch(d_state)
		if(0)
			if(istype(W, /obj/item/weapon/wirecutters))
				playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
				src.d_state = 1
				update_icon()
				getFromPool(/obj/item/stack/rods, get_turf(src), 2)
				user.visible_message("<span class='warning'>[user] cuts out the outer grille.</span>", \
				"<span class='notice'>You cut out the outer grille, exposing the reinforced cover.</span>")
				return

		if(1)
			if(istype(W, /obj/item/weapon/screwdriver))
				user.visible_message("<span class='notice'>[user] begins unsecuring the reinforced cover.</span>", \
				"<span class='notice'>You begin unsecuring the reinforced cover.</span>")
				playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)

				if(do_after(user, 40))
					src.d_state = 2
					update_icon()
					user.visible_message("<span class='warning'>[user] unsecures the reinforced cover.</span>", \
					"<span class='notice'>You unsecure the reinforced cover.</span>")
				return

			//Repairing or fourth step to finish reinforced wall construction
			else if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/rods/O = W
				if(O.amount < 2)
					return
				O.use(2)
				src.d_state = 0
				update_icon()	//Call smoothwall.dm, goes through update_icon()
				user.visible_message("<span class='notice'>[user] adds an outer grille to the reinforced cover.</span>", \
				"<span class='notice'>You add an outer grille to the reinforced cover.</span>")
				return

		if(2)
			if(istype(W, /obj/item/weapon/weldingtool))

				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0, user))
					user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s cover.</span>", \
					"<span class='notice'>You begin slicing through \the [src]'s cover.</span>", \
					"<span class='warning'>You hear welding noises.</span>")
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user, 60))
						playsound(src, 'sound/items/Welder.ogg', 100, 1) //Not an error, play welder sound again
						src.d_state = 3
						update_icon()
						user.visible_message("<span class='warning'>[user] finishes weakening \the [src]'s cover.</span>", \
						"<span class='notice'>You finish weakening \the [src]'s cover.</span>", \
						"<span class='warning'>You hear welding noises.</span>")
				else
					user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
				return

			if(istype(W, /obj/item/weapon/pickaxe/plasmacutter)) //Ah, snowflake coding, my favorite

				user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s cover.</span>", \
					"<span class='notice'>You begin slicing through \the [src]'s cover.</span>", \
					"<span class='warning'>You hear welding noises.</span>")
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 40))
					playsound(src, 'sound/items/Welder.ogg', 100, 1) //Not an error, play welder sound again
					src.d_state = 3
					update_icon()
					user.visible_message("<span class='warning'>[user] finishes weakening \the [src]'s cover.</span>", \
						"<span class='notice'>You finish weakening \the [src]'s cover.</span>", \
						"<span class='warning'>You hear welding noises.</span>")
				return

		if(3)
			if(istype(W, /obj/item/weapon/crowbar))

				user.visible_message("<span class='warning'>[user] starts prying off \the [src]'s cover.</span>", \
				"<span class='notice'>You struggle to pry off \the [src]'s cover.</span>", \
				"<span class='warning'>You hear a crowbar.</span>")
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				if(do_after(user, 100))
					playsound(src, 'sound/items/Deconstruct.ogg', 100, 1) //SLAM
					src.d_state = 4
					update_icon()
					getFromPool(/obj/item/stack/sheet/plasteel, get_turf(src))
					user.visible_message("<span class='warning'>[user] pries off \the [src]'s cover.</span>", \
					"<span class='notice'>You pry off \the [src]'s cover.</span>")
				return

		if(4)
			if(istype(W, /obj/item/weapon/wrench))

				user.visible_message("<span class='warning'>[user] starts removing the bolts anchoring the support rods.</span>", \
				"<span class='notice'>You start removing the bolts anchoring the support rods.</span>")
				playsound(src, 'sound/items/Ratchet.ogg', 100, 1)

				if(do_after(user, 40))
					src.d_state = 5
					update_icon()
					user.visible_message("<span class='warning'>[user] removes the bolts anchoring the support rods.</span>", \
					"<span class='notice'>You remove the bolts anchoring the support rods.</span>")
				return

			//Third construction step, add the second plasteel sheet
			else if(istype(W, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/P = W
				user.visible_message("<span class='notice'>[user] starts installing a reinforced cover.</span>", \
				"<span class='notice'>You start installing a reinforced cover.</span>")
				playsound(src, 'sound/items/Deconstruct.ogg', 100, 1)

				if(do_after(user, 50))
					P.use(1)
					src.d_state = 1 //A new pristine reinforced cover, go straight to finishing the wall with rods
					update_icon()
					user.visible_message("<span class='notice'>[user] finishes installing a reinforced cover.</span>", \
					"<span class='notice'>You finish installing a reinforced cover.</span>")
				return

		if(5)
			if(istype(W, /obj/item/weapon/weldingtool))

				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					user.visible_message("<span class='warning'>[user] begins slicing through the external support rods.</span>", \
					"<span class='notice'>You begin slicing through the external support rods.</span>")
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user, 100))
						playsound(src, 'sound/items/Welder.ogg', 100, 1) //Not an error, play welder sound again
						src.d_state = 6
						update_icon()
						var/obj/item/stack/rods/R = getFromPool(/obj/item/stack/rods, get_turf(src))
						R.amount = 2
						user.visible_message("<span class='warning'>[user] slices through the external support rods.</span>", \
						"<span class='notice'>You slice through the external support rods, exposing the last reinforced sheath.</span>")
				else
					user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
				return

			if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))

				user.visible_message("<span class='warning'>[user] begins slicing through the external support rods.</span>", \
				"<span class='notice'>You begin slicing through the external support rods.</span>")
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, 70))
					playsound(src, 'sound/items/Welder.ogg', 100, 1)
					src.d_state = 6
					update_icon()
					new /obj/item/stack/rods(src)
					user.visible_message("<span class='warning'>[user] slices through the external support rods.</span>", \
					"<span class='notice'>You slice through the external support rods, exposing the inner reinforced cover.</span>")
				return

			//Second construction or repair step, tighten the anchoring bolts
			else if(istype(W, /obj/item/weapon/wrench))

				user.visible_message("<span class='notice'>[user] starts tightening the bolts anchoring the support rods.</span>", \
				"<span class='notice'>You start tightening the bolts anchoring the support rods.</span>")
				playsound(src, 'sound/items/Ratchet.ogg', 100, 1)

				if(do_after(user, 40))
					src.d_state = 4
					update_icon()
					user.visible_message("<span class='notice'>[user] tightens the bolts anchoring the support rods.</span>", \
					"<span class='notice'>You tighten the bolts anchoring the support rods.</span>")
				return

		if(6)
			if(istype(W, /obj/item/weapon/crowbar))

				user.visible_message("<span class='warning'>[user] starts prying off the inner reinforced cover.</span>", \
				"<span class='notice'>You struggle to pry off the inner reinforced cover.</span>")
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				if(do_after(user, 100))
					user.visible_message("<span class='warning'>[user] pries off the inner reinforced cover.</span>", \
					"<span class='notice'>You pry off the inner reinforced cover.</span>")
					dismantle_wall() //Mr. Engineer, break down that reinforced wall
				return

			//Repairing and starting reinforced wall construction (after finishing the girder fluff)
			else if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/rods/O = W
				if(O.amount < 2)
					return
				O.use(2)
				src.d_state = 5
				update_icon()
				user.visible_message("<span class='notice'>[user] installs external support rods on the reinforced cover.</span>", \
				"<span class='notice'>You install external support rods on the reinforced cover.</span>")
				return

//This is where we perform actions that aren't deconstructing, constructing or thermiting the reinforced wall

	//Drilling
	//Needs a diamond drill or equivalent
	if(istype(W, /obj/item/weapon/pickaxe))

		var/obj/item/weapon/pickaxe/PK = W
		if(!(PK.diggables & DIG_RWALLS))
			return

		user.visible_message("<span class='warning'>[user] begins [PK.drill_verb] straight into \the [src].</span>", \
		"<span class='notice'>You begin [PK.drill_verb] straight into \the [src].</span>")
		playsound(src, PK.drill_sound, 100, 1)
		if(do_after(user, PK.digspeed * 50))
			user.visible_message("<span class='notice'>[user]'s [PK] tears though the last of \the [src], leaving nothing but a girder.</span>", \
			"<span class='notice'>Your [PK] tears though the last of \the [src], leaving nothing but a girder.</span>")
			dismantle_wall()
		return

	else if(istype(W, /obj/item/mounted))
		return

	//Finally, CHECKING FOR FALSE WALLS if it isn't damaged
	//This is obsolete since reinforced false walls were commented out, but gotta slap the wall with my hand anyways !
	else if(!d_state)
		return attack_hand(user)
	return

/turf/simulated/wall/r_wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()

/turf/simulated/wall/r_wall/ex_act(severity)
	if(rotting)
		severity = 1.0
	switch(severity)
		if(1.0)
			if(prob(66)) //It's "bomb-proof"
				dismantle_wall(1,1) //So it isn't completely destroyed, nice uh ?
			else
				dismantle_wall(0,1) //Fuck it up nicely
		if(2.0)
			if(prob(25)) //Fairly likely to stand, point-blank damage is "gone"
				dismantle_wall(0,1)
			else
				src.d_state = 4
				update_icon()
				getFromPool(/obj/item/stack/rods, get_turf(src)) //Lose one rod, because it blasted right through
				getFromPool(/obj/item/stack/sheet/plasteel, get_turf(src))
		if(3.0)
			if(prob(15))
				dismantle_wall(0,1)
			else //If prob fails, break the outer safety grille to look like scrap damage
				src.d_state = 1
				update_icon()
				getFromPool(/obj/item/stack/rods, get_turf(src), 2)
	return
