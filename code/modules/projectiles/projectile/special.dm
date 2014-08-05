/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"


	on_hit(var/atom/target, var/blocked = 0)
		empulse(target, 1, 1)
		return 1


/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	flag = "bullet"


	on_hit(var/atom/target, var/blocked = 0)
		explosion(target, -1, 0, 2)
		return 1

/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	var/temperature = 300

	on_hit(var/atom/target, var/blocked = 0)//These two could likely check temp protection on the mob
		if(istype(target, /mob/living))
			var/mob/M = target
			M.bodytemperature = temperature
		return 1

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "smallf"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return

		sleep(-1) //Might not be important enough for a sleep(-1) but the sleep/spawn itself is necessary thanks to explosions and metoerhits

		if(src)//Do not add to this if() statement, otherwise the meteor won't delete them
			if(A)

				A.meteorhit(src)
				playsound(get_turf(src), 'sound/effects/meteorimpact.ogg', 40, 1)

				for(var/mob/M in range(10, src))
					if(!M.stat && !istype(M, /mob/living/silicon/ai))\
						shake_camera(M, 3, 1)
				del(src)
				return 1
		else
			return 0

/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

	on_hit(var/atom/target, var/blocked = 0)
		var/mob/living/M = target
//		if(ishuman(target) && M.dna && M.dna.mutantrace == "plant") //Plantmen possibly get mutated and damaged by the rays.
		if(ishuman(target))
			var/mob/living/carbon/human/H = M
			if((H.species.flags & IS_PLANT) && (M.nutrition < 500))
				if(prob(15))
					M.apply_effect((rand(30,80)),IRRADIATE)
					M.Weaken(5)
					for (var/mob/V in viewers(src))
						V.show_message("\red [M] writhes in pain as \his vacuoles boil.", 3, "\red You hear the crunching of leaves.", 2)
				if(prob(35))
				//	for (var/mob/V in viewers(src)) //Public messages commented out to prevent possible metaish genetics experimentation and stuff. - Cheridan
				//		V.show_message("\red [M] is mutated by the radiation beam.", 3, "\red You hear the snapping of twigs.", 2)
					if(prob(80))
						randmutb(M)
						domutcheck(M,null)
					else
						randmutg(M)
						domutcheck(M,null)
				else
					M.adjustFireLoss(rand(5,15))
					M.show_message("\red The radiation beam singes you!")
				//	for (var/mob/V in viewers(src))
				//		V.show_message("\red [M] is singed by the radiation beam.", 3, "\red You hear the crackle of burning leaves.", 2)
		else if(istype(target, /mob/living/carbon/))
		//	for (var/mob/V in viewers(src))
		//		V.show_message("The radiation beam dissipates harmlessly through [M]", 3)
			M.show_message("\blue The radiation beam dissipates harmlessly through your body.")
		else
			return 1

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

	on_hit(var/atom/target, var/blocked = 0)
		var/mob/M = target
//		if(ishuman(target) && M.dna && M.dna.mutantrace == "plant") //These rays make plantmen fat.
		if(ishuman(target)) //These rays make plantmen fat.
			var/mob/living/carbon/human/H = M
			if((H.species.flags & IS_PLANT) && (M.nutrition < 500))
				M.nutrition += 30
		else if (istype(target, /mob/living/carbon/))
			M.show_message("\blue The radiation beam dissipates harmlessly through your body.")
		else
			return 1


/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

	on_hit(var/atom/target, var/blocked = 0)
		if(ishuman(target))
			var/mob/living/carbon/human/M = target
			M.adjustBrainLoss(20)
			M.hallucination += 20

