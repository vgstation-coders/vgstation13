//Cleanbot assembly
/obj/item/weapon/bucket_sensor
	desc = "It's a bucket. With a sensor attached."
	name = "proxy bucket"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "bucket_proxy"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = W_CLASS_MEDIUM
	flags = 0
	var/created_name = "Cleanbot"


//Cleanbot
//Patrols the station, looking for mess to clean
/obj/machinery/bot/cleanbot
	name = "Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "cleanbot0"
	icon_initial = "cleanbot"
	density = 0
	anchored = 0
	//weight = 1.0E7
	health = 25
	maxHealth = 25
	var/cleaning = 0
	var/screwloose = 0
	var/oddbutton = 0
	var/blood = 1
	var/crayon = 0
	var/list/blacklisted_targets = list()
	req_access = list(access_janitor)
	bot_flags = BOT_PATROL|BOT_BEACON|BOT_CONTROL
	auto_patrol = TRUE

	//for attack code
	var/coolingdown = FALSE
	var/attackcooldown = 5 SECONDS // for admin cancer
	locked = FALSE
	can_take_pai = TRUE
	commanding_radios = list(/obj/item/radio/integrated/signal/bot/janitor)

/obj/machinery/bot/cleanbot/New()
	..()
	cleanbot_list.Add(src)
	src.get_targets()
	src.icon_state = "[src.icon_initial][src.on]"
	src.botcard = new /obj/item/weapon/card/id(src)
	var/datum/job/janitor/J = new/datum/job/janitor
	src.botcard.access = J.get_access()

/obj/machinery/bot/cleanbot/Destroy()
	cleanbot_list.Remove(src)
	..()


/obj/machinery/bot/cleanbot/turn_on()
	. = ..()
	src.icon_state = "[src.icon_initial][src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/cleanbot/turn_off()
	..()
	if(!isnull(src.target) && isturf(target))
		var/turf/T = target
		T.targetted_by = null
	src.target = null
	old_targets = list()
	src.icon_state = "[src.icon_initial][src.on]"
	path = list()
	patrol_path = list()
	src.updateUsrDialog()

/obj/machinery/bot/cleanbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	usr.set_machine(src)
	interact(user)

