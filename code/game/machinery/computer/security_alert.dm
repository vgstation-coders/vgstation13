var/list/security_alerts_computers = list()
	
/****************
Security Alerts Computer
This computer is supposed to be the comprehensive list
of automated alarms that security should be made aware of.
This includes SPS alarms, lockbox cracking alarms, camera alarms, 
door alarms, crate cracking alarms, turret engagement warnings,
encoded proximity alarms, you name it.
Alerts are listed as TYPE - TIME - AREA + CO,OR,DINATES.
TODO: literally every alarm but SPS alarms.
***************/	
	
/obj/machinery/computer/security_alerts //copied mostly from the bhangometer, see it for comments
	name = "Security Alerts Computer"
	desc = "Lists security alerts from various sensors."
	circuit = "/obj/item/weapon/circuitboard/security_alerts"
	icon_state = "secalert"
	var/list/saved_security_alerts = list()
	var/last_alert_time = 0
	var/muted = FALSE

	hack_abilities = list(
		/datum/malfhack_ability/trigger_sps,
		/datum/malfhack_ability/toggle/mute_sps,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/toggle/disable
	)

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/security_alerts/New()
	..()
	security_alerts_computers += src

/obj/machinery/computer/security_alerts/Destroy()
	security_alerts_computers -= src
	..()

/obj/machinery/computer/security_alerts/process()
	return PROCESS_KILL

/obj/machinery/computer/security_alerts/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/security_alerts/attack_ghost(mob/user as mob)
	ui_interact(user)

/obj/machinery/computer/security_alerts/attack_hand(mob/user as mob)
	add_fingerprint(user)
	ui_interact(user)
	update_icon(showalert = FALSE)

/obj/machinery/computer/security_alerts/update_icon(var/showalert = FALSE)
	..()
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		overlays.Cut()
		return
	else
		icon_state = "secalert"
	if(showalert)
		overlays += image(icon = icon, icon_state = "secalert-newalerts")
	else
		overlays.Cut()


/obj/machinery/computer/security_alerts/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE)) 
		return

	if(!ui) 
		ui = nanomanager.get_open_ui(user, src, ui_key, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "security_alert.tmpl", name, 450, 200)
		ui.set_initial_data(saved_security_alerts)
		ui.open()
		ui.set_auto_update(1)
	else
		ui.push_data(saved_security_alerts)


/obj/machinery/computer/security_alerts/interact(mob/user as mob)
	var/listing = {"
<html>
	<head>
		<title>Nanotrasen Security Alerts Computer</title>
	</head>
	<body>
		<h1>Recent Alerts</h1>
		<table>
			<tr>
				<th>Type</th>
				<th>Time</th>
				<th>Location</th>
			</tr>
"}
	for(var/item in saved_security_alerts)
		listing += item
	listing += {"
		</table>
	</body>
</html>"}
	user << browse(listing, "window=security_alert")
	onclose(user, "security_alert")

/obj/machinery/computer/security_alerts/proc/receive_alert(var/alerttype, var/newdata, var/verbose = 1)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		return
	if(muted)
		return
	if(saved_security_alerts.Find(newdata)) //no need for duplicate entries
		return 
	saved_security_alerts.Insert(1,newdata)
	if(saved_security_alerts.len >= 50) //no need for infinite logs
		pop(saved_security_alerts)
	var/message = "Alert. [alerttype]"
	if(verbose)
		say(message)
	playsound(src,'sound/machines/radioboop.ogg',40,1)
	flick("secalert-update", src)
	nanomanager.update_uis(src)
	update_icon(showalert = TRUE)

/obj/machinery/computer/security_alerts/say_quote(text)
	return "reports, [text]."
