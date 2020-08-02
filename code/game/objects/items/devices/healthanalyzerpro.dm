/obj/item/device/healthanalyzerpro/
	name = "ProHealth Analyzer"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	icon_state = "adv_health"
	item_state = "healthanalyzer"
	desc = "A hand-held body scanner able to precisely distinguish vital signs of the subject. This particular device is an experimental model outfitted with several modules that fulfill the roles of common scanning tools, memory function to record last made scan and a printer."
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 4
	starting_materials = list(MAT_IRON = 700, MAT_PLASTIC = 200, MAT_URANIUM = 50, MAT_SILVER = 50, MAT_GOLD = 50)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = Tc_MAGNETS + "=4;" + Tc_BIOTECH + "=4"
	attack_delay = 0
	var/tmp/last_scantime = 0
	var/last_reading = null
	var/mode = "Health Scan"
	var/list/modes = list("Health Scan", "Simplified Health Scan", "Advanced Health Scan", "Reagents Scan", "Immunity Scan", "Autopsy Scan")
	var/list/datum/autopsy_data_scanner/wdata = list()
	var/list/datum/autopsy_data_scanner/chemtraces = list()
	var/target_name = null
	var/timeofdeath = null
	var/advanced_butchery = null
	var/obj/item/device/antibody_scanner/immune
	var/last_print

/obj/item/device/healthanalyzerpro/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Current active mode: [mode].</span>")

/obj/item/device/healthanalyzerpro/verb/toggle_mode()
	set name = "Switch mode"
	set category = "Object"

	mode = input(usr, "Please select module.", "Pro Health Scanner") in modes
	last_reading = null
	last_scantime = 0

/obj/item/device/healthanalyzerpro/verb/print(mob/user)
	set name = "Print from memory"
	set category = "Object"

	if(mode == "Immunity Scan")
		to_chat(user, "<span class='warning'>Due to memory constraints, immunity scan doesn't provide printing function!</span>")
		return
	if(!last_reading)
		to_chat(user, "<span class='warning'>The memory is empty.</span>")
		return
	if(!user.dexterity_check()) //it's a complex thingy
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(last_print + 150 > world.time)
		to_chat(user, "<span class='warning'>Printing energy spent, please wait a moment.</span>")
		return

	for(var/mob/O in viewers(usr))
		O.show_message("<span class='warning'>\the [src] rattles and prints out a sheet of paper.</span>", 1)
	sleep(10)
	last_print = world.time
	var/obj/item/weapon/paper/R = new(loc)
	R.name = "paper - '[mode] results'"
	R.info = last_reading
	if(istype(user,/mob/living/carbon))
		user.put_in_hands(R)

/obj/item/device/healthanalyzerpro/attack(mob/living/L, mob/living/user)
	if(!user.dexterity_check()) //it's a complex thingy
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(user.hallucinating())
		hallucinate_scan(L,user)
		return
	if(mode == "Health Scan" || mode == "Simplified Health Scan")
		health_scan(L,user)
	if(mode == "Advanced Health Scan")
		if(istype(L,/mob/living/carbon/human/))
			body_scan(L,user)
	if(mode == "Autopsy Scan")
		if(istype(L,/mob/living/carbon/human/))
			autopsy_scan(L,user)
	src.add_fingerprint(user)

/obj/item/device/healthanalyzerpro/preattack(atom/O, mob/user) //snowlakes
	if(mode == "Reagents Scan")
		reagent_scan(O,user)
	if(mode == "Immunity Scan")
		immune_scan(O,user)
	src.add_fingerprint(user)

/obj/item/device/healthanalyzerpro/attack_self(mob/living/user)
	. = ..()
	if(.)
		return
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(last_reading)
		if(!user.hallucinating())
			to_chat(user, "<span class='bnotice'>Accessing Prior Scan Result</span>")
			if(mode == "Autopsy Scan" || mode == "Advanced Health Scan")
				user << browse(last_reading, "window=borerscan;size=430x600")
			else
				to_chat(user, last_reading)
		else
			hallucinate_scan(user)
	src.add_fingerprint(user)

/obj/item/device/healthanalyzerpro/proc/hallucinate_scan(mob/living/M, mob/living/user)
	if(M && M.isDead())
		user.show_message("<span class='game say'><b>\The [src] beeps</b>, \"It's dead, Jim.\"</span>", MESSAGE_HEAR ,"<span class='notice'>\The [src] glows black.</span>")
	else
		to_chat(user, "<span class='notice'>\The [src] glows [pick("red", "green", "blue", "pink")]! You wonder what that would mean.</span>")


