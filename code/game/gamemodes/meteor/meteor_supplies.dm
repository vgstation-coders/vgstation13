//This is where we spawn the supplies to declutter everything. The supply drop event is under meteor_subevents

/proc/meteorsupplyspawning()

	//For barricades and materials
	for(var/turf/T in meteor_materialkit)
		meteor_materialkit -= T
		for(var/atom/A in T) //Cleaning loop borrowed from the shuttle
			//if(istype(A,/mob/living))
				//var/mob/living/unlucky_person = A
				//unlucky_person.gib() //We told you to get the fuck out of here
			if(istype(A,/obj) || istype(A,/turf/simulated/wall)) //Remove anything in the way
				qdel(A) //Telegib
		spawn()
			spark_system.attach(T)
			spark_system.set_up(5, 0, T)
			spark_system.start()
			new /obj/structure/rack(T)
			new /obj/item/stack/sheet/wood(T, 50) //20 cade kits, or miscellaneous things
			new /obj/item/stack/sheet/wood(T, 50)
			new /obj/item/stack/sheet/metal(T, 50)
			new /obj/item/stack/sheet/glass(T, 50)
			new /obj/item/stack/sheet/rglass/plasmarglass(T, 50) //Bomb-proof, so very useful

	//Discount EVA that also acts as explosion shielding
	for(var/turf/T in meteor_bombkit)
		meteor_bombkit -= T
		for(var/atom/A in T)
			//if(istype(A,/mob/living))
				//var/mob/living/unlucky_person = A
				//unlucky_person.gib()
			if(istype(A,/obj) && !istype(A, /obj/machinery/atmospherics) || istype(A,/turf/simulated/wall)) //Snowflake code since some instances are over pipes
				qdel(A)
		spawn()
			spark_system.attach(T)
			spark_system.set_up(5, 0, T)
			spark_system.start()
			new /obj/machinery/suit_storage_unit/meteor_eod(T)

	//Things that don't fit in the EVA kits
	for(var/turf/T in meteor_bombkitextra)
		meteor_bombkitextra -= T
		for(var/atom/A in T)
			//if(istype(A,/mob/living))
				//var/mob/living/unlucky_person = A
				//unlucky_person.gib()
			if(istype(A,/obj) || istype(A,/turf/simulated/wall))
				qdel(A)
		spawn()
			spark_system.attach(T)
			spark_system.set_up(5, 0, T)
			spark_system.start()
			new /obj/structure/table(T) //Enough racks already
			new /obj/item/clothing/gloves/black(T) //Always dress with style
			new /obj/item/clothing/gloves/black(T)
			new /obj/item/clothing/gloves/black(T)
			new /obj/item/clothing/gloves/black(T)
			new /obj/item/clothing/gloves/black(T)
			new /obj/item/clothing/gloves/black(T)
			new /obj/item/clothing/glasses/sunglasses(T) //Wouldn't it be dumb if a meteor explosion blinded you
			new /obj/item/clothing/glasses/sunglasses(T)
			new /obj/item/clothing/glasses/sunglasses(T)
			new /obj/item/clothing/glasses/sunglasses(T)
			new /obj/item/clothing/glasses/sunglasses(T)
			new /obj/item/clothing/glasses/sunglasses(T)

	//Free oxygen tanks
	for(var/turf/T in meteor_tankkit)
		meteor_tankkit -= T
		for(var/atom/A in T)
			//if(istype(A,/mob/living))
				//var/mob/living/unlucky_person = A
				//unlucky_person.gib()
			if(istype(A,/obj) || istype(A,/turf/simulated/wall))
				qdel(A)
		spawn()
			spark_system.attach(T)
			spark_system.set_up(5, 0, T)
			spark_system.start()
			new /obj/structure/dispenser/oxygen(T)

	//Oxygen canisters for internals, don't waste 'em
	for(var/turf/T in meteor_canisterkit)
		meteor_canisterkit -= T
		for(var/atom/A in T)
			//if(istype(A,/mob/living))
				//var/mob/living/unlucky_person = A
				//unlucky_person.gib()
			if(istype(A,/obj) || istype(A,/turf/simulated/wall))
				qdel(A)
		spawn(1)
			spark_system.attach(T)
			spark_system.set_up(5, 0, T)
			spark_system.start()
			new /obj/machinery/portable_atmospherics/canister/oxygen(T)

			//WE BUILD
	for(var/turf/T in meteor_buildkit)
		meteor_buildkit -= T
		for(var/atom/A in T)
			//if(istype(A,/mob/living))
				//var/mob/living/unlucky_person = A
				//unlucky_person.gib()
			if(istype(A,/obj) || istype(A,/turf/simulated/wall))
				qdel(A)
		spawn(1)
			spark_system.attach(T)
			spark_system.set_up(5, 0, T)
			spark_system.start()
			new /obj/structure/rack(T)
			new /obj/item/weapon/storage/toolbox/electrical(T)
			new /obj/item/weapon/storage/toolbox/electrical(T)
			new /obj/item/weapon/storage/toolbox/mechanical(T)
			new /obj/item/weapon/storage/toolbox/mechanical(T)
			new /obj/item/clothing/head/welding(T)
			new /obj/item/clothing/head/welding(T)
			new /obj/item/device/multitool(T)
			new /obj/item/device/multitool(T)

	//Because eating is important
	for(var/turf/T in meteor_pizzakit)
		meteor_pizzakit -= T
		for(var/atom/A in T)
			//if(istype(A,/mob/living))
				//var/mob/living/unlucky_person = A
				//unlucky_person.gib()
			if(istype(A,/obj) || istype(A,/turf/simulated/wall))
				qdel(A)
		spawn(1)
			spark_system.attach(T)
			spark_system.set_up(5, 0, T)
			spark_system.start()
			new /obj/structure/closet/crate/meteor_pizza(T)

	//Don't panic
	for(var/turf/T in meteor_panickit)
		meteor_panickit -= T
		for(var/atom/A in T)
			//if(istype(A,/mob/living))
				//var/mob/living/unlucky_person = A
				//unlucky_person.gib()
			if(istype(A,/obj) || istype(A,/turf/simulated/wall))
				qdel(A)
		spawn(1)
			spark_system.attach(T)
			spark_system.set_up(5, 0, T)
			spark_system.start()
			new /obj/structure/rack(T)
			new /obj/item/weapon/storage/toolbox/emergency(T)
			new /obj/item/weapon/storage/toolbox/emergency(T)
			new /obj/item/device/violin(T) //My tune will go on
			new /obj/item/weapon/paper_bin(T) //Any last wishes ?
			new /obj/item/weapon/pen/red(T)

	//Emergency Area Shielding. Uses a lot of power
	for(var/turf/T in meteor_shieldkit) //Note : Has been replaced directly with the meteor monitor build kit for now. Actual update to the supply spawns will be done much later
		meteor_shieldkit -= T
		for(var/atom/A in T)
			//if(istype(A,/mob/living))
				//var/mob/living/unlucky_person = A
				//unlucky_person.gib()
			if(istype(A,/obj) || istype(A,/turf/simulated/wall))
				qdel(A)
		spawn(1)
			spark_system.attach(T)
			spark_system.set_up(5, 0, T)
			spark_system.start()
			new /obj/structure/closet/crate/meteormonitorbuildkit(T)
			//new /obj/machinery/shieldgen(T)

	//Power that should last for a bit. Pairs well with the shield generator when Engineering is dead
	for(var/turf/T in meteor_genkit)
		meteor_genkit -= T
		for(var/atom/A in T)
			//if(istype(A,/mob/living))
				//var/mob/living/unlucky_person = A
				//unlucky_person.gib()
			if(istype(A,/obj) || istype(A,/turf/simulated/wall))
				qdel(A)
		spawn(1)
			spark_system.attach(T)
			spark_system.set_up(5, 0, T)
			spark_system.start()
			new /obj/machinery/power/port_gen/pacman(T)
			new /obj/item/stack/sheet/mineral/plasma(T, 20)

	for(var/turf/T in meteor_breachkit)
		meteor_breachkit -= T
		for(var/atom/A in T)
			//if(istype(A,/mob/living))
				//var/mob/living/unlucky_person = A
				//unlucky_person.gib()
			if(istype(A,/obj) || istype(A,/turf/simulated/wall))
				qdel(A)
		spawn(1)
			spark_system.attach(T)
			spark_system.set_up(5, 0, T)
			spark_system.start()
			new /obj/structure/closet/crate/meteorengi(T)

			//Use existing templates in landmarks.dm, global.dm and here to add more supplies

