/obj/item/toy/lotto_ticket
	name = "scratch-off lotto ticket"
	desc = "A scratch-off lotto ticket."
	icon = 'icons/obj/toy.dmi'
	w_class = W_CLASS_TINY
	var/revealed = FALSE
	var/iswinner = FALSE
	var/prize_multiplier
	var/winnings = 0
	var/list/prizelist = list(100000,50000,10000,5000,1000,500,250,100,50,20,10,5,4,3,2,1)
	var/list/problist = list(0.0001, 0.0002, 0.001, 0.002, 0.01, 0.02, 0.04, 0.2, 1, 2.5, 5, 10, 12.5, 17, 20, 25)
	var/tuning_value = 1/5 //Used to adjust expected values.

/obj/item/toy/lotto_ticket/New()
	..()
	pixel_y = rand(-8, 8) * PIXEL_MULTIPLIER
	pixel_x = rand(-9, 9) * PIXEL_MULTIPLIER

/obj/item/toy/lotto_ticket/proc/scratch(var/input_prize_multiplier, var/mob/user)
	var/profit = 0
	var/luck = user?.luck()
	for(var/prize = 1 to problist.len)
		var/thisprob = problist[prize]
		//Take luck into account.
		if(user ? user.lucky_prob(thisprob, luckfactor = 1/12000, maxskew = 49.9, ourluck = luck) : prob(thisprob))
			profit = prizelist[prize] * prize_multiplier * tuning_value
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
		if(!user.is_holding_item(src) && istype(src,/obj/item/toy/lotto_ticket/supermatter_surprise))
			to_chat(user, "<span class='notice'>The special film is too tough to scratch without holding the ticket in your hand!</span>")
			return 1
		if(S.is_sharp() || istype(S, /obj/item/weapon/coin))
			if(do_after(user, src, 1 SECONDS))
				src.revealed = TRUE
				src.update_icon()
				to_chat(user, "<span class='notice'>You scratch off the film covering the prizes.</span>")
				winnings = scratch(prize_multiplier, user)
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
	prize_multiplier = 5 //EV 4.55, ER -0.45

//Tier 2 card
/obj/item/toy/lotto_ticket/diamond_hands
	name = "Diamond Hands lottery ticket"
	desc = "A mid-price scratch-off lottery ticket. Win up to 400,000 credits!"
	icon_state = "lotto_2"
	prize_multiplier = 20 //EV 18.20, ER -1.80

//Tier 3 card
/obj/item/toy/lotto_ticket/phazon_fortune
	name = "Phazon Fortune lottery ticket"
	desc = "An expensive scratch-off lottery ticket. Win up to 1,000,000 credits!"
	icon_state = "lotto_3"
	prize_multiplier = 50 //EV 45.50, ER -4.50

//Emag card
/obj/item/toy/lotto_ticket/supermatter_surprise
	name = "Supermatter Surprise lottery ticket"
	desc = "An extremely expensive scratch-off lottery ticket. Guaranteed win of up to 5,000,000 credits! Experimental film material - use at your own risk!"
	icon_state = "lotto_4"
	prize_multiplier = 50
	tuning_value = 1
	var/flashed = FALSE

/obj/item/toy/lotto_ticket/supermatter_surprise/attackby(obj/item/weapon/S, mob/user)
	..()
	if(!flashed)
		if(!user.is_holding_item(src))
			return 1
		if(S.is_sharp() || istype(S, /obj/item/weapon/coin))
			to_chat(user, "<span class='notice'>Removing the film emits a brilliant flash of light!</span>")
			var/flash_turf = get_turf(src)
			for(var/mob/living/M in get_hearers_in_view(3, flash_turf))
				flash(get_turf(M), M)
			flashed = TRUE
			playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
			var/obj/item/supermatter_shielding/SS = locate(/obj/item/supermatter_shielding) in user.contents
			if(SS)
				SS.supermatter_act(src)
			else
				var/obj/item/clothing/gloves/golden/G = user.get_item_by_slot(slot_gloves)
				if(istype(G))
					to_chat(user,"<span class='notice'>The special lubrication on \the [G] prevents your hand from melting. That was a close one!</span>")
					return 1
				var/datum/organ/external/external = user.get_active_hand_organ()
				if(external)
					user.visible_message("<span class='warning'>As \the [user] grasps onto \the [src], their [external.display_name] begins rapidly combusting!</span>", "<span class = 'warning'>As you try to get a grip onto \the [src], you feel your [external.display_name] tingle and glow, before it rapidly dissipates into ash.</span>")
					playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
					external.dust()
				return 1

//Unprinted card
/obj/item/toy/lotto_ticket/unprinted
	name = "unprinted lottery ticket"
	desc = "A worthless, unprinted lotto ticket."
	icon_state = "lotto_5"
	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1

/obj/item/toy/lotto_ticket/unprinted/attackby(obj/item/weapon/S, mob/user)
	return 0