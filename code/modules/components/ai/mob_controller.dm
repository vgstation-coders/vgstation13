/datum/component/controller/mob
	var/walk_delay=4

/datum/component/controller/mob/RecieveSignal(var/message_type, var/list/args)
	if(isliving(container.holder))
		var/mob/living/M=container.holder
		testing("Got command: \[[message_type]\]: [json_encode(args)]")
		switch(message_type)
			if("move") // list("loc"=turf)
	               // list("dir"=NORTH)
				if("loc" in args)
					//walk_to(src, target, minimum_distance, delay)
					walk_to(holder, args["loc"], 1, walk_delay)
				if("dir" in args)
					// walk(M, get_dir(src,M), MISSILE_SPEED)
					walk(holder, args["dir"], walk_delay)

			if("add body temp") // list("temp"=TEMP_IN_KELVIN)
				M.bodytemperature += args["temp"]

			if("state") // list("state"=HOSTILE_STANCE_ATTACK)
				setState(args["state"])
