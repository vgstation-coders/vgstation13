#define DRILL_TIME 2

/obj/item/key/gigadrill
	name = "gigadrill key"
	desc = "A dusty and old key."
	icon_state = "keys"

/obj/structure/bed/chair/vehicle/gigadrill
	name = "gigadrill"
	icon_state = "gigadrill"
	keytype = /obj/item/key/gigadrill
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/gigadrill
	var/turf/drilling_turf
	var/obj/structure/ore_box/OB //The orebox contained within

/obj/structure/bed/chair/vehicle/gigadrill/Destroy()
	if(OB)
		OB.forceMove(get_turf(src))
		OB = null
	..()

/obj/structure/bed/chair/vehicle/gigadrill/buckle_mob(mob/M, mob/user)
  ..()
  update_icon()

/obj/structure/bed/chair/vehicle/gigadrill/attack_hand()
	..()
	update_icon()

/obj/structure/bed/chair/vehicle/gigadrill/to_bump()
	..()
	if(occupant)
		occupant.pixel_y += 2
		spawn(1)
		occupant.pixel_y -= 2

/obj/structure/bed/chair/vehicle/gigadrill/handle_layer()
	if(dir == NORTH)
		plane = OBJ_PLANE
		layer = ABOVE_OBJ_LAYER
	else
		plane = ABOVE_HUMAN_PLANE
		layer = VEHICLE_LAYER

/obj/structure/bed/chair/vehicle/gigadrill/make_offsets()
	offsets = list(
		"[SOUTH]" = list("x" = 0, "y" = 18 * PIXEL_MULTIPLIER),
		"[WEST]" = list("x" = 18 * PIXEL_MULTIPLIER, "y" = 9 * PIXEL_MULTIPLIER),
		"[NORTH]" = list("x" = 0, "y" = 7 * PIXEL_MULTIPLIER),
		"[EAST]" = list("x" = -18 * PIXEL_MULTIPLIER, "y" = 9 * PIXEL_MULTIPLIER)
		)

/obj/structure/bed/chair/vehicle/gigadrill/update_icon()
  if(occupant)
    icon_state = "gigadrill_mov"
  else
    icon_state = "gigadrill"

/obj/structure/bed/chair/vehicle/gigadrill/proc/drill(atom/target)
	if(!occupant)
		return

	if(istype(target, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = target
		if(M.mining_difficulty > MINE_DIFFICULTY_TOUGH)
			return
		if(M.finds && M.finds.len) //Shameless copypaste. TODO: Make an actual proc for this then apply it to mechs as well.
			if(prob(5))
				M.excavate_find(5, M.finds[1])
			else if(prob(50))
				M.finds.Remove(M.finds[1])
				if(prob(50))
					M.artifact_debris()
		M.GetDrilled()
		if(OB)
			var/count = 0
			for(var/obj/item/stack/ore/ore in range(src,1))
				if(get_dir(src,ore)&dir && ore.material)
					OB.materials.addAmount(ore.material,ore.amount)
					returnToPool(ore)
					count++
			if(count)
				to_chat(occupant,"<span class='notice'>[count] ore successfully loaded into cargo compartment.</span>")

/obj/structure/bed/chair/vehicle/gigadrill/MouseDropTo(atom/movable/O as mob|obj, mob/user as mob)
	..()
	if(OB || !istype(O, /obj/structure/ore_box))
		return
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O)) //no you can't pull things out of your ass
		return
	if(user.incapacitated() || user.lying) //are you cuffed, dying, lying, stunned or other
		return
	if(!Adjacent(user) || !user.Adjacent(src) || user.contents.Find(src)) // is the mob too far away from you, or are you too far away from the source
		return

	to_chat(user, "<span class = 'notice'>You load \the [O] onto \the [src].</span>")
	O.forceMove(src)
	OB = O

/obj/structure/bed/chair/vehicle/gigadrill/MouseDropFrom(over_object, src_location, var/turf/over_location, src_control, over_control, params)
	..()
	if(!OB)
		return
	if(!ishigherbeing(usr) && !isrobot(usr) || usr.incapacitated() || usr.lying)
		return
	if(!istype(over_location) || over_location.density)
		return
	if(!Adjacent(over_location))
		return
	if((!Adjacent(usr) || !usr.Adjacent(over_location)))
		return
	for(var/atom/movable/A in over_location.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	to_chat(usr, "<span class = 'notice'>You offload \the [OB]</span>")
	OB.forceMove(over_location)
	OB = null

/obj/effect/decal/mecha_wreckage/vehicle/gigadrill
	// TODO: SPRITE PLS
	//icon = 'icons/obj/vehicles.dmi'
	//icon_state = "gigadrill_wreck"
	name = "gigadrill wreckage"
	desc = "The rocks are safer.  For now."

#undef DRILL_TIME
