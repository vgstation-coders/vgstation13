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
	var/harvest_repeat = 0          // If 1, this plant will fruit repeatedly.
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
	var/plant_dmi = 'icons/obj/hydroponics.dmi'// DMI  to use for the plant growing in the tray.
	var/plant_icon                  // Icon to use for the plant growing in the tray.
	var/packet_icon = "seed"        // Icon to use for physical seed packet item.
	var/biolum                      // Plant is bioluminescent.
	var/biolum_colour               // The colour of the plant's radiance.
	var/splat_type = /obj/effect/decal/cleanable/fruit_smudge //Decal to create if the fruit is splatter-able and subsequently splattered.

	var/mob_drop					// Seed type dropped by the mobs when it dies without an host

	var/large = 1					// Is the plant large? For clay pots.

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
		var/gas = pick("oxygen","nitrogen","plasma","carbon_dioxide")
		consume_gasses[gas] = rand(3,9)

	if(prob(5))
		exude_gasses = list()
		var/gas = pick("oxygen","nitrogen","plasma","carbon_dioxide")
		exude_gasses[gas] = rand(3,9)

	chems = list()
	if(prob(80))
		chems["nutriment"] = list(rand(1,5),rand(5,10))

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
		immutable = -1*/ //shekels

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
		"bicaridine",
		"hyperzine",
		"cryoxadone",
		"blood",
		"potassium",
		"plasticide",
		"mutationtoxin",
		"amutationtoxin",
		"inaprovaline",
		"space_drugs",
		"paroxetine",
		"mercury",
		"sugar",
		"radium",
		"ryetalyn",
		"alkysine",
		"thermite",
		"tramadol",
		"cryptobiolin",
		"dermaline",
		"dexalin",
		"plasma",
		"synaptizine",
		"impedrezene",
		"hyronalin",
		"peridaxon",
		"toxin",
		"rezadone",
		"ethylredoxrazine",
		"slimejelly",
		"cyanide",
		"mindbreaker",
		"neurotoxin",
		"leporazine",
		"stoxin"
	)

	for(var/rid in chems)
		possible_chems -= rid
	if(!possible_chems.len)
		return 0
	var/new_chem = pick(possible_chems)
	chems[new_chem] = list(rand(1,severity/3),rand(10-Ceiling(severity/3),15))
	return 1

//Gives the plant a new, random icon from a list, with matching growth stages number.
/datum/seed/proc/randomize_icon(var/change_packet = 1)
	var/list/plant_icons = pick(list(
		list("seed-chili",              "chili",				6),
		list("seed-icepepper",          "chiliice",				6),
		list("seed-berry",              "berry",				6),
		list("seed-glowberry",          "glowberry",			6),
		list("seed-poisonberry",        "poisonberry",			6),
		list("seed-deathberry",         "deathberry",			6),
		list("seed-nettle",             "nettle",				6),
		list("seed-deathnettle",        "deathnettle",			6),
		list("seed-tomato",             "tomato",				6),
		list("seed-bloodtomato",        "bloodtomato",			6),
		list("seed-killertomato",       "killertomato",			2),
		list("seed-bluetomato",         "bluetomato",			6),
		list("seed-bluespacetomato",    "bluespacetomato",		6),
		list("seed-eggplant",           "eggplant",				6),
		list("seed-eggy",               "eggy",					6),
		list("seed-apple",              "apple",				6),
		list("seed-goldapple",          "goldapple",			6),
		list("seed-ambrosiavulgaris",   "ambrosiavulgaris",		6),
		list("seed-ambrosiadeus",       "ambrosiadeus",			6),
		list("mycelium-chanter",        "chanter",				3),
		list("mycelium-plump",          "plump",				3),
		list("mycelium-reishi",         "reishi",				4),
		list("mycelium-liberty",        "liberty",				3),
		list("mycelium-amanita",        "amanita",				3),
		list("mycelium-angel",          "angel",				3),
		list("mycelium-tower",          "towercap",				3),
		list("mycelium-glowshroom",     "glowshroom",			4),
		list("mycelium-walkingmushroom","walkingmushroom",		3),
		list("mycelium-plast",          "plastellium",			3),
		list("seed-harebell",           "harebell",				4),
		list("seed-poppy",              "poppy",				3),
		list("seed-sunflower",          "sunflower",			3),
		list("seed-moonflower",         "moonflower",			3),
		list("seed-novaflower",         "novaflower",			3),
		list("seed-grapes",             "grape",				2),
		list("seed-greengrapes",        "greengrape",			2),
		list("seed-peanut",             "peanut",				6),
		list("seed-cabbage",            "cabbage",				1),
		list("seed-shand",              "shand",				3),
		list("seed-mtear",              "mtear",				4),
		list("seed-banana",             "banana",				6),
		list("seed-corn",               "corn",					3),
		list("seed-potato",             "potato",				4),
		list("seed-soybean",            "soybean",				6),
		list("seed-koibean",            "soybean",				6),
		list("seed-wheat",              "wheat",				6),
		list("seed-rice",               "rice",					4),
		list("seed-carrot",             "carrot",				3),
		list("seed-ambrosiavulgaris",   "weeds",				4),
		list("seed-whitebeet",          "whitebeet",			6),
		list("seed-sugarcane",          "sugarcane",			3),
		list("seed-watermelon",         "watermelon",			6),
		list("seed-pumpkin",            "pumpkin",				2),
		list("seed-lime",               "lime",					6),
		list("seed-lemon",              "lemon",				6),
		list("seed-orange",             "orange",				6),
		list("seed-grass",              "grass",				2),
		list("seed-cocoapod",           "cocoapod",				5),
		list("seed-cherry",             "cherry",				5),
		list("seed-kudzu",              "kudzu",				4),
		))

	if (change_packet) packet_icon = plant_icons[1]
	plant_icon = plant_icons[2]
	growth_stages = plant_icons[3]

