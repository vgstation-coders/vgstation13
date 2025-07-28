#define CHARACTER_SETUP 0
#define UI_SETUP 1
#define GENERAL_SETUP 2
#define SPECIAL_ROLES_SETUP 3

var/list/preferences_datums = list()
var/global/list/special_roles = list(
	ROLE_ALIEN     	= 1,
	BLOBOVERMIND   	= 1,
	ROLE_BORER     	= 1,
	CHANGELING   	= 1,
	CULTIST      	= 1,
	ROLE_PLANT     	= 1,
	MALF         	= 1,
	NUKE_OP	    	= 1,
	ROLE_PAI        = 1,
	ROLE_POSIBRAIN  = 1,
	REV          	= 1,
	TRAITOR      	= 1,
	CHALLENGER		= 1,
	VAMPIRE      	= 1,
	VOXRAIDER    	= 1,
	WIZARD       	= 1,
	ROLE_STRIKE	  	= 1,
	GRINCH			= 1,
	NINJA			= 1,
	TIMEAGENT		= 1,
	PULSEDEMON		= 1,
	ROLE_MINOR		= 1,
	ROLE_PRISONER   = 1,
	ROLE_GRUE		= 1,
	DIVERGENTCLONE  = 1,
)

/var/list/antag_roles = list(
	ROLE_ALIEN      = 1,
	BLOBOVERMIND   	= 1,
	CHANGELING   	= 1,
	CULTIST      	= 1,
	MALF         	= 1,
	NUKE_OP	    	= 1,
	REV          	= 1,
	TRAITOR      	= 1,
	CHALLENGER		= 1,
	VAMPIRE      	= 1,
	VOXRAIDER    	= 1,
	WIZARD       	= 1,
	ROLE_STRIKE	  	= 1,
	GRINCH			= 1,
	NINJA			= 1,
	TIMEAGENT		= 1,
	PULSEDEMON		= 1,
	ROLE_MINOR		= 1,
	ROLE_PRISONER	= 1,
	ROLE_GRUE		= 1,
	DIVERGENTCLONE  = 1,
)

var/list/nonantag_roles = list(
	ROLE_BORER        = 1,
	ROLE_PLANT        = 1,
	ROLE_PAI          = 1,
	ROLE_POSIBRAIN    = 1,
)

var/list/role_wiki=list(
	ROLE_ALIEN				= "Xenomorph",
	BLOBOVERMIND			= "Blob",
	ROLE_BORER				= "Cortical_Borer",
	CHANGELING				= "Changeling",
	CULTIST					= "Cult",
	ROLE_PLANT				= "Dionaea",
	MALF					= "Guide_to_Malfunction",
	NUKE_OP					= "Nuclear_Agent",
	ROLE_PAI				= "Personal_AI",
	ROLE_POSIBRAIN			= "Guide_to_Silicon_Laws",
	REV						= "Revolution",
	TRAITOR					= "Traitor",
	CHALLENGER				= "Challengers",
	VAMPIRE					= "Vampire",
	VOXRAIDER				= "Vox_Raider",
	WIZARD					= "Wizard",
	GRINCH					= "Grinch",
	NINJA					= "Space_Ninja",
	TIMEAGENT				= "Time_Agent",
	PULSEDEMON				= "Pulse_Demon",
	ROLE_MINOR				= "Minor_Roles",
	ROLE_PRISONER			= "Minor_Roles",
	ROLE_GRUE				= "Grue",
	DIVERGENTCLONE			= "Divergent_Clone",
)

var/list/special_popup_text2num = list(
	"Only use chat" = SPECIAL_POPUP_DISABLED,
	"Only use special" = SPECIAL_POPUP_EXCLUSIVE,
	"Use both chat and special" = SPECIAL_POPUP_USE_BOTH,
)

var/list/headset_sound_text2num = list(
	"Disabled" = HEADSET_SOUND_DISABLED,
	"Transmit Only" = HEADSET_SOUND_TRANSMIT,
	"All" = HEADSET_SOUND_ALL,
)

