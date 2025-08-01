//our character's name
/datum/preference_setting/string/real_name
	name = "Character name"
	sql_name = "real_name"

	sql_table = "players"

	enabled = TRUE

	default_setting = "John D. Spessman"

/datum/preference_setting/string/real_name/sanitize_setting(var/new_setting)
	return reject_bad_name(new_setting)

/datum/preference_setting/string/real_name/randomise(var/mob/user)
	var/gender = parent.get_pref(/datum/preference_setting/enum/gender)
	var/species = parent.get_pref(/datum/preference_setting/string/species)
	setting = random_name(gender, species)
	parent.ShowChoices(user)
	return setting

/datum/preference_setting/string/real_name/choose_setting(var/mob/user)
	var/new_name = reject_bad_name( input(user, "Choose your character's name:", "Character Preference")  as text|null )
	if(new_name)
		setting = new_name
	else
		to_chat(user, "<span class='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ', some diacritics, and .</span>")
	parent.ShowChoices(user)

//whether we are a random name every round
/datum/preference_setting/toggle/be_random_name
	name = "Be random name"
	sql_name = "random_name"

	sql_table = "players"

	enabled = TRUE

	default_setting = FALSE

//whether we are a random name every round
/datum/preference_setting/toggle/be_random_body
	name = "Be random body"
	sql_name = "random_body"

	sql_table = "players"

	enabled = TRUE

	default_setting = FALSE

//gender crticial theory [gender of character (well duh)]
/datum/preference_setting/enum/gender
	name = "Gender"
	sql_name = "gender"

	sql_table = "players"

	enabled = TRUE

	default_setting = MALE // smh
	allowed_values = list(MALE, FEMALE)

/datum/preference_setting/enum/gender/choose_setting(mob/user)
	if(setting == MALE)
		setting = FEMALE
	else
		setting = MALE

	var/datum/preference_setting/species = parent.get_pref_datum(/datum/preference_setting/string/species)
	var/datum/preference_setting/f_style = parent.get_pref_datum(/datum/preference_setting/string/f_style)
	var/datum/preference_setting/h_style = parent.get_pref_datum(/datum/preference_setting/string/h_style)

	f_style.setting = random_facial_hair_style(setting, species)
	h_style.setting = random_hair_style(setting, species)
	parent.ShowChoices(user)

/datum/preference_setting/enum/gender/sanitize_setting(var/new_setting)
	return sanitize_gender(new_setting) // Historical reasons

//age of character
/datum/preference_setting/numerical/age
	name = "Age"
	sql_name = "age"

	sql_table = "players"

	enabled = TRUE

	default_setting = 30 // smh
	min_value = AGE_MIN
	max_value = AGE_MAX

/datum/preference_setting/numerical/age/choose_setting(mob/user)
	var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
	if(new_age)
		setting = clamp(round(new_age), min_value, max_value)
	parent.ShowChoices(user)

//underwear
// This is an integer for historical reasons (you'll read that a lot in this file)
/datum/preference_setting/numerical/underwear
	name = "Underwear"
	sql_name = "underwear"

	sql_table = "body"

	enabled = TRUE

	default_setting = UNDERWEAR_MALE_NONE
	min_value = UNDERWEAR_MALE_NONE
	max_value = UNDERWEAR_FEMALE_BLACK_HUSBANDBEATER

/datum/preference_setting/numerical/underwear/choose_setting(var/mob/user)
	var/datum/preference_setting/gender = parent.get_pref_datum(/datum/preference_setting/enum/gender)
	var/list/underwear_options
	if(gender.setting == MALE)
		underwear_options = underwear_m
	else
		underwear_options = underwear_f

	var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_options
	if(new_underwear)
		setting = underwear_options.Find(new_underwear)
	parent.ShowChoices(user)

/datum/preference_setting/numerical/backbag
	name = "Backbag"
	sql_name = "backbag"
	sql_table = "body"
	enabled = TRUE

	default_setting = BACKPACK
	min_value = NO_BACKPACK
	max_value = MESSENGER_BAG

/datum/preference_setting/numerical/backbag/choose_setting(var/mob/user)
	var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backbaglist
	if(new_backbag)
		setting = backbaglist.Find(new_backbag)
	parent.ShowChoices(user)

/datum/preference_setting/string/h_style
	name = "Hair style"
	sql_name = "hair_style_name"
	sql_table = "body"
	enabled = TRUE

	default_setting = "Bald"

