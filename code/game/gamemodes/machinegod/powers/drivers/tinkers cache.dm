/datum/clockcult_power/tinkers_cache
	name				= "Tinkerer's Cache"
	desc				= "Constructs a cache that can store up to X Components, and one brain/MMI. When casting any power, caches on any z-level are picked from first before taking from the slab's Component storage. Daemons will automatically attempt to fill the oldest cache with space remaining."

	invocation			= "Ohv’yqva n qvfcra’fre!"
	cast_time			= 40
	req_components		= list(CLOCK_REPLICANT = 2)

/datum/clockcult_power/tinkers_cache/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	var/turf/T = get_turf(user)
	if(!T)
		return 1

	var/obj/machinery/tinkers_cacheNC = new/obj/machinery/tinkers_cache {alpha = 0} (T)
	animate(NC, alpha = initial(NC.alpha), 5)

	user.visible_message("<span class='notice'>\A [NC] appears beneath [user]!</span>", "<span class='clockwork'>\The [NC] materialises underneath you!</span>") // I would say "your feet", but then I'd have to check if the user has actual feet.
