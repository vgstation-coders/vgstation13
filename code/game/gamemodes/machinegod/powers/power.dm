/datum/clockcult_power
	var/name = "this shouldn't appear."
	var/desc = "OH GOD CALL A CODER THE UNIVERSE IS EXPLODING."

	var/invocation 			= "GRYY'CWO!"	//Invocation of this power. Yes that translates to "TELL PJB".
	var/cast_time 			=-1				//Time this power should take to be casted, -1 will make it custom and calculated when it is activated.
	var/participants_min	= 1				//Participants required to cast this. minimum.
	var/participants_max	= 1				//Participants required to cast this. maximum.
	var/loudness			= CLOCK_SPOKEN	//Chanted, spoken, or whispered. CLOCK_CALC to calculate dynamically.
	var/category			= CLOCK_DRIVER	//Category this falls under.
	var/list/req_components[0]				//Required components for this power, format is list(compid = amount, ...)

//Checks if the power can be casted.
//Note that this DOES NOT check for components, such is handled on the side of the clockslab.
/datum/clockcult_power/proc/can_cast			(var/mob/user, var/obj/item/weapon/clockslab/C, var/list/participants)
	return 1

//Gets the cast time, only used if cast_time == -1.
/datum/clockcult_power/proc/get_cast_time		(var/mob/user, var/obj/item/weapon/clockslab/C, var/list/participants)
	return 1

/datum/clockcult_power/proc/get_loudness		(var/mob/user, var/obj/item/weapon/clockslab/C, var/list/participants)
	return CLOCK_WHISPERED

//This proc is called when the power is casted.
//Return 1 if the invocation failed (for example, a do_after() that got cancelled up), and the components will not be taken.
/datum/clockcult_power/proc/activate			(var/mob/user, var/obj/item/weapon/clockslab/C, var/list/participants)
	return




