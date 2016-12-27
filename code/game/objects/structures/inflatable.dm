/obj/item/inflatable
	name = "inflatable"
	w_class = W_CLASS_MEDIUM
	icon = 'icons/obj/inflatable.dmi'
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_PLASTIC
	starting_materials = list(MAT_PLASTIC = 1.5*CC_PER_SHEET_MISC)

	var/deploy_path = null
	var/tmp/inflating = FALSE

/obj/item/inflatable/attack_self(mob/user)
	if(!deploy_path)
		return
	if(!istype(user.loc, /turf))
		return

	add_fingerprint(user)
	if(user.drop_item(src))
		inflating = TRUE
		anchored = 1
		to_chat(user, "<span class='notice'>You pull the inflation cord on \the [src].</span>")
		spawn(10)
			if(can_inflate())
				inflate()
			else
				inflating = FALSE
				anchored = 0

/obj/item/inflatable/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/inflatable/attack_hand(mob/user)
	if(inflating)
		return
	..()

/obj/item/inflatable/proc/can_inflate(var/location)
	if(!location)
		location = loc
	if(!isturf(location))
		return 0
	if(locate(/obj/structure/inflatable) in get_turf(location))
		return 0
	return 1

/obj/item/inflatable/proc/inflate()
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	var/obj/structure/inflatable/R = new deploy_path(get_turf(src))
	transfer_fingerprints_to(R)
	visible_message("<span class='notice'>\The [src] inflates.</span>")
	qdel(src)

/obj/item/inflatable/attackby(var/obj/item/I, var/mob/user)
	if(iswelder(I))
		weld(I, user)
	..()

/obj/item/inflatable/proc/weld(var/obj/item/weapon/weldingtool/WE, var/mob/user)
	if(!istype(WE))
		return
	if(!WE.remove_fuel(1, user))
		return
	to_chat(user, "<span class='notice'>You melt \the [src] into a plastic sheet.</span>")
	getFromPool(/obj/item/stack/sheet/mineral/plastic, get_turf(src))
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

/obj/item/inflatable/torn
	name = "torn inflatable structure"
	desc = "The shredded remains of an inflatable structure. It is too damaged to be repaired."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_torn"

/obj/item/inflatable/torn/attack_self(mob/user)
	to_chat(user, "<span class='notice'>This inflatable structure is damaged beyond use.</span>")
	add_fingerprint(user)

/obj/structure/inflatable
	name = "inflatable"
	desc = "An inflated membrane. Do not puncture."
	density = 1
	anchored = 1
	opacity = 0
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "wall"

	var/undeploy_path = null
	var/tmp/deflating = 0
	var/health = 30

/obj/structure/inflatable/wall
	name = "inflatable wall"
	undeploy_path = /obj/item/inflatable/wall

/obj/structure/inflatable/New()
	..()
	update_nearby_tiles()

/obj/structure/inflatable/Destroy()
	update_nearby_tiles()
	..()

/obj/structure/inflatable/bullet_act(var/obj/item/projectile/Proj)
	..()
	if(Proj.damage)
		take_damage(Proj.damage)

/obj/structure/inflatable/projectile_check()
	return PROJREACT_WINDOWS

/obj/structure/inflatable/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			deflate(1)
		if(3)
			take_damage(rand(15,45), 0)

/obj/structure/inflatable/attackby(obj/item/I, mob/user)
	if(!istype(I) || istype(I, /obj/item/weapon/inflatable_dispenser))
		return

	if((I.damtype == BRUTE && I.is_sharp()) || I.damtype == BURN)
		..()
		take_damage(I.force)
	else
		user.visible_message("<span class='notice'>[user] bonks \the [src] with \the [I], but it harmlessly bounces off.</span>")
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
	user.delayNextAttack(10)

/obj/structure/inflatable/attack_animal(var/mob/living/simple_animal/M)
	if(take_damage(rand(M.melee_damage_lower, M.melee_damage_upper)))
		M.visible_message("<span class='danger'>[M] tears open \the [src]!</span>")
	else
		M.visible_message("<span class='danger'>[M] [M.attacktext] \the [src]!</span>")
	M.delayNextAttack(10)
	return 1

/obj/structure/inflatable/attack_alien(mob/user)
	user.visible_message("<span class='danger'>[user] rips \the [src] apart!</span>")
	deflate(1)

/obj/structure/inflatable/proc/take_damage(var/damage, var/sound_effect = 1)
	health = max(0, health - damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
	if(health <= 0)
		spawn(1)
			deflate(1)
		return 1
	return 0

/obj/structure/inflatable/CtrlClick()
	hand_deflate()

/obj/structure/inflatable/proc/deflate(var/violent=0, var/deflatespeed = 50)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	var/obj/item/inflatable/remains
	if(violent)
		visible_message("[src] rapidly deflates!")
		remains = new /obj/item/inflatable/torn(loc)
	else
		if(!undeploy_path || deflating)
			return
		visible_message("\The [src] starts to deflate.")
		deflating = 1
		sleep(deflatespeed)
		visible_message("\The [src] fully deflates.")
		remains = new undeploy_path(loc)
	transfer_fingerprints_to(remains)
	qdel(src)

/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(!isliving(usr) || usr.incapacitated() || !usr.Adjacent(src) || !usr.IsAdvancedToolUser() || deflating)
		return

	verbs -= /obj/structure/inflatable/verb/hand_deflate
	deflate()

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
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	return !density

/obj/structure/inflatable/door
	name = "inflatable door"

	icon_state = "door_closed"
	undeploy_path = /obj/item/inflatable/door

	var/is_open = 0
	var/busy = 0

/obj/structure/inflatable/door/attack_robot(mob/user)
	if(user.Adjacent(src))
		toggle(user)

/obj/structure/inflatable/door/attack_hand(mob/user)
	toggle(user)

/obj/structure/inflatable/door/proc/toggle(mob/user)
	if(busy)
		return

	add_fingerprint(user)
	if(is_open)
		Close()
	else
		Open()
	update_nearby_tiles()

/obj/structure/inflatable/door/proc/Open()
	busy = 1
	flick("door_opening",src)
	sleep(5)
	density = 0
	is_open = 1
	update_icon()
	busy = 0

/obj/structure/inflatable/door/proc/Close()
	busy = 1
	flick("door_closing",src)
	sleep(5)
	density = 1
	is_open = 0
	update_icon()
	busy = 0

/obj/structure/inflatable/door/update_icon()
	icon_state = "door_[is_open ? "open" : "closed"]"
