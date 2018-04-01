/obj/item/stack/sheet/animalhide
	name = "hide"
	desc = "Something went wrong."
	icon_state = "sheet-hide"
	item_state = "sheet-hide"
	novariants = TRUE

/obj/item/stack/sheet/animalhide/human
	name = "human skin"
	desc = "The by-product of human farming."
	singular_name = "human skin piece"
	novariants = FALSE

GLOBAL_LIST_INIT(human_recipes, list( \
	new/datum/stack_recipe("bloated human costume", /obj/item/clothing/suit/hooded/bloated_human, 5), \
	))

/obj/item/stack/sheet/animalhide/human/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.human_recipes
	return ..()

/obj/item/stack/sheet/animalhide/generic
	name = "skin"
	desc = "A piece of skin."
	singular_name = "skin piece"
	novariants = FALSE

/obj/item/stack/sheet/animalhide/corgi
	name = "corgi hide"
	desc = "The by-product of corgi farming."
	singular_name = "corgi hide piece"
	icon_state = "sheet-corgi"
	item_state = "sheet-corgi"

/obj/item/stack/sheet/animalhide/gondola
	name = "gondola hide"
	desc = "The extremely valuable by-product of gondola hunting."
	singular_name = "gondola hide piece"
	icon_state = "sheet-gondola"
	item_state = "sheet-gondola"


GLOBAL_LIST_INIT(corgi_recipes, list ( \
	new/datum/stack_recipe("corgi costume", /obj/item/clothing/suit/hooded/ian_costume, 3), \
	))

/obj/item/stack/sheet/animalhide/corgi/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.corgi_recipes
	return ..()

/obj/item/stack/sheet/animalhide/cat
	name = "cat hide"
	desc = "The by-product of cat farming."
	singular_name = "cat hide piece"
	icon_state = "sheet-cat"
	item_state = "sheet-cat"

/obj/item/stack/sheet/animalhide/monkey
	name = "monkey hide"
	desc = "The by-product of monkey farming."
	singular_name = "monkey hide piece"
	icon_state = "sheet-monkey"
	icon_state = "sheet-monkey"

GLOBAL_LIST_INIT(monkey_recipes, list ( \
	new/datum/stack_recipe("monkey mask", /obj/item/clothing/mask/gas/monkeymask, 1), \
	new/datum/stack_recipe("monkey suit", /obj/item/clothing/suit/monkeysuit, 2), \
	))

/obj/item/stack/sheet/animalhide/monkey/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.monkey_recipes
	return ..()

/obj/item/stack/sheet/animalhide/lizard
	name = "lizard skin"
	desc = "Sssssss..."
	singular_name = "lizard skin piece"
	icon_state = "sheet-lizard"
	item_state = "sheet-lizard"

/obj/item/stack/sheet/animalhide/xeno
	name = "alien hide"
	desc = "The skin of a terrible creature."
	singular_name = "alien hide piece"
	icon_state = "sheet-xeno"
	item_state = "sheet-xeno"

GLOBAL_LIST_INIT(xeno_recipes, list ( \
	new/datum/stack_recipe("alien helmet", /obj/item/clothing/head/xenos, 1), \
	new/datum/stack_recipe("alien suit", /obj/item/clothing/suit/xenos, 2), \
	))

/obj/item/stack/sheet/animalhide/xeno/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.xeno_recipes
	return ..()

//don't see anywhere else to put these, maybe together they could be used to make the xenos suit?
/obj/item/stack/sheet/xenochitin
	name = "alien chitin"
	desc = "A piece of the hide of a terrible creature."
	singular_name = "alien hide piece"
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"
	novariants = TRUE

/obj/item/xenos_claw
	name = "alien claw"
	desc = "The claw of a terrible creature."
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/weed_extract
	name = "weed extract"
	desc = "A piece of slimy, purplish weed."
	icon = 'icons/mob/alien.dmi'
	icon_state = "weed_extract"

/obj/item/stack/sheet/hairlesshide
	name = "hairless hide"
	desc = "This hide was stripped of its hair, but still needs washing and tanning."
	singular_name = "hairless hide piece"
	icon_state = "sheet-hairlesshide"
	item_state = "sheet-hairlesshide"

