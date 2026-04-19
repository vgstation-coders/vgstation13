#define WALLCOMPLETED 0
#define WALLCOVEREXPOSED 1
#define WALLCOVERUNSECURED 2
#define WALLCOVERWEAKENED 3
#define WALLCOVERREMOVED 4
#define WALLRODSUNSECURED 5
#define WALLRODSCUT 6
/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal and anchored rods used to separate rooms and keep all but the most equipped crewmen out."
	icon_state = "r_wall"
	opacity = 1
	density = 1

	walltype = "rwall"
	mineral = "plasteel"
	hardness = 90

	explosion_block = 2
	girder_type = /obj/structure/girder/reinforced

	penetration_dampening = 20

	var/d_state = WALLCOMPLETED

/turf/simulated/wall/r_wall/examine(mob/user)
	..()
	if(d_state)
		switch(d_state) //How fucked or unfinished is our wall
			if(WALLCOVEREXPOSED)
				to_chat(user, "It has no outer grille")
			if(WALLCOVERUNSECURED)
				to_chat(user, "It has no outer grille and the external reinforced cover is exposed")
			if(WALLCOVERWEAKENED)
				to_chat(user, "It has no outer grille and the external reinforced cover has been welded into")
			if(WALLCOVERREMOVED)
				to_chat(user, "It has no outer grille or external reinforced cover and the external support rods are exposed")
			if(WALLRODSUNSECURED)
				to_chat(user, "It has no outer grille or external reinforced cover and the external support rods are loose")
			if(WALLRODSCUT)
				to_chat(user, "It has no outer grille, external reinforced cover or external support rods and the inner reinforced cover is exposed")//And that's terrible


//We need to export this here because we want to handle it differently
//This took me longer to find this than it should havle
/turf/simulated/wall/r_wall/relativewall()
	if(d_state) //We are fucking building
		return //Fuck off
	..()

/turf/simulated/wall/r_wall/update_icon()
	if(!d_state) //Are we under construction or deconstruction ?
		relativewall() //Well isn't that odd, let's pass this to smoothwall.dm
		relativewall_neighbours() //Let's make sure the other walls know about this travesty
		return //Now fuck off
	update_d_state_icon()
	update_paint_overlay()

/turf/simulated/wall/r_wall/proc/update_d_state_icon()
	icon_state = "r_wall-[d_state]"  //You can thank me later

