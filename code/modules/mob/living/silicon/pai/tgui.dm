// TGUI interface for the pAI software suite.
// The shared purchase/uninstall/wirejack/charge loops live in software.dm.

/mob/living/silicon/pai/ui_state(mob/user)
	return always_state

/mob/living/silicon/pai/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiOS")
		ui.open()

/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["name"] = name
	data["ram"] = ram
	data["screen"] = screen || "main"
	data["subscreen"] = subscreen ? subscreen : 0
	data["temp"] = temp
	data["software"] = software
	data["signal"] = list("frequency" = format_frequency(sradio.frequency), "code" = sradio.code)
	data["uninstall"] = list("progress" = uninstallprogress, "target" = uninstall_target)
	data["charge"] = charge
	var/mob/carrier = get_holder_of_type(loc, /mob)
	data["carrier"] = carrier ? carrier.name : null
	data["toggles"] = list(
		"translator" = universal_understand,
		"light" = lighted,
		"mesons" = mesons,
		"volume" = loudspeak
	)
	data["directives"] = list(
		"master" = master,
		"dna" = dna ? dna.unique_enzymes : null,
		"law0" = pai_law0,
		"laws" = pai_laws
	)

	var/list/available = list()
	for(var/entry in available_software)
		available += list(list(
			"id" = entry,
			"name" = uppertext(entry),
			"cost" = available_software[entry],
			"installed" = (entry in software)
		))
	data["available"] = available

	switch(screen)
		if(SOFT_CM)
			// get_manifest_json() HTML-encodes names; the window shows plain text.
			var/list/manifest = list()
			var/list/source = data_core ? data_core.get_manifest_json() : list()
			for(var/department in source)
				var/list/entries = list()
				for(var/list/entry in source[department])
					entries += list(list(
						"name" = html_decode(entry["name"]),
						"rank" = html_decode(entry["rank"]),
						"active" = entry["active"]
					))
				manifest[department] = entries
			data["manifest"] = manifest
		if(SOFT_MS)
			data["medical"] = pai_medical_data()
		if(SOFT_SS)
			data["security"] = pai_security_data()
		if(SOFT_DM)
			data["messenger"] = pai_messenger_data()
		if(SOFT_AS)
			data["atmo"] = pai_atmo_data()
		if(SOFT_WJ)
			data["wirejack"] = list(
				"target" = hacktarget ? hacktarget.name : null,
				"progress" = hackprogress
			)
		if(SOFT_CS)
			data["chems"] = pai_chem_data()
		if(SOFT_FS)
			data["foods"] = pai_food_data()
		if(SOFT_HM)
			data["holomap"] = list(
				"mode" = (holo_target == initial(holo_target)) ? "Internal Viewer" : "External Projector"
			)

	return data

