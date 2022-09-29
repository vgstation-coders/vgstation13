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
	var/static/list/smoothables = list(/obj/structure/catwalk)
	return smoothables

/obj/structure/catwalk/relativewall()
	icon_state = "catwalk[..()]"

/obj/structure/catwalk/isSmoothableNeighbor(atom/A)

	if(istype(A, /turf/space))
		return 0
	return ..()

/obj/structure/catwalk/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(75))
				qdel(src)
			else
				new /obj/structure/lattice(src.loc)
				qdel(src)
		if(3.0)
			if(prob(10))
				new /obj/structure/lattice(src.loc)
				qdel(src)

/obj/structure/catwalk/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	if(C.is_screwdriver(user))
		to_chat(user, "<span class='notice'>You begin undoing the screws holding the catwalk together.</span>")
		C.playtoolsound(src, 80)
		if(do_after(user, src, 30) && src)
			to_chat(user, "<span class='notice'>You finish taking taking the catwalk apart.</span>")
			new /obj/item/stack/rods(src.loc, 2)
			new /obj/structure/lattice(src.loc)
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
