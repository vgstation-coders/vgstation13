
/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	voice_name = "unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"
	can_butcher = 1
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human
	var/list/hud_list[9]
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/embedded_flag	  //To check if we've need to roll for damage on movement while an item is imbedded in us.

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/manifested
	real_name = "Manifested Ghost"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/manifested/New(var/new_loc, delay_ready_dna = 0)
	underwear = 0
	..(new_loc, "Manifested")

/mob/living/carbon/human/skrell/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Skrell Male Tentacles"
	..(new_loc, "Skrell")

/mob/living/carbon/human/tajaran/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Tajaran Ears"
	..(new_loc, "Tajaran")

/mob/living/carbon/human/unathi/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Unathi Horns"
	..(new_loc, "Unathi")

/mob/living/carbon/human/vox/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Short Vox Quills"
	..(new_loc, "Vox")

/mob/living/carbon/human/diona/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Diona")

/mob/living/carbon/human/skellington/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Skellington", delay_ready_dna)

/mob/living/carbon/human/skelevox/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Skeletal Vox")

/mob/living/carbon/human/plasma/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Plasmaman")

/mob/living/carbon/human/muton/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Muton")

/mob/living/carbon/human/grey/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Grey")

/mob/living/carbon/human/golem/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Golem")

/mob/living/carbon/human/grue/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Grue")

/mob/living/carbon/human/slime/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Slime")

/mob/living/carbon/human/NPC/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc)
	initialize_basic_NPC_components()

/mob/living/carbon/human/frankenstein/New(var/new_loc, delay_ready_dna = 0) //Just fuck my shit up: the mob
	f_style = pick(facial_hair_styles_list)
	h_style = pick(hair_styles_list)

	var/list/valid_species = (all_species - list("Krampus", "Horror"))

	var/datum/species/new_species = all_species[pick(valid_species)]
	..(new_loc, new_species.name)
	gender = pick(MALE, FEMALE, NEUTER, PLURAL)
	meat_type = pick(typesof(/obj/item/weapon/reagent_containers/food/snacks/meat))

	for(var/datum/organ/external/E in organs)
		E.species = all_species[pick(valid_species)]

	update_body()

/mob/living/carbon/human/generate_static_overlay()
	if(!istype(static_overlays,/list))
		static_overlays = list()
	static_overlays.Add(list("static", "blank", "letter"))
	var/image/static_overlay = image(icon('icons/effects/effects.dmi', "static"), loc = src)
	static_overlay.override = 1
	static_overlays["static"] = static_overlay

	static_overlay = image(icon('icons/effects/effects.dmi', "blank_human"), loc = src)
	static_overlay.override = 1
	static_overlays["blank"] = static_overlay

	static_overlay = getLetterImage(src, "H", 1)
	static_overlay.override = 1
	static_overlays["letter"] = static_overlay

/mob/living/carbon/human/New(var/new_loc, var/new_species_name = null, var/delay_ready_dna=0)
	if(!hair_styles_list.len)
		buildHairLists()
	if(!all_species.len)
		buildSpeciesLists()

	if(new_species_name)
		s_tone = random_skin_tone(new_species_name)
	multicolor_skin_r = rand(0,255)	//Only used when the human has a species datum with the MULTICOLOR anatomical flag
	multicolor_skin_g = rand(0,255)
	multicolor_skin_b = rand(0,255)

	if(!src.species)
		if(new_species_name)
			src.set_species(new_species_name)
		else
			src.set_species()

	movement_speed_modifier = species.move_speed_multiplier

	default_language = get_default_language()

	create_reagents(1000)

	if(!dna)
		dna = new /datum/dna(null)
		dna.species=species.name
		dna.b_type = random_blood_type()

	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealthy")
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudunknown")
	hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD_OOC]  = image('icons/mob/hud.dmi', src, "hudhealthy")

	obj_overlays[FIRE_LAYER]		= getFromPool(/obj/abstract/Overlays/fire_layer)
	obj_overlays[MUTANTRACE_LAYER]	= getFromPool(/obj/abstract/Overlays/mutantrace_layer)
	obj_overlays[MUTATIONS_LAYER]	= getFromPool(/obj/abstract/Overlays/mutations_layer)
	obj_overlays[DAMAGE_LAYER]		= getFromPool(/obj/abstract/Overlays/damage_layer)
	obj_overlays[UNIFORM_LAYER]		= getFromPool(/obj/abstract/Overlays/uniform_layer)
	obj_overlays[ID_LAYER]			= getFromPool(/obj/abstract/Overlays/id_layer)
	obj_overlays[SHOES_LAYER]		= getFromPool(/obj/abstract/Overlays/shoes_layer)
	obj_overlays[GLOVES_LAYER]		= getFromPool(/obj/abstract/Overlays/gloves_layer)
	obj_overlays[EARS_LAYER]		= getFromPool(/obj/abstract/Overlays/ears_layer)
	obj_overlays[SUIT_LAYER]		= getFromPool(/obj/abstract/Overlays/suit_layer)
	obj_overlays[GLASSES_LAYER]		= getFromPool(/obj/abstract/Overlays/glasses_layer)
	obj_overlays[BELT_LAYER]		= getFromPool(/obj/abstract/Overlays/belt_layer)
	obj_overlays[SUIT_STORE_LAYER]	= getFromPool(/obj/abstract/Overlays/suit_store_layer)
	obj_overlays[BACK_LAYER]		= getFromPool(/obj/abstract/Overlays/back_layer)
	obj_overlays[HAIR_LAYER]		= getFromPool(/obj/abstract/Overlays/hair_layer)
	obj_overlays[GLASSES_OVER_HAIR_LAYER] = getFromPool(/obj/abstract/Overlays/glasses_over_hair_layer)
	obj_overlays[FACEMASK_LAYER]	= getFromPool(/obj/abstract/Overlays/facemask_layer)
	obj_overlays[HEAD_LAYER]		= getFromPool(/obj/abstract/Overlays/head_layer)
	obj_overlays[HANDCUFF_LAYER]	= getFromPool(/obj/abstract/Overlays/handcuff_layer)
	obj_overlays[LEGCUFF_LAYER]		= getFromPool(/obj/abstract/Overlays/legcuff_layer)
	//obj_overlays[HAND_LAYER]		= getFromPool(/obj/abstract/Overlays/hand_layer) //moved to human/update_inv_hand()
	obj_overlays[TAIL_LAYER]		= getFromPool(/obj/abstract/Overlays/tail_layer)
	obj_overlays[TARGETED_LAYER]	= getFromPool(/obj/abstract/Overlays/targeted_layer)

	..()

	if(dna)
		dna.real_name = real_name
		dna.flavor_text = flavor_text

	prev_gender = gender // Debug for plural genders
	make_blood()
	init_butchering_list() // While animals only generate list of their teeth/skins on death, humans generate it when they're born.

	// Set up DNA.
	if(!delay_ready_dna)
		dna.ready_dna(src)

	if(hardcore_mode_on)
		spawn(2 SECONDS)
			//Hardcore mode stuff
			//Warn the player that not eating will lead to his death
			if(eligible_for_hardcore_mode(src))
				to_chat(src, "<h5><span class='notice'>Hardcore mode is enabled!</span></h5>")
				to_chat(src, "<b>You must eat to survive. Starvation for extended periods of time will kill you!</b>")
				to_chat(src, "<b>Keep an eye out on the hunger indicator on the right of your screen; it will start flashing red and black when you're close to starvation.</b>")

	update_colour(0,1)

	spawn()
		update_mutantrace()

