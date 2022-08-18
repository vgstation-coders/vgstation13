
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//                                            SERVICE ORDERS                                                //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//8 orders

//-------------------------------------------------Chef----------------------------------------------------

/datum/centcomm_order/department/civilian
	acct_by_string = "Civilian"

/datum/centcomm_order/per_unit/department/civilian
	name = "Nanotrasen Farmers United"
	acct_by_string = "Civilian"

/datum/centcomm_order/department/civilian/food
	var/sauce = 0//I SAID I WANTED KETCHUP
	request_consoles_to_notify = list(
		"Kitchen",
		"Hydroponics",
		)

/datum/centcomm_order/department/civilian/food/New()
	..()
	var/chosen_food = rand(1,7)
	switch(chosen_food)
		if (1)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/pie = rand(3,12)
			)
			worth = 30*requested[requested[1]]
			name = "Clown Federation" //honk
			//no sauce for those, we know they're not gonna eat them
		if (2)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen = rand(1,3)
			)
			worth = 200*requested[requested[1]]
			sauce = 1
		if (3)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/superbiteburger = rand(1,3)
			)
			worth = 300*requested[requested[1]]
			sauce = 2
		if (4)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey = rand(1,2)
			)
			worth = 400*requested[requested[1]]
			sauce = 2
		if (5)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/bleachkipper = rand(2,5)
			)
			worth = 300*requested[requested[1]]
		if (6)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/potentham = rand(1,2)
			)
			worth = 1000*requested[requested[1]]
		if (7)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/sundayroast = rand(1,2)
			)
			worth = 700*requested[requested[1]]
			sauce = 2
	if (sauce && prob(60))
		worth += 100
		switch (sauce)
			if (1)//sweet
				sauce = pick(
					/datum/reagent/sugar,
					/datum/reagent/caramel,
					/datum/reagent/honey,
					/datum/reagent/honey/royal_jelly,
					/datum/reagent/cinnamon,
					/datum/reagent/coco)
			else//salty
				sauce = pick(
					/datum/reagent/mayo,
					/datum/reagent/ketchup,
					/datum/reagent/mustard,
					/datum/reagent/capsaicin,
					/datum/reagent/soysauce,
					/datum/reagent/vinegar)
		var/datum/reagent/R = sauce
		extra_requirements = "With some [initial(R.name)] as well. Don't forget the sauce or the dish won't be accepted."


/datum/centcomm_order/department/civilian/food/ExtraChecks(var/obj/item/weapon/reagent_containers/food/snacks/F)
	if (!istype(F))
		return 0
	if (!sauce)
		return 1
	if (F.reagents?.has_reagent_type(sauce, amount = -1, strict = 1))
		return 1
	return 0

/datum/centcomm_order/department/civilian/food/BuildToExtraChecks(var/obj/item/weapon/reagent_containers/food/snacks/F)
	if (istype(F) && sauce)
		F.reagents.add_reagent(sauce,F.reagents.maximum_volume)


/datum/centcomm_order/department/civilian/poutinecitadel/New()
	..()
	request_consoles_to_notify = list(
		"Kitchen",
		)
	requested = list(
		/obj/structure/poutineocean/poutinecitadel = 1
	)
	must_be_in_crate = 0
	worth = 1200

/datum/centcomm_order/department/civilian/popcake/New()
	..()
	request_consoles_to_notify = list(
		"Kitchen",
		)
	requested = list(
		/obj/structure/popout_cake = 1
	)
	must_be_in_crate = 0
	worth = 1000

//-------------------------------------------------Botany----------------------------------------------------


/datum/centcomm_order/department/civilian/novaflower/New()
	..()
	request_consoles_to_notify = list(
		"Hydroponics",
		)
	requested = list(
		/obj/item/weapon/grown/novaflower = rand(3,8)
	)
	worth = 70*requested[requested[1]]


/datum/centcomm_order/per_unit/department/civilian/potato/New()
	..()
	request_consoles_to_notify = list(
		"Hydroponics",
		)
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = rand(50,200)
	)
	unit_prices=list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = 5
	)
	worth = "5$ per potato"


