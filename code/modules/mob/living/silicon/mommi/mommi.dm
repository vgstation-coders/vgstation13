/*  Basically, the concept is this:
You have an MMI.  It can't do squat on its own.
Now you put some robot legs and arms on the thing, and POOF!  You have a Mobile MMI, or MoMMI.
Why?  MoMMIs can do all sorts of shit, like ventcrawl, do shit with their hands, etc.
They can only use one tool at a time, they can't choose modules, and they have 1/6th the HP of a borg.
*/
/mob/living/silicon/robot/mommi
	name = "Mobile MMI"
	desc = "It's like a crab, but it has a utility tool on one arm and a crude metal claw on the other.  That, and you doubt it'd survive in an ocean for very long."
	real_name = "Mobile MMI"
	icon = 'icons/mob/mommi.dmi'
	icon_state = "mommi"
	maxHealth = 60
	health = 60

	pass_flags = PASSTABLE
	mob_bump_flag = ROBOT
	mob_swap_flags = ALLMOBS
	mob_push_flags = 0

	modtype = "Nanotrasen"
	braintype = "Mobile MMI"

	//New() stuff
	startup_sound = 'sound/misc/interference.ogg'

	//This is no cyborg boy, no cyborg!
	cell_type = /obj/item/weapon/cell/crepe/mommi //The secret behind MoMMIs, literal powercreep.
	wiring_type = /datum/wires/robot/mommi

	AIlink = FALSE //Fuck AIs, you're a crab.
	scrambledcodes = TRUE //Don't appear on the SS13/ROBOTS cameranet, you're not supposed to be a ventcrawling security camera.

	//MoMMI stuff
	var/picked_icon = FALSE

	var/keeper= TRUE // FALSE = No, TRUE = Yes (Disables speech and common radio.)
	var/prefix = "Mobile MMI"
	var/damage_control_network = "Damage Control"

	var/static_choice = "static"
	var/list/static_choices = list("static", "letter", "blank")

	var/obj/abstract/screen/inv_tool = null
	var/obj/item/tool_state = null
	var/obj/item/head_state = null

/mob/living/silicon/robot/mommi/getModules()
	return mommi_modules //Default non-subtype mommis aren't supposed to spawn outside of bus anyways

//REMOVE STATIC
/mob/living/silicon/robot/mommi/Destroy()
	remove_static_overlays()
	..()

/mob/living/silicon/robot/mommi/track_globally()
	return //don't track

/mob/living/silicon/robot/mommi/remove_screen_objs()
	..()
	if(inv_tool)
		returnToPool(inv_tool)
		if(client)
			client.screen -= inv_tool
		inv_tool = null

/mob/living/silicon/robot/mommi/updatename()
	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	else
		changed_name = "[prefix] [num2text(ident)]"
	real_name = changed_name
	name = real_name

