#define HYDRO_SPEED_MULTIPLIER 1

/obj/machinery/portable_atmospherics/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "hydrotray3"
	density = 1
	anchored = 1
	flags = OPENCONTAINER
	volume = 100

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK


	var/draw_warnings = 1 //Set to 0 to stop it from drawing the alert lights.

	// Plant maintenance vars.
	var/waterlevel = 100       // Water (max 100)
	var/nutrilevel = 100       // Nutrient (max 100)
	var/pestlevel = 0          // Pests (max 10)
	var/weedlevel = 0          // Weeds (max 10)

	// Tray state vars.
	var/dead = 0               // Is it dead?
	var/harvest = 0            // Is it ready to harvest?
	var/age = 0                // Current plant age
	var/sampled = 0            // Have wa taken a sample?

	// Harvest/mutation mods.
	var/yield_mod = 0          // Modifier to yield
	var/mutation_mod = 0       // Modifier to mutation chance
	var/toxins = 0             // Toxicity in the tray?
	var/mutation_level = 0     // When it hits 100, the plant mutates.

	// Mechanical concerns.
	var/health = 0             // Plant health.
	var/lastproduce = 0        // Last time tray was harvested
	var/lastcycle = 0          // Cycle timing/tracking var.
	var/cycledelay = 150       // Delay per cycle.
	var/closed_system          // If set, the tray will attempt to take atmos from a pipe.
	var/force_update           // Set this to bypass the cycle time check.
	var/obj/temp_chem_holder   // Something to hold reagents during process_reagents()

	var/bees = 0				//Are there currently bees above the tray?

	var/decay_reduction = 0     //How much is mutation decay reduced by?
	var/weed_coefficient = 1    //Coefficient to the chance of weeds appearing
	var/internal_light = 1
	var/light_on = 0

	// Seed details/line data.
	var/datum/seed/seed = null // The currently planted seed

	// Reagent information for process(), consider moving this to a controller along
	// with cycle information under 'mechanical concerns' at some point.
	var/global/list/toxic_reagents = list(
		"anti_toxin" =     -2,
		"toxin" =           2,
		"fluorine" =        2.5,
		"chlorine" =        1.5,
		"sacid" =           1.5,
		"pacid" =           3,
		"plantbgone" =      3,
		"cryoxadone" =     -3,
		"radium" =          2
		)
	var/global/list/nutrient_reagents = list(
		"milk" =            0.1,
		"beer" =            0.25,
		"phosphorus" =      0.1,
		"sugar" =           0.1,
		"sodawater" =       0.1,
		"ammonia" =         1,
		"diethylamine" =    2,
		"nutriment" =       1,
		"adminordrazine" =  1,
		"eznutrient" =      1,
		"robustharvest" =   1,
		"left4zed" =        1
		)
	var/global/list/weedkiller_reagents = list(
		"fluorine" =       -4,
		"chlorine" =       -3,
		"phosphorus" =     -2,
		"sugar" =           2,
		"sacid" =          -2,
		"pacid" =          -4,
		"plantbgone" =     -8,
		"adminordrazine" = -5
		)
	var/global/list/pestkiller_reagents = list(
		"sugar" =           2,
		"diethylamine" =   -2,
		"adminordrazine" = -5
		)
	var/global/list/water_reagents = list(
		"water" =           1,
		"adminordrazine" =  1,
		"milk" =            0.9,
		"beer" =            0.7,
		"flourine" =       -0.5,
		"chlorine" =       -0.5,
		"phosphorus" =     -0.5,
		"water" =           1,
		"sodawater" =       1,
		)

	// Beneficial reagents also have values for modifying yield_mod and mut_mod (in that order).
	var/global/list/beneficial_reagents = list(
		"beer" =           list( -0.05, 0,   0   ),
		"fluorine" =       list( -2,    0,   0   ),
		"chlorine" =       list( -1,    0,   0   ),
		"phosphorus" =     list( -0.75, 0,   0   ),
		"sodawater" =      list(  0.1,  0,   0   ),
		"sacid" =          list( -1,    0,   0   ),
		"pacid" =          list( -2,    0,   0   ),
		"plantbgone" =     list( -2,    0,   0.2 ),
		"cryoxadone" =     list(  3,    0,   0   ),
		"ammonia" =        list(  0.5,  0,   0   ),
		"diethylamine" =   list(  1,    0,   0   ),
		"nutriment" =      list(  0.5,  0.1,   0 ),
		"radium" =         list( -1.5,  0,   0.2 ),
		"adminordrazine" = list(  1,    1,   1   ),
		"robustharvest" =  list(  0,    0.2, 0   ),
		"left4zed" =       list( -0.1, -0.2, 2   )
		)

	// Mutagen list specifies minimum value for the mutation to take place, rather
	// than a bound as the lists above specify.
	var/global/list/mutagenic_reagents = list(
		"radium" =  8,
		"mutagen" = 15
		)

