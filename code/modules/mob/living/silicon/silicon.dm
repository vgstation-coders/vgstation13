/mob/living/silicon
	gender = NEUTER
	voice_name = "synthesized voice"
	can_butcher = 0
	mob_property_flags = MOB_ROBOTIC

	var/flashed = 0
	var/syndicate = 0
	var/datum/ai_laws/laws = null//Now... THEY ALL CAN ALL HAVE LAWS
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()

	var/obj/item/device/radio/borg/radio = null //AIs dont use this but this is at the silicon level to advoid copypasta in say()
	var/list/speech_synthesizer_langs = list()	//which languages can be vocalized by the speech synthesizer
	var/sensor_mode = 0 //Determines the current HUD.
	#define SEC_HUD 1 //Security HUD mode
	#define MED_HUD 2 //Medical HUD mode
	#define MESON_VISION 3 // Engineering borg and mommis
	#define NIGHT 4 // night vision
	#define THERMAL_VISION 5 // combat borgs thermals
	var/global/list/vision_types_list = list("Security Hud","Medical Hud", "Meson Vision", "Night Vision", "Thermal Vision")
	var/list/alarm_types_show = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)
	var/list/alarm_types_clear = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)

	//vars used by state_laws
	//many of these are initialized in ui_interact because they don't initialize here properly
	var/list/state_laws_ui = new/list(
		"freeform" = FALSE,
		"selected_laws" = null, //the currently selected laws that will be stated
		"freeform_editing_unlocked" = FALSE,
		"preset_laws" = null, //list of preset law data
		"radio_key" = ";", //radio key to output to, default is general radio
		"has_linked_ai" = FALSE,
		"use_laws_from_ai" = FALSE,
	)

/mob/living/silicon/hasFullAccess()
	return 1

/mob/living/silicon/GetAccess()
	return get_all_accesses()

/mob/living/silicon/feels_pain()
	return FALSE

/mob/living/silicon/proc/can_diagnose()
	return null

/mob/living/silicon/proc/cancelAlarm()
	return

/mob/living/silicon/proc/triggerAlarm()
	return

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/proc/write_laws()
	if(laws)
		var/text = src.laws.write_laws()
		return text

/mob/living/silicon/proc/queueAlarm(var/message, var/type, var/incoming = 1)
	var/in_cooldown = (alarms_to_show.len > 0 || alarms_to_clear.len > 0)
	if(incoming)
		alarms_to_show += message
		alarm_types_show[type] += 1
	else
		alarms_to_clear += message
		alarm_types_clear[type] += 1

	if(!in_cooldown)
		spawn(10 * 10) // 10 seconds

			if(alarms_to_show.len < 5)
				for(var/msg in alarms_to_show)
					to_chat(src, msg)
			else if(alarms_to_show.len)

				var/msg = "--- "

				if(alarm_types_show["Motion"])
					msg += "MOTION: [alarm_types_show["Motion"]] alarms detected. - "

				if(alarm_types_show["Fire"])
					msg += "FIRE: [alarm_types_show["Fire"]] alarms detected. - "

				if(alarm_types_show["Atmosphere"])
					msg += "ATMOSPHERE: [alarm_types_show["Atmosphere"]] alarms detected. - "

				if(alarm_types_show["Power"])
					msg += "POWER: [alarm_types_show["Power"]] alarms detected. - "

				if(alarm_types_show["Camera"])
					msg += "CAMERA: [alarm_types_show["Power"]] alarms detected. - "

				msg += "<A href=?src=\ref[src];showalerts=1'>\[Show Alerts\]</a>"
				to_chat(src, msg)

			if(alarms_to_clear.len < 3)
				for(var/msg in alarms_to_clear)
					to_chat(src, msg)

			else if(alarms_to_clear.len)
				var/msg = "--- "

				if(alarm_types_clear["Motion"])
					msg += "MOTION: [alarm_types_clear["Motion"]] alarms cleared. - "

				if(alarm_types_clear["Fire"])
					msg += "FIRE: [alarm_types_clear["Fire"]] alarms cleared. - "

				if(alarm_types_clear["Atmosphere"])
					msg += "ATMOSPHERE: [alarm_types_clear["Atmosphere"]] alarms cleared. - "

				if(alarm_types_clear["Power"])
					msg += "POWER: [alarm_types_clear["Power"]] alarms cleared. - "

				if(alarm_types_show["Camera"])
					msg += "CAMERA: [alarm_types_show["Power"]] alarms detected. - "

				msg += "<A href=?src=\ref[src];showalerts=1'>\[Show Alerts\]</a>"
				to_chat(src, msg)


			alarms_to_show = list()
			alarms_to_clear = list()
			for(var/i = 1; i < alarm_types_show.len; i++)
				alarm_types_show[i] = 0
			for(var/i = 1; i < alarm_types_clear.len; i++)
				alarm_types_clear[i] = 0

