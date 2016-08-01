/var/global/sent_spiders_to_station = 0

/datum/event/spider_infestation
	announceWhen	= 450

	var/spawncount = 1


/datum/event/spider_infestation/setup()
	announceWhen = rand(300, 600)
	spawncount = rand(8, 12)	//spiderlings only have a 50% chance to grow big and strong
	sent_spiders_to_station = 0

/datum/event/spider_infestation/announce()
	command_alert(/datum/command_alert/xenomorphs)


/datum/event/spider_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in atmos_machines)
		if(temp_vent.loc.z == 1 && !temp_vent.welded && temp_vent.network)
			if(temp_vent.network.normal_members.len > 50)
				vents += temp_vent

	while((spawncount >= 1) && vents.len)
		var/obj/vent = pick(vents)
		new /mob/living/simple_animal/hostile/giant_spider/spiderling(vent.loc)
		vents -= vent
		spawncount--