/obj/machinery/portable_atmospherics/hydroponics/New()
	..()
	temp_chem_holder = new()
	temp_chem_holder.create_reagents(10)
	create_reagents(200)
	connect()
	update_icon()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/hydroponics,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()
	if(closed_system)
		flags &= ~OPENCONTAINER

/obj/machinery/portable_atmospherics/hydroponics/RefreshParts()
	var/capcount = 0
	var/scancount = 0
	var/mattercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/capacitor)) capcount += SP.rating
		if(istype(SP, /obj/item/weapon/stock_parts/scanning_module)) scancount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/matter_bin)) mattercount += SP.rating
	decay_reduction = scancount
	weed_coefficient = 2/mattercount
	internal_light = capcount

/obj/machinery/portable_atmospherics/hydroponics/bullet_act(var/obj/item/projectile/Proj)

	//Don't act on seeds like dionaea that shouldn't change.
	if(seed && seed.immutable > 0)
		return

	//Override for somatoray projectiles.
	if(istype(Proj ,/obj/item/projectile/energy/floramut) && prob(20))
		mutate(1)
		return
	else if(istype(Proj ,/obj/item/projectile/energy/florayield) && prob(20))
		yield_mod = min(10,yield_mod+rand(1,2))
		return

	..()

/obj/machinery/portable_atmospherics/hydroponics/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/machinery/portable_atmospherics/hydroponics/process()

	//Do this even if we're not ready for a plant cycle.
	process_reagents()

	// Update values every cycle rather than every process() tick.
	if(force_update)
		force_update = 0
	else if(world.time < (lastcycle + cycledelay))
		return
	lastcycle = world.time

	// Mutation level drops each main tick.
	mutation_level -= rand(2-decay_reduction,4-decay_reduction)

	var/mob/living/simple_animal/bee/BEE = locate() in loc
	if(BEE && (BEE.feral < 1))
		bees = 1
	else
		bees = 0

	// Weeds like water and nutrients, there's a chance the weed population will increase.
	// Bonus chance if the tray is unoccupied.
	if(waterlevel > 10 && nutrilevel > 2 && prob(isnull(seed) ? 5 : (1/(1+bees))))
		weedlevel += 1 * HYDRO_SPEED_MULTIPLIER * weed_coefficient

	// There's a chance for a weed explosion to happen if the weeds take over.
	// Plants that are themselves weeds (weed_tolerance > 10) are unaffected.
	if (weedlevel >= 10 && prob(10))
		if(!seed || weedlevel >= seed.weed_tolerance)
			weed_invasion()

	// If there is no seed data (and hence nothing planted),
	// or the plant is dead, process nothing further.
	if(!seed || dead)
		if(draw_warnings) update_icon() //Harvesting would fail to set alert icons properly.
		return

	// Advance plant age.
	if(harvest)
		if(prob(80)) age += (1 * HYDRO_SPEED_MULTIPLIER)/(1+bees)
	else
		if(prob(80+(20*bees))) age += 1 * HYDRO_SPEED_MULTIPLIER + (bees/2)

	//Highly mutable plants have a chance of mutating every tick.
	if(seed.immutable == -1)
		var/mut_prob = rand(1,100)
		if(mut_prob <= 5) mutate(mut_prob == 1 ? 2 : 1)

	// Other plants also mutate if enough mutagenic compounds have been added.
	if(!seed.immutable)
		if(prob(min(mutation_level,100)))
			mutate((rand(100) < 15) ? 2 : 1)
			mutation_level = 0

	// Maintain tray nutrient and water levels.
	if(seed.nutrient_consumption > 0 && nutrilevel > 0 && prob(25))
		nutrilevel -= max(0,seed.nutrient_consumption * HYDRO_SPEED_MULTIPLIER)
	if(seed.water_consumption > 0 && waterlevel > 0  && prob(25))
		waterlevel -= max(0,seed.water_consumption * HYDRO_SPEED_MULTIPLIER)

	// Make sure the plant is not starving or thirsty. Adequate
	// water and nutrients will cause a plant to become healthier.
	var/healthmod = rand(1,3) * HYDRO_SPEED_MULTIPLIER
	if(seed.requires_nutrients && prob(35))
		health += (nutrilevel < 2 ? -healthmod : healthmod)
	if(seed.requires_water && prob(35))
		health += (waterlevel < 10 ? -healthmod : healthmod)

	// Check that pressure, heat and light are all within bounds.
	// First, handle an open system or an unconnected closed system.

	var/turf/T = loc
	var/datum/gas_mixture/environment

	// If we're closed, take from our internal sources.
	if(closed_system)
		environment = air_contents

	// If atmos input is not there, grab from turf.
	if(!environment)
		if(istype(T))
			environment = T.return_air()

	if(!environment)
		if(istype(T, /turf/space))
			environment = space_gas
		else
			return

	// Handle gas consumption.
	if(seed.consume_gasses && seed.consume_gasses.len)
		var/missing_gas = 0
		for(var/gas in seed.consume_gasses)
			if(environment)
				switch(gas)
					if("oxygen")
						if(environment.oxygen <= seed.consume_gasses[gas])
							missing_gas++
							continue
					if("plasma")
						if(environment.toxins >= seed.consume_gasses[gas])
							missing_gas++
							continue
					if("nitrogen")
						if(environment.nitrogen >= seed.consume_gasses[gas])
							missing_gas++
							continue
					if("carbon_dioxide")
						if(environment.carbon_dioxide >= seed.consume_gasses[gas])
							missing_gas++
							continue
				environment.adjust_gas(gas,-seed.consume_gasses[gas],1)
			else
				missing_gas++

		if(missing_gas > 0)
			health -= missing_gas * HYDRO_SPEED_MULTIPLIER

	// Process it.
	var/pressure = environment.return_pressure()
	if(pressure < seed.lowkpa_tolerance || pressure > seed.highkpa_tolerance)
		health -= healthmod

	if(abs(environment.temperature - seed.ideal_heat) > seed.heat_tolerance)
		health -= healthmod

	// Handle gas production.
	if(seed.exude_gasses && seed.exude_gasses.len)
		for(var/gas in seed.exude_gasses)
			environment.adjust_gas(gas, max(1,round((seed.exude_gasses[gas]*seed.potency)/seed.exude_gasses.len)))

	// If we're attached to a pipenet, then we should let the pipenet know we might have modified some gasses
	//if (closed_system && connected_port)
	//'	update_connected_network()

	// Handle light requirements.

	var/light_available = 5
	if(T.dynamic_lighting)
		light_available = T.get_lumcount(0.5) * 10

	if(abs(light_available - seed.ideal_light) > seed.light_tolerance)
		health -= healthmod

	// Toxin levels beyond the plant's tolerance cause damage, but
	// toxins are sucked up each tick and slowly reduce over time.
	if(toxins > 0)
		var/toxin_uptake = max(1,round(toxins/10))
		if(toxins > seed.toxins_tolerance)
			health -= toxin_uptake
		toxins -= toxin_uptake * (1+bees)
		if(BEE && BEE.parent)
			var/obj/machinery/apiary/A = BEE.parent
			A.toxic += toxin_uptake//gotta be careful where you let your bees hang around

	// Check for pests and weeds.
	// Some carnivorous plants happily eat pests.
	if(pestlevel > 0)
		if(seed.carnivorous)
			health += HYDRO_SPEED_MULTIPLIER
			pestlevel -= HYDRO_SPEED_MULTIPLIER
		else if (pestlevel >= seed.pest_tolerance)
			health -= HYDRO_SPEED_MULTIPLIER

	// Some plants thrive and live off of weeds.
	if(weedlevel > 0)
		if(seed.parasite)
			health += HYDRO_SPEED_MULTIPLIER
			weedlevel -= HYDRO_SPEED_MULTIPLIER
		else if (weedlevel >= seed.weed_tolerance)
			health -= HYDRO_SPEED_MULTIPLIER

	// Handle life and death.
	// If the plant is too old, it loses health fast.
	if(age > seed.lifespan)
		health -= (rand(3,5) * HYDRO_SPEED_MULTIPLIER)/(1+bees)

	// When the plant dies, weeds thrive and pests die off.
	if(health <= 0)
		dead = 1
		mutation_level = 0
		harvest = 0
		weedlevel += 1 * HYDRO_SPEED_MULTIPLIER
		pestlevel = 0

	// If enough time (in cycles, not ticks) has passed since the plant was harvested, we're ready to harvest again.
	else if(seed.products && seed.products.len && age > seed.production && \
	 (age - lastproduce) > seed.production && (!harvest && !dead))
		harvest = 1
		lastproduce = age

	if(prob(3/(1+bees)))  // On each tick, there's a chance the pest population will increase
		pestlevel += 0.1 * HYDRO_SPEED_MULTIPLIER

	check_level_sanity()
	update_icon()
	return