/mob/living/carbon/human/player_panel_controls()
	var/html=""

	// TODO: Loop through contents and call parasite_panel or something.
	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(B)
		html +="<h2>Borer:</h2> [B] ("
		if(B.controlling)
			html += "<a style='color:red;font-weight:bold;' href='?src=\ref[B]&act=release'>Controlling</a>"
		else if(B.host_brain.ckey)
			html += "<a style='color:red;font-weight:bold;' href='?src=\ref[B]&act=release'>!HOST BRAIN BUGGED!</a>"
		else
			html += "Not Controlling"
		html += " | <a href='?src=\ref[B]&act=detach'>Detach</a>"
		html += " | <a href='?_src_=holder;adminmoreinfo=\ref[B]'>?</a> | <a href='?_src_=vars;mob_player_panel=\ref[B]'>PP</a>"
		html += ")"

	return html

/mob/living/carbon/human/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")
		stat(null, "Move Mode: [m_intent]")
		if(ticker && ticker.mode && ticker.mode.name == "AI malfunction")
			if(ticker.mode:malf_mode_declared)
				stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
		if(emergency_shuttle)
			if(emergency_shuttle.online && emergency_shuttle.location < 2)
				var/timeleft = emergency_shuttle.timeleft()
				if (timeleft)
					stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

		if (internal)
			if (!internal.air_contents)
				qdel(internal)
				internal = null
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)
		if(mind)
			if(mind.changeling)
				stat("Chemical Storage", mind.changeling.chem_charges)
				stat("Genetic Damage Time", mind.changeling.geneticdamage)

		if(istype(loc, /obj/spacepod)) // Spacdpods!
			var/obj/spacepod/S = loc
			stat("Spacepod Charge", "[istype(S.battery) ? "[S.battery.charge] / [S.battery.maxcharge]" : "No cell detected"]")
			stat("Spacepod Integrity", "[!S.health ? "0" : "[(S.health / initial(S.health)) * 100]"]%")

/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M as mob)
	M.unarmed_attack_mob(src)

/mob/living/carbon/human/proc/is_loyalty_implanted(mob/living/carbon/human/M)
	for(var/L in M.contents)
		if(istype(L, /obj/item/weapon/implant/loyalty))
			for(var/datum/organ/external/O in M.organs)
				if(L in O.implants)
					return 1
	return 0

/mob/living/carbon/human/attack_slime(mob/living/carbon/slime/M as mob)
	M.unarmed_attack_mob(src)

/mob/living/carbon/human/restrained()
	if (timestopped)
		return 1 //under effects of time magick
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0



/mob/living/carbon/human/var/co2overloadtime = null
/mob/living/carbon/human/var/temperature_resistance = T0C+75 //but why is this here

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/Crossed(var/atom/movable/AM)
	var/blood = 0
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOverCreature(src,species.blood_color)
		blood = 1
	var/obj/structure/bed/chair/vehicle/wheelchair/motorized/syndicate/WC = AM
	if(istype(WC))
		if(!WC.attack_cooldown)
			WC.crush(src,species.blood_color)
			blood = 1
	var/obj/machinery/bot/cleanbot/roomba/R = AM
	if(istype(R))
		if(R.armed)
			R.annoy(src)
	if(blood)
		blood_splatter(loc,src,1)

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	var/obj/item/weapon/storage/wallet/wallet = wear_id
	if (istype(pda))
		if (pda.id && istype(pda.id, /obj/item/weapon/card/id))
			. = pda.id.assignment
		else
			. = pda.ownjob
	else if (istype(wallet))
		var/obj/item/weapon/card/id/wallet_id = wallet.GetID()
		if(istype(wallet_id))
			. = wallet_id.assignment
	else if (istype(id))
		. = id.assignment
	else
		return if_no_id
	if (!.)
		. = if_no_job
	return
//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(var/if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id)
			. = pda.id.registered_name
		else
			. = pda.owner
	else if (istype(id))
		. = id.registered_name
	else
		return if_no_id
	return
//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/proc/get_visible_name()
	if( wear_mask && (is_slot_hidden(wear_mask.body_parts_covered,HIDEFACE)))	//Wearing a mask which hides our face, use id-name if possible
		return get_id_name("Unknown")
	if( head && (is_slot_hidden(head.body_parts_covered,HIDEFACE)))
		return get_id_name("Unknown")	//Likewise for hats
	if(mind && mind.vampire && (VAMP_SHADOW in mind.vampire.powers) && mind.vampire.ismenacing)
		return get_id_name("Unknown")
	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if(id_name && (id_name != face_name))
		return "[face_name] (as [id_name])"
	return face_name
//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name()
	var/datum/organ/external/head/head_organ = get_organ(LIMB_HEAD)
	if((wear_mask && (is_slot_hidden(wear_mask.body_parts_covered,HIDEFACE))) || ( head && (is_slot_hidden(head.body_parts_covered,HIDEFACE))) || !head_organ || head_organ.disfigured || (head_organ.status & ORGAN_DESTROYED) || !real_name || (M_HUSK in mutations) )	//Wearing a mask which hides our face, use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(var/if_no_id = "Unknown")
	if(wear_id)
		. = wear_id.get_owner_name_from_ID()
	if(!.)
		return if_no_id

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(var/shock_damage, var/obj/source, var/base_siemens_coeff = 1.0, var/def_zone = null)
	if(status_flags & GODMODE || M_NO_SHOCK in src.mutations)
		return 0	//godmode

	if (!def_zone)
		def_zone = pick(LIMB_LEFT_HAND, LIMB_RIGHT_HAND)

	var/datum/organ/external/affected_organ = get_organ(check_zone(def_zone))
	var/siemens_coeff = base_siemens_coeff * get_siemens_coefficient_organ(affected_organ)

	return ..(shock_damage, source, siemens_coeff, def_zone)

/mob/living/carbon/human/hear_radio_only()
	if(!ears)
		return 0
	return is_on_ears(/obj/item/device/radio/headset/headset_earmuffs)

