////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////

//Food is basically a glorified beaker with a lot of fancy coding. Now you know, and knowing is half the battle
/obj/item/weapon/reagent_containers/food
	icon = 'icons/obj/food.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/food.dmi', "right_hand" = 'icons/mob/in-hand/right/food.dmi')
	possible_transfer_amounts = null
	volume = 50 //Food can contain a beaker's worth of reagents unless specified otherwise. Do note large servings of complex food items can contain well over 50 reagents total

/obj/item/weapon/reagent_containers/food/New()
		..()
		src.pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER	//Randomizes position slightly.
		src.pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER

/obj/item/weapon/reagent_containers/food/fits_in_iv_drip()
	return 1

/obj/item/weapon/reagent_containers/food/dipping_sauce
	var/dip_message = ""

/obj/item/weapon/reagent_containers/food/dipping_sauce/update_icon()
	if(!reagents || !reagents.has_reagent(DIPPING_SAUCE))
		reagents.clear_reagents()
		icon_state = "empty_dip"
		desc = "It's all empty now."
	else
		icon_state = initial(icon_state)
		desc = initial(desc)

/obj/item/weapon/reagent_containers/food/dipping_sauce/New()
	..()
	reagents.add_reagent(DIPPING_SAUCE,30)

/obj/item/weapon/reagent_containers/food/dipping_sauce/attackby(obj/item/weapon/reagent_containers/food/snacks/S, mob/user) //Dipping sauce is not a snack because you can't just pick it up and eat it. Instead, you need to dip snacks in it.
	if(..()) return
	if(istype(S))
		if(!reagents.has_reagent(DIPPING_SAUCE))
			update_icon()
			to_chat(user,"<span class='warning'>\The [src] is out of dip!</span>")
		if(S.reagents.has_reagent(DIPPING_SAUCE))
			to_chat(user,"<span class='warning'>\The [S] has already been dipped!</span>")
			return 1
		reagents.trans_to(S,3)
		visible_message("<span class='notice'>[user] dips \the [S] in \the [src]. [prob(30) ? "[dip_message]" : ""]</span>")
		if(istype(S,/obj/item/weapon/reagent_containers/food/snacks/tortillachip))
			S.desc = "A particularly delicious morsel!"
		update_icon()
	return 1

/obj/item/weapon/reagent_containers/food/dipping_sauce/queso
	name = "queso"
	desc = "A classic dipping sauce that you can't go wrong with."
	icon_state = "queso"
	dip_message = "It's a flavor fiesta!"

/obj/item/weapon/reagent_containers/food/dipping_sauce/guacamole
	name = "guacamole"
	desc = "The original recipe calls for avocado, but this space-age substitute has supplanted the ancient style in popularity."
	icon_state = "guacamole"
	dip_message = "Taste the tang!"

/obj/item/weapon/reagent_containers/food/dipping_sauce/salsa
	name = "salsa"
	desc = "A spicy dipping sauce popular among cosmopolitan spaceports."
	icon_state = "salsa"
	dip_message = "Arriba arriba!"

/obj/item/weapon/reagent_containers/food/dipping_sauce/hummus
	name = "hummus"
	desc = "The name 'hummus' literally means 'chickpeas', but this variant on the dip has gained popularity in New Mecca, on Helion Prime."
	icon_state = "hummus"
	dip_message = "God is good!"

/obj/item/weapon/chipbasket
	name = "basket of tortilla chips"
	icon = 'icons/obj/food.dmi'
	icon_state = "chipbasket-full"

/obj/item/weapon/chipbasket/New()
	..()
	for(var/i = 1 to 10)
		new /obj/item/weapon/reagent_containers/food/snacks/tortillachip(src)

/obj/item/weapon/chipbasket/update_icon()
	if(contents.len>5)
		icon_state = "chipbasket-full"
	else if(contents.len)
		icon_state = "chipbasket-half"
	else
		icon_state = "chipbasket-empty"

/obj/item/weapon/chipbasket/attack_hand(mob/user)
	if(contents)
		user.put_in_hands(pick(contents)) //Pick out a chip at random
		update_icon()
	else
		MouseDropFrom(user)

/obj/item/weapon/chipbasket/attackby(obj/item/weapon/reagent_containers/food/snacks/tortillachip/T, mob/user)
	if(..()) return
	if(istype(T))
		if(contents.len >= 10)
			to_chat(user, "<span class='warning'>The basket is full!</span>")
			return
		user.drop_item(T, src) //This chip could be spiked or have a bite missing - we want to store it for later.
		update_icon()

/obj/item/weapon/chipbasket/MouseDropFrom(over_object)
	if(!usr.incapacitated() && (usr.contents.Find(src) || Adjacent(usr)) && usr.empty_hand_indexes_amount() && usr == over_object)
		usr.put_in_hands(src)
		usr.visible_message("<span class='notice'>[usr] picks up the [src].</span>", "<span class='notice'>You pick up \the [src].</span>")

/obj/item/weapon/reagent_containers/food/snacks/tortillachip
	name = "tortilla chip"
	desc = "Bland without dipping sauce."
	bitesize = 4
	icon_state = "tortillachip"

/obj/item/weapon/reagent_containers/food/snacks/tortillachip/New()
	..()
	reagents.add_reagent(NUTRIMENT,1)

/obj/structure/poutineocean
	name = "poutine ocean"
	desc = "This enormous, horrific cheese wheel is filled to the brim with poutine. You'll probably never reach the bottom."
	icon = 'icons/obj/food_huge.dmi'
	icon_state = "poutineocean"
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -8 * PIXEL_MULTIPLIER
	var/type_to_dispense = /obj/item/weapon/reagent_containers/food/snacks/poutine

/obj/structure/poutineocean/attack_hand(mob/user)
	to_chat(user, "<span class='warning'>You need a plate to get food from \the [src]!</span>")

/obj/structure/poutineocean/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/trash/plate))
		if(user.drop_item(W))
			qdel(W)
			var/obj/item/AM = new type_to_dispense(get_turf(src))
			user.put_in_hands(AM)
			user.visible_message("<span class='notice'>[user] gathers some [AM.name] from \the [src], and shovels it onto their plate!</span>", "<span class='notice'>You gather some [AM.name] from \the [src], and shovel it onto your plate!</span>")
			return
	..()

/obj/structure/poutineocean/MouseDropFrom(over_object)
	return

/obj/structure/poutineocean/poutinecitadel
	name = "poutine citadel"
	desc = "O, Canada!"
	icon = 'icons/obj/food_huge.dmi'
	icon_state = "poutinecitadel"
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -8 * PIXEL_MULTIPLIER
	type_to_dispense = /obj/item/weapon/reagent_containers/food/snacks/poutinesyrup
