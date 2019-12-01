/obj/item/clothing/head/helmet
	name = "helmet"
	icon_state = "helmet_sec"
	item_state = "helmet"
	flags = FPRINT
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	body_parts_covered = HEAD|EARS|EYES|MASKHEADHAIR
	heat_conductivity = HELMET_HEAT_CONDUCTIVITY
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.7
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/head/helmet/visor
	name = "visor helmet"
	desc = "For when you need to protect your face from the backblast of your pepperspray"
	icon_state = "riot_helm"
	item_state = "riot_helm"
	armor = list(melee = 50, bullet = 25, laser = 45, energy = 15, bomb = 30, bio = 0, rad = 0)
	actions_types = list(/datum/action/item_action/toggle_helmet)
	body_parts_covered = FULL_HEAD
	var/state = 1

/obj/item/clothing/head/helmet/visor/New()
	..()
	update_icon()

/obj/item/clothing/head/helmet/visor/attack_self(mob/user)
	state = !state
	to_chat(user, "<span class = 'notice'>You flick \the [src] [state ? "down" : "up"].</span>")
	switch(state)
		if(1) //FACE COVERED
			body_parts_covered = FULL_HEAD
		if(0) //VISOR UP
			body_parts_covered = HEAD|EARS
	update_icon(user)

