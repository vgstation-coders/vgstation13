#define CLONEPODRANGE 7
/obj/machinery/computer/cloning
	name = "cloning console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "cloning"
	circuit = "/obj/item/weapon/circuitboard/cloning"
	var/list/links = list() //list of machines connected to this cloning console.
	req_access = list(access_heads) //Only used for record deletion right now.
	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	//var/obj/machinery/species_modifier/species_mod = null //linked Species Modifier. For handling species.
	var/obj/machinery/cloning/clonepod/pod1 = null //Linked cloning pod.
	var/temp = ""
	var/scantemp = "Scanner unoccupied"
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/dna2/record/active_record = null
	var/obj/item/weapon/disk/data/diskette = null //Mostly so the geneticist can steal everything.
	var/loading = 0 // Nice loading text
	var/available_species = list("Human","Tajaran","Skrell","Unathi","Grey","Plasmamen","Vox")

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/cloning/New()
	..()
	spawn(5)
		updatemodules()
		return
	return

/obj/machinery/computer/cloning/initialize()
	pod1 = findcloner()

/obj/machinery/computer/cloning/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return ""

/obj/machinery/computer/cloning/canLink(var/obj/O)
	return (istype(O,/obj/machinery/cloning) && get_dist(src,O) < CLONEPODRANGE)

/obj/machinery/computer/cloning/isLinkedWith(var/obj/O)
	return O != null && O in links

/obj/machinery/computer/cloning/getLink(var/idx)
	return (idx >= 1 && idx <= links.len) ? links[idx] : null

/obj/machinery/computer/cloning/linkWith(var/mob/user, var/obj/O, var/link/context)
	if(istype(O, /obj/machinery/cloning/clonepod))
		pod1 = O
		return 1
/*	if(istype(O, /obj/machinery/cloning/species_modifier))
		species_mod = O
		return 1
*/

/obj/machinery/computer/cloning/proc/updatemodules()
	scanner = findscanner()
	if (!isnull(pod1))
		pod1.connected = src // Some variable the pod needs

/obj/machinery/computer/cloning/proc/findscanner()
	var/obj/machinery/dna_scannernew/scannerf = null

	// Loop through every direction
	for(dir in list(NORTH,EAST,SOUTH,WEST))

		// Try to find a scanner in that direction
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, dir))

		// If found, then we break, and return the scanner
		if (!isnull(scannerf))
			break

	// If no scanner was found, it will return null
	return scannerf

/obj/machinery/computer/cloning/proc/findcloner()
	var/obj/machinery/cloning/clonepod/pod_found = null
	for (pod_found in orange(src, CLONEPODRANGE))
		if(pod_found.connected)
			continue
		pod_found.connected = src
		return pod_found

#undef CLONEPODRANGE

