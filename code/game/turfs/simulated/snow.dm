/turf/simulated/floor/plating/snow
	name = "snow"
	desc = "A layer of frozen water particles, kept solid by temperatures way below freezing. On the plus side, can easily be weaponized."
	icon = 'icons/turf/new_snow.dmi'
	icon_state = "snow0"
	temperature = T0C
	oxygen = MOLES_O2STANDARD_ARCTIC
	nitrogen = MOLES_N2STANDARD_ARCTIC
	can_border_transition = 1
	var/snowballs = 0
	var/global/list/icon_state_to_appearance = list()

/turf/simulated/floor/plating/snow/make_wood_floor()
	return

/turf/simulated/floor/plating/snow/make_carpet_floor()
	return

/turf/simulated/floor/plating/snow/New()

	..()
	icon_state = "snow[rand(0, 6)]"
	if(icon_state_to_appearance[icon_state])
		appearance = icon_state_to_appearance[icon_state]
	else
		var/image/snowfx1 = image('icons/turf/snowfx.dmi', "snowlayer1",SNOW_OVERLAY_LAYER)
		var/image/snowfx2 = image('icons/turf/snowfx.dmi', "snowlayer2",SNOW_OVERLAY_LAYER)
		snowfx1.plane = EFFECTS_PLANE
		snowfx2.plane = EFFECTS_PLANE
		overlays += snowfx1
		overlays += snowfx2
		icon_state_to_appearance[icon_state] = appearance
	snowballs = rand(5, 10) //Used to be (30, 50). A quick way to overload the server with atom instances.

/turf/simulated/floor/plating/snow/attackby(obj/item/weapon/W as obj, mob/user as mob)

	..()

	if(!snowballs)
		to_chat(user, "<span class='notice'>There's not enough snow left to dig up.</span>")
		return

	if(isshovel(W))
		user.visible_message("<span class='notice'>[user] starts digging out some snow with \the [W].</span>", \
		"<span class='notice'>You start digging out some snow with \the [W].</span>")
		user.delayNextAttack(20)
		if(do_after(user, src, 20))
			user.visible_message("<span class='notice'>[user] digs out some snow with \the [W].</span>", \
			"<span class='notice'>You dig out some snow with \the [W].</span>")
			extract_snowballs(5, FALSE, user)

/turf/simulated/floor/plating/snow/attack_hand(mob/user as mob)

	//Reach down and make a snowball
	if(!snowballs)
		to_chat(user, "<span class='notice'>There's not enough snow left to make a snowball.</span>")
		return

	user.visible_message("<span class='notice'>[user] reaches down and starts forming a snowball.</span>", \
	"<span class='notice'>You reach down and start forming a snowball.</span>")
	user.delayNextAttack(10)
	if(do_after(user, src, 5))
		user.visible_message("<span class='notice'>[user] finishes forming a snowball.</span>", \
		"<span class='notice'>You finish forming a snowball.</span>")
		extract_snowballs(1, TRUE, user)

	..()

/turf/simulated/floor/plating/snow/proc/extract_snowballs(var/snowball_amount = 0, var/pick_up = FALSE, var/mob/user)

	if(!snowball_amount)
		return

	var/extract_amount = min(snowballs, snowball_amount)

	for(var/i = 0; i < extract_amount, i++)
		var/obj/item/stack/sheet/snow/snowball = new /obj/item/stack/sheet/snow(user.loc)
		snowball.pixel_x = rand(-16, 16) * PIXEL_MULTIPLIER //Would be wise to move this into snowball New() down the line
		snowball.pixel_y = rand(-16, 16) * PIXEL_MULTIPLIER

		if(pick_up)
			user.put_in_hands(snowball)

		snowballs--

	if(!snowballs)
		return

//In the future, catwalks should be the base to build in the arctic, not lattices
//This would however require a decent rework of floor construction and deconstruction
/turf/simulated/floor/plating/snow/canBuildCatwalk()
	return BUILD_FAILURE

/turf/simulated/floor/plating/snow/canBuildLattice()
	if(x >= (world.maxx - TRANSITIONEDGE) || x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (y >= (world.maxy - TRANSITIONEDGE || y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/simulated/floor/plating/snow/canBuildPlating()
	if(x >= (world.maxx - TRANSITIONEDGE) || x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (y >= (world.maxy - TRANSITIONEDGE || y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(locate(/obj/structure/lattice) in contents)
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/simulated/floor/plating/snow/Entered(mob/user)
	..()
	if(isliving(user) && !user.locked_to && !user.lying && !user.flying)
		playsound(src, pick(snowsound), 10, 1, -1, channel = 123)

/turf/simulated/floor/plating/snow/cold
	temperature = T_ARCTIC

/turf/simulated/floor/plating/snow/permafrost
	icon_state = "permafrost_full"

/turf/simulated/floor/plating/snow/ice
	name = "ice"
	icon_state = "ice"

/turf/simulated/floor/plating/snow/concrete
	name = "concrete"
	icon = 'icons/turf/floors.dmi'
	icon_state = "concrete"