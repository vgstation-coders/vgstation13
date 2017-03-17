/*
	The server logs all traffic and signal data. Once it records the signal, it sends
	it to the subspace broadcaster.

	Store a maximum of 100 logs and then deletes them.
*/

/obj/machinery/telecomms/server
	name = "telecommunication server"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "server"
	desc = "A machine used to store data and network statistics."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 15
	machinetype = 4
	heating_power = 50

	var/list/log_entries = list()
	var/list/stored_names = list()
	var/list/TrafficActions = list()
	var/logs = 0 // number of logs
	var/totaltraffic = 0 // gigabytes (if > 1024, divide by 1024 -> terrabytes)

	var/list/memory = list()	// stored memory
	var/rawcode = ""	// the code to compile (raw text)
	var/datum/TCS_Compiler/Compiler	// the compiler that compiles and runs the code
	var/autoruncode = FALSE		// TRUE if the code is set to run every time a signal is picked up

	var/encryption = "null" // encryption key: ie "password"
	var/salt = "null"		// encryption salt: ie "123comsat"
							// would add up to md5("password123comsat")
	var/language = "human"
	var/obj/item/device/radio/headset/server_radio = null
	var/last_signal = 0 	// Last time it sent a signal

/obj/machinery/telecomms/server/New()
	..()
	Compiler = new()
	Compiler.Holder = src
	server_radio = new()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/telecomms/server,
		/obj/item/weapon/stock_parts/subspace/filter,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator
	)

	RefreshParts()

/obj/machinery/telecomms/server/Destroy()
	// Garbage collects all the NTSL datums.
	if(Compiler)
		Compiler.GC()
		Compiler = null
	..()

/obj/machinery/telecomms/server/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)

	if(signal.data["message"])

		if(is_freq_listening(signal))

			if(traffic > 0)
				totaltraffic += traffic // add current traffic to total traffic

			//Is this a test signal? Bypass logging
			if(signal.data["type"] != 4)

				// If signal has a message and appropriate frequency

				update_logs()

				var/datum/comm_log_entry/log = new
				var/mob/M = signal.data["mob"]
				// Copy the signal.data entries we want
				log.parameters["mobtype"] = signal.data["mobtype"]
				log.parameters["job"] = signal.data["job"]
				log.parameters["key"] = signal.data["key"]
				log.parameters["message"] = signal.data["message"]
				log.parameters["name"] = signal.data["name"]
				log.parameters["realname"] = signal.data["realname"]

				if(!istype(M, /mob/new_player) && istype(M))
					log.parameters["uspeech"] = M.universal_speak
				else
					log.parameters["uspeech"] = 0



				// If the signal is still compressed, make the log entry gibberish
				if(signal.data["compression"] > 0)
					log.parameters["message"] = Gibberish(signal.data["message"], signal.data["compression"] + 50)
					log.parameters["job"] = Gibberish(signal.data["job"], signal.data["compression"] + 50)
					log.parameters["name"] = Gibberish(signal.data["name"], signal.data["compression"] + 50)
					log.parameters["realname"] = Gibberish(signal.data["realname"], signal.data["compression"] + 50)
					log.input_type = "Corrupt File"

				// Log and store everything that needs to be logged
				log_entries.Add(log)
				if(!(signal.data["name"] in stored_names))
					stored_names.Add(signal.data["name"])
				logs++
				signal.data["server"] = src

				// Give the log a name
				var/identifier = num2text( rand(-1000,1000) + world.time )
				log.hash = md5(identifier)

				if(Compiler && autoruncode)
					Compiler.Run(signal)	// execute the code

			var/can_send = relay_information(signal, "/obj/machinery/telecomms/hub")
			if(!can_send)
				relay_information(signal, "/obj/machinery/telecomms/broadcaster")


/obj/machinery/telecomms/server/proc/setcode(var/t)
	if(t)
		if(istext(t))
			rawcode = t

/obj/machinery/telecomms/server/proc/admin_log(var/mob/mob)
	var/msg = "[key_name(mob)] has compiled a script to [src.id]"

	diary << msg
	diary << rawcode

	investigation_log(I_NTSL, "[msg]<br /><pre>[rawcode]</pre>")

	if (length(rawcode)) // Let's not bother the admins for empty code.
		message_admins("[msg] ([formatJumpTo(mob)])", 0, 1)

/obj/machinery/telecomms/server/proc/compile(var/mob/user)
	if(Compiler)
		admin_log(user)
		return Compiler.Compile(rawcode)

/obj/machinery/telecomms/server/proc/update_logs()
	// start deleting the very first log entry
	if(logs >= 400)
		for(var/i = 1, i <= logs, i++) // locate the first garbage collectable log entry and remove it
			var/datum/comm_log_entry/L = log_entries[i]
			if(L.garbage_collector)
				log_entries.Remove(L)
				logs--
				break

/obj/machinery/telecomms/server/proc/add_entry(var/content, var/input)
	var/datum/comm_log_entry/log = new
	var/identifier = num2text( rand(-1000,1000) + world.time )
	log.name = input
	log.hash = md5(identifier)
	log.input_type = input
	log.parameters["message"] = content
	log_entries.Add(log)
	update_logs()

// Simple log entry datum

/datum/comm_log_entry
	var/parameters = list() // carbon-copy to signal.data[]
	var/name = "Data Packet"
	var/hash = ""
	var/garbage_collector = 1 // if set to 0, will not be garbage collected
	var/input_type = "Speech File"