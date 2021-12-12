

/* Tools!
 * Note: Multitools are /obj/item/device
 *
 * Contains:
 * 		Wrench
 * 		Screwdriver
 * 		Wirecutters
 * 		Welding Tool
 * 		Crowbar
 * 		Revolver Conversion Kit(made sense)
 *		Soldering Tool
 *		Fuel Can
 */

/obj/item/tool
	name = "tool"
	desc = "A tool."


/* Used for fancy tool subtypes that are faster or slower than the standard tool.
 * The value for the key "construct" (or Co_CON_SPEED) is the multiplier for construction delay.
 * The value for the key "deconstruct" (or Co_DECON_SPEED) is the multiplier for deconstruction delay, in case you hadn't guessed.
 * If one is zero, the tool cannot be used in that direction. If you want to adminbus an instant tool, use .0001 or something, not 0.
 * Don't set either to a negative number. It will probably break, though I'm not really sure in what way.
 * Since this is a variable of /atom, it can technically be applied to any item used in construction, as long as the construction is based on construction datums.
 * Yes, this allows for hyperspeed building stacks, but I wouldn't recommend that, as it doesn't carry over too well when stacks are merged or separated.
 * Might work for borg stack modules, though. Worth looking into.
 */
/atom/movable
	var/list/construction_delay_mult = null
	//Formatted as list(Co_CON_SPEED = value, Co_DECON_SPEED = value)

/*
 * Wrench
 */
/obj/item/tool/wrench
	name = "wrench"
	desc = "A wrench with common uses. Can be found in your hand."
	icon = 'icons/obj/items.dmi'
	icon_state = "wrench"
	hitsound = "sound/weapons/smash.ogg"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	force = 5.0
	throwforce = 7.0
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 150)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_MATERIALS + "=1;" + Tc_ENGINEERING + "=1"
	attack_verb = list("bashes", "batters", "bludgeons", "whacks")
	toolsounds = list('sound/items/Ratchet.ogg')

	crit_chance_melee = 2*CRIT_CHANCE_MELEE

/obj/item/tool/wrench/is_wrench(mob/user)
	return TRUE

/obj/item/tool/wrench/attackby(obj/item/weapon/W, mob/user)
	..()
	if(user.is_in_modules(src))
		return
	if(istype(W, /obj/item/weapon/handcuffs/cable) && !istype(src, /obj/item/tool/wrench/socket))
		to_chat(user, "<span class='notice'>You wrap the cable restraint around the top of the wrench.</span>")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/tool/wrench_wired/I = new (get_turf(user))
			user.put_in_hands(I)
		else
			new /obj/item/tool/wrench_wired(get_turf(src.loc))
		qdel(src)
		qdel(W)

//we inherit a lot from wrench, so we change very little
/obj/item/tool/wrench/socket
	name = "socket wrench"
	desc = "A wrench intended to be wrenchier than other wrenches. It's the wrenchiest."
	icon_state = "socket_wrench"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	w_class = W_CLASS_LARGE //big shit, to balance its power
	force = 15.0
	throwforce = 12.0

/obj/item/tool/wrench/socket/slime_act(primarytype, mob/user)
	..()
	if(primarytype == /mob/living/carbon/slime/bluespace)
		has_slime=1
		to_chat(user, "You shove the slime extract inside \the [src]'s head.")
		return TRUE

/*
 * Screwdriver
 */
/obj/item/tool/screwdriver
	name = "screwdriver"
	desc = "You can be totally screwy with this."
	icon = 'icons/obj/items.dmi'
	icon_state = "screwdriver"
	hitsound = 'sound/weapons/toolhit.ogg'
	flags = FPRINT
	siemens_coefficient = 1
	sharpness = 1
	sharpness_flags = SHARP_TIP
	slot_flags = SLOT_BELT
	force = 5.0
	w_class = W_CLASS_TINY
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	starting_materials = list(MAT_IRON = 75)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	attack_verb = list("stabs")
	toolsounds = list('sound/items/Screwdriver.ogg', 'sound/items/Screwdriver2.ogg')

