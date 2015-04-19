// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	name = "body scanner"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1
	idle_power_usage = 125
	active_power_usage = 250
	var/orient = "LEFT"
	var/scanning = 1
	machine_flags = SCREWTOGGLE | CROWDESTROY
	component_parts = newlist(
		/obj/item/weapon/circuitboard/fullbodyscanner,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module
	)
	var/mob/living/carbon/occupant
	var/locked

	l_color = "#00FF00"

/obj/machinery/bodyscanner/New()
	..()
	RefreshParts()
	spawn( 5 )
		if(orient == "RIGHT")
			icon_state = "body_scanner_0-r"
			generate_console(get_step(get_turf(src), WEST))
		else
			generate_console(get_step(get_turf(src), EAST))
		return
	return

/obj/machinery/bodyscanner/proc/generate_console(turf/T as turf)
	if(!T.density && !T.contents.len)
		var/obj/machinery/body_scanconsole/SC = new /obj/machinery/body_scanconsole(T.loc)
		SC.orient = src.orient
		return 1
	else
		var/obj/machinery/exists = locate(/obj/machinery/body_scanconsole/, T.loc)
		if(exists)
			//We have a console already. Kill it and replace it.
			qdel(exists)
			var/obj/machinery/body_scanconsole/SC = new /obj/machinery/body_scanconsole(T.loc)
			SC.orient = src.orient
			return 1
		else
			//Failed to generate console
			return 0

/obj/machinery/bodyscanner/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		T += SP.rating
	scanning = round(T/3) //9 = virals, BAC, Blood Type; 6 = Blood Type; 3 = basic

/obj/machinery/bodyscanner/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)) && src.occupant)
		SetLuminosity(2)
	else
		SetLuminosity(0)

