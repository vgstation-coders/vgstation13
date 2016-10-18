/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_MEDIUM
	force = 9.0
	throwforce = 5
	throw_speed = 5
	throw_range = 20
	starting_materials = list(MAT_IRON = 1875)
	max_amount = 60
	attack_verb = list("hits", "bludgeons", "whacks")
	w_type=RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	var/active = 0

/obj/item/stack/rods/Destroy()
	..()
	if(active)
		returnToPool(active)
		active = null

/obj/item/stack/rods/can_drag_use(mob/user, turf/T)
	if(user.Adjacent(T) && T.canBuildLattice(src)) //can we place here

		if(use(1)) //place and use rod
			return 1
		else
			returnToPool(active) //otherwise remove the draggable screen
			active = null

/obj/item/stack/rods/drag_use(mob/user, turf/T)
	playsound(T, 'sound/weapons/Genhit.ogg', 25, 1)
	new /obj/structure/lattice(T)

/obj/item/stack/rods/end_drag_use()
	active = null

/obj/item/stack/rods/dropped()
	..()
	if(active)
		returnToPool(active)
		active = null

/obj/item/stack/rods/afterattack(atom/Target, mob/user, adjacent, params)
	var/busy = 0
	if(adjacent)
		if(isturf(Target) || istype(Target, /obj/structure/lattice))
			var/turf/T = get_turf(Target)
			var/obj/structure/lattice/L = T.canBuildCatwalk(src)
			if(istype(L))
				if(amount < 2)
					to_chat(user, "<span class='warning'>You need atleast 2 rods to build a catwalk!</span>")
					return
				if(busy) //We are already building a catwalk, avoids stacking catwalks
					return
				to_chat(user, "<span class='notice'>You begin to build a catwalk.</span>")
				busy = 1
				if(do_after(user, Target, 30))
					busy = 0
					if(amount < 2)
						to_chat(user, "<span class='warning'>You ran out of rods!</span>")
						return
					if(!istype(L) || L.loc != T)
						to_chat(user, "<span class='warning'>You need a lattice first!</span>")
						return
					playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You build a catwalk!</span>")
					use(2)
					new /obj/structure/catwalk(T)
					qdel(L)
					return

			if(T.canBuildLattice(src))
				to_chat(user, "<span class='notice'>Constructing support lattice ...</span>")
				playsound(get_turf(src), 'sound/weapons/Genhit.ogg', 50, 1)
				new /obj/structure/lattice(T)
				use(1)
				return

/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W

		if(amount < 2)
			to_chat(user, "<span class='warning'>You need at least two rods to do this.</span>")
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal)
			M.amount = 1
			M.forceMove(get_turf(usr)) //This is because new() doesn't call forceMove, so we're forcemoving the new sheet to make it stack with other sheets on the ground.
			user.visible_message("<span class='warning'>[src] is shaped into metal by [user.name] with the welding tool.</span>", \
			"<span class='warning'>You shape the [src] into metal with the welding tool.</span>", \
			"<span class='warning'>You hear welding.</span>")
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(2)
			if (!R && replace)
				user.put_in_hands(M)
		return 1
	return ..()


/obj/item/stack/rods/attack_self(mob/user as mob)
	src.add_fingerprint(user)

	if(!active) //Start click drag construction
		active = getFromPool(/obj/screen/draggable, src, user)
		to_chat(user, "Beginning lattice construction mode, click and hold to use. Use rods again to create grille.")
		return
	else //End click drag construction, create grille
		returnToPool(active)

	if(!istype(user.loc, /turf))
		return 0

	if(locate(/obj/structure/grille, user.loc))
		for(var/obj/structure/grille/G in user.loc)
			if(G.broken)
				G.health = initial(G.health)
				G.healthcheck()
				use(1)
			else
				return 1
	else
		if(amount < 2)
			to_chat(user, "<span class='notice'>You need at least two rods to do this.</span>")
			return

		to_chat(user, "<span class='notice'>Assembling grille...</span>")

		if(!do_after(user, get_turf(src), 10))
			return

		var/obj/structure/grille/Grille = getFromPool(/obj/structure/grille, user.loc)
		if(!Grille)
			Grille = new(user.loc)
		to_chat(user, "<span class='notice'>You assembled a grille!</span>")
		Grille.add_fingerprint(user)
		use(2)
