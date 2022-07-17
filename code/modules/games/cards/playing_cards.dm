#define CARD_DISPLACE	9
#define CARD_WIDTH		7 //Width of the icon

/*
 *	Taken from /tg/
 */

/datum/context_click/cardhand/return_clicked_id(x_pos, y_pos)
	var/obj/item/toy/cardhand/hand = holder

	var/card_distance = CARD_DISPLACE - hand.currenthand.len //How far apart each card is
	var/starting_card_x = hand.currenthand.len * (CARD_DISPLACE - hand.currenthand.len) - CARD_DISPLACE

	if(x_pos < starting_card_x + CARD_WIDTH)
		return 1
	else
		return round( ( x_pos - (starting_card_x + CARD_WIDTH) ) / card_distance ) + 2 //+2, because we floor, and because we skipped the first card

/datum/context_click/cardhand/action(obj/item/used_item, mob/user, params)
	var/obj/item/toy/cardhand/hand = holder
	if(!used_item)
		var/index = clamp(return_clicked_id_by_params(params), 1, hand.currenthand.len)
		var/obj/item/toy/singlecard/card = hand.currenthand[index]
		hand.currenthand.Remove(card)
		user.put_in_hands(card)
		hand.update_icon()
		if(hand.currenthand.len == 1)
			var/obj/item/toy/singlecard/C = hand.currenthand[1]
			user.u_equip(hand, FALSE)
			user.put_in_inactive_hand(C)
			qdel(hand)
	else if(istype(used_item, /obj/item/toy/singlecard))
		var/index = clamp(return_clicked_id_by_params(params), 1, hand.currenthand.len)
		hand.currenthand.Insert(index, used_item) //We put it where we specified
		hand.update_icon()

/obj/item/toy/cards
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_full"
	w_class = W_CLASS_SMALL
	var/decktype = null //For the icons of different card game decks
	var/list/cards  //List of the singlecard items we carry
	var/strict_deck = 1 //If we only accept cards that came from us

/obj/item/toy/cards/New()
	..()
	cards = list()
	generate_cards()
	update_icon()

/obj/item/toy/cards/proc/generate_cards()
	cards += new/obj/item/toy/singlecard(src, src, "Red Joker")
	cards += new/obj/item/toy/singlecard(src, src, "Black Joker")

	for(var/i = 2; i <= 10; i++)
		cards += new/obj/item/toy/singlecard(src, src, "[i] of Hearts")
		cards += new/obj/item/toy/singlecard(src, src, "[i] of Spades")
		cards += new/obj/item/toy/singlecard(src, src, "[i] of Clubs")
		cards += new/obj/item/toy/singlecard(src, src, "[i] of Diamonds")

	cards += new/obj/item/toy/singlecard(src, src, "King of Hearts")
	cards += new/obj/item/toy/singlecard(src, src, "King of Spades")
	cards += new/obj/item/toy/singlecard(src, src, "King of Clubs")
	cards += new/obj/item/toy/singlecard(src, src, "King of Diamonds")
	cards += new/obj/item/toy/singlecard(src, src, "Queen of Hearts")
	cards += new/obj/item/toy/singlecard(src, src, "Queen of Spades")
	cards += new/obj/item/toy/singlecard(src, src, "Queen of Clubs")
	cards += new/obj/item/toy/singlecard(src, src, "Queen of Diamonds")
	cards += new/obj/item/toy/singlecard(src, src, "Jack of Hearts")
	cards += new/obj/item/toy/singlecard(src, src, "Jack of Spades")
	cards += new/obj/item/toy/singlecard(src, src, "Jack of Clubs")
	cards += new/obj/item/toy/singlecard(src, src, "Jack of Diamonds")
	cards += new/obj/item/toy/singlecard(src, src, "Ace of Hearts")
	cards += new/obj/item/toy/singlecard(src, src, "Ace of Spades")
	cards += new/obj/item/toy/singlecard(src, src, "Ace of Clubs")
	cards += new/obj/item/toy/singlecard(src, src, "Ace of Diamonds")


/obj/item/toy/cards/examine(mob/user)
	..()
	user.show_message("There are [cards.len] cards in the deck.", 1)

/obj/item/toy/cards/attack_hand(mob/user as mob)
	var/choice = null
	if(!cards.len)
		icon_state = "deck_empty"
		to_chat(user, "<span class='notice'>There are no more cards to draw.</span>")
		return
	choice = cards[1]
	cards -= choice
	user.put_in_active_hand(choice)
	user.visible_message("<span class='notice'>[user] draws a card from the deck.</span>",
						"<span class='notice'>You draw a card from the deck.")

	update_icon()

/obj/item/toy/cards/attack_self(var/mob/user)
	if(user.attack_delayer.blocked())
		return
	cards = shuffle(cards)
	playsound(user, 'sound/items/cardshuffle.ogg', 50, 1)
	user.visible_message("<span class='notice'>[user] shuffles the deck.</span>",
						 "<span class='notice'>You shuffle the deck.</span>")
	user.delayNextAttack(1 SECONDS)

