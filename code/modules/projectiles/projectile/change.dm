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


/obj/item/projectile/change/proc/wabbajack(var/mob/living/M,var/type) //WHY: as mob in living_mob_list
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
