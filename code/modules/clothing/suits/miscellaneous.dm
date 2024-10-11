/*
 * Contains:
 *		Lasertag
 *		Costume
 *		Misc
 */

/*
 * Lasertag
 */

var/list/tag_suits_list = list()

/obj/item/clothing/suit/tag
	blood_overlay_type = "armor"
	origin_tech = Tc_MATERIALS + "=1;" + Tc_MAGNETS + "=2"
	body_parts_covered = FULL_TORSO
	siemens_coefficient = 3.0
	var/datum/laser_tag_game/my_laser_tag_game = null
	var/datum/laser_tag_participant/player = null

/obj/item/clothing/suit/tag/New()
	tag_suits_list += src
	return ..()

/obj/item/clothing/suit/tag/Destroy()
	tag_suits_list -= src
	my_laser_tag_game = null
	player = null
	return ..()

/obj/item/clothing/suit/tag/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return 0
	if(istype(target, /obj/item/clothing/under) || istype(target, /obj/item/clothing/monkeyclothes))
		var/obj/item/clothing/C = target
		var/obj/item/clothing/accessory/lasertag/L = new()
		if(C.check_accessory_overlap(L))
			to_chat(user, "<span class='notice'>You cannot attach more accessories of this type to \the [C].</span>")
			return
		if(user.drop_item(src))
			to_chat(user, "<span class='notice'>You attach \the [src] to \the [C].</span>")
			C.attach_accessory(L)
			transfer_fingerprints(src,L)
			forceMove(L)
			L.source_vest = src
			L.update_icon()
		return 1
	return ..()

/obj/item/clothing/suit/tag/attack_self(var/mob/living/carbon/human/H)
	if (H.incapacitated())
		return
	else
		H << browse(get_window_text(H),"window=laser_tag_window;size=700x500")

/obj/item/clothing/suit/tag/proc/get_window_text(var/mob/living/carbon/human/H)
	var/dat = list()
	dat += "<h3>Laser tag games</h3> <br/>"
	dat += "<b>Tag:</b> [get_gamer_tag(H)]<br/>"
	dat += "<hr/>"
	if (!my_laser_tag_game)
		dat += "Available laser tag games: <br/>"
		for (var/datum/laser_tag_game/game in laser_tag_games)
			dat += "<b>[game.name]</b> - <a href='?src=\ref[src]&join_game=\ref[game]'>Join!</a> <br/>'"
	else
		dat += "My game: <b>[my_laser_tag_game.name]</b>"
		if (my_laser_tag_game.owner == player)
			dat += " -- <a href='?src=\ref[src]&edit_game=\ref[my_laser_tag_game]'>Edit/delete</a>"
		dat += "<br/>"
		dat += "<b>Mode:</b> [my_laser_tag_game.mode] <br/>"
		dat += "<a href='?src=\ref[src]&get_score=\ref[my_laser_tag_game]'>Get scoreboard</a><br/>"
		dat += "<a href='?src=\ref[src]&leave_game=\ref[my_laser_tag_game]'>Leave game</a><br/>"
	dat += "<hr/>"
	dat += "<a href='?src=\ref[src]&create_game=1'>Create a new game</a><br/>"
	dat += "<hr/>"
	dat += "<a href='?src=\ref[src]&clear_gamertag=1'>Clear tag</a>"

	return jointext(dat,"")

/obj/item/clothing/suit/tag/proc/refresh_edit_window(var/mob/user, var/datum/laser_tag_game/my_laser_tag_game)
	var/dat = {"
		<h3>Game parameters</h3>
		<br/>
		<b>Mode:</b> <a href='?src=\ref[src]&game_mode=\ref[my_laser_tag_game]'>[my_laser_tag_game.mode] </a><br/>
		<b>Fire mode:</b> <a href='?src=\ref[src]&fire_mode=\ref[my_laser_tag_game]'>[my_laser_tag_game.fire_mode] </a> <br/>
		<b>Stun time:</b> <a href='?src=\ref[src]&stun_time=\ref[my_laser_tag_game]'>[my_laser_tag_game.stun_time] </a> <br/>
		<b>Disable time:</b> <a href='?src=\ref[src]&disable_time=\ref[my_laser_tag_game]'>[my_laser_tag_game.disable_time] </a> <br/>
		<b><a href='?src=\ref[src]&delete_game=\ref[my_laser_tag_game]'>Delete the game</a></b> <br/>
		<br/>
		<b><a href='?src=\ref[src]&edition_done=\ref[my_laser_tag_game]'>Done</a></b>
	""}
	user << browse(dat,"window=laser_tag_window2;size=250x250")

