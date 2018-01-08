/*
	Telekinesis

	This needs more thinking out, but I might as well.
*/
var/const/tk_maxrange = 15

/*
	Telekinetic attack:

	By default, emulate the user's unarmed attack
*/
/atom/proc/attack_tk(mob/user)
	if(user.stat)
		return
	user.UnarmedAttack(src,0) // attack_hand, attack_paw, etc

/*
	This is similar to item attack_self, but applies to anything
	that you can grab with a telekinetic grab.

	It is used for manipulating things at range, for example, opening and closing closets.
	There are not a lot of defaults at this time, add more where appropriate.
*/
/atom/proc/attack_self_tk(mob/user)

/obj/attack_tk(mob/user)
	if(user.stat)
		return
	if(anchored)
		..()
		return

	var/obj/item/tk_grab/O = new(src)
	if(user.put_in_hands(O))
		O.host = user
		O.focus_object(src)
	else
		to_chat(user, "<span class='warning'>You have to wave your hands around to use the Force.</span>")
	return

/obj/item/attack_tk(mob/user)
	if(user.stat || !isturf(loc))
		return
	if((M_TK in user.mutations) && !user.get_active_hand()) // both should already be true to get here
		var/obj/item/tk_grab/O = new(src)
		if(user.put_in_hands(O))
			O.host = user
			O.focus_object(src)
		else
			to_chat(user, "<span class='warning'>You have to wave your hands around to use the Force.</span>")
	else
		warning("Strange attack_tk(): TK([M_TK in user.mutations]) empty hand([!user.get_active_hand()])")

/mob/attack_tk(mob/user) // needs more thinking about

/*
	TK Grab Item (the workhorse of old TK)

	* If you have not grabbed something, do a normal tk attack
	* If you have something, throw it at the target.  If it is already adjacent, do a normal attackby()
	* If you click what you are holding, or attack_self(), do an attack_self_tk() on it.
	* Deletes itself if it is ever not in your hand, or if you should have no access to TK.
*/
/obj/item/tk_grab
	name = "The Force"
	desc = "Magic"
	icon = 'icons/obj/magic.dmi'//Needs sprites
	icon_state = "2"
	flags = NO_ATTACK_MSG
	//item_state = null
	w_class = W_CLASS_GIANT
	layer = HUD_ITEM_LAYER
	plane = HUD_PLANE
	abstract = 1

	var/last_throw = 0
	var/atom/movable/focus = null
	var/mob/living/host = null


/obj/item/tk_grab/dropped(mob/user as mob)
	if(focus && user && loc != user && loc != user.loc) // drop_item(null, ) gets called when you tk-attack a table/closet with an item
		if(focus.Adjacent(loc))
			focus.forceMove(loc)
	qdel(src)


	//stops TK grabs being equipped anywhere but into hands
/obj/item/tk_grab/equipped(var/mob/user, var/slot, hand_index)
	if(hand_index)
		return
	qdel(src)

/obj/item/tk_grab/attack_self(mob/user as mob)
	if(focus)
		focus.attack_self_tk(user)

/obj/item/tk_grab/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, proximity, params)//TODO: go over this
	if(user)
		user.delayNextAttack(8)
	if(!target || !user)
		return
	if(last_throw+3 > world.time)
		return
	if(!host || host != user)
		qdel(src)
		return
	if(!(M_TK in host.mutations))
		qdel(src)
		return
	if(isobj(target) && !isturf(target.loc))
		return
	var/d = get_dist(user, target)
	if(focus)
		d = max(d,get_dist(user,focus)) // whichever is further

	/*switch(d)
		if(0)
			;
		if(1 to 5) // not adjacent may mean blocked by window
			if(!proximity)
				user.next_move += 2
		if(5 to 7)
			user.next_move += 5
		if(8 to tk_maxrange)
			user.next_move += 10
		else
			to_chat(user, "<span class='notice'>Your mind won't reach that far.</span>")
			return*/

	if(d > tk_maxrange)
		to_chat(user, "<span class='warning'>Your mind won't reach that far.</span>")
		return

	if(!focus)
		focus_object(target, user)
		return

	if(target == focus)
		target.attack_self_tk(user)
		return // todo: something like attack_self not laden with assumptions inherent to attack_self

	if(!istype(target, /turf) && istype(focus,/obj/item) && target.Adjacent(focus))
		var/obj/item/I = focus
		var/isb = I.siemens_coefficient
		var/ipb = I.permeability_coefficient
		I.siemens_coefficient = 0
		I.permeability_coefficient = 0.05
		var/resolved = target.attackby(I, user, params)
		if(!resolved && target && I)
			I.afterattack(target,user,1,params) // for splashing with beakers
		I.siemens_coefficient = isb
		I.permeability_coefficient =ipb

	else
		apply_focus_overlay()
		focus.throw_at(target, 10, 1)
		last_throw = world.time
		return

/obj/item/tk_grab/attack(mob/living/M as mob, mob/living/user as mob, def_zone)

/obj/item/tk_grab/proc/focus_object(var/obj/target, var/mob/living/user)
	if(!istype(target,/obj))
		return//Cant throw non objects atm might let it do mobs later
	if(target.anchored || !isturf(target.loc))
		qdel(src)
		return
	focus = target
	update_icon()
	apply_focus_overlay()

/obj/item/tk_grab/proc/apply_focus_overlay()
	if(!focus)
		return
	var/obj/effect/overlay/O = new /obj/effect/overlay(locate(focus.x,focus.y,focus.z))
	O.name = "sparkles"
	O.anchored = 1
	O.setDensity(FALSE)
	O.layer = FLY_LAYER
	O.plane = EFFECTS_PLANE
	O.dir = pick(cardinal)
	O.icon = 'icons/effects/effects.dmi'
	O.icon_state = "nothing"
	flick("empdisable",O)
	spawn(5)
		qdel(O)


/obj/item/tk_grab/update_icon()
	overlays.len = 0
	if(focus && focus.icon && focus.icon_state)
		overlays += icon(focus.icon,focus.icon_state)

/*Not quite done likely needs to use something thats not get_step_to
/obj/item/tk_grab/proc/check_path()
	var/turf/ref = get_turf(src.loc)
	var/turf/target = get_turf(focus.loc)
	if(!ref || !target)
		return 0
	var/distance = get_dist(ref, target)
	if(distance >= 10)
		return 0
	for(var/i = 1 to distance)
		ref = get_step_to(ref, target, 0)
	if(ref != target)
		return 0
	return 1
*/

///obj/item/tk_grab/equip_to_slot_or_del(obj/item/W, slot, del_on_fail = 1)
/*
	if(istype(user, /mob/living/carbon))
		if((user:mutations & M_TK) && get_dist(source, user) <= 7)
			if(user:get_active_hand())
				return 0
			var/X = source:x
			var/Y = source:y
			var/Z = source:z
*/
