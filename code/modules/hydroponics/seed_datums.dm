var/global/list/seed_types = list()       // A list of all seed data.
var/global/list/gene_tag_masks = list()   // Gene obfuscation for delicious trial and error goodness.

/datum/plantgene
	var/genetype    // Label used when applying trait.
	var/list/values // Values to copy into the target seed datum.

/datum/seed

	//Tracking.
	var/uid                        // Unique identifier.
	var/name                       // Index for global list.
	var/seed_name                  // Plant name for seed packet.
	var/seed_noun = "seeds"        // Descriptor for packet.
	var/display_name               // Prettier name.
	var/roundstart                 // If set, seed will not display variety number.
	var/mysterious                 // Only used for the random seed packets.

	// Output.
	var/list/products              // Possible fruit/other product paths.
	var/list/mutants               // Possible predefined mutant varieties, if any.
	var/list/chems                 // Chemicals that plant produces in products/injects into victim. Total units of chemical in products: First value + (Potency/Second value)
	var/list/consume_gasses=list() // The plant will absorb these gasses during its life.
	var/list/exude_gasses=list()   // The plant will exude these gasses during its life.

	//Tolerances.
	var/nutrient_consumption = 0.25 // Plant eats this much per tick.
	var/water_consumption = 3       // Plant drinks this much per tick.
	var/ideal_heat = 293            // Preferred temperature in Kelvin.
	var/heat_tolerance = 20         // Departure from ideal that is survivable.
	var/ideal_light = 7             // Preferred light level in luminosity.
	var/light_tolerance = 5         // Departure from ideal that is survivable.
	var/toxins_tolerance = 4        // Resistance to poison.
	var/lowkpa_tolerance = 25       // Low pressure capacity.
	var/highkpa_tolerance = 200     // High pressure capacity.
	var/pest_tolerance = 5          // Threshold for pests to impact health.
	var/weed_tolerance = 5          // Threshold for weeds to impact health.

	//General traits.
	var/endurance = 100             // Maximum plant HP when growing.
	var/yield = 0                   // Amount of product.
	var/lifespan = 0                // Time before the plant dies.
	var/maturation = 0              // Time taken before the plant is mature.
	var/production = 0              // Time before harvesting can be undertaken again.
	var/growth_stages = 6           // Number of stages the plant passes through before it is mature.
	var/harvest_repeat = 0          // If 1, this plant will fruit repeatedly. If 2, the plant will self-harvest.
	var/potency = 1                 // General purpose plant strength value.
	var/spread = 0                  // 0 limits plant to tray, 1 = creepers, 2 = vines.
	var/immutable = 0               // If set, plant will never mutate. If -1, plant is  highly mutable.
	var/alter_temp = 0              // If set, the plant will periodically alter local temp by this amount.
	var/carnivorous = 0             // 0 = none, 1 = eat pests in tray, 2 = eat living things.
	var/parasite = 0                // 0 = no, 1 = gain health from weed level. //Todo: Some more interactions with this.
	var/hematophage = 0				// 0 = no, 1 = plant only gains nutriment from blood.
	var/thorny = 0					// If 1, does brute damage when touched without protection. Can't be held or harvested without gloves. Short for the Thorned Reaper.
	var/stinging = 0				// If 1, injects reagents when touched without protection.
	var/ligneous = 0				// If 1, requires sharp instrument to harvest. Kudzu with this trait resists sharp items better.
	var/teleporting = 0				// If 1, causes teleportation when thrown.
	var/juicy = 0					// 0 = no, 1 = splatters when thrown, 2 = slips

	// Cosmetics.
	var/plant_dmi = 'icons/obj/hydroponics/apple.dmi'// DMI  to use for the plant growing in the tray.
	var/plant_icon                  // Icon to use for the plant growing in the tray.
	var/packet_icon = "seed"        // Icon to use for physical seed packet item.
	var/biolum                      // Plant is bioluminescent.
	var/biolum_colour               // The colour of the plant's radiance.
	var/splat_type = /obj/effect/decal/cleanable/fruit_smudge //Decal to create if the fruit is splatter-able and subsequently splattered.

	var/mob_drop					// Seed type dropped by the mobs when it dies without an host

	var/large = 1					// Is the plant large? For clay pots.

