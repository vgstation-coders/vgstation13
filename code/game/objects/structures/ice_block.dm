/obj/structure/ice_block
	name = "block of ice"
	desc = "A sheer block of ice."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ice_block"
	plane = ABOVE_HUMAN_PLANE

/obj/structure/ice_block/New(loc, var/atom/movable/locking_to, var/lifetime = 0)
	..()
	if(lifetime)
		spawn(lifetime)
			melt()
	if(!locking_to)
		return
	locking_to.forceMove(get_turf(src))

	if(isliving(locking_to))
		var/mob/living/L = locking_to
		if(L.locked_to)
			L.locked_to = 0
			L.anchored = 0

		for(var/obj/item/I in L.held_items)
			L.drop_item(I)

		if(L.locked_to)
			L.unlock_from()

		L.delayNextAttack(lifetime)
		L.click_delayer.setDelay(lifetime)

	lock_atom(locking_to, /datum/locking_category/ice_block)

/obj/structure/ice_block/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 100)
		melt()

/obj/structure/ice_block/examine(mob/user)
	..()
	var/list/L = get_locked(/datum/locking_category/ice_block)
	if(!L.len)
		return
	var/atom/A = L[1]
	if(A)
		to_chat(user, "<span class = 'notice'>There is \a [A] frozen inside!</span>")
		if(prob(15))
			to_chat(user, "<span class = 'notice'>Boy am I glad that he's in there, and that we're out here.</span>")

/obj/structure/ice_block/melt()
	var/list/L = get_locked(/datum/locking_category/ice_block)
	if(L.len)
		var/atom/A = L[1]
		unlock_atom(A)
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.wet(10 SECONDS)
	qdel(src)

/datum/locking_category/ice_block