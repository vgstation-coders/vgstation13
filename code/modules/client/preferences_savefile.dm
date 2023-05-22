/// IF YOU NEED A FIELD ADDED TO THE DATABASE, CREATE A MIGRATION SO SHIT GETS UPDATED.
/// Also update SQL/players2.sql.
/// SEE code/modules/migrations/SS13_Prefs/

/datum/preferences/proc/SetChangelog(ckey,hash)
	lastchangelog=hash
	var/database/query/q = new
	q.Add("UPDATE client SET lastchangelog=? WHERE ckey=?",lastchangelog,ckey)
	if(!q.Execute(db))
		message_admins("Error in SetChangelog [__FILE__] ln:[__LINE__] #: [q.Error()] - [q.ErrorMsg()]")
		WARNING("Error in Setchangelog [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
		return 0

/datum/preferences/proc/load_preferences_sqlite(var/ckey)
	var/list/preference_list_client = new
	var/database/query/check = new
	var/database/query/q = new
	check.Add("SELECT ckey FROM client WHERE ckey = ?", ckey)
	if(check.Execute(db))
		if(!check.NextRow())
			message_admins("Error in load_preferences_sqlite [__FILE__] ln:[__LINE__] #: [check.Error()] - [check.ErrorMsg()]")
			WARNING("Error in load_preferences_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
			return 0
	else
		message_admins("Error in load_preferences_sqlite [__FILE__] ln:[__LINE__] #: [check.Error()] - [check.ErrorMsg()]")
		WARNING("Error in load_preferences_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
		return 0
	q.Add("SELECT * FROM client WHERE ckey = ?", ckey)
	if(q.Execute(db))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			for(var/a in row)
				preference_list_client[a] = row[a]
	else
		message_admins("Error in load_preferences_sqlite [__FILE__] ln:[__LINE__] #: [q.Error()] - [q.ErrorMsg()]")
		WARNING("Error in load_preferences_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	ooccolor 		=	preference_list_client["ooc_color"]
	lastchangelog 	= 	preference_list_client["lastchangelog"]
	UI_style 		=	preference_list_client["UI_style"]
	default_slot 	=	text2num(preference_list_client["default_slot"])
	toggles 		=	text2num(preference_list_client["toggles"])
	UI_style_color	= 	preference_list_client["UI_style_color"]
	UI_style_alpha 	= 	text2num(preference_list_client["UI_style_alpha"])
	warns			=	text2num(preference_list_client["warns"])
	warnbans		=	text2num(preference_list_client["warnsbans"])
	volume			=	text2num(preference_list_client["volume"])
	usewmp			=	text2num(preference_list_client["usewmp"])
	special_popup	=	text2num(preference_list_client["special"])
	randomslot		=	text2num(preference_list_client["randomslot"])
	usenanoui		=	text2num(preference_list_client["usenanoui"])
	tooltips		=	text2num(preference_list_client["tooltips"])
	progress_bars	=	text2num(preference_list_client["progress_bars"])
	space_parallax	=	text2num(preference_list_client["space_parallax"])
	space_dust		=	text2num(preference_list_client["space_dust"])
	parallax_speed	=	text2num(preference_list_client["parallax_speed"])
	stumble			=	text2num(preference_list_client["stumble"])
	attack_animation=	text2num(preference_list_client["attack_animation"])
	pulltoggle		=	text2num(preference_list_client["pulltoggle"])
	hear_voicesound = 	text2num(preference_list_client["hear_voicesound"])
	hear_instruments =	text2num(preference_list_client["hear_instruments"])
	ambience_volume	=	text2num(preference_list_client["ambience_volume"])
	headset_sound	= 	text2num(preference_list_client["headset_sound"])
	credits_volume	=	text2num(preference_list_client["credits_volume"])
	credits 		=	preference_list_client["credits"]
	jingle	 		=	preference_list_client["jingle"]
	window_flashing  =	text2num(preference_list_client["window_flashing"])
	antag_objectives =  text2num(preference_list_client["antag_objectives"])
	typing_indicator 	 =  text2num(preference_list_client["typing_indicator"])
	mob_chat_on_map 	 =  text2num(preference_list_client["mob_chat_on_map"])
	max_chat_length 	 =  text2num(preference_list_client["max_chat_length"])
	obj_chat_on_map 	 =  text2num(preference_list_client["obj_chat_on_map"])
	no_goonchat_for_obj  =  text2num(preference_list_client["no_goonchat_for_obj"])
	tgui_fancy           =  text2num(preference_list_client["tgui_fancy"])
	show_warning_next_time = text2num(preference_list_client["show_warning_next_time"])
	last_warned_message = preference_list_client["last_warned_message"]
	warning_admin = preference_list_client["warning_admin"]
	fps = preference_list_client["fps"]

	ooccolor		= 	sanitize_hexcolor(ooccolor, initial(ooccolor))
	lastchangelog	= 	sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= 	sanitize_inlist(UI_style, list("White", "Midnight","Orange","old"), initial(UI_style))
	//be_special		= 	sanitize_integer(be_special, 0, 65535, initial(be_special))
	default_slot	= 	sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	toggles			= 	sanitize_integer(toggles, 0, 131071, initial(toggles))
	UI_style_color	= 	sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha	= 	sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))
	randomslot		= 	sanitize_integer(randomslot, 0, 1, initial(randomslot))
	volume			= 	sanitize_integer(volume, 0, 100, initial(volume))
	usewmp			= 	sanitize_integer(usewmp, 0, 1, initial(usewmp))
	special_popup	= 	sanitize_integer(special_popup, 0, 2, initial(special_popup))
	usenanoui		= 	sanitize_integer(usenanoui, 0, 1, initial(usenanoui))
	progress_bars	= 	sanitize_integer(progress_bars, 0, 1, initial(progress_bars))
	space_parallax	=	sanitize_integer(space_parallax, 0, 1, initial(space_parallax))
	space_dust		=	sanitize_integer(space_dust, 0, 1, initial(space_dust))
	parallax_speed	=	sanitize_integer(parallax_speed, 0, 5, initial(parallax_speed))
	stumble			= 	sanitize_integer(stumble, 0, 1, initial(stumble))
	attack_animation=	sanitize_integer(attack_animation, 0, 65535, initial(attack_animation))
	pulltoggle		=	sanitize_integer(pulltoggle, 0, 1, initial(pulltoggle))
	credits			= 	sanitize_inlist(credits, list(CREDITS_NEVER, CREDITS_ALWAYS, CREDITS_NO_RERUNS), initial(credits))
	jingle			= 	sanitize_inlist(jingle, list(JINGLE_NEVER, JINGLE_CLASSIC, JINGLE_ALL), initial(jingle))
	hear_voicesound = 	sanitize_integer(hear_voicesound, 0, 1, initial(hear_voicesound))
	hear_instruments =	sanitize_integer(hear_instruments, 0, 1, initial(hear_instruments))
	ambience_volume = sanitize_integer(ambience_volume, 0, 100, initial(ambience_volume))
	headset_sound = sanitize_integer(headset_sound, 0, 2, initial(headset_sound))
	credits_volume  = sanitize_integer(credits_volume, 0, 100, initial(credits_volume))
	window_flashing = sanitize_integer(window_flashing, 0, 1, initial(window_flashing))
	antag_objectives =  sanitize_integer(antag_objectives, 0, 1, initial(antag_objectives))
	typing_indicator 	 =  sanitize_integer(typing_indicator, 0, 1, initial(typing_indicator))
	mob_chat_on_map 	 =  sanitize_integer(mob_chat_on_map, 0, 1, initial(mob_chat_on_map))
	max_chat_length 	 =  sanitize_integer(max_chat_length, 0, CHAT_MESSAGE_MAX_LENGTH, initial(max_chat_length))
	obj_chat_on_map 	 =  sanitize_integer(obj_chat_on_map, 0, 1, initial(obj_chat_on_map))
	no_goonchat_for_obj  =  sanitize_integer(no_goonchat_for_obj, 0, 1, initial(no_goonchat_for_obj))
	tgui_fancy           =  sanitize_integer(tgui_fancy, 0, 1, initial(tgui_fancy))
	show_warning_next_time = sanitize_integer(show_warning_next_time, 0, 1, initial(show_warning_next_time))
	fps = sanitize_integer(fps, -1, 1000, initial(fps))
	initialize_preferences()
	return 1

/datum/preferences/proc/initialize_preferences(client_login = 0)
	if(attack_animation == PERSON_ANIMATION)
		person_animation_viewers |= client
		item_animation_viewers -= client
	else if(attack_animation == ITEM_ANIMATION)
		item_animation_viewers |= client
		person_animation_viewers -= client
	else
		item_animation_viewers -= client
		person_animation_viewers -= client

/datum/preferences/proc/save_preferences_sqlite(var/user, var/ckey)
	var/database/query/check = new
	var/database/query/q = new
	check.Add("SELECT ckey FROM client WHERE ckey = ?", ckey)
	if(check.Execute(db))
		if(!check.NextRow())
			q.Add("INSERT into client (ckey, ooc_color, lastchangelog, UI_style, default_slot, toggles, UI_style_color, UI_style_alpha, warns, warnbans, randomslot, volume, usewmp, special, usenanoui, tooltips, progress_bars, space_parallax, space_dust, parallax_speed, stumble, attack_animation, pulltoggle, credits, jingle, hear_voicesound, hear_instruments, ambience_volume, headset_sound, credits_volume, window_flashing, antag_objectives, typing_indicator, mob_chat_on_map, max_chat_length, obj_chat_on_map, no_goonchat_for_obj, tgui_fancy, show_warning_next_time, last_warned_message, warning_admin, fps) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",\
			ckey, ooccolor, lastchangelog, UI_style, default_slot, toggles, UI_style_color, UI_style_alpha, warns, warnbans, randomslot, volume, usewmp, special_popup, usenanoui, tooltips, progress_bars, space_parallax, space_dust, parallax_speed, stumble, attack_animation, pulltoggle, credits, jingle, hear_voicesound, hear_instruments, ambience_volume, headset_sound, credits_volume, window_flashing, antag_objectives, typing_indicator, mob_chat_on_map, max_chat_length, obj_chat_on_map, no_goonchat_for_obj, tgui_fancy, show_warning_next_time, last_warned_message, warning_admin, fps)
			if(!q.Execute(db))
				message_admins("Error in save_preferences_sqlite [__FILE__] ln:[__LINE__] #: [q.Error()] - [q.ErrorMsg()]")
				WARNING("Error in save_preferences_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				return 0
		else
			q.Add("UPDATE client SET ooc_color=?,lastchangelog=?,UI_style=?,default_slot=?,toggles=?,UI_style_color=?,UI_style_alpha=?,warns=?,warnbans=?,randomslot=?,volume=?,usewmp=?,special=?,usenanoui=?,tooltips=?,progress_bars=?,space_parallax=?,space_dust=?,parallax_speed=?, stumble=?, attack_animation=?, pulltoggle=?, credits=?, jingle=?, hear_voicesound=?, hear_instruments=?, ambience_volume=?, headset_sound=?, credits_volume=?, window_flashing=?, antag_objectives=? , typing_indicator=? , mob_chat_on_map=? , max_chat_length=?, obj_chat_on_map=?, no_goonchat_for_obj=?, tgui_fancy=?, show_warning_next_time=?, last_warned_message=?, warning_admin=?, fps=? WHERE ckey = ?",\
			ooccolor, lastchangelog, UI_style, default_slot, toggles, UI_style_color, UI_style_alpha, warns, warnbans, randomslot, volume, usewmp, special_popup, usenanoui, tooltips, progress_bars, space_parallax, space_dust, parallax_speed, stumble, attack_animation, pulltoggle, credits, jingle, hear_voicesound, hear_instruments, ambience_volume, headset_sound, credits_volume, window_flashing, antag_objectives, typing_indicator, mob_chat_on_map, max_chat_length, obj_chat_on_map,no_goonchat_for_obj, tgui_fancy, show_warning_next_time, last_warned_message, warning_admin, fps, ckey)
			if(!q.Execute(db))
				message_admins("Error in save_preferences_sqlite [__FILE__] ln:[__LINE__] #: [q.Error()] - [q.ErrorMsg()]")
				WARNING("Error in save_preferences_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				return 0
	else
		message_admins("Error in save_preferences_sqlite [__FILE__] ln:[__LINE__] #: [check.Error()] - [check.ErrorMsg()]")
		WARNING("Error in save_preferences_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
		return 0
	to_chat(user, "Preferences Updated.")
	lastPolled = world.timeofday
	return 1

/datum/preferences/proc/load_save_sqlite(var/ckey, var/user, var/slot)
	var/list/preference_list = new
	var/database/query/q     = new
	var/database/query/check = new

	check.Add("SELECT player_ckey FROM players WHERE player_ckey = ? AND player_slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())
			to_chat(user, "You have no character file to load, please save one first.")
			WARNING("[__LINE__]: datum/preferences/load_save_sqlite has returned")
			return 0
	else
		message_admins("load_save_sqlite Check Error #: [check.Error()] - [check.ErrorMsg()]")
		WARNING("[__LINE__]: datum/preferences/load_save_sqlite has returned")

		return 0

	q.Add({"
SELECT
    limbs.player_ckey,
    limbs.player_slot,
    limbs.l_arm,
    limbs.r_arm,
    limbs.l_leg,
    limbs.r_leg,
    limbs.l_foot,
    limbs.r_foot,
    limbs.l_hand,
    limbs.r_hand,
    limbs.heart,
    limbs.eyes,
    limbs.lungs,
    limbs.liver,
    limbs.kidneys,
    players.player_ckey,
    players.player_slot,
    players.ooc_notes,
    players.real_name,
    players.random_name,
    players.random_body,
    players.gender,
    players.age,
    players.species,
    players.language,
    players.flavor_text,
    players.med_record,
    players.sec_record,
    players.gen_record,
    players.player_alt_titles,
    players.disabilities,
    players.nanotrasen_relation,
    players.bank_security,
    players.wage_ratio,
    jobs.player_ckey,
    jobs.player_slot,
    jobs.alternate_option,
    jobs.jobs,
    body.player_ckey,
    body.player_slot,
    body.hair_red,
    body.hair_green,
    body.hair_blue,
    body.facial_red,
    body.facial_green,
    body.facial_blue,
    body.skin_tone,
    body.hair_style_name,
    body.facial_style_name,
    body.eyes_red,
    body.eyes_green,
    body.eyes_blue,
    body.underwear,
    body.backbag
FROM
    players
INNER JOIN
    limbs
ON
    (
        players.player_ckey = limbs.player_ckey)
AND (
        players.player_slot = limbs.player_slot)
INNER JOIN
    jobs
ON
    (
        limbs.player_ckey = jobs.player_ckey)
AND (
        limbs.player_slot = jobs.player_slot)
INNER JOIN
    body
ON
    (
        jobs.player_ckey = body.player_ckey)
AND (
        jobs.player_slot = body.player_slot)
WHERE
    players.player_ckey = ?
AND players.player_slot = ? ;"}, ckey, slot)
	if(q.Execute(db))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			for(var/a in row)
				preference_list[a] = row[a]
	else
		message_admins("load_save_sqlite Error #: [q.Error()] - [q.ErrorMsg()]")
		WARNING("[__LINE__]: datum/preferences/load_save_sqlite has returned")
		return 0

	var/list/player_alt_list1 = new
	var/list/player_alt_list2 = new()
	player_alt_list1.Add(splittext(preference_list["player_alt_titles"], ";")) // we're getting the first part of the string for each job.
	for(var/item in player_alt_list1) // iterating through the list
		if(!findtext(item, ":"))
			continue
		var/delim_location = findtext(item, ":") // getting the second part of the string that will be handled for titles
		var/job = copytext(item, 1, delim_location) // getting where the job is, it's in the first slot so we want to get that position.
		var/title = copytext(item, delim_location + 1, 0) // getting where the job title is, it's in the second slot so we want to get that position.
		player_alt_list2[job] = title // we assign the alt_titles here to specific job titles and hope everything works.

	metadata 			= preference_list["ooc_notes"]
	real_name 			= preference_list["real_name"]
	be_random_name 		= text2num(preference_list["random_name"])
	be_random_body 		= text2num(preference_list["random_body"])
	gender 				= preference_list["gender"]
	age 				= text2num(preference_list["age"])
	species				= preference_list["species"]
	language			= preference_list["language"]
	flavor_text			= preference_list["flavor_text"]
	med_record			= preference_list["med_record"]
	sec_record			= preference_list["sec_record"]
	gen_record			= preference_list["gen_record"]
	player_alt_titles	= player_alt_list2
	disabilities		= text2num(preference_list["disabilities"])
	nanotrasen_relation	= preference_list["nanotrasen_relation"]
	bank_security 		= preference_list["bank_security"]
	wage_ratio	 		= preference_list["wage_ratio"]

	r_hair				= text2num(preference_list["hair_red"])
	g_hair				= text2num(preference_list["hair_green"])
	b_hair				= text2num(preference_list["hair_blue"])
	h_style				= preference_list["hair_style_name"]

	r_facial			= text2num(preference_list["facial_red"])
	g_facial			= text2num(preference_list["facial_green"])
	b_facial			= text2num(preference_list["facial_blue"])
	f_style				= preference_list["facial_style_name"]

	r_eyes				= text2num(preference_list["eyes_red"])
	g_eyes				= text2num(preference_list["eyes_green"])
	b_eyes				= text2num(preference_list["eyes_blue"])

	s_tone				= text2num(preference_list["skin_tone"])

	underwear			= text2num(preference_list["underwear"])
	backbag				= text2num(preference_list["backbag"])

	organ_data[LIMB_LEFT_ARM] = preference_list[LIMB_LEFT_ARM]
	organ_data[LIMB_RIGHT_ARM] = preference_list[LIMB_RIGHT_ARM]
	organ_data[LIMB_LEFT_LEG] = preference_list[LIMB_LEFT_LEG]
	organ_data[LIMB_RIGHT_LEG] = preference_list[LIMB_RIGHT_LEG]
	organ_data[LIMB_LEFT_FOOT]= preference_list[LIMB_LEFT_FOOT]
	organ_data[LIMB_RIGHT_FOOT]= preference_list[LIMB_RIGHT_FOOT]
	organ_data[LIMB_LEFT_HAND]= preference_list[LIMB_LEFT_HAND]
	organ_data[LIMB_RIGHT_HAND]= preference_list[LIMB_RIGHT_HAND]
	organ_data["heart"] = preference_list["heart"]
	organ_data["eyes"] 	= preference_list["eyes"]
	organ_data["lungs"] = preference_list["lungs"]
	organ_data["kidneys"]=preference_list["kidneys"]
	organ_data["liver"] = preference_list["liver"]

	alternate_option	= text2num(preference_list["alternate_option"])
	if(preference_list["jobs"] && preference_list["jobs"] != "")
		jobs = json_decode(preference_list["jobs"])
	else
		jobs = list()
	metadata			= sanitize_text(metadata, initial(metadata))
	real_name			= reject_bad_name(real_name)

	if(isnull(species))
		species = "Human"
	if(isnull(language))
		language = "None"
	if(isnull(nanotrasen_relation))
		nanotrasen_relation = initial(nanotrasen_relation)
	if(isnull(bank_security))
		bank_security = initial(bank_security)
	if(isnull(wage_ratio))
		wage_ratio = initial(wage_ratio)
	if(!real_name)
		real_name = random_name(gender,species)
	wage_ratio = clamp(wage_ratio,0,100)

	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	be_random_body	= sanitize_integer(be_random_body, 0, 1, initial(be_random_body))
	gender			= sanitize_gender(gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))

	r_hair			= sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair			= sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair			= sanitize_integer(b_hair, 0, 255, initial(b_hair))

	r_facial		= sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial		= sanitize_integer(g_facial, 0, 255, initial(g_facial))

	b_facial		= sanitize_integer(b_facial, 0, 255, initial(b_facial))
	s_tone			= sanitize_integer(s_tone, -185, 34, initial(s_tone))
	h_style			= sanitize_inlist(h_style, hair_styles_list, initial(h_style))
	f_style			= sanitize_inlist(f_style, facial_hair_styles_list, initial(f_style))

	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))

	underwear		= sanitize_integer(underwear, 1, underwear_m.len, initial(underwear))
	backbag			= sanitize_integer(backbag, 1, backbaglist.len, initial(backbag))
	//be_special      = sanitize_integer(be_special, 0, 65535, initial(be_special))

	alternate_option = sanitize_integer(alternate_option, 0, 2, initial(alternate_option))

	for(var/role_id in special_roles)
		roles[role_id]=0
	q = new
	q.Add("SELECT role, preference FROM client_roles WHERE ckey=? AND slot=?", ckey, slot)
	if(q.Execute(db))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			roles[row["role"]] = text2num(row["preference"])
	else
		message_admins("Error in load_save_sqlite [__FILE__] ln:[__LINE__] #: [q.Error()] - [q.ErrorMsg()]")
		WARNING("[__LINE__]: datum/preferences/load_save_sqlite has returned")
		return 0

	if(!skills)
		skills = list()
	if(!used_skillpoints)
		used_skillpoints= 0
	if(isnull(disabilities))
		disabilities = 0
	if(!player_alt_titles)
		player_alt_titles = new()
	if(!organ_data)
		src.organ_data = list()

	if(user)
		to_chat(user, "Successfully loaded [real_name].")

	return 1

/datum/preferences/proc/random_character_sqlite(var/user, var/ckey)
	var/database/query/q = new
	var/list/slot_list = new
	q.Add("SELECT player_slot FROM players WHERE player_ckey=?", ckey)
	if(q.Execute(db))
		while(q.NextRow())
			slot_list.Add(q.GetColumn(1))
	else
		message_admins("Error in random_character_sqlite [__FILE__] ln:[__LINE__] #: [q.Error()] - [q.ErrorMsg()]")
		WARNING("Error in random_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
		return 0
	var/random_slot = pick(slot_list)
	load_save_sqlite(ckey, user, random_slot)
	return 1

/datum/preferences/proc/save_character_sqlite(var/ckey, var/user, var/slot)
	if(slot > MAX_SAVE_SLOTS)
		to_chat(user, "You are limited to 8 character slots.")
		message_admins("[ckey] attempted to override character slot limit")
		return 0

	var/database/query/q = new
	var/database/query/check = new

	var/altTitles

	// The FUCK is this shit
	for(var/a in player_alt_titles)
		altTitles += "[a]:[player_alt_titles[a]];"

	check.Add("SELECT player_ckey FROM players WHERE player_ckey = ? AND player_slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())
			q.Add("INSERT INTO players (player_ckey,player_slot,ooc_notes,real_name, random_name,    gender, age, species, language, flavor_text, med_record, sec_record, gen_record, player_alt_titles, disabilities, nanotrasen_relation, bank_security, wage_ratio, random_body)\
			                    VALUES (?,          ?,          ?,        ?,         ?,              ?,      ?,   ?,       ?,        ?,           ?,          ?,          ?,          ?,                 ?,            ?,                   ?,             ?,          ?)",
			                            ckey,       slot,       metadata, real_name, be_random_name, gender, age, species, language, flavor_text, med_record, sec_record, gen_record, altTitles,         disabilities, nanotrasen_relation, bank_security, wage_ratio, be_random_body)
			if(!q.Execute(db))
				message_admins("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				WARNING("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			to_chat(user, "Created Character")
		else
			q.Add("UPDATE players SET ooc_notes=?,real_name=?,random_name=?,  gender=?,age=?,species=?,language=?,flavor_text=?,med_record=?,sec_record=?,gen_record=?,player_alt_titles=?,disabilities=?,nanotrasen_relation=?,bank_security=?,wage_ratio=?,random_body=?   WHERE player_ckey = ? AND player_slot = ?",\
									  metadata,   real_name,  be_random_name, gender,  age,  species,  language,  flavor_text,  med_record,  sec_record,  gen_record,  altTitles,          disabilities,  nanotrasen_relation,  bank_security,  wage_ratio,  be_random_body,       ckey,               slot)
			if(!q.Execute(db))
				message_admins("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				WARNING("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			to_chat(user, "Updated Character")
	else
		message_admins("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[check.Error()] - [check.ErrorMsg()]")
		WARNING("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	check.Add("SELECT player_ckey FROM body WHERE player_ckey = ? AND player_slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())
			q.Add("INSERT INTO body (player_ckey, player_slot, hair_red, hair_green, hair_blue, facial_red, facial_green, facial_blue, skin_tone, hair_style_name, facial_style_name, eyes_red, eyes_green, eyes_blue, underwear, backbag) \
			                 VALUES (?,           ?,           ?,        ?,          ?,         ?,          ?,            ?,           ?,         ?,               ?,                 ?,        ?,          ?,         ?,         ?)",
			                         ckey,        slot,        r_hair,   g_hair,     b_hair,    r_facial,   g_facial,     b_facial,    s_tone,    h_style,         f_style,           r_eyes,   g_eyes,     b_eyes,    underwear, backbag)
			if(!q.Execute(db))
				message_admins("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				WARNING("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			to_chat(user, "Created Body")
		else
			q.Add("UPDATE body SET hair_red=?, hair_green=?, hair_blue=?, facial_red=?, facial_green=?, facial_blue=?, skin_tone=?, hair_style_name=?, facial_style_name=?, eyes_red=?, eyes_green=?, eyes_blue=?, underwear=?, backbag=? WHERE player_ckey = ? AND player_slot = ?",\
			                       r_hair,     g_hair,       b_hair,      r_facial,     g_facial,       b_facial,      s_tone,      h_style,           f_style,             r_eyes,     g_eyes,       b_eyes,      underwear,   backbag,        ckey,               slot)
			if(!q.Execute(db))
				message_admins("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				WARNING("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			to_chat(user, "Updated Body")
	else
		message_admins("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #: [check.Error()] - [check.ErrorMsg()]")
		WARNING("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	check.Add("SELECT player_ckey FROM jobs WHERE player_ckey = ? AND player_slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())
		    //                       1           2           3                4
			q.Add("INSERT INTO jobs (player_ckey,player_slot,alternate_option,jobs) \
					         VALUES (?,          ?,          ?,               ?)", \
							        ckey,        slot,       alternate_option,json_encode(jobs))
			if(!q.Execute(db))
				message_admins("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #: [q.Error()] - [q.ErrorMsg()]")
				WARNING("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			to_chat(user, "Created Job list")
		else
		    //                     1                  2
			q.Add("UPDATE jobs SET alternate_option=?,jobs=? WHERE player_ckey = ? AND player_slot = ?",\
								   alternate_option,  json_encode(jobs),        ckey,               slot)
			if(!q.Execute(db))
				message_admins("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #: [q.Error()] - [q.ErrorMsg()]")
				WARNING("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			to_chat(user, "Updated Job List")
	else
		message_admins("Error in save_character_sqlite ln [__LINE__] #: [check.Error()] - [check.ErrorMsg()]")
		WARNING("Error in save_character_sqlite ln [__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	check.Add("SELECT player_ckey FROM limbs WHERE player_ckey = ? AND player_slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())
			q.Add("INSERT INTO limbs (player_ckey, player_slot) VALUES (?,?)", ckey, slot)
			if(!q.Execute(db))
				message_admins("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #: [q.Error()] - [q.ErrorMsg()]")
				WARNING("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			for(var/stuff in organ_data)
				q.Add("UPDATE limbs SET [stuff]=? WHERE player_ckey = ? AND player_slot = ?", organ_data[stuff], ckey, slot)
				if(!q.Execute(db))
					message_admins("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #; [q.Error()] - [q.ErrorMsg()]")
					WARNING("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
					return 0
			to_chat(user, "Created Limbs")
		else
			for(var/stuff in organ_data)
				q.Add("UPDATE limbs SET [stuff] = ? WHERE player_ckey = ? AND player_slot = ?", organ_data[stuff], ckey, slot)
				if(!q.Execute(db))
					message_admins("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #: [q.Error()] - [q.ErrorMsg()]")
					WARNING("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
					return 0
			to_chat(user, "Updated Limbs")
	else
		message_admins("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #: [check.Error()] - [check.ErrorMsg()]")
		WARNING("Error in save_character_sqlite [__FILE__] ln:[__LINE__] #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	for(var/role_id in roles)
		if(!(roles[role_id] & ROLEPREF_SAVE))
			continue
		q = new
		q.Add("INSERT OR REPLACE INTO client_roles (ckey, slot, role, preference) VALUES (?,?,?,?)", ckey, slot, role_id, (roles[role_id] & ROLEPREF_VALMASK))
		//testing("INSERT OR REPLACE INTO client_roles (ckey, slot, role, preference) VALUES ('[ckey]',[slot],'[role_id]',[roles[role_id] & ROLEPREF_VALMASK])")
		if(!q.Execute(db)) // This never triggers on error, for some reason.
			message_admins("ClientRoleInsert: Error #: [q.Error()] - [q.ErrorMsg()]")
			WARNING("ClientRoleInsert: Error #:[q.Error()] - [q.ErrorMsg()]")
			return 0

	return 1
