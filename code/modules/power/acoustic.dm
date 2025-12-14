var/list/atom/sound_hearers = list() // Things that hear actual audio sound and react to it

/obj/machinery/power/acoustic
	name = "acoustic resonator"
	desc = "A low-power device that generates power based on sound detection."
	icon_state = "acoustic"
	density = 1
	machine_flags = SCREWTOGGLE | WRENCHMOVE
	flags = FPRINT | HEAR
	anchored = 1
	use_power = MACHINE_POWER_USE_NONE
	idle_power_usage = 0
	var/count_power = 0 //How much power have we produced SO FAR this count?
	var/tick_power = 0 //How much power did we produce last count?
	var/power_efficiency = 1 //Based on parts
	component_parts = newlist(
		/obj/item/weapon/circuitboard/acoustic,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/console_screen
	)

	hack_abilities = list(
		/datum/malfhack_ability/oneuse/overload_quiet
	)

/obj/machinery/power/acoustic/New()
	. = ..()
	sound_hearers += src
	RefreshParts()

/obj/machinery/power/acoustic/RefreshParts()
	var/calc = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/capacitor))
			calc+=SP.rating
	power_efficiency = calc/4 //Possible results 1, 2, and 3 -- basically, what tier we have

/obj/machinery/power/acoustic/Destroy()
	sound_hearers -= src
	. = ..()

/obj/machinery/power/acoustic/examine(mob/user as mob)
	..()
	to_chat(user, "<span class='info'>During the last cycle, it produced [format_watts(tick_power)].</span>")

/obj/machinery/power/acoustic/Hear(datum/speech/speech, rendered_speech)
	. = ..()
	if(anchored)
		var/rate = length(speech.message)
		if("megaphone" in speech.message_classes)
			rate *= 2
		count_power += (rate * power_efficiency)
		flick("acoustic1",src)

/obj/machinery/power/acoustic/process()
	tick_power = count_power
	count_power = 0
	add_avail(tick_power)

/atom/proc/hear_sound(var/turf/turf_source, soundin, vol as num, vary, frequency, falloff, gas_modified, var/channel = 0,var/wait = FALSE, var/atom/source)
	return

/obj/machinery/power/acoustic/hear_sound(var/turf/turf_source, soundin, vol as num, vary, frequency, falloff, gas_modified, var/channel = 0,var/wait = FALSE, var/atom/source)
	if(anchored)
		if(gas_modified)
			var/turf/current_turf = get_turf(src)
			if(!current_turf)
				return

			var/datum/gas_mixture/environment = current_turf.return_air()
			var/atmosphere = 0
			if(environment)
				atmosphere = environment.return_pressure()

			/// Local sound modifications ///
			if(atmosphere < MIN_SOUND_PRESSURE) //no sound reception in space, boyos
				vol = 0
			else
				vol = vol * atmosphere / ONE_ATMOSPHERE //diverges from mob hearing here, more gas means more power!
			/// end ///

		count_power += (vol * power_efficiency)
		flick("acoustic1",src)
