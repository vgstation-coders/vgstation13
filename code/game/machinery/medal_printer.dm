/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/medal_printer
	name = "medal printer"
	desc = "Prints a variety of medal accessories."
	icon = 'icons/obj/machines/mechanic.dmi'
	icon_state = "medalprinter"
	icon_state_open = "medalprinter_t"
	nano_file = "medalprinter.tmpl"
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	research_flags = NANOTOUCH | TAKESMATIN | HASOUTPUT | IGNORE_CHEMS | HASMAT_OVER

	allowed_materials = list(
						MAT_IRON,
						MAT_GOLD,
						MAT_SILVER
	)

	part_sets = list(
		"Standard_Medals"=list(
		new /obj/item/clothing/accessory/medal/participation(), \
		new /obj/item/clothing/accessory/medal/silver(), \
		new /obj/item/clothing/accessory/medal/gold(), \
		),
		"Unique_Medals"=list(
		new /obj/item/clothing/accessory/medal/conduct(), \
		new /obj/item/clothing/accessory/medal/bronze_heart(), \
		new /obj/item/clothing/accessory/medal/silver/valor(), \
		new /obj/item/clothing/accessory/medal/silver/security(),\
		new /obj/item/clothing/accessory/medal/gold/captain(),\
		new /obj/item/clothing/accessory/medal/gold/heroism(), \
		))

/obj/machinery/r_n_d/fabricator/medal_printer/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/medal_printer,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)
	RefreshParts()

