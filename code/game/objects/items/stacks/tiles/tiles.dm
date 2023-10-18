/obj/item/stack/tile/metal
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
	material = "metal"
	var/active

/obj/item/stack/tile/metal/New(var/loc, var/amount=null)
	. = ..()
	pixel_x = rand(1, 14) * PIXEL_MULTIPLIER
	pixel_y = rand(1, 14) * PIXEL_MULTIPLIER

/obj/item/stack/tile/metal/Destroy()
	..()
	if(active)
		QDEL_NULL(active)

/obj/item/stack/tile/metal/attack_self(mob/user)
	if(!active) //Start click drag construction
		active = new /obj/abstract/screen/draggable(src, user)
		to_chat(user, "Beginning plating construction mode, click and hold to use.")
		return
	else //End click drag construction, create grille
		qdel(active)

/obj/item/stack/tile/metal/can_drag_use(mob/user, turf/T)
	if(user.Adjacent(T)) //can we place here
		var/canbuild = T.canBuildPlating()
		if(canbuild == BUILD_SUCCESS || canbuild == BUILD_IGNORE || T.canBuildFloortile(src.type))
			if(use(1)) //place and use rod
				return 1
			else
				QDEL_NULL(active) //otherwise remove the draggable screen

/obj/item/stack/tile/metal/drag_use(mob/user, turf/T)
	if(T.canBuildFloortile(src.type) && istype(T,/turf/simulated/floor))
		var/turf/simulated/floor/F = T
		F.make_tiled_floor(src)
		playsound(T, 'sound/weapons/Genhit.ogg', 25, 1)
		return
	if(T.canBuildPlating() == BUILD_SUCCESS) //This deletes lattices, only necessary for BUILD_SUCCESS
		var/L = locate(/obj/structure/lattice) in T
		if(!L)
			return
		qdel(L)
	playsound(T, 'sound/weapons/Genhit.ogg', 25, 1)
	build(T)

/obj/item/stack/tile/metal/end_drag_use()
	active = null

/obj/item/stack/tile/metal/dropped()
	..()
	if(active)
		QDEL_NULL(active)

/obj/item/stack/tile/metal/proc/build(turf/S as turf)
	if(S.air)
		var/datum/gas_mixture/GM = S.air
		if(GM.pressure > HALF_ATM)
			var/turf/simulated/floor/plating/P
			S.ChangeTurf(P)
			return
	S.ChangeTurf(/turf/simulated/floor/plating/airless)

/obj/item/stack/tile/metal/attackby(obj/item/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(amount < 4)
			to_chat(user, "<span class='warning'>You need at least four tiles to do this.</span>")
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/M = new sheet_type
			M.amount = 1
			M.forceMove(get_turf(usr)) //This is because new() doesn't call forceMove, so we're forcemoving the new sheet to make it stack with other sheets on the ground.
			user.visible_message("<span class='warning'>[src] is shaped into [M.name] sheets by [user.name] with the welding tool.</span>", \
			"<span class='warning'>You shape the [src] into [M.name] sheets with the welding tool.</span>", \
			"<span class='warning'>You hear welding.</span>")
			var/obj/item/stack/tile/metal/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(4)
			if (!R && replace)
				user.put_in_hands(M)
		return 1
	return ..()

/obj/item/stack/tile/metal/afterattack(atom/target, mob/user, adjacent, params)
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
					playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
					build(T)
					use(1)
					return
				if(BUILD_IGNORE)
					playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
					build(T)
					use(1)
				if(BUILD_FAILURE)
					to_chat(user, "<span class='warning'>The plating is going to need some support.</span>")
					return


/obj/item/stack/glass_tile/rglass/afterattack(atom/target, mob/user, adjacent, params)
	if(adjacent)
		if(isturf(target) || istype(target, /obj/structure/lattice))
			var/turf/T = get_turf(target)
			switch(T.canBuildPlating())
				if(BUILD_SUCCESS)
					playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
					build(T)
					use(1)

/obj/item/stack/glass_tile/rglass
	name = "glass tile"
	singular_name = "tile"
	desc = "A relatively clear reinforced glass tile."
	icon_state = "tile_rglass"
	max_amount = 60

/obj/item/stack/glass_tile/rglass/proc/build(turf/S as turf)
	var/obj/structure/lattice/L = S.canBuildCatwalk(src)
	if(istype(L))
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
		qdel(L)
		if(S.air)
			var/datum/gas_mixture/GM = S.air
			if(GM.pressure > HALF_ATM)
				S.ChangeTurf(/turf/simulated/floor/glass)
				return
		S.ChangeTurf(/turf/simulated/floor/glass/airless)



/obj/item/stack/glass_tile/rglass/plasma
	name = "plasma glass tile"
	singular_name = "tile"
	desc = "A relatively clear reinforced plasma glass tile."
	icon_state = "tile_plasmarglass"

/obj/item/stack/glass_tile/rglass/plasma/build(turf/S as turf)
	var/obj/structure/lattice/L = S.canBuildCatwalk(src)
	if(istype(L))
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
		qdel(L)
		if(S.air)
			var/datum/gas_mixture/GM = S.air
			if(GM.pressure > HALF_ATM)
				S.ChangeTurf(/turf/simulated/floor/glass/plasma)
				return
		S.ChangeTurf(/turf/simulated/floor/glass/plasma/airless)

/obj/item/stack/tile/metal/plasteel
	name = "reinforced floor tile"
	singular_name = "reinforced floor tile"
	desc = "Those could work as a pretty tough throwing weapon."
	icon_state = "r_tile"
	force = 9.0
	starting_materials = list(MAT_IRON = 937.5, MAT_PLASMA = 937.5)
	melt_temperature = MELTPOINT_PLASMA
	throwforce = 15
	sheet_type = /obj/item/stack/sheet/plasteel
	material = "plasteel"
