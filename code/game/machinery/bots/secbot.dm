//Secbot
//Patrol, look for perps. If you find a perp, chase him and give him the spicy stick
/obj/machinery/bot/secbot
	name = "Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "secbot0"
	icon_initial = "secbot"
	density = 0
	anchored = 0
	health = 25
	maxHealth = 25
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5
//	weight = 1.0E7
	req_one_access = list(access_security, access_forensics_lockers)
	control_filter = RADIO_SECBOT
	var/check_records = 1

	var/idcheck = 0 //If true, arrest people with no IDs
	var/weaponscheck = 0 //If true, arrest people for weapons if they lack access	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff
	var/declare_arrests = 0 //When making an arrest, should it notify everyone wearing sechuds?
	var/next_harm_time = 0

	var/arrest_message = null //unique arrest message for beepsky variants
	var/cuffing = 0 // Are we currently cuffing
	var/threatlevel = 0

	var/list/unsafe_weapons = list( //things that the secbot will check for
		/obj/item/weapon/gun,
		/obj/item/weapon/melee
		)

	//List of weapons that secbots will not arrest for, also copypasted in ed209.dm and metaldetector.dm
	var/list/safe_weapons = list(
		/obj/item/weapon/gun/energy/tag,
		/obj/item/weapon/gun/energy/laser/practice,
		/obj/item/weapon/gun/hookshot,
		/obj/item/weapon/melee/defibrillator
		)

	light_color = LIGHT_COLOR_RED
	bot_flags = BOT_PATROL|BOT_BEACON|BOT_CONTROL
	var/obj/item/weapon/melee/baton/baton = null
	var/baton_type = /obj/item/weapon/melee/baton/
	var/secbot_assembly_type = /obj/item/weapon/secbot_assembly/

	commanding_radios = list(/obj/item/radio/integrated/signal/bot/beepsky, /obj/machinery/navbeacon)

	hack_abilities = list(
		/datum/malfhack_ability/oneuse/emag,
		/datum/malfhack_ability/oneuse/overload_quiet
	)

/obj/machinery/bot/secbot/power_change()
	..()
	if(src.on)
		set_light(2)
	else
		set_light(0)

/obj/machinery/bot/secbot/beepsky
	name = "Officer Beep O'sky"
	desc = "It's Officer Beep O'sky! Powered by a potato and a shot of whiskey."
	auto_patrol = 1
	declare_arrests = 1

/obj/item/weapon/secbot_assembly
	name = "helmet/signaler assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/build_step = 0
	var/created_name = "Securitron" //To preserve the name if it's a unique securitron I guess

/obj/machinery/bot/secbot/New()
	. = ..()
	icon_state = "[src.icon_initial][src.on]"
	botcard = new /obj/item/weapon/card/id(src)
	var/datum/job/detective/J = new/datum/job/detective
	botcard.access = J.get_access()

/obj/machinery/bot/secbot/turn_on()
	..()
	src.icon_state = "[src.icon_initial][src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/secbot/turn_off()
	..()
	target = null
	steps_per = initial_steps_per
	old_targets = list()
	anchored = 0
	start_walk_to(0)
	icon_state = "[src.icon_initial][src.on]"
	updateUsrDialog()

/obj/machinery/bot/secbot/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	usr.set_machine(src)
	interact(user)