//This is where we create packs and custom supplies. The EOD suit dispenser is available under suit dispensers

/obj/structure/closet/crate/meteor_pizza
	desc = "Covered in meteor dust, but the food inside must still be good."
	name = "space weather inc. food rations"
	icon = 'icons/obj/storage.dmi'
	icon_state = "freezer"
	density = 1
	icon_opened = "freezeropen"
	icon_closed = "freezer"

/obj/structure/closet/crate/meteor_pizza/New()
	..()
	new /obj/item/pizzabox/margherita(src)
	new /obj/item/pizzabox/mushroom(src)
	new /obj/item/pizzabox/meat(src)
	new /obj/item/pizzabox/vegetable(src)
	new /obj/item/weapon/kitchenknife(src)

/obj/structure/closet/crate/meteorengi
	desc = "Good to patch up holes in a hurry, soak meteor hits and keep idiots away from the window bays."
	name = "space weather inc. emergency kit"
	icon = 'icons/obj/storage.dmi'
	icon_state = "engicrate"
	density = 1
	icon_opened = "engicrateopen"
	icon_closed = "engicrate"

/obj/structure/closet/crate/meteorengi/New()
	..()
	new /obj/item/taperoll/atmos(src) //Just for the hell of it
	new /obj/item/taperoll/atmos(src)
	new /obj/item/weapon/grenade/chem_grenade/metalfoam(src) //Could use a custom box
	new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)
	new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)
	new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)

/obj/structure/closet/crate/meteormonitorbuildkit
	desc = "This crate contains the most precious supply you'll ever need in a meteor storm. A computer telling you how fucked you are and how you're going to be fucked"
	name = "space weather inc. meteor monitor build kit"
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	density = 1
	icon_opened = "crateopen"
	icon_closed = "crate"

/obj/structure/closet/crate/meteormonitorbuildkit/New()
	..()
	new /obj/item/stack/sheet/metal(src, 5)
	new /obj/item/stack/sheet/glass(src, 2)
	new /obj/item/weapon/cable_coil(src, 30)
	new /obj/item/weapon/circuitboard/meteormonitor(src)
