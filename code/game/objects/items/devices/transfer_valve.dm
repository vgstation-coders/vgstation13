/obj/item/device/transfer_valve
	icon = 'icons/obj/assemblies.dmi'
	name = "tank transfer valve"
	icon_state = "valve_1"
	item_state = "ttv"
	lefthand_file = 'icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/bombs_righthand.dmi'
	desc = "Regulates the transfer of air between two tanks."
	w_class = WEIGHT_CLASS_BULKY
	var/obj/item/tank/tank_one
	var/obj/item/tank/tank_two
	var/obj/item/device/assembly/attached_device
	var/mob/attacher = null
	var/valve_open = FALSE
	var/toggle = 1

/obj/item/device/transfer_valve/IsAssemblyHolder()
	return TRUE

/obj/item/device/transfer_valve/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/tank))
		if(tank_one && tank_two)
			to_chat(user, "<span class='warning'>There are already two tanks attached, remove one first!</span>")
			return

		if(!tank_one)
			if(!user.transferItemToLoc(item, src))
				return
			tank_one = item
			to_chat(user, "<span class='notice'>You attach the tank to the transfer valve.</span>")
		else if(!tank_two)
			if(!user.transferItemToLoc(item, src))
				return
			tank_two = item
			to_chat(user, "<span class='notice'>You attach the tank to the transfer valve.</span>")

		update_icon()
//TODO: Have this take an assemblyholder
	else if(isassembly(item))
		var/obj/item/device/assembly/A = item
		if(A.secured)
			to_chat(user, "<span class='notice'>The device is secured.</span>")
			return
		if(attached_device)
			to_chat(user, "<span class='warning'>There is already a device attached to the valve, remove it first!</span>")
			return
		if(!user.transferItemToLoc(item, src))
			return
		attached_device = A
		to_chat(user, "<span class='notice'>You attach the [item] to the valve controls and secure it.</span>")
		A.holder = src
		A.toggle_secure()	//this calls update_icon(), which calls update_icon() on the holder (i.e. the bomb).

		GLOB.bombers += "[key_name(user)] attached a [item] to a transfer valve."
		message_admins("[key_name_admin(user)] attached a [item] to a transfer valve.")
		log_game("[key_name(user)] attached a [item] to a transfer valve.")
		attacher = user
	return