/obj/machinery/bot/secbot/interact(mob/user)
	var/dat

	dat += text({"
<TT><B>Automatic Security Unit v1.3</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [src.open ? "opened" : "closed"]"},

"<A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A>" )

	if(!src.locked || issilicon(user))
		dat += text({"<BR>
Arrest for No ID: [] <BR>
Arrest for Unauthorized Weapons: []<BR>
Arrest for Warrant: []<BR>
<BR>
Operating Mode: []<BR>
Report Arrests: []<BR>
Auto Patrol: []"},

"<A href='?src=\ref[src];operation=idcheck'>[src.idcheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=weaponscheck'>[weaponscheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=ignorerec'>[src.check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=switchmode'>[src.arrest_type ? "Detain" : "Arrest"]</A>",
"<A href='?src=\ref[src];operation=declarearrests'>[src.declare_arrests ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )


	user << browse("<HEAD><TITLE>Securitron v1.3 controls</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/obj/machinery/bot/secbot/Topic(href, href_list)
	if(..())
		return 1
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if((href_list["power"]) && (src.allowed(usr)))
		if(src.on)
			turn_off()
		else
			turn_on()
		return

	switch(href_list["operation"])
		if("idcheck")
			src.idcheck = !src.idcheck
			src.updateUsrDialog()
		if("weaponscheck")
			weaponscheck = !weaponscheck
			updateUsrDialog()
		if("ignorerec")
			src.check_records = !src.check_records
			src.updateUsrDialog()
		if("switchmode")
			src.arrest_type = !src.arrest_type
			src.updateUsrDialog()
		if("patrol")
			auto_patrol = !auto_patrol
			updateUsrDialog()
		if("declarearrests")
			src.declare_arrests = !src.declare_arrests
			src.updateUsrDialog()

/obj/machinery/bot/secbot/can_path()
	return !cuffing

/obj/machinery/bot/secbot/proc/set_target(var/mob/M)
	summoned = FALSE
	target = M
	steps_per = 3
	//process_path()

/obj/machinery/bot/secbot/can_patrol()
	return steps_per == initial_steps_per

/obj/machinery/bot/secbot/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, "Controls are now [locked ? "locked." : "unlocked."]")
			updateUsrDialog()
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			else if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
	else
		. = ..()
		if(. && !target)
			sleep(0.5 SECONDS)
			threatlevel = user.assess_threat(src)
			threatlevel += PERP_LEVEL_ARREST_MORE
			if(threatlevel > 0)
				set_target(user)

/obj/machinery/bot/secbot/kick_act(mob/living/H)
	..()
	sleep(0.5 SECONDS)
	threatlevel = H.assess_threat(src)
	threatlevel += PERP_LEVEL_ARREST_MORE

	if(threatlevel > 0)
		set_target(H)

/obj/machinery/bot/secbot/emag_act(mob/user)
	..()
	if(open && !locked)
		if(user)
			to_chat(user, "<span class='warning'>You short out [src]'s target assessment circuits.</span>")
		for(var/mob/O in hearers(src))
			O.show_message("<span class='danger'>[src] buzzes oddly!</span>", 1)
		src.target = null
		steps_per = initial_steps_per
		if(user)
			add_oldtarget(user, 12)
		src.anchored = 0
		src.emagged = 2
		src.on = 1
		src.icon_state = "[src.icon_initial][src.on]"

/obj/machinery/bot/secbot/target_selection()
	anchored = 0
	threatlevel = 0
	for (var/mob/living/carbon/C in view(target_chasing_distance,src)) //Let's find us a criminal
		if ((C.stat) || (C.handcuffed))
			continue

		if (C.name in old_targets)
			continue

		if (istype(C, /mob/living/carbon/human))
			threatlevel = assess_perp(C)

		if (!threatlevel)
			continue

		else if (threatlevel >= PERP_LEVEL_ARREST)
			set_target(C)
			if(src.arrest_message == null)
				src.speak("Level [src.threatlevel] infraction alert!")
			else
				src.speak("[src.arrest_message]")
			playsound(src, pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50, 0)
			visible_message("<b>[src]</b> points at [C.name]!")

/obj/machinery/bot/secbot/process_bot()
	if (can_abandon_target())
		target = null
		steps_per = initial_steps_per
		find_target()

	decay_oldtargets()

	if (target)		// make sure target exists
		if(!istype(target.loc, /turf))
			return

		if (Adjacent(target))		// if right next to perp, arrest them
			var/mob/living/carbon/M = target
			path = list() // Kill our path
			target = null // Don't teabag them
			add_oldtarget(M.name, 12)
			var/beat_them = (!M.incapacitated() || emagged) // Only stun people non-stunned. Stun forever if we're emagged
			if (beat_them)
				playsound(src, 'sound/weapons/Egloves.ogg', 50, 1, -1)

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
					if (Adjacent(M))
						if (!istype(M))
							return
						if (M.handcuffed)
							return
						M.handcuffed = new /obj/item/weapon/handcuffs(M)
						M.update_inv_handcuffed()	//update handcuff overlays
						playsound(src, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0)
						spawn (1.5 SECONDS)
							cuffing = 0
					else
						cuffing = 0
			if(declare_arrests)
				var/area/location = get_area(src)
				broadcast_security_hud_message("[name] is [arrest_type ? "detaining" : "arresting"] level [threatlevel] suspect <b>[M]</b> in <b>[location]</b>", src)
			visible_message("<span class='danger'>[M] has been stunned by [src]!</span>")

			anchored = 1
			return

/obj/machinery/bot/secbot/return_status()
	if (target)
		return "On the move"
	if (auto_patrol)
		return "Patrolling"
	return ..()

/obj/machinery/bot/secbot/execute_signal_command(var/datum/signal/signal, var/command)
	if (..())
		return
	switch (command)
		if ("arrest_for_ids")
			idcheck = !idcheck

//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
//THIS CODE IS COPYPASTED IN ed209bot.dm AND metaldetector.dm, with slight variations
/obj/machinery/bot/secbot/proc/assess_perp(mob/living/carbon/human/perp)
	var/threatcount = 0 //If threat >= 4 at the end, they get arrested

	if(src.emagged == 2)
		return PERP_LEVEL_ARREST + rand(PERP_LEVEL_ARREST, PERP_LEVEL_ARREST*5) //Everyone is a criminal!

	if(!src.allowed(perp)) //cops can do no wrong, unless set to arrest.

		if(weaponscheck && !wpermit(perp))
			for(var/obj/item/I in perp.held_items)
				if(check_for_weapons(I))
					threatcount += PERP_LEVEL_ARREST

			if(istype(perp.belt, /obj/item/weapon/gun) || istype(perp.belt, /obj/item/weapon/melee))
				if(!(perp.belt.type in safe_weapons))
					threatcount += PERP_LEVEL_ARREST/2

		if(istype(perp.wear_suit, /obj/item/clothing/suit/wizrobe))
			threatcount += PERP_LEVEL_ARREST/2

		if(!isjusthuman(perp))
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

	if(src.check_records)
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

/obj/machinery/bot/secbot/proc/speak(var/message)
	visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",\
		drugged_message="<span class='game say'><span class='name'>[src]</span> beeps, \"[pick("Wait! Let's be friends!","Wait for me!","You're so cool!","I-It's not like I like you or anything...","Wanna see a magic trick?","Let's go have fun, assistant-kun~")]\"")
	return

/obj/machinery/bot/secbot/explode()

	start_walk_to(0)
	src.visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/secbot_assembly/Sa = new secbot_assembly_type(Tsec)
	Sa.build_step = 1
	Sa.overlays += image('icons/obj/aibots.dmi', "hs_hole")
	Sa.created_name = src.name
	new /obj/item/device/assembly/prox_sensor(Tsec)
	if(baton)
		if(is_holder_of(src, baton))
			baton.forceMove(Tsec)
	else
		new baton_type(Tsec)

	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	spark(src)

	new /obj/effect/decal/cleanable/blood/oil(src.loc)
	qdel(src)

/obj/machinery/bot/secbot/attack_alien(var/mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(target))
		set_target(user)

//Secbot Construction

/obj/item/clothing/head/helmet/tactical/sec/attackby(var/obj/item/device/assembly/signaler/S, mob/user as mob)
	if(!issignaler(S))
		..()
		return
	if(S.secured)
		user.create_in_hands(src, /obj/item/weapon/secbot_assembly, S, msg = "You add the signaler to \the [src].")

/obj/item/weapon/secbot_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if((iswelder(W)) && (!src.build_step))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			src.build_step++
			src.overlays += image('icons/obj/aibots.dmi', "hs_hole")
			to_chat(user, "You weld a hole in [src]!")

	else if(isprox(W) && (src.build_step == 1))
		if(user.drop_item(W))
			src.build_step++
			to_chat(user, "You add the prox sensor to [src]!")
			src.overlays += image('icons/obj/aibots.dmi', "hs_eye")
			src.name = "helmet/signaler/prox sensor assembly"
			qdel(W)

	else if(((istype(W, /obj/item/robot_parts/l_arm)) || (istype(W, /obj/item/robot_parts/r_arm))) && (src.build_step == 2))
		if(user.drop_item(W))
			src.build_step++
			to_chat(user, "You add the robot arm to [src]!")
			src.name = "helmet/signaler/prox sensor/robot arm assembly"
			src.overlays += image('icons/obj/aibots.dmi', "hs_arm")
			qdel(W)

	else if((istype(W, /obj/item/weapon/melee/baton)) && (src.build_step >= 3))
		if(user.drop_item(W))
			src.build_step++
			to_chat(user, "You complete the Securitron! Beep boop.")
			var/obj/machinery/bot/secbot/S = new /obj/machinery/bot/secbot
			S.forceMove(get_turf(src))
			S.name = src.created_name
			W.forceMove(S)
			S.baton = W
			qdel(src)

	else if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && src.loc != usr)
			return
		src.created_name = t

/obj/machinery/bot/secbot/declare()
	var/area/location = get_area(src)
	declare_message = "<span class='info'>[bicon(src)] [name] is [arrest_type ? "detaining" : "arresting"] level [threatlevel] scumbag <b>[target]</b> in <b>[location]</b></span>"
	..()

/obj/machinery/bot/secbot/proc/check_for_weapons(var/obj/item/slot_item) //Unused anywhere, copypasted in ed209bot.dm
	if(is_type_in_list(slot_item, unsafe_weapons))
		if(!(slot_item.type in safe_weapons))
			return 1
	return 0

/obj/machinery/bot/secbot/Destroy()
	if(baton)
		if(is_holder_of(src, baton))
			qdel(baton)
		baton = null

	return ..()

/obj/machinery/bot/secbot/proc/check_if_rigged()
	if(istype(baton) && baton.bcell && baton.bcell.rigged && is_holder_of(src, baton))
		if(baton.bcell.explode())
			explode()

/obj/machinery/bot/secbot/beepsky/cheapsky/find_target()
	..()
	if(target)
		var/area/location = get_area(src)
		broadcast_security_hud_message("[src.name] has spotted level [threatlevel] suspect <b>[target]</b> in <b>[location]</b>", src)

/obj/machinery/bot/secbot/beepsky/cheapsky/process_bot()
	if (!summoned && (!target || target.gcDestroyed))
		target = null
		steps_per = initial_steps_per
		find_target()

	decay_oldtargets()

	if (target)		// make sure target exists
		if(!istype(target.loc, /turf))
			return
		if (Adjacent(target))		// if right next to perp

			var/arrest_message = pick(
				"Remember, crime doesn't pay!",
				"Use your words, not your fists!",
				"When in doubt, talk it out.",
				"The weed of crime bears bitter fruit.",
				"Just say \"No!\" to space drugs!",
				"Violence is never the answer.",
				"I'm not an officer, I'm a Security <em>monitor</em>.")
			src.speak(arrest_message)

			add_oldtarget(target.name, 6)
			target = null
			steps_per = initial_steps_per

			if(declare_arrests)
				var/area/location = get_area(src)
				broadcast_security_hud_message("[name] is scolding level [threatlevel] suspect <b>[target]</b> in <b>[location]</b>", src)
			anchored = 1
			return
		else // No next to target.
			if(prob(20))
				visible_message("<b>[src]</b> points at \the [target]!")
				var/chase_message = pick(
					"What would your mother think if she saw you now?",
					"You should be ashamed of yourself!",
					"Don't you know that crime hurts everyone?",
					"People like you are why this station can't have nice things!",
					"Running from Security is a crime, you know!",
					"Stop right there, criminal scum!",
					"Nobody breaks the law on my watch!")
				speak(chase_message)


/obj/machinery/bot/secbot/beepsky/cheapsky/explode()
	start_walk_to(0)
	src.visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	var/list/parts = list(/obj/item/clothing/head/cardborg, /obj/item/device/assembly/signaler, /obj/item/device/assembly/prox_sensor)
	parts.Remove(pick(parts))
	for(var/i in parts)
		new i(Tsec)
	spark(src)
	new /obj/effect/decal/cleanable/blood/oil(src.loc)
	qdel(src)

/obj/machinery/bot/secbot/beepsky/cheapsky
	name = "Officer Cheapsky"
	desc = "The budget cuts have hit Security the hardest."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "cheapsky0"
	icon_initial = "cheapsky"
	health = 15
	maxHealth = 15
//Cheapsky Construction

/obj/item/weapon/secbot_assembly/cheapsky
	name = "box/signaler assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "box_signaler"
	item_state = "syringe_kit"
	build_step = 0
	created_name = "Officer Cheapsky"

/obj/item/clothing/head/cardborg/attackby(var/obj/item/device/assembly/signaler/S, mob/user)
	..()
	if(!issignaler(S))
		return
	if(S.secured)
		user.create_in_hands(src, /obj/item/weapon/secbot_assembly/cheapsky, S, msg = "You add the signaler to \the [src].")

/obj/item/weapon/secbot_assembly/cheapsky/attackby(obj/item/weapon/W, mob/user)
	if(W.sharpness && W.sharpness_flags & SHARP_BLADE && (!src.build_step))
		src.build_step++
		src.overlays += image('icons/obj/aibots.dmi', "bs_hole")
		to_chat(user, "You cut a hole in \the [src]!")

	else if(isprox(W) && (src.build_step == 1))
		if(user.drop_item(W))
			to_chat(user, "You complete the Securitron! Beep boop.")
			var/obj/machinery/bot/secbot/beepsky/cheapsky/S = new /obj/machinery/bot/secbot/beepsky/cheapsky
			S.forceMove(get_turf(src))
			S.name = src.created_name
			qdel(W)
			qdel(src)

	else if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && src.loc != usr)
			return
		src.created_name = t


