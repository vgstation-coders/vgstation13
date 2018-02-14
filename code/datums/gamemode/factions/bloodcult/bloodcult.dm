//CULT 3.0 BY DEITY LINK (2018)
//BASED ON THE ORIGINAL GAME MODE BY URIST MCDORF

/datum/faction/bloodcult
	name = "Cult of Nar-Sie"
	ID = BLOODCULT
	initial_role = CULTIST
	late_role = CULTIST
	desc = "A group of shady blood-obsessed individuals whose souls are devoted to Nar-Sie, the Geometer of Blood.\
	From his teachings, they were granted the ability to perform blood magic rituals allowing them to fight and grow their ranks, and given the goal of pushing his agenda.\
	Nar-Sie's goal is to tear open a breach through reality so he can pull the station into his realm and feast on the crew's blood and souls."
	roletype = /datum/role/cultist
	var/list/bloody_floors = list()//to replace later on

/datum/faction/bloodcult/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/mob/mob.dmi', "cult-logo")
	var/header = {"<BR><img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Cult of Nar-Sie</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

/datum/faction/bloodcult/AdminPanelEntry()
	var/list/dat = ..()
	dat += "<a href='?_src_=holder;cult_mindspeak=\ref[src]'>Voice of Nar-Sie</a>"
	return dat

/datum/faction/bloodcult/HandleNewMind(var/datum/mind/M)
	..()
	M.special_role = "Cultist"

/datum/faction/bloodcult/OnPostSetup()
	..()
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
//TODO: include warnings when victims or the user go pale from excessive blood payment.

/proc/get_available_blood(var/mob/user, var/amount_needed = 0)
	var/data = list(
		"bleeder" = null,
		"bleeder_amount" = 0,
		"grabbed" = null,
		"grabbed_amount" = 0,
		"hands" = null,
		"hands_amount" = 0,
		"held" = null,
		"held_amount" = 0,
		"held_lid" = 0,
		"splatter" = null,
		"splatter_amount" = 0,
		"bloodpack" = null,
		"bloodpack_amount" = 0,
		"bloodpack_noholes" = 0,
		"container" = null,
		"container_amount" = 0,
		"container_lid" = 0,
		"user" = null,
		"user_amount" = 0,
		"result" = "",
		)
	var/turf/T = get_turf(user)
	var/amount_gathered = 0

	//Is there blood on our hands?
	var/mob/living/carbon/human/H_user = user
	if (istype (H_user) && H_user.bloody_hands)
		data["hands"] = H_user
		var/blood_gathered = min(amount_needed,H_user.bloody_hands)
		data["hands_amount"] = blood_gathered
		amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data["result"] = "hands"
		return data

	//Is there a fresh blood splatter on the turf?
	for (var/obj/effect/decal/cleanable/blood/B in T)
		var/blood_volume = B.amount
		if (blood_volume && B.counts_as_blood)
			data["splatter"] = B
			var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
			data["splatter_amount"] = blood_gathered
			amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data["result"] = "splatter"
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
					data["grabbed"] = H
					data["grabbed_amount"] = blood_gathered
					amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data["result"] = "grabbed"
		return data

	//Is there a bleeding mob/corpse on the turf that still has blood in it?
	for (var/mob/living/carbon/human/H in T)
		if(user != H)
			for(var/datum/organ/external/org in H.organs)
				if(org.status & ORGAN_BLEEDING)
					var/blood_volume = round(H.vessel.get_reagent_amount(BLOOD))
					var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
					data["bleeder"] = H
					data["bleeder_amount"] = blood_gathered
					amount_gathered += blood_gathered
					break
		if (data["bleeder"])
			break

	if (amount_gathered >= amount_needed)
		data["result"] = "bleeder"
		return data


	var/obj/item/weapon/reagent_containers/glass/G_held = H_user.get_active_hand()
	if (!istype(G_held) || !round(G_held.reagents.get_reagent_amount(BLOOD)))
		G_held = H_user.get_inactive_hand()

	if (istype(G_held))
		var/blood_volume = round(G_held.reagents.get_reagent_amount(BLOOD))
		if (blood_volume)
			data["held"] = G_held
			if (G_held.is_open_container())
				var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
				data["held_amount"] = blood_gathered
				amount_gathered += blood_gathered
			else
				data["held_lid"] = 1

	if (amount_gathered >= amount_needed)
		data["result"] = "held"
		return data

	var/obj/item/weapon/reagent_containers/blood/blood_pack = H_user.get_active_hand()
	if (!istype(blood_pack) || !round(blood_pack.reagents.get_reagent_amount(BLOOD)))
		blood_pack = H_user.get_inactive_hand()

	if (istype(blood_pack))
		var/blood_volume = round(blood_pack.reagents.get_reagent_amount(BLOOD))
		if (blood_volume)
			data["bloodpack"] = blood_pack
			if (blood_pack.holes)
				var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
				data["bloodpack_amount"] = blood_gathered
				amount_gathered += blood_gathered
			else
				data["bloodpack_noholes"] = 1

	if (amount_gathered >= amount_needed)
		data["result"] = "bloodpack"
		return data


	//Is there a reagent container on the turf that has blood in it?
	for (var/obj/item/weapon/reagent_containers/glass/G in T)
		var/blood_volume = round(G.reagents.get_reagent_amount(BLOOD))
		if (blood_volume)
			data["container"] = G
			if (G.is_open_container())
				var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
				data["container_amount"] = blood_gathered
				amount_gathered += blood_gathered
				break
			else
				data["container_lid"] = 1

	if (amount_gathered >= amount_needed)
		data["result"] = "container"
		return data

	//Does the user have blood? (the user can pay in blood without having to bleed first)
	var/mob/living/carbon/human/H = user
	if (istype (H))
		var/blood_volume = round(H.vessel.get_reagent_amount(BLOOD))
		var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
		data["user"] = H
		data["user_amount"] = blood_gathered
		amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data["result"] = "user"
		return data

	data["result"] = "failure"
	return data


/proc/use_available_blood(var/mob/user, var/amount_needed = 0,var/previous_result = "")
	//Getting nearby blood sources
	var/list/data = get_available_blood(user, amount_needed)

	var/datum/reagent/blood/blood

	//Flavour text and blood data transfer
	switch (data["result"])
		if ("hands")
			var/mob/living/carbon/human/H = user
			blood = new()
			blood.data["blood_colour"] = H.hand_blood_color
			blood.data["blood_DNA"] = H.blood_DNA
			if (previous_result != "user")
				user.visible_message("<span class='warning'>The blood on \the [user]'s hands drips onto the floor!</span>",
									"<span class='rose'>You let the blood smeared on your hands join the pool of your summoning.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if ("splatter")
			var/obj/effect/decal/cleanable/blood/B = data["splatter"]
			blood = new()
			blood.data["blood_colour"] = B.basecolor
			blood.data["blood_DNA"] = B.blood_DNA
			blood.data["virus2"] = B.virus2
			if (previous_result != "user")
				user.visible_message("<span class='warning'>The blood on the floor bellow \the [user] starts moving!</span>",
									"<span class='rose'>You redirect the flow of blood inside the splatters on the floor toward the pool of your summoning.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if ("grabbed")
			var/mob/living/carbon/human/H = data["grabbed"]
			blood = get_blood(H.vessel)
			if (previous_result != "user")
				user.visible_message("<span class='warning'>\The [user] stabs their nails inside \the [data["grabbed"]], drawing blood from them!</span>",
									"<span class='rose'>You stab your nails inside \the [data["grabbed"]] to draw some blood from them.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if ("bleeder")
			var/mob/living/carbon/human/H = data["bleeder"]
			blood = get_blood(H.vessel)
			if (previous_result != "user")
				user.visible_message("<span class='warning'>\The [user] dips their fingers inside \the [data["bleeder"]]'s wounds!</span>",
									"<span class='rose'>You dip your fingers inside \the [data["bleeder"]]'s wounds to draw some blood from them.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if ("held")
			var/obj/item/weapon/reagent_containers/glass/G = data["held"]
			blood = locate() in G.reagents.reagent_list
			if (previous_result != "user")
				user.visible_message("<span class='warning'>\The [user] tips \the [data["held"]], pouring blood!</span>",
									"<span class='rose'>You tip \the [data["held"]] to pour the blood contained inside.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if ("bloodpack")
			var/obj/item/weapon/reagent_containers/blood/B = data["bloodpack"]
			blood = locate() in B.reagents.reagent_list
			if (previous_result != "user")
				user.visible_message("<span class='warning'>\The [user] squeezes \the [data["bloodpack"]], pouring blood!</span>",
									"<span class='rose'>You squeeze \the [data["bloodpack"]] to pour the blood contained inside.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if ("container")
			var/obj/item/weapon/reagent_containers/glass/G = data["container"]
			blood = locate() in G.reagents.reagent_list
			if (previous_result != "user")
				user.visible_message("<span class='warning'>\The [user] dips their fingers inside \the [data["container"]], covering them in blood!</span>",
									"<span class='rose'>You dip your fingers inside \the [data["container"]], covering them in blood.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if ("user")
			if (data["bloodpack_noholes"])
				to_chat(user, "<span class='warning'>You must puncture \the [data["bloodpack"]] before you can squeeze blood from it!</span>")
			else if (data["held_lid"])
				to_chat(user, "<span class='warning'>Remove \the [data["held"]]'s lid first!</span>")
			else if (data["container_lid"])
				to_chat(user, "<span class='warning'>Remove \the [data["held"]]'s lid first!</span>")
			var/mob/living/carbon/human/H = user
			blood = get_blood(H.vessel)
			if (previous_result != "user")
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
		if ("failure")
			if (data["bloodpack_noholes"])
				to_chat(user, "<span class='danger'>You must puncture \the [data["bloodpack"]] before you can squeeze blood from it!</span>")
			else if (data["held_lid"])
				to_chat(user, "<span class='danger'>Remove \the [data["held"]]'s lid first!</span>")
			else if (data["container_lid"])
				to_chat(user, "<span class='danger'>Remove \the [data["held"]]'s lid first!</span>")
			else
				to_chat(user, "<span class='danger'>There is no blood available. Not even in your own body!</span>")

	//Blood is only consumed if there is enough of it
	if (!data["failure"])
		if (data["hands"])
			var/mob/living/carbon/human/H = user
			H.bloody_hands = max(0, H.bloody_hands - data["hands_amount"])
			if (!H.bloody_hands)
				H.clean_blood()
				H.update_inv_gloves()
		if (data["splatter"])
			var/obj/effect/decal/cleanable/blood/B = data["splatter"]
			B.amount = max(0 , B.amount - data["splatter_amount"])
		if (data["grabbed"])
			var/mob/living/carbon/human/H = data["grabbed"]
			H.vessel.remove_reagent(BLOOD, data["grabbed_amount"])
			H.take_overall_damage(data["grabbed_amount"] ? 0.1 : 0)
		if (data["bleeder"])
			var/mob/living/carbon/human/H = data["bleeder"]
			H.vessel.remove_reagent(BLOOD, data["bleeder_amount"])
			H.take_overall_damage(data["bleeder_amount"] ? 0.1 : 0)
		if (data["held"])
			var/obj/item/weapon/reagent_containers/glass/G = data["held"]
			G.reagents.remove_reagent(BLOOD, data["held_amount"])
		if (data["container"])
			var/obj/item/weapon/reagent_containers/glass/G = data["container"]
			G.reagents.remove_reagent(BLOOD, data["container_amount"])
		if (data["user"])
			var/mob/living/carbon/human/H = user
			H.vessel.remove_reagent(BLOOD, data["user_amount"])
			H.take_overall_damage(data["user_amount"] ? 0.1 : 0)

	data["blood"] = blood
	return data
