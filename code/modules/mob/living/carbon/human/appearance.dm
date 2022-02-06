#define INDEX_RED 1
#define INDEX_GREEN 2
#define INDEX_BLUE 3

/datum/human_appearance
	// For identification.
	var/name
	var/gender

	// "Proper" to the appearance datum.
	var/s_tone = 0

	var/h_style = "Bald"
	var/r_hair = 0
	var/g_hair = 0
	var/b_hair = 0

	var/f_style = "Shaved"
	var/r_facial = 0
	var/g_facial = 0
	var/b_facial = 0

	var/r_eyes = 0
	var/g_eyes = 0
	var/b_eyes = 0

/mob/living/carbon/human/
	var/datum/human_appearance/my_appearance

/mob/living/carbon/human/proc/switch_appearance(var/datum/human_appearance/new_looks)
	if (!istype(new_looks))
		return
	my_appearance = new_looks
	regenerate_icons()

/datum/human_appearance/proc/Copy()
	var/datum/human_appearance/new_looks = new
	new_looks.name = name
	new_looks.gender = gender
	new_looks.s_tone = s_tone
	new_looks.h_style = h_style
	new_looks.r_hair = r_hair
	new_looks.g_hair = g_hair
	new_looks.f_style = f_style
	new_looks.r_facial = r_facial
	new_looks.g_facial = g_facial
	new_looks.b_facial = b_facial
	new_looks.r_eyes = r_eyes
	new_looks.g_eyes = g_eyes
	new_looks.b_eyes = b_eyes
	return new_looks

/datum/human_appearance/proc/randomise(var/new_gender, var/species)
	if (new_gender)
		gender = new_gender
	else
		gender = pick(MALE, FEMALE)

	s_tone = random_skin_tone(species)
	h_style = random_hair_style(gender, species)
	f_style = random_facial_hair_style(gender, species)

	var/list/hair_colour = randomize_hair_color("hair")
	var/list/facial_hair_colour = randomize_hair_color("facial")
	var/list/eye_colour = randomize_eyes_color()

	r_hair = hair_colour[INDEX_RED]
	g_hair = hair_colour[INDEX_GREEN]
	b_hair = hair_colour[INDEX_BLUE]

	r_facial = facial_hair_colour[INDEX_RED]
	g_facial = facial_hair_colour[INDEX_GREEN]
	b_facial = facial_hair_colour[INDEX_BLUE]

	r_eyes = eye_colour[INDEX_RED]
	g_eyes = eye_colour[INDEX_GREEN]
	b_eyes = eye_colour[INDEX_BLUE]

/mob/living/carbon/human/proc/randomise_appearance_for(var/new_gender)
	var/datum/human_appearance/new_looks = new

	new_looks.randomise(new_gender, species.name)
	my_appearance = new_looks
	regenerate_icons()

	return new_looks

/datum/human_appearance/proc/randomize_hair_color(var/target = "hair")
	if(prob (75) && target == "facial") // Chance to inherit hair color
		return list(r_hair, g_hair, b_hair)

	var/red
	var/green
	var/blue

	var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", 15;"punk")
	switch(col)
		if("blonde")
			red = 255
			green = 255
			blue = 0
		if("black")
			red = 0
			green = 0
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 51
		if("copper")
			red = 255
			green = 153
			blue = 0
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("wheat")
			red = 255
			green = 255
			blue = 153
		if("old")
			red = rand (100, 255)
			green = red
			blue = red
		if("punk")
			red = rand(0, 255)
			green = rand(0, 255)
			blue = rand(0, 255)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	return list(red, green, blue)

/datum/human_appearance/proc/randomize_eyes_color()
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	return list(red, green, blue)

/mob/living/carbon/human/proc/pick_gender(var/mob/user, var/title = "Character Generation", var/update_icons = TRUE)
	var/new_gender = alert(user, "Please select gender.", title, "Male", "Female")
	if (new_gender)
		setGender(new_gender == "Male" ? MALE : FEMALE)
	if (update_icons)
		regenerate_icons()

