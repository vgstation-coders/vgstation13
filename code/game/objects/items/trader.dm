/*
 *	Here defined the boxes contained in the trader vending machine.
 *	Feel free to add stuff. Don't forget to add them to the vmachine afterwards.
*/

/area/vault/mecha_graveyard

/obj/item/weapon/disk/shuttle_coords/vault/mecha_graveyard
	name = "Coordinates to the Mecha Graveyard"
	desc = "Here lay the dead steel of lost mechas, so says some gypsy."
	destination = /obj/docking_port/destination/vault/mecha_graveyard

/obj/docking_port/destination/vault/mecha_graveyard
	areaname = "mecha graveyard"

/datum/map_element/dungeon/mecha_graveyard
	file_path = "maps/randomvaults/dungeons/mecha_graveyard.dmm"
	unique = TRUE

/obj/effect/decal/mecha_wreckage/graveyard_ripley
	name = "Ripley wreckage"
	desc = "Surprisingly well preserved."
	icon_state = "ripley-broken"

/obj/effect/decal/mecha_wreckage/graveyard_ripley/New()
	..()
	var/list/parts = list(/obj/item/mecha_parts/part/ripley_torso,
								/obj/item/mecha_parts/part/ripley_left_arm,
								/obj/item/mecha_parts/part/ripley_right_arm,
								/obj/item/mecha_parts/part/ripley_left_leg,
								/obj/item/mecha_parts/part/ripley_right_leg)
	welder_salvage += parts

	if(prob(80))
		add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/drill,100)
	else
		add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/jetpack,100)

/obj/effect/decal/mecha_wreckage/graveyard_clarke
	name = "Clarke wreckage"
	desc = "Surprisingly well preserved."
	icon_state = "clarke-broken"

/obj/effect/decal/mecha_wreckage/graveyard_clarke/New()
	..()
	var/list/parts = list(
								/obj/item/mecha_parts/part/clarke_torso,
								/obj/item/mecha_parts/part/clarke_head,
								/obj/item/mecha_parts/part/clarke_left_arm,
								/obj/item/mecha_parts/part/clarke_right_arm,
								/obj/item/mecha_parts/part/clarke_left_tread,
								/obj/item/mecha_parts/part/clarke_right_tread)
	welder_salvage += parts

	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/collector,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/tiler,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/switchtool,100)

/obj/item/weapon/mech_expansion_kit
	name = "exosuit expansion kit"
	desc = "All the equipment you need to replace that useless legroom with a useful bonus equipment slot on your mech."
	icon = 'icons/obj/device.dmi'
	icon_state = "modkit"
	flags = FPRINT
	siemens_coefficient = 0
	w_class = W_CLASS_SMALL
	var/working = FALSE

/obj/item/weapon/mech_expansion_kit/preattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(!istype(target,/obj/mecha))
		to_chat(user,"<span class='warning'>That isn't an exosuit!</span>")
		return
	if(working)
		to_chat(user,"<span class='warning'>This is already being used to upgrade something!</span>")
		return
	var/obj/mecha/M = target
	if(M.max_equip > initial(M.max_equip))
		to_chat(user,"<span class='warning'>That exosuit cannot be modified any further. There's no more legroom to eliminate!</span>")
		return
	to_chat(user,"<span class='notice'>You begin modifying the exosuit.</span>")
	working = TRUE
	if(do_after(user,target,4 SECONDS))
		to_chat(user,"<span class='notice'>You finish modifying the exosuit!</span>")
		M.max_equip++
		qdel(src)
	else
		to_chat(user,"<span class='notice'>You stop modifying the exosuit.</span>")
		working = FALSE
	return 1

/obj/structure/wetdryvac
	name = "wet/dry vacuum"
	desc = "A powerful vacuum cleaner that can collect both trash and fluids."
	density = TRUE
	icon = 'icons/obj/objects.dmi'
	icon_state = "wetdryvac1"
	var/max_trash = 50
	var/list/trash = list()
	var/obj/item/vachandle/myhandle
	autoignition_temperature = AUTOIGNITION_PLASTIC

/obj/structure/wetdryvac/New()
	..()
	create_reagents(50)
	myhandle = new /obj/item/vachandle(src)

/obj/structure/wetdryvac/Destroy()
	if(myhandle)
		if(myhandle.loc == src)
			qdel(myhandle)
		else
			myhandle.myvac = null
		myhandle = null
	for(var/obj/item/I in trash)
		qdel(I)
	trash.Cut()
	..()

