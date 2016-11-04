/mob/living/carbon/human/proc/handle_hunger_based_strength()
	if(!(species.flags & HUNGER_BASED_STRENGTH))
		return

	set_hunger_based_mods_to_default()

	//150 and under is red hunger
	//150 to 250 nutrition is yellow hunger
	//250 to 350 nutrition is normal hunger
	//350 to 450 nutrition is normal hunger
	//450 and over nutrition is overfed

	//Modifying the existing values here instead of setting them, so that the flag can be used on other races with different defaults.
	if(nutrition < 150) //red hunger
		species.brute_mod *= 1.5
		species.burn_mod *= 1.5
		species.move_speed_mod += 10
									   //Threshold based on standard default.
		species.cold_level_1 += 23.15  //10C
		species.cold_level_2 += 43.15  //-30C
		species.cold_level_3 += 83.15  //-70C
		species.heat_level_1 -= 36.85  //50C
		species.heat_level_2 -= 56.85  //70C
		species.heat_level_3 -= 356.85 //370C
		species.darksight /= 2

	else if(nutrition < 250) //yellow hunger
		species.brute_mod *= 1.25
		species.burn_mod *= 1.25
		species.move_speed_mod += 5
		species.cold_level_1 += 13.15  //0C
		species.cold_level_2 += 23.15  //-50C
		species.cold_level_3 += 53.15  //-100C
		species.heat_level_1 -= 16.85  //70C
		species.heat_level_2 -= 26.85  //100C
		species.heat_level_3 -= 176.85 //550C
		species.darksight = 1

	else if(nutrition > 450)//overfed
		species.brute_mod = 0.75
		species.burn_mod = 0.75
		species.cold_level_1 -= 16.85  //-30C
		species.cold_level_2 -= 26.85  //-100C
		species.cold_level_3 -= 26.85  //-180
		species.heat_level_1 += 13.15  //100C
		species.heat_level_2 += 53.15  //180C
		species.heat_level_3 += 653.15 //1380C
		species.punch_damage += 5
		species.can_be_hypothermic = 0
		species.darksight *= 3
		species.throw_mult *= 1.25
		species.pressure_resistance += (10 * ONE_ATMOSPHERE)

mob/living/carbon/human/proc/set_hunger_based_mods_to_default()
	species.brute_mod = initial(species.brute_mod)
	species.burn_mod = initial(species.burn_mod)
	species.move_speed_mod = initial(species.move_speed_mod)
	species.cold_level_1 = initial(species.cold_level_1)	//-13.15C
	species.cold_level_2 = initial(species.cold_level_2)	//-73.15C
	species.cold_level_3 = initial(species.cold_level_3)	//-153.15C
	species.heat_level_1 = initial(species.heat_level_1)	//86.85C
	species.heat_level_2 = initial(species.heat_level_2)	//126.85C
	species.heat_level_3 = initial(species.heat_level_3)	//726.85C
	species.punch_damage = initial(species.punch_damage)
	species.can_be_hypothermic = initial(species.can_be_hypothermic)
	species.darksight = initial(species.darksight)
	species.throw_mult = initial(species.throw_mult)
	species.pressure_resistance = initial(species.pressure_resistance)