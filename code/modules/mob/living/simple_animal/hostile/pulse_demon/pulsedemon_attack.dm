/mob/living/simple_animal/hostile/pulse_demon/ClickOn(var/atom/A, var/params)
	if(!spell_channeling) // Abort if we're doing spell stuff
		if(get_area(A) == controlling_area && istype(A,/obj/machinery/power/apc)) // Put this first to get back into APCs
			A.attack_pulsedemon(src)
		else if(current_weapon && !attack_delayer.blocked())
			if(istype(current_weapon,/obj/item/weapon/gun))
				var/obj/item/weapon/gun/G = current_weapon
				G.Fire(A,src) // Shoot at something if we're in a weapon
		else if(current_robot) // Do APC stuff if in a borg
			log_admin("[key_name(src)] made [key_name(current_robot)] attack [A]") // Just so admins don't bwoink them in confusion
			message_admins("<span class='notice'>[key_name(src)] made [key_name(current_robot)] attack [A]</span>")
			var/list/modifiers = params2list(params)
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

			if(!attack_delayer.blocked())
				A.attack_robot(current_robot)
				delayNextAttack(10)
		else if(current_bot && !attack_delayer.blocked()) // Do bot stuff
			current_bot.attack_integrated_pulsedemon(src,A)
			delayNextAttack(10)
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

// Proc that allows special pulse demon functionality when inside a bot
/atom/proc/attack_integrated_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user, var/atom/A)
	return

/obj/machinery/bot/secbot/attack_integrated_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user, var/atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/M = A
		if(Adjacent(M))
			playsound(src, 'sound/weapons/Egloves.ogg', 50, 1, -1)

			if (istype(M, /mob/living/carbon/human))
				if (M.stuttering < 10 && (!(M_HULK in M.mutations)))
					M.stuttering = 10
			else
				M.stuttering = 10
			M.Stun(10)
			M.Knockdown(10)
			playsound(src, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
			visible_message("<span class='danger'>[src] is trying to put handcuffs on [M]!</span>")
			if(do_after(user, M, 2 SECONDS))
				if (!istype(M))
					return
				if (M.handcuffed)
					return
				M.handcuffed = new /obj/item/weapon/handcuffs(M)
				M.update_inv_handcuffed()	//update handcuff overlays
				playsound(src, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0)
		else
			if(src.arrest_message == null)
				src.speak("Level [src.threatlevel] infraction alert!")
			else
				src.speak("[src.arrest_message]")
			playsound(src, pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50, 0)
			visible_message("<b>[src]</b> points at [M.name]!")

/obj/machinery/bot/ed209/attack_integrated_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user, var/atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/M = A
		if(Adjacent(M))
			playsound(src, 'sound/weapons/Egloves.ogg', 50, 1, -1)
			icon_state = "[lasercolor][icon_initial]-c"
			spawn(2)
				icon_state = "[lasercolor][icon_initial][on]"

			if (istype(M, /mob/living/carbon/human))
				if (M.stuttering < 10 && (!(M_HULK in M.mutations)))
					M.stuttering = 10
			else
				M.stuttering = 10
			M.Stun(10)
			M.Knockdown(10)
			playsound(src, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
			visible_message("<span class='danger'>[src] is trying to put handcuffs on [M]!</span>")
			if(do_after(user, M, 2 SECONDS))
				if (!istype(M))
					return
				if (M.handcuffed)
					return
				M.handcuffed = new /obj/item/weapon/handcuffs(M)
				M.update_inv_handcuffed()	//update handcuff overlays
		else
			shootAt(M)

/obj/machinery/bot/floorbot/attack_integrated_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user, var/atom/A)
	if(istype(A,/turf/simulated/floor) && Adjacent(A))
		var/turf/simulated/floor/F = A
		if(prob(99)) // Make the chance of below lower since player controlled and all
			F.break_tile_to_plating()
		else
			F.ReplaceWithLattice()
		visible_message("<span class='warning'>[src] makes an excited booping sound as it begins tearing apart \the [F].</span>")

/obj/machinery/bot/cleanbot/attack_integrated_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user, var/atom/A)
	if(istype(A,/turf/simulated/floor) && Adjacent(A))
		var/turf/simulated/floor/F = A
		if(prob(50))
			F.wet(800)
		if(prob(50))
			visible_message("<span class='warning'>Something flies out of \the [src]! He seems to be acting oddly.</span>")
			if(!(locate(/obj/effect/decal/cleanable/blood/gibs) in F))
				new /obj/effect/decal/cleanable/blood/gibs(F)

