/obj/item/weapon/reagent_containers/food/snacks/fishcuit
	name = "fishcuit"
	desc = "The snack that smiles back, fishcuit."
	icon = ''
	icon_state = ""
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	var/flavorTown = 0

/obj/item/weapon/reagent_containers/food/snacks/fishcuit/angler_effect(obj/item/weapon/bait/baitUsed)
	flavorTown = (baitUsed.catchPower/20) * baitUsed.catchSizeMult + baitUsed.catchSizeAdd
	addFlavor()

/obj/item/weapon/reagent_containers/food/snacks/fishcuit/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(SUGAR, 2)
	reagents.add_reagent(CARAMEL, 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishcuit/proc/addFlavor()
	reagents.add_reagent(HONEY, rand(0, flavorTown))
	reagents.add_reagent(DOCTORSDELIGHT, rand(0, flavorTown))
	if(flavorTown >= 10 && prob(flavorTown))
		reagents.add_reagent(DIABEETUSOL, rand(0, flavorTown/2))	//Oh fuck we're too delicious

/obj/item/weapon/reagent_containers/food/snacks/fishcuit/preattack(atom/target, mob/user , proximity)
	if(isfish(target))	//Note to self: Make this a macro that exists
		var/mob/living/simple_animal/hostile/fishing/theFish = target
		if(!theFish.isDead())
			fishFeed(src, user)	//Essentially a universal taming item
