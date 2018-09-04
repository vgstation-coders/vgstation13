//CULT 3.0 BY DEITY LINK (2018)
//BASED ON THE ORIGINAL GAME MODE BY URIST MCDORF

var/veil_thickness = CULT_PROLOGUE

//CULT_PROLOGUE		Default thickness, only communication and raise structure runes enabled
//CULT_ACT_I		Altar raised. cultists can now convert.
//CULT_ACT_II		Cultist amount reached. cultists are now looking for the sacrifice
//CULT_ACT_III		Sacrifice complete. cult is now going loud, spreading blood and protecting bloodstones while the crew tries to destroy them
//CULT_ACT_IV		Bloodspill threshold reached. bloodstones become indestructible, rift opens above one of them. cultists must open it, crew must close it.
//CULT_EPILOGUE		The cult succeeded. The station is no longer reachable from space or through teleportation, and is now part of hell. Nar-Sie hunts the survivors.
//CULT_MENDED		The cult failed (bloodstones all destroyed or rift closed). cult magic permanently disabled, living cultists progressively die by themselves.

/datum/faction/bloodcult
	name = "Cult of Nar-Sie"
	ID = BLOODCULT
	initial_role = CULTIST
	late_role = CULTIST
	desc = "A group of shady blood-obsessed individuals whose souls are devoted to Nar-Sie, the Geometer of Blood.\
	From his teachings, they were granted the ability to perform blood magic rituals allowing them to fight and grow their ranks, and given the goal of pushing his agenda.\
	Nar-Sie's goal is to tear open a breach through reality so he can pull the station into his realm and feast on the crew's blood and souls."
	roletype = /datum/role/cultist
	logo_state = "cult-logo"
	var/list/bloody_floors = list()//to replace later on
	hud_icons = list("cult-logo")

/datum/faction/bloodcult/AdminPanelEntry(var/datum/admins/A)
	var/list/dat = ..()
	dat += "<br><a href='?src=\ref[A];cult_mindspeak=\ref[src]'>Voice of Nar-Sie</a>"
	return dat

/datum/faction/bloodcult/HandleNewMind(var/datum/mind/M)
	..()
	M.special_role = "Cultist"

/datum/faction/bloodcult/OnPostSetup()
	for(var/datum/role/R in members)
		R.OnPostSetup(FALSE)
	initialize_cultwords()

//to recode later on
/datum/faction/bloodcult/proc/is_sacrifice_target(var/datum/mind/M)
/*
	for(var/datum/objective/target/sacrifice/S in GetObjectives())
		if(S.target == M)
			return TRUE
			*/
	return FALSE

/proc/is_convertable_to_cult(datum/mind/mind)
	if(!istype(mind))
		return 0
	if(ishuman(mind.current) && (mind.assigned_role == "Chaplain"))
		return 0
	for(var/obj/item/weapon/implant/loyalty/L in mind.current)
		if(L.imp_in == mind.current)//Checks to see if the person contains an implant, then checks that the implant is actually inside of them
			return 0
	return 1

//When cultists need to pay in blood to use their spells, they have a few options at their disposal:
// * If their hands are bloody, they can use the few units of blood on them.
// * If there is a blood splatter on the ground that still has a certain amount of fresh blood in it, they can use that?
// * If they are grabbing another person, they can stab their nails in their vessels to draw some blood from them
// * If they are standing above a bleeding person, they can dip their fingers into their wounds.
// * If they are holding a container that has blood in it (such as a beaker or a blood pack), they can pour/squeeze blood from them
// * If they are standing above a container that has blood in it, they can dip their fingers into them
// * Finally if there are no alternative blood sources, you can always use your own blood.

