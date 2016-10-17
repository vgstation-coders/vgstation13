/obj/item/stack/tile/plasteel
	name = "floor tile"
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon."
	icon_state = "tile"
	w_class = W_CLASS_MEDIUM
	force = 6.0
	starting_materials = list(MAT_IRON = 937.5)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	throwforce = 10
	throw_speed = 4
	throw_range = 20
	flags = FPRINT
	siemens_coefficient = 1
	max_amount = 60
	var/active

	material = "metal"

/obj/item/stack/tile/plasteel/New(var/loc, var/amount=null)
	. = ..()
	pixel_x = rand(1, 14) * PIXEL_MULTIPLIER
	pixel_y = rand(1, 14) * PIXEL_MULTIPLIER

/obj/item/stack/tile/plasteel/Destroy()
	..()
	if(active)
		returnToPool(active)
		active = null

/obj/item/stack/tile/plasteel/attack_self(mob/user)
	if(!active) //Start click drag construction
		active = getFromPool(/obj/screen/draggable, src, user)
		to_chat(user, "Beginning plating construction mode, click and hold to use.")
		return
	else //End click drag construction, create grille
		returnToPool(active)

/obj/item/stack/tile/plasteel/can_drag_use(mob/user, turf/T)
	if(user.Adjacent(T)) //can we place here
		var/canbuild = T.canBuildPlating()
		if(canbuild == BUILD_SUCCESS || canbuild == BUILD_IGNORE)
			if(use(1)) //place and use rod
				return 1
			else
				returnToPool(active) //otherwise remove the draggable screen
				active = null

/obj/item/stack/tile/plasteel/drag_use(mob/user, turf/T)
	if(T.canBuildPlating() == BUILD_SUCCESS) //This deletes lattices, only necessary for BUILD_SUCCESS
		var/L = locate(/obj/structure/lattice) in T
		if(!L)
			return
		qdel(L)
	playsound(T, 'sound/weapons/Genhit.ogg', 25, 1)
	build(T)

/obj/item/stack/tile/plasteel/end_drag_use()
	active = null

/obj/item/stack/tile/plasteel/dropped()
	..()
	if(active)
		returnToPool(active)
		active = null

/obj/item/stack/tile/plasteel/proc/build(turf/S as turf)
	if(istype(S,/turf/space) || istype(S,/turf/unsimulated))
		S.ChangeTurf(/turf/simulated/floor/plating/airless)
	else
		S.ChangeTurf(/turf/simulated/floor/plating)
	return

/obj/item/stack/tile/plasteel/attackby(obj/item/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(amount < 4)
			to_chat(user, "<span class='warning'>You need at least four tiles to do this.</span>")
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal)
			M.amount = 1
			M.forceMove(get_turf(usr)) //This is because new() doesn't call forceMove, so we're forcemoving the new sheet to make it stack with other sheets on the ground.
			user.visible_message("<span class='warning'>[src] is shaped into metal by [user.name] with the welding tool.</span>", \
			"<span class='warning'>You shape the [src] into metal with the welding tool.</span>", \
			"<span class='warning'>You hear welding.</span>")
			var/obj/item/stack/tile/plasteel/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(4)
			if (!R && replace)
				user.put_in_hands(M)
		return 1
	return ..()

/obj/item/stack/tile/plasteel/afterattack(atom/target, mob/user, adjacent, params)
	if(adjacent)
		if(isturf(target) || istype(target, /obj/structure/lattice))
			var/turf/T = get_turf(target)
			var/obj/structure/lattice/L
			switch(T.canBuildPlating())
				if(BUILD_SUCCESS)
					L = locate(/obj/structure/lattice) in T
					if(!istype(L))
						return
					qdel(L)
					playsound(get_turf(src), 'sound/weapons/Genhit.ogg', 50, 1)
					build(T)
					use(1)
					return
				if(BUILD_IGNORE)
					playsound(get_turf(src), 'sound/weapons/Genhit.ogg', 50, 1)
					build(T)
					use(1)
				if(BUILD_FAILURE)
					to_chat(user, "<span class='warning'>The plating is going to need some support.</span>")
					return
