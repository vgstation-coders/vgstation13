/datum/event/old_vendotron
	endWhen = 15


/datum/event/old_vendotron/can_start()
	return 15

/datum/event/old_vendotron/setup()
	startWhen = rand(5, 15)

/datum/event/old_vendotron/announce()
	command_alert(/datum/command_alert/old_vendotron)

/datum/event/old_vendotron/start()
	launchVendor()

/datum/event/old_vendotron/proc/launchVendor()
	var/turf/startPoint = random_start_turf(1)
	var/obj/item/projectile/immovablerod/vending/vRod = new /obj/item/projectile/immovablerod/vending(startPoint)
	var/obj/machinery/vending/old_vendotron/theVend = new /obj/machinery/vending/old_vendotron(vRod)
	vRod.myVend = theVend
	var/turf/endPoint = locate(map.center_x, map.center_y, 1)
	vRod.throw_at(endPoint)

///datum/event/old_vendotron/proc/getVendStart()
//	var/startX = 0
//	var/startY = 0
//	var/startSide = rand(1,4)
//	switch(startSide)
//		if(X_NORTH_START || X_SOUTH_START)
//			startY = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE)
//			if(startSide == X_SOUTH_START)
//				startX = TRANSITIONEDGE
//			else
//				startX = world.maxx - TRANSITIONEDGE
//		if(Y_EAST_START || Y_WEST_START)
//			startX = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE)
//			if(startSide == Y_WEST_START)
//				startY = TRANSITIONEDGE
//			else
//				startY = world.maxy - TRANSITIONEDGE
//	return locate(startX, startY, 1)	//No vendors for roid I guess


/obj/item/projectile/immovablerod/vending
	name = "\improper mid-collision space debris"
	icon = 'icons/obj/vending.dmi'
	icon_state = "Old_Vendotron"
	var/collisionCount = 0
	var/obj/machinery/vending/old_vendotron/myVend = null

/obj/item/projectile/immovablerod/vending/New()
	..()
	collisionCount = rand(10, 25)
	to_chat(world, "Count is = [collisionCount]")

/obj/item/projectile/immovablerod/vending/break_stuff()
	if(loc.density)
		loc.ex_act(2)
		collisionCount--
		if(prob(25))
			clong()
		if(collisionCount <= 0)
			to_chat(world, "Should be becoming vendor")
			becomeVendor()

/obj/item/projectile/immovablerod/vending/proc/becomeVendor()
	myVend.forceMove(loc)
	myVend.state = anchored
	myVend.power_change()
	qdel(src)