//Random mutations moved to hydroponics_mutations.dm!

//Mutates a specific trait/set of traits. Used by the Bioballistic Delivery System.
/datum/seed/proc/apply_gene(var/datum/plantgene/gene)


	if(!gene || !gene.values || immutable > 0) return

	switch(gene.genetype)

		//Splicing products has some detrimental effects on yield and lifespan.
		if("products")

			if(gene.values.len < 6) return

			if(yield > 0)     yield =     max(1,round(yield*0.85))
			if(endurance > 0) endurance = max(1,round(endurance*0.85))
			if(lifespan > 0)  lifespan =  max(1,round(lifespan*0.85))

			if(!products) products = list()
			products |= gene.values[1]

			if(!chems) chems = list()

			var/list/gene_value = gene.values[2]
			for(var/rid in gene_value)

				var/list/gene_chem = gene_value[rid]

				if(!(rid in chems) || !chems[rid])
					chems[rid] = gene_chem.Copy()
					continue

				for(var/i=1;i<=gene_chem.len;i++)

					if(isnull(gene_chem[i]))
						chems[rid][i] = 0
						gene_chem[i] = 0
					if(!chems[rid][i]) continue

					if(chems[rid][i])
						chems[rid][i] = max(1,round((gene_chem[i] + chems[rid][i])/2))
					else
						chems[rid][i] = gene_chem[i]

			var/list/new_gasses = gene.values[3]
			if(islist(new_gasses))
				if(!exude_gasses) exude_gasses = list()
				exude_gasses |= new_gasses
				for(var/gas in exude_gasses)
					exude_gasses[gas] = max(1,round(exude_gasses[gas]*0.8))

			alter_temp =           gene.values[4]
			potency =              gene.values[5]
			harvest_repeat =       gene.values[6]

		if("consumption")

			if(gene.values.len < 5) return

			consume_gasses =       gene.values[1]
			nutrient_consumption = gene.values[2]
			water_consumption =    gene.values[3]
			carnivorous =          gene.values[4]
			parasite =             gene.values[5]

		if("environment")

			if(gene.values.len < 6) return

			ideal_heat =           gene.values[1]
			heat_tolerance =       gene.values[2]
			ideal_light =          gene.values[3]
			light_tolerance =      gene.values[4]
			lowkpa_tolerance  =    gene.values[5]
			highkpa_tolerance =    gene.values[6]

		if("resistance")

			if(gene.values.len < 3) return

			toxins_tolerance =     gene.values[1]
			pest_tolerance =       gene.values[2]
			weed_tolerance =       gene.values[3]

		if("vigour")

			if(gene.values.len < 6) return

			endurance =            gene.values[1]
			yield =                gene.values[2]
			lifespan =             gene.values[3]
			spread =               gene.values[4]
			maturation =           gene.values[5]
			production =           gene.values[6]

		if("biolum")

			if(gene.values.len < 2) return

			biolum =               gene.values[1]
			biolum_colour =        gene.values[2]


