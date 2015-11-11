/datum/clockcult_power/wraiths_spectacles
	name				= "Wraith's Spectacles"
	desc				= "Creates spectacles that grant true sight, but quickly ruin the wearer's vision. Prolonged use will result in blindness. Enemy cultists that wear this will have their eyes completely ruined."

	invocation			= "Tenag zr gehgu yraf."
	loudness			= CLOCK_WHISPERED
	cast_time			= 0
	req_components		= list(CLOCK_HIEROPHANT = 2)

/datum/clockcult_power/spectacles/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	var/turf/T = get_turf(user)
	if(!T)
		return 1

	var/obj/item/clothing/glasses/wraithspecs/W = new /obj/item/clothing/glasses/wraithspecs {alpha = 0} (T)
	animate(W, alpha = 255, 5)

	user.visible_message("<span class='notice'>A pair of [W] appears underneath [user]!</span>", "<span class='clockwork'>A pair of Wraith's Spectacles appears underneath you!</span>")
