/datum/event/old_vendotron_teleport
	endWhen = 15
	announceWhen = 5

/datum/event/old_vendotron_teleport/can_start()
	return 15

/datum/event/old_vendotron_teleport/setup()
	startWhen = rand(5, 15)

/datum/event/old_vendotron_teleport/announce()
	command_alert(/datum/command_alert/old_vendotron_teleport)

/datum/event/old_vendotron_teleport/start()
	teleportVendor()

/datum/event/old_vendotron_teleport/proc/teleportVendor()
	var/atom/chosenVend = vendSpawnDecide()
	fancyEntrance(chosenVend)

/datum/event/old_vendotron_teleport/proc/vendSpawnDecide()
	var/static/list/canReplace = list(
		/obj/machinery/vending/coffee,
		/obj/machinery/vending/snack,
		/obj/machinery/vending/cola,
		/obj/machinery/vending/cigarette,
		/obj/machinery/vending/discount,
		/obj/machinery/vending/groans,
		/obj/machinery/vending/nuka,
		/obj/machinery/vending/sovietsoda,
		/obj/machinery/vending/zamsnax,
	)
	var/list/possibleVends = list()
	for(var/obj/machinery/vending/aVendor in all_machines)
		if(!is_type_in_list(aVendor, canReplace))
			continue
		if(aVendor.loc.z != map.zMainStation)
			continue
		possibleVends.Add(aVendor)
	if(!possibleVends.len)	//Copy paste from infestation
		message_admins("Old Vendotron event has failed! Could not find any appropriate vending machines to replace.")
		announceWhen = -1
		endWhen = 0
		return
	var/toSpawn = pick(possibleVends)
	return toSpawn

/datum/event/old_vendotron_teleport/proc/fancyEntrance(var/obj/machinery/vending/vendToReplace)
	var/obj/effect/old_vendotron_entrance/vendPortal = new /obj/effect/old_vendotron_entrance(vendToReplace.loc)
	vendPortal.aestheticEntrance()
	playsound(E, 'sound/effects/eleczap.ogg', 100, 1)
	spawn(3 SECONDS)
		var/obj/machinery/vending/old_vendotron/OV = new /obj/machinery/vending/old_vendotron(vendToReplace.loc)
		if(!vendToReplace.gcDestroyed)
			vendToReplace.coinbox = null
			qdel(vendToReplace)
		playsound(OV, 'sound/effects/coins.ogg', 100, 1)

/obj/effect/old_vendotron_entrance
	name = "unknown bluespace tear"
	icon_state = "anom"
	alpha = 0

/obj/effect/old_vendotron_entrance/New()
	..()
	for(var/mob/dead/observer/people in observers)
		to_chat(people, "<span class = 'notice'>\A [src] has been thrown at the station, <a href='?src=\ref[people];follow=\ref[src]'>Follow it</a></span>")

/obj/effect/old_vendotron_entrance/proc/aestheticEntrance()
	animate(src, alpha = 255, transform = matrix()*2, time = 3 SECONDS)
	spawn(3 SECONDS)
		animate(src, icon_state = "bhole3", transform = matrix()*0.1, time = 3 SECONDS)
	spawn(35)
		qdel(src)
