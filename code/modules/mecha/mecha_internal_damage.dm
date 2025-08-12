///////////////////////////////////
////////  Internal damage  ////////
///////////////////////////////////

/obj/mecha/proc/check_for_internal_damage(var/list/possible_int_damage,var/ignore_threshold=null)
	if(!islist(possible_int_damage) || isemptylist(possible_int_damage))
		return
	if(prob(20))
		if(ignore_threshold || src.health*100/initial(src.health)<src.internal_damage_threshold)
			for(var/T in possible_int_damage)
				if(internal_damage & T)
					possible_int_damage -= T
			var/int_dam_flag = safepick(possible_int_damage)
			if(int_dam_flag)
				setInternalDamage(int_dam_flag)
	if(prob(10))
		if(ignore_threshold || src.health*100/initial(src.health)<src.internal_damage_threshold)
			var/obj/item/mecha_parts/mecha_equipment/drop = safepick(equipment)
			if(drop)
				drop.detach()
	return

/obj/mecha/proc/hasInternalDamage(int_dam_flag=null)
	return int_dam_flag ? internal_damage&int_dam_flag : internal_damage


/obj/mecha/proc/setInternalDamage(int_dam_flag)
	if(src && src.health > 0)
		internal_damage |= int_dam_flag
		pr_internal_damage.start()
		log_append_to_last("Internal damage of type [int_dam_flag].",1)
		occupant << sound('sound/machines/warning.ogg',wait=0)
	return

/obj/mecha/proc/clearInternalDamage(int_dam_flag)
	internal_damage &= ~int_dam_flag
	switch(int_dam_flag)
		if(MECHA_INT_TEMP_CONTROL)
			occupant_message("<span class='notice'><b>Life support system reactivated.</b></span>")
			pr_int_temp_processor.start()
		if(MECHA_INT_FIRE)
			occupant_message("<span class='notice'><b>Internal fire extinquished.</b></span>")
		if(MECHA_INT_TANK_BREACH)
			occupant_message("<span class='notice'><b>Damaged internal tank has been sealed.</b></span>")
	return
