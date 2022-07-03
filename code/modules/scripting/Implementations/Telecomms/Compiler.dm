//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33


/* --- Traffic Control Scripting Language --- */
	// Nanotrasen TCS Language - Made by Doohl

/datum/n_Interpreter/TCS_Interpreter/HandleError(datum/runtimeError/e)
	if(istype(Compiler,/datum/n_Compiler/TCS_Compiler))
		var/datum/n_Compiler/TCS_Compiler/TCS = Compiler
		TCS.Holder.add_entry(e.ToString(), "Execution Error")

/datum/n_Interpreter/TCS_Interpreter/AlertAdmins()
	if(Compiler && !alertadmins)
		if(istype(Compiler, /datum/n_Compiler/TCS_Compiler))
			var/datum/n_Compiler/TCS_Compiler/TCS = Compiler
			var/obj/machinery/telecomms/server/Holder = TCS.Holder
			var/message = "Potential crash-inducing NTSL script detected at telecommunications server [Holder] ([Holder.x], [Holder.y], [Holder.z])."

			alertadmins = 1
			message_admins(message, 1)

/datum/n_Compiler/TCS_Compiler
	var/obj/machinery/telecomms/server/Holder	// the server that is running the code
	interptype = /datum/n_Interpreter/TCS_Interpreter

/datum/n_Compiler/TCS_Compiler/GC()
	Holder = null
	..()

/datum/n_Compiler/TCS_Compiler/SetVars(var/datum/signal/signal)
	..()

	// Channel macros
	interpreter.SetVar("$common",		COMMON_FREQ)
	interpreter.SetVar("$science",		SCI_FREQ)
	interpreter.SetVar("$command",		COMM_FREQ)
	interpreter.SetVar("$medical",		MED_FREQ)
	interpreter.SetVar("$engineering",	ENG_FREQ)
	interpreter.SetVar("$security",		SEC_FREQ)
	interpreter.SetVar("$supply",		SUP_FREQ)

	// Signal data

	interpreter.SetVar("$content", 	signal.data["message"])
	interpreter.SetVar("$freq", 	signal.frequency)
	interpreter.SetVar("$source", 	signal.data["name"])
	interpreter.SetVar("$job",	 	signal.data["job"])
	interpreter.SetVar("$sign",		signal)
	interpreter.SetVar("$pass",		!(signal.data["reject"])) // if the signal isn't rejected, pass = 1; if the signal IS rejected, pass = 0

/datum/n_Compiler/TCS_Compiler/SetProcs(var/datum/signal/signal)
	// Set up the script procs

	/*
		-> Send another signal to a server
				@format: broadcast(content, frequency, source, job)

				@param content:		Message to broadcast
				@param frequency:	Frequency to broadcast to
				@param source:		The name of the source you wish to imitate. Must be stored in stored_names list.
				@param job:			The name of the job.
	*/
	interpreter.SetProc("broadcast", "tcombroadcast", signal, list("message", "freq", "source", "job"))

	/*
		-> Send a code signal.
				@format: signal(frequency, code)

				@param frequency:		Frequency to send the signal to
				@param code:			Encryption code to send the signal with
	*/
	interpreter.SetProc("signal", "tcs_signaler", signal, list("freq", "code"))

	/*
		-> Store a value permanently to the server machine (not the actual game hosting machine, the ingame machine)
				@format: tcs_mem(address, value)

				@param address:		The memory address (string index) to store a value to
				@param value:		The value to store to the memory address
	*/
	interpreter.SetProc("mem", "tcs_mem", signal, list("address", "value"))

	..()

/* -- Execute the compiled code -- */

/datum/n_Compiler/TCS_Compiler/Run(var/datum/signal/signal)
	..(signal)

	// Backwards-apply variables onto signal data
	/* sanitize (almost) EVERYTHING. fucking players can't be trusted with SHIT */

	signal.data["message"] 	= interpreter.GetVar("$content")
	signal.frequency 		= interpreter.GetCleanVar("$freq", signal.frequency)

	var/setname = interpreter.GetCleanVar("$source", signal.data["name"])

	if(signal.data["name"] != setname)
		signal.data["realname"] = setname
	signal.data["name"]		= setname
	signal.data["job"]		= interpreter.GetCleanVar("$job", signal.data["job"])
	signal.data["reject"]	= !(interpreter.GetCleanVar("$pass")) // set reject to the opposite of $pass

	// If the message is invalid, just don't broadcast it!
	if(signal.data["message"] == "" || !signal.data["message"])
		signal.data["reject"] = 1

