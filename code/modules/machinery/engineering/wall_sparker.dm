// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "Mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	var/id_tag = null
	var/disable = 0
	var/last_spark = 0
	var/base_state = "migniter"
	anchored = 1

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

/obj/machinery/sparker/New()
	..()

/obj/machinery/sparker/power_change()
	if ( powered() && disable == 0 )
		stat &= ~NOPOWER
		icon_state = "[base_state]"
//		src.sd_SetLuminosity(2)
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]-p"
//		src.sd_SetLuminosity(0)

/obj/machinery/sparker/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	if (istype(W, /obj/item/weapon/screwdriver))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("\red [user] has disabled the [src]!", "\red You disable the connection to the [src].")
			icon_state = "[base_state]-d"
		if (!src.disable)
			user.visible_message("\red [user] has reconnected the [src]!", "\red You fix the connection to the [src].")
			if(src.powered())
				icon_state = "[base_state]"
			else
				icon_state = "[base_state]-p"

/obj/machinery/sparker/attack_ai()
	if (src.anchored)
		return src.spark()
	else
		return

/obj/machinery/sparker/proc/spark()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_spark && world.time < src.last_spark + 50))
		return


	flick("[base_state]-spark", src)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, src)
	s.start()
	src.last_spark = world.time
	use_power(1000)
	var/turf/location = src.loc
	if (isturf(location))
		location.hotspot_expose(1000,500,1,surfaces=0)
	return 1

/obj/machinery/sparker/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	spark()
	..(severity)