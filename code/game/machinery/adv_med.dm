/obj/machinery/bodyscanner
	name = "body scanner"
	icon = 'icons/obj/cryogenics3.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1
	idle_power_usage = 125
	active_power_usage = 250
	var/scanning = 1
	machine_flags = SCREWTOGGLE | CROWDESTROY | EJECTNOTDEL | WRENCHMOVE | FIXED2WORK | EMAGGABLE
	component_parts = newlist(
		/obj/item/weapon/circuitboard/fullbodyscanner,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module
	)
	var/mob/living/carbon/occupant
	var/obj/item/device/antibody_scanner/immune

	light_color = LIGHT_COLOR_GREEN
	light_range_on = 3
	light_power_on = 2
	var/known_implants = list(/obj/item/weapon/implant/chem, /obj/item/weapon/implant/death_alarm, /obj/item/weapon/implant/loyalty, /obj/item/weapon/implant/tracking)
	var/delete
	var/temphtml
	flags = FPRINT | HEAR

/obj/machinery/bodyscanner/New()
	..()
	immune = new
	if(map.nameShort == "deff")
		icon = 'maps/defficiency/medbay.dmi'
	RefreshParts()

/obj/machinery/bodyscanner/Destroy()
	go_out() //Eject everything
	if (immune)
		qdel(immune)
		immune = null
	..()

/obj/machinery/bodyscanner/update_icon()
	icon_state = "body_scanner_[occupant ? "1" : "0"]"

/obj/machinery/bodyscanner/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		T += SP.rating
	scanning = round(T/3) //9 = Reagent details, Blood Type; 6 = Blood Type; 3 = basic. This value is also transformed into efficiency 1 to 1.

/obj/machinery/bodyscanner/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)) && occupant)
		set_light(light_range_on, light_power_on)
	else
		kill_light()

