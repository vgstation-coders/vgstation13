//Refer to game/centcomm_orders.dm

/datum/event/centcomm_order


/datum/event/centcomm_order/start()
	var/datum/centcomm_order/C = new
	C.name = command_name()
	if(prob(50))
		C.must_be_in_crate = rand(0,1)

	//Who is it paying to
	var/department = pick("Cargo","Medical","Science")
	var/list/choices
	C.acct = department_accounts[department]
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

		if("Science")
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
		if("Medical")
			choices = list(
				list(
					"item" = /obj/item/organ/internal/kidneys,
					"amount" = rand(1,3),
					"value" = rand(300,900),
					),
				list(
					"item" = /obj/item/organ/external/head,
					"amount" = rand(1,2),
					"value" = rand(250,750),
					)
				)


	var/list/chosen = pick(choices)
	var/item = chosen["item"]
	var/amount = chosen["amount"]
	var/value = chosen["value"]
	var/list/product = list(item)
	product[item] = amount
	C.requested = product
	C.worth = value
	C.acct_by_string = department
	supply_shuttle.add_centcomm_order(C)