//Health Scan and Simplified Health Scan

/obj/item/device/healthanalyzerpro/proc/health_scan(mob/living/M, mob/living/user)
	var/scan_detail
	if(mode == "Health Scan") scan_detail = 1
	else scan_detail = 0
	if(last_scantime + 1 SECONDS < world.time)
		last_reading = healthanalyze(M, user, scan_detail, silent = FALSE)
		last_scantime = world.time
	else
		last_reading = healthanalyze(M, user, scan_detail, silent = TRUE)

//Autopsy Function

/obj/item/device/healthanalyzerpro/proc/autopsy_scan(mob/living/carbon/human/M, mob/living/user)
	if(!istype(M))
		return
	if(!can_operate(M, user))
		to_chat(user, "<span class='warning'>Put the subject on a surgical unit.</span>")
		return
	to_chat(user, "<span class='info'>You start the advanced autopsy scan...</span>")
	if(do_mob(user, M, 100))
		playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
		if(target_name != M.name)
			target_name = M.name
			src.wdata = list()
			src.chemtraces = list()
			src.timeofdeath = null

			src.timeofdeath = M.timeofdeath
		var/scan_success
		for(var/organ_name in M.organs_by_name)
			var/datum/organ/external/O = M.get_organ(organ_name)
			if(O && O.open)
				src.add_data(O)
				scan_success += add_data(O)
		var/dat
		dat = format_autopsy_data()
		if(!scan_success) //change to dat
			to_chat(user, "<span class='warning'>Insuffient data retrieved. Please ensure that subject has proper surgical incisions.</span>")
		else
			to_chat(user, "<span class='info'>Autopsy analysis of [M] cocluded.</span>")
			user << browse(dat, "window=borerscan;size=430x600")
			last_reading = dat
			last_scantime = world.time

/obj/item/device/healthanalyzerpro/proc/add_data(var/datum/organ/external/O)
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
		return 0
	for(var/V in O.autopsy_data)
		var/datum/autopsy_data/W = O.autopsy_data[V]
		if(!W.pretend_weapon)
			W.pretend_weapon = W.weapon
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
	return 1

/obj/item/device/healthanalyzerpro/proc/format_autopsy_data() //slightly modified code from autopsy scanner
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
	return scan_data

//Advanced Health Scanner functions, basicly advanced body scanner

/obj/item/device/healthanalyzerpro/proc/body_scan(mob/living/M as mob, mob/living/user as mob)
	if (!M)
		return
	if(!istype(M, /mob/living/carbon/human))
		to_chat(src, "<span class='warning'>This module can only scan compatible lifeforms.</span>")
		return
	to_chat(user, "<span class='info'>You start the advanced medical scanning procedure...</span>")
	if(do_mob(user, M, 50))
		playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
		to_chat(user, "<span class='info'>Showing medical statistics of [M]...</span>")
		var/dat
		dat = format_health_data(get_health_data(M))
		user << browse(dat, "window=borerscan;size=430x600")
		last_reading = dat
		last_scantime = world.time
	return

/obj/item/device/healthanalyzerpro/proc/get_health_data(mob/living/M as mob, mob/living/user as mob)
	var/mob/living/carbon/human/H = M
	var/list/health_data = list(
		"stationtime" = worldtime2text(),
		"stat" = H.stat,
		"health" = H.health,
		"virus_present" = H.virus2.len,
		"bruteloss" = H.getBruteLoss(),
		"fireloss" = H.getFireLoss(),
		"oxyloss" = H.getOxyLoss(),
		"toxloss" = H.getToxLoss(),
		"rads" = H.radiation,
		"radtick" = H.rad_tick,
		"radstage" = H.get_rad_stage(),
		"cloneloss" = H.getCloneLoss(),
		"brainloss" = H.getBrainLoss(),
		"paralysis" = H.paralysis,
		"bodytemp" = H.bodytemperature,
		"borer_present_head" = H.has_brain_worms(),
		"borer_present_chest" = H.has_brain_worms(LIMB_CHEST),
		"borer_present_r_arm" = H.has_brain_worms(LIMB_RIGHT_ARM),
		"borer_present_l_arm" = H.has_brain_worms(LIMB_LEFT_ARM),
		"borer_present_r_leg" = H.has_brain_worms(LIMB_RIGHT_LEG),
		"borer_present_l_leg" = H.has_brain_worms(LIMB_LEFT_LEG),
		"inaprovaline_amount" = H.reagents.get_reagent_amount(INAPROVALINE),
		"dexalin_amount" = H.reagents.get_reagent_amount(DEXALIN),
		"stoxin_amount" = H.reagents.get_reagent_amount(STOXIN),
		"bicaridine_amount" = H.reagents.get_reagent_amount(BICARIDINE),
		"dermaline_amount" = H.reagents.get_reagent_amount(DERMALINE),
		"blood_amount" = H.vessel.get_reagent_amount(BLOOD),
		"all_chems" = H.reagents.reagent_list,
		"btype" = H.dna.b_type,
		"disabilities" = H.sdisabilities,
		"tg_diseases_list" = H.viruses,
		"lung_ruptured" = H.is_lung_ruptured(),
		"external_organs" = H.organs.Copy(),
		"internal_organs" = H.internal_organs.Copy()
		)
	return health_data


