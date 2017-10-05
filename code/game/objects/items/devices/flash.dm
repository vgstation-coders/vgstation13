/obj/item/device/flash
	name = "flash"
	desc = "Used for blinding and being an asshole."
	icon_state = "flash"
	item_state = "flash"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/electronics.dmi', "right_hand" = 'icons/mob/in-hand/right/electronics.dmi')
	throwforce = 5
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = Tc_MAGNETS + "=2;" + Tc_COMBAT + "=1"
	min_harm_label = 15 //Multiple layers?
	harm_label_examine = list("<span class='info'>A label is on the bulb, but doesn't cover it.</span>", "<span class='warning'>A label covers the bulb!</span>")

	var/times_used = 0 //Number of times it's been used.
	var/broken = 0     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.
	var/limited_conversions = 0 // for revsquad

/obj/item/device/flash/proc/clown_check(var/mob/user)
	if(user && clumsy_check(user) && prob(50))
		to_chat(user, "<span class='warning'>\The [src] slips out of your hand.</span>")
		user.drop_item()
		return 0
	return 1

/obj/item/device/flash/proc/flash_recharge()
	//capacitor recharges over time
	for(var/i=0, i<3, i++)
		if(last_used+600 > world.time)
			break
		last_used += 600
		times_used -= 2
	last_used = world.time
	times_used = max(0,round(times_used)) //sanity


/obj/item/device/flash/attack(mob/living/M as mob, mob/user as mob)
	var/length
	if(!user || !M) //sanity
		return

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been flashed (attempt) with [src.name] by [key_name(user)]</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to flash [key_name(M)]</font>")

	log_attack("<font color='red'>[key_name(user)] Used the [src.name] to flash [key_name(M)]</font>")

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	if(!clown_check(user))
		return

	if(broken)
		to_chat(user, "<span class='warning'>\The [src] is broken.</span>")
		return

	flash_recharge()

	//spamming the flash before it's fully charged (60seconds) increases the chance of it  breaking
	//It will never break on the first use.
	switch(times_used)
		if(0 to 5)
			last_used = world.time
			if(prob(times_used))	//if you use it 5 times in a minute it has a 10% chance to break!
				broken = 1
				to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
				icon_state = "flashburnt"
				item_state = "flashburnt"
				return
			times_used++
		else	//can only use it  5 times a minute
			to_chat(user, "<span class='warning'>*click* *click*</span>")
			return

	playsound(get_turf(user), 'sound/weapons/flash.ogg', 100, 1)

	if(isrobot(user))
		spawn(0)
			var/atom/movable/overlay/animation = new(get_turf(user))
			animation.layer = user.layer + 1
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = user
			flick("blspell", animation)
			sleep(5)
			qdel(animation)

	var/flashfail = (harm_labeled >= min_harm_label) //Flashfail is always true if the device has been successfully harm-labeled.

	if(iscarbon(M))
		var/mob/living/carbon/Subject = M

		if(Subject.eyecheck() > 0)
			user.visible_message("<span class='notice'>[user] fails to blind [M] with the flash!</span>")
		else
			if(Subject.eyecheck() <= 0)
				Subject.Knockdown(Subject.eyecheck() * 5 * -1 +10)
			if(user.mind && isrevhead(user)) // alien revhead when?
				if(ishuman(Subject))
					if(Subject.stat != DEAD)
						Subject.mind_initialize() // give them a mind datum if they don't have one

						var/is_revsquad = istype(ticker.mode, /datum/game_mode/revsquad)
						if(!is_revsquad || (is_revsquad && limited_conversions))
							var/result = ticker.mode.add_revolutionary(Subject.mind)

							if(result == 1)
								log_admin("[key_name(user)] has converted [key_name(Subject)] to the revolution at [formatLocation(Subject.loc)]")
								Subject.mind.has_been_rev = TRUE
								if(is_revsquad)
									limited_conversions--
									if(limited_conversions <= 0)
										to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
										broken = 1
										icon_state = "flashburnt"
							else if(result == ADD_REVOLUTIONARY_FAIL_IS_COMMAND || Subject.mind.has_been_rev) // command positions or has been rev before (according to old code you cannot attempt to rev people that has been deconverted, can be remove)
								to_chat(user, "<span class='warning'>This mind seems resistant to the flash!</span>")
							else if(result == ADD_REVOLUTIONARY_FAIL_IS_JOBBANNED) // rev jobbanned
								to_chat(user, "<span class='warning'>This mind seems resistant to the flash! (OOC INFO: REVOLUTIONARY JOBBANNED)</span>")
							else if(result == ADD_REVOLUTIONARY_FAIL_IS_IMPLANTED) // loyalty implanted
								to_chat(user, "<span class='warning'>Something seems to be blocking the flash!</span>")
					else
						to_chat(user, "<span class='warning'>This mind is so vacant that it is not susceptible to influence!</span>")
	else if(issilicon(M))
		var/mob/living/silicon/R = M
		if(flashfail)
			user.visible_message("<span class='notice'>[user] fails to overload [R]'s sensors with the flash!</span>")
		else
			length = rand(5,10)
			R.Knockdown(length)
			R.flashed = 1
			R.flash_eyes(affect_silicon = 1)
			user.visible_message("<span class='warning'>[user] overloads [R]'s sensors with the flash!</span>")
			spawn(length SECONDS)
				if (R.flashed)
					R.flashed = 0
	else //simple_animal maybe?
		user.visible_message("<span class='notice'>[user] fails to blind [M] with the flash!</span>")