/datum/seed/New()
	..()

//Creates a random seed. MAKE SURE THE LINE HAS DIVERGED BEFORE THIS IS CALLED.
/datum/seed/proc/randomize()


	roundstart = 0
	seed_name = "strange plant"     // TODO: name generator.
	display_name = "strange plants" // TODO: name generator.
	mysterious = 1

	seed_noun = pick("spores","nodes","cuttings","seeds")
	products = list(pick(typesof(/obj/item/weapon/reagent_containers/food/snacks/grown)-/obj/item/weapon/reagent_containers/food/snacks/grown))
	potency = rand(5,30)

	randomize_icon()

	if(prob(40))
		harvest_repeat = 1

	if(prob(5))
		consume_gasses = list()
		var/gas = pick(GAS_OXYGEN, GAS_NITROGEN, GAS_PLASMA, GAS_CARBON)
		consume_gasses[gas] = rand(3,9)

	if(prob(5))
		exude_gasses = list()
		var/gas = pick(GAS_OXYGEN, GAS_NITROGEN, GAS_PLASMA, GAS_CARBON)
		exude_gasses[gas] = rand(3,9)

	chems = list()
	if(prob(80))
		chems[NUTRIMENT] = list(rand(1,5),rand(5,10))

	var/additional_chems = rand(0,5)
	for(var/x=1;x<=additional_chems;x++)
		if(!add_random_chemical())
			break

	if(prob(90))
		nutrient_consumption = rand(30)/100
	else
		nutrient_consumption = 0

	if(prob(90))
		water_consumption = rand(10)
	else
		water_consumption = 0

	ideal_heat =       rand(273,313)
	heat_tolerance =   rand(10,30)
	ideal_light =      rand(2,10)
	light_tolerance =  rand(2,7)
	toxins_tolerance = rand(2,7)
	pest_tolerance =   rand(2,7)
	weed_tolerance =   rand(2,7)
	lowkpa_tolerance = rand(10,50)
	highkpa_tolerance = rand(100,300)

	if(prob(5))
		alter_temp = 1

	/*if(prob(1))
		immutable = -1*/ //todo this

	var/carnivore_prob = rand(100)
	if(carnivore_prob < 5)
		carnivorous = 2
	else if(carnivore_prob < 10)
		carnivorous = 1

	if(prob(5))
		parasite = 1

	var/vine_prob = rand(100)
	if(vine_prob < 5)
		spread = 2
	else if(vine_prob < 10)
		spread = 1

	if(prob(10))
		biolum = 1
		biolum_colour = "#[get_random_colour(1)]"

	if(prob(5))
		hematophage = 1

	if(prob(5))
		thorny = 1

	if(prob(5))
		stinging = 1

	if(prob(5))
		ligneous = 1

	var/juicy_prob = rand(100)
	if(juicy_prob < 5)
		juicy = 2
	else if(juicy_prob < 10)
		juicy = 1

	endurance = rand(60,100)
	yield = rand(2,15)
	maturation = rand(3,15)
	production = rand(3,10)
	lifespan = rand(4,15)*5

