//MINERAL FLOORS ARE HERE
//Includes: PLASMA, GOLD, SILVER, BANANIUM, DIAMOND, URANIUM, PHAZON

//PLASMA

/turf/simulated/floor/mineral/New()
	if(floor_tile)
		material = floor_tile.material
	..()

/turf/simulated/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"

/turf/simulated/floor/mineral/plasma/New()
	floor_tile = new /obj/item/stack/tile/mineral/plasma(null)
	..()

//GOLD

/turf/simulated/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"

/turf/simulated/floor/mineral/gold/New()
	floor_tile = new /obj/item/stack/tile/mineral/gold(null)
	..()

//SILVER

/turf/simulated/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"

/turf/simulated/floor/mineral/silver/New()
	floor_tile = new /obj/item/stack/tile/mineral/silver(null)
	..()

//BANANIUM

/turf/simulated/floor/mineral/clown
	name = "bananium floor"
	icon_state = "bananium"

/turf/simulated/floor/mineral/clown/New()
	floor_tile = new /obj/item/stack/tile/mineral/clown(null)
	..()

//DIAMOND

/turf/simulated/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"

/turf/simulated/floor/mineral/diamond/New()
	floor_tile = new /obj/item/stack/tile/mineral/diamond(null)
	..()

//URANIUM

/turf/simulated/floor/mineral/uranium
	name = "uranium floor"
	icon_state = "uranium"

/turf/simulated/floor/mineral/uranium/New()
	floor_tile = new /obj/item/stack/tile/mineral/uranium(null)
	..()

//PLASTIC

/turf/simulated/floor/mineral/plastic
	name = "plastic floor"
	icon_state = "plastic"

/turf/simulated/floor/mineral/plastic/New()
	floor_tile = new /obj/item/stack/tile/mineral/plastic(null)
	..()

//PHAZON

var/global/list/turf/simulated/floor/mineral/phazon/phazontiles = list()

/turf/simulated/floor/mineral/phazon
	name = "phazon floor"
	icon_state = "phazon"

/turf/simulated/floor/mineral/phazon/New()
	floor_tile = new /obj/item/stack/tile/mineral/phazon(null)
	..()
	phazontiles += src

/turf/simulated/floor/mineral/phazon/Destroy()
	..()
	phazontiles -= src

//BRASS

/turf/simulated/floor/mineral/clockwork
	name = "brass floor"
	icon_state = "brass"

/turf/simulated/floor/mineral/clockwork/New()
	floor_tile = new /obj/item/stack/tile/mineral/brass(null)
	..()

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
	floor_tile
	//I spent 10 hours trying to figure out how to make this use the nice randomized floors with the little peppermints I was so proud of. I give up, fuck floor tiles.

/turf/simulated/floor/mineral/gingerbread/New()
	floor_tile = new /obj/item/stack/tile/mineral/gingerbread(null)
	..()
