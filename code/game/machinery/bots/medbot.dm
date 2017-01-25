//MEDBOT
//MEDBOT PATHFINDING
//MEDBOT ASSEMBLY
#define INJECTION_TIME 30

/obj/machinery/bot/medbot
	name = "Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed. It has a slot for pAIs."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "medibot0"
	icon_initial = "medibot"
	density = 0
	anchored = 0
	health = 20
	maxhealth = 20
	req_access =list(access_medical)
	can_take_pai = TRUE
	var/stunned = 0 //It can be stunned by tasers. Delicate circuits.
//var/emagged = 0
	var/list/botcard_access = list(access_medical)
	var/obj/item/weapon/reagent_containers/glass/reagent_glass = null //Can be set to draw from this for reagents.
	var/skin = null //Set to "tox", "ointment" or "o2" for the other two firstaid kits.
	var/frustration = 0
	var/path[] = new()
	var/mob/living/carbon/patient = null
	var/mob/living/carbon/oldpatient = null
	var/oldloc = null
	var/last_found = 0
	var/last_newpatient_speak = 0 //Don't spam the "HEY I'M COMING" messages
	var/currently_healing = 0
	var/injection_amount = 15 //How much reagent do we inject at a time?
	var/heal_threshold = 10 //Start healing when they have this much damage in a category
	var/use_beaker = 0 //Use reagents in beaker instead of default treatment agents.
	//Setting which reagents to use to treat what by default. By id.
	var/treatment_brute = TRICORDRAZINE
	var/treatment_oxy = TRICORDRAZINE
	var/treatment_fire = TRICORDRAZINE
	var/treatment_tox = TRICORDRAZINE
	var/treatment_virus = SPACEACILLIN
	var/declare_treatment = 0 //When attempting to treat a patient, should it notify everyone wearing medhuds?
	var/shut_up = 0 //self explanatory :)
	var/declare_crit = 1 //If active, the bot will transmit a critical patient alert to MedHUD users.
	var/declare_cooldown = 0 //Prevents spam of critical patient alerts.
	var/pai_analyze_mode = FALSE //Used to switch between injecting people or analyzing them (for pAIs)
	var/reagent_id = null

	bot_type = MED_BOT

/obj/machinery/bot/medbot/mysterious
	name = "Mysterious Medibot"
	desc = "International Medibot of mystery."
	skin = "bezerk"
	treatment_oxy = DEXALINP
	treatment_brute = BICARIDINE
	treatment_fire = KELOTANE
	treatment_tox = ANTI_TOXIN

/obj/item/weapon/firstaid_arm_assembly
	name = "first aid/robot arm assembly"
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "firstaid_arm"
	var/build_step = 0
	var/created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	w_class = W_CLASS_MEDIUM

	New()
		..()
		spawn(5)
			if(src.skin)
				src.overlays += image('icons/obj/aibots.dmi', "kit_skin_[src.skin]")


/obj/machinery/bot/medbot/New()
	..()
	src.icon_state = "[src.icon_initial][src.on]"
	spawn(4)
		if(src.skin)
			src.overlays += image('icons/obj/aibots.dmi', "medskin_[src.skin]")
			switch(src.skin)
				if("tox")
					treatment_tox = ANTI_TOXIN
				if("ointment")
					treatment_fire = KELOTANE
				if("o2")
					treatment_oxy = DEXALIN
		else
			treatment_brute = BICARIDINE
		src.botcard = new /obj/item/weapon/card/id(src)
		if(isnull(src.botcard_access) || (src.botcard_access.len < 1))
			var/datum/job/doctor/J = new/datum/job/doctor
			src.botcard.access = J.get_access()
		else
			src.botcard.access = src.botcard_access

