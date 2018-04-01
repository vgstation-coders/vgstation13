/obj/machinery/power/emitter
	name = "emitter"
	desc = "A heavy-duty industrial laser, often used in containment fields and power generation."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"

	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)
	circuit = /obj/item/circuitboard/machine/emitter

	use_power = NO_POWER_USE
	idle_power_usage = 10
	active_power_usage = 300

	var/icon_state_on = "emitter_+a"
	var/active = 0
	var/powered = 0
	var/fire_delay = 100
	var/maximum_fire_delay = 100
	var/minimum_fire_delay = 20
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = FALSE
	var/allow_switch_interact = TRUE

	var/projectile_type = /obj/item/projectile/beam/emitter

	var/projectile_sound = 'sound/weapons/emitter.ogg'

	var/datum/effect_system/spark_spread/sparks

	// The following 3 vars are mostly for the prototype
	var/manual = FALSE
	var/charge = 0
	var/last_projectile_params

/obj/machinery/power/emitter/anchored
	anchored = TRUE

/obj/machinery/power/emitter/ctf
	name = "Energy Cannon"
	active = TRUE
	active_power_usage = FALSE
	idle_power_usage = FALSE
	locked = TRUE
	req_access_txt = "100"
	state = 2
	use_power = FALSE

/obj/machinery/power/emitter/Initialize()
	. = ..()
	RefreshParts()
	wires = new /datum/wires/emitter(src)
	if(state == 2 && anchored)
		connect_to_network()

	sparks = new
	sparks.attach(src)
	sparks.set_up(5, TRUE, src)

/obj/machinery/power/emitter/RefreshParts()
	var/max_firedelay = 120
	var/firedelay = 120
	var/min_firedelay = 24
	var/power_usage = 350
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		max_firedelay -= 20 * L.rating
		min_firedelay -= 4 * L.rating
		firedelay -= 20 * L.rating
	maximum_fire_delay = max_firedelay
	minimum_fire_delay = min_firedelay
	fire_delay = firedelay
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		power_usage -= 50 * M.rating
	active_power_usage = power_usage

/obj/machinery/power/emitter/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_FLIP ,null,CALLBACK(src, .proc/can_be_rotated))

/obj/machinery/power/emitter/proc/can_be_rotated(mob/user,rotation_type)
	if (anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	return TRUE

/obj/machinery/power/emitter/Destroy()
	if(SSticker.IsRoundInProgress())
		var/turf/T = get_turf(src)
		message_admins("Emitter deleted at [ADMIN_COORDJMP(T)]",0,1)
		log_game("Emitter deleted at [COORD(T)]")
		investigate_log("<font color='red'>deleted</font> at [get_area(src)] [COORD(T)]", INVESTIGATE_SINGULO)
	QDEL_NULL(sparks)
	return ..()

/obj/machinery/power/emitter/update_icon()
	if (active && powernet && avail(active_power_usage))
		icon_state = icon_state_on
	else
		icon_state = initial(icon_state)


/obj/machinery/power/emitter/interact(mob/user)
	add_fingerprint(user)
	if(state == 2)
		if(!powernet)
			to_chat(user, "<span class='warning'>The emitter isn't connected to a wire!</span>")
			return 1
		if(!locked && allow_switch_interact)
			if(src.active==1)
				src.active = 0
				to_chat(user, "<span class='notice'>You turn off \the [src].</span>")
				message_admins("Emitter turned off by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(src)]",0,1)
				log_game("Emitter turned off by [key_name(user)] in [COORD(src)]")
				investigate_log("turned <font color='red'>off</font> by [key_name(user)] at [get_area(src)]", INVESTIGATE_SINGULO)
			else
				src.active = 1
				to_chat(user, "<span class='notice'>You turn on \the [src].</span>")
				src.shot_number = 0
				src.fire_delay = maximum_fire_delay
				investigate_log("turned <font color='green'>on</font> by [key_name(user)] at [get_area(src)]", INVESTIGATE_SINGULO)
			update_icon()
		else
			to_chat(user, "<span class='warning'>The controls are locked!</span>")
	else
		to_chat(user, "<span class='warning'>[src] needs to be firmly secured to the floor first!</span>")
		return 1

/obj/machinery/power/emitter/attack_animal(mob/living/simple_animal/M)
	if(ismegafauna(M) && anchored)
		state = 0
		anchored = FALSE
		M.visible_message("<span class='warning'>[M] rips [src] free from its moorings!</span>")
	else
		..()
	if(!anchored)
		step(src, get_dir(M, src))


/obj/machinery/power/emitter/emp_act(severity)//Emitters are hardened but still might have issues
	return 1


/obj/machinery/power/emitter/process()
	if(stat & (BROKEN))
		return
	if(src.state != 2 || (!powernet && active_power_usage))
		src.active = 0
		update_icon()
		return
	if(src.active == 1)
		if(!active_power_usage || avail(active_power_usage))
			add_load(active_power_usage)
			if(!powered)
				powered = 1
				update_icon()
				investigate_log("regained power and turned <font color='green'>on</font> at [get_area(src)]", INVESTIGATE_SINGULO)
		else
			if(powered)
				powered = 0
				update_icon()
				investigate_log("lost power and turned <font color='red'>off</font> at [get_area(src)]", INVESTIGATE_SINGULO)
				log_game("Emitter lost power in ([x],[y],[z])")
			return
		if(charge <=80)
			charge+=5
		if(!check_delay() || manual == TRUE)
			return FALSE
		fire_beam()

/obj/machinery/power/emitter/proc/check_delay()
	if((src.last_shot + src.fire_delay) <= world.time)
		return TRUE
	return FALSE

/obj/machinery/power/emitter/proc/fire_beam_pulse()
	if(!check_delay())
		return FALSE
	if(state != 2)
		return FALSE
	if(avail(active_power_usage))
		add_load(active_power_usage)
		fire_beam()

/obj/machinery/power/emitter/proc/fire_beam(mob/user)
	var/obj/item/projectile/P = new projectile_type(get_turf(src))
	playsound(get_turf(src), projectile_sound, 50, 1)
	if(prob(35))
		sparks.start()
	P.firer = user? user : src
	if(last_projectile_params)
		P.p_x = last_projectile_params[2]
		P.p_y = last_projectile_params[3]
		P.fire(last_projectile_params[1])
	else
		P.fire(dir2angle(dir))
	if(!manual)
		last_shot = world.time
		if(shot_number < 3)
			fire_delay = 20
			shot_number ++
		else
			fire_delay = rand(minimum_fire_delay,maximum_fire_delay)
			shot_number = 0
	P.fire()
	return P

/obj/machinery/power/emitter/can_be_unfasten_wrench(mob/user, silent)
	if(active)
		if(!silent)
			to_chat(user, "<span class='warning'>Turn \the [src] off first!</span>")
		return FAILED_UNFASTEN

	else if(state == EM_WELDED)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] is welded to the floor!</span>")
		return FAILED_UNFASTEN

	return ..()

