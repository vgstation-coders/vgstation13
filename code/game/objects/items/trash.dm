//Items labled as 'trash' for the trash bag.
//TODO: Make this an item var or something...

//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/trash.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/trash.dmi', "right_hand" = 'icons/mob/in-hand/right/trash.dmi')
	w_class = W_CLASS_TINY
	desc = "This is rubbish."
	w_type=NOT_RECYCLABLE
	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1
	var/persistence_type = SS_TRASH
	var/age = 1 //For map persistence. +1 per round that this item has survived. After a certain amount, it will not carry on to the next round anymore.
	//var/global/list/trash_items = list()

/obj/item/trash/New(var/loc, var/age, var/icon_state, var/color, var/dir, var/pixel_x, var/pixel_y)
	if(age)
		setPersistenceAge(age)
	if(icon_state)
		src.icon_state = icon_state
	if(color)
		src.color = color
	if(dir)
		src.dir = dir
	if(pixel_x)
		src.pixel_x = pixel_x
	if(pixel_y)
		src.pixel_y = pixel_y

	if(ticker)
		initialize()

	..(loc)

/obj/item/trash/initialize()
	..()
	trash_items += src
	if(persistence_type)
		SSpersistence_map.track(src, persistence_type)

/obj/item/trash/Destroy()
	trash_items -= src
	if(persistence_type)
		SSpersistence_map.forget(src, persistence_type)
	..()

/obj/item/trash/getPersistenceAge()
	return age
/obj/item/trash/setPersistenceAge(nu)
	age = nu

/obj/item/trash/post_mapsave2atom(var/list/L)
	. = ..()
	if(pixel_x == 0)
		pixel_x = rand(-4, 4) * PIXEL_MULTIPLIER
	if(pixel_y == 0)
		pixel_y = rand(-4, 4) * PIXEL_MULTIPLIER

/obj/item/trash/attack(mob/M as mob, mob/living/user as mob)
	return

/obj/item/trash/bustanuts
	name = "\improper Busta-Nuts box"
	icon_state = "busta_nut"
	starting_materials = list(MAT_CARDBOARD = 370)
	w_type=RECYK_MISC

/obj/item/trash/oldempirebar
	name = "\improper Old Empire Bar wrapper"
	icon_state = "old_empire_bar"
	starting_materials = list(MAT_CARDBOARD = 370)
	w_type=RECYK_MISC

/obj/item/trash/raisins
	name = "\improper 4no raisins box"
	icon_state= "4no_raisins"
	starting_materials = list(MAT_CARDBOARD = 370)
	w_type=RECYK_MISC

/obj/item/trash/candy
	name = "candy wrapper"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "\improper Cheesie honkers bag"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "chips bag"
	icon_state = "chips"


/obj/item/trash/popcorn
	name = "popcorn box"
	icon_state = "popcorn"
	starting_materials = list(MAT_CARDBOARD = 370)
	w_type=RECYK_MISC

/obj/item/trash/popcorn/hoppers
	name = "hoppers box"
	icon_state = "hoppers"

/obj/item/trash/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky bag"
	icon_state = "sosjerky"
	starting_materials = list(MAT_CARDBOARD = 370)
	w_type=RECYK_MISC

/obj/item/trash/syndi_cakes
	name = "\improper Syndi cakes box"
	icon_state = "syndi_cakes"
	starting_materials = list(MAT_CARDBOARD = 370)
	w_type=RECYK_MISC

/obj/item/trash/discountchocolate
	name = "\improper Discount Dan's Chocolate Bar wrapper"
	icon_state = "danbar"

/obj/item/trash/donitos
	name = "\improper Donitos bag"
	icon_state = "donitos"

/obj/item/trash/donitos_coolranch
	name = "\improper Donitos Cool Ranch bag"
	icon_state = "donitos_coolranch"

/obj/item/trash/danitos
	name = "\improper Danitos bag"
	icon_state = "danitos"
	
/obj/item/trash/dangles
	name = "\improper Dangles can"
	icon_state = "dangles"
	autoignition_temperature = AUTOIGNITION_PLASTIC
	fire_fuel = 0
	
/obj/item/trash/dangles/New() 
	playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)

/obj/item/trash/waffles
	name = "waffle tray"
	icon_state = "waffles"

