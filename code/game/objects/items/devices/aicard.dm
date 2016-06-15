/obj/item/device/aicard
	name = "inteliCard"
	icon = 'icons/obj/pda.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	flags = FPRINT
	slot_flags = SLOT_BELT
	var/flush = null
	origin_tech = "programming=4;materials=4"


/obj/item/device/aicard/attack(mob/living/silicon/ai/M as mob, mob/user as mob)
	if(!istype(M, /mob/living/silicon/ai))//If target is not an AI.
		return ..()
	if(M.mind && M.mind.current != M)
		return ..()

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been carded with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to card [M.name] ([M.ckey])</font>")

	log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to card [M.name] ([M.ckey])</font>")

	transfer_ai("AICORE", "AICARD", M, user)

	playsound(get_turf(src), 'sound/machines/paistartup.ogg', 50, 1)
	return

/obj/item/device/aicard/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = "<TT><B>Intelicard</B><BR>"
	var/laws
	for(var/mob/living/silicon/ai/A in src)
		dat += "Stored AI: [A.name]<br>System integrity: [A.system_integrity()]%<br>"

		//AI DIDN'T KILL SOMEONE FOR ME, CARD HER TO CHECK HER LAWS

		//for (var/index = 1, index <= A.laws.ion.len, index++)
			//var/law = A.laws.ion[index]
			//if (length(law) > 0)
				//var/num = ionnum()
				//laws += "[num]. [law]"

		//if (A.laws.zeroth)
			//laws += "0: [A.laws.zeroth]<BR>"

		var/number = 1
		for (var/index = 1, index <= A.laws.inherent.len, index++)
			var/law = A.laws.inherent[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		for (var/index = 1, index <= A.laws.supplied.len, index++)
			var/law = A.laws.supplied[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		dat += "Laws:<br>[laws]<br>"

		if (A.stat == 2)
			dat += "<b>AI nonfunctional</b>"
		else
			if (!src.flush)
				dat += {"<A href='byond://?src=\ref[src];choice=Wipe'>Wipe AI</A>"}
			else
				dat += "<b>Wipe in progress</b>"
			dat += "<br>"
			dat += {"<a href='byond://?src=\ref[src];choice=Wireless'>[A.control_disabled ? "Enable" : "Disable"] Wireless Activity</a>"}
			dat += "<br>"
			dat += {"<a href='byond://?src=\ref[src];choice=Close'> Close</a>"}
	user << browse(dat, "window=aicard")
	onclose(user, "aicard")
	return

/obj/item/device/aicard/Topic(href, href_list)
	var/mob/living/U = usr
	if (!in_range(src, U)||U.machine!=src)//If they are not in range of 1 or less or their machine is not the card (ie, clicked on something else).
		U << browse(null, "window=aicard")
		U.unset_machine()
		return

	add_fingerprint(U)
	U.set_machine(src)

	switch(href_list["choice"])//Now we switch based on choice.
		if ("Close")
			U << browse(null, "window=aicard")
			U.unset_machine()
			return

		if ("Wipe")
			var/confirm = alert("Are you sure you want to wipe this card's memory? This cannot be undone once started.", "Confirm Wipe", "Yes", "No")
			if(confirm == "Yes")
				if(isnull(src)||!in_range(src, U)||U.machine!=src)
					U << browse(null, "window=aicard")
					U.unset_machine()
					return
				else
					flush = 1
					for(var/mob/living/silicon/ai/A in src)
						A.suiciding = 1
						to_chat(A, "Your core files are being wiped!")
						A.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been wiped with an [src.name] by [U.name] ([U.ckey])</font>")
						U.attack_log += text("\[[time_stamp()]\] <font color='red'>Used an [src.name] to wipe [A.name] ([A.ckey])</font>")
						log_attack("[key_name(U)] Used an [src.name] to wipe [key_name(A)]")

						while (A.stat != 2)
							A.adjustOxyLoss(2)
							A.updatehealth()
							sleep(10)
						flush = 0

		if ("Wireless")
			for(var/mob/living/silicon/ai/A in src)
				A.control_disabled = !A.control_disabled
				to_chat(A, "The intelicard's wireless port has been [A.control_disabled ? "disabled" : "enabled"]!")
				if (A.control_disabled)
					overlays -= image('icons/obj/pda.dmi', "aicard-on")
				else
					overlays += image('icons/obj/pda.dmi', "aicard-on")
	attack_self(U)

/obj/item/device/aicard/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(50)) qdel(src)
		if(3.0)
			if(prob(25)) qdel(src)
