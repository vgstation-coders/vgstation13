/*
 * Oh god
 * What the fuck am I doing
 * I am not good with compueter
 */


/obj/machinery/portable_atmospherics/hydroponics/proc/adjust_nutrient(var/amount, var/bloody = 0)
	if(seed)
		if(seed.hematophage != bloody)
			return
	else
		if(bloody)
			return
	nutrilevel += amount

/obj/machinery/portable_atmospherics/hydroponics/proc/adjust_water(var/amount)
	waterlevel += amount
	// Water dilutes toxin level.
	if(amount > 0)
		toxins -= amount*4

//Process reagents being input into the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/process_reagents()
	if(reagents.total_volume <= 0 || mutation_level >= 25)
		if(mutation_level) //probably a way to not check this twice but meh
			mutate(min(mutation_level, 25)) //Lazy 25u cap to prevent cheesing the whole thing
			mutation_level = 0
			return
	else
		for(var/datum/reagent/A in reagents.reagent_list)
			A.on_plant_life(src)
			reagents.update_total()

		check_level_sanity()
		update_icon_after_process = 1

/*
 -----------------------------------  -----------------------------------  -----------------------------------
*/

/datum/reagent/nutriment/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)
	if(T.seed && !T.dead)
		T.health += 0.5

/datum/reagent/fertilizer/eznutrient/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)

/datum/reagent/water/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(1)

/datum/reagent/mutagen
	custom_plant_metabolism = 2
/datum/reagent/mutagen/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.mutation_level += 1*T.mutation_mod*custom_plant_metabolism

/datum/reagent/radium
	custom_plant_metabolism = 2
/datum/reagent/radium/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.mutation_level += 0.6*T.mutation_mod*custom_plant_metabolism
	T.toxins += 4
	if(T.seed && !T.dead)
		T.health -= 1.5
		if(prob(20))
			T.mutation_mod += 0.1 //ha ha

/datum/reagent/fertilizer/left4zed/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)
	if(T.seed && !T.dead)
		T.health -= 0.5
		if(prob(30))
			T.mutation_mod += 0.2

/datum/reagent/diethylamine
	custom_plant_metabolism = 0.1
/datum/reagent/diethylamine/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	if(prob(100*custom_plant_metabolism))
		T.pestlevel -= 1
	if(T.seed && !T.dead)
		T.health += 0.1
		if(prob(200*custom_plant_metabolism))
			T.affect_growth(1)
		if(!T.seed.immutable)
			var/chance
			chance = unmix(T.seed.lifespan, 15, 125)*200*custom_plant_metabolism
			if(prob(chance))
				T.check_for_divergence(1)
				T.seed.lifespan++
			chance = unmix(T.seed.lifespan, 15, 125)*200*custom_plant_metabolism
			if(prob(chance))
				T.check_for_divergence(1)
				T.seed.endurance++

/datum/reagent/fertilizer/robustharvest
	custom_plant_metabolism = 0.1
/datum/reagent/fertilizer/robustharvest/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.05)
	if(prob(25*custom_plant_metabolism))
		T.weedlevel += 1
	if(T.seed && !T.dead && prob(25*custom_plant_metabolism))
		T.pestlevel += 1
	if(T.seed && !T.dead && !T.seed.immutable)
		var/chance
		chance = unmix(T.seed.potency, 15, 150)*350*custom_plant_metabolism
		if(prob(chance))
			T.check_for_divergence(1)
			T.seed.potency++
		chance = unmix(T.seed.yield, 6, 2)*15*custom_plant_metabolism
		if(prob(chance))
			T.check_for_divergence(1)
			T.seed.yield--
		/*chance = unmix(T.seed.endurance, 90, 15)*200*custom_plant_metabolism
		if(prob(chance))
			T.check_for_divergence(1)
			T.seed.endurance--*/

/datum/reagent/toxin/plantbgone/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 6
	T.weedlevel -= 8
	if(T.seed && !T.dead)
		T.health -= 20
		T.mutation_mod += 0.1

/datum/reagent/clonexadone
	custom_plant_metabolism = 0.5
/datum/reagent/clonexadone/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins -= 5
	if(T.seed && !T.dead)
		T.health += 5
		var/datum/seed/S = T.seed
		var/deviation
		if(T.age > S.maturation)
			deviation = max(S.maturation-1, T.age-rand(7,10))
		else
			deviation = S.maturation/S.growth_stages
		T.age -= deviation
		T.skip_aging++
		T.force_update = 1

/datum/reagent/milk/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	T.adjust_water(0.9)

/datum/reagent/beer/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.25)
	T.adjust_water(0.7)

/datum/reagent/blood/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.5, bloody=1)
	T.adjust_water(0.7)

/datum/reagent/phosphorus/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	T.adjust_water(-0.5)
	T.weedlevel -= 2

/datum/reagent/sugar/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	T.weedlevel += 2
	T.pestlevel += 2

/datum/reagent/sodiumchloride/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(-3)
	T.adjust_nutrient(-0.3)
	T.toxins += 8
	T.weedlevel -= 2
	T.pestlevel -= 1
	if(T.seed && !T.dead)
		T.health -= 2

/datum/reagent/sodawater/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	T.adjust_water(1)
	if(T.seed && !T.dead)
		T.health += 0.1

/datum/reagent/ammonia/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)
	if(T.seed && !T.dead)
		T.health += 0.5

/datum/reagent/adminordrazine/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)
	T.adjust_water(1)
	T.weedlevel -= 5
	T.pestlevel -= 5
	T.toxins -= 5
	if(T.seed && !T.dead)
		T.health += 50

/datum/reagent/anti_toxin/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins -= 10
	if(T.seed && !T.dead)
		T.health += 1

/datum/reagent/toxin/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 10

/datum/reagent/fluorine/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(-0.5)
	T.toxins += 25
	T.weedlevel -= 4
	if(T.seed && !T.dead)
		T.health -= 2

/datum/reagent/chlorine/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(-0.5)
	T.toxins += 15
	T.weedlevel -= 3
	if(T.seed && !T.dead)
		T.health -= 1

/datum/reagent/sacid/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 10
	T.weedlevel -= 2
	if(T.seed && !T.dead)
		T.health -= 4

/datum/reagent/pacid/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 20
	T.weedlevel -= 4
	if(T.seed && !T.dead)
		T.health -= 8

/datum/reagent/cryoxadone/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins -= 3
	if(T.seed && !T.dead)
		T.health += 3