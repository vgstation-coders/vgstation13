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

/obj/item/toy/lotto_ticket/proc/scratch(var/input_price)
	var/list/prizelist = list(100000,50000,10000,5000,1000,500,250,100,50,20,10,5,4,3,2,1)
	var/list/problist = list(0.0001, 0.0002, 0.001, 0.002, 0.01, 0.02, 0.04, 0.2, 1, 2.5, 5, 10, 12.5, 17, 20, 25)
	var/tuning_value = 1/5 //Used to adjust expected values.
	for(var/prize = 1 to problist.len)
		if(prob(problist[prize]))
			return(prizelist[prize]*input_price*tuning_value)

/obj/item/toy/lotto_ticket/attackby(obj/item/weapon/S as obj, mob/user as mob)
	if(!src.revealed == 1)
		if(S.is_sharp() || istype(S, /obj/item/weapon/coin))
			if(do_after(user, src, 1 SECONDS))
				src.revealed = 1
				src.update_icon()
				to_chat(user, "<span class='notice'>You scratch off the film covering the prizes.</span>")
				if(istype(src,/obj/item/toy/lotto_ticket/supermatter_surprise))
					winnings = 100000
				else
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
	else if(istype(src,/obj/item/toy/lotto_ticket/supermatter_surprise))
		icon_state = "lotto_4_scratched"

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
	ticket_price = 100 //EV 100,000, ER +99,900 ;^)

/obj/item/toy/lotto_ticket/supermatter_surprise/prepickup(mob/living/user)
	if(src.revealed == 1)
		var/obj/item/supermatter_shielding/SS = locate(/obj/item/supermatter_shielding) in user.contents
		if(SS)
			SS.supermatter_act(src)
		else
			var/obj/item/clothing/gloves/golden/G = user.get_item_by_slot(slot_gloves)
			if(istype(G))
				to_chat(user,"<span class='notice'>The special lubrication on \the [G] prevents your hand from melting, but also prevents you from getting a grip.</span>")
				return 1
			var/datum/organ/external/external = user.get_active_hand_organ()
			if(external)
				user.visible_message("<span class='warning'>As \the [user] grasps onto \the [src], their [external.display_name] begins rapidly combusting!</span>", "<span class = 'warning'>As you try to get a grip onto \the [src], you feel your [external.display_name] tingle and glow, before it rapidly dissipates into ash.</span>")
				playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
				external.dust()
			return 1
	else
		return

/obj/item/toy/lotto_ticket/supermatter_surprise/kick_act(mob/living/carbon/human/user)
	if(src.revealed == 1)
		var/obj/item/supermatter_shielding/SS = locate(/obj/item/supermatter_shielding) in contents
		if(SS)
			SS.supermatter_act(src)
		else
			var/obj/shoes = user.shoes
			if(shoes)
				user.visible_message("<span class = 'warning'>As \the [user] goes to kick \the [src], their [shoes] collide with \the [src] and rapidly flash into ash.</span>")
				user.u_equip(shoes, 1)
				var/obj/O = shoes.ashtype()
				new O(user.loc)
				qdel(shoes)
			else //Oh nooo
				var/datum/organ/external/external = user.get_organ(pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))
				user.visible_message("<span class = 'warning>As \the [user] goes to punt \the [src], their [external.display_name] begins rapidly combusting!</span>", "<span class = 'warning'>As you try to kick \the [src], you feel your [external.display_name] tingle and glow, before it rapidly dissipates into ash.</span>")
				playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
				external.dust()
			return 0
	else
		return

/obj/item/toy/lotto_ticket/supermatter_surprise/bite_act(mob/living/carbon/human/user)
	if(src.revealed == 1)
		var/obj/item/supermatter_shielding/SS = locate(/obj/item/supermatter_shielding) in contents
		if(SS)
			SS.supermatter_act(src)
		else
			var/datum/organ/external/head = user.get_organ(LIMB_HEAD)
			if(head)
				user.visible_message("<span class = 'warning'>As \the [user] bites down into \the [src], their [head.display_name] begins glowing a deep crimson before turning to dust.","<span class = 'warning'>As you bite down onto \the [src], you realize that supermatter tastes oddly like cheese and pickles before your tastebuds, then your tongue, and finally your entire head ceases to be.</span>")
				playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
				head.dust()
			return 0
	else
		return

/obj/item/toy/lotto_ticket/supermatter_surprise/can_be_stored(var/obj/item/weapon/storage/S)
	if(src.revealed == 1)
		if(istype(S, /obj/item/weapon/storage/backpack/holding))
			return TRUE
		return FALSE
	else
		return