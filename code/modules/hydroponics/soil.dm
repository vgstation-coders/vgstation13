/obj/machinery/portable_atmospherics/hydroponics/soil
	name = "soil"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "soil"
	density = 0
	use_power = 0
	draw_warnings = 0

/obj/machinery/portable_atmospherics/hydroponics/soil/attackby(var/obj/item/W, var/mob/user)
	if(istype(W, /obj/item/weapon/pickaxe/shovel))
		if(!seed)
			to_chat(user, "You clear up [src]!")
			new /obj/item/weapon/ore/glass(loc)//we get some of the dirt back
			new /obj/item/weapon/ore/glass(loc)
			qdel(src)
			return 1
		else
			..()
	else if(is_type_in_list(W,list(/obj/item/weapon/tank, /obj/item/weapon/screwdriver)))
		return
	else
		return ..()

/obj/machinery/portable_atmospherics/hydroponics/soil/smashDestroy(destroy_chance)
	qdel(src)

/obj/machinery/portable_atmospherics/hydroponics/soil/dropFrame()
	return 0

/obj/machinery/portable_atmospherics/hydroponics/soil/New()
	..()
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/close_lid
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/set_label
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/light_toggle
	component_parts = list()