//Gives the plant a new, random icon from a list, with matching growth stages number.
/datum/seed/proc/add_random_chemical(var/severity = 15)
	var/list/possible_chems = list(
		// Important Medicines
		REZADONE = 200,
		PERIDAXON = 200,
		// Items of Botany Importance
		CRYOXADONE = 100,
		RADIUM = 100,
		PLASTICIDE = 100,
		// Items of Botanist Importance
		COCAINE = 100,
		THERMITE = 100,
		NICOTINE = 100,
		LEPORAZINE = 100,
		POTASSIUM = 100,
		PLASMA = 100,
		// Misc Medicines
		OPIUM = 100,
		INAPROVALINE = 100,
		RYETALYN = 100,
		ALKYSINE = 100,
		KATHALAI = 100,
		THYMOL = 100,
		DEXALINP = 75,
		HYRONALIN = 100,
		BLOOD = 100,
		PHYTOSINE = 100,
		PHYTOCARISOL = 100,
		// Misc Poisons
		PHYSOSTIGMINE = 100,
		MERCURY = 100,
		HYOSCYAMINE = 100,
		VALERENIC_ACID = 100,
		CYANIDE = 100,
		CURARE = 100,
		SOLANINE = 100,
		SLIMEJELLY = 75,
		// Fun Things
		MUTATIONTOXIN = 50,
		AMUTATIONTOXIN = 10,
		MESCALINE = 100,
		METHYLIN = 100,
		CARPPHEROMONES = 40,
		NOTHING = 50,
		MINDBREAKER = 100,
		MINTTOXIN = 60,
		DEFALEXORIN = 100,
		// Things of Dubious Use
		SUGAR = 100,
		ETHYLREDOXRAZINE = 100,
		PAROXETINE = 100,
		TRAMADOL = 100,
	)

	for(var/rid in chems)
		possible_chems -= rid
	if(!possible_chems.len)
		return 0
	var/new_chem = pickweight(possible_chems)
	chems[new_chem] = list(rand(1,severity/3),rand(10-Ceiling(severity/3),15))
	return 1

//Gives the plant a new, random icon from a list, with matching growth stages number.
/datum/seed/proc/randomize_icon()
	var/list/plant_icons = pick(list(
		list('icons/obj/hydroponics/chili.dmi',				6),
		list('icons/obj/hydroponics/chiliice.dmi',			6),
		list('icons/obj/hydroponics/berry.dmi',				6),
		list('icons/obj/hydroponics/glowberry.dmi',			6),
		list('icons/obj/hydroponics/poisonberry.dmi',			6),
		list('icons/obj/hydroponics/deathberry.dmi',			6),
		list('icons/obj/hydroponics/nettle.dmi',				6),
		list('icons/obj/hydroponics/deathnettle.dmi',			6),
		list('icons/obj/hydroponics/tomato.dmi',				6),
		list('icons/obj/hydroponics/bloodtomato.dmi',			6),
		list('icons/obj/hydroponics/killertomato.dmi',		2),
		list('icons/obj/hydroponics/bluetomato.dmi',			6),
		list('icons/obj/hydroponics/bluespacetomato.dmi',		6),
		list('icons/obj/hydroponics/eggplant.dmi',			6),
		list('icons/obj/hydroponics/eggy.dmi',				6),
		list('icons/obj/hydroponics/apple.dmi',				6),
		list('icons/obj/hydroponics/goldapple.dmi',			6),
		list('icons/obj/hydroponics/ambrosiavulgaris.dmi',	6),
		list('icons/obj/hydroponics/ambrosiadeus.dmi',		6),
		list('icons/obj/hydroponics/chanter.dmi',				3),
		list('icons/obj/hydroponics/plump.dmi',				3),
		list('icons/obj/hydroponics/reishi.dmi',				4),
		list('icons/obj/hydroponics/liberty.dmi',				3),
		list('icons/obj/hydroponics/amanita.dmi',				3),
		list('icons/obj/hydroponics/angel.dmi',				3),
		list('icons/obj/hydroponics/towercap.dmi',			3),
		list('icons/obj/hydroponics/glowshroom.dmi',			4),
		list('icons/obj/hydroponics/walkingmushroom.dmi',		3),
		list('icons/obj/hydroponics/plastellium.dmi',		3),
		list('icons/obj/hydroponics/harebell.dmi',				4),
		list('icons/obj/hydroponics/poppy.dmi',				3),
		list('icons/obj/hydroponics/sunflower.dmi',			3),
		list('icons/obj/hydroponics/moonflower.dmi',			3),
		list('icons/obj/hydroponics/novaflower.dmi',			3),
		list('icons/obj/hydroponics/grape.dmi',				2),
		list('icons/obj/hydroponics/greengrape.dmi',			2),
		list('icons/obj/hydroponics/peanut.dmi',				6),
		list('icons/obj/hydroponics/cabbage.dmi',				1),
		list('icons/obj/hydroponics/shand.dmi',				3),
		list('icons/obj/hydroponics/mtear.dmi',				4),
		list('icons/obj/hydroponics/banana.dmi',				6),
		list('icons/obj/hydroponics/corn.dmi',					3),
		list('icons/obj/hydroponics/potato.dmi',				4),
		list('icons/obj/hydroponics/soybean.dmi',				6),
		list('icons/obj/hydroponics/soybean.dmi',				6),
		list('icons/obj/hydroponics/wheat.dmi',				6),
		list('icons/obj/hydroponics/rice.dmi',					4),
		list('icons/obj/hydroponics/carrot.dmi',				3),
		list('icons/obj/hydroponics/weeds.dmi',				4),
		list('icons/obj/hydroponics/whitebeet.dmi',			6),
		list('icons/obj/hydroponics/sugarcane.dmi',			3),
		list('icons/obj/hydroponics/watermelon.dmi',			6),
		list('icons/obj/hydroponics/pumpkin.dmi',				2),
		list('icons/obj/hydroponics/lime.dmi',					6),
		list('icons/obj/hydroponics/lemon.dmi',				6),
		list('icons/obj/hydroponics/orange.dmi',				6),
		list('icons/obj/hydroponics/grass.dmi',				2),
		list('icons/obj/hydroponics/cocoapod.dmi',				5),
		list('icons/obj/hydroponics/cherry.dmi',				5),
		list('icons/obj/hydroponics/kudzu.dmi',				4),
		list('icons/obj/hydroponics/pear.dmi', 				6),
		))
	
	plant_dmi = plant_icons[1]
	growth_stages = plant_icons[2]


