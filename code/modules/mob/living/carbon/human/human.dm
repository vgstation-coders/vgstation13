
/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	voice_name = "unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"
	can_butcher = 1
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/embedded_flag	  //To check if we've need to roll for damage on movement while an item is imbedded in us.

	var/fartCooldown = 20 SECONDS

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH|UNPACIFIABLE

/mob/living/carbon/human/manifested
	real_name = "Manifested Ghost"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/manifested/New(var/new_loc, delay_ready_dna = 0)
	underwear = 0
	..(new_loc, "Manifested")

/mob/living/carbon/human/skrell/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Skrell")
	my_appearance.h_style = "Skrell Male Tentacles"
	regenerate_icons()

/mob/living/carbon/human/tajaran/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Tajaran")
	my_appearance.h_style = "Tajaran Ears"
	regenerate_icons()

/mob/living/carbon/human/unathi/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Unathi")
	my_appearance.h_style = "Unathi Horns"
	regenerate_icons()

/mob/living/carbon/human/vox/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Vox")
	my_appearance.h_style = "Short Vox Quills"
	regenerate_icons()

/mob/living/carbon/human/diona/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Diona")
	regenerate_icons()

/mob/living/carbon/human/skellington/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Skellington", delay_ready_dna)
	my_appearance.h_style = "Bald"
	regenerate_icons()

/mob/living/carbon/human/skelevox/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Skeletal Vox")
	my_appearance.h_style = "Bald"
	regenerate_icons()

/mob/living/carbon/human/plasmaman/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Plasmaman")
	my_appearance.h_style = "Bald"
	regenerate_icons()

/mob/living/carbon/human/muton/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Muton")
	my_appearance.h_style = "Bald"
	regenerate_icons()

/mob/living/carbon/human/grey/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Grey")
	my_appearance.h_style = "Bald"
	regenerate_icons()

/mob/living/carbon/human/golem/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Golem")
	my_appearance.h_style = "Bald"
	regenerate_icons()

/mob/living/carbon/human/vampire/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Vampire")
	my_appearance.h_style = "Bald"
	regenerate_icons()

/mob/living/carbon/human/slime/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Slime")
	my_appearance.h_style = "Bald"
	regenerate_icons()

/mob/living/carbon/human/insectoid/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Insectoid")
	my_appearance.h_style = "Insectoid Antennae"
	regenerate_icons()

/mob/living/carbon/human/NPC/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc)
	initialize_basic_NPC_components()

/mob/living/carbon/human/frankenstein/New(var/new_loc, delay_ready_dna = 0, no_tail = FALSE) //Just fuck my shit up: the mob
	var/list/valid_species = (all_species - list("Krampus", "Horror", "Manifested"))

	var/datum/species/new_species = all_species[pick(valid_species)]
	..(new_loc, new_species.name)
	my_appearance.f_style = pick(facial_hair_styles_list)
	my_appearance.h_style = pick(hair_styles_list)
	gender = pick(MALE, FEMALE, NEUTER, PLURAL)
	meat_type = pick(typesof(/obj/item/weapon/reagent_containers/food/snacks/meat))

	for(var/datum/organ/external/E in organs)
		E.species = all_species[pick(valid_species)]
	var/datum/organ/external/tail/tail_datum = get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	if(no_tail)
		tail_datum.droplimb(TRUE, spawn_limb = FALSE)
	else
		var/list/tailed_species = list()
		for(var/species_name in all_species)
			var/datum/species/picked_species = all_species[species_name]
			if(picked_species.anatomy_flags & HAS_TAIL)
				tailed_species += picked_species
		var/datum/species/species_with_tail = pick(tailed_species)
		tail_datum.fleshify()
		tail_datum.create_tail_info(species_with_tail)
		tail_datum.species = species_with_tail
		tail_datum.update_tail(src, random = TRUE)
	update_body()

/mob/living/carbon/human/mushroom/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Mushroom")
	my_appearance.h_style = "Plump Helmet"
	my_appearance.r_hair = 60
	my_appearance.g_hair = 40
	my_appearance.b_hair = 80
	regenerate_icons()

/mob/living/carbon/human/lich/New(var/new_loc, delay_ready_dna = 0)
	..(new_loc, "Undead")
	my_appearance.h_style = "Bald"
	regenerate_icons()

