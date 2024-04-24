
/obj/item/weapon/reagent_containers/food/snacks/eggplantparm
	name = "Eggplant Parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spaghetti
	name = "Spaghetti"
	desc = "Now thats a nice pasta!"
	icon_state = "spaghetti"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 1)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/fishandchips
	name = "Fish and Chips"
	desc = "I do say so myself, chap."
	icon_state = "fishandchips"
	food_flags = FOOD_MEAT
	base_crumb_chance = 20
	reagents_to_add = list(NUTRIMENT = 6, CARPPHEROMONES = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/mommispaghetti
	name = "bowl of MoMMi spaghetti"
	desc = "You can feel the autism in this one."
	icon_state = "mommispaghetti"
	base_crumb_chance = 0
	reagents_to_add = list(AUTISTNANITES = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti
	name = "Boiled Spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spaghettiboiled"
	restraint_resist_time = 1 SECONDS
	toolsounds = list('sound/weapons/cablecuff.ogg')
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pastatomato
	name = "Spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6, TOMATOJUICE = 10)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon_state = "copypasta"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 12, TOMATOJUICE = 20)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti
	name = "Spaghetti & Meatballs"
	desc = "Now thats a nic'e meatball!"
	icon_state = "meatballspaghetti"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/crabspaghetti
	name = "Crab Spaghetti"
	desc = "Goes well with Coffee."
	icon_state = "crabspaghetti"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spesslaw
	name = "Spesslaw"
	desc = "A lawyer's favorite."
	icon_state = "spesslaw"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/risotto
	name = "Risotto"
	desc = "For the gentleman's wino, this is an offer one cannot refuse."
	icon_state = "risotto"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 4, WINE = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chilaquiles
	name = "chilaquiles"
	desc = "The salsa-equivalent of nachos."
	icon_state = "chilaquiles"
	bitesize = 1
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)

/obj/item/weapon/reagent_containers/food/snacks/quiche
	name = "quiche"
	desc = "The queechay has a long history of being mispronounced. Just a taste makes you feel more cerebral and cultured!"
	icon_state = "quiche"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	bitesize = 4
	plate_offset_y = -1
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, METHYLIN = 5)

/obj/item/weapon/reagent_containers/food/snacks/minestrone
	name = "minestrone"
	desc = "It's a me, minestrone."
	icon_state = "minestrone"
	bitesize = 4
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, IMIDAZOLINE = 2)

/obj/item/weapon/reagent_containers/food/snacks/gazpacho
	name = "gazpacho"
	desc = "A cool, refreshing soup originating in Space Spain's desert homeworld."
	icon_state = "gazpacho"
	bitesize = 4
	crumb_icon = "dribbles"
	filling_color = "#FF3300"
	valid_utensils = UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 12, FROSTOIL = 6)

/obj/item/weapon/reagent_containers/food/snacks/bruschetta
	name = "bruschetta"
	desc = "This dish's name probably originates from 'to roast over coals'. You can blame the hippies for banning coal use when the crew complains it isn't authentic."
	icon_state = "bruschetta"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	bitesize = 1
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/lasagna
	name = "lasagna"
	desc = "A carefully stacked trayful of meat, tomato, cheese, and pasta. Favorite of cats."
	icon_state = "lasagna"
	bitesize = 3
	storage_slots = 1
	w_class = W_CLASS_MEDIUM
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, TOMATOJUICE = 15)

var/global/list/bomb_like_items = list(/obj/item/device/transfer_valve, /obj/item/toy/bomb, /obj/item/weapon/c4, /obj/item/cannonball/fuse_bomb, /obj/item/weapon/grenade, /obj/item/device/onetankbomb)

/obj/item/weapon/reagent_containers/food/snacks/lasagna/can_hold(obj/item/weapon/W) //GREAT SCOTT!
	if(is_type_in_list(W, bomb_like_items))
		return TRUE
	return ..(W)

/obj/item/weapon/reagent_containers/food/snacks/pierogi
	name = "pierogi"
	desc = "Dumplings with potatoes and curd inside."
	icon_state = "pierogi"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/sauerkraut
	name = "sauerkraut"
	desc = "Cabbage that has fermented in salty brine."
	icon_state = "sauerkraut"
	trash = /obj/item/trash/snack_bowl
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/escargot
	icon_state = "escargot"
	name = "cooked escargot"
	desc = "A fine treat and an exquisite cuisine."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/food.dmi', "right_hand" = 'icons/mob/in-hand/right/food.dmi')
	bitesize = 1
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, SODIUMCHLORIDE = 2, HOLYWATER = 2)

/obj/item/weapon/reagent_containers/food/snacks/es_cargo
	icon_state = "es_cargo_closed"
	name = "es-cargo"
	desc = "Je-ne-veux-pas-travailler!"
	bitesize = 1
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/food.dmi', "right_hand" = 'icons/mob/in-hand/right/food.dmi')
	var/open = FALSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, SODIUMCHLORIDE = 2, HOLYWATER = 2)

/obj/item/weapon/reagent_containers/food/snacks/es_cargo/can_consume(mob/living/carbon/eater, mob/user)
	if (!open)
		visible_message("<span class='notice'>\The [eater] cannot eat from \the [src] if it's closed, imbecile!</span>","<span class='notice'>You must first open it!</span>", drugged_message = "<span class='danger'>Oh lalala, this is not it, not it at all !</span>")
		return FALSE
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/es_cargo/attack_self(var/mob/user)
	if (!open)
		open = TRUE
		icon_state = "es_cargo_opened"
		visible_message("<span class='notice'>\The [user] opens \the [src]!</span>", drugged_message = "<span class='notice'>This smells très bon !</span>")
		return
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/es_cargo/verb/toggle_open()
	set name = "Toggle open"
	set category = "Object"
	if (!open)
		open = TRUE
		icon_state = "es_cargo_opened"
		visible_message("<span class='notice'>\The [usr] opens \the [src]!</span>", drugged_message = "<span class='notice'>This smells très bon !</span>")
	else
		open = FALSE
		icon_state = "es_cargo_closed"
		visible_message("<span class='notice'>\The [usr] closes \the [src]!</span>", drugged_message = "<span class='notice'>Enough for today !</span>")