/obj/item/trash/pietin
	name = "pie tin"
	icon_state = "pietin"
	autoignition_temperature = 0
	siemens_coefficient = 2 //Do not touch live wires
	melt_temperature = MELTPOINT_SILICON //Not as high as steel

/obj/item/trash/pietin/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/trash/pietin))
		var/obj/item/I = new /obj/item/clothing/head/tinfoil(get_turf(src))
		qdel(W)
		qdel(src)
		user.put_in_hands(I)
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/doughslice))
		if(user.drop_item(W))
			new/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/pie(get_turf(src),W)
			qdel(W)
			qdel(src)
	if (iscablecoil(W))
		var/obj/item/stack/cable_coil/coil = W
		if(coil.amount < 5)
			to_chat(user, "<span class='notice'>There are not enough cables in the stack.</span>")
			return

		var/obj/item/I = new /obj/item/trash/wired_pietin_assembly(get_turf(src))
		coil.use(5)
		to_chat(user, "<span class='notice'>You remove the insulation and wrap the cables around the pie tin.</span>")
		qdel(src)
		user.put_in_hands(I)

/obj/item/trash/wired_pietin_assembly
	name = "wired pie tin assembly"
	icon_state = "pietin_assembly"
	autoignition_temperature = 0
	siemens_coefficient = 2
	melt_temperature = MELTPOINT_SILICON

/obj/item/trash/wired_pietin_assembly/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/trash/pietin))
		var/obj/item/I = new /obj/item/weapon/melee/defibrillator/improvised
		qdel(W)
		qdel(src)
		to_chat(user, "<span class='notice'>You add a second pie tin to the assembly.</span>")
		user.put_in_hands(I)

/obj/item/trash/snack_bowl
	name = "snack bowl"
	icon_state	= "snack_bowl"

/obj/item/trash/monkey_bowl
	name = "monkey bowl"
	icon_state	= "monkey_bowl"
	desc = "It was delicia."

/obj/item/trash/pistachios
	name = "pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "pemki pack"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "tray"
	icon_state = "tray"

/obj/item/trash/candle
	name = "candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/liquidfood
	name = "\improper \"LiquidFood\" ration"
	icon_state = "liquidfood"