/mob/living/carbon/human/New(var/new_loc, var/new_species_name = null, var/delay_ready_dna=0)
	my_appearance = new // Initialise how they look.
	if(new_species_name)
		my_appearance.s_tone = random_skin_tone(new_species_name)
	multicolor_skin_r = rand(0,255)	//Only used when the human has a species datum with the MULTICOLOR anatomical flag
	multicolor_skin_g = rand(0,255)
	multicolor_skin_b = rand(0,255)

	create_reagents(1000) //Moved it here because it could sometimes lead to errors in set_species() in certain cases

	if(!src.species)
		if(new_species_name)
			src.set_species(new_species_name)
		else
			src.set_species()

	movement_speed_modifier = species.move_speed_multiplier

	default_language = get_default_language()
	init_language = default_language

	if(!dna)
		dna = new /datum/dna(null)
		dna.species=species.name
		dna.b_type = random_blood_type()

	hud_list[HEALTH_HUD]      = new/image/hud('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[STATUS_HUD]      = new/image/hud('icons/mob/hud.dmi', src, "hudhealthy")
	hud_list[PHYSRECORD_HUD]  = new/image/hud('icons/mob/hud.dmi', src, "hudactive")
	hud_list[MENTRECORD_HUD]  = new/image/hud('icons/mob/hud.dmi', src, "hudblank")
	hud_list[ID_HUD]          = new/image/hud('icons/mob/hud.dmi', src, "hudunknown")
	hud_list[WANTED_HUD]      = new/image/hud('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = new/image/hud('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = new/image/hud('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPHOLY_HUD]     = new/image/hud('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = new/image/hud('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = new/image/hud('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD_OOC]  = new/image/hud('icons/mob/hud.dmi', src, "hudhealthy")
	hud_list[WAGE_HUD]        = new/image/hud('icons/mob/hud.dmi', src, "hudblank")

	..()

	if(dna)
		dna.real_name = real_name
		dna.flavor_text = flavor_text

	prev_gender = gender // Debug for plural genders
	make_blood()
	init_butchering_list() // While animals only generate list of their teeth/skins on death, humans generate it when they're born.
	my_appearance.name = real_name
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

	if(buddha_mode_everyone)
		status_flags ^= BUDDHAMODE

	update_colour(0)

	update_mutantrace()

	register_event(/event/equipped, src, nameof(src::update_name()))
	register_event(/event/unequipped, src, nameof(src::update_name()))

/mob/living/carbon/human/proc/update_name()
	name = get_visible_name()

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
		for(var/datum/faction/F in ticker.mode?.factions)
			var/F_stat = F.get_statpanel_addition()
			if(F_stat)
				stat(null, "[F_stat]")
		if(emergency_shuttle)
			if(emergency_shuttle.online && emergency_shuttle.location < 2)
				var/timeleft = emergency_shuttle.timeleft()
				if (timeleft)
					var/acronym = emergency_shuttle.location == 1 ? "ETD" : "ETA"
					stat(null, "[acronym]-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

		if (internal)
			if (!internal.air_contents)
				QDEL_NULL(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)
		/*if(mind)
			if(mind.changeling)
				stat("Chemical Storage", mind.changeling.chem_charges)
				stat("Genetic Damage Time", mind.changeling.geneticdamage)*/

		if(istype(loc, /obj/spacepod)) // Spacdpods!
			var/obj/spacepod/S = loc
			stat("Spacepod Charge", "[istype(S.battery) ? "[S.battery.charge] / [S.battery.maxcharge]" : "No cell detected"]")
			stat("Spacepod Integrity", "[!S.health ? "0" : "[(S.health / initial(S.health)) * 100]"]%")

		if(is_wearing_item(/obj/item/clothing/suit/space/rig, slot_wear_suit))
			var/obj/item/clothing/suit/space/rig/R = wear_suit
			if(R.cell)
				stat("\The [R.name]", "Charge: [R.cell.charge]")
			if(R.activated)
				stat("\The [R.name]", "Modules: [english_list(R.modules)]")

/mob/living/carbon/human/attack_slime(mob/living/carbon/slime/M as mob)
	M.unarmed_attack_mob(src)

/mob/living/carbon/human/restrained()
	if (..())
		return TRUE
	if (istype(wear_suit, /obj/item/clothing/suit/strait_jacket))
		return TRUE
	return FALSE

/mob/living/carbon/human/var/co2overloadtime = null

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/Crossed(var/atom/movable/AM)
	if (flags & INVULNERABLE)
		return
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
/mob/living/carbon/human/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job", var/give_rank = FALSE)
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	var/obj/item/weapon/storage/wallet/wallet = wear_id
	if (istype(pda))
		if (pda.id && istype(pda.id, /obj/item/weapon/card/id))
			if (give_rank)
				. = pda.id.rank
			else
				. = pda.id.assignment
		else
			. = pda.ownjob
	else if (istype(wallet))
		var/obj/item/weapon/card/id/wallet_id = wallet.GetID()
		if(istype(wallet_id))
			if (give_rank)
				. = wallet_id.rank
			else
				. = wallet_id.assignment
	else if (istype(id))
		if (give_rank)
			. = id.rank
		else
			. = id.assignment
	else
		return if_no_id
	if (!.)
		. = if_no_job
	return

/mob/living/carbon/human/identification_string()
	return "[get_identification_name()] ([get_assignment()])"

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_identification_name(var/if_no_id = "Unknown")
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

//repurposed proc. Now it combines get_worn_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/proc/get_visible_name()
	var/unknown_name = "Unknown"

	if ((Holiday == APRIL_FOOLS_DAY || Holiday == HALLOWEEN) && istype(wear_suit, /obj/item/clothing/suit/bedsheet_ghost))
		unknown_name = "a g-g-g-g-ghooooost"

	if (wear_mask && wear_mask.is_hidden_identity())	//Wearing a mask which hides our face, use id-name if possible
		return get_worn_id_name(unknown_name)
	if (head && head.is_hidden_identity())
		return get_worn_id_name(unknown_name)	//Likewise for hats
	if (istruevampire(src))
		return get_worn_id_name(unknown_name)

	var/face_name = get_face_name()
	var/id_name = get_worn_id_name("")
	if(id_name && (id_name != face_name))
		return "[face_name] (as [id_name])"
	return face_name

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name()
	var/datum/organ/external/head/head_organ = get_organ(LIMB_HEAD)
	if((wear_mask && wear_mask.is_hidden_identity() ) || ( head && head.is_hidden_identity() ) || !head_organ || head_organ.disfigured || (head_organ.status & ORGAN_DESTROYED) || !real_name || (M_HUSK in mutations) )	//Wearing a mask which hides our face, use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_worn_id_name(var/if_no_id = "Unknown")
	if(wear_id)
		. = wear_id.get_owner_name_from_ID()
	if(!.)
		return if_no_id

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(var/shock_damage, var/obj/source, var/base_siemens_coeff = 1.0, var/def_zone = null, var/incapacitation_duration)
	if(status_flags & GODMODE || (M_NO_SHOCK in src.mutations))
		return 0	//godmode

	if (!def_zone)
		def_zone = pick(LIMB_LEFT_HAND, LIMB_RIGHT_HAND)

	var/datum/organ/external/affected_organ = get_organ(check_zone(def_zone))
	var/siemens_coeff = base_siemens_coeff * get_siemens_coefficient_organ(affected_organ)

	return ..(shock_damage, source, siemens_coeff, def_zone, incapacitation_duration)

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

	if(slot_back in obscured)
		dat += "<BR><font color=grey><B>Back:</B> Obscured by [wear_suit]</font>"
	else
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

		if (istype(wear_suit, /obj/item/clothing))
			var/obj/item/clothing/WS = wear_suit
			if (WS.hood)
				dat += "<BR>[HTMLTAB]&#8627;<B>Hood:</B> <A href='?src=\ref[src];toggle_suit_hood=1'>Toggle</A>"

	if(slot_shoes in obscured)
		dat += "<BR><font color=grey><B>Shoes:</B> Obscured by [wear_suit]</font>"
	else
		dat += "<BR><B>Shoes:</B> <A href='?src=\ref[src];item=[slot_shoes]'>[makeStrippingButton(shoes)]</A>"

	if(slot_gloves in obscured)
		dat += "<BR><font color=grey><B>Gloves:</B> Obscured by [wear_suit]</font>"
	else
		dat += "<BR><B>Gloves:</B> <A href='?src=\ref[src];item=[slot_gloves]'>[makeStrippingButton(gloves)]</A>"

	dat += "<BR><B>Belt:</B> <A href='?src=\ref[src];item=[slot_belt]'>[makeStrippingButton(belt)]</A>"

	if(slot_w_uniform in obscured)
		dat += "<BR><font color=grey><B>Uniform:</B> Obscured by [wear_suit]</font>"
	else
		dat += "<BR><B>Uniform:</B> <A href='?src=\ref[src];item=[slot_w_uniform]'>[makeStrippingButton(w_uniform)]</A>"

		if(w_uniform)
			dat += "<BR>[HTMLTAB]&#8627;<B>Suit Sensors:</B> <A href='?src=\ref[src];sensors=1'>Set</A>"

			if (istype(w_uniform, /obj/item/clothing))
				var/obj/item/clothing/WU = w_uniform
				if (WU.hood)
					dat += "<BR>[HTMLTAB]&#8627;<B>Hood:</B> <A href='?src=\ref[src];toggle_uniform_hood=1'>Toggle</A>"

		if(pickpocket)
			dat += "<BR>[HTMLTAB]&#8627;<B>Pockets:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? l_store : "<font color=grey>Left (Empty)</font>"]</A>"
			dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? r_store : "<font color=grey>Right (Empty)</font>"]</A>"
		else
			dat += "<BR>[HTMLTAB]&#8627;<B>Pockets:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
			dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A>"

	dat += "<BR>[HTMLTAB]&#8627;<B>ID:</B> <A href='?src=\ref[src];id=1'>[makeStrippingButton(wear_id)]</A>"
	dat += "<BR>"

	if(handcuffed || mutual_handcuffs)
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

	else if(href_list["toggle_uniform_hood"])
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr)|| !w_uniform)
			return
		usr.visible_message("[usr] begins to toggle [src]'s hood.","You begin to toggle [src]'s hood.")
		if (do_mob(usr,src))
			if (istype(w_uniform, /obj/item/clothing))
				var/obj/item/clothing/C = w_uniform
				C.toggle_hood(src,usr,20)

	else if(href_list["toggle_suit_hood"])
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr)|| !wear_suit)
			return
		usr.visible_message("[usr] begins to toggle [src]'s hood.","You begin to toggle [src]'s hood.")
		if (do_mob(usr,src))
			if (istype(w_uniform, /obj/item/clothing))
				var/obj/item/clothing/C = w_uniform
				C.toggle_hood(src,usr,20)

	else if (href_list["refresh"])
		if((machine)&&(in_range(src, usr)))
			show_inv(machine)

	else if (href_list["criminal"])
		if(!usr.hasHUD(HUD_SECURITY) || !usr.hasHUD(HUD_ARRESTACCESS) || isjustobserver(usr))
			return
		var/perpname = get_identification_name(get_face_name())
		var/datum/data/record/sec_record = data_core.find_security_record_by_name(perpname)
		if(!sec_record)
			to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
			return
		var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", sec_record.fields["criminal"]) as null|anything in list("None", "*High Threat*", "*Arrest*", "Incarcerated", "Parolled", "Released")
		if(!setcriminal || (usr.incapacitated() && !isAdminGhost(usr)) || !usr.hasHUD(HUD_SECURITY))
			return
		sec_record.fields["criminal"] = setcriminal
	else if (href_list["secrecord"])
		if(!usr.hasHUD(HUD_SECURITY))
			return
		var/perpname = get_identification_name(get_face_name())
		var/datum/data/record/sec_record = data_core.find_security_record_by_name(perpname)
		if(!sec_record)
			to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
			return
		to_chat(usr, "<b>Name:</b> [sec_record.fields["name"]]	<b>Criminal status:</b> [sec_record.fields["criminal"]]")
		to_chat(usr, "<b>Notes:</b> [sec_record.fields["notes"]]")
		to_chat(usr, "<b>Comments:</b>")
		var/counter = 1
		while(sec_record.fields["com_[counter]"])
			to_chat(usr, sec_record.fields["com_[counter]"])
			counter++
		if(counter == 1)
			to_chat(usr, "No comments found.")
		if(!isjustobserver(usr))
			to_chat(usr, "<a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>")
	else if (href_list["secrecordadd"])
		if(!usr.hasHUD(HUD_SECURITY) || isjustobserver(usr))
			return
		var/perpname = get_identification_name(get_face_name())
		var/datum/data/record/sec_record = data_core.find_security_record_by_name(perpname)
		if(!sec_record)
			to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
			return
		var/t1 = copytext(sanitize(input(usr, "Add Comment:", "Security records") as message|null),1,MAX_MESSAGE_LEN)
		if (!t1 || (usr.incapacitated() && !isAdminGhost(usr)) || !usr.hasHUD(HUD_SECURITY))
			return
		sec_record.add_comment(t1)
	else if (href_list["medical"])
		if(!usr.hasHUD(HUD_MEDICAL) || isjustobserver(usr))
			return
		var/perpname = get_identification_name(get_face_name())
		var/datum/data/record/gen_record = data_core.find_general_record_by_name(perpname)
		if(!gen_record)
			to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
			return
		var/setmedical = input(usr, "Specify a new physical medical status for this person.", "Medical HUD", gen_record.fields["p_stat"]) as null|anything in list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled")
		if(!setmedical|| (usr.incapacitated() && !isAdminGhost(usr)) || !usr.hasHUD(HUD_MEDICAL))
			return
		gen_record.fields["p_stat"] = setmedical
		if(PDA_Manifest.len)
			PDA_Manifest.len = 0
	else if (href_list["medicalsanity"])
		if(!usr.hasHUD(HUD_MEDICAL) || isjustobserver(usr))
			return
		var/perpname = get_identification_name(get_face_name())
		var/datum/data/record/gen_record = data_core.find_general_record_by_name(perpname)
		if(!gen_record)
			to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
			return
		var/setmedical = input(usr, "Specify a new mental medical status for this person.", "Medical HUD", gen_record.fields["m_stat"]) as null|anything in list("*Insane*", "*Unstable*", "*Watch*", "Stable")
		if(!setmedical|| (usr.incapacitated() && !isAdminGhost(usr)) || !usr.hasHUD(HUD_MEDICAL))
			return
		gen_record.fields["m_stat"] = setmedical
		if(PDA_Manifest.len)
			PDA_Manifest.len = 0
	else if (href_list["medrecord"])
		if(!usr.hasHUD(HUD_MEDICAL))
			return
		var/perpname = get_identification_name(get_face_name())
		var/datum/data/record/med_record = data_core.find_medical_record_by_name(perpname)
		if(!med_record)
			to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
			return
		to_chat(usr, "<b>Name:</b> [med_record.fields["name"]]	<b>Blood type:</b> [med_record.fields["b_type"]]")
		to_chat(usr, "<b>DNA:</b> [med_record.fields["b_dna"]]")
		to_chat(usr, "<b>Minor disabilities:</b> [med_record.fields["mi_dis"]]")
		to_chat(usr, "<b>Details:</b> [med_record.fields["mi_dis_d"]]")
		to_chat(usr, "<b>Major disabilities:</b> [med_record.fields["ma_dis"]]")
		to_chat(usr, "<b>Details:</b> [med_record.fields["ma_dis_d"]]")
		to_chat(usr, "<b>Notes:</b> [med_record.fields["notes"]]")
		to_chat(usr, "<a href='?src=\ref[src];medrecordComment=`'>\[View Comment Log\]</a>")
	else if (href_list["medrecordComment"])
		if(!usr.hasHUD(HUD_MEDICAL))
			return
		var/perpname = get_identification_name(get_face_name())
		var/datum/data/record/med_record = data_core.find_medical_record_by_name(perpname)
		if(!med_record)
			to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
			return
		var/counter = 1
		while(med_record.fields["com_[counter]"])
			to_chat(usr, med_record.fields["com_[counter]"])
			counter++
		if (counter == 1)
			to_chat(usr, "No comment found.")
		if(!isjustobserver(usr))
			to_chat(usr, "<a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>")
	else if (href_list["medrecordadd"])
		if(!usr.hasHUD(HUD_MEDICAL) || isjustobserver(usr))
			return
		var/perpname = get_identification_name(get_face_name())
		var/datum/data/record/med_record = data_core.find_medical_record_by_name(perpname)
		if(!med_record)
			to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
			return
		var/t1 = copytext(sanitize(input(usr, "Add comment:", "Medical records") as message|null),1,MAX_MESSAGE_LEN)
		if (!t1 || (usr.incapacitated() && !isAdminGhost(usr)) || !usr.hasHUD(HUD_MEDICAL))
			return
		med_record.add_comment(t1)
	else if (href_list["purchaselog"])
		if(mind)
			mind.role_purchase_log()
	else if (href_list["listitems"])
		var/mob/M = usr
		if(istype(M, /mob/dead) || (!M.isUnconscious() && !M.eye_blind && !M.blinded))
			var/obj/item/I = locate(href_list["listitems"])
			var/obj/item/weapon/storage/internal/S = I
			if(istype(S))
				if(istype(S.master_item, /obj/item/clothing/suit/storage/trader))
					for(var/J in I.contents)
						to_chat(usr, "<span class='info'>[bicon(J)] \A [J].</span>")
	else if (href_list["show_flavor_text"])
		if(can_show_flavor_text())
			var/datum/browser/popup = new(usr, "\ref[src]", name, 500, 200)
			popup.set_content(strip_html(flavor_text))
			popup.open()
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

	for(var/datum/visioneffect/V in huds)
		. += V.eyeprot

	if(E)
		. += E.eyeprot

	return clamp(., -2, 2)