//Process reagents being input into the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/process_reagents()


	if(!reagents) return

	if(reagents.total_volume <= 0)
		return

	reagents.trans_to(temp_chem_holder, min(reagents.total_volume,rand(1,3)))

	for(var/datum/reagent/R in temp_chem_holder.reagents.reagent_list)

		var/reagent_total = temp_chem_holder.reagents.get_reagent_amount(R.id)

		if(seed && !dead)
			//Handle some general level adjustments.
			if(toxic_reagents[R.id])
				toxins += toxic_reagents[R.id]         * reagent_total
			if(weedkiller_reagents[R.id])
				weedlevel -= weedkiller_reagents[R.id] * reagent_total
			if(pestkiller_reagents[R.id])
				pestlevel += pestkiller_reagents[R.id] * reagent_total //Pest reducing reagents have negative pest level

			// Beneficial reagents have a few impacts along with health buffs.
			if(beneficial_reagents[R.id])
				health += beneficial_reagents[R.id][1]       * reagent_total
				yield_mod += beneficial_reagents[R.id][2]    * reagent_total
				mutation_mod += beneficial_reagents[R.id][3] * reagent_total

			// Mutagen is distinct from the previous types and mostly has a chance of proccing a mutation.
			if(mutagenic_reagents[R.id])
				mutation_level += reagent_total*mutagenic_reagents[R.id]+mutation_mod

		// Handle nutrient refilling.
		if(nutrient_reagents[R.id])
			nutrilevel += nutrient_reagents[R.id]  * reagent_total

		// Handle water and water refilling.
		var/water_added = 0
		if(water_reagents[R.id])
			var/water_input = water_reagents[R.id] * reagent_total
			water_added += water_input
			waterlevel += water_input

		// Water dilutes toxin level.
		if(water_added > 0)
			toxins -= round(water_added/4)

	temp_chem_holder.reagents.clear_reagents()
	check_level_sanity()
	update_icon()

