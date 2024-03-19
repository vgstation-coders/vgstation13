/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/backpacks_n_bags.dmi', "right_hand" = 'icons/mob/in-hand/right/backpacks_n_bags.dmi')
	icon_state = "briefcase"
	flags = FPRINT
	siemens_coefficient = 1
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_LARGE
	fits_max_w_class = W_CLASS_MEDIUM
	max_combined_w_class = 16
	autoignition_temperature = AUTOIGNITION_ORGANIC //fancy leather briefcases
	hitsound = "swing_hit"
	var/obj/item/weapon/handcuffs/casecuff = null

/obj/item/weapon/storage/briefcase/centcomm
	icon_state = "briefcase-centcomm"

/obj/item/weapon/storage/briefcase/biogen
	desc = "Smells faintly of potato."

/obj/item/weapon/storage/briefcase/orderly
	name = "orderly briefcase"
	desc = "A briefcase with a medical cross emblazoned on each side. It has a faintly sterile smell to it."
	icon_state = "medbriefcase"

/obj/item/weapon/storage/briefcase/orderly/New()
	..()
	new /obj/item/weapon/cookiesynth/lollicheap(src)
	for (var/i = 1 to 4)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/paralytic_injector(src)

/obj/item/weapon/storage/briefcase/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'><b>[user] is smashing \his head inside the [src.name]! It looks like \he's  trying to commit suicide!</b></span>")
	return (SUICIDE_ACT_BRUTELOSS)

/obj/item/weapon/storage/briefcase/centcomm/New()
	..()
	new /obj/item/weapon/paper/demotion_key(src)
	new /obj/item/weapon/paper/commendation_key(src)
	new /obj/item/weapon/pen/NT(src)

