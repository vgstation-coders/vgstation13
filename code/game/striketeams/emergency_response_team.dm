//ERT

var/list/response_team_members = list()

/datum/striketeam/ert
	striketeam_name = "Emergency Response Team"
	faction_name = "Nanotrasen"
	mission = "Ensure the station's return to working order, or organize its evacuation if judged necessary."
	team_size = 6
	min_size_for_leader = 0//set to 0 so there's always a designated team leader or to -1 so there is no leader.
	spawns_name = "ERT"
	can_customize = TRUE
	logo = "ert-logo"

/datum/striketeam/ert/failure()
	command_alert(/datum/command_alert/ert_fail)

/datum/striketeam/ert/extras()
	command_alert(/datum/command_alert/ert_success)

/datum/striketeam/ert/greet_commando(var/mob/living/carbon/human/H)
	if(H.key == leader_key)
		to_chat(H, "<span class='notice'>You are [H.real_name], the Commander of the Emergency Response Team, in the service of Nanotrasen.</span>")
	else
		to_chat(H, "<span class='notice'>You are [H.real_name], an Emergency Responder, in the service of Nanotrasen.</span>")
	to_chat(H, "<span class='notice'>Your mission is: <span class='danger'>[mission]</span></span>")

/datum/striketeam/ert/create_commando(obj/spawn_location, leader_selected = 0, key = "")
	var/mob/living/carbon/human/M = new(spawn_location.loc)
	response_team_members |= M

	var/mob/user = null
	for(var/mob/MO in player_list)
		if(MO.key == key)
			user = MO

	to_chat(user, "<span class='notice'>Congratulations, you've been selected to be part of an ERT. You can customize your character, but don't take too long, time is of the essence!</span>")

	var/commando_name = copytext(sanitize(input(user, "Pick a name","Name") as null|text), 1, MAX_MESSAGE_LEN)

	//todo: make it a panel, like in character creation
	var/new_facial = input(user, "Please select facial hair color.", "Character Generation") as color
	if(new_facial)
		M.r_facial = hex2num(copytext(new_facial, 2, 4))
		M.g_facial = hex2num(copytext(new_facial, 4, 6))
		M.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input(user, "Please select hair color.", "Character Generation") as color
	if(new_facial)
		M.r_hair = hex2num(copytext(new_hair, 2, 4))
		M.g_hair = hex2num(copytext(new_hair, 4, 6))
		M.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input(user, "Please select eye color.", "Character Generation") as color
	if(new_eyes)
		M.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		M.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		M.b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input(user, "Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text

	if (!new_tone)
		new_tone = 35
	M.s_tone = max(min(round(text2num(new_tone)), 220), 1)
	M.s_tone =  -M.s_tone + 35

	// hair
	var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
		hairs.Add(H.name) // add hair name to hairs
		qdel(H) // delete the hair after it's all done
		H = null

	//hair
	var/new_hstyle = input(user, "Select a hair style", "Grooming")  as null|anything in hair_styles_list
	if(new_hstyle)
		M.h_style = new_hstyle

	// facial hair
	var/new_fstyle = input(user, "Select a facial hair style", "Grooming")  as null|anything in facial_hair_styles_list
	if(new_fstyle)
		M.f_style = new_fstyle

	var/new_gender = alert(user, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			M.setGender(MALE)
		else
			M.setGender(FEMALE)

	//M.rebuild_appearance()
	M.update_hair()
	M.update_body()
	M.check_dna(M)

	M.real_name = commando_name
	M.name = commando_name
	M.age = !leader_selected ? rand(23,35) : rand(35,45)

	M.dna.ready_dna(M)//Creates DNA.

	//Creates mind stuff.
	M.mind = new
	M.mind.current = M
	M.mind.original = M
	M.mind.assigned_role = "MODE"
	M.mind.special_role = "Response Team"
	if(!(M.mind in ticker.minds))
		ticker.minds += M.mind//Adds them to regular mind list.
	M.forceMove(spawn_location.loc)
	M.equip_response_team(leader_selected)
	return M

/mob/living/carbon/human/proc/equip_response_team(leader_selected = 0)
	//Special radio setup
	equip_to_slot_or_del(new /obj/item/device/radio/headset/ert(src), slot_ears)

	//Adding Camera Network
	var/obj/machinery/camera/camera = new /obj/machinery/camera(src) //Gives all the commandos internals cameras.
	camera.network = "CREED"
	camera.c_tag = real_name

	//Basic Uniform
	equip_to_slot_or_del(new /obj/item/clothing/under/ert(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/device/flashlight(src), slot_l_store)
	equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(src), slot_belt)

	//Glasses
	equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(src), slot_glasses)

	//Shoes & gloves
	equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(src), slot_gloves)

	//Backpack
	equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(src), slot_back)
	equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival/ert(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(src), slot_in_backpack)

	if(leader_selected)
		equip_to_slot_or_del(new /obj/item/weapon/card/shuttle_pass/ERT(src), slot_in_backpack)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Emergency Responder[leader_selected ? " Leader" : ""]"
	W.registered_name = real_name
	W.name = "[real_name]'s ID Card ([W.assignment])"
	if(!leader_selected)
		W.access = get_centcom_access("Emergency Responder")
		W.icon_state = "ERT_empty"	//placeholder until revamp
	else
		W.access = get_centcom_access("Emergency Responders Leader")
		W.icon_state = "ERT_leader"
	equip_to_slot_or_del(W, slot_wear_id)
	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(src)
	L.imp_in = src
	L.implanted = 1
	var/datum/organ/external/affected = get_organ(LIMB_HEAD)
	affected.implants += L
	L.part = affected

	return 1