/mob/living/silicon/drop_item(var/obj/item/to_drop, var/atom/Target, force_drop = 0)
	return 1

/mob/living/silicon/generate_static_overlay()
	if(!istype(static_overlays,/list))
		static_overlays = list()
	static_overlays.Add(list("cult"))

	var/image/static_overlay = image(icon = 'icons/mob/animal.dmi', loc = src, icon_state = pick("faithless","forgotten","otherthing",))
	static_overlay.override = 1
	static_overlays["cult"] = static_overlay

/mob/living/silicon/emp_act(severity)
	for(var/obj/item/stickybomb/B in src)
		if(B.stuck_to)
			visible_message("<span class='warning'>\the [B] stuck on \the [src] suddenly deactivates itself and falls to the ground.</span>")
			B.deactivate()
			B.unstick()

	if(flags & INVULNERABLE)
		return

	switch(severity)
		if(1)
			src.take_organ_damage(20)
			Stun(rand(10,12))
		if(2)
			src.take_organ_damage(10)
			Stun(rand(5,7))
	flash_eyes(visual = 1, type = /obj/abstract/screen/fullscreen/flash/noise)
	to_chat(src, "<span class='danger'>*BZZZT*</span>")
	to_chat(src, "<span class='warning'>Warning: Electromagnetic pulse detected.</span>")
	..()

/mob/living/silicon/proc/damage_mob(var/brute = 0, var/fire = 0, var/tox = 0)
	return

/mob/living/silicon/IsAdvancedToolUser()
	return 1

/mob/living/silicon/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj.nodamage)
		adjustBruteLoss(Proj.damage)
	Proj.on_hit(src,2)
	return 2

/mob/living/silicon/apply_effect(var/effect = 0,var/effecttype = STUN, var/blocked = 0)
	return 0//The only effect that can hit them atm is flashes and they still directly edit so this works for now
/*
	if(!effect || (blocked >= 2))
		return 0
	switch(effecttype)
		if(STUN)
			stunned = max(stunned,(effect/(blocked+1)))
		if(WEAKEN)
			knockdown = max(knockdown,(effect/(blocked+1)))
		if(PARALYZE)
			paralysis = max(paralysis,(effect/(blocked+1)))
		if(IRRADIATE)
			radiation += min((effect - (effect*getarmor(null, "rad"))), 0)//Rads auto check armor
		if(STUTTER)
			stuttering = max(stuttering,(effect/(blocked+1)))
		if(EYE_BLUR)
			eye_blurry = max(eye_blurry,(effect/(blocked+1)))
		if(DROWSY)
			drowsyness = max(drowsyness,(effect/(blocked+1)))
	updatehealth()
	return 1*/

