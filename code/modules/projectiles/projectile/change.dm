/obj/item/projectile/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	flag = "energy"
	var/changetype=null
	fire_sound = 'sound/weapons/radgun.ogg'

/obj/item/projectile/change/on_hit(var/atom/change)
	var/type = changetype
	spawn(1)//fixes bugs caused by the target ceasing to exist before the projectile has died.
		wabbajack(change,type)


/obj/item/projectile/change/proc/wabbajack(var/mob/living/M,var/type)
	if(istype(M, /mob/living) && M.stat != DEAD)
		if(ismanifested(M))
			visible_message("<span class='caution'>The bolt of change doesn't seem to affect [M] in any way.</span>")
			return
		var/mob/living/new_mob
		// Random chance of fucking up
		if(type!=null && prob(10))
			type = null

		if(ishuman(M) && type == null)
			score["random_soc"]++ //Just for scorekeeping. Humans that were hit by a random-type bolt.

		var/randomize = type == null? pick(available_staff_transforms):type

		switch(randomize)
			if(SOC_MONKEY)
				new_mob = M.monkeyize()
			if(SOC_MARTIAN)
				new_mob = M.Martianize()
			if(SOC_CYBORG)
				new_mob = M.Robotize()
			if(SOC_MOMMI) //It really makes you think.
				new_mob = M.MoMMIfy()
			if(SOC_SLIME)
				new_mob = M.slimeize()
			if(SOC_XENO)
				new_mob = M.Alienize()
			if(SOC_HUMAN)
				new_mob = M.Humanize()
			if(SOC_CATBEAST)
				new_mob = M.Humanize("Tajaran")
			if(SOC_FRANKENSTEIN)
				new_mob = M.Frankensteinize()
			else
				return
		if(new_mob)
			var/mob/living/carbon/human/H = new_mob
			to_chat(new_mob, "<B>Your form morphs into that of a [(istype(H) && H.species && H.species.name) ? H.species.name : randomize].</B>")
			return new_mob

/obj/item/projectile/polymorph
	name = "bolt of polymorph"
	icon_state = "ice_1"
	damage = 0
	nodamage = TRUE
	flag = "energy"
	fire_sound = 'sound/weapons/radgun.ogg'
	var/status = MAJOR

/obj/item/projectile/polymorph/on_hit(var/atom/hit)
	if(hit == firer)
		var/mob/living/M = new /mob/living/simple_animal/pollywog(firer.loc)
		M.ckey = firer.ckey
		firer.Premorph()
		qdel(firer)
		return
	var/stat = status
	bullet_die()
	polymorph(hit,stat)

/obj/item/projectile/polymorph/proc/polymorph(var/mob/living/M, var/status)
	if(istype(M) && M.stat != DEAD)
		if(ismanifested(M))
			visible_message("<span class='caution'>The bolt of change doesn't seem to affect [M] in any way.</span>")
			return

		var/list/available_mobs = list()
		var/time_to_untransmog = 0
		var/kill = FALSE
		switch(status)
			if(MINOR)
				available_mobs = minor_mobs - (boss_mobs+blacklisted_mobs)
				time_to_untransmog = rand(10 SECONDS, 20 SECONDS)
			if(MAJOR)
				available_mobs = major_mobs - (boss_mobs+blacklisted_mobs)
				time_to_untransmog = rand(16 SECONDS, 32 SECONDS)
			if(DEFECTIVE)
				available_mobs = (major_mobs + corrupt_mobs) - (boss_mobs+blacklisted_mobs)
				kill = TRUE

		M.transmogrify(pick(available_mobs), kill_on_death = kill)
		if(time_to_untransmog)
			spawn(time_to_untransmog)
				M.completely_untransmogrify()
