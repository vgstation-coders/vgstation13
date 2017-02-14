//todo:
//ghost flickering + sprite
//ghosts spooking near happiest mask causing an immediate flickering
//the special stuff that happens when you get above 75 happiness

#define VERYHAPPY 75

#define HAPPIER 2
#define UNHAPPIER -10

/obj/item/clothing/mask/happy
	name = "Happiest Mask"
	desc = "<span class='sinister'>Yes, we can see you too.<span>"
	icon_state = "happiest"
	item_state = "happiest"
	clothing_flags = MASKINTERNALS
	body_parts_covered = FACE
	w_class = W_CLASS_SMALL
	siemens_coefficient = 3.0
	gas_transfer_coefficient = 0.90
	var/happiness = 10
	var/canemote = 1

/obj/item/clothing/mask/happy/New()
	..()
	visible_message("<span class='sinister'>We're just so very happy that you're here.<span>")

/obj/item/clothing/mask/happy/examine(mob/user as mob)
	..()
	var/mob/living/carbon/human/H = user
	if(istype(H) && H.wear_mask == src)
		var/adjective = "happy"
		switch(happiness)
			if(-100 to -20)
				adjective = "pissed off"
			if(-19 to 0)
				adjective = "unhappy"
			if(26 to 50)
				adjective = "joyful"
			if(51 to 100)
				adjective = "ecstatic"
		to_chat(user, "<span class='notice'>It has \an [adjective] expression.</span>")

/obj/item/clothing/mask/happy/equipped(M as mob, wear_mask)
	var/mob/living/carbon/human/H = M
	if(!istype(H))
		return
	if(H.wear_mask == src)
		flick("happiest_flash", src)
		to_chat(H, "<span class='warning'>Your thoughts are bombarded by incessant laughter.</span>\n<span class='sinister'>Oh joy! [H.real_name]'s decided to join the party!</span>")
		H << sound('sound/effects/hellclown.ogg')
		canremove = 0

/obj/item/clothing/mask/happy/attack_hand(mob/user as mob)
	if(user.wear_mask == src)
		flick("happiest_flash", src)
		to_chat(user, "<span class='sinister'>Why would you want to get rid of us, aren't you having fun?</span>")
		changehappiness(UNHAPPIER)
	else
		..()

/obj/item/clothing/mask/happy/pickup(mob/user as mob)
	flick("happiest_flash", src)
	to_chat(user, "<span class='warning'><B>The mask's eyesockets briefly flash with a foreboding red glare.</span></B>")

/obj/item/clothing/mask/happy/OnMobLife(var/mob/living/carbon/human/wearer)
	var/mob/living/carbon/human/W = wearer
	if(istype(W) && W.wear_mask == src)
		if(happiness <= 0)
			flick("happiest_flash", src)
			to_chat(W, "<span class='sinister'>It seems you're not being a very good friend to us. We definitely need to fire up this relationship!</span>")
			var/datum/organ/external/affecting = W.get_organ(LIMB_HEAD)
			if(affecting.take_damage(0, 20))
				W.UpdateDamageIcon(1)
			laugh(W)
			changehappiness(-UNHAPPIER)

		else if(happiness >= VERYHAPPY)
			//todo :)

		else
			if(prob(happiness/2))
				changehappiness(HAPPIER)
				flick("happiest_flash", src)
				W.say(pick("I'M SO HAPPY!", "SMILE!", "ISN'T EVERYTHING SO WONDERFUL?", "EVERYONE SHOULD SMILE!"))
				laugh(W)
				//need to add the ghost flickering

/obj/item/clothing/mask/happy/OnMobDeath(var/mob/living/carbon/human/wearer)
	var/mob/living/carbon/human/W = wearer
	W.visible_message("<span class=warning>The mask lets go of [W]'s corpse.</span>")
	W.drop_from_inventory(src)
	flick("happiest_flash", src)
	canremove = 1
	happiness = 10

/obj/item/clothing/mask/happy/acidable()
	var/mob/living/carbon/human/W = loc
	if(istype(W) && W.wear_mask == src)
		to_chat(W, "<span class='sinister'>Someone is trying to melt our face! We'll have to borrow some of yours.</span>")
		var/datum/organ/external/affecting = W.get_organ(LIMB_HEAD)
		if(affecting.take_damage(10, 0))
			W.UpdateDamageIcon(1)
		laugh(W)
		changehappiness(UNHAPPIER)
	return 0

/obj/item/clothing/mask/happy/proc/laugh(var/mob/living/carbon/human/W)
	if(!canemote)
		return

	var/laughdesc = pick("happy", "funny", "disturbing", "creepy", "horrid", "bloodcurdling", "freaky", "scary", "childish", "deranged", "airy", "snorting")
	var/laughtype = pick("laugh", "giggle", "chuckle", "grin", "smile")
	W.visible_message("[W]'s mask makes \a [laughdesc] [laughtype].")

	canemote = 0
	spawn(5 SECONDS)
		canemote = 1

/obj/item/clothing/mask/happy/proc/changehappiness(var/change)
	happiness = Clamp(happiness += change, -100, 100)

#undef VERYHAPPY
#undef HAPPIER
#undef UNHAPPIER