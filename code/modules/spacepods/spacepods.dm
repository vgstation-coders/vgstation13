// honk
#define DAMAGE			1
#define FIRE			2

#define SPACEPOD_MOVEDELAY_FAST 0.4
#define SPACEPOD_MOVEDELAY_MEDIUM 1
#define SPACEPOD_MOVEDELAY_SLOW 3
#define SPACEPOD_MOVEDELAY_DEFAULT SPACEPOD_MOVEDELAY_FAST
#define SPACEPOD_LIGHTS_CONSUMPTION 2 //battery consumption per second with lights on
#define SPACEPOD_LIGHTS_RANGE_ON 8
#define SPACEPOD_LIGHTS_RANGE_OFF 3 //one tile beyond the spacepod itself, "cockpit glow"

#define STATUS_REMOVE 1
#define STATUS_ADD 2

/obj/spacepod
	name = "\improper space pod"
	desc = "A space pod meant for space travel."
	icon = 'icons/48x48/pods.dmi'
	density = 1 //Dense. To raise the heat.
	opacity = 0
	anchored = 1
	layer = ABOVE_DOOR_LAYER
	infra_luminosity = 15
	internal_gravity = 1 // Can move in 0-gravity
	var/passenger_limit = 1 //Upper limit for how many passengers are allowed
	var/passengers_allowed = 1 //If the pilot allows people to jump in the side seats.
	var/list/occupants = list()
	var/datum/spacepod/equipment/ES
	var/obj/item/weapon/cell/battery
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/effect/system/trail/space_trail/ion_trail
	var/use_internal_tank = 0
	var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature
	var/datum/global_iterator/pr_give_air //moves air from tank to cabin
	var/datum/global_iterator/pr_lights_battery_use //passive battery use for the lights
	var/hatch_open = 0
	var/locked = FALSE
	var/next_firetime = 0
	var/list/pod_overlays
	health = 400
	maxHealth = 400
	var/lights_enabled = FALSE
	light_power = 2
	light_range = SPACEPOD_LIGHTS_RANGE_OFF
	appearance_flags = LONG_GLIDE|TILE_MOVER

	var/datum/delay_controller/move_delayer = new(0.1, ARBITRARILY_LARGE_NUMBER) //See setup.dm, 12
	var/passenger_fire = 0 //Whether or not a passenger can fire weapons attached to this pod
	var/movement_delay = SPACEPOD_MOVEDELAY_DEFAULT //Speed of the vehicle decreases as this value increases. Anything above 6 is slow, 1 is fast and 0 is very fast
	var/list/actions_types = list( //Actions to create and hold for the pilot
		/datum/action/spacepod/pilot/toggle_passengers,
		/datum/action/spacepod/pilot/toggle_passenger_weaponry,
		/datum/action/spacepod/pilot/change_speed,
		/datum/action/spacepod/pilot/toggle_lights,
		)
	var/list/actions_types_pilot = list(/datum/action/spacepod/fire_weapons) //Actions to create when a pilot boards, deleted upon leaving
	var/list/actions_types_passenger = list(/datum/action/spacepod/fire_weapons) //Actions to create when a passenger boards, deleted upon leaving
	var/list/actions = list()

/obj/spacepod/get_cell()
	return battery

/obj/spacepod/New()
	. = ..()
	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = image(icon, icon_state="pod_damage")
		pod_overlays[FIRE] = image(icon, icon_state="pod_fire")
	bound_width = 2*WORLD_ICON_SIZE
	bound_height = 2*WORLD_ICON_SIZE
	dir = EAST
	battery = new /obj/item/weapon/cell/high()
	add_cabin()
	add_airtank()
	src.ion_trail = new /datum/effect/system/trail/space_trail()
	src.ion_trail.set_up(src)
	src.ion_trail.start()
	src.use_internal_tank = 1
	pr_int_temp_processor = new /datum/global_iterator/pod_preserve_temp(list(src))
	pr_give_air = new /datum/global_iterator/pod_tank_give_air(list(src))
	pr_lights_battery_use = new /datum/global_iterator/pod_lights_use_charge(list(src))
	ES = new(src)
	for(var/path in actions_types)
		var/datum/action/A = new path(src)
		actions.Add(A)


