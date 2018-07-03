/obj/item/weapon/gun/akimbo
	name = "akimbo weapons"
	var/obj/item/weapon/gun/left
	var/obj/item/weapon/gun/right
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND

/obj/item/weapon/gun/akimbo/New(loc, var/obj/item/weapon/gun/in_left, var/obj/item/weapon/gun/in_right)
	left = in_left
	right = in_right
	name = "\a [in_left] and \a [in_right]"
	..()

/obj/item/weapon/gun/akimbo/dropped(mob/user)
	Break()
	..()

/obj/item/weapon/gun/akinbo/pickup(mob/user)
	update_icon(user)

/obj/item/weapon/gun/akimbo/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if(flag)
		return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(wielded)
		Fire(A,user,params, "struggle" = struggle)
	else
		to_chat(user, "<span class='warning'>You must dual-wield \the [src] before you can fire it!</span>")

/obj/item/weapon/gun/akimbo/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0, var/use_shooter_turf = FALSE)
	if(!(left.Fire(target,user,params,reflex,struggle,use_shooter_turf)) || !(right.Fire(target,user,params,reflex,struggle,use_shooter_turf)))
		Break()
		return
	update_icon(user)

/obj/item/weapon/gun/akimbo/proc/Break()
	var/mob/living/user = isliving(loc)? loc : null
	if(left && right)
		left.forceMove(get_turf(src))
		right.forceMove(get_turf(src))
		if(user)
			user.drop_item(src, force_drop = TRUE)
			user.put_in_hands(left)
			user.put_in_hands(right)
		left = null
		right = null
	qdel(src)

/obj/item/weapon/gun/akimbo/update_icon(mob/user)
	//right over left
	icon = left.icon
	icon_state = left.icon_state
	item_state = left.item_state
	if(inhand_states != left.inhand_states)
		inhand_states = left.inhand_states
	overlays += image("icon" = right.icon, "icon_state" = right.icon_state, "pixel_x" = 6, "pixel_y" = -5)
	if(wielded)
		wielded.icon = right.icon
		wielded.icon_state = right.icon_state
		wielded.item_state = right.item_state
		if(wielded.inhand_states != right.inhand_states)
			wielded.inhand_states = right.inhand_states
	if(user)
		user.update_inv_hands()