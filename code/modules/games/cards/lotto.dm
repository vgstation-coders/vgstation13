/obj/item/toy/lotto_ticket
	name = "scratch-off lotto ticket"
	desc = "A scratch-off lotto ticket."
	icon = 'icons/obj/toy.dmi'
	w_class = W_CLASS_TINY
	var/obj/item/toy/lotto_ticket/revealed = 0
	var/obj/item/toy/lotto_ticket/iswinner = 0
	var/obj/item/toy/lotto_ticket/ticket_price
	var/obj/item/toy/lotto_ticket/winnings = 0

/obj/item/toy/lotto_ticket/New()
	..()
	pixel_y = rand(-8, 8) * PIXEL_MULTIPLIER
	pixel_x = rand(-9, 9) * PIXEL_MULTIPLIER

/proc/obj/item/toy/lotto_ticket/scratch(input_price)
	var/list/prizelist = list(100000,50000,10000,5000,1000,500,250,100,50,20,10,5,4,3,2,1)
	var/list/problist = list(prob(1)*prob(1)*prob(1),prob(1)*prob(1)*prob(2),prob(1)*prob(1)*prob(10),prob(1)*prob(1)*prob(20),prob(1)*prob(1),prob(1)*prob(2),prob(1)*prob(4),prob(1)*prob(20),prob(1),prob(3),prob(5),prob(10),prob(13),prob(17),prob(20),prob(25))
	var/tuning_value = 1/5 //Used to adjust expected values.
	for(var/prize = 1 to problist.len)
		if(problist[prize])
			return(prizelist[prize]*input_price*tuning_value)

/obj/item/toy/lotto_ticket/attackby(obj/item/weapon/S as obj, mob/user as mob)
	if(!src.revealed == 1)
		if(S.is_sharp() || istype(S, /obj/item/weapon/coin))
			if(do_after(user, src, 1 SECONDS))
				src.revealed = 1
				src.update_icon()
				to_chat(user, "<span class='notice'>You scratch off the film covering the prizes.</span>")
				winnings = scratch(ticket_price)
				if(winnings > 0)
					src.iswinner = 1
				return
		else
			to_chat(user, "<span class='notice'>You need to use something sharp to scratch the ticket.</span>")
			return
	else
		to_chat(user, "<span class='notice'>The film covering the prizes has already been scratched off.</span>")
		return

/obj/item/toy/lotto_ticket/examine(mob/user)
	if(user.range_check(src))
		if(revealed == 1)
			..()
			if(iswinner == 1)
				to_chat(user, "<span class='notice'>This one is a winner! You've won [winnings] credits.</span>")
			else
				to_chat(user, "<span class='notice'>No wins on this one.</span>")
		else
			..()
			to_chat(user, "<span class='notice'>It hasn't been scratched off yet.</span>")
	else
		..() //Only show a regular description if it is too far away to read.
		to_chat(user, "<span class='notice'>It is too far away to read.</span>")

/obj/item/toy/lotto_ticket/update_icon()
	if(istype(src,/obj/item/toy/lotto_ticket/gold_rush))
		icon_state = "lotto_1_scratched"
	else if(istype(src,/obj/item/toy/lotto_ticket/diamond_hands))
		icon_state = "lotto_2_scratched"
	else if(istype(src,/obj/item/toy/lotto_ticket/phazon_fortune))
		icon_state = "lotto_3_scratched"

//Tier 1 card
/obj/item/toy/lotto_ticket/gold_rush
	name = "Gold Rush lottery ticket"
	desc = "A cheap scratch-off lottery ticket. Win up to 100,000 credits!"
	icon_state = "lotto_1"
	ticket_price = 5 //EV 4.55, ER -0.45

//Tier 2 card
/obj/item/toy/lotto_ticket/diamond_hands
	name = "Diamond Hands lottery ticket"
	desc = "A mid-price scratch-off lottery ticket. Win up to 400,000 credits!"
	icon_state = "lotto_2"
	ticket_price = 20 //EV 18.20, ER -1.80

//Tier 3 card
/obj/item/toy/lotto_ticket/phazon_fortune
	name = "Phazon Fortune lottery ticket"
	desc = "An expensive scratch-off lottery ticket. Win up to 1,000,000 credits!"
	icon_state = "lotto_3"
	ticket_price = 50 //EV 45.50, ER -4.50