/obj/spacepod/Destroy()
	if(occupants.len)
		for(var/mob/living/L in occupants)
			move_outside(L)
			L.gib()
	if(ES && ES.cargo_system)
		QDEL_NULL(ES.cargo_system.stored)
	QDEL_LIST_NULL(actions)
	QDEL_NULL(pr_int_temp_processor)
	QDEL_NULL(pr_give_air)
	QDEL_NULL(pr_lights_battery_use)
	QDEL_NULL(ES)
	QDEL_NULL(battery)
	QDEL_NULL(cabin_air)
	QDEL_NULL(ion_trail)
	qdel(pod_overlays[DAMAGE])
	qdel(pod_overlays[FIRE])
	pod_overlays = null
	QDEL_NULL(internal_tank)
	..()

/obj/spacepod/proc/update_icons()
	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = image(icon, icon_state="pod_damage")
		pod_overlays[FIRE] = image(icon, icon_state="pod_fire")

	if(health <= round(initial(health)/2))
		overlays += pod_overlays[DAMAGE]
		if(health <= round(initial(health)/4))
			overlays += pod_overlays[FIRE]
		else
			overlays -= pod_overlays[FIRE]
	else
		overlays -= pod_overlays[DAMAGE]

/obj/spacepod/bullet_act(var/obj/item/projectile/P)
	if(P.damage && !P.nodamage)
		adjust_health(P.damage)
	return ..()

/obj/spacepod/proc/adjust_health(var/damage)
	var/oldhealth = health
	health = clamp(health-damage,0, maxHealth)
	var/percentage = (health / initial(health)) * 100
	var/mob/pilot = get_pilot()
	if(pilot && oldhealth > health && percentage <= 25 && percentage > 0)
		pilot.playsound_local(pilot, 'sound/effects/engine_alert2.ogg', 50, 0, 0, 0, 0)
	if(pilot && oldhealth > health && !health)
		var/mob/living/L = pilot
		L.playsound_local(L, 'sound/effects/engine_alert1.ogg', 50, 0, 0, 0, 0)
	if(health <= 0)
		spawn(0)
			var/mob/living/L = get_pilot()
			if(L)
				to_chat(L, "<big><span class='warning'>Critical damage to the vessel detected, core explosion imminent!</span></big>")
			if(ES && ES.cargo_system && ES.cargo_system.stored)
				ES.cargo_system.stored.forceMove(get_turf(src))
				if(L)
					to_chat(L, "<span class='warning'>Automatically jettisoning cargo.</span>")
			for(var/i = 10, i >= 0; --i)
				if(L && L == get_pilot())
					to_chat(L, "<span class='warning'>[i]</span>")
				if(i == 0)
					explosion(loc, 2, 4, 8)
				sleep(10)

	update_icons()

/obj/spacepod/ex_act(severity)
	switch(severity)
		if(1)
			if(has_passengers())
				for(var/mob/living/L in get_passengers())
					move_outside(L, get_turf(src))
					L.ex_act(severity + 1)
					to_chat(L, "<span class='warning'>You are forcefully thrown from \the [src]!</span>")
			var/mob/living/carbon/human/H = get_pilot()
			if(H)
				move_outside(H, get_turf(src))
				H.ex_act(severity + 1)
				to_chat(H, "<span class='warning'>You are forcefully thrown from \the [src]!</span>")
			if(ES && ES.cargo_system && ES.cargo_system.stored)
				ES.cargo_system.stored.forceMove(get_turf(src))
				ES.cargo_system.stored.ex_act(severity + 1)
			QDEL_NULL(ion_trail) // Should be nulled by qdel src in next line but OH WELL
			qdel(src)
		if(2)
			adjust_health(100)
		if(3)
			if(prob(40))
				adjust_health(50)

