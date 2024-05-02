/obj/item/weapon/reagent_containers/food/snacks/salad
	name = "herb salad"
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#306900"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/salad/aesir
	name = "Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	filling_color = "#005369"
	reagents_to_add = list(NUTRIMENT = 8, TRICORDRAZINE = 8)

/obj/item/weapon/reagent_containers/food/snacks/salad/aesir/New()
	..()
	eatverb = pick("crunch", "devour", "nibble", "gnaw", "gobble", "chomp")

/obj/item/weapon/reagent_containers/food/snacks/salad/valid
	name = "valid salad"
	desc = "It's just an herb salad with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 8, DOCTORSDELIGHT = 5)

/obj/item/weapon/reagent_containers/food/snacks/salad/potato
	name = "Potato Salad"
	desc = "With 21st century technology, it could take as long as three days to make this."
	icon_state = "potato_salad"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/salad/starrynight
	name = "starry night salad"
	desc = "Eating too much of this salad may cause you to want to cut off your own ear."
	icon_state = "starrynight"
	bitesize = 2
	random_filling_colors = list("#8600C6","#306900","#9F5F2D")
	reagents_to_add = list(NUTRIMENT = 4, INACUSIATE = 1)

/obj/item/weapon/reagent_containers/food/snacks/salad/fruit
	name = "fruit salad"
	desc = "Popular among cargo technicians who break into fruit crates."
	icon_state = "fruitsalad"
	bitesize = 2
	random_filling_colors = list("#FFFF00","#FF9933","#FF3366","#CC0000")
	reagents_to_add = list(NUTRIMENT = 4)

/obj/item/weapon/reagent_containers/food/snacks/salad/nofruit
	name = "no-fruit salad"
	desc = "Attempting to make this meal cycle through other types of salad was prohibited by special council decision after six weeks of intensive debate at the central hub for Galatic International Trade."
	icon_state = "nofruitsalad"
	bitesize = 4
	reagents_to_add = list(NOTHING = 20)

/obj/item/weapon/reagent_containers/food/snacks/salad/rosolli
	name = "rosolli"
	desc = "A salad of root vegetables from Space Finland."
	icon_state = "rosolli"
	bitesize = 2
	filling_color = "#E00000"
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/salad/chinesecold
	name = "chinese cold salad"
	desc = "A whirlwind of strong flavors, served chilled. Found its origins in the old Terran nation-state of China before the rise of Space China."
	icon_state = "chinesecoldsalad"
	bitesize = 2
	random_filling_colors = list("#009900","#0066FF","#F7D795")
	trash = null
	reagents_to_add = list(NUTRIMENT = 8, FROSTOIL = 2)

/obj/item/weapon/reagent_containers/food/snacks/salad/chicken
	name = "chicken salad"
	desc = "Evokes the question: do you ruin chicken by putting it in a salad, or improve a salad by adding chicken?"
	icon_state = "chickensalad"
	bitesize = 4
	reagents_to_add = list(NUTRIMENT = 12)

/obj/item/weapon/reagent_containers/food/snacks/salad/grape
	name = "grape salad"
	desc = "Member Kingston? Member uncapped bombs? Member beardbeard? Member Goonleak? Member the vore raid? Member split departmental access? I member!"
	icon_state = "grapesalad"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 4)

/obj/item/weapon/reagent_containers/food/snacks/salad/orzo
	name = "orzo salad"
	desc = "A minty, exotic salad originating in Space Greece. Makes you feel slippery enough to escape denbts."
	icon_state = "orzosalad"
	bitesize = 4
	reagents_to_add = list(NUTRIMENT = 2, LUBE = 14)

/obj/item/weapon/reagent_containers/food/snacks/salad/mexican
	name = "mexican salad"
	desc = "A favorite of the janitorial staff, who often consider this a native dish. Viva Space Mexico!"
	icon_state = "mexicansalad"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	trash = null
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/salad/confederate
	name = "confederate spirit"
	desc = "Even in space, where a north/south orientation is meaningless, the South will rise again."
	icon_state = "confederatespirit"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	
/obj/item/weapon/reagent_containers/food/snacks/salad/tontes
	name = "tontes de pelouse"
	desc = "A fashionable dish that some critics say engages the aesthetic sensibilities of even the most refined gastronome."
	icon_state = "tontesdepelouse"
	bitesize = 3
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/salad/sauerkraut
	name = "sauerkraut"
	desc = "Cabbage that has fermented in salty brine."
	icon_state = "sauerkraut"
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/salad/coleslaw
	name = "Coleslaw"
	desc = "You fought the 'slaw, and the 'slaw won."
	icon_state = "coleslaw"
	plate_offset_y = 1
	trash = null
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 2