//Harvests the product of a plant.
/obj/machinery/portable_atmospherics/hydroponics/proc/harvest(var/mob/user)


	//Harvest the product of the plant,
	if(!seed || !harvest || !user)
		return

	if(closed_system)
		user << "You can't harvest from the plant while the lid is shut."
		return

	seed.harvest(user,yield_mod)

	// Reset values.
	harvest = 0
	lastproduce = age

	if(!seed.harvest_repeat)
		yield_mod = 0
		seed = null
		dead = 0
		age = 0
		sampled = 0
		mutation_mod = 0

	check_level_sanity()
	update_icon()
	return

//Clears out a dead plant.
/obj/machinery/portable_atmospherics/hydroponics/proc/remove_dead(var/mob/user)
	if(!user || !dead) return

	if(closed_system)
		user << "You can't remove the dead plant while the lid is shut."
		return

	seed = null
	dead = 0
	sampled = 0
	age = 0
	yield_mod = 0
	mutation_mod = 0

	user << "You remove the dead plant from the [src]."
	check_level_sanity()
	update_icon()
	return

//Refreshes the icon and sets the luminosity
/obj/machinery/portable_atmospherics/hydroponics/update_icon()
	overlays.len = 0

	// Updates the plant overlay.
	if(!isnull(seed))
		if(draw_warnings && health <= (seed.endurance / 2))
			overlays += image(seed.plant_dmi,"over_lowhealth3")

		if(dead)
			overlays += image(seed.plant_dmi,"[seed.plant_icon]-dead")
		else if(harvest)
			overlays += image(seed.plant_dmi,"[seed.plant_icon]-harvest")
		else if(age < seed.maturation)
			var/t_growthstate = max(1,round((age * seed.growth_stages) / seed.maturation))
			overlays += image(seed.plant_dmi,"[seed.plant_icon]-grow[t_growthstate]")
			lastproduce = age
		else
			overlays += image(seed.plant_dmi,"[seed.plant_icon]-grow[seed.growth_stages]")

	//Draw the cover.
	if(closed_system)
		overlays += "hydrocover"

	//Updated the various alert icons.
	if(draw_warnings)
		if(waterlevel <= 10)
			overlays += "over_lowwater3"
		if(nutrilevel <= 2)
			overlays += "over_lownutri3"
		if(weedlevel >= 5 || pestlevel >= 5 || toxins >= 40)
			overlays += "over_alert3"
		if(harvest)
			overlays += "over_harvest3"

	// Update bioluminescence and tray light
	calculate_light()
	return

