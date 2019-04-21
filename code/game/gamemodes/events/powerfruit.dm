//the actual powerfruit obj

/datum/seed/powerfruit
	name = "powerfruit"
	seed_name = "powerfruit"
	display_name = "powerfruit vines"
	packet_icon = "seed-powerfruit"
	products = list()
	plant_icon = "powerfruit"
	chems = list()

	lifespan = 20
	maturation = 6
	production = 6
	yield = 4
	potency = 20
	growth_stages = 4
	spread = 2
	water_consumption = 0.5

/obj/effect/plantsegment/powerfruit
	name = "powerfruit"
	desc = "A strange alien fruit somehow creating. How curious! It looks dangerous, better not touch it"
	icon = 'icons/obj/lighting.dmi' //TODO
	icon_state = "glowshroomf" //TODO
	var/datum/powerfruit_hive/hive = null
	var/rebuild = 1

/obj/effect/plantsegment/powerfruit/Destroy()
	if(importantToHive())
		hive.rebuild()
	hive.removeFruit(src)
	..()

/obj/effect/plantsegment/powerfruit/proc/importantToHive() //*might, just to boost performance a bit
	if(!hive) return
	//find some way to check if two of my neighbours are next to each other, if not, return true

/obj/effect/plantsegment/powerfruit/process()
	..()
	if(rebuild)
		for(var/turf/N in get_cardinal_neighbors())


		if(!hive)
			hive = new /datum/powerfruit_hive()
		//search for adjacent powerfruits, adapt their hive.
		//if there are multiple hive, connect them
		//if none are available, make own hive
		rebuild = 0

	//if there is a cable underneath and the hive has no connector yet, make this a connector, no need to rebuild, we just replace this obj with the connector one

	//if there is a person caught in the vines, burn em a bit

//electrocute people who aren't insulated

//connector, a subclass of the powerfruit which connects to the powernet
/obj/effect/plantsegment/powerfruit/connector
	name = "Connector"
	desc = "The vines intersect with the cable on the ground. This must be where all the power is fed into the network."
	icon = 'icons/obj/lighting.dmi' //TODO
	icon_state = "glowshroomf" //TODO

/obj/effect/plantsegment/powerfruit/connector/devolve()
	//devolve back into a powerfruit
	//create powerfruit at pos and qdel myself

//the powerfruit hivemind datum, handling all the connected powerfruit
/datum/powerfruit_hive/
	var/list/powerfruits
	var/obj/effect/plantsegment/powerfruit/connector/connection

/datum/powerfruit_hive/addFruit(var/obj/effect/plantsegment/powerfruit/F)


/datum/powerfruit_hive/removeFruit(var/obj/effect/plantsegment/powerfruit/F)

/datum/powerfruit_hive/proc/getPower()
	return powerfruits.len * 100 //prone to change, maybe take plant quality into account

/datum/powerfruit_hive/proc/rebuild()
	if(connection) connection.devolve()

	for(var/obj/effect/plantsegment/powerfruit/F in powerfruits)
		F.rebuild = 1

/datum/powerfruit_hive/proc/absorb(var/datum/powerfruit_hive/H)
	for(var/obj/effect/plantsegment/powerfruit/F in H.powerfruits)
		F.hive = src
		powerfruits += F

	if(H.connection) connection.devolve()

	qdel(H)
