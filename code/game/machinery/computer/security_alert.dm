var/list/security_alerts_computers = list()
	
/****************
Security Alerts Computer
This computer is supposed to be the comprehensive list
of automated alarms that security should be made aware of.
This includes SPS alarms, lockbox cracking alarms, camera alarms, 
door alarms, crate cracking alarms, turret engagement warnings,
encoded proximity alarms, you name it.
Alerts are listed as TYPE - TIME - AREA + COORDINATES.
TODO: literally every alarm but SPS alarms.
***************/	
	
/obj/machinery/computer/security_alerts //copied mostly from the bhangometer, see it for comments
	name = "Security Alerts Computer"
	desc = "Lists security alerts from various sensors."
	circuit = "/obj/item/weapon/circuitboard/security_alerts"
	icon_state = "secalert"
	var/list/saved_security_alerts = list()

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
	return src.attack_hand(user)

/obj/machinery/computer/security_alerts/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/security_alerts/attack_hand(mob/user as mob)
	ui_interact(user)

/obj/machinery/computer/security_alerts/update_icon()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	else
		icon_state = "secalert"
	return


/obj/machinery/computer/security_alerts/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if(stat & (BROKEN|NOPOWER)) 
		return

	var/list/data[0]
	var/list/show_alerts = list()
	for(var/list/saved_alerts in saved_security_alerts)
		var/list/alert_data = list()
		alert_data["type"] = saved_alerts["type"]
		alert_data["time"] = saved_alerts["time"]
		alert_data["area"] = saved_alerts["area"]
		alert_data["x"] = saved_alerts["x"]
		alert_data["y"] = saved_alerts["y"]
		alert_data["z"] = saved_alerts["z"]
		show_alerts += list(alert_data)
	data["show_alerts"] = show_alerts

	if(!ui) 
		ui = nanomanager.get_open_ui(user, src, ui_key, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "security_alert.tmpl", name, 400, 200)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
	else
		ui.push_data(data)
		return

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
	return
/obj/machinery/computer/security_alerts/proc/receive_alert(var/x0, var/y0, var/z0, var/alert_type, var/alert_area, var/alert_time, var/verbose = 1)
	if(stat & NOPOWER)
		return
	if(z != z0)
		return
	var/message = "Alert. [alert_type]"
	if(verbose)
		say(message)
	var/list/newalert = list()	
	newalert["type"] = alert_type
	newalert["time"] = alert_time
	newalert["area"] = alert_area
	newalert["x"] = x0
	newalert["y"] = y0
	newalert["z"] = z0
	saved_security_alerts += list(newalert)
	nanomanager.update_uis(src)

/obj/machinery/computer/security_alerts/say_quote(text)
	return "reports, [text]."