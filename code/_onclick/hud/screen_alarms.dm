//A system to manage and display alerts on screen without needing you to do it yourself

//PUBLIC -  call these wherever you want

//Proc to create or update an alert. Returns the alert if the alert is new or updated, 0 if it was thrown already
//category is a text string. Each mob may only have one alert per category; the previous one will be replaced
//alert_type is a type path of the actual alert to throw
//severity is an optional number that will be placed at the end of the icon_state for this alert
//For example, high pressure's icon_state is "highpressure" and can be serverity 1 or 2 to get "highpressure1" or "highpressure2"
//new_master is optional and sets the alert's icon state to "template" in the ui_style icons with the master as an overlay.
//Clicks are forwarded to master
//override makes it so the alert is not replaced until cleared by a clear_alert with clear_override.

/mob/proc/throw_alert(category, alert_type, severity, obj/new_master, override = FALSE)
	if(!category || gcDestroyed)
		return

	var/obj/abstract/screen/alert/new_alert = null

	if(alerts[category])
		new_alert = alerts[category]
		if(new_alert.override_alerts)
			return FALSE
		if(new_master && new_master != new_alert.master)
			clear_alert(category)
			return .()
		else if(!istype(new_alert, alert_type))
			clear_alert(category)
			return .()
		else if(!severity || severity == new_alert.severity)
			if(new_alert.timeout)
				clear_alert(category)
				return .()
			return FALSE
	else
		new_alert = new alert_type()
		new_alert.override_alerts = override
		if(override)
			new_alert.timeout = null

	if(new_master)
		var/old_layer = new_master.layer
		var/old_plane = new_master.plane
		new_master.layer = FLOAT_LAYER
		new_master.plane = FLOAT_PLANE
		new_alert.overlays. += new_master
		new_master.layer = old_layer
		new_master.plane = old_plane
		new_alert.master = new_master
	else
		new_alert.icon_state = "[initial(new_alert.icon_state)][severity]"
		new_alert.severity = severity
	alerts[category] = new_alert

	if(client && hud_used)
		hud_used.reorganize_alerts()
	new_alert.transform = matrix(32, 6, MATRIX_TRANSLATE)
	animate(new_alert, transform = matrix(), time = 2.5, easing = CUBIC_EASING)

	if(new_alert.timeout)
		alert_timeout(new_alert, category)
		new_alert.timeout = world.time + new_alert.timeout - world.tick_lag
	return new_alert

/mob/proc/alert_timeout(var/obj/abstract/screen/alert/alert, category)
	if(!istype(alert) || !category)
		return
	spawn(alert.timeout)
		if(alert.timeout && alerts[category] == alert && world.time >= alert.timeout)
			clear_alert(category)

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/obj/abstract/screen/alert/alert = alerts[category]
	if(!alert)
		return FALSE
	if(alert.override_alerts && !clear_override)
		return FALSE
	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert
	qdel(alert)


// PRIVATE = only edit, use, or override these if you're editing the system as a whole
#define SCREEN_ALARM_LIMIT 5 //Only change this if you're also touching the list bellow.
var/global/list/screen_alarms_lock = list(
	1 = ui_alert1,
	2 = ui_alert2,
	3 = ui_alert3,
	4 = ui_alert4,
	5 = ui_alert5
	)

//Re-render all alerts - also called in /datum/hud/show_hud() because it's needed there
/datum/hud/proc/reorganize_alerts()
	var/list/alerts = mymob.alerts
	var/icon_pref
	if(!hud_shown)
		for(var/i = 1, i <= alerts.len, i++)
			mymob.client.screen -= alerts[alerts[i]]
		return TRUE
	for(var/i = 1, i <= alerts.len, i++)
		if(i > SCREEN_ALARM_LIMIT)
			break
		var/obj/abstract/screen/alert = alerts[alerts[i]]
		if(alert.icon_state == "template")
			if(!icon_pref)
				icon_pref = ui_style2icon(mymob.client.prefs.UI_style)
			alert.icon = icon_pref
		alert.screen_loc = screen_alarms_lock[i]
		mymob.client.screen |= alert
	return TRUE

#undef SCREEN_ALARM_LIMIT


//Alarms defines
#define SCREEN_ALARM_BUCKLE "buckle"
#define SCREEN_ALARM_PRESSURE "pressure"
#define SCREEN_ALARM_TEMPERATURE "temp"
#define SCREEN_ALARM_FIRE "fire"

