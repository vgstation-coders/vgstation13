/*
		Portable Turrets:

		Constructed from metal, a gun of choice, and a prox sensor.
		Gun can be a taser or laser or energy gun.

		This code is slightly more documented than normal, as requested by XSI on IRC.

*/


/obj/machinery/porta_turret
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "grey_target_prism"
	anchored = 1
	invisibility = INVISIBILITY_LEVEL_TWO		// the turret is invisible if it's inside its cover
	density = 1
	use_power = 1			// this turret uses and requires power
	idle_power_usage = 50	// when inactive, this turret takes up constant 50 Equipment power
	active_power_usage = 300// when active, this turret takes up constant 300 Equipment power
	req_access = list(access_security)
	power_channel = EQUIP	// drains power from the EQUIPMENT channel

	var/lasercolor = ""		// Something to do with lasertag turrets, blame Sieve for not adding a comment.
	var/raised = 0			// if the turret cover is "open" and the turret is raised
	var/raising= 0			// if the turret is currently opening or closing its cover
	var/health = 80			// the turret's health
	var/locked = 1			// if the turret's behaviour control access is locked

	var/obj/item/weapon/gun/energy/installed = null		// the type of weapon installed
	var/reqpower = 750 //power used per shot

	var/obj/machinery/porta_turret_cover/cover = null	// the cover that is covering this turret
	var/last_fired = 0		// 1: if the turret is cooling down from a shot, 0: turret is ready to fire
	var/shot_delay = 15		// 1.5 seconds between each shot

	var/check_records = 1	// checks if it can use the security records
	var/criminals = 1		// checks if it can shoot people on arrest
	var/auth_weapons = 0	// checks if it can shoot people that have a weapon they aren't authorized to have
	var/stun_all = 0		// if this is active, the turret shoots everything that isn't security or head of staff
	var/check_anomalies = 1	// checks if it can shoot at unidentified lifeforms (ie xenos)
	var/ai		 = 0 		// if active, will shoot at anything not an AI or cyborg

	var/attacked = 0		// if set to 1, the turret gets pissed off and shoots at people nearby (unless they have sec access!)

	var/on = 1				// determines if the turret is on
	var/disabled = 0

	var/datum/effect/effect/system/spark_spread/spark_system // the spark system, used for generating... sparks?

	machine_flags = EMAGGABLE | SHUTTLEWRENCH

/obj/machinery/porta_turret/New()
	..()
	icon_state = "[lasercolor]grey_target_prism"
	// Sets up a spark system
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	power_change()
	cover = new /obj/machinery/porta_turret_cover(loc)
	cover.Parent_Turret = src
	spawn(10)
		update_gun()

/obj/machinery/porta_turret/proc/update_gun()
	if(!installed)// if for some reason the turret has no gun (ie, admin spawned) it resorts to basic taser shots
		installed = new /obj/item/weapon/gun/energy/taser(src)

	else
		var/obj/item/weapon/gun/energy/E = installed

		switch(E.type)
			if(/obj/item/weapon/gun/energy/laser/bluetag)
				lasercolor = "b"
				req_access = list(access_maint_tunnels)
				check_records = 0
				criminals = 0
				auth_weapons = 1
				stun_all = 0
				check_anomalies = 0

			if(/obj/item/weapon/gun/energy/laser/redtag)
				lasercolor = "r"
				req_access = list(access_maint_tunnels)
				check_records = 0
				criminals = 0
				auth_weapons = 1
				stun_all = 0
				check_anomalies = 0


/obj/machinery/porta_turret/Destroy()
	// deletes its own cover with it
	qdel(cover)
	qdel(installed)
	..()


