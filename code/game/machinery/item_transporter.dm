var/global/list/current_transporters = list()

/obj/machinery/item_transporter
	name = "transporter"
	desc = "A machine that transports goods throughout the station."
	icon = 'icons/obj/machines/item_transporter.dmi'
	//state 0 is closed, state 1 is open
	//state 01 is opening, state 10 is closing
	icon_state = "transporter0"
	//should be able to walk on it, but not dragged
	anchored = TRUE
	density = FALSE
	//needs a cooldown, we aren't free
	var/timed_cooldown = 0
	//how much time between each transport
	var/cooldown_time = 40 SECONDS
	var/spawn_cooldown = 4 SECONDS
	//required for deconstructing
	var/decon_stage = 0
	//so that multiple people can't use it
	var/busy = FALSE

/obj/machinery/item_transporter/examine(mob/user)
	. = ..()
	if(stat & NOPOWER)
		to_chat(user, "<span class='info'>\The [src] is currently unpowered, please power it.</span>")
	if(stat & BROKEN)
		to_chat(user, "<span class='info'>\The [src] is currently broken, please repair it.</span>")
	if(world.time < timed_cooldown)
		var/time_remaining = round((timed_cooldown - world.time) / 10)
		to_chat(user, "<span class='info'>\The [src] is currently on cooldown, please wait [time_remaining] seconds.</span>")

/obj/machinery/item_transporter/New()
	. = ..()
	var/area/src_area = get_area(src)
	var/rand_num = rand(100000, 999999)
	name = "[src_area.name] [initial(name)] ([rand_num])"
	current_transporters += src

	component_parts = newlist(
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser
	)
	RefreshParts()

/obj/machinery/item_transporter/Destroy()
	current_transporters -= src
	. = ..()

/obj/machinery/item_transporter/RefreshParts()
	var/mb_rating = 0
	var/l_rating = 0
	cooldown_time = 40 SECONDS
	spawn_cooldown = 5 SECONDS
	for(var/obj/item/weapon/stock_parts/matter_bin/spMatterBin in component_parts)
		mb_rating += spMatterBin.rating
	for(var/obj/item/weapon/stock_parts/micro_laser/spLaser in component_parts)
		l_rating += spLaser.rating
	cooldown_time -= (mb_rating * 10) SECONDS
	spawn_cooldown -= l_rating SECONDS

/obj/machinery/item_transporter/attack_ghost(mob/user)
	if(isAdminGhost(user))
		var/choice_list = list(
			"Reset Cooldown",
			"Set Cooldown"
		)
		var/choice = input(user, "Choose which action to do") as null|anything in choice_list
		switch(choice)
			if("Reset Cooldown")
				timed_cooldown = 0
				return
			if("Set Cooldown")
				var/num_choice = input(user, "How many seconds should the cooldown be?") as num
				if(!num_choice)
					return
				if(num_choice <= 0)
					num_choice = 1
				cooldown_time = num_choice SECONDS
				return
	var/obj/machinery/item_transporter/tele_choice = input(user, "Which transporter would you like to go to?") as null|anything in current_transporters
	if(!tele_choice)
		return
	user.forceMove(get_turf(tele_choice))

/obj/machinery/item_transporter/attack_hand(mob/user, ignore_brain_damage)
	if(isobserver(user))
		return
	if(user.incapacitated() || !user.Adjacent(src))
		return
	if(decon_stage)
		to_chat(user, "<span class='warning'>\The [src] has its wire panel open, close it before using.</span>")
		return
	if(world.time < timed_cooldown)
		var/time_remaining = round((timed_cooldown - world.time) / 10)
		to_chat(user, "<span class='warning'>\The [src] is currently on cooldown, please wait [time_remaining] seconds.</span>")
		return
	if(busy)
		return
	busy = TRUE
	var/obj/machinery/item_transporter/choice = input(user, "Which transporter will you select?") as null|anything in current_transporters
	if(!choice)
		busy = FALSE
		return
	if(user.incapacitated() || !user.Adjacent(src))
		busy = FALSE
		return
	var/turf/src_turf = get_turf(src)
	var/turf/choice_turf = get_turf(choice)
	if(src_turf.z != choice_turf.z)
		visible_message("<span class='notice'>\The [src] pings 'Target is too far to choose.'</span>")
		busy = FALSE
		return
	visible_message("<span class='notice'>\The [src] begins to power up...</span>")
	flick(icon, "transporter01")
	spawn(spawn_cooldown)
		icon_state = "transporter1"
		for(var/obj/moveO in src_turf)
			if(moveO.anchored)
				continue
			moveO.forceMove(choice_turf)
		flick(icon, "transporter10")
		icon_state = "transporter0"
		visible_message("<span class='notice'>\The [src] begins to cool down...</span>")
		timed_cooldown = world.time + cooldown_time
		playsound(src, 'sound/machines/chime.ogg', 50, 1)
		choice.timed_cooldown = world.time + choice.cooldown_time
		playsound(choice, 'sound/machines/chime.ogg', 50, 1)
		busy = FALSE

/obj/machinery/item_transporter/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.is_screwdriver(user))
		W.playtoolsound(src, 50)
		switch(decon_stage)
			if(0)
				to_chat(user, "<span class='notice'>You open the wire panel for \the [src].</span>")
				decon_stage = 1
				return
			if(1)
				to_chat(user, "<span class='notice'>You close the wire panel for \the [src].</span>")
				decon_stage = 0
				return
	else if(iscrowbar(W) && decon_stage)
		W.playtoolsound(src, 50)
		var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(get_turf(src))
		M.amount = 5
		for(var/obj/item/weapon/stock_parts/sParts in component_parts)
			sParts.forceMove(src.loc)
		qdel(src)
		return
	else if(istype(W, /obj/item/weapon/storage/bag/gadgets/part_replacer))
		return exchange_parts(user, W)
	else
		..()