//Random mutations moved to hydroponics_mutations.dm!

//Mutates a specific trait/set of traits. Used by the Bioballistic Delivery System.
/datum/seed/proc/apply_gene(var/datum/plantgene/gene, var/mode)

	if(!gene || !gene.values || immutable > 0)
		return

	switch(gene.genetype)
		if(GENE_PHYTOCHEMISTRY)
			if(!chems || mode == GENEGUN_MODE_PURGE)
				chems = list()

			var/list/gene_value = gene.values[1]
			for(var/rid in gene_value)
				var/list/gene_chem = gene_value[rid]

				if(!(rid in chems) || !chems[rid])
					chems[rid] = gene_chem.Copy()
					continue

				for(var/i=1 to gene_chem.len)
					if(isnull(gene_chem[i]))
						chems[rid][i] = 0
						gene_chem[i] = 0
					if(!chems[rid][i])
						continue

					if(chems[rid][i])
						chems[rid][i] = max(1,round((gene_chem[i] + chems[rid][i])/2))
					else
						chems[rid][i] = gene_chem[i]

			switch(mode)
				if(GENEGUN_MODE_PURGE)
					potency 			= gene.values[2]
					teleporting 		= gene.values[3]
				if(GENEGUN_MODE_SPLICE)
					potency 			= round(mix(gene.values[2], potency, rand(40, 60)/100), 0.1)
					teleporting 		= max(gene.values[3], teleporting)

		if(GENE_MORPHOLOGY)
			if(gene.values[1])
				if(!products || mode == GENEGUN_MODE_PURGE)
					products = list()
				products |= gene.values[1]
			switch(mode)
				if(GENEGUN_MODE_PURGE)
					thorny 				= gene.values[2]
					stinging 			= gene.values[3]
					ligneous 			= gene.values[4]
					juicy 				= gene.values[5]
				if(GENEGUN_MODE_SPLICE)
					thorny 				= max(gene.values[2], thorny)
					stinging 			= max(gene.values[3], stinging)
					ligneous 			= max(gene.values[4], ligneous)
					juicy 				= max(gene.values[5], juicy)

		if(GENE_BIOLUMINESCENCE)
			switch(mode)
				if(GENEGUN_MODE_PURGE)
					biolum 				= gene.values[1]
					biolum_colour 		= gene.values[2]
				if(GENEGUN_MODE_SPLICE)
					biolum 				= max(gene.values[1], biolum)
					biolum_colour 		= BlendRGB(gene.values[2], biolum_colour, rand(40, 60)/100)

		if(GENE_ECOLOGY)
			switch(mode)
				if(GENEGUN_MODE_PURGE)
					ideal_heat 			= gene.values[1]
					heat_tolerance 		= gene.values[2]
					ideal_light 		= gene.values[3]
					light_tolerance 	= gene.values[4]
					lowkpa_tolerance	= gene.values[5]
					highkpa_tolerance	= gene.values[6]
				if(GENEGUN_MODE_SPLICE)
					ideal_heat 			= Ceiling(mix(gene.values[1], ideal_heat, 		rand(40, 60)/100))
					heat_tolerance 		= Ceiling(mix(gene.values[2], heat_tolerance, 	rand(40, 60)/100))
					ideal_light 		= Ceiling(mix(gene.values[3], ideal_light,		rand(40, 60)/100))
					light_tolerance 	= Ceiling(mix(gene.values[4], light_tolerance, 	rand(40, 60)/100))
					lowkpa_tolerance	= Ceiling(mix(gene.values[5], lowkpa_tolerance, rand(40, 60)/100))
					highkpa_tolerance	= Ceiling(mix(gene.values[6], highkpa_tolerance,rand(40, 60)/100))

		if(GENE_ECOPHYSIOLOGY)
			switch(mode)
				if(GENEGUN_MODE_PURGE)
					toxins_tolerance 	= gene.values[1]
					pest_tolerance 		= gene.values[2]
					weed_tolerance 		= gene.values[3]
					lifespan 			= gene.values[4]
					endurance			= gene.values[5]
				if(GENEGUN_MODE_SPLICE)
					toxins_tolerance 	= round(mix(gene.values[1], toxins_tolerance,	rand(40, 60)/100), 0.1)
					pest_tolerance 		= round(mix(gene.values[2], pest_tolerance, 	rand(40, 60)/100), 0.1)
					weed_tolerance 		= round(mix(gene.values[3], weed_tolerance, 	rand(40, 60)/100), 0.1)
					lifespan 			= round(mix(gene.values[4], lifespan, 			rand(40, 60)/100), 0.1)
					endurance			= round(mix(gene.values[5], endurance, 			rand(40, 60)/100), 0.1)

		if(GENE_METABOLISM)
			switch(mode)
				if(GENEGUN_MODE_PURGE)
					nutrient_consumption	= gene.values[1]
					water_consumption 		= gene.values[2]
					alter_temp 				= gene.values[3]
				if(GENEGUN_MODE_SPLICE)
					nutrient_consumption	= mix(gene.values[1], nutrient_consumption,	rand(40, 60)/100)
					water_consumption 		= mix(gene.values[2], water_consumption,	rand(40, 60)/100)
					alter_temp 				= max(gene.values[3], alter_temp)
			var/list/new_gasses = gene.values[4]
			if(islist(new_gasses))
				if(!exude_gasses || mode == GENEGUN_MODE_PURGE)
					exude_gasses = list()
				exude_gasses |= new_gasses

		if(GENE_NUTRITION)
			switch(mode)
				if(GENEGUN_MODE_PURGE)
					carnivorous 		= gene.values[1]
					parasite 			= gene.values[2]
					hematophage 		= gene.values[3]
				if(GENEGUN_MODE_SPLICE)
					carnivorous 		= max(gene.values[1], carnivorous)
					parasite 			= max(gene.values[2], parasite)
					hematophage 		= max(gene.values[3], hematophage)
			var/list/new_gasses = gene.values[4]
			if(islist(new_gasses))
				if(!consume_gasses || mode == GENEGUN_MODE_PURGE)
					consume_gasses = list()
				consume_gasses |= new_gasses

		if(GENE_DEVELOPMENT)
			switch(mode)
				if(GENEGUN_MODE_PURGE)
					production 			= gene.values[1]
					maturation 			= gene.values[2]
					spread 				= gene.values[3]
					harvest_repeat 		= gene.values[4]
					yield				= gene.values[5]
				if(GENEGUN_MODE_SPLICE)
					production 			= round(mix(gene.values[1], production,	rand(40, 60)/100), 0.1)
					maturation 			= round(mix(gene.values[2], maturation,	rand(40, 60)/100), 0.1)
					spread 				= max(gene.values[3], spread)
					harvest_repeat 		= max(gene.values[4], harvest_repeat)
					yield				= round(mix(gene.values[5], yield,		rand(40, 60)/100), 0.1)

