
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Depth scanner - scans rock turfs / boulders and tells players if there is anything interesting inside, logs all finds + coordinates + times

//also known as the x-ray diffractor
/obj/item/device/depth_scanner
	name = "depth analysis scanner"
	desc = "Used to check spatial depth and density of rock outcroppings."
	icon = 'icons/obj/pda.dmi'
	icon_state = "crap"
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
	var/dissonance_spread = 1
	var/material = "unknown"

/obj/item/device/depth_scanner/proc/scan_atom(var/mob/user, var/atom/A)
	user.visible_message("<span class='notice'>[user] scans [A], the air around them humming gently.</span>")
	if(istype(A,/turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = A
		if(M.finds.len || M.artifact_find)

			//create a new scanlog entry
			var/datum/depth_scan/D = new()
			D.coords = "[M.x-WORLD_X_OFFSET[M.z]].[rand(0,9)]:[M.y-WORLD_Y_OFFSET[M.z]].[rand(0,9)]:[10 * M.z].[rand(0,9)]"
			D.time = worldtime2text()
			D.record_index = positive_locations.len + 1
			D.material = M.mineral ? M.mineral.display_name : "Rock"

			//find the first artifact and store it
			if(M.finds.len)
				var/datum/find/F = M.finds[1]
				D.depth = F.excavation_required * 2		//0-100% and 0-200cm
				D.clearance = F.clearance_range * 2
				D.material = F.responsive_reagent
			/*
			if(M.excavation_minerals.len)
				if(M.excavation_minerals[1] < D.depth)
					D.depth = M.excavation_minerals[1]
					D.clearance = rand(2,6)
					D.dissonance_spread = rand(1,1000) / 100
			*/

			positive_locations.Add(D)

			for(var/mob/L in range(src, 1))
				to_chat(L, "<span class='notice'>[bicon(src)] [src] pings.</span>")

	else if(istype(A,/obj/structure/boulder))
		var/obj/structure/boulder/B = A
		if(B.artifact_find)
			//create a new scanlog entry
			var/datum/depth_scan/D = new()
			D.coords = "[10 * (B.x-WORLD_X_OFFSET[B.z])].[rand(0,9)]:[10 * (B.y-WORLD_Y_OFFSET[B.z])].[rand(0,9)]:[10 * B.z].[rand(0,9)]"
			D.time = worldtime2text()
			D.record_index = positive_locations.len + 1

			//these values are arbitrary
			D.depth = rand(75,100)
			D.clearance = rand(5,25)
			D.dissonance_spread = rand(750,2500) / 100

			positive_locations.Add(D)

			for(var/mob/L in range(src, 1))
				to_chat(L, "<span class='notice'>[bicon(src)] [src] pings [pick("madly","wildly","excitedly","crazily")]!</span>")

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
		dat += "Dissonance spread: [current.dissonance_spread]<br>"
		var/index = responsive_carriers.Find(current.material)
		if(index > 0 && index <= finds_as_strings.len)
			dat += "Anomaly material: [finds_as_strings[index]]<br>"
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
				qdel(D)
				D = null
		else
			//GC will hopefully pick them up before too long
			positive_locations = list()
			qdel(current)
			current = null
	else if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=depth_scanner")

	updateSelfDialog()


/obj/item/device/xenoarch_scanner
	name = "Xenoarchaeological digsite locator"
	desc = "A scanner that checks the surrounding area for potential xenoarch digsites. If it finds any, It will briefly make them visible. Requires mesons for optimal use."
	icon_state = "forensic0-old" //placeholder
	item_state  = "analyzer"
	w_class = W_CLASS_SMALL
	flags = 0
	slot_flags = SLOT_BELT
	origin_tech = Tc_ANOMALY+"=1"
	var/cooldown = 0
	var/adv = FALSE

/obj/item/device/xenoarch_scanner/adv
	name = "Advanced Xenoarchaeological digsite locator"
	icon_state = "unknown"
	desc = "A scanner that scans the surrounding area for potential xenoarch digsites, highlighting them temporarily in a colour associated with their responsive reagent. Requires mesons for optimal use."
	adv = TRUE

/obj/item/device/xenoarch_scanner/adv/examine(mob/user)
	..()
	to_chat(user, "<span class = 'notice'>It has a list of colour codes:</span>")
	for(var/i in color_from_find_reagent)
		to_chat(user, "[i] = <span style = 'color:[color_from_find_reagent[i]];'>this colour</span>")

/obj/item/device/xenoarch_scanner/attack_self(mob/user)
	if(world.time > cooldown + 4 SECONDS)
		var/client/C = user.client
		if(!C)
			return
		cooldown = world.time
		for(var/turf/unsimulated/mineral/M in range(7, user))
			if(M.finds.len)
				var/datum/find/F = M.finds[1]
				var/new_icon_state
				var/new_color
				if(adv)
					new_icon_state = "find_overlay"
					new_color = color_from_find_reagent[F.responsive_reagent]
				else
					new_icon_state = pick("archaeo1","archaeo2","archaeo3")
				var/image/I = image('icons/turf/mine_overlays.dmi', loc = M, icon_state = new_icon_state, layer = UNDER_HUD_LAYER)
				if(new_color)
					I.color = new_color
				I.plane = HUD_PLANE
				C.images += I
				spawn(1 SECONDS)
					animate(I, alpha = 0, time = 2 SECONDS)
				spawn(3 SECONDS)
					if(C)
						C.images -= I