/obj/item/weapon/storage/briefcase/attack(mob/living/M as mob, mob/living/user as mob)
	if (clumsy_check(user) && prob(50))
		to_chat(user, "<span class='warning'>The [src] slips out of your hand and hits your head.</span>")
		user.take_organ_damage(10)
		user.Paralyse(2)
		playsound(src, "swing_hit", 50, 1, -1)
		return

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user
		M.assaulted_by(user)

	var/t = user.zone_sel.selecting
	if (t == LIMB_HEAD)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.stat < DEAD && H.health < 50 && prob(90))
				if ((H.head && istype(H.head, /obj/item/clothing/head/helmet)) && prob(80))
					to_chat(H, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
					return
				var/time = rand(2, 6)
				if (prob(75) && !H.stat && !(M.status_flags & BUDDHAMODE))
					user.do_attack_animation(H, src)
					playsound(H, hitsound, 50, 1, -1)
					user.visible_message("<span class='danger'><B>[H] has been knocked unconscious!</B>", "<span class='warning'>You knock [H] unconscious!</span></span>")
					H.Paralyse(time)
					H.stat = UNCONSCIOUS
					return
				else
					H.eye_blurry += 3
			if(H.stat < UNCONSCIOUS)
				H.visible_message("<span class='warning'>[user] tried to knock [H] unconscious!</span>", "<span class='warning'>[user] tried to knock you unconscious!</span>")	
	return ..()

/obj/item/weapon/storage/briefcase/MouseDropFrom(atom/over_object)
	if(istype(over_object,/mob/living/carbon/human))
		var/mob/living/carbon/human/target = over_object
		if(target.is_holding_item(src) && !target.stat && !target.restrained())
			if(cant_drop && !casecuff) //so you can't bypass glue this way
				..()
				return
			if(casecuff)
				playsound(target.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)
				target.visible_message("<span class='notice'>\The [target] uncuffs \the [src] from \his wrist.</span>", "<span class='notice'>You uncuff \the [src] from your wrist.</span>", "<span class='notice'>You hear two ratcheting clicks.</span>")
				casecuff.forceMove(target) //Exited() gets called, stuff happens there
			else
				if(!target.mutual_handcuffs && target.find_held_item_by_type(/obj/item/weapon/handcuffs)) //need handcuffs in their hands to do this
					var/cuffslot = target.find_held_item_by_type(/obj/item/weapon/handcuffs)
					var/obj/item/weapon/handcuffs/cuffinhand = target.held_items[cuffslot]
					if(target.drop_item(cuffinhand, src))
						casecuff = cuffinhand
						playsound(target.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)
						target.visible_message("<span class='notice'>\The [target] cuffs \the [src] to \his wrist with \the [casecuff].</span>", "<span class='notice'>You cuff \the [src] to your wrist with \the [casecuff].</span>", "<span class='notice'>You hear two ratcheting clicks.</span>")
						if(istype(casecuff, /obj/item/weapon/handcuffs/syndicate))
							var/obj/item/weapon/handcuffs/syndicate/syncuff = casecuff
							if(syncuff.mode == SYNDICUFFS_ON_APPLY && !syncuff.charge_detonated)
								if(syncuff.charge_detonated) //this is bad but syndicuffs are not meant for this sort of stuff
									return
								syncuff.charge_detonated = TRUE
								sleep(3)
								explosion(get_turf(target), 0, 1, 3, 0)
								QDEL_NULL(casecuff)
								return
						canremove = 0 //can't drop the case
						cant_drop = 1
						target.mutual_handcuffs = casecuff
						casecuff.invisibility = INVISIBILITY_MAXIMUM
						var/obj/abstract/Overlays/O = target.obj_overlays[HANDCUFF_LAYER]
						O.icon = 'icons/obj/cuffs.dmi'
						O.icon_state = "singlecuff[cuffslot]"
						O.pixel_x = target.species.inventory_offsets["[cuffslot]"]["pixel_x"] * PIXEL_MULTIPLIER
						O.pixel_y = target.species.inventory_offsets["[cuffslot]"]["pixel_y"] * PIXEL_MULTIPLIER
						target.obj_to_plane_overlay(O,HANDCUFF_LAYER)
						close_all()
						storage_locked = TRUE
				else
					to_chat(target, "<span class='warning'>You can't cuff \the [src] to your wrist without something to cuff with.</span>")

	..()
	return

/obj/item/weapon/storage/briefcase/Exited(atom/movable/Obj) //the casecuffs are stored invisibly in the case
	if(casecuff && Obj == casecuff)  //when stripped, they get forcemoved from the case, that's why this works
		var/mob/living/carbon/human/target = loc
		target.mutual_handcuffs = null
		target.overlays -= target.obj_overlays[HANDCUFF_LAYER]
		casecuff.invisibility = initial(casecuff.invisibility)
		canremove = 1
		cant_drop = 0
		casecuff.forceMove(target.loc) //otherwise the cuff copy ghosts show up
		casecuff.on_restraint_removal(target) //for syndicuffs
		casecuff = null
		storage_locked = FALSE
	..()

/obj/item/weapon/storage/briefcase/dropped(mob/user)
	..()
	if(casecuff)
		var/mob/living/carbon/human/uncuffed = user
		uncuffed.mutual_handcuffs = null
		uncuffed.overlays -= uncuffed.obj_overlays[HANDCUFF_LAYER]
		casecuff.invisibility = 0
		casecuff.forceMove(user.loc)
		canremove = 1
		cant_drop = 0
		casecuff.on_restraint_removal(uncuffed) //for syndicuffs
		casecuff = null
		storage_locked = FALSE

/obj/item/weapon/storage/briefcase/false_bottomed
	name = "briefcase"
	icon_state = "briefcase"
	force = 8.0
	throw_speed = 1
	throw_range = 3
	w_class = W_CLASS_LARGE
	fits_max_w_class = W_CLASS_SMALL
	max_combined_w_class = 10

	var/busy_hunting = 0
	var/bottom_open = 0 //is the false bottom open?
	var/obj/item/stored_item = null //what's in the false bottom. If it's a gun, we can fire it

/obj/item/weapon/storage/briefcase/false_bottomed/examine(mob/user)
	..()
	if(user.is_holding_item(src))
		to_chat(user, "<span class='notice'>This one feels a bit heavier than normal for how much fits in it.</span>")

/obj/item/weapon/storage/briefcase/false_bottomed/Destroy()
	if(stored_item)//since the stored_item isn't in the briefcase' contents we gotta remind the game to delete it here.
		QDEL_NULL(stored_item)
	..()

/obj/item/weapon/storage/briefcase/false_bottomed/afterattack(var/atom/A, mob/user)
	..()
	if(stored_item && istype(stored_item, /obj/item/weapon/gun) && get_dist(A, user) > 1)
		var/obj/item/weapon/gun/stored_gun = stored_item
		stored_gun.Fire(A, user)
	return

/obj/item/weapon/storage/briefcase/false_bottomed/attackby(var/obj/item/item, mob/user)
	if(item.is_screwdriver(user))
		if(!bottom_open && !busy_hunting)
			to_chat(user, "You begin to hunt around the rim of \the [src]...")
			busy_hunting = 1
			if(do_after(user, src, 20))
				if(user)
					to_chat(user, "You pry open the false bottom!")
				bottom_open = 1
			busy_hunting = 0
		else if(bottom_open)
			to_chat(user, "You push the false bottom down and close it with a click[stored_item ? ", with \the [stored_item] snugly inside." : "."]")
			bottom_open = 0
	else if(bottom_open)
		if(stored_item)
			to_chat(user, "<span class='warning'>There's already something in the false bottom!</span>")
			return
		if(item.w_class > W_CLASS_MEDIUM)
			to_chat(user, "<span class='warning'>\The [item] is too big to fit in the false bottom!</span>")
			return
		if(!user.drop_item(item))
			user << "<span class='warning'>\The [item] is stuck to your hands!</span>"
			return

		stored_item = item
		fits_max_w_class = W_CLASS_MEDIUM - stored_item.w_class
		item.forceMove(null) //null space here we go - to stop it showing up in the briefcase
		to_chat(user, "You place \the [item] into the false bottom of the briefcase.")
	else
		return ..()

/obj/item/weapon/storage/briefcase/false_bottomed/attack_hand(mob/user)
	if(bottom_open && stored_item)
		user.put_in_hands(stored_item)
		to_chat(user, "You pull out \the [stored_item] from \the [src]'s false bottom.")
		stored_item = null
		fits_max_w_class = initial(fits_max_w_class)
	else
		return ..()


/obj/item/weapon/storage/briefcase/false_bottomed/smg


/obj/item/weapon/storage/briefcase/false_bottomed/smg/New()
	..()
	var/obj/item/weapon/gun/projectile/automatic/uzi/bigmag/SMG = new
	SMG.gun_flags &= ~AUTOMAGDROP //dont want to drop mags in null space, do we?
	stored_item = SMG

/obj/item/weapon/storage/briefcase/bees
	var/released = FALSE

/obj/item/weapon/storage/briefcase/bees/show_to(mob/user as mob)
	..()
	if(!isliving(user) || user.stat)
		return
	if(!released)
		release(user)

//You can hit someone with the briefcase, and the bees will swarm at them
/obj/item/weapon/storage/briefcase/bees/afterattack(var/atom/target, var/mob/user, var/proximity_flag, var/click_parameters)
	if(!proximity_flag)
		return

	if (!isliving(target))
		return

	if(!released)
		release(target)

//The bees will attack whoever opens the briefcase or gets whacked with it
/obj/item/weapon/storage/briefcase/bees/proc/release(var/mob/user)
	released = TRUE
	visible_message("<span class='danger'>A swarm of bees pours out of \the [src]!</span>")
	var/mob/living/simple_animal/bee/swarm/BEES = new(get_turf(src))
	BEES.forceMove(user.loc)
	BEES.target = user
	BEES.AttackTarget()
