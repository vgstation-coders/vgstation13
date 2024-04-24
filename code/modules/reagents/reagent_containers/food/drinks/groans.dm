
/obj/item/weapon/reagent_containers/food/drinks/groans
	name = "Groans Soda"
	desc = "Groans Soda: We'll make you groan."
	icon_state = "groans"
	randpix = TRUE
	reagents_to_add = list(DISCOUNT = 10)

/obj/item/weapon/reagent_containers/food/drinks/groans/New()
	switch(rand(1,5))
		if(1)
			name = "Groans Soda: Cuban Spice Flavor"
			desc = "Warning: Long exposure to liquid inside may cause you to follow the rumba beat."
			icon_state += "_hot"
			reagents_to_add += list(CONDENSEDCAPSAICIN = 10, RUM = 10)
		if(2)
			name = "Groans Soda: Icey Cold Flavor"
			desc = "Cold in a can. Er, bottle."
			icon_state += "_cold"
			reagents_to_add += list(FROSTOIL= 10, ICE = list("volume" = 10,"temp" = T0C))
		if(3)
			name = "Groans Soda: Zero Calories"
			desc = "Zero Point Calories. That's right, we fit even MORE nutriment in this thing."
			icon_state += "_nutriment"
			reagents_to_add += list(NUTRIMENT = 20)
		if(4)
			name = "Groans Soda: Energy Shot"
			desc = "Warning: The Groans Energy Blend(tm), may be toxic to those without constant exposure to chemical waste. Drink responsibly."
			icon_state += "_energy"
			reagents_to_add += list(CORNSYRUP = 10, CHEMICAL_WASTE = 10)
		if(5)
			name = "Groans Soda: Double Dan"
			desc = "Just when you thought you've had enough Dan, The 'Double Dan' strikes back with this wonderful mixture of too many flavors. Bring a barf bag, Drink responsibly."
			icon_state += "_doubledew"
			reagents_to_add = list(DISCOUNT = 30)
	..()

/obj/item/weapon/groans
	name = "Groan-o-matic 9000"
	desc = "This is for testing reasons."
	icon_state = "toddler"

/obj/item/weapon/groans/attack_self(mob/user as mob)
	to_chat(user, "Now spawning groans.")
	var/turf/T = get_turf(user.loc)
	var/obj/item/weapon/reagent_containers/food/drinks/groans/A = new /obj/item/weapon/reagent_containers/food/drinks/groans(T)
	A.desc += " It also smells like a toddler." //This is required

/obj/item/weapon/reagent_containers/food/drinks/filk
	name = "Filk"
	desc = "Only the best Filk for your crew."
	icon_state = "filk"
	randpix = TRUE
	reagents_to_add = list(DISCOUNT = 10)

/obj/item/weapon/reagent_containers/food/drinks/filk/New()
	switch(rand(1,5))
		if(1)
			name = "Filk: Chocolate Edition"
			reagents_to_add += list(HOT_COCO = 10)
		if(2)
			name = "Filk: Scripture Edition"
			reagents_to_add += list(HOLYWATER = 30)
		if(3)
			name = "Filk: Carribean Edition"
			reagents_to_add += list(RUM = 30)
		if(4)
			name = "Filk: Sugar Blast Editon"
			reagents_to_add += list(SUGAR = 30, RADIUM = 10, TOXICWASTE = 10) // le epik fallout may mays
		if(5)
			name = "Filk: Pure Filk Edition"
			reagents_to_add = list(DISCOUNT = 30)
	..()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo
	name = "Grifeo"
	desc = "A quality drink."
	icon_state = "griefo"
	randpix = TRUE
	reagents_to_add = list(DISCOUNT = 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo/New()
	switch(rand(1,5))
		if(1)
			name = "Grifeo: Spicy"
			reagents_to_add += list(CONDENSEDCAPSAICIN = 30)
		if(2)
			name = "Grifeo: Frozen"
			reagents_to_add += list(FROSTOIL = 30)
		if(3)
			name = "Grifeo: Crystallic"
			reagents_to_add += list(CORNSYRUP = 20, ICE = list("volume" = 20,"temp" = T0C), SPACE_DRUGS = 20)
		if(4)
			name = "Grifeo: Rich"
			reagents_to_add += list(TEQUILA = 10, CHEMICAL_WASTE = 10)
		if(5)
			name = "Grifeo: Pure"
			reagents_to_add = list(DISCOUNT = 30)
	..()

/obj/item/weapon/reagent_containers/food/drinks/groansbanned
	name = "Groans: Banned Edition"
	desc = "Banned literally everywhere."
	icon_state = "groansevil"
	randpix = TRUE
	reagents_to_add = list(DISCOUNT = 10)

/obj/item/weapon/reagent_containers/food/drinks/groansbanned/New()
	switch(rand(1,5))
		if(1)
			name = "Groans Banned Soda: Fish Suprise"
			reagents_to_add += list(CARPOTOXIN = 10)
		if(2)
			name = "Groans Banned Soda: Bitter Suprise"
			reagents_to_add += list(TOXIN = 20)
		if(3)
			name = "Groans Banned Soda: Sour Suprise"
			reagents_to_add += list(PACID = 20)
		if(4)
			name = "Groans Banned Soda: Sleepy Suprise"
			reagents_to_add += list(STOXIN = 10)
		if(5)
			name = "Groans Banned Soda: Quadruple Dan"
			reagents_to_add = DISCOUNT
	..()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/mannsdrink
	name = "Mann's Drink"
	desc = "The only thing a <B>REAL MAN</B> needs."
	icon_state = "mannsdrink"
	randpix = TRUE
	reagents_to_add = list(DISCOUNT = 30, MANNITOL = 20)