/obj/machinery/portable_atmospherics/hydroponics/proc/calculate_light()
	var/light_out = 0
	if(light_on) light_out += internal_light
	if(seed&&seed.biolum)
		light_out+=round(seed.potency/10)
		if(seed.biolum_colour) light_color = seed.biolum_colour
		else light_color = null
	set_light(light_out)

 // If a weed growth is sufficient, this proc is called.
/obj/machinery/portable_atmospherics/hydroponics/proc/weed_invasion()


	//Remove the seed if something is already planted.
	if(seed) seed = null
	seed = seed_types[pick(list("reishi","nettles","amanita","mushrooms","plumphelmet","towercap","harebells","weeds"))]
	if(!seed) return //Weed does not exist, someone fucked up.

	dead = 0
	age = 0
	health = seed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0
	pestlevel = 0
	sampled = 0
	update_icon()
	visible_message("<span class='info'>[src] has been overtaken by [seed.display_name]</span>.")

	return

/obj/machinery/portable_atmospherics/hydroponics/proc/mutate(var/severity)


	// No seed, no mutations.
	if(!seed)
		return

	// Check if we should even bother working on the current seed datum.
	if(seed.mutants. && seed.mutants.len && severity > 1)
		mutate_species()
		return

	// We need to make sure we're not modifying one of the global seed datums.
	// If it's not in the global list, then no products of the line have been
	// harvested yet and it's safe to assume it's restricted to this tray.
	if(!isnull(seed_types[seed.name]))
		seed = seed.diverge()
	seed.mutate(severity,get_turf(src))

	return

