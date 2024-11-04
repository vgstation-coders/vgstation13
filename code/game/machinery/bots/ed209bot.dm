/obj/machinery/bot/ed209
	name = "ED-209 Security Robot"
	desc = "A security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed2090"
	icon_initial = "ed209"
	density = 1
	anchored = 0
//	weight = 1.0E7
	req_one_access = list(access_security, access_forensics_lockers)
	health = 100
	maxHealth = 100
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5
	steps_per = 2
	control_filter = RADIO_SECBOT
	var/cuffing = 0
	var/lastfired = 0
	var/shot_delay = 3 //.3 seconds between shots
	var/lasercolor = null
	var/disabled = 0//A holder for if it needs to be disabled, if true it will not seach for targets, shoot at targets, or move, currently only used for lasertag

	//var/lasers = 0

	var/threatlevel = 0
	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff

	var/projectile = /obj/item/projectile/energy/electrode
	bot_type = SEC_BOT

	auto_patrol = 0		// set to make bot automatically patrol
	var/declare_arrests = 1 //When making an arrest, should it notify everyone wearing sechuds?
	var/idcheck = 1 //If true, arrest people with no IDs
	var/weaponscheck = 1 //If true, arrest people for weapons if they don't have access
	bot_flags = BOT_PATROL|BOT_BEACON|BOT_CONTROL|BOT_DENSE
	//List of weapons that secbots will not arrest for, also copypasted in secbot.dm and metaldetector.dm
	var/safe_weapons = list(
		/obj/item/weapon/gun/energy/tag,
		/obj/item/weapon/gun/energy/laser/practice,
		/obj/item/weapon/gun/hookshot,
		/obj/item/weapon/melee/defibrillator
		)

	target_chasing_distance = 12
	commanding_radios = list(/obj/item/radio/integrated/signal/bot/beepsky)

/obj/item/weapon/ed209_assembly
	name = "ED-209 assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed209_frame"
	item_state = "ed209_frame"
	var/build_step = 0
	var/created_name = "ED-209 Security Robot" //To preserve the name if it's a unique securitron I guess
	var/lasercolor = null

/obj/machinery/bot/ed209/bluetag
	lasercolor = "b"
	projectile = /obj/item/projectile/beam/lasertag/blue

/obj/machinery/bot/ed209/redtag
	lasercolor = "r"
	projectile = /obj/item/projectile/beam/lasertag/red

/obj/machinery/bot/ed209/New(loc,created_name,created_lasercolor)
	. = ..()
	if(created_name)
		name = created_name
	if(created_lasercolor)
		lasercolor = created_lasercolor
	icon_state = "[lasercolor][icon_initial][on]"
	spawn(3)
		botcard = new /obj/item/weapon/card/id(src)
		var/datum/job/detective/J = new/datum/job/detective
		botcard.access = J.get_access()
		if(lasercolor)
			shot_delay = 6//Longer shot delay because JESUS CHRIST
			check_records = 0//Don't actively target people set to arrest
			arrest_type = 1//Don't even try to cuff
			req_access = list(access_maint_tunnels)
			if((lasercolor == "b") && (name == "ED-209 Security Robot"))//Picks a name if there isn't already a custom one
				name = pick("BLUE BALLER","SANIC","BLUE KILLDEATH MURDERBOT")
			if((lasercolor == "r") && (name == "ED-209 Security Robot"))
				name = pick("RED RAMPAGE","RED ROVER","RED KILLDEATH MURDERBOT")

/obj/machinery/bot/ed209/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover,/obj/machinery/bot/ed209))
		return 1
	else
		return ..()

/obj/machinery/bot/ed209/turn_on()
	. = ..()
	icon_state = "[lasercolor][icon_initial][on]"
	updateUsrDialog()

/obj/machinery/bot/ed209/turn_off()
	..()
	target = null
	anchored = 0
	old_targets = list()
	start_walk_to(0)
	icon_state = "[lasercolor][icon_initial][on]"
	updateUsrDialog()

