/datum/role/eet
	name = EET
	id = EET
	required_pref = ROLE_MINOR
	logo_state = "eet-logo"
	wikiroute = ROLE_MINOR
	var/hostile = FALSE
	var/list/poss_objective = list(/datum/objective/eet/books,/datum/objective/eet/food,/datum/objective/eet/banking,
								/datum/objective/eet/seeds,/datum/objective/eet/organ,/datum/objective/eet/seeds,
								/datum/objective/eet/religion,/datum/objective/eet/vacation,/datum/objective/eet/implant,
								/datum/objective/eet/organs)
	var/list/danger_objective = list(/datum/objective/eet/virus,/datum/objective/eet/data)
	var/peaceful = TRUE

/datum/role/eet/OnPostSetup()
	..()
	if(prob(50))
		peaceful = FALSE
	var/mob/living/carbon/human/H = antag.current
	H.set_species("Grey", force_organs=1)
	equip_eet(H)
	H.regenerate_icons()
	H.forceMove(eet_cont.loc)
	H.languages = list()
	H.add_language(LANGUAGE_GREY)
	H.default_language = LANGUAGE_GREY

/proc/equip_eet(var/mob/living/carbon/human/H)
	if(!istype(H))
		return
	H.delete_all_equipped_items()
	H.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple, slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/grey, slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/grey, slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots, slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/latex, slot_gloves)

	var/obj/item/weapon/card/id/ID = new(H)
	ID.assignment = "Assignment"
	H.equip_to_slot_or_del(ID, slot_wear_id)

/datum/role/eet/ForgeObjectives()
	var/list/objectives = poss_objective.Copy()
	if(hostile)
		objectives += danger_objective.Copy()
	for(var/i = 1 to 2)
		SelectObjective(pick_n_take(objectives))

/datum/role/eet/proc/SelectObjective(var/O) //Let O be an objective path
	if(!ispath(O))
		return
	AppendObjective(O)
	switch(O)
		if(/datum/objective/eet/religion)
			if(!eet_rel && eet_rel.religiousLeader)
				eet_rel = new /datum/religion/monolith
				eet_rel.holy_book = new eet_rel.bible_type
				eet_rel.holy_book.name = eet_rel.bible_name
				eet_rel.holy_book.my_rel = eet_rel
				eet_rel.activate(antag.current)
			else
				var/mob/living/carbon/C = antag.current
				var/obj/item/weapon/storage/bible/B = new
				B.icon_state = eet_rel.holy_book.icon_state
				B.item_state = eet_rel.holy_book.item_state
				B.name = eet_rel.bible_name
				B.my_rel = eet_rel
				C.put_in_hands(B)
				to_chat(antag.current,"<span class='good'>[eet_rel.religiousLeader] leads the Monolith faith and must handle conversions. You may assume leadership by using the Continuum if the old leader's mind is returned to it.</span>")

/datum/role/eet/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if(GREET_PEET)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='info'><font size='3'>You are a PEET, a Peaceful Enigmatic Extraterrestrial!</font></span>")
			to_chat(antag.current, "<B><span class='warning'>You are under normal rules regarding escalation and violence.</warning></B> <span class='info'>Complete your objectives peacefully or not at all.</span>")

		if(GREET_HEET)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'><font size='3'>You are a HEET, a Hostile Enigmatic Extraterrestrial!</font></span>")
			to_chat(antag.current, "<B><span class='warning'>You are fully authorized to kill and destroy as necessary to complete your objectives.</warning></B>")
