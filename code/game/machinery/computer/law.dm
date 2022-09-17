//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/aiupload
	name = "AI Upload"
	desc = "Used to upload laws to the AI using a cheap radio transceiver."
	icon_state = "upload"
	circuit = "/obj/item/weapon/circuitboard/aiupload"
	var/mob/living/silicon/ai/current = null
	var/mob/living/silicon/ai/occupant = null
	var/opened = 0

	light_color = "#555555"

/obj/machinery/computer/aiupload/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/device/aicard))
		if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
			to_chat(user, "This terminal isn't functioning right now, get it working!")
			return
		var/obj/item/card = I
		card.transfer_ai("AIUPLOAD","AICARD",src,user)
		attack_hand(user)
		return
	return ..()


/obj/machinery/computer/aiupload/verb/AccessInternals()
	set category = "Object"
	set name = "Access Computer's Internals"
	set src in oview(1)
	if(get_dist(src, usr) > 1 || usr.restrained() || usr.lying || usr.isUnconscious() || istype(usr, /mob/living/silicon))
		return
	
	opened = !opened
	if(opened)
		to_chat(usr, "<span class='notice'>The access panel is now open.</span>")
	else
		to_chat(usr, "<span class='notice'>The access panel is now closed.</span>")

/obj/machinery/computer/aiupload/proc/install_module(var/obj/item/weapon/aiModule/O, var/mob/user)
	if(stat & NOPOWER)
		to_chat(usr, "The upload computer has no power!")
		return 0
	if(stat & BROKEN)
		to_chat(usr, "The upload computer is broken!")
		return 0
	if(stat & FORCEDISABLE)
		to_chat(usr, "The upload computer isn't responding!")
		return 0
	if(!current)
		to_chat(usr, "You haven't selected an AI to transmit laws to!")
		return 0

	if(ticker && ticker.mode && ticker.mode.name == "blob")
		to_chat(usr, "Law uploads have been disabled by Nanotrasen!")
		return 0

	if(current.stat == 2 && occupant != current)
		to_chat(usr, "Upload failed. No signal is being detected from the AI.")
	else if(current.aiRestorePowerRoutine)
		to_chat(usr, "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power.")
	else
		// Modules should throw their own errors.
		// Our responsibility is to prevent success messages.
		var/obj/item/weapon/aiModule/M = O
		if(!M.validate(current.laws,current,user))
			return 0
		if(!M.upload(current.laws,current,user))
			return 0
		return 1

/obj/machinery/computer/aiupload/proc/announce_law_changes(var/mob/user)
	to_chat(current, "These are your laws now:")
	current.show_laws()
	current << sound('sound/machines/lawsync.ogg')
	for(var/mob/living/silicon/robot/R in cyborg_list)
		if(R.lawupdate && (R.connected_ai == current))
			to_chat(R, "These are your laws now:")
			R.show_laws()
			R << sound('sound/machines/lawsync.ogg')
			R.throw_alert(SCREEN_ALARM_ROBOT_LAW, /obj/abstract/screen/alert/robot/newlaw)
	to_chat(user, "<span class='notice'>Upload complete. The AI's laws have been modified.</span>")

/obj/machinery/computer/aiupload/proc/same_zlevel()
	if(!current)
		return FALSE
	var/turf/T = get_turf(current)
	if(!atoms_share_level(T, src))
		return FALSE
	return TRUE

