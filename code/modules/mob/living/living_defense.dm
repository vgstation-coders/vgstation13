
/*
	run_armor_check(a,b)
	args
	a:def_zone - What part is getting hit, if null will check entire body
	b:attack_flag - What type of attack, bullet, laser, energy, melee

	Returns
	0 - no block
	1 - halfblock
	2 - fullblock
*/
/mob/living/proc/run_armor_check(var/def_zone = null, var/attack_flag = "melee", var/absorb_text = null, var/soften_text = null, modifier = 1, var/quiet = 0, var/armor_penetration = 0)
	var/armor = getarmor(def_zone, attack_flag)
	var/absorb = 0

	if(prob(armor * modifier))
		absorb += 1
	if(prob(armor * modifier))
		absorb += 1

	if(prob(armor_penetration))
		absorb -= 1
	if(prob(armor_penetration))
		absorb -= 1

	if(absorb >= 2)
		if(!quiet)
			if(absorb_text)
				show_message("[absorb_text]")
			else
				show_message("<span class='warning'>Your armor absorbs the blow!</span>")
		return 2
	if(absorb == 1)
		if(!quiet)
			if(absorb_text)
				show_message("[soften_text]",4)
			else
				show_message("<span class='warning'>Your armor softens the blow!</span>")
		return 1
	return 0

/mob/living/proc/getarmor(var/def_zone, var/type)
	return 0

/mob/living/proc/getarmorabsorb(var/def_zone, var/type)
	return 0

/mob/living/proc/run_armor_absorb(var/def_zone = null, var/attack_flag = "melee", var/initial_damage)
	var/armor = getarmorabsorb(def_zone, attack_flag)
	var/final_damage = initial_damage
	if(armor)
		var/damage_multiplier = final_damage/armor
		if(damage_multiplier < 1)
			final_damage *= damage_multiplier

	return final_damage


/mob/living/bullet_act(var/obj/item/projectile/P, var/def_zone)
	var/obj/item/weapon/cloaking_device/C = locate((/obj/item/weapon/cloaking_device) in src)
	if(C && C.active)
		C.attack_self(src)//Should shut it off
		update_icons()
		to_chat(src, "<span class='notice'>Your [C.name] was disrupted!</span>")
		Stun(2)

	flash_weak_pain()

	if(istype(get_active_hand(),/obj/item/device/assembly/signaler))
		var/obj/item/device/assembly/signaler/signaler = get_active_hand()
		if(signaler.deadman && prob(80))
			src.visible_message("<span class='warning'>[src] triggers their deadman's switch!</span>")
			signaler.signal()

	var/absorb = run_armor_check(def_zone, P.flag, armor_penetration = P.armor_penetration)
	if(absorb >= 2)
		P.on_hit(src,2)
		return 2
	if(!P.nodamage)
		var/damage = run_armor_absorb(def_zone, P.flag, (P.damage/(absorb+1)))
		apply_damage(damage, P.damage_type, def_zone, absorb, P.is_sharp(), used_weapon = P)
		regenerate_icons()
	P.on_hit(src, absorb)
	if(istype(P, /obj/item/projectile/beam/lightning))
		if(P.damage >= 200)
			src.dust()
	return absorb

/mob/living/hitby(atom/movable/AM as mob|obj,var/speed = 5,var/dir)//Standardization and logging -Sieve
	. = ..()
	if(.)
		return
	if(flags & INVULNERABLE)
		return
	if(istype(AM,/obj/))
		var/obj/O = AM
		var/zone = ran_zone(LIMB_CHEST,75)//Hits a random part of the body, geared towards the chest
		var/dtype = BRUTE
		if(istype(O,/obj/item/weapon))
			var/obj/item/weapon/W = O
			dtype = W.damtype
		src.visible_message("<span class='warning'>[src] has been hit by [O].</span>")
		if(O.impactsound)
			playsound(loc, O.impactsound, 80, 1, -1)
		var/zone_normal_name
		switch(zone)
			if(LIMB_LEFT_ARM)
				zone_normal_name = "left arm"
			if(LIMB_RIGHT_ARM)
				zone_normal_name = "right arm"
			if(LIMB_LEFT_LEG)
				zone_normal_name = "left leg"
			if(LIMB_RIGHT_LEG)
				zone_normal_name = "right leg"
			else
				zone_normal_name = zone
		var/armor = run_armor_check(zone, "melee", "Your armor has protected your [zone_normal_name].", "Your armor has softened the blow to your [zone_normal_name].", armor_penetration = O.throwforce*(speed/5)*O.sharpness)
		if(armor < 2)
			var/damage = run_armor_absorb(zone, "melee", O.throwforce*(speed/5))
			apply_damage(damage, dtype, zone, armor, O.is_sharp(), O)

		// Begin BS12 momentum-transfer code.

		var/client/assailant = directory[ckey(O.fingerprintslast)]
		var/mob/M

		if(assailant && assailant.mob && istype(assailant.mob,/mob))
			M = assailant.mob

		if(speed >= EMBED_THROWING_SPEED)
			var/obj/item/weapon/W = O
			var/momentum = speed/2

			visible_message("<span class='warning'>[src] staggers under the impact!</span>","<span class='warning'>You stagger under the impact!</span>")
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)

			if(istype(W.loc,/mob/living) && W.sharpness_flags & SHARP_TIP) //Projectile is embedded and suitable for pinning.

				if(!istype(src,/mob/living/carbon/human)) //Handles embedding for non-humans and simple_animals.
					O.forceMove(src)
					src.embedded += O

				var/turf/T = near_wall(dir,2)

				if(T)
					src.forceMove(T)
					visible_message("<span class='warning'>[src] is pinned to the wall by [O]!</span>","<span class='warning'>You are pinned to the wall by [O]!</span>")
					src.anchored = 1
					src.pinned += O

		//Log stuf!

		if(!O.fingerprintslast)
			return
		var/throwByName = "an unknown inanimate object"
		if(M)
			throwByName = M.name
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>Hit [src.name] ([src.ckey]) with a thrown [O] (speed: [speed])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been hit with a thrown [O], last touched by [throwByName] ([assailant.ckey]) (speed: [speed])</font>")

		if(!src.isDead() && src.ckey) //Message admins if the hit mob is alive and has a ckey
			msg_admin_attack("[src.name] ([src.ckey]) was hit by a thrown [O], last touched by [throwByName] ([assailant.ckey]) (speed: [speed]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")

		if(!iscarbon(M))
			src.LAssailant = null
		else
			src.LAssailant = M