/*  -- Actual language proc code --  */

/var/const/SIGNAL_COOLDOWN = 20 // 2 seconds

/datum/signal/proc/tcs_mem(var/address, var/value)
	if(istext(address))
		var/obj/machinery/telecomms/server/S = data["server"]

		if(!value && value != 0)
			return S.memory[address]

		else
			S.memory[address] = value

/datum/signal/proc/tcs_signaler(var/freq = COMMON_FREQ, var/code = 30)
	if(isnum(freq) && isnum(code))

		var/obj/machinery/telecomms/server/S = data["server"]

		if(S.last_signal + SIGNAL_COOLDOWN > world.timeofday && S.last_signal < MIDNIGHT_ROLLOVER)
			return
		S.last_signal = world.timeofday

		var/datum/radio_frequency/connection = radio_controller.return_frequency(freq)

		if(findtext(num2text(freq), ".")) // if the frequency has been set as a decimal
			freq *= 10 // shift the decimal one place

		freq = sanitize_frequency(freq)

		code = round(code)
		code = clamp(code, 0, 100)

		var/datum/signal/signal = new /datum/signal
		signal.source = S
		signal.encryption = code
		signal.data["message"] = "ACTIVATE"

		connection.post_signal(S, signal)

		S.investigation_log(I_WIRES, "NTSL-triggered signaler activated by [S.id] - [format_frequency(frequency)]/[code]")


/datum/signal/proc/tcombroadcast(var/message, var/freq, var/source, var/job)
	var/datum/signal/newsign = new /datum/signal
	var/obj/machinery/telecomms/server/S = data["server"]
	var/obj/item/device/radio/hradio = S.server_radio

	if(!hradio)
		error("[src] has no radio.")
		return

	if((!message || message == "") && message != 0)
		message = "*beep*"
	if(!source)
		source = "[html_encode(uppertext(S.id))]"
		hradio = new // sets the hradio as a radio intercom
	if(!freq || (!isnum(freq) && text2num(freq) == null))
		freq = COMMON_FREQ
	if(findtext(num2text(freq), ".")) // if the frequency has been set as a decimal
		freq *= 10 // shift the decimal one place

	if(!job)
		job = "Unknown"

	//SAY REWRITE RELATED CODE.
	//This code is a little hacky, but it *should* work. Even though it'll result in a virtual speaker referencing another virtual speaker. vOv
	var/atom/movable/virtualspeaker/virt = new /atom/movable/virtualspeaker(null)
	virt.name = source
	virt.job = job
	//END SAY REWRITE RELATED CODE.


	newsign.data["mob"] = virt
	newsign.data["mobtype"] = /mob/living/carbon/human
	newsign.data["name"] = source
	newsign.data["realname"] = newsign.data["name"]
	newsign.data["job"] = "[job]"
	newsign.data["compression"] = 0
	newsign.data["message"] = message
	newsign.data["type"] = 2 // artificial broadcast
	if(!isnum(freq))
		freq = text2num(freq)
	newsign.frequency = freq

	var/datum/radio_frequency/connection = radio_controller.return_frequency(freq)
	newsign.data["connection"] = connection


	newsign.data["radio"] = hradio
	newsign.data["vmessage"] = message
	newsign.data["vname"] = source
	newsign.data["vmask"] = 0
	newsign.data["level"] = data["level"]

	newsign.sanitize_data()

	var/pass = S.relay_information(newsign, "/obj/machinery/telecomms/hub")
	if(!pass)
		S.relay_information(newsign, "/obj/machinery/telecomms/broadcaster") // send this simple message to broadcasters

	spawn(50)
		qdel(virt)