/obj/item/clothing/head/helmet/visor/update_icon(mob/user)
	switch(state)
		if(1) //FACE COVERED
			armor = initial(armor)
			icon_state = "[initial(icon_state)]_down"
			item_state = "[initial(item_state)]_down"
		if(0)
			armor = list(melee = 50, bullet = 10, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
			icon_state = "[initial(icon_state)]_up"
			item_state = "[initial(item_state)]_down"
	if(user)
		user.update_inv_head()
		user.update_inv_wear_mask()
		user.update_inv_glasses()
		user.update_hair()
		user.update_inv_ears()


/obj/item/clothing/head/helmet/siren
	name = "siren helmet"
	desc = "For the officer that's off patrolling all the nation."
	icon_state = "helmetgoofy" //Sprites courtesy of Blithering
	light_power = 2.5
	light_range = 4
	light_color = LIGHT_COLOR_RED
	actions_types = list(/datum/action/item_action/activate_siren)
	var/spamcheck = 0
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/head/helmet/siren/attack_self(mob/user)
	if(spamcheck)
		return
	playsound(src, 'sound/voice/woopwoop.ogg', 100, 1, vary = 0)
	user.visible_message("<span class='warning'>[user]'s [name] rasps, \"WOOP WOOP!\"</span>", \
						"<span class='warning'>Your [name] rasps, \"WOOP WOOP!\"</span>", \
						"<span class='warning'>You hear a siren: \"WOOP WOOP!\"</span>")

	var/list/bystanders = get_hearers_in_view(world.view, src)
	flick_overlay(image('icons/mob/talk.dmi', user, "hail", MOB_LAYER+1), clients_in_moblist(bystanders), 15)
	spamcheck = 1
	spawn(15)
		spamcheck = 0

/obj/item/clothing/head/helmet/dredd //same stats as /obj/item/clothing/head/helmet/tactical/swat
	name = "Judge Helmet"
	desc = "Judge, Jury, and Executioner."
	icon_state = "dredd-helmet"
	item_state = "dredd-helmet"
	flags = FPRINT
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	heat_conductivity = INS_HELMET_HEAT_CONDUCTIVITY
	species_fit = list()
	pressure_resistance = 200 * ONE_ATMOSPHERE
	siemens_coefficient = 0.5
	eyeprot = 1

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	flags = FPRINT
	item_state = "thunderdome"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	flags = FPRINT
	item_state = "gladiator"
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/roman
	name = "roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	armor = list(melee = 20, bullet = 0, laser = 20, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman"
	item_state = "roman"
	body_parts_covered = HEAD|EARS

/obj/item/clothing/head/helmet/roman/legionaire
	name = "roman legionaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman_c"
	item_state = "roman_c"
	body_parts_covered = HEAD|EARS

/obj/item/clothing/head/helmet/hopcap
	name = "Head of Personnel's Cap"
	desc = "Papers, Please."
	armor = list(melee = 25, bullet = 0, laser = 15, energy = 10, bomb = 5, bio = 0, rad = 0)
	item_state = "hopcap"
	icon_state = "hopcap"
	body_parts_covered = HEAD

/obj/item/clothing/head/helmet/aviatorhelmet
	name = "Aviator Helmet"
	desc = "Help the Bombardier!"
	armor = list(melee = 25, bullet = 0, laser = 20, energy = 10, bomb = 10, bio = 0, rad = 0)
	item_state = "aviator_helmet"
	icon_state = "aviator_helmet"
	species_restricted = list("exclude",VOX_SHAPED)

/obj/item/clothing/head/helmet/piratelord
	name = "pirate lord's helmet"
	desc = "The headwear of an all powerful and bloodthirsty pirate lord. Simply looking at it sends chills down your spine."
	armor = list(melee = 75, bullet = 75, laser = 75,energy = 75, bomb = 75, bio = 100, rad = 90)
	icon_state = "piratelord"

/obj/item/clothing/head/helmet/biker
	name = "Biker's Helmet"
	desc = "This helmet should protect you from russians and masked vigilantes."
	armor = list(melee = 25, bullet = 15, laser = 20, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "biker_helmet"
	body_parts_covered = FULL_HEAD|BEARD

/obj/item/clothing/head/helmet/richard
	name = "Richard"
	desc = "Do you like hurting people?"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	icon_state = "richard"
	body_parts_covered = FULL_HEAD|BEARD

/obj/item/clothing/head/helmet/megahelmet
	name = "DRN-001 Helmet"
	desc = "The helmet of the DRN-001 model. A simple, sturdy blue helmet."
	icon_state = "megahelmet"
	flags = FPRINT
	body_parts_covered = HEAD|EARS
	item_state = "megahelmet"
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/protohelmet
	name = "Prototype Helmet"
	desc = "Shiny red helmet with white accents and a built in shaded visor that does absolutely nothing, nothing but look rad as hell."
	icon_state = "protohelmet"
	flags = FPRINT
	item_state = "protohelmet"
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/breakhelmet
	name = "Broken Helmet"
	desc = "The product of twelve years of work by an eccentric and brilliant loner. A helmet belonging to the perfect man; an unbeatable machine."
	icon_state = "breakhelmet"
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	item_state = "breakhelmet"
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/megaxhelmet
	name = "Maverick Hunter Helmet"
	desc = "Heavily armored upgrade to the DRN-001 model's helmet, now comes with a pointless red crystal thing!"
	icon_state = "megaxhelmet"
	flags = FPRINT
	body_parts_covered = HEAD|EARS
	item_state = "megaxhelmet"
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/volnutthelmet
	name = "Digouter Helmet"
	desc = "A sturdy helmet, fortified to protect from falling rocks or buster shots."
	icon_state = "volnutthelmet"
	flags = FPRINT
	body_parts_covered = HEAD|EARS
	item_state = "volnutthelmet"
	armor = list(melee = 50, bullet = 40, laser = 40,energy = 40, bomb = 5, bio = 0, rad = 0)
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/joehelmet
	name = "Sniper Helmet"
	desc = "Helmet belonging to one of the many mass produced 'Joe' type robots."
	icon_state = "joehelmet"
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	item_state = "joehelmet"
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/doomguy
	name = "Doomguy's helmet"
	desc = ""
	icon_state = "doom"
	flags = FPRINT
	item_state = "doom"
	body_parts_covered = FULL_HEAD|BEARD
	armor = list(melee = 50, bullet = 40, laser = 40,energy = 40, bomb = 5, bio = 0, rad = 0)
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/rune
	name = "rune full helm"
	desc = "A full face helmet."
	icon_state = "knight_rune"
	item_state = "knight_rune"
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 30, bomb = 80, bio = 10, rad = 10)

/obj/item/clothing/head/helmet/knight
	name = "medieval helmet"
	desc = "A classic metal helmet."
	icon_state = "knight_green"
	item_state = "knight_green"
	body_parts_covered = FULL_HEAD|BEARD
	armor = list(melee = 20, bullet = 5, laser = 2,energy = 2, bomb = 2, bio = 2, rad = 0)
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/knight/blue
	icon_state = "knight_blue"
	item_state = "knight_blue"

/obj/item/clothing/head/helmet/knight/yellow
	icon_state = "knight_yellow"
	item_state = "knight_yellow"

/obj/item/clothing/head/helmet/knight/red
	icon_state = "knight_red"
	item_state = "knight_red"

/obj/item/clothing/head/helmet/knight/templar
	name = "crusader helmet"
	desc = "Deus Vult."
	icon_state = "knight_templar"
	item_state = "knight_templar"

/obj/item/clothing/head/helmet/knight/interrogator
	name = "interrogator helmet"
	desc = "A skull-shaped helmet, equipped red visors, marked by the oath of the dark angels."
	icon_state = "interrogator"
	item_state = "interrogator"

/obj/item/clothing/head/helmet/neorussian
	name = "neo-Russian helmet"
	desc = "This piece of equipment can double as a pillow, a bowl, an emergency toilet, and sometimes as a helmet."
	icon_state = "nr_helmet"
	item_state = "nr_helmet"
	body_parts_covered = EARS|HEAD
	heat_conductivity = INS_HELMET_HEAT_CONDUCTIVITY

/obj/item/clothing/head/helmet/police
	name = "police custodian helmet"
	desc = "A fancy helmet for a fancy policeman."
	icon_state = "police_helmet"
	item_state = "police_helmet"
	body_parts_covered = HEAD

/obj/item/clothing/head/helmet/chainmail
	name = "chainmail coif"
	desc = "chains fashioned together to be a hood to wear over your head"
	icon_state = "chainmail_head"
	item_state = "chainmail_head"
	armor = list(melee = 10, bullet = 15, laser = 2,energy = 2, bomb = 2, bio = 2, rad = 0)
	flags = FPRINT
	siemens_coefficient = 1