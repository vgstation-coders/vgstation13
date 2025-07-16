#define LOG_CLEAR 1
#define LOG_SUS 2
#define LOG_THREAT 4

/obj/machinery/detector
	name = "Mr. V.A.L.I.D. Portable Threat Detector"
	desc = "This state of the art unit allows NT security personnel to contain a situation or secure an area better and faster."
	icon = 'icons/obj/detector.dmi'
	icon_state = "detector1"
	var/range = 3
	var/disable = 0
	var/last_read = 0
	var/base_state = "detector"
	anchored = 0
	ghost_read=0
	ghost_write=0
	density = 1
	var/idmode = 0
	var/scanmode = 0
	var/senset = 0
	var/logview = 0

	req_access = list(access_security)

	flags = FPRINT | PROXMOVE
	machine_flags = WRENCHMOVE | FIXED2WORK | EMAGGABLE
	on_armory_manifest = TRUE

	//List of weapons that metaldetector will not flash for, also copypasted in secbot.dm and ed209bot.dm
	var/list/safe_weapons = list(
		/obj/item/weapon/gun/energy/tag,
		/obj/item/weapon/gun/energy/laser/practice,
		/obj/item/weapon/gun/hookshot,
		/obj/item/weapon/melee/defibrillator
		)
	var/list/threat_logs = list()
	var/list/sus_logs = list()
	var/list/clear_logs = list()
	var/log_level = LOG_SUS | LOG_THREAT

