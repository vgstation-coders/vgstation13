//Farmbots by GauHelldragon - 12/30/2012
// A new type of buildable aiBot that helps out in hydroponics

// Made by using a robot arm on a water tank and then adding:
// A plant analyzer, a bucket, a mini-hoe and then a proximity sensor (in that order)

// Will water, weed and fertilize plants that need it
// When emagged, it will WATER, "weed" and "fertilize" humans instead
// Holds up to 10 fertilizers (only the type dispensed by the machines, not chemistry bottles)
// It will fill up it's water tank at a sink when low.

// The behavior panel can be unlocked with hydroponics access and be modified to disable certain behaviors
// By default, it will ignore weeds and mushrooms, but can be set to tend to these types of plants as well.

//Seems a little stupid handling multiple Go direction X,Y,Z to do Job F,G,H if it's in multiple directions so I'd reccomend only enabling 1 water/fertilize/weed task at a time. - SarahJohnson


#define FARMBOT_MODE_WATER			1
#define FARMBOT_MODE_FERTILIZE	 	2
#define FARMBOT_MODE_WEED			3
#define FARMBOT_MODE_REFILL			4
#define FARMBOT_MODE_WAITING		5

#define FARMBOT_ANIMATION_TIME		25 //How long it takes to use one of the action animations
#define FARMBOT_EMAG_DELAY			60 //How long of a delay after doing one of the emagged attack actions
#define FARMBOT_ACTION_DELAY		35 //How long of a delay after doing one of the normal actions

/obj/machinery/bot/farmbot
	name = "Farmbot"
	desc = "The botanist's best friend."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "farmbot0"
	icon_initial = "farmbot"
	density = 1
	anchored = 0
	health = 50
	maxHealth = 50
	req_access =list(access_hydroponics)
	bot_flags = BOT_DENSE|BOT_NOT_CHASING

	var/Max_Fertilizers = 10

	var/setting_water = 1
	var/setting_refill = 1
	var/setting_fertilize = 1
	var/setting_weed = 1
	var/setting_ignoreEmpty = 0
	var/mode //Which mode is being used, 0 means it is looking for work

	var/obj/structure/reagent_dispensers/watertank/tank // the water tank that was used to make it, remains inside the bot.

/obj/machinery/bot/farmbot/vox_garden_farmbot
	name = "Special Vox Trader Farmbot"
	req_access = list()
	req_one_access =  list(access_hydroponics, access_trade)

/obj/machinery/bot/farmbot/New()
	..()
	src.icon_state = "[src.icon_initial][src.on]"
	src.botcard = new /obj/item/weapon/card/id(src)
	src.botcard.access = req_access

	if ( !tank ) //Should be set as part of making it... but lets check anyway
		tank = locate(/obj/structure/reagent_dispensers/watertank/) in contents
	if ( !tank ) //An admin must have spawned the farmbot! Better give it a tank.
		tank = new /obj/structure/reagent_dispensers/watertank(src)

/obj/machinery/bot/farmbot/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if (istype(mover,/mob/living/simple_animal/bee))
		return 1
	return ..()

/obj/machinery/bot/farmbot/turn_on()
	. = ..()
	src.icon_state = "[src.icon_initial][src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/farmbot/turn_off()
	..()
	src.path = list()
	src.icon_state = "[src.icon_initial][src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/farmbot/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/machinery/bot/farmbot/proc/get_total_ferts()
	var total_fert = 0
	for(var/obj/item/weapon/reagent_containers/glass/fert in contents)
		total_fert++
	return total_fert