/mob/living/carbon/human/isGoodPickpocket()
	var/obj/item/clothing/gloves/G = gloves
	if(istype(G))
		return G.pickpocket

//Don't forget to change this too if you universalize the gloves
/mob/living/carbon/human/proc/place_in_glove_storage(var/obj/item/I)
	var/obj/item/clothing/gloves/black/thief/storage/S = gloves
	if(!I) //How did you do this
		return 0
	if(istype(S))
		if(S.hold.can_be_inserted(I, 1)) //There is no check in handling item insertion
			S.hold.handle_item_insertion(I, 1)
		else
			put_in_hands(I)


/mob/living/carbon/human/abiotic(var/full_body = 0)
	for(var/obj/item/I in held_items)
		if(I.abstract)
			continue

		return 1

	if(full_body)
		for(var/obj/item/I in get_all_slots())
			return 1

	return 0


/mob/living/carbon/human/proc/check_dna_integrity()
	dna.check_integrity(src)

/mob/living/carbon/human/proc/update_dna_from_appearance() // Takes care of updating our DNA so it matches our appearance
	dna.ResetUIFrom(src)

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
	if(species && species.flags & SPECIES_NO_MOUTH)
		return

	if(!lastpuke)
		lastpuke = 1
		to_chat(src, "<spawn class='warning'>You feel nauseous...</span>")

		spawn((instant ? 0 : 150))	//15 seconds until second warning
			to_chat(src, "<spawn class='danger'>You feel like you are about to throw up!</span>")

			sleep((instant ? 0 : 100))	//And you have 10 more seconds to move it to the bathrooms

			if(gcDestroyed)
				return

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

			playsound(loc, 'sound/effects/splat.ogg', 50, 1)

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

	pick_appearance(src,"Morph",FALSE)

	pick_gender(src,"Morph",FALSE)

	regenerate_icons()

	check_dna_integrity()

	update_dna_from_appearance()

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
	h.disfigured = FALSE

	if(species && !(species.anatomy_flags & NO_BLOOD))
		vessel.add_reagent(BLOOD,560-vessel.total_volume)

	var/datum/organ/internal/brain/BBrain = internal_organs_by_name["brain"]
	if(!BBrain)
		var/obj/item/organ/external/head/B = decapitated?.get()
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

/mob/living/carbon/human/add_blood(var/mob/living/carbon/human/M)
	if (!..())
		return FALSE
	if(!M)
		return

	had_blood = TRUE

	//if this blood isn't already in the list, add it
	if(blood_DNA[M.dna.unique_enzymes])
		return FALSE //already bloodied with this blood. Cannot add more.
	blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	update_inv_gloves()	//handles bloody hands overlays and updating
	return 1 //we applied blood to the item

/mob/living/carbon/human/add_blood_from_data(var/list/blood_data)
	if (!..())
		return FALSE
	if(!blood_data)
		return

	had_blood = TRUE

	//if this blood isn't already in the list, add it
	if(blood_DNA[blood_data["blood_DNA"]])
		return FALSE //already bloodied with this blood. Cannot add more.
	blood_DNA[blood_data["blood_DNA"]] = blood_data["blood_type"]
	update_inv_gloves()	//handles bloody hands overlays and updating
	return TRUE //we applied blood to the item

/mob/living/carbon/human/proc/add_blood_to_feet(var/_amount, var/_color, var/list/_blood_DNA=list(), var/luminous = FALSE)
	if(shoes)
		var/obj/item/clothing/shoes/S = shoes
		S.track_blood = max(0, _amount, S.track_blood)                //Adding blood to shoes
		S.luminous_paint = luminous
		if(!S.blood_DNA)
			S.blood_DNA = list()
		var/newcolor = (S.blood_color && S.blood_DNA.len) ? BlendRYB(S.blood_color, _color, 0.5) : _color
		S.blood_color = newcolor
		S.set_blood_overlay()
		if(_blood_DNA)
			S.blood_DNA |= _blood_DNA.Copy()
		update_inv_shoes(1)

	else
		track_blood = max(_amount, 0, track_blood)                                //Or feet
		if(!feet_blood_DNA)
			feet_blood_DNA = list()

		feet_blood_lum = luminous

		if(!istype(_blood_DNA, /list))
			_blood_DNA = list()
		else
			feet_blood_DNA |= _blood_DNA.Copy()

		feet_blood_color = (feet_blood_color && feet_blood_DNA.len) ? BlendRYB(feet_blood_color, _color, 0.5) : _color

		update_inv_shoes(1)

/mob/living/carbon/human/proc/luminous_feet()
	if(shoes)
		var/obj/item/clothing/shoes/S = shoes
		return S.luminous_paint
	else
		return feet_blood_lum

/mob/living/carbon/human/clean_blood()
	.=..()
	if(!shoes && istype(feet_blood_DNA, /list) && feet_blood_DNA.len)
		feet_blood_color = null
		feet_blood_DNA.len = 0
		update_inv_shoes(1)
		return 1

/mob/living/carbon/human/clean_act(var/cleanliness)
	..()
	for(var/obj/item/I in held_items)
		I.clean_act(cleanliness)

	for(var/obj/item/clothing/C in get_equipped_items())
		C.clean_act(cleanliness)

	if (cleanliness >= CLEANLINESS_SPACECLEANER)
		color = ""//color is a bit easier to remove on humans, for convenience's sake


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