/datum/preference_setting/string/h_style/sanitize_setting(var/new_setting)
	return sanitize_inlist(new_setting, hair_styles_list, default_setting)

/datum/preference_setting/string/h_style/randomise()
	var/datum/preference_setting/gender = parent.get_pref_datum(/datum/preference_setting/enum/gender)
	var/datum/preference_setting/species = parent.get_pref_datum(/datum/preference_setting/string/species)
	setting = random_hair_style(gender.setting, species.setting)

	var/list/colours = random_hair_color()

	var/datum/preference_setting/numerical/r_hair = parent.get_pref_datum(/datum/preference_setting/numerical/r_hair)
	r_hair.setting = colours[1]
	var/datum/preference_setting/numerical/g_hair = parent.get_pref_datum(/datum/preference_setting/numerical/g_hair)
	g_hair.setting = colours[2]
	var/datum/preference_setting/numerical/b_hair = parent.get_pref_datum(/datum/preference_setting/numerical/g_hair)
	b_hair.setting = colours[3]

/datum/preference_setting/string/h_style/proc/input_hair_color(var/mob/user)

	var/datum/preference_setting/species_setting = parent.get_pref_datum(/datum/preference_setting/string/species)
	var/species = species_setting.setting

	var/datum/preference_setting/numerical/r_hair = parent.get_pref_datum(/datum/preference_setting/numerical/r_hair)
	var/datum/preference_setting/numerical/g_hair = parent.get_pref_datum(/datum/preference_setting/numerical/g_hair)
	var/datum/preference_setting/numerical/b_hair = parent.get_pref_datum(/datum/preference_setting/numerical/b_hair)

	switch (species)
		if("Human", "Unathi", "Diona", "Mushroom")
			var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference", rgb(r_hair, g_hair, b_hair)) as color|null
			if(new_hair)
				r_hair.setting = hex2num(copytext(new_hair, 2, 4))
				g_hair.setting = hex2num(copytext(new_hair, 4, 6))
				b_hair.setting = hex2num(copytext(new_hair, 6, 8))

		if("Vox")
			var/new_hair_vox = input(user, "Choose your character's hair color:", "Character Preference") as null|anything in list("Green", "Azure", "Brown", "Emerald", "Gray", "Light Green", "Green-Brown")
			if(new_hair_vox)
				r_hair.setting = haircolordesc(new_hair_vox) // Yeah, vox uses r_hair number as an index for discrete colour values.
				// Why is that? Historical reasons
				to_chat(user,"<span class='notice'>Your hair will now be [new_hair_vox] in color.</span>")

		if("Insectoid")
			var/carapace = input(user, "Choose your character's carapace colour, color values will be adjusted to between 35 and 80:", "Character Preference", rgb(r_hair, g_hair, b_hair)) as color|null
			if(carapace)
				var/datum/preference_setting/numerical/r_facial = parent.get_pref_datum(/datum/preference_setting/numerical/r_facial)
				var/datum/preference_setting/numerical/g_facial = parent.get_pref_datum(/datum/preference_setting/numerical/g_facial)
				var/datum/preference_setting/numerical/b_facial = parent.get_pref_datum(/datum/preference_setting/numerical/b_facial)

				r_facial.setting = hex2num(copytext(carapace, 2, 4))
				g_facial.setting = hex2num(copytext(carapace, 4, 6))
				b_facial.setting = hex2num(copytext(carapace, 6, 8))
				r_facial.setting = clamp(r_hair, 0, 80)
				g_facial.setting = clamp(g_hair, 0, 50)
				b_facial.setting = clamp(b_hair, 0, 35)
	parent.ShowChoices(user)

/datum/preference_setting/string/h_style/choose_setting(var/mob/user)
	var/species = parent.get_pref(/datum/preference_setting/string/species)
	var/new_h_style = input(user, "Choose your character's hair style:", "Character Preference") as null|anything in valid_sprite_accessories(hair_styles_list, null, species) //gender intentionally left null so speshul snowflakes can cross-hairdress
	if(new_h_style)
		setting = new_h_style
	parent.ShowChoices(user)