/obj/structure/wetdryvac/examine(mob/user)
	..()
	to_chat(user,"<span class='info'>The wet tank gauge reads: [reagents.total_volume]/[reagents.maximum_volume]</span>")
	to_chat(user,"<span class='info'>The dry storage gauge reads: [trash.len]/[max_trash]</span>")

/obj/structure/wetdryvac/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/vachandle))
		if(!myhandle)
			myhandle = W
		if(myhandle == W)
			to_chat(user,"<span class='notice'>You insert \the [W] into \the [src].")
			user.drop_item(W,src)
			update_icon()
	else
		..()

/obj/structure/wetdryvac/attack_hand(mob/user)
	if(myhandle && myhandle.loc == src)
		user.put_in_hands(myhandle)
		update_icon()
	else
		..()

/obj/structure/wetdryvac/update_icon()
	if(myhandle)
		icon_state = "wetdryvac[myhandle.loc == src]"
	else
		icon_state = "wetdryvac0"

/obj/structure/wetdryvac/MouseDropFrom(var/obj/O, src_location, var/turf/over_location, src_control, over_control, params)
	if(!can_use(usr,O))
		return
	if(istype(O,/obj/structure/sink))
		if(!reagents.total_volume)
			to_chat(usr,"<span class='warning'>\The [src] wet tank is already empty!</span>")
			return
		playsound(src, 'sound/effects/slosh.ogg', 25, 1)
		reagents.clear_reagents()
		to_chat(usr, "<span class='notice'>You flush \the [src] wet contents down \the [O].</span>")
	else if(istype(O,/obj/item/weapon/reagent_containers) && O.is_open_container())
		if(!reagents.total_volume)
			to_chat(usr,"<span class='warning'>\The [src] wet tank is already empty!</span>")
			return
		playsound(src, 'sound/effects/slosh.ogg', 25, 1)
		to_chat(usr, "<span class='notice'>You pour \the [src] wet contents into \the [O].</span>")
		reagents.trans_to(O.reagents,reagents.total_volume)
	else if(istype(O,/obj/machinery/disposal))
		if(!contents.len)
			to_chat(usr,"<span class='warning'>\The [src] dry storage is already empty!</span>")
			return
		playsound(src, 'sound/effects/freeze.ogg', 25, 1) //this sounds like trash moving to me
		for(var/obj/item/I in trash)
			I.forceMove(O)
		trash.Cut()
		to_chat(usr, "<span class='notice'>You dump \the [src] dry contents into \the [O].</span>")

/obj/structure/wetdryvac/MouseDropTo(atom/O, mob/user)
	if(!can_use(user,O))
		return
	whrr(get_turf(O))

/obj/structure/wetdryvac/proc/whrr(var/turf/T)
	if(!T)
		return
	playsound(src, 'sound/effects/vacuum.ogg', 25, 1)
	for(var/obj/effect/decal/cleanable/C in T)
		if(C.reagent)
			if(reagents.is_full())
				visible_message("<span class='warning'>\The [src] sputters, wet tank full!</span>")
				break
			reagents.add_reagent(C.reagent,1)
		qdel(C)
	for(var/obj/effect/overlay/puddle/P in T)
		if(reagents.is_full())
			visible_message("<span class='warning'>\The [src] sputters, wet tank full!</span>")
			break
		if(P.wet == TURF_WET_LUBE)
			reagents.add_reagent(LUBE,1)
		else if(P.wet == TURF_WET_WATER)
			reagents.add_reagent(WATER,1)
		qdel(P)
	T.clean_blood()
	for(var/obj/item/trash/R in T)
		if(trash.len >= max_trash)
			visible_message("<span class='warning'>\The [src] sputters, dry storage full!</span>")
			return
		R.forceMove(src)
		trash += R

/obj/structure/wetdryvac/proc/can_use(mob/user, atom/target)
	if(!ishigherbeing(user) && !isrobot(user) || user.incapacitated() || user.lying)
		return FALSE
	if(!Adjacent(user) || !user.Adjacent(target))
		return FALSE
	return TRUE

/obj/item/vachandle
	name = "vacuum handle"
	desc = "Handy. It doesn't suck per se, it merely conveys suckage."
	w_class = W_CLASS_MEDIUM
	icon = 'icons/obj/objects.dmi'
	icon_state = "vachandle"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	item_state = "vachandle"
	w_class = W_CLASS_HUGE
	var/obj/structure/wetdryvac/myvac
	var/event_key = null

