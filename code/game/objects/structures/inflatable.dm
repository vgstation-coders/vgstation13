/obj/item/inflatable
	name = "inflatable"
	w_class = 2
	icon = 'icons/obj/inflatable.dmi'
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

/obj/item/inflatable/door
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
	penetration_dampening = 3

	var/undeploy_path = null
	var/health = 50

/obj/structure/inflatable/wall
	name = "inflatable wall"
	undeploy_path = /obj/item/inflatable/wall

/obj/structure/inflatable/New(location)
	..()
	update_nearby_tiles()

/obj/structure/inflatable/Destroy()
	update_nearby_tiles()
	..()

/obj/structure/inflatable/Cross(atom/movable/mover, turf/target, height=0, air_group=0)
	return 0

/obj/structure/inflatable/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <= 0)
		deflate(1)

/obj/structure/inflatable/projectile_check()
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

/obj/structure/inflatable/attack_hand(mob/user)
	add_fingerprint(user)

/obj/structure/inflatable/attackby(obj/item/weapon/W, mob/user)
	if(W.is_sharp())
		visible_message("<span class='danger'>[user] pierces [src] with [W]!</span>")
		deflate(1)
	if(W.damtype == BRUTE || W.damtype == BURN)
		hit(W.force)
		..()

/obj/structure/inflatable/attack_alien(mob/user)
	user.delayNextAttack(10)
	if(islarva(user))
		return
	visible_message("<span class='danger'>\The [user] rips [src] apart!</span>")
	deflate(1)

/obj/structure/inflatable/attack_animal(mob/user)
	user.delayNextAttack(10)
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	user.visible_message("<span class='danger'>\The [user] attacks [src]!</span>")
	attack_generic(M, M.melee_damage_upper)

/obj/structure/inflatable/attack_slime(mob/user)
	user.delayNextAttack(10)
	if(!isslimeadult(user))
		return
	user.visible_message("<span class='danger'>\The [user] glomps [src]!</span>")
	attack_generic(user, rand(10, 15))

/obj/structure/inflatable/proc/hit(var/damage, var/sound_effect = 1)
	health = max(0, health - damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/attackblob.ogg', 75, 1)
	if(health <= 0)
		deflate(1)

/obj/structure/inflatable/CtrlClick()
	hand_deflate()

/obj/structure/inflatable/proc/deflate(var/violent=0)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	if(violent)
		visible_message("\The [src] rapidly deflates!")
		var/obj/item/inflatable/torn/R = new /obj/item/inflatable/torn(loc)
		transfer_fingerprints_to(R)
		qdel(src)
	else
		if(!undeploy_path)
			return
		visible_message("\The [src] slowly deflates.")
		spawn(50)
			var/obj/item/inflatable/R = new undeploy_path(loc)
			transfer_fingerprints_to(R)
			qdel(src)

/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(isobserver(usr) || usr.restrained() || !usr.Adjacent(src))
		return

	verbs -= /obj/structure/inflatable/verb/hand_deflate
	deflate()

/obj/structure/inflatable/proc/attack_generic(var/mob/user, var/damage, var/attack_verb)
	health -= damage
	if(health <= 0)
		spawn(1) deflate(1)
	return 1

/obj/structure/inflatable/door
	name = "inflatable door"
	icon_state = "door_closed"
	undeploy_path = /obj/item/inflatable/door
	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0

/obj/structure/inflatable/door/attack_robot(mob/user) //those aren't machinery, they're just big fucking slabs of a mineral
	if(get_dist(user,src) <= 1) //not remotely though
		return TryToSwitchState(user)

/obj/structure/inflatable/door/attack_hand(mob/user)
	return TryToSwitchState(user)

/obj/structure/inflatable/door/Cross(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group)
		return state
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/inflatable/door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates) return
	if(ismob(user))
		var/mob/M = user
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()
	else if(istype(user, /obj/mecha))
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
	playsound(loc, 'sound/effects/attackblob.ogg', 75, 1)
	sleep(10)
	density = 0
	set_opacity(0)
	state = 1
	update_icon()
	isSwitchingStates = 0

/obj/structure/inflatable/door/proc/Close()
	isSwitchingStates = 1
	flick("door_closing",src)
	playsound(loc, 'sound/effects/attackblob.ogg', 75, 1)
	sleep(10)
	density = 1
	set_opacity(0)
	state = 0
	update_icon()
	isSwitchingStates = 0

/obj/structure/inflatable/proc/update_nearby_tiles()
	if (isnull(air_master))
		return
	var/T = loc
	if (isturf(T))
		air_master.mark_for_update(T)
	return 1

/obj/structure/inflatable/door/update_icon()
	if(state)
		icon_state = "door_open"
	else
		icon_state = "door_closed"

/obj/structure/inflatable/door/deflate(var/violent=0)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	if(violent)
		visible_message("\The [src] rapidly deflates!")
		var/obj/item/inflatable/door/torn/R = new /obj/item/inflatable/door/torn(loc)
		transfer_fingerprints_to(R)
		qdel(src)
	else
		visible_message("\The [src] slowly deflates.")
		spawn(50)
			var/obj/item/inflatable/door/R = new /obj/item/inflatable/door(loc)
			transfer_fingerprints_to(R)
			qdel(src)

/obj/item/inflatable/torn
	name = "torn inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation. It is too torn to be usable."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_wall_torn"

/obj/item/inflatable/torn/attack_self(mob/user)
	to_chat(user, "<span class='notice'>The inflatable wall is too torn to be inflated!</span>")
	add_fingerprint(user)

/obj/item/inflatable/door/torn
	name = "torn inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation. It is too torn to be usable."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_door_torn"

/obj/item/inflatable/door/torn/attack_self(mob/user)
	to_chat(user, "<span class='notice'>The inflatable door is too torn to be inflated!</span>")
	add_fingerprint(user)

/obj/item/weapon/storage/box/inflatable
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors."
	icon_state = "inf_box"
	item_state = "syringe_kit"

/obj/item/weapon/storage/box/inflatable/New()
	..()
	for(var/i = 1 to 3)
		new /obj/item/inflatable/door(src)
	for(var/i = 1 to 4)
		new /obj/item/inflatable/wall(src)