/turf/simulated/wall/r_wall/attackby(obj/item/W as obj, mob/user as mob)
	user.delayNextAttack(5)
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(issolder(W) && bullet_marks)
		remove_holes(W,user)
		return

	//Get the user's location
	if(!istype(user.loc, /turf))
		return	//Can't do this stuff whilst inside objects and such //Thanks BYOND

	if(rotting)
		if(W.is_hot()) //Yes, you can do it with a welding tool, or a lighter, or a candle, or an energy sword
			user.visible_message("<span class='notice'>[user] burns the fungi away with \the [W].</span>", \
			"<span class='notice'>You burn the fungi away with \the [W].</span>")
			playsound(src, 'sound/items/Welder.ogg', 10, 1)
			remove_rot()
			return
		if(istype(W,/obj/item/weapon/soap))
			user.visible_message("<span class='notice'>[user] forcefully scrubs the fungi away with \the [W].</span>", \
			"<span class='notice'>You forcefully scrub the fungi away with \the [W].</span>")
			remove_rot()
			return
		else if(!W.is_sharp() && W.force >= 10 || W.force >= 20)
			user.visible_message("<span class='warning'>With one strong swing, [user] destroys the rotting [src] with \the [W].</span>", \
			"<span class='notice'>With one strong swing, the rotting [src] crumbles away under \the [W].</span>")
			dismantle_wall()

			var/pdiff = performWallPressureCheck(src)
			if(pdiff)
				investigation_log(I_ATMOS, "with a pdiff of [pdiff] has been broken after rotting by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
				message_admins("\The [src] with a pdiff of [pdiff] has been broken after rotting by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite && can_thermite)
		if(W.is_hot()) //HEY CAN THIS SET THE THERMITE ON FIRE ?
			user.visible_message("<span class='warning'>[user] applies \the [W] to the thermite coating \the [src] and waits.</span>", \
			"<span class='warning'>You apply \the [W] to the thermite coating \the [src] and wait...</span>")
			if(do_after(user, src, 100) && W.is_hot()) //Thermite is hard to light up
				thermitemelt(user) //There, I just saved you fifty lines of redundant typechecks and awful snowflake coding
				user.visible_message("<span class='warning'>[user] sets \the [src] ablaze with \the [W]!</span>", \
				"<span class='warning'>You set \the [src] ablaze with \the [W]!</span>")
				return

	//Deconstruction and reconstruction
	switch(d_state)
		if(WALLCOMPLETED)
			if(W.is_wirecutter(user))
				W.playtoolsound(src, 100)
				src.d_state = WALLCOVEREXPOSED
				update_icon()
				user.visible_message("<span class='warning'>[user] cuts out \the [src]'s outer grille.</span>", \
				"<span class='notice'>You cut out \the [src]'s outer grille, exposing the external cover.</span>")
				return

		if(WALLCOVEREXPOSED)
			if(W.is_screwdriver(user))
				user.visible_message("<span class='warning'>[user] begins unsecuring \the [src]'s external cover.</span>", \
				"<span class='notice'>You begin unsecuring \the [src]'s external cover.</span>")
				W.playtoolsound(src, 100)

				if(do_after(user, src, 40) && d_state == WALLCOVEREXPOSED)
					src.d_state = WALLCOVERUNSECURED
					update_icon()
					user.visible_message("<span class='warning'>[user] unsecures \the [src]'s external cover.</span>", \
					"<span class='notice'>You unsecure \the [src]'s external cover.</span>")
				return

			//Repairing outer grille, use welding tool
			else if(iswelder(W))
				var/obj/item/tool/weldingtool/WT = W
				user.visible_message("<span class='notice'>[user] begins mending the damage on \the [src]'s outer grille.</span>", \
				"<span class='notice'>You begin mending the damage on \the [src]'s outer grille.</span>", \
				"<span class='warning'>You hear welding noises.</span>")
				if(WT.do_weld(user, src, 40, 0) && d_state == WALLCOVEREXPOSED)
					src.d_state = WALLCOMPLETED
					update_icon()
					user.visible_message("<span class='notice'>[user] mends the damage on \the [src]'s outer grille.</span>", \
					"<span class='notice'>You mend the damage on \the [src]'s outer grille.</span>", \
					"<span class='warning'>You hear welding noises.</span>")
				return

		if(WALLCOVERUNSECURED)
			if(iswelder(W))
				var/obj/item/tool/weldingtool/WT = W
				user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s external cover.</span>", \
				"<span class='notice'>You begin slicing through \the [src]'s external cover.</span>", \
				"<span class='warning'>You hear welding noises.</span>")
				if(WT.do_weld(user, src, 60, 0) && d_state == WALLCOVERUNSECURED)
					src.d_state = WALLCOVERWEAKENED
					update_icon()
					user.visible_message("<span class='warning'>[user] finishes weakening \the [src]'s external cover.</span>", \
					"<span class='notice'>You finish weakening \the [src]'s external cover.</span>", \
					"<span class='warning'>You hear welding noises.</span>")

				return
			//Re-secure external cover, unsurprisingly exact same step as above
			else if(W.is_screwdriver(user))
				user.visible_message("<span class='notice'>[user] begins securing \the [src]'s external cover.</span>", \
				"<span class='notice'>You begin securing \the [src]'s external cover.</span>")
				W.playtoolsound(src, 100)

				if(do_after(user, src, 40) && d_state == WALLCOVERUNSECURED)
					src.d_state = WALLCOVEREXPOSED
					update_icon()
					user.visible_message("<span class='warning'>[user] secures \the [src]'s external cover.</span>", \
					"<span class='notice'>You secure \the [src]'s external cover.</span>")
				return

		if(WALLCOVERWEAKENED)
			if(iscrowbar(W))

				user.visible_message("<span class='warning'>[user] starts prying off \the [src]'s external cover.</span>", \
				"<span class='notice'>You struggle to pry off \the [src]'s external cover.</span>", \
				"<span class='warning'>You hear a crowbar.</span>")
				W.playtoolsound(src, 100)

				if(do_after(user, src, 100) && d_state == WALLCOVERWEAKENED)
					playsound(src, 'sound/items/Deconstruct.ogg', 100, 1) //SLAM
					var/sheet_spawned = get_sheet_type()
					if(sheet_spawned)
						new sheet_spawned(get_turf(src))
					user.visible_message("<span class='warning'>[user] pries off \the [src]'s external cover.</span>", \
					"<span class='notice'>You pry off \the [src]'s external cover.</span>")
					if(type != /turf/simulated/wall/r_wall) //easy hack for mineral walls
						ChangeTurf(/turf/simulated/wall/r_wall/nocover)
					else
						src.d_state = WALLCOVERREMOVED
						update_icon()
				return

			//Fix welding damage caused above, by welding shit into place again
			else if(iswelder(W))

				var/obj/item/tool/weldingtool/WT = W
				user.visible_message("<span class='notice'>[user] begins fixing the welding damage on \the [src]'s external cover.</span>", \
				"<span class='notice'>You begin fixing the welding damage on \the [src]'s external cover.</span>", \
				"<span class='warning'>You hear welding noises.</span>")

				if(WT.do_weld(user, src, 60, 0) && d_state == WALLCOVERWEAKENED)
					playsound(src, 'sound/items/Welder.ogg', 100, 1) //Not an error, play welder sound again
					src.d_state = WALLCOVERUNSECURED
					update_icon()
					user.visible_message("<span class='warning'>[user] fixes the welding damage on \the [src]'s external cover.</span>", \
					"<span class='notice'>You fix the welding damage on \the [src]'s external cover.</span>", \
					"<span class='warning'>You hear welding noises.</span>")
				return

		if(WALLCOVERREMOVED)
			if(W.is_wrench(user))

				user.visible_message("<span class='warning'>[user] starts loosening the bolts anchoring \the [src]'s external support rods.</span>", \
				"<span class='notice'>You start loosening the bolts anchoring \the [src]'s external support rods.</span>")
				W.playtoolsound(src, 100)

				if(do_after(user, src, 40) && d_state == WALLCOVERREMOVED)
					src.d_state = WALLRODSUNSECURED
					update_icon()
					user.visible_message("<span class='warning'>[user] loosens the bolts anchoring \the [src]'s external support rods.</span>", \
					"<span class='notice'>You loosen the bolts anchoring \the [src]'s external support rods.</span>")
				return

			//Only construction step after reinforced girder, add the second plasteel sheet
			//Acts as a super repair step, incidentally, if there's clearly more than cover damage
			else if(istype(W, /obj/item/stack/sheet))
				var/obj/item/stack/sheet/P = W
				var/newpath = null
				if(istype(P, /obj/item/stack/sheet/mineral) || istype(P, /obj/item/stack/sheet/wood))
					newpath = text2path("/turf/simulated/wall/r_wall/mineral/[P.sheettype]")
				if(!newpath && !istype(P,(/obj/item/stack/sheet/plasteel)))
					return
				user.visible_message("<span class='notice'>[user] starts installing an external cover to \the [src].</span>", \
				"<span class='notice'>You start installing an external cover to \the [src].</span>")
				playsound(src, 'sound/items/Deconstruct.ogg', 100, 1)

				if(do_after(user, src, 50) && d_state == WALLCOVERREMOVED)
					P.use(1)
					if(newpath)
						ChangeTurf(newpath)
						relativewall_neighbours()
					else
						src.d_state = WALLCOMPLETED //A new pristine reinforced cover, we are done here
						update_icon()
					user.visible_message("<span class='notice'>[user] finishes installing an external cover to \the [src].</span>", \
					"<span class='notice'>You finish installing an external cover to \the [src].</span>")
				return

		if(WALLRODSUNSECURED)
			if(iswelder(W))

				var/obj/item/tool/weldingtool/WT = W
				user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s external support rods.</span>", \
				"<span class='notice'>You begin slicing through \the [src]'s external support rods.</span>")

				if(WT.do_weld(user, src, 100, 0) && d_state == WALLRODSUNSECURED)
					src.d_state = WALLRODSCUT
					update_icon()
					user.visible_message("<span class='warning'>[user] slices through \the [src]'s external support rods.</span>", \
					"<span class='notice'>You slice through \the [src]'s external support rods, exposing its internal cover.</span>")
				return

			if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))

				user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s external support rods.</span>", \
				"<span class='notice'>You begin slicing through \the [src]'s external support rods.</span>")
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user, src, 70))
					playsound(src, 'sound/items/Welder.ogg', 100, 1)
					src.d_state = WALLRODSCUT
					update_icon()
					user.visible_message("<span class='warning'>[user] slices through \the [src]'s external support rods.</span>", \
					"<span class='notice'>You slice through \the [src]'s external support rods, exposing its internal cover.</span>")
				return

			//Repair step, tighten the anchoring bolts
			else if(W.is_wrench(user))

				user.visible_message("<span class='notice'>[user] starts tightening the bolts anchoring \the [src]'s external support rods.</span>", \
				"<span class='notice'>You start tightening the bolts anchoring \the [src]'s external support rods.</span>")
				W.playtoolsound(src, 100)

				if(do_after(user, src, 40) && d_state == WALLRODSUNSECURED)
					src.d_state = WALLCOVERREMOVED
					update_icon()
					user.visible_message("<span class='notice'>[user] tightens the bolts anchoring \the [src]'s external support rods.</span>", \
					"<span class='notice'>You tighten the bolts anchoring \the [src]'s external support rods.</span>")
				return

		if(WALLRODSCUT)
			if(iscrowbar(W))

				user.visible_message("<span class='warning'>[user] starts prying off [src]'s internal cover.</span>", \
				"<span class='notice'>You struggle to pry off [src]'s internal cover.</span>")
				W.playtoolsound(src, 100)

				if(do_after(user, src, 100) && d_state == WALLRODSCUT)
					user.visible_message("<span class='warning'>[user] pries off [src]'s internal cover.</span>", \
					"<span class='notice'>You pry off [src]'s internal cover.</span>")
					playsound(src, 'sound/items/Deconstruct.ogg', 100, 1)

					var/pdiff = performWallPressureCheck(src)
					if(pdiff)
						investigation_log(I_ATMOS, "with a pdiff of [pdiff] has been dismantled by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
						message_admins("\The [src] with a pdiff of [pdiff] has been dismantled by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")

					dismantle_wall() //Mr. Engineer, break down that reinforced wall

				return

			//Repair the external support rods welded through in the previous step, with a welding tool. Naturally
			else if(iswelder(W))

				var/obj/item/tool/weldingtool/WT = W
				if(WT.remove_fuel(1,user))
					user.visible_message("<span class='notice'>[user] begins mending \the [src]'s external support rods.</span>", \
					"<span class='notice'>You begin mending \the [src]'s external support rods.</span>")
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user, src, 100) && d_state == WALLRODSCUT)
						playsound(src, 'sound/items/Welder.ogg', 100, 1) //Not an error, play welder sound again
						src.d_state = WALLRODSUNSECURED
						update_icon()
						user.visible_message("<span class='warning'>[user] mends \the [src]'s external support rods.</span>", \
						"<span class='notice'>You mend \the [src]'s external support rods.</span>")
				else
					return