/obj/spacepod/attackby(obj/item/W, mob/user)
	if(iscrowbar(W))
		hatch_open = !hatch_open
		to_chat(user, "<span class='notice'>You [hatch_open ? "open" : "close"] the maintenance hatch.</span>")
		if(hatch_open && contents.len)
			var/anyitem = 0
			for(var/atom/movable/AM in contents)
				if(istype(AM,/obj/item))
					if(AM == battery || istype(AM, /obj/item/device/spacepod_equipment))
						continue //don't eject this particular item!
					if(ES && ES.cargo_system && istype(AM, ES.cargo_system.allowed_types))
						continue //it's a crate, probably!
					anyitem++
					AM.forceMove(get_turf(user))
			if(anyitem)
				visible_message("<span class='warning'>With a clatter, [anyitem > 1 ? "some items land" : "an item lands"] at the feet of [user].</span>")
		return
	if(health < maxHealth && iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.do_weld(user, src, 30, 5))
			to_chat(user, "<span class='notice'>You patch up \the [src].</span>")
			adjust_health(-rand(15,30))
			return

	if(istype(W, /obj/item/weapon/cell))
		if(!hatch_open)
			return ..()
		if(battery)
			to_chat(user, "<span class='notice'>The pod already has a battery.</span>")
			return
		if(user.drop_item(W, src))
			battery = W
			return
	if(istype(W, /obj/item/device/spacepod_equipment))
		if(!hatch_open)
			return ..()
		if(!ES)
			to_chat(user, "<span class='warning'>The pod has no equipment datum, yell at pomf</span>")
			return
		if(istype(W, /obj/item/device/spacepod_equipment/weaponry))
			if(!ES.weapons_allowed)
				to_chat(user, "<span class='notice'>The pod model does not allow for weapons to be installed.</span>")
				return
			if(ES.weapon_system)
				to_chat(user, "<span class='notice'>The pod already has a weapon system, remove it first.</span>")
				return
			else
				if(user.drop_item(W, src))
					to_chat(user, "<span class='notice'>You insert \the [W] into the equipment system.</span>")
					ES.weapon_system = W
					ES.weapon_system.my_atom = src
					//new/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapon_system(src, ES.weapon_system.verb_name, ES.weapon_system.verb_desc) //Yes, it has to be referenced like that. W.verb_name/desc doesn't compile.
					return
		if(istype(W, /obj/item/device/spacepod_equipment/locking))
			if(ES.locking_system)
				to_chat(user, "<span class = 'notice'>\The [src] already has a locking system.</span>")
				return
			else if(user.drop_item(W, src))
				to_chat(user, "<span class='notice'>You insert \the [W] into the equipment system.</span>")
				ES.locking_system = W
				ES.locking_system.my_atom = src
				return
		if(istype(W, /obj/item/device/spacepod_equipment/cargo))
			if(ES.cargo_system)
				to_chat(user, "<span class = 'notice'>\The [src] already has a cargo system.</span>")
				return
			else if(user.drop_item(W, src))
				to_chat(user, "<span class='notice'>You insert \the [W] into the equipment system.</span>")
				ES.cargo_system = W
				ES.cargo_system.my_atom = src
				return
	if(W.force)
		visible_message("<span class = 'warning'>\The [user] hits \the [src] with \the [W]</span>")
		adjust_health(W.force)
		W.on_attack(src, user)


