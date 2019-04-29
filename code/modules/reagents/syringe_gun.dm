/obj/item/weapon/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon = 'icons/obj/gun.dmi'
	icon_state = "syringegun"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = W_CLASS_MEDIUM
	throw_speed = 2
	throw_range = 10
	force = 4.0
	clumsy_check = 0	//It has its own clumsy interaction
	fire_sound = 'sound/items/syringeproj.ogg'
	var/list/syringes = new/list()
	var/max_syringes = 1
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_METAL

/obj/item/weapon/gun/syringe/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>[syringes.len] / [max_syringes] syringes.</span>")

/obj/item/weapon/gun/syringe/isHandgun()
	return FALSE

/obj/item/weapon/gun/syringe/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I
		if(S.mode != 2)//SYRINGE_BROKEN in syringes.dm
			if(syringes.len < max_syringes)
				if(user.drop_item(I, src))
					syringes += I
					to_chat(user, "<span class='notice'>You put the syringe in [src].</span>")
					to_chat(user, "<span class='notice'>[syringes.len] / [max_syringes] syringes.</span>")
					investigation_log(I_CHEMS, "was loaded with \a [I] by [key_name(user)], containing [I.reagents.get_reagent_ids(1)]")
			else
				to_chat(user, "<span class='warning'>[src] cannot hold more syringes.</span>")
		else
			to_chat(user, "<span class='warning'>This syringe is broken!</span>")

		return 1 // Avoid calling the syringe's afterattack()

/obj/item/weapon/gun/syringe/afterattack(obj/target, mob/user , flag)
	if(target == user)
		return
	..()

/obj/item/weapon/gun/syringe/canbe_fired()
	return syringes.len

/obj/item/weapon/gun/syringe/can_discharge()
	return canbe_fired()

/obj/item/weapon/gun/syringe/can_hit(var/mob/living/target as mob, var/mob/living/user as mob)
	return 1		//SHOOT AND LET THE GOD GUIDE IT (probably will hit a wall anyway)

/obj/item/weapon/gun/syringe/process_chambered()
	if(canbe_fired())
		if(!in_chamber)
			var/S = syringes[1]
			in_chamber = new /obj/item/projectile/bullet/syringe(src, S)
			syringes -= S
			qdel(S)
		return 1

/obj/item/weapon/gun/syringe/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	if(clumsy_check(user))
		if(prob(50))
			to_chat(user, "<span class='warning'>You accidentally shoot yourself!</span>")
			var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
			if((!S) || (!S.reagents))
				to_chat(user, "<span class='notice'>Thankfully, nothing happens.</span>")
				return
			syringes -= S
			S.reagents.trans_to(user, S.reagents.total_volume)
			qdel(S)
			return
	..()

/obj/item/weapon/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to four syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 4