//Returns a list of the desired trait values.
/datum/seed/proc/get_gene(var/genetype)


	if(!genetype) return 0

	var/datum/plantgene/P = new()
	P.genetype = genetype

	switch(genetype)
		if("products")
			P.values = list(
				(products             ? products             : 0),
				(chems                ? chems                : 0),
				(exude_gasses         ? exude_gasses         : 0),
				(alter_temp           ? alter_temp           : 0),
				(potency              ? potency              : 0),
				(harvest_repeat       ? harvest_repeat       : 0)
				)

		if("consumption")
			P.values = list(
				(consume_gasses       ? consume_gasses       : 0),
				(nutrient_consumption ? nutrient_consumption : 0),
				(water_consumption    ? water_consumption    : 0),
				(carnivorous          ? carnivorous          : 0),
				(parasite             ? parasite             : 0)
				)

		if("environment")
			P.values = list(
				(ideal_heat           ? ideal_heat           : 0),
				(heat_tolerance       ? heat_tolerance       : 0),
				(ideal_light          ? ideal_light          : 0),
				(light_tolerance      ? light_tolerance      : 0),
				(lowkpa_tolerance     ? lowkpa_tolerance     : 0),
				(highkpa_tolerance    ? highkpa_tolerance    : 0)
				)

		if("resistance")
			P.values = list(
				(toxins_tolerance     ? toxins_tolerance     : 0),
				(pest_tolerance       ? pest_tolerance       : 0),
				(weed_tolerance       ? weed_tolerance       : 0)
				)

		if("vigour")
			P.values = list(
				(endurance            ? endurance            : 0),
				(yield                ? yield                : 0),
				(lifespan             ? lifespan             : 0),
				(spread               ? spread               : 0),
				(maturation           ? maturation           : 0),
				(production           ? production           : 0)
				)

		if("biolum")
			P.values = list(
				(biolum               ? biolum               : 0),
				(biolum_colour        ? biolum_colour        : 0)
				)

	return (P ? P : 0)

//This may be a new line. Update the global if it is.
/datum/seed/proc/add_newline_to_controller()
	if(name == "new line" || !(name in plant_controller.seeds))
		uid = plant_controller.seeds.len + 1
		name = "[uid]"
		plant_controller.seeds[name] = src

//Place the plant products at the feet of the user.
/datum/seed/proc/harvest(var/mob/user,var/yield_mod = 1)


	if(!user)
		return

	if(isnull(products) || !products.len || yield <= 0)
		user << "<span class='warning'>You fail to harvest anything useful.</span>"
	else
		user << "You harvest from the [display_name]."

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
			var/obj/item/product = new product_type(get_turf(user))

			score["stuffharvested"] += 1 //One point per product unit

			if(mysterious)
				product.name += "?"
				product.desc += " On second thought, something about this one looks strange."

			if(biolum)
				if(biolum_colour)
					product.light_color = biolum_colour
				product.set_light(biolum)

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

/datum/seed/proc/check_harvest(var/mob/user, var/obj/machinery/portable_atmospherics/hydroponics/tray)
	var/success = 1
	var/stung = 0
	if(thorny || stinging)
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if(!H.check_body_part_coverage(HANDS))
				for(var/assblast in list("r_hand", "l_hand"))
					if(stung) continue
					var/datum/organ/external/affecting = H.get_organ(assblast)
					if(affecting && affecting.is_existing() && affecting.is_usable() && affecting.is_organic())
						stung = 1
						if(thorny)
							if(affecting.take_damage(5+carnivorous*5, 0))
								H.UpdateDamageIcon()
								H.updatehealth()
							else
								H.adjustBruteLoss(5+carnivorous*5)
							H << "<span class='danger'>You are prickled by the sharp thorns on \the [seed_name]!</span>"
							if(H.species && !(H.species.flags & NO_PAIN))
								success = 0
						if(stinging)
							if(chems && chems.len)
								for(var/rid in chems)
									H.reagents.add_reagent(rid, Clamp(1, 5, potency/10))
								H << "<span class='danger'>You are stung by \the [seed_name]!</span>"
								if(hematophage)
									if(tray && H.species && !(H.species.flags & NO_BLOOD)) //the indentation gap doesn't stop from getting wider
										var/drawing = min(15, H.vessel.get_reagent_amount("blood"))
										H.vessel.remove_reagent("blood", drawing)
										tray.reagents.add_reagent("blood", drawing)
	if(ligneous)
		if(istype(user, /mob/living/carbon))
			var/mob/living/carbon/M = user
			if((!M.l_hand || !M.l_hand.is_sharp()) && (!M.r_hand || !M.r_hand.is_sharp()))
				M << "<span class='warning'>The stems on this plant are too tough to cut by hand, you'll need something sharp in one of your hands to harvest it.</span>"
				success = 0
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


	if(immutable > 0) return

	//Set up some basic information.
	var/datum/seed/new_seed = new /datum/seed()
	new_seed.name = "new line"
	new_seed.uid = 0
	new_seed.roundstart = 0
	new_seed.large = large

	//Copy over everything else.
	if(products)       new_seed.products = products.Copy()
	if(mutants)        new_seed.mutants = mutants.Copy()
	if(chems)          new_seed.chems = chems.Copy()
	if(consume_gasses) new_seed.consume_gasses = consume_gasses.Copy()
	if(exude_gasses)   new_seed.exude_gasses = exude_gasses.Copy()

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

	ASSERT(istype(new_seed)) //something happened... oh no...
	return new_seed

/datum/seed/proc/get_reagent_names()
	var/list/reagent_names = list()
	var/datum/reagent/R
	for (var/rid in chems)
		R = chemical_reagents_list[rid]
		reagent_names += R.name
	return reagent_names