/obj/item/device/healthanalyzerpro/proc/format_health_data(var/list/occ)
	var/known_implants = list(/obj/item/weapon/implant/chem, /obj/item/weapon/implant/death_alarm, /obj/item/weapon/implant/loyalty, /obj/item/weapon/implant/tracking)
	var/dat = "<font color='blue'><b>Scan performed at [occ["stationtime"]]</b></font><br>"
	dat += "<font color='blue'><b>Target Statistics:</b></font><br>"
	var/aux
	switch (occ["stat"])
		if(0)
			aux = "Conscious"
		if(1)
			aux = "Unconscious"
		else
			aux = "Dead"
	dat += text("[]\tHealth %: [] ([])</font><br>", (occ["health"] > 50 ? "<font color='blue'>" : "<font color='red'>"), occ["health"], aux)
	if(occ["virus_present"])
		dat += "<font color='red'>Pathogen detected in blood stream.</font><br>"
	dat += text("[]\t-Brute Damage %: []</font><br>", (occ["bruteloss"] < 60 ? "<font color='blue'>" : "<font color='red'>"), occ["bruteloss"])
	dat += text("[]\t-Respiratory Damage %: []</font><br>", (occ["oxyloss"] < 60 ? "<font color='blue'>" : "<font color='red'>"), occ["oxyloss"])
	dat += text("[]\t-Toxin Content %: []</font><br>", (occ["toxloss"] < 60 ? "<font color='blue'>" : "<font color='red'>"), occ["toxloss"])
	dat += text("[]\t-Burn Severity %: []</font><br><br>", (occ["fireloss"] < 60 ? "<font color='blue'>" : "<font color='red'>"), occ["fireloss"])

	dat += text("[]\tRadiation Level %: []</font><br>", (occ["rads"] < 10 ?"<font color='blue'>" : "<font color='red'>"), occ["rads"])
	if(occ["radtick"] > 0)
		dat += text("<font color='red'>Radiation sickness progression: <b>[occ["radtick"]]</b> Stage: <b>[occ["radstage"]]</b></font><br>")
	dat += text("[]\tGenetic Tissue Damage %: []</font><br>", (occ["cloneloss"] < 1 ?"<font color='blue'>" : "<font color='red'>"), occ["cloneloss"])
	dat += text("[]\tApprox. Brain Damage %: []</font><br>", (occ["brainloss"] < 1 ?"<font color='blue'>" : "<font color='red'>"), occ["brainloss"])
	dat += text("Paralysis Summary %: [] ([] seconds left!)<br>", occ["paralysis"], round(occ["paralysis"] / 4))
	dat += text("Body Temperature: [occ["bodytemp"]-T0C]&deg;C ([occ["bodytemp"]*1.8-459.67]&deg;F)<br><HR>")

	if(occ["borer_present_head"])
		dat += "Large growth detected in frontal lobe, possibly cancerous. Surgical removal is recommended.<br>"
	if(occ["borer_present_chest"])
		dat += "Large growth detected in chest cavity, possibly cancerous. Surgical removal is recommended.<br>"
	if(occ["borer_present_r_arm"])
		dat += "Large growth detected in right arm, possibly cancerous. Surgical removal is recommended.<br>"
	if(occ["borer_present_l_arm"])
		dat += "Large growth detected in left arm, possibly cancerous. Surgical removal is recommended.<br>"
	if(occ["borer_present_r_leg"])
		dat += "Large growth detected in right leg, possibly cancerous. Surgical removal is recommended.<br>"
	if(occ["borer_present_l_leg"])
		dat += "Large growth detected in left leg, possibly cancerous. Surgical removal is recommended.<br>"

	dat += text("[]\tBlood Level %: [] ([] units)</FONT><BR>", (occ["blood_amount"] > 448 ?"<font color='blue'>" : "<font color='red'>"), occ["blood_amount"]*100 / 560, occ["blood_amount"])
	dat += text("<font color='blue'>\tBlood Type: []</FONT><BR>", occ["btype"])

	dat += text("Inaprovaline: [] units<BR>", occ["inaprovaline_amount"])
	dat += text("Soporific: [] units<BR>", occ["stoxin_amount"])
	dat += text("[]\tDermaline: [] units</FONT><BR>", (occ["dermaline_amount"] < 30 ? "<font color='black'>" : "<font color='red'>"), occ["dermaline_amount"])
	dat += text("[]\tBicaridine: [] units<BR>", (occ["bicaridine_amount"] < 30 ? "<font color='black'>" : "<font color='red'>"), occ["bicaridine_amount"])
	dat += text("[]\tDexalin: [] units<BR>", (occ["dexalin_amount"] < 30 ? "<font color='black'>" : "<font color='red'>"), occ["dexalin_amount"])

	for(var/datum/disease/D in occ["tg_diseases_list"])
		if(!D.hidden[SCANNER])
			dat += text("<BR><font color='red'><B>Warning: [D.form] Detected</B>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]</FONT><BR>")

	dat += "<HR><table border='1'>"
	dat += "<tr>"
	dat += "<th>Organ</th>"
	dat += "<th>Burn Damage</th>"
	dat += "<th>Brute Damage</th>"
	dat += "<th>Other Wounds</th>"
	dat += "</tr>"

	for(var/datum/organ/external/e in occ["external_organs"])
		var/AN = ""
		var/open = ""
		var/infected = ""
		var/imp = ""
		var/bled = ""
		var/robot = ""
		var/splint = ""
		var/internal_bleeding = ""
		var/lung_ruptured = ""
		var/e_cancer = ""
		var/bone_strengthened = ""

		dat += "<tr>"

		for(var/datum/wound/W in e.wounds)
			if(W.internal)
				internal_bleeding = "<br>Internal bleeding"
				break
		if(istype(e, /datum/organ/external/chest) && occ["lung_ruptured"])
			lung_ruptured = "Lung ruptured:"
		if(e.status & ORGAN_SPLINTED)
			splint = "Splinted:"
		if(e.status & ORGAN_BLEEDING)
			bled = "Bleeding:"
		if(e.status & ORGAN_BROKEN)
			AN = "[e.broken_description]:"
		if(e.status & ORGAN_ROBOT)
			robot = "Prosthetic:"
		if(e.open)
			open = "Open:"
		if(e.min_broken_damage != initial(e.min_broken_damage))
			var/difference = e.min_broken_damage - initial(e.min_broken_damage)
			if(difference > 0)
				difference = "+[difference]"
			bone_strengthened = "Altered bone strength ([difference]g/cm<sup>2</sup>)"

		switch (e.germ_level)
			if (INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
				infected = "Mild Infection:"
			if (INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infected = "Mild Infection+:"
			if (INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infected = "Mild Infection++:"
			if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
				infected = "Acute Infection:"
			if (INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infected = "Acute Infection+:"
			if (INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 400)
				infected = "Acute Infection++:"
			if (INFECTION_LEVEL_THREE to INFINITY)
				infected = "Septic:"

		if(e.implants.len)
			var/unknown_body = 0
			for(var/I in e.implants)
				if(is_type_in_list(I,known_implants))
					imp += "Implant detected:"
				else
					unknown_body++
			if(unknown_body || e.hidden)
				imp += "Unknown body present:"

		switch(e.cancer_stage)
			if(CANCER_STAGE_BENIGN to CANCER_STAGE_SMALL_TUMOR)
				e_cancer = "Benign Tumor:"
			if(CANCER_STAGE_SMALL_TUMOR to CANCER_STAGE_LARGE_TUMOR)
				e_cancer = "Small Tumor:"
			if(CANCER_STAGE_LARGE_TUMOR to CANCER_STAGE_METASTASIS)
				e_cancer = "Large Tumor:"
			if(CANCER_STAGE_METASTASIS to INFINITY)
				e_cancer = "Metastatic Tumor:"

		if(!AN && !open && !infected && !e_cancer & !imp)
			AN = "None:"
		if(e.status & ORGAN_DESTROYED)
			dat += "<td>[e.display_name]</td><td>-</td><td>-</td><td><font color='red'>Not Found</font></td>"
		else
			dat += "<td>[e.display_name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][e_cancer][internal_bleeding][lung_ruptured][bone_strengthened]</td>"
		dat += "</tr>"

	var/list/organs_to_list = list(
	/datum/organ/internal/lungs,/datum/organ/internal/liver,
	/datum/organ/internal/kidney,/datum/organ/internal/brain,
	/datum/organ/internal/appendix,/datum/organ/internal/eyes)

	for(var/datum/organ/internal/i in occ["internal_organs"])
		var/mech = ""
		if(i.robotic == 1)
			mech = "Assisted:"
		if(i.robotic == 2)
			mech = "Mechanical:"

		var/infection = "None"
		switch (i.germ_level)
			if (1 to INFECTION_LEVEL_ONE + 200)
				infection = "Mild Infection:"
			if (INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infection = "Mild Infection+:"
			if (INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infection = "Mild Infection++:"
			if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
				infection = "Acute Infection:"
			if (INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infection = "Acute Infection+:"
			if (INFECTION_LEVEL_TWO + 300 to INFINITY)
				infection = "Acute Infection++:"

		var/i_cancer
		switch(i.cancer_stage)
			if(CANCER_STAGE_BENIGN to CANCER_STAGE_SMALL_TUMOR)
				i_cancer = "Benign Tumor:"
			if(CANCER_STAGE_SMALL_TUMOR to CANCER_STAGE_LARGE_TUMOR)
				i_cancer = "Small Tumor:"
			if(CANCER_STAGE_LARGE_TUMOR to CANCER_STAGE_METASTASIS)
				i_cancer = "Large Tumor:"
			if(CANCER_STAGE_METASTASIS to INFINITY)
				i_cancer = "Metastatic Tumor:"

		dat += "<tr>"
		if(i.status & ORGAN_CUT_AWAY)
			dat += "<td>[i.name]</td><td>-</td><td>-</td><td><font color='red'>Surgically Detached</font></td>"
		else
			dat += "<td>[i.name]</td><td>N/A</td><td>[i.damage]</td><td>[infection][i_cancer][mech]</td><td></td>"
		dat += "</tr>"
		for(var/organtype in organs_to_list)
			if(istype(i,organtype))
				organs_to_list -= organtype
				break
	for(var/path in organs_to_list)
		var/datum/organ/internal/i = path
		dat += "<tr><td>[initial(i.name)]</td><td>-</td><td>-</td><td><font color='red'>Not Found</font></td></tr>"
	dat += "</table>"

	if(occ["sdisabilities"] & BLIND)
		dat += text("<font color='red'>Cataracts detected.</font><BR>")
	if(occ["sdisabilities"] & NEARSIGHTED)
		dat += text("<font color='red'>Retinal misalignment detected.</font><BR>")
	return dat

//Reagent Scan function

/obj/item/device/healthanalyzerpro/proc/reagent_scan(atom/O, mob/user)
	if(O.reagents)
		to_chat(user, "<span class='info'>You start the reagents scan...</span>")
		if(do_mob(user, O, 20))
			playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
			var/chems = ""
			var/dat = ""
			if(O.reagents.reagent_list.len)
				for(var/datum/reagent/R in O.reagents.reagent_list)
					var/reagent_percent = (R.volume/O.reagents.total_volume)*100
					chems += "<br><span class='notice'>[R] ["([R.volume] units, [reagent_percent]%)"]</span>"
			if(chems)
				dat += "<span class='notice'>Chemicals found in \the [O]:[chems]</span>"
				to_chat(user, "[dat]")
			else
				dat = "<span class='notice'>No active chemical agents found in \the [O].</span>"
				to_chat(user, "[dat]")
			last_reading = dat
			last_scantime = world.time

//the fucking virology scanner part

/obj/item/device/healthanalyzerpro/proc/immune_scan(atom/O, mob/user)
	if(!immune)
		immune = new
	if(do_mob(user, O, 10))
		immune.attack(O,usr)
		last_scantime = world.time
		qdel(immune)
		immune = null
