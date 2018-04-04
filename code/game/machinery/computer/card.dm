//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/card
	name = "Identification Computer"
	desc = "Terminal for programming Nanotrasen employee ID cards to access parts of the station."
	icon_state = "id"
	req_access = list(access_change_ids)
	circuit = "/obj/item/weapon/circuitboard/card"
	var/obj/item/weapon/card/id/modify = null
	var/mode = 0.0
	var/printing = null
	var/list/card_skins = list(
		"data",
		"id",
		"gold",
		"silver",
		"centcom_old",
		"centcom",
		"security",
		"medical",
		"HoS",
		"research",
		"cargo",
		"engineering",
		"CMO",
		"RD",
		"CE",
		"clown",
		"mime",
		"trader",
		"syndie" // yes no?
	)

	var/list/cent_card_skins = list(
		"data",
		"id",
		"centcom_old",
		"centcom",
		"syndie",
		"deathsquad",
		"creed",
		"ERT_leader",
		"ERT_security",
		"ERT_engineering",
		"ERT_medical",
	)

	light_color = LIGHT_COLOR_BLUE

	proc/is_centcom()
		return istype(src, /obj/machinery/computer/card/centcom)

	proc/is_authenticated()
		return scan ? check_access(scan) : 0

	proc/get_target_rank()
		return modify && modify.assignment ? modify.assignment : "Unassigned"

	proc/format_jobs(list/jobs)
		var/list/formatted = list()
		for(var/job in jobs)
			formatted.Add(list(list(
				"display_name" = replacetext(job, " ", "&nbsp;"),
				"target_rank" = get_target_rank(),
				"job" = job)))

		return formatted

	proc/format_card_skins(list/card_skins)
		var/list/formatted = list()
		for(var/skin in card_skins)
			formatted.Add(list(list(
				"display_name" = replacetext(skin, " ", "&nbsp;"),
				"skin" = skin)))

		return formatted

/obj/machinery/computer/card/verb/eject_id()
	set category = "Object"
	set name = "Eject ID Card"
	set src in oview(1)

	if(!usr || usr.isUnconscious() || usr.lying)
		return

	if(!usr.dexterity_check())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(scan)
		to_chat(usr, "You remove \the [scan] from \the [src].")
		scan.forceMove(get_turf(src))
		if(Adjacent(usr) && !usr.get_active_hand())
			usr.put_in_hands(scan)
		scan = null
	else if(modify)
		to_chat(usr, "You remove \the [modify] from \the [src].")
		modify.forceMove(get_turf(src))
		if(Adjacent(usr) && !usr.get_active_hand())
			usr.put_in_hands(modify)
		modify = null
	else
		to_chat(usr, "There is nothing to remove from the console.")
	return

/obj/machinery/computer/card/attackby(obj/item/weapon/card/id/id_card, mob/user)
	if(!istype(id_card))
		return ..()

	//Past this point, we are for sure inserting an ID.
	if(!user.dexterity_check()) //Since we can't remove the ID, let's not put it in, to prevent tragic ID stuckness.
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(id_card.loc == src) //With telekinesis, someone can retain the reference to a card after it's put inside via TKgrab, thus attacking us with a card we already had
		return

	if(!is_centcom() && !scan && (access_change_ids in id_card.access))
		if(user.drop_item(id_card, src))
			scan = id_card
	else if(is_centcom() && !scan && ((access_cent_creed in id_card.access) || (access_cent_captain in id_card.access)))
		if(user.drop_item(id_card, src))
			scan = id_card
	else if(!modify)
		if(user.drop_item(id_card, src))
			modify = id_card

	nanomanager.update_uis(src)
	attack_hand(user)