/obj/machinery/bot/cleanbot/interact(mob/user as mob)
	var/dat
	dat += text({"
<TT><B>Automatic Station Cleaner v1.0</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]<BR>
Maintenance panel is [src.open ? "opened" : "closed"]"},
text("<A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A>"))
	if(!src.locked || issilicon(user))
		dat += text({"<BR>Cleans Blood: []<BR>"}, text("<A href='?src=\ref[src];operation=blood'>[src.blood ? "Yes" : "No"]</A>"))
		dat += text({"<BR>Cleans Crayon: []<BR>"}, text("<A href='?src=\ref[src];operation=crayon'>[src.crayon ? "Yes" : "No"]</A>"))
		dat += text({"<BR>Patrol station: []<BR>"}, text("<A href='?src=\ref[src];operation=patrol'>[src.auto_patrol ? "Yes" : "No"]</A>"))
	//	dat += text({"<BR>Beacon frequency: []<BR>"}, text("<A href='?src=\ref[src];operation=freq'>[src.beacon_freq]</A>"))
	if(src.open && !src.locked)
		dat += text({"
Odd looking screw twiddled: []<BR>
Weird button pressed: []"},
text("<A href='?src=\ref[src];operation=screw'>[src.screwloose ? "Yes" : "No"]</A>"),
text("<A href='?src=\ref[src];operation=oddbutton'>[src.oddbutton ? "Yes" : "No"]</A>"))

	user << browse("<HEAD><TITLE>Cleaner v1.0 controls</TITLE></HEAD>[dat]", "window=autocleaner")
	onclose(user, "autocleaner")
	return

/obj/machinery/bot/cleanbot/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	switch(href_list["operation"])
		if("start")
			if (src.on)
				turn_off()
			else
				turn_on()
		if(BLOOD)
			src.blood = !src.blood
			src.get_targets()
			src.updateUsrDialog()
		if("crayon")
			src.crayon = !src.crayon
			src.get_targets()
			src.updateUsrDialog()
		if("patrol")
			src.auto_patrol =!src.auto_patrol
			src.patrol_path = list()
			src.updateUsrDialog()
		if("freq")
			var/freq = text2num(input("Select frequency for  navigation beacons", "Frequnecy", num2text(beacon_freq / 10))) * 10
			if (freq > 0)
				src.beacon_freq = freq
			src.updateUsrDialog()
		if("screw")
			src.screwloose = !src.screwloose
			to_chat(usr, "<span class='notice>You twiddle the screw.</span>")
			src.updateUsrDialog()
		if("oddbutton")
			src.oddbutton = !src.oddbutton
			to_chat(usr, "<span class='notice'>You press the weird button.</span>")
			src.updateUsrDialog()

/obj/machinery/bot/cleanbot/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(allowed(usr) && !open && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] [src]'s behaviour controls.</span>")
			updateUsrDialog()
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			else if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='notice'>[src] doesn't seem to respect your authority.</span>")
	else
		return ..()

/obj/machinery/bot/cleanbot/emag_act(mob/user)
	..()
	if(open && !locked)
		if(user)
			to_chat(user, "<span class='notice'>The [src] buzzes and beeps.</span>")
		src.oddbutton = 1
		src.screwloose = 1

/obj/machinery/bot/cleanbot/can_path()
	return !cleaning

/obj/machinery/bot/cleanbot/process_bot()
	if(can_abandon_target())
		find_target()

	decay_oldtargets()

	if (!screwloose && !oddbutton && prob(5))
		visible_message("<span class='notice'>[src] makes an excited beeping booping sound!</span>")

	if (screwloose && prob(5))
		if (istype(loc, /turf/simulated))
			var/turf/simulated/T = loc
			T.wet(800)

	if(oddbutton && prob(5))
		visible_message("<span class='warning'>Something flies out of \the [src]! He seems to be acting oddly.</span>")
		add_oldtarget(get_turf(new /obj/effect/decal/cleanable/blood/gibs(loc)), -1) //So we don't target our own gib)

/obj/machinery/bot/cleanbot/target_selection()
	for(var/turf/T in view(7, src))
		if(istype(T, /turf/space))
			continue
		for(var/obj/effect/decal/cleanable/C in T)
			if(!is_type_in_list(C, blacklisted_targets) && !T.has_dense_content() && !T.targetted_by && !(T in old_targets))
				target = T
				add_oldtarget(T)
				T.targetted_by = src
				return

/obj/machinery/bot/cleanbot/at_path_target()
	clean(target)
	remove_oldtarget(target)
	target = null
	return ..()

/obj/machinery/bot/cleanbot/proc/get_targets() //This seems slightly wasteful, but it will only be called approximately once every six rounds so whatever
	blacklisted_targets = list()

	if(!src.blood)
		blacklisted_targets += (/obj/effect/decal/cleanable/blood)
	if(!src.crayon)
		blacklisted_targets += (/obj/effect/decal/cleanable/crayon)

/obj/machinery/bot/cleanbot/proc/clean(var/turf/target_turf)
	target = null
	anchored = 1
	icon_state = "[src.icon_initial]-c"
	visible_message("<span class='warning'>[src] begins to clean up the [target_turf].</span>")
	cleaning = 1

	if (istype(target_turf, /turf/simulated))
		var/turf/simulated/F = target_turf
		if (F.advanced_graffiti)
			F.overlays -= F.advanced_graffiti_overlay
			F.advanced_graffiti_overlay = null
			qdel(F.advanced_graffiti)

	for(var/obj/effect/decal/cleanable/C in target_turf)
		if(!(is_type_in_list(C,blacklisted_targets)))
			qdel(C)
			sleep(5)
	src.cleaning = 0
	icon_state = "[src.icon_initial][on]"
	anchored = 0

/obj/machinery/bot/cleanbot/explode()
	src.on = 0
	src.visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/reagent_containers/glass/bucket(Tsec)

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	spark(src)
	eject_integratedpai_if_present()
	qdel(src)

/obj/machinery/bot/cleanbot/return_status()
	if (cleaning)
		return "Cleaning"
	if (target)
		return "Moving"
	if (auto_patrol)
		return "Patrolling"
	return ..()


/obj/machinery/bot/cleanbot/roomba
	desc = "A small, plate-like cleaning robot. It looks quite concerned."
	icon_state = "roombot0"
	icon_initial = "roombot"
	var/armed = 0

/obj/machinery/bot/cleanbot/roomba/attackby(var/obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/kitchen/utensil/fork) && !armed && user.a_intent != I_HURT)
		if(user.drop_item(W))
			qdel(W)
			to_chat(user, "<span class='notice'>You attach \the [W] to \the [src]. It looks increasingly concerned about its current situation.</span>")
			armed++
	else if(istype(W, /obj/item/weapon/lighter) && armed == 1 && user.a_intent != I_HURT)
		if(user.drop_item(W))
			qdel(W)
			to_chat(user, "<span class='notice'>You attach \the [W] to \the [src]. It appears to roll its sensor in disappointment before carrying on with its work.</span>")
			armed++
			icon_state = "roombot_battle[on]"
			icon_initial = "roombot_battle"
	else if (istype(W, /obj/item/clothing/head/maidhat))
		var/obj/machinery/bot/cleanbot/roomba/meido/M = new(get_turf(src))

		if(name != initial(name))
			M.name = name
		else
			name = "maidbot"

		M.install_pai(eject_integratedpai_if_present())
		to_chat(user, "<span class='notice'>You attach \the [W] to \the [src]. It makes a soft booping noise and its light blinks excitedly for a moment.</span>")
		qdel(src)
	else
		. = ..()

