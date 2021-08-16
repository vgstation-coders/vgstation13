/obj/machinery/power/apc
	malf_hack_time = APC_HACK_TIME
	hack_abilities = list(
		/datum/malfhack_ability/toggle/apclock
	)

/obj/machinery/power/apc/malfhack_valid(var/mob/living/silicon/ai/malf)
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!istype(M) || !istype(malf))		
		to_chat(malf, "<span class='warning'>You are not a malfunctioning AI.</span>")
		return FALSE
	if(currently_hacking_ai && currently_hacking_ai != malf)
		to_chat(malf, "<span class='warning'>Another malfunctioning intelligence has started taking control of [src].</span>")	//there shouldnt be more than one malf anyway
		return FALSE
	if(malfai && malfai != malf)
		to_chat(malf, "<span class='warning'>Another malfunctioning intelligence has took control of [src].</span>")		//there shouldnt be more than one malf anyway
		return FALSE
	if(src in M.currently_hacking_apcs)
		to_chat(malf, "<span class='warning'>You are already taking control of the [src].</span>")
		return FALSE
	if(M.currently_hacking_apcs.len >= M.apc_hacklimit)
		to_chat(malf, "<span class='warning'>Your systems are not capable of hacking more than [M.apc_hacklimit] APCs at a time.</span>")
		return FALSE
	if(STATION_Z != z)
		to_chat(malf, "<span class='warning'>You cannot hack APCs off the main station.</span>")
		return FALSE
	return TRUE

/obj/machinery/power/apc/start_malfhack(var/mob/living/silicon/ai/malf)
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!istype(M) || !istype(malf))
		return
	to_chat(malf, "Beginning override of APC systems. This will take [malf_hack_time/10] seconds.")
	M.currently_hacking_apcs += src
	currently_hacking_ai = malf
	new /obj/effect/hack_overlay(null, malf, src)
	malf.handle_regular_hud_updates()
	return TRUE


/obj/machinery/power/apc/set_malf_owner(var/mob/living/silicon/ai/malf)
	if(!..())
		return
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!istype(M) || !istype(malf))
		return
	M.currently_hacking_apcs -= src
	malf_owner = malf
	to_chat(malf, "APC Hack Complete. The [name] is now under your exclusive control. You now have [M.apcs.len] APCs under your control.")
	malf.clear_alert(name)
	locked = TRUE
	malfhack = TRUE
	currently_hacking_ai = null
	malfai = malf
	M.apcs += src
	malf.handle_regular_hud_updates()
	update_icon()

/obj/machinery/power/apc/proc/clear_malf()
	malflocked = FALSE
	malfhack = FALSE
	malf_owner = null
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