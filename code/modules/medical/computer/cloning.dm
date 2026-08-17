#define CLONEPODRANGE 7
#define ERR_NO_CLONEPOD 1
#define ERR_CLONEPOD_OCCUPIED 2
#define ERR_CLONEPOD_BIOMASS 3
#define ERR_CLONEPOD_MESS 4

/obj/machinery/computer/cloning
	name = "cloning console"
	desc = "A computer that takes DNA from a DNA scanner and uses it to clone an organism with a cloning pod."
	icon = 'icons/obj/computer.dmi'
	icon_state = "cloning"
	circuit = "/obj/item/weapon/circuitboard/cloning"
	req_access = list(access_heads) //Only used for record deletion right now.
	var/list/obj/machinery/dna_scannernew/scanners = list() //Linked scanners. For scanning.
	//var/obj/machinery/species_modifier/species_mod = null //linked Species Modifier. For handling species.
	var/list/obj/machinery/cloning/clonepod/pods = list() //Linked cloning pods.
	var/temp = ""
	var/scantemp = "Scanner unoccupied"
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/dna2/record/active_record = null
	var/obj/item/weapon/disk/data/diskette = null //Mostly so the geneticist can steal everything.
	var/loading = 0 // Nice loading text
	var/available_species = list("Human","Tajaran","Skrell","Unathi","Grey","Plasmamen","Vox", "Insectoid")

	light_color = LIGHT_COLOR_BLUE

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag
	)


/obj/machinery/computer/cloning/New()
	..()
	spawn(5)
		updatemodules()
		return
	return

/obj/machinery/computer/cloning/Destroy()
	if(pods.len)
		for(var/obj/machinery/cloning/clonepod/pod in pods)
			pod.connected -= src
		pods.Cut()
	if(scanners.len)
		for(var/obj/machinery/dna_scannernew/scanner in scanners)
			scanner.connected -= src
		scanners.Cut()
	if(diskette)
		if(loc)
			diskette.forceMove(loc)
		else
			qdel(diskette)
		diskette = null
	records.Cut()
	active_record = null

	..()

/obj/machinery/computer/cloning/initialize()
	updatemodules()

/obj/machinery/computer/cloning/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return ""

/obj/machinery/computer/cloning/canLink(var/obj/O)
	return (istype(O,/obj/machinery/cloning) && get_dist(src,O) < CLONEPODRANGE)

/obj/machinery/computer/cloning/isLinkedWith(var/obj/O)
	return O != null && ((O in pods) || (O in scanners))

///obj/machinery/computer/cloning/getLink(var/idx) - abandoned orphan code that never worked anyway
//	return (idx >= 1 && idx <= links.len) ? links[idx] : null

/obj/machinery/computer/cloning/linkWith(var/mob/user, var/obj/O, var/list/context)
	if(istype(O, /obj/machinery/cloning/clonepod))
		pods += O
		var/obj/machinery/cloning/clonepod/C = O
		C.connected += src
		return 1

/obj/machinery/computer/cloning/proc/updatemodules()
	scanners = findscanners()
	pods = findcloners()

/obj/machinery/computer/cloning/proc/findscanners()
	. = list()
	var/obj/machinery/dna_scannernew/scannerf = null

	// Loop through every direction
	for(dir in cardinal)

		// Try to find a scanner in that direction
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, dir))

		// If found, then we add the scanner to the return
		if (!isnull(scannerf))
			. += scannerf
			scannerf.connected += src

/obj/machinery/computer/cloning/proc/findcloners()
	. = list()
	for (var/obj/machinery/cloning/clonepod/pod_found in orange(src, CLONEPODRANGE))
		. += pod_found
		pod_found.connected += src

#undef CLONEPODRANGE