/datum/preference_setting/string/h_style/process_link(var/task, var/mob/user, var/list/href_list)
	. = ..()
	if (.)
		return
	var/species = parent.get_pref(/datum/preference_setting/string/species)
	switch (task)
		if ("next_hair_style")
			setting = next_list_item(setting, valid_sprite_accessories(hair_styles_list, null, species)) //gender intentionally left null so speshul snowflakes can cross-hairdress
			parent.ShowChoices(user)
		if("previous_hair_style")
			setting = previous_list_item(setting, valid_sprite_accessories(hair_styles_list, null, species)) //gender intentionally left null so speshul snowflakes can cross-hairdress
			parent.ShowChoices(user)
		if("input_hair_color")
			input_hair_color(user)

// Those are split in 3 integer rather than a colour string for historical reasons.
/datum/preference_setting/numerical/r_hair
	name = "Red comp. RGB hair"
	sql_name = "hair_red" // They're also inconsistently named between DB and DM
	sql_table = "body"
	enabled = TRUE

	default_setting = 0
	min_value = 0
	max_value = 255

/datum/preference_setting/numerical/r_hair/randomise()
	return

/datum/preference_setting/numerical/g_hair
	name = "Green comp. RGB hair"
	sql_name = "hair_green"
	sql_table = "body"
	enabled = TRUE

	default_setting = 0
	min_value = 0
	max_value = 255

/datum/preference_setting/numerical/b_hair/randomise()
	return

/datum/preference_setting/numerical/b_hair
	name = "Blue comp. RGB hair"
	sql_name = "hair_blue"
	sql_table = "body"
	enabled = TRUE

	default_setting = 0
	min_value = 0
	max_value = 255

/datum/preference_setting/string/f_style
	name = "Facial Hair style"
	sql_name = "facial_style_name" //ew
	sql_table = "body"

	enabled = TRUE

	default_setting = "Bald"

/datum/preference_setting/string/f_style/sanitize_setting(var/new_setting)
	return sanitize_inlist(new_setting, facial_hair_styles_list, default_setting)

/datum/preference_setting/string/f_style/randomise()
	var/datum/preference_setting/gender = parent.get_pref_datum(/datum/preference_setting/enum/gender)
	var/datum/preference_setting/species = parent.get_pref_datum(/datum/preference_setting/string/species)
	setting = random_facial_hair_style(gender.setting, species.setting)

	var/datum/preference_setting/numerical/r_facial = parent.get_pref_datum(/datum/preference_setting/numerical/r_facial)
	var/datum/preference_setting/numerical/g_facial = parent.get_pref_datum(/datum/preference_setting/numerical/g_facial)
	var/datum/preference_setting/numerical/b_facial = parent.get_pref_datum(/datum/preference_setting/numerical/b_facial)

	if (prob(75))
		var/datum/preference_setting/numerical/r_hair = parent.get_pref_datum(/datum/preference_setting/numerical/r_hair)
		var/datum/preference_setting/numerical/g_hair = parent.get_pref_datum(/datum/preference_setting/numerical/g_hair)
		var/datum/preference_setting/numerical/b_hair = parent.get_pref_datum(/datum/preference_setting/numerical/b_hair)

		r_facial.setting = r_hair.setting
		g_facial.setting = g_hair.setting
		b_facial.setting = b_hair.setting
	else
		var/list/colours = random_hair_color()
		r_facial.setting = colours[1]
		g_facial.setting = colours[2]
		b_facial.setting = colours[3]

/datum/preference_setting/string/f_style/proc/input_facial_hair_color(var/mob/user)
	message_admins("begin input facial hair colour")
	var/species = parent.get_pref(/datum/preference_setting/string/species)
	var/datum/preference_setting/numerical/r_facial = parent.get_pref_datum(/datum/preference_setting/numerical/r_facial)
	var/datum/preference_setting/numerical/g_facial = parent.get_pref_datum(/datum/preference_setting/numerical/g_facial)
	var/datum/preference_setting/numerical/b_facial = parent.get_pref_datum(/datum/preference_setting/numerical/b_facial)

	switch(species)
		if("Human", "Unathi")
			var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference", rgb(r_facial.setting, g_facial.setting, b_facial.setting)) as color|null
			if(new_facial)
				r_facial.setting = hex2num(copytext(new_facial, 2, 4))
				g_facial.setting = hex2num(copytext(new_facial, 4, 6))
				b_facial.setting = hex2num(copytext(new_facial, 6, 8))
		else
			to_chat(user, "<span class='warning'>No facial hair colour setting for speices [species] yet.</span>")
	parent.ShowChoices(user)

