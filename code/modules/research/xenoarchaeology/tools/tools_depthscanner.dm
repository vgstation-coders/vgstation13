
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Depth scanner - scans rock turfs / boulders and tells players if there is anything interesting inside.

//also known as the x-ray diffractor
/obj/item/device/depth_scanner
	name = "depth analysis scanner"
	desc = "Used to check spatial depth and density of rock outcroppings."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "depthscanner"
	item_state = "analyzer"
	w_class = W_CLASS_TINY
	flags = FPRINT
	slot_flags = SLOT_BELT

/obj/item/device/depth_scanner/proc/scan_atom(var/mob/user, var/atom/A)
	user.visible_message("<span class='notice'>[user] scans [A], the air around them humming gently.</span>")
	if(istype(A,/turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = A
		if(M.finds.len || M.artifact_find)
			for(var/mob/L in range(src, 1))
				to_chat(L, "<span class='notice'>[bicon(src)] [src] pings.</span>")
			playsound(user, 'sound/machines/info.ogg', 20, 1)

			//find the first artifact and store it
			if(M.finds.len)
				var/datum/find/F = M.finds[1]
				to_chat(user,"Anomaly depth: [F.excavation_required] cm")
				to_chat(user,"Clearance above anomaly depth: [F.clearance_range] cm")
				var/index = responsive_carriers.Find(F.responsive_reagent)
				if(index > 0 && index <= finds_as_strings.len)
					to_chat(user,"Anomaly material: <font color=[color_from_find_reagent[finds_as_strings[index]]]>[finds_as_strings[index]]</font></strong>")
				else
					to_chat(user,"Anomaly material: Unknown")
			else
				to_chat(user,"Anomaly depth: 0 cm")
				to_chat(user,"Clearance above anomaly depth: 0 cm")
				to_chat(user,"Anomaly material: Unknown")
		else
			playsound(user, 'sound/items/detscan.ogg', 10, 1)

	else if(istype(A,/obj/structure/boulder))
		var/obj/structure/boulder/B = A
		if(B.artifact_find)
			for(var/mob/L in range(src, 1))
				to_chat(L, "<span class='notice'>[bicon(src)] [src] pings [pick("madly","wildly","excitedly","crazily")]!</span>")
			playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)

			//these values are arbitrary
			to_chat(user,"Anomaly depth: [rand(75,100)] cm")
			to_chat(user,"Clearance above anomaly depth: [rand(5,25)] cm")
			to_chat(user,"Anomaly material: Unknown")
		else
			playsound(user, 'sound/items/detscan.ogg', 10, 1)