/obj/item/tool/screwdriver/suicide_act(var/mob/living/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is stabbing the [src.name] into \his temple! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is stabbing the [src.name] into \his heart! It looks like \he's trying to commit suicide.</span>"))
	return(SUICIDE_ACT_BRUTELOSS)

/obj/item/tool/screwdriver/New()
	. = ..()

	switch(pick("red","blue","purple","brown","green","cyan","yellow"))
		if ("red")
			icon_state = "screwdriver2"
			item_state = "screwdriver"
		if ("blue")
			icon_state = "screwdriver"
			item_state = "screwdriver_blue"
		if ("purple")
			icon_state = "screwdriver3"
			item_state = "screwdriver_purple"
		if ("brown")
			icon_state = "screwdriver4"
			item_state = "screwdriver_brown"
		if ("green")
			icon_state = "screwdriver5"
			item_state = "screwdriver_green"
		if ("cyan")
			icon_state = "screwdriver6"
			item_state = "screwdriver_cyan"
		if ("yellow")
			icon_state = "screwdriver7"
			item_state = "screwdriver_yellow"

	if (prob(75))
		src.pixel_y = rand(0, 16) * PIXEL_MULTIPLIER

/obj/item/tool/screwdriver/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()
	if(can_operate(M, user, src))
		return ..()
	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != LIMB_HEAD)
		return ..()
	if(clumsy_check(user) && prob(50))
		M = user
	return eyestab(M,user)