/obj/item/clothing/suit/tag/Topic(href, href_list)
	if(..())
		return 1

	if (href_list["join_game"])
		var/datum/laser_tag_game/game = locate(href_list["join_game"])
		game.handle_new_player(player, usr)
		my_laser_tag_game = game
		usr << browse(get_window_text(usr),"window=laser_tag_window;size=500x250")
		return

	if (href_list["create_game"])
		var/datum/laser_tag_game/game = new
		game.owner = player
		my_laser_tag_game = game
		game.name = "[get_first_word(usr.name)]'s game"
		game.handle_new_player(player, usr)
		refresh_edit_window(usr, game)
		usr << browse(get_window_text(usr),"window=laser_tag_window;size=500x250")
		return

	// Game parametrisation
	if (href_list["edit_game"])
		var/datum/laser_tag_game/game = locate(href_list["edit_game"])
		if (game.owner != player)
			return
		refresh_edit_window(usr, game)
		return

	if (href_list["game_mode"])
		var/datum/laser_tag_game/game = locate(href_list["game_mode"])
		if (game.owner != player)
			return
		var/choices = list(
			LT_MODE_TEAM,
			LT_MODE_FFA,
		)
		var/choice = input(usr, "Choose the game mode.", "Game mode") as null|anything in choices
		if (choice)
			game.mode = choice
		refresh_edit_window(usr, game)
		return

	if (href_list["fire_mode"])
		var/datum/laser_tag_game/game = locate(href_list["fire_mode"])
		if (game.owner != player)
			return
		var/choices = list(
			LT_FIREMODE_LASER,
			LT_FIREMODE_TASER,
		)
		var/choice = input(usr, "Choose the fire mode.", "Fire mode") as null|anything in choices
		if (choice)
			game.fire_mode = choice
		refresh_edit_window(usr, game)
		return

	if (href_list["stun_time"])
		var/datum/laser_tag_game/game = locate(href_list["stun_time"])
		if (game.owner != player)
			return
		var/choice = input(usr, "Choose the stun duration.", "Stun duration") as null|num
		game.stun_time = clamp(choice, 0, 12)
		refresh_edit_window(usr, game)
		return

	if (href_list["disable_time"])
		var/datum/laser_tag_game/game = locate(href_list["disable_time"])
		if (game.owner != player)
			return
		var/choice = input(usr, "Choose the disbale duration.", "Disable duration") as null|num
		game.disable_time = clamp(choice, 0, 30)
		refresh_edit_window(usr, game)
		return

	if (href_list["edition_done"])
		usr << browse(null,"window=laser_tag_window2;size=250x250")
		return

	if (href_list["delete_game"])
		var/datum/laser_tag_game/game = locate(href_list["delete_game"])
		if (game.owner != player)
			return
		qdel(game)
		usr << browse(null,"window=laser_tag_window2;size=250x250")
		return
	// End game parametrisation

	if (href_list["get_score"])
		var/datum/laser_tag_game/game = locate(href_list["get_score"])
		game.get_score_board(usr)
		return

	if (href_list["leave_game"])
		var/datum/laser_tag_game/game = locate(href_list["leave_game"])
		game.kick_player(usr)
		usr << browse(get_window_text(usr),"window=laser_tag_window;size=500x250")
		return

	if (href_list["clear_gamertag"])
		my_laser_tag_game = null
		player = null
		usr << browse(null,"window=laser_tag_window;size=500x250")
		to_chat(usr, "<span = 'notice'>You clear your tag out of the vest and leave it to be used by someone else.</span>")
		return

/proc/get_tag_armor(mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(istype(H.wear_suit, /obj/item/clothing/suit/tag))
			return H.wear_suit
		if(isclothing(H.w_uniform))
			var/obj/item/clothing/C = H.w_uniform
			for(var/obj/item/clothing/accessory/lasertag/L in C.accessories)
				return L.source_vest
	if(ismonkey(M))
		var/mob/living/carbon/monkey/MO = M
		if(isclothing(MO.uniform))
			for(var/obj/item/clothing/accessory/lasertag/L in MO.uniform.accessories)
				return L.source_vest
	if(ishologram(M))
		var/mob/living/simple_animal/hologram/advanced/AH = M
		if(istype(AH.wear_suit, /obj/item/clothing/suit/tag))
			return AH.wear_suit
		if(isclothing(AH.w_uniform))
			var/obj/item/clothing/C = AH.w_uniform
			for(var/obj/item/clothing/accessory/lasertag/L in C.accessories)
				return L.source_vest

/obj/item/clothing/suit/tag/proc/get_gamer_tag(var/mob/living/carbon/human/H)
	if (!player)
		var/datum/laser_tag_participant/gamer = new
		gamer.nametag = get_first_word(H.name) + "#[rand(1000, 9999)]"
		switch (src.type)
			if (/obj/item/clothing/suit/tag/bluetag)
				gamer.team = "Blue"
			if (/obj/item/clothing/suit/tag/redtag)
				gamer.team = "Red"
		src.player = gamer
	return player.nametag

/obj/item/clothing/suit/tag/bluetag
	name = "blue laser tag armour"
	desc = "Blue Pride, Station Wide."
	icon_state = "bluetag"
	item_state = "bluetag"
	allowed = list (/obj/item/weapon/gun/energy/tag/blue)

/obj/item/clothing/suit/tag/redtag
	name = "red laser tag armour"
	desc = "Pew pew pew."
	icon_state = "redtag"
	item_state = "redtag"
	allowed = list (/obj/item/weapon/gun/energy/tag/red)

/*
 * Costume
 */
/obj/item/clothing/suit/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	flags = FPRINT
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV

/obj/item/clothing/suit/hgpirate
	name = "pirate captain coat"
	desc = "Yarr."
	icon_state = "hgpirate"
	flags = FPRINT
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV


/obj/item/clothing/suit/cyborg_suit
	name = "cyborg suit"
	desc = "Suit for a cyborg costume."
	icon_state = "death"//broken on mob, item fine
	flags = FPRINT
	siemens_coefficient = 1
	fire_resist = T0C+5200
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS

/obj/item/clothing/suit/greatcoat
	name = "great coat"
	desc = "A Nazi great coat."
	icon_state = "nazi"//broken on mob, item fine
	flags = FPRINT


/obj/item/clothing/suit/johnny_coat
	name = "johnny~~ coat"
	desc = "Johnny~~"
	icon_state = "johnny"//broken on mob, item fine
	item_state = "johnny"
	flags = FPRINT


/obj/item/clothing/suit/justice
	name = "justice suit"
	desc = "this pretty much looks ridiculous."
	icon_state = "justice"
	flags = FPRINT
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS

/obj/item/clothing/suit/judgerobe
	name = "judge's robe"
	desc = "This robe commands authority."
	icon_state = "judge"
	item_state = "judge"
	species_fit = list(INSECT_SHAPED)
	clothing_flags = ONESIZEFITSALL
	allowed = list(/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/spacecash)


/obj/item/clothing/suit/wcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "vest"
	item_state = "wcoat"
	blood_overlay_type = "armor"
	body_parts_covered = FULL_TORSO
	species_fit = list(INSECT_SHAPED)


/obj/item/clothing/suit/apron/overalls
	name = "coveralls"
	desc = "A set of denim overalls."
	icon_state = "overalls"
	item_state = "overalls"
	body_parts_covered = FULL_TORSO|LEGS
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)


