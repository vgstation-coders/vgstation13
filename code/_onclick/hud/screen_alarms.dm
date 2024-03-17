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
		new_alert.category = category
		new_alert.owner = src
		new_alert.override_alerts = override
		if(override)
			new_alert.timeout = null

	if(new_master)
		var/old_layer = new_master.layer
		var/old_plane = new_master.plane
		new_master.layer = FLOAT_LAYER
		new_master.plane = FLOAT_PLANE
		new_alert.overlays += new_master
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
	return new_alert

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/obj/abstract/screen/alert/alert = alerts[category]
	if(!alert)
		return FALSE
	if(alert.override_alerts && !clear_override)
		return FALSE
	qdel(alert)

/mob/proc/clear_all_alerts()
	for(var/category in alerts)
		clear_alert(category)


// PRIVATE = only edit, use, or override these if you're editing the system as a whole

var/global/list/screen_alarms_locs = list(
	1 = ui_alert1,
	2 = ui_alert2,
	3 = ui_alert3,
	4 = ui_alert4,
	5 = ui_alert5
	)

//Re-render all alerts
/datum/hud/proc/reorganize_alerts()
	var/list/mobalerts = mymob.alerts
	var/icon_pref
	if(!mobalerts.len)
		return FALSE
	if(!hud_shown)
		for(var/i = 1, i <= mobalerts.len, i++)
			mymob.client.screen -= mobalerts[mobalerts[i]]
		return TRUE
	for(var/i in 1 to mobalerts.len)
		if(mobalerts[i] == "mob_cryo")
			mobalerts.Swap(i, 1)
	for(var/i = 1, i <= mobalerts.len, i++)
		if(i > screen_alarms_locs.len)
			break
		var/obj/abstract/screen/alert/alert = mobalerts[mobalerts[i]]
		if(alert.icon_state == "template")
			if(!icon_pref)
				icon_pref = ui_style2icon(mymob.client.prefs.UI_style)
			alert.icon = icon_pref
		alert.screen_loc = screen_alarms_locs[i]
		mymob.client.screen |= alert
	return TRUE

//Alarms defines
#define FIRE_ALARM_SAFE 0
#define FIRE_ALARM_FROSTBITE 1
#define FIRE_ALARM_ON_FIRE 2

#define TEMP_ALARM_SAFE 0
#define TEMP_ALARM_COLD_WEAK -2
#define TEMP_ALARM_COLD_MILD -3
#define TEMP_ALARM_COLD_STRONG -4
#define TEMP_ALARM_HEAT_WEAK 2
#define TEMP_ALARM_HEAT_MILD 3
#define TEMP_ALARM_HEAT_STRONG 4

#define SCREEN_ALARM_BUCKLE "mob_buckle"
#define SCREEN_ALARM_CRYO "mob_cryo"
#define SCREEN_ALARM_PRESSURE "mob_pressure"
#define SCREEN_ALARM_TEMPERATURE "mob_temp"
#define SCREEN_ALARM_FIRE "mob_fire"
#define SCREEN_ALARM_TOXINS "mob_toxins"
#define SCREEN_ALARM_BREATH "mob_breath"
#define SCREEN_ALARM_FOOD "mob_food"
#define SCREEN_ALARM_SLEEP "mob_sleep"

#define SCREEN_ALARM_ROBOT_CELL "robot_cell"
#define SCREEN_ALARM_ROBOT_LAW "robot_law"
#define SCREEN_ALARM_ROBOT_HACK "robot_hack"
#define SCREEN_ALARM_ROBOT_LOCK "robot_lock"
#define SCREEN_ALARM_ROBOT_MODULELOCK "robot_modulelock"
#define SCREEN_ALARM_ROBOT_RESET "robot_reset"

#define SCREEN_ALARM_APC_HACKING "apc_hacking"

#define SCREEN_ALARM_NAMEPICK "namepick"