/obj/machinery/computer/card/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/card/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/card/attack_hand(mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

/obj/machinery/computer/card/ui_interact(mob/user, ui_key="main", datum/nanoui/ui=null, var/force_open=NANOUI_FOCUS)
	user.set_machine(src)

	var/data[0]
	data["src"] = "\ref[src]"
	data["station_name"] = station_name()
	data["mode"] = mode
	data["printing"] = printing
	data["manifest"] = data_core ? html_decode(data_core.get_manifest(0)) : null
	data["target_name"] = modify ? modify.name : "-----"
	data["target_owner"] = modify && modify.registered_name ? modify.registered_name : "-----"
	data["target_rank"] = get_target_rank()
	data["scan_name"] = scan ? scan.name : "-----"
	data["authenticated"] = is_authenticated()
	data["has_modify"] = !!modify
	data["account_number"] = modify ? modify.associated_account_number : null
	data["centcom_access"] = is_centcom()
	data["all_centcom_access"] = null
	data["regions"] = null

	data["head_jobs"] = format_jobs(command_positions)
	data["engineering_jobs"] = format_jobs(engineering_positions)
	data["medical_jobs"] = format_jobs(medical_positions)
	data["science_jobs"] = format_jobs(science_positions)
	data["security_jobs"] = format_jobs(security_positions)
	data["cargo_jobs"] = format_jobs(cargo_positions)
	data["civilian_jobs"] = format_jobs(civilian_positions)
	data["centcom_jobs"] = format_jobs(get_all_centcom_jobs())
	data["card_skins"] = format_card_skins(card_skins)
	data["cent_card_skins"] = format_card_skins(cent_card_skins)

	if(modify)
		data["current_skin"] = modify.icon_state

	if (modify && is_centcom())
		var/list/all_centcom_access = list()
		for(var/access in get_all_centcom_access())
			if (get_centcom_access_desc(access))
				all_centcom_access.Add(list(list(
					"desc" = replacetext(get_centcom_access_desc(access), " ", "&nbsp"),
					"ref" = access,
					"allowed" = (access in modify.access) ? 1 : 0)))

		data["all_centcom_access"] = all_centcom_access
	else if (modify)
		var/list/regions = list()
		for(var/i = 1; i <= 7; i++)
			var/list/accesses = list()
			for(var/access in get_region_accesses(i))
				if (get_access_desc(access))
					accesses.Add(list(list(
						"desc" = replacetext(get_access_desc(access), " ", "&nbsp"),
						"ref" = access,
						"allowed" = (access in modify.access) ? 1 : 0)))

			regions.Add(list(list(
				"name" = get_region_accesses_name(i),
				"accesses" = accesses)))

		data["regions"] = regions

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "identification_computer.tmpl", src.name, 800, 700)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/card/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1
	switch(href_list["choice"])
		if ("modify")
			if (modify)
				data_core.manifest_modify(modify.registered_name, modify.assignment)
				modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")
				modify.forceMove(get_turf(src))
				if(Adjacent(usr) && !usr.get_active_hand())
					usr.put_in_hands(modify)
				modify = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/weapon/card/id))
					if(usr.drop_item(I, src))
						modify = I

		if ("scan")
			if(scan)
				scan.forceMove(get_turf(src))
				if(Adjacent(usr) && !usr.get_active_hand())
					usr.put_in_hands(scan)
				scan = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/weapon/card/id))
					if(usr.drop_item(I, src))
						scan = I

		if("access")
			if(href_list["allowed"])
				if(is_authenticated())
					var/access_type = text2num(href_list["access_target"])
					var/access_allowed = text2num(href_list["allowed"])
					if(access_type in (is_centcom() ? get_all_centcom_access() : get_all_accesses()))
						modify.access -= access_type
						if(!access_allowed)
							modify.access += access_type
		if("skin")
			modify.icon_state = href_list["skin_target"]


		if ("assign")
			if (is_authenticated() && modify)
				var/t1 = href_list["assign_target"]
				if(t1 == "Custom")
					var/temp_t = input("Enter a custom job assignment.","Assignment") as null|text
					if(temp_t)
						temp_t = copytext(sanitize(temp_t),1,45)
						//let custom jobs function as an impromptu alt title, mainly for sechuds
						if(temp_t && modify)
							modify.assignment = temp_t
				else
					var/list/access = list()
					if(is_centcom())
						access = get_centcom_access(t1)
					else
						var/datum/job/jobdatum
						for(var/jobtype in typesof(/datum/job))
							var/datum/job/J = new jobtype
							if(ckey(J.title) == ckey(t1))
								jobdatum = J
								break
						if(!jobdatum)
							to_chat(usr, "<span class='warning'>No log exists for this job: [t1]</span>")
							return

						access = jobdatum.get_access()

					modify.access = access
					modify.assignment = t1
					modify.rank = t1

		if ("reg")
			if (is_authenticated())
				var/t2 = modify
				if ((modify == t2 && (in_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(loc, /turf)))
					var/temp_name = reject_bad_name(href_list["reg"])
					if(temp_name)
						modify.registered_name = temp_name
					else
						src.visible_message("<span class='notice'>[src] buzzes rudely.</span>")
					modify.update_virtual_wallet()
			nanomanager.update_uis(src)

		if ("account")
			if (is_authenticated())
				var/t2 = modify
				if ((modify == t2 && (in_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(loc, /turf)))
					var/account_num = text2num(href_list["account"])
					modify.associated_account_number = account_num
			nanomanager.update_uis(src)

		if ("mode")
			mode = text2num(href_list["mode_target"])

		if ("print")
			if (!printing)
				printing = 1
				spawn(50)
					printing = null
					nanomanager.update_uis(src)

					var/obj/item/weapon/paper/P = new(loc)
					if (mode)
						P.name = text("crew manifest ([])", worldtime2text())
						P.info = {"<h4>Crew Manifest</h4>
							<br>
							[data_core ? data_core.get_manifest(0) : ""]
						"}
					else if (modify)
						P.name = "access report"
						P.info = {"<h4>Access Report</h4>
							<u>Prepared By:</u> [scan.registered_name ? scan.registered_name : "Unknown"]<br>
							<u>For:</u> [modify.registered_name ? modify.registered_name : "Unregistered"]<br>
							<hr>
							<u>Assignment:</u> [modify.assignment]<br>
							<u>Account Number:</u> #[modify.associated_account_number]<br>
							<u>Blood Type:</u> [modify.blood_type]<br><br>
							<u>Access:</u><br>
						"}

						for(var/A in modify.access)
							P.info += "  [get_access_desc(A)]"

	if (modify)
		modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")

	return 1

/obj/machinery/computer/card/kick_act(mob/living/H)
	..()
	if(modify)
		if(prob(50))
			modify.forceMove(get_turf(src))
			visible_message("<span class='notice'>\A [modify] pops out of \the [src]!</span>")
			modify = null

/obj/machinery/computer/card/centcom
	name = "CentCom Identification Computer"
	circuit = "/obj/item/weapon/circuitboard/card/centcom"
	req_access = list(
		access_cent_creed,
		access_cent_captain,
		)
