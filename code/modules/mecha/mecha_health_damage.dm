/obj/mecha/proc/get_health()
	return (health/initial(health)*100)

////////////////////////////////////////
////////  Health related procs  ////////
////////////////////////////////////////

/obj/mecha/proc/take_flat_damage(amount, type="brute")
	if(amount)
		health -= amount
		update_health()
		log_append_to_last("Took [amount] points of damage.",1)
	return

/obj/mecha/proc/get_damage_absorption()
	var/obj/item/mecha_parts/component/armor/AC = internal_components[MECH_ARMOR]

	if(!istype(AC))
		return

	else
		if(AC.get_efficiency() > 0.25)
			return AC.damage_absorption

	return
/*
/obj/mecha/proc/components_handle_damage(var/damage, var/type = BRUTE)
	var/obj/item/mecha_parts/component/armor/AC = internal_components[MECH_ARMOR]
	var/penetrating_attack = FALSE

	damage *= src.damage_absorption[type]

	if(AC)
		var/armor_efficiency = AC.get_efficiency()
		var/damage_change = armor_efficiency * (damage * 0.5) * AC.damage_absorption[type]
		AC.damage_part(damage_change, type)
		damage -= damage_change
		if(AC.integrity < 5)
			AC.damage_part(AC.integrity) // No 0.1% health armor

	var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]

	if(HC)
		if(HC.integrity)
			var/hull_absorb = round(rand(5, 10) / 10, 0.1) * (damage * 0.5)
			HC.damage_part(hull_absorb, type)
			damage -= hull_absorb

	for(var/obj/item/mecha_parts/component/C in (internal_components - list(MECH_HULL, MECH_ARMOR)))
		if(prob(C.relative_size))
			var/damage_part_amt = round(damage / 2, 0.1)
			C.damage_part(damage_part_amt)
			damage -= damage_part_amt

	return damage
*/

/obj/mecha/proc/components_handle_damage(var/damage, var/type = BRUTE)
	var/obj/item/mecha_parts/component/armor/AC = internal_components[MECH_ARMOR]
	var/penetrating_attack = FALSE
	damage *= src.damage_absorption[type]
	if(AC)
		var/armor_efficiency = AC.get_efficiency()
		var/damage_change = armor_efficiency * (damage * 0.5) * AC.damage_absorption[type]
		AC.damage_part(damage_change, type)
		damage -= damage_change
		if(AC.integrity < 5)
			AC.damage_part(AC.integrity) // No 0.1% health armor
	var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]
	if(HC)
		if(HC.integrity)
			var/hull_absorb = round(rand(5, 10) / 10, 0.1) * (damage * 0.5)
			HC.damage_part(hull_absorb, type)
			damage -= hull_absorb
	for(var/component_key in internal_components)
		if(component_key == MECH_HULL || component_key == MECH_ARMOR)
			continue
		var/obj/item/mecha_parts/component/C = internal_components[component_key]
		if(C && prob(C.relative_size))
			var/damage_part_amt = round(damage / 3, 0.1)
			C.damage_part(damage_part_amt)
			damage -= damage_part_amt
	return damage

/obj/mecha/take_damage(incoming_damage, damage_type = "brute", skip_break, mute, var/violent = TRUE)
	if(incoming_damage)
		var/damage = absorbDamage(incoming_damage,damage_type)
		if(violent)
			damage = components_handle_damage(damage,damage_type)
		health -= damage
		update_health()
		CheckEnclosed()
		CheckLocks()
		SetPressure()
		log_append_to_last("Took [damage] points of damage. Damage type: \"[damage_type]\".",1)
	return

/obj/mecha/proc/absorbDamage(damage,damage_type)
	return call((proc_res["dynabsorbdamage"]||src), "dynabsorbdamage")(damage,damage_type)

/obj/mecha/proc/dynabsorbdamage(damage,damage_type)
	return damage*(listgetindex(get_damage_absorption(),damage_type) || 1)

/obj/mecha/proc/update_health()
	if(src.health > 0)
		spark(src, 2, FALSE)
	else
		qdel(src)

