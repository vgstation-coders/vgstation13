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
		QDEL_NULL(active)

/obj/item/stack/rods/can_drag_use(mob/user, turf/T)
	if(user.Adjacent(T) && T.canBuildLattice(src)) //can we place here

		if(use(1)) //place and use rod
			return 1
		else
			QDEL_NULL(active) //otherwise remove the draggable screen

/obj/item/stack/rods/drag_use(mob/user, turf/T)
	playsound(T, 'sound/weapons/Genhit.ogg', 25, 1)
	new /obj/structure/lattice(T)

/obj/item/stack/rods/end_drag_use()
	active = null

/obj/item/stack/rods/dropped()
	..()
	if(active)
		QDEL_NULL(active)

/obj/item/stack/rods/afterattack(atom/Target, mob/user, adjacent, params)
	var/busy = 0
	if(adjacent)
		if(isturf(Target) || istype(Target, /obj/structure/lattice))
			var/turf/T = get_turf(Target)
			var/obj/structure/lattice/L = T.canBuildCatwalk(src)
			if(istype(L))
				if(busy) //We are already building a catwalk, avoids stacking catwalks
					return
				to_chat(user, "<span class='notice'>You begin to build a catwalk.</span>")
				busy = 1
				if(do_after(user, Target, 15))
					busy = 0
					if(!istype(L) || L.loc != T)
						to_chat(user, "<span class='warning'>You need a lattice first!</span>")
						return
					playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You build a catwalk!</span>")
					use(1)
					new /obj/structure/catwalk(T)
					qdel(L)
					return

			if(T.canBuildLattice(src))
				to_chat(user, "<span class='notice'>Constructing support lattice ...</span>")
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				new /obj/structure/lattice(T)
				use(1)
				return

/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W

		if(amount < 2)
			to_chat(user, "<span class='warning'>You need at least two rods to do this.</span>")
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal
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
		active = new /obj/abstract/screen/draggable(src, user)
		to_chat(user, "Beginning lattice construction mode, click and hold to use. Use rods again to create grille.")
		return
	else //End click drag construction, create grille
		qdel(active)

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

		var/obj/structure/grille/Grille = new /obj/structure/grille(user.loc)
		if(!Grille)
			Grille = new(user.loc)
		to_chat(user, "<span class='notice'>You assembled a grille!</span>")
		Grille.add_fingerprint(user)
		use(2)


/obj/item/stack/chains
	name = "chain"
	desc = "link by link, my chain got longer."
	icon_state = "chains"
	singular_name = "chain"
	irregular_plural = "chains"
	max_amount = 20
	w_type = RECYK_METAL

/obj/item/stack/chains/can_stack_with(var/obj/item/other_stack)
	if(!ispath(other_stack) && istype(other_stack) && other_stack.material_type == material_type)
		return ..()
	return 0

/obj/item/stack/chains/New(var/loc, var/amount=null)
	recipes = chain_recipes
	..()

var/list/datum/stack_recipe/chain_recipes = list (
	new/datum/stack_recipe/blacksmithing("Suit of Chainmail",		/obj/item/clothing/suit/armor/vest/chainmail,					10,	time = 100,required_strikes = 15),
	new/datum/stack_recipe/blacksmithing("Chainmail Coif",		/obj/item/clothing/head/helmet/chainmail,					5,	time = 100,required_strikes = 15),
	)


/obj/item/stack/telecrystal
	name = "refined telecrystals"
	singular_name = "telecrystal"
	desc = "A method of creating an untraceable bluespace teleportation link between two points."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "ansible_crystal"
	mech_flags = MECH_SCAN_FAIL


/obj/item/stack/rcd_ammo
	name = "compressed matter cartridge"
	singular_name = "compressed matter cartridge"
	desc = "Highly compressed matter in a cartridge form, used in various fabricators."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	max_amount = 12

	origin_tech = Tc_MATERIALS + "=2"
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 20000, MAT_GLASS = 10000)
	w_type = RECYK_ELECTRONIC

/obj/item/stack/rcd_ammo/ce
	amount = 12

/obj/item/stack/rcd_ammo/attackby(var/obj/O, mob/user)
	if(is_type_in_list(O, list(/obj/item/device/rcd/matter/engineering,  /obj/item/device/rcd/matter/rsf)) || (istype(O, /obj/item/device/material_synth) && !istype(O, /obj/item/device/material_synth/robot)))
		return O.attackby(src, user)

/obj/item/stack/bolts
	name = "plasteel bolts"
	singular name = "bag of plasteel bolts"
	desc = "Plasteel bolts are used in the anchoring of structures, though they can also be applied to reinforced flooring to make it difficult to crawl across."
	icon_state = "bagofbolts"
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_SMALL
	force = 3
	throwforce = 9
	throw_speed = 5
	throw_range = 20
	starting_materials = list(MAT_IRON = 1875, MAT_PLASMA = 1875)
	max_amount = 12
	attack_verb = list("bolts")
	w_type=RECYK_METAL
	melt_temperature = MELTPOINT_PLASMA

/obj/item/stack/bolts/attackby(var/obj/O, mob/user)
	if(istype(O, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = O
		new /obj/item/clothing/head/franken_bolt(get_turf(src))
		C.use(1)
		use(1)
	else
		..()


/obj/item/stack/bolts/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return 1
	if(istype(target, /obj/structure))
		var/obj/structure/S = target
		if(!S.anchored)
			S.hasbolts = TRUE
			S.anchored = TRUE
			to_chat(user, "<span class='notice'>You bolt \the [target] into place.</span>")
			use(1)
			return 1
	return..()