//THIS CODE IS COPYPASTED IN ed209bot.dm AND secbot.dm, with slight variations
/obj/machinery/detector/proc/assess_perp(mob/living/carbon/human/perp as mob)
	var/threatcount = 0 //If threat >= PERP_LEVEL_ARREST at the end, they get arrested
	if(!(istype(perp, /mob/living/carbon)) || isalien(perp) || isbrain(perp))
		return -1
	var/list/to_evaluate = list()
	if(ishuman(perp))
		to_evaluate = list(perp.back, perp.belt, perp.s_store) + (scanmode ? list(perp.l_store, perp.r_store) : null)
	if(ismonkey(perp))
		to_evaluate = list(perp.back)
	if(!src.allowed(perp)) //cops can do no wrong, unless set to arrest

		if(!wpermit(perp))
			for(var/obj/item/I in perp.held_items)
				if(check_for_weapons(I))
					threatcount += PERP_LEVEL_ARREST

			for(var/obj/item/I in to_evaluate)
				if(check_for_weapons(I))
					threatcount += PERP_LEVEL_ARREST/2

			if(perp.back && istype(perp.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = perp.back
				for(var/obj/item/weapon/thing in B.contents)
					if(check_for_weapons(thing))
						threatcount += PERP_LEVEL_ARREST/2

		if(idmode)
			if(!perp.wear_id)
				threatcount += PERP_LEVEL_ARREST

		else
			if(!perp.wear_id)
				threatcount += PERP_LEVEL_ARREST/2

		if(ishuman(perp))
			if(istype(perp.wear_suit, /obj/item/clothing/suit/wizrobe))
				threatcount += PERP_LEVEL_ARREST/2

		if(perp.dna && perp.dna.mutantrace && perp.dna.mutantrace != "none")
			threatcount += PERP_LEVEL_ARREST/2

		//Agent cards lower threatlevel.
		if(perp.wear_id && istype(perp.wear_id.GetID(), /obj/item/weapon/card/id/syndicate))
			threatcount -= PERP_LEVEL_ARREST/2

	var/passperpname = ""
	for (var/datum/data/record/E in data_core.general)
		var/perpname = perp.name

		if(perp.wear_id)
			var/obj/item/weapon/card/id/id = perp.wear_id.GetID()

			if(id)
				perpname = id.registered_name
		else
			perpname = "Unknown"
		passperpname = perpname
		if(E.fields["name"] == perpname)
			for (var/datum/data/record/R in data_core.security)
				if((R.fields["id"] == E.fields["id"]) && ((R.fields["criminal"] == "*Arrest*") || R.fields["criminal"] == "*High Threat*"))
					threatcount = PERP_LEVEL_ARREST
					break

	var/list/retlist = list(threatcount, passperpname)
	if(emagged)
		retlist[1] = PERP_LEVEL_ARREST + rand(PERP_LEVEL_ARREST, PERP_LEVEL_ARREST*5)
	return retlist





/obj/machinery/detector/power_change()
	if (powered())
		stat &= ~NOPOWER
//		icon_state = "[base_state]1"
	else
		stat |= NOPOWER
//		icon_state = "[base_state]1"

/obj/machinery/detector/attackby(obj/item/W, mob/user)
	if(..(W, user) == 1)
		return 1 // resolved for click code!

	/*if (W.is_wirecutter(user))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("<span class='warning'>[user] has disconnected the detector array!</span>", "<span class='warning'>You disconnect the detector array!</span>")
		if (!src.disable)
			user.visible_message("<span class='warning'>[user] has connected the detector array!</span>", "<span class='warning'>You connect the detector array!</span>")
	*/

/obj/machinery/detector/Topic(href, href_list)
	if(..())
		return 1

	if(usr)
		usr.set_machine(src)

	switch(href_list["action"])
		if("idmode")
			idmode = !idmode
		if("scanmode")
			scanmode = !scanmode
		if("senmode")
			senset = !senset
		if("setlogs")
			toggle_logflag(href_list["logflag"])
		if("viewlogs")
			logview = !logview
		if("clearlogs")
			switch(href_list["logflag"])
				if(LOG_CLEAR)
					clear_logs.Cut()
				if(LOG_SUS)
					sus_logs.Cut()
				if(LOG_THREAT)
					threat_logs.Cut()
		else
			return

	src.updateUsrDialog()
	return 1

/obj/machinery/detector/proc/toggle_logflag(flag)
	if (log_level & flag)
		log_level &= ~flag
	else
		log_level |= flag

/obj/machinery/detector/attack_hand(mob/user as mob)

	if(src.allowed(user))


		user.set_machine(src)

		if(!src.anchored)
			return

		var/dat = "<TITLE>Mr. V.A.L.I.D. Portable Threat Detector</TITLE>"
		if(!logview)
			dat += {"<h3>Menu:</h3><h4><br>
			Citizens must carry ID: <A href='?src=\ref[src];action=idmode'>Turn [idmode ? "Off" : "On"]</A><br>
			Intrusive Scan: <A href='?src=\ref[src];action=scanmode'>Turn [scanmode ? "Off" : "On"]</A><br>
			DeMil Alerts: <A href='?src=\ref[src];action=senmode'>Turn [senset ? "Off" : "On"]</A></h4>
			<h3>Logging:</h3><h4><br>
			Clear subjects: <A href='?src=\ref[src];action=setlogs;logflag=[LOG_CLEAR]'>Turn [(log_level & LOG_CLEAR) ? "Off" : "On"]</A><br>
			Suspicious subjects: <A href='?src=\ref[src];action=setlogs;logflag=[LOG_SUS]'>Turn [(log_level & LOG_SUS) ? "Off" : "On"]</A><br>
			Threats: <A href='?src=\ref[src];action=setlogs;logflag=[LOG_THREAT]'>Turn [(log_level & LOG_THREAT) ? "Off" : "On"]</A></h4>
			"}
			if(clear_logs.len || sus_logs.len || threat_logs.len)
				dat += "<h3><A href='?src=\ref[src];action=viewlogs'>View logs</A></h3>"
		else
			dat += {"<h3>Logs:</h3><h4><br>
					Clear subjects: <A href='?src=\ref[src];action=clearlogs;logflag=[LOG_CLEAR]'>(Clear)</A><br><br>"}
			for(var/name in clear_logs)
				dat += "[name] - [clear_logs[name]]<br>"
			dat += "<br>Analysis needed: <A href='?src=\ref[src];action=clearlogs;logflag=[LOG_SUS]'>(Clear)</A><br><br>"
			for(var/name in sus_logs)
				dat += "[name] - [sus_logs[name]]<br>"
			dat += "<br>Threats detected: <A href='?src=\ref[src];action=clearlogs;logflag=[LOG_THREAT]'>(Clear)</A><br><br>"
			for(var/name in threat_logs)
				dat += "[name] - [threat_logs[name]]<br>"
			dat += "</h4><h3><A href='?src=\ref[src];action=viewlogs'>Return</A></h3>"
		user << browse(HTML_SKELETON(dat), "window=detector;size=575x300")
		onclose(user, "detector")
		return

	else
		src.visible_message("<span class = 'warning'>ACCESS DENIED!</span>")


/obj/machinery/detector/proc/flash()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_read && world.time < src.last_read + 2 SECONDS))
		return


	var/maxthreat = 0
	var/sndstr = ""
	var/list/threat_carbons = list()
	var/list/clear_carbons = list()
	var/list/mildly_threatening_carbons = list()
	for(var/mob/living/carbon/O in view(src, range))
		var/list/ourretlist = src.assess_perp(O)
		if(!islist(ourretlist) || !ourretlist.len)
			continue
		var/dudesthreat = ourretlist[1]
		var/dudesname = ourretlist[2]

		if(dudesthreat >= PERP_LEVEL_ARREST)
			if(maxthreat < 2)
				sndstr = "sound/machines/alert.ogg"
				maxthreat = 2
			src.last_read = world.time
			use_power(1000)
			threat_carbons += dudesname
		else if(dudesthreat && senset)
			if(maxthreat < 1)
				sndstr = "sound/machines/domore.ogg"
				maxthreat = 1
			src.last_read = world.time
			use_power(1000)
			mildly_threatening_carbons += dudesname
		else
			if(maxthreat == 0)
				sndstr = "sound/machines/info.ogg"
			src.last_read = world.time
			use_power(1000)
			clear_carbons += dudesname

	if(threat_carbons.len)
		say("Threat detected! Subject[threat_carbons.len > 1 ? "s" : ""]: [threat_carbons.Join(", ")].")
		if(log_level & LOG_THREAT)
			for(var/logname in threat_carbons)
				threat_logs[logname] = worldtime2text(give_seconds = TRUE)
	if(clear_carbons.len)
		say("Clear. Subject[clear_carbons.len > 1 ? "s" : ""]: [clear_carbons.Join(", ")].")
		if(log_level & LOG_CLEAR)
			for(var/logname in clear_carbons)
				clear_logs[logname] = worldtime2text(give_seconds = TRUE)
	if(mildly_threatening_carbons.len)
		say("Additional screening required! Subject[threat_carbons.len > 1 ? "s" : ""]: [mildly_threatening_carbons.Join(", ")].")
		if(log_level & LOG_SUS)
			for(var/logname in mildly_threatening_carbons)
				sus_logs[logname] = worldtime2text(give_seconds = TRUE)

	flick("[base_state]_flash", src)
	playsound(src, sndstr, 100, 1)


/obj/machinery/detector/proc/check_for_weapons(var/obj/item/slot_item) //Unused anywhere, copypasted in secbot.dm
	if(istype(slot_item, /obj/item/weapon/gun) || istype(slot_item, /obj/item/weapon/melee))
		if(!(slot_item.type in safe_weapons))
			return 1
	return 0


/obj/machinery/detector/emp_act(severity)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		..(severity)
		return
	if(prob(75/severity))
		flash()
	..(severity)

/obj/machinery/detector/emag_act(mob/user)
	..()
	emagged = TRUE

/obj/machinery/detector/HasProximity(atom/movable/AM as mob|obj)
	if ((src.disable) || (src.last_read && world.time < src.last_read + 3 SECONDS))
		return

	if(istype(AM, /mob/living/carbon))

		if ((src.anchored))
			src.flash()

/obj/machinery/detector/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	overlays.len = 0
	if(anchored)
		src.overlays += image(icon = icon, icon_state = "[base_state]-s")

#undef LOG_CLEAR
#undef LOG_SUS
#undef LOG_THREAT