/obj/mecha/attack_hand(mob/living/user as mob, monkey = FALSE)
	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = deflect_chance

	if(!ArmC)
		temp_deflect_chance = 1

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))

	if(monkey)
		src.log_message("Attack by paw. Attacker - [user].",1)
	else
		src.log_message("Attack by hand. Attacker - [user].",1)
	var/obj/item/mecha_parts/mecha_equipment/passive/rack/R = get_equipment(/obj/item/mecha_parts/mecha_equipment/passive/rack)
	if(R && operation_allowed(user))
		R.rack.AltClick(user)
		return
	user.do_attack_animation(src, user)
	if ((M_HULK in user.mutations) && !prob(temp_deflect_chance))
		src.take_damage(15)
		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		user.visible_message("<span class='red'><b>[user] hits [src.name], doing some damage.</b></span>", "<span class='red'><b>You hit [src.name] with all your might. The metal creaks and bends.</b></span>")
	else
		user.visible_message("<span class='red'><b>[user] hits [src.name]. Nothing happens.</b></span>","<span class='red'><b>You hit [src.name] with no visible effect.</b></span>")
		src.log_append_to_last("Armor saved.")

	user.delayNextAttack(10)

/obj/mecha/attack_paw(mob/user as mob)
	return src.attack_hand(user, TRUE)


/obj/mecha/attack_alien(mob/living/user as mob)
	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = deflect_chance

	if(!ArmC)
		temp_deflect_chance = 1

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))

	user.do_attack_animation(src, user)
	src.log_message("Attack by alien. Attacker - [user].",1)
	if(!prob(temp_deflect_chance))
		src.take_damage(15)
		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		playsound(src, 'sound/weapons/slash.ogg', 50, 1, -1)
		to_chat(user, "<span class='warning'>You slash at the armored suit!</span>")
		visible_message("<span class='warning'>The [user] slashes at [src.name]'s armor!</span>")
	else
		src.log_append_to_last("Armor saved.")
		playsound(src, 'sound/weapons/slash.ogg', 50, 1, -1)
		to_chat(user, "<span class='good'>Your claws had no effect!</span>")
		src.occupant_message("<span class='notice'>The [user]'s claws are stopped by the armor.</span>")
		visible_message("<span class='notice'>The [user] rebounds off [src.name]'s armor!</span>")

	user.delayNextAttack(10)

/obj/mecha/attack_animal(mob/living/simple_animal/user as mob)
	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = deflect_chance

	if(!ArmC)
		temp_deflect_chance = 1

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))

	user.do_attack_animation(src, user)
	src.log_message("Attack by simple animal. Attacker - [user].",1)
	if(user.melee_damage_upper == 0)
		user.emote("[user.friendly] [src]")
	else
		add_logs(user, src, "attacked", admin = user.ckey ? TRUE : FALSE) //Only add this to the server logs if they're controlled by a player.
		if(!prob(temp_deflect_chance))
			var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
			src.take_damage(damage)
			src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
			visible_message("<span class='warning'><B>[user]</B> [user.attacktext] [src]!</span>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
		else
			src.log_append_to_last("Armor saved.")
			playsound(src, 'sound/weapons/slash.ogg', 50, 1, -1)
			src.occupant_message("<span class='notice'>The [user]'s attack is stopped by the armor.</span>")
			visible_message("<span class='notice'>The [user] rebounds off [src.name]'s armor!</span>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
	user.delayNextAttack(10)

/obj/mecha/hitby(atom/movable/A as mob|obj) //wrapper
	. = ..()
	if(.)
		return
	src.log_message("Hit by [A].",1)
	call((proc_res["dynhitby"]||src), "dynhitby")(A)

/obj/mecha/proc/dynhitby(atom/movable/A)
	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = deflect_chance
	var/temp_damage_minimum = damage_minimum

	if(!ArmC)
		temp_deflect_chance = src.deflect_chance + (defense_mode ? 25 : 0)
		temp_damage_minimum = src.damage_minimum

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))
		temp_damage_minimum = round(ArmC.get_efficiency() * ArmC.damage_minimum) + src.damage_minimum

	if(istype(A, /obj/item/mecha_parts/mecha_tracking) && !tracking && prob(25))
		A.forceMove(src)
		tracking = A
		src.visible_message("The [A] fastens firmly to [src].")
		return

	if(prob(temp_deflect_chance) || istype(A, /mob))
		src.occupant_message("<span class='notice'>The [A] bounces off the armor.</span>")
		src.visible_message("The [A] bounces off the [src.name] armor")
		src.log_append_to_last("Armor saved.")
		if(istype(A, /mob/living))
			var/mob/living/M = A
			M.take_organ_damage(10)

	else if(istype(A, /obj))
		var/obj/O = A
		if(O.throwforce)

			var/pass_damage = O.throwforce
			var/pass_damage_reduc_mod
			if(pass_damage <= temp_damage_minimum)//Too little to go through.
				src.occupant_message("<span class='notice'>\The [A] bounces off the armor.</span>")
				src.visible_message("\The [A] bounces off \the [src] armor")
				return

				pass_damage_reduc_mod = 1

			for(var/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/ME in equipment)
				pass_damage = ME.handle_ranged_contact(A, pass_damage)

			pass_damage = (pass_damage*pass_damage_reduc_mod)//Applying damage reduction
			src.take_damage(pass_damage)	//The take_damage() proc handles armor values
			if(pass_damage > internal_damage_minimum)	//Only decently painful attacks trigger a chance of mech damage.
				src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	return