//Record_organ datum, stores as much info as it can about each organ
var/datum/record_organ //This is just a dummy proc, not storing any variables here even if it is "name"

/datum/record_organ/proc/can_record(var/datum/organ/O) //To optimize things a little, see if the limb should be recorded in the first place

/datum/record_organ/proc/record_values(var/datum/organ/O)

/datum/record_organ/proc/apply_values(var/datum/organ/O)

/datum/record_organ/external
	var/name //This is only used for tracking which limb has to be affected, don't paste this over in apply_values
	var/brute_damage
	var/burn_damage
	var/list/wounds = list()
	var/status_flags

/datum/record_organ/external/can_record(var/datum/organ/external/E)
	return (E.brute_dam || E.burn_dam || E.wounds.len || E.status)

/datum/record_organ/external/record_values(var/datum/organ/external/E)
	if(E && istype(E))
		name = E.name
		brute_damage = E.brute_dam
		burn_damage = E.burn_dam
		wounds = E.wounds.Copy()
		E.wounds = list() //Because otherwise the wounds would get caught in the garbage collection and fully heal the mob as they get deleted
		status_flags = E.status

/datum/record_organ/external/apply_values(var/datum/organ/external/E)
	if(E && istype(E))
		E.brute_dam = brute_damage
		E.burn_dam = burn_damage
		E.wounds = wounds.Copy()
		wounds = list() //Now get rid of this here
		E.status = status_flags

/datum/record_organ/internal
	var/name
	var/damage
	var/robotic

/datum/record_organ/internal/can_record(var/datum/organ/internal/I)
	return (I.damage || I.robotic)

/datum/record_organ/internal/record_values(var/datum/organ/internal/I)
	if(I && istype(I))
		name = I.name
		damage = I.damage
		robotic = I.robotic

/datum/record_organ/internal/apply_values(var/datum/organ/internal/I)
	if(I && istype(I))
		I.damage = damage
		I.robotic = robotic

/mob/living/carbon/human/proc/set_species(var/new_species_name, var/force_organs, var/default_colour, var/transfer_damage = 0, var/mob/living/carbon/human/target_override)
	set waitfor = FALSE

	// Target override, in case we want to transfer stuff from a previous mob (the override) to the current one.
	// Only applied to the damage transfer system.
	var/mob/living/carbon/human/target = src
	if(target_override && istype(target_override))
		target = target_override

	//A list of organs and their associated damages
	//External and internal organs have different damage systems
	var/list/recorded_external_damage = list()
	var/list/recorded_internal_damage = list()

	if(transfer_damage) //Don't bother recording any of it if we're not transferring the damage
		for(var/datum/organ/external/E in target.organs) //"organs" is actually external organs
			var/datum/record_organ/external/external_data = new
			if(external_data.can_record(E))
				external_data.record_values(E)
				recorded_external_damage += external_data
		for(var/datum/organ/internal/I in target.internal_organs)
			var/datum/record_organ/internal/internal_data = new
			if(internal_data.can_record(I))
				internal_data.record_values(I)
				recorded_internal_damage += internal_data

	if(new_species_name)
		if(src.species && src.species.name && (src.species.name == new_species_name))
			if(transfer_damage)
				if(target != src) //This mob is a new mob, let's apply the damage from the previous mob
					apply_stored_damages(recorded_external_damage, recorded_internal_damage)
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
			for(var/spell/spell in spell_list)
				if(spell.type in species.spells)
					remove_spell(spell)
		for(var/L in species.known_languages)
			remove_language(L)
		species.clear_organs(src)

	var/datum/species/S = all_species[new_species_name]

	src.species = new S.type
	src.species.myhuman = src

	if(S.gender)
		gender = S.gender
	else if (gender == "neuter") // when going back from an non-gendered species to a gendered one, you'll get assigned randomly
		if (prob(50))
			gender = "male"
		else
			gender = "female"

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
	else
		for(var/datum/organ/external/current_organ in organs)
			if(species.anatomy_flags & NO_BLOOD)
				current_organ.status &= ~ORGAN_BLEEDING
			if(species.anatomy_flags & NO_BONES)
				current_organ.status &= ~ORGAN_BROKEN
				current_organ.status &= ~ORGAN_SPLINTED
			if(species.anatomy_flags & NO_STRUCTURE && current_organ.status & ORGAN_DESTROYED)
				current_organ.status |= ORGAN_ATTACHABLE
				current_organ.amputated = 1
				current_organ.setAmputatedTree()
				current_organ.open = 0
	var/datum/organ/internal/eyes/E = src.internal_organs_by_name["eyes"]
	if(E)
		src.see_in_dark = E.see_in_dark
	if(src.see_in_dark > 2)
		src.see_invisible = SEE_INVISIBLE_LEVEL_ONE
	else
		src.see_invisible = SEE_INVISIBLE_LIVING
	if((src.species.default_mutations.len > 0) || (src.species.default_blocks.len > 0))
		src.do_deferred_species_setup = 1
	meat_type = species.meat_type
	src.movement_speed_modifier = species.move_speed_multiplier

	if(dna)
		dna.species = new_species_name
	//Now re-apply all the damages from before the transformation
	if(transfer_damage)
		apply_stored_damages(recorded_external_damage, recorded_internal_damage)

	if(my_appearance)
		var/list/valid_hair = valid_sprite_accessories(hair_styles_list, null, species.name)
		if (!(my_appearance.h_style in valid_hair))
			my_appearance.h_style = random_hair_style(gender, species)
		var/list/valid_facial_hair = valid_sprite_accessories(facial_hair_styles_list, null, species.name)
		if (!(my_appearance.f_style in valid_facial_hair))
			my_appearance.f_style = random_facial_hair_style(gender, species)
		if (((my_appearance.s_tone < 0) && !(species.anatomy_flags & HAS_SKIN_TONE)) || (my_appearance.s_tone > species.max_skin_tone))
			my_appearance.s_tone = random_skin_tone(species)
		if(dna)
			update_dna_from_appearance()

	src.species.handle_post_spawn(src)
	src.update_icons()
	if(species.species_intro)
		to_chat(src, "<span class = 'notice'>[species.species_intro]</span>")
	return 1

/mob/living/carbon/human/proc/apply_stored_damages(var/list/recorded_external_damage, var/list/recorded_internal_damage)
	for(var/datum/organ/external/new_external in organs)
		for(var/datum/record_organ/external/old_external in recorded_external_damage)
			if(new_external.name == old_external.name)
				old_external.apply_values(new_external)
				recorded_external_damage -= old_external //Trim the list so it doesn't search as much
				QDEL_NULL(old_external)
				break //We found a matching record for this organ, move on to the next organ
	for(var/datum/organ/internal/new_internal in internal_organs)
		for(var/datum/record_organ/internal/old_internal in recorded_internal_damage)
			if(new_internal.name == old_internal.name)
				old_internal.apply_values(new_internal)
				recorded_internal_damage -= old_internal
				QDEL_NULL(old_internal)
				break
	src.handle_organs(TRUE) //Now update them

#define BLOODOODLE_NOSOURCE	0
#define BLOODOODLE_HANDS	1
#define BLOODOODLE_GLOVES	2
#define BLOODOODLE_BLEEDING	2

