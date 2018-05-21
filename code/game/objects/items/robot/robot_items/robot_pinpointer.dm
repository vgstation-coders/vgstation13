//Syndie Crisis's pinpointer
/obj/item/weapon/pinpointer/syndicate_crisis
	name = "syndicate pinpointer"
	desc = "An integrated tracking device, jury-rigged to search for living Syndicate operatives."
	watches_nuke = FALSE

/obj/item/weapon/pinpointer/syndicate_crisis/process()
	point_at(get_closest_syndie())

/obj/item/weapon/pinpointer/syndicate_crisis/attack_self()
	if(!active)
		active = TRUE
		process()
		fast_objects += src
		to_chat(usr,"<span class='notice'>You activate the pinpointer</span>")
	else
		active = FALSE
		fast_objects -= src
		icon_state = "pinoff"
		to_chat(usr,"<span class='notice'>You deactivate the pinpointer</span>")

/obj/item/weapon/pinpointer/syndicate_crisis/proc/get_closest_syndie()
	var/list/possible_targets = list()
	var/turf/here = get_turf(src)
	if(ticker.mode.syndicates.len)
		for(var/datum/mind/N in ticker.mode.syndicates)
			var/mob/M = N.current
			if(M && !M.isDead())
				possible_targets |= M
	var/mob/living/closest_syndie = get_closest_atom(/mob/living/carbon/human, possible_targets, here)
	return closest_syndie