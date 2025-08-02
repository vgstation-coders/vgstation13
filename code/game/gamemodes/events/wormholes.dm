/proc/wormhole_event()
	spawn()
		var/list/pick_turfs = list()
		for(var/A in the_station_areas)
			for(var/turf/simulated/floor/T in get_area_turfs(A))
				if(!T.has_dense_content())
					pick_turfs += T

		if(pick_turfs.len)
			//All ready. Announce that bad juju is afoot.
			command_alert(/datum/command_alert/wormholes)
			//prob(20) can be approximated to 1 wormhole every 5 turfs!
			//admittedly less random but totally worth it >_<
			var/event_duration = 3000	//~5 minutes in ticks
			var/sleep_duration = round( event_duration / ((pick_turfs.len/5)+1) ) //+1 to avoid division by zero!
			var/end_time = world.time + event_duration	//the time by which the event should have ended

			while(world.time < end_time)
				if(!pick_turfs.len)
					log_debug("Wormhole event out of turfs to pick. Ending the event")
					return

				create_wormhole(pick_n_take(pick_turfs),pick_n_take(pick_turfs))

				sleep(sleep_duration)						//have a well deserved nap!

			log_debug("Wormhole event in overtime. Ending the event")

//maybe this proc can even be used as an admin tool for teleporting players without ruining immulsions?
/proc/create_wormhole(var/turf/enter as turf, var/turf/exit as turf)
	var/obj/effect/portal/P = new /obj/effect/portal( enter )
	P.target = exit
	P.icon = 'icons/obj/objects.dmi'
	P.icon_state = "anom"
	P.name = "wormhole"
	spawn(rand(300,600)) //This isn't useful, the new in hand tele will likely override it
		qdel(P)
