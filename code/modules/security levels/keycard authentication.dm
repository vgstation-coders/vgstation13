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
	req_one_access = list(access_keycard_auth)
	anchored = 1.0
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

/obj/machinery/keycard_auth/New()
	..()
	authenticators += src

/obj/machinery/keycard_auth/attack_ai(mob/user as mob)
	if(ismalf(user))
		..()
	else
		to_chat(user, "<span class='notice'>The station AI is not to interact with these devices.</span>")

/obj/machinery/keycard_auth/attack_paw(mob/user as mob)
	to_chat(user, "<span class='notice'>You are too primitive to use this device.</span>")
	return

/obj/machinery/keycard_auth/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		to_chat(user, "<span class='notice'>This device is not powered.</span>")
		return
	if(isID(W) || isPDA(W))
		if(check_access(W))
			if(active == 1)
				//This is not the device that made the initial request. It is the device confirming the request.
				if(event_source)
					confirmed = 1

					// All the useful information is in the source device, so copy it over. There's probably a better way to do this.
					event_triggered_by = event_source.event_triggered_by
					event_confirmed_by = usr
					event = event_source.event
					ert_reason = event_source.ert_reason

					playsound(src, get_sfx("card_swipe"), 60, 1, -5)
					to_chat(user, "<span class='notice'>You swipe your ID card to confirm the [event].</span>")

					trigger_event(event)
			else if(screen == 2)
				playsound(src, get_sfx("card_swipe"), 60, 1, -5)
				to_chat(user, "<span class='notice'>You swipe your ID card to request the [event].</span>")

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
	if(user.stat || stat & (NOPOWER|BROKEN|FORCEDISABLE))
		to_chat(user, "<span class='notice'>This device is not powered.</span>")
		return
	if(busy)
		to_chat(user, "<span class='notice'>This device is busy.</span>")
		return

	user.set_machine(src)

	var/dat = "<h1>Keycard Authentication Device</h1>"


	dat += {"This device is used to trigger some high security events. It requires the simultaneous swipe of two high-level ID cards.
		<br><hr><br>"}
	if(screen == 1)

		dat += {"Select an event to trigger:<ul>
			<li><A href='?src=\ref[src];triggerevent=Rainbow alert'>Rainbow alert</A></li>
			<li><A href='?src=\ref[src];triggerevent=Red alert'>Red alert</A></li>"}
		if((get_security_level() in list("red", "delta")))
			dat += "<li><A href='?src=\ref[src];triggerevent=Emergency Response Team'>Emergency Response Team</A></li>"
		else
			dat += "<li>Emergency Response Team (Disabled while below Code Red)</li>"
		dat += {"<li><A href='?src=\ref[src];triggerevent=Grant Emergency Maintenance Access'>Grant Emergency Maintenance Access</A></li>
			<li><A href='?src=\ref[src];triggerevent=Revoke Emergency Maintenance Access'>Revoke Emergency Maintenance Access</A></li>
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
		to_chat(usr, "<span class='notice'>This device is busy.</span>")
		return
	if(usr.stat || stat & (BROKEN|NOPOWER|FORCEDISABLE))
		to_chat(usr, "<span class='notice'>This device is without power.</span>")
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
	busy = 0
	event_source = null
	icon_state = "auth_off"
	event_triggered_by = null
	event_confirmed_by = null

/obj/machinery/keycard_auth/proc/broadcast_request()
	icon_state = "auth_on"
	for(var/obj/machinery/keycard_auth/KA in authenticators)
		if(KA == src)
			continue
		KA.receive_request(src)

/obj/machinery/keycard_auth/proc/receive_request(var/obj/machinery/keycard_auth/source)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		return
	event_source = source
	busy = 1
	active = 1
	icon_state = "auth_on"

	spawn(confirm_delay)
		if(active)
			for(var/obj/machinery/keycard_auth/KA in authenticators)
				KA.reset()

/obj/machinery/keycard_auth/proc/trigger_event()
	switch(event)
		if("Rainbow alert")
			set_security_level(SEC_LEVEL_RAINBOW)
			feedback_inc("alert_keycard_auth_rainbow",1)
		if("Red alert")
			set_security_level(SEC_LEVEL_RED)
			feedback_inc("alert_keycard_auth_red",1)
		if("Grant Emergency Maintenance Access")
			make_doors_all_access(list(access_maint_tunnels))
			feedback_inc("alert_keycard_auth_maintGrant",1)
		if("Revoke Emergency Maintenance Access")
			revoke_doors_all_access(list(access_maint_tunnels))
			feedback_inc("alert_keycard_auth_maintRevoke",1)
		if("Emergency Response Team")
			var/datum/striketeam/ert/response_team = new()
			response_team.mission = ert_reason
			response_team.trigger_strike() // This will show up as *null* in logs, adding requester gives them power to approve an ERT.
			feedback_inc("alert_keycard_auth_ert",1)
			event_source.visible_message("<span class='notice'>An ERT has been requested, please await a response.</span>")
			playsound(event_source, 'sound/machines/notify.ogg', 60, 0)

	log_game("[key_name(event_triggered_by)] triggered and [key_name(event_confirmed_by)] confirmed event [event][event=="Emergency Response Team"?". ERT reason given was '[ert_reason]'":""]")
	message_admins("[key_name(event_triggered_by)] triggered and [key_name(event_confirmed_by)] confirmed event [event][event=="Emergency Response Team"?". ERT reason given was '[ert_reason]'":""]")
	for(var/obj/machinery/keycard_auth/KA in authenticators)
		KA.reset()

var/global/list/all_access_list = list()

/proc/make_doors_all_access(var/list/accesses, var/announce = TRUE)
	all_access_list.Add(accesses)
	if(announce)
		to_chat(world, "<font size=4 color='red'>Attention!</font>")
		to_chat(world, "<span class='red'>The [get_access_desc_list(accesses)] access requirement has been revoked on all airlocks.</span>")

/proc/revoke_doors_all_access(var/list/accesses, var/announce = TRUE)
	all_access_list.Remove(accesses)
	if(announce)
		to_chat(world, "<font size=4 color='red'>Attention!</font>")
		to_chat(world, "<span class='red'>The [get_access_desc_list(accesses)] access requirement has been readded on all airlocks.</span>")

/obj/machinery/door/airlock/allowed(mob/M)
	if(check_access_list(all_access_list))
		return 1
	return ..(M)