/obj/item/projectile/thrownbolas
	name ="bolas"
	icon_state= "bolas_thrown"
	damage = 3
	kill_count = 50
	damage_type = BRUTE
	flag = "bullet"
	anchored = 0 //it's an object, can still be affected by singularity

	on_hit(var/atom/target, var/blocked = 0)
		log_admin("[src] has hit an atom of [target]")
		if(isliving(target) && target != usr) //if the target is a live creature other than the thrower
			var/mob/living/M = target
			if(ishuman(M)) //if they're a human species
				var/mob/living/carbon/human/H = M
				if(H.m_intent == "run") //if they're set to run (though not necessarily running at that moment)
					if(prob(70)) //this probability is up for change and mostly a placeholder - Comic
						step(H, H.dir)
						H << "\blue Your legs have been tangled!"
						viewers(H) << "\red [H] was tripped by the bolas!"
						H.Stun(5) //used instead of setting damage in vars to avoid non-human targets being affected
						H.Weaken(10)
						H.legcuffed = new /obj/item/weapon/legcuffs/bolas(H) //applies legcuff properties inherited through legcuffs
						H.update_inv_legcuffed()
						if (!H.legcuffed) //if it triggers, but they aren't cuffed because of immunity
							OnDeath() //spawn the item anyways
						else
							qdel(src) //delete the projectile
				else if(H.legcuffed) //if the target is already legcuffed (has to be walking)
					OnDeath()
				else //walking, but uncuffed, or the running prob(70) failed
					H << "\blue You stumble over the thrown bolas"
					step(H, H.dir)
					H.m_intent = "walk"
					OnDeath()
			else
				M.Stun(2) //minor stun damage to anything not human
				OnDeath()
		else
			OnDeath()

	OnDeath()
		log_admin(shot_from)
		if(shot_from == /obj/item/weapon/legcuffs/bolas) //if it's thrown, we want it to respawn the item. Mechs don't do this to avoid spam and infinite bolas works
			// log_admin("Bolas created at [get_turf(src)]")
			var /obj/item/weapon/legcuffs/bolas/B = new /obj/item/weapon/legcuffs/bolas
			B.loc = get_turf(src)
		qdel(src)

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return
		if(src)
			if(A)
				if(istype(A, /mob/living)) //if it hits something living, we want to go to on_hit
					on_hit(A)
				else
				// log_admin("Currently travelling in [get_dir(starting, original)], at location [src.loc]")
				// step(src, turn(get_dir(starting, original), 180)) //reverses object by finding direction from its starting position to its target
					OnDeath() //it deletes the projectile and decides to spawn the bolas
				return 1
		else
			return 0

/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = "energy"
	damage = 15
	damage_type = BRUTE
	flag = "energy"
	var/range = 2

obj/item/projectile/kinetic/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure < 50)
		name = "full strength kinetic force"
		damage = 30
	..()

/* wat - N3X
/obj/item/projectile/kinetic/Range()
	range--
	if(range <= 0)
		new /obj/item/effect/kinetic_blast(src.loc)
		qdel(src)
*/

/obj/item/projectile/kinetic/on_hit(var/atom/target, var/blocked = 0)
	if(!loc) return
	var/turf/target_turf = get_turf(target)
	//testing("Hit [target.type], on [target_turf.type].")
	if(istype(target_turf, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = target_turf
		M.GetDrilled()
	new /obj/item/effect/kinetic_blast(target_turf)
	..(target,blocked)

/obj/item/projectile/kinetic/Bump(atom/A as mob|obj|turf|area)
	if(!loc) return
	if(A == firer)
		loc = A.loc
		return

	if(src)//Do not add to this if() statement, otherwise the meteor won't delete them

		if(A)
			var/turf/target_turf = get_turf(A)
			//testing("Bumped [A.type], on [target_turf.type].")
			if(istype(target_turf, /turf/unsimulated/mineral))
				var/turf/unsimulated/mineral/M = target_turf
				M.GetDrilled()
			// Now we bump as a bullet, if the atom is a non-turf.
			if(!isturf(A))
				..(A)
			//qdel(src) // Comment this out if you want to shoot through the asteroid, ERASER-style.
			returnToPool(src)
			return 1
	else
		//qdel(src)
		returnToPool(src)
		return 0

/obj/item/effect/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = 4.1

/obj/item/effect/kinetic_blast/New()
	spawn(4)
		del(src)