/obj/machinery/computer/cloning/attackby(obj/item/W as obj, mob/user as mob)
	. = ..()
	if(.)
		return .
	if (istype(W, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if (!src.diskette)
			if(user.drop_item(W, src))
				src.diskette = W
				to_chat(user, "You insert \the [W].")
				src.updateUsrDialog()
				return 1

/obj/machinery/computer/cloning/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		if(user && !issilicon(user))
			user.visible_message("<span class='warning'>[user] slides something into \the [src]'s card-reader.</span>","<span class='warning'>You disable \the [src]'s safety overrides.</span>")

/obj/machinery/computer/cloning/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_hand(mob/user as mob)
	if(..())
		return 1
	user.set_machine(src)

	updatemodules()

	var/dat = "<h3>Cloning System Control</h3>"

	dat += {"<font size=-1><a href='byond://?src=\ref[src];refresh=1'>Refresh</a></font>
		<br><tt>[temp]</tt><br>"}
	switch(src.menu)
		if(1)
			// Modules
			dat += "<h4>Modules</h4>"
			//dat += "<a href='byond://?src=\ref[src];relmodules=1'>Reload Modules</a>"
			if (!scanners.len)
				dat += " <font color=red>Scanner-ERROR</font><br>"
			else
				dat += " <font color=green>Scanner-Found!</font><br>"
			if (!pods.len)
				dat += " <font color=red>Pod-ERROR</font><br>"
			else
				dat += " <font color=green>Pod-Found!</font><br>"

			// Scanner
			dat += "<h4>Scanner Functions</h4>"

			if(loading)
				dat += "<b>Scanning...</b><br>"
			else
				dat += "<b>[scantemp]</b><br>"

			if (!scanners.len)
				dat += "No scanners connected!<br>"
			else
				var/i = 0
				for(var/obj/machinery/dna_scannernew/scanner in scanners)
					i++
					dat += "Scanner [i] lock status: <a href='byond://?src=\ref[src];lock=\ref[scanner]'>[scanner.locked ? "Locked" : "Unlocked"]</a><br>"
					if (scanner.occupant)
						if(scantemp == "Scanners unoccupied")
							scantemp = "" // Stupid check to remove the text

						dat += "<a href='byond://?src=\ref[src];scan=\ref[scanner]'>Scan - [scanner.occupant]</a><br>"
					else
						scantemp = "Scanners unoccupied"

			if (pods.len)
				var/i = 0
				for(var/obj/machinery/cloning/clonepod/pod in pods)
					i++
					dat += "Pod [i] Biomass: <i>[pod.biomass]</i><br>"

			// Database

			dat += {"<h4>Database Functions</h4>
				<a href='byond://?src=\ref[src];menu=2'>View Records[records.len?"([records.len])":""]</a><br>"}
			if (src.diskette)
				dat += "<a href='byond://?src=\ref[src];disk=eject'>Eject Disk</a>"


		if(2)

			dat += {"<h4>Current records</h4>
				<a href='byond://?src=\ref[src];menu=1'>Back</a><br><ul>"}
			for(var/datum/dna2/record/R in src.records)
				dat += "<li><a href='byond://?src=\ref[src];view_rec=\ref[R]'>[R.dna.real_name && R.dna.real_name != "" ? R.dna.real_name : "Unknown"]</a></li>"

		if(3)

			dat += {"<h4>Selected Record</h4>
				<a href='byond://?src=\ref[src];menu=2'>Back</a><br>"}
			if (!src.active_record)
				dat += "<font color=red>ERROR: Record not found.</font>"
			else
				dat += {"<br><font size=1><a href='byond://?src=\ref[src];del_rec=1'>Edit Record</a></font><br>
					<b>Name:</b> [src.active_record.dna.real_name && src.active_record.dna.real_name != "" ? src.active_record.dna.real_name : "Unknown"]<br>"}
				if (!isnull(src.diskette))

					dat += {"<a href='byond://?src=\ref[src];disk=load'>Load from disk.</a>
						| Save: <a href='byond://?src=\ref[src];save_disk=ue'>UI + UE</a>
						| Save: <a href='byond://?src=\ref[src];save_disk=ui'>UI</a>
						| Save: <a href='byond://?src=\ref[src];save_disk=se'>SE</a>
						<br>"}
				else
					dat += "<br>" //Keeping a line empty for appearances I guess.

				dat += {"<b>UI:</b> [src.active_record.dna.uni_identity]<br>
				<b>SE:</b> [src.active_record.dna.struc_enzymes]<br><br>"}

				var/biomass_found = FALSE
				for(var/obj/machinery/cloning/clonepod/pod in pods)
					if(pod.biomass >= CLONE_BIOMASS)
						biomass_found = TRUE
						break
				if(biomass_found)
					dat += {"<a href='byond://?src=\ref[src];clone=\ref[src.active_record]'>Clone</a><br>"}
				else
					dat += {"<b>Insufficient biomass in any pod</b><br>"}

		if(4)
			if (!src.active_record)
				src.menu = 2
			dat = {"[src.temp]<br>
                        [(emagged) ? "<h4> Edit Record </h4>\
						<b><a href='byond://?src=\ref[src];change_name=1'>Change name.</a></b><br>\
                        <b><a href='byond://?src=\ref[src];change_species=1'>Change Species.</a></b><br>" : ""]
                        <h4>Record Deletion</h4>
                        <b><a href='byond://?src=\ref[src];del_rec=1'>Scan card to confirm.</a></b><br>
                        <b><a href='byond://?src=\ref[src];menu=3'>Return</a></b>"}
	user << browse(HTML_SKELETON(dat), "window=cloning")
	onclose(user, "cloning")
	return

/obj/machinery/computer/cloning/Topic(href, href_list)
	if(..())
		return

	if(loading)
		return

	if (href_list["scan"])
		var/obj/machinery/dna_scannernew/scanner = locate(href_list["scan"])
		if(scanner in scanners)
			scantemp = ""

			loading = 1
			src.updateUsrDialog()

			spawn(20)
				src.scan_mob(scanner.occupant)

				loading = 0
				src.updateUsrDialog()

	else if (href_list["lock"])
		//No locking an open scanner.
		var/obj/machinery/dna_scannernew/scanner = locate(href_list["lock"])
		if(scanner in scanners)
			scanner.locked = !scanner.locked && scanner.occupant

	else if (href_list["view_rec"])
		src.active_record = locate(href_list["view_rec"])
		if(istype(src.active_record,/datum/dna2/record))
			if ((isnull(src.active_record.ckey)))
				QDEL_NULL(src.active_record)
				src.temp = "ERROR: Record Corrupt"
			else
				src.menu = 3
		else
			src.active_record = null
			src.temp = "Record missing."

	else if (href_list["del_rec"])
		if ((!src.active_record) || (src.menu < 3))
			return
		if (src.menu == 3) //If we are viewing a record, confirm deletion
			src.temp = "Edit record?"
			src.menu = 4

		else if (src.menu == 4)
			var/obj/item/weapon/card/id/C = usr.get_active_hand()
			if (istype(C)||istype(C, /obj/item/device/pda))
				if(src.check_access(C))
					src.records.Remove(src.active_record)
					QDEL_NULL(src.active_record)
					src.temp = "Record deleted."
					src.menu = 2
				else
					src.temp = "Access Denied."

	else if (href_list["disk"]) //Load or eject.
		switch(href_list["disk"])
			if("load")
				if ((isnull(src.diskette)) || isnull(src.diskette.buf))
					src.temp = "Load error."
					src.updateUsrDialog()
					return
				if (isnull(src.active_record))
					src.temp = "Record error."
					src.menu = 1
					src.updateUsrDialog()
					return

				src.active_record = src.diskette.buf

				src.temp = "Load successful."
			if("eject")
				if (!isnull(src.diskette))
					src.diskette.forceMove(src.loc)
					src.diskette = null

	else if (href_list["save_disk"]) //Save to disk!
		if ((isnull(src.diskette)) || (src.diskette.read_only) || (isnull(src.active_record)))
			src.temp = "Save error."
			src.updateUsrDialog()
			return

		// DNA2 makes things a little simpler.
		src.diskette.buf=src.active_record.Clone() //Copy the record, not just the reference to it
		src.diskette.buf.types=0
		switch(href_list["save_disk"]) //Save as Ui/Ui+Ue/Se
			if("ui")
				src.diskette.buf.types=DNA2_BUF_UI
			if("ue")
				src.diskette.buf.types=DNA2_BUF_UI|DNA2_BUF_UE
			if("se")
				src.diskette.buf.types=DNA2_BUF_SE
		src.diskette.name = "data disk - '[src.active_record.dna.real_name && src.active_record.dna.real_name != "" ? src.active_record.dna.real_name : "Unknown"]'"
		src.temp = "Save \[[href_list["save_disk"]]\] successful."

	else if (href_list["refresh"])
		src.updateUsrDialog()

	else if (href_list["clone"])
		var/datum/dna2/record/C = locate(href_list["clone"])
		//Look for that player! They better be dead!
		if(istype(C))
			var/obj/machinery/cloning/clonepod/pod_used = null
			var/list/errcodes = list()
			for(var/obj/machinery/cloning/clonepod/pod in pods)
				//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
				if(!canLink(pod)) //If the pod exists BUT it's too far away from the console
					errcodes += list(1)
				else if(pod.occupants.len > 0)
					errcodes += list(2)
				else if(pod.biomass < CLONE_BIOMASS)
					errcodes += list(3)
				else if(pod.mess)
					errcodes += list(4)
				else
					pod_used = pod
					break
			if(pod_used)
				if(pod_used.growclone(C))
					temp = "Initiating cloning cycle..."
					records.Remove(C)
					QDEL_NULL(C)
					menu = 1
				else
					temp = "Initiating cloning cycle...<br>Error: Post-initialisation failed. Cloning cycle aborted."
					src.updateUsrDialog()
					return
			else if(errcodes.len)
				temp = "Error:"
				var/i = 0
				for(var/code in errcodes)
					temp += " "
					i++
					switch(code)
						if(ERR_NO_CLONEPOD)
							temp += "Clone pod [i] unlinkable."
						if(ERR_CLONEPOD_OCCUPIED)
							temp += "Clone pod [i] is currently occupied."
						if(ERR_CLONEPOD_BIOMASS)
							temp += "Clone pod [i] does not have enough biomass."
						if(ERR_CLONEPOD_MESS)
							temp += "Clone pod [i] is malfunctioned."

		else
			temp = "Error: Data corruption."

	else if (href_list["menu"])
		src.menu = text2num(href_list["menu"])

	else if (emagged && active_record)
		if(href_list["change_name"])
			var/name_of_victim = copytext(sanitize(input(usr, "/^!@#! ERROR: NAME PROTOCOLS OVERRIDDEN. MANUALLY INSERT NAME.", "Change Record Name") as text|null),1,MAX_NAME_LEN)
			if(name_of_victim)
				active_record.dna.real_name = name_of_victim
		if(href_list["change_species"])
			var/species_of_victim = input(usr, "/^!@#! ERROR: SPECIES PROTOCOLS OVERRIDDEN. MANUALLY INSERT SPECIES.","Change Record Species") as null|anything in list("random")+available_species
			if(species_of_victim)
				if(species_of_victim == "random")
					active_record.dna.species = pick(available_species)
				else
					active_record.dna.species = species_of_victim
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/subject as mob)
	if((isnull(subject)) || (!ishuman(subject) && !istype(subject, /mob/living/slime_pile)) || (!subject.dna) || (ismanifested(subject)))
		scantemp = "Error: Unable to locate valid genetic data." //Something went very wrong here
		return
	if(istype(subject, /mob/living/slime_pile))
		var/mob/living/slime_pile/P = subject
		if(P.slime_person && P.slime_person.has_brain())
			subject = P.slime_person
		else
			scantemp = "Unable to locate genetic base within the slime puddle. Micro-MRI scans indicate its brain is missing."
			return
	if(!subject.has_brain())
		scantemp = "Error: No signs of intelligence detected." //Self explainatory
		return
	if(!subject.mind) //This human was never controlled by a player, so they can't be cloned
		scantemp = "Error: Mental interface failure."
		return

	if(subject.mind && subject.mind.suiciding) //We cannot clone this guy because he suicided. Believe it or not, some people who suicide don't know about this. Let's tell them what's wrong.
		scantemp = "Error: Mental interface failure."
		if(subject.client)
			to_chat(subject, "<span class='warning'>Someone is trying to clone your corpse, but you may not be revived as you committed suicide.</span>")
		else
			var/mob/dead/observer/ghost = mind_can_reenter(subject.mind)
			if(ghost)
				var/mob/ghostmob = ghost.get_top_transmogrification()
				if(ghostmob)
					to_chat(ghostmob, "<span class='warning'>Someone is trying to clone your corpse, but you may not be revived as you committed suicide.</span>")
		return

	if(M_NOCLONE in subject.mutations) //We cannot clone this guy because he's a husk, but maybe we can give a more informative message.
		if(subject.client)
			scantemp = "Error: Unable to locate valid genetic data. However, mental interface initialized successfully."
			to_chat(subject, "<span class='interface'><span class='big bold'>Someone is trying to clone your corpse.</span> \
				You cannot be cloned as your body has been husked. However, your brain may still be used. Your ghost has been displayed as active and inside your body.</span>")
		else
			scantemp = "Error: Unable to locate valid genetic data. Additionally, [subject.ghost_reenter_alert("Someone is trying to clone your corpse. You cannot be cloned as your body has been husked. However, your brain may still be used. To show you're still active, return to your body!") ? "subject's brain is not responding to scanning stimuli" : "mental interface failed to initialize"]."
		return

	//There's nothing wrong with the corpse itself past this point
	if(!subject.client) //There is not a player "in control" of this corpse, maybe they ghosted, maybe they logged out
		scantemp = "Error: [subject.ghost_reenter_alert("Someone is trying to clone your corpse. Return to your body if you want to be cloned!") ? "Subject's brain is not responding to scanning stimuli, subject may be brain dead. Please try again in five seconds" : "Mental interface failure"]."
		return

	//Past this point, we know for sure the corpse is cloneable and has a ghost inside.
	if(!subject.ckey) //ideally would never happen but a check never hurts
		scantemp = "Error: Mental interface failure."
		return
	if(!isnull(find_record(subject.ckey)))
		scantemp = "Subject already in database." //duh
		return


	subject.dna.check_integrity()

	// Borer sanity checks.
	var/mob/living/simple_animal/borer/B=subject.has_brain_worms()
	if(B && B.controlling)
		// This shouldn't happen, but lolsanity.
		subject.do_release_control(1)

	var/datum/dna2/record/R = new /datum/dna2/record()

//Removed this so that slime puddles, etc. can be cloned. Anyway, in practice here a brain's owner's DNA should always correspond to the DNA of the subject that brain exists within.
//	var/datum/organ/internal/brain/Brain = subject.internal_organs_by_name["brain"]
//	if(!isnull(Brain.owner_dna) && Brain.owner_dna != subject.dna)
//		R.dna = Brain.owner_dna.Clone()
//	else
//		R.dna=subject.dna.Clone()
	R.dna=subject.dna.Clone()

	R.ckey = subject.ckey
	R.id= copytext(md5(R.dna.real_name), 2, 6)
	R.name=R.dna.real_name
	R.types=DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	R.languages = subject.languages.Copy()
	R.attack_log = subject.attack_log.Copy()
	R.default_language = subject.default_language
	R.times_cloned = subject.times_cloned
	R.talkcount = subject.talkcount
	R.clown = (M_CLUMSY in subject.mutations)

	if (!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.mind = "\ref[subject.mind]"

	src.records += R
	scantemp = "Subject successfully scanned."

//Find a specific record by key.
/obj/machinery/computer/cloning/proc/find_record(var/find_key)
	var/selected_record = null
	for(var/datum/dna2/record/R in src.records)
		if (R.ckey == find_key)
			selected_record = R
			break
	return selected_record

/obj/machinery/computer/cloning/update_icon()
	..()
	overlays = 0
	if(!(stat & (NOPOWER | BROKEN | FORCEDISABLE)))
		for(var/obj/machinery/dna_scannernew/scanner in scanners)
			if(scanner && scanner.occupant)
				overlays += image(icon = icon, icon_state = "cloning-scan")
				break
		for(var/obj/machinery/cloning/clonepod/pod in pods)
			if(pod && pod.occupants.len > 0)
				overlays += image(icon = icon, icon_state = "cloning-pod")
				break
