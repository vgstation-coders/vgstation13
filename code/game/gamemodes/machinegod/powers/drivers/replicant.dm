/datum/clockcult_power/replicant
	name				= "Replicant"
	desc				= "Forms a new clockwork slab from the alloy and drops it at the user's feet. Slabs are used to create components and use them to activate powers. Slabs require a living, active cultist that does not possess extra slabs to generate components. Components will be made once every 3 minutes at random, or once every 4 minutes if a specific type is requested."

	invocation			= "S’betr zr fyno."
	loudness			= CLOCK_WHISPERED
	cast_time			= 0
	req_components		= list(CLOCK_REPLICANT = 1)

/datum/clockcult_power/replicant/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	var/turf/T = get_turf(user)
	if(!T)
		return 1

	var/obj/item/clockslab/NC = new /obj/item/clockslab {alpha = 0} (T)
	animate(NC, alpha = initial(NC.alpha), 5)

	user.visible_message("<span class='notice'>\A [NC] appears beneath [user]!</span>", "<span class='clockwork'>\The [NC] materialises underneath you!</span>") // I would say "your feet", but then I'd have to check if the user has actual feet.