/obj/item/tool/screwdriver/attackby(var/obj/O)
	if(istype(O, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = O
		var/mob/M = usr
		if(ishuman(M) && !M.restrained() && !M.stat && !M.paralysis && ! M.stunned)
			if(!istype(M.loc,/turf))
				return
			if(C.amount < 10)
				to_chat(usr, "<span class='warning'>You need at least 10 lengths to make a bolas wire!</span>")
				return
			var/obj/item/weapon/legcuffs/bolas/cable/B = new /obj/item/weapon/legcuffs/bolas/cable(usr.loc)
			qdel(src)
			B.icon_state = "cbolas_[C._color]"
			B.cable_color = C._color
			B.screw_state = item_state
			B.screw_istate = icon_state
			to_chat(M, "<span class='notice'>You wind some cable around the screwdriver handle to make a bolas wire.</span>")
			C.use(10)
		else
			to_chat(usr, "<span class='warning'>You cannot do that.</span>")
	else
		..()

/obj/item/tool/screwdriver/is_screwdriver(var/mob/user)
	return TRUE
/*
 * Wirecutters
 */
/obj/item/tool/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon = 'icons/obj/items.dmi'
	icon_state = "cutters"
	hitsound = 'sound/weapons/toolhit.ogg'
	flags = FPRINT
	siemens_coefficient = 1
	sharpness = 1
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	slot_flags = SLOT_BELT
	force = 6.0
	throw_speed = 2
	throw_range = 9
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 80)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_MATERIALS + "=1;" + Tc_ENGINEERING + "=1"
	attack_verb = list("pinches", "nips at")
	toolsounds = list('sound/items/Wirecutter.ogg')

/obj/item/tool/wirecutters/is_wirecutter(mob/user)
	return TRUE

/obj/item/tool/wirecutters/New()
	. = ..()

	if(prob(50))
		icon_state = "cutters-y"
		item_state = "cutters_yellow"

/obj/item/tool/wirecutters/attack(mob/living/carbon/C as mob, mob/user as mob)
	if((iscarbon(C)) && (C.handcuffed) && (istype(C.handcuffed, /obj/item/weapon/handcuffs/cable)) && user.a_intent!=I_HURT)
		usr.visible_message("\The [user] cuts \the [C]'s [C.handcuffed.name] with \the [src]!",\
		"You cut \the [C]'s [C.handcuffed.name] with \the [src]!",\
		"You hear cable being cut.")
		qdel(C.handcuffed)
		return
	else
		..()

/obj/item/tool/wirecutters/scissors
	name = "scissors"
	desc = "This cuts paper."
	icon_state = "scissors"

/obj/item/tool/wirecutters/scissors/New()
	. = ..()
	icon_state = "scissors"
/*
 * Welding Tool
 */
/obj/item/tool/weldingtool
	name = "welding tool"
	desc = "Ensure the switch is safely in the off position before refueling."
	icon = 'icons/obj/items.dmi'
	icon_state = "welder"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	hitsound = 'sound/weapons/toolhit.ogg'
	flags = FPRINT | OPENCONTAINER
	siemens_coefficient = 1
	slot_flags = SLOT_BELT

	//Amount of OUCH when it's thrown
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	sharpness = 0.8
	sharpness_flags = INSULATED_EDGE | HOT_EDGE // A gas flame is pretty insulated, is it?
	heat_production = 3800
	source_temperature = TEMPERATURE_WELDER
	light_color = LIGHT_COLOR_FIRE
	light_type = LIGHT_SOFT_FLICKER

	//Cost to make in the autolathe
	starting_materials = list(MAT_IRON = 70, MAT_GLASS = 30)
	w_type = RECYK_MISC
	melt_temperature = MELTPOINT_PLASTIC

	//R&D tech level
	origin_tech = Tc_ENGINEERING + "=1"

	//Welding tool specific stuff
	var/welding = 0 	//Whether or not the welding tool is off(0) or on(1)
	var/status = 1 		//Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower)
	var/max_fuel = 20 	//The max amount of fuel the welder can hold
	var/start_fueled = 1 //Explicit, should the welder start with fuel in it ?
	var/eye_damaging = TRUE	//Whether the welder damages unprotected eyes.
	var/weld_speed = 1 //How much faster this welder is at welding. Higher number = faster
	toolsounds = list('sound/items/Welder.ogg', 'sound/items/Welder2.ogg')

/obj/item/tool/weldingtool/New()
	. = ..()
	create_reagents(max_fuel)
	if(start_fueled)
		reagents.add_reagent(FUEL, max_fuel)

/obj/item/tool/weldingtool/examine(mob/user)
	..()
	if (!status)
		to_chat(user, "<span class='notice'>The welder is unsecured.</span>")
	to_chat(user, "It contains [get_fuel()]/[src.max_fuel] units of fuel!")

/obj/item/tool/weldingtool/attackby(obj/item/W as obj, mob/user as mob)
	if(user.is_in_modules(src))
		return
	if(istype(W,/obj/item/tool/screwdriver))
		if(welding)
			to_chat(user, "<span class='warning'>Stop welding first!</span>")
			return
		status = !status
		if(status)
			to_chat(user, "<span class='notice'>You resecure the welder.</span>")
		else
			to_chat(user, "<span class='notice'>The welder can now be attached and modified.</span>")
		src.add_fingerprint(user)
		return
	if((!status) && (istype(W,/obj/item/stack/rods)))
		var/obj/item/stack/rods/R = W
		R.use(1)
		var/obj/item/weapon/gun/projectile/flamethrower/F = new/obj/item/weapon/gun/projectile/flamethrower(user.loc)
		src.forceMove(F)
		F.weldtool = src
		if (user.client)
			user.client.screen -= src
		user.u_equip(src,0)
		src.master = F
		reset_plane_and_layer()
		user.u_equip(src,0)
		if (user.client)
			user.client.screen -= src
		src.forceMove(F)
		src.add_fingerprint(user)
		return
	..()

/obj/item/tool/weldingtool/proc/do_weld(var/mob/user, var/atom/thing, var/time, var/fuel_cost)
	if(!remove_fuel(fuel_cost, user))
		return 0
	playtoolsound(src, 50)
	return isOn() && do_after(user, thing, time/weld_speed) && isOn() //Checks if it's on, then does the do_after, then checks if it's still on after.

/obj/item/tool/weldingtool/process()
	switch(welding)
		//If off
		if(0)
			if(icon_state != "welder") //Check that the sprite is correct, if it isnt, it means toggle() was not called
				force = 3
				sharpness = 0
				sharpness_flags = 0
				damtype = "brute"
				heat_production = 0
				source_temperature = 0
				update_icon()
				hitsound = "sound/weapons/toolhit.ogg"
				welding = 0
			processing_objects.Remove(src)
			return
		//Welders left on now use up fuel, but lets not have them run out quite that fast
		if(1)
			if(icon_state != "welder1") //Check that the sprite is correct, if it isnt, it means toggle() was not called
				force = 15
				sharpness = 0.8
				sharpness_flags = INSULATED_EDGE | HOT_EDGE
				damtype = "fire"
				heat_production = 3800
				source_temperature = TEMPERATURE_WELDER
				update_icon()
				hitsound = "sound/weapons/welderattack.ogg"
			if(prob(5))
				remove_fuel(1)

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.is_holding_item(src))
			location = get_turf(M)
	if (istype(location, /turf) && welding)
		location.hotspot_expose(source_temperature, 5,surfaces=istype(loc,/turf))

