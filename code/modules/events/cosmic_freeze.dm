/datum/event/cosmic_freeze
	var/turf/starting_turf = null

/datum/event/cosmic_freeze/start()
	starting_turf = cosmic_freeze_event()

/datum/event/cosmic_freeze/announce()
	command_alert("Thermal scans of [starting_turf.loc] suggest that the close approach of a comet has somehow manifested a snow storm aboard the station. Allowing that storm to propagate through the station might have unforeseen consequences.", "Cosmic Snow Storm")


///////SNOW READER(debug object)////////

/obj/structure/snowreader
	name = "Snow Reader"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "festivus_pole"

	var/delay_chill = 5
	var/delay_spread = 20

	var/change_tick = 1

/obj/structure/snowreader/New()
	read_snow()

/obj/structure/snowreader/proc/read_snow()
	visible_message("there are [snow_tiles] tiles covered in snow")
	spread_delay = delay_spread
	chill_delay = delay_chill
	snowTickMod = change_tick
	sleep(50)
	read_snow()
