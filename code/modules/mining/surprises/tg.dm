///////////////////
// /tg/ Surprises
///////////////////

/mining_surprise/organharvest
	walltypes = list(
		/turf/simulated/wall/r_wall=2,
		/turf/simulated/wall=2,
		/turf/unsimulated/mineral/random/high_chance=1
	)
	floortypes = list(
		/turf/simulated/floor=1,
		/turf/simulated/floor/engine=1
	)
	spawntypes = list(
		/obj/item/device/reagent_scanner/adv=1,
		/obj/item/clothing/glasses/hud/health=1,
		/obj/machinery/bot/medbot/mysterious=1
	)
	fluffitems = list(
		/obj/effect/decal/cleanable/blood=5,
		/obj/item/weapon/reagent_containers/food/snacks/organ=2, // OM NOM
		/obj/structure/closet/crate/freezer=2,
		/obj/machinery/optable=1,
		/obj/item/tool/scalpel=1,
		/obj/item/weapon/storage/firstaid/regular=3,
		/obj/item/weapon/tank/anesthetic=1,
		///obj/item/weapon/surgical_drapes=2
	)

	flags = CONTIGUOUS_WALLS | CONTIGUOUS_FLOORS

	complex_max_size=3
	room_size_max=7

/mining_surprise/cult
	name = "Hidden Temple"
	walltypes = list(
		/turf/simulated/wall/cult=3,
		/turf/unsimulated/mineral/random/high_chance=1
	)
	floortypes = list(
		/turf/simulated/floor/engine/cult=1
	)
	spawntypes = list(
		/mob/living/simple_animal/hostile/creature=1,
		// /obj/item/organ/internal/heart=2,
		/obj/item/soulstone=1
	)
	fluffitems = list(
		/obj/effect/gateway=1,
		/obj/item/mounted/frame/painting/narsie=1,
		/obj/effect/gibspawner=1,
		/obj/structure/cult_legacy/talisman=1,
		/obj/item/toy/crayon/red=2,
		/obj/effect/decal/cleanable/blood=4,
		/obj/structure/table/woodentable=2,
		/obj/item/weapon/ectoplasm=3
	)

	flags = CONTIGUOUS_WALLS | CONTIGUOUS_FLOORS

	complex_max_size=3
	room_size_max=5

/mining_surprise/wizden
	name = "Hidden Den"
	walltypes = list(
		/turf/simulated/wall/mineral/plasma=3,
		/turf/unsimulated/mineral/random/high_chance=1
	)
	floortypes = list(
		/turf/simulated/floor/wood=1
	)
	spawntypes = list(
		// /vg/: Let's not. /obj/item/weapon/veilrender/vealrender=1,
		// /vg/: /obj/item/key=1
		/obj/item/clothing/glasses/monocle=5,
		// /vg/:
		/obj/structure/bed/chair/vehicle/firebird=1
	)
	fluffitems = list(
		/obj/structure/safe/floor/wizard=1,
		// /obj/structure/wardrobe=1,
		/obj/item/weapon/storage/belt/soulstone=1,
		/obj/item/trash/candle=3,
		/obj/item/weapon/dice=3,
		/obj/item/weapon/staff=2,
		/obj/effect/decal/cleanable/dirt=3,
		/obj/item/weapon/coin/mythril=3
	)

	flags = CONTIGUOUS_WALLS | CONTIGUOUS_FLOORS

	complex_max_size=1
	room_size_max=7

/mining_surprise/cavein
	name="Cave-In"

	walltypes = list(
		/turf/unsimulated/mineral/random/high_chance=1
	)
	floortypes = list(
		/turf/unsimulated/floor/asteroid=1
	)
	spawntypes = list(
		/obj/mecha/working/ripley/mining=1,
		/obj/item/weapon/pickaxe/jackhammer=2,
		/obj/item/weapon/pickaxe/drill/diamond=2
	)
	fluffitems = list(
		/obj/effect/decal/cleanable/blood=3,
		/obj/effect/decal/remains/human=1,
		/obj/item/clothing/under/overalls=1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili=1,
		/obj/item/weapon/tank/oxygen/red=2
	)

	complex_max_size=3
	room_size_max=7

/mining_surprise/human/hitech
	complex_max_size=3
	room_size_max=7

	walltypes = list(
		/turf/simulated/wall/r_wall=1
	)
	floortypes = list(
		/turf/simulated/floor/greengrid=1,
		/turf/simulated/floor/bluegrid=1
	)
	spawntypes = list(
		/obj/item/weapon/pickaxe/plasmacutter/accelerator=1,
		/obj/machinery/shieldgen=1,
		/obj/item/weapon/cell/hyper=1
	)
	fluffitems = list(
		/obj/structure/table/reinforced=2,
		/obj/item/weapon/stock_parts/capacitor/adv/super/ultra=3,
		/obj/item/weapon/stock_parts/micro_laser/high/ultra/giga=3,
		/obj/item/weapon/stock_parts/manipulator/nano/pico/femto=3,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic/bluespace=3,
		/obj/item/weapon/stock_parts/matter_bin/adv/super/bluespace=3,
//		/obj/item/weapon/stock_parts/console_screen/reinforced/plasma/rplasma=3,
		/obj/item/device/pda/clear=1
	)

/mining_surprise/human/speakeasy
	complex_max_size=3
	room_size_max=7

	floortypes = list(
		/turf/simulated/floor,
		/turf/simulated/floor/wood)
	spawntypes = list(
		/obj/item/weapon/melee/energy/sword/pirate=1,
		/obj/structure/closet/syndicate/resources=2
	)
	fluffitems = list(
		/obj/structure/table/woodentable=2,
		/obj/structure/reagent_dispensers/beerkeg=1,
		/obj/item/weapon/spacecash/c1000=2,
		/obj/item/weapon/reagent_containers/food/drinks/shaker=1,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/wine=3,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey=3,
		/obj/item/clothing/shoes/laceup=2
	)

/mining_surprise/human/plantlab
	complex_max_size=2
	room_size_max=7

	spawntypes = list(
		/obj/item/floral_somatoray=1,
		//obj/item/seeds/novaflowerseed=2,
		/obj/item/seeds/bluespacetomatoseed=2,
		// /vg/:
		/obj/item/seeds/nofruitseed=5
	)
	fluffitems = list(
		// /obj/structure/flora/kirbyplants=1,
		/obj/structure/table/reinforced=2,
		/obj/machinery/portable_atmospherics/hydroponics/loose=1,
		/obj/effect/glowshroom/single=2,
		/obj/item/weapon/reagent_containers/syringe/antitoxin=2,
		/obj/item/weapon/reagent_containers/glass/bottle/diethylamine=3,
		/obj/item/weapon/reagent_containers/glass/bottle/ammonia=3
	)
