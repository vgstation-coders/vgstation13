/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	desc = "Used to unload ore from ore boxes."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null


/obj/machinery/mineral/unloading_machine/New()
	..()
	spawn(5)
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input)
				break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output)
				break

/obj/machinery/mineral/unloading_machine/process()
	if(output && input)
		var/obj/structure/ore_box/BOX = locate(/obj/structure/ore_box, input.loc)
		if(BOX)
			BOX.materials.makeAndRemoveOre(get_turf(output))
		var/obj/item/I = locate(/obj/item, input.loc)
		if(I)
			I.forceMove(get_turf(output))