var/list/pager_list = list()

/obj/item/device/pager
	name = "station alerts pager"
	desc = "Alerts engineers of any triggered station alarms."
	icon_state = "pager_muted"
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1
	force = 5.0
	w_class = W_CLASS_SMALL
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	starting_materials = list(MAT_IRON = 500, MAT_GLASS = 200)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_SILICON
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_BLUESPACE + "=2"
	slot_flags = SLOT_BELT
	var/muted = TRUE
	var/list/prefs = list("Power","Fire","Atmosphere")
	var/last_alert_time = 0
	var/alert_delay = 10 SECONDS
	var/last_alert = ""

/obj/item/device/pager/New()
	..()
	pager_list += src
	//default pager settings
	prefs["Power"] = "quiet"
	prefs["Fire"] = "loud"
	prefs["Atmosphere"] = "quiet"

/obj/item/device/pager/Destroy()
	pager_list -= src
	..()

/obj/item/device/pager/update_icon()
	icon_state = "pager_[muted?"muted":"inactive"]"

/obj/item/device/pager/attack_self(mob/user)
	interact(user)

/obj/item/device/pager/interact(mob/user)
	var/dat = "<html><head><title>[src]</title></head><body><TT>"
	dat += {"
		<ul>
			<li><b>Atmosphere Alerts: </b>
				[prefs["Atmosphere"] == "silent" ? "<b>Silent</b>" : {"<a href="?src=\ref[src];atmos_prefs=silent">Silent</a>"}]
				[prefs["Atmosphere"] == "quiet" ? "<b>Quiet</b>" 	 : {"<a href="?src=\ref[src];atmos_prefs=quiet">Quiet</a>"}]
				[prefs["Atmosphere"] == "loud" ? "<b>Loud</b>" : {"<a href="?src=\ref[src];atmos_prefs=loud">Loud</a>"}]
			<li><b>Fire Alerts: </b>
				[prefs["Fire"] == "silent" ? "<b>Silent</b>" : {"<a href="?src=\ref[src];fire_prefs=silent">Silent</a>"}]
				[prefs["Fire"] == "quiet" ? "<b>Quiet</b>" 	 : {"<a href="?src=\ref[src];fire_prefs=quiet">Quiet</a>"}]
				[prefs["Fire"] == "loud" ? "<b>Loud</b>" : {"<a href="?src=\ref[src];fire_prefs=loud">Loud</a>"}]
			<li><b>Power Alerts: </b>
				[prefs["Power"] == "silent" ? "<b>Silent</b>" : {"<a href="?src=\ref[src];power_prefs=silent">Silent</a>"}]
				[prefs["Power"] == "quiet" ? "<b>Quiet</b>" 	 : {"<a href="?src=\ref[src];power_prefs=quiet">Quiet</a>"}]
				[prefs["Power"] == "loud" ? "<b>Loud</b>" : {"<a href="?src=\ref[src];power_prefs=loud">Loud</a>"}]
			</li>
		</ul>"}
	dat += "Silent will provide no audible indication of an alert.<BR>"
	dat += "Quiet will announce an alert with no sound effects.<BR>"
	dat += "Loud will announce an alert and play a sound effect.<BR><BR>"
	dat += "Pager status: [muted ? "<A href='byond://?src=\ref[src];toggle_mute'>Muted</A>" : "<A href='byond://?src=\ref[src];toggle_mute'>Active</A>"]<BR>"

	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "\ref[src]", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/item/device/pager/Topic(href, href_list)
	if(!in_range(src,usr) && !isAdminGhost(usr) && !issilicon(usr))
		usr << browse(null, "window=pager")
		return 1
	usr.set_machine(src)
	if("toggle_mute" in href_list)
		toggle_mute()
	else if ("atmos_prefs" in href_list)
		prefs["Atmosphere"] = href_list["atmos_prefs"]
	else if ("fire_prefs" in href_list)
		prefs["Fire"] = href_list["fire_prefs"]
	else if ("power_prefs" in href_list)
		prefs["Power"] = href_list["power_prefs"]
	if (!( master ))
		if (istype(loc, /mob))
			interact(loc)
		else
			updateDialog()
	else
		if (istype(master.loc, /mob))
			interact(master.loc)
		else
			updateDialog()
	add_fingerprint(usr)

/obj/item/device/pager/AltClick(mob/user)
	if(!(user) || !isliving(user))
		return FALSE
	if(user.incapacitated() || !Adjacent(user))
		return FALSE
	toggle_mute(user)

/obj/item/device/pager/proc/toggle_mute(mob/user)
	muted = !muted
	to_chat(user, "You [muted ? ""  : "un"]mute \the [src]")
	update_icon()

/obj/item/device/pager/proc/triggerAlarm(var/class, area/A)
	if(muted)
		return
	var/alarmlevel = prefs[class]
	var/alarmtext = "[class] alarm detected in \the [A]!"
	if(alarmtext == last_alert)
		return
	last_alert = alarmtext
	var/sleeptime = rand(0,3)
	sleep(sleeptime SECONDS) //provides some variety in when the pagers are triggered rather than all firing simultaneously
	icon_state = "pager_active"
	switch(alarmlevel)
		if("silent")
		if("quiet")
			say(alarmtext)
		if("loud")
			say(alarmtext)
			if(world.time - last_alert_time >= alert_delay)
				playsound(src, 'sound/effects/3beep.ogg', 100, 0, 1)
				last_alert_time = world.time
	sleep(3 SECONDS)
	update_icon()

/obj/item/device/pager/emp_act(severity)
	muted = TRUE
	for(var/pref in prefs)
		prefs[pref] = "silent"
	update_icon()
