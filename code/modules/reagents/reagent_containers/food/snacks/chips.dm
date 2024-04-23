//////////////////CHIPS//////////////////

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps."
	icon_state = "chips"
	trash = /obj/item/trash/chips
	filling_color = "#FFB700"
	base_crumb_chance = 30
	valid_utensils = 0
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable
	name = "Plain Chips"
	desc = "Where did the bag come from?"
	icon_state = "plain_chips"
	item_state = "plain_chips"
	trash = null
	reagents_to_add = list(NUTRIMENT = 5)

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/vinegar
	name = "Salt and Vinegar Chips"
	desc = "The objectively best flavour."
	icon_state = "salt_vinegar_chips"
	item_state = "salt_vinegar_chips"
	reagents_to_add = list(NUTRIMENT = 7)

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/cheddar
	name = "Cheddar Chips"
	desc = "Dangerously cheesy."
	icon_state = "cheddar_chips"
	item_state = "cheddar_chips"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 7)

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/clown
	name = "Banana Chips"
	desc = "A clown's favourite snack!"
	icon_state = "clown_chips"
	item_state = "clown_chips"
	reagents_to_add = list(NUTRIMENT = 7, HONKSERUM = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nuclear
	name = "Nuclear Chips"
	desc = "Radioactive taste!"
	icon_state = "nuclear_chips"
	item_state = "nuclear_chips"
	reagents_to_add = list(NUTRIMENT = 7, NUKA_COLA = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/communist
	name = "Communist Chips"
	desc = "A perfect snack to share with the party!"
	icon_state = "commie_chips"
	item_state = "commie_chips"
	reagents_to_add = list(NUTRIMENT = 7, VODKA = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/xeno
	name = "Xeno Raiders"
	desc = "A great taste that is out of this world!"
	icon_state = "xeno_chips"
	item_state = "xeno_chips"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 7)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/hot
	name = "Hot Chips"
	desc = "Don't get the dust in your eyes!"
	icon_state = "hot_chips"
	item_state = "hot_chips"
	trash = null
	reagents_to_add = list(NUTRIMENT = 8, CAPSAICIN = 7)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nova
	name = "Nova Chips"
	desc = "Little disks of heat, like a bag full of tiny suns!"
	icon_state = "nova_chips"
	item_state = "nova_chips"
	trash = null
	reagents_to_add = list(NUTRIMENT = 7, NOVAFLOUR = 4, HELL_RAMEN = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/zamitos
	name = "Zamitos: Original Flavor"
	desc = "An overly processed taste that reminds you of days past when you snacked on these as a small greyling."
	trash = /obj/item/trash/chips/zamitos_o
	icon_state = "zamitos_original"
	filling_color = "#F7CE7B"
	bitesize = 0.9 // It takes a little while to chew through a bag of chips!
	reagents_to_add = list(NUTRIMENT = 2, ZAMSPICES = 5)

/obj/item/weapon/reagent_containers/food/snacks/zamitos/New()
	if(prob(30))
		name = "Zamitos: Blue Goo Flavor"
		desc = "Not as filling as the original flavor, and the texture is strange."
		trash = /obj/item/trash/chips/zamitos_bg
		icon_state = "zamitos_bluegoo"
		filling_color = "#5BC9DD"
		reagents_to_add = list(NUTRIMENT = 1, BLUEGOO = 5)
		bitesize = 0.8 // Same number of bites but less nutriment because it's the worst
	..()

/obj/item/weapon/reagent_containers/food/snacks/zamitos_stokjerky
	name = "Zamitos: Spicy Stok Jerky Flavor"
	desc = "Meat-flavored crisps with three different seasonings! Almost as good as real meat."
	trash = /obj/item/trash/chips/zamitos_sj
	icon_state = "zamitos_stokjerky"
	filling_color = "#A66626"
	reagents_to_add = list(NUTRIMENT = 6, ZAMSPICES = 2, SOYSAUCE = 2, ZAMSPICYTOXIN = 6)
	bitesize = 2 // Takes a fair few bites to finish, because why would you want to rush this?
