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
	layer = 5.0
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
	var/path[] = new()
	var/patrol_path[] = null
	var/beacon_freq = 1445		// navigation beacon frequency
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/should_patrol
	var/next_dest
	var/next_dest_loc

/obj/machinery/bot/cleanbot/New()
	..()
	get_targets()
	icon_state = "[icon_initial][on]"

	should_patrol = 1

	botcard = new /obj/item/weapon/card/id(src)
	var/datum/job/janitor/J = new/datum/job/janitor
	botcard.access = J.get_access()

	locked = 0 // Start unlocked so roboticist can set them to patrol.

	if(radio_controller)
		radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)


/obj/machinery/bot/cleanbot/turn_on()
	. = ..()
	icon_state = "[icon_initial][on]"
	updateUsrDialog()

/obj/machinery/bot/cleanbot/turn_off()
	..()
	if(!isnull(target))
		target.targetted_by = null
	target = null
	oldtarget = null
	oldloc = null
	icon_state = "[icon_initial][on]"
	path = new()
	updateUsrDialog()

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
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel is [open ? "opened" : "closed"]"},
text("<A href='?src=\ref[src];operation=start'>[on ? "On" : "Off"]</A>"))
	if(!locked || issilicon(user))
		dat += text({"<BR>Cleans Blood: []<BR>"}, text("<A href='?src=\ref[src];operation=blood'>[blood ? "Yes" : "No"]</A>"))
		dat += text({"<BR>Cleans Crayon: []<BR>"}, text("<A href='?src=\ref[src];operation=crayon'>[crayon ? "Yes" : "No"]</A>"))
		dat += text({"<BR>Patrol station: []<BR>"}, text("<A href='?src=\ref[src];operation=patrol'>[should_patrol ? "Yes" : "No"]</A>"))
	//	dat += text({"<BR>Beacon frequency: []<BR>"}, text("<A href='?src=\ref[src];operation=freq'>[beacon_freq]</A>"))
	if(open && !locked)
		dat += text({"
Odd looking screw twiddled: []<BR>
Weird button pressed: []"},
text("<A href='?src=\ref[src];operation=screw'>[screwloose ? "Yes" : "No"]</A>"),
text("<A href='?src=\ref[src];operation=oddbutton'>[oddbutton ? "Yes" : "No"]</A>"))

	user << browse("<HEAD><TITLE>Cleaner v1.0 controls</TITLE></HEAD>[dat]", "window=autocleaner")
	onclose(user, "autocleaner")
	return

/obj/machinery/bot/cleanbot/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	switch(href_list["operation"])
		if("start")
			if (on)
				turn_off()
			else
				turn_on()
		if(BLOOD)
			blood = !blood
			get_targets()
			updateUsrDialog()
		if("crayon")
			crayon = !crayon
			get_targets()
			updateUsrDialog()
		if("patrol")
			should_patrol =!should_patrol
			patrol_path = null
			updateUsrDialog()
		if("freq")
			var/freq = text2num(input("Select frequency for  navigation beacons", "Frequnecy", num2text(beacon_freq / 10))) * 10
			if (freq > 0)
				beacon_freq = freq
			updateUsrDialog()
		if("screw")
			screwloose = !screwloose
			to_chat(usr, "<span class='notice>You twiddle the screw.</span>")
			updateUsrDialog()
		if("oddbutton")
			oddbutton = !oddbutton
			to_chat(usr, "<span class='notice'>You press the weird button.</span>")
			updateUsrDialog()

/obj/machinery/bot/cleanbot/attackby(obj/item/weapon/W, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(allowed(usr) && !open && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the [src] behaviour controls.</span>")
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='notice'>This [src] doesn't seem to respect your authority.</span>")
	else
		return ..()

/obj/machinery/bot/cleanbot/Emag(mob/user as mob)
	..()
	if(open && !locked)
		if(user) to_chat(user, "<span class='notice'>The [src] buzzes and beeps.</span>")
		oddbutton = 1
		screwloose = 1

/obj/machinery/bot/cleanbot/process()
	//set background = 1

	if(!on)
		return
	if(cleaning)
		return

	if(!screwloose && !oddbutton && prob(5))
		visible_message("[src] makes an excited beeping booping sound!")

	if(screwloose && prob(5))
		if(istype(loc,/turf/simulated))
			var/turf/simulated/T = loc
			T.wet(800)
	if(oddbutton && prob(5))
		visible_message("Something flies out of [src]. He seems to be acting oddly.")
		var/obj/effect/decal/cleanable/blood/gibs/gib = getFromPool(/obj/effect/decal/cleanable/blood/gibs, loc)
		gib.New(gib.loc)
		//gib.streak(list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		oldtarget = get_turf(gib)
	if(!target || target == null)
		for (var/turf/T in view(7,src))
			if(target) break
			if(istype(T,/turf/space)) continue
			for(var/obj/effect/decal/cleanable/sickfilth in T.contents)
				if(sickfilth && !(is_type_in_list(sickfilth, blacklisted_targets)))
					if(!T.targetted_by && T!=oldtarget)
						oldtarget = T								 // or if it is but the bot is gone.
						target = T									 // and it's stuff we clean?  Clean it.
						T.targetted_by = src	// Claim the messy tile we are targeting.
						break

	if(!target || target == null)
		if(loc != oldloc)
			oldtarget = null

		if (!should_patrol)
			return

		if (!patrol_path || patrol_path.len < 1)
			var/datum/radio_frequency/frequency = radio_controller.return_frequency(beacon_freq)

			if(!frequency) return

			closest_dist = 9999
			closest_loc = null
			next_dest_loc = null

			var/datum/signal/signal = getFromPool(/datum/signal)
			signal.source = src
			signal.transmission_method = 1
			signal.data = list("findbeacon" = "patrol")
			frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
			spawn(5)
				if (!next_dest_loc)
					next_dest_loc = closest_loc
				if (next_dest_loc)
					patrol_path = AStar(loc, next_dest_loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 120, id=botcard, exclude=null)
		else
			patrol_move()

		return

	if(!path)
		path = new()
	if(target && path.len == 0)
		spawn(0)
			if(!src || !target) return
			path = AStar(loc, target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_cardinal, 0, 30)
			if (!path) path = list()
			if(path.len == 0)
				oldtarget = target
				target.targetted_by = null
				target = null
		return
	if(path.len > 0 && target && (target != null))
		step_to(src, path[1])
		path -= path[1]
	else if(path.len == 1)
		step_to(src, target)

	if(target && (target != null))
		patrol_path = null
		if(loc == target)
			clean(target)
			path = new()
			target = null
			return

	oldloc = loc

/obj/machinery/bot/cleanbot/proc/patrol_move()
	if (patrol_path.len <= 0)
		return

	var/next = patrol_path[1]
	patrol_path -= next
	if (next == loc)
		return

	var/moved = step_towards(src, next)
	if (!moved)
		failed_steps++
	if (failed_steps > 4)
		patrol_path = null
		next_dest = null
		failed_steps = 0
	else
		failed_steps = 0

/obj/machinery/bot/cleanbot/receive_signal(datum/signal/signal)
	var/recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return

	var/dist = get_dist(src, signal.source.loc)
	if (dist < closest_dist && signal.source.loc != loc)
		closest_dist = dist
		closest_loc = signal.source.loc
		next_dest = signal.data["next_patrol"]

	if (recv == next_dest)
		next_dest_loc = signal.source.loc
		next_dest = signal.data["next_patrol"]

/obj/machinery/bot/cleanbot/proc/get_targets() //This seems slightly wasteful, but it will only be called approximately once every six rounds so whatever
	blacklisted_targets = list()

	if(!blood)
		blacklisted_targets += (/obj/effect/decal/cleanable/blood)
	if(!crayon)
		blacklisted_targets += (/obj/effect/decal/cleanable/crayon)

/obj/machinery/bot/cleanbot/proc/clean(var/turf/target)
	anchored = 1
	icon_state = "[icon_initial]-c"
	visible_message("<span class='warning'>[src] begins to clean up the [target].</span>")
	cleaning = 1
	spawn(2 SECONDS)
		for(var/obj/effect/decal/cleanable/C in target)
			if(!(is_type_in_list(C,blacklisted_targets)))
				spawn(5)
				qdel(C)
		cleaning = 0
		icon_state = "[icon_initial][on]"
		anchored = 0
		target = null

/obj/machinery/bot/cleanbot/explode()
	on = 0
	visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/reagent_containers/glass/bucket(Tsec)

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return

/obj/item/weapon/bucket_sensor/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		if(user.drop_item(W))
			qdel(W)
			var/turf/T = get_turf(loc)
			var/obj/machinery/bot/cleanbot/A = new /obj/machinery/bot/cleanbot(T)
			A.name = created_name
			to_chat(user, "<span class='notice'>You add the robot arm to the bucket and sensor assembly. Beep boop!</span>")
			user.drop_from_inventory(src)
			qdel(src)

	else if (istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", name, created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && loc != usr)
			return
		created_name = t
