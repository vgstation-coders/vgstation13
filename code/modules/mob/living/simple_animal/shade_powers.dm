/mob/living/simple_animal/shade/proc/give_blade_powers()
	if (!istype(loc, /obj/item/weapon/melee/soulblade))
		return
	if (client)
		client.CAN_MOVE_DIAGONALLY = 1
		client.screen += list(
			gui_icons.soulblade_bgLEFT,
			gui_icons.soulblade_coverLEFT,
			gui_icons.soulblade_bloodbar,
			)
	var/obj/item/weapon/melee/soulblade/SB = loc
	var/datum/control/new_control = new /datum/control/soulblade(src, SB)
	control_object.Add(new_control)
	new_control.take_control()
	add_spell(new /spell/soulblade/blade_kinesis, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
	add_spell(new /spell/soulblade/blade_spin, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
	add_spell(new /spell/soulblade/blade_perforate, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)



/mob/living/simple_animal/shade/proc/remove_blade_powers()//this should always fire when the shade gets removed from the blade, such as when it gets destroyed
	if (client)
		client.CAN_MOVE_DIAGONALLY = 0
		client.screen -= list(
			gui_icons.soulblade_bgLEFT,
			gui_icons.soulblade_coverLEFT,
			gui_icons.soulblade_bloodbar,
			)
	for(var/spell/soulblade/spell_to_remove in spell_list)
		remove_spell(spell_to_remove)

/spell/soulblade
	panel = "Cult"
	override_base = "cult"
	user_type = USER_TYPE_CULT
	var/blood_cost = 0

/spell/soulblade/cast_check(skipcharge = 0,mob/user = usr)
	var/obj/item/weapon/melee/soulblade/SB = user.loc
	if (SB.blood < blood_cost)
		to_chat(user, "<span class='danger'>You don't have enough blood left for this move.</span>")
		return 0
	return ..()

/spell/soulblade/after_cast(list/targets)
	..()
	var/obj/item/weapon/melee/soulblade/SB = holder.loc
	SB.blood = max(0,SB.blood-blood_cost)
	var/mob/shade = holder
	var/matrix/M = matrix()
	M.Scale(1,SB.blood/SB.maxblood)
	var/total_offset = (60 + (100*(SB.blood/SB.maxblood))) * PIXEL_MULTIPLIER
	shade.hud_used.mymob.gui_icons.soulblade_bloodbar.transform = M
	shade.hud_used.mymob.gui_icons.soulblade_bloodbar.screen_loc = "WEST,CENTER-[8-round(total_offset/WORLD_ICON_SIZE)]:[total_offset%WORLD_ICON_SIZE]"
	shade.hud_used.mymob.gui_icons.soulblade_coverLEFT.maptext = "[SB.blood]"

/spell/soulblade/blade_kinesis
	name = "Self Telekinesis"
	desc = "(1 BLOOD) Move yourself without the need of being held."
	hud_state = "souldblade_move"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 0
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

/spell/soulblade/blade_spin
	name = "Spin Slash"
	desc = "(5 BLOOD) Stop your momentum and cut in front of you."
	hud_state = "soulblade_spin"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 15
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

	blood_cost = 5

/spell/soulblade/blade_spin/choose_targets(var/mob/user = usr)
	var/obj/item/weapon/melee/soulblade/SB = user.loc
	if (!isturf(SB.loc) && !istype(SB.loc,/obj/item/projectile))
		return null
	var/turf/T = get_turf(SB)
	var/dir = SB.dir
	if (istype(T,/obj/item/projectile))
		var/obj/item/projectile/P = T
		dir = get_dir(P.starting,P.target)
	var/list/my_targets = list()
	for (var/atom/A in T)
		if (A == SB)
			continue
		if (istype(A,/atom/movable/lighting_overlay))
			continue
		if (ismob(A))
			var/mob/M = A
			if (!iscultist(M))
				my_targets += M
		else
			//BREAK EVERYTHING
			if (!istype(A, /obj/item/weapon/storage))
				my_targets += A
	for (var/atom/A in get_step(T,dir))
		if (istype(A,/atom/movable/lighting_overlay))
			continue
		if (ismob(A))
			var/mob/M = A
			if (!iscultist(M))
				my_targets += M
		else
			//BREAK EVERYTHING
			if (!istype(A, /obj/item/weapon/storage))
				my_targets += A

	return my_targets

/spell/soulblade/blade_spin/before_cast(var/list/targets, var/user)
	return targets

/spell/soulblade/blade_spin/cast(var/list/targets, var/mob/user)
	..()
	var/obj/item/weapon/melee/soulblade/SB = user.loc
	SB.throwing = 0
	if (istype(SB.loc,/obj/item/projectile))
		var/obj/item/projectile/P = SB.loc
		qdel(P)
	flick("soulblade-spin",SB)
	for (var/atom/A in targets)
		A.attackby(SB,user)

/spell/soulblade/blade_perforate
	name = "Perforate"
	desc = "(20 BLOOD) Hurl yourself through the air."
	hud_state = "soulblade_perforate"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 40
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

	blood_cost = 20

/spell/soulblade/blade_perforate/choose_targets(var/mob/user = usr)
	var/obj/item/weapon/melee/soulblade/SB = user.loc
	if (!isturf(SB.loc))
		return null
	return list(get_step(get_turf(SB),SB.dir))

/spell/soulblade/blade_perforate/before_cast(var/list/targets, var/user)
	return targets

/spell/soulblade/blade_perforate/cast(var/list/targets, var/mob/user)
	..()
	var/obj/item/weapon/melee/soulblade/blade = user.loc
	var/turf/starting = get_turf(blade)
	var/turf/target = targets[1]
	var/turf/second_target = target
	if (targets.len > 1)
		second_target = targets[2]
	var/obj/item/projectile/soulbullet/SB = new (starting)
	SB.original = target
	SB.target = target
	SB.current = starting
	SB.starting = starting
	SB.secondary_target = second_target
	SB.yo = target.y - starting.y
	SB.xo = target.x - starting.x
	SB.shade = user
	SB.blade = blade
	blade.forceMove(SB)
	SB.OnFired()
	SB.process()


/client/MouseDrop(src_object,over_object,src_location,over_location,src_control,over_control,params)
	if(!mob || !isshade(mob) || !istype(mob.loc,/obj/item/weapon/melee/soulblade))
		return ..()
	if(!isturf(src_location) || !isturf(over_location))
		return ..()
	if(src_location == over_location)
		return ..()
	var/spell/soulblade/blade_perforate/BP = locate() in mob.spell_list
	if (BP)
		BP.perform(mob,0,list(src_location,over_location))

/obj/item/projectile/soulbullet
	name = "soul blade"
	icon = 'icons/obj/cult_64x64.dmi'
	icon_state = "soulbullet"
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -10 * PIXEL_MULTIPLIER
	damage = 1//so we may trigger stuff that reacts to bullet damage, like welding fuel tanks
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

/obj/item/projectile/soulbullet/attackby(var/obj/item/I, var/mob/user)
	if (blade)
		return blade.attackby(I,user)

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