/obj/item/tool/weldingtool/attack(mob/M as mob, mob/user as mob)
	if(hasorgans(M))
		if(can_operate(M, user, src))
			if(do_surgery(M, user, src))
				return
		var/datum/organ/external/S = M:organs_by_name[user.zone_sel.selecting]
		if (!S)
			return
		if(!(S.status & ORGAN_ROBOT) || user.a_intent != I_HELP)
			return ..()
		if(S.brute_dam)
			if (!src.welding)
				to_chat(user, "<span class='notice'>You press \the unlit [src] against [user == M ? "your" : "[M]'s"] [S.display_name], but nothing happens.</span>")
				return
			if(remove_fuel(1, user))
				S.heal_damage(15,0,0,1)
				if(user != M)
					user.visible_message("<span class='attack'>\The [user] patches some dents on \the [M]'s [S.display_name] with \the [src]</span>",\
					"<span class='attack'>You patch some dents on \the [M]'s [S.display_name]</span>",\
					"You hear a welder.")
				else
					user.visible_message("<span class='attack'>\The [user] patches some dents on their [S.display_name] with \the [src]</span>",\
					"<span class='attack'>You patch some dents on your [S.display_name]</span>",\
					"You hear a welder.")
		else
			to_chat(user, "Nothing to fix!")
	else
		return ..()

/obj/item/tool/weldingtool/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity)
		return
	if (istype(A, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,A) <= 1 && !src.welding)
		if(A.reagents.trans_to(src, max_fuel))
			to_chat(user, "<span class='notice'>Welder refueled.</span>")
			playsound(src, 'sound/effects/refill.ogg', 50, 1, -6)
		else if(!A.reagents)
			to_chat(user, "<span class='notice'>\The [A] is empty.</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] is already full.</span>")
		return
	else if (istype(A, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,A) <= 1 && src.welding)
		message_admins("[key_name_admin(user)] triggered a fueltank explosion.")
		log_game("[key_name(user)] triggered a fueltank explosion.")
		to_chat(user, "<span class='warning'>That was stupid of you.</span>")
		var/obj/structure/reagent_dispensers/fueltank/tank = A
		tank.explode()
		return
	if (src.welding)
		if(isliving(A))
			var/mob/living/L = A
			L.IgniteMob()
			remove_fuel(1)

/obj/item/tool/weldingtool/attack_self(mob/user as mob)
	toggle(user)

//Returns the amount of fuel in the welder
/obj/item/tool/weldingtool/proc/get_fuel()
	return reagents.get_reagent_amount(FUEL)


//Removes fuel from the welding tool. If a mob is passed, it will perform an eyecheck on the mob. This should probably be renamed to use()
/obj/item/tool/weldingtool/proc/remove_fuel(var/amount = 1, var/mob/M = null)
	if(!get_fuel())
		if(M) //First and foremost make sure there is enough fuel
			to_chat(M, "<span class='notice'>You need more welding fuel to complete this task.</span>")
		return 0
	if(!welding)
		if(M)
			to_chat(M, "<span class='notice'>Your welding tool has to be lit first.</span>")
		return 0
	if(get_fuel() >= amount)
		reagents.remove_reagent(FUEL, amount)
		check_fuel()
		if(M)
			eyecheck(M)
		return 1