/obj/machinery/power/emitter/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			state = EM_SECURED
		else
			state = EM_UNSECURED

/obj/machinery/power/emitter/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I, 0)
	return TRUE

/obj/machinery/power/emitter/welder_act(mob/living/user, obj/item/I)
	if(active)
		to_chat(user, "Turn \the [src] off first.")
		return TRUE

	switch(state)
		if(EM_UNSECURED)
			to_chat(user, "<span class='warning'>The [src.name] needs to be wrenched to the floor!</span>")
		if(EM_SECURED)
			if(!I.tool_start_check(user, amount=0))
				return TRUE
			user.visible_message("[user.name] starts to weld the [name] to the floor.", \
				"<span class='notice'>You start to weld \the [src] to the floor...</span>", \
				"<span class='italics'>You hear welding.</span>")
			if(I.use_tool(src, user, 20, volume=50))
				state = EM_WELDED
				to_chat(user, "<span class='notice'>You weld \the [src] to the floor.</span>")
				connect_to_network()
		if(EM_WELDED)
			if(!I.tool_start_check(user, amount=0))
				return TRUE
			user.visible_message("[user.name] starts to cut the [name] free from the floor.", \
				"<span class='notice'>You start to cut \the [src] free from the floor...</span>", \
				"<span class='italics'>You hear welding.</span>")
			if(I.use_tool(src, user, 20, volume=50))
				state = EM_SECURED
				to_chat(user, "<span class='notice'>You cut \the [src] free from the floor.</span>")
				disconnect_from_network()

	return TRUE

/obj/machinery/power/emitter/crowbar_act(mob/living/user, obj/item/I)
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/power/emitter/screwdriver_act(mob/living/user, obj/item/I)
	default_deconstruction_screwdriver(user, "emitter_open", "emitter", I)
	return TRUE


/obj/machinery/power/emitter/attackby(obj/item/I, mob/user, params)
	if(I.GetID())
		if(obj_flags & EMAGGED)
			to_chat(user, "<span class='warning'>The lock seems to be broken!</span>")
			return
		if(allowed(user))
			if(active)
				locked = !locked
				to_chat(user, "<span class='notice'>You [src.locked ? "lock" : "unlock"] the controls.</span>")
			else
				to_chat(user, "<span class='warning'>The controls can only be locked when \the [src] is online!</span>")
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")
		return

	else if(is_wire_tool(I) && panel_open)
		wires.interact(user)
		return

	else if(exchange_parts(user, I))
		return

	return ..()

/obj/machinery/power/emitter/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	locked = FALSE
	obj_flags |= EMAGGED
	if(user)
		user.visible_message("[user.name] emags [src].","<span class='notice'>You short out the lock.</span>")


