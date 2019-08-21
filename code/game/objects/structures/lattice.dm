/obj/structure/lattice
	desc = "A lightweight support lattice."
	name = "lattice"
	icon = 'icons/obj/structures.dmi'
	icon_state = "latticefull"
	density = 0
	anchored = 1.0
	layer = LATTICE_LAYER
	plane = ABOVE_PLATING_PLANE

	//	flags = CONDUCT

/obj/structure/lattice/canSmoothWith()
	var/static/list/smoothables = list(
		/obj/structure/lattice,
		/obj/structure/catwalk,
		/turf,
	)
	return smoothables

/obj/structure/lattice/New(loc)
	..(loc)
	icon = 'icons/obj/smoothlattice.dmi'
	if(ticker && ticker.current_state >= GAME_STATE_PLAYING)
		initialize()

/obj/structure/lattice/initialize()
	relativewall()
	relativewall_neighbours()

/obj/structure/lattice/relativewall()
	var/junction = findSmoothingNeighbors()
	icon_state = "lattice[junction]"

/obj/structure/lattice/isSmoothableNeighbor(atom/A)
	if (istype(A, /turf/space))
		return 0

	return ..()

/obj/structure/lattice/blob_act()
	qdel(src)

/obj/structure/lattice/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			qdel(src)

/obj/structure/lattice/attackby(obj/item/C as obj, mob/user as mob)
	if(iswelder(C))
		var/obj/item/weapon/weldingtool/WeldingTool = C
		if(WeldingTool.remove_fuel(0, user))
			to_chat(user, "<span class='notice'>Slicing [src] joints...</span>")
			new/obj/item/stack/rods(loc)
			qdel(src)
	else
		var/turf/T = get_turf(src)
		T.attackby(C, user) //Attacking to the lattice will attack to the space turf

/obj/structure/lattice/wood/attackby(obj/item/C as obj, mob/user as mob)
	if(C.sharpness_flags & (CHOPWOOD|SERRATED_BLADE)) // If C is able to cut down a tree
		new/obj/item/stack/sheet/wood(loc)
		to_chat(user, "<span class='notice'>You chop the [src] apart!</span>")
		qdel(src)
	else
		var/turf/T = get_turf(src)
		T.attackby(C, user) //Attacking the wood will attack the turf underneath

/obj/structure/lattice/wood
	name = "wood foundations"
	desc = "It's a foundation, for building on."
	icon_state = "lattice-wood"
/obj/structure/lattice/wood/canSmoothWith()
	return null

/obj/structure/lattice/wood/New()
	return
