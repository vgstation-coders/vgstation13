///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

////////////////////////////////
// Definitions
////////////////////////////////
/datum/stack_recipe/cable_cuffs/finish_building(var/mob/usr, var/obj/item/stack/cable_coil/S, var/obj/item/weapon/handcuffs/cable/C)
	C._color = S._color
	C.update_icon()

var/global/list/datum/stack_recipe/cable_recipes = list ( \
	new/datum/stack_recipe/cable_cuffs("cable cuffs", /obj/item/weapon/handcuffs/cable, 15, time = 3, one_per_turf = 0, on_floor = 0))

#define MAXCOIL 30

/obj/item/stack/cable_coil
	name = "cable coil"
	icon = 'icons/obj/power.dmi'
	icon_state = "coil_red"
	gender = NEUTER
	amount = MAXCOIL
	restock_amount = 2
	singular_name = "cable piece"
	max_amount = MAXCOIL
	_color = "red"
	desc = "A coil of power cable."
	throwforce = 10
	w_class = W_CLASS_SMALL
	throw_speed = 2
	throw_range = 5
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL)
	w_type = RECYK_METAL
	flags =  FPRINT
	autoignition_temperature = AUTOIGNITION_PLASTIC
	siemens_coefficient = 1.5 //Extra conducting
	slot_flags = SLOT_BELT
	item_state = "coil_red"
	attack_verb = list("whips", "lashes", "disciplines", "flogs")
	toolsounds = list('sound/weapons/cablecuff.ogg')
	surgerysound = 'sound/items/fixovein.ogg'

// Noose suicides, now ported from hippie!
/obj/item/stack/cable_coil/suicide_act(var/mob/living/user)
	if(locate(/obj/item/weapon/stool) in get_turf(user))
		user.visible_message("<span class='danger'>[user] is making a noose with \the [src.name]! It looks like \he's trying to commit suicide!</span>")
	else
		user.visible_message("<span class='danger'>[user] is strangling \himself with \the [src.name]! It looks like \he's trying to commit suicide!</span>")
	return(SUICIDE_ACT_OXYLOSS)

/obj/item/stack/cable_coil/New(loc, amount, var/param_color = null)
	..()

	recipes = cable_recipes
	if(param_color)
		_color = param_color

	pixel_x = rand(-2,2) * PIXEL_MULTIPLIER
	pixel_y = rand(-2,2) * PIXEL_MULTIPLIER
	update_icon()

///////////////////////////////////
// General procedures
///////////////////////////////////

/obj/item/stack/cable_coil/preattack(atom/target, mob/user, proximity_flag, params)
	var/turf/target_turf

	if(isturf(target))
		target_turf = target
		if(!target_turf.can_place_cables())
			to_chat(user, "<span class='warning'>You can't place cables there.</span>")
			return
	else if(istype(target, /obj/structure/catwalk))
		target_turf = get_turf(target)

	if(target_turf)
		turf_place(target_turf, user)
	else
		return ..()