/obj/item/clothing/suit/syndicatefake
	name = "red space suit replica"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "A plastic replica of the syndicate space suit, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/toy)
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/suit/spaceninjafake
	name = "space ninja suit replica"
	icon_state = "s-ninja-old"
	item_state = "s-ninja_suit"
	desc = "A plastic replica of a ninja suit, you'll look just like a real murderous space ninja in this! This is a toy, it is not made for use in space!"
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/toy)
	body_parts_covered = ARMS|LEGS|FULL_TORSO

/obj/item/clothing/suit/opsfake
	icon_state = "rig-syndi"
	name = "blood-red hardsuit"
	desc = "A plastic replica of a nuclear operative's suit, you'll look just like a real murderous syndicate operative in this! This is a toy, it is not made for use in space!"
	item_state = "syndie_hardsuit"
	species_fit = list(VOX_SHAPED, SKRELL_SHAPED, UNATHI_SHAPED, TAJARAN_SHAPED, INSECT_SHAPED, GREY_SHAPED)
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/toy)
	body_parts_covered = ARMS|LEGS|FULL_TORSO

/obj/item/clothing/suit/timefake
	name = "time suit"
	desc = "A replica of a real time suit; it reminds you of the previous timelines. May the loop protect the ones left behind."
	icon_state = "time_suit"
	item_state = "time_suit"
	species_fit = list(VOX_SHAPED, SKRELL_SHAPED, UNATHI_SHAPED, TAJARAN_SHAPED, INSECT_SHAPED)
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/toy)
	body_parts_covered = ARMS|LEGS|FULL_TORSO
	clothing_flags = ONESIZEFITSALL

/obj/item/clothing/suit/sith
	name = "Sith Robe"
	desc = "It's treason then."
	icon_state = "sith"
	item_state = "sith"
	clothing_flags = ONESIZEFITSALL
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET
	wizard_garb = 1 //Allows lightning to be used
	allowed = list(/obj/item/weapon/melee/energy/sword, /obj/item/weapon/melee/energy/sword/dualsaber) //Fits e-swords
	species_fit = list(INSECT_SHAPED)
	hood = new /obj/item/clothing/head/sith()
	hood_suit_name = "robes"

/obj/item/clothing/suit/hastur
	name = "Hastur's Robes"
	desc = "Robes not meant to be worn by man."
	icon_state = "hastur"
	item_state = "hastur"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET
	hood = new /obj/item/clothing/head/hasturhood()
	hood_suit_name = "robes"

/obj/item/clothing/suit/reaper_robes
	name = "\improper grim robes"
	desc = "Tends to snag on tombstones"
	icon_state = "reaper_hoodie" //edited version of chaplain_hoodie. 1px longer, and more open at the front
	item_state = "reaper_hoodie"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	body_parts_covered = FULL_TORSO|LEGS|ARMS|IGNORE_INV
	hood = new /obj/item/clothing/head/chaplain_hood()
	hood_suit_name = "robes"

/obj/item/clothing/suit/cassock
	name = "Cassock"
	desc = "A black garment belonging to a priest."
	icon_state = "cassock"
	item_state = "cassock"
	body_parts_covered = ARMS|LEGS|FULL_TORSO
	clothing_flags = ONESIZEFITSALL
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/suit/imperium_monk
	name = "Imperium monk"
	desc = "Have YOU killed a xenos today?"
	icon_state = "imperium_monk"
	item_state = "imperium_monk"
	body_parts_covered = FULL_TORSO|LEGS|FEET|ARMS
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/suit/vamphunter
	name = "vampire hunter armor"
	desc = "A set of ornate leather armor modelled off of a set worn by an ancient vampire-hunting warrior. While quite fearsome looking, it offers little in protection."
	icon_state = "vamphunter"
	item_state = "vamphunter"
	body_parts_covered = FULL_TORSO|FEET
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/suit/hunter
	name ="modern vampire hunter's overcoat"
	desc = "An iconic blue overcoat similar to the one worn by a vampire hunter that vanquished Dracula 800 years ago. The sleeves have been ripped off for a better range of motion."
	icon_state = "hunter_overcoat"
	item_state = "hunter_overcoat"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing_castlevania.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing_castlevania.dmi')
	body_parts_covered = FULL_TORSO

/obj/item/clothing/suit/hunter/offenseTackleBonus()
	return 3

/obj/item/clothing/suit/hunter/rangeTackleBonus()
	return 1

/obj/item/clothing/suit/chickensuit
	name = "chicken suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "chickensuit"
	item_state = "chickensuit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)
	body_parts_covered = FULL_TORSO|LEGS|FEET|ARMS|HANDS|HIDETAIL
	siemens_coefficient = 2.0

