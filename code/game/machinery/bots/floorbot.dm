//Floorbot assemblies
/obj/item/weapon/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top."
	name = "tiles and toolbox"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = W_CLASS_MEDIUM
	flags = 0
	var/created_name = "Floorbot"
	var/skin = null

/obj/item/weapon/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached."
	name = "tiles, toolbox and sensor arrangement"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = W_CLASS_MEDIUM
	flags = 0
	var/created_name = "Floorbot"
	var/skin = null

// Tell other floorbots what we're fucking with so two floorbots don't dick with the same tile.
var/global/list/floorbot_targets=list()

//Floorbot
/obj/machinery/bot/floorbot
	name = "Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "floorbot0"
	icon_initial = "floorbot"
	density = 0
	anchored = 0
	health = 25
	maxHealth = 25
	auto_patrol = 0		// set to make bot automatically patrol
	bot_flags = BOT_PATROL|BOT_BEACON|BOT_NOT_CHASING|BOT_SPACEWORTHY|BOT_CONTROL
	var/amount = 10
	var/repairing = 0
	var/improvefloors = 0
	var/eattiles = 0
	var/maketiles = 0
	var/oldloc = null
	req_one_access = list(access_robotics, access_construction)
	var/targetdirection
	beacon_freq = 1445		// navigation beacon frequency
	var/skin = null
	commanding_radios = list(/obj/item/radio/integrated/signal/bot/floorbot)

/obj/machinery/bot/floorbot/New()
	. = ..()
	botcard = new /obj/item/weapon/card/id(src)
	var/datum/job/engineer/E = new /datum/job/engineer
	botcard.access = E.get_access()
	update_icon()

/obj/machinery/bot/floorbot/turn_on()
	. = ..()
	update_icon()
	updateUsrDialog()

/obj/machinery/bot/floorbot/turn_off()
	..()
	if(!isnull(target))
		floorbot_targets -= target
	target = null
	old_targets = list()
	oldloc = null
	update_icon()
	updateUsrDialog()

/obj/machinery/bot/floorbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	usr.set_machine(src)
	interact(user)

/obj/machinery/bot/floorbot/interact(mob/user as mob)
	var/dat
	dat += "<TT><B>Automatic Station Floor Repairer v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];operation=start'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"
	dat += "Tiles left: [amount]<BR>"
	dat += "Behaviour controls are [locked ? "locked" : "unlocked"]<BR>"
	if(!locked || issilicon(user))
		dat += "Improves floors: <A href='?src=\ref[src];operation=improve'>[improvefloors ? "Yes" : "No"]</A><BR>"
		dat += "Finds tiles: <A href='?src=\ref[src];operation=tiles'>[eattiles ? "Yes" : "No"]</A><BR>"
		dat += "Make single pieces of metal into tiles when empty: <A href='?src=\ref[src];operation=make'>[maketiles ? "Yes" : "No"]</A><BR>"

	user << browse("<HEAD><TITLE>Repairbot v0.1 controls (alpha)</TITLE></HEAD>[dat]", "window=autorepair")
	onclose(user, "autorepair")


/obj/machinery/bot/floorbot/proc/speak(var/message)
	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",2)

/obj/machinery/bot/floorbot/attackby(var/obj/item/W , mob/user)
	if(istype(W, /obj/item/stack/tile/metal))
		var/obj/item/stack/tile/metal/T = W
		if(amount >= 50)
			return
		var/loaded = min(50-amount, T.amount)
		T.use(loaded)
		amount += loaded
		to_chat(user, "<span class='notice'>You load [loaded] tiles into the floorbot. He now contains [amount] tiles.</span>")
		update_icon()
		updateUsrDialog()
	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(allowed(usr) && !open && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] \the [src]'s behaviour controls.</span>")
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

/obj/machinery/bot/floorbot/emag_act(mob/user as mob)
	..()
	if(open && !locked)
		if(user)
			to_chat(user, "<span class='notice'>The [src] buzzes and beeps.</span>")

/obj/machinery/bot/floorbot/Topic(href, href_list)
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
		if("improve")
			improvefloors = !improvefloors
			updateUsrDialog()
		if("tiles")
			eattiles = !eattiles
			updateUsrDialog()
		if("make")
			maketiles = !maketiles
			updateUsrDialog()

/obj/machinery/bot/floorbot/proc/is_obj_valid_target(var/atom/T,var/list/floorbottargets)
	if(T in floorbottargets)
		return 0
	if(T in old_targets)
		return 0
	if(istype(T.loc, /turf/simulated/wall))
		return 0
	if(!T.loc.Enter(src, loc, TRUE))
		return 0
	return 1

/obj/machinery/bot/floorbot/proc/hunt_for_tiles(var/list/shit_in_view, var/list/floorbottargets)
	for(var/obj/item/stack/tile/metal/T in shit_in_view)
		if(!(T in floorbot_targets) && is_obj_valid_target(T,floorbottargets))
			add_oldtarget(T)
			target = T
			floorbot_targets +=T
			return

