//CONTAINS: Detective's Scanner


/obj/item/device/detective_scanner
	name = "Scanner"
	desc = "Used to scan objects for DNA and fingerprints."
	icon_state = "forensic1"
	var/amount = 20.0
	var/list/stored = list()
	w_class = W_CLASS_MEDIUM
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT

/obj/item/device/detective_scanner/attackby(obj/item/weapon/f_card/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/f_card))
		if (W.fingerprints)
			return
		if (src.amount == 20)
			return
		if (W.amount + src.amount > 20)
			src.amount = 20
			W.amount = W.amount + src.amount - 20
		else
			src.amount += W.amount
			//W = null
			qdel(W)
			W = null
		add_fingerprint(user)
		if (W)
			W.add_fingerprint(user)
	return

/obj/item/device/detective_scanner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if (!ishuman(M))
		to_chat(user, "<span class='warning'>[M] is not human and cannot have the fingerprints.</span>")
		return 0
	if (( !( istype(M.dna, /datum/dna) ) || M.gloves) )
		to_chat(user, "<span class='notice'>No fingerprints found on [M]</span>")
		return 0
	else
		if (src.amount < 1)
			to_chat(user, text("<span class='notice'>Fingerprints scanned on [M]. Need more cards to print.</span>"))
		else
			src.amount--
			var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card( user.loc )
			F.amount = 1
			F.add_fingerprint(M)
			F.icon_state = "fingerprint1"
			F.name = text("FPrintC- '[M.name]'")

			to_chat(user, "<span class='notice'>Done printing.</span>")
		to_chat(user, "<span class='notice'>[M]'s Fingerprints: [md5(M.dna.uni_identity)]</span>")
	if ( !M.blood_DNA || !M.blood_DNA.len )
		to_chat(user, "<span class='notice'>No blood found on [M]</span>")
		if(M.blood_DNA)
			qdel(M.blood_DNA)
			M.blood_DNA = null
	else
		to_chat(user, "<span class='notice'>Blood found on [M]. Analysing...</span>")
		spawn(15)
			for(var/blood in M.blood_DNA)
				to_chat(user, "<span class='notice'>Blood type: [M.blood_DNA[blood]]\nDNA: [blood]</span>")
	return

/obj/item/device/detective_scanner/proc/extract_fingerprints(var/atom/A)
	var/list/extracted_prints=list()
	if(!A.fingerprints || !A.fingerprints.len)
		if(A.fingerprints)
			qdel(A.fingerprints)
			A.fingerprints = null
	else
		for(var/i in A.fingerprints)
			extracted_prints[i]=A.fingerprints[i]
	return extracted_prints

/obj/item/device/detective_scanner/proc/extract_blood(var/atom/A)
	var/list/extracted_blood=list()
	if(A.blood_DNA)
		for(var/blood in A.blood_DNA)
			extracted_blood[blood]=A.blood_DNA[blood]
	return extracted_blood

/obj/item/device/detective_scanner/proc/extract_fibers(var/atom/A)
	var/list/extracted_fibers=list()
	if(A.suit_fibers)
		for(var/fiber in A.suit_fibers)
			extracted_fibers[fiber]=A.suit_fibers[fiber]
	return extracted_fibers