//This is where we perform actions that aren't deconstructing, constructing or thermiting the reinforced wall

	//Drilling
	//Needs a diamond drill or equivalent
	if(istype(W, /obj/item/weapon/pickaxe))

		var/obj/item/weapon/pickaxe/PK = W
		if(!(PK.diggables & DIG_RWALLS))
			return
		if(walltype == "diamond")
			return

		user.visible_message("<span class='warning'>[user] begins [PK.drill_verb] straight into \the [src].</span>", \
		"<span class='notice'>You begin [PK.drill_verb] straight into \the [src].</span>")
		PK.playtoolsound(src, 100)
		if(do_after(user, src, (MINE_DURATION * PK.toolspeed) * 50))
			user.visible_message("<span class='notice'>[user]'s [PK] tears though the last of \the [src], leaving nothing but a girder.</span>", \
			"<span class='notice'>Your [PK] tears though the last of \the [src], leaving nothing but a girder.</span>")
			var/pdiff = performWallPressureCheck(src)
			if(pdiff)
				investigation_log(I_ATMOS, "with a pdiff of [pdiff] has been drilled through by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
				message_admins("\The [src] with a pdiff of [pdiff] has been drilled through by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")

			dismantle_wall()
		return

	else if(istype(W, /obj/item/mounted))
		return

	//Finally, CHECKING FOR FALSE WALLS if it isn't damaged
	//This is obsolete since reinforced false walls were commented out, but gotta slap the wall with my hand anyways !
	else if(!d_state)
		if(istype(W, /obj/item/tool/crowbar/red))
			user.delayNextAttack(W.attack_delay)
			playsound(src, "crowbar_hit", 50, 1, -1)
		else
			return attack_hand(user)
	return

/turf/simulated/wall/r_wall/attack_construct(mob/user as mob)
	return 0

/turf/simulated/wall/r_wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()

/turf/simulated/wall/r_wall/dismantle_wall(devastated = 0, explode = 0)
	if(!devastated)
		new /obj/item/stack/sheet/plasteel(src)//Reinforced girder has deconstruction steps too. If no girder, drop ONE plasteel sheet AND rod)
		new girder_type(src)
	else
		new /obj/item/stack/rods(src, 2)
		new /obj/item/stack/sheet/plasteel(src)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)

	ChangeTurf(dismantle_type)
	update_near_walls()

