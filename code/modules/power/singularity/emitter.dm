//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/power/emitter
	name = "emitter"
	desc = "A heavy duty industrial laser."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter0"
	anchored = 0
	density = 1
	req_access = list(access_engine_minor)

	use_power = MACHINE_POWER_USE_NONE
	power_priority = POWER_PRIORITY_POWER_EQUIPMENT
	monitoring_enabled = TRUE
	idle_power_usage = 10
	active_power_usage = 300

	var/active = 0
	var/powered = 0
	var/fire_delay = 100
	var/last_shot = 0
	var/shot_number = 0
	var/locked = 0
	var/previous_state = 0//for update_icon() purposes
	var/beam_power = 1
	var/min_satisfaction = 0.3 //Emitter will shutdown below this level of power satisfaction
	var/last_satisfaction = 0

	machine_flags = EMAGGABLE | WRENCHMOVE | FIXED2WORK | WELD_FIXED | MULTITOOL_MENU

	var/frequency = 0
	var/datum/radio_frequency/radio_connection

	//Now uses a constant beam.
	var/obj/effect/beam/emitter/beam = null

/obj/machinery/power/emitter/New(var/turf/loc)
	..()
	previous_state = state

	//Radio remote control
/obj/machinery/power/emitter/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/power/emitter/verb/rotate_cw()
	set name = "Rotate (Clockwise)"
	set category = "Object"
	set src in oview(1)

	if(src.anchored || usr:stat)
		to_chat(usr, "<span class='warning'>It is fastened to the floor!</span>")
		return 0
	src.dir = turn(src.dir, -90)
	return 1

/obj/machinery/power/emitter/verb/rotate_ccw()
	set name = "Rotate (Counter-Clockwise)"
	set category = "Object"
	set src in oview(1)

	if(src.anchored || usr:stat)
		to_chat(usr, "<span class='warning'>It is fastened to the floor!</span>")
		return 0
	src.dir = turn(src.dir, 90)
	return 1

