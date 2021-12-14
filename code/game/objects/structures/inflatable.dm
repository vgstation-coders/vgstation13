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
				inflate(user)
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

/obj/item/inflatable/proc/inflate(mob/user)
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	var/obj/structure/inflatable/R = new deploy_path(get_turf(src))
	transfer_fingerprints_to(R)
	visible_message("<span class='notice'>\The [src] inflates.</span>")
	qdel(src)

/obj/item/inflatable/attackby(var/obj/item/I, var/mob/user)
	if(iswelder(I))
		weld(I, user)
	..()

/obj/item/inflatable/proc/weld(var/obj/item/tool/weldingtool/WE, var/mob/user)
	if(!istype(WE))
		return
	if(!WE.remove_fuel(1, user))
		return
	to_chat(user, "<span class='notice'>You melt \the [src] into a plastic sheet.</span>")
	new /obj/item/stack/sheet/mineral/plastic(get_turf(src))
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

/obj/item/inflatable/shelter
	name = "inflatable shelter"
	desc = "A special plasma shelter designed to resist great heat and temperatures so that victims can survive until rescue."
	icon_state = "folded"
	deploy_path = /obj/structure/inflatable/shelter

/obj/item/inflatable/floor
	name = "inflatable floor"
	desc = "A folded membrane, which rapidly expands along the horizontal plane until it runs out of room to inflate, or air to inflate with."
	icon_state = "folded_floor"
	deploy_path = /turf/simulated/floor/inflatable

/obj/item/inflatable/floor/can_inflate(var/location)
	var/turf/T = get_turf(src)
	if(!istype(T, get_base_turf(T.z)))
		return FALSE
	return ..()

/obj/item/inflatable/floor/inflate(mob/user)
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	visible_message("<span class='notice'>\The [src] inflates.</span>")
	var/turf/T = get_turf(src)
	T.ChangeTurf(/turf/simulated/floor/inflatable)
	qdel(src)

/*/obj/item/inflatable/shelter/attack_self(mob/user)
	user.anchored = 1 Previously, this would anchor the user in place until it inflated and put them inside
	..()
	spawn()
		user.anchored = 0*/

/obj/item/inflatable/shelter/inflate(mob/user)
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	var/obj/structure/inflatable/shelter/R = new deploy_path(get_turf(src))
	transfer_fingerprints_to(R)
	visible_message("<span class='notice'>\The [src] inflates.</span>")
	//R.enter_shelter(user)
	qdel(src)

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
	pass_flags_self = PASSGLASS
	var/undeploy_path = null
	var/spawn_undeployed = TRUE
	var/tmp/deflating = 0
	var/health = 30
	var/ctrl_deflate = TRUE

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
	. = ..()
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
	var/damage_dealt = rand(M.melee_damage_lower, M.melee_damage_upper)
	if (!damage_dealt)
		M.visible_message("<span class='notice'>\The [M] nuzzles \the [src].</span>")
		return 1
	if(take_damage(damage_dealt))
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
	if(ctrl_deflate)
		hand_deflate()
	else
		..()

/obj/structure/inflatable/proc/deflate(var/violent=0, var/deflatespeed = 50)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	var/obj/item/inflatable/remains
	if(violent)
		visible_message("[src] rapidly deflates!")
		if(spawn_undeployed)
			remains = new /obj/item/inflatable/torn(loc)
	else
		if(!undeploy_path || deflating)
			return
		visible_message("\The [src] starts to deflate.")
		deflating = 1
		sleep(deflatespeed)
		visible_message("\The [src] fully deflates.")
		if(spawn_undeployed)
			remains = new undeploy_path(loc)
	if(remains)
		transfer_fingerprints_to(remains)
	for(var/atom/movable/AM in src)
		AM.forceMove(src.loc)
	qdel(src)

/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(!isliving(usr) || usr.incapacitated() || !usr.Adjacent(src) || !usr.dexterity_check() || deflating)
		return

	verbs -= /obj/structure/inflatable/verb/hand_deflate
	deflate()

/obj/structure/inflatable/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group)
		return 0
	if(istype(mover) && mover.checkpass(pass_flags_self))
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
	setDensity(TRUE)
	is_open = 0
	update_icon()
	busy = 0