/obj/item/device/transfer_valve/attack_self(mob/user)
	user.set_machine(src)
	var/dat = {"<B> Valve properties: </B>
	<BR> <B> Attachment one:</B> [tank_one] [tank_one ? "<A href='?src=[REF(src)];tankone=1'>Remove</A>" : ""]
	<BR> <B> Attachment two:</B> [tank_two] [tank_two ? "<A href='?src=[REF(src)];tanktwo=1'>Remove</A>" : ""]
	<BR> <B> Valve attachment:</B> [attached_device ? "<A href='?src=[REF(src)];device=1'>[attached_device]</A>" : "None"] [attached_device ? "<A href='?src=[REF(src)];rem_device=1'>Remove</A>" : ""]
	<BR> <B> Valve status: </B> [ valve_open ? "<A href='?src=[REF(src)];open=1'>Closed</A> <B>Open</B>" : "<B>Closed</B> <A href='?src=[REF(src)];open=1'>Open</A>"]"}

	var/datum/browser/popup = new(user, "trans_valve", name)
	popup.set_content(dat)
	popup.open()
	return

/obj/item/device/transfer_valve/Topic(href, href_list)
	..()
	if(!usr.canUseTopic(src))
		return
	if(tank_one && href_list["tankone"])
		split_gases()
		valve_open = FALSE
		tank_one.forceMove(drop_location())
		tank_one = null
		update_icon()
	else if(tank_two && href_list["tanktwo"])
		split_gases()
		valve_open = FALSE
		tank_two.forceMove(drop_location())
		tank_two = null
		update_icon()
	else if(href_list["open"])
		toggle_valve()
	else if(attached_device)
		if(href_list["rem_device"])
			attached_device.forceMove(drop_location())
			attached_device.holder = null
			attached_device = null
			update_icon()
		if(href_list["device"])
			attached_device.attack_self(usr)

	attack_self(usr)
	add_fingerprint(usr)

/obj/item/device/transfer_valve/proc/process_activation(obj/item/device/D)
	if(toggle)
		toggle = FALSE
		toggle_valve()
		addtimer(CALLBACK(src, .proc/toggle_off), 5)	//To stop a signal being spammed from a proxy sensor constantly going off or whatever

/obj/item/device/transfer_valve/proc/toggle_off()
	toggle = TRUE

/obj/item/device/transfer_valve/update_icon()
	cut_overlays()
	underlays = null

	if(!tank_one && !tank_two && !attached_device)
		icon_state = "valve_1"
		return
	icon_state = "valve"

	if(tank_one)
		add_overlay("[tank_one.icon_state]")
	if(tank_two)
		var/icon/J = new(icon, icon_state = "[tank_two.icon_state]")
		J.Shift(WEST, 13)
		underlays += J
	if(attached_device)
		add_overlay("device")

/obj/item/device/transfer_valve/proc/merge_gases()
	tank_two.air_contents.volume += tank_one.air_contents.volume
	var/datum/gas_mixture/temp
	temp = tank_one.air_contents.remove_ratio(1)
	tank_two.air_contents.merge(temp)

/obj/item/device/transfer_valve/proc/split_gases()
	if (!valve_open || !tank_one || !tank_two)
		return
	var/ratio1 = tank_one.air_contents.volume/tank_two.air_contents.volume
	var/datum/gas_mixture/temp
	temp = tank_two.air_contents.remove_ratio(ratio1)
	tank_one.air_contents.merge(temp)
	tank_two.air_contents.volume -=  tank_one.air_contents.volume

	/*
	Exadv1: I know this isn't how it's going to work, but this was just to check
	it explodes properly when it gets a signal (and it does).
	*/

/obj/item/device/transfer_valve/proc/toggle_valve()
	if(!valve_open && tank_one && tank_two)
		valve_open = TRUE
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)

		var/attachment = "no device"
		if(attached_device)
			if(istype(attached_device, /obj/item/device/assembly/signaler))
				attachment = "<A HREF='?_src_=holder;[HrefToken()];secrets=list_signalers'>[attached_device]</A>"
			else
				attachment = attached_device

		var/attacher_name = ""
		if(!attacher)
			attacher_name = "Unknown"
		else
			attacher_name = "[key_name_admin(attacher)]"

		var/log_str1 = "Bomb valve opened in "
		var/log_str2 = "with [attachment] attacher: [attacher_name]"

		var/log_attacher = ""
		if(attacher)
			log_attacher = "[ADMIN_QUE(attacher)] [ADMIN_FLW(attacher)]"

		var/mob/mob = get_mob_by_key(src.fingerprintslast)
		var/last_touch_info = ""
		if(mob)
			last_touch_info = "[ADMIN_QUE(mob)] [ADMIN_FLW(mob)]"

		var/log_str3 = " Last touched by: [key_name_admin(mob)]"

		var/bomb_message = "[log_str1] [A.name][ADMIN_JMP(bombturf)] [log_str2][log_attacher] [log_str3][last_touch_info]"

		GLOB.bombers += bomb_message

		message_admins(bomb_message, 0, 1)
		log_game("[log_str1] [A.name][COORD(bombturf)] [log_str2] [log_str3]")
		merge_gases()
		for(var/i in 1 to 6)
			addtimer(CALLBACK(src, .proc/update_icon), 20 + (i - 1) * 10)

	else if(valve_open && tank_one && tank_two)
		split_gases()
		valve_open = FALSE
		update_icon()

// this doesn't do anything but the timer etc. expects it to be here
// eventually maybe have it update icon to show state (timer, prox etc.) like old bombs
/obj/item/device/transfer_valve/proc/c_state()
	return
