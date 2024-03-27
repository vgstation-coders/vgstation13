var/list/mass_drivers = list()
/obj/machinery/mass_driver
	name = "mass driver"
	desc = "Shoots things into space."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mass_driver"
	anchored = 1.0
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 2
	active_power_usage = 50
	machine_flags = EMAGGABLE | MULTITOOL_MENU
	layer = BELOW_TABLE_LAYER

	var/power = 1.0
	var/code = 1.0
	id_tag = "default"
	var/drive_range = 50 //this is mostly irrelevant since current mass drivers throw into space, but you could make a lower-range mass driver for interstation transport or something I guess.

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag
	)

/obj/machinery/mass_driver/New()
	..()
	mass_drivers += src
	check_competition()

/obj/machinery/mass_driver/proc/check_competition(var/turf/T = get_turf(src))
	for(var/obj/machinery/mass_driver/M in T)
		if(M == src)
			continue
		else
			message_admins("Two mass drivers were placed on the same tile. This should not happen.(<A href='?_src_=holder;jumpto=\ref[T]'><b>Jump to</b></A>)")
			qdel(src)
			break

/obj/machinery/mass_driver/Destroy()
	mass_drivers -= src
	..()

/obj/machinery/mass_driver/attackby(obj/item/weapon/W, mob/user as mob)

	. = ..()
	if(.)
		return .

	if(W.is_screwdriver(user))
		to_chat(user, "You begin to unscrew the bolts off \the [src]...")
		W.playtoolsound(src, 50)
		if(do_after(user, src, 30))
			var/obj/machinery/mass_driver_frame/F = new(get_turf(src))
			F.dir = src.dir
			F.anchored = 1
			F.construct.index = 1
			F.icon_state = "mass_driver_b4"
			qdel(src)
		return 1

	return ..()

/obj/machinery/mass_driver/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<ul>
	<li>[format_tag("ID Tag","id_tag")]</li>
	</ul>"}

/obj/machinery/mass_driver/proc/drive(amount)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		return
	use_power(500*power)
	var/O_limit = 0
	var/atom/target = get_edge_target_turf(src, dir)
	for(var/atom/movable/O in loc)
		if(!O.anchored||istype(O, /obj/mecha))//Mechs need their launch platforms.
			O_limit++
			if(istype(O,/obj/mecha))
				var/obj/mecha/M = O
				M.crashing = null
			if(O_limit >= 20)//so no more than 20 items are sent at a time, probably for counter-lag purposes
				break
			use_power(500)
			spawn()
				var/coef = 1
				if(emagged)
					coef = 5
				O.throw_at(target, drive_range * power * coef, power * coef)
	flick("mass_driver1", src)
	return

/obj/machinery/mass_driver/emp_act(severity)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		return
	drive()
	..(severity)

/obj/machinery/mass_driver/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		if(user)
			to_chat(user, "You hack the Mass Driver, radically increasing the force at which it'll throw things. Better not stand in its way.")
		return 1
	return -1 //GROSS

////////////////MASS BUMPER///////////////////

/obj/machinery/mass_driver/bumper
	name = "mass bumper"
	desc = "Now you're here, now you're over there."
	density = 1

/obj/machinery/mass_driver/bumper/Bumped(M as mob|obj)
	setDensity(FALSE)
	step(M, get_dir(M,src))
	spawn(1)
		setDensity(TRUE)
	drive()
	return

////////////////MASS DRIVER FRAME///////////////////

/obj/machinery/mass_driver_frame
	name = "mass driver frame"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mass_driver_b0"
	density = 0
	anchored = 0
	var/datum/construction/reversible/construct

/obj/machinery/mass_driver_frame/New()
	. = ..()
	construct = new /datum/construction/reversible/mass_driver(src)

/obj/machinery/mass_driver_frame/attackby(var/obj/item/W, var/mob/user)
	if(!construct || !construct.action(W, user))
		..()

/obj/machinery/mass_driver_frame/verb/rotate()
	set category = "Object"
	set name = "Rotate Frame"
	set src in view(1)

	if (usr.isUnconscious() || usr.restrained())
		return

	src.dir = turn(src.dir, -90)
	return