/obj/machinery/computer/aiupload/attackby(obj/item/weapon/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/aiModule))
		if(!same_zlevel())
			to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the target AI!")
			return
		if(install_module(O,user))
			announce_law_changes(user)
	else if(istype(O, /obj/item/weapon/planning_frame))
		if(!same_zlevel())
			to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the target AI!")
			return
		if(stat & NOPOWER)
			to_chat(usr, "The upload computer has no power!")
			return
		if(stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return
		if(stat & FORCEDISABLE)
			to_chat(usr, "The upload computer isn't responding!")
			return 0
		if(!current)
			to_chat(usr, "You haven't selected an AI to transmit laws to!")
			return

		if(ticker && ticker.mode && ticker.mode.name == "blob")
			to_chat(usr, "Law uploads have been disabled by Nanotrasen!")
			return

		if(current.stat == 2 || current.control_disabled == 1)
			to_chat(usr, "Upload failed. No signal is being detected from the AI.")
		else if(current.aiRestorePowerRoutine)
			to_chat(usr, "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power.")
		else
			var/obj/item/weapon/planning_frame/frame=O
			if(frame.modules.len>0)
				to_chat(user, "<span class='notice'>You begin to load \the [frame] into \the [src]...</span>")
				if(do_after(user, src,50))
					var/failed=0
					for(var/i=1;i<=frame.modules.len;i++)
						var/obj/item/weapon/aiModule/M = frame.modules[i]
						to_chat(user, "<span class='notice'>Running [M]...</span>")
						if(!install_module(M,user))
							failed=1
							break
					if(!failed)
						announce_law_changes(user)
			else
				to_chat(user, "<span class='warning'>It's empty, doofus.</span>")
	else
		..()

/obj/machinery/computer/aiupload/attack_hand(var/mob/user as mob)
	if(istype(user,/mob/dead))
		to_chat(usr, "<span class='rose'>Your ghostly hand goes right through!</span>")
		return
	if(stat & NOPOWER)
		to_chat(usr, "The upload computer has no power!")
		return
	if(stat & FORCEDISABLE)
		to_chat(usr, "The upload computer isn't responding!")
		return 0
	if(stat & BROKEN)
		to_chat(usr, "The upload computer is broken!")
		return

	if (occupant)
		current = occupant
	else if (current)
		current = null
		update_icon()
		return
	else
		current = select_active_ai(user)

	if(!current)
		to_chat(usr, "No active AIs detected.")
	else
		if(src.occupant)
			to_chat(usr, "AI detected on this terminal. [current.name] selected for law changes.")
		else
			to_chat(usr, "[current.name] selected for law changes.")

	update_icon()

/obj/machinery/computer/borgupload
	name = "Cyborg Upload"
	desc = "Used to upload laws to Cyborgs."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/borgupload"
	var/mob/living/silicon/robot/current = null
	light_color = "#555555"

/obj/machinery/computer/borgupload/proc/announce_law_changes()
	to_chat(current, "These are your laws now:")
	current.show_laws()
	current << sound('sound/machines/lawsync.ogg')
	current.throw_alert(SCREEN_ALARM_ROBOT_LAW, /obj/abstract/screen/alert/robot/newlaw)
	to_chat(usr, "<span class='notice'>Upload complete. The robot's laws have been modified.</span>")

/obj/machinery/computer/borgupload/proc/install_module(var/obj/item/weapon/aiModule/M,var/mob/user)
	if(stat & NOPOWER)
		to_chat(usr, "The upload computer has no power!")
		return 0
	if(stat & BROKEN)
		to_chat(usr, "The upload computer is broken!")
		return 0
	if(stat & FORCEDISABLE)
		to_chat(usr, "The upload computer isn't responding!")
		return 0
	if(!current)
		to_chat(usr, "You haven't selected a robot to transmit laws to!")
		return 0

	if(current.stat == 2 || current.emagged)
		to_chat(usr, "Upload failed. No signal is being detected from the robot.")
		return 0
	if(istype(current, /mob/living/silicon/robot/mommi))
		var/mob/living/silicon/robot/mommi/mommi = current
		if(mommi.keeper)
			to_chat(usr, "Upload failed. No signal is being detected from the cyborg.")
			return 0
	else if(current.connected_ai)
		to_chat(usr, "Upload failed. The robot is slaved to an AI.")
		return 0
	else
		// Modules should throw their own errors.
		// Our responsibility is to prevent success messages.
		if(!M.validate(current.laws,current,user))
			return 0
		if(!M.upload(current.laws,current,user))
			return 0
		announce_law_changes()
	return 1

/obj/machinery/computer/borgupload/proc/same_zlevel()
	if(!current)
		return FALSE
	var/turf/T = get_turf(current)
	if(!atoms_share_level(T, src))
		return FALSE
	return TRUE

/obj/machinery/computer/borgupload/attackby(var/obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/aiModule))
		if(!same_zlevel())
			to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the target silicon!")
			return
		if(isMoMMI(current))
			var/mob/living/silicon/robot/mommi/mommi = current
			if(mommi.keeper)
				to_chat(user, "<span class='warning'>[current] is operating in KEEPER mode and cannot be accessed via control signals.</span>")
				return ..()
		install_module(W,user)
	else if(istype(W, /obj/item/weapon/planning_frame))
		if(!same_zlevel())
			to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the target silicon!")
			return
		if(stat & NOPOWER)
			to_chat(user, "The upload computer has no power!")
			return
		if(stat & BROKEN)
			to_chat(user, "The upload computer is broken!")
			return
		if(stat & FORCEDISABLE)
			to_chat(usr, "The upload computer isn't responding!")
			return 0
		if(!current)
			to_chat(user, "You haven't selected a robot to transmit laws to!")
			return

		if(current.stat == 2 || current.emagged)
			to_chat(user, "Upload failed. No signal is being detected from the robot.")
			return
		if(istype(current, /mob/living/silicon/robot/mommi))
			var/mob/living/silicon/robot/mommi/mommi = current
			if(mommi.keeper)
				to_chat(user, "Upload failed. No signal is being detected from the cyborg.")
				return
		else if(current.connected_ai)
			to_chat(user, "Upload failed. The robot is slaved to an AI.")
		else
			var/obj/item/weapon/planning_frame/frame=W
			if(frame.modules.len>0)
				to_chat(user, "<span class='notice'>You begin to load \the [frame] into \the [src]...</span>")
				if(do_after(user, src,50))
					var/failed=0
					for(var/i=1;i<=frame.modules.len;i++)
						var/obj/item/weapon/aiModule/M = frame.modules[i]
						to_chat(user, "<span class='notice'>Running [M]...</span>")
						if(!install_module(M,user))
							failed=1
							break
					if(!failed)
						announce_law_changes()
			else
				to_chat(user, "<span class='warning'>It's empty, doofus.</span>")
	else
		return ..()