/obj/spacepod/attack_hand(mob/user as mob)
	if(!hatch_open)
		return ..()
	if(!ES || !istype(ES))
		to_chat(user, "<span class='warning'>The pod has no equipment datum, or is the wrong type, yell at pomf.</span>")
		return
	if(locked)
		to_chat(user, "<span class = 'warning'>\The [src] is locked, disallowing access to the internal components.</span>")
		return
	var/list/possible = list()
	if(battery)
		possible.Add("Energy Cell")
	if(ES.weapon_system)
		possible.Add("Weapon System")
	/* Not yet implemented
	if(ES.engine_system)
		possible.Add("Engine System")
	if(ES.shield_system)
		possible.Add("Shield System")
	*/
	if(ES.locking_system)
		possible.Add("Locking System")
	if(ES.cargo_system)
		possible.Add("Cargo System")
	var/obj/item/device/spacepod_equipment/SPE
	switch(input(user, "Remove which equipment?", null, null) as null|anything in possible)
		if("Energy Cell")
			if(user.put_in_any_hand_if_possible(battery))
				to_chat(user, "<span class='notice'>You remove \the [battery] from the space pod</span>")
				battery = null
		if("Weapon System")
			SPE = ES.weapon_system
			if(user.put_in_any_hand_if_possible(SPE))
				to_chat(user, "<span class='notice'>You remove \the [SPE] from the equipment system.</span>")
				SPE.my_atom = null
				ES.weapon_system = null
				verbs -= typesof(/obj/item/device/spacepod_equipment/weaponry/proc)
			else
				to_chat(user, "<span class='warning'>You need an open hand to do that.</span>")
		if("Locking System")
			SPE = ES.locking_system
			if(user.put_in_any_hand_if_possible(SPE))
				to_chat(user, "<span class='notice'>You remove \the [SPE] from the equipment system.</span>")
				SPE.my_atom = null
				ES.locking_system = null
			else
				to_chat(user, "<span class='warning'>You need an open hand to do that.</span>")
		if("Cargo System")
			var/obj/item/device/spacepod_equipment/cargo/CARGOSYS = ES.cargo_system
			if(CARGOSYS.stored)
				to_chat(user, "<span class='warning'>The cargo bay is loaded, you need to empty it first.</span>")
				return
			if(user.put_in_any_hand_if_possible(CARGOSYS))
				to_chat(user, "<span class='notice'>You remove \the [CARGOSYS] from the equipment system.</span>")
				CARGOSYS.my_atom = null
				ES.cargo_system = null
			else
				to_chat(user, "<span class='warning'>You need an open hand to do that.</span>")
		/*
		if("engine system")
			SPE = ES.engine_system
			if(user.put_in_any_hand_if_possible(SPE))
				to_chat(user, "<span class='notice'>You remove \the [SPE] from the equipment system.</span>")
				ES.engine_system = null
			else
				to_chat(user, "<span class='warning'>You need an open hand to do that.</span>")
		if("shield system")
			SPE = ES.shield_system
			if(user.put_in_any_hand_if_possible(SPE))
				to_chat(user, "<span class='notice'>You remove \the [SPE] from the equipment system.</span>")
				ES.shield_system = null
			else
				to_chat(user, "<span class='warning'>You need an open hand to do that.</span>")
		*/

/obj/spacepod/emag_act(var/mob/user, var/obj/item/weapon/card/emag/E)
	locked = FALSE
	visible_message("<span class = 'warning'>\The [src] beeps twice.</span>")

/obj/spacepod/civilian
	icon_state = "pod_civ"
	desc = "A sleek civilian space pod."

/obj/spacepod/random
	icon_state = "pod_civ"

// placeholder
/obj/spacepod/random/New()
	..()
	icon_state = pick("pod_civ", "pod_black", "pod_mil", "pod_synd", "pod_gold", "pod_industrial")
	switch(icon_state)
		if("pod_civ")
			desc = "A sleek civilian space pod."
		if("pod_black")
			desc = "A plain black space pod without any distinctive markings."
		if("pod_mil")
			desc = "A dark grey space pod bearing the Nanotrasen military insignia."
		if("pod_synd")
			desc = "A menacing military space pod with \"Fuck NT\" stenciled onto the side."
		if("pod_gold")
			desc = "A civilian space pod with a gold body. It must have cost somebody a pretty penny."
		if("pod_industrial")
			desc = "A space pod with signs of wear on the plating. A spaceproof sticker designates it for performing industrial tasks."

/obj/spacepod/verb/toggle_internal_tank()
	set name = "Toggle internal airtank usage"
	set category = "Spacepod"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.get_pilot())
		return
	src.use_internal_tank = !src.use_internal_tank
	to_chat(src.get_pilot(), "<span class='notice'>Now taking air from [use_internal_tank?"internal airtank":"environment"].</span>")
	return

/obj/spacepod/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.adjust_multi(
		GAS_OXYGEN, O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature),
		GAS_NITROGEN, N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature))
	return cabin_air

/obj/spacepod/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air()
	return internal_tank

/obj/spacepod/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()
	return

/obj/spacepod/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)
	return

/obj/spacepod/return_air()
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/spacepod/proc/return_pressure()
	. = 0
	if(use_internal_tank)
		. =  cabin_air.return_pressure()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_pressure()
	return

/obj/spacepod/proc/return_temperature()
	. = 0
	if(use_internal_tank)
		. = cabin_air.return_temperature()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_temperature()
	return

/obj/spacepod/MouseDropTo(atom/moved, mob/user)
	if(!Adjacent(moved) || !Adjacent(user))
		return
	if(ES && ES.cargo_system && is_type_in_list(moved, ES.cargo_system.allowed_types))
		attempt_load_cargo(moved, user)
	if(moved != user)
		return
	attempt_move_inside(moved, user)