/obj/machinery/bot/medbot/turn_on()
	. = ..()
	src.icon_state = "[src.icon_initial][src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/medbot/turn_off()
	..()
	src.patient = null
	src.oldpatient = null
	src.oldloc = null
	src.path = new()
	src.currently_healing = 0
	src.last_found = world.time
	src.icon_state = "[src.icon_initial][src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/medbot/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/bot/medbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	var/dat
	dat += "<TT><B>Automatic Medical Unit v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [src.open ? "opened" : "closed"]<BR>"
	dat += "Beaker: "
	if (src.reagent_glass)
		dat += "<A href='?src=\ref[src];eject=1'>Loaded \[[src.reagent_glass.reagents.total_volume]/[src.reagent_glass.reagents.maximum_volume]\]</a>"
	else
		dat += "None Loaded"
	dat += "<br>Behaviour controls are [src.locked ? "locked" : "unlocked"]<hr>"
	if(!src.locked || issilicon(user))
		dat += "<TT>Healing Threshold: "
		dat += "<a href='?src=\ref[src];adj_threshold=-10'>--</a> "
		dat += "<a href='?src=\ref[src];adj_threshold=-5'>-</a> "
		dat += "[src.heal_threshold] "
		dat += "<a href='?src=\ref[src];adj_threshold=5'>+</a> "
		dat += "<a href='?src=\ref[src];adj_threshold=10'>++</a>"
		dat += "</TT><br>"

		dat += "<TT>Injection Level: "
		dat += "<a href='?src=\ref[src];adj_inject=-5'>-</a> "
		dat += "[src.injection_amount] "
		dat += "<a href='?src=\ref[src];adj_inject=5'>+</a> "
		dat += "</TT><br>"

		dat += "Reagent Source: "
		dat += "<a href='?src=\ref[src];use_beaker=1'>[src.use_beaker ? "Loaded Beaker (When available)" : "Internal Synthesizer"]</a><br>"

		dat += "Treatment report is [src.declare_treatment ? "on" : "off"]. <a href='?src=\ref[src];declaretreatment=[1]'>Toggle</a><br>"

		dat += "The speaker switch is [src.shut_up ? "off" : "on"]. <a href='?src=\ref[src];togglevoice=[1]'>Toggle</a><br>"

		dat += "Critical Patient Alerts: <a href='?src=\ref[src];critalerts=1'>[declare_crit ? "Yes" : "No"]</a><br>"

	user << browse("<HEAD><TITLE>Medibot v1.0 controls</TITLE></HEAD>[dat]", "window=automed")
	onclose(user, "automed")
	return

/obj/machinery/bot/medbot/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if ((href_list["power"]) && (src.allowed(usr)))
		if (src.on)
			turn_off()
		else
			turn_on()

	else if((href_list["adj_threshold"]) && (!src.locked || issilicon(usr)))
		var/adjust_num = text2num(href_list["adj_threshold"])
		src.heal_threshold += adjust_num
		if(src.heal_threshold < 5)
			src.heal_threshold = 5
		if(src.heal_threshold > 75)
			src.heal_threshold = 75

	else if((href_list["adj_inject"]) && (!src.locked || issilicon(usr)))
		var/adjust_num = text2num(href_list["adj_inject"])
		src.injection_amount += adjust_num
		if(src.injection_amount < 5)
			src.injection_amount = 5
		if(src.injection_amount > 15)
			src.injection_amount = 15

	else if((href_list["use_beaker"]) && (!src.locked || issilicon(usr)))
		src.use_beaker = !src.use_beaker

	else if (href_list["eject"] && (!isnull(src.reagent_glass)))
		if(!src.locked)
			src.reagent_glass.forceMove(get_turf(src))
			src.reagent_glass = null
		else
			to_chat(usr, "<span class='notice'>You cannot eject the beaker because the panel is locked.</span>")

	else if ((href_list["togglevoice"]) && (!src.locked || issilicon(usr)))
		src.shut_up = !src.shut_up

	else if ((href_list["declaretreatment"]) && (!src.locked || issilicon(usr)))
		src.declare_treatment = !src.declare_treatment

	else if ((href_list["critalerts"]) && (!locked || issilicon(usr)))
		declare_crit = !declare_crit

	src.updateUsrDialog()
	return