/obj/machinery/porta_turret/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/porta_turret/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	var/dat

	// The browse() text, similar to ED-209s and beepskies.
	if(!(src.lasercolor))//Lasertag turrets have less options
		dat += text({"
<TT><B>Automatic Portable Turret Installation</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]"},

"<A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A>" )

		if(!src.locked)
			dat += text({"<BR>
Check for Weapon Authorization: []<BR>
Check Security Records: []<BR>
Neutralize Identified Criminals: []<BR>
Neutralize All Non-Security and Non-Command Personnel: []<BR>
Neutralize All Unidentified Life Signs: []<BR>"},

"<A href='?src=\ref[src];operation=authweapon'>[src.auth_weapons ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=checkrecords'>[src.check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=shootcrooks'>[src.criminals ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=shootall'>[stun_all ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=checkxenos'>[check_anomalies ? "Yes" : "No"]</A>" )
	else
		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(((src.lasercolor) == "b") && (istype(H.wear_suit, /obj/item/clothing/suit/redtag)))
				return
			if(((src.lasercolor) == "r") && (istype(H.wear_suit, /obj/item/clothing/suit/bluetag)))
				return
		dat += text({"
<TT><B>Automatic Portable Turret Installation</B></TT><BR><BR>
Status: []<BR>"},

"<A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A>" )


	user << browse("<HEAD><TITLE>Automatic Portable Turret Installation</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/obj/machinery/porta_turret/Topic(href, href_list)
	if (..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if ((href_list["power"]) && (src.allowed(usr)))
		if(on && emagged)
			to_chat(usr, "<span class='warning'>The turret isn't responding!</span>")
			return
		if(anchored) // you can't turn a turret on/off if it's not anchored/secured
			on = !on // toggle on/off
		else
			to_chat(usr, "<span class='warning'>It has to be secured first!</span>")

		updateUsrDialog()
		return

	switch(href_list["operation"])
		// toggles customizable behavioural protocols

		if ("authweapon")
			src.auth_weapons = !src.auth_weapons
		if ("checkrecords")
			src.check_records = !src.check_records
		if ("shootcrooks")
			src.criminals = !src.criminals
		if("shootall")
			stun_all = !stun_all
		if("checkxenos")
			check_anomalies = !check_anomalies
	updateUsrDialog()


/obj/machinery/porta_turret/power_change()

	if(!anchored)
		icon_state = "turretCover"
		return
	if(stat & BROKEN)
		icon_state = "[lasercolor]destroyed_target_prism"
	else
		if( powered() )
			if (on)
				if (emagged)
					icon_state = "[lasercolor]orange_target_prism"
				else
					icon_state = "[lasercolor]target_prism"
			else
				icon_state = "[lasercolor]grey_target_prism"
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "[lasercolor]grey_target_prism"
				stat |= NOPOWER

/obj/machinery/porta_turret/emag(mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You short out [src]'s threat assessment circuits.</span>")
		if(anchored) //this is like this because the turret itself is invisible when retracted, so the cover displays the message instead
			cover.visible_message("<span class='warning'>[src] hums oddly...</span>", "<span class='warning'>You hear an odd humming.</span>")
		else //But when unsecured the cover is gone, so it shows the message itself
			visible_message("<span class='warning'>[src] hums oddly...</span>", "<span class='warning'>You hear an odd humming.</span>")
		if(istype(installed, /obj/item/weapon/gun/energy/laser/redtag) || istype(installed, /obj/item/weapon/gun/energy/laser/redtag))
			installed.projectile_type = /obj/item/projectile/beam/lasertag/omni //if you manage to get this gun back out, good for you
		emagged = 1
		req_access = null
		on = 0 // turns off the turret temporarily
		sleep(60) // 6 seconds for the traitor to gtfo of the area before the turret decides to ruin his shit
		if(anchored) //Can't turn on if not secure
			on = 1 // turns it back on. The cover popUp() popDown() are automatically called in process(), no need to define it here

/obj/machinery/porta_turret/attackby(obj/item/W as obj, mob/user as mob)
	if(stat & BROKEN)
		if(iscrowbar(W))

			// If the turret is destroyed, you can remove it with a crowbar to
			// try and salvage its components
			to_chat(user, "You begin prying the metal coverings off.")
			sleep(20)
			var/salvaged
			if(installed)
				if(prob(70))
					var/obj/item/I = installed
					I.forceMove(get_turf(src))
					installed = null
					lasercolor = null
					salvaged++
			if(prob(75))
				getFromPool(/obj/item/stack/sheet/metal, loc, rand(2,6))
				salvaged++
			if(prob(50))
				new /obj/item/device/assembly/prox_sensor(get_turf(src))
				salvaged++
			if(salvaged)
				to_chat(user, "You remove the turret and salvage some components.")
			else
				to_chat(user, "You remove the turret but did not manage to salvage anything.")
			qdel(src)
		return

	..()

	if(iswrench(W) && !on && !raised && wrenchAnchor(user))
		// This code handles moving the turret around. After all, it's a portable turret!

		if(anchored)
			invisibility = INVISIBILITY_LEVEL_TWO
			icon_state = "[lasercolor]grey_target_prism"
			cover=new/obj/machinery/porta_turret_cover(src.loc) // create a new turret cover. While this is handled in process(), this is to workaround a bug where the turret becomes invisible for a split second
			cover.Parent_Turret = src // make the cover's parent src
			power_change()
		else
			icon_state = "turretCover"
			invisibility = 0
			qdel(cover) // deletes the cover, and the turret instance itself becomes its own cover.

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		// Behavior lock/unlock mangement
		if (allowed(user))
			locked = !src.locked
			to_chat(user, "Controls are now [locked ? "locked." : "unlocked."]")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

	else
		user.delayNextAttack(10)
		// if the turret was attacked with the intention of harming it:
		if (W.force >= 2)
			src.health -= W.force * 0.5
			if (src.health <= 0)
				src.die()
		// if the force of impact dealt at least 1 damage, the turret gets pissed off
			playsound(loc, 'sound/effects/grillehit.ogg', 75, 1)
			if(W.attack_verb && W.attack_verb.len)
				user.visible_message("<span class='warning'><B>[user] [pick(W.attack_verb)] \the [src] with \the [W]!</span>", \
						 "<span class='warning'>You attack \the [src] with \the [W]!</span>", \
						 "<span class='warning'>You hear a clang!</span>")
			else
				user.visible_message("<span class='warning'><B>[user] attacks \the [src] with \the [W]!</span>", \
						 "<span class='warning'>You attack \the [src] with \the [W]!</span>", \
						 "<span class='warning'>You hear a clang!</span>")
			if(on)
				attacked += 5



/obj/machinery/porta_turret/bullet_act(var/obj/item/projectile/Proj)
	if(on && Proj.damage > 0)
		attacked += 5

	src.health -= Proj.damage
	..()
	if(prob(45) && Proj.damage > 0)
		src.spark_system.start()
	if (src.health <= 0)
		src.die() // the death process :(
	if((src.lasercolor == "b") && (src.disabled == 0))
		if(istype(Proj, /obj/item/projectile/beam/lasertag/red))
			src.disabled = 1
			qdel (Proj)
			Proj = null
			sleep(100)
			src.disabled = 0
	if((src.lasercolor == "r") && (src.disabled == 0))
		if(istype(Proj, /obj/item/projectile/beam/lasertag/blue))
			src.disabled = 1
			qdel (Proj)
			Proj = null
			sleep(100)
			src.disabled = 0
	return

/obj/machinery/porta_turret/emp_act(severity)
	if(on)
		// if the turret is on, the EMP no matter how severe disables the turret for a while
		// and scrambles its settings, with a slight chance of having an emag effect
		check_records=pick(0,1)
		criminals=pick(0,1)
		auth_weapons=pick(0,1)
		stun_all=pick(0,0,0,0,1) // stun_all is a pretty big deal, so it's least likely to get turned on
		if(prob(5))
			emagged = 1
		on=0
		sleep(rand(60,600))
		if(!on)
			on=1

	..()

/obj/machinery/porta_turret/ex_act(severity)
	if(severity < 3)
		qdel(src)
	else
		health -= 30
		if(health <= 0)
			die()

/obj/machinery/porta_turret/proc/die() // called when the turret dies, ie, health <= 0
	src.health = 0
	src.density = 0
	src.stat |= BROKEN // enables the BROKEN bit
	src.icon_state = "[lasercolor]destroyed_target_prism"
	invisibility=0
	src.spark_system.start() // creates some sparks because they look cool
	src.density=1
	qdel(cover) // deletes the cover - no need on keeping it there!



/obj/machinery/porta_turret/process()
	// the main machinery process

	//set background = 1

	if(src.cover==null && anchored) // if it has no cover and is anchored
		if (stat & BROKEN) // if the turret is borked
			qdel(cover) // delete its cover, assuming it has one. Workaround for a pesky little bug
		else

			src.cover = new /obj/machinery/porta_turret_cover(src.loc) // if the turret has no cover and is anchored, give it a cover
			src.cover.Parent_Turret = src // assign the cover its Parent_Turret, which would be this (src)

	if(stat & (NOPOWER|BROKEN))
		// if the turret has no power or is broken, make the turret pop down if it hasn't already
		popDown()
		return

	if(!on)
		// if the turret is off, make it pop down
		popDown()
		return

	last_fired = 0
	if(attacked)
		attacked--

	var/list/targets = list()		   // list of primary targets
	var/list/secondarytargets = list() // targets that are least important




	for(var/mob/living/L in view(7+emagged*5, src))
		if(L.flags & INVULNERABLE)
			continue
		if(L.isDead() || isMoMMI(L))//mommis are always safe
			continue
		if(emagged)
			if(L.isUnconscious())
				secondarytargets += L //if the turret is emagged, skip all the fancy target picking stuff
			else
				targets += L  //and focus on murdering everything

		else if(!issilicon(L))
			if(isanimal(L)) // if its set to check for xenos/carps, check for non-mob "crittersssss"(And simple_animals)
				if(check_anomalies || attacked)
					if(L.isUnconscious())
						continue
					// Ignore lazarus-injected mobs.
					if(dd_hasprefix(L.faction, "lazarus"))
						continue
					targets += L

			if(isalien(L))
				if(check_anomalies || attacked) // git those fukken xenos
					if(!L.isUnconscious())
						targets += L
					else
						secondarytargets += L

			else
				if(L.isUnconscious() || L.restrained()) // if the perp is handcuffed or dead/dying, no need to bother really
					continue // move onto next potential victim!

				if(ai) // If it's set to attack all nonsilicons, target them!
					if(L.lying)
						secondarytargets += L
						continue
					else
						targets += L
						continue

				if(ishuman(L)) // if the target is a human, analyze threat level
					if(assess_perp(L) < PERP_LEVEL_ARREST)
						continue // if threat level < PERP_LEVEL_ARREST, keep going

				if(ismonkey(L) && !(check_anomalies || attacked))
					continue // Don't target monkeys or borgs/AIs you dumb shit

				if(isslime(L) && !(check_anomalies || attacked))
					continue

				if(L.lying) // if the perp is lying down, it's still a target but a less-important target
					secondarytargets += L
					continue

				targets += L // if the perp has passed all previous tests, congrats, it is now a "shoot-me!" nominee


	if (targets.len>0) // if there are targets to shoot

		var/atom/t = pick(targets) // pick a perp from the list of targets. Targets go first because they are the most important

		if (istype(t, /mob/living)) // if a mob
			var/mob/living/M = t // simple typecasting
			if (M.stat!=2) // if the target is not dead
				spawn() popUp() // pop the turret up if it's not already up.
				dir=get_dir(src,M) // even if you can't shoot, follow the target
				spawn() shootAt(M) // shoot the target, finally
		if(prob(15))
			if(prob(50))
				playsound(get_turf(src), 'sound/effects/turret/move1.wav', 60, 1)
			else
				playsound(get_turf(src), 'sound/effects/turret/move2.wav', 60, 1)

	else if(secondarytargets.len>0) // if there are no primary targets, go for secondary targets
		var/mob/t = pick(secondarytargets)
		if (istype(t, /mob/living))
			if (t.stat!=2)
				spawn() popUp()
				dir=get_dir(src,t)
				shootAt(t)
		if(prob(15))
			if(prob(50))
				playsound(get_turf(src), 'sound/effects/turret/move1.wav', 60, 1)
			else
				playsound(get_turf(src), 'sound/effects/turret/move2.wav', 60, 1)
	else
		spawn()
			popDown()


/obj/machinery/porta_turret/proc/popUp() // pops the turret up
	if(disabled)
		return
	if(raising || raised)
		return
	if(stat & BROKEN)
		return
	invisibility=0
	raising=1
	flick("popup",cover)
	playsound(get_turf(src), 'sound/effects/turret/open.wav', 60, 1)
	sleep(5)
	sleep(5)
	raising=0
	cover.icon_state="openTurretCover"
	raised=1
	layer = TURRET_LAYER

/obj/machinery/porta_turret/proc/popDown() // pops the turret down
	if(disabled)
		return
	if(raising || !raised)
		return
	if(stat & BROKEN)
		return
	layer = OBJ_LAYER
	raising=1
	flick("popdown",cover)
	playsound(get_turf(src), 'sound/effects/turret/open.wav', 60, 1)
	sleep(10)
	raising=0
	cover.icon_state="turretCover"
	raised=0
	invisibility = INVISIBILITY_LEVEL_TWO
	icon_state="[lasercolor]grey_target_prism"


/obj/machinery/porta_turret/proc/assess_perp(mob/living/carbon/human/perp as mob)
	var/threatcount = 0 // the integer returned

	if(src.emagged)
		return PERP_LEVEL_ARREST + rand(PERP_LEVEL_ARREST, PERP_LEVEL_ARREST*5) // if emagged, always return more than PERP_LEVEL_ARREST.

	if((stun_all && !src.allowed(perp)) || attacked && !src.allowed(perp))
		// if the turret has been attacked or is angry, target all non-sec people
		if(!src.allowed(perp))
			return PERP_LEVEL_ARREST + rand(PERP_LEVEL_ARREST, PERP_LEVEL_ARREST*5)

	if(auth_weapons) // check for weapon authorization
		if((isnull(perp.wear_id)) || (istype(perp.wear_id.GetID(), /obj/item/weapon/card/id/syndicate)))

			if((src.allowed(perp)) && !(src.lasercolor)) // if the perp has security access, return 0
				return 0

			for(var/obj/item/G in perp.held_items)
				if(istype(G, /obj/item/weapon/gun))
					if(istype(G, /obj/item/weapon/gun/projectile/shotgun))
						continue
				else if(!istype(G, /obj/item/weapon/melee/baton))
					continue
				//Scan for guns and stun batons. Bartender's shotgun doesn't trigger the turret

				threatcount += PERP_LEVEL_ARREST

			if(istype(perp.belt, /obj/item/weapon/gun) || istype(perp.belt, /obj/item/weapon/melee/baton))
				threatcount += PERP_LEVEL_ARREST/2

	if((src.lasercolor) == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
		threatcount = 0//But does not target anyone else
		if(istype(perp.wear_suit, /obj/item/clothing/suit/redtag))
			threatcount += PERP_LEVEL_ARREST
		if(perp.find_held_item_by_type(/obj/item/weapon/gun/energy/laser/redtag))
			threatcount += PERP_LEVEL_ARREST
		if(istype(perp.belt, /obj/item/weapon/gun/energy/laser/redtag))
			threatcount += PERP_LEVEL_ARREST/2

	if((src.lasercolor) == "r")
		threatcount = 0
		if(istype(perp.wear_suit, /obj/item/clothing/suit/bluetag))
			threatcount += PERP_LEVEL_ARREST
		if(perp.find_held_item_by_type(/obj/item/weapon/gun/energy/laser/bluetag))
			threatcount += PERP_LEVEL_ARREST
		if(istype(perp.belt, /obj/item/weapon/gun/energy/laser/bluetag))
			threatcount += PERP_LEVEL_ARREST/2

	if (src.check_records) // if the turret can check the records, check if they are set to *Arrest* on records
		for (var/datum/data/record/E in data_core.general)

			var/perpname = perp.name
			if (perp.wear_id)
				var/obj/item/weapon/card/id/id = perp.wear_id.GetID()
				if (id)
					perpname = id.registered_name

			if (E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if ((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						threatcount = PERP_LEVEL_ARREST
						break



	return threatcount





/obj/machinery/porta_turret/proc/shootAt(var/atom/movable/target) // shoots at a target
	if(disabled)
		return

	if(lasercolor && (istype(target,/mob/living/carbon/human)))
		var/mob/living/carbon/human/H = target
		if(H.lying)
			return

	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if (!istype(T) || !istype(U))
		return

	if (!raised) // the turret has to be raised in order to fire - makes sense, right?
		return

	if(!emagged)
		icon_state = "[lasercolor]target_prism"
	else
		icon_state = "[lasercolor]orange_target_prism"

	use_power(reqpower)

//		 //Shooting Code:
	playsound(get_turf(src), installed.fire_sound, 75, 1)
	var/obj/item/projectile/A
	A = new installed.projectile_type(loc)
	A.original = target
	A.starting = T
	A.shot_from = installed
	A.current = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.OnFired()
	spawn()
		A.process()

	if(emagged && !last_fired)
		sleep(5)
		last_fired = 1
		shootAt(target)
	return



/*

		Portable turret constructions

		Known as "turret frame"s

*/

/obj/machinery/porta_turret_construct
	name = "turret frame"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turret_frame"
	density=1
	var/build_step = 0 // the current step in the building process
	var/finish_name="turret" // the name applied to the product turret
	var/obj/item/weapon/gun/energy/installed = null // the gun installed
	machine_flags = SHUTTLEWRENCH



/obj/machinery/porta_turret_construct/attackby(obj/item/W as obj, mob/user as mob)

	// this is a bit unweildy but self-explanitory
	switch(build_step)
		if(0) // first step
			if(iswrench(W) && !anchored && wrenchAnchor(user))
				build_step = 1
				anchored = 1
				return

			else if(iscrowbar(W) && !anchored)
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 75, 1)
				to_chat(user, "You dismantle the turret construction.")
				getFromPool(/obj/item/stack/sheet/metal, loc, 5)
				qdel(src)
				return

		if(1)
			if(istype(W, /obj/item/stack/sheet/metal))
				var/obj/item/stack/sheet/metal/stack = W
				if(stack.use(2)) // requires 2 metal sheets
					to_chat(user, "<span class='notice'>You add some metal armor to the interior frame.</span>")
					build_step = 2
					icon_state = "turret_frame2"
					return
				else
					to_chat(user, "<span class='warning'>You need at least 2 [stack] to add internal armor.</span>")
					return

			else if(iswrench(W) && wrenchAnchor(user))
				build_step = 0
				anchored = 0
				return


		if(2)
			if(iswrench(W))
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
				to_chat(user, "<span class='notice'>You bolt the metal armor into place.</span>")
				build_step = 3
				return

			else if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(!WT.isOn())
					return
				if (WT.get_fuel() < 5) // uses up 5 fuel.
					to_chat(user, "<span class='warning'>You need more fuel to complete this task.</span>")
					return

				playsound(get_turf(src), pick('sound/items/Welder.ogg', 'sound/items/Welder2.ogg'), 50, 1)
				if(do_after(user, src, 20))
					if(!src || !WT.remove_fuel(5, user))
						return
					build_step = 1
					to_chat(user, "You remove the turret's interior metal armor.")
					getFromPool(/obj/item/stack/sheet/metal, loc, 2)
					icon_state = "turret_frame"
					return


		if(3)
			if(istype(W, /obj/item/weapon/gun/energy)) // the gun installation part
				if(!user.drop_item(W, src))
					to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
					return
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 100, 1)
				installed = W
				to_chat(user, "<span class='notice'>You add \the [W] to the turret.</span>")
				build_step = 4
				return

			else if(iswrench(W))
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
				to_chat(user, "You remove the turret's metal armor bolts.")
				build_step = 2
				return

		if(4)
			if(isprox(W))
				if(!user.drop_item(W, src))
					to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
					return
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 100, 1)
				build_step = 5
				to_chat(user, "<span class='notice'>You add the prox sensor to the turret.</span>")
				qdel(W)
				return

			// attack_hand() removes the gun

		if(5)
			if(isscrewdriver(W))
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 100, 1)
				build_step = 6
				to_chat(user, "<span class='notice'>You close the internal access hatch.</span>")
				return

			// attack_hand() removes the prox sensor

		if(6)
			if(istype(W, /obj/item/stack/sheet/metal))
				var/obj/item/stack/sheet/metal/stack = W
				if(stack.use(2))
					to_chat(user, "<span class='notice'>You add some metal armor to the exterior frame.</span>")
					build_step = 7
					return
				else
					to_chat(user, "<span class='warning'>You need at least 2 [stack] to add external armor.</span>")
					return

			else if(isscrewdriver(W))
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 100, 1)
				build_step = 5
				to_chat(user, "You open the internal access hatch.")
				return

		if(7)
			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT = W
				if(!WT.isOn())
					return
				if (WT.get_fuel() < 5)
					to_chat(user, "<span class='warning'>You need more fuel to complete this task.</span>")

				playsound(get_turf(src), pick('sound/items/Welder.ogg', 'sound/items/Welder2.ogg'), 50, 1)
				if(do_after(user, src, 30))
					if(!src || !WT.remove_fuel(5, user))
						return
					build_step = 8
					to_chat(user, "<span class='notice'>You weld the turret's armor down.</span>")

					// The final step: create a full turret
					var/obj/machinery/porta_turret/Turret = new/obj/machinery/porta_turret(locate(x,y,z))
					Turret.name = finish_name
					Turret.installed = src.installed
					installed.forceMove(Turret)
					Turret.update_gun()
					qdel(src)

			else if(iscrowbar(W))
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 75, 1)
				to_chat(user, "You pry off the turret's exterior armor.")
				getFromPool(/obj/item/stack/sheet/metal, loc, 2)
				build_step = 6
				return

	if (istype(W, /obj/item/weapon/pen)) // you can rename turrets like bots!
		var/t = input(user, "Enter new turret name", src.name, src.finish_name) as text
		t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.finish_name = t
		return
	..()

/obj/machinery/porta_turret_construct/attack_ghost(var/mob/user) //stop taking the guns out
	return 0

/obj/machinery/porta_turret_construct/attack_ai(var/mob/user)
	return 0

/obj/machinery/porta_turret_construct/attack_hand(mob/user as mob)
	switch(build_step)
		if(4)
			if(!installed)
				return
			build_step = 3

			to_chat(user, "You remove \the [installed] from the turret frame.")
			var/obj/item/I = installed
			user.put_in_hands(I)
			installed = null

		if(5)
			to_chat(user, "You remove the prox sensor from the turret frame.")
			var/obj/item/device/assembly/prox_sensor/P = new(user.loc)
			user.put_in_hands(P)
			build_step = 4



/obj/machinery/porta_turret_cover
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	anchored = 1
	layer = TURRET_COVER_LAYER
	density = 0
	var/obj/machinery/porta_turret/Parent_Turret = null

	machine_flags = SHUTTLEWRENCH


/obj/machinery/porta_turret_cover/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	return Parent_Turret.attack_ai(user)

/obj/machinery/porta_turret_cover/attackby(obj/item/W as obj, mob/user as mob)
	add_fingerprint(user)
	return Parent_Turret.attackby(W, user)

/obj/machinery/porta_turret_cover/attack_hand(mob/user as mob)
	add_fingerprint(user)
	return Parent_Turret.attack_hand(user)

/obj/machinery/porta_turret/stationary
	emagged = 1

	New()
		installed = new/obj/item/weapon/gun/energy/laser(src)
		..()