/obj/machinery/power/emitter/prototype
	name = "Prototype Emitter"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "protoemitter"
	icon_state_on = "protoemitter_+a"
	can_buckle = TRUE
	buckle_lying = 0
	var/view_range = 12
	var/datum/action/innate/protoemitter/firing/auto

//BUCKLE HOOKS

/obj/machinery/power/emitter/prototype/unbuckle_mob(mob/living/buckled_mob,force = 0)
	playsound(src,'sound/mecha/mechmove01.ogg', 50, 1)
	manual = FALSE
	for(var/obj/item/I in buckled_mob.held_items)
		if(istype(I, /obj/item/turret_control))
			qdel(I)
	if(istype(buckled_mob))
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
		if(buckled_mob.client)
			buckled_mob.client.change_view(CONFIG_GET(string/default_view))
	auto.Remove(buckled_mob)
	. = ..()

/obj/machinery/power/emitter/prototype/user_buckle_mob(mob/living/M, mob/living/carbon/user)
	if(user.incapacitated() || !istype(user))
		return
	for(var/atom/movable/A in get_turf(src))
		if(A.density && (A != src && A != M))
			return
	M.forceMove(get_turf(src))
	..()
	playsound(src,'sound/mecha/mechmove01.ogg', 50, 1)
	M.pixel_y = 14
	layer = 4.1
	if(M.client)
		M.client.change_view(view_range)
	if(!auto)
		auto = new()
	auto.Grant(M, src)

/datum/action/innate/protoemitter
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	var/obj/machinery/power/emitter/prototype/PE
	var/mob/living/carbon/U


/datum/action/innate/protoemitter/Grant(mob/living/carbon/L, obj/machinery/power/emitter/prototype/proto)
	PE = proto
	U = L
	. = ..()

/datum/action/innate/protoemitter/firing
	name = "Switch to Manual Firing"
	desc = "The emitter will only fire on your command and at your designated target"
	button_icon_state = "mech_zoom_on"

/datum/action/innate/protoemitter/firing/Activate()
	if(PE.manual)
		playsound(PE,'sound/mecha/mechmove01.ogg', 50, 1)
		PE.manual = FALSE
		name = "Switch to Manual Firing"
		desc = "The emitter will only fire on your command and at your designated target"
		button_icon_state = "mech_zoom_on"
		for(var/obj/item/I in U.held_items)
			if(istype(I, /obj/item/turret_control))
				qdel(I)
		UpdateButtonIcon()
		return
	else
		playsound(PE,'sound/mecha/mechmove01.ogg', 50, 1)
		name = "Switch to Automatic Firing"
		desc = "Emitters will switch to periodic firing at your last target"
		button_icon_state = "mech_zoom_off"
		PE.manual = TRUE
		for(var/V in U.held_items)
			var/obj/item/I = V
			if(istype(I))
				if(U.dropItemToGround(I))
					var/obj/item/turret_control/TC = new /obj/item/turret_control()
					U.put_in_hands(TC)
			else	//Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
				var/obj/item/turret_control/TC = new /obj/item/turret_control()
				U.put_in_hands(TC)
		UpdateButtonIcon()


/obj/item/turret_control
	name = "turret controls"
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	flags_1 = ABSTRACT_1 | NODROP_1
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF | NOBLUDGEON_1
	var/delay = 0

/obj/item/turret_control/afterattack(atom/targeted_atom, mob/user, proxflag, clickparams)
	..()
	var/obj/machinery/power/emitter/E = user.buckled
	E.setDir(get_dir(E,targeted_atom))
	user.setDir(E.dir)
	switch(E.dir)
		if(NORTH)
			E.layer = 3.9
			user.pixel_x = 0
			user.pixel_y = -14
		if(NORTHEAST)
			E.layer = 3.9
			user.pixel_x = -8
			user.pixel_y = -12
		if(EAST)
			E.layer = 4.1
			user.pixel_x = -14
			user.pixel_y = 0
		if(SOUTHEAST)
			E.layer = 3.9
			user.pixel_x = -8
			user.pixel_y = 12
		if(SOUTH)
			E.layer = 4.1
			user.pixel_x = 0
			user.pixel_y = 14
		if(SOUTHWEST)
			E.layer = 3.9
			user.pixel_x = 8
			user.pixel_y = 12
		if(WEST)
			E.layer = 4.1
			user.pixel_x = 14
			user.pixel_y = 0
		if(NORTHWEST)
			E.layer = 3.9
			user.pixel_x = 8
			user.pixel_y = -12

	E.last_projectile_params = calculate_projectile_angle_and_pixel_offsets(user, clickparams)

	if(E.charge >= 10 && world.time > delay)
		E.charge -= 10
		E.fire_beam(user)
		delay = world.time + 10
	else if (E.charge < 10)
		playsound(get_turf(user),'sound/machines/buzz-sigh.ogg', 50, 1)