/turf/simulated/wall/r_wall/ex_act(severity)
	if(rotting)
		severity = 1.0
	switch(severity)
		if(1.0)
			dismantle_wall(!prob(66),1) //So it isn't completely destroyed, nice uh ?
		if(2.0)
			if(prob(75) && (d_state == WALLCOMPLETED))//No more infinite plasteel generation!
				remove_cover()
			else
				dismantle_wall(0,1)
		if(3.0)
			if(prob(15))
				dismantle_wall(0,1)
			else //If prob fails, break the outer safety grille to look like scrap damage
				src.d_state = WALLCOVEREXPOSED
				update_icon()
	return

/turf/simulated/wall/r_wall/proc/remove_cover()
	var/sheet_spawned = get_sheet_type()
	if(sheet_spawned)
		new sheet_spawned(get_turf(src))
	if(type != /turf/simulated/wall/r_wall) //easy hack for mineral walls
		ChangeTurf(/turf/simulated/wall/r_wall/nocover)
	else
		src.d_state = WALLCOVERREMOVED
		update_icon()

/turf/simulated/wall/r_wall/dissolvable()
	return 0

/turf/simulated/wall/r_wall/nocover
	d_state = WALLCOVERREMOVED
	icon_state = "r_wall-4"

/turf/simulated/wall/r_wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist."
	icon_state = ""
	explosion_block = 1
	var/image/d_state_image