/obj/machinery/computer/borgupload/attack_hand(var/mob/user as mob)
	if(istype(user,/mob/dead))
		to_chat(usr, "<span class='rose'>Your ghostly hand goes right through!</span>")
		return
	if(stat & NOPOWER)
		to_chat(usr, "The upload computer has no power!")
		return
	if(stat & BROKEN)
		to_chat(usr, "The upload computer is broken!")
		return
	if(stat & FORCEDISABLE)
		to_chat(usr, "The upload computer isn't responding!")
		return 0
	current = freeborg()

	if(!current)
		to_chat(usr, "No free cyborgs detected.")
	else
		to_chat(usr, "[current.name] selected for law changes.")


/obj/machinery/computer/aiupload/longrange
	name = "Long Range AI Upload"
	desc = "Used to upload laws to the AI using a powerful subspace transceiver."
	circuit = "/obj/item/weapon/circuitboard/aiupload/longrange"

/obj/machinery/computer/aiupload/longrange/same_zlevel()
	return TRUE

/obj/machinery/computer/aiupload/update_icon()
	..()
	overlays = 0
	
	if(stat & (BROKEN | NOPOWER | FORCEDISABLE))
		return
	
	if (occupant)
		switch (occupant.stat)
			if (CONSCIOUS)
				overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
			if (DEAD)
				overlays += image('icons/obj/computer.dmi', "ai-fixer-404")
	else if (current)
		if(current.stat == DEAD)
			overlays += image('icons/obj/computer.dmi', "upload_wireless_dead")
		else if(current.aiRestorePowerRoutine)
			overlays += image('icons/obj/computer.dmi', "upload_wireless_nopower")
		else
			overlays += image('icons/obj/computer.dmi', "upload_wireless")

/obj/machinery/computer/aiupload/process()
	..()
	update_icon()