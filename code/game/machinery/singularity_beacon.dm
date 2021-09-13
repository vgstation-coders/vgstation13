
/obj/machinery/singularity_beacon
	name = "singularity beacon"
	desc = "A suspicious-looking beacon. It looks like one of those snazzy state-of-the-art bluespace devices."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "beacon0"
	anchored = 0
	density = 1
	machine_flags = WRENCHMOVE | FIXED2WORK
	layer = MOB_LAYER
	plane = MOB_PLANE

	light_color = LIGHT_COLOR_RED
	light_range_on = 2
	light_power_on = 2

	var/obj/item/weapon/cell/cell
	var/power_load = 1000 //A bit ugly. How much power this machine needs per tick. Equivalent to one minute on 30k W battery, two second ticks
	var/power_draw = 0 //If there's spare power on the grid, cannibalize it to charge the beacon's battery
	var/active = 0 //It doesn't use APCs, so use_power wouldn't really suit it
	var/icontype = "beacon"
	var/obj/structure/cable/attached = null

/obj/machinery/singularity_beacon/get_cell()
	return cell

/obj/machinery/singularity_beacon/New()

	..()

	cell = new /obj/item/weapon/cell/hyper(src) //Singularity beacons are wasteful as fuck, that state-of-the-art cell will last a single minute

/obj/machinery/singularity_beacon/examine(mob/user)

	..()

	if(anchored)
		to_chat(user, "<span class='info'>It appears firmly secured to the floor. Nothing a wrench can't undo.</span>")
	to_chat(user, "<span class='info'>It features a power port. [attached ? "A power cable is running through it":"It looks like a power cable can be ran straight through it to power it"].</span>")
	if(active)
		to_chat(user, "<span class='info'>It is slowly pulsing red and emitting a deep humming sound.</span>")

/obj/machinery/singularity_beacon/proc/activate(mob/user = null)
	if(!anchored) //Sanity
		return
	if(!check_power())
		if(user)
			user.visible_message("<span class='warning'>[user] tries to start \the [src], but it shuts down halfway.</span>", \
			"<span class='warning'>You try to start \the [src], but it shuts down halfway. Looks like a power issue.</span>")
		else
			visible_message("<span class='warning'>\The [src] suddenly springs to life, only to shut down halfway through startup.</span>")
		return
	for(var/obj/machinery/singularity/singulo in power_machines)
		if(singulo.z == z)
			singulo.target = src
	icon_state = "[icontype]1"
	active = 1
	set_light(light_range_on, light_power_on, light_color)
	if(user)
		user.visible_message("<span class='warning'>[user] starts up \the [src].</span>", \
		"<span class='notice'>You start up \the [src].</span>")
	else
		visible_message("<span class='warning'>\The [src] suddenly springs to life.</span>")

/obj/machinery/singularity_beacon/proc/deactivate(mob/user = null)
	for(var/obj/machinery/singularity/singulo in power_machines)
		if(singulo.target == src)
			singulo.target = null
	icon_state = "[icontype]0"
	active = 0
	kill_light()
	if(user)
		user.visible_message("<span class='warning'>[user] shuts down \the [src].</span>", \
		"<span class='notice'>You shut down \the [src].</span>")
	else
		visible_message("<span class='warning'>\The [src] suddenly shuts down.</span>")

/obj/machinery/singularity_beacon/attack_ai(mob/user as mob)
	to_chat(user, "<span class='warning'>You try to interface with \the [src], but it throws a strange encrypted error message.</span>")
	return

/obj/machinery/singularity_beacon/attack_hand(var/mob/user as mob)
	user.delayNextAttack(10) //Prevent spam toggling, otherwise you can brick the cell very quickly
	if(anchored)
		if(!attached)
			var/turf/T = get_turf(src)
			if(isturf(T) && !T.intact)
				attached = locate() in T
			if(attached)
				user.visible_message("<span class='notice'>[user] reaches for the exposed cabling and carefully runs it through \the [src]'s power port.</span>", \
				"<span class='notice'>You reach for the exposed cabling and carefully run it through \the [src]'s power port.</span>")
				return //Need to attack again to actually start
		return active ? deactivate(user) : activate(user)
	else
		to_chat(user, "<span class='warning'>\The [src] doesn't work on the fly, wrench it down first.</span>")
		return

/obj/machinery/singularity_beacon/wrenchAnchor(var/mob/user, var/obj/item/I)
	if(active)
		to_chat(user, "<span class='warning'>Turn off \the [src] first.</span>")
		return FALSE
	. = ..()
	if(!.)
		return
	if(attached)
		attached = null //Reset attached cable

/obj/machinery/singularity_beacon/Destroy()
	new /datum/artifact_postmortem_data(src,TRUE)//we only archive those that were excavated
	if(active)
		deactivate()
	if(cell)
		qdel(cell)
		cell = null
	..()

/*
* Added for a simple way to check power. Verifies that the beacon
* is connected to a wire, the wire is part of a powernet (that part's
* sort of redundant, since all wires either join or create one when placed)
* and that the powernet has at least 1500 power units available for use.
* Doesn't use them, though, just makes sure they're there.
* - QualityVan, Aug 11 2012
*/

//Simplified check for power. If we can charge straight out of the grid, do it
/obj/machinery/singularity_beacon/proc/check_wire_power()
	if(!attached) //No wire, move straight to battery power
		return 0
	var/datum/powernet/PN = attached.get_powernet()
	if(!PN) //Powernet is dead
		return 0
	if(PN.avail < power_load) //Cannot drain enough power, needs 1500 per tick, move to battery
		return 0
	else
		PN.load += power_load
		if(cell && cell.charge < cell.maxcharge && cell.charge > 0 && PN.netexcess)
			power_draw = min(cell.maxcharge - cell.charge, PN.netexcess) //Draw power directly from excess power
			PN.load += power_draw
			cell.give(power_draw) //We drew power from the grid, charge the cell
		return 1

//Use up the battery if powernet check fails
/obj/machinery/singularity_beacon/proc/check_battery_power()

	if(cell && cell.charge > power_load)
		cell.use(power_load)
		return 1
	else //Nothing here either
		return 0

//Composite of the two, called at every process
/obj/machinery/singularity_beacon/proc/check_power()

	return check_wire_power() || check_battery_power()

/obj/machinery/singularity_beacon/process()
	if(!active)
		return
	if(!anchored) //If it got unanchored "inexplicably"
		deactivate()
	else
		if(!check_power()) //No power
			deactivate()

/obj/machinery/singularity_beacon/syndicate
	icontype = "beaconsynd"
	icon_state = "beaconsynd0"
