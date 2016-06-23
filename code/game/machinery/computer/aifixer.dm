/obj/machinery/computer/aifixer
	name = "AI System Integrity Restorer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "ai-fixer"
	req_access = list(access_captain, access_robotics, access_heads)
	var/mob/living/silicon/ai/occupant = null
	var/active = 0

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/aifixer/New()
	..()
	update_icon()

/obj/machinery/computer/aifixer/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/device/aicard))
		if(stat & (NOPOWER|BROKEN))
			to_chat(user, "This terminal isn't functioning right now, get it working!")
			return
		I:transfer_ai("AIFIXER","AICARD",src,user)
		return
	return ..()

/obj/machinery/computer/aifixer/attack_ai(var/mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/aifixer/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/aifixer/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = "<h3>AI System Integrity Restorer</h3><br><br>"

	if (occupant)
		var/laws
		dat += "Stored AI: [occupant.name]<br>System integrity: [occupant.system_integrity()]%<br>"

		if (occupant.laws.zeroth)
			laws += "0: [occupant.laws.zeroth]<BR>"

		var/number = 1
		for (var/index = 1, index <= occupant.laws.inherent.len, index++)
			var/law = occupant.laws.inherent[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		for (var/index = 1, index <= occupant.laws.supplied.len, index++)
			var/law = occupant.laws.supplied[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		dat += "Laws:<br>[laws]<br>"

		if (occupant.stat == 2)
			dat += "<b>AI nonfunctional</b>"
		else
			dat += "<b>AI functional</b>"
		if (!active)
			dat += {"<br><br><A href='byond://?src=\ref[src];fix=1'>Begin Reconstruction</A>"}
		else
			dat += "<br><br>Reconstruction in process, please wait.<br>"
	dat += {" <A href='?src=\ref[user];mach_close=computer'>Close</A>"}


	user.set_machine(src)

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/aifixer/process()
	if(..())
		updateUsrDialog()
		return

/obj/machinery/computer/aifixer/Topic(href, href_list)
	if(..())
		return
	if (href_list["fix"])
		active = 1
		overlays += image('icons/obj/computer.dmi', "ai-fixer-on")
		while (occupant.health < 100)
			occupant.adjustOxyLoss(-1)
			occupant.adjustFireLoss(-1)
			occupant.adjustToxLoss(-1)
			occupant.adjustBruteLoss(-1)
			occupant.updatehealth()
			if (occupant.health >= 0 && occupant.stat == 2)
				occupant.stat = 0
				occupant.lying = 0
				occupant.resurrect()
				overlays -= image('icons/obj/computer.dmi', "ai-fixer-404")
				overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
			updateUsrDialog()
			sleep(10)
		active = 0
		overlays -= image('icons/obj/computer.dmi', "ai-fixer-on")


		add_fingerprint(usr)
	updateUsrDialog()
	return


/obj/machinery/computer/aifixer/update_icon()
	..()
	overlays = 0
	// Broken / Unpowered
	if(stat & (BROKEN | NOPOWER))
		return

	if (occupant)
		switch (occupant.stat)
			if (0)
				overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
			if (2)
				overlays += image('icons/obj/computer.dmi', "ai-fixer-404")
	else
		overlays += image('icons/obj/computer.dmi', "ai-fixer-empty")
