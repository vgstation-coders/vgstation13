#define AUTOLATHE_BUILD_TIME	0.5
#define AUTOLATHE_MAX_TIME		50 //5 seconds max, * time_coeff

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe
	name = "\improper Autolathe"
	desc = "Produces a large range of common items using metal and glass."
	icon_state = "autolathe"
	icon_state_open = "autolathe_t"
	nano_file = "autolathe.tmpl"
	density = 1

	design_types = list()

	start_end_anims = 1

	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 50
	active_power_usage = 500

	build_time = AUTOLATHE_BUILD_TIME

	removable_designs = 0
	plastic_added = 0

	allowed_materials = list(
						MAT_IRON,
						MAT_GLASS,
						MAT_PLASTIC,
	)

	machine_flags = SCREWTOGGLE | CROWDESTROY | EMAGGABLE | WRENCHMOVE | FIXED2WORK | MULTIOUTPUT

	research_flags = NANOTOUCH | TAKESMATIN | HASOUTPUT | IGNORE_CHEMS | HASMAT_OVER | FAB_RECYCLER

	light_color = LIGHT_COLOR_CYAN

	one_part_set_only = 0
	part_sets = list(
		"Tools"=list(
		new /obj/item/device/multitool(), \
		new /obj/item/tool/weldingtool/empty(), \
		new /obj/item/tool/crowbar(), \
		new /obj/item/tool/screwdriver(), \
		new /obj/item/tool/wirecutters(), \
		new /obj/item/tool/wrench(), \
		new /obj/item/tool/solder(),\
		new /obj/item/tool/wirecutters/clippers(),\
		new /obj/item/weapon/minihoe(),\
		new /obj/item/device/analyzer(), \
		new /obj/item/weapon/pickaxe/shovel/spade(), \
		new /obj/item/weapon/hatchet/metalhandle(), \
		new /obj/item/device/silicate_sprayer/empty(), \
		),
		"Containers"=list(
		new /obj/item/weapon/reagent_containers/glass/beaker(), \
		new /obj/item/weapon/reagent_containers/glass/beaker/large(), \
		new /obj/item/weapon/reagent_containers/glass/metal_bucket(), \
		new /obj/item/weapon/reagent_containers/glass/bucket(), \
		new /obj/item/weapon/reagent_containers/glass/beaker/vial(), \
		new /obj/item/weapon/reagent_containers/food/drinks/mug(), \
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(), \
		new /obj/item/weapon/storage/toolbox(), \
		new /obj/item/weapon/reagent_containers/glass/jar(), \
		),
		"Assemblies"=list(
		new /obj/item/device/assembly/igniter(), \
		new /obj/item/device/assembly/signaler(), \
		new /obj/item/device/assembly/infra(), \
		new /obj/item/device/assembly/timer(), \
		new /obj/item/device/assembly/voice(), \
		new /obj/item/device/assembly/prox_sensor(), \
		new /obj/item/device/assembly/speaker(), \
		new /obj/item/device/assembly/addition(), \
		new /obj/item/device/assembly/comparison(), \
		new /obj/item/device/assembly/randomizer(), \
		new /obj/item/device/assembly/read_write(), \
		new /obj/item/device/assembly/math(), \
		),
		"Stock_Parts"=list(
		new /obj/item/weapon/stock_parts/console_screen(), \
		new /obj/item/weapon/stock_parts/capacitor(), \
		new /obj/item/weapon/stock_parts/scanning_module(), \
		new /obj/item/weapon/stock_parts/manipulator(), \
		new /obj/item/weapon/stock_parts/micro_laser(), \
		new /obj/item/weapon/stock_parts/matter_bin(), \
		),
		"Medical"=list(
		new /obj/item/weapon/storage/pill_bottle(),\
		new /obj/item/weapon/reagent_containers/syringe(), \
		new /obj/item/tool/scalpel(), \
		new /obj/item/tool/circular_saw(), \
		new /obj/item/tool/surgicaldrill(),\
		new /obj/item/tool/retractor(),\
		new /obj/item/tool/cautery(),\
		new /obj/item/tool/hemostat(),\
		),
		"Ammunition"=list(
		new /obj/item/ammo_casing/shotgun/blank(), \
		new /obj/item/ammo_casing/shotgun/beanbag(), \
		new /obj/item/ammo_casing/shotgun/flare(), \
		new /obj/item/ammo_storage/speedloader/shotgun(),
		new /obj/item/ammo_storage/speedloader/c38/empty(), \
		new /obj/item/ammo_storage/box/c38(), \
		new /obj/item/toy/ammo/gun(), \
		),
		"Misc_Tools"=list(
		new /obj/item/device/flashlight(), \
		new /obj/item/weapon/extinguisher/empty(), \
		new /obj/item/device/radio/headset(), \
		new /obj/item/device/radio/off(), \
		new /obj/item/weapon/kitchen/utensil/knife/large(), \
		new /obj/item/clothing/head/welding(), \
		new /obj/item/device/taperecorder(), \
		new /obj/item/tool/wirecutters/scissors(), \
		new /obj/item/weapon/chisel(), \
		new /obj/item/weapon/razor(), \
		new /obj/item/device/rcd/tile_painter(), \
		new /obj/item/device/rcd/matter/rsf(), \
		new /obj/item/device/destTagger(), \
		new /obj/item/device/priceTagger(), \
		new /obj/item/weapon/hand_labeler(), \
		new /obj/item/device/breathalyzer(), \
		),
		"Misc_Other"=list(
		new /obj/item/stack/rcd_ammo(), \
		new /obj/item/weapon/light/tube(), \
		new /obj/item/weapon/light/bulb(), \
		new /obj/item/ashtray/glass(), \
		new /obj/item/weapon/storage/pill_bottle/dice(),\
		new /obj/item/weapon/camera_assembly(), \
		new /obj/item/stack/sheet/glass/rglass(), \
		new /obj/item/stack/rods(), \
		new /obj/item/weapon/storage/box/ornaments(), \
		new /obj/item/weapon/storage/box/ornaments/teardrop_ornaments(), \
		new /obj/item/weapon/disk/shuttle_coords/station_auxillary(),\
		new /obj/item/weapon/disk/blank(),\
		),
		"Hidden_Items" = list(
		new /obj/item/weapon/gun/projectile/flamethrower/full(), \
		new /obj/item/ammo_storage/box/flare(), \
		new /obj/item/device/rcd/matter/engineering(), \
		new /obj/item/device/rcd/rpd(),\
		new /obj/item/device/radio/electropack(), \
		new /obj/item/tool/weldingtool/largetank/empty(), \
		new /obj/item/clothing/glasses/welding(), \
		new /obj/item/weapon/handcuffs(), \
		new /obj/item/ammo_storage/box/a357(), \
		new /obj/item/ammo_casing/shotgun(), \
		new /obj/item/ammo_casing/shotgun/dart(), \
		new /obj/item/ammo_casing/shotgun/buckshot(),\
		new /obj/item/weapon/beartrap(),\
		new /obj/item/gun_part/scope(),\
		new /obj/item/weapon/grenade/chem_grenade/timer(), \
		)
	)

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/autolathe,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/get_construction_time_w_coeff(datum/design/part)
	return min(..(), (AUTOLATHE_MAX_TIME * time_coeff)) //we have set designs, so we can make them quickly

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/is_contraband(var/datum/design/part)
	if(part in part_sets["Hidden_Items"])
		return 1

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/update_hacked()
	if(screen == 51)
		screen = 11 //take the autolathe away from the contraband menu, since otherwise it can still print contraband until another category is selected
	/*if(hacked)
		part_sets["Items"] |= part_sets["Hidden Items"]
	else
		part_sets["Items"] -= part_sets["Hidden Items"]*/
