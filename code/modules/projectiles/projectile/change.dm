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


/obj/item/projectile/change/proc/wabbajack(var/mob/living/M,var/type) //WHY: as mob in living_mob_lis
	if(istype(M, /mob/living) && M.stat != DEAD)
		if(istype(M, /mob/living/carbon/human/manifested)) // DEEEEEEEEEEEEEEITY
			visible_message("<span class='caution'>The bolt of change doesn't seem to affect [M] in any way.</span>")
			return
		var/mob/living/new_mob
		// Random chance of fucking up
		if(type!=null && prob(10))
			type = null

		var/randomize = type == null? pick(available_staff_transforms):type

		switch(randomize)
			if("monkey")
				new_mob = M.monkeyize()
			if("robot")
				new_mob = M.Robotize()
			if("mommi")
				new_mob = M.MoMMIfy()
			if("slime")
				new_mob = M.slimeize()
			if("xeno")
				new_mob = M.Alienize()
			if("human")
				new_mob = M.Humanize()
			if("furry")
				new_mob = M.Humanize("Tajaran")
			if("frankenstein")
				new_mob = M.Frankensteinize()
			else
				return
		if(new_mob)
			if(M.mind && M.mind.wizard_spells && M.mind.wizard_spells.len)
				for (var/spell/S in M.mind.wizard_spells)
					new_mob.spell_list += new S.type
			to_chat(new_mob, "<B>Your form morphs into that of a [randomize].</B>")
			return new_mob

