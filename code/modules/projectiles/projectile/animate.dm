
/obj/item/projectile/animate
	name = "bolt of animation"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"

/obj/item/projectile/animate/to_bump(var/atom/change)
	if(istype(change, /obj/item) || istype(change, /obj/structure) && !is_type_in_list(change, protected_objects))
		change.animationBolt(firer)
	else if(istype(change, /mob/living/simple_animal/hostile/mimic/copy))
		var/mob/living/simple_animal/hostile/mimic/copy/targeted = change
		targeted.ChangeOwner(firer)
	else if(istype(change, /mob/living/simple_animal/hostile/mannequin))
		var/mob/living/simple_animal/hostile/mannequin/targeted = change
		targeted.ChangeOwner(firer)
	..()
