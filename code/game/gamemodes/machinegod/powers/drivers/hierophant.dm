/datum/clockcult_power/hierophant
	name				= "Hierophant"
	desc				= "Temporarily allows the slab to act as a one-way radio, and transmit them to any other cultist's mind. Speaking as well as nearby whispers will be heard. ((All player-controlled cult mobs may speak through the Hierophant Network by using :6.))"

	invocation			= "Tenag fyno r’nef."
	req_components		= list(CLOCK_HIEROPHANT = 1)
	cast_time			= 0
	loudness			= CLOCK_WHISPERED

/datum/clockcult_power/hierophant/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	C.hierophant_remaining += CLOCK_HIEROPHANT_DURATION
