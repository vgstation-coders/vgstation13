/obj/item/toy/lotto_ticket
	name = "scratch-off lotto ticket"
	desc = "A scratch-off lotto ticket."
	icon = 'icons/obj/toy.dmi'
	w_class = W_CLASS_TINY
	var/revealed = FALSE
	var/iswinner = FALSE
	var/ticket_price
	var/winnings = 0
	var/list/prizelist = list(100000,50000,10000,5000,1000,500,250,100,50,20,10,5,4,3,2,1)
	var/list/problist = list(0.0001, 0.0002, 0.001, 0.002, 0.01, 0.02, 0.04, 0.2, 1, 2.5, 5, 10, 12.5, 17, 20, 25)

/obj/item/toy/lotto_ticket/New()
	..()
	pixel_y = rand(-8, 8) * PIXEL_MULTIPLIER
	pixel_x = rand(-9, 9) * PIXEL_MULTIPLIER

/obj/item/toy/lotto_ticket/proc/scratch(var/input_price)
	var/tuning_value = 1/5 //Used to adjust expected values.
	var/profit = 0
	for(var/prize = 1 to problist.len)
		if(prob(problist[prize]))
			profit = prizelist[prize]*input_price*tuning_value
			return profit

//Flash code taken from Blinder
/obj/item/toy/lotto_ticket/proc/flash(var/turf/T , var/mob/living/M)
	playsound(src, 'sound/effects/EMPulse.ogg', 100, 1)

	if(M.blinded)
		return

	M.flash_eyes(visual = 1, affect_silicon = 1)

	if(issilicon(M))
		M.Knockdown(rand(5, 10))
		M.visible_message("<span class='warning'>[M]'s sensors are overloaded by the flash of light!</span>","<span class='warning'>Your sensors are overloaded by the flash of light!</span>")

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
		if (E && E.damage >= E.min_bruised_damage)
			to_chat(M, "<span class='warning'>Your eyes start to burn badly!</span>")
	M.update_icons()


/obj/item/toy/lotto_ticket/attackby(obj/item/weapon/S, mob/user)
	if(!revealed)
		if(S.is_sharp() || istype(S, /obj/item/weapon/coin))
			if(do_after(user, src, 1 SECONDS))
				src.revealed = TRUE
				src.update_icon()
				to_chat(user, "<span class='notice'>You scratch off the film covering the prizes.</span>")
				winnings = scratch(ticket_price)
				if(winnings)
					src.iswinner = TRUE
		else
			to_chat(user, "<span class='notice'>You need to use something sharp to scratch the ticket.</span>")
	else
		to_chat(user, "<span class='notice'>The film covering the prizes has already been scratched off.</span>")

/obj/item/toy/lotto_ticket/examine(mob/user)
	if(user.range_check(src))
		..()
		if(revealed)
			if(iswinner)
				to_chat(user, "<span class='notice'>This one is a winner! You've won [winnings] credits.</span>")
			else
				to_chat(user, "<span class='notice'>No wins on this one.</span>")
		else
			to_chat(user, "<span class='notice'>It hasn't been scratched off yet.</span>")
	else
		..() //Only show a regular description if it is too far away to read.
		to_chat(user, "<span class='notice'>It is too far away to read.</span>")

/obj/item/toy/lotto_ticket/update_icon()
	icon_state = initial(icon_state) + (revealed ? "_scratched" : "")

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


//Emag card
/obj/item/toy/lotto_ticket/supermatter_surprise
	name = "Supermatter Surprise lottery ticket"
	desc = "An extremely expensive scratch-off lottery ticket. Guaranteed win up to 100,000 credits!"
	icon_state = "lotto_4"
	ticket_price = 100
	var/flashed = FALSE

/obj/item/toy/lotto_ticket/supermatter_surprise/scratch()
	var/input_price = 5
	var/profit = 0
	while(!profit)
		for(var/prize = 1 to problist.len)
			if(prob(problist[prize]))
				profit = prizelist[prize]*input_price
				return profit

/obj/item/toy/lotto_ticket/supermatter_surprise/attackby(obj/item/weapon/S, mob/user)
	..()
	if(!flashed)
		if(S.is_sharp() || istype(S, /obj/item/weapon/coin))
			to_chat(user, "<span class='notice'>Removing the film emits a brilliant flash of light!</span>")
			//Radiation emission code taken from Jukebox
			emitted_harvestable_radiation(get_turf(src), 20, range = 5)	//Standing by a juke applies a dose of 17 rads to humans so we'll round based on that. 1/5th the power of a freshly born stage 1 singularity.
			for(var/mob/living/carbon/M in view(src,3))
				var/rads = 50 * sqrt( 1 / (get_dist(M, src) + 1) ) //It's like a transmitter, but 1/3 as powerful.
				M.apply_radiation(round(rads/2),RAD_EXTERNAL) //Distance/rads: 1 = 18, 2 = 14, 3 = 12
			var/flash_turf = get_turf(src)
			for(var/mob/living/M in get_hearers_in_view(3, flash_turf))
				flash(get_turf(M), M)
			flashed = TRUE