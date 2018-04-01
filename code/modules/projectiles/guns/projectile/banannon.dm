/obj/item/weapon/gun/banannon
	name = "banannon"
	desc = "The most fearsome weapon ever wielded by clown mercenaries."
	icon = 'icons/obj/gun.dmi'
	icon_state = "banannon"
	item_state = "banannon"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	recoil = 0
	slot_flags = SLOT_BELT
	flags = FPRINT
	w_class = W_CLASS_MEDIUM
	fire_delay = 0
	fire_sound = null
	clumsy_check = 0
	var/max_ammo = 10
	var/current_ammo = 10

/obj/item/weapon/gun/banannon/New()
	..()
	chamber_if_possible()

/obj/item/weapon/gun/banannon/update_icon()
	if(current_ammo >= max_ammo)
		icon_state = initial(icon_state)
	else if(current_ammo <= 0)
		icon_state = "banannon_empty"
	else
		icon_state = "[initial(icon_state)]_[round((current_ammo/max_ammo) * 10)]"

/obj/item/weapon/gun/banannon/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has [current_ammo] round\s remaining.</span>")

/obj/item/weapon/gun/banannon/proc/chamber_if_possible()
	if(current_ammo > 0)
		if(!process_chambered())
			in_chamber = new /obj/item/projectile/bullet/sabonana(src)

/obj/item/weapon/gun/banannon/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if(flag)
		return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(!current_ammo)
		return click_empty(user)
	chamber_if_possible()
	if(Fire(A,user,params, struggle = struggle))
		current_ammo--
		chamber_if_possible()
	update_icon()

/obj/item/weapon/gun/banannon/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0, var/use_shooter_turf = FALSE)
	if(istype(user, /mob/living))
		var/mob/living/M = user
		if(!clumsy_check(M) && prob(50))
			to_chat(M, "<span class='danger'>\The [src] blows up in your face.</span>")
			M.take_organ_damage(0,20)
			qdel(src)
			return 0
	return ..()

/obj/item/weapon/gun/banannon/process_chambered()
	return in_chamber

/obj/item/weapon/gun/banannon/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/banana))
		if(current_ammo >= max_ammo)
			return
		if(user.drop_item(W))
			current_ammo++
			chamber_if_possible()
			playsound(src, 'sound/items/Deconstruct.ogg', 25, 1)
			qdel(W)
			update_icon()
			
/obj/item/weapon/gun/banannon/can_discharge()
	if(current_ammo)
		return 1