//Returns a list of the desired trait values.
/datum/seed/proc/get_gene(var/genetype)
	if(!genetype)
		return 0

	var/datum/plantgene/P = new()
	P.genetype = genetype

	switch(genetype)
		if(GENE_PHYTOCHEMISTRY)
			P.values = list(
				(chems                	? chems                	: 0),
				(potency				? potency 				: 0),
				(teleporting          	? teleporting          	: 0) // Yes, bluespace anomalies are caused by a mystery chemical, I don't have to explain shit
			)
		if(GENE_MORPHOLOGY)
			P.values = list(
				(products           	? products            	: 0),
				(thorny           	 	? thorny           		: 0),
				(stinging            	? stinging            	: 0),
				(ligneous             	? ligneous            	: 0),
				(juicy             		? juicy             	: 0)
			)
		if(GENE_BIOLUMINESCENCE)
			P.values = list(
				(biolum               	? biolum              	: 0),
				(biolum_colour        	? biolum_colour      	: 0)
			)
		if(GENE_ECOLOGY)
			P.values = list(
				(ideal_heat           	? ideal_heat          	: 0),
				(heat_tolerance      	? heat_tolerance     	: 0),
				(ideal_light         	? ideal_light         	: 0),
				(light_tolerance      	? light_tolerance     	: 0),
				(lowkpa_tolerance     	? lowkpa_tolerance    	: 0),
				(highkpa_tolerance   	? highkpa_tolerance   	: 0)
			)
		if(GENE_ECOPHYSIOLOGY)
			P.values = list(
				(toxins_tolerance     	? toxins_tolerance    	: 0),
				(pest_tolerance       	? pest_tolerance      	: 0),
				(weed_tolerance       	? weed_tolerance      	: 0),
				(lifespan      			? lifespan				: 0),
				(endurance       		? endurance       		: 0)
			)
		if(GENE_METABOLISM)
			P.values = list(
				(nutrient_consumption 	? nutrient_consumption	: 0),
				(water_consumption    	? water_consumption   	: 0),
				(alter_temp    			? alter_temp    		: 0),
				(exude_gasses    		? exude_gasses    		: 0)
			)
		if(GENE_NUTRITION)
			P.values = list(
				(carnivorous 			? carnivorous			: 0),
				(parasite    			? parasite   			: 0),
				(hematophage    		? hematophage    		: 0),
				(consume_gasses    		? consume_gasses    	: 0)
			)
		if(GENE_DEVELOPMENT)
			P.values = list(
				(production           	? production          	: 0),
				(maturation           	? maturation          	: 0),
				(spread         		? spread         		: 0),
				(harvest_repeat       	? harvest_repeat      	: 0),
				(yield              	? yield              	: 0)
			)
	return (P ? P : 0)

