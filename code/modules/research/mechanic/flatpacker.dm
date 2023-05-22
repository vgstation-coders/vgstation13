#define FLA_FAB_BASETIME 0.5

/obj/machinery/r_n_d/fabricator/mechanic_fab/flatpacker
	name = "Flatpack Fabricator"
	desc = "A machine used to produce flatpacks from blueprint designs."
	icon = 'icons/obj/machines/mechanic.dmi'
	icon_state = "flatpacker"

	nano_file = "flatpacker.tmpl"

	build_time = FLA_FAB_BASETIME

	design_types = list(FLATPACKER)

	var/build_parts =  list(
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/scanning_module = 1
		)

	one_part_set_only = 0
	part_sets = list(	"Machines" = list(),
						"Computers" = list(),
						"Misc" = list()
		)

/obj/machinery/r_n_d/fabricator/mechanic_fab/flatpacker/New()
	..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/flatpacker,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module
	)

	RefreshParts()

/obj/machinery/r_n_d/fabricator/mechanic_fab/flatpacker/build_part(var/datum/design/mechanic_design/part)
	if(!part)
		return

	if(!remove_materials(part))
		stopped = 1
		src.visible_message("<span class='notice'>The [src.name] beeps, \"Not enough materials to complete item.\"</span>")
		return

	src.being_built = new part.build_path(src)

	src.busy = 1
	src.overlays += image(icon = icon, icon_state = "[base_state]_ani")
	src.use_power = MACHINE_POWER_USE_ACTIVE
	src.updateUsrDialog()
	//message_admins("We're going building with [get_construction_time_w_coeff(part)]")
	sleep(get_construction_time_w_coeff(part))
	src.use_power = MACHINE_POWER_USE_IDLE
	src.overlays -= image(icon = icon, icon_state = "[base_state]_ani")
	if(being_built)
		var/turf/output = get_output()
		var/obj/structure/closet/crate/flatpack/new_flatpack = new(output)
		if(istype(being_built, /obj/machinery))
			var/obj/machinery/X = being_built //we have to cast it to a /obj/machinery so we can use the parts transfer code
			X.force_parts_transfer(part) //add in scanned upgraded components
			being_built = X
		new_flatpack.insert_machine(being_built)
		for(var/obj/structure/closet/crate/flatpack/existing in output)
			if(existing.try_add_stack(new_flatpack))
				break
		src.visible_message("[bicon(src)] \The [src] beeps: \"Successfully completed \the [being_built.name].\"")
		src.being_built = null

	src.updateUsrDialog()
	src.busy = 0
	return 1

/obj/machinery/r_n_d/fabricator/mechanic_fab/flatpacker/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(..())
		return 1
	if (O.is_open_container())
		return 1