/obj/machinery/portable_atmospherics/hydroponics/proc/check_level_sanity()
	//Make sure various values are sane.
	if(seed)
		health =     max(0,min(seed.endurance,health))
	else
		health = 0
		dead = 0

	mutation_level = max(0,min(mutation_level,100))
	nutrilevel =     max(0,min(nutrilevel,10))
	waterlevel =     max(0,min(waterlevel,100))
	pestlevel =      max(0,min(pestlevel,10))
	weedlevel =      max(0,min(weedlevel,10))
	toxins =         max(0,min(toxins,10))

/obj/machinery/portable_atmospherics/hydroponics/proc/mutate_species()


	var/previous_plant = seed.display_name
	var/newseed = seed.get_mutant_variant()
	if(newseed in seed_types)
		seed = seed_types[newseed]
	else
		return

	dead = 0
	mutate(1)
	age = 0
	health = seed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0

	update_icon()
	visible_message("<span class='alert'>The</span> <span class='info'>[previous_plant]</span> <span class='alert'>has suddenly mutated into</span> <span class='info'>[seed.display_name]!</span>")

	return

/obj/machinery/portable_atmospherics/hydroponics/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(O.is_open_container())
		return 0

	if(..())
		return 1

	if(istype(O, /obj/item/claypot))
		user << "<span class='warning'>You must place the pot on the ground and use a spade on \the [src] to make a transplant.</span>"
		return

	if(seed && istype(O, /obj/item/weapon/pickaxe/shovel))
		var/obj/item/claypot/C = locate() in range(user,1)
		if(!C)
			user << "<span class='warning'>You need an empty clay pot next to you.</span>"
			return
		playsound(loc, 'sound/items/shovel.ogg', 50, 1)
		if(do_after(user, src, 50))
			user.visible_message(	"<span class='notice'>[user] transplants \the [seed.display_name] into \the [C].</span>",
									"<span class='notice'>\icon[src] You transplant \the [seed.display_name] into \the [C].</span>",
									"<span class='notice'>You hear a ratchet.</span>")

			var/obj/structure/claypot/S = new(get_turf(C))
			transfer_fingerprints(C, S)
			qdel(C)

			if(seed.large)
				S.icon_state += "-large"

			if(dead)
				S.overlays += image(seed.plant_dmi,"[seed.plant_icon]-dead")
			else if(harvest)
				S.overlays += image(seed.plant_dmi,"[seed.plant_icon]-harvest")
			else if(age < seed.maturation)
				var/t_growthstate = max(1,round((age * seed.growth_stages) / seed.maturation))
				S.overlays += image(seed.plant_dmi,"[seed.plant_icon]-grow[t_growthstate]")
			else
				S.overlays += image(seed.plant_dmi,"[seed.plant_icon]-grow[seed.growth_stages]")

			S.plant_name = seed.display_name

			if(seed.biolum)
				S.set_light(round(seed.potency/10))
				if(seed.biolum_colour)
					S.light_color = seed.biolum_colour

			harvest = 0
			seed = null
			dead = 0
			sampled = 0
			age = 0
			yield_mod = 0
			mutation_mod = 0
			set_light(0)

			check_level_sanity()
			update_icon()

		return

	if(istype(O, /obj/item/weapon/wirecutters) || istype(O, /obj/item/weapon/scalpel))

		if(!seed)
			user << "There is nothing to take a sample from in \the [src]."
			return

		if(sampled)
			user << "You have already sampled from this plant."
			return

		if(dead)
			user << "The plant is dead."
			return

		// Create a sample.
		seed.harvest(user,yield_mod,1)
		health -= (rand(3,5)*10)

		if(prob(30))
			sampled = 1

		// Bookkeeping.
		check_level_sanity()
		force_update = 1
		process()

		return

	else if(istype(O, /obj/item/weapon/reagent_containers/syringe))

		var/obj/item/weapon/reagent_containers/syringe/S = O

		if (S.mode == 1)
			if(seed)
				return ..()
			else
				user << "There's no plant to inject."
				return 1
		else
			if(seed)
				//Leaving this in in case we want to extract from plants later.
				user << "You can't get any extract out of this plant."
			else
				user << "There's nothing to draw something from."
			return 1

	else if (istype(O, /obj/item/seeds))

		if(!seed)

			var/obj/item/seeds/S = O
			user.drop_item(S)

			if(!S.seed)
				user << "The packet seems to be empty. You throw it away."
				qdel(O)
				return

			user << "You plant the [S.seed.seed_name] [S.seed.seed_noun]."

			if(S.seed.spread == 1)
				msg_admin_attack("[key_name(user)] has planted a creeper packet.")
				var/obj/effect/plant_controller/creeper/PC = new(get_turf(src))
				if(PC)
					PC.seed = S.seed
			else if(S.seed.spread == 2)
				msg_admin_attack("[key_name(user)] has planted a spreading vine packet.")
				var/obj/effect/plant_controller/PC = new(get_turf(src))
				if(PC)
					PC.seed = S.seed
			else
				seed = S.seed //Grab the seed datum.
				dead = 0
				age = 1
				//Snowflakey, maybe move this to the seed datum
				health = (istype(S, /obj/item/seeds/cutting) ? round(seed.endurance/rand(2,5)) : seed.endurance)

				lastcycle = world.time

			qdel(O)

			check_level_sanity()
			update_icon()

		else
			user << "<span class='alert'>\The [src] already has seeds in it!</span>"

	else if (istype(O, /obj/item/weapon/minihoe))  // The minihoe

		if(weedlevel > 0)
			user.visible_message("<span class='alert'>[user] starts uprooting the weeds.</span>", "<span class='alert'>You remove the weeds from the [src].</span>")
			weedlevel = 0
			update_icon()
		else
			user << "<span class='alert'>This plot is completely devoid of weeds. It doesn't need uprooting.</span>"

	else if (istype(O, /obj/item/weapon/storage/bag/plants))

		attack_hand(user)

		var/obj/item/weapon/storage/bag/plants/S = O
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in locate(user.x,user.y,user.z))
			if(!S.can_be_inserted(G))
				return
			S.handle_item_insertion(G, 1)

	else if ( istype(O, /obj/item/weapon/plantspray) )

		var/obj/item/weapon/plantspray/spray = O
		user.drop_item(spray)
		toxins += spray.toxicity
		pestlevel -= spray.pest_kill_str
		weedlevel -= spray.weed_kill_str
		user << "You spray [src] with [O]."
		playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
		qdel(O)

		check_level_sanity()
		update_icon()

	else if(istype(O, /obj/item/weapon/wrench))

		//If there's a connector here, the portable_atmospherics setup can handle it.
		if(locate(/obj/machinery/atmospherics/unary/portables_connector/) in loc)
			return ..()

		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		anchored = !anchored
		user << "You [anchored ? "wrench" : "unwrench"] \the [src]."

	else if(istype(O, /obj/item/apiary))

		if(seed)
			user << "<span class='alert'>[src] is already occupied!</span>"
		else
			user.drop_item(O)
			qdel(O)

			var/obj/machinery/apiary/A = new(src.loc)
			A.icon = src.icon
			A.icon_state = src.icon_state
			A.hydrotray_type = src.type
			A.component_parts = component_parts.Copy()
			A.contents = contents.Copy()
			contents.len = 0
			component_parts.len = 0
			qdel(src)

	return

