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
		if(ismanifested(M) || iscluwnebanned(M))
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
				new_mob = M.Alienize(pick("Hunter", "Sentinel"))
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

/obj/item/projectile/zwartepiet
	name = "bolt of zwarte piet"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	flag = "energy"
	var/changetype=null
	fire_sound = 'sound/weapons/radgun.ogg'

/obj/item/projectile/zwartepiet/on_hit(var/atom/pietje)
	var/type = changetype
	spawn(1)
		zwartepietenate(pietje,type)

/obj/item/projectile/zwartepiet/proc/zwartepietenate(var/mob/living/carbon/human/M,var/type) //WHY: as mob in living_mob_list
	if(istype(M, /mob/living) && M.stat != DEAD)
		M.zwartepietify()
		to_chat(M, "<B>You feel jovial!</B>")

/obj/item/projectile/mouse
	name = "mouser pistol shot"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	flag = "energy"
	fire_sound = 'sound/effects/stealthoff.ogg'

/obj/item/projectile/mouse/on_hit(var/atom/change)
	if(!iscarbon(change))
		return
	var/mob/tomouse = change
	tomouse.audible_scream()
	spawn(1)//fixes bugs caused by the target ceasing to exist before the projectile has died.
		var/mob/M = tomouse.transmogrify(/mob/living/simple_animal/mouse/transmog)
		M.SetStunned(5)
		M.Jitter(5)
		to_chat(M,"<span class='sinister'>You are dazed by the transformation!</span>")
		to_chat(M,"<span class='danger'>You are imprisoned by this tiny body. If you can die, you will change back!</span>")