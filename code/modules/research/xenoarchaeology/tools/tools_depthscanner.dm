
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Depth scanner - scans rock turfs / boulders and tells players if there is anything interesting inside, logs all finds + coordinates + times

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
	var/list/positive_locations = list()
	var/datum/depth_scan/current

/datum/depth_scan
	var/time = ""
	var/coords = ""
	var/depth = 0
	var/clearance = 0
	var/record_index = 1
	var/material = "unknown"

/obj/item/device/depth_scanner/proc/scan_atom(var/mob/user, var/atom/A)
	user.visible_message("<span class='notice'>[user] scans [A], the air around them humming gently.</span>")
	if(istype(A,/turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = A
		if(M.finds.len || M.artifact_find)
			for(var/mob/L in range(src, 1))
				to_chat(L, "<span class='notice'>[bicon(src)] [src] pings.</span>")
			playsound(user, 'sound/machines/info.ogg', 20, 1)
			//create a new scanlog entry
			var/datum/depth_scan/D = new()
			D.coords = "[M.x-WORLD_X_OFFSET[M.z]].[rand(0,9)]:[M.y-WORLD_Y_OFFSET[M.z]].[rand(0,9)]:[10 * M.z].[rand(0,9)]"
			D.time = worldtime2text()
			D.record_index = positive_locations.len + 1
			D.material = M.mineral ? M.mineral.display_name : "Rock"

			//find the first artifact and store it
			if(M.finds.len)
				var/datum/find/F = M.finds[1]
				D.depth = F.excavation_required	//0-100% and 0-100cm
				D.clearance = F.clearance_range
				D.material = F.responsive_reagent
				to_chat(user,"<span class='notice'>Anomaly depth: <strong>[F.excavation_required]</strong> cm</span>")
				to_chat(user,"<span class='notice'>Clearance above anomaly depth: <strong>[F.clearance_range]</strong> cm</span>")
				var/index = responsive_carriers.Find(F.responsive_reagent)
				if(index > 0 && index <= finds_as_strings.len)
					to_chat(user,"<span class='notice'>Anomaly material: <strong><font color=[color_from_find_reagent[finds_as_strings[index]]]>[finds_as_strings[index]]</font></strong></span>")
				else
					to_chat(user,"<span class='notice'>Anomaly material: <strong>Unknown</strong></span>")
			else
				to_chat(user,"<span class='notice'>Anomaly depth: <strong>0</strong> cm</span>")
				to_chat(user,"<span class='notice'>Clearance above anomaly depth: <strong>0</strong> cm</span>")
				to_chat(user,"<span class='notice'>Anomaly material: <strong>Unknown</strong></span>")

			positive_locations.Add(D)
		else
			playsound(user, 'sound/items/detscan.ogg', 10, 1)

	else if(istype(A,/obj/structure/boulder))
		var/obj/structure/boulder/B = A
		if(B.artifact_find)
			for(var/mob/L in range(src, 1))
				to_chat(L, "<span class='notice'>[bicon(src)] [src] pings [pick("madly","wildly","excitedly","crazily")]!</span>")
			playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
			//create a new scanlog entry
			var/datum/depth_scan/D = new()
			D.coords = "[10 * (B.x-WORLD_X_OFFSET[B.z])].[rand(0,9)]:[10 * (B.y-WORLD_Y_OFFSET[B.z])].[rand(0,9)]:[10 * B.z].[rand(0,9)]"
			D.time = worldtime2text()
			D.record_index = positive_locations.len + 1

			//these values are arbitrary
			D.depth = rand(75,100)
			D.clearance = rand(5,25)

			positive_locations.Add(D)

			to_chat(user,"<span class='notice'>Anomaly depth: <strong>[rand(75,100)]</strong></span> cm")
			to_chat(user,"<span class='notice'>Clearance above anomaly depth: <strong>[rand(5,25)]</strong> cm</span>")
			to_chat(user,"<span class='notice'>Anomaly material: <strong>Unknown</strong></span>")
		else
			playsound(user, 'sound/items/detscan.ogg', 10, 1)

/obj/item/device/depth_scanner/attack_self(var/mob/user as mob)
	return src.interact(user)

/obj/item/device/depth_scanner/interact(var/mob/user as mob)
	var/dat = "<b>Co-ordinates with positive matches</b><br>"
	dat += "<A href='?src=\ref[src];clear=0'>== Clear all ==</a><br>"
	if(current)
		dat += "Time: [current.time]<br>"
		dat += "Coords: [current.coords]<br>"
		dat += "Anomaly depth: [current.depth] cm<br>"
		dat += "Clearance above anomaly depth: [current.clearance] cm<br>"
		var/index = responsive_carriers.Find(current.material)
		if(index > 0 && index <= finds_as_strings.len)
			dat += "Anomaly material: <font color=[color_from_find_reagent[finds_as_strings[index]]]>[finds_as_strings[index]]</font><br>"
		else
			dat += "Anomaly material: Unknown<br>"
		dat += "<A href='?src=\ref[src];clear=[current.record_index]'>clear entry</a><br>"
	else
		dat += "Select an entry from the list<br>"
		dat += "<br>"
		dat += "<br>"
		dat += "<br>"
		dat += "<br>"
	dat += "<hr>"
	if(positive_locations.len)
		for(var/index=1, index<=positive_locations.len, index++)
			var/datum/depth_scan/D = positive_locations[index]
			dat += "<A href='?src=\ref[src];select=[index]'>[D.time], coords: [D.coords]</a><br>"
	else
		dat += "No entries recorded."
	dat += "<hr>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh</a><br>"
	dat += "<A href='?src=\ref[src];close=1'>Close</a><br>"
	user << browse(dat,"window=depth_scanner;size=300x500")
	onclose(user, "depth_scanner")

/obj/item/device/depth_scanner/Topic(href, href_list)
	..()
	usr.set_machine(src)

	if(href_list["select"])
		var/index = text2num(href_list["select"])
		if(index && index <= positive_locations.len)
			current = positive_locations[index]
	else if(href_list["clear"])
		var/index = text2num(href_list["clear"])
		if(index)
			if(index <= positive_locations.len)
				var/datum/depth_scan/D = positive_locations[index]
				positive_locations.Remove(D)
				QDEL_NULL(D)
		else
			//GC will hopefully pick them up before too long
			positive_locations = list()
			QDEL_NULL(current)
	else if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=depth_scanner")

	updateSelfDialog()
