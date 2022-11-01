#define CARD_DISPLACE	9
#define CARD_WIDTH		7 //Width of the icon

#define JOKER_CARD	0
#define ACE_CARD	1
#define JACK_CARD 	11
#define QUEEN_CARD	12
#define KING_CARD	13

#define ROYAL_FLUSH 10
#define STRAIGHT_FLUSH 9
#define FOUR_KIND 8
#define FULL_HOUSE 7
#define FLUSH 6
#define STRAIGHT 5
#define THREE_KIND 4
#define TWO_PAIR 3
#define PAIR 2
#define HIGH_CARD 1

/*
 *	Taken from /tg/
 */

var/static/list/card_suits = list("Hearts","Spades","Clubs","Diamonds")
var/static/list/cardcombos2name = list("high card","pair","two pair","three of a kind","straight","flush","full house","four of a kind","straight flush","royal flush")

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
	for(var/obj/item/toy/singlecard/card in cards)
		qdel(card)
	cards.Cut()
	cards += new/obj/item/toy/singlecard(src, src, 0, "Hearts")
	cards += new/obj/item/toy/singlecard(src, src, 0, "Spades")

	for(var/suit in card_suits)
		for(var/i in ACE_CARD to KING_CARD)
			cards += new/obj/item/toy/singlecard(src, src, i, suit)


/obj/item/toy/cards/examine(mob/user)
	..()
	user.show_message("There are [cards.len] cards in the deck.", 1)

/obj/item/toy/cards/attack_hand(mob/user as mob)
	var/choice = null
	if(!cards.len)
		icon_state = "deck_empty"
		to_chat(user, "<span class='notice'>There are no more cards to draw.</span>")
		return
	var/draw_index = 1
	if(user?.lucky_prob(1/cards.len,1/10,20,user?.luck()))
		var/obj/item/toy/cardhand/CH = user.get_inactive_hand()
		if(istype(CH))
			var/num2get = 0
			var/suit2get = 0
			var/list/nums = list()
			var/list/suits = list()
			for(var/obj/item/toy/singlecard/card in CH.currenthand)
				if(!istype(card,/obj/item/toy/singlecard/une) && !istype(card,/obj/item/toy/singlecard/wizard))
					nums += "[card.number]"
					suits += card.suit
			var/obj/item/toy/cardhand/OH
			for(var/obj/item/toy/cardhand/otherhand in adjacent_atoms(src))
				if(otherhand != src)
					OH = otherhand
					break
			switch(CH.get_texas_holdem_combo(OH))
				if(THREE_KIND)
					if(user?.lucky_prob(50,1/10,40,user?.luck()))
						for(var/number in nums)
							if(count_by_name(nums,number) == 3)
								num2get = text2num(number) // make it four of a kind
					else
						for(var/number in nums)
							if(count_by_name(nums,number) == 2)
								num2get = text2num(number) // make it a full house
				if(TWO_PAIR)
					for(var/number in nums)
						if(count_by_name(nums,number) >= 2)
							num2get = text2num(number) // make it a full house
				if(PAIR)
					for(var/number in nums)
						if(count_by_name(nums,number) >= 2)
							num2get = text2num(number) // make it a three of a kind
				else
					if(user?.lucky_prob(50,1/10,40,user?.luck()))
						if(user?.lucky_prob(50,1/10,40,user?.luck()))
							suit2get = pick(suits) // attempt at a flush
						num2get = text2num(pick(nums))+1 // attempt at a straight
						if(num2get > KING_CARD)
							num2get = ACE_CARD // helps with royal flushes
					else
						num2get = text2num(pick(nums)) // just a pair
			for(var/obj/item/toy/singlecard/card in cards)
				if((!num2get || card.number == num2get) && (!suit2get || card.suit == suit2get))
					break
				draw_index++

	choice = cards[draw_index]
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
	var/list/obj/item/toy/singlecard/currenthand = list()
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

/*/obj/item/toy/cardhand/dropped(mob/user) // use for testing
	for(var/obj/item/toy/cardhand/otherhand in adjacent_atoms(src))
		if(otherhand != src)
			var/ourcombo = get_texas_holdem_combo(otherhand)
			var/result = "\a [cardcombos2name[ourcombo]][ourcombo == HIGH_CARD ? " of [cardnumber2name(get_high_card(otherhand))]" : ""]."
			user.visible_message("<span class = 'notice'>[user] has [result]</span>","<span class = 'notice'>You have [result]</span>")*/

