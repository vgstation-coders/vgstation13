//Arctic atmospheric defines

#define ARCTIC_ATMOSPHERE 90.13
#define T_ARCTIC 223.65 //- 49.5 Celcius, taken from South Pole averages
#define MOLES_ARCTICSTANDARD (ARCTIC_ATMOSPHERE*CELL_VOLUME/(T_ARCTIC*R_IDEAL_GAS_EQUATION)) //Note : Open air tiles obviously aren't 2.5 meters in height, but abstracted for now with infinite atmos
#define MOLES_O2STANDARD_ARCTIC MOLES_ARCTICSTANDARD*O2STANDARD	//O2 standard value (21%)
#define MOLES_N2STANDARD_ARCTIC MOLES_ARCTICSTANDARD*N2STANDARD	//N2 standard value (79%)

/turf/unsimulated/floor/snow
	name = "snow"
	desc = "A layer of frozen water particles, kept solid by temperatures way below freezing. On the plus side, can easily be weaponized."
	icon = 'icons/turf/new_snow.dmi'
	icon_state = "snow"
	temperature = T_ARCTIC
	oxygen = MOLES_O2STANDARD_ARCTIC
	nitrogen = MOLES_N2STANDARD_ARCTIC
	light_color = "#e5ffff"
	can_border_transition = 1
	dynamic_lighting = 0
	luminosity = 1
	plane = BELOW_TURF_PLANE

	var/snowballs = 0
	var/global/list/snow_appearance = list()
	var/list/snowsound = list('sound/misc/snow1.ogg', 'sound/misc/snow2.ogg', 'sound/misc/snow3.ogg', 'sound/misc/snow4.ogg', 'sound/misc/snow5.ogg', 'sound/misc/snow6.ogg')

/turf/unsimulated/floor/snow/New()
	var/snowrand = rand(0, 5)
	if(snow_appearance["[snowrand]"])
		appearance = snow_appearance["[snowrand]"]
	else
		icon_state = "permafrost_full"
		overlays += image(icon,"snow[snowrand]")

		var/image/snowverlay = image('icons/turf/rock_overlay.dmi',"snow_overlay")
		snowverlay.pixel_x = -4
		snowverlay.pixel_y = -4
		overlays += snowverlay

		for(var/i = 1 to 2) // saves us two (2!) whole lines but I don't like copypasting, plus hopefully one day people will make more
			var/image/snowfx = image('icons/turf/snowfx.dmi', "snowlayer[i]")
			snowfx.plane = EFFECTS_PLANE
			overlays += snowfx

		snow_appearance["[snowrand]"] = appearance

	..()


/turf/unsimulated/floor/snow/attackby(obj/item/weapon/W as obj, mob/user as mob)

	..()

	if(istype(W, /obj/item/weapon/pickaxe/shovel))
		user.visible_message("<span class='notice'>[user] starts digging out some snow with \the [W].</span>", \
		"<span class='notice'>You start digging out some snow with \the [W].</span>")
		user.delayNextAttack(20)
		if(do_after(user, src, 20))
			user.visible_message("<span class='notice'>[user] digs out some snow with \the [W].</span>", \
			"<span class='notice'>You dig out some snow with \the [W].</span>")
			extract_snowballs(5, 0, user)

/turf/unsimulated/floor/snow/attack_hand(mob/user as mob)

	//Reach down and make a snowball
	user.visible_message("<span class='notice'>[user] reaches down and starts forming a snowball.</span>", \
	"<span class='notice'>You reach down and start forming a snowball.</span>")
	user.delayNextAttack(10)
	if(do_after(user, src, 5))
		user.visible_message("<span class='notice'>[user] finishes forming a snowball.</span>", \
		"<span class='notice'>You finish forming a snowball.</span>")
		extract_snowballs(1, 1, user)

	..()

/turf/unsimulated/floor/snow/proc/extract_snowballs(var/snowball_amount = 0, var/pick_up = 0, var/mob/user)

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

	if(!snowballs) //We're out of snow, turn into a permafrost tile
		ChangeTurf(/turf/unsimulated/floor/snow/permafrost)

//In the future, catwalks should be the base to build in the arctic, not lattices
//This would however require a decent rework of floor construction and deconstruction
/turf/unsimulated/floor/snow/permafrost/canBuildCatwalk()
	return BUILD_FAILURE

/turf/unsimulated/floor/snow/permafrost/canBuildLattice()
	if(x >= (world.maxx - TRANSITIONEDGE) || x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (y >= (world.maxy - TRANSITIONEDGE || y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/unsimulated/floor/snow/permafrost/canBuildPlating()
	if(x >= (world.maxx - TRANSITIONEDGE) || x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (y >= (world.maxy - TRANSITIONEDGE || y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(locate(/obj/structure/lattice) in contents)
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/unsimulated/floor/snow/Entered(mob/user)
	..()
	if(isliving(user) && !user.locked_to && !user.lying && !user.flying)
		playsound(get_turf(src), pick(snowsound), 10, 1, -1, channel = 123)

//Permafrost is frozen dirt, this shows up below the snow tiles when you dig them out
/turf/unsimulated/floor/snow/permafrost

	name = "permafrost"
	desc = "A layer of dirt permanently exposed to temperatures below freezing. If exposed to snow fall, it will likely be covered in snow again given a few days."
	icon_state = "permafrost_full"
	canSmoothWith = "/turf/unsimulated/floor/snow/permafrost"

/turf/unsimulated/floor/snow/permafrost/New()

	..()

	snowballs = 0

/*/turf/unsimulated/floor/snow/permafrost/update_icon()

	..()

	var/junction = findSmoothingNeighbors()
	var/dircount = 0
	for(var/direction in diagonal)
		if(istype(get_step(src, direction), /turf/unsimulated/floor/snow/permafrost))
			if((direction & junction) == direction)
				overlays += dirt_layers["diag[direction]"]
				dircount++
	if(dircount == 4)
		overlays.Cut()
		icon_state = "permafrost_full"
		overlays += snow_layers["1"]
		overlays += snow_layers["2"]
	else if(junction)
		overlays += dirt_layers["snow[junction]"]
	else
		overlays += dirt_layers["snow0"]
*/