/obj/machinery/power/emitter/AltClick(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	rotate_cw()

/obj/machinery/power/emitter/initialize()
	..()
	if(state == 2 && anchored)
		connect_to_network()
		update_icon()
		update_beam()

	if(frequency)
		set_frequency(frequency)

/obj/machinery/power/emitter/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag","set_id")]</a></li>
	</ul>
	"}

/obj/machinery/power/emitter/proc/update_beam()
	if(active && powered)
		if(!beam)
			beam = new /obj/effect/beam/emitter(loc)
			beam.dir = dir
			beam.emit(spawn_by=src)
		if (last_satisfaction != get_satisfaction()) // Beam power scales down is satisfaction is down too
			beam.set_power(beam_power * get_satisfaction())
	else
		if(beam)
			beam._re_emit = 0
			QDEL_NULL(beam)

/obj/machinery/power/emitter/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return 0

	var/on
//	to_chat(world, "\ref[src] received signal. tag [signal.data["tag"]], cmd [signal.data["command"]], state [signal.data["state"]], sigtype [signal.data["sigtype"]]")
	if(signal.data["command"])
		switch(signal.data["command"])
			if("on")
				on = 1

			if("off")
				on = 0

			if("set")
				on = signal.data["state"] > 0

			if("toggle")
				on = !active

		if(!isnull(on) && anchored && state == 2 && on != active)
			if (active != on)
				if (on)
					turn_on()
				else
					turn_off()

			var/statestr = on ? "on":"off"
			// Spammy message_admins("Emitter turned [statestr] by radio signal ([signal.data["command"]] @ [frequency]) in [formatJumpTo(src)]",0,1)
			log_game("Emitter turned [statestr] by radio signal ([signal.data["command"]] @ [frequency]) in ([x],[y],[z])")
			investigation_log(I_SINGULO,"turned <font color='orange'>[statestr]</font> by radio signal ([signal.data["command"]] @ [frequency])")

/obj/machinery/power/emitter/Destroy()
	qdel(beam)
	message_admins("Emitter deleted at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	log_game("Emitter deleted at ([x],[y],[z])")
	investigation_log(I_SINGULO,"<font color='red'>deleted</font> at ([x],[y],[z])")
	..()

/obj/machinery/power/emitter/update_icon()
	overlays.len = 0
	icon_state = "emitter[state]"
	if (state != previous_state)
		flick("emitterflick-[previous_state][state]",src)
		previous_state = state

	if(powered && get_powernet() && get_satisfaction() > min_satisfaction && active)
		var/image/emitterbeam = image(icon,"emitter-beam")
		emitterbeam.plane = ABOVE_LIGHTING_PLANE
		emitterbeam.layer = ABOVE_LIGHTING_LAYER
		overlays += emitterbeam

	if(locked)
		var/image/emitterlock = image(icon,"emitter-lock")
		emitterlock.plane = ABOVE_LIGHTING_PLANE
		emitterlock.layer = ABOVE_LIGHTING_LAYER
		overlays += emitterlock

/obj/machinery/power/emitter/get_monitor_status()
	if (!(monitoring_enabled && active))
		return null

	var/list/template = get_monitor_status_template()
	template["demand"] = active_power_usage

	return list("\ref[src]" = template)

/obj/machinery/power/emitter/attack_hand(mob/user as mob)
	//Require consciousness
	if(user.stat && !isAdminGhost(user))
		return

	src.add_fingerprint(user)
	if(state == 2)
		if(!get_powernet())
			to_chat(user, "<span class='warning'>\The [src] isn't connected to a wire.</span>")
			return 1
		if(!src.locked)
			if(active)
				turn_off()
				user.visible_message("<span class='warning'>[user] turns \the [src] off.", \
				"<span class='notice'>You turn \the [src] off.")
				message_admins("Emitter turned off by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Emitter turned off by [user.ckey]([user]) in ([x],[y],[z])")
				investigation_log(I_SINGULO,"turned <font color='red'>off</font> by [user.key]")
			else
				turn_on()
				user.visible_message("<span class='warning'>[user] turns \the [src] on.", \
				"<span class='notice'>You turn \the [src] on.")
				message_admins("Emitter turned on by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Emitter turned on by [user.ckey]([user]) in ([x],[y],[z])")
				investigation_log(I_SINGULO,"turned <font color='green'>on</font> by [user.key]")
		else
			to_chat(user, "<span class='warning'>\The [src]'s controls are locked!</span>")
	else
		to_chat(user, "<span class='warning'>\The [src] needs to be firmly secured to the floor first.</span>")
		return 1

/obj/machinery/power/emitter/forceMove(atom/destination, step_x = 0, step_y = 0, no_tp = FALSE, harderforce = FALSE, glide_size_override = 0)
	if(active) // You just removed it from the power cable it was on, what did you think would happen?
		visible_message("<span class='warning'>The [src] gets yanked off of its power source and turns off!</span>")
		turn_off()
	..()

//Important note, those procs not log the emitter being turned on or off, so please use the logs in attack_hand above
/obj/machinery/power/emitter/proc/turn_on()
	active = 1
	shot_number = 0
	fire_delay = 100
	update_icon()
	//update_beam()

/obj/machinery/power/emitter/proc/turn_off()
	active = 0
	update_icon()
	update_beam()

/obj/machinery/power/emitter/emp_act(var/severity) //Emitters are EMP-proof for obvious reasons
	return 1

/obj/machinery/power/emitter/process()
	if(!anchored) //If it got unanchored "inexplicably"... fucking badmins
		active = 0
		update_icon()
		update_beam()
		return

	if(stat & BROKEN)
		return

	if(state != 2 || (!powernet && active_power_usage)) //Not welded to the floor, or no more wire underneath and requires power
		active = 0
		update_icon()
		update_beam()
		return

	if (active)
		add_load(active_power_usage) //Request power for next tick

	if(((last_shot + fire_delay) <= world.time) && (active == 1)) //It's currently activated and it hasn't processed in a bit
		if(!active_power_usage || get_satisfaction() > min_satisfaction) //Doesn't require power or powernet has enough supply
			if(!powered) //Yay its powered
				powered = 1
				update_icon()
				update_beam()
				investigation_log(I_SINGULO,"regained power and turned <font color='green'>on</font>")
			else if (last_satisfaction != get_satisfaction())
				update_beam()
		else
			if(powered) //Fuck its not anymore
				powered = 0 //Whelp time to kill it then
				update_beam() //Update its beam and icon
				update_icon()
				investigation_log(I_SINGULO,"lost power and turned <font color='red'>off</font>")
			return

		last_shot = world.time

		if(shot_number < 3)
			fire_delay = 2
			shot_number++
		else
			fire_delay = rand(20, 100)
			shot_number = 0

		//beam = new /obj/item/projectile/beam/emitter(loc)
		//beam.dir = dir
		//playsound(src, 'sound/weapons/emitter.ogg', 25, 1)

		if(prob(35))
			spark(src, 5)

		//A.dumbfire()

/obj/machinery/power/emitter/emag_act(mob/user)
	if(!emagged)
		locked = 0
		emagged = 1
		if(user)
			user.visible_message("<span class='danger'>[user] shorts out \the [src]'s lock.</span>", "<span class='warning'>You short out \the [src]'s lock.</span>")
		update_icon()

/obj/machinery/power/emitter/wrenchAnchor(var/mob/user, var/obj/item/I)
	if(active)
		to_chat(user, "<span class='warning'>Turn off \the [src] first.</span>")
		return FALSE
	. = ..()
	update_icon()

/obj/machinery/power/emitter/weldToFloor()
	if(..() == 1)
		switch(state)
			if(1)
				disconnect_from_network()
			if(2)
				connect_to_network()
		update_icon()
		return 1
	return -1

/obj/machinery/power/emitter/attackby(obj/item/W, mob/user)
	. = ..() //Holy fucking shit
	if(.)
		return .

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			to_chat(user, "<span class='warning'>The lock appears to be broken.</span>")
			return
		if(src.allowed(user))
			if(active)
				src.locked = !src.locked
				to_chat(user, "<span class='notice'>The controls are now [src.locked ? "locked" : "unlocked"].</span>")
				update_icon()
			else
				src.locked = 0 //just in case it somehow gets locked
				to_chat(user, "<span class='warning'>The controls can only be locked when \the [src] is online</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/machinery/power/emitter/canClone(var/obj/machinery/power/emitter/O)
	return istype(O)

/obj/machinery/power/emitter/clone(var/obj/machinery/power/emitter/O)
	id_tag = O.id_tag
	set_frequency(O.frequency)
	return 1

/obj/machinery/power/emitter/npc_tamper_act(mob/living/L)
	attack_hand(L)

/////////////////////////////////////////////////////////////////////////////////////

/obj/effect/beam/emitter
	name = "emitter beam"
	icon = 'icons/effects/beam.dmi'
	icon_state = "emitter_1"
	anchored = 1.0
	flags = 0
	base_damage = 30
	full_damage = 30
	damage_type = BURN

	var/base_state = "emitter"
	var/power = 1

/obj/effect/beam/emitter/proc/set_power(var/newpower = 1)
	power = newpower
	if(next)
		var/obj/effect/beam/emitter/next_beam=next
		next_beam.set_power(power)
	update_icon()
	if(!master)
		INVOKE_EVENT(src, /event/beam_power_change, "beam" = src)

/obj/effect/beam/emitter/spawn_child()
	var/obj/effect/beam/emitter/beam = ..()
	if(!beam)
		return null
	beam.power = power
	return beam

/obj/effect/beam/emitter/update_icon()
	if(!master)
		invisibility = 101 //Make doubly sure
		return
	var/visible_power = clamp(round(power/3) + 1, 1, 3)
	//if(!master)
		//testing("Visible power: [visible_power]")
	icon_state = "[base_state]_[visible_power]"

/obj/effect/beam/emitter/get_machine_underlay(var/mdir)
	var/visible_power = clamp(round(power/3) + 1, 1, 3)
	return image(icon = icon, icon_state = "[base_state]_[visible_power] underlay", dir = mdir)

/obj/effect/beam/emitter/get_damage()
	return base_damage * power

/////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/power/emitter/antique
	name = "antique emitter"
	desc = "An old fashioned heavy duty industrial laser."
	icon_state = "emitter"

/obj/machinery/power/emitter/antique/update_icon()
	if(powered && get_powernet() && get_satisfaction() > min_satisfaction && active)
		icon_state = "emitter_+a"
	else
		icon_state = "emitter"
