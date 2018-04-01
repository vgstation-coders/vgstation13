//Experimental cloner; clones a body regardless of the owner's status, letting a ghost control it instead
/obj/machinery/clonepod/experimental
	name = "experimental cloning pod"
	desc = "An ancient cloning pod. It seems to be an early prototype of the experimental cloners used in Nanotrasen Stations."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	req_access = null
	circuit = /obj/item/circuitboard/machine/clonepod/experimental
	internal_radio = FALSE

//Start growing a human clone in the pod!
/obj/machinery/clonepod/experimental/growclone(clonename, ui, se, datum/species/mrace, list/features, factions)
	if(panel_open)
		return FALSE
	if(mess || attempting)
		return FALSE

	attempting = TRUE //One at a time!!
	countdown.start()

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)

	H.hardset_dna(ui, se, H.real_name, null, mrace, features)

	if(efficiency > 2)
		var/list/unclean_mutations = (GLOB.not_good_mutations|GLOB.bad_mutations)
		H.dna.remove_mutation_group(unclean_mutations)
	if(efficiency > 5 && prob(20))
		H.randmutvg()
	if(efficiency < 3 && prob(50))
		var/mob/M = H.randmutb()
		if(ismob(M))
			H = M

	H.silent = 20 //Prevents an extreme edge case where clones could speak if they said something at exactly the right moment.
	occupant = H

	if(!clonename)	//to prevent null names
		clonename = "clone ([rand(0,999)])"
	H.real_name = clonename

	icon_state = "pod_1"
	//Get the clone body ready
	maim_clone(H)
	H.add_trait(TRAIT_STABLEHEART, "cloning")
	H.add_trait(TRAIT_EMOTEMUTE, "cloning")
	H.add_trait(TRAIT_MUTE, "cloning")
	H.add_trait(TRAIT_NOBREATH, "cloning")
	H.add_trait(TRAIT_NOCRITDAMAGE, "cloning")
	H.Unconscious(80)

	var/list/candidates = pollCandidatesForMob("Do you want to play as [clonename]'s defective clone?", null, null, null, 100, H)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		H.key = C.key

	if(grab_ghost_when == CLONER_FRESH_CLONE)
		H.grab_ghost()
		to_chat(H, "<span class='notice'><b>Consciousness slowly creeps over you as your body regenerates.</b><br><i>So this is what cloning feels like?</i></span>")

	if(grab_ghost_when == CLONER_MATURE_CLONE)
		H.ghostize(TRUE)	//Only does anything if they were still in their old body and not already a ghost
		to_chat(H.get_ghost(TRUE), "<span class='notice'>Your body is beginning to regenerate in a cloning pod. You will become conscious when it is complete.</span>")

	if(H)
		H.faction |= factions

		H.set_cloned_appearance()

		H.suiciding = FALSE
	attempting = FALSE
	return TRUE


//Prototype cloning console, much more rudimental and lacks modern functions such as saving records, autocloning, or safety checks.
/obj/machinery/computer/prototype_cloning
	name = "prototype cloning console"
	desc = "Used to operate an experimental cloner."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/prototype_cloning
	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/list/pods //Linked experimental cloning pods
	var/temp = "Inactive"
	var/scantemp = "Ready to Scan"
	var/loading = FALSE // Nice loading text

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/prototype_cloning/Initialize()
	. = ..()
	updatemodules(TRUE)

/obj/machinery/computer/prototype_cloning/Destroy()
	if(pods)
		for(var/P in pods)
			DetachCloner(P)
		pods = null
	return ..()

/obj/machinery/computer/prototype_cloning/proc/GetAvailablePod(mind = null)
	if(pods)
		for(var/P in pods)
			var/obj/machinery/clonepod/experimental/pod = P
			if(pod.is_operational() && !(pod.occupant || pod.mess))
				return pod

/obj/machinery/computer/prototype_cloning/proc/updatemodules(findfirstcloner)
	scanner = findscanner()
	if(findfirstcloner && !LAZYLEN(pods))
		findcloner()

/obj/machinery/computer/prototype_cloning/proc/findscanner()
	var/obj/machinery/dna_scannernew/scannerf = null

	// Loop through every direction
	for(var/direction in GLOB.cardinals)
		// Try to find a scanner in that direction
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, direction))
		// If found and operational, return the scanner
		if (!isnull(scannerf) && scannerf.is_operational())
			return scannerf

	// If no scanner was found, it will return null
	return null

/obj/machinery/computer/prototype_cloning/proc/findcloner()
	var/obj/machinery/clonepod/experimental/podf = null
	for(var/direction in GLOB.cardinals)
		podf = locate(/obj/machinery/clonepod/experimental, get_step(src, direction))
		if (!isnull(podf) && podf.is_operational())
			AttachCloner(podf)

/obj/machinery/computer/prototype_cloning/proc/AttachCloner(obj/machinery/clonepod/experimental/pod)
	if(!pod.connected)
		pod.connected = src
		LAZYADD(pods, pod)

/obj/machinery/computer/prototype_cloning/proc/DetachCloner(obj/machinery/clonepod/experimental/pod)
	pod.connected = null
	LAZYREMOVE(pods, pod)