/datum/preference_setting/string/f_style/choose_setting(var/mob/user)
	var/species = parent.get_pref(/datum/preference_setting/string/species)
	var/gender = parent.get_pref(/datum/preference_setting/enum/gender)
	var/new_f_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_sprite_accessories(facial_hair_styles_list, gender, species)
	if(new_f_style)
		setting = new_f_style
	parent.ShowChoices(user)

/datum/preference_setting/string/f_style/process_link(var/task, var/mob/user, var/list/href_list)
	. = ..()
	if (.)
		return
	var/species = parent.get_pref(/datum/preference_setting/string/species)
	switch (task)
		if ("next_facehair_style")
			setting = next_list_item(setting, valid_sprite_accessories(facial_hair_styles_list, null, species)) //gender intentionally left null so speshul snowflakes can cross-hairdress
			parent.ShowChoices(user)
		if("next_facehair_style")
			setting = previous_list_item(setting, valid_sprite_accessories(facial_hair_styles_list, null, species))
			parent.ShowChoices(user)
		if("input_facial_hair_color")
			input_facial_hair_color(user)

/datum/preference_setting/numerical/r_facial
	name = "Red comp. RGB facial hair"
	sql_name = "facial_red"
	sql_table = "body"
	enabled = TRUE

	default_setting = 0
	min_value = 0
	max_value = 255

/datum/preference_setting/numerical/r_facial/randomise()
	return

/datum/preference_setting/numerical/g_facial
	name = "Green comp. RGB facial hair"
	sql_name = "facial_green"
	sql_table = "body"
	enabled = TRUE

	default_setting = 0
	min_value = 0
	max_value = 255

/datum/preference_setting/numerical/g_facial/randomise()
	return

/datum/preference_setting/numerical/b_facial
	name = "Blue comp. RGB hair"
	sql_name = "facial_blue"
	sql_table = "body"
	enabled = TRUE

	default_setting = 0
	min_value = 0
	max_value = 255

/datum/preference_setting/numerical/b_facial/randomise()
	return

// Because it's all stored as r_eyes, g_eyes, b_eyes
// We have to pick one color which acts as the `input` catcher for all eye colour
// This should probably be reworked but that'll be in a later PR.
/datum/preference_setting/numerical/r_eyes
	name = "Red comp. RGB eyes"
	sql_name = "eyes_red" // WHY IS YOUR SQL NAME DIFFERENT FROM YOUR REAL HANDLE???
	sql_table = "body"
	enabled = TRUE

	default_setting = 0
	min_value = 0
	max_value = 255

/datum/preference_setting/numerical/r_eyes/choose_setting(var/mob/user)
	var/red_value = parent.get_pref(/datum/preference_setting/numerical/r_eyes)
	var/green_value = parent.get_pref(/datum/preference_setting/numerical/g_eyes)
	var/blue_value = parent.get_pref(/datum/preference_setting/numerical/b_eyes)
	var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference", rgb(red_value, green_value, blue_value)) as color|null
	if(new_eyes)
		var/datum/preference_setting/numerical/g_eyes = parent.get_pref_datum(/datum/preference_setting/numerical/g_eyes)
		var/datum/preference_setting/numerical/b_eyes = parent.get_pref_datum(/datum/preference_setting/numerical/b_eyes)
		setting = hex2num(copytext(new_eyes, 2, 4))
		g_eyes.setting = hex2num(copytext(new_eyes, 4, 6))
		b_eyes.setting = hex2num(copytext(new_eyes, 6, 8))
	parent.ShowChoices(user)

/datum/preference_setting/numerical/g_eyes
	name = "Green comp. RGB eyes"
	sql_name = "eyes_green"
	sql_table = "body"
	enabled = TRUE

	default_setting = 0
	min_value = 0
	max_value = 255

/datum/preference_setting/numerical/b_eyes
	name = "Blue comp. RGB eyes"
	sql_name = "eyes_blue"
	sql_table = "body"
	enabled = TRUE

	default_setting = 0
	min_value = 0
	max_value = 255

/datum/preference_setting/numerical/s_tone
	name = "Skin tone"
	sql_name = "skin_tone"
	sql_table = "body"
	enabled = TRUE

	default_setting = -100
	min_value = -185
	max_value = 35