/mob/living/silicon/pai/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("refresh")
			return TRUE

		if("screen")
			var/new_screen = params["screen"]
			if(new_screen == SOFT_NW)
				if(painews)
					painews.attack_hand(usr)
				return TRUE
			var/list/module_screens = list(SOFT_CM, SOFT_DM, SOFT_MS, SOFT_SS, SOFT_UT, SOFT_AS, SOFT_WJ, SOFT_CS, SOFT_FS, SOFT_RS, SOFT_RT, SOFT_FL, SOFT_HM, SOFT_VE, SOFT_ME)
			if((new_screen in module_screens) && !(new_screen in software))
				return TRUE
			if(!(new_screen in (list("main", "directives", SOFT_BY, SOFT_UN) + module_screens)))
				return TRUE
			screen = new_screen
			subscreen = 0
			if(screen == SOFT_MS && !medHUD)
				apply_hud_by_type(/datum/visioneffect/medical)
				medHUD = TRUE
			if(screen == SOFT_SS && !secHUD)
				apply_hud_by_type(/datum/visioneffect/security/arrest)
				apply_hud_by_type(/datum/visioneffect/job)
				secHUD = TRUE
			return TRUE

		if("subscreen")
			subscreen = max(0, min(2, text2num(params["subscreen"])))
			return TRUE

		if("buy")
			var/target = params["target"]
			if(available_software.Find(target) && !(target in software))
				var/cost = available_software[target]
				if(ram >= cost)
					ram -= cost
					software.Add(target)
				else
					to_chat(src, "<span class='warning'>Insufficient RAM available. Consider uninstalling unnecessary software.</span>")
			return TRUE

		if("uninstall")
			var/target = params["target"]
			if(!software.Find(target) || !available_software.Find(target))
				return TRUE
			var/cost = available_software[target]
			uninstall_target = target
			uninstallprogress = 0
			if(uninstall_loop(cost))
				ram += cost
				pai_finish_uninstall(target, cost)
			uninstallprogress = -1
			uninstall_target = null
			return TRUE

		if("cancel_uninstall")
			uninstallprogress = -1
			uninstall_target = null
			return TRUE

		if("toggle")
			switch(params["toggle"])
				if("translator")
					if(!(SOFT_UT in software))
						return TRUE
					universal_speak = !universal_speak
					universal_understand = !universal_understand
				if("light")
					if(!(SOFT_FL in software))
						return TRUE
					lighted = !lighted
					card.set_light(lighted ? 4 : 0)
				if("mesons")
					if(!(SOFT_ME in software))
						return TRUE
					mesons = !mesons
					if(mesons)
						apply_hud_by_type(/datum/visioneffect/meson)
					else
						remove_hud_by_type(/datum/visioneffect/meson)
					handle_regular_hud_updates()
				if("volume")
					if(!(SOFT_VE in software))
						return TRUE
					loudspeak = !loudspeak
			return TRUE

		if("signal")
			if(!(SOFT_RS in software))
				return TRUE
			if(params["send"])
				sradio.send_signal("ACTIVATE")
				for(var/mob/O in hearers(1, loc))
					O.show_message("[bicon(src)] *beep* *beep*", 1, "*beep* *beep*", 2)
			if(params["freq"])
				var/new_frequency = (sradio.frequency + text2num(params["freq"]))
				if(new_frequency < 1200 || new_frequency > 1600)
					new_frequency = sanitize_frequency(new_frequency)
				sradio.set_frequency(new_frequency)
			if(params["code"])
				sradio.code += text2num(params["code"])
				sradio.code = round(sradio.code)
				sradio.code = min(100, sradio.code)
				sradio.code = max(1, sradio.code)
			return TRUE

		if("chem")
			if(!(SOFT_CS in software))
				return TRUE
			var/chem = params["chem"]
			var/list/valid_chems = list()
			for(var/chem_name in synthable_default_chems)
				valid_chems += synthable_default_chems[chem_name]
			if(SOFT_MS in software)
				for(var/chem_name in synthable_medical_chems)
					valid_chems += synthable_medical_chems[chem_name]
			if(!(chem in valid_chems))
				return TRUE
			if(!get_holder_of_type(loc, /mob))
				to_chat(src, "<span class='warning'>You must have a carrier to inject with chemicals!</span>")
			else if(!charge && chargeloop(SOFT_CS))
				var/mob/M = get_holder_of_type(loc, /mob)
				if(M)
					M.reagents.add_reagent(chem, 15)
					playsound(loc, 'sound/effects/bubbles.ogg', 50, 1)
			else
				to_chat(src, "<span class='warning'>Charge interrupted.</span>")
			return TRUE

		if("food")
			if(!(SOFT_FS in software))
				return TRUE
			var/food_type = params["food"]
			var/list/valid_food = list()
			for(var/food_name in synthable_default_food)
				valid_food += "[synthable_default_food[food_name]]"
			if(!(food_type in valid_food))
				return TRUE
			if(!charge && chargeloop(SOFT_FS))
				var/obj/item/weapon/reagent_containers/food/F = new food_type(get_turf(src))
				var/mob/M = get_holder_of_type(loc, /mob)
				if(M)
					M.put_in_hands(F)
				playsound(loc, 'sound/machines/foodsynth.ogg', 50, 1)
			return TRUE

		if("wirejack_cancel")
			if(!(SOFT_WJ in software))
				return TRUE
			hacktarget = null
			hackprogress = 0
			return TRUE

		if("medical")
			if(!(SOFT_MS in software))
				return TRUE
			var/datum/data/record/R = locate(params["record"])
			if(!istype(R))
				return TRUE
			medicalActive1 = R
			medicalActive2 = R
			for(var/datum/data/record/E in data_core.medical)
				if(E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"])
					medicalActive2 = E
					break
			subscreen = text2num(params["sub"]) || 1
			return TRUE

		if("security")
			if(!(SOFT_SS in software))
				return TRUE
			var/datum/data/record/R = locate(params["record"])
			if(!istype(R))
				return TRUE
			securityActive1 = R
			securityActive2 = R
			for(var/datum/data/record/E in data_core.security)
				if(E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"])
					securityActive2 = E
					break
			subscreen = text2num(params["sub"]) || 1
			return TRUE

		if("messenger")
			if(!(SOFT_DM in software))
				return TRUE
			var/datum/pda_app/messenger/app
			if(pda)
				app = locate(/datum/pda_app/messenger) in pda.applications
			if(!app)
				return TRUE
			if(params["toggler"])
				app.toff = !app.toff
			if(params["ringer"])
				app.silent = !app.silent
			if(params["target"])
				if(silence_time)
					to_chat(src, "<span class='warning'>Communications circuits remain unitialized.</span>")
					return TRUE
				var/obj/item/device/pda/P = locate(params["target"])
				if(istype(P))
					app.create_message(src, P)
			return TRUE

		if("getdna")
			var/mob/M = get_holder_of_type(loc, /mob/living)
			if(!M)
				to_chat(src, "<span class='warning'>You are not being carried by anyone!</span>")
				return TRUE
			spawn CheckDNA(M, src)
			return TRUE

		if("holomap")
			if(!(SOFT_HM in software))
				return TRUE
			if(params["switch_target"])
				holo_target = (holo_target == initial(holo_target)) ? "show_user" : initial(holo_target)
			if(params["toggle"])
				if(!holomap_device)
					holomap_device = new(src)
				if(holo_target == "show_user")
					var/mob/M = get_holder_of_type(loc, /mob)
					if(M)
						holomap_device.toggleHolomap(M)
				else
					holomap_device.toggleHolomap(src)
			return TRUE

		if("open_device")
			switch(params["device"])
				if("gps")
					if(!(SOFT_PS in software))
						return TRUE
					if(!pps_device)
						pps_device = new(src)
					pps_device.attack_self(usr)
					if(!sharedfirmware && xps_device)
						sharedfirmware = TRUE
						ram += 10
						to_chat(src, "Shared software dependencies with the expedition tracker, RAM cost refunded.")
				if("xps")
					if(!(SOFT_XS in software))
						return TRUE
					if(!xps_device)
						xps_device = new(src)
					xps_device.attack_self(usr)
					if(!sharedfirmware && pps_device)
						sharedfirmware = TRUE
						ram += 10
						to_chat(src, "Shared software dependencies with the pAI position tracker, RAM cost refunded.")
			return TRUE

		if("radio")
			radio.attack_self(usr)
			return TRUE

		if("image")
			card.setEmotion()
			return TRUE

		if("newscaster")
			if(!(SOFT_NW in software))
				return TRUE
			if(painews)
				painews.attack_hand(usr)
			return TRUE

		if("bioscan")
			if(!(SOFT_MS in software))
				return TRUE
			var/mob/living/M = get_holder_of_type(loc, /mob/living)
			pai_bioscan = M ? pai_html_to_text(healthanalyze(M, src, TRUE)) : "No biological host found."
			return TRUE

		if("dismiss_temp")
			temp = null
			return TRUE

	return FALSE

/mob/living/silicon/pai/proc/pai_html_to_text(var/text)
	if(!text)
		return ""
	text = replacetext(text, "<br>", "\n")
	text = replacetext(text, "<br/>", "\n")
	text = replacetext(text, "<br />", "\n")
	text = replacetext(text, "<BR>", "\n")
	text = replacetext(text, "</td>", " ")
	text = replacetext(text, "</tr>", "\n")
	// strip_html() only removes the angle brackets, leaving the tag names behind
	// and turning newlines into '#'. Remove whole tags instead.
	var/result = ""
	var/remaining = text
	while(length(remaining))
		var/open = findtext(remaining, "<")
		if(!open)
			result += remaining
			break
		result += copytext(remaining, 1, open)
		var/close = findtext(remaining, ">", open + 1)
		if(!close)
			result += copytext(remaining, open)
			break
		remaining = copytext(remaining, close + 1)
	result = replacetext(html_decode(result), "&nbsp;", " ")
	result = replacetext(result, "&deg;", ascii2text(176))
	return copytext(result, 1, 20000)

/mob/living/silicon/pai/proc/pai_medical_data()
	var/list/data = list()
	var/list/records = list()
	if(data_core)
		for(var/datum/data/record/R in sortRecord(data_core.general))
			records += list(list(
				"ref" = "\ref[R]",
				"id" = R.fields["id"],
				"name" = R.fields["name"]
			))
	data["records"] = records
	if(subscreen == 1)
		if(istype(medicalActive1) && data_core.general.Find(medicalActive1))
			data["active1"] = list(
				list("label" = "Name", "value" = medicalActive1.fields["name"]),
				list("label" = "ID", "value" = medicalActive1.fields["id"]),
				list("label" = "Sex", "value" = medicalActive1.fields["sex"]),
				list("label" = "Age", "value" = medicalActive1.fields["age"]),
				list("label" = "Fingerprint", "value" = medicalActive1.fields["fingerprint"]),
				list("label" = "Physical Status", "value" = medicalActive1.fields["p_stat"]),
				list("label" = "Mental Status", "value" = medicalActive1.fields["m_stat"])
			)
		else
			data["error"] = "Requested medical record not found."
		if(istype(medicalActive2) && data_core.medical.Find(medicalActive2))
			data["active2"] = list(
				list("label" = "Blood Type", "value" = medicalActive2.fields["b_type"]),
				list("label" = "DNA", "value" = medicalActive2.fields["b_dna"]),
				list("label" = "Minor Disabilities", "value" = medicalActive2.fields["mi_dis"]),
				list("label" = "Minor Details", "value" = medicalActive2.fields["mi_dis_d"]),
				list("label" = "Major Disabilities", "value" = medicalActive2.fields["ma_dis"]),
				list("label" = "Major Details", "value" = medicalActive2.fields["ma_dis_d"]),
				list("label" = "Allergies", "value" = medicalActive2.fields["alg"]),
				list("label" = "Allergy Details", "value" = medicalActive2.fields["alg_d"]),
				list("label" = "Current Diseases", "value" = medicalActive2.fields["cdi"]),
				list("label" = "Disease Details", "value" = medicalActive2.fields["cdi_d"]),
				list("label" = "Notes", "value" = medicalActive2.fields["notes"])
			)
	if(subscreen == 2)
		data["bioscan"] = pai_bioscan
	return data

/mob/living/silicon/pai/proc/pai_security_data()
	var/list/data = list()
	var/list/records = list()
	if(data_core)
		for(var/datum/data/record/R in sortRecord(data_core.general))
			records += list(list(
				"ref" = "\ref[R]",
				"id" = R.fields["id"],
				"name" = R.fields["name"]
			))
	data["records"] = records
	if(subscreen == 1)
		if(istype(securityActive1) && data_core.general.Find(securityActive1))
			data["active1"] = list(
				list("label" = "Name", "value" = securityActive1.fields["name"]),
				list("label" = "ID", "value" = securityActive1.fields["id"]),
				list("label" = "Sex", "value" = securityActive1.fields["sex"]),
				list("label" = "Age", "value" = securityActive1.fields["age"]),
				list("label" = "Rank", "value" = securityActive1.fields["rank"]),
				list("label" = "Fingerprint", "value" = securityActive1.fields["fingerprint"]),
				list("label" = "Physical Status", "value" = securityActive1.fields["p_stat"]),
				list("label" = "Mental Status", "value" = securityActive1.fields["m_stat"])
			)
		else
			data["error"] = "Requested security record not found."
		if(istype(securityActive2) && data_core.security.Find(securityActive2))
			data["active2"] = list(
				list("label" = "Criminal Status", "value" = securityActive2.fields["criminal"]),
				list("label" = "Notes", "value" = securityActive2.fields["notes"])
			)
			var/list/comments = list()
			var/counter = 1
			while(securityActive2.fields["com_[counter]"])
				comments += securityActive2.fields["com_[counter]"]
				counter++
			data["comments"] = comments
	return data

/mob/living/silicon/pai/proc/pai_messenger_data()
	var/list/data = list()
	var/datum/pda_app/messenger/app
	if(pda)
		app = locate(/datum/pda_app/messenger) in pda.applications
	if(!app)
		data["error"] = "The pAI has no PDA messenger initialised, please report this as an issue."
		return data
	data["toff"] = app.toff
	data["silent"] = app.silent
	var/list/pdas = list()
	if(!app.toff)
		for(var/obj/item/device/pda/P in get_viewable_pdas())
			pdas += list(list("ref" = "\ref[P]", "name" = "[P]"))
	data["pdas"] = pdas
	var/list/messages = list()
	for(var/note in app.tnote)
		var/message = pai_html_to_text(app.tnote[note])
		var/icon/img = app.imglist[note]
		messages += list(list(
			"key" = note,
			"text" = message,
			"photo" = img ? icon2base64(ImagePDA(img)) : null
		))
	data["messages"] = messages
	return data

/mob/living/silicon/pai/proc/pai_atmo_data()
	var/list/data = list()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T ? T.return_air() : null
	if(!environment)
		data["error"] = "No gasses detected."
		return data
	var/total_moles = environment.total_moles()
	data["pressure"] = round(environment.return_pressure(), 0.1)
	data["temperature"] = round(environment.temperature - T0C)
	var/list/gases = list()
	if(total_moles)
		var/o2_level = environment[GAS_OXYGEN] / total_moles
		var/n2_level = environment[GAS_NITROGEN] / total_moles
		var/co2_level = environment[GAS_CARBON] / total_moles
		var/plasma_level = environment[GAS_PLASMA] / total_moles
		gases += list(list("name" = "Oxygen", "percent" = round(o2_level * 100)))
		gases += list(list("name" = "Nitrogen", "percent" = round(n2_level * 100)))
		gases += list(list("name" = "Carbon Dioxide", "percent" = round(co2_level * 100)))
		gases += list(list("name" = "Plasma", "percent" = round(plasma_level * 100)))
		var/unknown_level = 1 - (o2_level + n2_level + co2_level + plasma_level)
		if(unknown_level > 0.01)
			gases += list(list("name" = "Other", "percent" = round(unknown_level * 100)))
	data["gases"] = gases
	return data

/mob/living/silicon/pai/proc/pai_chem_data()
	var/list/chems = list()
	for(var/chem_name in synthable_default_chems)
		chems += list(list("name" = chem_name, "id" = synthable_default_chems[chem_name]))
	if(SOFT_MS in software)
		for(var/chem_name in synthable_medical_chems)
			chems += list(list("name" = chem_name, "id" = synthable_medical_chems[chem_name]))
	return chems

/mob/living/silicon/pai/proc/pai_food_data()
	var/list/foods = list()
	for(var/food_name in synthable_default_food)
		foods += list(list("name" = food_name, "path" = "[synthable_default_food[food_name]]"))
	return foods

/mob/living/silicon/pai/proc/pai_finish_uninstall(var/target, var/cost)
	if(target == SOFT_FL)
		lighted = FALSE
		card.set_light(0)
	if(target == SOFT_PS)
		qdel(pps_device)
		pps_device = null
		if(sharedfirmware)
			ram -= cost
		sharedfirmware = FALSE
	if(target == SOFT_XS)
		qdel(xps_device)
		xps_device = null
		if(sharedfirmware)
			ram -= cost
		sharedfirmware = FALSE
	if(target == SOFT_HM)
		qdel(holomap_device)
		holomap_device = null
	if(target == SOFT_MS)
		remove_hud_by_type(/datum/visioneffect/medical)
		medHUD = FALSE
	if(target == SOFT_SS)
		remove_hud_by_type(/datum/visioneffect/security/arrest)
		remove_hud_by_type(/datum/visioneffect/job)
		secHUD = FALSE
	if(target == SOFT_VE)
		loudspeak = initial(loudspeak)
	if(target == SOFT_ME)
		remove_hud_by_type(/datum/visioneffect/meson)
		mesons = initial(mesons)
	if(target == SOFT_UT)
		universal_speak = FALSE
		universal_understand = FALSE
	if(screen == target)
		screen = SOFT_UN
	software.Remove(target)
