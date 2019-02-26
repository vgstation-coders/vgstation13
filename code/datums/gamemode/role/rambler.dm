/datum/role/rambler
	name = RAMBLER
	id = RAMBLER
	required_pref = ROLE_MINOR
	special_role = RAMBLER
	logo_state = "rambler-logo"
	wikiroute = ROLE_MINOR

/datum/role/rambler/OnPostSetup()
	. =..()
	if(ishuman(antag.current))
		equip_rambler(antag.current)
		name_rambler(antag.current)

/datum/role/rambler/ForgeObjectives()
	AppendObjective(/datum/objective/investigate)
	AppendObjective(/datum/objective/freeform/ponder)
	AppendObjective(/datum/objective/ramble)

/datum/role/rambler/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='info'>[custom]</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='info'><B>You are a Soul Rambler.</B><BR>You wander space, looking for the man who killed your closest friend. And, perhaps, seeking answers to less tangible questions about life. If you happen to help people along the way, so be it.</span>")

	to_chat(antag.current, "<span class='danger'>You have no powers, except the power to blow minds. Your shakashuri can be used to pacify spirits, but you will otherwise need to rely on your weapons-grade philosophical insights.</span>")

/obj/item/device/instrument/recorder/shakashuri
	name = "Shakashuri"
	desc = "Similar to other woodwinds, though it can be played only by a true rambler of souls."
	slot_flags = SLOT_BACK

/obj/item/device/instrument/recorder/shakashuri/attack_self(mob/user)
	if(!isrambler(user))
		to_chat(user,"<span class='warning'>Playing this would require 9 years of training!</span>")
		return
	else
		..()

/obj/item/device/instrument/recorder/shakashuri/OnPlayed(mob/user,mob/M)
	if(user!=M)
		M.reagents.add_reagent(CHILLWAX,0.3)

/obj/item/weapon/reagent_containers/food/snacks/quiche/frittata/New()
	..()
	name = "frittata"
	desc = "Now you have no need to eat balls for breakfast."
	reagents.add_reagent(DOCTORSDELIGHT,37)

/obj/item/clothing/mask/necklace/crystal
	name = "crystal necklace"
	desc = "Your final momento of a lost friend. Use it to decide on the killer."
	icon_state = "tooth-necklace"
	var/mob/living/suspect = null

/obj/item/clothing/mask/necklace/crystal/attack_self(mob/user)
	suspect = input(user, "Choose your suspect, from those whose voices you've heard before.", "Soul Inspiration") as null|mob in user.mind.heard_before

/obj/item/clothing/mask/necklace/crystal/examine(mob/user)
	..()
	if(isrambler(user))
		to_chat(user, "<span class='notice'>Your current suspect is [suspect ? suspect : "no one"].</span>")

/proc/equip_rambler(var/mob/living/carbon/human/H)
	if(!istype(H))
		return 0
	H.delete_all_equipped_items()
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/necklace/crystal, slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white, slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/device/instrument/recorder/shakashuri, slot_back)
	H.put_in_hands(new /obj/item/weapon/reagent_containers/food/snacks/quiche/frittata(get_turf(H)))

/proc/name_rambler(var/mob/living/carbon/human/H)
	var/randomname = pick("Xavier","Renegade","Angel")
	spawn(0)
		var/newname = copytext(sanitize(input(H, "You are on a soul journey. Would you like to change your name to something else?", randomname, randomname) as null|text),1,MAX_NAME_LEN)

		if (!newname)
			newname = randomname

		H.fully_replace_character_name(H.real_name, newname)

//Ramblers cannot wear anything over any part of their torso.
/obj/item/clothing/proc/rambler_check(mob/user)
	if(isrambler(user) && body_parts_covered & FULL_TORSO)
		to_chat(user,"<span class='warning'>Part of being a soul rambler is freedom. The freedom for flesh to breathe with the breeze.</span>")
		return FALSE
	else
		return TRUE