/obj/item/toy/cards/attackby(obj/item/I, mob/living/user)
	..()
	if(istype(I, /obj/item/toy/singlecard))
		var/obj/item/toy/singlecard/C = I
		if((!C.parentdeck && !strict_deck) || C.parentdeck == src)
			if(C.flipped == 0)
				C.Flip() //Flip the card back face down before it's put into the deck
			if(user.drop_item(C, src))
				cards += C
				user.visible_message("<span class='notice'>[user] adds a card to the bottom of the deck.</span>",
									 "You add the card to the bottom of the deck.</span>")
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks.</span>")
			update_icon()

	if(istype(I, /obj/item/toy/cardhand))
		var/obj/item/toy/cardhand/C = I
		if((!C.parentdeck && !strict_deck) || C.parentdeck == src)
			if(user.drop_item(C))
				for(var/obj/item/toy/singlecard/card in C.currenthand)
					if(card.flipped == 0)
						card.Flip()
					card.forceMove(src)
					cards += card
				user.visible_message("<span class='notice'>[user] puts their hand of cards into the deck.</span>",
									 "<span class='notice'>You put the hand into the deck.</span>")
				qdel(C)
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks.</span>")
		update_icon()

/obj/item/toy/cards/update_icon()
	if(cards.len > 26)
		icon_state = "deck_full"
	else if(cards.len > 10)
		icon_state = "deck_half"
	else if(cards.len > 1)
		icon_state = "deck_low"

/obj/item/toy/cards/verb/draw_specific()
	set name = "Draw specific card"
	set category = "Object"
	set src in usr

	var/list/card_names = new /list(src.cards.len)
	for(var/i = 1; i <= src.cards.len; i++)
		var/obj/item/toy/singlecard/T = src.cards[i]
		card_names[i] = T.cardname

	usr.visible_message("<span class='notice'>[usr] rifles through the deck.</span>",
							"<span class='notice'>You rifle through the deck.")

	var/N = input("Draw a specific card from the deck.") as null|anything in card_names
	if(N)
		var/obj/item/toy/singlecard/C = null
		for(var/i = 1; i <= src.cards.len; i++)
			var/obj/item/toy/singlecard/Q = src.cards[i]
			if(N == Q.cardname)
				C = Q
		var/mob/living/M = usr
		if(!M.find_empty_hand_index())
			to_chat(usr, "<span class='warning'>Your other hand is full.</span>")
			return

		cards -= C
		C.Flip()
		usr.put_in_hands(C)

		usr.visible_message("<span class='notice'>[usr] draws a specific card from the deck.</span>",
							"<span class='notice'>You draw the [N] from the deck.")
		update_icon()

/obj/item/toy/cards/MouseDropFrom(atom/over_object)
	MouseDropPickUp(over_object)
	return ..()

////////////////////////////
/////////CARD HANDS/////////
////////////////////////////

/obj/item/toy/cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/toy.dmi'
	icon_state = "handbase"
	w_class = W_CLASS_SMALL
	var/list/currenthand = list()
	var/obj/item/toy/cards/parentdeck = null
	var/max_hand_size = 7

	var/datum/context_click/cardhand/hand_click

/obj/item/toy/cardhand/New()
	..()
	hand_click = new(src)

/obj/item/toy/cardhand/examine(mob/user)
	..()
	var/name_list = list()
	for(var/obj/item/toy/singlecard/card in currenthand)
		name_list += card.name //We don't use cardname because they might be flipped
	user.show_message("It holds [english_list(name_list)]", 1)

/obj/item/toy/cardhand/attackby(obj/item/toy/singlecard/C, mob/living/user, params)
	if(istype(C))
		if(!(C.parentdeck || src.parentdeck) || C.parentdeck == src.parentdeck)
			if(currenthand.len >= max_hand_size)
				to_chat(user, "<span class = 'warning'>You can't add any more cards to this hand.</span>")
				return
			if(user.drop_item(C, src))
				hand_click.action(C, user, params)
				user.visible_message("<span class='notice'>[user] adds a card to their hand.</span>",
									 "<span class='notice'>You add the [C.cardname] to your hand.</span>")
				update_icon()
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks.</span>")
		return 1
	else if(istype(C, /obj/item/toy/cardhand))
		var/obj/item/toy/cardhand/H = C
		var/compatible = 1
		var/cardcount = H.currenthand.len + src.currenthand.len
		if(cardcount > 5)
			compatible = 0
		for(var/obj/item/toy/singlecard/card in H.currenthand)
			for(var/obj/item/toy/singlecard/sourcecard in src.currenthand)
				if(!(!(card.parentdeck || sourcecard.parentdeck) || card.parentdeck == sourcecard.parentdeck))
					compatible = 0
		if(compatible)
			user << "<span class='notice'>You add [src] to your hand.</span>"
			for(var/obj/item/toy/singlecard/card in currenthand)
				currenthand -= card
				H.currenthand += card
				card.forceMove(H)
			H.update_icon()

			qdel(src)
		else if(cardcount > 5)
			user << "<span class='notice'>You can't make a hand that large.</span>"
		else
			user << "<span class='warning'> You can't mix cards from other decks.</span>"
	if(istype(C, /obj/item/toy/cards)) //shuffle us in
		return C.attackby(src, user)
	return ..()

