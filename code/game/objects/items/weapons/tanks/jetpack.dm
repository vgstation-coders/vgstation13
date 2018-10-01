

/obj/item/weapon/tank/jetpack
	name = "Jetpack (Empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	w_class = W_CLASS_MEDIUM
	item_state = "jetpack"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	var/datum/effect/effect/system/trail/ion_trail
	var/on = 0.0
	var/stabilization_on = 0
	var/volume_rate = 500              //Needed for borg jetpack transfer
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/jetpack_stabilization,/datum/action/item_action/toggle_jetpack)

/obj/item/weapon/tank/jetpack/proc/toggle_rockets()
	src.stabilization_on = !( src.stabilization_on )
	to_chat(usr, "You toggle the stabilization [stabilization_on? "on":"off"].")
	return


/obj/item/weapon/tank/jetpack/proc/toggle()
	on = !on
	if(on)
		icon_state = "[icon_state]-on"
//			item_state = "[item_state]-on"
		ion_trail.start()
	else
		icon_state = initial(icon_state)
//			item_state = initial(item_state)
		ion_trail.stop()
	return


/obj/item/weapon/tank/jetpack/proc/allow_thrust(num, mob/living/user as mob)
	if(!(src.on))
		return 0
	if((num < 0.005 || src.air_contents.total_moles() < num))
		src.toggle()
		return 0

	var/datum/gas_mixture/G = src.air_contents.remove(num)
	var/allgases = G.total_moles()

	if(allgases >= 0.005)
		return 1

	qdel(G)
	G = null
	return

/datum/action/item_action/toggle_jetpack
	name = "Toggle Jetpack"

/datum/action/item_action/toggle_jetpack/Trigger()
	var/obj/item/weapon/tank/jetpack/T = target
	if(!istype(T))
		return
	T.toggle()

/datum/action/item_action/jetpack_stabilization
	name = "Toggle Jetpack Stabilization"

/datum/action/item_action/jetpack_stabilization/IsAvailable()
	var/obj/item/weapon/tank/jetpack/J = target
	if(!istype(J) || !J.on)
		return 0
	return ..()

/datum/action/item_action/jetpack_stabilization/Trigger()
	var/obj/item/weapon/tank/jetpack/T = target
	if(!istype(T))
		return
	T.toggle_rockets()

/obj/item/weapon/tank/jetpack/New()
	. = ..()
	ion_trail = new /datum/effect/effect/system/trail()
	ion_trail.set_up(src)

/obj/item/weapon/tank/jetpack/void
	name = "Void Jetpack (Oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	item_state =  "jetpack-void"

/obj/item/weapon/tank/jetpack/void/New()
	. = ..()
	air_contents.adjust_gas(GAS_OXYGEN, (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/jetpack/oxygen
	name = "Jetpack (Oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	item_state = "jetpack"

/obj/item/weapon/tank/jetpack/oxygen/New()
	. = ..()
	air_contents.adjust_gas(GAS_OXYGEN, (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/jetpack/oxygen/nukeops
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. This one is unusually heavy."
	volume = 105 //please keep this restricted to actual nuke ops, it might trigger bomb autism if used in transfer valves

/obj/item/weapon/tank/jetpack/nitrogen
	name = "Jetpack (Nitrogen)"
	desc = "A tank of compressed nitrogen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack-red"
	item_state = "jetpack-red"

/obj/item/weapon/tank/jetpack/nitrogen/New()
	. = ..()
	air_contents.adjust_gas(GAS_NITROGEN, (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/jetpack/carbondioxide
	name = "Jetpack (Carbon Dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	distribute_pressure = 0
	icon_state = "jetpack-black"
	item_state =  "jetpack-black"

/obj/item/weapon/tank/jetpack/carbondioxide/New()
	. = ..()
	air_contents.adjust_gas(GAS_CARBON, (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/jetpack/carbondioxide/silicon
	actions_types = list(/datum/action/item_action/jetpack_stabilization,/datum/action/item_action/toggle_jetpack)