/obj/abstract/screen/alert
	name = "Alert"
	desc = "Something seems to have gone wrong with this alert, so report this bug please."
	icon = 'icons/mob/screen_alarms.dmi'
	icon_state = "default"
	mouse_opacity = TRUE
	var/severity
	var/mob/owner
	var/category
	var/timeout = null //If set to a number, this alert will clear itself after that many deciseconds
	var/override_alerts = FALSE //If it is overriding other alerts of the same type
	var/alerttooltipstyle = null
	var/emph = FALSE //Whether to have a flashy outline

/obj/abstract/screen/alert/New()
	..()
	if(timeout)
		add_timer(new /callback(src, nameof(src::qdel_self())), timeout)
	if(emph)
		overlays.Add(image('icons/mob/screen_alarms.dmi', icon_state = "emph_outline"))

/obj/abstract/screen/alert/proc/qdel_self()
	qdel(src)

/obj/abstract/screen/alert/Destroy()
	if(owner)
		owner.alerts -= category
		if(owner.client && owner.hud_used)
			owner.hud_used.reorganize_alerts()
			owner.client.screen -= src
		owner = null
	..()

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

/obj/abstract/screen/alert/object/cryo
	name = "Cryogenics"
	desc = "You're frozen inside a cryogenics tube. Click on this alert to engage the release sequence."

/obj/abstract/screen/alert/object/cryo/Click(location, control, params)
	. = ..()
	var/obj/machinery/atmospherics/unary/cryo_cell/C = master
	if(C)
		if(!C.on)
			return C.go_out(ejector = usr) //If the cryo tube is off, exit normally.
		return C.AltClick(usr) //Otherwise, use the 30 second exit method.

/obj/abstract/screen/alert/object/buckled
	name = "Buckled"
	desc = "You've been buckled to something and can't move. Click on this alert to unbuckle."

/obj/abstract/screen/alert/object/buckled/coffin/Click(location, control, params)
	if(!usr || !usr.client)
		return
	var/paramslist = params2list(params)
	if(paramslist["shift"])
		to_chat(usr, "<span class='notice'>[name]</span> - <span class='info'>[desc]</span>")
		return
	if(master && istype(master, /obj/structure/closet/coffin))
		var/obj/structure/closet/coffin/C = master
		C.unbuckle_to(get_turf(C))

//Carbon Alarms
/obj/abstract/screen/alert/carbon/breath
	name = "Suffocating"
	desc = "Find some good air before you pass out!"
	icon_state = "carbon_oxy"

/obj/abstract/screen/alert/tox
	name = "Toxins"
	desc = "Your body is exposed to either environmental toxins or radiation poisoning."
	icon_state = "carbon_tox"

/obj/abstract/screen/alert/carbon/burn
	icon_state = "carbon_burn"

/obj/abstract/screen/alert/carbon/burn/fire
	name = "On Fire"
	desc = "Your body is on fire. Click on this alert to stop, drop and roll."

/obj/abstract/screen/alert/carbon/burn/fire/Click()
	..()
	if(isliving(usr))
		var/mob/living/M = usr
		M.resist()

/obj/abstract/screen/alert/carbon/burn/ice
	name = "Frostbite"
	desc = "Your body is exposed to temperatures below freezing point."

/obj/abstract/screen/alert/carbon/temp
	icon_state = "carbon_temp"

/obj/abstract/screen/alert/carbon/temp/hot
	name = "Too Hot"
	desc = "You're flaming hot!"

/obj/abstract/screen/alert/carbon/temp/cold
	name = "Too Cold"
	desc = "You're freezing cold!"

/obj/abstract/screen/alert/carbon/pressure
	icon_state = "carbon_pressure"

/obj/abstract/screen/alert/carbon/pressure/low
	name = "Low Pressure"
	desc = "The air around you is hazardously thin."

/obj/abstract/screen/alert/carbon/pressure/high
	name = "High Pressure"
	desc = "The air around you is hazardously thick."

/obj/abstract/screen/alert/carbon/food
	icon_state = "nutrition"

/obj/abstract/screen/alert/carbon/food/fat
	name = "Fat"
	desc = "You ate too much food, lardass."