/turf/simulated/wall/r_wall/mineral/New()
	. = ..()
	d_state_image = image(icon,"r_overlay")
	overlays += d_state_image

/turf/simulated/wall/r_wall/mineral/update_d_state_icon()
	overlays -= d_state_image
	d_state_image.icon_state = "r_overlay-[d_state]"
	overlays += d_state_image

/turf/simulated/wall/r_wall/mineral/wood
	name = "reinforced wooden wall"
	desc = "A reinforced wall with wooden plating."
	icon_state = "wood0"
	walltype = "wood"
	mineral = "wood"

/turf/simulated/wall/r_wall/mineral/wood/attackby(var/obj/item/W, var/mob/user)
	if(W.sharpness_flags & CHOPWOOD)
		user.visible_message("<span class='notice'>[user] starts chopping at \the [src] with \the [W].</span>", \
				"<span class='notice'>You start chopping at \the [src] with \the [W].</span>", \
				"<span class='warning'>You hear the sound of wood being cut.</span>")
		W.playtoolsound(src, 100)
		var/choptime = 50
		if(istype(W, /obj/item/weapon/fireaxe))
			choptime = 10
		if(do_after(user, src, choptime))
			user.visible_message("<span class='warning'>[user] smashes through \the [src] with \the [W].</span>", \
						"<span class='notice'>You smash through \the [src].</span>")
			W.playtoolsound(src, 100)
			remove_cover()
	else
		..()