//You can use wires to heal robotics
/obj/item/stack/cable_coil/attack(mob/M as mob, mob/user as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/S = H.get_organ(user.zone_sel.selecting)

		if(!(S.is_robotic()) || user.a_intent != I_HELP)
			return ..()

		if(S.burn_dam > 0 && use(1))
			S.heal_damage(0, 15, 0, 1)

			if(user != H)
				user.visible_message("<span class='warning'>\The [user] repairs some burn damage on their [S.display_name] with \the [src].</span>",\
				"<span class='warning'>You repair some burn damage on your [S.display_name].</span>",\
				"<span class='warning'>You hear wires being cut.</span>")
			else
				user.visible_message("<span class='warning'>\The [user] repairs some burn damage on their [S.display_name] with \the [src].</span>",\
				"<span class='warning'>You repair some burn damage on your [S.display_name].</span>",\
				"<span class='warning'>You hear wires being cut.</span>")
		else
			to_chat(user, "<span class='warning'>There's nothing to fix on this limb!</span>")
	else
		return ..()

/obj/item/stack/cable_coil/use(var/amount)
	. = ..()
	update_icon()

/obj/item/stack/cable_coil/add(var/amount)
	. = ..()
	update_icon()

/obj/item/stack/cable_coil/can_stack_with(obj/item/other_stack)
	return istype(other_stack, /obj/item/stack/cable_coil) && !istype(other_stack, /obj/item/stack/cable_coil/heavyduty) //It can be any cable, except the fat stuff

/obj/item/stack/cable_coil/update_icon()
	if(!_color)
		_color = pick("red", "yellow", "blue", "green")

	if(amount == 1)
		icon_state = "coil_[_color]1"
		name = "cable piece"
	else if(amount == 2)
		icon_state = "coil_[_color]2"
		name = "cable piece"
	else
		icon_state = "coil_[_color]"
		name = "cable coil"

/obj/item/stack/cable_coil/examine()
	set src in view(1)

	if(amount == 1)
		to_chat(usr, "A short piece of power cable.")
	else if(amount == 2)
		to_chat(usr, "A piece of power cable.")
	else
		to_chat(usr, "A coil of power cable. There are [amount] lengths of cable in the coil.")

//Items usable on a cable coil :
// - Wirecutters : Cut a piece off
// - Cable coil : Merge the cables
/obj/item/stack/cable_coil/attackby(obj/item/weapon/W, mob/user)
	if(W.is_wirecutter(user) && (amount > 1))
		use(1)
		new /obj/item/stack/cable_coil(user.loc, 1, _color)
		to_chat(user, "<span class='notice'>You cut a piece off the cable coil.</span>")
		update_icon()
		return
	if(istype(W, /obj/item/weapon/rcl/))
		var/obj/item/weapon/rcl/O = W
		O.attackby(src, usr)
		return
	return ..()

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

//Called when cable_coil is clicked on a turf/simulated/floor
/obj/item/stack/cable_coil/proc/turf_place(turf/simulated/floor/F, mob/user, var/dirnew)
	if(!isturf(user.loc))
		return

	if(!user.Adjacent(F)) //Too far
		to_chat(user, "<span class='warning'>You can't lay cable that far away.</span>")
		return

	if(F.intact) //If floor is intact, complain
		to_chat(user, "<span class='warning'>You can't lay cable there until the floor is removed.</span>")
		return
	var/dirn = null
	if(!dirnew) //If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
		if(user.loc == F)
			dirn = user.dir //If laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(F, user)
	else
		dirn = dirnew
	for(var/obj/structure/cable/LC in F)
		if(LC.d2 == dirn && LC.d1 == 0)
			to_chat(user, "<span class='warning'>There already is a cable at that position.</span>")
			return

	var/obj/structure/cable/C = new /obj/structure/cable(F)
	C.cableColor(_color)

	//Set up the new cable
	if(isopenspace(F))
		C.d1 = dirn
		C.d2 = DOWN // It's an X-32 node cable
		var/turf/simulated/current_turf = F
		while(use(1)) // Toss this down the open space for as much as we can
			current_turf = GetBelow(current_turf)
			if(!current_turf)
				break
			var/obj/structure/cable/C2 = new /obj/structure/cable(current_turf)
			C2.cableColor(_color)
			var/turf/to_check = GetBelow(current_turf)
			if(to_check && (to_check.intact || !to_check.can_place_cables())) // Can the turf below have cables on it? Important to know if the cable should hang here.
				to_check = null
			var/leave_hanging = FALSE
			if(isopenspace(current_turf) && to_check && use(1))
				C2.d1 = UP
				C2.d2 = DOWN
			else
				C2.d1 = 0
				C2.d2 = UP
				leave_hanging = TRUE
			C2.add_fingerprint(user)
			C2.update_icon()

			//Create a new powernet with the cable, if needed it will be merged later
			var/datum/powernet/PN2 = new /datum/powernet
			PN2.add_cable(C2)

			C2.mergeZConnectedNetworks()   //Merge the powernet with above powernets
			C2.mergeConnectedNetworksOnTurf() //Merge the powernet with on turf powernets
			if(leave_hanging)
				break
	else
		C.d1 = 0 //It's a O-X node cable
		C.d2 = dirn
	C.add_fingerprint(user)
	C.update_icon()

	//Create a new powernet with the cable, if needed it will be merged later
	var/datum/powernet/PN = new /datum/powernet
	PN.add_cable(C)


	C.mergeConnectedNetworks(C.d2 == DOWN ? C.d1 : C.d2)   //Merge the powernet with adjacents powernets
	C.mergeConnectedNetworksOnTurf() //Merge the powernet with on turf powernets

	if(C.d2 & (C.d2 - 1)) //If the cable is layed diagonally, check the others 2 possible directions
		C.mergeDiagonalsNetworks(C.d2)

	if(C.d2 == UP || C.d2 == DOWN) //If the cable goes to another z-level, check the others 2 possible directions
		C.mergeZConnectedNetworks()

	use(1)

	if(arcanetampered && isliving(user))
		var/mob/living/L = user
		L.electrocute_act(30,src)
		if(prob(50)) //Fail
			new /obj/item/stack/cable_coil(C.loc, 1)
			qdel(C)
			return // let's not return the reference to a pooled cable
	else if(C.shock(user, 50))
		if(prob(50)) //Fail
			new /obj/item/stack/cable_coil(C.loc, 1)
			qdel(C)
			return // let's not return the reference to a pooled cable

	return C //What was our last known position?

//Called when cable_coil is click on an installed obj/cable
//or click on a turf that already contains a "node" cable
/obj/item/stack/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user)
	var/turf/U = user.loc

	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact) //Sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1) //Make sure it's close enough
		to_chat(user, "<span class='warning'>You can't lay cable that far away.</span>")
		return

	if(U == T) //If clicked on the turf we're standing on, try to put a cable in the direction we're facing
		turf_place(T, user)
		return

	var/dirn = get_dir(C, user)

	//One end of the clicked cable is pointing towards us
	if(C.d1 == dirn || C.d2 == dirn)
		if(U.intact) //Can't place a cable if the floor is complete
			to_chat(user, "<span class='warning'>You can't lay cable there until the floor is removed.</span>")
			return
		else
			//Cable is pointing at us, we're standing on an open tile
			//So create a stub pointing at the clicked cable on our tile

			turf_place(user.loc,user,turn(dirn, 180))

	//Exisiting cable doesn't point at our position, so see if it's a stub
	else if(C.d1 == 0)
		//If so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2 //These will be the new directions
		var/nd2 = dirn

		if(nd1 > nd2) //Swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2

		for(var/obj/structure/cable/LC in T) //Check to make sure there's no matching cable
			if(LC == C)	//Skip the cable we're interacting with
				continue

			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1)) //Make sure no cable matches either direction
				to_chat(user, "<span class='warning'>There's already a cable at that position.</span>")
				return

		C.cableColor(_color)

		C.d1 = nd1
		C.d2 = nd2

		C.add_fingerprint()
		C.update_icon()

		C.mergeConnectedNetworks(C.d1) //Merge the powernets
		C.mergeConnectedNetworks(C.d2) //In the two new cable directions
		C.mergeConnectedNetworksOnTurf()

		if(C.d1 & (C.d1 - 1)) //If the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d1)

		if(C.d2 & (C.d2 - 1)) //If the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d2)

		use(1)

		if(C.shock(user, 50))
			if(prob(50)) //Fail
				new /obj/item/stack/cable_coil(C.loc, 1, C.light_color)
				qdel(C)
				return

		C.denode() //This call may have disconnected some cables that terminated on the centre of the turf, if so split the powernets.

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/cable_coil/cut

