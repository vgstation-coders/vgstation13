/obj/item/device/aicard
	name = "inteliCard"
	desc = "A device that stores artifical intelligence units."
	icon = 'icons/obj/pda.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	flags = FPRINT
	slot_flags = SLOT_BELT
	var/flush = null
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_MATERIALS + "=4"


/obj/item/device/aicard/attack(mob/living/silicon/ai/M as mob, mob/user as mob)
	if(!istype(M, /mob/living/silicon/ai))//If target is not an AI.
		return ..()
	if(M.mind && M.mind.current != M)
		return ..()

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been carded with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to card [M.name] ([M.ckey])</font>")

	log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to card [M.name] ([M.ckey])</font>")

	transfer_ai("AICORE", "AICARD", M, user)

	playsound(src, 'sound/machines/paistartup.ogg', 50, 1)
	return

/obj/item/device/aicard/attack_self(mob/user)
	tgui_interact(user)

/obj/item/device/aicard/ui_data()
	var/list/data = list()
	var/mob/living/silicon/ai/mistake = locate() in src
	if(mistake)
		data["name"] = mistake.name
		var/list/laws = list()
		var/number = 1

		//AI DIDN'T KILL SOMEONE FOR ME, CARD HER TO CHECK HER LAWS

		//for (var/index = 1, index <= A.laws.ion.len, index++)
			//var/law = A.laws.ion[index]
			//if (length(law) > 0)
				//var/num = ionnum()
				//laws += "[num]. [law]"

		//if (A.laws.zeroth)
			//laws += "0: [A.laws.zeroth]<BR>"

		for (var/index = 1, index <= mistake.laws.inherent.len, index++)
			var/law = mistake.laws.inherent[index]
			if (length(law) > 0)
				laws += "[number]: [law]"
				number++

		for (var/index = 1, index <= mistake.laws.supplied.len, index++)
			var/law = mistake.laws.supplied[index]
			if (length(law) > 0)
				laws += "[number]: [law]"
				number++

		data["laws"] = laws
		data["health"] = mistake.system_integrity()
		data["wireless"] = !mistake.control_disabled
		data["isDead"] = mistake.stat == DEAD
		data["isBraindead"] = !!mistake.client
	data["wiping"] = flush
	return data

/obj/item/device/aicard/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = global.hands_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Intellicard", name, 500, 500, master_ui, state)
		ui.open()

/obj/item/device/aicard/ui_act(action, params, datum/tgui/ui)
	if(..())
		return FALSE
	switch(action)
		if("wipe")
			if(flush)
				flush = FALSE
				return TRUE
			var/confirm = alert("Are you sure you want to wipe this card's memory? This cannot be undone once started.", "Confirm Wipe", "Yes", "No")
			if(confirm != "Yes" || ..())
				return TRUE
			flush = TRUE
			for(var/mob/living/silicon/ai/A in src)
				A.suiciding = 1
				to_chat(A, "Your core files are being wiped!")
				A.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been wiped with an [src.name] by [ui.user.name] ([ui.user.ckey])</font>"
				ui.user.attack_log += "\[[time_stamp()]\] <font color='red'>Used an [src.name] to wipe [A.name] ([A.ckey])</font>"
				log_attack("[key_name(ui.user)] Used an [src.name] to wipe [key_name(A)]")

				spawn()
					while (A.stat != DEAD && flush)
						A.adjustOxyLoss(2)
						A.updatehealth()
						sleep(1 SECONDS)
					flush = FALSE
			return TRUE
		if("wireless")
			for(var/mob/living/silicon/ai/A in src)
				A.control_disabled = !A.control_disabled
				to_chat(A, "The intellicard's wireless port has been [A.control_disabled ? "disabled" : "enabled"]!")
				if (A.control_disabled)
					overlays -= image('icons/obj/pda.dmi', "aicard-on")
				else
					overlays += image('icons/obj/pda.dmi', "aicard-on")
			return TRUE

/obj/item/device/aicard/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(50))
				qdel(src)
		if(3.0)
			if(prob(25))
				qdel(src)