/obj/item/clothing/suit/chickensuit/white
	name = "white chicken suit"
	desc = "Silky smooth. The feathers of legend...could it be..."
	icon_state = "chickensuit_white"
	item_state = "chickensuit_white"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/monkeysuit
	name = "Monkey Suit"
	desc = "A suit that looks like a primate."
	icon_state = "monkeysuit"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS|HIDETAIL
	siemens_coefficient = 2.0
	clothing_flags = ONESIZEFITSALL


/obj/item/clothing/suit/holidaypriest
	name = "Holiday Priest"
	desc = "This is a nice holiday my son."
	icon_state = "holidaypriest"
	item_state = "holidaypriest"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/suit/highlanderkilt
	name = "highlander's kilt"
	desc = "There can be only one."
	icon_state = "highlanderkilt"
	item_state = "highlanderkilt"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	wizard_garb = 1 //required for the spell in the highlander syndicate bundle

/obj/item/clothing/suit/cardborg
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides."
	icon_state = "cardborg"
	item_state = "cardborg"
	species_fit = list(INSECT_SHAPED)
	starting_materials = list(MAT_CARDBOARD = 11250)
	w_type=RECYK_MISC

/*
 * Misc
 */

/obj/item/clothing/suit/strait_jacket
	name = "straitjacket"
	desc = "A suit that completely restrains the wearer."
	icon_state = "strait_jacket"
	item_state = "strait_jacket"
	origin_tech = Tc_BIOTECH + "=2"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS|HIDETAIL
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/suit/ianshirt
	name = "worn shirt"
	desc = "A worn out, curiously comfortable t-shirt with a picture of Ian. You wouldn't go so far as to say it feels like being hugged when you wear it but it's pretty close. Good for sleeping in."
	icon_state = "ianshirt"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)
	body_parts_covered = ARMS|FULL_TORSO

//Blue suit jacket toggle
/obj/item/clothing/suit/suit/verb/toggle()
	set name = "Toggle Jacket Buttons"
	set category = "Object"
	set src in usr

	if(!usr.canmove || usr.isUnconscious() || usr.restrained())
		return 0

	if(src.icon_state == "suitjacket_blue_open")
		src.icon_state = "suitjacket_blue"
		src.item_state = "suitjacket_blue"
		to_chat(usr, "You button up the suit jacket.")
	else if(src.icon_state == "suitjacket_blue")
		src.icon_state = "suitjacket_blue_open"
		src.item_state = "suitjacket_blue_open"
		to_chat(usr, "You unbutton the suit jacket.")
	else
		to_chat(usr, "You button-up some imaginary buttons on your [src].")
		return
	usr.update_inv_wear_suit()

//coats

/obj/item/clothing/suit/leathercoat
	name = "leather coat"
	desc = "A long, thick black leather coat."
	icon_state = "leathercoat"//broken completely
	flags = FPRINT

/obj/item/clothing/suit/browncoat
	name = "brown leather coat"
	desc = "A long, brown leather coat."
	icon_state = "browncoat"//broken completely
	flags = FPRINT

/obj/item/clothing/suit/neocoat
	name = "black coat"
	desc = "A flowing, black coat."
	icon_state = "neocoat"//broken completely
	flags = FPRINT

//actual suits

/obj/item/clothing/suit/creamsuit
	name = "cream suit"
	desc = "A cream coloured, genteel suit."
	icon_state = "creamsuit"//broken completely
	flags = FPRINT

//stripper

/obj/item/clothing/under/stripper/stripper_pink
	name = "pink swimsuit"
	desc = "A rather skimpy pink swimsuit."
	icon_state = "stripper_p_under"
	_color = "stripper_p"
	siemens_coefficient = 1

/obj/item/clothing/under/stripper/stripper_green
	name = "green swimsuit"
	desc = "A rather skimpy green swimsuit."
	icon_state = "stripper_g_under"
	_color = "stripper_g"
	siemens_coefficient = 1

/obj/item/clothing/suit/stripper/stripper_pink
	name = "pink skimpy dress"
	desc = "A rather skimpy pink dress."
	icon_state = "stripper_p_over"
	item_state = "stripper_p"
	siemens_coefficient = 1

/obj/item/clothing/suit/stripper/stripper_green
	name = "green skimpy dress"
	desc = "A rather skimpy green dress."
	icon_state = "stripper_g_over"
	item_state = "stripper_g"
	siemens_coefficient = 1

/obj/item/clothing/under/stripper/mankini
	name = "the mankini"
	desc = "No honest man would wear this abomination."
	icon_state = "mankini"
	_color = "mankini"
	siemens_coefficient = 1
	body_parts_covered = 0
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/xenos
	name = "xenos suit"
	desc = "A suit made out of chitinous alien hide."
	icon_state = "xenos"
	item_state = "xenos_helm"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	siemens_coefficient = 2.0

//swimsuit

/obj/item/clothing/under/swimsuit
	siemens_coefficient = 1
	body_parts_covered = 0

/obj/item/clothing/under/swimsuit/black
	name = "black swimsuit"
	desc = "An oldfashioned black swimsuit."
	icon_state = "swim_black"
	_color = "swim_black"
	siemens_coefficient = 1
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/swimsuit/blue
	name = "blue swimsuit"
	desc = "An oldfashioned blue swimsuit."
	icon_state = "swim_blue"
	_color = "swim_blue"
	siemens_coefficient = 1
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/swimsuit/purple
	name = "purple swimsuit"
	desc = "An oldfashioned purple swimsuit."
	icon_state = "swim_purp"
	_color = "swim_purp"
	siemens_coefficient = 1
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/swimsuit/green
	name = "green swimsuit"
	desc = "An oldfashioned green swimsuit."
	icon_state = "swim_green"
	_color = "swim_green"
	siemens_coefficient = 1
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/swimsuit/red
	name = "red swimsuit"
	desc = "An oldfashioned red swimsuit."
	icon_state = "swim_red"
	_color = "swim_red"
	siemens_coefficient = 1
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/suit/simonjacket
	name = "Simon's Jacket"
	desc = "Now you too can pierce the heavens."
	icon_state = "simonjacket"
	species_fit = list(VOX_SHAPED)
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV
	allowed = list (/obj/item/weapon/pickaxe/drill)

