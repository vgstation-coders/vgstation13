//Terribly sorry for the code doubling, but things go derpy otherwise.
/obj/machinery/door/airlock/multi_tile
	width = 2
	appearance_flags = 0

/obj/machinery/door/airlock/multi_tile/glass
	name = "Glass Airlock"
	icon = 'icons/obj/doors/Door2x1glass.dmi'
	opacity = 0
	glass = 1
	assembly_type = /obj/structure/door_assembly/multi_tile
	animation_delay = 8

/obj/machinery/door/airlock/multi_tile/glass/bump_open(mob/user as mob)
	if(istype(user,/mob/living/simple_animal/hostile/giant_spider))
		return //Fuck you spiders stop leaving the salvage ship
	..(user)