/obj/item/stack/cable_coil/cut/New(loc, amount, var/param_color = null)
	..(loc)
	if(!amount)
		src.amount = rand(1, 2)
	pixel_x = rand(-2, 2) * PIXEL_MULTIPLIER
	pixel_y = rand(-2, 2) * PIXEL_MULTIPLIER
	update_icon()

/obj/item/stack/cable_coil/yellow
	_color = "yellow"
	icon_state = "coil_yellow"

/obj/item/stack/cable_coil/blue
	_color = "blue"
	icon_state = "coil_blue"

/obj/item/stack/cable_coil/green
	_color = "green"
	icon_state = "coil_green"

/obj/item/stack/cable_coil/pink
	_color = "pink"
	icon_state = "coil_pink"

/obj/item/stack/cable_coil/orange
	_color = "orange"
	icon_state = "coil_orange"

/obj/item/stack/cable_coil/cyan
	_color = "cyan"
	icon_state = "coil_cyan"

/obj/item/stack/cable_coil/white
	_color = "white"
	icon_state = "coil_white"

/obj/item/stack/cable_coil/random/New(loc, amount, var/param_color = null)
	..()
	_color = pick("red","yellow","green","blue","pink")
	icon_state = "coil_[_color]"

/obj/item/stack/cable_coil/persistent/turf_place(turf/simulated/floor/F, mob/user, var/dirnew)	//for cable coil that needs to not be capable of being used up entirely
	if(amount > 1)
		return ..()

/obj/item/stack/cable_coil/persistent/cable_join(obj/structure/cable/C, mob/user)
	if(amount > 1)
		return ..()

/obj/item/stack/cable_coil/persistent/attack(mob/M, mob/user)
	if(amount > 1)
		return ..()