/turf/simulated/wall/r_wall/mineral/wood/ex_act(var/severity)
	if(severity < 3)
		new /obj/item/stack/sheet/wood(src, 2)
	..()

/turf/simulated/wall/r_wall/mineral/wood/log
	name = "reinforced log wall"
	desc = "A reinforced log wall, ideal for a cabin."
	girder_type = null
	walltype = "log"
	mineral = "log"
	icon_state = "log0"
	var/deconstruct_type = /turf/unsimulated/floor/snow/empty

/turf/simulated/wall/r_wall/mineral/wood/log/dismantle_wall()
	new /obj/item/weapon/grown/log/tree(src)
	for(var/obj/O in src.contents)
		if(istype(O,/obj/effect/cult_shortcut))
			qdel(O)
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
	ChangeTurf(deconstruct_type)
	update_near_walls()

/turf/simulated/wall/r_wall/mineral/wood/log/desert
	deconstruct_type = /turf/simulated/floor/plating/ironsand

/turf/simulated/wall/r_wall/mineral/brick
	name = "reinforced brick wall"
	desc = "A reinforced wall with brick siding. It looks nice."
	icon_state = "brick0"
	walltype = "brick"
	mineral = "brick"

/turf/simulated/wall/r_wall/mineral/gold
	name = "reinforced gold wall"
	desc = "A reinforced wall with gold plating. Swag!"
	icon_state = "gold0"
	walltype = "gold"
	mineral = "gold"
	//var/electro = 1
	//var/shocked = null

/turf/simulated/wall/r_wall/mineral/gold/gold_old
	icon_state = "gold_old0"
	walltype = "gold_old"

/turf/simulated/wall/r_wall/mineral/silver
	name = "reinforced silver wall"
	desc = "A reinforced wall with silver plating. Shiny!"
	icon_state = "silver0"
	walltype = "silver"
	mineral = "silver"
	//var/electro = 0.75
	//var/shocked = null

/turf/simulated/wall/r_wall/mineral/silver/silver_old
	icon_state = "silver_old0"
	walltype = "silver_old"

/turf/simulated/wall/r_wall/mineral/diamond
	name = "reinforced diamond wall"
	desc = "A reinforced wall with diamond plating. You monster."
	icon_state = "diamond0"
	walltype = "diamond"
	mineral = "diamond"
	explosion_block = 3

/turf/simulated/wall/r_wall/mineral/clown
	name = "reinforced bananium wall"
	desc = "A reinforced wall with bananium plating. Honk!"
	icon_state = "clown0"
	walltype = "clown"
	mineral = "clown"

/turf/simulated/wall/r_wall/mineral/sandstone
	name = "reinforced sandstone wall"
	desc = "A reinforced wall with sandstone plating."
	icon_state = "sandstone0"
	walltype = "sandstone"
	mineral = "sandstone"
	explosion_block = 0

/turf/simulated/wall/r_wall/mineral/plastic
	name = "reinforced plastic wall"
	desc = "A reinforced wall made of colorful plastic blocks attached together."
	icon_state = "plastic0"
	walltype = "plastic"
	mineral = "plastic"
	opacity = 0
	explosion_block = 0

/turf/simulated/wall/r_wall/mineral/uranium
	name = "reinforced uranium wall"
	desc = "A reinforced wall with uranium plating. This is probably a bad idea."
	icon_state = "uranium0"
	walltype = "uranium"
	mineral = "uranium"
	explosion_block = 2
	var/active = null
	var/last_event = 0

/turf/simulated/wall/r_wall/mineral/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			emitted_harvestable_radiation(src, 3, range = 5)
			for(var/mob/living/L in range(3,src))
				L.apply_radiation(12,RAD_EXTERNAL)
			for(var/turf/simulated/wall/mineral/uranium/T in range(3,src))
				T.radiate()
			last_event = world.time
			active = null
			return
	return