var/const/MAX_SAVE_SLOTS = 16

#define POLLED_LIMIT	100

/datum/preferences
	var/list/subsections
	//doohickeys for savefiles
	var/database/db = ("players2.sqlite")
	var/path

	// Which character slot
	var/slot = 1
	var/list/slot_names = new
	var/slot_name = ""

	// 0 = character settings, 1 = game preferences
	var/current_tab = 0

	// Last time the guy saved their prefs
	var/lastPolled = 0

	var/savefile_version = 0

	// Alist = associative lists. This is a new 516 thing. Woo!
	var/alist/preference_settings_client = alist()
	var/alist/preference_settings_character = alist()

	// Don't like hardcoding this but I can't find a way..
	var/list/organ_data = list()

	// REALLY don't like hardcoding this. Will be for another time
	var/list/roles = list()

	//non-preference stuff
	// Shouldn't these by on client?
	var/last_ip
	var/last_id
	var/muted

	//Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null
	var/preview_background = null
	var/list/background_options = list("Black", "White", "Tile")

	var/client/client
	var/saveloaded = 0

/datum/preferences/New(client/C)
	client=C
	if(istype(C))
		init_datums()
		init_subsections()
		var/theckey = C.ckey
		var/thekey = C.key
		if(!IsGuestKey(thekey))
			var/load_pref = try_load_preferences(theckey, C.mob)
			var/default_slot = get_pref(/datum/preference_setting/numerical/default_slot)
			slot = default_slot
			if(load_pref)
				to_chat(C, "Successfully loaded preferences.")
				while(!SS_READY(SShumans))
					sleep(1)
				try_load_save_sqlite(theckey, C, default_slot)
				return
			CRASH("Could not load preferences!")

		while(!SS_READY(SShumans))
			sleep(1)
		randomize_appearance_for(random_gender = TRUE)
		var/default_slot = get_pref(/datum/preference_setting/numerical/default_slot)
		var/gender = get_pref(/datum/preference_setting/enum/gender)
		var/species = get_pref(/datum/preference_setting/string/species)
		var/datum/preference_setting/real_name = get_pref_datum(/datum/preference_setting/string/real_name)
		real_name.setting = random_name(gender, species)
		save_character_sqlite(theckey, C, default_slot)
		saveloaded = 1

/datum/preferences/proc/init_datums()
	for (var/database_setting in typesof(/datum/preference_setting))
		var/datum/preference_setting/setting_datum = database_setting
		if (!initial(setting_datum.enabled))
			continue
		setting_datum = new database_setting(src)
		if (setting_datum.sql_table == "client")
			preference_settings_client[database_setting] = setting_datum
		else
			preference_settings_character[database_setting] = setting_datum

/datum/preferences/Destroy()
	for(var/entry in subsections)
		var/datum/preferences_subsection/prefs_ss = subsections[entry]
		if(prefs_ss && !prefs_ss.gcDestroyed)
			QDEL_NULL(prefs_ss)
	for(var/key, setting in preference_settings_character)
		QDEL_NULL(setting)
		preference_settings_character -= key
	for(var/key, setting in preference_settings_client)
		QDEL_NULL(setting)
		preference_settings_client -= key
	..()

// Try to load a SQLite save for this character, creating it if there's nothing.
/datum/preferences/proc/try_load_save_sqlite(var/theckey, var/theclient, var/theslot)
	var/attempts = 0
	var/database/query/existing_player_check = new

	existing_player_check.Add("SELECT player_ckey FROM players WHERE player_ckey = ? AND player_slot = ?", theckey, theslot)

	if(existing_player_check.Execute(db))
		if(!existing_player_check.NextRow())
			while(!create_character_sqlite(theckey, theclient, theslot) && attempts < 5)
				sleep(15)
				attempts++
			if(attempts >= 5)//failsafe so people don't get locked out of the round forever
				fallback_random_character(theckey, theclient)
			save_character_sqlite(theckey, theclient, theslot)
		else
			while(!load_character_sqlite(theckey, theclient, theslot) && attempts < 5)
				sleep(15)
				attempts++
			if(attempts >= 5)//failsafe so people don't get locked out of the round forever
				fallback_random_character(theckey, theclient)

	saveloaded = 1
	theclient << 'sound/misc/prefsready.wav'

