


/obj/machinery/detector
	name = "Mr. V.A.L.I.D. Portable Threat Detector"
	desc = "This state of the art unit allows NT security personnel to contain a situation or secure an area better and faster."
	icon = 'icons/obj/detector.dmi'
	icon_state = "detector1"
	var/id_tag = null
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

	req_access = list(access_security)

	flags = FPRINT | PROXMOVE
	machine_flags = WRENCHMOVE | FIXED2WORK | EMAGGABLE

	//List of weapons that metaldetector will not flash for, also copypasted in secbot.dm and ed209bot.dm
	var/safe_weapons = list(
		/obj/item/weapon/gun/energy/tag,
		/obj/item/weapon/gun/energy/laser/practice,
		/obj/item/weapon/gun/hookshot,
		/obj/item/weapon/gun/energy/floragun,
		/obj/item/weapon/melee/defibrillator
		)

//THIS CODE IS COPYPASTED IN ed209bot.dm AND secbot.dm, with slight variations
/obj/machinery/detector/proc/assess_perp(mob/living/carbon/human/perp as mob)
	var/threatcount = 0 //If threat >= PERP_LEVEL_ARREST at the end, they get arrested
	if(!(istype(perp, /mob/living/carbon)) || isalien(perp) || isbrain(perp))
		return -1

	if(!src.allowed(perp)) //cops can do no wrong, unless set to arrest

		if(!wpermit(perp))
			for(var/obj/item/I in perp.held_items)
				if(check_for_weapons(I))
					threatcount += PERP_LEVEL_ARREST

			for(var/obj/item/I in list(perp.back, perp.belt, perp.s_store) + (scanmode ? list(perp.l_store, perp.r_store) : null))
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
				if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
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

	/*if (iswirecutter(W))
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
		else
			return

	src.updateUsrDialog()
	return 1



/obj/machinery/detector/attack_hand(mob/user as mob)

	if(src.allowed(user))


		user.set_machine(src)

		if(!src.anchored)
			return

		var/dat = {"
		<TITLE>Mr. V.A.L.I.D. Portable Threat Detector</TITLE><h3>Menu:</h3><h4>

		<br>Citizens must carry ID: <A href='?src=\ref[src];action=idmode'>Turn [idmode ? "Off" : "On"]</A>

		<br>Intrusive Scan: <A href='?src=\ref[src];action=scanmode'>Turn [scanmode ? "Off" : "On"]</A>

		<br>DeMil Alerts: <A href='?src=\ref[src];action=senmode'>Turn [senset ? "Off" : "On"]</A></h4>
		"}

		user << browse(dat, "window=detector;size=575x300")
		onclose(user, "detector")
		return

	else
		src.visible_message("<span class = 'warning'>ACCESS DENIED!</span>")


/obj/machinery/detector/proc/flash()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_read && world.time < src.last_read + 20))
		return


	var/maxthreat = 0
	var/sndstr = ""
	for(var/mob/living/O in view(src, range))
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
			src.visible_message("<span class = 'warning'>Threat Detected! Subject: [dudesname]</span>")////


		else if(dudesthreat && senset)

			if(maxthreat < 1)
				sndstr = "sound/machines/domore.ogg"
				maxthreat = 1


			src.last_read = world.time
			use_power(1000)
			src.visible_message("<span class = 'warning'>Additional screening required! Subject: [dudesname]</span>")


		else

			if(maxthreat == 0)
				sndstr = "sound/machines/info.ogg"



			src.last_read = world.time
			use_power(1000)
			src.visible_message("<span class = 'notice'> Subject: [dudesname] clear.</span>")


	flick("[base_state]_flash", src)
	playsound(src, sndstr, 100, 1)


/obj/machinery/detector/proc/check_for_weapons(var/obj/item/slot_item) //Unused anywhere, copypasted in secbot.dm
	if(istype(slot_item, /obj/item/weapon/gun) || istype(slot_item, /obj/item/weapon/melee))
		if(!(slot_item.type in safe_weapons))
			return 1
	return 0


/obj/machinery/detector/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(prob(75/severity))
		flash()
	..(severity)

/obj/machinery/detector/emag(mob/user)
	..()
	emagged = TRUE

/obj/machinery/detector/HasProximity(atom/movable/AM as mob|obj)
	if ((src.disable) || (src.last_read && world.time < src.last_read + 30))
		return

	if(istype(AM, /mob/living/carbon))

		if ((src.anchored))
			src.flash()

/obj/machinery/detector/wrenchAnchor(var/mob/user)
	. = ..()
	if(!.)
		return
	overlays.len = 0
	if(anchored)
		src.overlays += image(icon = icon, icon_state = "[base_state]-s")
