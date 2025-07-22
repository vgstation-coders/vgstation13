/obj/machinery/portable_atmospherics/hydroponics/soil
	name = "soil"
	desc = "Yup, that's dirt."
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "soil"
	density = 0
	use_power = MACHINE_POWER_USE_NONE
	draw_warnings = 0
	is_soil = 1
	machine_flags = 0 // THIS SHOULD NOT EVER BE UNWRENCHED AND IT SHOULD NOT EVER SPAWN MACHINE FRAMES, MY GOD

/obj/machinery/portable_atmospherics/hydroponics/soil/attackby(var/obj/item/W, var/mob/user)
	if(isshovel(W))
		if(!seed)
			to_chat(user, "You clear up [src]!")
			drop_stack(/obj/item/stack/ore/glass, loc, 2)//we get some of the dirt back
			qdel(src)
			return 1
		else
			..()
	else
		return ..()

/obj/machinery/portable_atmospherics/hydroponics/soil/smashDestroy(destroy_chance)
	qdel(src)

/obj/machinery/portable_atmospherics/hydroponics/soil/New()
	..()
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/close_lid
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/set_label
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/light_toggle
	component_parts = list()


/////////////////////////////////////////////////////////////////////////

/obj/machinery/portable_atmospherics/hydroponics/plastic
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "hydrotray_plastic"
	density = 0
	use_power = MACHINE_POWER_USE_NONE
	draw_warnings = 0
	anchored = 0
	is_plastic = 1
	machine_flags = 0

/obj/machinery/portable_atmospherics/hydroponics/plastic/attackby(var/obj/item/W, var/mob/user)
	if(iswrench(W))
		if(!seed)
			to_chat(user, "You deconstruct \the [src]!")
			W.playtoolsound(src, 50)
			drop_stack(/obj/item/stack/sheet/mineral/plastic, loc, 3)//we get some of the plastic back
			qdel(src)
			return 1
		else
			..()
	else
		return ..()

/obj/machinery/portable_atmospherics/hydroponics/soil/smashDestroy(destroy_chance)
	drop_stack(/obj/item/stack/sheet/mineral/plastic, loc, 3)//we get some of the plastic back
	qdel(src)

/obj/machinery/portable_atmospherics/hydroponics/soil/New()
	..()
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/close_lid
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/set_label
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/light_toggle
	component_parts = list()
