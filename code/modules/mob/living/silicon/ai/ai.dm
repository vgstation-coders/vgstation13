/mob/living/silicon/ai
	name = "\improper Artificial Intelligence"
	job = "AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai"
	anchored = TRUE
	density = TRUE
	canmove = FALSE
	force_compose = TRUE

	var/list/network = list(CAMERANET_SS13)
	var/list/connected_robots = list() //Its robot slaves.

	var/aiRestorePowerRoutine = 0

	//Alarm stuff
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())
	var/viewalerts = FALSE

	//Law-related stuff
	var/lawcheck[1]
	var/ioncheck[1]

	//Component stuff
	var/obj/machinery/camera/current = null
	var/obj/item/device/pda/ai/aiPDA = null
	var/obj/item/device/multitool/aiMulti = null
	var/obj/item/device/station_map/station_holomap = null
	var/obj/item/device/camera/silicon/aicamera = null

	//Icon stuff
	var/busy = FALSE	//Toggle Floor Bolt busy var.
	var/icon/holo_icon	//Default is assigned when AI is created.
	var/chosen_core_icon_state = "ai"

	// The AI's "eye". Described on the top of the page in eye.dm
	var/mob/camera/aiEye/eyeobj
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1

	//MALFUNCTION stuff
	var/ai_flags = 0

	var/control_disabled = FALSE // Set to TRUE to stop AI from interacting via Click() -- TLE
	var/malfhacking = FALSE // More or less a copy of the above var, so that malf AIs can hack and still get new cyborgs -- NeoFite

	var/obj/machinery/power/apc/malfhack = null
	var/explosive = FALSE //does the AI explode when it dies?

	var/mob/living/silicon/ai/parent = null
	var/camera_light_on = FALSE
	var/list/obj/machinery/camera/lit_cameras = list()

	var/datum/trackable/track = new()

	var/last_paper_seen = null
	var/can_shunt = TRUE
	var/last_announcement = ""

/mob/living/silicon/ai/New(loc, var/datum/ai_laws/L, var/obj/item/device/mmi/B, var/safety = FALSE)
	PickAIName()
	SetAILanguages()
	SetAIComponents()
	SetAILaws(L)

	if(!safety) //Only used by AIize() to successfully spawn an AI.
		if(!B)//If there is no player/brain inside.
			new /obj/structure/AIcore/deactivated(loc)//New empty terminal.
			qdel(src)//Delete AI.
			return
		else
			if(B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)
			Greet()
	
	ai_list += src
	holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))

	..()
	playsound(src, 'sound/machines/WXP_startup.ogg', 75, FALSE)

/mob/living/silicon/ai/check_eye(var/mob/user as mob)
	if(!current)
		return null
	user.reset_view(current)
	return TRUE

/mob/living/silicon/ai/blob_act()
	if(flags & INVULNERABLE)
		return
	if(stat != DEAD)
		..()
		playsound(loc, 'sound/effects/blobattack.ogg',50,1)
		adjustBruteLoss(60)
		updatehealth()
		return TRUE
	return FALSE

/mob/living/silicon/ai/restrained()
	if(timestopped)
		return TRUE //under effects of time magick
	return FALSE

/mob/living/silicon/ai/emp_act(severity)
	if(flags & INVULNERABLE)
		return

	if(prob(30))
		switch(pick(1,2))
			if(1)
				view_core()
			if(2)
				ai_call_shuttle()
	..()

/mob/living/silicon/ai/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	// if(!blinded) (this is now in flash_eyes)
	flash_eyes(visual = TRUE, affect_silicon = TRUE)

	switch(severity)
		if(1.0)
			if(!isDead())
				adjustBruteLoss(100)
				adjustFireLoss(100)
		if(2.0)
			if(!isDead())
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if(!isDead())
				adjustBruteLoss(30)

	updatehealth()

/mob/living/silicon/ai/put_in_hands(var/obj/item/W)
	return FALSE

/mob/living/silicon/ai/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	return 2

