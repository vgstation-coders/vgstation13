/mob/living/simple_animal/hostile/pulse_demon/ClickOn(var/atom/A, var/params)
	if(!spell_channeling) // Abort if we're doing spell stuff
		if(get_area(A) == controlling_area && istype(A,/obj/machinery/power/apc)) // Put this first to get back into APCs
			A.attack_pulsedemon(src)
		else if(get_area(A) == controlling_area) // Only in APC areas
			var/list/modifiers = params2list(params) // For doors and other AI stuff
			if(modifiers["middle"])
				if(modifiers["shift"])
					MiddleShiftClickOn(A)
					return
				else
					MiddleClickOn(A)
					return
			if(modifiers["shift"])
				ShiftClickOn(A)
				return
			if(modifiers["alt"]) // alt and alt-gr (rightalt)
				AltClickOn(A)
				return
			if(modifiers["ctrl"])
				CtrlClickOn(A)
				return
			A.attack_pulsedemon(src)
		else if(isliving(A))
			..()
	else
		spell_channeling.channeled_spell(A) // Handle spell stuff

// Do AI stuff for this
/mob/living/simple_animal/hostile/pulse_demon/ShiftClickOn(var/atom/A)
	if(get_area(A) == controlling_area)
		A.AIShiftClick(src)

/mob/living/simple_animal/hostile/pulse_demon/CtrlClickOn(var/atom/A)
	if(get_area(A) == controlling_area)
		A.AICtrlClick(src)

/mob/living/simple_animal/hostile/pulse_demon/AltClickOn(var/atom/A)
	if(get_area(A) == controlling_area)
		A.AIAltClick(src)

/mob/living/simple_animal/hostile/pulse_demon/MiddleShiftClickOn(var/atom/A)
	if(get_area(A) == controlling_area)
		A.AIMiddleShiftClick(src)

// Proc that allows special pulse demon functionality
/atom/proc/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
	return

// Most machinery just does normal AI attacks
/obj/machinery/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
	return attack_ai(user)

// Except cams, which block you from viewing them otherwise
/obj/machinery/computer/security/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
	return attack_hand(user)

// Lets you view from these, and inherit view properties like xray if any
/obj/machinery/camera/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
	user.forceMove(src.loc)
	to_chat(user, "<span class='notice'>You jump towards \the [src]. This allows you to see the area around you in better detail. To come back to the APC click the APC.</span>")
	user.change_sight(adding = vision_flags)

/obj/machinery/hologram/holopad/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
	if(user.loc != src.loc)
		user.forceMove(src.loc)
		to_chat(user, "<span class='notice'>You jump towards \the [src]. This allows you to communicate with others. To come back to the APC click the APC.</span>")
	else
		attack_hand(user)

// Talk ability handled elsewhere
/obj/item/device/radio/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
	//you can jump to station bounced radios too, not just wall intercoms
	if(user.loc != src.loc)
		user.forceMove(src.loc)
		to_chat(user, "<span class='notice'>You jump towards \the [src]. This allows you to communicate with others. To come back to the APC click the APC.</span>")
	else
		attack_ai(user)

// Lets you go back into the APC, and also removes cam stuff
/obj/machinery/power/apc/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
	if(user.loc != src.loc)
		user.forceMove(src.loc)
		if(user.current_bot)
			user.current_bot.PD_occupant = null
			if(user.current_bot.pAImove_delayer && !user.current_bot.integratedpai)
				QDEL_NULL(user.current_bot.pAImove_delayer)
		user.current_robot = null
		user.current_bot = null
		user.current_weapon = null
		user.change_sight(removing = SEE_TURFS | SEE_MOBS | SEE_OBJS)
	else
		attack_ai(user)
