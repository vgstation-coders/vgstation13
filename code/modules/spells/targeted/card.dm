/spell/targeted/card
	name = "Card Trick"
	desc = "Ask a person about whether a random card is theirs. Their whole inventory is filled with copies of the card."
	abbreviation = "CT"
	user_type = USER_TYPE_WIZARD // Now it's a meme available for wizards! //It's quite the exquisite meme
	specialization = SSUTILITY
	school = "transmutation"
	charge_max = 100 //10 seconds
	spell_flags = WAIT_FOR_CLICK
	invocation_type = SpI_SHOUT
	max_targets = 1
	compatible_mobs = list(/mob/living/carbon/human)
	level_max = list(Sp_TOTAL = 0, Sp_SPEED = 0, Sp_POWER = 0) //You can't quicken this, this would be kind of useless
	hud_state = "card_trick"
	var/current_suit
	var/current_number

/spell/targeted/card/before_cast(list/targets, user)
	. = ..()
	current_suit = pick(card_suits)
	current_number = pick(ACE_CARD,KING_CARD)

/spell/targeted/card/invocation(mob/user, list/targets)
	invocation = "IS THE [uppertext(current_number)] OF [uppertext(current_suit)] YOUR CARD?"
	..()

/spell/targeted/card/cast(list/targets, mob/user)
	..()
	for(var/mob/living/carbon/human/H in targets)
		for(var/obj/item/weapon/storage/S in recursive_type_check(H, /obj/item/weapon/storage))
			while(!S.is_full())
				new /obj/item/toy/singlecard/unflipped(S, cardnum = current_number, cardsuit = current_suit)
		if(!H.get_item_by_slot(slot_l_store))
			H.l_store = new /obj/item/toy/singlecard/unflipped(cardnum = current_number, cardsuit = current_suit)
		if(!H.get_item_by_slot(slot_r_store))
			H.r_store = new /obj/item/toy/singlecard/unflipped(cardnum = current_number, cardsuit = current_suit)
		H.update_inv_pockets(0)