/datum/preferences/proc/fallback_random_character(var/theclient, var/theckey)
	randomize_appearance_for(random_gender = TRUE)
	var/species = get_pref(/datum/preference_setting/string/species)
	var/gender = get_pref(/datum/preference_setting/enum/gender)
	var/datum/preference_setting/name_setting = get_pref_datum(/datum/preference_setting/string/real_name)
	name_setting.setting = random_name(gender, species)
	log_debug("Player [theckey] FAILED to load save 5 times and has been randomized.")
	log_admin("Player [theckey] FAILED to load save 5 times and has been randomized.")
	if(theclient)
		alert(theclient, "For some reason you've failed to load your save slot 5 times now, so you've been generated a random character. Don't worry, it didn't overwrite your old one. Saving it may overwrite it, so be careful.","Randomized Character", "OK")

/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	var/list/player_alt_titles = get_pref(/datum/preference_setting/list_values/player_alt_titles)
	var/alt_title = player_alt_titles[job.title]
	if(!alt_title || !(alt_title in job.alt_titles))
		return job.title
	return alt_title

/datum/preferences/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	var/datum/preference_setting/p_alt_tiltes_set = get_pref_datum(/datum/preference_setting/list_values/player_alt_titles)
	var/list/player_alt_titles = p_alt_tiltes_set.setting
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/preferences/proc/SetJob(mob/user, role, increase)
	var/datum/job/job = job_master.GetJob(role)
	var/species = get_pref(/datum/preference_setting/string/species)
	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if(job.species_blacklist.Find(species)) //Check if our species is in the blacklist
		to_chat(user, "<span class='notice'>Your species ([species]) can't have this job!</span>")
		return

	if(job.species_whitelist.len) //Whitelist isn't empty - check if our species is in the whitelist
		if(!job.species_whitelist.Find(species))
			var/allowed_species = ""
			for(var/S in job.species_whitelist)
				allowed_species += "[S]"

				if(job.species_whitelist.Find(S) != job.species_whitelist.len)
					allowed_species += ", "

			to_chat(user, "<span class='notice'>Only the following species can have this job: [allowed_species]. Your species is ([species]).</span>")
			return
	var/list/jobs = get_pref(/datum/preference_setting/assoc_list_setting/jobs)
	var/new_value = jobs[job.title]
	if(increase)
		new_value += 1
		if(new_value > JOB_PREF_HIGH)
			new_value = JOB_PREF_NEVER
	else
		new_value -= 1
		if(new_value < JOB_PREF_NEVER)
			new_value = JOB_PREF_HIGH

	// If setting a job to high,
	// set any other job that is currently high to med
	if(new_value == JOB_PREF_HIGH)
		for(var/some_job in jobs)
			if(jobs[some_job] == JOB_PREF_HIGH)
				jobs[some_job] = JOB_PREF_MED
		jobs[job.title] = new_value
	else if(new_value == JOB_PREF_NEVER)
		jobs -= job.title
	else
		jobs[job.title] = new_value
	SetJobsChoice(user)
	return 1