/obj/item/clothing/suit/kaminacape
	name = "Kamina's Cape"
	desc = "Don't believe in yourself, dumbass. Believe in me. Believe in the Kamina who believes in you."
	icon_state = "kaminacape"
	body_parts_covered = 0

/obj/item/clothing/suit/officercoat
	name = "Officer's Coat"
	desc = "Ein Mantel gemacht, um die Juden zu bestrafen."
	icon_state = "officersuit"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/soldiercoat
	name = "Soldier's Coat"
	desc = "Und das heißt: Erika."
	icon_state = "soldiersuit"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/suit/russofurcoat
	name = "russian fur coat"
	desc = "Let the land do the fighting for you."
	icon_state = "russofurcoat"
	allowed = list(/obj/item/weapon/gun)
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV
	species_fit = list(INSECT_SHAPED, GREY_SHAPED)

/obj/item/clothing/suit/doshjacket
	name = "Plasterer's Jacket"
	desc = "Perfect for doing up the house."
	icon_state = "doshjacket"
	body_parts_covered = FULL_TORSO|ARMS
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/suit/storage/greaserjacket
	name = "Greaser Jacket"
	desc = "Need a haircut greaser?"
	icon_state = "greaserjacket_plain"
	item_state = "greaserjacket_plain"
	body_parts_covered = FULL_TORSO|ARMS
	species_fit = list(INSECT_SHAPED, GREY_SHAPED, VOX_SHAPED)
	clothing_flags = ONESIZEFITSALL
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/weapon/tank/emergency_nitrogen)

/obj/item/clothing/suit/storage/greaserjacket/spider
	name = "Spider Leather Jacket"
	desc = "Lookin' pretty fly, guy."
	icon_state = "greaserjacket_spider"
	item_state = "greaserjacket_spider"

/obj/item/clothing/suit/storage/greaserjacket/cult
	name = "Nar-Sie MC Jacket"
	desc = "Betcha didn't think cultists could look this good."
	icon_state = "greaserjacket_cult"
	item_state = "greaserjacket_cult"

/obj/item/clothing/suit/storage/greaserjacket/snakes
	name = "Tunnel Snake Jacket"
	desc = "Tunnel Snakes Rule!"
	icon_state = "greaserjacket_snakes"
	item_state = "greaserjacket_snakes"

/obj/item/clothing/suit/lordadmiral
	name = "Lord Admiral's Coat"
	desc = "You'll be the Ruler of the King's Navy in no time."
	icon_state = "lordadmiral"
	species_fit = list(INSECT_SHAPED)
	allowed = list (/obj/item/weapon/gun,/obj/item/toy/gun)

/obj/item/clothing/suit/raincoat
	name = "Raincoat"
	desc = "Do you like Huey Lewis and the News?"
	icon_state = "raincoat"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV //transparent
	allowed = list (/obj/item/weapon/fireaxe)
	sterility = 100
	starting_materials = list(MAT_PLASTIC = 5*CC_PER_SHEET_MISC) //Recipe calls for 5 sheets
	w_type = RECYK_PLASTIC

/obj/item/clothing/suit/kefkarobe
	name = "Crazed Jester's Robe"
	desc = "Do I look like a waiter?"
	icon_state = "kefkarobe"

/obj/item/clothing/suit/libertycoat
	name = "Liberty Coat"
	desc = "Smells faintly of freedom."
	icon_state = "libertycoat"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	body_parts_covered = FULL_TORSO|ARMS

