/turf/simulated/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	floor_tile = /obj/item/stack/tile/mineral/plasma

//GOLD

/turf/simulated/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	floor_tile = /obj/item/stack/tile/mineral/gold

//SILVER

/turf/simulated/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	floor_tile = /obj/item/stack/tile/mineral/silver

//BANANIUM

/turf/simulated/floor/mineral/clown
	name = "bananium floor"
	icon_state = "bananium"
	floor_tile = /obj/item/stack/tile/mineral/clown

//DIAMOND

/turf/simulated/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	floor_tile = /obj/item/stack/tile/mineral/diamond

//URANIUM

/turf/simulated/floor/mineral/uranium
	name = "uranium floor"
	icon_state = "uranium"
	floor_tile = /obj/item/stack/tile/mineral/uranium

//PLASTIC

/turf/simulated/floor/mineral/plastic
	name = "plastic floor"
	icon_state = "plastic"
	floor_tile = /obj/item/stack/tile/mineral/plastic

//PHAZON

/turf/simulated/floor/mineral/phazon
	name = "phazon floor"
	icon_state = "phazon"
	floor_tile = /obj/item/stack/tile/mineral/phazon
	turf_speed_multiplier = 1.75

//BRASS

/turf/simulated/floor/mineral/clockwork
	name = "brass floor"
	icon_state = "brass"
	floor_tile = /obj/item/stack/tile/mineral/brass

/turf/simulated/floor/mineral/clockwork/cultify()
	return

/turf/simulated/floor/mineral/clockwork/clockworkify()
	return

//GINGERBREAD
/turf/simulated/floor/mineral/gingerbread_floor
	name = "gingerbread floor"
	icon_state = "gingerbread_floor1"


/turf/simulated/floor/mineral/gingerbread_floor/New()
	icon_state = "gingerbread_floor[rand(1,13)]"

/turf/simulated/floor/mineral/gingerbread_tile
	name = "gingerbread tile"
	icon_state = "gingerbread_tile"

/turf/simulated/floor/mineral/gingerbread_dirt_tile
	name = "dirty gingerbread tile"
	icon_state = "gingerbread_dirt_tile1"

/turf/simulated/floor/mineral/gingerbread_dirt_tile/New()
	icon_state = "gingerbread_dirt_tile[rand(1,3)]"

/turf/simulated/floor/mineral/gingerbread_nest
	name = "gingerbread nest"
	icon_state = "gingerbread_nest1"

/turf/simulated/floor/mineral/gingerbread_nest/New()
	icon_state = "gingerbread_nest[rand(1,3)]"

/turf/simulated/floor/mineral/gingerbread
	name = "gingerbread panel floor"
	icon_state = "gingerbread"
	floor_tile = /obj/item/stack/tile/mineral/gingerbread
	//I spent 10 hours trying to figure out how to make this use the nice randomized floors with the little peppermints I was so proud of. I give up, fuck floor tiles.
