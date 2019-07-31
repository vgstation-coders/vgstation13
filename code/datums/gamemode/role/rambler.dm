/datum/role/rambler
	name = RAMBLER
	id = RAMBLER
	required_pref = ROLE_MINOR
	special_role = RAMBLER
	logo_state = "rambler-logo"
	wikiroute = ROLE_MINOR
	var/remaining_vows = 3

/datum/role/rambler/OnPostSetup()
	. =..()
	if(ishuman(antag.current))
		equip_rambler(antag.current)
		name_rambler(antag.current)

/datum/role/rambler/ForgeObjectives()
	AppendObjective(/datum/objective/investigate)
	if(prob(10)) //Since Ramblers generate extra objectives from vows, let's not clog up the list too often
		AppendObjective(/datum/objective/freeform/ponder)
	AppendObjective(/datum/objective/ramble)

/datum/role/rambler/ShuttleDocked(state)
	if(state == 1)
		for(var/datum/objective/uphold_vow/O in objectives.GetObjectives())
			O.PollMind()

/datum/role/rambler/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='info'>[custom]</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='info'><B>You are a Soul Rambler.</B><BR>You wander space, looking for the one who killed your closest friend. And, perhaps, seeking answers to less tangible questions about life. If you happen to help people along the way, so be it.</span>")

	to_chat(antag.current, "<span class='warning'>You have no powers, except the power to blow minds. Your shakashuri can be used to pacify spirits, but you will otherwise need to rely on your weapons-grade philosophical insights.</span>")

/datum/role/rambler/can_wear(var/obj/item/clothing/C)
	if(istype(C,/obj/item/clothing/mask/breath))
		return ALWAYSTRUE
	if(C.body_parts_covered & FULL_TORSO)
		return FALSE //This previously had feedback but it would spam the user if they tried to quick equip
	else
		return TRUE


/obj/item/device/instrument/recorder/shakashuri
	name = "shakashuri"
	desc = "Similar to other woodwinds, though it can be played only by a true rambler of souls."
	slot_flags = SLOT_BACK

/obj/item/device/instrument/recorder/shakashuri/attack_self(mob/user)
	if(!isrambler(user))
		to_chat(user,"<span class='warning'>Playing this would require 9 years of training!</span>")
		return
	else
		..()

/obj/item/device/instrument/recorder/shakashuri/OnPlayed(mob/user,mob/M)
	if(user!=M && M.reagents && !M.reagents.has_reagent(CHILLWAX,1))
		M.reagents.add_reagent(CHILLWAX,0.3)

/obj/item/weapon/reagent_containers/food/snacks/quiche/frittata/New()
	..()
	name = "frittata"
	desc = "Now you have no need to eat balls for breakfast."
	reagents.add_reagent(DOCTORSDELIGHT,37)

/obj/item/clothing/mask/necklace/crystal
	name = "crystal necklace"
	desc = "Your final memento of a lost friend. Use it to decide on the killer."
	icon_state = "tooth-necklace"
	var/datum/mind/suspect = null

/obj/item/clothing/mask/necklace/crystal/attack_self(mob/user)
	if(!isrambler(user))
		return
	var/list/possible_choices = get_list_of_elements(user.mind.heard_before)
	if(!length(possible_choices))
		to_chat(user,"<span class='warning'>You haven't heard anyone talk.</span>")
		return
	var/mob/chosen_mob = input(user, "Choose your suspect, from those whose voices you've heard before.", "Soul Inspiration") as null|mob in possible_choices
	if(!chosen_mob)
		return
	if(!isliving(chosen_mob))
		to_chat(user,"<span class='warning'>That is some kind of ghost or something!</span>")
		return
	if(chosen_mob == user)
		to_chat(user,"<span class='warning'>You already know the crime was arson!</span>")
		return
	var/datum/mind/potential = chosen_mob.mind
	if(!potential)
		to_chat(user,"<span class='warning'>To accuse the mindless? The scrawling of a madman!</span>")
		return
	if(potential == suspect)
		to_chat(user,"<span class='warning'>It is just as you suspected. The suspect is the suspicious suspect you have already suspected!</span>")
		return
	to_chat(user,"<span class='info'>Your new suspect is [chosen_mob].</span>")
	suspect = potential

/obj/item/clothing/mask/necklace/crystal/examine(mob/user)
	..()
	if(isrambler(user))
		to_chat(user, "<span class='notice'>Your current suspect is [suspect ? suspect : "no one"].</span>")

/proc/equip_rambler(var/mob/living/carbon/human/frankenstein/H)
	var/mob/living/carbon/human/frankenstein/F
	//If we are a Frankenstein, continue. If we're human, frankensteinize. If not human, abort.
	if(!istype(H))
		if(ishuman(H))
			F = H.Frankensteinize()
		else
			return 0
	else
		F = H
	F.mutations += M_NO_BREATH
	F.dna.SetSEState(NOBREATHBLOCK,1)
	F.add_spell(new /spell/targeted/lockinvow)
	F.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel, slot_back)
	F.equip_or_collect(new /obj/item/clothing/mask/necklace/crystal, slot_wear_mask)
	F.equip_or_collect(new /obj/item/clothing/shoes/white, slot_shoes)
	F.put_in_hands(new /obj/item/device/instrument/recorder/shakashuri)
	F.equip_or_collect(new /obj/item/weapon/reagent_containers/food/snacks/quiche/frittata, slot_in_backpack)

/proc/name_rambler(var/mob/living/carbon/human/H)
	var/randomname = pick("Xavier","Renegade","Angel")
	spawn(0)
		var/newname = copytext(sanitize(input(H, "You are on a soul journey. Would you like to change your name to something else?", randomname, randomname) as null|text),1,MAX_NAME_LEN)

		if (!newname)
			newname = randomname

		H.fully_replace_character_name(H.real_name, newname)

/spell/targeted/lockinvow
	name = "Lock in Vow"
	desc = "Allows you to vow to another soul."
	abbreviation = "LV"
	charge_max = 100
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK
	compatible_mobs = list(/mob/living)
	hud_state = "rambler-vow"

/spell/targeted/lockinvow/cast(list/targets, mob/user = user)
	..()
	var/datum/role/rambler/R = user.mind.GetRole(RAMBLER)
	if(!istype(R))
		return
	for(var/mob/living/target in targets)
		if(!target.mind)
			to_chat(user,"<span class='warning'>[target] has no mind!</span>")
			continue
		var/vow = copytext(sanitize(input(user, "Enter your vow. You have [R.remaining_vows] left.", "VOW LOCK IN") as null|text),1,MAX_MESSAGE_LEN)
		if(vow)
			user.say("[target], I vow [vow].")
			user.say("VOW LOCKED IN!")
			R.remaining_vows--
			if(!R.remaining_vows)
				for(var/spell/spell_to_remove in R.antag.current.spell_list)
					if(istype(spell_to_remove,/spell/targeted/lockinvow))
						R.antag.current.remove_spell(spell_to_remove)
			var/datum/objective/uphold_vow/O = new()
			O.target = target.mind
			O.vow_text = vow
			R.objectives.AddObjective(O,R.antag)
