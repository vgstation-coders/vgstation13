#define NORTH 1
#define SOUTH 2
#define EAST 4
#define WEST 8

#define TOPLEFT NORTH | WEST
#define TOPRIGHT (NORTH << SECONDARY) | EAST
#define BOTTOMLEFT SOUTH | (WEST << SECONDARY)
#define BOTTOMRIGHT (SOUTH << SECONDARY) | (EAST << SECONDARY)

#define MAZEVIEWDIST 1

#define EASTWEST 256
#define NORTHSOUTH 1024

#define DIRECTION_SECONDARY 4 //all secondary paths are bitwise shifted this value from their original direction
#define CROSSING_SECONDARY 1
//for example, North path two is 1<<4=16
//exception: crossing at EASTWEST and NORTHSOUTH are shifted only once

/obj/structure/mousemaze
	name = "mouse labyrinth"
	desc = "Used primarily in neurological studies to test the effects of brain damage."
	icon = 'icons/obj/mousemaze.dmi'
	icon_state = "mousemaze"
	anchored = TRUE
	var/mazeflags = 0 //Which paths are chiseled out?
	var/datum/context_click/mazemaker/buildmaster
	var/list/denizens = list() //This list associates mobs inside this mousemaze with which corner they're in. NW, NE, SW, SE

/obj/structure/mousemaze/New()
	..()
	buildmaster = new(src)

/obj/structure/mousemaze/Destroy()
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(src))
	denizens.Cut()
	..()

/obj/structure/mousemaze/attackby(obj/item/weapon/W,mob/user, params)
	if(istype(W,/obj/item/weapon/chisel))
		buildmaster.action(W, user, params)
	else if(istype(W,/obj/item/weapon/holder/animal))
		var/obj/item/weapon/holder/animal/H = W
		if(H.stored_mob.size == SIZE_TINY)
			enter(H.stored_mob)
	else if(iscrowbar(W))
		visible_message("<span class='danger'>[user] begins dismantling the [src]!</span>")
		if(do_after(user,src,count_set_bitflags(mazeflags) SECONDS + 1)) //1+paths set seconds to deconstruct.
			getFromPool(/obj/item/stack/sheet/wood, loc, 2)
			qdel(src)
	else
		..()

/obj/structure/mousemaze/attack_animal(mob/user)
	if(user.size == SIZE_TINY)
		enter(user)
	else
		..()

/obj/structure/mousemaze/proc/enter(mob/living/L)
	if(L.client)
		var/client/C = L.client
		C.changeView(MAZEVIEWDIST)
	L.forceMove(src)
	denizens[L] = TOPLEFT

/obj/structure/mousemaze/proc/exit(mob/living/L,exitdir)
	if(L.client)
		var/client/C = L.client
		C.changeView(initial(C.view))
	var/turf/exiting
	if(exitdir)
		exiting = get_step(src,exitdir)
	else
		exiting = get_turf(src)
	L.forceMove(exiting)
	playsound(src, 'sound/machines/ding.ogg', 50, 1)
	L.visible_message("<span class='good'>\The [L] exits the maze!</span>","<span class='good'>You solve the maze!</span>")

/obj/structure/mousemaze/relaymove(mob/living/L, direction)
	var/corner = denizens[L] //corner values are a composite of their 2 exit values

	//trying to move out; if this has a direction value OR a sceondary direction value, we'll exit that way
	//example: TOPRIGHT is (NORTH << SECONDARY) | EAST = 10100, so this would evaluate as follows:
	//Example input: North (1)
	//10100 & 00001 FALSE or 1 & 1 TRUE
	//Example input: East (001)
	//10100 & 00100 TRUE (shortcircuits)
	if((corner & direction) || ((corner >> 4) & direction))
		var/obj/structure/mousemaze/MM = locate(/obj/structure/mousemaze) in get_step(src,direction)
		if(MM)
			transfer(L,corner,direction)
		else
			exit(L,direction)

/obj/structure/mousemaze/proc/transfer(mob/living/L,prevcorner,enterdir)
	return

/obj/structure/mousemaze/ex_act(severity)
	for(var/atom/A in contents)
		A.ex_act(severity)
	switch(severity)
		if(1,2)
			qdel(src)
		if(3)
			if(prob(60))
				qdel(src)

//Gives the id clicked in this particular handler
/datum/context_click/mazemaker/return_clicked_id(var/x_pos, var/y_pos)
	switch(y_pos)
		if(1 to 3) //SOUTH slot
			switch(x_pos)
				if(4 to 13)
					return SOUTH
				if(20 to 29)
					return SOUTH << DIRECTION_SECONDARY

		if(4 to 13) //This is an EAST, EASTWEST, WEST slot, in position 2
			switch(x_pos)
				if(1 to 3)
					return WEST << DIRECTION_SECONDARY
				if(15 to 18)
					return EASTWEST << CROSSING_SECONDARY
				if(30 to 32)
					return EAST << DIRECTION_SECONDARY

		if(15 to 18)
			switch(x_pos)
				if(4 to 13)
					return NORTHSOUTH
				if(20 to 29)
					return NORTHSOUTH << CROSSING_SECONDARY

		if(21 to 29) //This is an EAST, EASTWEST, or WEST slot, in position 1
			switch(x_pos)
				if(1 to 3)
					return WEST
				if(15 to 18)
					return EASTWEST
				if(30 to 32)
					return EAST

		if(30 to 32) //NORTH slot
			switch(x_pos)
				if(4 to 13)
					return NORTH
				if(20 to 29)
					return NORTH << DIRECTION_SECONDARY

//Called by attackby with a set of params
//Tries to decide on the flag we want to toggle based on return_clicked_by_params
/datum/context_click/mazemaker/action(obj/item/used_item, mob/user, params)
	var/obj/structure/mousemaze/MM = holder
	if(!istype(MM))
		return
	var/index = return_clicked_id_by_params(params)
	if(MM.mazeflags & index)
		MM.mazeflags &= ~index
	else
		MM.mazeflags |= index
	MM.update_icon()

#define HIGHEST_MAZE_BIT 11
/obj/structure/mousemaze/update_icon()
	overlays.Cut()
	var/bit = HIGHEST_MAZE_BIT
	var/counter = mazeflags
	while(bit>=0)
		if(counter >= (2**bit))
			overlays += image(icon = icon, icon_state = "overlay_[2**bit]")
			counter -= (2**bit)
		bit--