/obj/spacepod/MouseDropFrom(atom/over)
	if(!usr || !over)
		return
	if(!Adjacent(usr) || !Adjacent(over))
		return
	var/turf/T = get_turf(over)
	if(!occupants.Find(usr))
		var/mob/pilot = get_pilot()
		visible_message("<span class='notice'>[usr] start pulling [pilot.name] out of \the [src].</span>")
		if(do_after(usr, src, 4 SECONDS))
			move_outside(pilot, T)
			add_fingerprint(usr)
		return
	if(!Adjacent(T) || T.density)
		return
	for(var/atom/movable/A in T.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	if(occupants.Find(usr))
		move_outside(usr,T)

/obj/spacepod/verb/attempt_move_inside()
	set category = "Spacepod"
	set name = "Enter / Exit Pod"
	set src in oview(1)

	if(occupants.Find(usr))
		move_outside(usr, get_turf(src))
		return

	if(locked)
		to_chat(usr, "<span class = 'warning'>\The [src] is locked.</span>")
		return

	if(usr.incapacitated() || usr.lying) //are you cuffed, dying, lying, stunned or other
		return
	if (!ishigherbeing(usr))
		return
/*
	if (usr.abiotic())
		to_chat(usr, "<span class='notice'><B>Subject cannot have abiotic items on.</B></span>")
		return
*/
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting the life sucked out of you by \the [M]!")
			return
//	to_chat(usr, "You start climbing into [src.name]")

	visible_message("<span class='notice'>[usr] starts to climb into \the [src].</span>")

	if(do_after(usr, src, 4 SECONDS))
		var/list/passengers = get_passengers()
		if(!get_pilot() || passengers.len < passenger_limit)
			move_into_pod(usr)
		else
			to_chat(usr, "<span class = 'warning'>Not enough room inside \the [src].</span>")
	else
		to_chat(usr, "You stop entering the pod.")
	return

/obj/spacepod/proc/attempt_load_cargo(atom/movable/moved, mob/user)
	if(!ES || !istype(ES))
		to_chat(user, "<span class='warning'>The pod has no equipment datum, or is the wrong type, yell at pomf.</span>")
		return
	if(!ES.cargo_system)
		to_chat(user, "<span class='warning'>The pod has no cargo system.</span>")
		return
	if(locked)
		to_chat(usr, "<span class = 'warning'>\The [src] is locked.</span>")
		return
	if(usr.incapacitated() || usr.lying) //are you cuffed, dying, lying, stunned or other
		return
	if (!ishigherbeing(usr))
		return
	if(ES.cargo_system.stored)
		to_chat(user, "<span class='warning'>The pod has no room in its cargo bay.</span>")

	visible_message("<span class='notice'>[usr] starts to load \the [moved] into \the [src].</span>")

	if(do_after(usr, src, 4 SECONDS))
		if(ES.cargo_system.stored)
			//Something loaded when you weren't looking!
			to_chat(user, "<span class='warning'>The pod has no room in its cargo bay.</span>")
			return
		moved.forceMove(src)
		ES.cargo_system.stored = moved
		src.add_fingerprint(usr)
		moved.add_fingerprint(usr)
		to_chat(usr, "<span class = 'notice'>You load \the [moved] into \the [src].</span>")
	else
		to_chat(usr, "You stop loading the pod.")
	return

/obj/spacepod/verb/attempt_unload_cargo()
	set category = "Spacepod"
	set name = "Unload Cargo"
	set src in oview(1)

	if(!ES || !istype(ES))
		to_chat(usr, "<span class='warning'>The pod has no equipment datum, or is the wrong type, yell at pomf.</span>")
		return
	if(!ES.cargo_system)
		to_chat(usr, "<span class='warning'>The pod has no cargo system.</span>")
		return
	if(locked)
		to_chat(usr, "<span class = 'warning'>\The [src] is locked.</span>")
		return
	if(usr.incapacitated() || usr.lying) //are you cuffed, dying, lying, stunned or other
		return
	if (!ishigherbeing(usr))
		return
	if(!ES.cargo_system.stored)
		to_chat(usr, "<span class='warning'>The pod has nothing in the cargo bay.</span>")
		return

	visible_message("<span class='notice'>[usr] starts to unload \the [src].</span>")

	if(do_after(usr, src, 4 SECONDS))
		if(!ES.cargo_system.stored)
			//Something unloaded when you weren't looking!
			return
		ES.cargo_system.stored.forceMove(get_turf(src))
		src.add_fingerprint(usr)
		ES.cargo_system.stored.add_fingerprint(usr)
		to_chat(usr, "<span class = 'notice'>You unload \the [ES.cargo_system.stored] from \the [src].</span>")
		ES.cargo_system.stored = null
	else
		to_chat(usr, "You stop unloading the pod.")
	return

/obj/spacepod/proc/attempt_cargo_resist(var/mob/living/user, var/obj/contained)
	if(!ES || !istype(ES))
		to_chat(user, "<span class='warning'>The pod has no equipment datum, or is the wrong type, yell at pomf.</span>")
		return
	if(!ES.cargo_system)
		to_chat(user, "<span class='warning'>Something's resisting in a spacepod's cargo bay with no cargo bay. Tell your local coder...</span>")
		return
	user.visible_message("<span class='danger'>\The [src]'s cargo hatch begins to make banging sounds!</span>",
						  "<span class='warning'>You slam on the back of \the [contained] and start trying to bust out of \the [src]'s cargo bay! (This will take about 30 seconds)</span>")
	if(do_after(user, src, 30 SECONDS))
		if(!ES.cargo_system.stored)
			//Something unloaded when you weren't looking!
			return
		ES.cargo_system.stored.forceMove(get_turf(src))
		user.visible_message("<span class='danger'>\The [src]'s cargo hatch pops open, and \the [contained] inside pops out!</span>",
						"<span class='warning'>You manage to pop \the [src]'s cargo door open!</span>")
		ES.cargo_system.stored = null

/datum/global_iterator/pod_preserve_temp  //normalizing cabin air temperature to 20 degrees celsium
	delay = 20
/datum/global_iterator/pod_preserve_temp/process(var/obj/spacepod/spacepod)
	if(spacepod.cabin_air && spacepod.cabin_air.return_volume() > 0)
		var/delta = spacepod.cabin_air.temperature - T20C
		spacepod.cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))