/obj/item/trash/chicken_bucket
	name = "chicken bucket"
	icon_state = "kfc_bucket"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC
	armor = list(melee = 1, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	slot_flags = SLOT_HEAD

/obj/item/trash/fries_cone
	name = "fries cone"
	icon_state = "used_cone"
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC

/obj/item/trash/fries_punet
	name = "fries punnet"
	icon_state = "used_punnet"
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC

/obj/item/trash/mannequin/cultify()
	if(icon_state != "mannequin_cult_empty")
		name = "cult mannequin pedestale"
		icon_state = "mannequin_cult_empty"

/obj/item/trash/mannequin
	name = "mannequin pedestale"
	icon = 'icons/obj/mannequin.dmi'
	icon_state = "mannequin_empty"

/obj/item/trash/mannequin/cult
	name = "cult mannequin pedestale"
	icon_state = "mannequin_cult_empty"

/obj/item/trash/mannequin/large
	name = "cyber mannequin pedestale"
	icon_state = "mannequin_cyber_empty"

/obj/item/trash/byond_box
	name = "discarded BYOND support package"
	icon_state = "byond"
	starting_materials = list(MAT_CARDBOARD = 370)
	autoignition_temperature = 522
	w_type=RECYK_MISC

var/list/crushed_cans_cache = list()

/obj/item/trash/soda_cans
	name = "crushed soda can"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/drinkingglass.dmi', "right_hand" = 'icons/mob/in-hand/right/drinkingglass.dmi')
	icon = 'icons/obj/drinks.dmi'
	icon_state = "crushed_can"
	starting_materials = list(MAT_IRON = 50)
	w_type=RECYK_METAL
	force = 0
	throwforce = 2
	throw_range = 8
	throw_speed = 3

/obj/item/trash/soda_cans/New(var/loc, var/age, var/icon_state, var/color, var/dir, var/pixel_x, var/pixel_y)
	name = color
	..(loc, age, icon_state, null, dir, pixel_x, pixel_y)
	if(icon_state)
		if (!(icon_state in crushed_cans_cache))
			var/icon/I = icon('icons/obj/drinks.dmi',"crushed_can")
			var/icon/J = icon('icons/obj/drinks.dmi',"crushed_can-overlay")
			var/icon/K = icon('icons/obj/drinks.dmi',icon_state)
			I.Blend(K,ICON_MULTIPLY)
			I.Blend(J,ICON_OVERLAY)
			crushed_cans_cache[icon_state] = I
		icon = icon(crushed_cans_cache[icon_state])
		item_state = icon_state

/obj/item/trash/soda_cans/atom2mapsave()
	. = ..()
	.["color"] = name//a bit hacky but at least it works

/obj/item/trash/slag
	name = "slag"
	desc = "Electronics burnt to a crisp."
	icon_state = "slag"

/obj/item/trash/used_tray
	name = "dirty tray"
	icon_state	= "tray_plastic_used"
	desc = "No nutrition left, just memories."

/obj/item/trash/used_tray2
	name = "used tray"
	icon_state	= "tray_plastic2_used"
	desc = "Whoever said a tray is most useful when it is empty must not have been hungry."

/obj/item/trash/zam_notraisins
	name = "zam notraisins"
	icon_state	= "zam_notraisins_rubbish"

/obj/item/trash/zam_sliderwrapper
	name = "zam slider wrapper"
	icon_state	= "zam_spiderslider_wrapper"

/obj/item/trash/egg
	name = "egg shell"
	icon_state	= "egg"
	desc = "Pieces of calcium carbonate."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/food.dmi', "right_hand" = 'icons/mob/in-hand/right/food.dmi')

/obj/item/trash/egg/borer
	icon_state	= "borer egg-growing"

/obj/item/trash/misc_packet
	name = "condiment packet"
	desc = "A used condiment packet."
	icon_state	= "misc_small"

/obj/item/trash/ketchup_packet
	name = "ketchup packet"
	desc = "A used ketchup packet."
	icon_state	= "ketchup_small"
	
/obj/item/trash/ketchup_packet
	name = "hotsauce packet"
	desc = "A used hotsauce packet."
	icon_state	= "hotsauce_small"

/obj/item/trash/mayo_packet
	name = "mayonnaise packet"
	desc = "A used mayonnaise packet."
	icon_state	= "mayo_small"

/obj/item/trash/soysauce_packet
	name = "soy sauce packet"
	desc = "A used soy sauce packet."
	icon_state	= "soysauce_small"

/obj/item/trash/vinegar_packet
	name = "malt vinegar packet"
	desc = "A used vinegar packet."
	icon_state	= "vinegar_small"
	
/obj/item/trash/hotsauce_packet
	name = "hotsauce packet"
	desc = "A used hotsauce packet."
	icon_state	= "hotsauce_small"

/obj/item/trash/zamitos_o
	name = "Zamitos: Original Flavor"
	desc = "Crumbs to crumbs."
	icon_state	= "zamitos_o"

/obj/item/trash/zamitos_bg
	name = "Zamitos: Blue Goo Flavor"
	desc = "Someone around here is a goo eater."
	icon_state	= "zamitos_bg"

/obj/item/trash/zamitos_sj
	name = "Zamitos: Spicy Stok Jerky Flavor"
	desc = "The end of a meat-flavored era."
	icon_state	= "zamitos_sj"

/obj/item/trash/zamspices_packet
	name = "zam spices packet"
	desc = "A used Zam spices packet."
	icon_state	= "zamspices_small"

/obj/item/trash/zammild_packet
	name = "zam's mild sauce packet"
	desc = "A used Zam's mild sauce packet."
	icon_state	= "zammild_small"

/obj/item/trash/zamspicytoxin_packet
	name = "zam's spicy sauce packet"
	desc = "A used Zam's spicy sauce packet."
	icon_state	= "zamspicytoxin_small"

/obj/item/trash/discount_packet
	name = "Discount Dan's Special Sauce"
	desc = "Contained 40% less sauce than competing products!"
	icon_state	= "discount_small"

/obj/item/trash/emptybowl
	name = "empty bowl"
	desc = "No soup, no use."
	icon_state	= "emptybowl"

/obj/item/trash/emptybowl_ufo
	name = "empty saucer bowl"
	desc = "What a shame it's too small to fly in."
	icon_state	= "emptysaucerbowl"
	starting_materials = list(MAT_IRON = 100)
	w_type=RECYK_METAL