/obj/item/stack/sheet/wetleather
	name = "wet leather"
	desc = "This leather has been cleaned but still needs to be dried."
	singular_name = "wet leather piece"
	icon_state = "sheet-wetleather"
	item_state = "sheet-wetleather"
	var/wetness = 30 //Reduced when exposed to high temperautres
	var/drying_threshold_temperature = 500 //Kelvin to start drying

/*
 * Leather SHeet
 */
/obj/item/stack/sheet/leather
	name = "leather"
	desc = "The by-product of mob grinding."
	singular_name = "leather piece"
	icon_state = "sheet-leather"
	item_state = "sheet-leather"

GLOBAL_LIST_INIT(leather_recipes, list ( \
	new/datum/stack_recipe("wallet", /obj/item/storage/wallet, 1), \
	new/datum/stack_recipe("muzzle", /obj/item/clothing/mask/muzzle, 2), \
	new/datum/stack_recipe("botany gloves", /obj/item/clothing/gloves/botanic_leather, 3), \
	new/datum/stack_recipe("toolbelt", /obj/item/storage/belt/utility, 4), \
	new/datum/stack_recipe("leather satchel", /obj/item/storage/backpack/satchel/leather, 5), \
	new/datum/stack_recipe("bandolier", /obj/item/storage/belt/bandolier, 5), \
	new/datum/stack_recipe("leather jacket", /obj/item/clothing/suit/jacket/leather, 7), \
	new/datum/stack_recipe("leather overcoat", /obj/item/clothing/suit/jacket/leather/overcoat, 10), \
))

/obj/item/stack/sheet/leather/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.leather_recipes
	return ..()

/*
 * Sinew
 */
/obj/item/stack/sheet/sinew
	name = "watcher sinew"
	icon = 'icons/obj/mining.dmi'
	desc = "Long stringy filaments which presumably came from a watcher's wings."
	singular_name = "watcher sinew"
	icon_state = "sinew"
	novariants = TRUE


GLOBAL_LIST_INIT(sinew_recipes, list ( \
	new/datum/stack_recipe("sinew restraints", /obj/item/restraints/handcuffs/sinew, 1), \
))

/obj/item/stack/sheet/sinew/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.sinew_recipes
	return ..()

		/*
 * Plates
 		*/
/obj/item/stack/sheet/animalhide/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_hide"
	singular_name = "hide plate"
	max_amount = 6
	novariants = FALSE
	flags_1 = NOBLUDGEON_1
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER


/obj/item/stack/sheet/animalhide/ashdrake
	name = "ash drake hide"
	desc = "The strong, scaled hide of an ash drake."
	icon = 'icons/obj/mining.dmi'
	icon_state = "dragon_hide"
	singular_name = "drake plate"
	max_amount = 10
	novariants = FALSE
	flags_1 = NOBLUDGEON_1
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER


//Step one - dehairing.

/obj/item/stack/sheet/animalhide/attackby(obj/item/W, mob/user, params)
	if(W.is_sharp())
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		user.visible_message("[user] starts cutting hair off \the [src].", "<span class='notice'>You start cutting the hair off \the [src]...</span>", "<span class='italics'>You hear the sound of a knife rubbing against flesh.</span>")
		if(do_after(user,50, target = src))
			to_chat(user, "<span class='notice'>You cut the hair from this [src.singular_name].</span>")
			var/obj/item/stack/sheet/hairlesshide/HS = new(user.loc)
			HS.amount = 1
			use(1)
	else
		return ..()


//Step two - washing..... it's actually in washing machine code.

//Step three - drying
/obj/item/stack/sheet/wetleather/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature >= drying_threshold_temperature)
		wetness--
		if(wetness == 0)
			//Try locating an exisitng stack on the tile and add to there if possible
			for(var/obj/item/stack/sheet/leather/HS in src.loc)
				if(HS.amount < 50)
					HS.amount++
					src.use(1)
					wetness = initial(wetness)
					break
			//If it gets to here it means it did not find a suitable stack on the tile.
			var/obj/item/stack/sheet/leather/HS = new(src.loc)
			HS.amount = 1
			wetness = initial(wetness)
			src.use(1)

/obj/item/stack/sheet/wetleather/microwave_act(obj/machinery/microwave/MW)
	..()
	var/obj/item/stack/sheet/leather/L = new(loc)
	L.amount = amount
	qdel(src)