/obj/machinery/bot/farmbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	var/dat
	dat += "<TT><B>Automatic Hydroponic Assisting Unit v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>"

	dat += "Water Tank: "
	if ( tank )
		dat += "\[[tank.reagents.total_volume]/[tank.reagents.maximum_volume]\]"
	else
		dat += "Error: Water Tank not Found"

	dat += "<br>Fertilizer Storage: <A href='?src=\ref[src];eject=1'>\[[get_total_ferts()]/[Max_Fertilizers]\]</a>"

	dat += "<br>Behaviour controls are [src.locked ? "locked" : "unlocked"]<hr>"
	if(!src.locked)
		dat += "<TT>Watering Controls:<br>"
		dat += " Water Plants : <A href='?src=\ref[src];water=1'>[src.setting_water ? "Yes" : "No"]</A><BR>"
		dat += " Refill Watertank : <A href='?src=\ref[src];refill=1'>[src.setting_refill ? "Yes" : "No"]</A><BR>"
		dat += "<br>Fertilizer Controls:<br>"
		dat += " Fertilize Plants : <A href='?src=\ref[src];fertilize=1'>[src.setting_fertilize ? "Yes" : "No"]</A><BR>"
		dat += "<br>Weeding Controls:<br>"
		dat += " Weed Plants : <A href='?src=\ref[src];weed=1'>[src.setting_weed ? "Yes" : "No"]</A><BR>"
		dat += "Ignore Empty Trays : <A href='?src=\ref[src];ignoreEmpty=1'>[src.setting_ignoreEmpty ? "Yes" : "No"]</A><BR>"
		dat += "</TT>"

	user << browse("<HEAD><TITLE>Farmbot v1.0 controls</TITLE></HEAD>[dat]", "window=autofarm")
	onclose(user, "autofarm")
	return

/obj/machinery/bot/farmbot/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if ((href_list["power"]) && (src.allowed(usr)))
		if (src.on)
			turn_off()
		else
			turn_on()

	else if((href_list[WATER]) && (!src.locked))
		setting_water = !setting_water
	else if((href_list["refill"]) && (!src.locked))
		setting_refill = !setting_refill
	else if((href_list["fertilize"]) && (!src.locked))
		setting_fertilize = !setting_fertilize
	else if((href_list["weed"]) && (!src.locked))
		setting_weed = !setting_weed
	else if((href_list["ignoreEmpty"]) && (!src.locked))
		setting_ignoreEmpty = !setting_ignoreEmpty
	else if (href_list["eject"] )
		flick("[src.icon_initial]_hatch",src)
		for (var/obj/item/weapon/reagent_containers/glass/fert in contents)
			fert.forceMove(get_turf(src))

	src.updateUsrDialog()
	return

