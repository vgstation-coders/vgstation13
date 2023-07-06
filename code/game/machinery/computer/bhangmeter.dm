var/list/bhangmeters = list()

/*
	/datum/sensed_explosion
	/obj/machinery/computer/bhangmeter
*/
/datum/sensed_explosion
	var/image/explosion_image



///////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/computer/bhangmeter
	name = "bhangmeter"
	desc = "Uses a tachyon-doppler array to measure explosions of all shapes and sizes.
	icon = 'icons/obj/computer.dmi'
	icon_state = "forensic"
	circuit = "/obj/item/weapon/circuitboard/bhangmeter"
	var/list/bangs = list()

/obj/machinery/computer/bhangmeter/New()
	..()
	bhangmeters += src

/obj/machinery/computer/bhangmeter/Destroy()
	bhangmeters -= src
	..()

/obj/machinery/computer/bhangmeter/process()
	return PROCESS_KILL

/obj/machinery/computer/bhangmeter/say_quote(text)
	return "coldly states, [text]"

/obj/machinery/computer/bhangmeter/attack_hand(var/mob/user)


/obj/machinery/computer/bhangmeter/attack_paw(var/mob/user)
	attack_hand(user)

/obj/machinery/computer/bhangmeter/attack_animal(var/mob/user)
	attack_hand(user)
