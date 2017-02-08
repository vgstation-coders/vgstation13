#define BORG_CAMERA_BUFFER 30

/mob/living/silicon/robot/Process_Spacemove()
	if(module)
		for(var/obj/item/weapon/tank/jetpack/J in module.modules)
			if(J && istype(J, /obj/item/weapon/tank/jetpack))
				if(J.allow_thrust(0.01))
					return 1
	if(..())
		return 1
	return 0

 //No longer needed, but I'll leave it here incase we plan to re-use it.
/mob/living/silicon/robot/movement_delay()
	var/tally = 0 //Incase I need to add stuff other than "speed" later

	tally = speed

	if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
		tally-=3 // JESUS FUCKING CHRIST WHY

	var/turf/T = loc
	if(istype(T))
		tally = T.adjust_slowdown(src, tally)

		if(tally == -1)
			return tally

	return tally+config.robot_delay

// ROBOT MOVEMENT

// Update the portable camera everytime the Robot moves.
// This might be laggy, comment it out if there are problems.
/mob/living/silicon/robot/var/updating = 0

/mob/living/silicon/robot/Move(atom/NewLoc, Dir)
	var/oldLoc = src.loc
	. = ..()
	if(.)
		if(istype(NewLoc, /turf/unsimulated/floor/asteroid) && istype(module, /obj/item/weapon/robot_module/miner))
			var/obj/item/weapon/storage/bag/ore/ore_bag = locate(/obj/item/weapon/storage/bag/ore) in get_all_slots() //find it in our modules
			if(ore_bag)
				for(var/obj/item/weapon/ore/ore in NewLoc.contents)
					ore_bag.preattack(NewLoc, src, 1) //collects everything
					break
		if(src.camera)
			if(!updating)
				updating = 1
				spawn(BORG_CAMERA_BUFFER)
					if(oldLoc != src.loc)
						cameranet.updatePortableCamera(src.camera)
					updating = 0

		if(module)
			if(module.type == /obj/item/weapon/robot_module/janitor)
				var/turf/tile = loc
				if(isturf(tile))
					tile.clean_blood()
					for(var/A in tile)
						if(istype(A, /obj/effect))
							if(istype(A, /obj/effect/rune) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay))
								qdel(A)
						else if(istype(A, /obj/item))
							var/obj/item/cleaned_item = A
							cleaned_item.clean_blood()
						else if(istype(A, /mob/living/carbon/human))
							var/mob/living/carbon/human/cleaned_human = A
							if(cleaned_human.lying)
								if(cleaned_human.head)
									cleaned_human.head.clean_blood()
									cleaned_human.update_inv_head(0)
								if(cleaned_human.wear_suit)
									cleaned_human.wear_suit.clean_blood()
									cleaned_human.update_inv_wear_suit(0)
								else if(cleaned_human.w_uniform)
									cleaned_human.w_uniform.clean_blood()
									cleaned_human.update_inv_w_uniform(0)
								if(cleaned_human.shoes)
									cleaned_human.shoes.clean_blood()
									cleaned_human.update_inv_shoes(0)
								cleaned_human.clean_blood()
								cleaned_human << "<span class='warning'>[src] cleans your face!</span>"