/mob/living/silicon/ai/attack_alien(mob/living/carbon/alien/humanoid/M)
	switch(M.a_intent)
		if(I_HELP)
			visible_message("<span class='notice'>[M] caresses [src]'s plating with its scythe like arm.</span>")

		else //harm
			if(M.unarmed_attack_mob(src))
				if(prob(8))
					flash_eyes(visual = TRUE, type = /obj/abstract/screen/fullscreen/flash/noise)

/mob/living/silicon/ai/attack_animal(mob/living/simple_animal/M as mob)
	M.unarmed_attack_mob(src)

/mob/living/silicon/ai/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswrench(W))
		if(anchored)
			user.visible_message("<span class='notice'>\The [user] starts to unbolt \the [src] from the plating...</span>")
			if(!do_after(user, src,40))
				user.visible_message("<span class='notice'>\The [user] decides not to unbolt \the [src].</span>")
				return
			user.visible_message("<span class='notice'>\The [user] finishes unfastening \the [src]!</span>")
			anchored = FALSE
			return
		else
			user.visible_message("<span class='notice'>\The [user] starts to bolt \the [src] to the plating...</span>")
			if(!do_after(user, src,40))
				user.visible_message("<span class='notice'>\The [user] decides not to bolt \the [src].</span>")
				return
			user.visible_message("<span class='notice'>\The [user] finishes fastening down \the [src]!</span>")
			anchored = TRUE
			return
	else
		return ..()


/mob/living/silicon/ai/get_multitool(var/active_only=0)
	return aiMulti

/mob/living/silicon/ai/html_mob_check()
	return TRUE

/mob/living/silicon/ai/isTeleViewing(var/client_eye)
	return TRUE

/mob/living/silicon/ai/update_icon()
	if(stat == DEAD)
		if("[chosen_core_icon_state]-crash" in icon_states(src.icon,1))
			icon_state = "[chosen_core_icon_state]-crash"
		else
			icon_state = "ai-crash"
		return
	icon_state = chosen_core_icon_state

/mob/living/silicon/ai/Topic(href, href_list)
	if(usr != src)
		return
	..()
	if(href_list["mach_close"])
		if(href_list["mach_close"] == "aialerts")
			viewalerts = FALSE
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)
	if(href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"])) in cameranet.cameras
	if(href_list["showalerts"])
		ai_alerts()

	if(href_list["show_paper"])
		if(last_paper_seen)
			src << browse(last_paper_seen, "window=show_paper")
	//Carn: holopad requests
	if(href_list["jumptoholopad"])
		var/obj/machinery/hologram/holopad/H = locate(href_list["jumptoholopad"])
		if(stat == CONSCIOUS)
			if(H)
				H.attack_ai(src) //may as well recycle
			else
				to_chat(src, "<span class='notice'>Unable to locate the holopad.</span>")

	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return

	if(href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawc"])
		switch(lawcheck[L+1])
			if("Yes")
				lawcheck[L+1] = "No"
			if("No")
				lawcheck[L+1] = "Yes"
		checklaws()

	if(href_list["lawi"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawi"])
		switch(ioncheck[L])
			if("Yes")
				ioncheck[L] = "No"
			if("No")
				ioncheck[L] = "Yes"
		checklaws()

	if(href_list["laws"]) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()

	if(href_list["track"])
		var/mob/target = locate(href_list["track"]) in mob_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(A && target)
			A.ai_actual_track(target)
		return

	else if(href_list["faketrack"])
		var/mob/target = locate(href_list["track"]) in mob_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(A && target)

			A.cameraFollow = target
			to_chat(A, text("Now tracking [] on camera.", target.name))
			if(usr.machine == null)
				usr.machine = usr

			while (src.cameraFollow == target)
				to_chat(usr, "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb).")
				sleep(40)
				continue

		return

	if(href_list["open"])
		var/mob/target = locate(href_list["open"])
		var/mob/living/silicon/ai/A = locate(href_list["open2"])
		if(A && target)
			A.open_nearest_door(target)
		return