/mob/living/carbon/human/verb/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor, murder mystery style."

	if (incapacitated() || isUnconscious())
		return

	var/turf/T = get_turf(src)
	if (!isfloor(T))
		to_chat(src, "<span class='warning'>You can only doodle over floors.</span>")
		return

	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		to_chat(src, "<span class='warning'>This floor is already filled with writings.</span>")
		return

	var/doodle_color
	var/doodle_DNA
	var/doodle_type
	var/obj/item/clothing/gloves/actual_gloves
	var/blood_source = BLOODOODLE_NOSOURCE

	//blood on your gloves?
	if (istype(gloves, /obj/item/clothing/gloves))
		actual_gloves = gloves
		if(actual_gloves.transfer_blood > 0 && actual_gloves.blood_DNA?.len)
			doodle_DNA = pick(actual_gloves.blood_DNA)
			doodle_type = actual_gloves.blood_DNA[doodle_DNA]
			doodle_color = actual_gloves.blood_color
			blood_source = BLOODOODLE_GLOVES

	//blood on your hands?
	if(!actual_gloves && bloody_hands > 0 && bloody_hands_data?.len)
		doodle_DNA = bloody_hands_data["blood_DNA"]
		doodle_type = bloody_hands_data["blood_type"]
		doodle_color = bloody_hands_data["blood_colour"]
		blood_source = BLOODOODLE_HANDS

	//are your own hands bleeding you wannabe cultist?
	var/datum/organ/external/right_hand = organs_by_name[LIMB_RIGHT_HAND]
	var/datum/organ/external/left_hand = organs_by_name[LIMB_LEFT_HAND]
	if (!doodle_color && !actual_gloves)
		if ((!(right_hand.status & ORGAN_DESTROYED) && (right_hand.status & ORGAN_BLEEDING)) || (!(left_hand.status & ORGAN_DESTROYED) && (left_hand.status & ORGAN_BLEEDING)))
			if (dna)
				doodle_DNA = dna.unique_enzymes
				doodle_type = dna.b_type
			if (species)
				if (species.anatomy_flags & NO_BLOOD)
					to_chat(src, "<span class='warning'>There is no blood to use coming out of your wounds.</span>")
					return
				doodle_color = species.blood_color
			else
				doodle_color = DEFAULT_BLOOD
			blood_source = BLOODOODLE_BLEEDING

	if (!doodle_color)
		to_chat(src, "<span class='warning'>There is no blood on your [actual_gloves ? "gloves" : "hands"].</span>")
		return


	//Blood found, now to write a message
	var/max_length = 30
	var/message = stripped_input(src,"Write a message. You will be able to preview it.","Bloody writings", "")

	if (!message)
		return

	message = copytext(message, 1, max_length)

	var/letter_amount = length(replacetext(message, " ", ""))
	if(!letter_amount) //If there is no text
		return

	//Previewing our message
	var/image/I = image(icon = null)
	I.maptext = {"<span style="color:[doodle_color];font-size:9pt;font-family:'Bloody';" align="center" valign="top">[message]</span>"}
	I.maptext_height = 32
	I.maptext_width = 64
	I.maptext_x = -16
	I.maptext_y = -2
	I.loc = T
	I.alpha = 180

	client.images.Add(I)
	var/continue_drawing = alert(src, "This is how your message will look. Continue?", "Bloody writings", "Yes", "Cancel")

	client.images.Remove(I)
	animate(I) //Cancel the animation so that the image gets garbage collected
	I.loc = null
	qdel(I)

	if(continue_drawing != "Yes" || !Adjacent(T))
		return

	//One last sanity check
	var/can_still_doodle = FALSE
	var/obj/item/clothing/gloves/actual_gloves2
	if (istype(gloves, /obj/item/clothing/gloves))
		actual_gloves2 = gloves
	switch(blood_source)
		if (BLOODOODLE_HANDS)
			if(!actual_gloves2 && bloody_hands > 0 && bloody_hands_data?.len)
				can_still_doodle = TRUE
		if (BLOODOODLE_GLOVES)
			if(actual_gloves2.transfer_blood > 0 && actual_gloves2.blood_DNA?.len)
				can_still_doodle = TRUE
		if (BLOODOODLE_BLEEDING)
			if (!actual_gloves2)
				if ((!(right_hand.status & ORGAN_DESTROYED) && (right_hand.status & ORGAN_BLEEDING)) || (!(left_hand.status & ORGAN_DESTROYED) && (left_hand.status & ORGAN_BLEEDING)))
					can_still_doodle = TRUE

	if(!can_still_doodle)
		if (blood_source == BLOODOODLE_BLEEDING)
			to_chat(src, "<span class='warning'>Your hands are no longer bleeding.</span>")
		else
			to_chat(src, "<span class='warning'>There is no blood left on your [actual_gloves2 ? "gloves" : "hands"].</span>")
		return

	//Finally writing our message
	var/obj/effect/decal/cleanable/blood/writing/W = new /obj/effect/decal/cleanable/blood/writing(T)
	W.basecolor = doodle_color
	W.maptext = {"<span style="color:[doodle_color];font-size:9pt;font-family:'Bloody';" align="center" valign="top">[message]</span>"}
	W.add_fingerprint(src)
	var/invisible = invisibility || !alpha
	W.visible_message("<span class='warning'>[invisible ? "Invisible fingers" : "\The [src]"] crudely paint[invisible ? "" : "s"] something in blood on \the [T]...</span>")
	W.blood_DNA[doodle_DNA] = doodle_type

	switch(blood_source)
		if (BLOODOODLE_HANDS)
			bloody_hands = max(0,bloody_hands - 1)
		if (BLOODOODLE_GLOVES)
			actual_gloves2.transfer_blood = max(0,actual_gloves2.transfer_blood - 1)
		if (BLOODOODLE_BLEEDING)
			if (vessel)
				vessel.remove_reagent(BLOOD, 1)
	update_inv_gloves()

#undef BLOODOODLE_NOSOURCE
#undef BLOODOODLE_HANDS
#undef BLOODOODLE_GLOVES
#undef BLOODOODLE_BLEEDING


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
	if((shoes.clothing_flags & MAGPULSE) && singulo.current_size <= STAGE_FOUR)
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
	if(head)
		ACL |= head.GetAccess()
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

/mob/living/carbon/human/update_perception()
	if (dark_plane)
		dark_plane.alphas = list()
		dark_plane.colours = null
		dark_plane.blend_mode = BLEND_ADD

	if (master_plane)
		master_plane.blend_mode = BLEND_MULTIPLY

	if(client && dark_plane)
		var/datum/organ/internal/eyes/E = src.internal_organs_by_name["eyes"]
		if(E)
			E.update_perception(src)

		for(var/ID in virus2)
			var/datum/disease2/disease/D = virus2[ID]
			for (var/datum/disease2/effect/catvision/catvision in D.effects)
				if (catvision.count)
					dark_plane.alphas["cattulism"] = clamp(15 + (catvision.count * 20),15,155) // The more it activates, the better we see, until we see as well as a tajaran would.
					break
		if(dark_plane_alpha_override)
			dark_plane.alphas["override"] = dark_plane_alpha_override

	for(var/datum/visioneffect/V in huds)
		V.process_update_perception(src)
		if (dark_plane && V.my_dark_plane_alpha_override && V.my_dark_plane_alpha_override_value)
			dark_plane.alphas["[V.my_dark_plane_alpha_override]"] = V.my_dark_plane_alpha_override_value

	if (istype(glasses))
		glasses.update_perception(src)
		if (dark_plane && glasses.my_dark_plane_alpha_override && glasses.my_dark_plane_alpha_override_value)
			dark_plane.alphas["[glasses.my_dark_plane_alpha_override]"] = glasses.my_dark_plane_alpha_override_value

	if (mind)
		for (var/key in mind.antag_roles)
			var/datum/role/R = mind.antag_roles[key]
			R.update_perception()

	check_dark_vision()

/mob/living/carbon/human/assess_threat(var/obj/machinery/bot/secbot/judgebot, var/lasercolor)
	if(judgebot.emagged == 2)
		return 10 //Everyone is a criminal!
	var/threatcount = 0
	//Lasertag
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team.
			if(iswearingredtag(src))
				threatcount += 4
			if(find_held_item_by_type(/obj/item/weapon/gun/energy/tag/red))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/tag/red))
				threatcount += 2
		if(lasercolor == "r")
			if(iswearingbluetag(src))
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
				if("*High Threat*")
					threatcount += 10
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
	if(is_loyalty_implanted())
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
/mob/living/carbon/human/has_attached_brain()
	if(internal_organs_by_name["brain"])
		var/datum/organ/internal/brain = internal_organs_by_name["brain"]
		if(brain && istype(brain) && !(brain.status & ORGAN_CUT_AWAY))
			return 1
	return 0
