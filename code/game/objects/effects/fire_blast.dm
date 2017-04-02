/obj/effect/fire_blast
	name = "fire blast"
	desc = "That looks hot."
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	density = 0
	anchored = 1.0
	w_type=NOT_RECYCLABLE
	var/fire_damage = 0
	var/blast_age = 1
	var/duration = 10 //1/10ths of a second
	var/spread = 1
	var/spread_start = 100
	var/spread_chance = 20

/obj/effect/fire_blast/New(atom/A, var/damage = 0, var/current_step = 0, var/age = 1, var/pressure = 0, var/blast_temperature = 0, var/fire_duration)
	..(A)
	icon_state = "[rand(1,3)]"

	blast_age = age
	if(fire_duration)
		duration = fire_duration

	if(damage)
		fire_damage = damage
	set_light(3)

	pressure = round(pressure)
	var/adjusted_fire_damage = fire_damage

	switch(pressure)
		if(1000 to INFINITY)
			spread_start = 5
			spread_chance = 50
		if(800 to 999)
			spread_start = 6
			spread_chance = 40
			adjusted_fire_damage = fire_damage * 0.9
		if(600 to 799)
			spread_start = 7
			spread_chance = 30
			adjusted_fire_damage = fire_damage * 0.8
		if(400 to 599)
			spread_start = 8
			adjusted_fire_damage = fire_damage * 0.7
		if(300 to 399)
			spread_start = 9
			adjusted_fire_damage = fire_damage * 0.6
		if(150 to 299)
			spread_start = 10
			adjusted_fire_damage = fire_damage * 0.4
		if(0 to 149)
			adjusted_fire_damage = fire_damage * 0.25

	spawn()
		if(spread && current_step >= spread_start && blast_age < 4)
			var/turf/TS = get_turf(src)
			for(var/turf/TU in range(1, TS))
				if(TU != get_turf(src))
					var/tilehasfire = 0
					var/obstructed = 0
					for(var/obj/effect/E in TU)
						if(istype(E, /obj/effect/fire_blast))
							tilehasfire = 1
					for(var/obj/machinery/door/D in TU)
						if(istype(D, /obj/machinery/door/airlock) || istype(D, /obj/machinery/door/mineral))
							if(D.density)
								obstructed = 1
					if(prob(spread_chance) && TS.Adjacent(TU) && !TU.density && !tilehasfire && !obstructed)
						new type(TU, fire_damage, current_step, blast_age+1, pressure, blast_temperature, duration)
				sleep(1)

	spawn()
		for(var/i = 1; i <= (duration * 0.5); i++)
			for(var/mob/living/L in get_turf(src))
				if(issilicon(L))
					continue

				if(!L.on_fire)
					L.adjust_fire_stacks(0.5)
					L.IgniteMob()

				if(L.mutations.Find(M_RESIST_HEAT)) //Heat resistance protects you from damage, but you still get set on fire
					continue

				if(!istype(L, /mob/living/carbon/human))
					L.adjustFireLoss(adjusted_fire_damage * 2) //Deals double damage to non-human mobs
				else
					L.adjustFireLoss(adjusted_fire_damage)

			for(var/obj/O in get_turf(A))
				if(istype(O, /obj/structure/reagent_dispensers/fueltank))
					var/obj/structure/reagent_dispensers/fueltank/F = O
					if(blast_temperature >= 561.15) //561.15 is welderfuel's autoignition temperature.
						F.explode()
				else if(O.autoignition_temperature)
					if(blast_temperature >= O.autoignition_temperature)
						O.ignite(blast_temperature)
			for(var/obj/effect/E in get_turf(A))
				if(istype(E, /obj/effect/blob))
					var/obj/effect/blob/B = E
					B.health -= (adjusted_fire_damage/10)
					B.update_icon()
			var/turf/T2 = get_turf(src)
			T2.hotspot_expose((blast_temperature * 2) + 380,500)
			sleep(2)

		qdel(src)

/obj/effect/fire_blast/blue
	icon = 'icons/effects/fireblue.dmi'

/obj/effect/fire_blast/blue/New(T, var/damage = 0, var/current_step = 0, var/age = 1, var/pressure = 0, var/blast_temperature = 0, var/fire_duration)
	..(T, damage, current_step, age, pressure, blast_temperature, fire_duration)
	spread_start = 0
	spread_chance = 30

/obj/effect/gas_puff
	name = "gas puff"
	desc = "A small puff of gas."
	icon = 'icons/effects/plasma.dmi'
	icon_state = null
	density = 0
	w_type=NOT_RECYCLABLE

/obj/effect/gas_puff/New(atom/A, var/datum/gas_mixture/stored_gas = null, var/type_of_gas)
	..(A)

	if(type_of_gas)
		switch(type_of_gas)
			if("plasma")
				icon_state = "onturf-purple"
				name = "plasma puff"
				desc = "A small puff of plasma gas."
			if("N2O")
				icon_state = "sl_gas"
				name = "N2O puff"
				desc = "A small puff of nitrogen dioxide gas."
		update_icon()

	if(stored_gas)
		loc.assume_air(stored_gas)

	spawn()
		for(var/i = 1; i <= 5; i++)
			sleep(2)

		qdel(src)