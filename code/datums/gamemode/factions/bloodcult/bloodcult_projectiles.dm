
//////////////////////////////
//                          //
//   PERFORATING BLADE      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //Used when a filled soul blade performs a perforation
//////////////////////////////

/obj/item/projectile/soulbullet
	name = "soul blade"
	icon = 'icons/obj/cult_64x64.dmi'
	icon_state = "soulbullet"
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -10 * PIXEL_MULTIPLIER
	damage = 30//Only affects obj/turf. Mobs take a regular hit from the sword.
	phase_type = PROJREACT_MOBS
	penetration = -1
	fire_sound = null
	mouse_opacity = 1
	var/turf/secondary_target = null
	var/obj/item/weapon/melee/soulblade/blade = null
	var/mob/living/simple_animal/shade/shade = null
	var/redirected = 0
	var/leave_shadows = -1
	var/matrix/shadow_matrix = null

/obj/item/projectile/soulbullet/Destroy()
	var/turf/T = get_turf(src)
	if (T)
		if (blade)
			blade.forceMove(T)
	blade = null
	shade = null
	..()

/obj/item/projectile/soulbullet/OnFired(var/proj_target = original)
	target = get_turf(proj_target)
	if (!secondary_target)
		secondary_target = target
	if (!shade)
		icon_state = "soulbullet-empty"
	dist_x = abs(target.x - starting.x)
	dist_y = abs(target.y - starting.y)
	override_starting_X = starting.x
	override_starting_Y = starting.y
	override_target_X = target.x
	override_target_Y = target.y
	if (target.x > starting.x)
		dx = EAST
	else
		dx = WEST
	if (target.y > starting.y)
		dy = NORTH
	else
		dy = SOUTH
	if(dist_x > dist_y)
		error = dist_x/2 - dist_y
	else
		error = dist_y/2 - dist_x
	if (target!=secondary_target)
		target_angle = round(Get_Angle(target,secondary_target))
		blade.dir = get_dir(target,secondary_target)
	else
		target_angle = round(Get_Angle(starting,target))
		blade.dir = get_dir(starting,target)
	shadow_matrix = turn(matrix(),target_angle+45)
	transform = shadow_matrix
	//var/matrix/base_matrix = turn(matrix(),target_angle)
	//var/image/I = image('icons/obj/cult_64x64.dmi',"[icon_state]_spin")
	//I.transform = base_matrix
	if (shade)
		icon_state = "soulbullet_spin"
		plane = HUD_PLANE
		layer = ABOVE_HUD_LAYER
	else
		icon_state = "soulbullet-empty_spin"
	spawn(5)
		leave_shadows = 0
		/*
		if( !("[icon_state]_angle[target_angle]" in bullet_master) )
			var/image/I = new('icons/obj/cult_64x64.dmi',"[icon_state]")
			//I.transform = base_matrix
			bullet_master["[icon_state]_angle[target_angle]"] = I
		src.icon = bullet_master["[icon_state]_angle[target_angle]"]
		*/
		if (shade)
			icon_state = "soulbullet"
		else
			icon_state = "soulbullet-empty"
	return 1

/obj/item/projectile/soulbullet/bresenham_step(var/distA, var/distB, var/dA, var/dB)
	if (shade && leave_shadows >= 0)
		leave_shadows++
		if ((leave_shadows%3)==0)
			anim(target = loc, a_icon = 'icons/obj/cult_64x64.dmi', flick_anim = "soulblade-shadow", lay = NARSIE_GLOW, offX = pixel_x, offY = pixel_y, plane = LIGHTING_PLANE, trans = shadow_matrix)
	if(..())
		return 2
	else
		return 0

/obj/item/projectile/soulbullet/to_bump(var/atom/A)
	if (shade)
		if (ismob(A))
			var/mob/M = A
			if (!iscultist(M))
				A.attackby(blade,shade)
			else if (!M.get_active_hand())//cultists can catch the blade on the fly
				blade.forceMove(loc)
				blade.attack_hand(M)
				blade = null
				qdel(src)
		else
			A.attackby(blade,shade)
	else
		if (ismob(A))
			var/mob/M = A
			if (!iscultist(M))
				A.hitby(blade)
		else
			A.hitby(blade)
	if(isliving(A))
		forceMove(get_step(loc,dir))
		bump_original_check()
	else
		..()

