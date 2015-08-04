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

/obj/item/projectile/severing/on_hit(var/atom/target,var/blocked)
	if(!isliving(target)) return 0
	var/mob/living/L = target
	if(L.flags & INVULNERABLE) return 0
	if(sever) //Diffindo: severs limbs
		if(prob(23)) return 0 //Diffindo has 23% chance to miss
		if(ishuman(L)) //Limb removal only implemented for humans
			var/mob/living/carbon/human/H = L
			var/datum/organ/external/O = null
			switch(def_zone) //Select target limb, semi-randomly if player isn't aiming at one
				if("head")  O = H.organs_by_name[pick("l_arm","r_arm","l_hand","r_hand")]
				if("chest") O = H.organs_by_name[pick("l_arm","r_arm","l_hand","r_hand","l_leg","r_leg","l_foot","r_foot")]
				if("groin") O = H.organs_by_name[pick("l_leg","r_leg","l_foot","r_foot")]
				else        O = H.get_organ(def_zone) //They're targeting a specific limb, use it
			if(!(O.status & ORGAN_DESTROYED)) O.droplimb(1,1,1) //Slice it off
			else H << "<span class='notice'>You count yourself lucky as the bolt zips past where your [O] should be..</span>"
		else L.adjustBruteLoss(20) //Not a human: just damage them
	else L.adjustBruteLoss(6) //Sectumsempra: plain damage
	playsound(get_turf(L), 'sound/weapons/bladeslice.ogg', 50, 0)
	return 1