/proc/get_available_blood(var/mob/user, var/amount_needed = 0)
	var/data = list(
		BLOODCOST_TARGET_BLEEDER = null,
		BLOODCOST_AMOUNT_BLEEDER = 0,
		BLOODCOST_TARGET_GRAB = null,
		BLOODCOST_AMOUNT_GRAB = 0,
		BLOODCOST_TARGET_HANDS = null,
		BLOODCOST_AMOUNT_HANDS = 0,
		BLOODCOST_TARGET_HELD = null,
		BLOODCOST_AMOUNT_HELD = 0,
		BLOODCOST_LID_HELD = 0,
		BLOODCOST_TARGET_SPLATTER = null,
		BLOODCOST_AMOUNT_SPLATTER = 0,
		BLOODCOST_TARGET_BLOODPACK = null,
		BLOODCOST_AMOUNT_BLOODPACK = 0,
		BLOODCOST_HOLES_BLOODPACK = 0,
		BLOODCOST_TARGET_CONTAINER = null,
		BLOODCOST_AMOUNT_CONTAINER = 0,
		BLOODCOST_LID_CONTAINER = 0,
		BLOODCOST_TARGET_USER = null,
		BLOODCOST_AMOUNT_USER = 0,
		BLOODCOST_RESULT = "",
		BLOODCOST_TOTAL = 0,
		)
	var/turf/T = get_turf(user)
	var/amount_gathered = 0

	//Is there blood on our hands?
	var/mob/living/carbon/human/H_user = user
	if (istype (H_user) && H_user.bloody_hands)
		data[BLOODCOST_TARGET_HANDS] = H_user
		var/blood_gathered = min(amount_needed,H_user.bloody_hands)
		data[BLOODCOST_AMOUNT_HANDS] = blood_gathered
		amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_HANDS
		return data

	//Is there a fresh blood splatter on the turf?
	for (var/obj/effect/decal/cleanable/blood/B in T)
		var/blood_volume = B.amount
		if (blood_volume && B.counts_as_blood)
			data[BLOODCOST_TARGET_SPLATTER] = B
			var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
			data[BLOODCOST_AMOUNT_SPLATTER] = blood_gathered
			amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_SPLATTER
		return data

	//Is the cultist currently grabbing a bleeding mob/corpse that still has blood in it?
	var/obj/item/weapon/grab/Grab = locate() in user
	if (Grab)
		if(ishuman(Grab.affecting))
			var/mob/living/carbon/human/H = Grab.affecting
			for(var/datum/organ/external/org in H.organs)
				if(org.status & ORGAN_BLEEDING)
					var/blood_volume = round(H.vessel.get_reagent_amount(BLOOD))
					var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
					data[BLOODCOST_TARGET_GRAB] = H
					data[BLOODCOST_AMOUNT_GRAB] = blood_gathered
					amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_GRAB
		return data

	//Is there a bleeding mob/corpse on the turf that still has blood in it?
	for (var/mob/living/carbon/human/H in T)
		if(user != H)
			for(var/datum/organ/external/org in H.organs)
				if(org.status & ORGAN_BLEEDING)
					var/blood_volume = round(H.vessel.get_reagent_amount(BLOOD))
					var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
					data[BLOODCOST_TARGET_BLEEDER] = H
					data[BLOODCOST_AMOUNT_BLEEDER] = blood_gathered
					amount_gathered += blood_gathered
					break
		if (data[BLOODCOST_TARGET_BLEEDER])
			break

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_BLEEDER
		return data


	var/obj/item/weapon/reagent_containers/G_held = H_user.get_active_hand()
	if (!istype(G_held) || !round(G_held.reagents.get_reagent_amount(BLOOD)))
		G_held = H_user.get_inactive_hand()

	if (istype(G_held))
		var/blood_volume = round(G_held.reagents.get_reagent_amount(BLOOD))
		if (blood_volume)
			data[BLOODCOST_TARGET_HELD] = G_held
			if (G_held.is_open_container())
				var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
				data[BLOODCOST_AMOUNT_HELD] = blood_gathered
				amount_gathered += blood_gathered
			else
				data[BLOODCOST_LID_HELD] = 1

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_HELD
		return data

	var/obj/item/weapon/reagent_containers/blood/blood_pack = H_user.get_active_hand()
	if (!istype(blood_pack) || !round(blood_pack.reagents.get_reagent_amount(BLOOD)))
		blood_pack = H_user.get_inactive_hand()

	if (istype(blood_pack))
		var/blood_volume = round(blood_pack.reagents.get_reagent_amount(BLOOD))
		if (blood_volume)
			data[BLOODCOST_TARGET_BLOODPACK] = blood_pack
			if (blood_pack.holes)
				var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
				data[BLOODCOST_AMOUNT_BLOODPACK] = blood_gathered
				amount_gathered += blood_gathered
			else
				data[BLOODCOST_HOLES_BLOODPACK] = 1

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_BLOODPACK
		return data


	//Is there a reagent container on the turf that has blood in it?
	for (var/obj/item/weapon/reagent_containers/G in T)
		var/blood_volume = round(G.reagents.get_reagent_amount(BLOOD))
		if (blood_volume)
			data[BLOODCOST_TARGET_CONTAINER] = G
			if (G.is_open_container())
				var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
				data[BLOODCOST_AMOUNT_CONTAINER] = blood_gathered
				amount_gathered += blood_gathered
				break
			else
				data[BLOODCOST_LID_CONTAINER] = 1

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_CONTAINER
		return data

	//Does the user have blood? (the user can pay in blood without having to bleed first)
	var/mob/living/carbon/human/H = user
	if (istype (H))
		var/blood_volume = round(H.vessel.get_reagent_amount(BLOOD))
		var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
		data[BLOODCOST_TARGET_USER] = H
		data[BLOODCOST_AMOUNT_USER] = blood_gathered
		amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_USER
		return data

	data[BLOODCOST_RESULT] = BLOODCOST_FAILURE
	return data


