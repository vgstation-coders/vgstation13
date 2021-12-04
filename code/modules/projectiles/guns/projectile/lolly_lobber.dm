/obj/item/weapon/gun/lolly_lobber
	name = "Lolly Lobber"
	desc = "A horrible combination of steel and sweets. Custom made to weaponize candy canes with questionable success."
	icon = 'icons/obj/gun.dmi'
	icon_state = "lolly_lobber"
	item_state = "redtag"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	recoil = 0
	slot_flags = SLOT_BELT
	flags = FPRINT
	w_class = W_CLASS_MEDIUM
	fire_delay = 3
	fire_sound = 'sound/items/syringeproj.ogg'
	var/max_ammo = 13 //baker's dozen
	var/current_ammo = 13

/obj/item/weapon/gun/lolly_lobber/New()
	..()
	chamber_if_possible()

/obj/item/weapon/gun/lolly_lobber/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has [current_ammo] round\s remaining.</span>")

/obj/item/weapon/gun/lolly_lobber/proc/chamber_if_possible()
	if(current_ammo > 0)
		if(!process_chambered())
			in_chamber = new /obj/item/projectile/bullet/syringe/candycane (src)

/obj/item/weapon/gun/lolly_lobber/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if(flag)
		return
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(!current_ammo)
		return click_empty(user)
	chamber_if_possible()
	if(Fire(A,user,params, struggle = struggle))
		current_ammo--
		chamber_if_possible()

/obj/item/weapon/gun/lolly_lobber/process_chambered()
	return in_chamber

/obj/item/weapon/gun/lolly_lobber/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/candy_cane))
		if(current_ammo >= max_ammo)
			return
		if(user.drop_item(W))
			current_ammo++
			chamber_if_possible()
			playsound(src, 'sound/items/Deconstruct.ogg', 25, 1)
			qdel(W)

/obj/item/weapon/gun/lolly_lobber/can_discharge()
	if(current_ammo)
		return 1