/datum/preferences/proc/ResetJobs()
	// For reference `get_pref` would be equivalent here but I am doing this for clarity.
	var/datum/preference_setting/jobs_setting = get_pref_datum(/datum/preference_setting/assoc_list_setting/jobs)
	var/list/jobs = jobs_setting.setting
	jobs.Cut()

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!user)
		return
	var/datum/preferences_subsection/subsection = subsections[href_list["subsection"]]
	if(subsection)
		var/result = subsection.process_link(user, href_list)
		if(result)
			return result

	// General soft-coding stuff.
	// Relatively inelegant. Any better idea?
	for (var/key, value in preference_settings_client)
		var/datum/preference_setting/setting = value
		if (setting.sql_name == href_list["preference"])
			setting.process_link(href_list["task"], user, href_list)
			ShowChoices(user)
			return

	for (var/key, value in preference_settings_character)
		var/datum/preference_setting/setting = value
		if (setting.sql_name == href_list["preference"])
			setting.process_link(href_list["task"], user, href_list)
			return

	if(href_list["task"] == "random_body")
		for (var/key, value in preference_settings_character)
			var/datum/preference_setting/setting = value
			if (setting.sql_name == "real_name") // Bit ugly but have to do it
				continue
			setting.randomise(user)
		ShowChoices(user)
		return

	// Some unfortunate hard-coding stuff
	if(href_list["preference"] == "records")
		if(text2num(href_list["record"]) >= 1)
			SetRecords(user)
		else
			user << browse(null, "window=records")
			ShowChoices(user)

		if(href_list["task"] == "med_record")
			var/datum/preference_setting/med_record = get_pref_datum(/datum/preference_setting/string/med_record)
			var/medmsg = input(usr,"Set your medical notes here.","Medical Records",html_decode(med_record.setting)) as message

			if(medmsg != null)
				medmsg = copytext(medmsg, 1, MAX_PAPER_MESSAGE_LEN)
				medmsg = html_encode(medmsg)
				med_record.setting = medmsg
				SetRecords(user)

		if(href_list["task"] == "sec_record")
			var/datum/preference_setting/sec_record = get_pref_datum(/datum/preference_setting/string/sec_record)
			var/secmsg = input(usr,"Set your security notes here.","Security Records",html_decode(sec_record.setting)) as message

			if(secmsg != null)
				secmsg = copytext(secmsg, 1, MAX_PAPER_MESSAGE_LEN)
				secmsg = html_encode(secmsg)

				sec_record.setting = secmsg
				SetRecords(user)

		if(href_list["task"] == "gen_record")
			var/datum/preference_setting/gen_record = get_pref_datum(/datum/preference_setting/string/gen_record)
			var/genmsg = input(usr,"Set your employment notes here.","Employment Records",html_decode(gen_record.setting)) as message

			if(genmsg != null)
				genmsg = copytext(genmsg, 1, MAX_PAPER_MESSAGE_LEN)
				genmsg = html_encode(genmsg)

				gen_record.setting = genmsg
				SetRecords(user)

		return

	// Roles
	if(href_list["preference"] == "set_roles")
		return SetRoles(user,href_list)

	if(href_list["preference"] == "next_preview_background")
		preview_background = next_list_item(preview_background, background_options)
		return ShowChoices(user)
	if(href_list["preference"] == "previous_preview_background")
		preview_background = previous_list_item(preview_background, background_options)
		return ShowChoices(user)

	// Special actions
	if (href_list["action"])
		switch (href_list["action"])
			if("save")
				if(world.timeofday >= (lastPolled + POLLED_LIMIT) || user.client.holder)
					save_preferences_sqlite(user, user.ckey)
					save_character_sqlite(user.ckey, user, slot)
					lastPolled = world.timeofday
				else
					to_chat(user, "You need to wait [round((((lastPolled + POLLED_LIMIT) - world.timeofday) / 10))] seconds before you can save again.")
					//random_character_sqlite(user, user.ckey)

			if("reload")
				load_preferences_sqlite(user.ckey)
				load_character_sqlite(user.ckey, user, slot)

			if("open_load_dialog")
				if(!IsGuestKey(user.key))
					open_load_dialog(user)
					// DO NOT update window as it'd steal focus.
					return

			if("close_load_dialog")
				close_load_dialog(user)

			if("changeslot")
				var/num = text2num(href_list["num"])
				try_load_slot(user.ckey, user, num)
				var/datum/preference_setting/numerical/default_slot/slot_pref = get_pref_datum(/datum/preference_setting/numerical/default_slot)
				slot_pref.setting = num
				slot = num
				close_load_dialog(user)
				ShowChoices(user)

			if("tab")
				if(href_list["tab"])
					current_tab = text2num(href_list["tab"])

		ShowChoices(user)
		return
	// We made it this far, means link was unprocessed
	CRASH("unprocessed href for [client]; data=[json_encode(href_list)]")

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, safety = 0)
	var/datum/preference_setting/name_setting = get_pref_datum(/datum/preference_setting/string/real_name)
	var/species = get_pref(/datum/preference_setting/string/species)
	var/gender= get_pref(/datum/preference_setting/enum/gender)
	if(get_pref(/datum/preference_setting/toggle/be_random_name))
		name_setting.setting = random_name(gender,species)
	if(config.humans_need_surnames && species == "Human")
		var/firstspace = findtext(name_setting.setting, " ")
		var/name_length = length(name_setting.setting)
		if(!firstspace)	//we need a surname
			name_setting.setting += " [pick(last_names)]"
		else if(firstspace == name_length)
			name_setting.setting += "[pick(last_names)]"

	character.real_name = name_setting.setting
	character.name = character.real_name
	character.flavor_text = get_pref(/datum/preference_setting/string/flavor_text)
	if(character.dna)
		character.dna.real_name = character.real_name
		character.dna.flavor_text = character.flavor_text

	character.med_record = get_pref(/datum/preference_setting/string/med_record)
	character.sec_record = get_pref(/datum/preference_setting/string/sec_record)
	character.gen_record = get_pref(/datum/preference_setting/string/gen_record)

	character.setGender(gender)
	character.age = get_pref(/datum/preference_setting/numerical/age)

	character.my_appearance.r_eyes = get_pref(/datum/preference_setting/numerical/r_eyes)
	character.my_appearance.g_eyes = get_pref(/datum/preference_setting/numerical/g_eyes)
	character.my_appearance.b_eyes = get_pref(/datum/preference_setting/numerical/b_eyes)

	character.my_appearance.r_hair = get_pref(/datum/preference_setting/numerical/r_hair)
	character.my_appearance.g_hair = get_pref(/datum/preference_setting/numerical/g_hair)
	character.my_appearance.b_hair = get_pref(/datum/preference_setting/numerical/b_hair)

	character.my_appearance.r_facial = get_pref(/datum/preference_setting/numerical/r_facial)
	character.my_appearance.g_facial = get_pref(/datum/preference_setting/numerical/g_facial)
	character.my_appearance.b_facial = get_pref(/datum/preference_setting/numerical/b_facial)

	character.my_appearance.s_tone = get_pref(/datum/preference_setting/numerical/s_tone)

	character.my_appearance.h_style = get_pref(/datum/preference_setting/string/h_style)
	character.my_appearance.f_style = get_pref(/datum/preference_setting/string/f_style)

	character.dna.ResetUIFrom(character)

	if(get_pref(/datum/preference_setting/toggle/be_random_body))
		character.my_appearance.randomise()

	// Destroy/cyborgize organs

	for(var/name in organ_data)
		var/datum/organ/external/O = character.organs_by_name[name]
		var/datum/organ/internal/I = character.internal_organs_by_name[name]
		var/status = organ_data[name]

		if(status == "amputated")
			O.status &= ~ORGAN_ROBOT
			O.status &= ~ORGAN_PEG
			O.amputated = 1
			O.status |= ORGAN_DESTROYED
			O.destspawn = 1
		else if(status == "cyborg")
			O.status &= ~ORGAN_PEG
			O.status |= ORGAN_ROBOT
		else if(status == "peg")
			O.status &= ~ORGAN_ROBOT
			O.status |= ORGAN_PEG
		else if(status == "assisted")
			I?.mechassist()
		else if(status == "mechanical")
			I?.mechanize()
		else
			continue
	var/disabilities = get_pref(/datum/preference_setting/binary_flag/disabilities)
	var/datum/species/chosen_species = all_species[species]
	if( (disabilities & DISABILITY_FLAG_FAT) && (chosen_species.anatomy_flags & CAN_BE_FAT) )
		character.mutations += M_FAT
	if(disabilities & DISABILITY_FLAG_NEARSIGHTED)
		character.disabilities|=NEARSIGHTED
	if(disabilities & DISABILITY_FLAG_EPILEPTIC)
		character.disabilities|=EPILEPSY
	if(disabilities & DISABILITY_FLAG_EHS)
		character.disabilities|=ELECTROSENSE
	if(disabilities & DISABILITY_FLAG_DEAF)
		character.sdisabilities|=DEAF
	if(disabilities & DISABILITY_FLAG_BLIND)
		character.sdisabilities|=BLIND
	/*if(disabilities & DISABILITY_FLAG_COUGHING)
		character.sdisabilities|=COUGHING
	if(disabilities & DISABILITY_FLAG_TOURETTES)
		character.sdisabilities|=TOURETTES Still working on it. - Angelite */

	var/underwear = get_pref(/datum/preference_setting/numerical/underwear)
	if(underwear > underwear_m.len || underwear < 1)
		underwear = 0 //I'm sure this is 100% unnecessary, but I'm paranoid... sue me. //HAH NOW NO MORE MAGIC CLONING UNDIES
	character.underwear = underwear

	var/backbag = get_pref(/datum/preference_setting/numerical/backbag)
	if(backbag > 5 || backbag < 1)
		backbag = 1 //Same as above
	character.backbag = backbag

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(character.gender in list(PLURAL, NEUTER))
		if(isliving(character) && !ismushroom(character)) //Ghosts and mushroom people are neuter by default
			message_admins("[character] ([character.ckey]) has spawned with their gender as plural or neuter. Please notify coders.")
			character.setGender(MALE)