/obj/structure/inflatable/door/update_icon()
	icon_state = "door_[is_open ? "open" : "closed"]"

/obj/structure/inflatable/shelter
	name = "inflatable shelter"
	desc = "A shelter designed to protect from extreme heat and pressure, but vulnerable to popping by other forms of trauma. The entrance is fitted with a medical autoinjector."
	icon_state = "shelter_base"
	anchored = 0
	undeploy_path = /obj/item/inflatable/shelter
	ctrl_deflate = FALSE
	var/list/exiting = list()
	var/datum/gas_mixture/cabin_air

/obj/structure/inflatable/shelter/New()
	..()
	cabin_air = new /datum/gas_mixture()
	cabin_air.volume = CELL_VOLUME / 3
	cabin_air.temperature = T20C+20 //Nice and toasty to avoid Celthermia
	cabin_air.adjust_multi(
		GAS_OXYGEN, MOLES_O2STANDARD,
		GAS_NITROGEN, MOLES_N2STANDARD)

/obj/structure/inflatable/shelter/examine(mob/user)
	..()
	if(!(user.loc == src))
		to_chat(user, "<span class='notice'>Click to enter. Use grab on shelter to force target inside. Click-drag onto firealarm or right click to deflate.</span>")
	else
		to_chat(user, "<span class='notice'>Click to package contaminated clothes. Click-drag to an adjacent turf or Resist to exit/cancel exit.</span>")
	var/list/living_contents = list()
	for(var/mob/living/L in contents)
		living_contents += L.name //Shelters can frequently end up with dropped items because people fall asleep.
	if(living_contents.len)
		to_chat(user,"<span class='info'>You can see [english_list(living_contents)] inside.</span>")

/obj/structure/inflatable/shelter/forceMove(atom/NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0, from_tp = 0) //Like an unanchored window, we can block if pushed into place.
	..()
	update_nearby_tiles()

/obj/structure/inflatable/shelter/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	update_nearby_tiles()
	..()
	update_nearby_tiles()

/obj/structure/inflatable/shelter/is_airtight()
	return TRUE

/obj/structure/inflatable/shelter/update_icon()
	overlays = list()
	var/mob/living/carbon/human/occupant = locate(/mob/living/carbon/human) in contents
	if(occupant)
		var/image/occupant_overlay = occupant.appearance
		overlays += occupant_overlay
	var/image/cover_overlay = image('icons/obj/inflatable.dmi', icon_state = "shelter_top", layer = FLY_LAYER)
	cover_overlay.plane = ABOVE_HUMAN_PLANE
	overlays += cover_overlay

/obj/structure/inflatable/shelter/attack_hand(mob/user)
	if(user.loc == src && ishuman(user))
		if(!laundry(user))
			to_chat(user,"<span class='warning'>You are not wearing any contaminated clothes. Did you mean to Resist free?</span>")
	else
		to_chat(user,"<span class='notice'>You begin to climb into the shelter.</span>")
		if(do_after(user, src, 10))
			enter_shelter(user)