//Britsky

/obj/machinery/bot/secbot/beepsky/britsky
	name = "Officer Britsky"
	desc = "Ready to check your license."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "bsecbot0"
	icon_initial = "bsecbot"

	arrest_message = "Oi mate! You need a license for that!"

	weaponscheck = 1

	unsafe_weapons =list(
		/obj/item/weapon/gun,
		/obj/item/weapon/melee,
		/obj/item/toy/,
		/obj/item/ashtray,
		/obj/item/candle,
		/obj/item/weapon/bananapeel,
		/obj/item/weapon/soap,
		/obj/item/weapon/bikehorn,
		/obj/item/tool/wrench,
		/obj/item/tool/screwdriver,
		/obj/item/tool/wirecutters,
		/obj/item/tool/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/tool/solder,
		/obj/item/tool/scalpel,
		/obj/item/tool/surgicaldrill,
		/obj/item/tool/circular_saw,
		/obj/item/tool/bonesetter,
		/obj/item/weapon/match,
		/obj/item/weapon/lighter,
		/obj/item/weapon/kitchen,
		/obj/item/weapon/reagent_containers/pill
		)
	safe_weapons = null //no safe weapons for britsky

	baton_type = /obj/item/weapon/melee/classic_baton/
	secbot_assembly_type = /obj/item/weapon/secbot_assembly/britsky