/mob/living/carbon/human/proc/pick_appearance(var/mob/user, var/title = "Character Generation", var/update_icons_and_dna = TRUE)
	// SKIN
	if (species)
		switch (species.name)
			if ("Human")
				var/new_tone = input(user, "Select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", title, "[35-my_appearance.s_tone]")  as text
				if (!new_tone)
					new_tone = 35
				my_appearance.s_tone = max(min(round(text2num(new_tone)), 220), 1)
				my_appearance.s_tone =  -my_appearance.s_tone + 35
			if ("Vox")
				var/new_tone = input(user, "Select feather color: 1-6 (1=dark green, 2=brown, 3=grey, 4=light green, 5=azure, 6=emerald)", title, "[my_appearance.s_tone]")  as text
				if (!new_tone)
					new_tone = 1
				my_appearance.s_tone = max(min(round(text2num(new_tone)), 6), 1)
			if ("Grey")
				var/new_tone = input(user, "Select skin color: 1-4 (1=grey, 2=pale gray, 3=greyish green, 4=greyish blue)", title, "[my_appearance.s_tone]")  as text
				if (!new_tone)
					new_tone = 1
				my_appearance.s_tone = max(min(round(text2num(new_tone)), 4), 1)
	else
		var/new_tone = input(user, "Select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", title, "[35-my_appearance.s_tone]")  as text
		if (!new_tone)
			new_tone = 35
		my_appearance.s_tone = max(min(round(text2num(new_tone)), 220), 1)
		my_appearance.s_tone =  -my_appearance.s_tone + 35

	// EYES
	var/new_eye_color = input(user, "Select eye color.", title,rgb(my_appearance.r_eyes,my_appearance.g_eyes,my_appearance.b_eyes)) as color
	if(new_eye_color)
		my_appearance.r_eyes = hex2num(copytext(new_eye_color, 2, 4))
		my_appearance.g_eyes = hex2num(copytext(new_eye_color, 4, 6))
		my_appearance.b_eyes = hex2num(copytext(new_eye_color, 6, 8))

	// HAIR
	if (species)
		var/list/valid_hair = valid_sprite_accessories(hair_styles_list, null, species.name)	//can morph any hair regardless of gender
		if(valid_hair.len)
			var/new_style = input(user, "Select hair style", title, my_appearance.h_style) as null|anything in valid_hair
			if(new_style)
				my_appearance.h_style = new_style

	var/new_hair_color = input(user, "Select hair color.", title,rgb(my_appearance.r_hair,my_appearance.g_hair,my_appearance.b_hair)) as color
	if(new_hair_color)
		my_appearance.r_hair = hex2num(copytext(new_hair_color, 2, 4))
		my_appearance.g_hair = hex2num(copytext(new_hair_color, 4, 6))
		my_appearance.b_hair = hex2num(copytext(new_hair_color, 6, 8))

	// BEARD
	if (species)
		var/list/valid_facial_hair = valid_sprite_accessories(facial_hair_styles_list, null, species.name)	//can morph any beard regardless of gender
		if(valid_facial_hair.len)
			var/new_style = input(user, "Select a facial hair style", title, my_appearance.f_style) as null|anything in valid_facial_hair
			if(new_style)
				my_appearance.f_style = new_style

	var/new_beard_color = input(user, "Select facial hair color.", title,rgb(my_appearance.r_facial,my_appearance.g_facial,my_appearance.b_facial)) as color
	if(new_beard_color)
		my_appearance.r_facial = hex2num(copytext(new_beard_color, 2, 4))
		my_appearance.g_facial = hex2num(copytext(new_beard_color, 4, 6))
		my_appearance.b_facial = hex2num(copytext(new_beard_color, 6, 8))

	if (update_icons_and_dna)
		regenerate_icons()
		check_dna_integrity()
		update_dna_from_appearance()

/datum/human_appearance/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"r_hair",
		"g_hair",
		"b_hair",
		"h_style",
		"r_facial",
		"g_facial",
		"b_facial",
		"f_style",
		"r_eyes",
		"g_eyes",
		"b_eyes",
		"s_tone"
)
	reset_vars_after_duration(resettable_vars, duration)