/obj/item/projectile/soulbullet/bump_original_check()
	if (loc == target && !redirected)
		redirect()

/obj/item/projectile/soulbullet/reset()
	..()
	secondary_target = target


/obj/item/projectile/soulbullet/proc/redirect()
	redirected = 1
	projectile_speed = 0.66
	if (target == secondary_target)
		return
	starting = target
	target = secondary_target
	dist_x = abs(target.x - starting.x)
	dist_y = abs(target.y - starting.y)
	override_starting_X = starting.x
	override_starting_Y = starting.y
	override_target_X = target.x
	override_target_Y = target.y
	if (target.x > starting.x)
		dx = EAST
	else
		dx = WEST
	if (target.y > starting.y)
		dy = NORTH
	else
		dy = SOUTH
	if(dist_x > dist_y)
		error = dist_x/2 - dist_y
	else
		error = dist_y/2 - dist_x

/obj/item/projectile/soulbullet/cultify()
	return


/obj/item/projectile/soulbullet/Cross(var/atom/movable/mover, var/turf/target, var/height=1.5, var/air_group = 0)
	if(istype(mover, /obj/item/projectile))
		if (prob(30))//less likely to be hit when perforating
			return 0
	return ..()

/obj/item/projectile/soulbullet/attackby(var/obj/item/I, var/mob/user)
	if (blade)
		return blade.attackby(I,user)

/obj/item/projectile/soulbullet/hitby(var/atom/movable/AM)
	if (blade)
		return blade.hitby(AM)

/obj/item/projectile/soulbullet/bullet_act(var/obj/item/projectile/P)
	if (blade)
		return blade.bullet_act(P)

//////////////////////////////
//                          //
//        BLOOD SLASH       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //Used when a cultist swings a soul blade that has at least 5 blood in it.
//////////////////////////////

/obj/item/projectile/bloodslash
	name = "soul blade"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "bloodslash"
	damage = 15
	damage_type = BURN
	flag = "energy"
	custom_impact = 1

/obj/item/projectile/bloodslash/Destroy()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/effects/forge_over.ogg', 100, 1)
	if (!locate(/obj/effect/decal/cleanable/blood/splatter) in T)
		var/obj/effect/decal/cleanable/blood/splatter/S = new (T)//splash
		S.amount = 1
	..()

/obj/item/projectile/bloodslash/to_bump(var/atom/A)
	if (isliving(A))
		forceMove(A.loc)
		var/mob/living/M = A
		if (!iscultist(M))
			..()
	qdel(src)

/obj/item/projectile/bloodslash/on_hit(var/atom/target, var/blocked = 0)
	if (isliving(target))
		var/mob/living/M = target
		if(M.flags & INVULNERABLE)
			return 0
		if (iscultist(M))
			return 0
		if (M.stat == DEAD)
			return 0
		to_chat(M, "<span class='warning'>You feel a searing heat inside of you!</span>")
	return 1

/obj/item/projectile/bloodslash/cultify()
	return


//////////////////////////////
//                          //
//        BLOOD NAIL        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //Used when a cultist throws a blood dagger
//////////////////////////////

/obj/item/projectile/blooddagger
	name = "blood dagger"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "blood_dagger"
	damage = 5
	flag = "energy"
	custom_impact = 1
	projectile_speed = 0.66
	var/absorbed = 0
	var/stacks = 0

/obj/item/projectile/blooddagger/Destroy()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/effects/forge_over.ogg', 100, 1)
	if (!absorbed && !locate(/obj/effect/decal/cleanable/blood/splatter) in T)
		var/obj/effect/decal/cleanable/blood/splatter/S = new (T)//splash
		if (color)
			S.basecolor = color
			S.update_icon()
	..()