/datum/preference_setting/numerical/s_tone/choose_setting(var/mob/user)
	var/datum/preference_setting/species_datum = parent.get_pref_datum(/datum/preference_setting/string/species)
	var/species = species_datum.setting
	switch (species)
		if("Human")
			var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
			if(new_s_tone)
				setting = 35 - clamp(new_s_tone,1,220)
				to_chat(user,"You're now [skintone2racedescription(setting, species)].")
		if("Vox")//Can't reference species flags here, sorry.
			var/skin_c = input(user, "Choose your Vox's skin color:\n(1 = Green, 2 = Brown, 3 = Gray, 4 = Light Green, 5 = Azure, 6 = Emerald)", "Character Preference") as num|null
			if(skin_c)
				setting = clamp(skin_c,1,6)
				to_chat(user,"You will now be [skintone2racedescription(setting,species)] in color.")
		if("Grey")
			var/skin_c = input(user, "Choose your Grey's skin color:\n(1 = Gray, 2 = Light, 3 = Green, 4 = Blue)", "Character Preference") as num|null
			if(skin_c)
				setting = clamp(skin_c,1,4)
				to_chat(user,"You will now be [skintone2racedescription(setting,species)] in color.")
		if("Insectoid")
			var/datum/preference_setting/r_hair = parent.get_pref_datum(/datum/preference_setting/numerical/r_hair)
			var/datum/preference_setting/g_hair = parent.get_pref_datum(/datum/preference_setting/numerical/g_hair)
			var/datum/preference_setting/b_hair = parent.get_pref_datum(/datum/preference_setting/numerical/b_hair)
			var/carapace = input(user, "Choose your character's carapace colour, color values will be adjusted to between 35 and 80:", "Character Preference", rgb(r_hair.setting, g_hair.setting, b_hair.setting)) as color|null
			if(carapace)
				r_hair.setting = hex2num(copytext(carapace, 2, 4))
				g_hair.setting = hex2num(copytext(carapace, 4, 6))
				b_hair.setting = hex2num(copytext(carapace, 6, 8))
				r_hair.setting = clamp(r_hair.setting, 0, 80)
				g_hair.setting = clamp(g_hair.setting, 0, 50)
				b_hair.setting = clamp(b_hair.setting, 0, 35)
		else
			to_chat(user,"Your species doesn't have different skin tones. Yet?")
	parent.ShowChoices(user)

/datum/preference_setting/numerical/s_tone/randomise()
	var/species = parent.get_pref(/datum/preference_setting/string/species)
	setting = random_skin_tone(species)

/datum/preference_setting/string/species
	name = "Species"
	sql_name = "species"
	sql_table = "players"
	enabled = TRUE

	default_setting = "Human"

/datum/preference_setting/string/species/choose_setting(var/mob/user)
	var/prev_species = setting
	var/gender = parent.get_pref(/datum/preference_setting/enum/gender)
	if(check_rights(R_ADMIN,0)) // `usr` my beloved :] // usr still sort of works here because this in direct line from a TOPIC() call, but still
		setting = input("Please select a species", "Character Generation", null) in whitelisted_species
	else
		setting = input("Please select a species", "Character Generation", null) in playable_species
	if(prev_species != setting)
		//grab one of the valid hair styles for the newly chosen species
		var/list/valid_hairstyles = valid_sprite_accessories(hair_styles_list, gender, setting, HAIRSTYLE_CANTRIP)
		var/datum/preference_setting/h_style = parent.get_pref_datum(/datum/preference_setting/string/h_style)
		if(valid_hairstyles.len)
			h_style.setting = pick(valid_hairstyles)
		else
			//this shouldn't happen
			h_style.setting = hair_styles_list["Bald"]

		//grab one of the valid facial hair styles for the newly chosen species
		var/list/valid_facialhairstyles = valid_sprite_accessories(facial_hair_styles_list, gender, setting)
		var/datum/preference_setting/f_style = parent.get_pref_datum(/datum/preference_setting/string/f_style)
		if(valid_facialhairstyles.len)
			f_style.setting = pick(valid_facialhairstyles)
		else
			//this shouldn't happen
			f_style.setting = facial_hair_styles_list["Shaved"]


		var/datum/preference_setting/numerical/r_hair = parent.get_pref_datum(/datum/preference_setting/numerical/r_hair)
		var/datum/preference_setting/numerical/g_hair = parent.get_pref_datum(/datum/preference_setting/numerical/g_hair)
		var/datum/preference_setting/numerical/b_hair = parent.get_pref_datum(/datum/preference_setting/numerical/b_hair)

		//reset hair colour and skin colour
		r_hair.setting = 0//hex2num(copytext(new_hair, 2, 4))
		g_hair.setting = 0//hex2num(copytext(new_hair, 4, 6))
		b_hair.setting = 0//hex2num(copytext(new_hair, 6, 8))

		var/datum/preference_setting/numerical/s_tone = parent.get_pref_datum(/datum/preference_setting/numerical/s_tone)
		s_tone.setting = s_tone.default_setting

		// Job list check
		var/datum/preference_setting/jobs = parent.get_pref_datum(/datum/preference_setting/assoc_list_setting/jobs)
		var/list/jobs_list = jobs.setting

		for(var/datum/job/job in job_master.occupations)
			if(job.species_blacklist.Find(setting)) //If new species is in a job's blacklist
				jobs_list -= job.title
				to_chat(user, "<span class='info'>Your new species ([setting]) is blacklisted from [job.title].</span>")

			if(job.species_whitelist.len) //If the job has a species whitelist
				if(!job.species_whitelist.Find(setting)) //And it doesn't include our new species
					if(jobs_list.Remove(job.title))
						to_chat(user, "<span class='info'>Your new species ([setting]) can't be [job.title]. Your preferences have been adjusted.</span>")
	parent.ShowChoices(user)