//Britsky Construction

/obj/item/weapon/secbot_assembly/britsky
	name = "custodian signaler assembly"
	desc = "some sort of british assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "bhelmet_signaler"
	build_step = 0
	created_name = "Officer Britsky"


/obj/item/clothing/head/helmet/police/attackby(var/obj/item/device/assembly/signaler/S, mob/user)
	..()
	if(!issignaler(S))
		return
	if(S.secured)
		user.create_in_hands(src, /obj/item/weapon/secbot_assembly/britsky, S, msg = "You add the signaler to \the [src].")

/obj/item/weapon/secbot_assembly/britsky/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if((iswelder(W)) && (!src.build_step))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			src.build_step++
			src.overlays += image('icons/obj/aibots.dmi', "bhs_hole")
			to_chat(user, "You weld a hole in [src]!")

	else if(isprox(W) && (src.build_step == 1))
		if(user.drop_item(W))
			src.build_step++
			to_chat(user, "You add the prox sensor to [src]!")
			src.overlays += image('icons/obj/aibots.dmi', "bhs_eye")
			src.name = "helmet/signaler/prox sensor assembly"
			qdel(W)

	else if(((istype(W, /obj/item/robot_parts/l_arm)) || (istype(W, /obj/item/robot_parts/r_arm))) && (src.build_step == 2))
		if(user.drop_item(W))
			src.build_step++
			to_chat(user, "You add the robot arm to [src]!")
			src.name = "helmet/signaler/prox sensor/robot arm assembly"
			src.overlays += image('icons/obj/aibots.dmi', "bhs_arm")
			qdel(W)

	else if((istype(W, /obj/item/weapon/melee/classic_baton)) && (src.build_step >= 3))
		if(user.drop_item(W))
			src.build_step++
			to_chat(user, "You complete the Securitron! Beep boop.")
			var/obj/machinery/bot/secbot/beepsky/britsky/S = new /obj/machinery/bot/secbot/beepsky/britsky
			S.forceMove(get_turf(src))
			S.name = src.created_name
			W.forceMove(S)
			S.baton = W
			qdel(src)