/datum/global_iterator/pod_tank_give_air
	delay = 15

/datum/global_iterator/pod_tank_give_air/process(var/obj/spacepod/spacepod)
	if(spacepod.internal_tank)
		var/datum/gas_mixture/tank_air = spacepod.internal_tank.return_air()
		var/datum/gas_mixture/cabin_air = spacepod.cabin_air

		var/release_pressure = ONE_ATMOSPHERE
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		var/transfer_moles = 0
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				transfer_moles = pressure_delta * cabin_air.return_volume() / (cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
				cabin_air.merge(removed)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/datum/gas_mixture/t_air = spacepod.get_turf_air()
			pressure_delta = cabin_pressure - release_pressure
			if(t_air)
				pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0) //if location pressure is lower than cabin pressure
				transfer_moles = pressure_delta * cabin_air.return_volume() / (cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
				if(t_air)
					t_air.merge(removed)
				else //just delete the cabin gas, we're in space or some shit
					qdel(removed)
	else
		return stop()

/datum/global_iterator/pod_lights_use_charge
	delay = 10

/datum/global_iterator/pod_lights_use_charge/process(var/obj/spacepod/spacepod)
	if(spacepod.battery && spacepod.lights_enabled)
		if(spacepod.battery.charge > 0)
			spacepod.battery.use(SPACEPOD_LIGHTS_CONSUMPTION)
		else
			spacepod.toggle_lights()

/obj/spacepod/proc/toggle_lights()
	if(lights_enabled)
		set_light(SPACEPOD_LIGHTS_RANGE_OFF)
		to_chat(usr, "<span class='notice'>Lights disabled.</span>")
	else
		set_light(SPACEPOD_LIGHTS_RANGE_ON)
		to_chat(usr, "<span class='notice'>Lights enabled.</span>")
	lights_enabled = !lights_enabled

/obj/spacepod/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	var/oldloc = loc
	. = ..()
	if(Dir && (oldloc != NewLoc))
		loc.Entered(src, oldloc)

/obj/spacepod/Process_Spacemove(var/check_drift = 0, mob/user)
	var/dense_object = 0
	if(!user)
		for(var/direction in list(NORTH, NORTHEAST, EAST))
			var/turf/cardinal = get_step(src, direction)
			if(istype(cardinal, /turf/space))
				continue
			dense_object++
			break
	if(!dense_object)
		return 0
	inertia_dir = 0
	return 1

/obj/spacepod/relaymove(mob/user, direction)
	if(user != get_pilot())
		return 0 //Stop hogging the wheel!
	if(move_delayer.blocked())
		return 0
	var/moveship = 1
	if(battery && battery.charge >= ES.movement_charge && health)
		src.dir = direction

		if(inertia_dir == turn(direction, 180))
			inertia_dir = 0
			moveship = 0

		if(moveship)
			set_glide_size(DELAY2GLIDESIZE(movement_delay))
			Move(get_step(src,direction), direction)
			if(istype(src.loc, /turf/space))
				inertia_dir = direction
	else
		if(!battery)
			to_chat(user, "<span class='warning'>No energy cell detected.</span>")
		else if(battery.charge < ES.movement_charge)
			to_chat(user, "<span class='warning'>Not enough charge left.</span>")
		else if(!health)
			to_chat(user, "<span class='warning'>\The [src] is currently exploding.</span>")
		else
			to_chat(user, "<span class='warning'>Unknown error has occurred, yell at pomf.</span>")
		return 0
	battery.use(ES.movement_charge)
	move_delayer.delayNext(round(movement_delay,world.tick_lag))

/obj/spacepod/process_inertia(turf/start)
	set waitfor = 0

	if(Process_Spacemove(1))
		inertia_dir = 0
		return

	sleep(INERTIA_MOVEDELAY)

	if(loc == start)
		if(inertia_dir)
			set_glide_size(DELAY2GLIDESIZE(INERTIA_MOVEDELAY))
			step(src, inertia_dir)


/obj/effect/landmark/spacepod/random //One of these will be chosen from across all Z levels to receive a pod in gameticker.dm
	name = "spacepod spawner"
	invisibility = 101
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1


/obj/effect/landmark/spacepod/guaranteed //We're not messing around: we want a guaranteed pod!
	name = "guaranteed spacepod spawner"
	invisibility = 101
	anchored = 1
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"

/obj/effect/landmark/spacepod/guaranteed/New()
	sleep(10)
	new /obj/spacepod/random(get_turf(src))
	qdel(src)

/obj/spacepod/dissolvable()
	return 0

/obj/spacepod/proc/move_into_pod(var/mob/living/L)
	if(L && L.client && (L in range(1)))
		L.reset_view(src)
		L.stop_pulling()
		L.forceMove(src)
		src.add_fingerprint(L)
		adjust_occupants(L, STATUS_ADD)
		return 1
	return 0

/obj/spacepod/proc/get_pilot()
	if(occupants.len)
		return occupants[1]
	return 0

/obj/spacepod/proc/has_passengers()
	if(occupants.len > 1)
		return occupants.len-1
	return 0

/obj/spacepod/proc/get_passengers()
	var/list/L = list()
	if(occupants.len > 1)
		L = occupants.Copy(2)
	return L

/obj/spacepod/proc/toggle_passengers()
	if(usr!=get_pilot())
		return
	src.passengers_allowed = !passengers_allowed
	to_chat(src.get_pilot(), "<span class='notice'>Now [passengers_allowed?"allowing passengers":"disallowing passengers, and ejecting any current passengers"].</span>")
	if(!passengers_allowed && has_passengers())
		for(var/mob/living/L in get_passengers())
			to_chat(L, "<span class='warning'>Ejection sequence activated: Ejecting in 3 seconds</span>")
			spawn(30)
				if(occupants.Find(L) && L.loc == src)
					playsound(src, 'sound/weapons/rocket.ogg', 50, 1)
					var/turf/T = get_turf(src)
					var/turf/target_turf
					move_outside(L,T)
					target_turf = get_edge_target_turf(T, opposite_dirs[dir])
					L.throw_at(target_turf,100,3)

/obj/spacepod/proc/move_outside(var/mob/occupant, var/turf/exit_turf)
	if(!exit_turf)
		exit_turf = get_turf(src)
	adjust_occupants(occupant, STATUS_REMOVE)
	occupant.forceMove(exit_turf)

/obj/spacepod/proc/adjust_occupants(var/mob/user, var/status)
	if(status == STATUS_REMOVE)
		var/pilot = get_pilot()
		if(user == pilot) //They're the pilot
			for(var/datum/action/S in actions)
				if(istype (S, /datum/action/spacepod/pilot)) //Keep these
					S.Remove(user)
				else if(S.owner == user) //Remove these
					qdel(S)
					actions.Remove(S)
		else //They're a passenger
			for(var/datum/action/spacepod/S in actions)
				if(S.owner == user) //Remove these
					qdel(S)
					actions.Remove(S)
		occupants.Remove(user)
		if(get_pilot() && pilot != get_pilot()) //NEW PILOT
			var/mob/living/new_pilot = get_pilot()
			if(!new_pilot)
				return
			to_chat(new_pilot, "<span class = 'notice'>You are now the pilot of \the [src].</span>")
			for(var/datum/action/spacepod/S in actions)
				if(S.owner == new_pilot) //Remove these
					qdel(S)
					actions.Remove(S)
			for(var/datum/action/spacepod/pilot/P in actions)
				P.Grant(new_pilot)
			for(var/path in actions_types_pilot)
				var/datum/action/A = new path(src)
				actions.Add(A)
				A.Grant(new_pilot)
	else if(status == STATUS_ADD)
		occupants.Add(user)
		if(user == get_pilot()) //They're the new pilot
			for(var/datum/action/spacepod/pilot/P in actions)
				P.Grant(user)
			for(var/path in actions_types_pilot)
				var/datum/action/A = new path(src)
				actions.Add(A)
				A.Grant(user)
		else //They're a new passenger
			for(var/path in actions_types_passenger)
				var/datum/action/A = new path(src)
				actions.Add(A)
				A.Grant(user)

/obj/spacepod/proc/change_speed()
	if(usr != get_pilot())
		return
	if(movement_delay == SPACEPOD_MOVEDELAY_FAST)
		movement_delay = SPACEPOD_MOVEDELAY_SLOW
		to_chat(usr, "<span class='notice'>Thrusters strength: low.</span>")
	else if(movement_delay == SPACEPOD_MOVEDELAY_MEDIUM)
		movement_delay = SPACEPOD_MOVEDELAY_FAST
		to_chat(usr, "<span class='notice'>Thrusters strength: high.</span>")
	else
		movement_delay = SPACEPOD_MOVEDELAY_MEDIUM
		to_chat(usr, "<span class='notice'>Thrusters strength: medium.</span>")

/obj/spacepod/proc/toggle_passenger_guns()
	if(usr!=get_pilot())
		return
	src.passenger_fire = !passenger_fire
	to_chat(src.get_pilot(), "<span class='notice'>Now [passenger_fire?"allowing passengers to fire spacepod weaponry":"disallowing passengers to fire spacepod weaponry"].</span>")
	playsound(src, 'sound/items/flashlight_on.ogg', 50, 1)

/obj/spacepod/taxi
	name = "taxi pod"
	icon_state = "pod_taxi"
	desc = "Brightly coloured to attract attention of potential passengers. Has room for multiple passengers at the expense of weapons."
	passenger_limit = 3
	actions_types = list( //Actions to create and hold for the pilot
		/datum/action/spacepod/pilot/toggle_passengers,
		/datum/action/spacepod/pilot/change_speed,
		/datum/action/spacepod/pilot/toggle_lights,
		)
	actions_types_pilot = list()
	actions_types_passenger = list()

/obj/spacepod/taxi/New()
	..()
	ES.weapons_allowed = 0

#undef DAMAGE
#undef FIRE

#undef SPACEPOD_MOVEDELAY_FAST
#undef SPACEPOD_MOVEDELAY_MEDIUM
#undef SPACEPOD_MOVEDELAY_SLOW
#undef SPACEPOD_MOVEDELAY_DEFAULT
#undef SPACEPOD_LIGHTS_CONSUMPTION
#undef SPACEPOD_LIGHTS_RANGE_ON
#undef SPACEPOD_LIGHTS_RANGE_OFF

#undef STATUS_REMOVE
#undef STATUS_ADD
