/obj/item/toy/lotto_ticket
	name = "scratch-off lotto ticket"
	desc = "A scratch-off lotto ticket."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_full"
	w_class = W_CLASS_TINY
	var/obj/item/toy/lotto_ticket/revealed = 0
	var/obj/item/toy/lotto_ticket/iswinner = 0

/obj/item/toy/lotto_ticket/New()
	..()
	pixel_y = rand(-8, 8) * PIXEL_MULTIPLIER
	pixel_x = rand(-9, 9) * PIXEL_MULTIPLIER

/obj/item/toy/lotto_ticket/attackby(obj/item/weapon/S as obj, mob/user as mob)
	if(S.is_sharp() || istype(S, /obj/item/weapon/coin))
		src.revealed = 1
		to_chat(user, "<span class='notice'>You scratch off the film covering the prizes.</span>")
		return
	else
		to_chat(user, "<span class='notice'>You need to use something sharp to scratch the ticket.</span>")
		return

/obj/item/toy/lotto_ticket/examine(mob/user)
	if(user.range_check(src))
		if(revealed == 1)
			..()
			if(iswinner != 0)
				to_chat(user, "<span class='notice'>This one is a winner!</span>")
			else
				to_chat(user, "<span class='notice'>No wins on this one.</span>")
		else
			..()
			to_chat(user, "<span class='notice'>It hasn't been scratched off yet.</span>")
	else
		..() //Only show a regular description if it is too far away to read.
		to_chat(user, "<span class='notice'>It is too far away to read.</span>")

///obj/item/toy/lotto_ticket/credit_king
//	name = "Credit King lottery ticket"
//	desc = "A cheap scratch-off lottery ticket. 5 possible prizes of up to 250,000 credits!"
//	icon_state = "credit_king_ticket"


///obj/item/toy/lotto_ticket/credit_king/New()
//	..()
//	var/prize_total = 0
//	var/available_prizes = 5 //Expected return = 4.75, expected gain = -.25
//	var/obj/item/toy/lotto_ticket/credit_king/prizelist = list(1,2,3,4,5,10,20,50,100,500,1000,5000,10000,50000)
//	var/obj/item/toy/lotto_ticket/credit_king/problist = list(10,10,10,1,1,.1,.1,.1,.01,.01,.001,.001,.0001,.0001)
//	var/obj/item/toy/lotto_ticket/credit_king/iswinner = 0


/obj/item/toy/lotto_ticket/gold_bar
	name = "Gold Bar lottery ticket"
	desc = "A mid-price scratch-off lottery ticket. 4 possible prizes of up to 500,000 credits!"
	icon_state = "gold_bar_ticket"

/obj/item/toy/lotto_ticket/gold_bar/New()
	..()
	var/available_prizes = 4 //Expected return = 9.88, expected gain = -.12
	var/prizelist = list(2,4,6,8,10,20,40,100,200,1000,2000,10000,20000,125000)
	var/problist = list(10,10,10,2,2,.2,.2,.2,.02,.02,.002,.002,.0002,.0002)
	var/obj/item/toy/lotto_ticket/gold_bar/list/won_list
	for(var/i = 1 to available_prizes)
		var/prize_index = 1
		for(var/prize_prob in problist)
			if(prob(prize_prob))
				won_list += prizelist[prize_index]
				prize_index += 1
				iswinner = 1
	var/obj/item/toy/lotto_ticket/gold_bar/total_winnings = 0
	if(iswinner != 0)
		for(var/win in won_list)
			total_winnings += win


///obj/item/toy/lotto_ticket/diamond_hands
//	name = "Diamond Hands lottery ticket"
//	desc = "An expensive scratch-off lottery ticket. 2 possible prizes of up to 1,000,000 credits!"
//	icon_state = "diamond_hands_ticket"

///obj/item/toy/lotto_ticket/diamond_hands/New()
//	..()
//	var/prize_total = 0
//	var/available_prizes = 2 //Expected return = 22, expected gain = 2
//	var/obj/item/toy/lotto_ticket/diamond_hands/prizelist = list(5,10,15,20,25,50,100,250,500,2500,5000,25000,50000,500000)
//	var/obj/item/toy/lotto_ticket/diamond_hands/problist = list(10,10,10,4,4,.4,.4,.4,.04,.04,.004,.004,.0004,.0004)
//	var/obj/item/toy/lotto_ticket/diamond_hands/iswinner = 0