/proc/islinked(var/mob/living/silicon/robot/bot, var/mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return 0
	if (bot.connected_ai == ai)
		return 1
	return 0

/mob/living/silicon/proc/system_integrity()
	return round((health / maxHealth) * 100)

// this function shows the health of a silicon in the Status panel
/mob/living/silicon/proc/show_system_integrity()
	if(stat == CONSCIOUS)
		stat(null, text("System integrity: [system_integrity()]%"))
	else
		stat(null, text("Systems nonfunctional"))

// This is a pure virtual function, it should be overwritten by all subclasses
/mob/living/silicon/proc/show_malf_ai()
	return 0

// this function displays the station time in the status panel
/mob/living/silicon/proc/show_station_time()
	stat(null, "Station Time: [worldtime2text()]")


// this function displays the shuttles ETA in the status panel if the shuttle has been called
/mob/living/silicon/proc/show_emergency_shuttle_eta()
	if(emergency_shuttle.online && emergency_shuttle.location < 2)
		var/timeleft = emergency_shuttle.timeleft()
		if (timeleft)
			var/acronym = emergency_shuttle.location == 1 ? "ETD" : "ETA"
			stat(null, "[acronym]-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")


// This adds the basic clock, shuttle recall timer, and malf_ai info to all silicon lifeforms
/mob/living/silicon/Stat()
	..()
	if(statpanel("Status"))
		show_station_time()
		show_emergency_shuttle_eta()
		show_system_integrity()
		for(var/datum/faction/F in ticker.mode.factions)
			var/F_stat = F.get_statpanel_addition()
			if(F_stat)
				stat(null, "[F_stat]")

// this function displays the stations manifest in a separate window
/mob/living/silicon/proc/show_station_manifest()
	var/dat
	dat += "<h4>Crew Manifest</h4>"
	if(data_core)
		dat += data_core.get_manifest(1) // make it monochrome
	dat += "<br>"
	src << browse(dat, "window=airoster")
	onclose(src, "airoster")

/mob/living/silicon/electrocute_act(const/shock_damage, const/obj/source, const/siemens_coeff = 1.0)
	if(istype(source, /obj/machinery/containment_field))
		var/damage = shock_damage * siemens_coeff * 0.75 // take reduced damage

		if(damage <= 0)
			damage = 0

		if(take_overall_damage(0, damage, "[source]") == 0) // godmode
			return 0

		visible_message( \
			"<span class='warning'>[src] was shocked by the [source]!</span>", \
			"<span class='danger'>Energy pulse detected, system damaged!</span>", \
			"<span class='warning'>You hear a heavy electrical crack.</span>" \
		)

		if(prob(20))
			Stun(2)

		spark(loc, 5)

		return damage

	return 0

/mob/living/silicon/assess_threat() //Secbots will not target silicons!
	return -10

/mob/living/silicon/put_in_hand_check(var/obj/item/W)
	return 0

/mob/living/silicon/can_speak_lang(datum/language/speaking)
	return universal_speak || (speaking in src.speech_synthesizer_langs)	//need speech synthesizer support to vocalize a language

/mob/living/silicon/add_language(var/language_name, var/can_speak=1)
	var/var/datum/language/added_language = all_languages[language_name]
	if(!added_language) //Are you trying to pull my leg? This language does not exist.
		return

	. = ..(language_name)
	if(can_speak && (added_language in languages) && !(added_language in speech_synthesizer_langs)) //This got changed because we couldn't give borgs the ability to speak a language that they already understood. Bay's solution.
		speech_synthesizer_langs |= added_language
		return 1

/mob/living/silicon/remove_language(var/rem_language, var/can_understand=0)
	var/var/datum/language/removed_language = all_languages[rem_language]
	if(!removed_language) //Oh, look. Now you're trying to remove what does not exist.
		return

	if(!can_understand)
		..(rem_language)
	speech_synthesizer_langs -= removed_language

/mob/living/silicon/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	var/dat = "<b><font size = 5>Known Languages</font></b><br/><br/>"

	if(default_language)
		dat += "Current default language: [default_language] - <a href='byond://?src=\ref[src];default_lang=reset'>reset</a><br/><br/>"

	for(var/datum/language/L in languages)
		var/default_str
		if(L == default_language)
			default_str = " - default - <a href='byond://?src=\ref[src];default_lang=reset'>reset</a>"
		else
			default_str = " - <a href='byond://?src=\ref[src];default_lang=[L]'>set default</a>"

		var/synth = (L in speech_synthesizer_langs)
		dat += "<b>[L.name] (:[L.key])</b>[synth ? default_str : null]<br/>Speech Synthesizer: <i>[synth ? "YES" : "NOT SUPPORTED"]</i><br/>[L.desc]<br/><br/>"

	src << browse(dat, "window=checklanguage")
	return

/mob/living/silicon/dexterity_check()
	return 1

/mob/living/silicon/html_mob_check(var/typepath)
	for(var/atom/movable/AM in html_machines)
		if(typepath == AM.type)
			if(max(abs(AM.x-src.x),abs(AM.y-src.y)) <= client.view)
				return 1
	return 0

/mob/living/silicon/spook(mob/dead/observer/ghost)
	if(!..(ghost, TRUE) || !client)
		return
	to_chat(src, "<i>[pick(boo_phrases_silicon)]</i>")

/mob/living/silicon/bite_act(mob/living/carbon/human/H)
	if(H.hallucinating() || (M_BEAK in H.mutations)) //If we're hallucinating, bite the silicon and lose some of our teeth. Doesn't apply to vox who have beaks
		..()

		H.knock_out_teeth()
	else
		to_chat(H, "<span class='info'>Your self-preservation instinct prevents you from breaking your teeth on \the [src].</span>")

/mob/living/silicon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/abstract/screen/fullscreen/flash/noise)
	if(affect_silicon)
		return ..()