//This may be a new line. Update the global if it is.
/datum/seed/proc/add_newline_to_controller()
	if(name == "new line" || !(name in SSplant.seeds))
		uid = SSplant.seeds.len + 1
		name = "[uid]"
		SSplant.seeds[name] = src

//Place the plant products at the feet of the user.
/datum/seed/proc/harvest(var/mob/user,var/yield_mod = 1)
	if(!user)
		return

	if(isnull(products) || !products.len || yield <= 0)
		to_chat(user, "<span class='warning'>You fail to harvest anything useful.</span>")
	else
		to_chat(user, "You harvest from the [display_name].")

		generate_product(get_turf(user), yield_mod)

/datum/seed/proc/generate_product(var/turf/T, yield_mod)
	add_newline_to_controller()

	var/total_yield = 0
	if(yield > -1)
		if(isnull(yield_mod) || yield_mod < 0)
			yield_mod = 1
			total_yield = yield
		else
			total_yield = yield * yield_mod
		total_yield = round(max(1,total_yield))

	currently_querying = list()
	for(var/i = 0;i<total_yield;i++)
		var/product_type = pick(products)

		var/obj/item/product

		if(ispath(product_type, /obj/item/stack))
			product = drop_stack(product_type, T, 1, null)
		else
			product = new product_type(T)

		score["stuffharvested"] += 1 //One point per product unit

		if(mysterious)
			product.name += "?"
			product.desc += " On second thought, something about this one looks strange."

		if(biolum)
			if(biolum_colour)
				product.light_color = biolum_colour
			//product.set_light(1+round(potency/50))
			product.set_light(2)

		//Handle spawning in living, mobile products (like dionaea).
		if(istype(product,/mob/living))

			product.visible_message("<span class='notice'>The pod disgorges [product]!</span>")
			handle_living_product(product)

		// Make sure the product is inheriting the correct seed type reference.
		else if(istype(product,/obj/item/weapon/reagent_containers/food/snacks/grown))
			var/obj/item/weapon/reagent_containers/food/snacks/grown/current_product = product
			current_product.plantname = name
		else if(istype(product,/obj/item/weapon/grown))
			var/obj/item/weapon/grown/current_product = product
			current_product.plantname = name

