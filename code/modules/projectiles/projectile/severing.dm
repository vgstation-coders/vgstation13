/obj/item/projectile/severing
	name = "bolt of severing"
	icon_state = "red_laser"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"
	var/sever = 1 //0 for sectumsempra(cutting, can cause bleeding), 1 for diffindo(hacks off arms/legs, acts like 0 on nonhumans)
	var/obj/item/weapon/gun/energy/severwand/SW = null

/obj/item/projectile/severing/OnFired()
	SW = shot_from
	sever = SW.sever
	if(sever)
		name = "bolt of severing"
		color = "#FF0000"
	else
		name = "bolt of slashing"
		color = "#AA2200"

/obj/item/projectile/severing/on_hit(var/atom/target, var/blocked = 0)
	if(isliving(target))
		var/mob/living/L = target
		if(L.flags & INVULNERABLE)
			return 0
		if(sever)
			if(prob(23))
				return 0
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				var/datum/organ/external/O = null
				switch(def_zone)
					if("head")
						O = H.organs_by_name[(pick("l_arm","r_arm","l_hand","r_hand"))]
					if("chest")
						O = H.organs_by_name[(pick("l_arm","r_arm","l_hand","r_hand","l_leg","r_leg","l_foot","r_foot"))]
					if("groin")
						O = H.organs_by_name[(pick("l_leg","r_leg","l_foot","r_foot"))]
					else
						O = H.get_organ(def_zone)
				if(!(O.status & ORGAN_DESTROYED))
					O.droplimb(1,1,1)
					playsound(H.loc, 'sound/weapons/bloodyslice.ogg', 65, 0)
				else
					H << "<span class='notice'>You count yourself lucky as the bolt zips past where your [O] should be..</span>"
			else
				L.adjustBruteLoss(20)
				playsound(L.loc, 'sound/weapons/bloodyslice.ogg', 50, 0)
		else
			L.adjustBruteLoss(6)
			playsound(L.loc, 'sound/weapons/bladeslice.ogg', 50, 0)
	return 1