/*
 *	Here defined the boxes contained in the trader vending machine.
 *	Feel free to add stuff. Don't forget to add them to the vmachine afterwards.
*/

/obj/item/weapon/coin/trader
	material=MAT_GOLD
	name = "trader coin"
	icon_state = "coin_mythril"

/obj/item/weapon/storage/trader_marauder
	name = "box of Marauder circuits"
	desc = "All in one box!"
	icon = 'icons/obj/storage/smallboxes.dmi'
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/trader_marauder/New() //Because we're good jews, they won't be able to finish the marauder. The box is missing a circuit.
	..()
	new /obj/item/weapon/circuitboard/mecha/marauder(src)
	new /obj/item/weapon/circuitboard/mecha/marauder/peripherals(src)
	//new /obj/item/weapon/circuitboard/mecha/marauder/targeting(src)
	new /obj/item/weapon/circuitboard/mecha/marauder/main(src)

/obj/item/weapon/storage/trader_chemistry
	name = "chemist's pallet"
	desc = "Everything you need to make art."
	icon = 'icons/obj/storage/smallboxes.dmi'
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/trader_chemistry/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/bottle/peridaxon(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/rezadone(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/nanobotssmall(src)

/obj/item/weapon/storage/bluespace_crystal
	name = "natural bluespace crystals box"
	desc = "Hmmm... it smells like tomato"
	icon = 'icons/obj/storage/smallboxes.dmi'
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/bluespace_crystal/New()
	..()
	for(var/amount = 1 to 6)
		new /obj/item/bluespace_crystal(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato(src)

/obj/structure/closet/secure_closet/wonderful
	name = "wonderful wardrobe"
	desc = "Stolen from Space Narnia."
	req_access = list(access_trade)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"
	var/wonder_whitelist = list(
	/obj/item/clothing/mask/morphing/corgi,
	/obj/item/clothing/under/rank/vice,
	/obj/item/clothing/shoes/clown_shoes/advanced,
	list(/obj/item/clothing/suit/space/clown, /obj/item/clothing/head/helmet/space/clown),
	/obj/item/clothing/shoes/magboots/magnificent,
	list(/obj/item/clothing/suit/space/plasmaman/bee, /obj/item/clothing/head/helmet/space/plasmaman/bee),
	list(/obj/item/clothing/head/wizard/lich, /obj/item/clothing/suit/wizrobe/lich, /obj/item/clothing/suit/wizrobe/skelelich),
	list(/obj/item/clothing/suit/space/plasmaman/cultist, /obj/item/clothing/head/helmet/space/plasmaman/cultist),
	list(/obj/item/clothing/head/helmet/space/plasmaman/security/captain, /obj/item/clothing/suit/space/plasmaman/security/captain),
	/obj/item/clothing/under/skelevoxsuit,
	list(/obj/item/clothing/suit/wintercoat/ce, /obj/item/clothing/suit/wintercoat/cmo, /obj/item/clothing/suit/wintercoat/security/hos, /obj/item/clothing/suit/wintercoat/hop, /obj/item/clothing/suit/wintercoat/captain, /obj/item/clothing/suit/wintercoat/clown, /obj/item/clothing/suit/wintercoat/slimecoat),
	list(/obj/item/clothing/head/helmet/space/rig/wizard, /obj/item/clothing/suit/space/rig/wizard, /obj/item/clothing/gloves/purple, /obj/item/clothing/shoes/sandal),
	list(/obj/item/clothing/head/helmet/space/rig/knight, /obj/item/clothing/head/helmet/space/rig/knight),
	list(/obj/item/clothing/suit/space/ancient, /obj/item/clothing/suit/space/ancient),
	list(/obj/item/clothing/shoes/clockwork_boots, /obj/item/clothing/head/clockwork_hood, /obj/item/clothing/suit/clockwork_robes),
	/obj/item/clothing/mask/necklace/xeno_claw
	)
/obj/structure/closet/secure_closet/wonderful/New()
	..()
	for(var/amount = 1 to 10)
		var/wonder_clothing = pick_n_take(wonder_whitelist)
		if(islist(wonder_clothing))
			for(var/i in wonder_clothing)
				new i(src)
		else
			new wonder_clothing(src)

/*/obj/structure/cage/with_random_slime
	..()

	add_mob

/mob/living/carbon/slime/proc/randomSlime()
*/

/area/vault/mecha_graveyard

/obj/item/weapon/disk/shuttle_coords/vault/mecha_graveyard
	name = "Coordinates to the Mecha Graveyard"
	desc = "Here lay the dead steel of lost mechas, so says some gypsy."
	destination = /obj/docking_port/destination/vault/mecha_graveyard

/obj/docking_port/destination/vault/mecha_graveyard
	areaname = "mecha graveyard"

/datum/map_element/dungeon/mecha_graveyard
	file_path = "maps/randomvaults/dungeons/mecha_graveyard.dmm"
	unique = TRUE

/obj/effect/decal/mecha_wreckage/graveyard_ripley
	name = "Ripley wreckage"
	desc = "Surprisingly well preserved."
	icon_state = "ripley-broken"

/obj/effect/decal/mecha_wreckage/graveyard_ripley/New()
	..()
	var/list/parts = list(/obj/item/mecha_parts/part/ripley_torso,
								/obj/item/mecha_parts/part/ripley_left_arm,
								/obj/item/mecha_parts/part/ripley_right_arm,
								/obj/item/mecha_parts/part/ripley_left_leg,
								/obj/item/mecha_parts/part/ripley_right_leg)
	welder_salvage += parts

	if(prob(80))
		add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/drill,100)
	else
		add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/jetpack,100)

/obj/effect/decal/mecha_wreckage/graveyard_clarke
	name = "Clarke wreckage"
	desc = "Surprisingly well preserved."
	icon_state = "clarke-broken"

/obj/effect/decal/mecha_wreckage/graveyard_clarke/New()
	..()
	var/list/parts = list(
								/obj/item/mecha_parts/part/clarke_torso,
								/obj/item/mecha_parts/part/clarke_head,
								/obj/item/mecha_parts/part/clarke_left_arm,
								/obj/item/mecha_parts/part/clarke_right_arm,
								/obj/item/mecha_parts/part/clarke_left_tread,
								/obj/item/mecha_parts/part/clarke_right_tread)
	welder_salvage += parts

	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/collector,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/tiler,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/switchtool,100)