/obj/item/clothing/suit/storage/draculacoat
	name = "Vampire Coat"
	desc = "What is a man? A miserable little pile of secrets."
	icon_state = "draculacoat"
	blood_overlay_type = "coat"
	cant_hold = list(/obj/item/weapon/nullrod, /obj/item/weapon/storage/bible)
	armor = list(melee = 30, bullet = 20, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	clothing_flags = ONESIZEFITSALL

/obj/item/clothing/suit/storage/draculacoat_fake
	name = "Vampire Costume"
	desc = "Smells faintly of pumpkins and bloody mary."
	icon_state = "draculacoat"
	blood_overlay_type = "coat"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	clothing_flags = ONESIZEFITSALL

/obj/item/clothing/suit/bedsheet_ghost
	name = "Bedsheet Ghost"
	desc = "You did cut out eye holes, but you don't remember drawing a face. Spooooky"
	icon_state = "bedsheet_ghost"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')
	blood_overlay_type = "coat"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	hood = new /obj/item/clothing/head/bedsheet_ghost()
	hood_suit_name = "robes"
	body_parts_covered = FULL_BODY|HIDEBACK
	body_parts_visible_override = FEET
	force_hood = TRUE

/obj/item/clothing/suit/maidapron
	name = "Apron"
	desc = "Simple white apron."
	icon_state = "maidapron"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	body_parts_covered = FULL_TORSO

/obj/item/clothing/suit/clownpiece
	name = "small fairy wings"
	desc = "Some small and translucid insect-like wings."
	icon_state = "clownpiece"
	body_parts_covered = 0

/obj/item/clothing/suit/clownpiece/flying
	name = "small fairy wings"
	desc = "Some small and translucid insect-like wings. Looks like these are the real deal!"
	icon_state = "clownpiece-fly"

/obj/item/clothing/suit/clownpiece/flying/attack_hand(var/mob/living/carbon/human/H)
	if(!istype(H))
		return ..()
	if((src == H.wear_suit) && H.flying)
		H.stop_flying()
		animate(H, pixel_y = pixel_y + 10 * PIXEL_MULTIPLIER, time = 1, loop = 1)
		animate(H, pixel_y = pixel_y, time = 10, loop = 1, easing = SINE_EASING)
		animate(H)
		if(H.lying)//aka. if they have just been stunned
			H.pixel_y -= 6 * PIXEL_MULTIPLIER
	..()

/obj/item/clothing/suit/clownpiece/flying/equipped(var/mob/user, var/slot)
	var/mob/living/carbon/human/H = user
	if(!istype(H)) return
	if((slot == slot_wear_suit) && !user.flying)
		user.flying = 1
		animate(user, pixel_y = pixel_y + 10 * PIXEL_MULTIPLIER, time = 10, loop = 1, easing = SINE_EASING)

/obj/item/clothing/suit/clownpiece/flying/dropped(mob/user as mob)
	if(user.flying)
		user.stop_flying()
		animate(user, pixel_y = pixel_y + 10 * PIXEL_MULTIPLIER, time = 1, loop = 1)
		animate(user, pixel_y = pixel_y, time = 10, loop = 1, easing = SINE_EASING)
		animate(user)
		if(user.lying)//aka. if they have just been stunned
			user.pixel_y -= 6 * PIXEL_MULTIPLIER
	..()


/obj/item/clothing/suit/jumper/christmas
	name = "christmas jumper"
	desc = "Made by professional knitting nanas to truly fit the festive mood."
	heat_conductivity = INS_ARMOUR_HEAT_CONDUCTIVITY
	body_parts_covered = FULL_TORSO|ARMS
	icon_state = "cjumper-red"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/suit/jumper/christmas/red
	desc = "Made by professional knitting nanas to truly fit the festive mood. This one has a tasteful red colour to it, and a festive Fir tree."
	icon_state = "cjumper-red"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/suit/jumper/christmas/blue
	desc = "Made by professional knitting nanas to truly fit the festive mood. This one has a nice light blue colouring to it, and has a snowman on it."
	icon_state = "cjumper-blue"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/suit/jumper/christmas/green
	desc = "Made by professional knitting nanas to truly fit the festive mood. This one is green in colour, and has a reindeer with a red nose on the front. At least you think it's a reindeer."
	icon_state = "cjumper-green"
	species_fit = list(GREY_SHAPED, INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/suit/spaceblanket
	plane = ABOVE_OBJ_PLANE
	layer = BLANKIES_LAYER
	w_class = W_CLASS_SMALL
	icon_state = "shittyuglyawfulBADblanket"
	name = "space blanket"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	desc = "First developed by NASA in 1964 for the US space program!"
	heat_conductivity = 0 // Good luck losing heat in this!
	slowdown = HARDSUIT_SLOWDOWN_BULKY
	var/bearpelt = 0
	extinguishingProb = 70
	species_fit = list(INSECT_SHAPED)


/obj/item/clothing/suit/spaceblanket/attackby(obj/item/W,mob/user)
	..()
	if(istype(W,/obj/item/clothing/head/bearpelt) && !bearpelt)
		to_chat(user,"<span class='notice'>You add \the [W] to \the [src].</span>")
		qdel(W)
		qdel(src)
		var/obj/advanced = new /obj/item/clothing/suit/spaceblanket/advanced (src.loc)
		user.put_in_hands(advanced)

/obj/item/clothing/suit/spaceblanket/advanced
	name = "advanced space blanket"
	desc = "Using an Advanced Space Blanket requires Advanced Power Blanket Training."
	icon_state = "goodblanket"
	heat_conductivity = 0
	slowdown = HARDSUIT_SLOWDOWN_MED
	bearpelt = 1
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/suit/storage/trader
	name = "trader's coat"
	desc = "A long trenchcoat with many pockets sewn into the lining."
	icon_state = "tradercoat"
	item_state = "tradercoat"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')
	blood_overlay_type = "coat"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	max_combined_w_class = 28
	storage_slots = 14
	actions_types = list(/datum/action/item_action/show_wares)
	allowed = list(/obj/item/weapon/gun/projectile/hecate/hunting)

/datum/action/item_action/show_wares/Trigger()
	var/obj/item/clothing/suit/storage/trader/T = target
	if(!istype(T))
		return
	T.show_wares()

/obj/item/clothing/suit/storage/trader/proc/show_wares()
	var/mob/M = loc
	if(!istype(M) || M.incapacitated())
		return
	M.visible_message("<span class='notice'>\The [M] opens \his [src.name], allowing you to see inside. <a HREF='?src=\ref[M];listitems=\ref[hold]'>Take a closer look.</a></span>","<span class='notice'>You flash the contents of your [src.name].</span>")

/obj/item/clothing/suit/mino
	name = "mino"
	desc = "A raincoat made of straw."
	icon_state = "mino"
	item_state = "mino"
	body_parts_covered = ARMS|FULL_TORSO|IGNORE_INV
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/suit/mino/vinesafe
	mech_flags = MECH_SCAN_ILLEGAL

/obj/item/clothing/suit/mino/vinesafe/vine_protected()
	return TRUE

/obj/item/clothing/suit/kimono
	name = "kimono"
	desc = "A traditional Japanese kimono."
	icon_state = "fancy_kimono"
	item_state = "fancy_kimono"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV

/obj/item/clothing/suit/kimono/happi
	name = "haori"
	desc = "A traditional Japanese jacket worn over a kimono. The symbol on their backs referred to the group with which they were associated."
	icon_state = "haori"
	item_state = "haori"

/obj/item/clothing/suit/jack
	name = "white kimono"
	desc = "A white and plain looking kimono."
	icon_state = "jack_robe"
	item_state = "jack_robe"

/obj/item/clothing/suit/kimono/ronin
	name = "black kimono"
	desc = "A black and plain looking kimono."
	icon_state = "ronin_kimono"
	item_state = "ronin_kimono"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/suit/kimono/sakura
	name = "sakura kimono"
	desc = "A pale-pink, nearly white, kimono with a red and gold obi. There is a embroidered design of cherry blossom flowers covering the kimono."
	icon_state = "sakura_kimono"
	item_state = "sakura_kimono"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/suit/clockwork_robes
	name = "clockwork robes"
	desc = "A set of armored robes worn by the followers of Ratvar."
	icon_state = "clockwork"
	item_state = "clockwork"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV
	allowed = list(/obj/item/weapon/storage/bible, /obj/item/weapon/nullrod/spear)
	hood = new /obj/item/clothing/head/clockwork_hood()


/obj/item/clothing/suit/inquisitor
	name = "inquisitor's coat"
	desc = "This inquisitor attire was made for new recruits, and has excellent straightforward defense. But not nearly enough to allow an ordinary man to stand any real chance against the the wicked."
	icon_state = "coat-church"
	item_state = "coat-church"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV
	allowed = list(/obj/item/weapon/nullrod, /obj/item/weapon/storage/bible)
	armor = list(melee = 40, bullet = 25, laser = 5, energy = 0, bomb = 0, bio = 0, rad = 0)
	wizard_garb = TRUE


/obj/item/clothing/suit/leather_apron
	name = "leather apron"
	desc = "A rough apron made out of leather. It is commonly used by blacksmiths to shield them from the forge's embers."
	icon_state = "apronleather"
	item_state = "apronleather"
	flags = FPRINT
	body_parts_covered = FULL_TORSO|IGNORE_INV
	allowed = list(/obj/item/weapon/hammer)
	armor = list(melee = 10, bullet = 5, laser = 20, energy = 0, bomb = 10, bio = 0, rad = 0)
	max_heat_protection_temperature = 800
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/suit/red_suit
	name = "red suit"
	desc = "A sleazy looking red suit."
	icon_state = "red_suit"
	item_state = "red_suit"
	body_parts_covered = 0
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/suit/poncho
	name = "poncho"
	desc = "A wooly poncho. Smells of beans."
	icon_state = "poncho"
	item_state = "poncho"
	clothing_flags = ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|IGNORE_INV

/obj/item/clothing/suit/banana_suit
	name = "banana suit"
	desc = "Peanut butter jelly time!"
	icon_state = "banana_suit"
	item_state = "banana_suit"
	body_parts_covered = FULL_TORSO|ARMS|LEGS|HIDEJUMPSUIT

//BOMBER VEST
//The whole "bump into people to detonate it, it's the only way" part is intentional, just run into them already
/obj/item/clothing/suit/bomber_vest
	name = "Bomber Vest"
	desc = "A normal vest rigged with impact-sensitive explosives. While active, bumping into anything or being touched will detonate it. For some reason, this will only work if worn."
	icon_state = "bombvest"
	item_state = "bombvest"
	body_parts_covered = FULL_TORSO|IGNORE_INV
	actions_types = list(/datum/action/item_action/toggle_bomber_vest)
	var/active = 0
	var/will_activate = 0 //When worn, will become active
	var/detonation_msg //This will be parsed onto the admin logs and is written at the time of the detonation trigger.

/obj/item/clothing/suit/bomber_vest/proc/activate_vest()
	var/mob/living/carbon/human/H = loc
	if(!H)
		return
	if(!ishuman(H))
		return
	if(!(H.wear_suit == src))
		return
	active = 1
	canremove = 0
	H.register_event(/event/touched, src, nameof(src::on_touched()))
	H.register_event(/event/attacked_by, src, nameof(src::on_attacked_by()))
	H.register_event(/event/hitby, src, nameof(src::on_hitby()))
	H.register_event(/event/unarmed_attack, src, nameof(src::on_unarmed_attack()))
	H.register_event(/event/to_bump, src, nameof(src::on_to_bump()))
	H.register_event(/event/bumped, src, nameof(src::on_bumped()))

/obj/item/clothing/suit/bomber_vest/proc/on_touched(mob/toucher, mob/touched)
	if(toucher == touched) //No bombing ourselves by checking ourselves
		return
	detonation_msg = "being touched by [toucher]"
	detonate()
/obj/item/clothing/suit/bomber_vest/proc/on_attacked_by(mob/attacker, mob/attacked, obj/item/item)
	detonation_msg = "being hit with \a [item] by [attacker]"
	detonate()
/obj/item/clothing/suit/bomber_vest/proc/on_hitby(mob/attacker, mob/attacked, obj/item/item)
	detonation_msg = "being hit with a thrown [item]"
	detonate()
/obj/item/clothing/suit/bomber_vest/proc/on_unarmed_attack(mob/attacker, mob/attacked)
	detonation_msg = "being punched by [attacker]"
	detonate()
/obj/item/clothing/suit/bomber_vest/proc/on_to_bump(atom/movable/bumper, atom/bumped)
	detonation_msg = "bumping into [bumped]"
	detonate()
/obj/item/clothing/suit/bomber_vest/proc/on_bumped(atom/movable/bumper, atom/bumped)
	detonation_msg = "being bumped into by [bumper]"
	detonate()

/obj/item/clothing/suit/bomber_vest/proc/deactivate_vest()
	active = 0
	var/mob/living/carbon/human/H = loc
	if(H)
		H.unregister_event(/event/touched, src, nameof(src::on_touched()))
		H.unregister_event(/event/attacked_by, src, nameof(src::on_attacked_by()))
		H.unregister_event(/event/hitby, src, nameof(src::on_hitby()))
		H.unregister_event(/event/unarmed_attack, src, nameof(src::on_unarmed_attack()))
		H.unregister_event(/event/to_bump, src, nameof(src::on_to_bump()))
		H.unregister_event(/event/bumped, src, nameof(src::on_bumped()))

/obj/item/clothing/suit/bomber_vest/examine(mob/user)
	..()
	if(active)
		to_chat(user, "<span class='danger'>It appears to be active. RUN!</span>")

/obj/item/clothing/suit/bomber_vest/suicide_act(var/mob/living/user)
	if (!active) //no explosion with no active vest, dummy
		return

	var/message_say = user.handle_suicide_bomb_cause(src)
	if(!message_say)
		return
	to_chat(viewers(user), "<span class='danger'>[user] activates the [src]! It looks like \he's going out with a bang!</span>")
	user.say(message_say)
	explosion(user, 3, 5, 7, whodunnit = user)
	message_admins("[user] has detonated \the [src] via suiciding with it!")
	qdel(src) //Just in case
	return SUICIDE_ACT_CUSTOM

/obj/item/clothing/suit/bomber_vest/proc/detonate()
	var/mob/living/carbon/human/H = loc
	if(!ishuman(H) || !active)
		return
	explosion(H, 3, 5, 7, whodunnit = H)
	message_admins("[H] has detonated \the [src] via [detonation_msg]!")
	qdel(src) //Just in case

/obj/item/clothing/suit/bomber_vest/equipped(mob/user, slot, hand_index)
	..()
	if(will_activate)
		to_chat(user, "<span class='warning'>\The [src] beeps.</span>")
		activate_vest()

/datum/action/item_action/toggle_bomber_vest
	name = "Toggle Bomber Vest"
	desc = "Activate the bomber vest, causing the slightest touch to detonate it and blow both you and everyone nearby into bits if active. Usable only when worn, and can't be taken off once active. You can prime it ahead of time if it is in your hand so that it automatically activates when worn.</span>"

/datum/action/item_action/toggle_bomber_vest/Trigger()
	if(IsAvailable() && owner && target)
		var/obj/item/clothing/suit/bomber_vest/B = target
		var/mob/living/carbon/human/H = owner
		if(B.active)
			to_chat(H, "<span class='warning'>The vest is already active!</span>")
			return
		else if(!H.is_wearing_item(B, slot_wear_suit)) //There are less complex ways of doing this but something broke
			if(B.will_activate == 0)
				to_chat(owner, "<span class='warning'>You prime the bomber vest to activate when worn.</span>")
				B.will_activate = 1
			else
				to_chat(owner, "<span class='notice'>You disarm the bomber vest for the time being.</span>")
				B.will_activate = 0
			return
		else if(!B.active)
			B.activate_vest()
			to_chat(owner, "<span class='warning'>You toggle on the vest. Bumping into anything will detonate it, as will being hit.</span>")

// -- American """"""Football""""""

/obj/item/clothing/suit/nt_football
	name = "NT Football suit"
	desc = "Contrary to popular belief, 13 wasn't chosen, it's simply the last number that hasn't been permanently inducted into the SNFL Hall of Fame."
	blood_overlay_type = "armor"
	body_parts_covered = FULL_TORSO
	icon_state = "ntfootball"
	flags = FPRINT

/obj/item/clothing/suit/syndie_football
	name = "Syndie Football suit"
	desc = "The S stands for Soccer."
	blood_overlay_type = "armor"
	body_parts_covered = FULL_TORSO
	icon_state = "syndiefootball"
	flags = FPRINT

/obj/item/clothing/suit/reticulatedvest
	name = "reticulated vest"
	desc = "A vest that makes use of reticulation to increase surface area and help disperse emitter particles. It was later discovered this also makes it effective against blobs organisms."
	icon_state = "reticulated2"
	item_state = "labgreen"
	blood_overlay_type = "armor"
	body_parts_covered = FULL_TORSO
	allowed = list(/obj/item/weapon/tank,
	/obj/item/weapon/gun/energy/laser/liberator)
	starting_materials = list(MAT_WOOD = 1*CC_PER_SHEET_MISC)
	w_type = RECYK_WOOD
	var/hits = 2

/obj/item/clothing/suit/reticulatedvest/update_icon()
	icon_state = "reticulated[hits]"

/obj/item/clothing/suit/scuba
	name = "scuba suit"
	desc = "A watertight swimming suit used to support a Self-Contained Underwater Breathing Apparatus."
	icon_state = "scuba"
	item_state = "scuba"
	origin_tech = Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=1"
	w_class = W_CLASS_LARGE//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = ARMS|LEGS|FULL_TORSO
	allowed = list(/obj/item/weapon/tank)
	slowdown = HARDSUIT_SLOWDOWN_LOW
	pressure_resistance = 2 * ONE_ATMOSPHERE
	species_fit = list(VOX_SHAPED)
	clothing_flags = ONESIZEFITSALL

/obj/item/clothing/suit/wftr
	name ="welding fuel tank refiller shirt"
	desc = "A shirt worn by those with a passion for refilling welding fuel tanks."
	icon_state = "wftr"
	item_state = "wftr"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED, GREY_SHAPED)
	body_parts_covered = FULL_TORSO
