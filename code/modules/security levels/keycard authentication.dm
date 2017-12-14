var/global/list/obj/machinery/keycard_auth/authenticators = list()

/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	var/active = 0 //This gets set to 1 on all devices except the one where the initial request was made.
	var/event = ""
	var/screen = 1
	var/confirmed = 0 //This variable is set by the device that confirms the request.
	var/confirm_delay = 5 SECONDS
	var/busy = 0 //Busy when waiting for authentication or an event request has been sent from this device.
	var/obj/machinery/keycard_auth/event_source
	var/mob/event_triggered_by
	var/mob/event_confirmed_by
	var/ert_reason
	//1 = select event
	//2 = authenticate
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

/obj/machinery/keycard_auth/New()
	..()
	authenticators += src

/obj/machinery/keycard_auth/attack_ai(mob/user as mob)
	to_chat(user, "The station AI is not to interact with these devices.")
	return

/obj/machinery/keycard_auth/attack_paw(mob/user as mob)
	to_chat(user, "You are too primitive to use this device.")
	return

/obj/machinery/keycard_auth/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		to_chat(user, "This device is not powered.")
		return
	if(istype(W,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/ID = W
		if(access_keycard_auth in ID.access)
			if(active == 1)
				//This is not the device that made the initial request. It is the device confirming the request.
				if(event_source)
					event_source.confirmed = 1
					event_source.event_confirmed_by = usr
			else if(screen == 2)
				event_triggered_by = usr
				broadcast_request() //This is the device making the initial event request. It needs to broadcast to other devices

/obj/machinery/keycard_auth/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		icon_state = "auth_off"
	else
		stat |= NOPOWER

/obj/machinery/keycard_auth/Destroy()
	..()
	authenticators -= src

/obj/machinery/keycard_auth/attack_hand(mob/user as mob)
	if(user.stat || stat & (NOPOWER|BROKEN))
		to_chat(user, "This device is not powered.")
		return
	if(busy)
		to_chat(user, "This device is busy.")
		return

	user.set_machine(src)

	var/dat = "<h1>Keycard Authentication Device</h1>"


	dat += {"This device is used to trigger some high security events. It requires the simultaneous swipe of two high-level ID cards.
		<br><hr><br>"}
	if(screen == 1)

		dat += {"Select an event to trigger:<ul>
			<li><A href='?src=\ref[src];triggerevent=Red alert'>Red alert</A></li>"}
		if((get_security_level() in list("red", "delta")))
			dat += "<li><A href='?src=\ref[src];triggerevent=Emergency Response Team'>Emergency Response Team</A></li>"
		else
			dat += "<li>Emergency Response Team (Disabled while below Code Red)</li>"
		dat += {"<li><A href='?src=\ref[src];triggerevent=Grant Emergency Maintenance Access'>Grant Emergency Maintenance Access</A></li>
			<li><A href='?src=\ref[src];triggerevent=Revoke Emergency Maintenance Access'>Revoke Emergency Maintenance Access</A></li>
			</ul>"}
		dat += {"<li><A href='?src=\ref[src];triggerevent=Grant Emergency Mining Base Access'>Grant Emergency Mining Base Access</A></li>
			<li><A href='?src=\ref[src];triggerevent=Revoke Emergency Mining Base Access'>Revoke Emergency Mining Base Access</A></li>
			</ul>"}
		dat += {"<li><A href='?src=\ref[src];triggerevent=Grant Emergency Xenoarchaeology Base Access'>Grant Emergency Xenoarchaeology Base Access</A></li>
			<li><A href='?src=\ref[src];triggerevent=Revoke Emergency Xenoarchaeology Base Access'>Revoke Emergency Xenoarchaeology Base Access</A></li>
			</ul>"}
		dat += {"<li><A href='?src=\ref[src];triggerevent=Remove Crew Weapon Restrictions'>Remove Crew Weapon Restrictions</A></li>
			<li><A href='?src=\ref[src];triggerevent=Re Enable Crew Weapon Restrictions'>Re Enable Crew Weapon Restrictions</A></li>
			</ul>"}
		user << browse(dat, "window=keycard_auth;size=500x300")
	if(screen == 2)

		dat += "Please swipe your card to authorize the following event: <b>[event]</b>"
		if(event == "Emergency Response Team")
			dat += "<p>Given reason for ERT request: '[ert_reason]'"

		dat += "<p><A href='?src=\ref[src];reset=1'>Back</A>"
		user << browse(dat, "window=keycard_auth;size=500x300")
	return


/obj/machinery/keycard_auth/Topic(href, href_list)
	if(..())
		return 1
	if(busy)
		to_chat(usr, "This device is busy.")
		return
	if(usr.stat || stat & (BROKEN|NOPOWER))
		to_chat(usr, "This device is without power.")
		return
	if(href_list["triggerevent"])
		if(href_list["triggerevent"] == "Emergency Response Team")
			ert_reason = stripped_input(usr, "Please input the reason for calling an Emergency Response Team. This may be all the briefing they get before arriving at the station.", "Response Team Justification", ert_reason)
			if(!ert_reason)
				to_chat(usr, "<span class='warning'>You are required to give a reason to call an ERT.</span>")
				return
			if(!Adjacent(usr) || usr.incapacitated())
				return
		event = href_list["triggerevent"]
		screen = 2
	if(href_list["reset"])
		reset()

	updateUsrDialog()
	add_fingerprint(usr)
	return

/obj/machinery/keycard_auth/proc/reset()
	active = 0
	event = ""
	screen = 1
	confirmed = 0
	event_source = null
	icon_state = "auth_off"
	event_triggered_by = null
	event_confirmed_by = null

/obj/machinery/keycard_auth/proc/broadcast_request()
	icon_state = "auth_on"
	for(var/obj/machinery/keycard_auth/KA in authenticators)
		if(KA == src)
			continue
		KA.reset()
		spawn()
			KA.receive_request(src)

	sleep(confirm_delay)
	if(confirmed)
		confirmed = 0
		trigger_event(event)
		log_game("[key_name(event_triggered_by)] triggered and [key_name(event_confirmed_by)] confirmed event [event][event=="Emergency Response Team"?". ERT reason given was '[ert_reason]'":""]")
		message_admins("[key_name(event_triggered_by)] triggered and [key_name(event_confirmed_by)] confirmed event [event][event=="Emergency Response Team"?". ERT reason given was '[ert_reason]'":""]", 1)
	reset()

/obj/machinery/keycard_auth/proc/receive_request(var/obj/machinery/keycard_auth/source)
	if(stat & (BROKEN|NOPOWER))
		return
	event_source = source
	busy = 1
	active = 1
	icon_state = "auth_on"

	sleep(confirm_delay)

	event_source = null
	icon_state = "auth_off"
	active = 0
	busy = 0

/obj/machinery/keycard_auth/proc/trigger_event()
	switch(event)
		if("Red alert") // Xenoarchaeology Base
			set_security_level(SEC_LEVEL_RED)
			feedback_inc("alert_keycard_auth_red",1)
		if("Grant Emergency Maintenance Access")
			make_maint_all_access()
			feedback_inc("alert_keycard_auth_maintGrant",1)
		if("Revoke Emergency Maintenance Access")
			revoke_maint_all_access()
			feedback_inc("alert_keycard_auth_maintRevoke",1)
		if("Grant Emergency Mining Base Access") // emergency mining station access
			make_mining_all_access()
			feedback_inc("alert_keycard_auth_miningGrant",1)
		if("Revoke Emergency Mining Base Access") //removes mining all access
			revoke_mining_all_access()
		if("Grant Emergency Xenoarchaeology Base Access") // emergency xenoarch station access
			make_xenoarch_all_access()
			feedback_inc("alert_keycard_auth_xenoarchGrant",1)
		if("Revoke Emergency Xenoarchaeology Base Access") //removes xenoarch all access
			revoke_xenoarch_all_access()
			feedback_inc("alert_keycard_auth_xenoarchRevoke",1)
		if("Remove Crew Weapon Restrictions") // remove armory access
			make_armory_all_access()
			feedback_inc("alert_keycard_auth_armoryGrant",1)
		if("Re Enable Crew Weapon Restrictions") //re ad armory access
			revoke_armory_all_access()
			feedback_inc("alert_keycard_auth_armoryRevoke",1)
		if("Emergency Response Team")
			var/datum/striketeam/ert/response_team = new()
			response_team.mission = ert_reason
			response_team.trigger_strike()
			feedback_inc("alert_keycard_auth_ert",1)

var/global/maint_all_access = 0

/proc/make_maint_all_access()
	maint_all_access = 1
	to_chat(world, "<font size=4 color='red'>Attention!</font>")
	to_chat(world, "<font color='red'>The maintenance access requirement has been revoked on all airlocks.</font>")

/proc/revoke_maint_all_access()
	maint_all_access = 0
	to_chat(world, "<font size=4 color='red'>Attention!</font>")
	to_chat(world, "<font color='red'>The maintenance access requirement has been readded on all maintenance airlocks.</font>")

/obj/machinery/door/airlock/allowed(mob/M)
	if(maint_all_access && src.check_access_list(list(access_maint_tunnels)))
		return 1
	return ..(M)

/obj/machinery/door/airlock/allowed(mob/K)
	if(maint_all_access && src.check_access_list(list(access_maint_tunnels)))
		return 1
	return ..(K)

var/global/mining_all_access = 0

/proc/make_mining_all_access()
	mining_all_access = 1
	to_chat(world, "<font size=4 color='red'>Attention!</font>")
	to_chat(world, "<font color='red'>The mining access requirement has been revoked on the mining station and mining shuttle.</font>")

/proc/revoke_mining_all_access()
	mining_all_access = 0
	to_chat(world, "<font size=4 color='red'>Attention!</font>")
	to_chat(world, "<font color='red'>The mining access requirement has been readded on the mining station and mining shuttle.</font>")

/obj/machinery/door/airlock/allowed(mob/T)
	if(mining_all_access && src.check_access_list(list(access_mining, access_mint, access_mining_station)))
		return 1
	return ..(T)

/obj/machinery/door/window/allowed(mob/F)
	if(mining_all_access && src.check_access_list(list(access_mining, access_mint, access_mining_station)))
		return 1
	return ..(F)

/obj/machinery/computer/shuttle_control/mining/allowed(mob/G)
	if(mining_all_access && src.check_access_list(list(access_mining, access_mint, access_mining_station)))
		return 1
	return ..(G)

var/global/xenoarch_all_access = 0

/proc/make_xenoarch_all_access()
	xenoarch_all_access = 1
	to_chat(world, "<font size=4 color='red'>Attention!</font>")
	to_chat(world, "<font color='red'>The research access requirement has been revoked on the xenoarchaeology station and mining research.</font>")

/proc/revoke_xenoarch_all_access()
	xenoarch_all_access = 0
	to_chat(world, "<font size=4 color='red'>Attention!</font>")
	to_chat(world, "<font color='red'>The research access requirement has been readded on the xenoarchaeology station and research shuttle.</font>")

/obj/machinery/door/airlock/allowed(mob/Q)
	if(xenoarch_all_access && src.check_access_list(list(access_science, access_rnd)))
		return 1
	return ..(Q)

/obj/machinery/door/window/allowed(mob/B)
	if(xenoarch_all_access && src.check_access_list(list(access_science, access_rnd)))
		return 1
	return ..(B)

/obj/machinery/computer/shuttle_control/research/allowed(mob/L)
	if(xenoarch_all_access && src.check_access_list(list(access_science)))
		return 1
	return ..(L)

var/global/armory_all_access = 0

/proc/make_armory_all_access()
	armory_all_access = 1
	to_chat(world, "<font size=4 color='red'>Attention!</font>")
	to_chat(world, "<font color='red'>Crew weapon restrictions disabled. All crewmembers are permitted to use lethal weaponry against threats to the station without repurcussion</font>")

/proc/revoke_armory_all_access()
	armory_all_access = 0
	to_chat(world, "<font size=4 color='red'>Attention!</font>")
	to_chat(world, "<font color='red'>Crew weapon restrictions enabled. Lethal weaponry now requires official permit to be wielded by non-authorized personnel, or will be met with repercussions.</font>")

/obj/machinery/door/airlock/allowed(mob/Z) ///obj/machinery/door/window
	if(armory_all_access && src.check_access_list(list(access_armory, access_weapons)))
		return 1
	return ..(Z)

/obj/machinery/door/window/allowed(mob/C)
	if(armory_all_access && src.check_access_list(list(access_armory, access_weapons, access_security)))
		return 1
	return ..(C)


/obj/structure/closet/allowed(mob/X)
	if(armory_all_access && src.check_access_list(list(access_armory, access_weapons, access_security)))
		return 1
	return ..(X)

/obj/item/weapon/storage/lockbox/allowed(mob/V)
	if(armory_all_access && src.check_access_list(list(access_armory, access_weapons, access_security, access_brig)))
		return 1
	return ..(V)