/obj/item/toy/cardhand/proc/get_texas_holdem_combo(var/obj/item/toy/cardhand/otherhand)
	var/list/nums = list()
	var/list/suits = list()
	var/list/found_combos = list()
	for(var/obj/item/toy/singlecard/card in currenthand)
		if(!istype(card,/obj/item/toy/singlecard/une) && !istype(card,/obj/item/toy/singlecard/wizard))
			nums += "[card.number]"
			suits += card.suit
	if(otherhand)
		for(var/obj/item/toy/singlecard/card in otherhand.currenthand)
			if(!istype(card,/obj/item/toy/singlecard/une) && !istype(card,/obj/item/toy/singlecard/wizard))
				nums += "[card.number]"
				suits += card.suit
	var/highcard = get_high_card(otherhand)
	for(var/suit in suits)
		if(count_by_name(suits,suit) >= 5)
			found_combos += FLUSH
			break
	var/matches = 0
	for(var/straightnum in highcard-1 to highcard-4)
		if("[straightnum]" in nums)
			matches++
	if(matches >= 4)
		if(FLUSH in found_combos)
			if(highcard == KING_CARD+1)
				found_combos += ROYAL_FLUSH
			else
				found_combos += STRAIGHT_FLUSH
		else
			found_combos += STRAIGHT
	for(var/number in nums)
		switch(count_by_name(nums,number))
			if(4 to INFINITY)
				found_combos += FOUR_KIND
				break
			if(3)
				for(var/number2 in nums)
					if(text2num(number2) != text2num(number) && count_by_name(nums,number2) >= 2)
						found_combos += FULL_HOUSE
						break
				if(!(THREE_KIND in found_combos))
					found_combos += THREE_KIND
			if(2)
				for(var/number2 in nums)
					if(text2num(number2) != text2num(number))
						switch(count_by_name(nums,number2))
							if(3 to INFINITY)
								found_combos += FULL_HOUSE
								break
							if(2)
								found_combos += TWO_PAIR
								break
				found_combos += PAIR
				break
	. = HIGH_CARD
	for(var/combo in found_combos)
		if(combo > .)
			. = combo

/obj/item/toy/cardhand/proc/get_high_card(var/obj/item/toy/cardhand/otherhand)
	. = 2
	for(var/obj/item/toy/singlecard/card in currenthand)
		if(!istype(card,/obj/item/toy/singlecard/une) && !istype(card,/obj/item/toy/singlecard/wizard))
			if(card.number == ACE_CARD)
				return KING_CARD+1
			if(card.number > .)
				. = card.number
	if(otherhand)
		var/otherhigh = otherhand.get_high_card()
		if(otherhigh > .)
			. = otherhigh

///////////////////////////
/////////CARD ITEMS////////
///////////////////////////

/obj/item/toy/singlecard
	name = "card"
	desc = "A card."
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_down"
	w_class = W_CLASS_TINY
	var/number = 1
	var/suit = "Spades"
	var/cardname = "Ace of Spades"
	var/obj/item/toy/cards/parentdeck = null
	var/flipped = TRUE //Cards start flipped so that dealers can deal without having to see the card.
	pixel_x = -5

/obj/item/toy/singlecard/unflipped //Card that is face-up, just so that it's visible
	flipped = FALSE

/obj/item/toy/singlecard/New(NewLoc, cardsource, cardnum, cardsuit)
	..(NewLoc)
	if(cardsource)
		parentdeck = cardsource
	if(cardnum >= 0 && cardnum <= 13)
		number = cardnum
	if(cardsuit && (cardsuit in card_suits))
		suit = cardsuit
	if(!number)
		switch(suit)
			if("Spades", "Clubs")
				suit = "Black"
			if("Hearts", "Diamonds")
				suit = "Red"
	cardname = number ? "[cardnumber2name(number)] of [suit]" : "[suit] [cardnumber2name(number)]"
	name = cardname
	update_icon()

/proc/cardnumber2name(var/number)
	switch(number)
		if(JOKER_CARD)
			return "Joker"
		if(ACE_CARD)
			return "Ace"
		if(JACK_CARD)
			return "Jack"
		if(QUEEN_CARD)
			return "Queen"
		if(KING_CARD)
			return "King"
	return "[number]"

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