/obj/item/toy/cardhand/attack_self(mob/user)
	for(var/obj/item/toy/singlecard/card in currenthand)
		card.Flip()
		update_icon()
	return ..()

/obj/item/toy/cardhand/attack_hand(mob/user, params)
	if(user.get_inactive_hand() == src)
		return hand_click.action(null, user, params)
	return ..()

/obj/item/toy/cardhand/update_icon()
	overlays.len = 0
	for(var/i = currenthand.len; i >= 1; i--)
		var/obj/item/toy/singlecard/card = currenthand[i]
		if(card)
			card.layer = FLOAT_LAYER
			card.plane = FLOAT_PLANE
			card.pixel_x = i * (CARD_DISPLACE - currenthand.len) - CARD_DISPLACE
			overlays += card

///////////////////////////
/////////CARD ITEMS////////
///////////////////////////

/obj/item/toy/singlecard
	name = "card"
	desc = "A card."
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_down"
	w_class = W_CLASS_TINY
	var/cardname = null
	var/obj/item/toy/cards/parentdeck = null
	var/flipped = TRUE //Cards start flipped so that dealers can deal without having to see the card.
	pixel_x = -5

/obj/item/toy/singlecard/unflipped //Card that is face-up, just so that it's visible
	flipped = FALSE

/obj/item/toy/singlecard/New(NewLoc, cardsource, newcardname)
	..(NewLoc)
	if(cardsource)
		parentdeck = cardsource
	if(newcardname)
		cardname = newcardname
		name = cardname
	update_icon()

/obj/item/toy/singlecard/Destroy()
	if(parentdeck)
		parentdeck.cards -= src
	..()

/obj/item/toy/singlecard/update_icon()
	if(flipped)
		icon_state = "singlecard_down"
		pixel_x = -5
		name = "card"
	else
		if(cardname)
			icon_state = "sc_[cardname]"
			name = src.cardname
		else
			icon_state = "sc_Ace of Spades"
			name = "What Card"
		pixel_x = 5

/obj/item/toy/singlecard/examine(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/cardUser = user
		if(cardUser.is_holding_item(src))
			cardUser.visible_message("<span class='notice'>[cardUser] checks \his card.",
									 "<span class='notice'>The card reads: [name]</span>")
		else
			to_chat(cardUser, "<span class='notice'>You need to have the card in your hand to check it.</span>")

/obj/item/toy/singlecard/proc/Flip()
	flipped = !flipped
	update_icon()

/obj/item/toy/singlecard/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/toy/singlecard))
		var/obj/item/toy/singlecard/C = I
		if(!(C.parentdeck || parentdeck) || C.parentdeck == parentdeck)
			var/obj/item/toy/cardhand/H = new/obj/item/toy/cardhand(user.loc)
			H.parentdeck = C.parentdeck
			user.drop_item(C, src, force_drop = 1)
			user.remove_from_mob(src) //we could be anywhere!
			forceMove(H)
			user.put_in_active_hand(H)
			to_chat(user, "<span class='notice'>You combine [C] and [src] into a hand.</span>")

			H.currenthand += C
			H.currenthand += src
			H.update_icon()
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")
	else if(istype(I, /obj/item/toy/cardhand))
		var/obj/item/toy/cardhand/H = I
		var/compatible = 1
		for(var/obj/item/toy/singlecard/card in H.currenthand)
			if(!(!(card.parentdeck || parentdeck) || card.parentdeck == src.parentdeck))
				compatible = 0
		if(H.currenthand.len >= H.max_hand_size)
			to_chat(user, "<span class = 'warning'>You can't add any more cards to this hand.</span>")
			return
		if(compatible)
			user << "<span class = 'notice'>You add [src] to your hand.</span>"
			user.drop_item(src)
			user.remove_from_mob(src) //we could be anywhere!
			forceMove(H)
			H.currenthand += src
			H.update_icon()
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"
	if(istype(I, /obj/item/toy/cards)) //shuffle us in
		return I.attackby(src, user)

/obj/item/toy/singlecard/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user] flips a card over.</span>", //So that players can see whether a dealer is looking at their cards as he deals them
						 "<span class='notice'>You flip the card over.</span>")
	Flip()
	return ..()