/obj/item/projectile/blooddagger/to_bump(var/atom/A)
	if (isliving(A))
		forceMove(A.loc)
		var/mob/living/M = A
		if (!iscultist(M))
			setDensity(FALSE)
			invisibility = 101
			kill_count = 0
			var/obj/effect/overlay/bloodnail/nail = new (A.loc)
			nail.transform = transform
			if (color)
				nail.color = color
			else
				nail.color = DEFAULT_BLOOD
			if(isliving(A))
				nail.stick_to(A)
				var/mob/living/L = A
				L.take_overall_damage(damage,0)
				to_chat(L, "<span class='warning'>\The [src] stabs your body, sticking you in place.</span>")
				to_chat(L, "<span class='danger'>Resist or click the nail to dislodge it.</span>")
			else if(loc)
				var/turf/T = get_turf(src)
				nail.stick_to(T,get_dir(src,A))
			bullet_die()
			return
		else if (ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/reagent/blood/B = get_blood(H.vessel)
			if (B && !(H.species.flags & NO_BLOOD))
				H.vessel.add_reagent(BLOOD, 5 + stacks * 5)
				H.vessel.update_total()
				to_chat(H, "<span class='notice'>[firer ? "\The [firer]'s" : "The"] [src] enters your body painlessly, irrigating your vessels with some fresh blood.</span>")
			else
				to_chat(H, "<span class='notice'>[firer ? "\The [firer]'s" : "The"] [src] enters your body, but you have no vessels to irrigate.</span>")
			absorbed = 1
			playsound(H, 'sound/weapons/bloodyslice.ogg', 30, 1)

	qdel(src)

/obj/item/projectile/blooddagger/on_hit(var/atom/target, var/blocked = 0)
	if (isliving(target))
		var/mob/living/M = target
		if(M.flags & INVULNERABLE)
			return 0
		if (iscultist(M))
			return 0
		if (M.stat == DEAD)
			return 0
	return 1


/obj/item/projectile/blooddagger/bump_original_check()
	if(!bumped)
		if(loc == get_turf(original))
			if(!(original in permutated))
				to_bump(original)

/obj/item/projectile/blooddagger/cultify()
	return


/obj/effect/overlay/bloodnail
	name = "blood nail"
	desc = "A pointy red nail, appearing to pierce not through what it rests upon, but through the fabric of reality itself."
	icon = 'icons/effects/effects.dmi'
	icon_state = "bloodnail"
	anchored = 1
	density = 0
	plane = ABOVE_HUMAN_PLANE
	layer = CLOSED_CURTAIN_LAYER
	var/atom/stuck_to = null
	var/duration = 100

/obj/effect/overlay/bloodnail/New()
	..()
	pixel_x = rand(-4, 4) * PIXEL_MULTIPLIER
	pixel_y = rand(-4, 4) * PIXEL_MULTIPLIER

/obj/effect/overlay/bloodnail/Destroy()
	if(stuck_to)
		unlock_atom(stuck_to)
	stuck_to = null
	..()

/obj/effect/overlay/bloodnail/cultify()
	return

/obj/effect/overlay/bloodnail/proc/stick_to(var/atom/A, var/side = null)
	pixel_x = rand(-4, 4) * PIXEL_MULTIPLIER
	pixel_y = rand(-4, 4) * PIXEL_MULTIPLIER
	playsound(A, 'sound/items/metal_impact.ogg', 30, 1)
	var/turf/T = get_turf(A)
	playsound(T, 'sound/weapons/hivehand_empty.ogg', 75, 1)

	if(isliving(A) && !isspace(T))//can't nail people down unless there's a turf to nail them to.
		stuck_to = A
		visible_message("<span class='warning'>\the [src] nails \the [A] to \the [T].</span>")
		lock_atom(A, /datum/locking_category/buckle)

	spawn(duration)
		qdel(src)


/obj/effect/overlay/bloodnail/attack_hand(var/mob/user)
	if (do_after(user,src,15))
		unstick()

/obj/effect/overlay/bloodnail/proc/unstick()
	if(stuck_to)
		unlock_atom(stuck_to)
	qdel(src)
