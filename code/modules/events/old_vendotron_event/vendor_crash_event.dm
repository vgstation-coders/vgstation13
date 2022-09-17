/datum/event/old_vendotron_crash
	endWhen = 15
	announceWhen = 5

/datum/event/old_vendotron_crash/can_start()
	return 5

/datum/event/old_vendotron_crash/setup()
	startWhen = rand(5, 15)

/datum/event/old_vendotron_crash/announce()
	command_alert(/datum/command_alert/old_vendotron_crash)

/datum/event/old_vendotron_crash/start()
	launchVendor()

/datum/event/old_vendotron_crash/proc/launchVendor()
	var/turf/startPoint = random_start_turf(1)
	var/obj/item/projectile/immovablerod/vending/vRod = new /obj/item/projectile/immovablerod/vending(startPoint)
	var/obj/machinery/vending/old_vendotron/theVend = new /obj/machinery/vending/old_vendotron(vRod)
	vRod.myVend = theVend
	var/turf/endPoint = locate(map.center_x, map.center_y, 1)
	vRod.throw_at(endPoint)

/obj/item/projectile/immovablerod/vending
	name = "\improper mid-collision space debris"
	icon = 'icons/obj/vending.dmi'
	icon_state = "Old_Vendotron"
	var/collisionCount = 0
	var/obj/machinery/vending/old_vendotron/myVend = null

/obj/item/projectile/immovablerod/vending/New()
	..()
	collisionCount = rand(4, 6)

/obj/item/projectile/immovablerod/vending/break_stuff()
	if(loc.density)
		loc.ex_act(2)
		collisionCount--
		if(prob(25))
			clong()
		if(collisionCount <= 0)
			becomeVendor()

/obj/item/projectile/immovablerod/vending/proc/becomeVendor()
	myVend.forceMove(loc)
	myVend.state = anchored
	myVend.power_change()
	qdel(src)