//Harvest without concern for the user
/datum/seed/proc/autoharvest(var/turf/T, var/yield_mod = 1)
	if(T && (!isnull(products)) && products.len && (yield > 0))
		generate_product(T, yield_mod)

/datum/seed/proc/check_harvest(var/mob/user, var/obj/machinery/portable_atmospherics/hydroponics/tray)
	var/success = 1
	var/stung = 0
	if(thorny || stinging)
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if(!H.check_body_part_coverage(HANDS))
				for(var/assblast in list(LIMB_RIGHT_HAND, LIMB_LEFT_HAND))
					if(stung)
						continue
					var/datum/organ/external/affecting = H.get_organ(assblast)
					if(affecting && affecting.is_existing() && affecting.is_usable() && affecting.is_organic())
						stung = 1
						if(thorny)
							if(affecting.take_damage(5+carnivorous*5, 0))
								H.UpdateDamageIcon()
								H.updatehealth()
							else
								H.adjustBruteLoss(5+carnivorous*5)
							to_chat(H, "<span class='danger'>You are prickled by the sharp thorns on \the [seed_name]!</span>")
							if(H.feels_pain())
								success = 0
						if(stinging)
							if(chems && chems.len)
								for(var/rid in chems)
									H.reagents.add_reagent(rid, clamp(1, 5, potency/10))
								to_chat(H, "<span class='danger'>You are stung by \the [seed_name]!</span>")
								if(hematophage)
									if(tray && H.species && !(H.species.anatomy_flags & NO_BLOOD)) //the indentation gap doesn't stop from getting wider
										var/drawing = min(15, H.vessel.get_reagent_amount(BLOOD))
										H.vessel.remove_reagent(BLOOD, drawing)
										tray.reagents.add_reagent(BLOOD, drawing)
	if(ligneous && success)
		success = 0
		if(istype(user, /mob/living/carbon))
			var/mob/living/carbon/M = user
			for(var/obj/item/I in M.held_items)
				if(I.sharpness_flags & (SHARP_BLADE|SERRATED_BLADE))
					success = 1
					break

			if(!success)
				to_chat(M, "<span class='warning'>The stems on this plant are too tough to cut by hand, you'll need something sharp in one of your hands to harvest it.</span>")

	return success