/obj/item/vachandle/New()
	..()
	myvac = loc

/obj/item/vachandle/Destroy()
	myvac.myhandle = null
	myvac = null
	..()

/obj/item/vachandle/pickup(mob/user)
	..()
	user.register_event(/event/moved, src, nameof(src::mob_moved()))

/obj/item/vachandle/dropped(mob/user)
	user.unregister_event(/event/moved, src, nameof(src::mob_moved()))
	if(loc != myvac)
		retract()

/obj/item/vachandle/throw_at()
	retract()

/obj/item/vachandle/proc/mob_moved(atom/movable/mover)
	if(myvac && get_dist(src,myvac) > 2) //Needs a little leeway because dragging isn't instant
		retract()

/obj/item/vachandle/proc/retract()
	if(loc == myvac)
		return
	visible_message("<span class='warning'>\The [src] snaps back into \the [myvac]!</span>")
	if(ismob(loc))
		var/mob/M = loc
		M.drop_item(src,myvac)
	else
		forceMove(myvac)
	myvac.update_icon()

/obj/item/vachandle/preattack(atom/target, mob/user , proximity)
	if(!myvac)
		to_chat(user, "<span class='warning'>\The [src] isn't attached to a vacuum!</span>")
		return
	if(!proximity || !myvac.can_use(user,target))
		return
	if(target == myvac)
		return ..()
	myvac.whrr(get_turf(target))
	return 1

/obj/item/weapon/fakeposter_kit
	name = "cargo cache kit"
	desc = "Used to create a hidden cache behind what appears to be a cargo poster."
	icon = 'icons/obj/barricade.dmi'
	icon_state = "barricade_kit"
	w_class = W_CLASS_MEDIUM
	autoignition_temperature = AUTOIGNITION_PAPER

/obj/item/weapon/fakeposter_kit/preattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(istype(target,/turf/simulated/wall))
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
		if(do_after(user,target,4 SECONDS))
			to_chat(user,"<span class='notice'>Using the kit, you hollow out the wall and hang the poster in front.</span>")
			var/obj/structure/fakecargoposter/FCP = new(target)
			FCP.access_loc = get_turf(user)
			qdel(src)
			return 1
	else
		return ..()

/obj/structure/fakecargoposter
	icon = 'icons/obj/posters.dmi'
	var/obj/item/weapon/storage/cargocache/cash
	var/turf/access_loc
	autoignition_temperature = AUTOIGNITION_PAPER

/obj/structure/fakecargoposter/New()
	..()
	var/datum/poster/type = pick(/datum/poster/special/cargoflag,/datum/poster/special/cargofull)
	icon_state = initial(type.icon_state)
	desc = initial(type.desc)
	name = initial(type.name)
	cash = new(src)

/obj/structure/fakecargoposter/examine(mob/user)
	..()
	if(user.loc == access_loc)
		to_chat(user, "<span class='info'>Upon closer inspection, there's a hidden cache behind it accessible with a free hand.</span>")

/obj/structure/fakecargoposter/Destroy()
	for(var/atom/movable/A in cash.contents)
		A.forceMove(loc)
	QDEL_NULL(cash)
	..()

/obj/structure/fakecargoposter/attackby(var/obj/item/weapon/W, mob/user)
	if(iswelder(W))
		visible_message("<span class='warning'>[user] is destroying the hidden cache disguised as a poster!</span>")
		var/obj/item/tool/weldingtool/WT=W
		if(WT.do_weld(user, src, 10 SECONDS, 5))
			visible_message("<span class='warning'>[user] destroyed the hidden cache!</span>")
			qdel(src)
	else if(user.loc == access_loc)
		cash.attackby(W,user)
	else
		..()

/obj/structure/fakecargoposter/attack_hand(mob/user)
	if(user.loc == access_loc)
		cash.AltClick(user)

/obj/item/weapon/storage/cargocache
	name = "cargo cache"
	desc = "A large hidey hole for all your goodies."
	icon = 'icons/obj/posters.dmi'
	icon_state = "cargoposter-flag"
	fits_max_w_class = W_CLASS_LARGE
	max_combined_w_class = 28
	slot_flags = 0
	autoignition_temperature = AUTOIGNITION_PAPER

/obj/item/weapon/storage/cargocache/distance_interact(mob/user)
	if(istype(loc,/obj/structure/fakecargoposter) && user.Adjacent(loc))
		return TRUE
	return FALSE