/obj/item/device/detective_scanner/afterattack(atom/A as obj|turf|area, mob/user as mob)
	if(!in_range(A,user))
		return
	if(loc != user)
		return
	if(istype(A,/obj/machinery/computer/forensic_scanning)) //breaks shit.
		return
	if(istype(A,/obj/item/weapon/f_card))
		to_chat(user, "The scanner displays on the screen: \"ERROR 43: Object on Excluded Object List.\"")
		return

	add_fingerprint(user)

	var/list/blood_DNA_found    = src.extract_blood(A)
	var/list/fingerprints_found = src.extract_fingerprints(A)
	var/list/fibers_found       = src.extract_fibers(A)

	// Blood/vomit splatters no longer clickable, so scan the entire turf.
	if (istype(A,/turf))
		var/turf/T=A
		for(var/atom/O in T)
			// Blood splatters, runes.
			if (istype(O, /obj/effect/decal/cleanable/blood) || istype(O, /obj/effect/rune_legacy))
				blood_DNA_found    += extract_blood(O)
				//fingerprints_found += extract_fingerprints(O)
				//fibers_found       += extract_fibers(O)
	//General
	if (fingerprints_found.len == 0 && blood_DNA_found.len == 0 && fibers_found.len == 0)
		user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
		"<span class='notice'>Unable to locate any fingerprints, materials, fibers, or blood on [A]!</span>",\
		"You hear a faint hum of electrical equipment.")
		return 0

	if(add_data(A,blood_DNA_found,fingerprints_found,fibers_found))
		to_chat(user, "<span class='notice'>Object already in internal memory. Consolidating data...</span>")
		return

	//PRINTS
	if(fingerprints_found.len>0)
		to_chat(user, "<span class='notice'>Isolated [fingerprints_found.len] fingerprints: Data Stored: Scan with Hi-Res Forensic Scanner to retrieve.</span>")
		playsound(src, 'sound/items/detscan.ogg', 50, 1)

		var/list/complete_prints = list()
		for(var/i in fingerprints_found)
			var/print = fingerprints_found[i]
			if(stringpercent(print) <= FINGERPRINT_COMPLETE)
				complete_prints += print

		if(complete_prints.len < 1)
			to_chat(user, "<span class='notice'>&nbsp;&nbsp;No intact prints found</span>")
		else
			to_chat(user, "<span class='notice'>&nbsp;&nbsp;Found [complete_prints.len] intact prints</span>")
			for(var/i in complete_prints)
				to_chat(user, "<span class='notice'>&nbsp;&nbsp;&nbsp;&nbsp;[i]</span>")

	//FIBERS
	if(fibers_found.len)
		to_chat(user, "<span class='notice'>Fibers/Materials Data Stored: Scan with Hi-Res Forensic Scanner to retrieve.</span>")
		playsound(src, 'sound/items/detscan.ogg', 50, 1)

	//Blood
	if (blood_DNA_found.len)
		to_chat(user, "<span class='notice'>Blood found on [A]. Analysing...</span>")
		spawn(15)
			for(var/blood in blood_DNA_found)
				to_chat(user, "Blood type: <span class='warning'>[blood_DNA_found[blood]] \t </span>DNA: <span class='warning'>[blood]</span>")

	if(prob(80) || !fingerprints_found.len)
		user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
		"You finish scanning \the [A].",\
		"You hear a faint hum of electrical equipment.")
		return 0
	else
		user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]\n[user.gender == MALE ? "He" : "She"] seems to perk up slightly at the readout." ,\
		"The results of the scan pique your interest.",\
		"You hear a faint hum of electrical equipment, and someone making a thoughtful noise.")
		return 0
	return

/obj/item/device/detective_scanner/proc/add_data(var/atom/A, var/list/blood_DNA_found,var/list/fingerprints_found,var/list/fibers_found)
	//I love associative lists.
	var/list/data_entry = stored["\ref [A]"]
	if(islist(data_entry)) //Yay, it was already stored!
		//Merge the fingerprints.
		var/list/data_prints = data_entry[1]
		for(var/print in fingerprints_found)
			var/merged_print = data_prints[print]
			if(!merged_print)
				data_prints[print] = A.fingerprints[print]
			else
				data_prints[print] = stringmerge(data_prints[print],A.fingerprints[print])

		//Now the fibers
		var/list/fibers = data_entry[2]
		if(!fibers)
			fibers = list()
		if(fibers_found.len)
			for(var/j = 1, j <= fibers_found.len, j++)	//Fibers~~~
				if(!fibers.Find(fibers_found[j]))	//It isn't!  Add!
					fibers += fibers_found[j]
		var/list/blood = data_entry[3]
		if(!blood)
			blood = list()
		if(blood_DNA_found.len)
			for(var/main_blood in A.blood_DNA)
				if(!blood[main_blood])
					blood[main_blood] = A.blood_DNA[blood]
		return 1
	var/list/sum_list[4]	//Pack it back up!
	sum_list[1] = fingerprints_found.Copy()
	sum_list[2] = fibers_found.Copy()
	sum_list[3] = blood_DNA_found.Copy()
	sum_list[4] = "\The [A] in \the [get_area(A)]"
	stored["\ref [A]"] = sum_list
	return 0

/proc/get_timestamp()
	return time2text(world.time + 432000, "hh:mm:ss")

/obj/item/device/detective_scanner/forger
	var/list/custom_forgery[3]
	var/forging = 0

/obj/item/device/detective_scanner/forger/New()
	..()
	custom_forgery[1] = list()
	custom_forgery[2] = list()
	custom_forgery[3] = list()