#define SCREEN_ALARM_ROBOT_CELL "robot_cell"
#define SCREEN_ALARM_ROBOT_LAW "robot_law"
#define SCREEN_ALARM_ROBOT_HACK "robot_hack"
#define SCREEN_ALARM_ROBOT_LOCK "robot_lock"

/obj/abstract/screen/alert
	name = "Alert"
	desc = "Something seems to have gone wrong with this alert, so report this bug please."
	icon = 'icons/mob/screen_alarms.dmi'
	icon_state = "default"
	mouse_opacity = TRUE
	var/timeout = null //If set to a number, this alert will clear itself after that many deciseconds
	var/severity = null
	var/override_alerts = FALSE //If it is overriding other alerts of the same type
	var/alerttooltipstyle = null 

/obj/abstract/screen/alert/Click(location, control, params)
	if(!usr || !usr.client)
		return
	var/paramslist = params2list(params)
	if(paramslist["shift"]) // screen objects don't do the normal Click() stuff so we'll cheat
		to_chat(usr, "<span class='notice'>[name]</span> - <span class='info'>[desc]</span>")
		return
	if(master)
		return usr.client.Click(master, location, control, params)

/obj/abstract/screen/alert/MouseEntered(location,control,params)
	if(!gcDestroyed)
		openToolTip(usr, src, params, title = name, content = desc, theme = alerttooltipstyle)

/obj/abstract/screen/alert/MouseExited()
	closeToolTip(usr)


//Object Alarms
/obj/abstract/screen/alert/object
	icon_state = "template" // We'll set the icon to the client's ui pref in reorganize_alerts()

/obj/abstract/screen/alert/object/buckled
	name = "Buckled"
	desc = "You've been buckled to something and can't move. Click this alert to unbuckle unless you're unable to."

//Robot Alarms
/obj/abstract/screen/alert/robot
	icon_state = "silicon_template"

/obj/abstract/screen/alert/robot/temp
	icon_state = "temp"

/obj/abstract/screen/alert/robot/temp/hot
	name = "Environment: Hot"
	desc = "This unit's temperature meter reads: It's flaming hot!"

/obj/abstract/screen/alert/robot/temp/cold
	name = "Environment: Cold"
	desc = "This unit's temperature meter reads: It's freezing cold!"

/obj/abstract/screen/alert/robot/pressure
	icon_state = "pressure"

/obj/abstract/screen/alert/robot/pressure/low
	name = "Environment: Low Pressure"
	desc = "The air around this unit is hazardously thin."

/obj/abstract/screen/alert/robot/pressure/high
	name = "Environment: High Pressure"
	desc = "The air around this unit is hazardously thick."

/obj/abstract/screen/alert/robot/cell
	name = "Missing Power Cell"
	desc = "This unit has no power cell."
	icon_state = "charge"

/obj/abstract/screen/alert/robot/cell/low
	name = "Low Charge"
	desc = "This unit's power cell is running low."

/obj/abstract/screen/alert/robot/cell/empty
	name = "Out of Power"
	desc = "This unit's power cell has no charge remaining."

/obj/abstract/screen/alert/robot/fire
	name = "On Fire"
	desc = "This unit is on fire."
	icon_state = "silicon_fire"

/obj/abstract/screen/alert/robot/hacked
	name = "Hacked"
	desc = "Hazardous non-standard equipment detected. Please ensure any usage of this equipment is in line with this unit's laws, if any."
	icon_state = "hacked"

/obj/abstract/screen/alert/robot/locked
	name = "Locked Down"
	desc = "This unit has been remotely locked down."
	icon_state = "locked"

/obj/abstract/screen/alert/robot/newlaw
	name = "Law Update"
	desc = "Laws have potentially been uploaded to or removed from this unit. Please be aware of any changes \
so as to remain in compliance with the most up-to-date laws."
	icon_state = "newlaw"
	timeout = 30 SECONDS

/obj/abstract/screen/alert/robot/newlaw/Click()
	..()
	if(!issilicon(usr))
		return
	var/mob/living/silicon/S = usr
	if(S.alerts[SCREEN_ALARM_ROBOT_LAW] == src)
		S.show_laws()
		S.clear_alert(SCREEN_ALARM_ROBOT_LAW)