/*
	Ear and eye protection

	Some mobs have built-in ear or eye protection, mobs that can wear equipment may account their eye/ear wear into this proc
*/

//earprot(): retuns 0 for no protection, 1 for full protection (no ears, earmuffs, etc)
/mob/living/proc/earprot()
	return 0

//eyecheck(): retuns 0 for no protection, 1 for partial protection, 2 for full protection
//EYECHECK_NO_PROTECTION, EYECHECK_PARTIAL_PROTECTION, EYECHECK_FULL_PROTECTION

/mob/living/proc/eyecheck()
	return EYECHECK_NO_PROTECTION


//BITES
/mob/living/bite_act(mob/living/carbon/human/M as mob)
	var/damage = rand(1, 5)

	if(M.organ_has_mutation(LIMB_HEAD, M_BEAK)) //Beaks = stronger bites
		damage += 4

	if(!damage)
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		visible_message("<span class='danger'>\The [M] has attempted to bite \the [src]!</span>")
		return 0

	playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
	src.visible_message("<span class='danger'>\The [M] has bitten \the [src]!</span>", "<span class='userdanger'>You were bitten by \the [M]!</span>")

	adjustBruteLoss(damage)
	return

//KICKS
/mob/living/kick_act(mob/living/carbon/human/M)
	//Pick a random usable foot to perform the kick with
	var/datum/organ/external/foot_organ = M.pick_usable_organ(LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT)

	M.delayNextAttack(20) //Kicks are slow

	if((M_CLUMSY in M.mutations) && prob(20)) //Kicking yourself (or being clumsy) = stun
		M.visible_message("<span class='notice'>\The [M] trips while attempting to kick \the [src]!</span>", "<span class='userdanger'>While attempting to kick \the [src], you trip and fall!</span>")
		M.Knockdown(rand(1,10))
		return

	var/stomping = 0
	var/attack_verb = "kicks"

	if(M.size > size && !flying) //On the ground, the kicker is bigger than/equal size of the victim = stomp
		stomping = 1

	var/damage = rand(0,7)

	if(stomping) //Stomps = more damage and armor bypassing
		damage += rand(0,7)
		attack_verb = "stomps on"
	else if(M.reagents && M.reagents.has_reagent(GYRO))
		damage += rand(0,4)
		attack_verb = "roundhouse kicks"

	if(!damage)
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		visible_message("<span class='danger'>\The [M] attempts to kick \the [src]!</span>")
		return 0

	//Handle shoes
	var/obj/item/clothing/shoes/S = M.shoes
	if(istype(S))
		damage += S.bonus_kick_damage
		S.on_kick(M, src)
	else if(M.organ_has_mutation(foot_organ, M_TALONS)) //Not wearing shoes and having talons = bonus 1-6 damage
		damage += rand(1,6)

	playsound(loc, "punch", 30, 1, -1)

	visible_message("<span class='danger'>\The [M] [attack_verb] \the [src]!</span>", "<span class='userdanger'>\The [M] [attack_verb] you!</span>")

	if(M.size != size) //The bigger the kicker, the more damage
		damage = max(damage + (rand(1,5) * (1 + M.size - size)), 0)

	adjustBruteLoss(damage)

/mob/living/proc/near_wall(var/direction,var/distance=1)
	var/turf/T = get_step(get_turf(src),direction)
	var/turf/last_turf = src.loc
	var/i = 1

	while(i>0 && i<=distance)
		if(T.density) //Turf is a wall!
			return last_turf
		i++
		last_turf = T
		T = get_step(T,direction)

	return 0

// End BS12 momentum-transfer code.
//Mobs on Fire
/mob/living/proc/IgniteMob()
	if(fire_stacks > 0 && !on_fire)
		on_fire = 1
		set_light(src.light_range + 3)
		update_fire()
		return 1
	else
		return 0

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
		set_light(src.light_range - 3)
		update_fire()

/mob/living/proc/update_fire()
	return

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
	fire_stacks = Clamp(fire_stacks + add_fire_stacks, -20, 20)

/mob/living/proc/handle_fire()
	if((flags & INVULNERABLE) && on_fire)
		extinguish()
	if(fire_stacks < 0)
		fire_stacks++ //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return 1

	var/oxy=0
	var/turf/T=loc
	if(istype(T))
		var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
		if(G)
			oxy = G.molar_density("oxygen")
	if(oxy < (1 / CELL_VOLUME) || fire_stacks <= 0)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return 1
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1,surfaces=1)

/mob/living/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(mutations.Find(M_UNBURNABLE))
		return

	adjust_fire_stacks(0.5)
	IgniteMob()

//Mobs on Fire end