/obj/item/device/flash/attack_self(mob/living/carbon/user as mob, flag = 0, emp = 0)
	if(!user || !clown_check(user))
		return
	if(broken)
		user.show_message("<span class='warning'>The [src.name] is broken</span>", 2)
		return

	flash_recharge()

	//spamming the flash before it's fully charged (60seconds) increases the chance of it  breaking
	//It will never break on the first use.
	switch(times_used)
		if(0 to 5)
			if(prob(2*times_used))	//if you use it 5 times in a minute it has a 10% chance to break!
				broken = 1
				to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
				icon_state = "flashburnt"
				item_state = "flashburnt"
				return
			times_used++
		else	//can only use it  5 times a minute
			user.show_message("<span class='warning'>*click* *click*</span>", 2)
			return
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1)
	if(harm_labeled >= min_harm_label)
		return //Act as if the flash was activated except the useful part.
	flick("flash2", src)
	if(user && isrobot(user))
		spawn(0)
			var/atom/movable/overlay/animation = new(user.loc)
			animation.layer = user.layer + 1
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = user
			flick("blspell", animation)
			sleep(5)
			qdel(animation)
			animation = null

	for(var/mob/living/carbon/M in oviewers(3, null))
		if(prob(50))
			if (locate(/obj/item/weapon/cloaking_device, M))
				for(var/obj/item/weapon/cloaking_device/S in M)
					S.active = 0
					S.icon_state = "shield0"
		if(M.alpha < 255)
			var/oldalpha = M.alpha
			if(prob(80))
				M.alpha = 255
				M.visible_message("<span class='warning'>[M] suddenly becomes fully visible!</span>",\
								"<span class='warning'>You see a bright flash of light and are suddenly fully visible again.</span>")
				spawn(50)
					M.alpha = oldalpha
		var/safety = M:eyecheck()
		if(!safety)
			M.flash_eyes(affect_silicon = 1)

	return

/obj/item/device/flash/emp_act(severity)
	if(broken)
		return
	flash_recharge()
	switch(times_used)
		if(0 to 5)
			if(prob(2*times_used))
				broken = 1
				icon_state = "flashburnt"
				item_state = "flashburnt"
				return
			times_used++
			if(istype(loc, /mob/living/carbon) && harm_labeled < min_harm_label)
				var/mob/living/carbon/M = loc
				var/safety = M.eyecheck()
				if(safety <= 0)
					M.Knockdown(10)
					M.flash_eyes(visual = 1)
					for(var/mob/O in viewers(M, null))
						O.show_message("<span class='disarm'>[M] is blinded by the flash!</span>")
	..()

/obj/item/device/flash/restock()
	if(broken)
		broken = 0
		times_used = 0
		icon_state = "flash"
		item_state = "flash"

/obj/item/device/flash/synthetic
	name = "synthetic flash"
	desc = "When a problem arises, SCIENCE is the solution."
	icon_state = "sflash"
	origin_tech = Tc_MAGNETS + "=2;" + Tc_COMBAT + "=1"

/obj/item/device/flash/synthetic/attack(mob/living/M as mob, mob/user as mob)
	..()
	if(!broken)
		broken = 1
		to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
		icon_state = "flashburnt"
		item_state = "flashburnt"

/obj/item/device/flash/synthetic/attack_self(mob/living/carbon/user as mob, flag = 0, emp = 0)
	..()
	if(!broken)
		broken = 1
		to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
		icon_state = "flashburnt"
		item_state = "flashburnt"

/obj/item/device/flash/revsquad
	limited_conversions = REVSQUAD_FLASH_USES
	mech_flags = MECH_SCAN_FAIL
