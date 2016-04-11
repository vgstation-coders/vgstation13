/obj/item/projectile/forcebolt
	name = "force bolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ice_1"
	damage = 25
	flag = "energy"
	fire_sound = 'sound/weapons/radgun.ogg'

/obj/item/projectile/forcebolt/strong
	name = "force bolt"

/obj/item/projectile/forcebolt/on_hit(var/atom/target, var/blocked = 0)

	var/obj/T = target
	var/throwdir = get_dir(firer,target)
	if(prob(50))
		if(istype(target, /mob/living/carbon/))
			var/mob/living/carbon/MM = target
			MM.apply_effect(1, WEAKEN)
			to_chat(MM, "<span class='warning'>The force knocks you off your feet!</span>")
	T.throw_at(get_edge_target_turf(target, throwdir),10,1)
	return 1


/obj/item/projectile/forcebolt/strong/on_hit(var/atom/target, var/blocked = 0)
	damage = 30
	// NONE OF THIS WORKS. DO NOT USE.
	var/throwdir = null

	for(var/mob/M in hearers(1, src))
		if(M == firer) continue
		if(M.loc != src.loc)
			throwdir = get_dir(src,target)
			if(prob(75))
				if(istype(M, /mob/living/carbon/))
					var/mob/living/carbon/MM = M
					MM.apply_effect(2, WEAKEN)
					to_chat(MM, "<span class='warning'>The force knocks you off your feet!</span>")
			M.throw_at(get_edge_target_turf(M, throwdir),15,1)
	return ..()
