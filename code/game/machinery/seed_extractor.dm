/obj/machinery/seed_extractor
	name = "\improper seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "sextractor"
	density = 1
	anchored = 1
	var/opened = 0.0

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/seed_extractor/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/seed_extractor,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

obj/machinery/seed_extractor/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/F = O
		user.drop_item()
		user << "<span class='notice'>You extract some seeds from [F].</span>"
		var/seed = text2path(F.seed)
		var/t_amount = 0
		var/t_max = rand(1,4)
		while(t_amount < t_max)
			var/obj/item/seeds/t_prod = new seed(loc)
			t_prod.species = F.species
			t_prod.lifespan = F.lifespan
			t_prod.endurance = F.endurance
			t_prod.maturation = F.maturation
			t_prod.production = F.production
			t_prod.yield = F.yield
			t_prod.potency = F.potency
			t_amount++
		del(O)

	else if(istype(O, /obj/item/weapon/grown/))
		var/obj/item/weapon/grown/F = O
		user.drop_item()
		user << "<span class='notice'>You extract some seeds from [F].</span>"
		var/seed = text2path(F.seed)
		var/t_amount = 0
		var/t_max = rand(1,4)
		while(t_amount < t_max)
			var/obj/item/seeds/t_prod = new seed(loc)
			t_prod.species = F.species
			t_prod.lifespan = F.lifespan
			t_prod.endurance = F.endurance
			t_prod.maturation = F.maturation
			t_prod.production = F.production
			t_prod.yield = F.yield
			t_prod.potency = F.potency
			t_amount++
		del(O)

	else if(istype(O, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/S = O
		user << "<span class='notice'>You extract some seeds from [S].</span>"
		S.use(1)
		new /obj/item/seeds/grassseed(loc)

	if(O)
		var/obj/item/F = O
		if(F.nonplant_seed_type)
			user.drop_item()
			var/t_amount = 0
			var/t_max = rand(1,4)
			while(t_amount < t_max)
				new F.nonplant_seed_type(src.loc)
				t_amount++
			del(F)

	else if (istype(O, /obj/item/weapon/screwdriver))
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
		if (!opened)
			user.visible_message("<span class='warning'>[user] opens [src]'s maintenance hatch!</span>", "<span class='notice'>You open [src]'s maintenance hatch.</span>")
			src.opened = 1
		else
			user.visible_message("<span class='warning'>[user] closes [src]'s maintenance hatch!</span>", "<span class='notice'>You close [src]'s maintenance hatch.</span>")
			src.opened = 0
		return 1
	else if(istype(O, /obj/item/weapon/crowbar))
		if (opened)
			user.visible_message("<span class='warning'>[user] begins to remove the circuits from [src]!</span>", "<span class='notice'>You begin to remove the circuits from [src].</span>")
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			if(do_after(user,50))
				user.visible_message("<span class='warning'>[user] removes the circuits from [src]!", "<span class='notice'>You remove the circuits from [src].</span>")
				var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				M.state = 2
				M.icon_state = "box_1"
				for(var/obj/I in component_parts)
					if(I.reliability != 100 && crit_fail)
						I.crit_fail = 1
					I.loc = src.loc
				del(src)
				return 1