/obj/machinery/bodyscanner/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(!ismob(O)) //humans only
		return
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc)) //no you can't pull things out of your ass
		return
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.resting) //are you cuffed, dying, lying, stunned or other
		return
	if(O.anchored || !Adjacent(user) || !user.Adjacent(src) || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(occupant)
		user << "<span class='notice'>\The [src] is already occupied!</span>"
		return
	if(isrobot(user))
		if(!istype(user:module, /obj/item/weapon/robot_module/medical))
			user << "<span class='warning'>You do not have the means to do this!</span>"
			return
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		user << "<span class='notice'>Subject cannot have abiotic items on.</span>"
		return
	for(var/mob/living/carbon/slime/M in range(1, L))
		if(M.Victim == L)
			usr << "<span class='notice'>[L] will not fit into \the [src] because they have a slime latched onto their head.</span>"
			return
	if(L == user)
		visible_message("[user] climbs into \the [src].")
	else
		visible_message("[user] places [L] into \the [src].")

	if(L.client)
		L.client.perspective = EYE_PERSPECTIVE
		L.client.eye = src
	L.loc = src
	src.occupant = L
	src.icon_state = "body_scanner_1"
	for(var/obj/OO in src)
		OO.loc = src.loc
		//Foreach goto(154)
	src.add_fingerprint(user)
	return

/obj/machinery/bodyscanner/relaymove(mob/user as mob)
	if(user.stat)
		return
	src.go_out()
	return

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if(usr.stat != 0 || (usr.status_flags & FAKEDEATH))
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Body Scanner"

	if(usr.stat != 0 || (usr.status_flags & FAKEDEATH))
		return
	if(src.occupant)
		usr << "<span class='notice'>\The [src] is already occupied!</span>"
		return
	if(usr.abiotic())
		usr << "<span class='notice'>Subject cannot have abiotic items on.</span>"
		return
	if(usr.buckled)
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	src.icon_state = "body_scanner_1"
	for(var/obj/O in src)
		qdel(O)
	src.add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/proc/go_out()
	if((!( src.occupant ) || src.locked))
		return
	for(var/obj/O in src)
		O.loc = src.loc

	if(src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	src.icon_state = "body_scanner_0"
	return

/obj/machinery/bodyscanner/attackby(obj/item/weapon/W as obj, user as mob)
	if(iscrowbar(W) && occupant)
		return
	if(iswrench(W))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(orient == "RIGHT")
			orient = "LEFT"
			if(generate_console(get_step(get_turf(src), WEST)))
				qdel(locate(/obj/machinery/bodyscanner, get_step(src, EAST)))
			else
				orient = "RIGHT"
				visible_message("<span class='warning'>There is no space!</span>","<span class='warning'>[user] wants to be hardcore, but his CMO won't let him.</span>")
		else
			orient = "RIGHT"
			if(generate_console(get_step(get_turf(src), EAST)))
				qdel(locate(/obj/machinery/bodyscanner, get_step(src, WEST)))
			else
				orient = "LEFT"
				visible_message("<span class='warning'>There is no space!</span>","<span class='warning'>[user] wants to be hardcore, but his CMO won't let him.</span>")
		return
	if(!istype(W, /obj/item/weapon/grab))
		return ..()
	var/obj/item/weapon/grab/G = W
	if((!( istype(G, /obj/item/weapon/grab) ) || !( ismob(G.affecting) )))
		return
	if(src.occupant)
		user << "<span class='notice'>\The [src] is already occupied!</span>"
		return
	if(G.affecting.buckled)
		G.affecting.buckled.unbuckle()
	if(G.affecting.abiotic())
		user << "<span class='notice'>Subject cannot have abiotic items on.</span>"
		return
	var/mob/M = G.affecting
	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src
	src.occupant = M
	src.icon_state = "body_scanner_1"
	for(var/obj/O in src)
		O.loc = src.loc
	src.add_fingerprint(user)
	qdel(G)
	return

/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		else
	return

/obj/machinery/bodyscanner/blob_act()
	if(prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		qdel(src)


/obj/machinery/body_scanconsole
	var/obj/machinery/bodyscanner/connected
	var/known_implants = list(/obj/item/weapon/implant/chem, /obj/item/weapon/implant/death_alarm, /obj/item/weapon/implant/loyalty, /obj/item/weapon/implant/tracking)
	var/delete
	var/temphtml
	name = "body scanner console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "body_scannerconsole"
	density = 1
	anchored = 1
	var/orient = "LEFT"

/obj/machinery/body_scanconsole/New()
	..()
	spawn(5)
		if(orient == "RIGHT")
			icon_state = "body_scannerconsole-r"
			src.connected = locate(/obj/machinery/bodyscanner, get_step(src, EAST))
		else
			src.connected = locate(/obj/machinery/bodyscanner, get_step(src, WEST))
	return

/obj/machinery/body_scanconsole/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		else
	return

/obj/machinery/body_scanconsole/blob_act()
	if(prob(50))
		qdel(src)

/obj/machinery/body_scanconsole/power_change()
	if(stat & BROKEN)
		if(orient == "LEFT")
			icon_state = "body_scannerconsole-p"
		else
			icon_state = "body_scannerconsole-p-r"
	else if(powered())
		if(orient == "LEFT")
			icon_state = "body_scannerconsole"
		else
			icon_state = "body_scannerconsole-r"
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			if(orient == "LEFT")
				icon_state = "body_scannerconsole-p"
			else
				icon_state = "body_scannerconsole-p-r"
			stat |= NOPOWER

/obj/machinery/body_scanconsole/process()
	if (stat & (BROKEN | NOPOWER | MAINT | EMPED))
		use_power = 0
		return

	if (connected && connected.occupant)
		use_power = 2
	else
		use_power = 1

/obj/machinery/body_scanconsole/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/attack_ai(user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswrench(W)&&!connected)
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
		qdel(src)
	else
		return ..()

/obj/machinery/body_scanconsole/attack_hand(user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(!connected || (connected.stat & (NOPOWER|BROKEN)))
		user << "<span class='warning'>This console is not connected to a functioning body scanner.</span>"
		return
	if(!ishuman(connected.occupant))
		user << "<span class='warning'>This device can only scan compatible lifeforms.</span>"
		return

	var/dat
	if(src.delete && src.temphtml) //Window in buffer but its just simple message, so nothing
		src.delete = src.delete
	else if(!src.delete && src.temphtml) //Window in buffer - its a menu, dont add clear message
		dat = text("[]<BR><BR><A href='?src=\ref[];clear=1'>Main Menu</A>", src.temphtml, src)
	else
		if(src.connected) //Is something connected?
			dat = format_occupant_data(src.connected.get_occupant_data())
			dat += "<HR><A href='?src=\ref[src];print=1'>Print</A><BR>"
			if(connected.scanning==3)
				dat += "<font color='red'>Voice recognition active. Activatation key: 'Scanner, print'.</font>"
		else
			dat = "<font color='red'>Error: No Body Scanner connected.</font>"

	dat += text("<BR><A href='?src=\ref[];mach_close=scanconsole'>Close</A>", user)
	user << browse(dat, "window=scanconsole;size=430x600")
	return


/obj/machinery/body_scanconsole/Topic(href, href_list)
	if(..())
		return

	if(href_list["print"])
		if(!src.connected)
			usr << "\icon[src]<span class='warning'>Error: No body scanner connected.</span>"
			return
		var/mob/living/carbon/human/occupant = src.connected.occupant
		if(!src.connected.occupant)
			usr << "\icon[src]<span class='warning'>\The [src.connected] is empty.</span>"
			return
		if(!istype(occupant,/mob/living/carbon/human))
			usr << "\icon[src]<span class='warning'>\The [src.connected] cannot scan that lifeform.</span>"
			return
		var/obj/item/weapon/paper/R = new(src.loc)
		R.name = "paper - 'body scan report'"
		R.info = format_occupant_data(src.connected.get_occupant_data())


/obj/machinery/bodyscanner/proc/get_occupant_data()
	if (!occupant || !istype(occupant, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = occupant
	var/list/occupant_data = list(
		"stationtime" = worldtime2text(),
		"stat" = H.stat,
		"health" = H.health,
		"virus_present" = H.virus2.len,
		"bruteloss" = H.getBruteLoss(),
		"fireloss" = H.getFireLoss(),
		"oxyloss" = H.getOxyLoss(),
		"toxloss" = H.getToxLoss(),
		"rads" = H.radiation,
		"cloneloss" = H.getCloneLoss(),
		"brainloss" = H.getBrainLoss(),
		"paralysis" = H.paralysis,
		"bodytemp" = H.bodytemperature,
		"borer_present" = H.has_brain_worms(),
		"inaprovaline_amount" = H.reagents.get_reagent_amount("inaprovaline"),
		"dexalin_amount" = H.reagents.get_reagent_amount("dexalin"),
		"stoxin_amount" = H.reagents.get_reagent_amount("stoxin"),
		"bicaridine_amount" = H.reagents.get_reagent_amount("bicaridine"),
		"dermaline_amount" = H.reagents.get_reagent_amount("dermaline"),
		"blood_amount" = H.vessel.get_reagent_amount("blood"),
		"all_chems" = H.reagents.reagent_list,
		"btype" = H.dna.b_type,
		"disabilities" = H.sdisabilities,
		"tg_diseases_list" = H.viruses,
		"lung_ruptured" = H.is_lung_ruptured(),
		"external_organs" = H.organs.Copy(),
		"internal_organs" = H.internal_organs.Copy()
		)
	return occupant_data


/obj/machinery/body_scanconsole/proc/format_occupant_data(var/list/occ)
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
		dat += "<font color='red'>Viral pathogen detected in blood stream.</font><br>"
	dat += text("[]\t-Brute Damage %: []</font><br>", (occ["bruteloss"] < 60 ? "<font color='blue'>" : "<font color='red'>"), occ["bruteloss"])
	dat += text("[]\t-Respiratory Damage %: []</font><br>", (occ["oxyloss"] < 60 ? "<font color='blue'>" : "<font color='red'>"), occ["oxyloss"])
	dat += text("[]\t-Toxin Content %: []</font><br>", (occ["toxloss"] < 60 ? "<font color='blue'>" : "<font color='red'>"), occ["toxloss"])
	dat += text("[]\t-Burn Severity %: []</font><br><br>", (occ["fireloss"] < 60 ? "<font color='blue'>" : "<font color='red'>"), occ["fireloss"])

	dat += text("[]\tRadiation Level %: []</font><br>", (occ["rads"] < 10 ?"<font color='blue'>" : "<font color='red'>"), occ["rads"])
	dat += text("[]\tGenetic Tissue Damage %: []</font><br>", (occ["cloneloss"] < 1 ?"<font color='blue'>" : "<font color='red'>"), occ["cloneloss"])
	dat += text("[]\tApprox. Brain Damage %: []</font><br>", (occ["brainloss"] < 1 ?"<font color='blue'>" : "<font color='red'>"), occ["brainloss"])
	dat += text("Paralysis Summary %: [] ([] seconds left!)<br>", occ["paralysis"], round(occ["paralysis"] / 4))
	dat += text("Body Temperature: [occ["bodytemp"]-T0C]&deg;C ([occ["bodytemp"]*1.8-459.67]&deg;F)<br><HR>")

	if(occ["borer_present"])
		dat += "Large growth detected in frontal lobe, possibly cancerous. Surgical removal is recommended.<br>"

	dat += text("[]\tBlood Level %: [] ([] units)</FONT><BR>", (occ["blood_amount"] > 448 ?"<font color='blue'>" : "<font color='red'>"), occ["blood_amount"]*100 / 560, occ["blood_amount"])
	if(connected.scanning>=2)
		dat += text("<font color='blue'>\tBlood Type: []</FONT><BR>", occ["btype"])

	dat += text("Inaprovaline: [] units<BR>", occ["inaprovaline_amount"])
	dat += text("Soporific: [] units<BR>", occ["stoxin_amount"])
	dat += text("[]\tDermaline: [] units</FONT><BR>", (occ["dermaline_amount"] < 30 ? "<font color='black'>" : "<font color='red'>"), occ["dermaline_amount"])
	dat += text("[]\tBicaridine: [] units<BR>", (occ["bicaridine_amount"] < 30 ? "<font color='black'>" : "<font color='red'>"), occ["bicaridine_amount"])
	dat += text("[]\tDexalin: [] units<BR>", (occ["dexalin_amount"] < 30 ? "<font color='black'>" : "<font color='red'>"), occ["dexalin_amount"])

	if(connected.scanning>2)
		for(var/datum/reagent/R in occ["all_chems"])
			if(R.id == "blood" || R.id == "inaprovaline" || R.id == "stoxin" || R.id == "dermaline" || R.id == "bicaridine" || R.id == "dexalin") return //no repeats
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

		if(!AN && !open && !infected & !imp)
			AN = "None:"
		if(!(e.status & ORGAN_DESTROYED))
			dat += "<td>[e.display_name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][internal_bleeding][lung_ruptured]</td>"
		else
			dat += "<td>[e.display_name]</td><td>-</td><td>-</td><td>Not Found</td>"
		dat += "</tr>"

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

		dat += "<tr>"
		dat += "<td>[i.name]</td><td>N/A</td><td>[i.damage]</td><td>[infection]:[mech]</td><td></td>"
		dat += "</tr>"
	dat += "</table>"

	if(occ["sdisabilities"] & BLIND)
		dat += text("<font color='red'>Cataracts detected.</font><BR>")
	if(occ["sdisabilities"] & NEARSIGHTED)
		dat += text("<font color='red'>Retinal misalignment detected.</font><BR>")
	return dat

/obj/machinery/body_scanconsole/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
	if(!src.connected || src.connected.scanning<3)
		return
	if(speaker in range(3) && findtext(message, "scanner, print"))
		var/mob/living/carbon/human/occupant = src.connected.occupant
		if(!src.connected.occupant||!istype(occupant,/mob/living/carbon/human))
			return
		var/obj/item/weapon/paper/R = new(src.loc)
		R.name = "paper - 'body scan report'"
		R.info = format_occupant_data(src.connected.get_occupant_data())
