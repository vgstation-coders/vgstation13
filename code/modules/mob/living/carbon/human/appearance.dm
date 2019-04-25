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

/mob/living/carbon/human/proc/randomise_appearance_for(var/new_gender)
	var/datum/human_appearance/appearance = new

	if (new_gender)
		appearance.gender = new_gender
	else
		appearance.gender = pick(MALE, FEMALE)
	
	appearance.s_tone = random_skin_tone(species)
	appearance.h_style = random_hair_style(gender, species)
	appearance.f_style = random_facial_hair_style(gender, species)

	var/list/hair_colour = randomize_hair_color("hair")
	var/list/facial_hair_colour = randomize_hair_color("facial")
	var/list/eye_colour = randomize_eyes_color()

	appearance.r_hair = hair_colour[INDEX_RED]
	appearance.g_hair = hair_colour[INDEX_GREEN]
	appearance.b_hair = hair_colour[INDEX_BLUE]

	appearance.r_facial = facial_hair_colour[INDEX_RED]
	appearance.g_facial = facial_hair_colour[INDEX_GREEN]
	appearance.b_facial = facial_hair_colour[INDEX_BLUE]

	appearance.r_eyes = eye_colour[INDEX_RED]
	appearance.g_eyes = eye_colour[INDEX_GREEN]
	appearance.b_eyes = eye_colour[INDEX_BLUE]
	gender = appearance.gender
	regenerate_icons()
	return appearance

/mob/living/carbon/human/proc/randomize_hair_color(var/target = "hair")
	if(prob (75) && target == "facial") // Chance to inherit hair color
		return list(my_appearance.r_hair, my_appearance.g_hair, my_appearance.b_hair)

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

/mob/living/carbon/human/proc/randomize_eyes_color()
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