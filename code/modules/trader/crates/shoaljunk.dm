//15+3+8 = 26
var/global/list/shoal_stuff = list(
	//5 of a kind
	/obj/item/weapon/hair_dye/skin_dye/discount,/obj/item/weapon/hair_dye/skin_dye/discount,/obj/item/weapon/hair_dye/skin_dye/discount,/obj/item/weapon/hair_dye/skin_dye/discount,/obj/item/weapon/hair_dye/skin_dye/discount,
	/obj/item/weapon/storage/bag/gadgets/part_replacer/injector,/obj/item/weapon/storage/bag/gadgets/part_replacer/injector,/obj/item/weapon/storage/bag/gadgets/part_replacer/injector,/obj/item/weapon/storage/bag/gadgets/part_replacer/injector,/obj/item/weapon/storage/bag/gadgets/part_replacer/injector,
	/obj/item/weapon/storage/bag/gadgets/part_replacer/injector/super,/obj/item/weapon/storage/bag/gadgets/part_replacer/injector/super,/obj/item/weapon/storage/bag/gadgets/part_replacer/injector/super,/obj/item/weapon/storage/bag/gadgets/part_replacer/injector/super,/obj/item/weapon/storage/bag/gadgets/part_replacer/injector/super,
	//3 of a kind
	/obj/item/weapon/boxofsnow,/obj/item/weapon/boxofsnow,/obj/item/weapon/boxofsnow,
	/obj/item/clothing/accessory/wristwatch/black,/obj/item/clothing/accessory/wristwatch/black,/obj/item/clothing/accessory/wristwatch/black,
	//1 of a kind
	/obj/item/weapon/reagent_containers/food/snacks/borer_egg,
	/obj/item/weapon/vinyl/echoes,
	/obj/item/fish_eggs/seadevil,
	/obj/structure/bed/therapy,
	/obj/item/weapon/grenade/station/discount,
	/obj/item/device/crank_charger/generous,
	/obj/item/weapon/storage/gachabox,
	/obj/item/weapon/storage/bluespace_crystal,
)
/obj/structure/closet/crate/shoaljunk
	name = "Shoal junk crate"
	desc = "What? It fell off a spacetruck."

/obj/structure/closet/crate/shoaljunk/New()
	..()
	for(var/i = 1 to 10)
		if(!shoal_stuff.len)
			return
		var/path = pick_n_take(shoal_stuff)
		new path(src)

/obj/item/weapon/boxofsnow
	name = "box of winter"
	desc = "It has a single red button on top. Probably want to be careful where you open this."
	icon = 'icons/obj/storage/smallboxes.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
	icon_state = "box_of_doom"
	item_state = "box_of_doom"
	autoignition_temperature = AUTOIGNITION_PAPER

/obj/item/weapon/boxofsnow/attack_self(mob/user)
	var/turf/center = get_turf(loc)
	for(var/i = 1 to rand(8,24))
		new /obj/item/stack/sheet/snow(center)
	for(var/turf/simulated/T in circleview(user,5))
		if(istype(T,/turf/simulated/floor))
			new /obj/structure/snow(T) //Floors get snow
		if(istype(T,/turf/simulated/wall))
			new /obj/machinery/xmas_light(T) //Walls get lights
	if(prob(66)) //Snowman or St. Corgi
		new /mob/living/simple_animal/hostile/retaliate/snowman(center)
	else
		new /mob/living/simple_animal/corgi/saint(center)
	visible_message("<span class='danger'>[user] lets loose \the [src]!</span>")
	qdel(src)

/obj/item/weapon/storage/bluespace_crystal
	name = "natural bluespace crystals box"
	desc = "Hmmm... it smells like tomato."
	icon = 'icons/obj/storage/smallboxes.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/bluespace_crystal/New()
	..()
	for(var/amount = 1 to 6)
		new /obj/item/bluespace_crystal(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato(src)

/obj/item/weapon/storage/gachabox
	name = "wholesale capsule kit"
	can_only_hold = list(/obj/item/weapon/capsule)
	storage_slots = 60
	max_combined_w_class = ARBITRARILY_LARGE_NUMBER
	display_contents_with_number = TRUE
	allow_quick_empty = TRUE
	allow_quick_gather = TRUE
	icon = 'icons/obj/storage/smallboxes.dmi'
	icon_state = "box"
	autoignition_temperature = AUTOIGNITION_PLASTIC

/obj/item/weapon/storage/gachabox/New()
	..()
	for(var/amount = 1 to 60)
		new /obj/item/weapon/capsule(src)