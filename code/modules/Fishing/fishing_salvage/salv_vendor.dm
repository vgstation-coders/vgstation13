/obj/machinery/vending/salvaged
	name = "salvaged vending machine"
	desc = "Covered in layers of gunk of varying ages and origins, it's obvious this old vendomat has a history, and wares to match."
	icon = ''
	icon_state = ""
	shoot_chance = 0
	accepted_coins = list(/obj/item/weapon/coin)
	maxhealth = 1000
	health = 1000
	var/capitalPissed = 0
	var/awakeThreshold =
	var/list/cheapSkates = list()

	products = list()

/obj/machinery/vending/salvaged/damaged(var/coef = 1, var/debt = 1)
	health -= 4*coef


/obj/machinery/vending/salvaged/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= 250
			capitalPissed += 5
		if(2.0)
			health -= 100
			capitalPissed += 2
		if(3.0)
			health -= 50
			capitalPissed++

/obj/machinery/vending/salvaged/emag(mob/user)
	cheapSkates += user
	closeShop()

/obj/machinery/vending/salvaged/kick_act(mob/living/carbon/human/user)
	..()
	if(!user in cheapSkates)
		cheapSkates += user
	if(prob(capitalPissed))
		closeShop()