/mob/living/silicon/robot/mommi/emag_act(mob/user)
	if(user == src && !emagged)//Dont shitpost inside the game, thats just going too far
		if(module)
			var/obj/item/weapon/robot_module/mommi/mymodule = module
			to_chat(user, "<span class='warning'>[mymodule.ae_type] anti-emancipation override initiated.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return TRUE
	if(..())
		return TRUE
	remove_static_overlays()
	updateicon()

	//If KEEPER is enabled, disable it.
	if(keeper)
		keeper = FALSE

	//and maybe some more freedoms like staying up past bedtime, littering, and jaywalking :)
	if(!HAS_MODULE_QUIRK(src, MODULE_CAN_HANDLE_FOOD))
		module.quirk_flags |= MODULE_CAN_HANDLE_FOOD

/mob/living/silicon/robot/mommi/attackby(obj/item/weapon/W, mob/living/user)
	if(istype(W, /obj/item/stack/cable_coil) && wiresexposed)
		var/obj/item/stack/cable_coil/coil = W
		adjustFireLoss(-30)
		updatehealth()
		coil.use(1)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("<span class='warning'>[user] has fixed some of the burnt wires on [src]!</span>"), 1)

	else if(iscrowbar(W))	// crowbar means open or close the cover
		if(isDead())
			to_chat(user, "You pop the MMI off the base.")
			spawn(0)
				qdel(src)
			return
		if(opened)
			if(mmi && wiresexposed && wires.IsAllCut())
				//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
				to_chat(user, "You jam the crowbar into \the [src] and begin levering [mmi].")
				if(do_after(user, src,3))
					to_chat(user, "You damage some parts of the casing, but eventually manage to rip out [mmi]!")
					var/limbs = list(/obj/item/robot_parts/l_leg, /obj/item/robot_parts/r_leg, /obj/item/robot_parts/l_arm, /obj/item/robot_parts/r_arm)
					for(var/newlimb = 1 to rand(2, 4))
						var/limb_to_spawn = pick(limbs)
						limbs -= limb_to_spawn

						new limb_to_spawn(loc)
					qdel(src)
					return
			else
				to_chat(user, "You close the cover.")
				opened = FALSE
				updateicon()
		else
			if(locked)
				to_chat(user, "The cover is locked and cannot be opened.")
			else
				to_chat(user, "You open the cover.")
				opened = TRUE
				updateicon()

	else if(istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		if(wiresexposed)
			to_chat(user, "Close the panel first.")
		else if(cell)
			to_chat(user, "There is a power cell already installed.")
		else
			user.drop_item(W, src)
			cell = W
			to_chat(user, "You insert the power cell.")
		updateicon()

	else if(iswiretool(W))
		if(wiresexposed)
			wires.Interact(user)
		else
			to_chat(user, "You can't reach the wiring.")

	else if(W.is_screwdriver(user) && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
		updateicon()

	else if(W.is_screwdriver(user) && opened && cell)	// radio
		if(radio)
			radio.attackby(W,user)//Push it to the radio to let it handle everything
		else
			to_chat(user, "Unable to locate a radio.")
		updateicon()

	else if(istype(W, /obj/item/device/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			to_chat(user, "Unable to locate a radio.")

	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		U.attempt_action(src,user)

	else if(istype(W, /obj/item/device/camera_bug))
		help_shake_act(user)
		return FALSE

	else
		user.do_attack_animation(src, W)
		spark(src, 5, FALSE)
		return ..()

/mob/living/silicon/robot/mommi/attack_hand(mob/user)
	add_fingerprint(user)

	if(opened && !wiresexposed && (!isMoMMI(user)))
		if(cell)
			cell.updateicon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			to_chat(user, "You remove \the [cell].")
			cell = null
			updateicon()
			return

	if(!istype(user, /mob/living/silicon))
		switch(user.a_intent)
			if(I_DISARM)
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [name] ([ckey])</font>")
				attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [user.name] ([user.ckey])</font>")
				log_admin("ATTACK: [user.name] ([user.ckey]) disarmed [name] ([ckey])")
				log_attack("<font color='red'>[user.name] ([user.ckey]) disarmed [name] ([ckey])</font>")
				var/randn = rand(1,100)
				if(randn <= 25)
					knockdown = 3
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[user] has pushed [src]!</span>")
					var/obj/item/found = locate(tool_state) in module.modules
					if(!found)
						var/obj/item/TS = tool_state
						drop_item(TS)
						if(TS && TS.loc)
							visible_message("<span class='warning'><B>[src]'s robotic arm loses grip on what it was holding</span>")
					return
				if(randn <= 50)//MoMMI's robot arm is stronger than a human's, but not by much
					var/obj/item/found = locate(tool_state) in module.modules
					if(!found)
						var/obj/item/TS = tool_state
						drop_item(TS)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						visible_message("<span class='danger'>[user] has disarmed [src]!</span>")
					else
						playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
						visible_message("<span class='danger'>[user] attempted to disarm [src]!</span>")
					return
			if(I_HELP)
				help_shake_act(user)
				return

/mob/living/silicon/robot/mommi/choose_icon()
	if(..())
		picked_icon = TRUE

/mob/living/silicon/robot/mommi/installed_modules()
	if(!module)
		pick_module()
		return
	if(!picked_icon)
		if(!module_sprites)
			set_module_sprites(module.sprites)
		choose_icon()
		return
	var/dat = "<HEAD><TITLE>Modules</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += {"<BR>
	<BR>
	<B>Activated Modules</B>
	<BR>
	Sight Mode: <A HREF=?src=\ref[src];vision=0>[sensor_mode ? "[vision_types_list[sensor_mode]]" : "No sight module enabled"]</A><BR>
	Utility Module: [tool_state ? "<A HREF=?src=\ref[src];mod=\ref[tool_state]>[tool_state]</A>" : "No module selected"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	for (var/obj in module.modules)
		if(!obj)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(obj))
			dat += text("[obj]: <B>Activated</B><BR>")
		else
			dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Activate</A><BR>")
	if(emagged)
		if(activated(module.emag))
			dat += text("[module.emag]: <B>Activated</B><BR>")
		else
			dat += text("[module.emag]: <A HREF=?src=\ref[src];act=\ref[module.emag]>Activate</A><BR>")
	src << browse(dat, "window=robotmod&can_close=1")
	onclose(src,"robotmod") // Register on-close shit, which unsets machinery.


/mob/living/silicon/robot/mommi/Topic(href, href_list)
	. = ..()
	if(usr && (src != usr))
		return

	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)
		return

	if(href_list["showalerts"])
		robot_alerts()
		return

	if(href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		if(O && O == tool_state)
			O.attack_self(src)

	if(href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		var/obj/item/TS
		if(!(locate(O) in module.modules) && O != module.emag)
			return
		TS = tool_state
		if(tool_state)
			contents -= tool_state
			if(client)
				client.screen -= tool_state
		tool_state = O
		O.hud_layerise()
		contents += O
		inv_tool.icon_state = "inv1 +a"
		module_active=tool_state
		if(TS && istype(TS))
			if(is_in_modules(TS))
				TS.forceMove(module)
			else
				TS.layer=initial(TS.layer)
				TS.forceMove(loc)

		installed_modules()
	return

/mob/living/silicon/robot/mommi/radio_menu()
	radio.interact(src)//Just use the radio's Topic() instead of bullshit special-snowflake code
