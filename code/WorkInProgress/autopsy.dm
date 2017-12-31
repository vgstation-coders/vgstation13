
//moved these here from code/defines/obj/weapon.dm
//please preference put stuff where it's easy to find - C

// Autopsy is part of a surgery. See /code/modules/surgery/other.dm - Dec 6, 2017

/obj/item/weapon/autopsy_scanner
	name = "autopsy scanner"
	desc = "Extracts information on wounds."
	icon = 'icons/obj/autopsy_scanner.dmi'
	icon_state = ""
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_TINY
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"
	var/list/datum/autopsy_data_scanner/wdata = list()
	var/list/datum/autopsy_data_scanner/chemtraces = list()
	var/target_name = null
	var/timeofdeath = null
	var/advanced_butchery = null

/datum/autopsy_data_scanner
	var/weapon = null // this is the DEFINITE weapon type that was used
	var/list/organs_scanned = list() // this maps a number of scanned organs to
									 // the wounds to those organs with this data's weapon type
	var/organ_names = ""

/datum/autopsy_data
	var/weapon = null
	var/pretend_weapon = null
	var/damage = 0
	var/hits = 0
	var/time_inflicted = 0

	proc/copy()
		var/datum/autopsy_data/W = new()
		W.weapon = weapon
		W.pretend_weapon = pretend_weapon
		W.damage = damage
		W.hits = hits
		W.time_inflicted = time_inflicted
		return W

/obj/item/weapon/autopsy_scanner/proc/add_data(var/datum/organ/external/O)
	if(istype(O,/datum/organ/external/chest))
		var/mob/living/carbon/human/H = O.owner
		if(H)
			if(H.advanced_butchery && H.advanced_butchery.len)
				advanced_butchery = "\The [target_name] seems to have been butchered with"
				for(var/i = 1, i <= H.advanced_butchery.len, i++)
					var/tool_name = H.advanced_butchery[i]
					if(tool_name == "grue")
						advanced_butchery = "<span class='warning'>\The [target_name] is likely to have been eaten by a grue.</span>"
						break
					if(H.advanced_butchery.len == 1)
						advanced_butchery += " \a [tool_name]."
					else if(i != H.advanced_butchery.len)
						advanced_butchery += " \a [tool_name][H.advanced_butchery.len > 2 ? "," : ""]"
					else
						advanced_butchery += " and \a [tool_name]."

	if(!O.autopsy_data.len && !O.trace_chemicals.len)
		return

	for(var/V in O.autopsy_data)
		var/datum/autopsy_data/W = O.autopsy_data[V]

		if(!W.pretend_weapon)
			/*
			// the more hits, the more likely it is that we get the right weapon type
			if(prob(50 + W.hits * 10 + W.damage))
			*/

			// Buffing this stuff up for now!
			if(1)
				W.pretend_weapon = W.weapon
			else
				W.pretend_weapon = pick("mechanical toolbox", "wirecutters", "revolver", "crowbar", "fire extinguisher", "tomato soup", "oxygen tank", "emergency oxygen tank", "laser", "bullet")


		var/datum/autopsy_data_scanner/D = wdata[V]
		if(!D)
			D = new()
			D.weapon = W.weapon
			wdata[V] = D

		if(!D.organs_scanned[O.name])
			if(D.organ_names == "")
				D.organ_names = O.display_name
			else
				D.organ_names += ", [O.display_name]"

		qdel (D.organs_scanned[O.name])
		D.organs_scanned[O.name] = W.copy()

	for(var/V in O.trace_chemicals)
		if(O.trace_chemicals[V] > 0 && !chemtraces.Find(V))
			chemtraces += V


/obj/item/weapon/autopsy_scanner/verb/print_data()
	set category = "Object"
	set src in view(usr, 1)
	set name = "Print Data"
	if(usr.isUnconscious() || !(istype(usr,/mob/living/carbon/human)))
		to_chat(usr, "No.")
		return

	var/scan_data = ""

	if(timeofdeath)
		scan_data += "<b>Time of death:</b> [worldtime2text(timeofdeath)]<br><br>"

	var/n = 1
	for(var/wdata_idx in wdata)
		var/datum/autopsy_data_scanner/D = wdata[wdata_idx]
		var/total_hits = 0
		var/total_score = 0
		var/list/weapon_chances = list() // maps weapon names to a score
		var/age = 0

		for(var/wound_idx in D.organs_scanned)
			var/datum/autopsy_data/W = D.organs_scanned[wound_idx]
			total_hits += W.hits

			var/wname = W.pretend_weapon

			if(wname in weapon_chances)
				weapon_chances[wname] += W.damage
			else
				weapon_chances[wname] = max(W.damage, 1)
			total_score+=W.damage


			var/wound_age = W.time_inflicted
			age = max(age, wound_age)

		var/damage_desc

		var/damaging_weapon = (total_score != 0)

		// total score happens to be the total damage
		switch(total_score)
			if(0)
				damage_desc = "Unknown"
			if(1 to 5)
				damage_desc = "<font color='green'>negligible</font>"
			if(5 to 15)
				damage_desc = "<font color='green'>light</font>"
			if(15 to 30)
				damage_desc = "<font color='orange'>moderate</font>"
			if(30 to 1000)
				damage_desc = "<font color='red'>severe</font>"

		if(!total_score)
			total_score = D.organs_scanned.len

		scan_data += "<b>Weapon #[n]</b><br>"
		if(damaging_weapon)
			scan_data += "Severity: [damage_desc]<br>"
			scan_data += "Hits by weapon: [total_hits]<br>"
		scan_data += "Approximate time of wound infliction: [worldtime2text(age)]<br>"
		scan_data += "Affected limbs: [D.organ_names]<br>"
		scan_data += "Possible weapons:<br>"
		for(var/weapon_name in weapon_chances)
			scan_data += "\t[100*weapon_chances[weapon_name]/total_score]% [weapon_name]<br>"

		scan_data += "<br>"

		n++

	if(chemtraces.len)
		scan_data += "<b>Trace Chemicals: </b><br>"
		for(var/chemID in chemtraces)
			scan_data += chemID
			scan_data += "<br>"

	scan_data += "<br>[advanced_butchery]<br>"

	for(var/mob/O in viewers(usr))
		O.show_message("<span class='warning'>\the [src] rattles and prints out a sheet of paper.</span>", 1)

	sleep(10)

	var/obj/item/weapon/paper/P = new(usr.loc)
	P.name = "Autopsy Data ([target_name])"
	P.info = "<tt>[scan_data]</tt>"
	P.overlays += image(icon = P.icon, icon_state = "paper_words")

	if(istype(usr,/mob/living/carbon))
		// place the item in the usr's hand if possible
		usr.put_in_hands(P)
