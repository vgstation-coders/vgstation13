
/datum/role/pulse_demon
	name = PULSEDEMON
	id = PULSEDEMON
	special_role = PULSEDEMON
	required_pref = ROLE_MINOR
	wikiroute = ROLE_MINOR
	logo_state = "spider-logo"
	greets = list(GREET_DEFAULT)
	default_admin_voice = "The Currents"
	admin_voice_style = "skeleton"
	var/list/obj/machinery/power/apc/controlled_apcs = list()

/datum/role/pulse_demon/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='warning'><B>You are a pulse demon, a being of pure electrical energy that travels along the station's wires and infests machinery!</B></span>")
	to_chat(antag.current, "<BR><B>Travel along power cables to visit APCs or power machinery such as rad collectors and SMEs. Once in an APC, you can spend time in it to hijack it and control any machinery in the visible area as you please! Other power machinery allows you to take advantage of power stored within them to upgrade your charge and refill it. Don't let it run out! If the powernet goes blank you'll start losing health and eventually die off! You immune to all forms of damage and obstacles in the way of cables but are also extremely weak to EMPs, so avoid those at all costs.</B>")

/datum/role/pulse_demon/ForgeObjectives()
	AppendObjective(/datum/objective/pulse_demon/infest)
	AppendObjective(/datum/objective/pulse_demon/tamper)