/obj/machinery/bodyscanner/MouseDropTo(atom/movable/O as mob|obj, mob/user as mob)
	if(!ismob(O)) //humans only
		return
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O)) //no you can't pull things out of your ass
		return
	if(user.incapacitated() || user.lying) //are you cuffed, dying, lying, stunned or other
		return
	if(!Adjacent(user) || !user.Adjacent(src) || user.contents.Find(src)) // is the mob too far away from you, or are you too far away from the source
		return
	if(O.locked_to)
		var/datum/locking_category/category = O.locked_to.get_lock_cat_for(O)
		if(!istype(category, /datum/locking_category/buckle/bed/roller))
			return
	else if(O.anchored)
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishigherbeing(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(occupant)
		to_chat(user, "<span class='notice'>\The [src] is already occupied!</span>")
		return
	if(isrobot(user))
		var/mob/living/silicon/robot/robit = usr
		if(!HAS_MODULE_QUIRK(robit, MODULE_CAN_HANDLE_MEDICAL))
			to_chat(user, "<span class='warning'>You do not have the means to do this!</span>")
			return
	var/mob/living/L = O
	if(!istype(L))
		return
	for(var/mob/living/carbon/slime/M in range(1, L))
		if(M.Victim == L)
			to_chat(usr, "<span class='notice'>[L] will not fit into \the [src] because they have a slime latched onto their head.</span>")
			return

	if(L == user)
		visible_message("[user] climbs into \the [src].")
	else
		visible_message("[user] places [L] into \the [src].")

	L.unlock_from() //We checked above that they can ONLY be buckled to a rollerbed to allow this to happen!
	L.forceMove(src)
	L.reset_view()
	occupant = L
	update_icon()
	for(var/obj/OO in src)
		OO.forceMove(loc)
	add_fingerprint(user)
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(light_range_on, light_power_on)
	return

/obj/machinery/bodyscanner/MouseDropFrom(over_object, src_location, var/turf/over_location, src_control, over_control, params)
	if(!ishigherbeing(usr) && !isrobot(usr) || usr.incapacitated() || usr.lying)
		return
	if(!occupant)
		to_chat(usr, "<span class='warning'>The scanner is unoccupied!</span>")
		return
	if(isrobot(usr))
		var/mob/living/silicon/robot/robit = usr
		if(!HAS_MODULE_QUIRK(robit, MODULE_CAN_HANDLE_MEDICAL))
			to_chat(usr, "<span class='warning'>You do not have the means to do this!</span>")
			return
	over_location = get_turf(over_location)
	if(!istype(over_location) || over_location.density)
		return
	if(!Adjacent(over_location))
		return
	if(!(occupant == usr) && (!Adjacent(usr) || !usr.Adjacent(over_location)))
		return
	for(var/atom/movable/A in over_location.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	if(occupant == usr)
		visible_message("[usr] climbs out of \the [src].")
	else
		visible_message("[usr] removes [occupant.name] from \the [src].")
	go_out(over_location, ejector = usr)

/obj/machinery/bodyscanner/relaymove(mob/user as mob)
	if(user.stat)
		return
	go_out(ejector = user)
	return

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if(usr.isUnconscious())
		return
	go_out(ejector = usr)
	add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Body Scanner"

	if(usr.isUnconscious())
		return
	if(src.occupant)
		to_chat(usr, "<span class='notice'>\The [src] is already occupied!</span>")
		return
	if(usr.locked_to)
		return
	usr.pulling = null
	usr.forceMove(src)
	usr.reset_view()
	src.occupant = usr
	update_icon()
	for(var/obj/O in src)
		qdel(O)
	src.add_fingerprint(usr)
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(light_range_on, light_power_on)
	return

/obj/machinery/bodyscanner/proc/go_out(var/exit = loc, var/mob/ejector)
	if(!src.occupant)
		return
	for (var/atom/movable/x in src.contents)
		if(x in component_parts)
			continue
		x.forceMove(src.loc)

	if(!occupant.gcDestroyed)
		occupant.forceMove(exit)
		occupant.reset_view()
		if(istype(ejector) && ejector != occupant)
			var/obj/structure/bed/roller/B = locate() in exit
			if(B)
				B.buckle_mob(occupant, ejector)
				ejector.start_pulling(B)
	occupant = null
	update_icon()
	kill_light()

/obj/machinery/bodyscanner/emag(mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You disable the X-ray dosage limiter on \the [src].</span>")
		to_chat(user, "<span class='notice'>\The [src] emits an ominous hum.</span>")
		emagged = 1
		return 1
	else if (emagged)
		to_chat(user, "<span class='warning'>You re-enable the dosage limiter on \the [src].</span>")
		to_chat(user, "<span class='notice'>\The [src] emits a quiet whine.</span>")
		emagged = 0
		return 0

/obj/machinery/bodyscanner/crowbarDestroy(mob/user, obj/item/tool/crowbar/I)
	if(occupant)
		to_chat(user, "<span class='warning'>You cannot disassemble \the [src], it's occupado.</span>")
		return FALSE
	return ..()

/obj/machinery/bodyscanner/attackby(obj/item/weapon/W as obj, user as mob)
	if(!istype(W, /obj/item/weapon/grab))
		return ..()
	var/obj/item/weapon/grab/G = W
	if((!( istype(G, /obj/item/weapon/grab) ) || !( ismob(G.affecting) )))
		return
	if(src.occupant)
		to_chat(user, "<span class='notice'>\The [src] is already occupied!</span>")
		return

	G.affecting.unlock_from()

	/*if(G.affecting.abiotic())
		to_chat(user, "<span class='notice'>Subject cannot have abiotic items on.</span>")
		return*/
	var/mob/M = G.affecting
	M.forceMove(src)
	M.reset_view()
	src.occupant = M
	update_icon()
	src.add_fingerprint(user)
	qdel(G)
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(light_range_on, light_power_on)
	return

/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(src.loc)
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					ex_act(severity)
				qdel(src)
				return
		else
	return

/obj/machinery/bodyscanner/blob_act()
	if(prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(src.loc)
		qdel(src)


/obj/machinery/bodyscanner/process()
	if (stat & (BROKEN | NOPOWER | MAINT | EMPED))
		use_power = 0
		return
	if (occupant)
		use_power = 2
		if (emagged)
			occupant.apply_radiation(12,RAD_EXTERNAL)

	else
		use_power = 1

/obj/machinery/bodyscanner/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/bodyscanner/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/bodyscanner/attack_hand(mob/user)
	if(..())
		return
	if(!ishuman(occupant))
		to_chat(user, "<span class='warning'>This device can only scan compatible lifeforms.</span>")
		return

	if(!isobserver(user) && (user.loc == src || (!Adjacent(user)&&!issilicon(user)) || user.incapacitated()))
		return

	var/dat
	if(src.delete && src.temphtml) //Window in buffer but its just simple message, so nothing
		src.delete = src.delete
	else if(!src.delete && src.temphtml) //Window in buffer - its a menu, dont add clear message
		dat = text("[]<BR><BR><A href='?src=\ref[];clear=1'>Main Menu</A>", src.temphtml, src)
	else
		dat = format_occupant_data(get_occupant_data(occupant),scanning)
		dat += "<HR><a href='?src=\ref[src];immunity=1'>View Immune System scan</a><br>"
		dat += "<HR><A href='?src=\ref[src];print=1'>Print</A><BR>"

	dat += text("<BR><A href='?src=\ref[];mach_close=scanconsole'>Close</A>", user)
	user << browse(dat, "window=scanconsole;size=430x600")
	return


/obj/machinery/bodyscanner/Topic(href, href_list)
	if(..())
		return

	if(usr.loc == src)
		return

	if(href_list["print"])
		if(!occupant)
			to_chat(usr, "[bicon(src)]<span class='warning'>\The [src] is empty.</span>")
			return
		if(!istype(occupant,/mob/living/carbon/human))
			to_chat(usr, "[bicon(src)]<span class='warning'>\The [src] cannot scan that lifeform.</span>")
			return
		var/obj/item/weapon/paper/R = new(loc)
		R.name = "paper - 'body scan report'"
		R.info = format_occupant_data(get_occupant_data(occupant),scanning)

	else if(href_list["immunity"])
		if(!immune)
			immune = new
		if (occupant)
			immune.attack(occupant,usr)


/proc/get_occupant_data(mob/living/M)
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


/proc/format_occupant_data(var/list/occ,var/efficiency=0)
	var/known_implants = list(/obj/item/weapon/implant/chem, /obj/item/weapon/implant/death_alarm, /obj/item/weapon/implant/loyalty, /obj/item/weapon/implant/tracking)
	var/dat = "<font color='blue'><b>Scan performed at [occ["stationtime"]]</b></font><br>"
	dat += "<font color='blue'><b>Occupant Statistics:</b></font><br>"
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

	if(efficiency>2)
		for(var/datum/reagent/R in occ["all_chems"])
			if(R.id == BLOOD || R.id == INAPROVALINE || R.id == STOXIN || R.id == DERMALINE || R.id == BICARIDINE || R.id == DEXALIN)
				continue //no repeats
			else
				dat += text("<font color='black'>Detected</font> <font color='blue'>[R.volume]</font> <font color='black'>units of</font> <font color='blue'>[R.name]</font><BR>")
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
					imp += "[I] implanted:"
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

		if(!AN && !open && !infected && !e_cancer && !imp)
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

/obj/machinery/bodyscanner/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(scanning<3)
		return
	if(speech.speaker && !speech.frequency)
		if(findtext(speech.message, "print"))
			if(!occupant||!istype(occupant,/mob/living/carbon/human))
				return
			say("Now outputting diagnostic.")
			var/obj/item/weapon/paper/R = new(src.loc)
			R.name = "paper - 'body scan report'"
			R.info = format_occupant_data(get_occupant_data(occupant),scanning)


/obj/machinery/bodyscanner/upgraded
	name = "advanced body scanner"
	component_parts = newlist(
		/obj/item/weapon/circuitboard/fullbodyscanner,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
	)
