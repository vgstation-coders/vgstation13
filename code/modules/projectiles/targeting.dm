//This file handles all the "send bullet to target" and "locate and handle manual targets" business

//Wherever we shoot once and leave the target be, or fill them with lead until they become 'compliant'
/obj/item/weapon/gun/verb/toggle_target_fire_once()
	set name = "Toggle Hostage Fire Strategy"
	set category = "Object"
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/obj/item/weapon/gun/verb/toggle_target_fire_once()  called tick#: [world.time]")
	target_fire_once = !target_fire_once
	if(!target_fire_once)
		usr << "<span class='warning'>You will now continue firing until your target becomes 'compliant' again.</span>"
	else
		usr << "<span class='notice'>You will now fire once and lower your aim if your target stops complying.</span>"

//Manually lower our aim
/obj/item/weapon/gun/verb/lower_aim()
	set name = "Lower Aim"
	set category = "Object"
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/obj/item/weapon/gun/verb/lower_aim()  called tick#: [world.time]")
	if(target)
		stop_aim(usr)
		usr.visible_message("<span class='notice'>\The [usr] lowers \his [src.name].</span>", \
		"<span class='notice'>You lower your [src.name].</span>")

//If we drop our weapon, immediately stop aiming
/obj/item/weapon/gun/dropped(mob/user as mob)
	stop_aim(user)
	if(user.client)
		user.client.remove_gun_icons()
	return ..()

/obj/item/weapon/gun/equipped(var/mob/user, var/slot)
	if(slot != slot_l_hand && slot != slot_r_hand)
		stop_aim(user)
		if(user.client)
			user.client.remove_gun_icons()
	return ..()