// Create a seed packet directly from the plant.
/datum/seed/proc/spawn_seed_packet(turf/target)
	add_newline_to_controller()
	var/obj/item/seeds/seeds = new(target)
	seeds.seed_type = src.name
	seeds.update_seed()
	return

// When the seed in this machine mutates/is modified, the tray seed value
// is set to a new datum copied from the original. This datum won't actually
// be put into the global datum list until the product is harvested, though.
/datum/seed/proc/diverge(var/modified)
	if(immutable > 0)
		return

	//Set up some basic information.
	var/datum/seed/new_seed = new /datum/seed()
	new_seed.name = "new line"
	new_seed.uid = 0
	new_seed.roundstart = 0
	new_seed.large = large

	//Copy over everything else.
	if(products)
		new_seed.products = products.Copy()
	if(mutants)
		new_seed.mutants = mutants.Copy()
	if(chems)
		new_seed.chems = chems.Copy()
	if(consume_gasses)
		new_seed.consume_gasses = consume_gasses.Copy()
	if(exude_gasses)
		new_seed.exude_gasses = exude_gasses.Copy()

	if(modified != -1)
		new_seed.seed_name = "[(roundstart ? "[(modified ? "modified" : "mutant")] " : "")][seed_name]"
		new_seed.display_name = "[(roundstart ? "[(modified ? "modified" : "mutant")] " : "")][display_name]"
	else
		new_seed.seed_name = "[seed_name]"
		new_seed.display_name = "[display_name]"

	new_seed.nutrient_consumption = nutrient_consumption
	new_seed.water_consumption =    water_consumption
	new_seed.ideal_heat =           ideal_heat
	new_seed.heat_tolerance =       heat_tolerance
	new_seed.ideal_light =          ideal_light
	new_seed.light_tolerance =      light_tolerance
	new_seed.toxins_tolerance =     toxins_tolerance
	new_seed.lowkpa_tolerance =     lowkpa_tolerance
	new_seed.highkpa_tolerance =    highkpa_tolerance
	new_seed.pest_tolerance =       pest_tolerance
	new_seed.weed_tolerance =       weed_tolerance
	new_seed.endurance =            endurance
	new_seed.yield =                yield
	new_seed.lifespan =             lifespan
	new_seed.maturation =           maturation
	new_seed.production =           production
	new_seed.growth_stages =        growth_stages
	new_seed.harvest_repeat =       harvest_repeat
	new_seed.potency =              potency
	new_seed.spread =               spread
	new_seed.carnivorous =          carnivorous
	new_seed.parasite =             parasite
	new_seed.hematophage =          hematophage
	new_seed.thorny =               thorny
	new_seed.stinging =             stinging
	new_seed.ligneous =             ligneous
	new_seed.teleporting =          teleporting
	new_seed.juicy =        	    juicy
	new_seed.plant_icon =           plant_icon
	new_seed.splat_type =           splat_type
	new_seed.packet_icon =          packet_icon
	new_seed.biolum =               biolum
	new_seed.biolum_colour =        biolum_colour
	new_seed.alter_temp = 			alter_temp
	new_seed.plant_dmi =			plant_dmi

	ASSERT(istype(new_seed)) //something happened... oh no...
	return new_seed

/datum/seed/proc/get_reagent_names()
	var/list/reagent_names = list()
	var/datum/reagent/R
	for (var/rid in chems)
		R = chemical_reagents_list[rid]
		reagent_names += R.name
	return reagent_names