//Returns whether or not the welding tool is currently on.
/obj/item/tool/weldingtool/proc/isOn()
	return src.welding


/obj/item/tool/weldingtool/is_hot()
	if(isOn())
		return source_temperature
	return 0


/obj/item/tool/weldingtool/is_sharp()
	if(isOn())
		return sharpness
	return 0

//Sets the welding state of the welding tool. If you see W.welding = 1 anywhere, please change it to W.setWelding(1)
//so that the welding tool updates accordingly
/obj/item/tool/weldingtool/proc/setWelding(var/temp_welding)
	//If we're turning it on
	if(temp_welding > 0)
		src.welding = 1
		if (remove_fuel(1))
			to_chat(usr, "<span class='notice'>\The [src] switches on.</span>")
			playsound(src,pick('sound/items/lighter1.ogg','sound/items/lighter2.ogg'),40,1)
			set_light(2)
			src.force = 15
			src.damtype = "fire"
			update_icon()
			processing_objects.Add(src)
		else
			to_chat(usr, "<span class='notice'>Need more fuel!</span>")
			src.welding = 0
			return
	//Otherwise
	else
		to_chat(usr, "<span class='notice'>\The [src] switches off.</span>")
		playsound(src,'sound/effects/zzzt.ogg',20,1)
		kill_light()
		src.force = 3
		src.damtype = "brute"
		update_icon()
		src.welding = 0

//Turns off the welder if there is no more fuel (does this really need to be its own proc?)
/obj/item/tool/weldingtool/proc/check_fuel()
	if((get_fuel() <= 0) && welding)
		toggle()
		return 0
	return 1


//Toggles the welder off and on
/obj/item/tool/weldingtool/proc/toggle(var/mob/user)
	if(!status)
		to_chat(user, "<span class='notice'>You need to secure the [src] first.</span>")
		return
	src.welding = !( src.welding )
	if (src.welding)
		if (remove_fuel(1))
			if(user && istype(user))
				to_chat(user, "<span class='notice'>You switch the [src] on.</span>")
			playsound(src,pick('sound/items/lighter1.ogg','sound/items/lighter2.ogg'),40,1)
			set_light(2)
			src.force = 15
			src.damtype = "fire"
			update_icon()
			processing_objects.Add(src)
		else
			if(user && istype(user))
				to_chat(user, "<span class='notice'>Need more fuel!</span>")
			src.welding = 0
			return
	else
		if(user && istype(user))
			to_chat(usr, "<span class='notice'>You switch the [src] off.</span>")
		else
			visible_message("<span class='notice'>\The [src] shuts off!</span>")
		playsound(src,'sound/effects/zzzt.ogg',20,1)
		kill_light()
		src.force = 3
		src.damtype = "brute"
		update_icon()
		src.welding = 0