//We aren't aiming anymore. Let our targets go
/obj/item/weapon/gun/proc/stop_aim(var/mob/living/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/proc/stop_aim() called tick#: [world.time]")
	if(target)
		for(var/mob/living/M in target)
			if(M)
				M.untarget(user, src) //Untargeting people.
		del(target)

//Figure out if we should just go ahead and fire, or start taking hostages
/obj/item/weapon/gun/proc/prefire(atom/A as mob|obj|turf|area, var/mob/living/user, params, struggle = 0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/proc/prefire() called tick#: [world.time]")

	/*
	//Lets not spam it
	if(lock_time > world.time - 2)
		return
	 */

	if(isliving(A) && !(A in target)) //We clicked on a mob that wasn't targeted yet. Cast and aim
		var/mob/living/M = A
		aim_at_target(M, user)

	else //Nothing, fire away
		Fire(A, user, params, "struggle" = struggle) //Fire like normal otherwise

//Acquire our target
/obj/item/weapon/gun/proc/aim_at_target(var/mob/living/M, var/mob/living/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/proc/Aim() called tick#: [world.time]")
	if(!target)
		target = list()
	if(!target.len) //Simplest case, we have no target yet
		user.visible_message("<span class='danger'>[user] aims \his [src.name] at [M]!</span>", \
		"<span class='danger'>You aim your [src.name] at [M]!</span>")
	else //We have a target, it gets more complicated
		if(!automatic) //We already have a target, and this weapon isn't automatic
			for(var/mob/living/L in target)
				L.untarget(src) //Break off all other targets
			del(target)
			user.visible_message("<span class='danger'>[user] suddenly turns \his [src.name] on [M]!</span>", \
			"<span class='danger'>You suddenly turn your [src.name] on [M]!</span>")
		else //Alright, this weapon is automatic
			if(target.len < 5) //Automatic weapon can target five people, we're clear
				user.visible_message("<span class='danger'>[user] changes \his [src.name]'s bearing to include [M]!</span>", \
				"<span class='danger'>You change your [src.name]'s bearing to include [M]!</span>")
			else //Too many targets
				user << "<span class='warning'>You can only target up to five people at once with \the [src]!</span>"
				return

	target.Add(M) //Add to our targets
	M.handle_targeting(user, src) //And now, for the gritty hostage taking stuff

//The target has acted in a way that has triggered us. Time to shoot them
/obj/item/weapon/gun/proc/shoot_at_target(var/mob/living/user, var/mob/living/T)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/proc/shoot_at_target() called tick#: [world.time]")
	if(user == T)
		return
	if(src != user.get_active_hand())
		stop_aim(user)
		return
	user.last_move_intent = world.time
	if(can_fire())
		var/firing_check = can_hit(T, user) //0 if it cannot hit them, 1 if it is capable of hitting, and 2 if a special check is preventing it from firing.
		if(firing_check > 0)
			if(firing_check == 1)
				Fire(T, user, reflex = 1)
		else if(!told_cant_shoot)
			user << "<span class='warning'>[T] cannot be hit from here!</span>"
			told_cant_shoot = 1
			spawn(30)
				told_cant_shoot = 0
	else
		playsound(get_turf(src), 'sound/weapons/empty.ogg', 100, 1) //It's empty hon'
		visible_message("<span class='warning'>*click*</span>")

	user.dir = get_cardinal_dir(src, T)

	if(target_fire_once) //We will fire only once even if they continue not complying
		T.untarget(src)

//Targeting management variables
/mob/var/list/targeted_by
/mob/var/target_time = -100
/mob/var/last_move_intent = -100
/mob/var/last_target_click = -5
/mob/var/target_locked = null

//We will now handle being targeted from here
/mob/living/proc/handle_targeting(var/mob/living/user, var/obj/item/weapon/gun/G)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\mob/living/proc/handle_targeting() called tick#: [world.time]")

	playsound(get_turf(src), 'sound/weapons/TargetOn.ogg', 100, 1)

	if(!targeted_by)
		targeted_by = list()
	targeted_by.Add(G)
	G.lock_time = world.time + 10 //Target has one second to realize they're targeted and stop
	src << "<span class='danger'>Your character is being targeted. They have one second to stop movement and interactions.</span> \
	While targeted, you may drag and drop items, speak and use anything in your HUD. \
	Interacting with objects, using items or moving will result in being fired upon. \
	<span class='warning'>The aggressor may also fire manually, so try not to get on their bad side.</span>"

	if(targeted_by.len == 1) //We only do it once, even if multiple guns are aimed at us
		spawn(0)
			target_locked = image("icon" = 'icons/effects/Targeted.dmi', "icon_state" = "locking")
			update_targeted()
			spawn(0)
				sleep(G.lock_time)
				if(target_locked)
					target_locked = image("icon" = 'icons/effects/Targeted.dmi', "icon_state" = "locked")
					update_targeted()

	//Adding the buttons to the controler person
	if(user && user.client) //Sanity
		user.client.add_gun_icons()
	else
		G.lower_aim()
		return

	//We now move on to the part where we process until the hostage situation is over
	if(m_intent == "run" && user.client.target_can_move && !user.client.target_can_run)
		src << "<span class='warning'>Your captive is allowing you to walk. Make sure to respect their wishes and not start running, or you will be fired upon.</span>"

	//Process the aiming. Should be probably in separate object with process()
	while(targeted_by)
		if(!user.client) //The client is gone, lower the aim
			G.lower_aim()
		if((last_move_intent > G.lock_time + 10) && !user.client.target_can_move) //If target moved when not allowed to
			G.shoot_at_target(user, src) //You fucked up
		else if((last_move_intent > G.lock_time + 10) && !user.client.target_can_run && m_intent == "run") //If the target ran while targeted
			G.shoot_at_target(user, src) //You fucked up
		if((last_target_click > G.lock_time + 10) && !user.client.target_can_click) //If the target clicked the map to pick something up/shoot/etc
			G.shoot_at_target(user, src) //You fucked up
		sleep(1)

/mob/living/proc/untarget(var/mob/living/user, var/obj/item/weapon/gun/G)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\mob/living/proc/untarget() called tick#: [world.time]")
	if(!G.silenced)
		playsound(get_turf(src), 'sound/weapons/TargetOff.ogg', 100, 1)
	targeted_by.Remove(G)
	G.target.Remove(src) //De-target them
	if(user && user.client && !G.target.len)
		user.client.remove_gun_icons()
		del(G.target)
	if(!targeted_by.len)
		del(target_locked) //Remove the overlay
		del(targeted_by)
	spawn()
		update_targeted()

//If you move out of range, it isn't going to still stay locked on you any more.
/client/var/target_can_move = 0
/client/var/target_can_run = 0
/client/var/target_can_click = 0
/client/var/gun_mode = 0

//These are called by the on-screen buttons, adjusting what the victim can and cannot do.
/client/proc/add_gun_icons()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\client/proc/add_gun_icons() called tick#: [world.time]")
	if(!usr)
		return
	if(!usr.item_use_icon)
		usr.item_use_icon = getFromPool(/obj/screen/gun/item)
		usr.item_use_icon.icon_state = "no_item[target_can_click]"
		usr.item_use_icon.name = "[target_can_click ? "Disallow" : "Allow"] Item Use"

	if(!usr.gun_move_icon)
		usr.gun_move_icon = getFromPool(/obj/screen/gun/move)
		usr.gun_move_icon.icon_state = "no_walk[target_can_move]"
		usr.gun_move_icon.name = "[target_can_move ? "Disallow" : "Allow"] Walking"

	if(target_can_move && !usr.gun_run_icon)
		usr.gun_run_icon = getFromPool(/obj/screen/gun/run)
		usr.gun_run_icon.icon_state = "no_run[target_can_run]"
		usr.gun_run_icon.name = "[target_can_run ? "Disallow" : "Allow"] Running"

	screen += usr.item_use_icon
	screen += usr.gun_move_icon
	if(target_can_move)
		screen += usr.gun_run_icon

/client/proc/remove_gun_icons()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\client/proc/remove_gun_icons() called tick#: [world.time]")
	if(!usr)
		return
	if(usr.gun_move_icon)
		returnToPool(usr.gun_move_icon)
		screen -= usr.gun_move_icon
		usr.gun_move_icon = null
	if(usr.item_use_icon)
		returnToPool(usr.item_use_icon)
		screen -= usr.item_use_icon
		usr.item_use_icon = null
	if(usr.gun_run_icon)
		returnToPool(usr.gun_run_icon)
		screen -= usr.gun_run_icon
		usr.gun_run_icon = null

/client/verb/ToggleGunMode()
	set hidden = 1
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\client/verb/ToggleGunMode()  called tick#: [world.time]")
	gun_mode = !gun_mode
	if(gun_mode)
		usr << "<span class='notice'>You will now take people you are aiming at captive.</span>"
		add_gun_icons()
	else
		usr << "<span class='warning'>You will now shoot anything you are aiming at.</span>"
		for(var/obj/item/weapon/gun/G in usr)
			G.stop_aim(usr)
		remove_gun_icons()
	if(usr.gun_setting_icon)
		usr.gun_setting_icon.icon_state = "gun[gun_mode]"

/client/verb/AllowTargetMove()
	set hidden = 1
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\client/verb/AllowTargetMove()  called tick#: [world.time]")

	//Changing client's permissions
	target_can_move = !target_can_move
	if(target_can_move)
		usr << "<span class='notice'>Your target is now allowed to walk.</span>"
		usr.gun_run_icon = getFromPool(/obj/screen/gun/run)	//Adding icon for running permission
		screen += usr.gun_run_icon
	else
		usr << "<span class='warning'>Your target is no longer allowed to move.</span>"
		target_can_run = 0
		del(usr.gun_run_icon) //No need for icon for running permission

	//Updating walking permission button
	if(usr.gun_move_icon)
		usr.gun_move_icon.icon_state = "no_walk[target_can_move]"
		usr.gun_move_icon.name = "[target_can_move ? "Disallow" : "Allow"] Walking"

	//Handling change for all the guns on client
	for(var/obj/item/weapon/gun/G in usr)
		G.lock_time = world.time + 5
		if(G.target)
			for(var/mob/living/M in G.target)
				if(target_can_move)
					M << "<span class='warning'>Your character is now allowed to <b>walk</b>.</span>"
				else
					M << "<span class='danger'>Your character is no longer allowed to move and will be shot if they do.</span>"

/mob/living/proc/set_m_intent(var/intent)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\mob/living/proc/set_m_intent() called tick#: [world.time]")
	if(intent != "walk" && intent != "run")
		return 0
	m_intent = intent
	if(hud_used)
		if (hud_used.move_intent)
			hud_used.move_intent.icon_state = intent == "walk" ? "walking" : "running"

/client/verb/AllowTargetRun()
	set hidden = 1
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\client/verb/AllowTargetRun()  called tick#: [world.time]")

	//Changing client's permissions
	target_can_run = !target_can_run
	if(target_can_run)
		usr << "<span class='notice'>Your target is now allowed to run.</span>"
	else
		usr << "<span class='warning'>Your target is no longer allowed to run.</span>"

	//Updating running permission button
	if(usr.gun_run_icon)
		usr.gun_run_icon.icon_state = "no_run[target_can_run]"
		usr.gun_run_icon.name = "[target_can_run ? "Disallow" : "Allow"] Running"

	//Handling change for all the guns on client
	for(var/obj/item/weapon/gun/G in src)
		G.lock_time = world.time + 5
		if(G.target)
			for(var/mob/living/M in G.target)
				if(target_can_run)
					M << "<span class='warning'>Your character is now allowed to <b>run</b>.</span>"
				else
					M << "<span class='danger'>Your character is no longer allowed to run and will be shot if they do.</span>"

client/verb/AllowTargetClick()
	set hidden = 1
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\client/verb/AllowTargetClick()  called tick#: [world.time]")

	//Changing client's permissions
	target_can_click = !target_can_click
	if(target_can_click)
		usr << "<span class='notice'>Your target is now allowed to use items.</span>"
	else
		usr << "<span class='notice'>Your target is no longer allowed to use items.</span>"

	if(usr.item_use_icon)
		usr.item_use_icon.icon_state = "no_item[target_can_click]"
		usr.item_use_icon.name = "[target_can_click ? "Disallow" : "Allow"] Item Use"

	//Handling change for all the guns on client
	for(var/obj/item/weapon/gun/G in src)
		G.lock_time = world.time + 5
		if(G.target)
			for(var/mob/living/M in G.target)
				if(target_can_click)
					M << "<span class='warning'>Your character is now allowed to <b>use items</b>.</span>"
				else
					M << "<span class='warning'>Your character is no longer allowed to <b>use items</b>.</span>"
