#define REDCARD	"#ff0000"
#define YELLOWCARD	"#f9d009"
#define GREENCARD	"#00cc00"
#define BLUECARD	"#0000ff"
#define BLACKCARD	"#000000"

#define UNE_SKIP 10
#define UNE_REVERSE 11
#define UNE_DRAW2 12

var/static/list/une_suits = list("Red" = REDCARD,"Yellow" = YELLOWCARD,"Green" = GREENCARD,"Blue" = BLUECARD)
var/static/list/other_une_suits = list("Wild" = "wild","Draw 4" = "draw4")
var/static/list/specialunecards2icon = list("skip","reverse","draw2")

/obj/item/toy/cards/une
	name = "deck of une cards"
	desc = "A deck of une playing cards."
	icon = 'icons/obj/une_cards.dmi'
	icon_state = "deck_full"

/obj/item/toy/cards/une/generate_cards()
	for(var/i in 0 to 1)
		for(var/j in i to 9)//Second full set without a 0 card this time.
			for(var/suit in une_suits)
				cards += new/obj/item/toy/singlecard/une(src, src, j, suit, "[j]", une_suits[suit])
	for(var/i in 0 to 3)//Black is just a placeholder and not actually used in the coloring.
		for(var/suit in other_une_suits)
			cards += new/obj/item/toy/singlecard/une(src, src, 0, suit, other_une_suits[suit], BLACKCARD)
	for(var/suit in une_suits)
		for(var/j in 1 to 2)
			for(var/i in UNE_SKIP to UNE_DRAW2)
				cards += new/obj/item/toy/singlecard/une(src, src, i, suit, specialunecards2icon[i-9], une_suits[suit])

/obj/item/toy/cards/une/draw_with_luck(user)
	return 1 // TODO: something for this game

/obj/item/toy/singlecard/une
	name = "une card"
	desc = "A card."
	icon = 'icons/obj/une_cards.dmi'
	icon_state = "unecard_down"
	var/image/unecardimg

/obj/item/toy/singlecard/une/New(NewLoc, cardsource, cardnum, cardsuit, truecardname, cardhexcolor)
	unecardimg = image('icons/obj/une_cards.dmi', truecardname)
	if(cardhexcolor != BLACKCARD)
		unecardimg.color = cardhexcolor
	..()
	if(cardnum >= 0 && cardnum <= 9)
		number = cardnum
	if(cardsuit && ((number && (cardsuit in une_suits)) || (cardsuit in other_une_suits)))
		suit = cardsuit
	cardname = "[suit][number ? " [unecardnumber2name(number)]" : ""]"
	name = cardname
	update_icon()

/obj/item/toy/singlecard/une/update_icon()
	if(flipped)
		icon_state = "unecard_down"
		overlays -= unecardimg
		name = "une card"
		pixel_x = -5
	else
		icon_state = "unecard_up"
		overlays += unecardimg
		name = cardname
		pixel_x = 5

/proc/unecardnumber2name(var/number)
	switch(number)
		if(UNE_SKIP)
			return "Skip"
		if(UNE_REVERSE)
			return "Reverse"
		if(UNE_DRAW2)
			return "Draw 2"
	return "[number]"


#undef REDCARD
#undef YELLOWCARD
#undef GREENCARD
#undef BLUECARD
