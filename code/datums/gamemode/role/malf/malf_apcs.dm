/obj/machinery/power/apc/take_control(var/mob/living/silicon/ai/malf)
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!istype(malf) || !istype(M))
		return
	if(currently_hacking_ai && currently_hacking_ai != malf)
		to_chat(malf, "<span class='warning'>Another malfunctioning intelligence has started taking control of [src].</span>")
		return
	if(malfai && malfai != malf)
		to_chat(malf, "<span class='warning'>Another malfunctioning intelligence has took control of [src].</span>")
		return
	if(src in M.currently_hacking_apcs)
		to_chat(malf, "<span class='warning'>You are already taking control of the [src].</span>")
		return
	if(M.currently_hacking_apcs.len >= M.apc_hacklimit)
		to_chat(malf, "<span class='warning'>Your systems are not capable of hacking more than [M.apc_hacklimit] APCs at a time.</span>")
		return
	if(STATION_Z != z)
		to_chat(malf, "<span class='warning'>You cannot hack APCs off the main station.</span>")
		return

	to_chat(malf, "Beginning override of APC systems. This will take [APC_HACK_TIME/10] seconds.")
	M.currently_hacking_apcs += src
	currently_hacking_ai = malf
	var/obj/effect/hack_overlay/overlay = new /obj/effect/hack_overlay(null, malf, src)	//TODO, different looking overlay for APCS or other special machines
	malf.handle_regular_hud_updates()

	sleep(APC_HACK_TIME)
	overlay.set_icon("hacked")
	set_malf_owner(malf)


/obj/machinery/power/apc/proc/set_malf_owner(var/mob/living/silicon/ai/malf)
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!istype(malf) || !istype(M))
		return
	to_chat(malf, "Hack complete. The [name] is now under your exclusive control. You now have [M.apcs.len] APCs under your control.")
	malf.clear_alert(name)
	locked = TRUE
	malfhack = TRUE
	M.currently_hacking_apcs -= src
	currently_hacking_ai = null
	malfai = malf
	malf_owners += malf
	M.apcs += src
	malf.handle_regular_hud_updates()
	update_icon()

/obj/machinery/power/apc/proc/clear_malf()
	malflocked = FALSE
	malfhack = FALSE
	malf_owners = list()
	if(currently_hacking_ai)
		to_chat(currently_hacking_ai, "<span class='warning'>The [src] you were taking control of lost its connection to you!</span>")
		currently_hacking_ai.clear_alert(name)
		currently_hacking_ai = null
		currently_hacking_ai.handle_regular_hud_updates()
	if(malfai)
		to_chat(currently_hacking_ai, "<span class='warning'>You lost your connection to the [src]!</span>")
		var/datum/role/malfAI/M = malfai.mind.GetRole(MALF)
		M.apcs -= src
		malfai.handle_regular_hud_updates()
	update_icon()