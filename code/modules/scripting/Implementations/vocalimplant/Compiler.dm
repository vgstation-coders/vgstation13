/datum/n_Interpreter/vocal_implant/HandleError(datum/runtimeError/e)
	if(istype(Compiler,/datum/n_Compiler/vocal_implant))
		var/datum/n_Compiler/vocal_implant/VI = Compiler
		if(istype(VI.Holder.loc,/obj/item/weapon/implanter/vocal))
			var/obj/item/weapon/implanter/vocal/V = VI.Holder.loc
			V.say(e.ToString())

/datum/n_Interpreter/vocal_implant/AlertAdmins()
	if(Compiler && !alertadmins)
		if(istype(Compiler, /datum/n_Compiler/vocal_implant))
			var/datum/n_Compiler/vocal_implant/V = Compiler
			var/obj/item/weapon/implant/vocal/VI = V.Holder
			if(VI)
				var/turf/T = get_turf(VI)
				var/mob/M = get_holder_of_type(VI,/mob)
				var/message = "Potential crash-inducing NTSL script detected in vocal implant[M ? " held by [M]" :""] at [T.x], [T.y], [T.z]."

				alertadmins = 1
				message_admins(message, 1)

/datum/n_Compiler/vocal_implant
	var/obj/item/weapon/implant/vocal/Holder	// the implant that is running the code
	interptype = /datum/n_Interpreter/vocal_implant

/datum/n_Compiler/vocal_implant/GC()
	Holder = null
	..()

/datum/n_Compiler/vocal_implant/SetVars(var/datum/signal/signal)
	..()
	// Signal data
	interpreter.SetVar("$content", 	signal.data["message"])
	interpreter.SetVar("$pass",		!(signal.data["reject"])) // if the signal isn't rejected, pass = 1; if the signal IS rejected, pass = 0

/datum/n_Compiler/vocal_implant/SetProcs(var/datum/signal/signal)
	// Set up the script procs

	/*
		-> Send another signal to a speaker, same name as telecomms proc for ease of memory.
				@format: broadcast(content)

				@param content:		Message to broadcast
	*/
	interpreter.SetProc("broadcast", "vibroadcast", signal, list("message"))

	/*
		-> Store a value permanently to the server machine (not the actual game hosting machine, the ingame machine)
				@format: tcs_mem(address, value)

				@param address:		The memory address (string index) to store a value to
				@param value:		The value to store to the memory address
	*/
	interpreter.SetProc("mem", "vi_mem", signal, list("address", "value"))

	..()

/* -- Execute the compiled code -- */

/datum/n_Compiler/vocal_implant/Run(var/datum/signal/signal)
	..(signal)

	// Backwards-apply variables onto signal data

	signal.data["message"] 	= interpreter.GetVar("$content")
	signal.data["reject"]	= !(interpreter.GetCleanVar("$pass")) // set reject to the opposite of $pass

	// If the message is invalid, just don't broadcast it!
	if(signal.data["message"] == "" || !signal.data["message"])
		signal.data["reject"] = 1

/datum/signal/proc/vi_mem(var/address, var/value)
	if(istext(address))
		var/obj/item/weapon/implant/vocal/V = data["implant"]

		if(!value && value != 0)
			return V.memory[address]

		else
			V.memory[address] = value

/datum/signal/proc/vibroadcast(var/message)
	var/obj/item/weapon/implant/vocal/V = data["implant"]
	var/atom/movable/speaker = V.imp_in || V.loc

	if(!ismob(speaker) || !istype(speaker,/obj/item/weapon/implanter/vocal))
		error("[src] is not implanted or in an implanter.")
		return

	if((!message || message == "") && message != 0)
		message = "*beep*"

	speaker.say(message)
	message_admins("The [V] in [speaker] made \him say \"[message]\" [formatJumpTo(speaker)]")