/turf/simulated/wall/r_wall/mineral/uranium/attack_hand(mob/user as mob)
	radiate()
	..()

/turf/simulated/wall/r_wall/mineral/uranium/attackby(obj/item/weapon/W as obj, mob/user as mob)
	radiate()
	..()

/turf/simulated/wall/r_wall/mineral/uranium/Bumped(AM as mob|obj)
	radiate()
	..()

/turf/simulated/wall/r_wall/mineral/plasma
	name = "reinforced plasma wall"
	desc = "A reinforced wall with plasma plating. This is definately a bad idea."
	icon_state = "plasma0"
	walltype = "plasma"
	mineral = "plasma"

/turf/simulated/wall/r_wall/mineral/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		ignite(W.is_hot())
		return
	..()

/turf/simulated/wall/r_wall/mineral/plasma/proc/PlasmaBurn(temperature)
	var/pdiff = performWallPressureCheck(src)
	if(pdiff > 0)
		investigation_log(I_ATMOS, "with a pdiff of [pdiff] has caught on fire at [formatJumpTo(get_turf(src))]!")
		message_admins("\The [src] with a pdiff of [pdiff] has caught of fire at [formatJumpTo(get_turf(src))]!")
	spawn(2)
	ChangeTurf(/turf/simulated/wall/r_wall/nocover)
	for(var/turf/simulated/floor/target_tile in range(0,src))
		/*if(target_tile.parent && target_tile.parent.group_processing)
			target_tile.parent.suspend_group_processing()*/
		var/datum/gas_mixture/napalm = new
		var/toxinsToDeduce = 20
		napalm.temperature = 400+T0C
		napalm.adjust_gas(GAS_PLASMA, toxinsToDeduce)
		target_tile.assume_air(napalm)
		spawn (0) target_tile.hotspot_expose(temperature, MEDIUM_FLAME,1)
	for(var/obj/structure/falsewall/plasma/F in range(3,src))//Hackish as fuck, but until fire_act works, there is nothing I can do -Sieve
		var/turf/T = get_turf(F)
		T.ChangeTurf(/turf/simulated/wall/mineral/plasma/)
		QDEL_NULL (F)
	for(var/turf/simulated/wall/mineral/plasma/W in range(3,src))
		W.ignite((temperature/4))//Added so that you can't set off a massive chain reaction with a small flame
	for(var/turf/simulated/wall/r_wall/mineral/plasma/W2 in range(3,src))
		W2.ignite((temperature/4))
	for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
		D.ignite(temperature/4)

/turf/simulated/wall/r_wall/mineral/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/simulated/wall/r_wall/mineral/plasma/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/simulated/wall/r_wall/mineral/plasma/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj,/obj/item/projectile/beam))
		PlasmaBurn(2500)
	else if(istype(Proj,/obj/item/projectile/ion))
		PlasmaBurn(500)
	..()

/turf/simulated/wall/r_wall/mineral/clockwork
	name = "reinforced clockwork wall"
	desc = "A huge reinforced chunk of warm metal. The clanging of machinery emanates from within."
	icon_state = "clock"
	walltype = "clock"
	mineral = "brass"
//	dismantle_type = /turf/simulated/floor/engine/clockwork // SOON
	girder_type = /obj/structure/girder/clockwork

/turf/simulated/wall/r_wall/mineral/clockwork/cultify()
	return

/turf/simulated/wall/r_wall/mineral/clockwork/clockworkify()
	return

/turf/simulated/wall/r_wall/mineral/gingerbread
	name = "reinforced gingerbread wall"
	desc = "Extremely stale and generally unappetizing."
	icon_state = "gingerbread0"
	walltype = "gingerbread"
	mineral = "gingerbread"

#undef WALLCOMPLETED
#undef WALLCOVEREXPOSED
#undef WALLCOVERUNSECURED
#undef WALLCOVERWEAKENED
#undef WALLCOVERREMOVED
#undef WALLRODSUNSECURED
#undef WALLRODSCUT