//Decides whether or not to damage a player's eyes based on what they're wearing as protection
//Note: This should probably be moved to mob
/obj/item/tool/weldingtool/proc/eyecheck(mob/user as mob)
	if(!iscarbon(user))
		return 1
	var/mob/living/carbon/C = user //eyecheck is living-level
	var/safety = C.eyecheck()
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
		if(!E)
			return
		if(E.welding_proof)
			user.simple_message("<span class='notice'>Your eyelenses darken to accommodate for the welder's glow.</span>")
			return
		if(safety < 2 && eye_damaging && !(user.sdisabilities & BLIND))
			switch(safety)
				if(1)
					user.simple_message("<span class='warning'>Your eyes sting a little.</span>",\
						"<span class='warning'>You shed a tear.</span>")
					E.damage += rand(1, 2)
					if(E.damage > 12)
						user.eye_blurry += rand(3,6)
				if(0)
					user.simple_message("<span class='warning'>Your eyes burn.</span>",\
						"<span class='warning'>Some tears fall down from your eyes.</span>")
					E.damage += rand(2, 4)
					if(E.damage > 10)
						E.damage += rand(4,10)
				if(-1)
					var/obj/item/clothing/to_blame = H.head //blame the hat
					if(!to_blame || (istype(to_blame) && H.glasses && H.glasses.eyeprot < to_blame.eyeprot)) //if we don't have a hat, the issue is the glasses. Otherwise, if the glasses are worse, blame the glasses
						to_blame = H.glasses
					user.simple_message("<span class='warning'>Your [to_blame] intensifies the welder's glow. Your eyes itch and burn severely.</span>",\
						"<span class='warning'>Somebody's cutting onions.</span>")
					user.eye_blurry += rand(12,20)
					E.damage += rand(12, 16)
			if(E.damage > 10 && safety < 2)
				user.simple_message("<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>",\
					"<span class='warning'>This is too sad! You start to cry.</span>")
			if (E.damage >= E.min_broken_damage)
				user.simple_message("<span class='warning'>You go blind!</span>","<span class='warning'>Somebody turns the lights off.</span>")
				user.sdisabilities |= BLIND
			else if (E.damage >= E.min_bruised_damage)
				user.simple_message("<span class='warning'>You go blind!</span>","<span class='warning'>Somebody turns the lights off.</span>")
				user.eye_blind = 5
				user.eye_blurry = 5
				user.disabilities |= NEARSIGHTED
				spawn(100)
					user.disabilities &= ~NEARSIGHTED

/obj/item/tool/weldingtool/update_icon()
	..()
	icon_state = "[initial(icon_state)][welding ? "1" : ""]" //Ternary operator.

/obj/item/tool/weldingtool/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"welding",
		"status")

	reset_vars_after_duration(resettable_vars, duration)


/obj/item/tool/weldingtool/empty
	start_fueled = 0

/obj/item/tool/weldingtool/largetank
	name = "industrial welding tool"
	desc = "The cutting edge between portability and tank size."
	icon_state = "welder_large"
	max_fuel = 40
	starting_materials = list(MAT_IRON = 70, MAT_GLASS = 60)
	origin_tech = Tc_ENGINEERING + "=2"

/obj/item/tool/weldingtool/largetank/empty
	start_fueled = 0

/obj/item/tool/weldingtool/hugetank
	name = "upgraded welding tool"
	desc = "A large tank for a large job."
	icon_state = "welder_larger"
	max_fuel = 80
	w_class = W_CLASS_MEDIUM
	starting_materials = list(MAT_IRON = 70, MAT_GLASS = 120)
	origin_tech = Tc_ENGINEERING + "=3"

/obj/item/tool/weldingtool/hugetank/empty
	start_fueled = 0

/obj/item/tool/weldingtool/hugetank/mech
	name = "welding tool"
	eye_damaging = FALSE

/obj/item/tool/weldingtool/gatling
	name = "gatling welder"
	desc = "Engineering Dakka."
	icon_state = "welder_gatling"
	max_fuel = 160
	weld_speed = 2
	w_class = W_CLASS_LARGE
	starting_materials = list(MAT_IRON = 18750, MAT_GLASS = 18750)
	origin_tech = Tc_ENGINEERING + "=4"

/obj/item/tool/weldingtool/gatling/empty
	start_fueled = 0


/obj/item/tool/weldingtool/experimental
	name = "experimental welding tool"
	max_fuel = 40
	w_class = W_CLASS_MEDIUM
	starting_materials = list(MAT_IRON = 70, MAT_GLASS = 120)
	origin_tech = Tc_ENGINEERING + "=4;" + Tc_PLASMATECH + "=3"
	icon_state = "ewelder"
	weld_speed = 1.25
	var/last_gen = 0

/obj/item/tool/weldingtool/experimental/empty
	start_fueled = 0

/obj/item/tool/weldingtool/experimental/process()
	..()
	reagents.add_reagent(FUEL, 5)