/mob/living/carbon/human/has_eyes()
	if(internal_organs_by_name["eyes"])
		var/datum/organ/internal/eyes = internal_organs_by_name["eyes"]
		if(eyes && istype(eyes) && !(eyes.status & ORGAN_CUT_AWAY))
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
/mob/living/carbon/human/singularity_pull(S, current_size, repel = FALSE, var/radiations = 3)
	if(src.flags & INVULNERABLE)
		return 0
	if(current_size >= STAGE_THREE) //Pull items from hand
		for(var/obj/item/I in held_items)
			if(prob(current_size*5) && I.w_class >= ((11-current_size)/2) && u_equip(I,1))
				if(!repel)
					step_towards(I, S)
				else
					step_away(I, S)
				to_chat(src, "<span class = 'warning'>\The [S] [repel ? "pushes" : "pulls"] \the [I] from your grip!</span>")
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
		return FALSE
	var/datum/organ/external/hand_organ_datum = get_active_hand_organ()
	var/obj/item/organ/external/hand_obj = new hand_organ_datum.generic_type
	if(!(hand_obj.is_dexterous))
		return FALSE
	if(gloves && istype(gloves, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = gloves
		if(!G.dexterity_check())//some gloves might make it harder to interact with complex technologies, or fit your index in a gun's trigger
			return FALSE
	if(getBrainLoss() >= 60)
		if(!(reagents.has_reagent(METHYLIN) ||  is_dexterous))//methylin and the is_dextrous var supercede brain damage, but not uncomfortable gloves
			return FALSE
	return TRUE//humans are dexterous enough by default

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

/mob/living/carbon/human/proc/asthma_attack()
	if(disabilities & ASTHMA && !(M_NO_BREATH in mutations) && !(species && species.flags & NO_BREATHE) && !(has_reagent_in_blood(ALBUTEROL)))
		forcesay("-")
		visible_message("<span class='danger'>\The [src] begins wheezing and grabbing at their throat!</span>", \
									"<span class='warning'>You begin wheezing and grabbing at your throat!</span>")
		src.reagents.add_reagent(MUCUS, 10)

// Makes all robotic limbs organic.
/mob/living/carbon/human/proc/make_robot_limbs_organic()
	for(var/datum/organ/external/O in organs)
		if(O.is_robotic())
			O.fleshify()
	update_icons()
	update_body()

// Makes all robot internal organs organic.
/mob/living/carbon/human/proc/make_robot_internals_organic()
	for(var/datum/organ/internal/O in internal_organs)
		O.robotic = 0

// Makes all robot organs, internal and external, organic.
/mob/living/carbon/human/proc/make_all_robot_parts_organic()
	make_robot_limbs_organic()
	make_robot_internals_organic()

// Makes all limbs robotic.
/mob/living/carbon/human/proc/make_organic_limbs_robotic()
	for(var/datum/organ/external/O in organs)
		if(!O.is_robotic())
			O.robotize()
	update_icons()
	update_body()

// Makes all internal organs robotic.
/mob/living/carbon/human/proc/make_organic_internals_robotic()
	for(var/datum/organ/internal/O in internal_organs)
		O.robotic = 2

// Makes all organs, internal and external, robotic.
/mob/living/carbon/human/proc/make_all_organic_parts_robotic()
	make_organic_limbs_robotic()
	make_organic_internals_robotic()

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

/mob/living/carbon/human/hasmouth()
	if(species.flags & SPECIES_NO_MOUTH)
		return 0
	return hasmouth

/mob/living/carbon/human/proc/can_bite(atom/target)
	//Need a mouth to bite

	if(!hasmouth())
		return 0

	//Need at least two teeth or a beak to bite

	if(check_body_part_coverage(MOUTH) && !isvampire(src))
		return 0

	if(M_BEAK in mutations)
		return 1

	var/datum/butchering_product/teeth/T = locate(/datum/butchering_product/teeth) in src.butchering_drops
	if(T && T.amount >= -1)
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


/mob/living/carbon/human/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/abstract/screen/fullscreen/flash)
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
	if(istype(locked_to, /obj/machinery/bot/mulebot)) //we only care about not appearing behind mulebots
		return
	if(lying)
		plane = LYING_HUMAN_PLANE
	else
		plane = HUMAN_PLANE
	var/area/this_area = get_area(src)
	if(istype(this_area) && this_area.project_shadows)
		update_shadow()
	loc.adjust_layer(src)

/mob/living/carbon/human/set_hand_amount(new_amount) //Humans need hand organs to use the new hands. This proc will give them some
	if(new_amount > held_items.len)
		for(var/i = (held_items.len + 1) to new_amount) //For all the new indexes, create a hand organ
			if(!find_organ_by_grasp_index(i))
				var/datum/organ/external/OE = new/datum/organ/external/hand/r_hand(organs_by_name[LIMB_GROIN]) //Fuck it the new hand will grow out of the groin (it doesn't matter anyways)
				OE.grasp_id = i
				OE.owner = src

				organs_by_name["hand[i]"] = OE
				grasp_organs.Add(OE)
				organs.Add(OE)
	..()

/mob/living/carbon/human/is_fat()
	return (M_FAT in mutations) && (species && species.anatomy_flags & CAN_BE_FAT)

// Bulky checks are often enough that it might as well be a proc for readability. -CW
/mob/living/carbon/human/proc/is_bulky()
	return species.anatomy_flags & IS_BULKY

/mob/living/carbon/human/isincrit()
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

/mob/living/carbon/human/get_lungs()
	return internal_organs_by_name["lungs"]

/mob/living/carbon/human/get_liver()
	return internal_organs_by_name["liver"]

/mob/living/carbon/human/get_kidneys()
	return internal_organs_by_name["kidneys"]

/mob/living/carbon/human/get_appendix()
	return internal_organs_by_name["appendix"]

//Moved from internal organ surgery
//Removes organ from src, places organ object in user's hands
//example: H.remove_internal_organ(H,H.internal_organs_by_name["heart"],H.get_organ(LIMB_CHEST))
/mob/living/carbon/human/remove_internal_organ(var/mob/living/user, var/datum/organ/internal/targetorgan, var/datum/organ/external/affectedarea)
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
			user.put_in_hands(extractedorgan)

			return extractedorgan

/mob/living/carbon/human/feels_pain()
	if(!species) //should really really not happen!!
		return FALSE
	if(species.flags & NO_PAIN)
		return FALSE
	if(pain_numb)
		return FALSE
	var/datum/organ/internal/brain/sponge = internal_organs_by_name["brain"]
	if(!sponge || !istype(sponge) || (sponge.status & ORGAN_CUT_AWAY))
		return FALSE
	return TRUE

/mob/living/carbon/human/advanced_mutate()
	..()
	if(prob(10))
		species.punch_damage = rand(1,5)
	species.max_hurt_damage = rand(1,10)
	if(prob(10))
		species.breath_type = pick(GAS_OXYGEN, GAS_PLASMA, GAS_NITROGEN, GAS_CARBON)
		var/datum/organ/internal/lungs/L = internal_organs_by_name["lungs"]
		if(L && !L.robotic)
			L.gasses.Remove(locate(/datum/lung_gas/metabolizable) in L.gasses)
			L.gasses.Add(new /datum/lung_gas/metabolizable(species.breath_type, min_pp = 16, max_pp = 140))

	species.heat_level_3 = rand(800, 1200)
	species.heat_level_2 = round(species.heat_level_3 / 2.5)
	species.heat_level_1 = round(species.heat_level_2 / 1.11)
	species.cold_level_1 = rand(160, 360)
	species.cold_level_2 = round(species.cold_level_1 / 1.3)
	species.cold_level_3 = round(species.cold_level_2 / 1.66)

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

	var/can_be_fat = species.anatomy_flags & CAN_BE_FAT	//removing this flag causes gamebreaking things like invisible fat aliens to happen

	if(prob(5))
		species.flags = rand(0,65535)
	if(prob(5))
		species.anatomy_flags = rand(0,65535)
	if(prob(5))
		species.chem_flags = rand(0,65535)
	if(prob(15))
		species.tackleRange = max(0, rand(species.tackleRange-2, species.tackleRange+2))	//Leaving this with no upper limit is a choice I'm making today. God help us tomorrow.
	if(prob(15))
		species.tacklePower = max(0, rand(species.tacklePower*0.5, species.tacklePower*1.5))


	if(!can_be_fat)
		species.anatomy_flags &= ~CAN_BE_FAT
	
	species.blood_color = get_random_colour()
	species.flesh_color = get_random_colour()

/mob/living/carbon/human/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"lip_style",
		"eye_style",
		"face_style",
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
		"lastDab",
		"lastAnemia",
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
	if(my_appearance)
		my_appearance.send_to_past(duration)

	updatehealth()

/mob/living/carbon/human/attack_icon()
	if(M_HULK in mutations)
		return image(icon = 'icons/mob/attackanims.dmi', icon_state = "hulk")
	else return image(icon = 'icons/mob/attackanims.dmi', icon_state = "default")

/mob/living/carbon/human/proc/initialize_barebones_NPC_components()	//doesn't actually do anything, but contains tools needed for other types to do things
	add_component(/datum/component/controller/movement/astar)

/mob/living/carbon/human/proc/initialize_basic_NPC_components()	//will wander around
	initialize_barebones_NPC_components()
	add_component(/datum/component/ai/human_brain)
	add_component(/datum/component/ai/target_finder/human)
	add_component(/datum/component/ai/target_holder/prioritizing)
	add_component(/datum/component/ai/melee/attack_human)
	add_component(/datum/component/ai/melee/throw_attack)
	add_component(/datum/component/ai/crowd_attack)
	add_component(pick(typesof(/datum/component/ai/targetting_handler)))

/mob/living/carbon/human/can_show_flavor_text()
	// Wearing a mask...
	if(wear_mask && wear_mask.is_hidden_identity())
		return FALSE
	// Or having a headpiece that protects your face...
	if(head && head.is_hidden_identity())
		return FALSE
	// Or lacking a head, or being disfigured...
	var/datum/organ/external/head/limb_head = get_organ(LIMB_HEAD)
	if(!limb_head || limb_head.disfigured || (limb_head.status & ORGAN_DESTROYED) || !real_name)
		return FALSE
	// Or being a husk...
	if(M_HUSK in mutations)
		return FALSE
	// Or being appearance banned...
	if(appearance_isbanned(src))
		return FALSE
	// ...means no flavor text for you. Otherwise, good to go.
	return TRUE

/mob/living/carbon/human/proc/zombify(mob/master, var/retain_mind = TRUE, var/crabzombie = FALSE)
	if(crabzombie)
		dropBorers()
		var/mob/living/simple_animal/hostile/necro/zombie/headcrab/T = new(get_turf(src), master, (retain_mind ? src : null))
		T.virus2 = virus_copylist(virus2)
		T.get_clothes(src, T)
		T.name = real_name
		T.host = src
		forceMove(null)
		return T
	else if(stat == DEAD || InCritical())
		dropBorers()
		var/mob/living/simple_animal/hostile/necro/zombie/turned/T = new(get_turf(src), master, (retain_mind ? src : null))
		if(master && master.faction)
			T.faction = "\ref[master]"
		T.add_spell(/spell/aoe_turf/necro/zombie/evolve)
		if(isgrey(src))
			T.icon_state = "mauled_laborer"
			T.icon_living = "mauled_laborer"
			T.icon_dead = "mauled_laborer"
		else if(isvox(src))
			T.icon_state = "rotting_raider1"
			T.icon_living = "rotting_raider1"
			T.icon_dead = "rotting_raider1"
		else if(isinsectoid(src))
			T.icon_state = "zombie_turned"
			T.icon_living = "zombie_turned"
			T.icon_dead = "zombie_turned"
		T.virus2 = virus_copylist(virus2)
		T.get_clothes(src, T)
		T.name = real_name
		T.host = src
		forceMove(null)
		return T
	else
		become_zombie = TRUE

/mob/living/carbon/human/drop_hands(var/atom/Target, force_drop = 0)
	if (istype(gloves, /obj/item/clothing/gloves/hunter))
		for(var/obj/item/I in held_items)
			if (istype(I, /obj/item/weapon/gun/hookshot/whip))
				to_chat(src, "<span class='notice'>You hold your grip onto your [I]</span>")
			else
				drop_item(I, Target, force_drop = force_drop)
	else
		..()

/mob/living/carbon/human/get_afterimage()
	if (istype(w_uniform, /obj/item/clothing/under/hunter)\
		&& istype(wear_suit, /obj/item/clothing/suit/hunter)\
		&& istype(shoes, /obj/item/clothing/shoes/hunter)\
		&& istype(head, /obj/item/clothing/head/hunter)\
		&& istype(gloves, /obj/item/clothing/gloves/hunter))
		playsound(src, 'sound/weapons/authenticrichtertackleslide.ogg', 70, 0)
		anim(target = src, a_icon = 'icons/effects/effects.dmi', flick_anim = "castlevania_tackle_flick", plane = ABOVE_LIGHTING_PLANE)
		return "richter tackle"

/mob/living/carbon/human/throw_item(var/atom/target,var/atom/movable/what=null)
	var/atom/movable/item = get_active_hand()
	if(what)
		item=what
	var/success = ..()
	if(success)
		if(istype(gloves))
			var/obj/item/clothing/gloves/G = gloves
			G.on_wearer_threw_item(src,target,item)

/mob/living/carbon/human/hasHUD(var/hud_kind)
	switch(hud_kind)
		if(HUD_MEDICAL)
			for(var/datum/visioneffect/medical/H in huds)
				return TRUE
			return FALSE
		if(HUD_SECURITY)
			var/glasses = get_item_by_slot(slot_glasses)
			if(glasses)
				if(istype(glasses, /obj/item/clothing/glasses/hud/security/sunglasses/syndishades))
					var/obj/item/clothing/glasses/hud/security/sunglasses/syndishades/S = glasses
					return S.full_access
			for(var/datum/visioneffect/security/H in huds)
				return TRUE
			return FALSE
		if(HUD_ARRESTACCESS)
			var/glasses = get_item_by_slot(slot_glasses)
			if(glasses)
				if(istype(glasses, /obj/item/clothing/glasses/hud/security/sunglasses/syndishades))
					var/obj/item/clothing/glasses/hud/security/sunglasses/syndishades/S = glasses
					return S.full_access
			for(var/datum/visioneffect/security/arrest/H in huds)
				return TRUE
			return FALSE
		if(HUD_WAGE)
			for(var/datum/visioneffect/accountdb/wage/H in huds)
				return TRUE
			return FALSE
		if(HUD_MESON)
			for(var/datum/visioneffect/meson/H in huds)
				return TRUE
			return FALSE
	return FALSE

/mob/living/carbon/human/on_syringe_injection(var/mob/user, var/obj/item/weapon/reagent_containers/syringe/tool)
	ASSERT(species)
	if(species.chem_flags & NO_INJECT)
		user.visible_message(
			"<span class='warning'>\The [user] tries to pierce [src] with \the [tool] but it won't go in!</span>",
			"<span class='warning'>You try to pierce [src] with \the [tool] but it won't go in!</span>")
		return INJECTION_RESULT_FAIL
	return ..()

/mob/living/carbon/human/get_cell()
	var/datum/organ/internal/heart/cell/C = get_heart()
	if(istype(C) && C.cell)
		return C.cell
	if(wear_suit && wear_suit.get_cell())
		return wear_suit.get_cell()

/mob/living/carbon/human/proc/butt_blast()
	var/mob/living/carbon/C = src
	if(C.op_stage.butt != SURGERY_NO_BUTT)
		if(remove_butt())
			to_chat(src, "<span class='warning'>Your ass just blew up!</span>")
	playsound(src, 'sound/effects/superfart.ogg', 50, 1)
	C.apply_damage(40, BRUTE, LIMB_GROIN)
	C.apply_damage(10, BURN, LIMB_GROIN)
	score.assesblasted++

// Returns null on failure, the butt on success.
/mob/living/carbon/human/proc/remove_butt(var/where = loc)
	if(op_stage.butt == SURGERY_NO_BUTT)
		return
	var/obj/item/clothing/head/butt/donkey = new(where)
	donkey.transfer_buttdentity(src)
	op_stage.butt = SURGERY_NO_BUTT
	return donkey

/mob/living/carbon/human/attempt_crawling(var/turf/target)
	if(!lying)
		return FALSE
	if(!isfloor(target) || !isfloor(get_turf(src)) || !Adjacent(target))
		return FALSE
	if(isUnconscious() || stunned || paralysis || !check_crawl_ability() || pulledby || grabbed_by.len || locked_to || client.move_delayer.blocked())
		return FALSE
	var/crawldelay = 0.2 SECONDS
	if(istype(target, /turf/simulated/floor/engine/bolted))
		adjustBruteLoss(5)
		delayNextMove(crawldelay)
		to_chat(src, "<span class='warning'>You injure yourself trying to crawl onto the bolted floor!</span>")
		return FALSE
	if (crawlcounter >= max_crawls_before_fatigue)
		if (prob(10))
			to_chat(src, "<span class='warning'>You get tired from all this crawling around.</span>")
		crawldelay = round(1 + base_movement_tally()/10) * 3 SECONDS
		crawlcounter = 1
	else
		crawlcounter++
	for(var/obj/effect/overlay/puddle/P in target)
		if(P.wet == TURF_WET_WATER && prob(20))
			to_chat(src, "<span class='warning'>Your hands slip and make no progress!</span>")
			return FALSE
		if(P.wet == TURF_WET_LUBE && prob(75))
			to_chat(src, "<span class='warning'>You lose your grip on the extremely slippery floor and make no progress!</span>")
			return FALSE
	. = Move(target, get_dir(src, target), glide_size_override = crawldelay)
	delayNextMove(crawldelay, additive = 1)

/mob/living/carbon/human/resist_memes(var/datum/speech/speech)
	//do not use check_contact_sterility because other things cover ears, like helmets
	if(ears && prob(ears.sterility))
		return TRUE //If wearing sterile earpiece, block the meme
	else
		return ..()

/mob/living
	var/hangman_score = 0 // For round end leaderboards

/mob/living/carbon/human/proc/DormantGenes(var/badGeneProb = 2, var/chanceForGoodIfBad = 10, var/goodGeneProb = 0, var/chanceForBadIfGood = 0) // default values are those used on roundstart/latejoin
	if(prob(badGeneProb))
		dna.GiveRandomSE(notflags = GENE_UNNATURAL,genetype = GENETYPE_BAD, dormant = TRUE)
		if(prob(chanceForGoodIfBad))
			dna.GiveRandomSE(notflags = GENE_UNNATURAL,genetype = GENETYPE_GOOD, dormant = TRUE)

	if(prob(goodGeneProb))
		dna.GiveRandomSE(notflags = GENE_UNNATURAL,genetype = GENETYPE_GOOD, dormant = TRUE)
		if(prob(chanceForBadIfGood))
			dna.GiveRandomSE(notflags = GENE_UNNATURAL,genetype = GENETYPE_BAD, dormant = TRUE)



/mob/living/carbon/human/Hear(var/datum/speech/speech, var/rendered_speech="")
	..()
	if(stat)
		return //Don't bother if we're dead or unconscious
	if(ear_deaf || speech.frequency || speech.speaker == src)
		return //First, eliminate radio chatter, speech from us, or wearing earmuffs/deafened
	var/mob/living/H = speech.speaker
	if(muted_letters && muted_letters.len) // If we're working with a hangman cursed individual
		var/hangman_answer = speech.message
		hangman_answer = replacetext(hangman_answer,".","") // Filter out punctuation and uppercase
		hangman_answer = replacetext(hangman_answer,"?","")
		hangman_answer = replacetext(hangman_answer,"!","")
		if(hangman_phrase != "" && hangman_answer == hangman_phrase) // Whole phrase guessed right?
			for(var/letter in muteletters_check)
				muted_letters.Remove(letter) // Wipe checked letters from muted ones
				muteletters_check.Remove(letter) // And the list itself
				H.hangman_score++ // Add to score
			H.visible_message("<span class='sinister'>[speech.speaker] has found the sentence spoken! It was \"[hangman_phrase]\".</span>","<span class='sinister'>You found the sentence spoken! It was \"[hangman_phrase]\".</span>")
			hangman_phrase = ""
		hangman_answer = uppertext(hangman_answer)
		if(length(hangman_answer) == 1) // If we only said a letter
			if(hangman_answer in muteletters_check) // Correct answer?
				muted_letters.Remove(hangman_answer) // Baleet it
				muteletters_check.Remove(hangman_answer) // Here too
				var/obscured_answer = hangman_phrase
				for(var/letter in muted_letters)
					obscured_answer = replacetext(obscured_answer, letter, "_")
				if(muteletters_check.len)
					H.visible_message("<span class='sinister'>[speech.speaker] has found a letter obscured in [src]'s sentence and it has been made clear! Current sentence: [obscured_answer].</span>","<span class='sinister'>You found a letter obscured in [src]'s sentence and it has been made clear! Current sentence: [obscured_answer].</span>")
				else
					H.visible_message("<span class='sinister'>[speech.speaker] has found the sentence spoken! It was \"[hangman_phrase]\".</span>","<span class='sinister'>You found the sentence spoken! It was \"[hangman_phrase]\".</span>")
					hangman_phrase = ""
				H.hangman_score++ // Add to score
			else if(muteletter_tries)
				muteletter_tries-- //Reduce the attempts left before...
				visible_message("<span class='sinister'>This letter is not found in obscured speech! [muteletter_tries] tries left.</span>")
			else
				set_muted_letters(max(0,26-(muted_letters.len+1))) // It gets scrambled and lengthened!
				visible_message("<span class='sinister'>Too many bad guessses... the letters have been obscured again!</span>")
	if(!mind || !mind.faith || length(speech.message) < 20)
		return //If we aren't religious or hearing a long message, don't check further
	if(dizziness || stuttering || jitteriness || hallucination || confused || drowsyness || pain_shock_stage)
		if(isliving(H) && H.mind == mind.faith.religiousLeader)
			AdjustDizzy(rand(-8,-10))
			stuttering = max(0,stuttering-rand(8,10))
			jitteriness = max(0,jitteriness-rand(8,10))
			hallucination = max(0,hallucination-rand(8,10))
			remove_confused(rand(8, 10))
			drowsyness = max(0, drowsyness-rand(8,10))
			pain_shock_stage = max(0, pain_shock_stage-rand(3,5))

/mob/living/carbon/human/proc/set_muted_letters(var/keep_amount)
	muteletter_tries = 3
	muted_letters = list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
	for(var/i = 0, i < keep_amount, i++)
		pick_n_take(muted_letters)

/mob/living/carbon/human/rejuvenate(animation = 0)
	muted_letters = list()
	muteletter_tries = 3
	..()

/mob/living/carbon/human/can_be_infected()
	return 1

//this method handles user getting attacked with an emag - the original logic was in human_defense.dm,
//but it's better that it belongs to human.dm
/mob/living/carbon/human/emag_act(var/mob/attacker, var/datum/organ/external/affecting, var/obj/item/weapon/card/emag)
	var/hit_area = affecting.display_name
	if(!(affecting.status & ORGAN_ROBOT))
		to_chat(attacker, "<span class='warning'>That limb isn't robotic.</span>")
		return FALSE
	if(affecting.sabotaged)
		to_chat(attacker, "<span class='warning'>\The [src]'s [hit_area] is already sabotaged!</span>")
	else
		to_chat(attacker, "<span class='warning'>You sneakily slide [emag] into the dataport on \the [src]'s [hit_area] and short out the safeties.</span>")
		affecting.sabotaged = TRUE
	return FALSE

/mob/living/carbon/human/swap_hand()
	var/valid_hand = FALSE
	for(var/i = 0; i < held_items.len; i++)
		if (++active_hand > held_items.len)
			active_hand = 1
		if (can_use_hand_or_stump(active_hand))
			valid_hand = TRUE
			break

	if(!valid_hand)
		active_hand = 0

	update_hands_icons()

/mob/living/carbon/human/get_personal_ambience()
	if(istype(locked_to, /obj/structure/bed/therapy))
		return list(/datum/ambience/beach)
	else
		return ..()

/mob/living/carbon/human/make_meat(location)
	var/ourMeat = new meat_type(location, src)
	return ourMeat	//Exists due to meat having a special New()

/mob/living/carbon/human/turn_into_mannequin(var/material = "marble",var/forever = FALSE)
	var/list/valid_mannequin_species = list(
		"Human",
		"Vox",
		"Manifested",
		)
	if (!(species.name in valid_mannequin_species))
		return FALSE

	var/turf/T = get_turf(src)
	var/obj/structure/mannequin/new_mannequin

	var/list/mannequin_clothing = list(
		SLOT_MANNEQUIN_ICLOTHING,
		SLOT_MANNEQUIN_FEET,
		SLOT_MANNEQUIN_GLOVES,
		SLOT_MANNEQUIN_EARS,
		SLOT_MANNEQUIN_OCLOTHING,
		SLOT_MANNEQUIN_EYES,
		SLOT_MANNEQUIN_BELT,
		SLOT_MANNEQUIN_MASK,
		SLOT_MANNEQUIN_HEAD,
		SLOT_MANNEQUIN_BACK,
		SLOT_MANNEQUIN_ID,
		)

	mannequin_clothing[SLOT_MANNEQUIN_ICLOTHING] = w_uniform
	mannequin_clothing[SLOT_MANNEQUIN_OCLOTHING] = wear_suit
	mannequin_clothing[SLOT_MANNEQUIN_HEAD] = head
	mannequin_clothing[SLOT_MANNEQUIN_MASK] = wear_mask
	mannequin_clothing[SLOT_MANNEQUIN_BACK] = back
	mannequin_clothing[SLOT_MANNEQUIN_ID] = wear_id
	mannequin_clothing[SLOT_MANNEQUIN_BELT] = belt
	mannequin_clothing[SLOT_MANNEQUIN_GLOVES] = gloves
	mannequin_clothing[SLOT_MANNEQUIN_FEET] = shoes
	mannequin_clothing[SLOT_MANNEQUIN_EARS] = ears
	mannequin_clothing[SLOT_MANNEQUIN_EYES] = glasses

	var/list/mannequin_held_items = list(null, null)

	for (var/i = 1 to mannequin_held_items.len)
		var/obj/O = held_items[i]
		if (O)
			drop_item(O,T,TRUE)
			mannequin_held_items[i] = O

	for (var/obj/O in get_all_slots())
		drop_item(O,T,TRUE)

	switch (species.name)
		if ("Human","Manifested")
			if (is_fat())
				switch (material)
					if ("marble")
						new_mannequin = new /obj/structure/mannequin/fat(T,my_appearance.f_style,my_appearance.h_style,mannequin_clothing,mannequin_held_items,src,forever)
					if ("wood")
						new_mannequin = new /obj/structure/mannequin/wood/fat(T,my_appearance.f_style,my_appearance.h_style,mannequin_clothing,mannequin_held_items,src,forever)
			else if (gender == FEMALE)
				switch (material)
					if ("marble")
						new_mannequin = new /obj/structure/mannequin/woman(T,my_appearance.f_style,my_appearance.h_style,mannequin_clothing,mannequin_held_items,src,forever)
					if ("wood")
						new_mannequin = new /obj/structure/mannequin/wood/woman(T,my_appearance.f_style,my_appearance.h_style,mannequin_clothing,mannequin_held_items,src,forever)
			else
				switch (material)
					if ("marble")
						new_mannequin = new /obj/structure/mannequin(T,my_appearance.f_style,my_appearance.h_style,mannequin_clothing,mannequin_held_items,src,forever)
					if ("wood")
						new_mannequin = new /obj/structure/mannequin/wood(T,my_appearance.f_style,my_appearance.h_style,mannequin_clothing,mannequin_held_items,src,forever)
		if ("Vox")
			switch (material)
				if ("marble")
					new_mannequin = new /obj/structure/mannequin/vox(T,my_appearance.f_style,my_appearance.h_style,mannequin_clothing,mannequin_held_items,src,forever)
				if ("wood")
					new_mannequin = new /obj/structure/mannequin/wood/vox(T,my_appearance.f_style,my_appearance.h_style,mannequin_clothing,mannequin_held_items,src,forever)

	if (new_mannequin)
		return TRUE
	return FALSE

/mob/living/carbon/human/get_butchering_products()
	if (!species)
		return list()

	switch (species.name)
		if ("Human","Manifested")
			return list(/datum/butchering_product/teeth/human, /datum/butchering_product/skin/human)
		if ("Unathi")
			return list(/datum/butchering_product/teeth/lots, /datum/butchering_product/skin/lizard/lots)
		if ("Skrell")
			return list(/datum/butchering_product/teeth/lots)
		if ("Skellington")
			return list(/datum/butchering_product/teeth/human)
		if ("Tajaran")
			return list(/datum/butchering_product/teeth/human, /datum/butchering_product/skin/cat/lots)
	return list()
		/*	Missing Sprites, pls contribute

		if ("Vox")
			return list(
		if ("Diona")
			return list(
		if ("Skeletal Vox")
			return list(
		if ("Plasmaman")
			return list(
		if ("Muton")
			return list(
		if ("Grey")
			return list(
		if ("Golem")
			return list(
		if ("Vampire")
			return list(
		if ("Slime")
			return list(
		if ("Insectoid")
			return list(
		if ("Mushroom")
			return list(
		if ("Undead")
			return list(

		*/