/datum/preferences/proc/SetRoles(var/mob/user, var/list/href_list)
	// We just grab the role from the POST(?) data.
	for(var/role_id in special_roles)
		if(role_id in href_list)
			roles[role_id] = text2num(href_list[role_id])
			ShowChoices(user)
			return 1

/datum/preferences/proc/get_pref_datum(var/datum/preference_setting/type) as /datum/preference_setting
	if (type in preference_settings_client)
		var/datum/preference_setting/the_setting = preference_settings_client[type]
		if (!the_setting)
			stack_trace("unset client preference [type] on [client]:[client.mob.type]")
			return initial(type.default_setting)
		return the_setting
	if (type in preference_settings_character)
		var/datum/preference_setting/the_setting = preference_settings_character[type]
		if (!the_setting)
			stack_trace("unset character preference [type] on [client]:[client.mob.type]")
			return initial(type.default_setting)
		return the_setting
	CRASH("invalid preference setting requested: [type] on [src.client]")

/datum/preferences/proc/get_pref(var/datum/preference_setting/type)
	var/datum/preference_setting/the_setting = get_pref_datum(type)
	return the_setting.setting

// limbs & organs
/datum/preferences/proc/change_pref_datum_limb(var/limb_internal_name, var/limb_internal_state)
	for (var/key, setting_datum in preference_settings_character)
		var/datum/preference_setting/setting_type = key
		if (initial(setting_type.sql_table) != "limbs")
			continue
		if (initial(setting_type.sql_name) == limb_internal_name)
			var/datum/preference_setting/limb = preference_settings_character[setting_type]
			limb.setting = limb_internal_state
			return

/client/verb/modify_preferences(page as num)
	set name = "modifypreferences"
	set hidden = 1
	if(!prefs.saveloaded)
		to_chat(src, "<span class='warning'>Your character preferences have not yet loaded.</span>")
		return
	switch(page)
		if(1)
			prefs.current_tab = GENERAL_SETUP
		if(2)
			prefs.current_tab = SPECIAL_ROLES_SETUP
	prefs.ShowChoices(usr)
