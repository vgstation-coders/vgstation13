/obj/item/inflatable
	name = "inflatable"
	w_class = W_CLASS_MEDIUM
	icon = 'icons/obj/inflatable.dmi'
	starting_materials = list(MAT_PLASTIC = 2*CC_PER_SHEET_MISC)

	var/deploy_path = null

/obj/item/inflatable/attack_self(mob/user)
	if(!deploy_path)
		return
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	to_chat(user, "<span class='notice'>You inflate \the [src].</span>")
	var/obj/structure/inflatable/R = new deploy_path(user.loc)
	transfer_fingerprints_to(R)
	R.add_fingerprint(user)
	qdel(src)


/obj/item/inflatable/wall
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	icon_state = "folded_wall"
	deploy_path = /obj/structure/inflatable/wall

/obj/item/inflatable/door/
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon_state = "folded_door"
	deploy_path = /obj/structure/inflatable/door

/obj/structure/inflatable
	name = "inflatable"
	desc = "An inflated membrane. Do not puncture."
	density = 1
	anchored = 1
	opacity = 0
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "wall"

	var/undeploy_path = null
	var/deflating = 0
	var/health = 50

/obj/structure/inflatable/wall
	name = "inflatable wall"
	undeploy_path = /obj/item/inflatable/wall

/obj/structure/inflatable/New(location)
	..()
	update_nearby_tiles(need_rebuild=1)

/obj/structure/inflatable/Destroy()
	update_nearby_tiles()
	..()

/obj/structure/inflatable/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 0

/obj/structure/inflatable/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <= 0)
		deflate(1)

/obj/structure/inflatable/projectile_check()
	if(density)
		return PROJREACT_WINDOWS

/obj/structure/inflatable/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			deflate(1)
		if(3)
			if(prob(50))
				deflate(1)

/obj/structure/inflatable/attack_hand(mob/user as mob)
	add_fingerprint(user)
	return

/obj/structure/inflatable/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!istype(W) || istype(W, /obj/item/weapon/inflatable_dispenser)) return

	if((W.damtype == BRUTE || W.damtype == BURN) && W.can_puncture())
		..()
		if(hit(W.force))
			visible_message("<span class='danger'>[user] pierces [src] with [W]!</span>")
	return

/obj/structure/inflatable/proc/hit(var/damage, var/sound_effect = 1)
	health = max(0, health - damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
	if(health <= 0)
		deflate(1)
		return 1
	return 0

/obj/structure/inflatable/CtrlClick()
	hand_deflate()

/obj/structure/inflatable/proc/deflate(var/violent=0)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	var/obj/item/inflatable/remains
	if(violent)
		visible_message("[src] rapidly deflates!")
		var/obj/item/inflatable/torn/R = new /obj/item/inflatable/torn(loc)
	else
		if(!undeploy_path)
			return
		visible_message("\The [src] starts to deflate.")
		deflating = 1
		spawn(50)
			visible_message("\The [src] fully deflates.")
			var/obj/item/inflatable/R = new undeploy_path(loc)
			transfer_fingerprints_to(R)
			qdel(src)
	transfer_fingerprints_to(R)
	qdel(src)

/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(isobserver(usr) || usr.incapacitated() || !usr.Adjacent(src) || !usr.has_hands() || deflating)
		return

	verbs -= /obj/structure/inflatable/verb/hand_deflate
	deflate()

/obj/structure/inflatable/attack_animal(var/mob/living/simple_animal/M)
	health -= rand(M.melee_damage_lower, M.melee_damage_upper)
	if(health <= 0)
		M.visible_message("<span class='danger'>[M] tears open \the [src]!</span>")
		spawn(1)
			deflate(1)
	else
		M.visible_message("<span class='danger'>[M] [M.attacktext] \the [src]!</span>")
	return 1

/obj/structure/inflatable/proc/update_nearby_tiles(var/turf/T)


	if(isnull(air_master))
		return 0

	if(!T)
		T = get_turf(src)

	if(isturf(T))
		air_master.mark_for_update(T)

	return 1

/obj/structure/inflatable/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group)
		return 0
	else
		return !density

/obj/structure/inflatable/door
	name = "inflatable door"
	density = 1
	anchored = 1
	opacity = 0

	icon_state = "door_closed"
	undeploy_path = /obj/item/inflatable/door

	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0

/obj/structure/inflatable/door/attack_robot(mob/user)
	if(isAI(user))
		return
	else if(isrobot(user))
		if(user.Adjacent(src))
			return TryToSwitchState(user)

/obj/structure/inflatable/door/attack_hand(mob/user)
	return TryToSwitchState(user)

/obj/structure/inflatable/door/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group)
		return state
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/inflatable/door/proc/TryToSwitchState(mob/user)
	if(isSwitchingStates)
		return

	if(!user.restrained() && (user.size > SIZE_TINY))
		add_fingerprint(user)
		SwitchState()

/obj/structure/inflatable/door/proc/SwitchState()
	if(state)
		Close()
	else
		Open()
	update_nearby_tiles()

/obj/structure/inflatable/door/proc/Open()
	isSwitchingStates = 1
	flick("door_opening",src)
	sleep(10)
	density = 0
	opacity = 0
	state = 1
	update_icon()
	isSwitchingStates = 0

/obj/structure/inflatable/door/proc/Close()
	isSwitchingStates = 1
	flick("door_closing",src)
	sleep(10)
	density = 1
	opacity = 0
	state = 0
	update_icon()
	isSwitchingStates = 0

/obj/structure/inflatable/door/update_icon()
	if(state)
		icon_state = "door_open"
	else
		icon_state = "door_closed"

/obj/structure/inflatable/door/deflate(var/violent=0)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	if(violent)
		visible_message("[src] rapidly deflates!")
		var/obj/item/inflatable/door/torn/R = new /obj/item/inflatable/door/torn(loc)
		transfer_fingerprints_to(R)
		qdel(src)
	else
		visible_message("[src] slowly deflates.")
		deflating = 1
		spawn(50)
			var/obj/item/inflatable/door/R = new /obj/item/inflatable/door(loc)
			transfer_fingerprints_to(R)
			qdel(src)

/obj/item/inflatable/torn
	name = "torn inflatable structure"
	desc = "The shredded remains of an inflatable structure. It is too damaged to be repaired."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_torn"

/obj/item/inflatable/torn/attack_self(mob/user)
		to_chat(user, "<span class='notice'>This inflatable structure is too torn to be inflated!</span>")
		add_fingerprint(user)

/obj/item/weapon/storage/briefcase/inflatables
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors."
	icon_state = "inf_box"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/zz_old_items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/zz_old_items_righthand.dmi')
	item_state = "syringe_kit"
	max_combined_w_class = 28

/obj/item/weapon/storage/briefcase/inflatables/New()
	..()
	new /obj/item/inflatable/door(src)
	new /obj/item/inflatable/door(src)
	new /obj/item/inflatable/door(src)
	new /obj/item/inflatable/wall(src)
	new /obj/item/inflatable/wall(src)
	new /obj/item/inflatable/wall(src)
	new /obj/item/inflatable/wall(src)