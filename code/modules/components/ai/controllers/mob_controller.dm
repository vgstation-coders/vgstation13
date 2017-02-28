/datum/component/controller/mob
	var/walk_delay=4

/datum/component/controller/mob/RecieveSignal(var/message_type, var/list/args)
	if(isliving(container.holder))
		var/mob/living/M=container.holder
		//testing("Got command: \[[message_type]\]: [json_encode(args)]")
		switch(message_type)
			if(COMSIG_MOVE) // list("loc"=turf)
	               // list("dir"=NORTH)
				if("loc" in args)
					//walk_to(src, target, minimum_distance, delay)
					//testing("Walking towards [args["loc"]] with walk_delay=[walk_delay]")
					walk_to(M, args["loc"], 1, walk_delay)
				if("dir" in args)
					// walk(M, get_dir(src,M), MISSILE_SPEED)
					walk(M, args["dir"], walk_delay)

			if(COMSIG_ADJUST_BODYTEMP) // list("temp"=TEMP_IN_KELVIN)
				M.bodytemperature += args["temp"]

			if(COMSIG_SET_BODYTEMP) // list("temp"=TEMP_IN_KELVIN)
				M.bodytemperature = args["temp"]

			if(COMSIG_STATE) // list("state"=HOSTILE_STANCE_ATTACK)
				setState(args["state"])