/obj/machinery/bot/cleanbot/roomba/Crossed(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		annoy(L)
	..()

/obj/machinery/bot/cleanbot/proc/attack_cooldown()
	coolingdown = TRUE
	spawn(attackcooldown)
		coolingdown = FALSE

/obj/machinery/bot/cleanbot/roomba/proc/annoy(var/mob/living/L)
	if(coolingdown == FALSE)
		switch(armed)
			if(1)
				L.visible_message("<span class = 'warning'>\The [src] [pick("prongs","pokes","pricks")] \the [L]", "<span class = 'warning'>The little shit, \the [src], stabs you with its attached fork!</span>")
				var/damage = rand(1,5)
				L.adjustBruteLoss(damage)
			if(2)
				L.visible_message("<span class = 'warning'>\The [src] prongs and singes \the [L]</span>", "<span class = 'warning'>The little shit, \the [src], singes and stabs you with its attached fork and lighter!</span>")
				var/damage = rand(3,12)
				L.adjustBruteLoss(damage)
				L.adjustFireLoss(damage/2)
		attack_cooldown()

/obj/item/weapon/bucket_sensor/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		if(user.drop_item(W))
			qdel(W)
			var/turf/T = get_turf(src.loc)
			var/obj/machinery/bot/cleanbot/A = new /obj/machinery/bot/cleanbot(T)
			A.name = src.created_name
			to_chat(user, "<span class='notice'>You add the robot arm to the bucket and sensor assembly. Beep boop!</span>")
			user.drop_from_inventory(src)
			qdel(src)

	else if(istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = W
		if(M.amount >= 5)
			if(user.drop_item(M))
				M.use(5)
				var/turf/T = get_turf(loc)
				var/obj/machinery/bot/cleanbot/A = new /obj/machinery/bot/cleanbot/roomba(T)
				A.name = created_name
				to_chat(user, "<span class='notice'>You add the metal sheets onto and around the bucket and sensor assembly. Beep boop!</span>")
				user.drop_from_inventory(src)
				qdel(src)

	else if (istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return
		src.created_name = t

/*
 *	pAI SHIT, it uses the pAI framework in objs.dm. Check that code for further information
*/

/obj/machinery/bot/cleanbot/on_integrated_pai_click(mob/living/silicon/pai/user, atom/target)
	if(!Adjacent(target))
		return
	if(istype(target,/obj/effect/decal/cleanable))
		user.simple_message("<span class='notice'>You scrub \the [target.name] out.</span>",
			"<span class='warning'>You destroy [pick("an artwork","a valuable artwork","a rare piece of art","a rare piece of modern art")].</span>")
		qdel(target)

	else if(istype(target,/turf/simulated))
		var/turf/simulated/T = target
		var/list/cleanables = list()

		for(var/obj/effect/decal/cleanable/CC in T)
			if(!istype(CC) || !CC)
				continue
			cleanables += CC

		for(var/obj/effect/decal/cleanable/CC in get_turf(user)) //Get all nearby decals drawn on this wall and erase them
			if(CC.on_wall == target)
				cleanables += CC

		if (istype(T, /turf/simulated/floor))
			var/turf/simulated/floor/F = T
			F.overlays -= F.advanced_graffiti_overlay
			F.advanced_graffiti_overlay = null
			qdel(F.advanced_graffiti)
			cleanables += "advanced graffiti"

		if(!cleanables.len)
			user.simple_message("<span class='notice'>You fail to clean anything.</span>",
				"<span class='notice'>There is nothing for you to vandalize.</span>")
			return
		cleanables = shuffle(cleanables)
		var/obj/effect/decal/cleanable/C
		for(var/obj/effect/decal/cleanable/d in cleanables)
			if(d && istype(d))
				C = d
				break
		user.simple_message("<span class='notice'>You scrub \the [C.name] out.</span>",
			"<span class='warning'>You destroy [pick("an artwork","a valuable artwork","a rare piece of art","a rare piece of modern art")].</span>")
		qdel(C)
	else
		user.simple_message("<span class='notice'>You clean \the [target.name].</span>",
			"<span class='warning'>You [pick("deface","ruin","stain")] \the [target.name].</span>")
		target.clean_blood()
	return

/obj/machinery/bot/cleanbot/state_controls_pai(obj/item/device/paicard/P)
	if(..())
		to_chat(P.pai, "<span class='info'><b>Welcome to your new body. Remember: you're a pAI inside a cleanbot, so get cleaning.</b></span>")
		to_chat(P.pai, "<span class='info'>- Click on something: Scrub it clean.</span>")
		to_chat(P.pai, "<span class='info'>If you want to exit the cleanbot, somebody has to right-click you and press 'Remove pAI'.</span>")

/obj/machinery/bot/cleanbot/roomba/meido
	name = "maidbot"
	desc = "A small, plate-like cleaning robot. It looks quite concerned. This one has a frilly headband attached to the top."
	icon_state = "maidbot0"
	icon_initial = "maidbot"
	armed = 0

/obj/machinery/bot/cleanbot/roomba/meido/attackby(var/obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/kitchen/utensil/fork) || istype(W, /obj/item/weapon/lighter))
		to_chat(user, "<span class='notice'>\The [src] buzzes and recoils at \the [W]. Perhaps it would prefer something more refined?</span>")
		return
	else if (istype(W, /obj/item/clothing/head/maidhat))
		to_chat(user, "<span class='notice'>\The [src] is already wearing one of those!</span>")
		return
	else if(W.type == /obj/item/weapon/kitchen/utensil/knife/large && !armed && user.a_intent != I_HURT)
		if(user.drop_item(W))
			qdel(W)
			to_chat(user, "<span class='notice'>\the [src] extends a tiny arm from a hidden compartment and grasps \the [W]. Its light blinks excitedly for a moment before returning to normal.</span>")
			armed++
			icon_state = "maidbot_battle[on]"
			icon_initial = "maidbot_battle"
	else
		. = ..()

/obj/machinery/bot/cleanbot/roomba/meido/annoy(var/mob/living/L)
	if(!coolingdown && armed)
		L.visible_message("<span class = 'warning'>\The [src] [pick("jabs","stabs","pokes")] \the [L]", "<span class = 'warning'>The little shit, \the [src], stabs you with its knife!</span>")
		L.adjustBruteLoss(rand(4,8))
	attack_cooldown()