/proc/use_available_blood(var/mob/user, var/amount_needed = 0,var/previous_result = "")
	//Getting nearby blood sources
	var/list/data = get_available_blood(user, amount_needed)

	var/datum/reagent/blood/blood

	//Flavour text and blood data transfer
	switch (data[BLOODCOST_RESULT])
		if (BLOODCOST_TARGET_HANDS)
			var/mob/living/carbon/human/H = user
			blood = new()
			blood.data["blood_colour"] = H.hand_blood_color
			blood.data["blood_DNA"] = H.blood_DNA
			if (previous_result != BLOODCOST_TARGET_HANDS)
				user.visible_message("<span class='warning'>The blood on \the [user]'s hands drips onto the floor!</span>",
									"<span class='rose'>You let the blood smeared on your hands join the pool of your summoning.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_SPLATTER)
			var/obj/effect/decal/cleanable/blood/B = data[BLOODCOST_TARGET_SPLATTER]
			blood = new()
			blood.data["blood_colour"] = B.basecolor
			blood.data["blood_DNA"] = B.blood_DNA
			blood.data["virus2"] = B.virus2
			if (previous_result != BLOODCOST_TARGET_SPLATTER)
				user.visible_message("<span class='warning'>The blood on the floor bellow \the [user] starts moving!</span>",
									"<span class='rose'>You redirect the flow of blood inside the splatters on the floor toward the pool of your summoning.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_GRAB)
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_GRAB]
			blood = get_blood(H.vessel)
			if (previous_result != BLOODCOST_TARGET_GRAB)
				user.visible_message("<span class='warning'>\The [user] stabs their nails inside \the [data[BLOODCOST_TARGET_GRAB]], drawing blood from them!</span>",
									"<span class='rose'>You stab your nails inside \the [data[BLOODCOST_TARGET_GRAB]] to draw some blood from them.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_BLEEDER)
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_BLEEDER]
			blood = get_blood(H.vessel)
			if (previous_result != BLOODCOST_TARGET_BLEEDER)
				user.visible_message("<span class='warning'>\The [user] dips their fingers inside \the [data[BLOODCOST_TARGET_BLEEDER]]'s wounds!</span>",
									"<span class='rose'>You dip your fingers inside \the [data[BLOODCOST_TARGET_BLEEDER]]'s wounds to draw some blood from them.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_HELD)
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_HELD]
			blood = locate() in G.reagents.reagent_list
			if (previous_result != BLOODCOST_TARGET_HELD)
				user.visible_message("<span class='warning'>\The [user] tips \the [data[BLOODCOST_TARGET_HELD]], pouring blood!</span>",
									"<span class='rose'>You tip \the [data[BLOODCOST_TARGET_HELD]] to pour the blood contained inside.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_BLOODPACK)
			var/obj/item/weapon/reagent_containers/blood/B = data[BLOODCOST_TARGET_BLOODPACK]
			blood = locate() in B.reagents.reagent_list
			if (previous_result != BLOODCOST_TARGET_BLOODPACK)
				user.visible_message("<span class='warning'>\The [user] squeezes \the [data[BLOODCOST_TARGET_BLOODPACK]], pouring blood!</span>",
									"<span class='rose'>You squeeze \the [data[BLOODCOST_TARGET_BLOODPACK]] to pour the blood contained inside.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_CONTAINER)
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_CONTAINER]
			blood = locate() in G.reagents.reagent_list
			if (previous_result != BLOODCOST_TARGET_CONTAINER)
				user.visible_message("<span class='warning'>\The [user] dips their fingers inside \the [data[BLOODCOST_TARGET_CONTAINER]], covering them in blood!</span>",
									"<span class='rose'>You dip your fingers inside \the [data[BLOODCOST_TARGET_CONTAINER]], covering them in blood.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_USER)
			if (data[BLOODCOST_HOLES_BLOODPACK])
				to_chat(user, "<span class='warning'>You must puncture \the [data[BLOODCOST_TARGET_BLOODPACK]] before you can squeeze blood from it!</span>")
			else if (data[BLOODCOST_LID_HELD])
				to_chat(user, "<span class='warning'>Remove \the [data[BLOODCOST_TARGET_HELD]]'s lid first!</span>")
			else if (data[BLOODCOST_LID_CONTAINER])
				to_chat(user, "<span class='warning'>Remove \the [data[BLOODCOST_TARGET_CONTAINER]]'s lid first!</span>")
			var/mob/living/carbon/human/H = user
			blood = get_blood(H.vessel)
			if (previous_result != BLOODCOST_TARGET_USER)
				if(istype(H))
					var/obj/item/weapon/W = H.get_active_hand()
					if (W && W.sharpness_flags & SHARP_BLADE)
						to_chat(user, "<span class='rose'>You slice open your finger with \the [W] to let a bit of blood flow.</span>")
					else
						var/obj/item/weapon/W2 = H.get_inactive_hand()
						if (W2 && W2.sharpness_flags & SHARP_BLADE)
							to_chat(user, "<span class='rose'>You slice open your finger with \the [W] to let a bit of blood flow.</span>")
						else
							to_chat(user, "<span class='rose'>You bite your finger and let the blood pearl up.</span>")
		if (BLOODCOST_FAILURE)
			if (data[BLOODCOST_HOLES_BLOODPACK])
				to_chat(user, "<span class='danger'>You must puncture \the [data[BLOODCOST_TARGET_BLOODPACK]] before you can squeeze blood from it!</span>")
			else if (data[BLOODCOST_LID_HELD])
				to_chat(user, "<span class='danger'>Remove \the [data[BLOODCOST_TARGET_HELD]]'s lid first!</span>")
			else if (data[BLOODCOST_LID_CONTAINER])
				to_chat(user, "<span class='danger'>Remove \the [data[BLOODCOST_TARGET_HELD]]'s lid first!</span>")
			else
				to_chat(user, "<span class='danger'>There is no blood available. Not even in your own body!</span>")

	//Blood is only consumed if there is enough of it
	if (!data[BLOODCOST_FAILURE])
		if (data[BLOODCOST_TARGET_HANDS])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_HANDS]
			var/mob/living/carbon/human/H = user
			H.bloody_hands = max(0, H.bloody_hands - data[BLOODCOST_AMOUNT_HANDS])
			if (!H.bloody_hands)
				H.clean_blood()
				H.update_inv_gloves()
		if (data[BLOODCOST_TARGET_SPLATTER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_SPLATTER]
			var/obj/effect/decal/cleanable/blood/B = data[BLOODCOST_TARGET_SPLATTER]
			B.amount = max(0 , B.amount - data[BLOODCOST_AMOUNT_SPLATTER])
		if (data[BLOODCOST_TARGET_GRAB])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_GRAB]
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_GRAB]
			H.vessel.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_GRAB])
			H.take_overall_damage(data[BLOODCOST_AMOUNT_GRAB] ? 0.1 : 0)
		if (data[BLOODCOST_TARGET_BLEEDER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_BLEEDER]
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_BLEEDER]
			H.vessel.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_BLEEDER])
			H.take_overall_damage(data[BLOODCOST_AMOUNT_BLEEDER] ? 0.1 : 0)
		if (data[BLOODCOST_TARGET_HELD])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_HELD]
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_HELD]
			G.reagents.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_HELD])
		if (data[BLOODCOST_TARGET_CONTAINER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_CONTAINER]
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_CONTAINER]
			G.reagents.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_CONTAINER])
		if (data[BLOODCOST_TARGET_USER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_USER]
			var/mob/living/carbon/human/H = user
			var/blood_before = H.vessel.get_reagent_amount(BLOOD)
			H.vessel.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_USER])
			var/blood_after = H.vessel.get_reagent_amount(BLOOD)
			if (blood_before > BLOOD_VOLUME_SAFE && blood_after < BLOOD_VOLUME_SAFE)
				to_chat(user, "<span class='sinister'>You start looking pale.</span>")
			else if (blood_before > BLOOD_VOLUME_WARN && blood_after < BLOOD_VOLUME_WARN)
				to_chat(user, "<span class='sinister'>You feel weak from the lack of blood.</span>")
			else if (blood_before > BLOOD_VOLUME_OKAY && blood_after < BLOOD_VOLUME_OKAY)
				to_chat(user, "<span class='sinister'>You are about to pass out from the lack of blood.</span>")
			else if (blood_before > BLOOD_VOLUME_BAD && blood_after < BLOOD_VOLUME_BAD)
				to_chat(user, "<span class='sinister'>You have trouble focusing, things will go bad if you keep using your blood.</span>")
			else if (blood_before > BLOOD_VOLUME_SURVIVE && blood_after < BLOOD_VOLUME_SURVIVE)
				to_chat(user, "<span class='sinister'>It will be all over soon.</span>")
			H.take_overall_damage(data[BLOODCOST_AMOUNT_USER] ? 0.1 : 0)

	data["blood"] = blood
	return data


/obj/item/proc/get_cult_power()
	return 0

var/static/list/valid_cultpower_slots = list(
	slot_wear_suit,
	slot_head,
	slot_shoes,
	)//might add more slots later as I add more items that could fit in them

/mob/proc/get_cult_power()
	var/power = 0
	for (var/slot in valid_cultpower_slots)
		var/obj/item/I = get_item_by_slot(slot)
		if (istype(I))
			power += I.get_cult_power()

	return power
