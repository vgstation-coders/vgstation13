//Helper object for picking dionaea (and other creatures) up.
// /obj/item/weapon/holder/animal works with ANY animal!

/obj/item/weapon/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/mob_holders.dmi', "right_hand" = 'icons/mob/in-hand/right/mob_holders.dmi')

	var/mob/stored_mob
	var/update_itemstate_on_twohand = FALSE //If there are different item states for holding this with one and two hands, this must be 1
	var/const/itemstate_twohand_suffix = "_2hand" //The item state

/obj/item/weapon/holder/New(loc, mob/M)
	..()
	processing_objects.Add(src)
	if(M)
		M.forceMove(src)

		src.stored_mob = M

/obj/item/weapon/holder/Destroy()
	//Hopefully this will stop the icon from remaining on human mobs.
	if(istype(loc,/mob/living))
		var/mob/living/A = src.loc
		A.drop_item(src, force_drop = TRUE)
		A.update_icons()

	for(var/mob/M in contents)
		M.forceMove(get_turf(src))
		if(M.client)
			M.client.eye = M

	processing_objects.Remove(src)
	..()

/obj/item/weapon/holder/supermatter_act(atom/source)
	if(stored_mob)
		stored_mob.supermatter_act(source, SUPERMATTER_DUST)
		qdel(stored_mob) //better safe than sorry, sorry mice.
	qdel(src)
	return TRUE

/obj/item/weapon/holder/process()
	if(!loc)
		return returnToPool(src)
	else if(istype(loc,/turf) || !(contents.len))
		return returnToPool(src)

/obj/item/weapon/holder/relaymove(mob/M, direction)
	returnToPool(src) //This calls Destroy(), and frees the mob

/obj/item/weapon/holder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	for(var/mob/M in src.contents)
		M.attackby(W,user)

/obj/item/weapon/holder/update_wield(mob/user)
	..()

	if(update_itemstate_on_twohand)
		item_state = "[initial(item_state)][wielded ? itemstate_twohand_suffix : ""]"

		if(user)
			user.update_inv_hands()

/obj/item/weapon/holder/kick_act(mob/user)
	..()

	if(stored_mob)
		stored_mob.kick_act(user)

/obj/item/weapon/holder/bite_act(mob/user)
	if(stored_mob)
		stored_mob.bite_act(user)

//Nymph holder

/obj/item/weapon/holder/diona
	name = "diona nymph"
	desc = "It's a tiny plant critter."
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	slot_flags = SLOT_HEAD
	origin_tech = Tc_MAGNETS + "=3;" + Tc_BIOTECH + "=5"

/obj/item/weapon/holder/diona/New(loc, mob/M)
	..()
	if(M)
		name = M.name

/obj/item/weapon/holder/animal
	name = "animal holder"
	desc = "This holder takes the mob's appearance, so it will work with any mob!"

/obj/item/weapon/holder/animal/New(loc, mob/M)
	..()
	if(M)
		appearance = M.appearance
		w_class = Clamp((M.size - SIZE_TINY) * W_CLASS_MEDIUM, W_CLASS_TINY, W_CLASS_HUGE)
		//	SIZE		|	W_CLASS

		//	SIZE_TINY	|	W_CLASS_TINY
		//	SIZE_SMALL	|	W_CLASS_MEDIUM
		//	SIZE_NORMAL	|	W_CLASS_HUGE
		//	SIZE_BIG	|	W_CLASS_HUGE
		//	SIZE_HUGE	|	W_CLASS_HUGE

		throw_range = 6 - w_class

		if(w_class > W_CLASS_SMALL)
			flags |= (TWOHANDABLE | MUSTTWOHAND)

//MICE

/obj/item/weapon/holder/animal/mouse
	name = "mouse holder"
	desc = "This one has icon states!"
	slot_flags = SLOT_HEAD
	item_state = "mouse" //Credit to Hubblenaut for sprites! https://github.com/Baystation12/Baystation12/pull/9416

/obj/item/weapon/holder/animal/mouse/New(loc, mob/M)
	..()
	if(istype(M, /mob/living/simple_animal/mouse))
		var/mob/living/simple_animal/mouse/mouse = M

		item_state = initial(mouse.icon_state) //Initial icon states are "mouse_gray", "mouse_white", etc
		if(!(item_state in list("mouse_white", "mouse_brown", "mouse_gray", "mouse_black", "mouse_plague", "mouse_balbc", "mouse_operative")))
			item_state = "mouse_gray"

//CORGI

/obj/item/weapon/holder/animal/corgi
	name = "corgi holder"
	desc = "Icon states yay!"
	item_state = "corgi"

	update_itemstate_on_twohand = TRUE

//CARP

/obj/item/weapon/holder/animal/carp
	name = "carp holder"
	item_state = "carp"

	update_itemstate_on_twohand = TRUE

//COWS

/obj/item/weapon/holder/animal/cow
	name = "cow holder"
	desc = "Pretty heavy"
	item_state = "cow"

//CATS

/obj/item/weapon/holder/animal/cat
	name = "cat holder"
	desc = "Runtime error"
	item_state = "cat1"

	update_itemstate_on_twohand = TRUE

//SALEM

/obj/item/weapon/holder/animal/salem
	name = "salem holder"
	desc = "Esp!"
	item_state = "salem"

	update_itemstate_on_twohand = TRUE

//SNAKES

/obj/item/weapon/holder/animal/snek
	name = "snake holder"
	desc = "Kept you waiting?"
	item_state = "snek"

//SLIMES
/obj/item/weapon/holder/animal/slime
	name = "slime holder"
	desc = "It seeps through your fingers"

/obj/item/weapon/holder/animal/slime/proc/unfreeze()
	var/mob/living/simple_animal/slime/S = stored_mob
	S.canmove = TRUE
	S.icon_state = "[S.colour] [istype(S,/mob/living/simple_animal/slime/adult) ? "adult" : "baby"] slime"
	returnToPool(src)

/obj/item/weapon/holder/animal/slime/throw_impact(atom/hit_atom)
	..()
	unfreeze()

/obj/item/weapon/holder/animal/slime/attack_self(mob/user)
	..()
	unfreeze()

/obj/item/weapon/holder/animal/pillow
	name = "pillow holder"
	desc = "Comforbable"
	item_state = "pillow"
	slot_flags = SLOT_HEAD
	update_itemstate_on_twohand = TRUE