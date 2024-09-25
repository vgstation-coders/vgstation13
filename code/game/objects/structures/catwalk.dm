/obj/structure/catwalk
	icon = 'icons/turf/catwalks.dmi'
	icon_state = "catwalk0"
	name = "catwalk"
	desc = "Cats really don't like these things."
	density = 0
	anchored = 1.0
	plane = ABOVE_PLATING_PLANE
	layer = CATWALK_LAYER

/obj/structure/catwalk/canSmoothWith()
	return 1

/obj/structure/catwalk/relativewall()
	icon_state = "catwalk[..()]"

/obj/structure/catwalk/isSmoothableNeighbor(atom/A)
	return !istype(A, /turf/space) && istype(A, /obj/structure/catwalk)

/obj/structure/catwalk/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(75))
				qdel(src)
			else
				make_lattice()
		if(3.0)
			if(prob(10))
				make_lattice()

/obj/structure/catwalk/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	if(C.is_screwdriver(user))
		to_chat(user, "<span class='notice'>You begin undoing the screws holding the catwalk together.</span>")
		C.playtoolsound(src, 80)
		if(do_after(user, src, 30) && src)
			to_chat(user, "<span class='notice'>You finish taking taking the catwalk apart.</span>")
			make_lattice(TRUE)

/obj/structure/catwalk/proc/make_lattice(and_rods = FALSE)
	var/atom/A = new /obj/structure/lattice(src.loc)
	A.recycles_cash = recycles_cash
	if(and_rods)
		A = new /obj/item/stack/rods(src.loc, 2)
		A.recycles_cash = recycles_cash
	qdel(src)

/obj/structure/catwalk/invulnerable/ex_act()
	return

/obj/structure/catwalk/invulnerable/attackby()
	return

//For an away mission
/obj/structure/catwalk/invulnerable/hive
	plane = ABOVE_TURF_PLANE

/obj/structure/catwalk/invulnerable/hive/isSmoothableNeighbor(atom/A)
	if(istype(A, /turf/unsimulated/wall/supermatter))
		return FALSE
	return ..()