/obj/machinery/bot/medbot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user) && !open && !emagged)
			src.locked = !src.locked
			to_chat(user, "<span class='notice'>Controls are now [src.locked ? "locked." : "unlocked."]</span>")
			src.updateUsrDialog()
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

	else if (istype(W, /obj/item/weapon/reagent_containers/glass))
		if(src.locked)
			to_chat(user, "<span class='notice'>You cannot insert a beaker because the panel is locked.</span>")
			return
		if(!isnull(src.reagent_glass))
			to_chat(user, "<span class='notice'>There is already a beaker loaded.</span>")
			return
		if(W.w_class > W_CLASS_SMALL)
			to_chat(user, "<span class='warning'>\The [W] is too big to fit.</span>")
			return

		if(user.drop_item(W, src))
			src.reagent_glass = W
			to_chat(user, "<span class='notice'>You insert [W].</span>")
			investigation_log(I_CHEMS, "was loaded with \a [W] by [key_name(user)], containing [W.reagents.get_reagent_ids(1)]")
			src.updateUsrDialog()
			return

	else
		..()
		if (health < maxhealth && !isscrewdriver(W) && W.force)
			step_to(src, (get_step_away(src,user)))

/obj/machinery/bot/medbot/Emag(mob/user as mob)
	..()
	if(open && !locked)
		declare_crit = 0
		if(user)
			to_chat(user, "<span class='warning'>You short out [src]'s reagent synthesis circuits.</span>")
		spawn(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("<span class='danger'>[src] buzzes oddly!</span>", 1)
		flick("medibot_spark", src)
		src.patient = null
		if(user)
			src.oldpatient = user
		src.currently_healing = 0
		src.last_found = world.time
		src.anchored = 0
		src.emagged = 2
		src.on = 1
		src.icon_state = "[src.icon_initial][src.on]"

/obj/machinery/bot/medbot/process()
	//set background = 1

	if(integratedpai)
		return

	if(!src.on)
		src.stunned = 0
		return

	if(src.stunned)
		src.icon_state = "[src.icon_initial]a"
		src.stunned--

		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0

		if(src.stunned <= 0)
			src.icon_state = "[src.icon_initial][src.on]"
			src.stunned = 0
		return

	if(src.frustration > 8)
		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0
		src.last_found = world.time
		src.path = new()

	if(!src.patient)
		if(!src.shut_up && prob(1))
			var/message = pick("Radar, put a mask on!","There's always a catch, and it's the best there is.","I knew it, I should've been a plastic surgeon.","What kind of medbay is this? Everyone's dropping like dead flies.","Delicious!")
			src.speak(message)

		for (var/mob/living/carbon/C in view(7,src)) //Time to find a patient!
			if ((C.stat == 2) || !istype(C, /mob/living/carbon/human))
				continue

			if ((C == src.oldpatient) && (world.time < src.last_found + 100))
				continue

			if(src.assess_patient(C))
				src.patient = C
				src.oldpatient = C
				src.last_found = world.time
				spawn(0)
					if((src.last_newpatient_speak + 100) < world.time) //Don't spam these messages!
						var/message = pick("Hey, you! Hold on, I'm coming.","Wait! I want to help!","You appear to be injured!")
						src.speak(message)
						src.last_newpatient_speak = world.time
						if(declare_treatment)
							var/area/location = get_area(src)
							broadcast_medical_hud_message("[src.name] is treating <b>[C]</b> in <b>[location]</b>", src)
					src.visible_message("<b>[src]</b> points at [C.name]!")
				break
			else
				continue

	if(!src.path)
		src.path = new()
	if(src.patient && (get_dist(src,src.patient) <= 1))
		if(!src.currently_healing)
			src.currently_healing = 1
			src.frustration = 0
			src.medicate_patient(src.patient)
		return

	else if(src.patient && (src.path.len) && (get_dist(src.patient,src.path[src.path.len]) > 2))
		src.path = new()
		src.currently_healing = 0
		src.last_found = world.time

	if(src.patient && src.path.len == 0 && (get_dist(src,src.patient) > 1))
		spawn(0)
			src.path = AStar(src.loc, get_turf(src.patient), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 30,id=botcard)
			if (!path)
				path = list()
			if(src.path.len == 0)
				src.oldpatient = src.patient
				src.patient = null
				src.currently_healing = 0
				src.last_found = world.time
		return

	if(src.path.len > 0 && src.patient)
		step_to(src, src.path[1])
		src.path -= src.path[1]
		spawn(3)
			if(src.path.len)
				step_to(src, src.path[1])
				src.path -= src.path[1]

	if(src.path.len > 8 && src.patient)
		src.frustration++

	return

/obj/machinery/bot/medbot/proc/assess_patient(mob/living/carbon/C as mob)
	//Time to see if they need medical help!
	if(C.stat == 2)
		return 0 //welp too late for them!

	if(C.suiciding)
		return 0 //Kevorkian school of robotic medical assistants.

	if(src.emagged == 2) //Everyone needs our medicine. (Our medicine is toxins)
		return 1

	if(declare_crit && C.health <= 0) //Critical condition! Call for help!
		declare()

	//If they're injured, we're using a beaker, and don't have one of our WONDERCHEMS.
	if((src.reagent_glass) && (src.use_beaker) && ((C.getBruteLoss() >= heal_threshold) || (C.getToxLoss() >= heal_threshold) || (C.getToxLoss() >= heal_threshold) || (C.getOxyLoss() >= (heal_threshold + 15))))
		for(var/datum/reagent/R in src.reagent_glass.reagents.reagent_list)
			if(!C.reagents.has_reagent(R))
				return 1
			continue

	//They're injured enough for it!
	if((C.getBruteLoss() >= heal_threshold) && (!C.reagents.has_reagent(src.treatment_brute)))
		return 1 //If they're already medicated don't bother!

	if((C.getOxyLoss() >= (15 + heal_threshold)) && (!C.reagents.has_reagent(src.treatment_oxy)))
		return 1

	if((C.getFireLoss() >= heal_threshold) && (!C.reagents.has_reagent(src.treatment_fire)))
		return 1

	if((C.getToxLoss() >= heal_threshold) && (!C.reagents.has_reagent(src.treatment_tox)))
		return 1


	for(var/datum/disease/D in C.viruses)
		if((D.stage > 1) || (D.spread_type == AIRBORNE))

			if (!C.reagents.has_reagent(src.treatment_virus))
				return 1 //STOP DISEASE FOREVER

	return 0

/obj/machinery/bot/medbot/proc/medicate_patient(mob/living/carbon/C as mob)
	if(!src.on)
		return

	if(!istype(C))
		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0
		src.last_found = world.time
		return

	if(C.stat == 2)
		var/death_message = pick("No! NO!","Live, damnit! LIVE!","I...I've never lost a patient before. Not today, I mean.")
		src.speak(death_message)
		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0
		src.last_found = world.time
		return

	//Use whatever is inside the loaded beaker. If there is one.
	if((src.use_beaker) && (src.reagent_glass) && (src.reagent_glass.reagents.total_volume))
		reagent_id = "internal_beaker"

	if(src.emagged == 2) //Emagged! Time to poison everybody.
		reagent_id = TOXIN

	var/virus = 0
	for(var/datum/disease/D in C.viruses)
		virus = 1

	if (!reagent_id && (virus))
		if(!C.reagents.has_reagent(src.treatment_virus))
			reagent_id = src.treatment_virus

	if (!reagent_id && (C.getBruteLoss() >= heal_threshold))
		if(!C.reagents.has_reagent(src.treatment_brute))
			reagent_id = src.treatment_brute

	if (!reagent_id && (C.getOxyLoss() >= (15 + heal_threshold)))
		if(!C.reagents.has_reagent(src.treatment_oxy))
			reagent_id = src.treatment_oxy

	if (!reagent_id && (C.getFireLoss() >= heal_threshold))
		if(!C.reagents.has_reagent(src.treatment_fire))
			reagent_id = src.treatment_fire

	if (!reagent_id && (C.getToxLoss() >= heal_threshold))
		if(!C.reagents.has_reagent(src.treatment_tox))
			reagent_id = src.treatment_tox

	if(!reagent_id) //If they don't need any of that they're probably cured!
		oldpatient = src.patient
		patient = null
		currently_healing = 0
		last_found = world.time
		var/message = pick("All patched up!","An apple a day keeps me away.","Feel better soon!")
		src.speak(message)
		return
	else
		src.icon_state = "[src.icon_initial]s"
		visible_message("<span class='danger'>[src] is trying to inject [patient]!</span>")

		if(integratedpai)
			if(do_after(integratedpai.pai, src, INJECTION_TIME))
				inject_patient()
		else
			spawn(INJECTION_TIME)
				inject_patient()

//	src.speak(reagent_id)
	reagent_id = null
	return

/obj/machinery/bot/medbot/proc/inject_patient()
	if ((get_dist(src, src.patient) <= 1) && (src.on))
		if((reagent_id == "internal_beaker") && (src.reagent_glass) && (src.reagent_glass.reagents.total_volume))
			src.reagent_glass.reagents.trans_to(src.patient,src.injection_amount) //Inject from beaker instead.
			src.reagent_glass.reagents.reaction(src.patient, 2)
		else
			src.patient.reagents.add_reagent(reagent_id,src.injection_amount)
		visible_message("<span class='danger'>[src] injects [src.patient] with the syringe!</span>")

	src.icon_state = "[src.icon_initial][src.on]"
	src.currently_healing = 0
	return

/obj/machinery/bot/medbot/proc/speak(var/message)
	if((!src.on) || (!message))
		return
	visible_message("<b>[src]</b> beeps, \"[message]\"",\
		drugged_message="<b>[src]</b> beeps, \"[pick("FEED ME HUMANS","LET THE BLOOD FLOW","BLOOD FOR THE BLOOD GOD","I SPREAD DEATH AND DESTRUCTION","EXTERMINATE","I HATE YOU!","SURRENDER TO YOUR MACHINE OVERLORDS","FEED ME SHITTERS")]\"")
	return

/obj/machinery/bot/medbot/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.flag == "taser")
		src.stunned = min(stunned+10,20)
	..()

