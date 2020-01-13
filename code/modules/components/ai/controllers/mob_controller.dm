/datum/component/controller/mob
	var/walk_delay=4

/datum/component/controller/mob/RecieveSignal(var/message_type, var/list/args)
	if(isliving(container.holder))
		var/mob/living/M=container.holder
		//testing("Got command: \[[message_type]\]: [json_encode(args)]")
		switch(message_type)
			if(COMSIG_CLICKON)
				var/atom/A = args["target"]
				var/params
				if(args["def_zone"])
					var/list/L = list("def_zone" = args["def_zone"])
					params = list2params(L)
				M.ClickOn(A, params)
			if(COMSIG_STEP)
				step(M, args["dir"], walk_delay)

			if(COMSIG_ADJUST_BODYTEMP) // list("temp"=TEMP_IN_KELVIN)
				M.bodytemperature += args["temp"]

			if(COMSIG_SET_BODYTEMP) // list("temp"=TEMP_IN_KELVIN)
				M.bodytemperature = args["temp"]

			if(COMSIG_STATE) // list("state"=HOSTILE_STANCE_ATTACK)
				setState(args["state"])