/datum/construction/reversible/mass_driver
	result = /obj/machinery/mass_driver
	decon = list(/obj/item/stack/sheet/plasteel = 3)
	steps = list(
				//5
				list(
					Co_NEXTSTEP = list(Co_KEY="is_screwdriver",
						Co_VIS_MSG = "<span class = 'notice'>{USER} finalize{s} {HOLDER}.</span>"),
					Co_BACKSTEP = list(Co_KEY=/obj/item/tool/crowbar,
						Co_START_MSG = "{USER} begin{s} to pry off the grille from {HOLDER}.",
						Co_VIS_MSG = "<span class = 'notice'>{USER} pr{ies} off the grille from {HOLDER}.</span>",
						Co_DELAY = 10),
					),
				//4
				list(
					Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/rods,
						Co_START_MSG = "{USER} begin{s} to complete {HOLDER}.",
						Co_VIS_MSG = "<span class = 'notice'>{USER} add{s} a grille to {HOLDER}.</span>",
						Co_START_SOUND = 'sound/items/Deconstruct.ogg',
						Co_DELAY = 20,
						Co_AMOUNT = 3),
					Co_BACKSTEP = list(Co_KEY=/obj/item/tool/wirecutters,
						Co_START_MSG = "{USER} begin{s} to remove wiring from {HOLDER}.",
						Co_VIS_MSG = "<span class = 'notice'>{USER} remove{s} cables from {HOLDER}.</span>",
						Co_DELAY = 10),
					),
				//3
				list(
					Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/cable_coil,
						Co_START_MSG = "{USER} start{s} adding cables to {HOLDER}.",
						Co_VIS_MSG = "<span class = 'notice'>{USER} add{s} cables to {HOLDER}.</span>",
						Co_DELAY = 20,
						Co_AMOUNT = 3),
					Co_BACKSTEP = list(Co_KEY=/obj/item/tool/weldingtool,
						Co_START_MSG = "{USER} begin{s} to un-weld {HOLDER} from the floor.",
						Co_VIS_MSG = "<span class = 'notice'>{USER} un-weld{s} {HOLDER} from the floor.</span>",
						Co_AMOUNT = 1,
						Co_DELAY = 40),
					),
				//2
				list(
					Co_NEXTSTEP = list(Co_KEY=/obj/item/tool/weldingtool,
						Co_START_MSG = "{USER} begin{s} to weld {HOLDER} to the floor.",
						Co_VIS_MSG = "<span class = 'notice'>{USER} weld{s} {HOLDER} to the floor.</span>",
						Co_AMOUNT = 1,
						Co_DELAY = 40),
					Co_BACKSTEP = list(Co_KEY=/obj/item/tool/wrench,
						Co_START_MSG = "{USER} begin{s} to de-anchor {HOLDER} from the floor.",
						Co_VIS_MSG = "<span class = 'notice'>{USER} de-anchor{s} {HOLDER} from the floor.</span>",
						Co_DELAY = 10),
					),
				//1
				list(
					Co_NEXTSTEP = list(Co_KEY=/obj/item/tool/wrench,
						Co_START_MSG = "{USER} begin{s} to anchor {HOLDER} on the floor.",
						Co_VIS_MSG = "<span class = 'notice'>{USER} anchor{s} {HOLDER} to the floor.</span>",
						Co_DELAY = 50),
					Co_BACKSTEP = list(Co_KEY=/obj/item/tool/weldingtool,
						Co_START_MSG = "{USER} begin{s} to cut {HOLDER} apart...",
						Co_VIS_MSG = "<span class = 'notice'>{USER} detach{es} the plasteel sheets from each other.</span>",
						Co_AMOUNT = 1,
						Co_DELAY = 30),
					),
				)

/datum/construction/reversible/mass_driver/update_icon(index as num)
	holder.icon_state = "mass_driver_b[steps.len-index]"

/datum/construction/reversible/mass_driver/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/reversible/mass_driver/update_index(diff, mob/user)
	. = ..()
	if(ismovable(holder))
		var/atom/movable/M = holder
		M.anchored = index < 5

/datum/construction/reversible/mass_driver/check_step(atom/used_atom, mob/user)
	if(index == 5)
		var/turf/T = get_turf(holder)
		if(!T)
			return 0
		for(var/obj/machinery/M in T)
			if(M == holder)
				continue
			if(istype(M, /obj/machinery/mass_driver_frame) || istype(M, /obj/machinery/mass_driver))
				to_chat(user, "<span class = 'notice'>You can't anchor \the [holder], as there's a mass driver in that location already.</span>")
				return 0
	return ..()

/datum/construction/reversible/mass_driver/spawn_result(mob/user as mob)
	if(result)
//		testing("[user] finished a [result]!")
		var/atom/R = new result(get_turf(holder))
		R.dir = holder.dir
		spawn()
			QDEL_NULL (holder)

	feedback_inc("mass_driver_created",1)
