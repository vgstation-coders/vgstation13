
/obj/item/stack/tile
	icon = 'icons/obj/tiles.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/sheets_n_ores.dmi', "right_hand" = 'icons/mob/in-hand/right/sheets_n_ores.dmi')
	var/material
	var/datum/paint_overlay/paint_overlay = null
	var/list/stacked_paint = list()

/obj/item/stack/tile/transfer_data_from(var/obj/item/stack/tile/S, var/amount)
	while(amount > 0)
		if (!S.paint_overlay)
			return
		if (!paint_overlay)
			paint_overlay = S.paint_overlay
			S.paint_overlay = null
			if (S.stacked_paint.len > 0)
				var/datum/paint_overlay/paint = S.stacked_paint[1]
				S.stacked_paint -= paint
				S.paint_overlay = paint
		else
			stacked_paint += S.paint_overlay
			S.paint_overlay = null
			if (S.stacked_paint.len > 0)
				var/datum/paint_overlay/paint = S.stacked_paint[1]
				S.stacked_paint -= paint
				S.paint_overlay = paint
		amount--

/obj/item/stack/tile/update_icon()
	overlays.len = 0
	if (paint_overlay && paint_overlay.sub_overlays.len > 0)
		var/image/O = pick(paint_overlay.sub_overlays)
		var/image/I = image('icons/obj/tiles.dmi',src,"tile-paint")
		I.color = O.color
		overlays += I

/obj/item/stack/tile/proc/adjust_slowdown(mob/living/L, current_slowdown)
	return current_slowdown

/obj/item/stack/tile/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return
		else
	return

/obj/item/stack/tile/blob_act()
	qdel(src)

/obj/item/stack/tile/singularity_act()
	qdel(src)
	return 2

/obj/item/stack/tile/clean_act(var/cleanliness)
	..()
	if (cleanliness >= CLEANLINESS_BLEACH)
		paint_overlay = null
		stacked_paint.len = 0
		update_icon()

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
			S.ChangeTurf(/turf/simulated/floor/plating)
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
	else if(istype(W,/obj/item/stack/rods))
		var/obj/item/stack/rods/R = W
		if(R.amount < 2)
			to_chat(user, "<span class='warning'>You need at least two rods to do this.</span>")
		if(R.use(2) && use(1))
			var/obj/item/stack/tile/plated_catwalk/PC = (locate(/obj/item/stack/tile/plated_catwalk) in get_turf(user))
			if(PC)
				PC.add(1)
			else
				new /obj/item/stack/tile/plated_catwalk(get_turf(user))
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


/obj/item/stack/tile/rglass/afterattack(atom/target, mob/user, adjacent, params)
	if(adjacent)
		if(isturf(target) || istype(target, /obj/structure/lattice))
			var/turf/T = get_turf(target)
			switch(T.canBuildPlating())
				if(BUILD_SUCCESS)
					playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
					build(T)
					use(1)

/obj/item/stack/tile/rglass
	name = "glass tile"
	singular_name = "tile"
	desc = "A relatively clear reinforced glass tile."
	icon_state = "tile_rglass"
	max_amount = 60

/obj/item/stack/tile/rglass/proc/build(turf/S as turf)
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



/obj/item/stack/tile/rglass/plasma
	name = "plasma glass tile"
	singular_name = "tile"
	desc = "A relatively clear reinforced plasma glass tile."
	icon_state = "tile_plasmarglass"

/obj/item/stack/tile/rglass/plasma/build(turf/S as turf)
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
