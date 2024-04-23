
////////////////////////////////
// YE ENTERING THE GUNK ZONE ///
///////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/skitter/ //if ye dish is a child of skitter it will move around after 30 ticks
	name = "skittering burger"
	desc = "A burger-shaped cockroach."
	icon_state = "bugburger"
	var/skitterdelay = 30
	var/skitterchance = 50

/obj/item/weapon/reagent_containers/food/snacks/skitter/New()
	..()
	processing_objects += src

/obj/item/weapon/reagent_containers/food/snacks/skitter/pickup(mob/user)
	timer = 0

/obj/item/weapon/reagent_containers/food/snacks/skitter/process()
	timer += 1
	if(timer > skitterdelay && istype(loc, /turf) && prob(skitterchance))
		Move(get_step(loc, pick(cardinal)))

/obj/item/weapon/reagent_containers/food/snacks/skitter/Destroy()
	processing_objects -= src
	..()

/obj/item/weapon/reagent_containers/food/snacks/skitter/gunkburger
	name = "gunk burger"
	desc = "A GunkCo classic! You will eat the bugs and you will enjoy them."
	icon_state = "bugburger"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20
	reagents_to_add = list(NUTRIMENT = 6, ROACHSHELL = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/skitter/gunkburger/New()
	if(prob(30))
		reagents_to_add = list(NUTRIMENT = 6, ROACHSHELL = 5, SALTWATER = 3) //the best non-karm emetic we have
		desc = "Legs wriggling, bug juices oozing out and that rotten smell... Oh god, you're gonna THR-"
	..()

/obj/item/weapon/reagent_containers/food/snacks/skitter/gunkburger/deluxe
	name = "deluxe gunk burger"
	desc = "GunkCo's latest innovation! You won't guess the special ingredient!"
	icon_state = "deluxebugburger"
	reagents_to_add = list(NUTRIMENT = 12, ROACHSHELL = 10)

/obj/item/weapon/reagent_containers/food/snacks/skitter/gunkburger/deluxe/New()
	if(prob(30))
		reagents_to_add = list(NUTRIMENT = 12, ROACHSHELL = 10, SALTWATER = 3) //the best non-karm emetic we have
		desc = "You can't comprehend how much I regret biting into this thing. The disgusting texture, burning juices and terrible taste will never leave my mind."
	..()

/obj/item/weapon/reagent_containers/food/snacks/skitter/gunkburger/super
	name = "Super Gunk Burger"
	desc = "The Cockroach King! Or matriarch actually. You can't even fathom eating that much cockroach."
	icon_state = "supergunkburger"
	food_flags = FOOD_MEAT | FOOD_LACTOSE | FOOD_ANIMAL
	skitterchance = 40
	skitterdelay = 60 //takes longer for super gunkburgers to walk and they walk less, muh weight or something
	reagents_to_add = list(NUTRIMENT = 40, ROACHSHELL = 15)
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/skitter/gunkburger/super/New()
	if(prob(30))
		reagents_to_add = list(NUTRIMENT = 40, ROACHSHELL = 15, SALTWATER = 3) //the best non-karm emetic we have
		desc = "I have tasted upon all the universe has to hold of gunk, and even the ambrosias and blingpizzas must ever afterward be poison to me."
	..()

/obj/item/weapon/reagent_containers/food/snacks/gunkkabob
	name = "Gunk-kabob"
	icon_state = "bugkabob"
	desc = "Not as disgusting as you'd expect!"
	trash = /obj/item/stack/rods
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, ROACHSHELL = 5, SALINE = 0.5) //just a taste
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soup/gunk
	name = "Gunk Soup"
	desc = "Smells like a garbage can."
	icon_state = "gunksoup"
	food_flags = FOOD_MEAT | FOOD_LIQUID
	filling_color = "#6D4930"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 8, ROACHSHELL = 5, WATER = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/gunk/embassy
	name = "Gunk Soup Embassy"
	desc = "Space Turkey's finest politicians are sent to this elite GunkCo facility."
	icon_state = "gunksoup_embassy_2" //here so it isn't invisible on nofruit pie rolls, gets overwritten on new()
	reagents_to_add = list(NUTRIMENT = 10, ROACHSHELL = 8, WATER = 5) //we lobbied for extra nutriment for you! no roaches were harmed this time, it's all exoskeleton flakes

/obj/item/weapon/reagent_containers/food/snacks/soup/gunk/embassy/New()
	..()
	if(prob(50))  //two flag waving styles
		icon_state = "gunksoup_embassy_1"
	else
		icon_state = "gunksoup_embassy_2"
	processing_objects += src
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/soup/gunk/embassy/process()
	timer += 1
	if(prob(20) && timer >= 10)
		timer = 0
		if(prob(50))
			icon_state = "gunksoup_embassy_1"
		else
			icon_state = "gunksoup_embassy_2"

/obj/item/weapon/reagent_containers/food/snacks/soup/gunk/embassy/Destroy()
	processing_objects -= src
	new /mob/living/simple_animal/cockroach/turkish(get_turf(src))
	new /mob/living/simple_animal/cockroach/turkish(get_turf(src))
	..()

/obj/item/weapon/reagent_containers/food/snacks/sliceable/gunkbread
	name = "gunkbread loaf"
	desc = "At some point you have to wonder not if you COULD make bread with garbage, but rather if you SHOULD."
	icon_state = "gunkbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/gunkbreadslice
	slices_num = 5
	storage_slots = 3
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	w_class = W_CLASS_MEDIUM
	reagents_to_add = list(NUTRIMENT = 30, ROACHSHELL = 5, CHEMICAL_WASTE = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/gunkbreadslice
	name = "gunkbread slice"
	desc = "Ahh, the smell of the maintenance hallways in bread form."
	icon_state = "gunkbreadslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE
	plate_offset_y = -4

/obj/item/weapon/reagent_containers/food/snacks/pie/gunkpie
	name = "gunk pie"
	desc = "Surprisingly free of toxins!"
	icon_state = "gunkpie"
	food_flags = FOOD_MEAT
	reagents_to_add = list(NUTRIMENT = 5, ROACHSHELL = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/gunk_pie/New()
	if(prob(30))
		reagents_to_add = list(NUTRIMENT = 5, ROACHSHELL = 5, CHEMICAL_WASTE = 5, SALINE = 1)
		desc = "The flavour of the maintenance halls in pie form."
	..()

/obj/item/weapon/reagent_containers/food/snacks/sliceable/gunkcake
	name = "gunk cake"
	desc = "The apex of garbage-based confectionary research."
	icon_state = "gunkcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/gunkcakeslice
	slices_num = 5
	storage_slots = 3
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 25, ROACHSHELL = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/gunkcakeslice
	name = "gunk cake slice"
	desc = "Your nose hairs recoil at the fumes coming out of this."
	icon_state = "gunkcakeslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = -1