/obj/item/device/detective_scanner/forger/attack_self(var/mob/user as mob)
	var/list/customprints = list()
	var/list/customfiber = list()
	var/list/customblood = list()
	if(forging)
		to_chat(user, "<span class='warning'>You are already forging evidence</span>")
		return 0
	clear_forgery()
	//fingerprint loop
	while(1)
		var/print = html_encode(input(usr,"Please enter a custom fingerprint or hit cancel to finish fingerprints") as text|null)
		if(!usr.client)
			forging = 0
			break
		if(!print )
			break
		customprints[print] = print
	while(1)
		var/fiber = html_encode(input(usr,"Please enter a custom fiber/material trace or hit cancel to finish fibers/materials") as text|null)
		if(!usr.client)
			forging = 0
			break
		if(!fiber)
			break
		customfiber[fiber] = null
	while(1)
		var/blood = html_encode(input(usr,"Please enter a custom Blood DNA or hit cancel to finish forging") as text|null)
		var/bloodtype = html_encode(input(usr,"Please enter a custom Blood Type") as text|null)
		if(!usr.client)
			forging = 0
			break
		if(!blood)
			break
		customblood[blood] = bloodtype
	forging = 0
	if(!customprints.len && !customfiber.len)
		to_chat(user, "<span class='notice'>No forgery saved.</span>")
		return
	to_chat(user, "<span class='notice'>Forgery saved and will be tied to the next applicable scanned item.</span>")
	custom_forgery[1] = customprints ? customprints.Copy() : null
	custom_forgery[2] = customfiber ? customfiber.Copy() : null
	custom_forgery[3] = customblood ? customblood.Copy() : null