/obj/machinery/computer/cloning/attackby(obj/item/W as obj, mob/user as mob)
	. = ..()
	if(.)
		return .
	if (istype(W, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if (!diskette)
			if(user.drop_item(W, src))
				diskette = W
				to_chat(user, "You insert \the [W].")
				updateUsrDialog()
				return 1

/obj/machinery/computer/cloning/emag(mob/user)
	if(!emagged)
		emagged = 1
		user.visible_message("<span class='warning'>[user] slides something into \the [src]'s card-reader.</span>","<span class='warning'>You disable \the [src]'s safety overrides.</span>")

/obj/machinery/computer/cloning/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_hand(mob/user as mob)
	user.set_machine(src)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	updatemodules()

	var/dat = "<h3>Cloning System Control</h3>"

	dat += {"<font size=-1><a href='byond://?src=\ref[src];refresh=1'>Refresh</a></font>
		<br><tt>[temp]</tt><br>"}
	switch(menu)
		if(1)
			// Modules
			dat += "<h4>Modules</h4>"
			//dat += "<a href='byond://?src=\ref[src];relmodules=1'>Reload Modules</a>"
			if (isnull(scanner))
				dat += " <font color=red>Scanner-ERROR</font><br>"
			else
				dat += " <font color=green>Scanner-Found!</font><br>"
			if (isnull(pod1))
				dat += " <font color=red>Pod-ERROR</font><br>"
			else
				dat += " <font color=green>Pod-Found!</font><br>"

			// Scanner
			dat += "<h4>Scanner Functions</h4>"

			if(loading)
				dat += "<b>Scanning...</b><br>"
			else
				dat += "<b>[scantemp]</b><br>"

			if (isnull(scanner))
				dat += "No scanner connected!<br>"
			else
				if (scanner.occupant)
					if(scantemp == "Scanner unoccupied") scantemp = "" // Stupid check to remove the text

					dat += "<a href='byond://?src=\ref[src];scan=1'>Scan - [scanner.occupant]</a><br>"
				else
					scantemp = "Scanner unoccupied"

				dat += "Lock status: <a href='byond://?src=\ref[src];lock=1'>[scanner.locked ? "Locked" : "Unlocked"]</a><br>"

			if (!isnull(pod1))
				dat += "Biomass: <i>[pod1.biomass]</i><br>"

			// Database

			dat += {"<h4>Database Functions</h4>
				<a href='byond://?src=\ref[src];menu=2'>View Records</a><br>"}
			if (diskette)
				dat += "<a href='byond://?src=\ref[src];disk=eject'>Eject Disk</a>"


		if(2)

			dat += {"<h4>Current records</h4>
				<a href='byond://?src=\ref[src];menu=1'>Back</a><br><ul>"}
			for(var/datum/dna2/record/R in records)
				dat += "<li><a href='byond://?src=\ref[src];view_rec=\ref[R]'>[R.dna.real_name && R.dna.real_name != "" ? R.dna.real_name : "Unknown"]</a></li>"

		if(3)

			dat += {"<h4>Selected Record</h4>
				<a href='byond://?src=\ref[src];menu=2'>Back</a><br>"}
			if (!active_record)
				dat += "<font color=red>ERROR: Record not found.</font>"
			else
				dat += {"<br><font size=1><a href='byond://?src=\ref[src];del_rec=1'>Edit Record</a></font><br>
					<b>Name:</b> [active_record.dna.real_name && active_record.dna.real_name != "" ? active_record.dna.real_name : "Unknown"]<br>"}
				var/obj/item/weapon/implant/health/H = null
				if(active_record.implant)
					H=locate(active_record.implant)

				if ((H) && (istype(H)))
					dat += "<b>Health:</b> [H.sensehealth()] | OXY-BURN-TOX-BRUTE<br>"
				else
					dat += "<font color=red>Unable to locate implant.</font><br>"

				if (!isnull(diskette))

					dat += {"<a href='byond://?src=\ref[src];disk=load'>Load from disk.</a>
						| Save: <a href='byond://?src=\ref[src];save_disk=ue'>UI + UE</a>
						| Save: <a href='byond://?src=\ref[src];save_disk=ui'>UI</a>
						| Save: <a href='byond://?src=\ref[src];save_disk=se'>SE</a>
						<br>"}
				else
					dat += "<br>" //Keeping a line empty for appearances I guess.

				dat += {"<b>UI:</b> [active_record.dna.uni_identity]<br>
				<b>SE:</b> [active_record.dna.struc_enzymes]<br><br>"}

				if(pod1 && pod1.biomass >= CLONE_BIOMASS)
					dat += {"<a href='byond://?src=\ref[src];clone=\ref[active_record]'>Clone</a><br>"}
				else
					dat += {"<b>Insufficient biomass</b><br>"}

		if(4)
			if (!active_record)
				menu = 2
			dat = {"[temp]<br>
                        [(emagged) ? "<h4> Edit Record </h4>\
						<b><a href='byond://?src=\ref[src];change_name=1'>Change name.</a></b><br>\
                        <b><a href='byond://?src=\ref[src];change_species=1'>Change Species.</a></b><br>" : ""]
                        <h4>Record Deletion</h4>
                        <b><a href='byond://?src=\ref[src];del_rec=1'>Scan card to confirm.</a></b><br>
                        <b><a href='byond://?src=\ref[src];menu=3'>Return</a></b>"}
	user << browse(dat, "window=cloning")
	onclose(user, "cloning")
	return

/obj/machinery/computer/cloning/Topic(href, href_list)
	if(..())
		return

	if(loading)
		return

	if ((href_list["scan"]) && (!isnull(scanner)))
		scantemp = ""

		loading = 1
		updateUsrDialog()

		spawn(20)
			scan_mob(scanner.occupant)

			loading = 0
			updateUsrDialog()


		//No locking an open scanner.
	else if ((href_list["lock"]) && (!isnull(scanner)))
		if ((!scanner.locked) && (scanner.occupant))
			scanner.locked = 1
		else
			scanner.locked = 0

	else if (href_list["view_rec"])
		active_record = locate(href_list["view_rec"])
		if(istype(active_record,/datum/dna2/record))
			if ((isnull(active_record.ckey)))
				qdel(active_record)
				active_record = null
				temp = "ERROR: Record Corrupt"
			else
				menu = 3
		else
			active_record = null
			temp = "Record missing."

	else if (href_list["del_rec"])
		if ((!active_record) || (menu < 3))
			return
		if (menu == 3) //If we are viewing a record, confirm deletion
			temp = "Edit record?"
			menu = 4

		else if (menu == 4)
			var/obj/item/weapon/card/id/C = usr.get_active_hand()
			if (istype(C)||istype(C, /obj/item/device/pda))
				if(check_access(C))
					records.Remove(active_record)
					qdel(active_record)
					active_record = null
					temp = "Record deleted."
					menu = 2
				else
					temp = "Access Denied."

	else if (href_list["disk"]) //Load or eject.
		switch(href_list["disk"])
			if("load")
				if ((isnull(diskette)) || isnull(diskette.buf))
					temp = "Load error."
					updateUsrDialog()
					return
				if (isnull(active_record))
					temp = "Record error."
					menu = 1
					updateUsrDialog()
					return

				active_record = diskette.buf

				temp = "Load successful."
			if("eject")
				if (!isnull(diskette))
					diskette.loc = loc
					diskette = null

	else if (href_list["save_disk"]) //Save to disk!
		if ((isnull(diskette)) || (diskette.read_only) || (isnull(active_record)))
			temp = "Save error."
			updateUsrDialog()
			return

		// DNA2 makes things a little simpler.
		diskette.buf=active_record
		diskette.buf.types=0
		switch(href_list["save_disk"]) //Save as Ui/Ui+Ue/Se
			if("ui")
				diskette.buf.types=DNA2_BUF_UI
			if("ue")
				diskette.buf.types=DNA2_BUF_UI|DNA2_BUF_UE
			if("se")
				diskette.buf.types=DNA2_BUF_SE
		diskette.name = "data disk - '[active_record.dna.real_name && active_record.dna.real_name != "" ? active_record.dna.real_name : "Unknown"]'"
		temp = "Save \[[href_list["save_disk"]]\] successful."

	else if (href_list["refresh"])
		updateUsrDialog()

	else if (href_list["clone"])
		var/datum/dna2/record/C = locate(href_list["clone"])
		//Look for that player! They better be dead!
		if(istype(C))
			//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
			if(!pod1 || !canLink(pod1)) //If the pod exists BUT it's too far away from the console
				temp = "Error: No Clonepod detected."
			else if(pod1.occupant)
				temp = "Error: Clonepod is currently occupied."
			else if(pod1.biomass < CLONE_BIOMASS)
				temp = "Error: Not enough biomass."
			else if(pod1.mess)
				temp = "Error: Clonepod malfunction."
			else if(!config.revival_cloning)
				temp = "Error: Unable to initiate cloning cycle."

			var/success = pod1.growclone(C)
			if(success)
				temp = "Initiating cloning cycle..."
				records.Remove(C)
				qdel(C)
				C = null
				menu = 1
			else

				var/mob/selected = find_dead_player("[C.ckey]")
				if(!selected)
					temp = "Initiating cloning cycle...<br>Error: Post-initialisation failed. Cloning cycle aborted."
					updateUsrDialog()
					return
				selected << 'sound/machines/chime.ogg'	//probably not the best sound but I think it's reasonable
				var/answer = alert(selected,"Do you want to return to life?","Cloning","Yes","No")
				if(answer != "No" && pod1.growclone(C))
					temp = "Initiating cloning cycle..."
					records.Remove(C)
					qdel(C)
					menu = 1
				else
					temp = "Initiating cloning cycle...<br>Error: Post-initialisation failed. Cloning cycle aborted."

		else
			temp = "Error: Data corruption."

	else if (href_list["menu"])
		menu = text2num(href_list["menu"])

	else if (emagged && active_record)
		if(href_list["change_name"])
			var/name_of_victim = input(usr, "/^!@#! ERROR: NAME PROTOCOLS OVERRIDDEN. MANUALLY INSERT NAME.", "Change Record Name") as text|null
			active_record.dna.real_name = name_of_victim
		if(href_list["change_species"])
			var/species_of_victim = input(usr, "/^!@#! ERROR: SPECIES PROTOCOLS OVERRIDDEN. MANUALLY INSERT SPECIES.","Change Record Species") as null|anything in list("random")+available_species
			if(species_of_victim == "random")
				active_record.dna.species = pick(available_species)
			else
				active_record.dna.species = species_of_victim
	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject as mob)
	if ((isnull(subject)) || (!(ishuman(subject))) || (!subject.dna) || (istype(subject, /mob/living/carbon/human/manifested)))
		scantemp = "Error: Unable to locate valid genetic data."
		return
	if (!subject.has_brain())
		scantemp = "Error: No signs of intelligence detected."
		return
	if ((M_NOCLONE in subject.mutations) || (subject.suiciding == 1))
		scantemp = "Error: Mental interface failure." //uncloneable, this guy is done for
		return
	if (!subject.client && subject.mind) //this guy ghosted from his corpse, but he can still come back!
		for(var/mob/dead/observer/ghost in player_list)
			if(ghost.mind == subject.mind && ghost.client && ghost.can_reenter_corpse)
				ghost << 'sound/effects/adminhelp.ogg'
				to_chat(ghost, "<span class='interface'><b><font size = 3>Someone is trying to clone your corpse. Return to your body if you want to be cloned!</b> \
					(Verbs -> Ghost -> Re-enter corpse, or <a href='?src=\ref[ghost];reentercorpse=1'>click here!</a>)</font></span>")
				scantemp = "Error: Subject's brain is not responding to scanning stimuli, subject may be brain dead. Please try again in five seconds."
				return
		//we couldn't find a suitable ghost.
		scantemp = "Error: Mental interface failure."
		return
	if (!subject.ckey) //checking this only now, since a ghosted player won't have a ckey
		scantemp = "Error: Mental interface failure." //ideally would never happen but a check never hurts
		return
	else
		if(!isnull(find_record(subject.ckey)))
			scantemp = "Subject already in database."
			return

	subject.dna.check_integrity()
	var/datum/organ/internal/brain/Brain = subject.internal_organs_by_name["brain"]
	// Borer sanity checks.
	var/mob/living/simple_animal/borer/B=subject.has_brain_worms()
	if(B && B.controlling)
		// This shouldn't happen, but lolsanity.
		subject.do_release_control(1)

	var/datum/dna2/record/R = new /datum/dna2/record()
	if(!isnull(Brain.owner_dna) && Brain.owner_dna != subject.dna)
		R.dna = Brain.owner_dna
	else
		R.dna=subject.dna
	R.ckey = subject.ckey
	R.id= copytext(md5(R.dna.real_name), 2, 6)
	R.name=R.dna.real_name
	R.types=DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	R.languages = subject.languages.Copy()

	//Add an implant if needed
	var/obj/item/weapon/implant/health/imp = locate(/obj/item/weapon/implant/health, subject)
	if (isnull(imp))
		imp = new /obj/item/weapon/implant/health(subject)
		imp.implanted = subject
		R.implant = "\ref[imp]"
	//Update it if needed
	else
		R.implant = "\ref[imp]"

	if (!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.mind = "\ref[subject.mind]"

	records += R
	scantemp = "Subject successfully scanned."

//Find a specific record by key.
/obj/machinery/computer/cloning/proc/find_record(var/find_key)
	var/selected_record = null
	for(var/datum/dna2/record/R in records)
		if (R.ckey == find_key)
			selected_record = R
			break
	return selected_record

/obj/machinery/computer/cloning/update_icon()
	overlays = 0
	if(!(stat & (NOPOWER | BROKEN)))
		if(scanner && scanner.occupant)
			overlays += image(icon = icon, icon_state = "cloning-scan")
		if(pod1 && pod1.occupant)
			overlays += image(icon = icon, icon_state = "cloning-pod")
