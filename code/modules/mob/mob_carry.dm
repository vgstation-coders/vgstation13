/mob/living/proc/carry_mob(mob/living/target)
	if(!adjacent(target))
		return
	if(grab_check(target))
		return
	if(being_carried || carried_being || target.being_carried || target.carried_being)
		return

	if(target.locked_to)
		to_chat(src, "<span class='notice'>You cannot carry \the [target], \he is buckled in!</span>")
		return
	if(locked_to)
		return
	target.visible_message("<span class='danger'><b>[src] bends down to pick up [target] in a fireman's carry.</b></span>","<span class='warning'>[src] grabs you in an attempt to pick up and carry you!</span>")
	if(do_mob(src, target, 30, 10, 0))
		if(being_carried || carried_being || target.being_carried || target.carried_being)
			return
		
		var/obj/item/weapon/carry/G = getFromPool(/obj/item/weapon/carry, src, target)
		var/obj/item/weapon/carry/GG = getFromPool(/obj/item/weapon/carry, src, target)
		if(!G || !GG)	//the carry will delete itself in New if affecting is anchored
			return
		if(!put_in_any_hand_if_possible(G) || !put_in_any_hand_if_possible(GG))
			drop_item(G, force_drop = 1)
			drop_item(GG, force_drop = 1)
			returnToPool(G)
			returnToPool(GG)
			to_chat(src, "<span class='warning'>You need both hands available to carry somebody!</span>")
			return 0
		lock_atom(target)
		target.being_carried = src
		carried_being = target
		var/datum/locking_category/category = target.locked_to.get_lock_cat_for(target)
		category.flags |= LOCKED_SHOULD_LIE
		target.update_canmove()
		target.pixel_y += 15
		//category.pixel_y_offset += 15
		switch(src.dir)
			if(NORTH)
				target.plane = src.plane + 1
			else
				target.plane = src.plane - 1

		visible_message("<span class='warning'>[src] carries [target] over \his shoulders!</span>")
	return 1

/obj/item/weapon/carry
	name = "carry"
	flags = NO_ATTACK_MSG
	var/mob/carrying = null
	var/mob/carried = null
	layer = HUD_ABOVE_ITEM_LAYER
	plane = HUD_PLANE
	abstract = 1
	item_state = "carry"
	w_class = W_CLASS_HUGE
	
	
/obj/item/weapon/carry/New(atom/loc, mob/living/L)
	..()
	carrying = loc
	carried = L

	if(!L.can_be_grabbed(carrying))
		returnToPool(src)
		return 0
	if(carried && carried.anchored)
		returnToPool(src)
		return 0
	