/datum/objective/eet/implant
	explanation_text = "Abduct sentients and implant enigmatic devices."
	name = "Implant Surgery (EET)"
	var/list/last_reported_out = list()

/datum/objective/eet/implant/IsFulfilled()
	last_reported_out.Cut()
	for(var/obj/item/eet_implant/E in eet_tracked_implants)
		var/atom/A = get_holder_at_turf_level(E)
		if(!ishuman(A))
			last_reported_out += E
	return !(last_reported_out.len)

/datum/objective/eet/implant/DatacoreQuery()
	return ..() + "; Unimplanted: [english_list(last_reported_out)]"