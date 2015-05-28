/turf/simulated/floor/mineral
	name = "mineral floor"
	icon_state = ""



/turf/simulated/floor/mineral/New()
	..()

//PLASMA

/turf/simulated/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	floor_tile = /obj/item/stack/tile/mineral/plasma

	New()
		if(floor_tile)
			returnToPool(floor_tile)
			floor_tile = null
		floor_tile = getFromPool(/obj/item/stack/tile/mineral/plasma, null)
		..()

//GOLD

/turf/simulated/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	floor_tile = /obj/item/stack/tile/mineral/gold

	New()
		if(floor_tile)
			returnToPool(floor_tile)
			floor_tile = null
		floor_tile = getFromPool(/obj/item/stack/tile/mineral/gold, null)
		..()

//SILVER

/turf/simulated/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	floor_tile = /obj/item/stack/tile/mineral/silver

	New()
		if(floor_tile)
			returnToPool(floor_tile)
			floor_tile = null
		floor_tile = getFromPool(/obj/item/stack/tile/mineral/silver, null)
		..()

//BANANIUM

/turf/simulated/floor/mineral/clown
	name = "bananium floor"
	icon_state = "bananium"
	floor_tile = /obj/item/stack/tile/mineral/clown
	var/spam_flag = 0

	New()
		if(floor_tile)
			returnToPool(floor_tile)
			floor_tile = null
		floor_tile = getFromPool(/obj/item/stack/tile/mineral/clown, null)
		..()

/turf/simulated/floor/mineral/clown/Entered(var/mob/AM)
	.=..()
	if(!.)
		if(istype(AM))
			squeek()

/turf/simulated/floor/mineral/clown/attackby(obj/item/weapon/W, mob/user, params)
	.=..()
	if(!.)
		honk()

/turf/simulated/floor/mineral/clown/attack_hand(mob/user)
	.=..()
	if(!.)
		honk()

/turf/simulated/floor/mineral/clown/attack_paw(mob/user)
	.=..()
	if(!.)
		honk()

/turf/simulated/floor/mineral/clown/proc/honk()
	if(!spam_flag)
		spam_flag = 1
		playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
		spawn(20)
			spam_flag = 0

/turf/simulated/floor/mineral/clown/proc/squeek()
	if(!spam_flag)
		spam_flag = 1
		playsound(src, "clownstep", 50, 1)
		spawn(10)
			spam_flag = 0

//DIAMOND

/turf/simulated/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	floor_tile = /obj/item/stack/tile/mineral/diamond

	New()
		if(floor_tile)
			returnToPool(floor_tile)
			floor_tile = null
		floor_tile = getFromPool(/obj/item/stack/tile/mineral/diamond, null)
		..()

//URANIUM

/turf/simulated/floor/mineral/uranium
	name = "uranium floor"
	icon_state = "uranium"
	floor_tile = /obj/item/stack/tile/mineral/uranium

	New()
		if(floor_tile)
			returnToPool(floor_tile)
			floor_tile = null
		floor_tile = getFromPool(/obj/item/stack/tile/mineral/uranium, null)
		..()