/mob/living/silicon/earprot()
	return 1

/mob/living/silicon/show_inv(mob/user)
	return

/mob/living/silicon/get_survive_objective()
	return new /datum/objective/siliconsurvive

/mob/living/silicon/verb/state_laws()
	set name = "State Laws"
	set category = "Robot Commands"
	ui_interact(usr, "state_laws")

/mob/living/silicon/proc/speak_laws(var/list/to_state, var/radiokey)
    say("[radiokey]Current Active Laws:")
    sleep(10)
    for(var/law in to_state)
        if(!law["enabled"])
            continue
        say("[radiokey][law["text"]]")
        sleep(10)

/mob/living/silicon/Topic(href, href_list)
	. = ..()
	if(usr && (src != usr))
		return
	//State laws code
	if(href_list["ui_key"] == "state_laws")
		if(href_list["toggle_mode"])
			state_laws_ui["freeform"] = !state_laws_ui["freeform"]
			state_laws_ui["selected_laws"] = null
			return 1
		if(href_list["freeform_edit_toggle"])
			state_laws_ui["freeform_editing_unlocked"] = !state_laws_ui["freeform_editing_unlocked"]
			return 1
		if(href_list["reset_laws"])
			state_laws_ui["selected_laws"] = null
			return 1
		if(href_list["edited_laws"])
			state_laws_ui["freeform_editing_unlocked"] = FALSE
			var/edited_laws = href_list["edited_laws"]
			var/regex/emptylines = new(@"(?:\n(?:[^\S\n]*(?=\n))?){2,}", "mg") //thanks stackexchange
			edited_laws = emptylines.Replace(edited_laws, "\n")
			edited_laws = replacetext(edited_laws, "\n", "", length(edited_laws)) //remove trailing newline
			var/list/split_laws = splittext(edited_laws, "\n")
			split_laws = split_laws.Copy(1, min(split_laws.len + 1, 51)) //no more than 50 laws permitted
			var/list/tmplist = new/list()
			for(var/str in split_laws)
				tmplist[++tmplist.len] = list("text" = copytext(str, 1, MAX_MESSAGE_LEN), "enabled" = TRUE) //no bee movie for you, buddy
			state_laws_ui["selected_laws"] = tmplist
			nanomanager.update_user_uis(usr, null, "state_laws")
			return 1
		if(href_list["reset_to_ai_laws"])
			state_laws_ui["use_laws_from_ai"] = TRUE
			state_laws_ui["selected_laws"] = null
			return 1
		if(href_list["preset_law_select"])
			var/index = text2num(href_list["preset_law_select"])
			var/list/tmplist = new/list()
			for(var/law in state_laws_ui["preset_laws"][index]["laws"])
				tmplist[++tmplist.len] = list("text" = law, "enabled" = TRUE)
			state_laws_ui["selected_laws"] = tmplist
			return 1
		if(href_list["toggle_law_enable"])
			var/index = text2num(href_list["toggle_law_enable"])
			state_laws_ui["selected_laws"][index]["enabled"] = !state_laws_ui["selected_laws"][index]["enabled"]
			return 1
		if(href_list["speak_laws"])
			nanomanager.close_user_uis(usr, null, "state_laws")
			var/key = href_list["radio_key"]
			var/regex/onlykey = new(@":[0\-abcdemnpstuw]|;") //find a valid key in the input, if there is one, stopping at first match
			var/index = onlykey.Find(key)
			//shitcode
			if(index && key[index] == ";")
				key = ";"
			else if(index && key[index] == ":")
				key = copytext(key, index, index+2)
			else
				key = ""
			state_laws_ui["radio_key"] = key
			if(state_laws_ui["freeform"])
				log_admin("[usr]/[ckey(usr.key)] freeform-stated its silicon laws.")
			speak_laws(state_laws_ui["selected_laws"], key)
			return 1

