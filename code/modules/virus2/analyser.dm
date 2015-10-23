/obj/machinery/disease2/diseaseanalyser
	name = "Disease Analyser"
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1

	machine_flags = SCREWTOGGLE | CROWDESTROY

	var/scanning = 0
	var/pause = 0
	var/process_time = 5
	var/minimum_growth = 50

	var/obj/item/weapon/virusdish/dish = null

/obj/machinery/disease2/diseaseanalyser/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/diseaseanalyser,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
	)

	RefreshParts()

/obj/machinery/disease2/diseaseanalyser/RefreshParts()
	var/scancount = 0
	var/lasercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/scanning_module)) scancount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser)) lasercount += SP.rating-1
	minimum_growth = initial(minimum_growth) - (scancount * 3)
	process_time = initial(process_time) - lasercount

/obj/machinery/disease2/diseaseanalyser/attackby(var/obj/I as obj, var/mob/user as mob)
	..()
	if(istype(I,/obj/item/weapon/virusdish))
		var/mob/living/carbon/c = user
		if(!dish)
			if(c.drop_item(I,src))
				dish = I
				for(var/mob/M in viewers(src))
					if(M == user)	continue
					M.show_message("<span class='notice'>[user.name] inserts the [dish.name] in the [src.name]</span>", 3)
		else
			user << "There is already a dish inserted"
	return


/obj/machinery/disease2/diseaseanalyser/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)

	if(scanning)
		scanning -= 1
		if(scanning == 0)
			var/r = dish.virus2.get_info()

			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src.loc)
			P.info = r
			dish.info = r
			dish.analysed = 1
			if (dish.virus2.addToDB())
				say("Added new pathogen to database.")
			dish.loc = src.loc
			dish = null
			icon_state = "analyser"

			visible_message("\The [src.name] prints a sheet of paper")

	else if(dish && !scanning && !pause)
		if(dish.virus2 && dish.growth > minimum_growth)
			dish.growth -= 10
			scanning = process_time
			icon_state = "analyser_processing"
		else
			pause = 1
			spawn(25)
				dish.loc = src.loc
				dish = null
				alert_noise("buzz")
				pause = 0
	return