/obj/machinery/portable_atmospherics/hydroponics/attack_tk(mob/user as mob)

	if(harvest)
		harvest(user)

	else if(dead)
		remove_dead(user)

/obj/machinery/portable_atmospherics/hydroponics/attack_ai(mob/user as mob)

	return //Until we find something smart for you to do, please steer clear. Thanks

/obj/machinery/portable_atmospherics/hydroponics/attack_robot(mob/user as mob)

	if(isMoMMI(user) && Adjacent(user)) //Are we a beep ping ?
		return attack_hand(user) //Let them use the tray

/obj/machinery/portable_atmospherics/hydroponics/attack_hand(mob/user as mob)

	if(isobserver(user))
		if(!(..()))
			return 0
	if(harvest)
		harvest(user)
	else if(dead)
		remove_dead(user)

	else
		examine(user) //using examine() to display the reagents inside the tray as well

/obj/machinery/portable_atmospherics/hydroponics/examine(mob/user)
	..()
	view_contents(user)

/obj/machinery/portable_atmospherics/hydroponics/proc/view_contents(mob/user)
	if(src.seed && !src.dead)
		user << "[src] has <span class='info'>[src.seed.display_name]</span> planted."
		if(src.health <= (src.seed.endurance / 2))
			user << "The plant looks <span class='alert'>unhealthy.</span>"
	else if(src.seed && src.dead)
		user << "[src] is full of dead plant matter."
	else
		user << "[src] has nothing planted."
	if (Adjacent(user) || isobserver(user) || issilicon(user))
		user << "Water: [round(src.waterlevel,0.1)]/100"
		user << "Nutrient: [round(src.nutrilevel,0.1)]/10"
		if(src.weedlevel >= 5)
			user << "[src] is <span class='alert'>filled with weeds!</span>"
		if(src.pestlevel >= 5)
			user << "[src] is <span class='alert'>filled with tiny worms!</span>"

		if(!istype(src,/obj/machinery/portable_atmospherics/hydroponics/soil))

			var/turf/T = loc
			var/datum/gas_mixture/environment

			if(closed_system && (connected_port || holding))
				environment = air_contents

			if(!environment)
				if(istype(T))
					environment = T.return_air()

			if(!environment)
				if(istype(T, /turf/space))
					environment = space_gas
				else //Somewhere we shouldn't be, panic
					return

			var/light_available = 5
			if(T.dynamic_lighting)
				light_available = T.get_lumcount() * 10

			user << "The tray's sensor suite is reporting a light level of [light_available] lumens and a temperature of [environment.temperature]K."