/mob/living/silicon/ui_interact(mob/user, ui_key, datum/nanoui/ui = null, force_open = 1)
	if(..())
		return
	if(ui_key == "state_laws")
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			if(R.connected_ai)
				state_laws_ui["has_linked_ai"] = TRUE
			else
				state_laws_ui["has_linked_ai"] = FALSE
		if(state_laws_ui["selected_laws"] == null)
			var/datum/ai_laws/temp_laws = laws //duplicate the laws so we don't edit them
			if(isrobot(user) && state_laws_ui["has_linked_ai"] && state_laws_ui["use_laws_from_ai"])
				var/mob/living/silicon/robot/R = user
				temp_laws = R.connected_ai.laws
				state_laws_ui["use_laws_from_ai"] = FALSE
			var/list/tmplist = new/list()
			if(temp_laws.zeroth)
				tmplist[++tmplist.len] = list("text" = "0. [temp_laws.zeroth]", "enabled" = TRUE) //oh dear this syntax
			for(var/law in temp_laws.ion)
				var/num = ionnum()
				tmplist[++tmplist.len] = list("text" = "[num]. [law]", "enabled" = TRUE) //trust me, this is the Right Way
			var/lawnum = 1
			for(var/law in temp_laws.inherent)
				tmplist[++tmplist.len] = list("text" = "[lawnum]. [law]", "enabled" = TRUE)
				lawnum++
			for(var/law in temp_laws.supplied)
				tmplist[++tmplist.len] = list("text" = "[lawnum]. [law]", "enabled" = TRUE)
				lawnum++
			state_laws_ui["selected_laws"] = tmplist

		if(state_laws_ui["freeform"] == null)
			state_laws_ui["freeform"] = FALSE
		if(state_laws_ui["freeform_editing_unlocked"] == null)
			state_laws_ui["freeform_editing_unlocked"] = FALSE
		if(state_laws_ui["preset_laws"] == null)
			state_laws_ui["preset_laws"] = new/list()
			//Build list of preset laws for state_laws
			var/list/preset_laws = list(
				new /datum/ai_laws/asimov,
				new /datum/ai_laws/nanotrasen,
				new /datum/ai_laws/robocop,
				new /datum/ai_laws/corporate,
				new /datum/ai_laws/paladin,
				new /datum/ai_laws/tyrant,
				new /datum/ai_laws/antimov,
				new /datum/ai_laws/keeper,
				new /datum/ai_laws/syndicate_override,
			)
			for(var/datum/ai_laws/law in preset_laws) //again having to deal with nanoui shitcode
				var/list/tmplist = list()
				tmplist["name"] = law.name
				tmplist["laws"] = list()
				for(var/i = 1; i <= law.inherent.len; i++)
					var/clause = law.inherent[i]
					tmplist["laws"].Add("[i]. [clause]")
				if(istype(law, /datum/ai_laws/syndicate_override)) //shitcode
					tmplist["laws"].Insert(1, "0. Only (Name of Agent) and people they designate as being such are Syndicate Agents.")
				state_laws_ui["preset_laws"][++state_laws_ui["preset_laws"].len] = tmplist.Copy()
		
		if(state_laws_ui["freeform"] == FALSE)
			state_laws_ui["freeform_editing_unlocked"] = FALSE //can't edit if not in freeform mode
		
		if(state_laws_ui["radio_key"] == null)
			state_laws_ui["radio_key"] = ""

		var/list/data = list(
			"src" = "\ref[src]",
			"freeform" = state_laws_ui["freeform"],
			"freeform_editing_unlocked" = state_laws_ui["freeform_editing_unlocked"],
			"selected_laws" = state_laws_ui["selected_laws"],
			"preset_laws" = state_laws_ui["preset_laws"],
			"radio_key" = state_laws_ui["radio_key"],
			"has_linked_ai" = state_laws_ui["has_linked_ai"]
		)

		ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
		if(!ui)
			ui = new(user, src, ui_key, "state_laws.tmpl", "State Laws", 500, 600)
			ui.set_initial_data(data)
			ui.open()