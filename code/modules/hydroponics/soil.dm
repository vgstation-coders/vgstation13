/obj/machinery/portable_atmospherics/hydroponics/soil
	name = "soil"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "soil"
	density = 0
	use_power = 0
	draw_warnings = 0

/obj/machinery/portable_atmospherics/hydroponics/soil/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/pickaxe/shovel))
		if(!seed)
			user << "You clear up [src]!"
			new /obj/item/weapon/ore/glass(loc)//we get some of the dirt back
			new /obj/item/weapon/ore/glass(loc)
			qdel(src)
		else
			..()
	else if(istype(O,/obj/item/weapon/pickaxe/shovel) || istype(O,/obj/item/weapon/tank) || istype(O,/obj/item/weapon/screwdriver))
		return
	else
		..()

/obj/machinery/portable_atmospherics/hydroponics/soil/smashDestroy(destroy_chance)
	qdel(src)

/obj/machinery/portable_atmospherics/hydroponics/soil/dropFrame()
	return 0

/obj/machinery/portable_atmospherics/hydroponics/soil/New()
	..()
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/close_lid
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/set_label
	component_parts = list()