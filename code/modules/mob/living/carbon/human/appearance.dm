#define INDEX_RED 1
#define INDEX_GREEN 2
#define INDEX_BLUE 3

/datum/human_appearance
	// For identification.
	var/name
	var/gender

	// "Proper" to the appearance datum.
	var/s_tone

	var/h_style = "Bald"
	var/r_hair
	var/g_hair
	var/b_hair

	var/f_style
	var/r_facial
	var/g_facial
	var/b_facial

	var/r_eyes
	var/g_eyes	
	var/b_eyes

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

/mob/living/carbon/human/proc/pick_gender(var/mob/user)
	var/new_gender = alert(user, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		setGender(new_gender == "Male" ? MALE : FEMALE)
	update_body()

/mob/living/carbon/human/proc/pick_appearance(var/mob/user)
	var/new_tone = input(user, "Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text
	if (!new_tone)
		new_tone = 35
	my_appearance.s_tone = max(min(round(text2num(new_tone)), 220), 1)
	my_appearance.s_tone =  -src.my_appearance.s_tone + 35

	var/new_facial = input(user, "Please select facial hair color.", "Character Generation") as color
	if(new_facial)
		my_appearance.r_facial = hex2num(copytext(new_facial, 2, 4))
		my_appearance.g_facial = hex2num(copytext(new_facial, 4, 6))
		my_appearance.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input(user, "Please select hair color.", "Character Generation") as color
	if(new_facial)
		my_appearance.r_hair = hex2num(copytext(new_hair, 2, 4))
		my_appearance.g_hair = hex2num(copytext(new_hair, 4, 6))
		my_appearance.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input(user, "Please select eye color.", "Character Generation") as color
	if(new_eyes)
		my_appearance.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		my_appearance.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		my_appearance.b_eyes = hex2num(copytext(new_eyes, 6, 8))

	//hair
	var/new_hstyle = input(user, "Select a hair style", "Grooming")  as null|anything in hair_styles_list
	if(new_hstyle)
		my_appearance.h_style = new_hstyle

	// facial hair
	var/new_fstyle = input(user, "Select a facial hair style", "Grooming")  as null|anything in facial_hair_styles_list
	if(new_fstyle)
		my_appearance.f_style = new_fstyle

	//M.rebuild_appearance()
	update_hair()
	update_body()
	check_dna()

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