/obj/structure/inflatable/shelter/attackby(obj/item/weapon/W,mob/user)
	if(istype(W,/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		var/mob/living/target = G.affecting
		user.visible_message("<span class='danger'>[user] begins to drag [target] into the shelter!</span>")
		if(do_after_many(user,list(target,src),20)) //Twice the normal time
			enter_shelter(target)
	else
		..()

/obj/structure/inflatable/shelter/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
	qdel(cabin_air)
	cabin_air = null
	..()

/obj/structure/inflatable/shelter/remove_air(amount)
	return cabin_air.remove(amount)

/obj/structure/inflatable/shelter/return_air()
	return cabin_air

/obj/structure/inflatable/shelter/proc/enter_shelter(mob/user)
	user.forceMove(src)
	update_icon()
	user.reset_view()
	if(user.reagents && !user.reagents.has_reagent(PRESLOMITE))
		user.reagents.add_reagent(PRESLOMITE,3)
		user.reagents.add_reagent(LEPORAZINE,1)
		to_chat(user,"<span class='warning'>You feel a prick upon entering \the [src].</span>")
	else
		to_chat(user,"<span class='notice'>You enter \the [src].</span>")

/obj/structure/inflatable/shelter/proc/laundry(var/mob/living/carbon/human/user)
	if(user.loc != src)
		return 0 //sanity
	var/obj/item/delivery/D = new /obj/item/delivery(src,null,W_CLASS_LARGE)
	//There are only three slots which can be contaminated: shoes, gloves and w_uniform.
	//Unfortunately, uniform has dependent slots: l_store, r_store, wear_id, and belt
	if(user.shoes && user.shoes.contaminated)
		stow(D,user.shoes,user)
	if(user.gloves && user.gloves.contaminated)
		stow(D,user.gloves,user)
	if(user.w_uniform && user.w_uniform.contaminated)
		if(user.l_store)
			stow(D,user.l_store,user)
		if(user.r_store)
			stow(D,user.r_store,user)
		if(user.wear_id)
			stow(D,user.wear_id,user)
		if(user.belt)
			stow(D,user.belt,user)
		stow(D,user.w_uniform,user)
	if(D.contents.len)
		user.put_in_hands(D)
		update_icon()
		playsound(loc, 'sound/effects/spray.ogg', 75, 1)
		return 1
	else
		qdel(D)
		return 0

/obj/structure/inflatable/shelter/proc/stow(obj/item/delivery/D,obj/item/I,mob/user)
	user.u_equip(I)
	I.forceMove(D)

/obj/structure/inflatable/shelter/ex_act(severity)
	if(severity<3)
		for(var/atom/movable/A as mob|obj in src)//pulls everything out and hits it with an explosion
			A.forceMove(loc)
			A.ex_act(severity++)
	..()

/obj/structure/inflatable/shelter/container_resist(var/mob/user,var/turf/dest)
	if (user.loc != src)
		exiting -= user
		to_chat(user,"<span class='warning'>You cannot climb out of something you aren't even in!</span>")
		return
	if(exiting.Find(user))
		exiting -= user
		to_chat(user,"<span class='warning'>You stop climbing free of \the [src].</span>")
		return
	visible_message("<span class='warning'>[user] begins to climb free of the \the [src]!</span>")
	exiting += user
	spawn(6 SECONDS)
		if(loc && exiting.Find(user)) //If not loc, it was probably deflated
			if (dest)
				user.forceMove(dest)
			else
				user.forceMove(loc)
			exiting -= user
			update_icon()
			to_chat(user,"<span class='notice'>You climb free of the shelter.</span>")

/obj/structure/inflatable/shelter/MouseDropTo(atom/movable/O, mob/user) //copy pasted from cryo code
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O)) //no you can't pull things out of your ass
		return
	if(user.incapacitated() || user.lying) //are you cuffed, dying, lying, stunned or other
		return
	if(!Adjacent(user) || !user.Adjacent(src)) // is the mob too far away from you, or are you too far away from the source
		return
	if(O.locked_to)
		return
	else if(O.anchored)
		return
	if(issilicon(O)) //robutts dont fit
		return
	if(!ishigherbeing(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(isrobot(user))
		var/mob/living/silicon/robot/robit = user
		if(!HAS_MODULE_QUIRK(robit, MODULE_CAN_HANDLE_MEDICAL))
			to_chat(user, "<span class='warning'>You do not have the means to do this!</span>")
			return
	var/mob/living/target = O
	if(!istype(target))
		return
	for(var/mob/living/carbon/slime/M in range(1,target))
		if(M.Victim == target)
			to_chat(usr, "[target.name] will not fit into the [src] because they have a slime latched onto their head.")
			return

	if(target == user)
		to_chat(user,"<span class='notice'>You begin to climb into the shelter.</span>")
		if(do_after(target,src,10))
			enter_shelter(target)
	else
		user.visible_message("<span class='danger'>[user] begins to drag [target] into the shelter!</span>")
		if(do_after_many(user,list(target,src),20)) //Twice the normal time
			enter_shelter(target)


/obj/structure/inflatable/shelter/MouseDropFrom(over_object, src_location, turf/over_location, src_control, over_control, params)
	if(!Adjacent(over_location))
		return
	if(!istype(over_location) || over_location.density)
		return
	if(usr.incapacitated())
		return
	for(var/atom/movable/A in over_location.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	if(istype(over_location))
		container_resist(usr,over_location)

/obj/structure/inflatable/shelter/Exited(var/atom/movable/mover)
	update_icon()
	return ..()