// The sanity check here is handled at Topic() level with `input()`
/datum/preference_setting/string/language
	name = "language"
	sql_name = "language"
	sql_table = "players"
	enabled = TRUE

	default_setting = "None"

/datum/preference_setting/string/language/choose_setting(var/mob/user)
	var/list/new_languages = list("None")
	for(var/L in all_languages)
		var/datum/language/lang = all_languages[L]
		if(lang.flags & CAN_BE_SECONDARY_LANGUAGE)
			new_languages += lang.name

	setting = input("Please select a secondary language", "Character Generation", null) in new_languages
	parent.ShowChoices(user)

/datum/preference_setting/string/flavor_text
	name = "Flavor Text"
	sql_name = "flavor_text"
	sql_table = "players"
	enabled = TRUE

	default_setting = ""
	max_length = 3000

/datum/preference_setting/string/flavor_text/choose_setting(var/mob/user)
	setting = input(user,"Set the flavor text in your 'examine' verb. This can also be used for OOC notes and preferences!","Flavor Text",html_decode(setting)) as message
	parent.ShowChoices(user)

/datum/preference_setting/string/med_record
	name = "Medical Records"
	sql_name = "med_record"
	sql_table = "players"
	enabled = TRUE

	default_setting = ""
	max_length = 3000

/datum/preference_setting/string/sec_record
	name = "Security Records"
	sql_name = "sec_record"
	sql_table = "players"
	enabled = TRUE

	default_setting = ""
	max_length = 3000

/datum/preference_setting/string/gen_record
	name = "General Records"
	sql_name = "gen_record"
	sql_table = "players"
	enabled = TRUE

	default_setting = ""
	max_length = 3000

// Why is it named like this, I have no idea.
/datum/preference_setting/string/metadata
	name = "OOC Notes"
	sql_name = "ooc_notes"
	sql_table = "players"
	enabled = TRUE

	default_setting = ""
	max_length = MAX_MESSAGE_LEN

/datum/preference_setting/string/metadata/choose_setting(var/mob/user)
	var/new_metadata = input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , setting)  as message|null
	if(new_metadata)
		setting = sanitize(copytext(new_metadata,1,MAX_MESSAGE_LEN))

/datum/preference_setting/list_values/player_alt_titles
	name = "Player alt titles"
	sql_name = "player_alt_titles"
	sql_table = "players"
	enabled = TRUE

	default_setting = list()

// For some reason this is saved as a raw string like "Title":"Alt Title";"Title2":"Alt-Title2"
// So we just need to do some splittext