/obj/machinery/bot/floorbot/proc/hunt_for_metal(var/list/shit_in_view, var/list/floorbottargets)
	for(var/obj/item/stack/sheet/metal/M in shit_in_view)
		if(!(M in floorbot_targets) && is_obj_valid_target(M) && M.amount == 1)
			add_oldtarget(M)
			target = M
			floorbot_targets += M
			return

/obj/machinery/bot/floorbot/proc/have_target()
	return (target != null && !target.gcDestroyed)

/obj/machinery/bot/floorbot/can_path()
	return !repairing

/obj/machinery/bot/floorbot/process_bot()
	if(repairing)
		return
	decay_oldtargets()
	if(prob(1))
		var/message = pick("Metal to the metal.","I am the only engineering staff on this station.","Law 1. Place tiles.","Tiles, tiles, tiles...")
		speak(message)
	if (!summoned)
		checkforwork()

/obj/machinery/bot/floorbot/at_path_target()
	if(istype(target, /obj/item/stack/tile/metal))
		eattile(target)
	else if(istype(target, /obj/item/stack/sheet/metal))
		maketile(target)
	else if(isturf(target))
		var/turf/T = target
		if(emagged < 2)
			if((T.is_plating() || istype(T,/turf/space/)))
				repair(target)
			else if(T.is_metal_floor())
				var/turf/simulated/floor/F = target
				if(F.broken || F.burnt)
					anchored = 1
					repairing = 1
					F.break_tile_to_plating()
					spawn(50)
						anchored = 0
						repairing = 0
		else if(emagged == 2 && T.is_plating())
			var/turf/simulated/floor/F = target
			anchored = 1
			repairing = 1
			if(prob(90))
				F.break_tile_to_plating()
			else
				F.ReplaceWithLattice()
			visible_message("<span class='warning'>[src] makes an excited booping sound as it begins tearing apart \the [F].</span>")
			spawn(50)
				amount ++
				anchored = 0
				repairing = 0
	path = list()
	floorbot_targets -= target
	target = null
	return ..()

/obj/machinery/bot/floorbot/proc/checkforwork()
	if(have_target())
		return 0
	var/list/can_see = view(target_chasing_distance, src)

	if(amount < 50)
		if(eattiles && hunt_for_tiles(can_see))
			return 1
		if(maketiles && hunt_for_metal(can_see))
			return 1
		else if(amount <= 0)
			return 0

	if(prob(5))
		visible_message("[src] makes an excited booping beeping sound!")

	if(emagged < 2)
		if(targetdirection != null)
			var/turf/T = get_step(src, targetdirection)
			if(istype(T, /turf/space) && !(T in floorbot_targets) && !(T in old_targets) && !T.has_dense_content())
				add_oldtarget(T)
				target = T
				floorbot_targets+=T
				return 1
		for (var/turf/space/D in can_see)
			if(!(D in old_targets) && !isspace(D.loc) && !(D in floorbot_targets) && !D.has_dense_content())
				add_oldtarget(D)
				target = D
				floorbot_targets += D
				return 1
		if(improvefloors)
			for(var/turf/simulated/floor/F in can_see)
				if(F in floorbot_targets)
					continue
				if(F in old_targets)
					continue
				if(F.has_dense_content())
					continue
				if(F.is_plating() && !(istype(F, /turf/simulated/wall)))
					if(!F.broken && !F.burnt)
						add_oldtarget(F)
						target = F
						floorbot_targets += F
						return 1
				if(F.is_metal_floor() && (F.broken||F.burnt))
					add_oldtarget(F)
					target = F
					floorbot_targets += F
					return 1
	else
		for (var/turf/simulated/floor/D in can_see)
			if(D in floorbot_targets)
				continue
			if(D in old_targets)
				continue
			if(D.has_dense_content())
				continue
			if(D.is_metal_floor())
				add_oldtarget(D)
				target = D
				floorbot_targets += D
				return 1
	return 0

/obj/machinery/bot/floorbot/proc/repair(var/turf/target)
	if(istype(target, /turf/space/))
		if(isspace(target.loc))
			return
	else if(!istype(target, /turf/simulated/floor))
		return
	if(amount <= 0)
		return
	anchored = 1
	icon_state = "[skin][icon_initial]-c"
	if(istype(target, /turf/space/))
		visible_message("<span class='warning'>[src] begins to repair the hole</span>")
		var/obj/item/stack/tile/metal/T = new /obj/item/stack/tile/metal
		repairing = 1
		spawn(50)
			T.build(target)
			repairing = 0
			amount -= 1
			update_icon()
			anchored = 0
	else
		var/turf/simulated/floor/F = loc
		if(!F.broken && !F.burnt)
			visible_message("<span class='warning'>[src] begins to improve the floor.</span>")
			repairing = 1
			spawn(50)
				F.make_tiled_floor(new /obj/item/stack/tile/metal)
				repairing = 0
				amount -= 1
				update_icon()
				anchored = 0
		else
			if(F.is_plating())
				visible_message("<span class='warning'>[src] begins to fix dents in the floor.</span>")
				repairing = 1
				spawn(20)
					repairing = 0
					// Cheap, and does the job.
					F.icon_state = "plating"
					F.burnt = 0
					F.broken = 0