/**
/obj/item/tool/weldingtool/experimental/proc/fuel_gen()//Proc to make the experimental welder generate fuel, optimized as fuck -Sieve
	var/gen_amount = ((world.time-last_gen)/25)          //Too bad it's not actually implemented
	reagents += (gen_amount)
	if(reagents > max_fuel)
		reagents = max_fuel
**/

/*
 * Crowbar
 */

/obj/item/tool/crowbar
	name = "crowbar"
	desc = "Used to hit floors."
	icon = 'icons/obj/items.dmi'
	icon_state = "crowbar"
	hitsound = "sound/weapons/toolhit.ogg"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	force = 5.0
	throwforce = 7.0
	item_state = "crowbar"
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 50)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_ENGINEERING + "=1"
	attack_verb = list("attacks", "bashes", "batters", "bludgeons", "whacks")
	toolsounds = list('sound/items/Crowbar.ogg')

/obj/item/tool/crowbar/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is smashing \his head in with the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (SUICIDE_ACT_BRUTELOSS)

/obj/item/tool/crowbar/red
	desc = "Rise and shine."
	icon = 'icons/obj/items.dmi'
	icon_state = "red_crowbar"
	item_state = "crowbar_red"
	miss_sound = "sounds/weapons/cbar_miss1.ogg"
	hitsound = "crowbar_hitbod"

/obj/item/tool/crowbar/red/New()
	..()
	if(Holiday == APRIL_FOOLS_DAY)
		attack_delay = 2 // Speed of the original
		force = 1.0 // To compensate

/obj/item/tool/crowbar/red/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is smashing \his head in with the [src.name]! It looks like \he's done waiting for half life three!</span>")
	playsound(get_turf(src), 'sound/medbot/Flatline_custom.ogg', 35)
	return (SUICIDE_ACT_BRUTELOSS)


/obj/item/weapon/conversion_kit
	name = "\improper Revolver Conversion Kit"
	desc = "A professional conversion kit used to convert any knock off revolver into the real deal capable of shooting lethal .357 rounds without the possibility of catastrophic failure."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "kit"
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_SMALL
	w_type = RECYK_MISC
	origin_tech = Tc_COMBAT + "=2"
	var/open = 0

/obj/item/weapon/conversion_kit/New()
	..()
	update_icon()

/obj/item/weapon/conversion_kit/update_icon()
	icon_state = "[initial(icon_state)]_[open]"

/obj/item/weapon/conversion_kit/attack_self(mob/user as mob)
	open = !open
	to_chat(user, "<span class='notice'>You [open?"open" : "close"] the conversion kit.</span>")
	update_icon()

/*
 * Soldering Iron
 */
/obj/item/tool/solder
	name = "soldering iron"
	icon = 'icons/obj/items.dmi'
	icon_state = "solder-0"
	hitsound = 'sound/weapons/toolhit.ogg'
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	force = 3.0
	sharpness = 1
	sharpness_flags = SHARP_TIP | HOT_EDGE
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 70, MAT_GLASS = 30)
	w_type = RECYK_MISC
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_ENGINEERING + "=1"
	var/max_fuel = 20 	//The max amount of acid stored
	toolsounds = list('sound/items/Welder.ogg')

/obj/item/tool/solder/New()
	. = ..()
	create_reagents(max_fuel)
	//Does not come fueled up

/obj/item/tool/solder/update_icon()
	..()
	switch(reagents.get_reagent_amount(SACID) + reagents.get_reagent_amount(FORMIC_ACID))
		if(16 to INFINITY)
			icon_state = "solder-20"
		if(11 to 15)
			icon_state = "solder-15"
		if(6 to 10)
			icon_state = "solder-10"
		if(1 to 5)
			icon_state = "solder-5"
		if(0)
			icon_state = "solder-0"

/obj/item/tool/solder/examine(mob/user)
	..()
	to_chat(user, "It contains [reagents.get_reagent_amount(SACID) + reagents.get_reagent_amount(FORMIC_ACID)]/[src.max_fuel] units of fuel!")