/obj/mecha/bullet_act(var/obj/item/projectile/Proj) //wrapper
	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]
	var/chance = 75
	if(!enclosed && occupant && !silicon_pilot)
		if(ArmC && ArmC.integrity >= 0)
			chance = 25
		if(prob(chance))
			occupant.bullet_act(Proj)
			visible_message("<span class='warning'>[occupant] is hit by \the [Proj]!")
			Proj.on_hit(src,2)
			if(Proj.penetration <= 5)
				return PROJECTILE_COLLISION_DEFAULT
	src.log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).",1)
	call((proc_res["dynbulletdamage"]||src), "dynbulletdamage")(Proj) //calls equipment
	return ..()

/obj/mecha/proc/dynbulletdamage(var/obj/item/projectile/Proj, var/penetrating = FALSE)

	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = 0
	var/temp_damage_minimum = 0
	var/penetration_reduction

	if(!ArmC || ArmC.integrity <= 5)
		temp_deflect_chance = src.deflect_chance + (defense_mode ? 25 : 0)
		temp_damage_minimum = src.damage_minimum
		penetration_reduction = src.penetration_reduction

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))
		temp_damage_minimum = round(ArmC.get_efficiency() * ArmC.damage_minimum) + src.damage_minimum
		penetration_reduction = ArmC.pen_reduction + src.penetration_reduction

	if(prob(temp_deflect_chance))
		src.occupant_message("<span class='notice'>The armor deflects incoming projectile.</span>")
		src.visible_message("The [src.name] armor deflects the projectile")
		src.log_append_to_last("Armor saved.")
		return

	if(Proj.flag == "taser")
		use_power(200)
		return

	if(!(Proj.nodamage))
		var/ignore_threshold
		if(istype(Proj, /obj/item/projectile/beam/pulse))	//ATM, this is literally only for the pulse rifles used mostly by deathsquads.
			ignore_threshold = 1

		var/damage = Proj.damage
		for(var/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/ME in equipment)
			damage = ME.dynbulletdamage(Proj, damage)

		if(damage < temp_damage_minimum)//too pathetic to really damage you.
			src.occupant_message("<span class='notice'>The armor deflects incoming projectile.</span>")
			src.visible_message("The [src.name] armor deflects\the [Proj]")
			return

		src.take_damage(damage, Proj.flag)	//The take_damage() proc handles armor values
		if(prob(25))
			spark(src, 2, FALSE)
		if(damage >= internal_damage_minimum)	//Only decently painful attacks trigger a chance of mech damage.
			src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),ignore_threshold)

		//AP projectiles have a chance to cause additional damage
		if(Proj.penetration)
			if(penetration_reduction)
				Proj.penetration -= penetration_reduction
			var/hit_occupant = 1 //only allow the occupant to be hit once
			for(var/i in 1 to min(Proj.penetration, round(Proj.damage/3)))
				if(src.occupant && hit_occupant && prob(75))
					occupant.bullet_act(Proj)
					visible_message("<span class='warning'>[occupant] is hit by \the [Proj]!")
					Proj.on_hit(src,2)
					hit_occupant = 0
					penetrating = TRUE
					return PROJECTILE_COLLISION_DEFAULT
				else
					if(damage > internal_damage_minimum)	//Only decently painful attacks trigger a chance of mech damage.
						src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT), 1)

				Proj.penetration--

	Proj.on_hit(src) //on_hit just returns if it's argument is not a living mob so does this actually do anything?
	return

/obj/mecha/ex_act(severity)
/*
	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = deflect_chance

	if(!ArmC)
		temp_deflect_chance = 0

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))
*/
	src.log_message("Affected by explosion of severity: [severity].",1)
//	if(prob(temp_deflect_chance))
//		severity++
//		src.log_append_to_last("Armor saved, changing severity to [severity].")
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(30))
				src.take_damage(initial(src.health)*1.5, "bomb")
				src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
			else
				src.take_damage(initial(src.health))
				src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
		if(3.0)
			src.take_damage(initial(src.health)/5, "bomb")
			src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
	return

