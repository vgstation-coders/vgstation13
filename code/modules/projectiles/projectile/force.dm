/obj/item/projectile/forcebolt
	name = "force bolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ice_1"
	damage = 25
	flag = "energy"
	fire_sound = 'sound/weapons/radgun.ogg'
	weaken = 1
	var/forceprob = 50
	var/throw_distance = 10
	var/throwdir

/obj/item/projectile/forcebolt/strong
	name = "force bolt"
	damage = 30
	weaken = 2
	forceprob = 75
	throw_distance = 15

/obj/item/projectile/forcebolt/on_hit(var/atom/target, var/blocked = 0)
	if(!throwdir)
		throwdir = get_dir(firer,target)
	if(prob(forceprob))
		if(isliving(target))
			..()
			to_chat(target, "<span class='warning'>The force knocks you off your feet!</span>")
	if(isatommovable(target))
		var/atom/movable/AM = target
		AM.throw_at(get_edge_target_turf(target, throwdir),throw_distance,1)
	return 1


/obj/item/projectile/forcebolt/strong/on_hit(var/atom/target, var/blocked = 0)
	throwdir = get_dir(firer,target)
	for(var/mob/M in range(1, target))
		if(M == firer)
			continue
		..(M, blocked)
	return 1