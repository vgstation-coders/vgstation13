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
	maxhealth = 25
	var/cleaning = 0
	var/screwloose = 0
	var/oddbutton = 0
	var/blood = 1
	var/crayon = 0
	var/list/blacklisted_targets = list()
	var/turf/target
	var/turf/oldtarget
	var/oldloc = null
	req_access = list(access_janitor)
	var/beacon_freq = 1445		// navigation beacon frequency
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/should_patrol
	var/next_dest
	var/next_dest_loc

/obj/machinery/bot/cleanbot/New()
	..()
	cleanbot_list.Add(src)
	src.get_targets()
	src.icon_state = "[src.icon_initial][src.on]"

	should_patrol = 1

	src.botcard = new /obj/item/weapon/card/id(src)
	var/datum/job/janitor/J = new/datum/job/janitor
	src.botcard.access = J.get_access()

	src.locked = 0 // Start unlocked so roboticist can set them to patrol.

	if(radio_controller)
		radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)

/obj/machinery/bot/cleanbot/Destroy()
	cleanbot_list.Remove(src)
	..()


/obj/machinery/bot/cleanbot/turn_on()
	. = ..()
	src.icon_state = "[src.icon_initial][src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/cleanbot/turn_off()
	..()
	if(!isnull(src.target))
		target.targetted_by = null
	src.target = null
	src.oldtarget = null
	src.oldloc = null
	src.icon_state = "[src.icon_initial][src.on]"
	src.path = new()
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
		dat += text({"<BR>Patrol station: []<BR>"}, text("<A href='?src=\ref[src];operation=patrol'>[src.should_patrol ? "Yes" : "No"]</A>"))
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
			src.should_patrol =!src.should_patrol
			drop_astar_path(src)
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

/obj/machinery/bot/cleanbot/Emag(mob/user as mob)
	..()
	if(open && !locked)
		if(user)
			to_chat(user, "<span class='notice'>The [src] buzzes and beeps.</span>")
		src.oddbutton = 1
		src.screwloose = 1

/obj/machinery/bot/cleanbot/process()
	//set background = 1

	if(!src.on)
		return
	if(src.cleaning)
		return

	if(!src.screwloose && !src.oddbutton && prob(5))
		visible_message("[src] makes an excited beeping booping sound!")

	if(src.screwloose && prob(5))
		if(istype(loc,/turf/simulated))
			var/turf/simulated/T = src.loc
			T.wet(800)
	if(src.oddbutton && prob(5))
		visible_message("Something flies out of [src]. He seems to be acting oddly.")
		var/obj/effect/decal/cleanable/blood/gibs/gib = getFromPool(/obj/effect/decal/cleanable/blood/gibs, src.loc)
		gib.New(gib.loc)
		//gib.streak(list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		src.oldtarget = get_turf(gib)
	if(!src.target || src.target == null)
		for (var/turf/T in view(7,src))
			if(target)
				break
			if(istype(T,/turf/space))
				continue
			for(var/obj/effect/decal/cleanable/sickfilth in T.contents)
				if(sickfilth && !(is_type_in_list(sickfilth, blacklisted_targets)))
					if(!T.targetted_by && T!=oldtarget)
						oldtarget = T								 // or if it is but the bot is gone.
						target = T									 // and it's stuff we clean?  Clean it.
						T.targetted_by = src	// Claim the messy tile we are targeting.
						break


/obj/machinery/bot/cleanbot/receive_signal(datum/signal/signal)
	var/recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return

	var/dist = get_dist(src, signal.source.loc)
	if (dist < closest_dist && signal.source.loc != src.loc)
		closest_dist = dist
		closest_loc = signal.source.loc
		next_dest = signal.data["next_patrol"]

	if (recv == next_dest)
		next_dest_loc = signal.source.loc
		next_dest = signal.data["next_patrol"]

/obj/machinery/bot/cleanbot/proc/get_targets() //This seems slightly wasteful, but it will only be called approximately once every six rounds so whatever
	blacklisted_targets = list()

	if(!src.blood)
		blacklisted_targets += (/obj/effect/decal/cleanable/blood)
	if(!src.crayon)
		blacklisted_targets += (/obj/effect/decal/cleanable/crayon)

/obj/machinery/bot/cleanbot/proc/clean(var/turf/target)
	anchored = 1
	icon_state = "[src.icon_initial]-c"
	visible_message("<span class='warning'>[src] begins to clean up the [target].</span>")
	cleaning = 1
	spawn(2 SECONDS)
		for(var/obj/effect/decal/cleanable/C in target)
			if(!(is_type_in_list(C,blacklisted_targets)))
				spawn(5)
				qdel(C)
		src.cleaning = 0
		icon_state = "[src.icon_initial][on]"
		anchored = 0
		target = null

/obj/machinery/bot/cleanbot/explode()
	src.on = 0
	src.visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/reagent_containers/glass/bucket(Tsec)

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	spark(src)
	qdel(src)
	return


/obj/machinery/bot/cleanbot/roomba
	desc = "A small, plate-like cleaning robot. It looks quite concerned."
	icon_state = "roombot0"
	icon_initial = "roombot"
	var/armed = 0

/obj/machinery/bot/cleanbot/roomba/attackby(var/obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchen/utensil/fork) && !armed && user.a_intent != I_HURT)
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
	else
		. = ..()

/obj/machinery/bot/cleanbot/roomba/Crossed(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(prob(30))
			annoy(L)
	..()

/obj/machinery/bot/cleanbot/roomba/proc/annoy(var/mob/living/L)
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