/datum/preference_setting/list_values/player_alt_titles/load_sql(var/sql_value)
	var/list/temporary_list = list()
	var/list/returned_list = list()
	temporary_list.Add(splittext(sql_value, ";")) // we're getting the first part of the string for each job.
	for(var/item in temporary_list) // iterating through the list
		if(!findtext(item, ":"))
			continue
		var/delim_location = findtext(item, ":") // getting the second part of the string that will be handled for titles
		var/job = copytext(item, 1, delim_location) // getting where the job is, it's in the first slot so we want to get that position.
		var/title = copytext(item, delim_location + 1, 0) // getting where the job title is, it's in the second slot so we want to get that position.
		returned_list[job] = title // we assign the alt_titles here to specific job titles and hope everything works.
	return returned_list

/datum/preference_setting/list_values/player_alt_titles/save_sql()
	var/return_string

	// From Nexis, circa 2017
	// The FUCK is this shit
	for(var/a in setting)
		return_string += "[a]:[setting[a]];"

	return return_string

// The organ data is a bit strange: all these are saved as individual setting flags
// But the whole of it is read as a single list.
// It's annoying to deal with but that's just technical debt

/datum/preference_setting/enum/organ_data
	name = "Organ data"
	sql_name = ""
	sql_table = "limbs"
	enabled = FALSE

	default_setting = null
	allowed_values = list(null, "cyborg", "amputated", "peg")

/datum/preference_setting/enum/organ_data/sanitize_setting(var/new_setting)
	. = ..()
	parent.organ_data[sql_name] = setting

/datum/preference_setting/enum/organ_data/limb_left_arm
	name = "Left Arm"
	sql_name = LIMB_LEFT_ARM
	enabled = TRUE


/datum/preference_setting/enum/organ_data/limb_right_arm
	name = "Right Arm"
	sql_name = LIMB_RIGHT_ARM
	enabled = TRUE


/datum/preference_setting/enum/organ_data/limb_left_leg
	name = "Left Leg"
	sql_name = LIMB_LEFT_LEG
	enabled = TRUE


/datum/preference_setting/enum/organ_data/limb_right_leg
	name = "Right Leg"
	sql_name = LIMB_RIGHT_LEG
	enabled = TRUE

/datum/preference_setting/enum/organ_data/limb_left_hand
	name = "Left Hand"
	sql_name = LIMB_LEFT_HAND
	enabled = TRUE

/datum/preference_setting/enum/organ_data/limb_right_hand
	name = "Right Hand"
	sql_name = LIMB_RIGHT_HAND
	enabled = TRUE

/datum/preference_setting/enum/organ_data/limb_left_foot
	name = "Left Foot"
	sql_name = LIMB_LEFT_FOOT
	enabled = TRUE

/datum/preference_setting/enum/organ_data/limb_right_foot
	name = "Right Foot"
	sql_name = LIMB_RIGHT_FOOT
	enabled = TRUE

/datum/preference_setting/enum/organ_data/organ
	enabled = FALSE
	allowed_values = list(null, "assisted", "mechanical")

/datum/preference_setting/enum/organ_data/organ/heart
	name = "Heart"
	sql_name = LIMB_HEART
	enabled = TRUE

/datum/preference_setting/enum/organ_data/organ/eyes
	name = "Eyes"
	sql_name = LIMB_EYES
	enabled = TRUE

/datum/preference_setting/enum/organ_data/organ/lung
	name = "Lung"
	sql_name = LIMB_LUNG
	enabled = TRUE

/datum/preference_setting/enum/organ_data/organ/liver
	name = "Liver"
	sql_name = LIMB_LIVER
	enabled = TRUE

/datum/preference_setting/enum/organ_data/organ/kidneys
	name = "Kidneys"
	sql_name = LIMB_KIDNEYS
	enabled = TRUE

//Keeps track of preferrence for not getting any wanted jobs
/datum/preference_setting/enum/alternate_option
	name = "Alternate Option if jobs filled"
	sql_name = "alternate_option"
	sql_table = "jobs"
	enabled = TRUE

	default_setting = RETURN_TO_LOBBY
	allowed_values = list(RETURN_TO_LOBBY, GET_RANDOM_JOB, BE_ASSISTANT, GET_EMPTY_JOB)

// Stored as JSON
/datum/preference_setting/assoc_list_setting/jobs
	name = "Jobs"
	sql_name = "jobs"
	sql_table = "jobs"
	enabled = TRUE

	default_setting = list()
	allowed_values_for_list_items = list(JOB_PREF_NEVER, JOB_PREF_LOW, JOB_PREF_MED, JOB_PREF_HIGH)

/datum/preference_setting/assoc_list_setting/jobs/save_sql()
	return json_encode(setting)