/obj/machinery/bot/farmbot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			src.locked = !src.locked
			to_chat(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
			src.updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

	else if (istype(W, /obj/item/weapon/reagent_containers/glass))
		if ( get_total_ferts() >= Max_Fertilizers )
			to_chat(user, "The fertilizer storage is full!")
			return
		if(user.drop_item(W, src))
			to_chat(user, "You insert [W].")
			flick("[src.icon_initial]_hatch",src)
			src.updateUsrDialog()
			return

	else
		..()

/obj/machinery/bot/farmbot/emag_act(mob/user as mob)
	..()
	if(user)
		to_chat(user, "<span class='warning'>You short out [src]'s plant identifier circuits.</span>")
	spawn(0)
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='danger'>[src] buzzes oddly!</span>", 1)
	flick("[src.icon_initial]_broke", src)
	src.emagged = 1
	src.on = 1
	src.icon_state = "[src.icon_initial][src.on]"
	target = null
	mode = FARMBOT_MODE_WAITING //Give the emagger a chance to get away! 15 seconds should be good.
	spawn(150)
		mode = 0


/obj/machinery/bot/farmbot/explode()
	src.on = 0
	visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/minihoe(Tsec)
	new /obj/item/weapon/reagent_containers/glass/bucket(Tsec)
	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/device/analyzer/plant_analyzer(Tsec)

	if ( tank )
		tank.forceMove(Tsec)

	for ( var/obj/item/weapon/reagent_containers/glass/fert in contents )
		if ( prob(50) )
			fert.forceMove(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	spark(src)
	qdel(src)
	return

/obj/machinery/bot/farmbot/can_path()
	return !mode

/obj/machinery/bot/farmbot/process_bot()
	//set background = 1

	if(!src.on)
		return

	if ( emagged && prob(1) )
		flick("[src.icon_initial]_broke", src)

	if ( mode == FARMBOT_MODE_WAITING )
		find_target()
		return

	if ( !mode || !target || !(target in view(7,src)) ) //Don't bother chasing down targets out of view

		mode = 0
		target = null
		if ( !find_target() )
			// Couldn't find a target, wait a while before trying again.
			mode = FARMBOT_MODE_WAITING
			spawn(100)
				mode = 0
			return

	if ( mode && target )
		if ( get_dist(target,src) <= 1 || ( emagged && mode == FARMBOT_MODE_FERTILIZE ) )
			path = list() // Kill our path
			// If we are in emagged fertilize mode, we throw the fertilizer, so distance doesn't matter
			frustration = 0
			use_farmbot_item()


/obj/machinery/bot/farmbot/proc/use_farmbot_item()
	if ( !target )
		mode = 0
		return 0

	if ( emagged && !ismob(target) ) // Humans are plants!
		mode = 0
		target = null
		return 0

	if ( !emagged && !istype(target,/obj/machinery/portable_atmospherics/hydroponics) && !istype(target,/obj/structure/sink) ) // Humans are not plants!
		mode = 0
		target = null
		return 0

	if ( mode == FARMBOT_MODE_FERTILIZE )
		//Find which fertilizer to use
		var/obj/item/weapon/reagent_containers/glass/fert
		for ( var/obj/item/weapon/reagent_containers/glass/nut in contents )
			fert = nut
			break
		if ( !fert )
			target = null
			mode = 0
			return
		fertilize(fert)

	if(mode == FARMBOT_MODE_WEED)
		weed()

	if(mode == FARMBOT_MODE_WATER)
		water()

	if(mode == FARMBOT_MODE_REFILL)
		refill()




/obj/machinery/bot/farmbot/target_selection()
	if ( emagged ) //Find a human and help them!
		for ( var/mob/living/carbon/human/human in view(7,src) )
			if (human.isDead())
				continue

			var list/options = list(FARMBOT_MODE_WEED)
			if ( get_total_ferts() )
				options.Add(FARMBOT_MODE_FERTILIZE)
			if ( tank && tank.reagents.total_volume >= 1 )
				options.Add(FARMBOT_MODE_WATER)
			mode = pick(options)
			target = human
			return mode
		return 0
	else
		if ( setting_refill && tank && tank.reagents.total_volume < 100 )
			for ( var/obj/structure/sink/source in view(7,src) )
				target = source
				mode = FARMBOT_MODE_REFILL
				return 1
		for ( var/obj/machinery/portable_atmospherics/hydroponics/tray in view(7,src) )
			var newMode = GetNeededMode(tray)
			if ( newMode )
				mode = newMode
				target = tray
				return 1
		return 0

/obj/machinery/bot/farmbot/proc/GetNeededMode(obj/machinery/portable_atmospherics/hydroponics/tray)
	if ( tray.dead )
		return 0

	if ( setting_ignoreEmpty && !tray.seed )
		return 0

	if ( setting_water && tray.get_waterlevel() < WATERLEVEL_MAX/5 && tank && tank.reagents.total_volume >= 1 )
		return FARMBOT_MODE_WATER

	if ( setting_weed && tray.get_weedlevel() >= WEEDLEVEL_MAX/2 )
		return FARMBOT_MODE_WEED
	if ( setting_fertilize && tray.get_nutrientlevel() <= NUTRIENTLEVEL_MAX/5 && get_total_ferts() && (!tray.seed || !tray.seed.hematophage) )
		return FARMBOT_MODE_FERTILIZE
	return 0


/obj/machinery/bot/farmbot/proc/fertilize(var/obj/item/weapon/reagent_containers/glass/fert)
	if ( !fert )
		target = null
		mode = 0
		return 0

	if ( emagged ) // Warning, hungry humans detected: throw fertilizer at them
		spawn(0)
			fert.forceMove(src.loc)
			fert.throw_at(target, 16, 3)
		src.visible_message("<span class='danger'>[src] launches [fert.name] at [target.name]!</span>")
		flick("[src.icon_initial]_broke", src)
		spawn (FARMBOT_EMAG_DELAY)
			mode = 0
			target = null
		return 1

	else // feed them plants~
		var/obj/machinery/portable_atmospherics/hydroponics/tray = target
		tray.add_nutrientlevel(10)
		fert.reagents.trans_to(tray, fert.reagents.total_volume)
		QDEL_NULL (fert)
		//tray.updateicon()
		icon_state = "[src.icon_initial]_fertile"
		mode = FARMBOT_MODE_WAITING

		spawn (FARMBOT_ACTION_DELAY)
			mode = 0
			target = null
		spawn (FARMBOT_ANIMATION_TIME)
			icon_state = "[src.icon_initial][src.on]"
		return 1

/obj/machinery/bot/farmbot/proc/weed()
	icon_state = "[src.icon_initial]_hoe"
	spawn(FARMBOT_ANIMATION_TIME)
		icon_state = "[src.icon_initial][src.on]"

	if ( emagged ) // Warning, humans infested with weeds!
		mode = FARMBOT_MODE_WAITING
		spawn(FARMBOT_EMAG_DELAY)
			mode = 0

		if ( prob(30) ) // better luck next time little guy
			src.visible_message("<span class='danger'>[src] swings wildly at [target] with a minihoe, missing completely!</span>")

		else // yayyy take that weeds~
			var/attackVerb = pick("slashes", "slices", "cuts", "claws")
			var /mob/living/carbon/human/human = target

			src.visible_message("<span class='danger'>[src] [attackVerb] [human]!</span>")
			var/damage = 15
			var/dam_zone = pick(LIMB_CHEST, LIMB_LEFT_HAND, LIMB_RIGHT_HAND, LIMB_LEFT_LEG, LIMB_RIGHT_LEG)
			var/datum/organ/external/affecting = human.get_organ(ran_zone(dam_zone))
			var/armor = human.run_armor_check(affecting, "melee")
			human.apply_damage(damage,BRUTE,affecting,armor)

	else // warning, plants infested with weeds!
		mode = FARMBOT_MODE_WAITING
		spawn(FARMBOT_ACTION_DELAY)
			mode = 0

		var /obj/machinery/portable_atmospherics/hydroponics/tray = target
		tray.add_weedlevel(-50)
		//tray.updateicon()

/obj/machinery/bot/farmbot/proc/water()
	if ( !tank || tank.reagents.total_volume < 1 )
		mode = 0
		target = null
		return 0

	icon_state = "[src.icon_initial]_water"
	spawn(FARMBOT_ANIMATION_TIME)
		icon_state = "[src.icon_initial][src.on]"

	if ( emagged ) // warning, humans are thirsty!
		var splashAmount = min(70,tank.reagents.total_volume)
		src.visible_message("<span class='warning'>[src] splashes [target] with a bucket of water!</span>")
		playsound(src, 'sound/effects/slosh.ogg', 25, 1)
		if ( prob(50) )
			tank.reagents.reaction(target, TOUCH) //splash the human!
		else
			tank.reagents.reaction(target.loc, TOUCH) //splash the human's roots!
		spawn(5)
			tank.reagents.remove_any(splashAmount)

		mode = FARMBOT_MODE_WAITING
		spawn(FARMBOT_EMAG_DELAY)
			mode = 0
	else
		var/obj/machinery/portable_atmospherics/hydroponics/tray = target
		var/b_amount = tank.reagents.remove_reagent(WATER, WATERLEVEL_MAX - tray.get_waterlevel())
		tray.add_waterlevel(b_amount)
		playsound(src, 'sound/effects/slosh.ogg', 25, 1)

		//tray.updateicon()
		mode = FARMBOT_MODE_WAITING
		spawn(FARMBOT_ACTION_DELAY)
			mode = 0

/obj/machinery/bot/farmbot/proc/refill()
	if ( !tank || !tank.reagents.total_volume > 600 || !istype(target,/obj/structure/sink) )
		mode = 0
		target = null
		return

	mode = FARMBOT_MODE_WAITING
	playsound(src, 'sound/effects/slosh.ogg', 25, 1)
	src.visible_message("<span class='notice'>[src] starts filling it's tank from [target].</span>")
	spawn(300)
		src.visible_message("<span class='notice'>[src] finishes filling it's tank.</span>")
		src.mode = 0
		tank.reagents.add_reagent(WATER, tank.reagents.maximum_volume - tank.reagents.total_volume )
		playsound(src, 'sound/effects/slosh.ogg', 25, 1)


/obj/item/weapon/farmbot_arm_assembly
	name = "water tank/robot arm assembly"
	desc = "A water tank with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "water_arm"
	var/build_step = 0
	var/created_name = "Farmbot" //To preserve the name if it's a unique farmbot I guess
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/farmbot_arm_assembly/New()
	..()
	spawn(4) // If an admin spawned it, it won't have a watertank it, so lets make one for em!
		var tank = locate(/obj/structure/reagent_dispensers/watertank) in contents
		if( !tank )
			new /obj/structure/reagent_dispensers/watertank(src)


/obj/structure/reagent_dispensers/watertank/attackby(var/obj/item/robot_parts/S, mob/user as mob)

	if ((!istype(S, /obj/item/robot_parts/l_arm)) && (!istype(S, /obj/item/robot_parts/r_arm)))
		..()
		return

	//Making a farmbot!

	var/obj/item/weapon/farmbot_arm_assembly/A = new /obj/item/weapon/farmbot_arm_assembly

	A.forceMove(src.loc)
	to_chat(user, "You add the robot arm to the [src]")
	src.forceMove(A) //Place the water tank into the assembly, it will be needed for the finished bot

	QDEL_NULL(S)

/obj/item/weapon/farmbot_arm_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if((istype(W, /obj/item/device/analyzer/plant_analyzer)) && (!src.build_step))
		src.build_step++
		to_chat(user, "You add the plant analyzer to [src]!")
		src.name = "farmbot assembly"
		QDEL_NULL(W)

	else if(( istype(W, /obj/item/weapon/reagent_containers/glass/bucket)) && (src.build_step == 1))
		src.build_step++
		to_chat(user, "You add a bucket to [src]!")
		src.name = "farmbot assembly with bucket"
		QDEL_NULL(W)

	else if(( istype(W, /obj/item/weapon/minihoe)) && (src.build_step == 2))
		src.build_step++
		to_chat(user, "You add a minihoe to [src]!")
		src.name = "farmbot assembly with bucket and minihoe"
		QDEL_NULL(W)

	else if((isprox(W)) && (src.build_step == 3))
		src.build_step++
		to_chat(user, "You complete the Farmbot! Beep boop.")
		var/obj/machinery/bot/farmbot/S = new /obj/machinery/bot/farmbot
		for ( var/obj/structure/reagent_dispensers/watertank/wTank in src.contents )
			wTank.forceMove(S)
			S.tank = wTank
		S.forceMove(get_turf(src))
		S.name = src.created_name
		QDEL_NULL(W)
		qdel(src)

	else if(istype(W, /obj/item/weapon/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
		t = copytext(sanitize(t), 1, MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t