//shameless copy pasting
/obj/item/device/detective_scanner/forger/afterattack(atom/A as obj|turf|area, mob/user as mob)
	var/list/custom_finger = list()
	var/list/custom_fiber = list()
	var/list/custom_blood = list()

	if(custom_forgery)
		custom_finger = custom_forgery[1]
		custom_fiber = custom_forgery[2]
		custom_blood = custom_forgery[3]

	if(!in_range(A,user))
		return
	if(loc != user)
		return
	if(istype(A,/obj/machinery/computer/forensic_scanning)) //breaks shit.
		return
	if(istype(A,/obj/item/weapon/f_card))
		to_chat(user, "The scanner displays on the screen: \"ERROR 43: Object on Excluded Object List.\"")
		return

	add_fingerprint(user)

	var/list/blood_DNA_found    = src.extract_blood(A)
	var/list/fingerprints_found = src.extract_fingerprints(A)
	var/list/fibers_found       = src.extract_fibers(A)

	// Blood/vomit splatters no longer clickable, so scan the entire turf.
	if (istype(A,/turf))
		var/turf/T=A
		for(var/atom/O in T)
			// Blood splatters, runes.
			if (istype(O, /obj/effect/decal/cleanable/blood) || istype(O, /obj/effect/rune_legacy))
				blood_DNA_found    += extract_blood(O)
				//fingerprints_found += extract_fingerprints(O)
				//fibers_found       += extract_fibers(O)
	//General
	if (fingerprints_found.len == 0 && blood_DNA_found.len == 0 && fibers_found.len == 0)
		if(!custom_finger.len && !custom_fiber.len && !custom_blood.len)
			user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
			"<span class='notice'>Unable to locate any fingerprints, materials, fibers, or blood on [A]!</span>",\
			"You hear a faint hum of electrical equipment.")
			return 0
		else
			user.visible_message("\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,\
			"<span class='notice'>Unable to locate any fingerprints, materials, fibers, or blood on [A], loading custom forgery instead.</span>",\
			"You hear a faint hum of electrical equipment.")

	if(add_data(A,blood_DNA_found,fingerprints_found,fibers_found))
		to_chat(user, "<span class='notice'>Object already in internal memory. Consolidating data...</span>")
		return


	//PRINTS
	if(!A.fingerprints || !A.fingerprints.len)
		if(A.fingerprints)
			qdel(A.fingerprints)
			A.fingerprints = null
	if(custom_finger.len)
		to_chat(user, "<span class='notice'>Isolated [custom_finger.len] fingerprints: Data Stored: Scan with Hi-Res Forensic Scanner to retrieve.</span>")
		to_chat(user, "<span class='notice'>&nbsp;&nbsp;Found [custom_finger.len] intact prints</span>")
		for(var/i in custom_finger)
			to_chat(user, "<span class='notice'>&nbsp;&nbsp;&nbsp;&nbsp;[i]</span>")
	else if(fingerprints_found.len)
		to_chat(user, "<span class='notice'>Isolated [A.fingerprints.len] fingerprints: Data Stored: Scan with Hi-Res Forensic Scanner to retrieve.</span>")
		var/list/complete_prints = list()
		for(var/i in fingerprints_found)
			var/print = fingerprints_found[i]
			if(stringpercent(print) <= FINGERPRINT_COMPLETE)
				complete_prints += print
		if(complete_prints.len < 1)
			to_chat(user, "<span class='notice'>&nbsp;&nbsp;No intact prints found</span>")
		else
			to_chat(user, "<span class='notice'>&nbsp;&nbsp;Found [complete_prints.len] intact prints</span>")
			for(var/i in complete_prints)
				to_chat(user, "<span class='notice'>&nbsp;&nbsp;&nbsp;&nbsp;[i]</span>")

	//FIBERS
	if(custom_fiber.len)
		to_chat(user, "<span class='notice'>Forged Fibers/Materials Data Found: Scan with Hi-Res Forensic Scanner to retrieve.</span>")
	else if(fibers_found.len)
		to_chat(user, "<span class='notice'>Fibers/Materials Data Stored: Scan with Hi-Res Forensic Scanner to retrieve.</span>")


	//Blood
	if(custom_blood.len)
		to_chat(user, "<span class='notice'>Forged Blood found. Analysing...</span>")
		spawn(15)
			for(var/blood in custom_blood)
				to_chat(user, "Blood type: <span class='warning'>[custom_blood[blood]] \t </span>DNA: <span class='warning'>[blood]</span>")
	else if (blood_DNA_found.len)
		to_chat(user, "<span class='notice'>Blood found on [A]. Analysing...</span>")
		spawn(15)
			for(var/blood in blood_DNA_found)
				to_chat(user, "Blood type: <span class='warning'>[blood_DNA_found[blood]] \t </span>DNA: <span class='warning'>[blood]</span>")
	return

/obj/item/device/detective_scanner/forger/add_data(var/atom/A, var/list/blood_DNA_found,var/list/fingerprints_found,var/list/fibers_found)
	//I love associative lists.
	var/list/data_entry = stored["\ref [A]"]
	var/list/custom_finger = list()
	var/list/custom_fiber = list()
	var/list/custom_blood = list()

	if(custom_forgery)
		custom_finger = custom_forgery[1]
		custom_fiber = custom_forgery[2]
		custom_blood = custom_forgery[3]

	if(islist(data_entry)) //Yay, it was already stored!
		//Merge the fingerprints.
		var/list/data_prints = data_entry[1]
		if(custom_finger.len)
			for(var/print in custom_finger)
				var/merged_print = data_prints[print]
				if(!merged_print)
					data_prints[print] = custom_finger
				else
					data_prints[print] = stringmerge(data_prints[print],custom_finger[print])
		else
			for(var/print in fingerprints_found)
				var/merged_print = data_prints[print]
				if(!merged_print)
					data_prints[print] = fingerprints_found[print]
				else
					data_prints[print] = stringmerge(data_prints[print],fingerprints_found[print])

		//Now the fibers
		var/list/fibers = data_entry[2]
		if(!fibers)
			fibers = list()
		if(custom_fiber.len)
			for(var/j = 1, j <= custom_fiber.len, j++)	//Fibers~~~
				if(!fibers.Find(custom_fiber[j]))	//It isn't!  Add!
					fibers += custom_fiber[j]

		else if(fibers_found && fibers_found.len)
			for(var/j = 1, j <= fibers_found.len, j++)	//Fibers~~~
				if(!fibers.Find(fibers_found[j]))	//It isn't!  Add!
					fibers += fibers_found[j]

		// Blud
		var/list/blood = data_entry[3]
		if(!blood)
			blood = list()
		if(custom_blood.len)
			for(var/main_blood in custom_blood)
				if(!blood[main_blood])
					blood[main_blood] = custom_blood[blood]
		else if(blood_DNA_found && blood_DNA_found.len)
			for(var/main_blood in blood_DNA_found)
				if(!blood[main_blood])
					blood[main_blood] = blood_DNA_found[blood]
		return 1
	var/list/sum_list[4]	//Pack it back up!
	if(custom_finger.len || custom_fiber.len || custom_blood.len)
		sum_list[1] = custom_finger ? custom_finger.Copy() : null
		sum_list[2] = custom_fiber ? custom_fiber.Copy() : null
		sum_list[3] = custom_blood ? custom_blood.Copy() : null
	else
		sum_list[1] = fingerprints_found.Copy()
		sum_list[2] = fibers_found.Copy()
		sum_list[3] = blood_DNA_found.Copy()
	sum_list[4] = "\The [A] in \the [get_area(A)]"
	stored["\ref [A]"] = sum_list
	clear_forgery()
	return 0

/obj/item/device/detective_scanner/forger/proc/clear_forgery()
	if(custom_forgery.len)
		custom_forgery[1] = list()
		custom_forgery[2] = list()
		custom_forgery[3] = list()