/datum/centcomm_order/per_unit/department/civilian/honeycomb
	var/flavor
	request_consoles_to_notify = list(
		"Hydroponics",
		)

/datum/centcomm_order/per_unit/department/civilian/honeycomb/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/honeycomb = rand(4,20)
	)
	if (prob(50))
		unit_prices=list(
			/obj/item/weapon/reagent_containers/food/snacks/honeycomb = 20
		)
		worth = "20$ per honeycomb"
		flavor = pick(
			/datum/reagent/drink/applejuice,
			/datum/reagent/drink/grapejuice,
			/datum/reagent/drink/banana,
			)
	else
		unit_prices=list(
			/obj/item/weapon/reagent_containers/food/snacks/honeycomb = 60
		)
		worth = "60$ per honeycomb"
		flavor = pick(
			/datum/reagent/blood,
			/datum/reagent/psilocybin,
			/datum/reagent/hyperzine/cocaine,
			)//we've got some interesting honey enthusiasts over at Central Command

	var/datum/reagent/F = flavor
	name_override = list(
		/obj/item/weapon/reagent_containers/food/snacks/honeycomb = "[initial(F.name)]-flavored Honeycombs"
	)
	extra_requirements = "The flavor has to be natural, and not injected into the honeycomb."

/datum/centcomm_order/per_unit/department/civilian/honeycomb/ExtraChecks(var/obj/item/weapon/reagent_containers/food/snacks/honeycomb/H)
	if (!istype(H))
		return 0
	if (!flavor)
		return 1
	if (!H.verify())
		return 0
	if (H.reagents?.has_reagent_type(flavor, amount = -1, strict = 1))
		return 1
	return 0

/datum/centcomm_order/per_unit/department/civilian/honeycomb/BuildToExtraChecks(var/obj/item/weapon/reagent_containers/food/snacks/honeycomb/H)
	if (istype(H) && flavor)
		H.reagents.add_reagent(flavor,H.reagents.maximum_volume)

/datum/centcomm_order/department/civilian/salmon/New()
	..()
	request_consoles_to_notify = list(
		"Hydroponics",
		)
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/salmonmeat = rand(3,8)
	)
	worth = 130*requested[requested[1]]


//---------------------------------------------------Bar----------------------------------------------------


/datum/centcomm_order/department/civilian/custom_drink
	var/grown
	request_consoles_to_notify = list(
		"Bar",
		)

/datum/centcomm_order/department/civilian/custom_drink/New()
	..()
	grown = pick(
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
		/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple,
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes,
		/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/pear,
		/obj/item/weapon/reagent_containers/food/snacks/grown/aloe,
		)
	var/obj/item/weapon/reagent_containers/food/snacks/grown/G = grown
	var/chosen_drink = rand(1,5)
	switch(chosen_drink)
		if (1)
			requested = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/wine = rand(1,6)
			)
			name_override = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/wine = "[initial(G.name)] wine"
			)
		if (2)
			requested = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/whiskey = rand(1,6)
			)
			name_override = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/whiskey = "[initial(G.name)] whiskey"
			)
		if (3)
			requested = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vermouth = rand(1,6)
			)
			name_override = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vermouth = "[initial(G.name)] vermouth"
			)
		if (4)
			requested = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vodka = rand(1,6)
			)
			name_override = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vodka = "[initial(G.name)] vodka"
			)
		if (5)
			requested = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/ale = rand(1,6)
			)
			name_override = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/ale = "[initial(G.name)] ale"
			)
	worth = 100*requested[requested[1]]

/datum/centcomm_order/department/civilian/custom_drink/ExtraChecks(var/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/C)
	if (!istype(C))
		return 0
	if (!grown)
		return 1
	for(var/obj/item/weapon/reagent_containers/food/snacks/S in C.ingredients)
		var/ok = 0
		var/ruined = 0
		if (istype(S, grown))
			ok = 1
		else
			ruined = 1
		if (ok && !ruined)
			return 1
	return 0

/datum/centcomm_order/department/civilian/custom_drink/BuildToExtraChecks(var/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/C)
	if (istype(C) && grown)
		C.ingredients.Add(new grown)