/obj/abstract/screen/alert/carbon/food/hungry
	name = "Hungry"
	desc = "Some food would be good right about now."

/obj/abstract/screen/alert/carbon/food/starving
	name = "Starving"
	desc = "You're severely malnourished. The hunger pains make moving around a chore."

/obj/abstract/screen/alert/carbon/i_slep
	name = "Sleeping"
	desc = "You're fast asleep."
	icon_state = "asleep"

//Corgi Alarms
/obj/abstract/screen/alert/carbon/breath/corgi
	icon_state = "corgi_oxy"

/obj/abstract/screen/alert/tox/corgi
	icon_state = "corgi_tox"

/obj/abstract/screen/alert/carbon/burn/fire/corgi
	icon_state = "corgi_burn"

/obj/abstract/screen/alert/carbon/burn/ice/corgi
	icon_state = "corgi_freeze"

//Alien Alarms
/obj/abstract/screen/alert/carbon/breath/alien
	icon_state = "alien_oxy"

/obj/abstract/screen/alert/tox/alien
	icon_state = "alien_tox"

/obj/abstract/screen/alert/carbon/burn/fire/alien
	icon_state = "alien_burn"

//Cult Alarms
/obj/abstract/screen/alert/carbon/burn/fire/construct
	icon_state = "construct_burn"
	desc = "The heat is too intense even for your obsidian body."

//Spider Alarms
/obj/abstract/screen/alert/carbon/burn/fire/spider
	icon_state = "spider_burn"
	desc = "You are on fire."

//Silicon Alarms
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

/obj/abstract/screen/alert/robot/apc_hacking
	icon_state = "hacking"
	name = "Overriding APC"
	desc = "You are currently hacking an APC. Click this alert to jump to the APC."
	var/obj/machinery/power/apc/apc = null

/obj/abstract/screen/alert/robot/apc_hacking/Click()
	..()
	if(!isAI(usr))
		return
	var/mob/living/silicon/ai/A = usr
	if(A.eyeobj)
		A.eyeobj.forceMove(apc.loc)

/obj/abstract/screen/alert/robot/hacked
	name = "Hacked"
	desc = "Hazardous non-standard equipment detected. Please ensure any usage of this equipment is in line with this unit's laws, if any."
	icon_state = "hacked"

/obj/abstract/screen/alert/robot/locked
	name = "Locked Down"
	desc = "This unit has been remotely locked down."
	icon_state = "locked"

/obj/abstract/screen/alert/robot/modulelocked
	name = "Locked Down"
	desc = "This modules on this unit have been remotely locked down."
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

/obj/abstract/screen/alert/name_pick
	name = "Pick a name"
	desc = "Click here to change your name."
	icon_state = "text"
	timeout = 60 SECONDS
	emph = TRUE
	var/namepick_message
	var/role
	var/allow_numbers

/obj/abstract/screen/alert/name_pick/Click()
	..()
	var/mob/living/L = usr
	if(L.alerts[SCREEN_ALARM_NAMEPICK] == src)
		L.clear_alert(SCREEN_ALARM_NAMEPICK)
		L.rename_self(role, allow_numbers, namepick_message)

/proc/mob_rename_self(mob/user, role, namepick_message, allow_numbers = FALSE)
	var/obj/abstract/screen/alert/name_pick/name_pick = user.throw_alert(SCREEN_ALARM_NAMEPICK, /obj/abstract/screen/alert/name_pick)
	name_pick.namepick_message = namepick_message
	name_pick.role = role
	name_pick.allow_numbers = allow_numbers

/obj/abstract/screen/alert/robot/reset_self
	name = "Reset your module"
	desc = "Click here to reset your module."
	icon_state = "module_reset"
	timeout = 60 SECONDS
	emph = TRUE

/obj/abstract/screen/alert/robot/reset_self/Click()
	..()
	var/mob/living/silicon/robot/R = usr
	R.install_upgrade(R, /obj/item/borg/upgrade/reset)
	qdel(src)
