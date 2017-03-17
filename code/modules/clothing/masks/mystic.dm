//todo:
//ghost flickering + sprite
//ghosts spooking near happiest mask causing an immediate flickering + happy boost

#define VERYHAPPY 75

#define HAPPIER 1
#define HAPPIERBLOODY 4
#define UNHAPPIER -10

/obj/item/clothing/mask/happy
	name = "happiest mask"
	desc = "<span class='sinister'>Yes, we can see you too.</span>"
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
	visible_message("<span class='sinister'>We're just so very happy that you're here. Come closer.</span>")
	flick("happiest_flash", src)
	laugh()

/obj/item/clothing/mask/happy/examine(mob/user as mob)
	..()
	var/mob/living/carbon/human/H = user
	if(istype(H) && H.wear_mask == src)
		var/adjective = "happy"
		switch(happiness)
			if(-100 to 0)
				adjective = "unhappy"
			if(1 to 9)
				adjective = "neutral"
			if(40 to 74)
				adjective = "joyful"
			if(75 to 100)
				adjective = "ecstatic"
		to_chat(user, "<span class='notice'>It has \an [adjective] expression.</span>")

/obj/item/clothing/mask/happy/equipped(mob/M as mob, wear_mask)
	var/mob/living/carbon/human/H = M
	if(loc == M && !istype(H))
		to_chat(M, "<span class=sinister>Go away you dumb animal, we have no interest in you.</span>")
		M.visible_message("<span class=warning>\The [src] slips right off of [M]'s face.</span>")
		M.drop_from_inventory(src)
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
	to_chat(user, "<span class='warning'><B>The mask's eyesockets briefly flash with a foreboding red glare.</span></B>\n<span class='sinister'>We're just so very happy to have you joining us. Bring us just a little closer.</span>")

/obj/item/clothing/mask/happy/OnMobLife(var/mob/living/carbon/human/W)
	if(istype(W) && W.wear_mask == src)
		if(happiness <= 0)
			flick("happiest_flash", src)
			var/datum/organ/external/affecting = W.get_organ(LIMB_HEAD)
			if(happiness <= -30) //This takes actual effort to reach
				to_chat(W, "<span class='sinister'>It's too bad you didn't want to be friends, we could have done great things together.</span>")
				visible_message("<span class='danger'>[W]'s neck suddenly twists at an unnatural angle.</span>")
				if(affecting.take_damage(100, 0))
					W.UpdateDamageIcon(1)
					return
			to_chat(W, "<span class='sinister'>It seems you're not being a very good friend to us. We'll just have to fire up this relationship!</span>")
			if(affecting.take_damage(0, 20))
				W.UpdateDamageIcon(1)
			laugh(W)
			changehappiness(-UNHAPPIER)
			return

		else if(happiness >= VERYHAPPY)
			var/bruted = W.getBruteLoss()
			var/burned = W.getFireLoss()
			if(bruted + burned > 0 && prob(happiness))
				var/healed = 0
				for(var/mob/living/carbon/human/H in view(5)) //the mask only draws from other humans
					var/heal = 0
					if(H == W || H.stat == DEAD)
						continue

					if(bruted > 0) //only heal one damage type per mob, preferring brute
						heal = min(5, bruted)
						H.adjustBruteLoss(heal)
						W.adjustBruteLoss(-heal)
						healed += heal

					else if(burned > 0)
						heal = min(5, burned)
						H.adjustFireLoss(heal)
						W.adjustFireLoss(-heal)
						healed += heal

					if(heal) //let's let them know that something happened to them
						to_chat(H, "<span class='sinister'>A friend of ours needs more life-force. Thankfully we can just borrow it from you.</span>")
						//spookanim(H)

				if(healed)
					spawn(1)
						//spookanim(W)
					healed = round(healed)
					changehappiness(-healed*3, 0) //since they helped you, you'll have to make them happier again
					return

		if(prob(happiness/2))
			if(canemote && blood_overlay) //It's on the same 5 second cooldown as emoting so you can't just spam it
				if(clean_blood())
					W.update_inv_wear_mask(0)
					changehappiness(HAPPIERBLOODY)
					to_chat(W, "<span class='sinister'>What a delicious meal our friend has given us.</span>")
			changehappiness(HAPPIER)

			flick("happiest_flash", src)
			W.say(pick("WE'RE JUST SO HAPPY!", "SMILE!", "ISN'T EVERYTHING SO WONDERFUL?", "EVERYONE SHOULD SMILE!", "WE'RE SO GLAD TO HAVE ANOTHER FRIEND!"))
			laugh(W)
			//spookanim(W)

/obj/item/clothing/mask/happy/OnMobDeath(var/mob/living/carbon/human/wearer)
	var/mob/living/carbon/human/W = wearer
	W.visible_message("<span class=warning>\The [src] slides off of [W]'s corpse.</span>")
	W.drop_from_inventory(src)
	flick("happiest_flash", src)
	canremove = 1
	happiness = 10

/obj/item/clothing/mask/happy/acidable()
	var/mob/living/carbon/human/W = loc
	if(istype(W) && W.wear_mask == src)
		to_chat(W, "<span class='sinister'>Someone is trying to melt our face! We'll have to borrow some of yours to fix it.</span>")
		var/datum/organ/external/affecting = W.get_organ(LIMB_HEAD)
		if(affecting.take_damage(15, 0))
			W.UpdateDamageIcon(1)
		laugh(W)
		changehappiness(UNHAPPIER)
	return 0

/obj/item/clothing/mask/happy/proc/laugh(var/mob/living/carbon/human/W)
	if(!canemote)
		return
	var/laughdesc = pick("happy", "funny", "disturbing", "creepy", "horrid", "bloodcurdling", "freaky", "scary", "childish", "deranged", "airy", "snorting")
	var/laughtype = pick("laugh", "giggle", "chuckle", "grin", "smile")
	if(W)
		W.visible_message("[W]'s mask makes \a [laughdesc] [laughtype].")
	else
		visible_message("\The [src] makes \a [laughdesc] [laughtype].")
	canemote = 0
	spawn(5 SECONDS)
		canemote = 1

/obj/item/clothing/mask/happy/proc/changehappiness(var/change)
	happiness = Clamp((happiness + change), -100, 100)

/obj/item/clothing/mask/happy/proc/spookanim(var/atom/A)//calling it on the mask wearer does it on all ghosts in range, calling it on a specific person does a red version showing they were just harmed
	//new obj/effect/whatever(get_turf(A))

#undef VERYHAPPY
#undef HAPPIER
#undef UNHAPPIER