/obj/machinery/portable_atmospherics/hydroponics/verb/close_lid()
	set name = "Toggle Tray Lid"
	set category = "Object"
	set src in view(1)

	if(!usr || usr.stat || usr.restrained() || (usr.status_flags & FAKEDEATH))
		return

	closed_system = !closed_system
	usr << "You [closed_system ? "close" : "open"] the tray's lid."
	if(closed_system)
		flags &= ~OPENCONTAINER
	else
		flags |= OPENCONTAINER

	update_icon()

/obj/machinery/portable_atmospherics/hydroponics/verb/light_toggle()
	set name = "Toggle Light"
	set category = "Object"
	set src in view(1)
	if(!usr || usr.stat || usr.restrained() || (usr.status_flags & FAKEDEATH))
		return
	light_on = !light_on
	calculate_light()

/obj/machinery/portable_atmospherics/hydroponics/soil
	name = "soil"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "soil"
	density = 0
	use_power = 0
	draw_warnings = 0

/obj/machinery/portable_atmospherics/hydroponics/soil/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/pickaxe/shovel))
		if(!seed)
			user << "You clear up [src]!"
			new /obj/item/weapon/ore/glass(loc)//we get some of the dirt back
			new /obj/item/weapon/ore/glass(loc)
			qdel(src)
		else
			..()
	else if(istype(O,/obj/item/weapon/pickaxe/shovel) || istype(O,/obj/item/weapon/tank))
		return
	else
		..()

/obj/machinery/portable_atmospherics/hydroponics/soil/New()
	..()
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/close_lid
	component_parts = list()


#undef HYDRO_SPEED_MULTIPLIER
