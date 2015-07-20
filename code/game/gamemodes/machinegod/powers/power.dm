/datum/clockcult_power
	var/name = "this shouldn't appear."
	var/desc = "OH GOD CALL A CODER THE UNIVERSE IS EXPLODING."

	var/invocation 			= "OH GOD"		//Invocation of this power.
	var/cast_time 			=-1				//Time this power should take to be casted, -1 will make it custom and calculated when it is activated.
	var/metal_req 			= 0				//If any, amount of metal required to cast this power.
	var/participants_min	= 1				//Participants required to cast this. minimum.
	var/participants_max	= 1				//Participants required to cast this. maximum.
	var/loudness			= CLOCK_SPOKEN	//Chanted, spoken, or whispered.
	var/category			= CLOCK_DRIVER	//Category this falls under.
	var/list/req_components[0]				//Required components for this power, format is list(compid = amount, ...)

//This proc is called when the power is casted.
/datum/clockcult_power/proc/activate(var/mob/user, var/list/participants)
	return

/datum/clockcult_power/proc/get_cast_time(var/mob/user, var/list/participants)
	return 1
