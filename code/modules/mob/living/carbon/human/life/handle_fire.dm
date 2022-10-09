//Refer to life.dm for caller

/mob/living/carbon/human/handle_fire()
	if(..())
		return
	if(isvampire(src) && isDead())
		dust(TRUE)

	var/thermal_protection = get_heat_protection(get_heat_protection_flags(30000)) //If you don't have fire suit level protection, you get a temperature increase
	if((1 - thermal_protection) > 0.0001 && bodytemperature < T0C+100) //MATHEMATICAL HELPERS FOR FUCKS SAKES
		bodytemperature = min(bodytemperature + BODYTEMP_HEATING_MAX,T0C+100)
		var/head_exposure = 1
		var/chest_exposure = 1
		var/groin_exposure = 1
		var/legs_exposure = 1
		var/arms_exposure = 1

		//Get heat transfer coefficients for clothing.

		for(var/obj/item/clothing/C in src)
			if(is_holding_item(C))
				continue

			if( C.max_heat_protection_temperature >= bodytemperature)
				if(!is_slot_hidden(C.body_parts_covered,FULL_HEAD))
					head_exposure = 0
				if(!is_slot_hidden(C.body_parts_covered,UPPER_TORSO))
					chest_exposure = 0
				if(!is_slot_hidden(C.body_parts_covered,LOWER_TORSO))
					groin_exposure = 0
				if(!is_slot_hidden(C.body_parts_covered,LEGS))
					legs_exposure = 0
				if(!is_slot_hidden(C.body_parts_covered,ARMS))
					arms_exposure = 0

		apply_damage(2.5*head_exposure, BURN, LIMB_HEAD, 0, 0, used_weapon = "Fire")
		apply_damage(2.5*chest_exposure, BURN, LIMB_CHEST, 0, 0, used_weapon ="Fire")
		apply_damage(2.0*groin_exposure, BURN, LIMB_GROIN, 0, 0, used_weapon ="Fire")
		apply_damage(0.6*legs_exposure, BURN, LIMB_LEFT_LEG, 0, 0, used_weapon = "Fire")
		apply_damage(0.6*legs_exposure, BURN, LIMB_RIGHT_LEG, 0, 0, used_weapon = "Fire")
		apply_damage(0.4*arms_exposure, BURN, LIMB_LEFT_ARM, 0, 0, used_weapon = "Fire")
		apply_damage(0.4*arms_exposure, BURN, LIMB_RIGHT_ARM, 0, 0, used_weapon = "Fire")
		adjustHalLoss(1)

		if(prob(20))
			src.audible_cough()
		if(prob(10))
			src.audible_scream()