/obj/machinery/bot/medbot/explode()
	src.on = 0
	visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/storage/firstaid(Tsec)
	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/device/healthanalyzer(Tsec)

	if(src.reagent_glass)
		src.reagent_glass.forceMove(Tsec)
		src.reagent_glass = null

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	eject_integratedpai_if_present()
	qdel(src)
	return

/obj/machinery/bot/medbot/Bump(M as mob|obj) //Leave no door unopened!
	if ((istype(M, /obj/machinery/door)) && (!isnull(src.botcard)))
		var/obj/machinery/door/D = M
		if (!istype(D, /obj/machinery/door/firedoor) && D.check_access(src.botcard))
			D.open()
			src.frustration = 0
	else if ((istype(M, /mob/living/)) && (!src.anchored))
		src.forceMove(M:loc)
		src.frustration = 0
	return

/* terrible
/obj/machinery/bot/medbot/Bumped(atom/movable/M as mob|obj)
	spawn(0)
		if (M)
			var/turf/T = get_turf(src)
			M:forceMove(T)
*/

/*
 *	Pathfinding procs, allow the medibot to path through doors it has access to.
 */

//Pretty ugh
/*
/turf/proc/AdjacentTurfsAllowMedAccess()
	var/L[] = new()
	for(var/turf/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindowNonDoor(t,get_access("Medical Doctor")))
				L.Add(t)
	return L


//It isn't blocked if we can open it, man.
/proc/TurfBlockedNonWindowNonDoor(turf/loc, var/list/access)
	for(var/obj/O in loc)
		if(O.density && !istype(O, /obj/structure/window) && !istype(O, /obj/machinery/door))
			return 1

		if (O.density && (istype(O, /obj/machinery/door)) && (access.len))
			var/obj/machinery/door/D = O
			for(var/req in D.req_access)
				if(!(req in access)) //doesn't have this access
					return 1

	return 0
*/

