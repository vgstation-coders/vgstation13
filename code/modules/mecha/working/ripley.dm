/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit. The workhorse of the exosuit world."
	name = "APLU MK-I \"Ripley\""
	icon_state = "ripley"
	initial_icon = "ripley"
	silicon_icon_state = "ripley-empty"
	base_color = "#DFD472"
	step_in = 2.5 //Move speed, lower is faster.
	/// How fast the mech is in low pressure
	var/fast_pressure_step_in = 1.5
	/// How fast the mech is in normal pressure
	var/slow_pressure_step_in = 2.5
	health = 150
	damage_absorption = list("brute"=0.85,"fire"=1.2,"bullet"=1,"laser"=1,"energy"=1,"bomb"=1)
	wreckage = /obj/effect/decal/mecha_wreckage/ripley
	enclosed = FALSE
	enter_delay = 15
	mech_sprites = list(
		"ripley",
		"ripley_glass",
		"hauler"
	)
	paintable = 1
	cargo_capacity = 20
	weight_max = 600
	damage_minimum = 0
	penetration_reduction = 0
	weight_tolerance = 2
	transparent_cabin = TRUE

	starting_components = list(
		/obj/item/mecha_parts/component/hull,
		/obj/item/mecha_parts/component/actuator,
		/obj/item/mecha_parts/component/armor/mining,
		/obj/item/mecha_parts/component/gas,
		/obj/item/mecha_parts/component/electrical,
		/obj/item/mecha_parts/component/coupler
		)

	max_hull_equip = 2
	max_weapon_equip = 0
	max_utility_equip = 3
	max_universal_equip = 0
	max_special_equip = 1

/obj/mecha/working/ripley/Move()
	. = ..()
	update_pressure()

/obj/mecha/working/ripley/create_visholder()
	if(!..())
		return
	var/matrix/size_matrix = matrix()
	size_matrix.Scale(0.5,0.5)
	visholder.transform = size_matrix
	visholder.pixel_y = 6

/obj/mecha/working/ripley/handle_vis_offset()
	if(!visholder)
		return
	if(dir == WEST)
		visholder.pixel_x = -4
	else if(dir == EAST)
		visholder.pixel_x = 4
	else
		visholder.pixel_x = 0


/obj/mecha/working/ripley/handle_vis_enter()
	..()

/obj/mecha/working/ripley/handle_vis_exit()
	..()

/obj/mecha/working/ripley/mk2
	desc = "Autonomous Power Loader Unit. The workhorse of the exosuit world, this variant is fitted with a pressurized cabin. "
	name = "APLU MK-II \"Ripley\""
	icon_state = "ripleymkii"
	initial_icon = "ripleymkii"
	step_in = 3 //Move speed, lower is faster.
	/// How fast the mech is in low pressure
	fast_pressure_step_in = 2
	/// How fast the mech is in normal pressure
	slow_pressure_step_in = 3
	health = 200
	damage_absorption = list("brute"=0.8,"fire"=1.2,"bullet"=1,"laser"=1,"energy"=1,"bomb"=0.8)
	wreckage = /obj/effect/decal/mecha_wreckage/ripley/mk2
	enclosed = TRUE
	enter_delay = 40
	mech_sprites = list(
		"ripleymkii",
		"titan",
		"ripley_flames_red",
		"ripley_flames_blue",
		"hivisripley"
	)
	paintable = 1
	penetration_reduction = 2
	damage_minimum = 2
	transparent_cabin = FALSE

	weight_max = 800

/obj/mecha/working/ripley/mk2/firefighter
	desc = "Standard APLU MK-II chassis, refitted with additional thermal protection and cistern."
	name = "APLU \"Firefighter\""
	icon_state = "firefighter"
	initial_icon = "firefighter"
	max_temperature = 10000
	health = 250
	light_range_on = 10
	light_brightness_on = 3
	damage_absorption = list("brute"=0.8,"fire"=0.5,"bullet"= 1,"laser"=1, "bomb"=0.8)
	wreckage = /obj/effect/decal/mecha_wreckage/ripley/firefighter
	mech_sprites = list(
		"firefighter",
		"aluminizer"
		)
	paintable = 1
	penetration_reduction = 3 // blocks .380
	damage_minimum = 3

	starting_components = list(
		/obj/item/mecha_parts/component/hull/atmos,
		/obj/item/mecha_parts/component/actuator,
		/obj/item/mecha_parts/component/armor/mining,
		/obj/item/mecha_parts/component/gas,
		/obj/item/mecha_parts/component/electrical,
		/obj/item/mecha_parts/component/coupler
		)

/obj/mecha/working/ripley/mk2/firefighter/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "DEATH-RIPLEY"
	icon_state = "deathripley"
	initial_icon = "deathripley"
	base_color = "#880015"
	step_in = 2
	opacity = 0
	light_range_on = 12
	light_brightness_on = 3
	internal_damage_threshold = 35
	damage_absorption = list("brute"=0.7,"fire"=0.7,"bullet"=0.8,"laser"=0.8, "energy"=0.9, "bomb"=0.7)
	wreckage = /obj/effect/decal/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0
	paintable = 0
	penetration_reduction = 5 // blocks .380
	damage_minimum = 5
	emp_gear_proof = TRUE
	max_hull_equip = 2
	max_weapon_equip = 1
	max_utility_equip = 4
	max_universal_equip = 1
	max_special_equip = 1

	starting_components = list(
		/obj/item/mecha_parts/component/hull/durable,
		/obj/item/mecha_parts/component/actuator,
		/obj/item/mecha_parts/component/armor/military,
		/obj/item/mecha_parts/component/gas,
		/obj/item/mecha_parts/component/electrical,
		/obj/item/mecha_parts/component/coupler
		)

/obj/mecha/working/ripley/mk2/firefighter/deathripley/New()
	..()
	new /obj/item/mecha_parts/mecha_equipment/tool/safety_clamp(src)
	return

/obj/mecha/working/ripley/mining
	desc = "An old, dusty mining ripley."
	name = "APLU \"Miner\""
	starts_with_tracking_beacon = FALSE //So it can't be easily found

/obj/mecha/working/ripley/mining/New()
	..()
	//Attach drill
	if(prob(25)) //Possible diamond drill... Feeling lucky?
		var/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill/D = new /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
		D.attach(src)
	else
		var/obj/item/mecha_parts/mecha_equipment/tool/drill/D = new /obj/item/mecha_parts/mecha_equipment/tool/drill
		D.attach(src)

	//Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/HC = new /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	HC.attach(src)
	src.hydraulic_clamp = HC

/obj/mecha/working/ripley/preloaded/New() //Starts with DD, tracking beacon, and clamp
	..()
	var/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill/D = new /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
	D.attach(src)
	var/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/HC = new /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	HC.attach(src)
	src.hydraulic_clamp = HC

/obj/mecha/working/ripley/proc/update_pressure()
	var/turf/T = get_turf(loc)

	. = FALSE
	if(!istype(T))
		return

	var/datum/gas_mixture/environment = T.return_air()
	if(!istype(environment))
		return

	var/pressure = environment.return_pressure()
	if(pressure <= 20)
		. = TRUE

	if(low_atmos_pressure_check (T))
		step_in = fast_pressure_step_in
	else
		step_in = slow_pressure_step_in

/proc/low_atmos_pressure_check(turf/T)
	. = FALSE
	if(!istype(T))
		return
	var/datum/gas_mixture/environment = T.return_air()
	if(!istype(environment))
		return
	var/pressure = environment.return_pressure()
	if(pressure <= 20)
		. = TRUE
