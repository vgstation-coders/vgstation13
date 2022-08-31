/obj/machinery/power/apc
	malf_hack_time = APC_HACK_TIME
	hack_abilities = list(
		/datum/malfhack_ability/toggle/apclock,
		/datum/malfhack_ability/shunt
	)

/obj/machinery/power/apc/malfhack_valid(var/mob/living/silicon/malf)
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
	if(map.zMainStation != z)
		to_chat(malf, "<span class='warning'>You cannot hack APCs off the main station.</span>")
		return FALSE
	return TRUE

/obj/machinery/power/apc/start_malfhack(var/mob/living/silicon/ai/malf)
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!istype(M) || !istype(malf))
		return
	to_chat(malf, "<span class='notice'>Beginning override of APC systems. This will take [malf_hack_time/10] seconds.</span>")
	M.currently_hacking_apcs += src
	currently_hacking_ai = malf
	new /obj/effect/hack_overlay(null, malf, src)
	malf.handle_regular_hud_updates()
	return TRUE


/obj/machinery/power/apc/set_malf_owner(var/datum/role/malfAI/M)
	var/mob/living/silicon/ai/malf = M.antag.current
	if(!..())
		return
	if(!istype(M) || !istype(malf))
		return
	M.currently_hacking_apcs -= src
	malf_owner = M
	malf.clear_alert(name)
	locked = TRUE
	malfhack = TRUE
	currently_hacking_ai = null
	malfai = malf
	M.apcs += src
	to_chat(malf, "<span class='notice'>APC Hack Complete. The [name] is now under your exclusive control. You now have [M.apcs.len] APCs under your control.</span>")
	var/total_APC = 0
	for(var/obj/machinery/power/apc/A in M.apcs)
		total_APC++
	if(total_APC % 5 == 0 && !(total_APC in M.apc_checkpoints)) //Every 5 APCs hacked, increases the limit of APCs that can be hacked by 1
		M.apc_hacklimit++
		to_chat(malf, "<span class='good'>You may now hack an additional APC at a time, up to [M.apc_hacklimit].</span>")
		M.apc_checkpoints += total_APC //Remembers that this many APCs were hacked to avoid exploits
	malf.handle_regular_hud_updates()
	malfimage = new /atom/movable/fake_camera_image(loc)
	malfimage.pixel_y = pixel_y
	malfimage.pixel_x = pixel_x
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

/obj/machinery/power/apc/disable_AI_control(var/disrupt = TRUE)
	stat |= NOAICONTROL
	if(malf_owner && disrupt)
		to_chat(malf_owner.antag.current, "<span class='danger'>AI Control on [src] has been cut! It will fail to generate any power until AI control is restored.</span>")
		malf_disrupt(duration = MALF_DISRUPT_TIME, permanent = TRUE) // No fixing this yourself!

/obj/machinery/power/apc/enable_AI_control(var/bypass)
	stat &= ~NOAICONTROL
	malf_undisrupt()


/atom/movable/fake_camera_image
	name          = ""
	anchored      = TRUE
	icon = 'icons/obj/power.dmi'
	icon_state = "apcfake"
	plane = FAKE_CAMERA_PLANE
	mouse_opacity    = 0

/atom/movable/fake_camera_image/New(var/turf/loc, var/new_icon, var/new_icon_state)
	..()
	if(new_icon)
		icon = icon
	if(new_icon_state)
		icon_state = new_icon_state



/spell/aoe_turf/corereturn
	name = "Return to Core"
	panel = "Malfunction"
	charge_type = Sp_CHARGES
	charge_max = 1
	hud_state = "unshunt"

/spell/aoe_turf/corereturn/before_target(mob/user)
	if(istype(user.loc, /obj/machinery/power/apc))
		return FALSE
	else
		to_chat(user, "<span class='notice'>You are already in your Main Core.</span>")
		return TRUE

/spell/aoe_turf/corereturn/choose_targets(mob/user = usr)
	return list(user.loc)

/spell/aoe_turf/corereturn/cast(var/list/targets, mob/user)
	var/obj/machinery/power/apc/apc = targets[1]
	apc.malfvacate()