/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	var/pickpocket = usr.isGoodPickpocket()
	var/list/obscured = check_obscured_slots()
	var/dat

	for(var/i = 1 to held_items.len) //Hands
		var/obj/item/I = held_items[i]
		dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"

	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[slot_back]'>[makeStrippingButton(back)]</A>"
	dat += "<BR>"
	dat += "<BR><B>Head:</B> <A href='?src=\ref[src];item=[slot_head]'>[makeStrippingButton(head)]</A>"
	if(slot_wear_mask in obscured)
		dat += "<BR><font color=grey><B>Mask:</B> Obscured by [head]</font>"
	else
		dat += "<BR><B>Mask:</B> <A href='?src=\ref[src];item=[slot_wear_mask]'>[makeStrippingButton(wear_mask)]</A>"
	if(has_breathing_mask())
		dat += "<BR>[HTMLTAB]&#8627;<B>Internals:</B> [src.internal ? "On" : "Off"]  <A href='?src=\ref[src];internals=1'>(Toggle)</A>"
	if(slot_glasses in obscured)
		dat += "<BR><font color=grey><B>Eyes:</B> Obscured by [head]</font>"
	else
		dat += "<BR><B>Eyes:</B> <A href='?src=\ref[src];item=[slot_glasses]'>[makeStrippingButton(glasses)]</A>"
	if(slot_ears in obscured)
		dat += "<BR><font color=grey><B>Ears:</B> Obscured by [head]</font>"
	else
		dat += "<BR><B>Ears:</B> <A href='?src=\ref[src];item=[slot_ears]'>[makeStrippingButton(ears)]</A>"
	dat += "<BR>"
	dat += "<BR><B>Exosuit:</B> <A href='?src=\ref[src];item=[slot_wear_suit]'>[makeStrippingButton(wear_suit)]</A>"
	if(wear_suit)
		dat += "<BR>[HTMLTAB]&#8627;<B>Suit Storage:</B> <A href='?src=\ref[src];item=[slot_s_store]'>[makeStrippingButton(s_store)]</A>"
	if(slot_shoes in obscured)
		dat += "<BR><font color=grey><B>Shoes:</B> Obscured by [wear_suit]</font>"
	else
		dat += "<BR><B>Shoes:</B> <A href='?src=\ref[src];item=[slot_shoes]'>[makeStrippingButton(shoes)]</A>"
	if(slot_gloves in obscured)
		dat += "<BR><font color=grey><B>Gloves:</B> Obscured by [wear_suit]</font>"
	else
		dat += "<BR><B>Gloves:</B> <A href='?src=\ref[src];item=[slot_gloves]'>[makeStrippingButton(gloves)]</A>"
	if(slot_w_uniform in obscured)
		dat += "<BR><font color=grey><B>Uniform:</B> Obscured by [wear_suit]</font>"
	else
		dat += "<BR><B>Uniform:</B> <A href='?src=\ref[src];item=[slot_w_uniform]'>[makeStrippingButton(w_uniform)]</A>"
		if(w_uniform)
			dat += "<BR>[HTMLTAB]&#8627;<B>Suit Sensors:</B> <A href='?src=\ref[src];sensors=1'>Set</A>"
	if(w_uniform)
		dat += "<BR>[HTMLTAB]&#8627;<B>Belt:</B> <A href='?src=\ref[src];item=[slot_belt]'>[makeStrippingButton(belt)]</A>"
		if(pickpocket)
			dat += "<BR>[HTMLTAB]&#8627;<B>Pockets:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? l_store : "<font color=grey>Left (Empty)</font>"]</A>"
			dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? r_store : "<font color=grey>Right (Empty)</font>"]</A>"
		else
			dat += "<BR>[HTMLTAB]&#8627;<B>Pockets:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
			dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A>"
		dat += "<BR>[HTMLTAB]&#8627;<B>ID:</B> <A href='?src=\ref[src];id=1'>[makeStrippingButton(wear_id)]</A>"
	dat += "<BR>"
	if(handcuffed)
		dat += "<BR><B>Handcuffed:</B> <A href='?src=\ref[src];item=[slot_handcuffed]'>Remove</A>"
	if(legcuffed)
		dat += "<BR><B>Legcuffed:</B> <A href='?src=\ref[src];item=[slot_legcuffed]'>Remove</A>"
	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}
	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/carbon/human/Topic(href, href_list)
	..() //Slot stripping, hand stripping, and internals setting in /mob/living/carbon/Topic()
	if(href_list["id"])
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		handle_strip_id(usr)

	else if(href_list["pockets"]) //href_list "pockets" would be "left" or "right"
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		handle_strip_pocket(usr, href_list["pockets"])

	else if(href_list["sensors"])
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		toggle_sensors(usr)

	else if (href_list["refresh"])
		if((machine)&&(in_range(src, usr)))
			show_inv(machine)

	else if (href_list["criminal"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/modified

			if(wear_id)
				var/obj/item/weapon/card/id/I = wear_id.GetID()
				if(I)
					perpname = I.registered_name
				else
					perpname = name
			else
				perpname = name

			if(perpname)
				for (var/datum/data/record/E in data_core.general)
					if (E.fields["name"] == perpname)
						for (var/datum/data/record/R in data_core.security)
							if (R.fields["id"] == E.fields["id"])

								var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Parolled", "Released", "Cancel")

								if(hasHUD(usr, "security"))
									if(setcriminal != "Cancel")
										R.fields["criminal"] = setcriminal
										modified = 1

										spawn()
											hud_updateflag |= 1 << WANTED_HUD
											if(istype(usr,/mob/living/carbon/human))
												var/mob/living/carbon/human/U = usr
												U.handle_regular_hud_updates()
											if(istype(usr,/mob/living/silicon/robot))
												var/mob/living/silicon/robot/U = usr
												U.handle_regular_hud_updates()

			if(!modified)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
	else if (href_list["secrecord"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								var/counter = 1
								to_chat(usr, "<b>Comments:</b>")
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, text("[]", R.fields[text("com_[]", counter)]))
									counter++
								if (counter == 1)
									to_chat(usr, "No comments found.")
								read = 1
								to_chat(usr, "<a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>")
			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
	else if (href_list["secrecordadd"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								var/t1 = copytext(sanitize(input("Add Comment:", "Sec. records", null, null)  as message),1,MAX_MESSAGE_LEN)
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"security")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(istype(usr,/mob/living/carbon/human))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
	else if (href_list["medical"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/modified = 0
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.general)
						if (R.fields["id"] == E.fields["id"])
							var/setmedical = input(usr, "Specify a new medical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled", "Cancel")
							if(hasHUD(usr,"medical"))
								if(setmedical != "Cancel")
									R.fields["p_stat"] = setmedical
									modified = 1
									if(PDA_Manifest.len)
										PDA_Manifest.len = 0
									spawn()
										if(istype(usr,/mob/living/carbon/human))
											var/mob/living/carbon/human/U = usr
											U.handle_regular_hud_updates()
										if(istype(usr,/mob/living/silicon/robot))
											var/mob/living/silicon/robot/U = usr
											U.handle_regular_hud_updates()
			if(!modified)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
	else if (href_list["medrecord"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Blood Type:</b> [R.fields["b_type"]]")
								to_chat(usr, "<b>DNA:</b> [R.fields["b_dna"]]")
								to_chat(usr, "<b>Minor Disabilities:</b> [R.fields["mi_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_dis_d"]]")
								to_chat(usr, "<b>Major Disabilities:</b> [R.fields["ma_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_dis_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='?src=\ref[src];medrecordComment=`'>\[View Comment Log\]</a>")
								read = 1
			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
	else if (href_list["medrecordComment"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, text("[]", R.fields[text("com_[]", counter)]))
									counter++
								if (counter == 1)
									to_chat(usr, "No comment found")
								to_chat(usr, "<a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>")
			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
	else if (href_list["medrecordadd"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								var/t1 = copytext(sanitize(input("Add Comment:", "Med. records", null, null)  as message),1,MAX_MESSAGE_LEN)
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"medical")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(istype(usr,/mob/living/carbon/human))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
		//else if(!. && error_msg && user)
//			to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [above_neck(target_zone) ? "on their head" : "on their body"].</span>")
	else if (href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		usr.examination(I)
	else if (href_list["listitems"])
		var/mob/M = usr
		if(istype(M, /mob/dead) || (!M.isUnconscious() && !M.eye_blind && !M.blinded))
			var/obj/item/I = locate(href_list["listitems"])
			var/obj/item/weapon/storage/internal/S = I
			if(istype(S))
				if(istype(S.master_item, /obj/item/clothing/suit/storage/trader))
					for(var/J in I.contents)
						to_chat(usr, "<span class='info'>[bicon(J)] \A [J].</span>")
	/*else if (href_list["lookmob"])
		var/mob/M = locate(href_list["lookmob"])
		usr.examination(M)*/

/**
 * Returns a number between -2 to 2.
 * TODO: What's the default return value?
 */
/mob/living/carbon/human/eyecheck()
	. = 0
	var/obj/item/clothing/head/headwear = src.head
	var/obj/item/clothing/glasses/eyewear = src.glasses
	var/datum/organ/internal/eyes/E = src.internal_organs_by_name["eyes"]

	if (istype(headwear))
		. += headwear.eyeprot

	if (istype(eyewear))
		. += eyewear.eyeprot

	if(E)
		. += E.eyeprot

	return Clamp(., -2, 2)


/mob/living/carbon/human/IsAdvancedToolUser()
	return 1//Humans can use guns and such

/mob/living/carbon/human/isGoodPickpocket()
	var/obj/item/clothing/gloves/G = gloves
	if(istype(G))
		return G.pickpocket

/mob/living/carbon/human/abiotic(var/full_body = 0)
	for(var/obj/item/I in held_items)
		if(I.abstract)
			continue

		return 1

	if(full_body)
		for(var/obj/item/I in get_all_slots())
			return 1

	return 0


/mob/living/carbon/human/proc/check_dna()
	dna.check_integrity(src)
	return

/mob/living/carbon/human/get_species()

	if(!species)
		set_species()

	if(dna && dna.mutantrace == "golem")
		return "Animated Construct"

	return species.name

/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		visible_message("<span class='warning'>[src] begins playing \his ribcage like a xylophone. It's quite spooky.</span>","<span class='notice'>You begin to play a spooky refrain on your ribcage.</span>","<span class='notice'>You hear a spooky xylophone melody.</span>")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/carbon/human/proc/vomit(hairball = 0, instant = 0)
	if(!lastpuke)
		lastpuke = 1
		to_chat(src, "<spawn class='warning'>You feel nauseous...</span>")

		spawn((instant ? 0 : 150))	//15 seconds until second warning
			to_chat(src, "<spawn class='danger'>You feel like you are about to throw up!</span>")

			sleep((instant ? 0 : 100))	//And you have 10 more seconds to move it to the bathrooms

			Stun(5)

			var/turf/location = loc
			var/spawn_vomit_on_floor = 0

			if(hairball)
				src.visible_message("<span class='warning'>[src] hacks up a hairball!</span>","<span class='danger'>You hack up a hairball!</span>")

			else
				var/skip_message = 0

				var/obj/structure/toilet/T = locate(/obj/structure/toilet) in location //Look for a toilet
				if(T && T.open)
					src.visible_message("<span class='warning'>[src] throws up into \the [T]!</span>", "<span class='danger'>You throw up into \the [T]!</span>")
					skip_message = 1
				else //Look for a bucket

					for(var/obj/item/weapon/reagent_containers/glass/G in (location.contents + src.get_active_hand() + src.get_inactive_hand()))
						if(!G.reagents)
							continue
						if(!G.is_open_container())
							continue

						src.visible_message("<span class='warning'>[src] throws up into \the [G]!</span>", "<span class='danger'>You throw up into \the [G]!</span>")

						if(G.reagents.total_volume <= G.reagents.maximum_volume-7) //Container can fit 7 more units of chemicals - vomit into it
							G.reagents.add_reagent(VOMIT, rand(3,10))
							if(src.reagents)
								reagents.trans_to(G, 1 + reagents.total_volume * 0.1)
						else //Container is nearly full - fill it to the brim with vomit and spawn some more on the floor
							G.reagents.add_reagent(VOMIT, 10)
							spawn_vomit_on_floor = 1
							to_chat(src, "<span class='warning'>\The [G] overflows!</span>")

						skip_message = 1

						break

				if(!skip_message)
					src.visible_message("<span class='warning'>[src] throws up!</span>","<span class='danger'>You throw up!</span>")
					spawn_vomit_on_floor = 1

			playsound(get_turf(loc), 'sound/effects/splat.ogg', 50, 1)

			if(spawn_vomit_on_floor)
				if(istype(location, /turf/simulated))
					location.add_vomit_floor(src, 1, (hairball ? 0 : 1), 1)

			if(!hairball)
				nutrition = max(nutrition-40,0)
				adjustToxLoss(-3)

			sleep((instant ? 0 : 350))	//Wait 35 seconds before next volley

			lastpuke = 0

/mob/living/carbon/human/proc/morph()
	set name = "Morph"
	set category = "Mutant Abilities"

	if(stat!=CONSCIOUS)
		reset_view(0)
		remoteview_target = null
		return

	if(!(M_MORPH in mutations))
		src.verbs -= /mob/living/carbon/human/proc/morph
		return

	var/new_facial = input("Please select facial hair color.", "Character Generation",rgb(r_facial,g_facial,b_facial)) as color
	if(new_facial)
		r_facial = hex2num(copytext(new_facial, 2, 4))
		g_facial = hex2num(copytext(new_facial, 4, 6))
		b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation",rgb(r_hair,g_hair,b_hair)) as color
	if(new_facial)
		r_hair = hex2num(copytext(new_hair, 2, 4))
		g_hair = hex2num(copytext(new_hair, 4, 6))
		b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation",rgb(r_eyes,g_eyes,b_eyes)) as color
	if(new_eyes)
		r_eyes = hex2num(copytext(new_eyes, 2, 4))
		g_eyes = hex2num(copytext(new_eyes, 4, 6))
		b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation", "[35-s_tone]")  as text

	if (!new_tone)
		new_tone = 35
	s_tone = max(min(round(text2num(new_tone)), 220), 1)
	s_tone =  -s_tone + 35

	// hair
	var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
		hairs.Add(H.name) // add hair name to hairs
		qdel(H) // delete the hair after it's all done
		H = null

	var/new_style = input("Please select hair style", "Character Generation",h_style)  as null|anything in hairs

	// if new style selected (not cancel)
	if (new_style)
		h_style = new_style

	// facial hair
	var/list/all_fhairs = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	var/list/fhairs = list()

	for(var/x in all_fhairs)
		var/datum/sprite_accessory/facial_hair/H = new x
		fhairs.Add(H.name)
		qdel(H)
		H = null

	new_style = input("Please select facial style", "Character Generation",f_style)  as null|anything in fhairs

	if(new_style)
		f_style = new_style

	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			setGender(MALE)
		else
			setGender(FEMALE)
	regenerate_icons()
	check_dna()

	visible_message("<span class='notice'>\The [src] morphs and changes [get_visible_gender() == MALE ? "his" : get_visible_gender() == FEMALE ? "her" : "their"] appearance!</span>", "<span class='notice'>You change your appearance!</span>", "<span class='warning'>Oh, god!  What the hell was that?  It sounded like flesh getting squished and bone ground into a different shape!</span>")

/mob/living/carbon/human/can_wield()
	return 1

/mob/living/carbon/human/proc/get_visible_gender()
	if(wear_suit && is_slot_hidden(wear_suit.body_parts_covered,HIDEJUMPSUIT) && ((is_slot_hidden(head.body_parts_covered,HIDEMASK)) || is_slot_hidden(wear_mask.body_parts_covered,HIDEMASK)))
		return NEUTER
	return gender

/mob/living/carbon/human/proc/increase_germ_level(n)
	if(gloves)
		gloves.germ_level += n
	else
		germ_level += n

/mob/living/carbon/human/revive()
	for (var/datum/organ/external/O in organs)
		O.status &= ~ORGAN_BROKEN
		O.status &= ~ORGAN_BLEEDING
		O.status &= ~ORGAN_SPLINTED
		O.status &= ~ORGAN_CUT_AWAY
		O.status &= ~ORGAN_ATTACHABLE
		if (!O.amputated)
			O.status &= ~ORGAN_DESTROYED
			O.destspawn = 0
		O.wounds.len = 0
		O.heal_damage(1000,1000,1,1)

	var/datum/organ/external/head/h = organs_by_name[LIMB_HEAD]
	h.disfigured = 0

	if(species && !(species.anatomy_flags & NO_BLOOD))
		vessel.add_reagent(BLOOD,560-vessel.total_volume)
		fixblood()

	var/datum/organ/internal/brain/BBrain = internal_organs_by_name["brain"]
	if(!BBrain)
		var/obj/item/organ/external/head/B = decapitated
		if(B)
			var/datum/organ/internal/brain/copied
			if(B.organ_data)
				var/datum/organ/internal/I = B.organ_data
				copied = I.Copy()
			else
				copied = new
			copied.owner = src
			internal_organs_by_name["brain"] = copied
			internal_organs += copied

			var/datum/organ/external/affected = get_organ(LIMB_HEAD)
			affected.internal_organs += copied
			affected.status = 0
			affected.amputated = 0
			affected.destspawn = 0
			update_body()
			updatehealth()
			UpdateDamageIcon()

			if(B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)

			if(B.borer)
				B.borer.perform_infestation(src)
				B.borer=null

			decapitated = null

			qdel(B)

	for(var/datum/organ/internal/I in internal_organs)
		I.damage = 0

	for (var/datum/disease/virus in viruses)
		virus.cure()
	for (var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		V.cure(src)

	..()

/mob/living/carbon/human/proc/is_lung_ruptured()
	var/datum/organ/internal/lungs/L = internal_organs_by_name["lungs"]
	return L && L.is_bruised()

/mob/living/carbon/human/proc/rupture_lung()
	var/datum/organ/internal/lungs/L = internal_organs_by_name["lungs"]

	if(L && !L.is_bruised())
		src.custom_pain("You feel a stabbing pain in your chest!", 1)
		L.damage = L.min_bruised_damage

/*
/mob/living/carbon/human/verb/simulate()
	set name = "sim"
	//set background = 1
	var/damage = input("Wound damage","Wound damage") as num
	var/germs = 0
	var/tdamage = 0
	var/ticks = 0
	while (germs < 2501 && ticks < 100000 && round(damage/10)*20)
		diary << "VIRUS TESTING: [ticks] : germs [germs] tdamage [tdamage] prob [round(damage/10)*20]"
		ticks++
		if (prob(round(damage/10)*20))
			germs++
		if (germs == 100)
			to_chat(world, "Reached stage 1 in [ticks] ticks")
		if (germs > 100)
			if (prob(10))
				damage++
				germs++
		if (germs == 1000)
			to_chat(world, "Reached stage 2 in [ticks] ticks")
		if (germs > 1000)
			damage++
			germs++
		if (germs == 2500)
			to_chat(world, "Reached stage 3 in [ticks] ticks")
	to_chat(world, "Mob took [tdamage] tox damage")
*/
//returns 1 if made bloody, returns 0 otherwise

/mob/living/carbon/human/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0
	if(!M)
		return
	//if this blood isn't already in the list, add it
	if(blood_DNA[M.dna.unique_enzymes])
		return 0 //already bloodied with this blood. Cannot add more.
	blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	hand_blood_color = blood_color
	src.update_inv_gloves()	//handles bloody hands overlays and updating
	verbs += /mob/living/carbon/human/proc/bloody_doodle
	return 1 //we applied blood to the item

/mob/living/carbon/human/clean_blood(var/clean_feet)
	.=..()
	if(clean_feet && !shoes && istype(feet_blood_DNA, /list) && feet_blood_DNA.len)
		feet_blood_color = null
		feet_blood_DNA.len = 0
		update_inv_shoes(1)
		return 1

/mob/living/carbon/human/yank_out_object()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!isliving(usr) || (usr.client && usr.client.move_delayer.blocked()))
		return
	usr.delayNextMove(20)

	if(usr.isUnconscious())
		to_chat(usr, "You are unconcious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/list/valid_objects = list()
	var/datum/organ/external/affected = null
	var/mob/living/carbon/human/S = src
	var/mob/living/carbon/human/U = usr
	var/self = null

	if(S == U)
		self = 1 // Removing object from yourself.

	valid_objects = get_visible_implants(1)

	if(!valid_objects.len)
		if(self)
			to_chat(src, "You have nothing stuck in your wounds that is large enough to remove without surgery.")
		else
			to_chat(U, "[src] has nothing stuck in their wounds that is large enough to remove without surgery.")
		return

	var/obj/item/weapon/selection = input("What do you want to yank out?", "Embedded objects") in valid_objects

	for(var/datum/organ/external/organ in organs) //Grab the organ holding the implant.
		for(var/obj/item/weapon/O in organ.implants)
			if(O == selection)
				affected = organ
	if(self)
		to_chat(src, "<span class='warning'>You attempt to get a good grip on the [selection] in your [affected.display_name] with bloody fingers.</span>")
	else
		to_chat(U, "<span class='warning'>You attempt to get a good grip on the [selection] in [S]'s [affected.display_name] with bloody fingers.</span>")

	if(istype(U,/mob/living/carbon/human/))
		U.bloody_hands(S)

	if(!do_after(U, src, 80))
		return

	if(!selection || !affected || !S || !U)
		return

	if(self)
		visible_message("<span class='danger'><b>[src] rips [selection] out of their [affected.display_name] in a welter of blood.</b></span>","<span class='warning'>You rip [selection] out of your [affected] in a welter of blood.</span>")
	else
		visible_message("<span class='danger'><b>[usr] rips [selection] out of [src]'s [affected.display_name] in a welter of blood.</b></span>","<span class='warning'>[usr] rips [selection] out of your [affected] in a welter of blood.</span>")

	selection.forceMove(get_turf(src))
	affected.implants -= selection
	pain_shock_stage+=10

	for(var/obj/item/weapon/O in pinned)
		if(O == selection)
			pinned -= O
		if(!pinned.len)
			anchored = 0

	if(prob(10)) //I'M SO ANEMIC I COULD JUST -DIE-.
		var/datum/wound/internal_bleeding/I = new (15)
		affected.wounds += I
		custom_pain("Something tears wetly in your [affected] as [selection] is pulled free!", 1)
	return 1

/mob/living/carbon/human/proc/get_visible_implants(var/class = 0)


	var/list/visible_implants = list()
	for(var/datum/organ/external/organ in src.organs)
		for(var/obj/item/weapon/O in organ.implants)
			if(!istype(O,/obj/item/weapon/implant) && (O.w_class > class) && !istype(O,/obj/item/weapon/shard/shrapnel))
				visible_implants += O

	return(visible_implants)

/mob/living/carbon/human/generate_name()
	name = species.makeName(gender,src)
	real_name = name
	return name

/mob/living/carbon/human/proc/handle_embedded_objects()
	for(var/datum/organ/external/organ in src.organs)
		if(organ.status & ORGAN_SPLINTED) //Splints prevent movement.
			continue
		for(var/obj/item/weapon/O in organ.implants)
			if(!istype(O,/obj/item/weapon/implant) && prob(5)) //Moving with things stuck in you could be bad.
				// All kinds of embedded objects cause bleeding.
				var/msg = null
				switch(rand(1,3))
					if(1)
						msg ="<span class='warning'>A spike of pain jolts your [organ.display_name] as you bump [O] inside.</span>"
					if(2)
						msg ="<span class='warning'>Your movement jostles [O] in your [organ.display_name] painfully.</span>"
					if(3)
						msg ="<span class='warning'>[O] in your [organ.display_name] twists painfully as you move.</span>"
				to_chat(src, msg)

				organ.take_damage(rand(1,3), 0, 0)
				if(!(organ.status & (ORGAN_ROBOT|ORGAN_PEG))) //There is no blood in protheses.
					organ.status |= ORGAN_BLEEDING
					src.adjustToxLoss(rand(1,3))

/mob/living/carbon/human/verb/check_pulse()
	set category = "Object"
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = 0

	if(usr.isUnconscious() || usr.restrained() || !isliving(usr) || isanimal(usr) || isAI(usr))
		return

	if(usr == src)
		self = 1

	if(!self)
		usr.visible_message("<span class='notice'>[usr] kneels down, puts \his hand on [src]'s wrist and begins counting their pulse.</span>",\
		"<span class='info'>You begin counting [src]'s pulse.</span>")
	else
		usr.visible_message("<span class='notice'>[usr] begins counting their pulse.</span>",\
		"<span class='info'>You begin counting your pulse.</span>")

	if(src.pulse)
		to_chat(usr, "<span class='notice'>[self ? "You have a" : "[src] has a"] pulse! Counting...</span>")
	else
		to_chat(usr, "<span class='warning'>[self ? "You have" : "[src] has"] no pulse!</span>")
		return

	to_chat(usr, "<span class='info'>Don't move until counting is finished.</span>")

	if (do_mob(usr, src, 60))
		to_chat(usr, "<span class='notice'>[self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)].</span>")
	else
		to_chat(usr, "<span class='info'>You moved while counting. Try again.</span>")

/mob/living/carbon/human/proc/set_species(var/new_species_name, var/force_organs, var/default_colour)


	if(new_species_name)
		if(src.species && src.species.name && (src.species.name == new_species_name))
			return
	else if(src.dna)
		new_species_name = src.dna.species
	else
		new_species_name = "Human"

	if(src.species)
		//if(src.species.language)	src.remove_language(species.language)
		if(src.species.abilities)
			src.verbs -= species.abilities
		if(species.spells)
			for(var/spell in species.spells)
				remove_spell(spell)
		for(var/L in species.known_languages)
			remove_language(L)
		species.clear_organs(src)

	var/datum/species/S = all_species[new_species_name]

	src.species = new S.type
	src.species.myhuman = src

	if(S.gender)
		gender = S.gender

	for(var/L in species.known_languages)
		add_language(L)
	if(species.default_language)
		add_language(species.default_language)
	if(src.species.abilities)
		src.verbs |= species.abilities
	if(species.spells)
		for(var/spell in species.spells)
			add_spell(spell, "racial_spell_ready", /obj/abstract/screen/movable/spell_master/racial)
	if(force_organs || !src.organs || !src.organs.len)
		src.species.create_organs(src)
	var/datum/organ/internal/eyes/E = src.internal_organs_by_name["eyes"]
	if(E)
		src.see_in_dark = E.see_in_dark //species.darksight
	if(src.see_in_dark > 2)
		src.see_invisible = SEE_INVISIBLE_LEVEL_ONE
	else
		src.see_invisible = SEE_INVISIBLE_LIVING
	if((src.species.default_mutations.len > 0) || (src.species.default_blocks.len > 0))
		src.do_deferred_species_setup = 1
	meat_type = species.meat_type
	spawn()
		src.dna.species = new_species_name
		src.species.handle_post_spawn(src)
		src.update_icons()
	return 1

/mob/living/carbon/human/proc/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if (src.stat)
		return

	if (usr != src)
		return 0 //something is terribly wrong

	if (!bloody_hands)
		verbs -= /mob/living/carbon/human/proc/bloody_doodle

	if (src.gloves)
		to_chat(src, "<span class='warning'>Your [src.gloves] are getting in the way.</span>")
		return

	var/turf/simulated/T = src.loc
	if (!istype(T)) //to prevent doodling out of mechs and lockers
		to_chat(src, "<span class='warning'>You cannot reach the floor.</span>")
		return

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	if (direction != "Here")
		T = get_step(T,text2dir(direction))
	if (!istype(T))
		to_chat(src, "<span class='warning'>You cannot doodle there.</span>")
		return

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		to_chat(src, "<span class='warning'>There is no space to write on!</span>")
		return

	var/max_length = bloody_hands * 30 //tweeter style

	var/message = stripped_input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", "")

	if (message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if (length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")

		var/obj/effect/decal/cleanable/blood/writing/W = getFromPool(/obj/effect/decal/cleanable/blood/writing, T)
		W.New(T)
		W.basecolor = (hand_blood_color) ? hand_blood_color : DEFAULT_BLOOD
		W.update_icon()
		W.message = message
		W.add_fingerprint(src)
/mob/living/carbon/human/can_inject(var/mob/user, var/error_msg, var/target_zone)
	. = 1
	if(!user)
		target_zone = pick(LIMB_CHEST,LIMB_CHEST,LIMB_CHEST,"left leg","right leg","left arm", "right arm", LIMB_HEAD)
	else if(!target_zone)
		target_zone = user.zone_sel.selecting
	/*switch(target_zone)
		if(LIMB_HEAD)
			if(head && head.flags & THICKMATERIAL)
				. = 0
		else
			if(wear_suit && wear_suit.flags & THICKMATERIAL)
				. = 0
	*/
	if(!. && error_msg && user)
 		// Might need re-wording.
		to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [target_zone == LIMB_HEAD ? "on their head" : "on their body"] to inject into.</span>")
/mob/living/carbon/human/canSingulothPull(var/obj/machinery/singularity/singulo)
	if(!..())
		return 0
	if(istype(shoes,/obj/item/clothing/shoes/magboots))
		var/obj/item/clothing/shoes/magboots/M = shoes
		if(M.magpulse && singulo.current_size <= STAGE_FOUR)
			return 0
	return 1
// Get ALL accesses available.
/mob/living/carbon/human/GetAccess()
	var/list/ACL=list()
	var/obj/item/I = get_active_hand()
	if(istype(I))
		ACL |= I.GetAccess()
	if(wear_id)
		ACL |= wear_id.GetAccess()
	return ACL

/mob/living/carbon/human/get_visible_id()
	var/id = null
	if(wear_id)
		id = wear_id.GetID()
	if(!id)
		for(var/obj/item/I in held_items)
			id = I.GetID()
			if(id)
				break
	return id

/mob/living/carbon/human/assess_threat(var/obj/machinery/bot/secbot/judgebot, var/lasercolor)
	if(judgebot.emagged == 2)
		return 10 //Everyone is a criminal!
	var/threatcount = 0
	//Lasertag
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team.
			if(istype(wear_suit, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if(find_held_item_by_type(/obj/item/weapon/gun/energy/tag/red))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/tag/red))
				threatcount += 2
		if(lasercolor == "r")
			if(istype(wear_suit, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if(find_held_item_by_type(/obj/item/weapon/gun/energy/tag/blue))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/tag/blue))
				threatcount += 2
		return threatcount
	//Check for ID
	var/obj/item/weapon/card/id/idcard = get_id_card()
	if(judgebot.idcheck && !idcard)
		threatcount += 4
	//Check for weapons
	if(judgebot.weaponscheck)
		if(!idcard || !(access_weapons in idcard.access))
			for(var/obj/item/I in held_items)
				if(judgebot.check_for_weapons(I))
					threatcount += 4

			if(judgebot.check_for_weapons(belt))
				threatcount += 2
	//Check for arrest warrant
	if(judgebot.check_records)
		var/perpname = get_face_name(get_id_name())
		var/datum/data/record/R = find_record("name", perpname, data_core.security)
		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if("*Arrest*")
					threatcount += 5
				if("Incarcerated")
					threatcount += 2
				if("Parolled")
					threatcount += 2
	//Check for dresscode violations
	if(istype(head, /obj/item/clothing/head/wizard) || istype(head, /obj/item/clothing/head/helmet/space/rig/wizard))
		threatcount += 2
	//Loyalty implants imply trustworthyness
	if(isloyal(src))
		threatcount -= 1
	//Secbots are racist!
	if(dna && dna.mutantrace && dna.mutantrace != "none")
		threatcount += 2
	//Agent cards lower threatlevel.
	if(istype(idcard, /obj/item/weapon/card/id/syndicate))
		threatcount -= 2
/mob/living/carbon/human/has_brain()
	if(internal_organs_by_name["brain"])
		var/datum/organ/internal/brain = internal_organs_by_name["brain"]
		if(brain && istype(brain))
			return 1
	return 0
/mob/living/carbon/human/has_eyes()
	if(internal_organs_by_name["eyes"])
		var/datum/organ/internal/eyes = internal_organs_by_name["eyes"]
		if(eyes && istype(eyes) && !eyes.status & ORGAN_CUT_AWAY)
			return 1
	return 0
/mob/living/carbon/human/singularity_act()
	if(src.flags & INVULNERABLE)
		return 0
	var/gain = 20
	if(mind)
		if((mind.assigned_role == "Station Engineer") || (mind.assigned_role == "Chief Engineer"))
			gain = 100
		if(mind.assigned_role == "Clown")
			gain = rand(-300, 300)
	investigation_log(I_SINGULO,"has been consumed by a singularity")
	gib()
	return gain
/mob/living/carbon/human/singularity_pull(S, current_size,var/radiations = 3)
	if(src.flags & INVULNERABLE)
		return 0
	if(current_size >= STAGE_THREE) //Pull items from hand
		for(var/obj/item/I in held_items)
			if(prob(current_size*5) && I.w_class >= ((11-current_size)/2) && u_equip(I,1))
				step_towards(I, src)
				to_chat(src, "<span class = 'warning'>\The [S] pulls \the [I] from your grip!</span>")
	if(radiations)
		apply_radiation(current_size * radiations, RAD_EXTERNAL)
	if(shoes)
		if(shoes.clothing_flags & NOSLIP && current_size <= STAGE_FOUR)
			return 0
	..()
/mob/living/carbon/human/get_default_language()
	. = ..()
	if(.)
		return .
	if(!species)
		return null
	return species.default_language ? all_languages[species.default_language] : null

/mob/living/carbon/human/dexterity_check()
	if (stat != CONSCIOUS)
		return 0

	if(reagents.has_reagent(METHYLIN))
		return 1

	if(getBrainLoss() >= 60)
		return 0

	if(gloves && istype(gloves, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = gloves

		return G.dexterity_check()

	return 1

/mob/living/carbon/human/spook(mob/dead/observer/ghost)
	if(!..(ghost, TRUE) || !client)
		return
	if(!hallucinating())
		to_chat(src, "<i>[pick(boo_phrases)]</i>")
	else
		to_chat(src, "<b><font color='[pick("red","orange","yellow","green","blue")]'>[pick(boo_phrases_drugs)]</font></b>")

/mob/living/carbon/human/proc/seizure(paralyse_duration = 10, jitter_duration = 1000)
	forcesay(epilepsy_appends)
	visible_message("<span class='danger'>\The [src] starts having a seizure!</span>", \
					"<span class='warning'>You have a seizure!</span>", \
					drugged_message = "<span class='info'>\The [src] starts raving.</span>")
	Paralyse(paralyse_duration)
	Jitter(jitter_duration)

// Makes all robotic limbs organic.
/mob/living/carbon/human/proc/make_robot_limbs_organic()
	for(var/datum/organ/external/O in src.organs)
		if(O.is_robotic())
			O &= ~ORGAN_ROBOT
	update_icons()

// Makes all robot internal organs organic.
/mob/living/carbon/human/proc/make_robot_internals_organic()
	for(var/datum/organ/internal/O in src.organs)
		if(O.robotic)
			O.robotic = 0

// Makes all robot organs, internal and external, organic.
/mob/living/carbon/human/proc/make_all_robot_parts_organic()
	make_robot_limbs_organic()
	make_robot_internals_organic()

/mob/living/carbon/human/proc/set_attack_type(new_type = NORMAL_ATTACK)
	kick_icon.icon_state = "act_kick"
	bite_icon.icon_state = "act_bite"

	if(attack_type == new_type)
		attack_type = NORMAL_ATTACK
		return

	attack_type = new_type
	switch(attack_type)
		if(NORMAL_ATTACK)

		if(ATTACK_KICK)
			kick_icon.icon_state = "act_kick_on"
		if(ATTACK_BITE)
			bite_icon.icon_state = "act_bite_on"

/mob/living/carbon/human/proc/can_kick(atom/target)
	//Need two feet to kick!

	if(legcuffed)
		return 0

	if(target && !isturf(target) && !isturf(target.loc))
		return 0

	var/datum/organ/external/left_foot = get_organ(LIMB_LEFT_FOOT)
	if(!left_foot)
		return 0
	else if(left_foot.status & ORGAN_DESTROYED)
		return 0

	var/datum/organ/external/right_foot = get_organ(LIMB_RIGHT_FOOT)
	if(!right_foot)
		return 0
	else if(right_foot.status & ORGAN_DESTROYED)
		return 0

	return 1

/mob/living/carbon/human/proc/can_bite(atom/target)
	//Need a mouth to bite

	if(!hasmouth)
		return 0

	//Need at least two teeth or a beak to bite

	if(check_body_part_coverage(MOUTH))
		if(!isvampire(src)) //Vampires can bite through masks
			return 0

	if(M_BEAK in mutations)
		return 1

	var/datum/butchering_product/teeth/T = locate(/datum/butchering_product/teeth) in src.butchering_drops
	if(T && T.amount >= 2)
		return 1

	return 0

/mob/living/carbon/human/proc/after_special_attack(atom/target, attack_type, attack_result)
	switch(attack_type)
		if(ATTACK_KICK)
			if(attack_result != SPECIAL_ATTACK_FAILED) //The kick landed successfully
				apply_inertia(get_dir(target, src))

/mob/living/carbon/human/proc/get_footprint_type()
	var/obj/item/clothing/shoes/S = shoes //Why isn't shoes just typecast in the first place?
	return ((istype(S) && S.footprint_type) || (species && species.footprint_type) || /obj/effect/decal/cleanable/blood/tracks/footprints) //The shoes' footprint type overrides the mob's, for obvious reasons. Shoes with a falsy footprint_type will let the mob's footprint take over, though.

/mob/living/carbon/human/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0)
	if(..()) // we've been flashed
		var/datum/organ/internal/eyes/eyes = internal_organs_by_name["eyes"]
		var/damage = intensity - eyecheck()
		if(visual)
			return
		if(!eyes)
			return
		switch(damage)
			if(0)
				to_chat(src, "<span class='notice'>Something bright flashes in the corner of your vision!</span>")
			if(1)
				to_chat(src, "<span class='warning'>Your eyes sting a little.</span>")
				if(prob(40))
					eyes.damage += 1

			if(2)
				src << "<span class='warning'>Your eyes burn.</span>"
				eyes.damage += rand(2, 4)

			else
				to_chat(src,"<span class='warning'>Your eyes itch and burn severely!</span>")
				eyes.damage += rand(12, 16)

		if(eyes.damage > 10)
			eye_blind += damage
			eye_blurry += damage * rand(3, 6)

			if(eyes.damage > 20)
				if (prob(eyes.damage - 20))
					to_chat(src, "<span class='warning'>Your eyes start to burn badly!</span>")
					disabilities |= NEARSIGHTED
				else if(prob(eyes.damage - 25))
					to_chat(src, "<span class='warning'>You can't see anything!</span>")
					disabilities |= BLIND
			else
				to_chat(src, "<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>")
		return 1
	else
		to_chat(src, "<span class='notice'>Something bright flashes in the corner of your vision!</span>")

/mob/living/carbon/human/reset_layer()
	if(lying)
		plane = LYING_HUMAN_PLANE
	else
		plane = HUMAN_PLANE

/mob/living/carbon/human/set_hand_amount(new_amount) //Humans need hand organs to use the new hands. This proc will give them some
	if(new_amount > held_items.len)
		for(var/i = (held_items.len + 1) to new_amount) //For all the new indexes, create a hand organ
			if(!find_organ_by_grasp_index(i))
				var/datum/organ/external/OE = new/datum/organ/external/r_hand(organs_by_name[LIMB_GROIN]) //Fuck it the new hand will grow out of the groin (it doesn't matter anyways)
				OE.grasp_id = i
				OE.owner = src

				organs_by_name["hand[i]"] = OE
				grasp_organs.Add(OE)
				organs.Add(OE)
	..()

/mob/living/carbon/human/is_fat()
	return (M_FAT in mutations) && (species && species.anatomy_flags & CAN_BE_FAT)

mob/living/carbon/human/isincrit()
	if (health - halloss <= config.health_threshold_softcrit)
		return 1

/mob/living/carbon/human/get_broken_organs()
	var/mob/living/carbon/human/H = src
	var/list/return_organs = list()
	for(var/datum/organ/external/damagedorgan in H.organs)
		if(damagedorgan.status & ORGAN_BROKEN && !(damagedorgan.status & ORGAN_SPLINTED))
			return_organs += damagedorgan
	return return_organs

/mob/living/carbon/human/get_bleeding_organs()
	var/mob/living/carbon/human/H = src
	var/list/return_organs = list()
	for(var/datum/organ/external/damagedorgan in H.organs)
		if(damagedorgan.status & ORGAN_BLEEDING)
			return_organs += damagedorgan
	return return_organs

/mob/living/carbon/human/get_heart()
	return internal_organs_by_name["heart"]

//Moved from internal organ surgery
//Removes organ from src, places organ object under user
//example: H.remove_internal_organ(H,H.internal_organs_by_name["heart"],H.get_organ(LIMB_CHEST))
mob/living/carbon/human/remove_internal_organ(var/mob/living/user, var/datum/organ/internal/targetorgan, var/datum/organ/external/affectedarea)
	var/obj/item/organ/internal/extractedorgan
	if(targetorgan && istype(targetorgan))
		extractedorgan = targetorgan.remove(user) //The organ that comes out at the end
		if(extractedorgan && istype(extractedorgan))
			// Stop the organ from continuing to reject.
			extractedorgan.organ_data.rejecting = null

			// Transfer over some blood data, if the organ doesn't have data.
			var/datum/reagent/blood/organ_blood = extractedorgan.reagents.reagent_list[BLOOD]
			var/organstring = targetorgan.organ_type
			if(!organ_blood || !organ_blood.data["blood_DNA"])
				vessel.trans_to(extractedorgan, 5, 1, 1)

			internal_organs_by_name[organstring] = null
			internal_organs_by_name -= organstring
			internal_organs -= extractedorgan.organ_data
			affectedarea.internal_organs -= extractedorgan.organ_data
			extractedorgan.removed(src,user)

			return extractedorgan

/mob/living/carbon/human/feels_pain()
	if(!species)
		return FALSE
	if(species.flags & NO_PAIN)
		return FALSE
	if(pain_numb)
		return FALSE
	return TRUE

/mob/living/carbon/human/advanced_mutate()
	..()
	if(prob(10))
		species.punch_damage = rand(1,5)
	species.max_hurt_damage = rand(1,10)
	if(prob(10))
		species.breath_type = pick("oxygen","toxins","nitrogen","carbon_dioxide")

	species.heat_level_3 = rand(800, 1200)
	species.heat_level_2 = round(species.heat_level_3 / 2.5)
	species.heat_level_1 = round(species.heat_level_2 / 1.11)
	species.cold_level_1 = rand(160, 360)
	species.cold_level_2 = round(species.cold_level_1 / 1.3)
	species.cold_level_3 = round(species.cold_level_2 / 1.66)

	if(prob(30))
		species.darksight = rand(0,8)
	species.hazard_high_pressure *= rand(5,20)/10
	species.warning_high_pressure = round(species.hazard_high_pressure / 1.69)
	species.hazard_low_pressure *= rand(5,20)/10
	species.warning_low_pressure = round(species.hazard_low_pressure * 2.5)
	if(prob(5))
		species.warning_low_pressure = -1
		species.hazard_low_pressure = -1

	species.brute_mod *= rand(5,20)/10
	species.burn_mod *= rand(5,20)/10
	species.tox_mod *= rand(5,20)/10

	if(prob(5))
		species.flags = rand(0,65535)
	if(prob(5))
		species.anatomy_flags = rand(0,65535)
	if(prob(5))
		species.chem_flags = rand(0,65535)

/mob/living/carbon/human/send_to_past(var/duration)
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
		"s_tone",
		"lip_style",
		"eye_style",
		"wear_suit",
		"w_uniform",
		"shoes",
		"belt",
		"gloves",
		"glasses",
		"head",
		"ears",
		"wear_id",
		"r_store",
		"l_store",
		"s_store",
		"l_ear",
		"r_ear",
		"said_last_words",
		"failed_last_breath",
		"last_dam",
		"bad_external_organs",
		"xylophone",
		"meatleft",
		"check_mutations",
		"lastFart",
		"last_shush",
		"last_emote_sound",
		"decapitated",
		"organs",
		"organs_by_name",
		"internal_organs",
		"internal_organs_by_name")

	reset_vars_after_duration(resettable_vars, duration)

	for(var/datum/organ/internal/O in internal_organs)
		O.send_to_past(duration)
	for(var/datum/organ/external/O in organs)
		O.send_to_past(duration)
	if(vessel)
		vessel.send_to_past(duration)

	updatehealth()

/mob/living/carbon/human/attack_icon()
	if(M_HULK in mutations)
		return image(icon = 'icons/mob/attackanims.dmi', icon_state = "hulk")
	else return image(icon = 'icons/mob/attackanims.dmi', icon_state = "default")

/mob/living/carbon/human/proc/initialize_barebones_NPC_components()	//doesn't actually do anything, but contains tools needed for other types to do things
	NPC_brain = new (src)
	NPC_brain.AddComponent(/datum/component/controller/mob)
	NPC_brain.AddComponent(/datum/component/ai/hand_control)

/mob/living/carbon/human/proc/initialize_basic_NPC_components()	//will wander around
	initialize_barebones_NPC_components()
	NPC_brain.AddComponent(/datum/component/ai/human_brain)
	NPC_brain.AddComponent(/datum/component/ai/target_finder/human)
	NPC_brain.AddComponent(/datum/component/ai/target_holder/prioritizing)
	NPC_brain.AddComponent(/datum/component/ai/melee/attack_human)
