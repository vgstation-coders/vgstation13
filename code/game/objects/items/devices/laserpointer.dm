/obj/item/device/laser_pointer
	name = "laser pointer"
	desc = "Don't shine it in your eyes!"
	icon = 'icons/obj/device.dmi'
	icon_state = "pointer"
	item_state = "pen"
	var/pointer_icon_state
	flags_1 = CONDUCT_1 | NOBLUDGEON_1
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=500, MAT_GLASS=500)
	w_class = WEIGHT_CLASS_SMALL
	var/turf/pointer_loc
	var/energy = 5
	var/max_energy = 5
	var/effectchance = 33
	var/recharging = 0
	var/recharge_locked = FALSE
	var/obj/item/stock_parts/micro_laser/diode //used for upgrading!


/obj/item/device/laser_pointer/red
	pointer_icon_state = "red_laser"
/obj/item/device/laser_pointer/green
	pointer_icon_state = "green_laser"
/obj/item/device/laser_pointer/blue
	pointer_icon_state = "blue_laser"
/obj/item/device/laser_pointer/purple
	pointer_icon_state = "purple_laser"

/obj/item/device/laser_pointer/New()
	..()
	diode = new(src)
	if(!pointer_icon_state)
		pointer_icon_state = pick("red_laser","green_laser","blue_laser","purple_laser")

/obj/item/device/laser_pointer/upgraded/New()
	..()
	diode = new /obj/item/stock_parts/micro_laser/ultra

/obj/item/device/laser_pointer/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/micro_laser))
		if(!diode)
			if(!user.transferItemToLoc(W, src))
				return
			diode = W
			to_chat(user, "<span class='notice'>You install a [diode.name] in [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] already has a diode installed.</span>")

	else if(istype(W, /obj/item/screwdriver))
		if(diode)
			to_chat(user, "<span class='notice'>You remove the [diode.name] from \the [src].</span>")
			diode.forceMove(drop_location())
			diode = null
	else
		return ..()

/obj/item/device/laser_pointer/afterattack(atom/target, mob/living/user, flag, params)
	laser_act(target, user, params)

/obj/item/device/laser_pointer/proc/laser_act(atom/target, mob/living/user, params)
	if( !(user in (viewers(7,target))) )
		return
	if (!diode)
		to_chat(user, "<span class='notice'>You point [src] at [target], but nothing happens!</span>")
		return
	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(user.has_trait(TRAIT_NOGUNS))
		to_chat(user, "<span class='warning'>Your fingers can't press the button!</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna.check_mutation(HULK))
			to_chat(user, "<span class='warning'>Your fingers can't press the button!</span>")
			return

	add_fingerprint(user)

	//nothing happens if the battery is drained
	if(recharge_locked)
		to_chat(user, "<span class='notice'>You point [src] at [target], but it's still charging.</span>")
		return

	var/outmsg
	var/turf/targloc = get_turf(target)

	//human/alien mobs
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(user.zone_selected == BODY_ZONE_PRECISE_EYES)
			add_logs(user, C, "shone in the eyes", src)

			var/severity = 1
			if(prob(33))
				severity = 2
			else if(prob(50))
				severity = 0

			//chance to actually hit the eyes depends on internal component
			if(prob(effectchance * diode.rating) && C.flash_act(severity))
				outmsg = "<span class='notice'>You blind [C] by shining [src] in their eyes.</span>"
			else
				outmsg = "<span class='warning'>You fail to blind [C] by shining [src] at their eyes!</span>"

	//robots
	else if(iscyborg(target))
		var/mob/living/silicon/S = target
		add_logs(user, S, "shone in the sensors", src)
		//chance to actually hit the eyes depends on internal component
		if(prob(effectchance * diode.rating))
			S.flash_act(affect_silicon = 1)
			S.Knockdown(rand(100,200))
			to_chat(S, "<span class='danger'>Your sensors were overloaded by a laser!</span>")
			outmsg = "<span class='notice'>You overload [S] by shining [src] at their sensors.</span>"
		else
			outmsg = "<span class='warning'>You fail to overload [S] by shining [src] at their sensors!</span>"

	//cameras
	else if(istype(target, /obj/machinery/camera))
		var/obj/machinery/camera/C = target
		if(prob(effectchance * diode.rating))
			C.emp_act(EMP_HEAVY)
			outmsg = "<span class='notice'>You hit the lens of [C] with [src], temporarily disabling the camera!</span>"
			add_logs(user, C, "EMPed", src)
		else
			outmsg = "<span class='warning'>You miss the lens of [C] with [src]!</span>"

	//catpeople
	for(var/mob/living/carbon/human/H in view(1,targloc))
		if(!iscatperson(H) || H.incapacitated() || H.eye_blind )
			continue
		if(!H.lying)
			H.setDir(get_dir(H,targloc)) // kitty always looks at the light
			if(prob(effectchance))
				H.visible_message("<span class='warning'>[H] makes a grab for the light!</span>","<span class='userdanger'>LIGHT!</span>")
				H.Move(targloc)
				add_logs(user, H, "moved with a laser pointer",src)
			else
				H.visible_message("<span class='notice'>[H] looks briefly distracted by the light.</span>","<span class = 'warning'> You're briefly tempted by the shiny light... </span>")
		else
			H.visible_message("<span class='notice'>[H] stares at the light</span>","<span class = 'warning'> You stare at the light... </span>")

	//cats!
	for(var/mob/living/simple_animal/pet/cat/C in view(1,targloc))
		if(prob(50))
			C.visible_message("<span class='notice'>[C] pounces on the light!</span>","<span class='warning'>LIGHT!</span>")
			C.Move(targloc)
			C.resting = TRUE
			C.update_canmove()
		else
			C.visible_message("<span class='notice'>[C] looks uninterested in your games.</span>","<span class='warning'>You spot [user] shining [src] at you. How insulting!</span>")

	//laser pointer image
	icon_state = "pointer_[pointer_icon_state]"
	var/image/I = image('icons/obj/projectiles.dmi',targloc,pointer_icon_state,10)
	var/list/click_params = params2list(params)
	if(click_params)
		if(click_params["icon-x"])
			I.pixel_x = (text2num(click_params["icon-x"]) - 16)
		if(click_params["icon-y"])
			I.pixel_y = (text2num(click_params["icon-y"]) - 16)
	else
		I.pixel_x = target.pixel_x + rand(-5,5)
		I.pixel_y = target.pixel_y + rand(-5,5)

	if(outmsg)
		to_chat(user, outmsg)
	else
		to_chat(user, "<span class='info'>You point [src] at [target].</span>")

	energy -= 1
	if(energy <= max_energy)
		if(!recharging)
			recharging = 1
			START_PROCESSING(SSobj, src)
		if(energy <= 0)
			to_chat(user, "<span class='warning'>[src]'s battery is overused, it needs time to recharge!</span>")
			recharge_locked = TRUE

	flick_overlay_view(I, targloc, 10)
	icon_state = "pointer"

/obj/item/device/laser_pointer/process()
	if(prob(20 - recharge_locked*5))
		energy += 1
		if(energy >= max_energy)
			energy = max_energy
			recharging = 0
			recharge_locked = FALSE
			..()
