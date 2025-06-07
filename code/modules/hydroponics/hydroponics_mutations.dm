/obj/machinery/portable_atmospherics/hydroponics/proc/generic_mutation_message(var/text = "quivers!")
	visible_message("<span class='notice'>\The [seed.display_name] [text]</span>")

/obj/machinery/portable_atmospherics/hydroponics/proc/check_for_divergence(var/modified = 0)
	// We need to make sure we're not modifying one of the global seed datums.
	// If it's not in the global list, then no products of the line have been
	// harvested yet and it's safe to assume it's restricted to this tray.
	if(!isnull(SSplant.seeds[seed.name]))
		seed = seed.diverge(modified)

/obj/machinery/portable_atmospherics/hydroponics/proc/mutate(var/gene)
	if(!seed)
		return
	if(seed.immutable)
		return
	if(age < 3 && length(seed.mutants) && gene)
		mutate_species()
	if(!gene)
		gene = pick(GENE_PHYTOCHEMISTRY, GENE_MORPHOLOGY, GENE_BIOLUMINESCENCE, GENE_ECOLOGY, GENE_ECOPHYSIOLOGY, GENE_METABOLISM, GENE_DEVELOPMENT, GENE_XENOPHYSIOLOGY)

	check_for_divergence()
	//The scaling functions modify stats with diminishing returns, approaching the hardcap value
	//15% is currently default for the maximum change in most cases
	//Log function so can't be equal to or less than 0, there are special cases where below a threshold the value is set to 0
	//Be aware the formulas are slightly different for lowering and increasing values inside log() and also min()
	switch(gene)
		if(GENE_PHYTOCHEMISTRY)
			var/mutation_type = pick(85; PLANT_POTENCY, 15; PLANT_CHEMICAL)
			switch(mutation_type)
				if(PLANT_POTENCY)
					if(seed.potency <= 0)
						return
					var/hardcap = 200.15 //finally fixes the 198 potency thing
					var/max_change = 0.11 //percent
					seed.potency += round(min(hardcap - hardcap/2*log(10,seed.potency/hardcap*100),max_change*hardcap),0.1)
					generic_mutation_message("quivers!")
				if(PLANT_CHEMICAL)
					var/check_success = FALSE
					if(prob(50))
						check_success = seed.remove_random_chemical()
						if(check_success)
							visible_message("<span class='notice'>\A gland on the [seed.display_name] withers and dies.</span>")
					if(prob(50))
						check_success = seed.add_random_chemical()
						if(check_success)
							visible_message("<span class='notice'>\The [seed.display_name] develops a strange-looking gland.</span>")

		if(GENE_MORPHOLOGY)
			var/mutation_type = pick(PLANT_PRODUCTS, PLANT_THORNY, PLANT_JUICY, PLANT_LIGNEOUS, PLANT_STINGING, PLANT_APPEARANCE)
			switch(mutation_type)
				if(PLANT_PRODUCTS)
					seed.products += pick(subtypesof(/obj/item/weapon/reagent_containers/food/snacks/grown))
					visible_message("<span class='notice'>\The [seed.display_name] seems to be growing something weird.</span>")
				if(PLANT_THORNY)
					seed.thorny = !seed.thorny
					if(seed.thorny)
						visible_message("<span class='notice'>\The [seed.display_name] spontaneously develops mean-looking thorns!</span>")
					else
						visible_message("<span class='notice'>\The [seed.display_name] sheds its thorns away...</span>")
				if(PLANT_JUICY)
					//clever way of going from 0 to 1 to 2. 
					seed.juicy = (seed.juicy + 1) % 3
					generic_mutation_message("wobbles!")
				if(PLANT_LIGNEOUS)
					seed.ligneous = !seed.ligneous
					if(seed.ligneous)
						visible_message("<span class='notice'>\The [seed.display_name] seems to grow a cover of robust bark.</span>")
					else
						visible_message("<span class='notice'>\The [seed.display_name]'s bark slowly sheds away...</span>")
				if(PLANT_STINGING)
					seed.stinging = !seed.stinging
					if(seed.stinging)
						visible_message("<span class='notice'>\The [seed.display_name] sprouts a coat of chemical stingers!</span>")
					else
						visible_message("<span class='notice'>\The [seed.display_name]'s stingers dry off and break...</span>")
				if(PLANT_APPEARANCE)
					seed.randomize_icon()
					update_icon()
					visible_message("<span class='notice'>\The [seed.display_name] suddenly looks a little different.</span>")

		if(GENE_BIOLUMINESCENCE)
			var/mutation_type = pick(seed.biolum ? 10 : 0;	PLANT_BIOLUM_COLOR, seed.biolum ? 1 : 10; PLANT_BIOLUM)
			switch(mutation_type)
				if(PLANT_BIOLUM)
					seed.biolum = !seed.biolum
					if(seed.biolum)
						visible_message("<span class='notice'>\The [seed.display_name] begins to glow!</span>")
						if(!seed.biolum_colour)
							seed.biolum_colour = "#[get_random_colour(1)]"
					else
						visible_message("<span class='notice'>\The [seed.display_name]'s glow dims...</span>")
				if(PLANT_BIOLUM_COLOR)
					seed.biolum_colour = "#[get_random_colour(0,75,190)]"
					visible_message("<span class='notice'>\The [seed.display_name]'s glow <font color='[seed.biolum_colour]'>changes colour</font>!</span>")
			update_icon()

		if(GENE_ECOLOGY)
			var/mutation_type = pick(PLANT_TEMPERATURE_IDEAL, PLANT_HEAT_TOLERANCE, PLANT_PRESSURE_TOLERANCE,PLANT_LIGHT_TOLERANCE, PLANT_LIGHT_IDEAL)
			switch(mutation_type)
				if(PLANT_TEMPERATURE_IDEAL)
					//Variance so small that it can be fixed by just touching the thermostat, but I guarantee people will just apply a new enviro gene anyways
					seed.ideal_heat = rand(253,343)
				if(PLANT_HEAT_TOLERANCE)
					var/hardcap = 800
					var/max_change = 0.10 //percent
					seed.heat_tolerance += round(min(hardcap - hardcap/2*round(log(10,seed.heat_tolerance/hardcap*100),0.01),max_change*hardcap),0.1)
				if(PLANT_PRESSURE_TOLERANCE)
					if(seed.lowkpa_tolerance < 1)
						seed.lowkpa_tolerance = 0
					else
						//lower better
						var/hardcap = 0.1
						var/max_change = 0.15 //percent
						seed.lowkpa_tolerance -= round(min(hardcap - hardcap/2*round(log(10,hardcap/seed.lowkpa_tolerance*100),0.01),max_change*seed.lowkpa_tolerance),0.1) 
					//higher better
					var/hardcap = 500
					var/max_change = 0.15 //percent
					seed.highkpa_tolerance += round(min(hardcap - hardcap/2*round(log(10,seed.highkpa_tolerance/hardcap*100),0.01),max_change*hardcap),0.1)
				if(PLANT_LIGHT_IDEAL)
					seed.ideal_light = rand(2,10)
				if(PLANT_LIGHT_TOLERANCE)
					var/hardcap = 10
					var/max_change = 0.15 //percent
					seed.light_tolerance += round(min(hardcap - hardcap/2*round(log(10,seed.light_tolerance/hardcap*100),0.01),max_change*hardcap),0.1)
			generic_mutation_message("shakes!")

		if(GENE_ECOPHYSIOLOGY)
			var/mutation_type = pick(PLANT_TOXIN_AFFINITY, PLANT_WEED_TOLERANCE, PLANT_PEST_TOLERANCE, PLANT_LIFESPAN, PLANT_ENDURANCE)
			switch(mutation_type)
				if(PLANT_TOXIN_AFFINITY)
					var/hardcap = 110
					var/max_change = 0.15 //percent
					seed.toxin_affinity += round(min(hardcap - hardcap/2*round(log(10,seed.toxin_affinity/hardcap*100),0.01),max_change*hardcap),0.1)
				if(PLANT_WEED_TOLERANCE)
					var/hardcap = 110
					var/max_change = 0.15 //percent
					seed.weed_tolerance += round(min(hardcap - hardcap/2*round(log(10,seed.weed_tolerance/hardcap*100),0.01),max_change*hardcap),0.1)
				if(PLANT_PEST_TOLERANCE)
					var/hardcap = 110
					var/max_change = 0.15 //percent
					seed.pest_tolerance += round(min(hardcap - hardcap/2*round(log(10,seed.pest_tolerance/hardcap*100),0.01),max_change*hardcap),0.1)
				if(PLANT_LIFESPAN)
					var/hardcap = 125
					var/max_change = 0.15 //percent
					seed.lifespan += round(min(hardcap - hardcap/2*round(log(10,seed.lifespan/hardcap*100),0.01),max_change*hardcap),0.1)
				if(PLANT_ENDURANCE)
					var/hardcap = 125
					var/max_change = 0.15 //percent
					seed.endurance += round(min(hardcap - hardcap/2*round(log(10,seed.endurance/hardcap*100),0.01),max_change*hardcap),0.1)
			generic_mutation_message("quivers!")

		if(GENE_METABOLISM)
			var/mutation_type = pick(30; PLANT_NUTRIENT_CONSUMPTION, 30; PLANT_FLUID_CONSUMPTION, 20; PLANT_VORACIOUS, 20; PLANT_HEMATOPHAGE)
			switch(mutation_type)
				if(PLANT_NUTRIENT_CONSUMPTION)
					if(seed.nutrient_consumption < 0.1)
						seed.nutrient_consumption = 0
					else
						//Lower better. Using simple linear function as values too small for log base 10
						var/change = 0.16 //percent
						seed.nutrient_consumption -= change*seed.nutrient_consumption
					generic_mutation_message("rustles!")
				if(PLANT_FLUID_CONSUMPTION)
					if(seed.fluid_consumption < 0.1)
						seed.fluid_consumption = 0
					else
						//Lower better. Using simple linear function as values too small for log base 10
						var/change = 0.16 //percent
						seed.fluid_consumption -= change*seed.fluid_consumption
					generic_mutation_message("rustles!")
				if(PLANT_VORACIOUS)
					//clever way of going from 0 to 1 to 2.
					seed.voracious = (seed.voracious + 1) % 3
					generic_mutation_message("shudders hungrily.")
				if(PLANT_HEMATOPHAGE)
					seed.hematophage = !seed.hematophage
					if(seed.hematophage)
						visible_message("<span class='notice'>\The [seed.display_name] shudders thirstily, turning red at the roots!</span>")
						add_nutrientlevel(-80)
					else
						visible_message("<span class='notice'>\The [seed.display_name]'s red roots slowly wash their color out...</span>")
		if(GENE_DEVELOPMENT)
			var/mutation_type
			if(seed.yield == -1)
				//These have a yield that is not allowed to be modified
				mutation_type = pick(PLANT_PRODUCTION, PLANT_MATURATION, PLANT_SPREAD)
			else
				mutation_type = pick(28; PLANT_PRODUCTION, 28; PLANT_MATURATION, 8; PLANT_SPREAD, 8; PLANT_HARVEST, 28; PLANT_YIELD)
			switch(mutation_type)
				if(PLANT_PRODUCTION)
					//lower better
					var/hardcap = 1
					var/max_change = 0.15 //percent
					seed.production -= round(min(hardcap - hardcap/2*round(log(10,hardcap/seed.production*100),0.01),max_change*seed.production),0.1)
					generic_mutation_message("wriggles!")
				if(PLANT_MATURATION)
					//lower better
					var/hardcap = 1.1
					var/max_change = 0.15 //percent
					seed.maturation -= round(min(hardcap - hardcap/2*round(log(10,hardcap/seed.maturation*100),0.01),max_change*seed.maturation),0.1)
					generic_mutation_message("wriggles!")
				if(PLANT_SPREAD)
					seed.spread = (seed.spread + 1) % 3
					if(src && seed && seed.spread == 1)
						visible_message("<span class='notice'>\The [seed.display_name] shifts in the tray!</span>")
						spawn(20)
							var/datum/seed/newseed = seed.diverge()
							newseed.spread = 1
							var/turf/T = get_turf(src)
							new /obj/effect/plantsegment(T, newseed)
							msg_admin_attack("a random chance hydroponics mutation has spawned limited growth creeper vines ([newseed.display_name]). <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>")
					else if(src && seed && seed.spread == 2)
						visible_message("<span class='notice'>\The [seed.display_name] spasms visibly, violently thrashing in the tray!</span>")
						var/datum/seed/newseed = seed.diverge()
						newseed.spread = 2
						var/turf/T = get_turf(src)
						new /obj/effect/plantsegment(T, newseed)
						msg_admin_attack("a random chance hydroponics mutation has spawned space vines ([newseed.display_name]). <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>")
					else
						visible_message("<span class='notice'>\The [seed.display_name] recedes into the tray.</span>")
				if(PLANT_HARVEST)
					var/new_harvest
					if(seed.harvest_repeat == 2)
						new_harvest = 1
					else
						new_harvest = !seed.harvest_repeat
					if(seed.harvest_repeat < new_harvest)
						visible_message("<span class='notice'>\The [seed.display_name] roots deep and sprouts new stalks!</span>")
					else
						visible_message("<span class='notice'>\The [seed.display_name] wilts away some of its roots.</span>")
					seed.harvest_repeat = new_harvest
				if(PLANT_YIELD)
					if(seed.yield <= 0)
						return
					var/hardcap = 16
					seed.yield += round(min(hardcap - hardcap/2*round(log(10,seed.yield/hardcap*100),0.01),0.15*hardcap),0.1)
		if(GENE_XENOPHYSIOLOGY)
			var/mutation_type = pick(PLANT_TELEPORT, PLANT_GAS, PLANT_ROOMTEMP, PLANT_NOREACT)
			switch(mutation_type)
				if(PLANT_TELEPORT)
					//Toggle true or false
					seed.teleporting = !seed.teleporting
					if(seed.teleporting)
						visible_message("<span class='notice'>\The [seed.display_name] wobbles unstably, glowing blue for a moment!</span>")
					else
						visible_message("<span class='notice'>\The [seed.display_name] slowly becomes spatial-temporally stable again.</span>")
				if(PLANT_GAS)
					if(length(seed.consume_gasses) && prob(50))
						seed.consume_gasses -= pick(seed.consume_gasses)
					if(prob(50))
						var/gas = pick(GAS_OXYGEN, GAS_NITROGEN, GAS_PLASMA, GAS_CARBON)
						seed.consume_gasses[gas] = rand(3,9)
					if(length(seed.exude_gasses) && prob(50))
						seed.exude_gasses -= pick(seed.exude_gasses)
					if(prob(50))
						var/gas = pick(GAS_OXYGEN, GAS_NITROGEN, GAS_PLASMA, GAS_CARBON)
						seed.exude_gasses[gas] = rand(3,9)
					generic_mutation_message("rustles!")
				if(PLANT_ROOMTEMP)
					seed.alter_temp = !seed.alter_temp
					generic_mutation_message("rustles!")

//Returns a key corresponding to an entry in the global seed list.
/datum/seed/proc/get_mutant_variant()
	if(!mutants || !mutants.len || immutable > 0)
		return 0
	return pick(mutants)

/obj/machinery/portable_atmospherics/hydroponics/proc/mutate_species()
	var/previous_plant = seed.display_name
	var/newseed = seed.get_mutant_variant()

	seed = SSplant.seeds[newseed]
	if(!seed)
		return
	dead = 0
	age = 1
	health = seed.endurance
	lastcycle = world.time
	harvest = 0
	sampled = 0

	update_icon()
	visible_message("<span class='alert'>The</span> <span class='italics,alert'>[previous_plant]</span> <span class='alert'>has suddenly mutated into</span> <span class='italics,alert'>[seed.display_name]!</span>")