/*
 *	Medbot Assembly -- Can be made out of all three medkits.
 */

/obj/item/weapon/storage/firstaid/attackby(var/obj/item/robot_parts/S, mob/user as mob)

	if ((!istype(S, /obj/item/robot_parts/l_arm)) && (!istype(S, /obj/item/robot_parts/r_arm)))
		. = ..()
		return

	//Making a medibot!
	if(src.contents.len >= 1)
		to_chat(user, "<span class='notice'>You need to empty [src] out first.</span>")
		return

	var/obj/item/weapon/firstaid_arm_assembly/A = new /obj/item/weapon/firstaid_arm_assembly
	if(istype(src,/obj/item/weapon/storage/firstaid/fire))
		A.skin = "ointment"
	else if(istype(src,/obj/item/weapon/storage/firstaid/toxin))
		A.skin = "tox"
	else if(istype(src,/obj/item/weapon/storage/firstaid/o2))
		A.skin = "o2"

	qdel(S)
	S = null
	user.put_in_hands(A)
	to_chat(user, "<span class='notice'>You add the robot arm to the first aid kit.</span>")
	user.drop_from_inventory(src)
	qdel(src)


/obj/item/weapon/firstaid_arm_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return
		src.created_name = t
	else
		switch(build_step)
			if(0)
				if(istype(W, /obj/item/device/healthanalyzer))
					if(user.drop_item(W))
						qdel(W)
						src.build_step++
						to_chat(user, "<span class='notice'>You add the health sensor to [src].</span>")
						src.name = "First aid/robot arm/health analyzer assembly"
						src.overlays += image('icons/obj/aibots.dmi', "na_scanner")

			if(1)
				if(isprox(W))
					if(user.drop_item(W))
						qdel(W)
						src.build_step++
						to_chat(user, "<span class='notice'>You complete the Medibot! Beep boop.</span>")
						var/turf/T = get_turf(src)
						var/obj/machinery/bot/medbot/S = new /obj/machinery/bot/medbot(T)
						S.skin = src.skin
						S.name = src.created_name
						user.drop_from_inventory(src)
						qdel(src)


