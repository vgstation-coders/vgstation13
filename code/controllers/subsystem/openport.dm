var/datum/subsystem/thanksbyond/SSthanksbyond

/// Band-aided attempt to work around a problem that prevents clients from
/// connecting to the server. Closing and opening the listening port seems
/// to fix it.
/datum/subsystem/thanksbyond
	name	= "OpenPort"
	wait	= 30 SECONDS
	flags	= SS_FIRE_IN_LOBBY
	var/port

/datum/subsystem/thanksbyond/New()
	NEW_SS_GLOBAL(SSthanksbyond)

/datum/subsystem/thanksbyond/Initialize()
	port = world.port
	return ..()

/datum/subsystem/thanksbyond/stat_entry()
	..("port: [port] | world.port: [world.port]")

/datum/subsystem/thanksbyond/fire(resumed = FALSE)
	if(!port)
		log_debug("[name]: skipping because port is not set")
		return
	var/old_port = world.port
	var/result = world.OpenPort("none")
	log_debug("[name]: closing port [old_port]: [result]")
	result = world.OpenPort(port)
	log_debug("[name]: opening port [port]: [result]")