/datum/preference_setting/assoc_list_setting/jobs/load_sql(var/sql_value)
	if (sql_value)
		return json_decode(sql_value)
	return list()

/datum/preference_setting/assoc_list_setting/jobs/process_link(var/task, var/mob/user, var/list/href_list)
	var/datum/preference_setting/alternate_option = parent.get_pref_datum(/datum/preference_setting/enum/alternate_option)
	switch(task)
		if("close")
			user << browse(null, "window=mob_occupation")
			parent.ShowChoices(user)
		if("reset")
			parent.ResetJobs()
		if("random") // This just changes the alternate option.
			if(alternate_option.setting == GET_RANDOM_JOB || alternate_option.setting == BE_ASSISTANT || alternate_option.setting == RETURN_TO_LOBBY)
				alternate_option.setting += 1
			else if(alternate_option.setting == GET_EMPTY_JOB)
				alternate_option.setting = 0
			else
				return 0
			parent.SetJobsChoice(user)
		if ("alt_title")
			var/datum/job/job = locate(href_list["job"])
			if (job)
				var/choices = list(job.title) + job.alt_titles
				var/choice = input("Pick a title for [job.title].", "Character Generation", parent.GetPlayerAltTitle(job)) as anything in choices | null
				if(choice)
					parent.SetPlayerAltTitle(job, choice)
			parent.SetJobsChoice(user)
		if("input")
			parent.SetJob(user, href_list["text"], href_list["level"] == "1")
		else // Menu
			parent.SetJobsChoice(user)
	return 1

/datum/preference_setting/enum/string/nanotrasen_relation
	name = "Nanotrasen Relationship"
	sql_name = "nanotrasen_relation"
	sql_table = "players"
	enabled = TRUE

	default_setting = "Neutral"
	allowed_values = list("Loyal", "Supportive", "Neutral", "Skeptical")

/datum/preference_setting/enum/string/nanotrasen_relation/choose_setting(var/mob/user)
	var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", )
	if(new_relation)
		setting = new_relation
	parent.ShowChoices(user)

/datum/preference_setting/enum/bank_security
	name = "Bank security"
	sql_name = "bank_security"
	sql_table = "players"
	enabled = TRUE

	default_setting = SECURITY_AUTO_LOGIN
	allowed_values = list(SECURITY_AUTO_LOGIN, SECURITY_MANUAL_LOGIN, SECURITY_CARD_AND_MANUAL_LOGIN)

/datum/preference_setting/enum/bank_security/choose_setting(var/mob/user)
	var/new_bank_security = input(user, BANK_SECURITY_EXPLANATION, "Character Preference")  as null|anything in bank_security_text2num_associative
	if(!isnull(new_bank_security))
		setting = bank_security_text2num_associative[new_bank_security]
	parent.ShowChoices(user)

/datum/preference_setting/numerical/wage_ratio
	name = "Wage ratio"
	sql_name = "wage_ratio"
	sql_table = "players"
	enabled = TRUE

	default_setting = 50
	min_value = 0
	max_value = 100

/datum/preference_setting/numerical/wage_ratio/randomise()
	return

/datum/preference_setting/numerical/wage_ratio/choose_setting(var/mob/user)
	var/new_wage_ratio = input(user, "Input what % of wages end up in virtual wallets, from 0-100", "Character Preference",setting) as num
	if(!isnull(new_wage_ratio))
		new_wage_ratio = clamp(new_wage_ratio,0,100)
		setting = new_wage_ratio
	parent.ShowChoices(user)

/datum/preference_setting/binary_flag/disabilities
	name = "Disabilities"
	sql_name = "disabilities"
	sql_table = "players"
	enabled = TRUE

/datum/preference_setting/binary_flag/disabilities/process_link(var/task, var/mob/user, var/list/href_list)
	switch(task)
		if("close")
			user << browse(null, "window=disabil")
			parent.ShowChoices(user)
		if("reset")
			setting=0
			parent.SetDisabilities(user)
		if("input")
			var/dflag=text2num(href_list["disability"])
			var/species = parent.get_pref(/datum/preference_setting/string/species)
			if(dflag >= 0)
				if(!(dflag==DISABILITY_FLAG_FAT && species!="Human"))
					setting ^= text2num(href_list["disability"]) //MAGIC
			parent.SetDisabilities(user)
		else
			parent.SetDisabilities(user)