/obj/machinery/bot/medbot/declare()
	if(declare_cooldown)
		return
	var/area/location = get_area(src)
	declare_message = "<span class='info'>[bicon(src)] Medical emergency! A patient is in critical condition at [location]!</span>"
	visible_message("<span class='info'>[bicon(src)] Medical emergency! A patient is in critical condition at [location]!</span>")
	..()
	declare_cooldown = 1
	spawn(100) //Ten seconds
		declare_cooldown = 0

/*
 *	pAI SHIT, it uses the pAI framework in objs.dm. Check that code for further information
*/

/obj/machinery/bot/medbot/getpAIMovementDelay()
	return 1

/obj/machinery/bot/medbot/pAImove(mob/living/silicon/pai/user, dir)
	if(!on)
		return
	if(!..())
		return
	step(src, dir)

/obj/machinery/bot/medbot/on_integrated_pai_click(mob/living/silicon/pai/user, mob/living/carbon/A)
	if(!Adjacent(A))
		return

	patient = A //Needed because medicate_patient doesn't set up one.

	if(pai_analyze_mode)
		if(istype(A, /mob/living/carbon))
			healthanalyze(A, user, 1)
	else
		medicate_patient(A)

/obj/machinery/bot/medbot/dropkey_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI uses the drop hotkey
	declare()

/obj/machinery/bot/medbot/swapkey_integrated_pai(mob/living/silicon/pai/user)	//called when integrated pAI uses the swap_hand() hotkey
	pai_analyze_mode ? to_chat(user, "<span class='info'>You switch to inject mode.</span>") : to_chat(user, "<span class='info'>You switch to analyze mode.</span>")
	pai_analyze_mode = !pai_analyze_mode

/obj/machinery/bot/medbot/state_controls_pai(obj/item/device/paicard/P)
	if(..())
		to_chat(P.pai, "<span class='info'><b>Welcome to your new body. Remember: you're a pAI inside a medbot, not a medbot.</b></span>")
		to_chat(P.pai, "<span class='info'>It is highly recommended to download the Medical Supplement from the pAI software interface as it gives you MedHUD.</span>")
		to_chat(P.pai, "<span class='info'>Your controls are:</span>")
		to_chat(P.pai, "<span class='info'>- (Q) Drop hotkey: You state there's a patient in critical condition</span>")
		to_chat(P.pai, "<span class='info'>- (X) Swap hands:  You switch to inject or analyze mode.</span>")
		to_chat(P.pai, "<span class='info'>- Click on somebody: Depending on your mode, you inject or analyze a person.</span>")
		to_chat(P.pai, "<span class='info'>What you inject depends on the medbot's configuration. You can't modify it</span>")
		to_chat(P.pai, "<span class='info'>If you want to exit the medbot, somebody has to right-click you and press 'Remove pAI'.</span>")

#undefine