/*Will fix later -Sieve
/obj/mecha/attack_blob(mob/user as mob)
	src.log_message("Attack by blob. Attacker - [user].",1)
	if(!prob(src.deflect_chance))
		src.take_damage(6)
		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		playsound(src, 'sound/effects/blobattack.ogg', 50, 1, -1)
		to_chat(user, "<span class='warning'>You smash at the armored suit!</span>")
		for (var/mob/V in viewers(src))
			if(V.client && !(V.blinded))
				V.show_message("<span class='warning'>The [user] smashes against [src.name]'s armor!</span>", 1)
	else
		src.log_append_to_last("Armor saved.")
		playsound(src, 'sound/effects/blobattack.ogg', 50, 1, -1)
		to_chat(user, "<span class='good'>Your attack had no effect!</span>")
		src.occupant_message("<span class='notice'>The [user]'s attack is stopped by the armor.</span>")
		for (var/mob/V in viewers(src))
			if(V.client && !(V.blinded))
				V.show_message("<span class='notice'>The [user] rebounds off the [src.name] armor!</span>", 1)
	return
*/

/obj/mecha/blob_act()
	take_damage(30, damage_type = "brute")
	return

/obj/mecha/emp_act(severity)
	var/obj/item/mecha_parts/component/electrical/zap = internal_components[MECH_ELECTRIC]
	if(get_charge())
		if(!zap || zap.integrity <= 0) // Only EMP the cell if there's no electrical hub
			cell.emp_act(severity*1.25)
		take_damage(10 / severity, damage_type = "energy", violent = FALSE)
		src.log_message("EMP detected",1)
		check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
		for(var/obj/item/mecha_parts/mecha_equipment/M in equipment)
			M.emp_act(severity)
		for(var/slot in internal_components)
			var/obj/item/mecha_parts/component/C = internal_components[slot]
			if(istype(C))
				C.emp_act(severity)
		return

/obj/mecha/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]

	var/turf/T = get_turf(loc)
	. = FALSE
	if(!istype(T))
		return
	var/datum/gas_mixture/environment = T.return_air()
	if(!istype(environment))
		return

	if(HC && HC.integrity <= 0)
		max_temperature += HC.max_temperature

	if(exposed_temperature>src.max_temperature && environment.return_pressure() >= HAZARD_HIGH_PRESSURE) // Has to be a sufficient pressure for fire to hurt mechs.
		src.log_message("Exposed to dangerous temperature.",1)
		src.take_damage(5, damage_type = "fire", violent = FALSE) // For now, make it so hull&armor doesn't take damage from fire.
		src.check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL))

	if(enclosed)// || mecha_flags & SILICON_PILOT)
		return
	for(var/mob/living/cookedalive as anything in occupant)
		if(cookedalive.fire_stacks < 5)
			cookedalive.adjust_fire_stacks(1)
			cookedalive.ignite()

	return

/obj/mecha/proc/dynattackby(obj/item/weapon/W as obj, mob/living/user as mob)
	user.delayNextAttack(8)
	user.do_attack_animation(src, W)

	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = deflect_chance
	var/temp_damage_minimum = damage_minimum

	if(!ArmC)
		temp_deflect_chance = src.deflect_chance + (defense_mode ? 25 : 0)
		temp_damage_minimum = src.damage_minimum

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))
		temp_damage_minimum = round(ArmC.get_efficiency() * ArmC.damage_minimum) + src.damage_minimum

	if(prob(temp_deflect_chance))		//Does your attack get deflected outright.
		src.occupant_message("<span class='notice'>\The [W] bounces off [src.name].</span>")
		to_chat(user, "<span class='danger'>\The [W] bounces off [src.name].</span>")
		src.log_append_to_last("Armor saved.")

	else if(W.force < temp_damage_minimum)	//Is your attack too PATHETIC to do anything. 3 damage to a person shouldn't do anything to a mech.
		src.occupant_message("<span class='notice'>\The [W] bounces off the armor.</span>")
		src.visible_message("\The [W] bounces off \the [src] armor")
		return

	else
		src.occupant_message("<font color='red'><b>[user] hits [src] with [W].</b></font>")
		user.visible_message("<font color='red'><b>[user] hits [src] with [W].</b></font>", "<font color='red'><b>You hit [src] with [W].</b></font>")

		var/pass_damage = W.force
		for(var/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/ME in equipment)
			pass_damage = ME.handle_projectile_contact(W, user, pass_damage)
		src.take_damage(pass_damage,W.damtype)	//The take_damage() proc handles armor values
		if(pass_damage > internal_damage_minimum)	//Only decently painful attacks trigger a chance of mech damage.
			src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	return
