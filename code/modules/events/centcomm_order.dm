//Refer to game/centcomm_orders.dm

/datum/event/centcomm_order

/datum/event/centcomm_order/can_start()
	return 25

/datum/event/centcomm_order/start()
	var/datum/centcomm_order/C = new
	C.name = command_name()
	if(prob(50))
		C.must_be_in_crate = rand(0,1)

	//Who is it paying to
	var/department = pick("Cargo","Medical","Science","Civilian")
	var/list/choices
	C.acct = department_accounts[department]
	C.acct_by_string = department
	switch(department)
		if("Cargo") //Minerals
			choices = list(
				list(
					"item" = /obj/item/stack/sheet/mineral/diamond,
					"amount" = rand(5,50),
					"value" = rand(400, 2500)
					),
				list(
					"item" = /obj/item/stack/sheet/mineral/uranium,
					"amount" = rand(5,50),
					"value" = rand(200, 1500)
					),
				list(
					"item" = /obj/item/stack/sheet/mineral/gold,
					"amount" = rand(5,50),
					"value" = rand(200, 1500)
					),
				list(
					"item" = /obj/item/stack/sheet/mineral/silver,
					"amount" = rand(5,50),
					"value" = rand(200, 1500)
					),
				list(
					"item" = /obj/item/stack/sheet/mineral/phazon,
					"amount" = rand(1,10),
					"value" = rand(400, 5000)
					),
				list(
					"item" = /obj/item/stack/sheet/mineral/clown,
					"amount" = rand(1,10),
					"value" = rand(200, 3500)
					)
				)

		if("Science") //Guns
			choices = list(
				list(
					"item" = /obj/item/weapon/gun/energy/gun/nuclear,
					"amount" = rand(1,5),
					"value" = rand(350,1250),
					),
				list(
					"item" = /obj/item/weapon/subspacetunneler,
					"amount" = rand(1,3),
					"value" = rand(350,1250),
					)
				)
		if("Medical") //Stolen organs
			choices = list(
				list(
					"item" = /obj/item/organ/internal/kidneys,
					"amount" = rand(1,3),
					"value" = rand(300,900),
					),
				)
		if("Civilian") //FOOD
			choices = list(
				list(
					"item" = /obj/item/weapon/reagent_containers/food/snacks/pie,
					"amount" = rand(3,12),
					"value" = rand(60,190),
					"name_override" = "Clown Federation" //Honk
					),
				list(
					"item" = /obj/structure/poutineocean/poutinecitadel,
					"amount" = 1,
					"value" = rand(1000,3000),
					),
				list(
					"item" = /obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen,
					"amount" = rand(1,3),
					"value" = rand(150,700),
					),
				list(
					"item" = /obj/item/weapon/reagent_containers/food/snacks/superbiteburger,
					"amount" = rand(1,3),
					"value" = rand(300,800),
					),
				list(
					"item" = /obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey,
					"amount" = rand(1,2),
					"value" = rand(100,400),
					),
				list(
					"item" = /obj/structure/popout_cake,
					"amount" = 1,
					"value" = rand(600,2000),
					),
				list(
					"item" = /obj/item/weapon/reagent_containers/food/snacks/bleachkipper,
					"amount" = rand(2,5),
					"value" = rand(120,500),
					),
				list(
					"item" = /obj/item/weapon/reagent_containers/food/snacks/potentham,
					"amount" = rand(1,2),
					"value" = rand(400,2001),
					),
				list(
					"item" = /obj/item/weapon/reagent_containers/food/snacks/sundayroast,
					"amount" = rand(1,2),
					"value" = rand(400,900),
					),
				)


	var/list/chosen = pick(choices)
	var/item = chosen["item"]
	var/amount = chosen["amount"]
	var/value = chosen["value"]
	if(chosen["name_override"])
		C.name = chosen["name_override"]
	var/list/product = list(item)
	product[item] = amount
	C.requested = product
	C.worth = value
	C.acct_by_string = department
	SSsupply_shuttle.add_centcomm_order(C)