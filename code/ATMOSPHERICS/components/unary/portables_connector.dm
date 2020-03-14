/obj/machinery/atmospherics/unary/portables_connector
	icon = 'icons/obj/atmospherics/portables_connector.dmi'
	icon_state = "hintact"

	name = "Connector Port"
	desc = "For connecting portables devices related to atmospherics control."

	var/obj/machinery/portable_atmospherics/connected_device

	var/on = 0
	use_power = 0
	level = 0


/obj/machinery/atmospherics/unary/portables_connector/New()
	initialize_directions = dir
	..()

/obj/machinery/atmospherics/unary/portables_connector/hide(var/i) //to make the little pipe section invisible, the icon changes.
	update_icon()

/obj/machinery/atmospherics/unary/portables_connector/process()
	. = ..()
	if(!on)
		return
	if(!connected_device)
		on = 0
		return
	if(network)
		network.update = 1
	return 1

/obj/machinery/atmospherics/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()

	if(node1)
		node1.disconnect(src)
		if(network)
			returnToPool(network)

	node1 = null

	..()

/obj/machinery/atmospherics/unary/portables_connector/Uncrossed(var/atom/movable/AM)
	if(!connected_device)
		return
	if(AM == connected_device)
		connected_device.disconnect()

/obj/machinery/atmospherics/unary/portables_connector/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node1)
		return network

	if(reference==connected_device)
		return network

	return null

/obj/machinery/atmospherics/unary/portables_connector/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(connected_device)
		results += connected_device.air_contents

	return results


/obj/machinery/atmospherics/unary/portables_connector/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (!W.is_wrench(user))
		return ..()
	if (connected_device)
		to_chat(user, "<span class='warning'>You cannot unwrench this [src], dettach [connected_device] first.</span>")
		return 1
	if (locate(/obj/machinery/portable_atmospherics, src.loc))
		return 1
	return ..()