/obj/machinery/bot/ed209/attack_hand(mob/user)
	. = ..()
	if (.)
		return
	var/dat

	dat += text({"
<TT><B>Automatic Security Unit v2.5</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"},

"<A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A>" )

	if(!locked || issilicon(user))
		if(!lasercolor)
			dat += text({"<BR>
Arrest for No ID: [] <BR>
Arrest for Unauthorized Weapons: [] <BR>
Arrest for Warrant: [] <BR>
<BR>
Operating Mode: []<BR>
Report Arrests: []<BR>
Auto Patrol: []"},

"<A href='?src=\ref[src];operation=idcheck'>[idcheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=weaponscheck'>[weaponscheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=ignorerec'>[check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=switchmode'>[arrest_type ? "Detain" : "Arrest"]</A>",
"<A href='?src=\ref[src];operation=declarearrests'>[declare_arrests ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )
		else
			dat += text({"<BR>
Auto Patrol: []"},

"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )


	user << browse("<HEAD><TITLE>Securitron v2.5 controls</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/obj/machinery/bot/ed209/Topic(href, href_list)
	if (..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(lasercolor && (istype(usr,/mob/living/carbon/human)))
		var/mob/living/carbon/human/H = usr
		if((lasercolor == "b") && iswearingredtag(H))//Opposing team cannot operate it
			return
		else if((lasercolor == "r") && iswearingbluetag(H))
			return
	if ((href_list["power"]) && (allowed(usr)))
		if (on)
			turn_off()
		else
			turn_on()
		return

	switch(href_list["operation"])
		if ("idcheck")
			idcheck = !idcheck
			updateUsrDialog()
		if("weaponscheck")
			weaponscheck = !weaponscheck
			updateUsrDialog()
		if ("ignorerec")
			check_records = !check_records
			updateUsrDialog()
		if ("switchmode")
			arrest_type = !arrest_type
			updateUsrDialog()
		if("patrol")
			auto_patrol = !auto_patrol
			updateUsrDialog()
		if("declarearrests")
			declare_arrests = !declare_arrests
			updateUsrDialog()

/obj/machinery/bot/ed209/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>Controls are now [locked ? "locked" : "unlocked"].</span>")
			updateUsrDialog()
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			else if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='notice'>Access denied.</span>")
	else
		. = ..()
		if (. && !target)
			threatlevel = user.assess_threat(src)
			threatlevel += PERP_LEVEL_ARREST_MORE
			if(threatlevel > 0)
				target = user
				shootAt(user)

/obj/machinery/bot/ed209/kick_act(mob/living/H)
	..()
	summoned = FALSE // Anger
	threatlevel = H.assess_threat(src)
	threatlevel += PERP_LEVEL_ARREST_MORE

	if(threatlevel > 0)
		target = H
		shootAt(H)

/obj/machinery/bot/ed209/emag_act(mob/user)
	..()
	if(open && !locked)
		if(user)
			to_chat(user, "<span class='warning'>You short out [src]'s target assessment circuits.</span>")
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='danger'>[src] buzzes oddly!</span>", 1)
		target = null
		add_oldtarget(user.name, 12)
		anchored = 0
		emagged = TRUE
		on = 1
		steps_per = 3 // Gotta go fast
		icon_state = "[lasercolor][icon_initial][on]"
		if(lasercolor)
			projectile = /obj/item/projectile/beam/lasertag/omni
		else
			projectile = /obj/item/projectile/beam
		shot_delay = 6//Longer shot delay because JESUS CHRIST
		check_records = 0//Don't actively target people set to arrest
		arrest_type = 1//Don't even try to cuff
		declare_arrests = 0


/obj/machinery/bot/ed209/target_selection()
	anchored = 0
	threatlevel = 0
	for (var/mob/living/carbon/C in view(target_chasing_distance,src)) //Let's find us a criminal
		if ((C.stat) || (C.handcuffed))
			continue

		if((lasercolor) && (C.lying))
			continue//Does not shoot at people lyind down when in lasertag mode, because it's just annoying, and they can fire once they get up.

		if (C.name in old_targets)
			continue

		if (istype(C, /mob/living/carbon/human))
			threatlevel = assess_perp(C)

		if (!threatlevel)
			continue

		else if (threatlevel >= PERP_LEVEL_ARREST)
			target = C
			speak("Level [threatlevel] infraction alert!")
			if(!lasercolor)
				playsound(src, pick('sound/voice/ed209_20sec.ogg', 'sound/voice/EDPlaceholder.ogg'), 50, 0)
			visible_message("<b>[src]</b> points at [C.name]!")
			process_path()

//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
//THIS CODE IS COPYPASTED IN secbot.dm AND metaldetector.dm, with slight variations
/obj/machinery/bot/ed209/proc/assess_perp(mob/living/carbon/human/perp)
	var/threatcount = 0 //If threat >= PERP_LEVEL_ARREST at the end, they get arrested

	if(emagged)
		return PERP_LEVEL_ARREST + rand(PERP_LEVEL_ARREST, PERP_LEVEL_ARREST*5) //Everyone is a criminal!

	if(!allowed(perp)) //cops can do no wrong, unless set to arrest.

		if(weaponscheck && !wpermit(perp))
			for(var/obj/item/W in perp.held_items)
				if(check_for_weapons(W))
					threatcount += PERP_LEVEL_ARREST

			if(istype(perp.belt, /obj/item/weapon/gun) || istype(perp.belt, /obj/item/weapon/melee))
				if(!(perp.belt.type in safe_weapons))
					threatcount += PERP_LEVEL_ARREST/2

		if(istype(perp.wear_suit, /obj/item/clothing/suit/wizrobe))
			threatcount += PERP_LEVEL_ARREST/2

		if(perp.dna && perp.dna.mutantrace && perp.dna.mutantrace != "none")
			threatcount += PERP_LEVEL_ARREST/2
		var/visible_id = perp.get_visible_id()
		if(!visible_id)
			if(idcheck)
				threatcount += PERP_LEVEL_ARREST
			else
				threatcount += PERP_LEVEL_ARREST/2

		//Agent cards lower threatlevel.
		if(istype(visible_id, /obj/item/weapon/card/id/syndicate))
			threatcount -= PERP_LEVEL_ARREST/2

	if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
		threatcount = 0//They will not, however shoot at people who have guns, because it gets really fucking annoying
		if(iswearingredtag(perp))
			threatcount += PERP_LEVEL_ARREST
		if(perp.find_held_item_by_type(/obj/item/weapon/gun/energy/tag/red))
			threatcount += PERP_LEVEL_ARREST
		if(istype(perp.belt, /obj/item/weapon/gun/energy/tag/red))
			threatcount += PERP_LEVEL_ARREST/2

	if(lasercolor == "r")
		threatcount = 0
		if(iswearingbluetag(perp))
			threatcount += PERP_LEVEL_ARREST
		if(perp.find_held_item_by_type(/obj/item/weapon/gun/energy/tag/blue))
			threatcount += PERP_LEVEL_ARREST
		if(istype(perp.belt, /obj/item/weapon/gun/energy/tag/blue))
			threatcount += PERP_LEVEL_ARREST/2

	if(check_records)
		for (var/datum/data/record/E in data_core.general)
			var/perpname = perp.name
			var/obj/item/weapon/card/id/id = perp.get_visible_id()
			if(id)
				perpname = id.registered_name

			if(E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*High Threat*"))
						threatcount = PERP_LEVEL_TERMINATE
						break
					if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						threatcount = PERP_LEVEL_ARREST
						break

	return threatcount

/obj/machinery/bot/ed209/can_path()
	return !cuffing

/obj/machinery/bot/ed209/process_bot()
	if (can_abandon_target())
		target = null
		find_target()

	decay_oldtargets()

	if (target)		// make sure target exists
		if(!istype(target.loc, /turf))
			return
		if (Adjacent(target))		// if right next to perp
			var/mob/living/carbon/M = target
			target = null // Don't teabag them
			path = list() // Kill our path
			add_oldtarget(M.name, 12)
			var/beat_them = (!M.incapacitated() || emagged) // Only stun people non-stunned. Stun forever if we're emagged
			if (beat_them)
				playsound(src, 'sound/weapons/Egloves.ogg', 50, 1, -1)
				icon_state = "[lasercolor][icon_initial]-c"
				spawn(2)
					icon_state = "[lasercolor][icon_initial][on]"
				if (istype(M, /mob/living/carbon/human))
					if (M.stuttering < 10 && (!(M_HULK in M.mutations)))
						M.stuttering = 10
				else
					M.stuttering = 10
				M.Stun(10)
				M.Knockdown(10)
			if (cuffing)
				return
			playsound(src, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
			visible_message("<span class='danger'>[src] is trying to put handcuffs on [M]!</span>")
			if (!arrest_type)
				cuffing = 1
				var/cuff_time = emagged ? 2 SECONDS : 6 SECONDS
				spawn(cuff_time)
					cuffing = 0
					if (Adjacent(M))
						if (!istype(M))
							return
						if (M.handcuffed)
							return
						M.handcuffed = new /obj/item/weapon/handcuffs(M)
						M.update_inv_handcuffed()	//update handcuff overlays
			if(declare_arrests)
				var/area/location = get_area(src)
				broadcast_security_hud_message("[name] is [arrest_type ? "detaining" : "arresting"] level [threatlevel] suspect <b>[M]</b> in <b>[location]</b>", src)
			visible_message("<span class='danger'>[M] has been stunned by [src]!</span>")

			anchored = 1
			return

		else								// not next to perp
			shootAt(target)

/obj/machinery/bot/ed209/proc/speak(var/message)
	visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",\
		drugged_message="<span class='game say'><span class='name'>[src]</span> beeps, \"[pick("I-It's not like I like you or anything... baka!","You're s-so silly!","I-I'm only doing this because you asked me nicely, baka...","S-stop that!","Y-you're embarassing me!")]\"")
	return

/obj/machinery/bot/ed209/explode()
	start_walk_to(0)
	visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/ed209_assembly/Sa = new /obj/item/weapon/ed209_assembly(Tsec)
	Sa.build_step = 1
	Sa.overlays += image('icons/obj/aibots.dmi', "hs_hole")
	Sa.created_name = name
	new /obj/item/device/assembly/prox_sensor(Tsec)

	if(!lasercolor)
		var/obj/item/weapon/gun/energy/taser/G = new /obj/item/weapon/gun/energy/taser(Tsec)
		G.power_supply.charge = 0
		G.update_icon()
	else if(lasercolor == "b")
		var/obj/item/weapon/gun/energy/tag/blue/G = new /obj/item/weapon/gun/energy/tag/blue(Tsec)
		G.power_supply.charge = 0
	else if(lasercolor == "r")
		var/obj/item/weapon/gun/energy/tag/red/G = new /obj/item/weapon/gun/energy/tag/red(Tsec)
		G.power_supply.charge = 0

	if (prob(50))
		new /obj/item/robot_parts/l_leg(Tsec)
		if (prob(25))
			new /obj/item/robot_parts/r_leg(Tsec)
	if (prob(25))//50% chance for a helmet OR vest
		if (prob(50))
			new /obj/item/clothing/head/helmet/tactical/sec(Tsec)
		else
			if(!lasercolor)
				new /obj/item/clothing/suit/armor/vest(Tsec)
			if(lasercolor == "b")
				new /obj/item/clothing/suit/tag/bluetag(Tsec)
			if(lasercolor == "r")
				new /obj/item/clothing/suit/tag/redtag(Tsec)

	spark(src)

	new /obj/effect/decal/cleanable/blood/oil(loc)
	qdel(src)


/obj/machinery/bot/ed209/proc/shootAt(var/mob/target)
	if(!projectile)
		return
	if(lastfired && world.time - lastfired < shot_delay)
		return
	lastfired = world.time
	var/turf/T = loc
	var/atom/U = (istype(target, /atom/movable) ? target.loc : target)
	if ((!( U ) || !( T )))
		return
	while(!( istype(U, /turf) ))
		U = U.loc
	if (!( istype(T, /turf) ))
		return

	//if(lastfired && world.time - lastfired < 100)
	//	playsound(src, 'ed209_shoot.ogg', 50, 0)

	if (!( istype(U, /turf) ))
		return
	var/shoot_them = (!target.incapacitated() || emagged) // Only stun people non-stunned. Stun forever if we're emagged
	if (!shoot_them)
		return
	var/obj/item/projectile/A = new projectile (loc)
	A.original = target
	A.target = target
	A.current = T
	A.starting = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	spawn()
		A.OnFired()
		A.process()
		return
	return

/obj/machinery/bot/ed209/attack_alien(var/mob/living/carbon/alien/user)
	..()
	if (!isalien(target))
		target = user


/obj/machinery/bot/ed209/emp_act(severity)

	if(severity==2 && prob(70))
		..(severity-1)
	else
		var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( loc )
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)
		spawn(10)
			qdel(pulse2)
		var/list/mob/living/carbon/targets = new
		for (var/mob/living/carbon/C in view(12,src))
			if (C.stat==2)
				continue
			targets += C
		if(targets.len)
			if(prob(50))
				var/mob/toshoot = pick(targets)
				if (toshoot)
					targets-=toshoot
					if (prob(50) && emagged < 2)
						emagged = 2
						shootAt(toshoot)
						emagged = 0
					else
						shootAt(toshoot)
			else if(prob(50))
				if(targets.len)
					var/mob/toarrest = pick(targets)
					if (toarrest)
						target = toarrest

/obj/machinery/bot/ed209/return_status()
	if (target)
		return "Chasing prep"
	if (auto_patrol)
		return "Patrolling"
	return ..()


#define ED209_BUILD_STEP_INITIAL 0
#define ED209_BUILD_STEP_ONELEG 1
#define ED209_BUILD_STEP_VEST 2
#define ED209_BUILD_STEP_WELD 3
#define ED209_BUILD_STEP_HELMET 4
#define ED209_BUILD_STEP_PROX_SENSOR 5
#define ED209_BUILD_STEP_CABLE 6
#define ED209_BUILD_STEP_WEAPON 7
#define ED209_BUILD_STEP_SCREWDRIVER 8
#define ED209_BUILD_STEP_FINAL 9

/obj/item/weapon/ed209_assembly/attackby(obj/item/weapon/W, mob/user)
	..()

	if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", name, created_name),1,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, user) && loc != user)
			return
		created_name = t
		return

	switch(build_step)
		if(ED209_BUILD_STEP_INITIAL, ED209_BUILD_STEP_ONELEG)
			if( istype(W, /obj/item/robot_parts/l_leg) || istype(W, /obj/item/robot_parts/r_leg) )
				if(user.drop_item(W))
					qdel(W)
					build_step++
					to_chat(user, "<span class='notice'>You add the robot leg to [src].</span>")
					name = "legs/frame assembly"
					if(build_step == ED209_BUILD_STEP_ONELEG)
						item_state = "ed209_leg"
						icon_state = "ed209_leg"
					else
						item_state = "ed209_legs"
						icon_state = "ed209_legs"

		if(ED209_BUILD_STEP_VEST)
			if( istype(W, /obj/item/clothing/suit/tag/redtag) )
				lasercolor = "r"
			else if( istype(W, /obj/item/clothing/suit/tag/bluetag) )
				lasercolor = "b"
			if( lasercolor || istype(W, /obj/item/clothing/suit/armor/vest) )
				if(user.drop_item(W))
					qdel(W)
					build_step++
					to_chat(user, "<span class='notice'>You add the armor to [src].</span>")
					name = "vest/legs/frame assembly"
					item_state = "[lasercolor]ed209_shell"
					icon_state = "[lasercolor]ed209_shell"

		if(ED209_BUILD_STEP_WELD)
			if( iswelder(W) )
				var/obj/item/tool/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					build_step++
					name = "shielded frame assembly"
					to_chat(user, "<span class='notice'>You welded the vest to [src].</span>")
		if(ED209_BUILD_STEP_HELMET)
			if( istype(W, /obj/item/clothing/head/helmet/tactical/sec) )
				if(user.drop_item(W))
					qdel(W)
					build_step++
					to_chat(user, "<span class='notice'>You add the helmet to [src].</span>")
					name = "covered and shielded frame assembly"
					item_state = "[lasercolor]ed209_hat"
					icon_state = "[lasercolor]ed209_hat"

		if(ED209_BUILD_STEP_PROX_SENSOR)
			if( isprox(W) )
				if(user.drop_item(W))
					qdel(W)
					build_step++
					to_chat(user, "<span class='notice'>You add the prox sensor to [src].</span>")
					name = "covered, shielded and sensored frame assembly"
					item_state = "[lasercolor]ed209_prox"
					icon_state = "[lasercolor]ed209_prox"

		if(ED209_BUILD_STEP_CABLE)
			if( istype(W, /obj/item/stack/cable_coil) )
				var/obj/item/stack/cable_coil/coil = W
				var/turf/T = get_turf(user)
				to_chat(user, "<span class='notice'>You start to wire [src]...</span>")
				sleep(40)
				if(get_turf(user) == T)
					coil.use(1)
					build_step++
					to_chat(user, "<span class='notice'>You wire the ED-209 assembly.</span>")
					name = "wired ED-209 assembly"

		if(ED209_BUILD_STEP_WEAPON)
			if(!user.drop_item(W))
				return

			switch(lasercolor)
				if("b")
					if( !istype(W, /obj/item/weapon/gun/energy/tag/blue) )
						return
					name = "bluetag ED-209 assembly"
				if("r")
					if( !istype(W, /obj/item/weapon/gun/energy/tag/red) )
						return
					name = "redtag ED-209 assembly"
				if(null)
					if( !istype(W, /obj/item/weapon/gun/energy/taser) )
						return
					name = "taser ED-209 assembly"
				else
					return
			build_step++
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			item_state = "[lasercolor]ed209_taser"
			icon_state = "[lasercolor]ed209_taser"
			qdel(W)

		if(ED209_BUILD_STEP_SCREWDRIVER)
			if( W.is_screwdriver(user) )
				W.playtoolsound(src, 100)
				var/turf/T = get_turf(user)
				to_chat(user, "<span class='notice'>Now attaching the gun to the frame...</span>")
				sleep(40)
				if(get_turf(user) == T)
					build_step++
					name = "armed [name]"
					to_chat(user, "<span class='notice'>Taser gun attached.</span>")

		if(ED209_BUILD_STEP_FINAL)
			if( istype(W, /obj/item/weapon/cell) )
				if(!user.drop_item(W))
					return

				build_step++
				to_chat(user, "<span class='notice'>You complete the ED-209.</span>")
				var/turf/T = get_turf(src)
				new /obj/machinery/bot/ed209(T,created_name,lasercolor)
				qdel(W)
				user.drop_from_inventory(src)
				qdel(src)


/obj/machinery/bot/ed209/bullet_act(var/obj/item/projectile/Proj)
	if((lasercolor == "b") && (disabled == 0))
		if(istype(Proj, /obj/item/projectile/beam/lasertag/red))
			disabled = 1
			//del (Proj)
			qdel(Proj)
			sleep(100)
			disabled = 0
		else
			. = ..()
	else if((lasercolor == "r") && (disabled == 0))
		if(istype(Proj, /obj/item/projectile/beam/lasertag/blue))
			disabled = 1
			//del (Proj)
			qdel(Proj)
			sleep(100)
			disabled = 0
		else
			. = ..()
	else
		return ..()

/obj/machinery/bot/ed209/proc/check_for_weapons(var/obj/item/slot_item) //Unused anywhere, copypasted in secbot.dm
	if(istype(slot_item, /obj/item/weapon/gun) || istype(slot_item, /obj/item/weapon/melee))
		if(!(slot_item.type in safe_weapons))
			return 1
	return 0

/obj/machinery/bot/ed209/declare()
	var/area/location = get_area(src)
	declare_message = "<span class='info'>[bicon(src)] [name] is [arrest_type ? "detaining" : "arresting"] level [threatlevel] scumbag <b>[target]</b> in <b>[location]</b></span>"
	..()
