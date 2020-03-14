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
	hitsound = "swing_hit"

/obj/item/weapon/storage/briefcase/centcomm
	icon_state = "briefcase-centcomm"

/obj/item/weapon/storage/briefcase/biogen
	desc = "Smells faintly of potato."

/obj/item/weapon/storage/briefcase/suicide_act(mob/user)
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
	..()

/obj/item/weapon/storage/briefcase/afterattack(var/atom/target, var/mob/user, var/proximity_flag, var/click_parameters)
	if(!proximity_flag)
		return

	if (!isliving(target))
		return

	var/mob/living/M = target

	if (M.stat == CONSCIOUS && M.health < 50)
		if(prob(90))
			if ((istype(M, /mob/living/carbon/human) && istype(M, /obj/item/clothing/head) && M.flags & 8 && prob(80)))
				to_chat(M, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
				return
			var/time = rand(2, 6)
			if (prob(75))
				M.Paralyse(time)
			else
				M.Stun(time)
			M.stat = UNCONSCIOUS
			M.visible_message("<span class='danger'>\The [M] has been knocked unconscious by \the [user]!</span>", "<span class='danger'>You have been knocked unconscious!</span>", "<span class='warning'>You hear someone fall.</span>")
		else
			M.visible_message("<span class='warning'>\The [user] tried to knock \the [M] unconcious!</span>", "<span class='warning'>\The [user] tried to knock you unconcious!</span>")
			M.eye_blurry += 3

/obj/item/weapon/storage/briefcase/false_bottomed
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. This one feels a bit heavier than normal for how much fits in it."
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

/obj/item/weapon/storage/briefcase/false_bottomed/Destroy()
	if(stored_item)//since the stored_item isn't in the briefcase' contents we gotta remind the game to delete it here.
		qdel(stored_item)
		stored_item = null
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
	var/obj/item/weapon/gun/projectile/automatic/SMG = new
	SMG.gun_flags &= ~AUTOMAGDROP //dont want to drop mags in null space, do we?
	stored_item = SMG

/obj/item/weapon/storage/briefcase/bees
	var/released = FALSE

/obj/item/weapon/storage/briefcase/bees/show_to(mob/user as mob)
	if(!released)
		release(user)
	..()

//You can hit someone with the briefcase, and the bees will swarm at them
/obj/item/weapon/storage/briefcase/bees/afterattack(var/atom/target, var/mob/user, var/proximity_flag, var/click_parameters)
	if(!proximity_flag)
		return

	if (!isliving(target))
		return

	if(!released)
		release(target)

//The bees will attack whoever opens the briefcase
/obj/item/weapon/storage/briefcase/bees/proc/release(var/mob/user)
	released = TRUE
	visible_message("<span class='danger'>A swarm of bees pours out of \the [src]!</span>")
	var/mob/living/simple_animal/bee/swarm/BEES = new(get_turf(src))
	BEES.forceMove(user.loc)
	BEES.target = user