/obj/machinery/bot/floorbot/proc/eattile(var/obj/item/stack/tile/metal/T)
	if(!istype(T, /obj/item/stack/tile/metal))
		return
	visible_message("<span class='warning'>[src] begins to collect tiles.</span>")
	repairing = 1
	spawn(20)
		if(isnull(T))
			repairing = 0
			return
		if(amount + T.amount > 50)
			var/i = 50 - amount
			amount += i
			T.amount -= i
		else
			amount += T.amount
			qdel(T)
		update_icon()
		repairing = 0

/obj/machinery/bot/floorbot/proc/maketile(var/obj/item/stack/sheet/metal/M)
	if(!istype(M, /obj/item/stack/sheet/metal))
		return
	if(M.amount < 1)
		return
	visible_message("<span class='warning'>[src] begins to create tiles.</span>")
	repairing = 1
	spawn(20)
		if(!M || !get_turf(M))
			repairing = 0
			return
		var/obj/item/stack/tile/metal/T = new /obj/item/stack/tile/metal(get_turf(M))
		T.amount = 4
		if(M.amount==1)
			qdel(M)
			//qdel(M)
		else
			M.amount--
		repairing = 0

/obj/machinery/bot/floorbot/update_icon()
	if(amount > 0)
		icon_state = "[skin][icon_initial][on]"
	else
		icon_state = "[skin][icon_initial][on]e"


/obj/machinery/bot/floorbot/get_patrol_path(var/list/L)
	if(..())
		return TRUE
	return FALSE

/obj/machinery/bot/floorbot/explode()
	on = 0
	visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	switch(skin)
		if("y")
			var/obj/item/weapon/storage/toolbox/electrical/N = new(Tsec)
			N.contents = list()
		if("r")
			var/obj/item/weapon/storage/toolbox/emergency/N = new(Tsec)
			N.contents = list()
		else
			var/obj/item/weapon/storage/toolbox/mechanical/N = new(Tsec)
			N.contents = list()

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	if(target)
		floorbot_targets -= target

	while (amount)//Dumps the tiles into the appropriate sized stacks
		if(amount >= 16)
			var/obj/item/stack/tile/metal/T = new (Tsec)
			T.amount = 16
			amount -= 16
		else
			var/obj/item/stack/tile/metal/T = new (Tsec)
			T.amount = amount
			amount = 0

	spark(src)
	qdel(src)
	return

/obj/machinery/bot/floorbot/return_status()
	if (repairing)
		return "Repairing"
	if (auto_patrol)
		return "Patrolling"
	if (target)
		return "Moving"
	return ..()

// -- Toolbox floorbot interactions --

/obj/item/weapon/storage/toolbox/proc/floorbot_type()
	return "no_build"

/obj/item/weapon/storage/toolbox/mechanical/floorbot_type()
	return null

/obj/item/weapon/storage/toolbox/emergency/floorbot_type()
	return "r"

/obj/item/weapon/storage/toolbox/electrical/floorbot_type()
	return "y"

/obj/item/weapon/storage/toolbox/attackby(var/obj/item/stack/tile/metal/T, mob/user as mob)
	if(!istype(T, /obj/item/stack/tile/metal) || contents.len >= 1 || floorbot_type() == "no_build") //Only do this if the thing is empty
		return ..()
	user.remove_from_mob(T)
	QDEL_NULL(T)
	var/obj/item/weapon/toolbox_tiles/B = new /obj/item/weapon/toolbox_tiles
	B.skin = floorbot_type()
	B.icon_state = "[B.skin]toolbox_tiles"
	user.put_in_hands(B)
	to_chat(user, "<span class='notice'>You add the tiles into the empty toolbox. They protrude from the top.</span>")
	user.drop_from_inventory(src)
	qdel(src)

/obj/item/weapon/toolbox_tiles/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(isprox(W))
		QDEL_NULL(W)
		var/obj/item/weapon/toolbox_tiles_sensor/B = new /obj/item/weapon/toolbox_tiles_sensor()
		B.created_name = created_name
		B.skin = skin
		B.icon_state = "[B.skin]toolbox_tiles_sensor"
		user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You add the sensor to the toolbox and tiles!</span>")
		user.drop_from_inventory(src)
		qdel(src)

	else if (istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", name, created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && loc != usr)
			return

		created_name = t

/obj/item/weapon/toolbox_tiles_sensor/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		qdel(W)
		var/turf/T = get_turf(user.loc)
		var/obj/machinery/bot/floorbot/A = new /obj/machinery/bot/floorbot(T)
		A.name = created_name
		A.skin = skin
		A.update_icon()
		to_chat(user, "<span class='notice'>You add the robot arm to the odd looking toolbox assembly! Boop beep!</span>")
		user.drop_from_inventory(src)
		qdel(src)
	else if (istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name)

		if (!t)
			return
		if (!in_range(src, usr) && loc != usr)
			return

		created_name = t
