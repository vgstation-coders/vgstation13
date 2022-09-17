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
	if(istype(M) && M.stat != DEAD)
		if(ismanifested(M) || iscluwnebanned(M))
			visible_message("<span class='caution'>The bolt of change doesn't seem to affect [M] in any way.</span>")
			return
		// Random chance of fucking up
		if(type!=null && prob(10))
			type = null

		if(ishuman(M) && type == null)
			score.random_soc++ //Just for scorekeeping. Humans that were hit by a random-type bolt.

		var/randomize = type == null? pick(available_staff_transforms):type

		switch(randomize)
			if(SOC_MONKEY)
				M.monkeyize()
			if(SOC_MARTIAN)
				M.Martianize()
			if(SOC_CYBORG)
				M.Robotize()
			if(SOC_MOMMI) //It really makes you think.
				M.MoMMIfy()
			if(SOC_SLIME)
				M.slimeize()
			if(SOC_XENO)
				M.Alienize(pick("Hunter", "Sentinel"))
			if(SOC_HUMAN)
				M.Humanize()
			if(SOC_CATBEAST)
				M.Humanize("Tajaran")
			if(SOC_FRANKENSTEIN)
				M.Frankensteinize()
			else
				return
		var/mob/living/carbon/human/H = M
		if(istype(H) && H.species && H.species.name)
			to_chat(H, "<B>Your form morphs into that of a [H.species.name].</B>")
		else
			to_chat(M, "<B>Your form morphs into that of a [randomize].</B>")

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