/obj/machinery/bot/mulebot/attack_integrated_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user, var/atom/A)
	if(istype(A) && Adjacent(A))
		if(ismovable(A))
			var/atom/movable/AM = A
			if(!AM.anchored)
				load(AM)
				if(is_locking(/datum/locking_category/mulebot))
					to_chat(user, "You load \the [AM] onto \the [src].")
					return
		var/atom/movable/load = is_locking(/datum/locking_category/mulebot) && get_locked(/datum/locking_category/mulebot)[1]
		if(load)
			to_chat(user, "You unload \the [load].")
			unload()

/obj/machinery/bot/medbot/attack_integrated_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user, var/atom/A)
	if (Adjacent(A) && iscarbon(A) && on)
		var/mob/living/carbon/C = A
		icon_state = "[icon_initial]s"
		visible_message("<span class='danger'>[src] is trying to inject [C]!</span>")
		if(do_after(user, C, INJECTION_TIME))
			C.reagents.add_reagent(TOXIN,injection_amount)
			visible_message("<span class='danger'>[src] injects [C] with the syringe!</span>")
			icon_state = "[icon_initial][on]"
		else
			icon_state = "[icon_initial][on]"

/obj/machinery/bot/bloodbot/attack_integrated_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user, var/atom/A)
	if(ishuman(A) && Adjacent(A) && on)
		var/mob/living/carbon/H = A
		if(prob(5))
			speak(pick("Blaah!","I vant to suck your blood!","I never drink... wine.","The blood is the life.","I must hunt soon!","I hunger!","Death rages.","The night beckons.","Mwa ha ha!"))
		drink(H)

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

// Lets you take over a weapon to fire
/obj/machinery/recharger/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
	user.loc = src
	if(charging)
		to_chat(user,"<span class='notice'>You are now attempting to hijack \the [charging], this will take approximately [user.takeover_time] seconds.</span>")
		if(do_after(user,charging,user.takeover_time*10))
			if(charging)
				to_chat(user,"<span class='notice'>You are now inside \the [charging].</span>")
				user.loc = charging
				user.current_weapon = charging
	else
		to_chat(user,"<span class='warning'>There is no weapon charging.</span>")

// Lets you take over a cell to rig, as if injected by plasma
/obj/machinery/cell_charger/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
	user.loc = src
	if(charging && !charging.rigged && !charging.occupant)
		to_chat(user,"<span class='notice'>You are now attempting to hijack \the [charging], this will take approximately [user.takeover_time] seconds.</span>")
		// Go in instantly if already rigged, else hijack timer
		if(!charging.rigged)
			if(do_after(user,src,user.takeover_time*10))
				to_chat(user,"<span class='notice'>You are now inside \the [charging].</span>")
				user.loc = charging
				charging.occupant = user
				charging.rigged = 1
		else
			to_chat(user,"<span class='notice'>You are now inside \the [charging].</span>")
			user.loc = charging
			charging.occupant = user
	else if(charging)
		to_chat(user,"<span class='warning'>There is already something in this cell.</span>")
	else
		to_chat(user,"<span class='warning'>There is no cell charging.</span>")

// Lets you take over a borg, to override its targeting and speech
/obj/machinery/recharge_station/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
	user.loc = src
	if(occupant && istype(occupant,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = occupant
		// Go in instantly if already compromised, else hijack timer
		if(!R.pulsecompromised)
			to_chat(user,"<span class='notice'>You are now attempting to hijack \the [R]'s targeting module, this will take approximately [user.takeover_time] seconds.</span>")
			to_chat(R,"<span class='danger'>ALERT: ELECTRICAL MALEVOLENCE DETECTED, TARGETING SYSTEMS HIJACK IN PROGRESS</span>")
			if(do_after(user,src,user.takeover_time*10))
				if(occupant)
					to_chat(user,"<span class='notice'>You are now inside \the [R], in control of its targeting.</span>")
					R.pulsecompromised = 1
					user.loc = R
					user.current_robot = R
					to_chat(R, "<span class='danger'>ERRORERRORERROR</span>")
					sleep(20)
					to_chat(R, "<span class='danger'>TARGETING SYSTEMS HIJACKED, REPORT ALL UNWANTED ACTIVITY IN VERBAL FORM</span>")
		else
			to_chat(user,"<span class='notice'>You are now inside \the [R], in control of its targeting.</span>")
			user.loc = R
			user.current_robot = R
	else
		to_chat(user,"<span class='warning'>There is no silicon-based occupant inside.</span>")

// Lets you take over a bot to move it around
/obj/machinery/bot/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
	if(user.loc != src)
		to_chat(user,"<span class='notice'>You are now inside \the [src]. If it is destroyed, you will instantly die.</span>")
		to_chat(user,"<span class='notice'>Leave it by jumping to a machine in \the [user.controlling_area].</span>")
		user.forceMove(src)
		user.current_bot = src
		PD_occupant = user
		if(!pAImove_delayer)
			pAImove_delayer = new(1, ARBITRARILY_LARGE_NUMBER)
		return TRUE
	return FALSE

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