/obj/item/tool/solder/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/) && W.flags & OPENCONTAINER)
		var/obj/item/weapon/reagent_containers/G = W
		if(G.reagents.reagent_list.len>1)
			user.simple_message("<span class='warning'>The mixture is rejected by the tool.</span>",
				"<span class='warning'>The tool isn't THAT thirsty.</span>")
			return
		if(!G.reagents.has_any_reagents(SACIDS, 1))
			user.simple_message("<span class='warning'>The tool is not compatible with that.</span>",
				"<span class='warning'>The tool won't drink that.</span>")
			return
		else
			var/space = max_fuel - reagents.total_volume
			if(!space)
				user.simple_message("<span class='warning'>The tool is full!</span>",
					"<span class='warning'>The tool isn't thirsty.</span>")
				return
			var/transfer_amount = min(G.amount_per_transfer_from_this,space)
			user.simple_message("<span class='info'>You transfer [transfer_amount] units to the [src].</span>",
				"<span class='info'>The tool gulps down your drink!</span>")
			if(G.reagents.has_reagent(SACID, 1))
				G.reagents.trans_id_to(src,SACID,transfer_amount)
			else
				G.reagents.trans_id_to(src,FORMIC_ACID,transfer_amount)
			update_icon()
	else
		return ..()

/obj/item/tool/solder/proc/remove_fuel(var/amount, mob/user as mob)
	if(reagents.get_reagent_amount(SACID) + reagents.get_reagent_amount(FORMIC_ACID) >= amount)
		var/facid_amount = amount - reagents.get_reagent_amount(SACID)
		reagents.remove_reagent(SACID, amount)
		if(facid_amount > 0)
			reagents.remove_reagent(FORMIC_ACID, facid_amount)
		update_icon()
		return 1
	else
		user.simple_message("<span class='warn'>The tool does not have enough acid!</span>",
			"<span class='warn'>The tool is too thirsty!</span>")
		return 0

/obj/item/tool/solder/pre_fueled/New()
	. = ..()
	reagents.add_reagent(SACID, 50)
	update_icon()

/*
* Fuel Can
* A special, large container that fits on the belt
*/
/obj/item/weapon/reagent_containers/glass/fuelcan
	name = "fuel can"
	desc = "A special container named Furst in its class by engineers. It has partitioned containment to allow engineers to separate different chemicals, such as welding fuel, sulphuric acid, or water. It also bears a clip to fit on a standard toolbelt."
	icon = 'icons/obj/items.dmi'
	icon_state = "fueljar0"
	starting_materials = list(MAT_IRON = 500)
	volume = 50
	possible_transfer_amounts = list(5,10,20)
	var/slot = 0 //This dictates which side is open
	var/datum/reagents/slotzero = null
	var/datum/reagents/slotone = null

/obj/item/weapon/reagent_containers/glass/fuelcan/New()
	..()
	slotzero = reagents
	slotone = new/datum/reagents(volume)
	slotone.my_atom = src
	reagents.add_reagent(FUEL, 50)

/obj/item/weapon/reagent_containers/glass/fuelcan/attack_self(mob/user as mob)
	if(!slot)
		slotzero = reagents
		reagents = slotone
	else
		slotone = reagents
		reagents = slotzero
	slot = !slot
	update_icon()
	to_chat(user, "<span class='notice'>You switch the stopper to the other side.</span>")

/obj/item/weapon/reagent_containers/glass/fuelcan/examine(mob/user)
	..()
	to_chat(user, "The alternate partition contains:")
	var/datum/reagents/alternate = (slot ? slotzero : slotone)
	if(alternate.reagent_list.len) //Copied from atom/examine
		for(var/datum/reagent/R in alternate.reagent_list)
			to_chat(user, "<span class='info'>[R.volume] units of [R.name]</span>")
	else
		to_chat(user, "<span class='info'>Nothing.</span>")

/obj/item/weapon/reagent_containers/glass/fuelcan/update_icon()
	icon_state = "fueljar[slot]"
