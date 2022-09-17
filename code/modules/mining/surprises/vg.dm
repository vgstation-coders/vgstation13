/* Not quite there yet
#define ANY_SIDE list(NORTH,SOUTH,EAST,WEST)

/layout_rule/place_adjacent/workbench
	placetype=/obj/structure/table

	min_to_place=3
	min_to_place=7

	next_to=list(
		/turf/simulated/wall = ANY_SIDE,
		/turf/simulated/wall/r_wall = ANY_SIDE,
	)
	// MUST NOT be next to these.
	not_next_to=list()

	decorations=list(
		/obj/item/tool/screwdriver=2,
		/obj/item/tool/crowbar=2,
		/obj/item/stack/metal=1,
		/obj/item/tool/wrench=2
	)

/layout_rule/place_adjacent/workbench/wooden
	placetype=/obj/structure/table/woodentable

/layout_rule/place_adjacent/workbench/reinforced
	placetype=/obj/structure/table/reinforced

/layout_rule/place_adjacent/chair
	placetype=/obj/structure/bed/chair

	min_to_place=1
	min_to_place=2

	next_to=list(
		/obj/structure/table = ANY_SIDE,
	)
	// MUST NOT be next to these.
	not_next_to=list(
		/obj/structure/bed/chair = ANY_SIDE
	)

	//flags = FACE_MATCH

/layout_rule/place_adjacent/chair/wooden
	placetype=/obj/structure/bed/chair/wooden

	min_to_place=1
	min_to_place=2

	next_to=list(
		/obj/structure/table/wooden = ANY_SIDE,
	)
	// MUST NOT be next to these.
	not_next_to=list(
		/obj/structure/bed/chair = ANY_SIDE
	)

	//flags = FACE_MATCH
*/
/mining_surprise/human
	name="Hidden Complex"
	floortypes = list(
		/turf/simulated/floor/airless=95,
		/turf/simulated/floor/plating/airless=5
	)
	walltypes = list(
		/turf/simulated/wall=100
	)
	spawntypes = list(
		/obj/item/weapon/pickaxe/silver					=4,
		/obj/item/weapon/pickaxe/drill					=4,
		/obj/item/weapon/pickaxe/jackhammer				=4,
		/obj/item/weapon/pickaxe/diamond				=3,
		/obj/item/weapon/pickaxe/drill/diamond			=3,
		/obj/item/weapon/pickaxe/gold					=3,
		/obj/item/weapon/pickaxe/plasmacutter/accelerator			=2,
		/obj/structure/closet/syndicate/resources		=2,
		/obj/item/weapon/melee/energy/sword/pirate		=1,
		/obj/mecha/working/ripley/mining				=1
	)
	complex_max_size=2

	flags = CONTIGUOUS_WALLS | CONTIGUOUS_FLOORS

/datum/map_element/mining_surprise/geode
	name="Geode"
	file_path = "maps/randomvaults/mining/geode.dmm"
	can_rotate = TRUE

/datum/map_element/mining_surprise/crashed_tradeship
	name="Crashed Tradeship"
	file_path = "maps/randomvaults/mining/crashed_tradeship.dmm"
	can_rotate = TRUE

/datum/map_element/mining_surprise/crashed_pod
	name="Crashed Pod"
	file_path = "maps/randomvaults/mining/crashed_pod.dmm"
	can_rotate = TRUE

/datum/map_element/mining_surprise/digsite
	name="Abandoned Digsite"
	file_path = "maps/randomvaults/mining/abandoned_digsite.dmm"

/datum/map_element/mining_surprise/forge
	name="Abandoned Forge"
	file_path = "maps/randomvaults/mining/abandoned_forge.dmm"

/datum/map_element/mining_surprise/aliens
	name="Alien Hive"
	file_path = "maps/randomvaults/mining/huggernest.dmm"
	can_rotate = TRUE

/datum/map_element/mining_surprise/angie
	name = "Angie's lair"
	desc = "From within this rich soil, the stone gathers moss."

	file_path = "maps/randomvaults/mining/angie_lair.dmm"
	can_rotate = TRUE

/datum/map_element/mining_surprise/mine_bar
	name = "The Buried Bar"
	desc = "A miner walks into a bar, Dusky says \"Sorry, you're too young to be served\"."

	file_path = "maps/randomvaults/mining/bar.dmm"

/datum/map_element/hoboshack
	name = "Space hobo shack"

	file_path = "maps/misc/hoboshack.dmm"

/datum/map_element/hoboshack/type1
	name = "Space hobo shack"

	file_path = "maps/misc/hoboshack.dmm"
	can_rotate = TRUE