/obj/machinery/computer/prototype_cloning/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/P = W

		if(istype(P.buffer, /obj/machinery/clonepod/experimental))
			if(get_area(P.buffer) != get_area(src))
				to_chat(user, "<font color = #666633>-% Cannot link machines across power zones. Buffer cleared %-</font color>")
				P.buffer = null
				return
			to_chat(user, "<font color = #666633>-% Successfully linked [P.buffer] with [src] %-</font color>")
			var/obj/machinery/clonepod/experimental/pod = P.buffer
			if(pod.connected)
				pod.connected.DetachCloner(pod)
			AttachCloner(pod)
		else
			P.buffer = src
			to_chat(user, "<font color = #666633>-% Successfully stored [REF(P.buffer)] [P.buffer.name] in buffer %-</font color>")
		return
	else
		return ..()

/obj/machinery/computer/prototype_cloning/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/prototype_cloning/interact(mob/user)
	user.set_machine(src)
	add_fingerprint(user)

	if(..())
		return

	updatemodules(TRUE)

	var/dat = ""
	dat += "<a href='byond://?src=[REF(src)];refresh=1'>Refresh</a>"

	dat += "<h3>Cloning Pod Status</h3>"
	dat += "<div class='statusDisplay'>[temp]&nbsp;</div>"

	if (isnull(src.scanner) || !LAZYLEN(pods))
		dat += "<h3>Modules</h3>"
		//dat += "<a href='byond://?src=[REF(src)];relmodules=1'>Reload Modules</a>"
		if (isnull(src.scanner))
			dat += "<font class='bad'>ERROR: No Scanner detected!</font><br>"
		if (!LAZYLEN(pods))
			dat += "<font class='bad'>ERROR: No Pod detected</font><br>"

	// Scan-n-Clone
	if (!isnull(src.scanner))
		var/mob/living/scanner_occupant = get_mob_or_brainmob(scanner.occupant)

		dat += "<h3>Cloning</h3>"

		dat += "<div class='statusDisplay'>"
		if(!scanner_occupant)
			dat += "Scanner Unoccupied"
		else if(loading)
			dat += "[scanner_occupant] => Scanning..."
		else
			scantemp = "Ready to Clone"
			dat += "[scanner_occupant] => [scantemp]"
		dat += "</div>"

		if(scanner_occupant)
			dat += "<a href='byond://?src=[REF(src)];clone=1'>Clone</a>"
			dat += "<br><a href='byond://?src=[REF(src)];lock=1'>[src.scanner.locked ? "Unlock Scanner" : "Lock Scanner"]</a>"
		else
			dat += "<span class='linkOff'>Clone</span>"

	var/datum/browser/popup = new(user, "cloning", "Prototype Cloning System Control")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/prototype_cloning/Topic(href, href_list)
	if(..())
		return

	if(loading)
		return

	else if ((href_list["clone"]) && !isnull(scanner) && scanner.is_operational())
		scantemp = ""

		loading = TRUE
		updateUsrDialog()
		playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		say("Initiating scan...")

		spawn(20)
			clone_occupant(scanner.occupant)
			loading = FALSE
			updateUsrDialog()
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

		//No locking an open scanner.
	else if ((href_list["lock"]) && !isnull(scanner) && scanner.is_operational())
		if ((!scanner.locked) && (scanner.occupant))
			scanner.locked = TRUE
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		else
			scanner.locked = FALSE
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

	else if (href_list["refresh"])
		updateUsrDialog()
		playsound(src, "terminal_type", 25, 0)

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/prototype_cloning/proc/clone_occupant(occupant)
	var/mob/living/mob_occupant = get_mob_or_brainmob(occupant)
	var/datum/dna/dna
	if(ishuman(mob_occupant))
		var/mob/living/carbon/C = mob_occupant
		dna = C.has_dna()
	if(isbrain(mob_occupant))
		var/mob/living/brain/B = mob_occupant
		dna = B.stored_dna

	if(!istype(dna))
		scantemp = "<font class='bad'>Unable to locate valid genetic data.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if((mob_occupant.has_trait(TRAIT_NOCLONE)) && (src.scanner.scan_level < 2))
		scantemp = "<font class='bad'>Subject no longer contains the fundamental materials required to create a living clone.</font>"
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
		return

	var/clone_species
	if(dna.species)
		clone_species = dna.species
	else
		var/datum/species/rando_race = pick(GLOB.roundstart_races)
		clone_species = rando_race.type

	var/obj/machinery/clonepod/pod = GetAvailablePod()
	//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
	if(!LAZYLEN(pods))
		temp = "<font class='bad'>No Clonepods detected.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	else if(!pod)
		temp = "<font class='bad'>No Clonepods available.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	else if(pod.occupant)
		temp = "<font class='bad'>Cloning cycle already in progress.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	else
		pod.growclone(mob_occupant.real_name, dna.uni_identity, dna.struc_enzymes, clone_species, dna.features, mob_occupant.faction)
		temp = "[mob_occupant.real_name] => <font class='good'>Cloning data sent to pod.</font>"
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)