/obj/item/mecha_parts/component/armor
	name = "mecha plating"
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "armor"
	w_class = W_CLASS_GIANT
	component_type = MECH_ARMOR
	start_damaged = FALSE
	emp_resistance = 4
	optimal_type = null	// List, if it exists. Exosuits meant to use the component.
	integrity_danger_mod = 0.4	// Multiplier for comparison to max_integrity before problems start.
	max_integrity = 100
	internal_damage_flag = MECHA_INT_TEMP_CONTROL
	step_delay = 100
	broken_icon = "armor_broken"
	var/armor_soak = 0.5 // Percentage of damage the armor 'soaks'
	var/pen_reduction = 1
	var/deflect_chance = 0
	var/list/damage_absorption = list(
		"brute"=	0.8,
		"fire"=		1.2,
		"bullet"=	0.9,
		"laser"=	1,
		"energy"=	1,
		"bomb"=		1,
		"bio"=		1,
		"rad"=		1
		)

	origin_tech = Tc_MATERIALS + "=1;"

	var/damage_minimum = 10

/obj/item/mecha_parts/component/armor/mining
	name = "blast-resistant mecha plating"
	desc = "A durable metal and foam plating designed to provide good protection from explosions, and to a lesser extent, kinetic impacts."
	icon_state = "armor_mining"
	armor_soak = 0.5
	step_delay = 200
	max_integrity = 80
	deflect_chance = 3
	pen_reduction = 2
	damage_minimum = 3

	damage_absorption = list(
									"brute"=0.75,
									"fire"=0.8,
									"bullet"=0.9,
									"laser"=0.85,
									"energy"=1,
									"bomb"=0.5,
									"bio"=1,
									"rad"=1
									)

	origin_tech = Tc_MATERIALS + "=1;"

/obj/item/mecha_parts/component/armor/lightweight
	name = "lightweight mecha plating"
	desc = "A very lightweight foam panel that covers the internals of the mech."
	icon_state = "armor_light"
	armor_soak = 0.3
	max_integrity = 30
	step_delay = 10
	pen_reduction = 1
	damage_minimum = 0

	damage_absorption = list(
									"brute"=1,
									"fire"=1.4,
									"bullet"=1,
									"laser"=1,
									"energy"=1,
									"bomb"=1,
									"bio"=1,
									"rad"=1
									)

	origin_tech = Tc_MATERIALS + "=1;"

/obj/item/mecha_parts/component/armor/reinforced
	name = "reinforced mecha plating"
	desc = "A heavy armour panel made out of reinforced steel."
	icon_state = "armor_durable"
	armor_soak = 0.6
	step_delay = 250
	max_integrity = 90
	deflect_chance = 5
	pen_reduction = 3
	damage_minimum = 3
	damage_absorption = list(
		"brute"=0.65,
		"fire"=1,
		"bullet"=0.7,
		"laser"=0.85,
		"energy"=1,
		"bomb"=0.8
		)

	origin_tech = Tc_MATERIALS + "=4;" + Tc_COMBAT + "=3;"

/obj/item/mecha_parts/component/armor/military
	name = "military grade mecha plating"
	desc = "A heavy, combat-grade armour panel made of ultra-hardened steel and plasteel composite."
	icon_state = "armor_military"
	armor_soak = 0.75
	step_delay = 400
	max_integrity = 120
	deflect_chance = 10
	optimal_type = list(/obj/mecha/combat)
	pen_reduction = 5
	damage_minimum = 5
	damage_absorption = list(
		"brute"=0.5,
		"fire"=1.1,
		"bullet"=0.6,
		"laser"=0.8,
		"energy"=0.9,
		"bomb"=0.8
		)

	origin_tech = Tc_MATERIALS + "=5;" + Tc_COMBAT + "=4;"

/obj/item/mecha_parts/component/armor/military/attach(var/obj/mecha/target, var/mob/living/user)
	. = ..()
	if(.)
		var/typepass = FALSE
		for(var/type in optimal_type)
			if(istype(chassis, type))
				typepass = TRUE

		if(typepass)
			step_delay *= 0.5
		else
			step_delay = initial(step_delay)

/obj/item/mecha_parts/component/armor/marshal
	name = "marshal mecha plating"
	desc = "A surprisingly thin, lightweight armour panel constructed out of flexible and combat-resistant reinforced plastics."
	icon_state = "armor_marshal"
	armor_soak = 0.6
	step_delay = 80
	max_integrity = 60
	deflect_chance = 5
	pen_reduction = 5
	damage_minimum = 0
	optimal_type = list(/obj/mecha/combat)
	damage_absorption = list(
		"brute"=0.7,
		"fire"=1,
		"bullet"=0.75,
		"laser"=0.7,
		"energy"=0.85,
		"bomb"=1
		)

	origin_tech = Tc_MATERIALS + "=5;" + Tc_COMBAT + "=4;"

/obj/item/mecha_parts/component/armor/marshal/striker
	name = "striker mecha plating"
	desc = "A thick panel constructed of ultra-hard ceramic composite. Lacks a backer, sacrificing durability for mobility and stopping ability."
	icon_state = "armor_marshal"
	armor_soak = 0.8
	step_delay = 100
	max_integrity = 50
	deflect_chance = 5
	pen_reduction = 10
	damage_absorption = list(
		"brute"=0.6,
		"fire"=1,
		"bullet"=0.5,
		"laser"=0.5,
		"energy"=1,
		"bomb"=1
		)

	origin_tech = Tc_MATERIALS + "=7;" + Tc_COMBAT + "=5;"

/obj/item/mecha_parts/component/armor/marshal/reinforced
	name = "blackops mecha plating"
	desc = "An armour panel that provides top protection, while remaining lightweight, thanks to the cutting-edge ceramics and duraplastics used."
	armor_soak = 0.75
	step_delay = 140
	max_integrity = 120
	deflect_chance = 10
	pen_reduction = 10
	damage_minimum = 5
	damage_absorption = list(
		"brute"=0.6,
		"fire"=0.8,
		"bullet"=0.6,
		"laser"=0.6,
		"energy"=0.65,
		"bomb"=0.8
		)

	origin_tech = Tc_MATERIALS + "=6;" + Tc_COMBAT + "=7;"

/obj/item/mecha_parts/component/armor/military/marauder
	name = "ultra-heavy mecha plating"
	desc = "An advanced matrix of spaced composites, duraplastics and depleted uranium, very heavy, but provides extreme protection."
	armor_soak = 0.8
	step_delay = 500
	max_integrity = 180
	optimal_type = list(/obj/mecha/combat/marauder)
	deflect_chance = 15
	damage_minimum = 10
	pen_reduction = 10 // blocks .50 BMG, on the Marauder
	damage_absorption = list(
		"brute"=0.5,
		"fire"=0.7,
		"bullet"=0.5,
		"laser"=0.6,
		"energy"=0.7,
		"bomb"=0.7
		)

	origin_tech = Tc_MATERIALS + "=6;" + Tc_COMBAT + "=7;"


/obj/item/mecha_parts/component/armor/military/marauder/attach(var/obj/mecha/target, var/mob/living/user)
	. = ..()
	if(.)
		var/typepass = FALSE
		for(var/type in optimal_type)
			if(istype(chassis, type))
				typepass = TRUE

		if(typepass)
			step_delay = 1
		else
			step_delay = initial(step_delay)

/obj/item/mecha_parts/component/armor/alien
	name = "strange mecha plating"
	desc = "A strange matrix of unknown composition, it seems to fall through your hands."
	icon_state = "armor_alien"
	armor_soak = 0.7
	emp_resistance = 2
	step_delay = 150
	max_integrity = 80
	deflect_chance = 10
	damage_minimum = 3
	damage_absorption = list(
		"brute"=0.7,
		"fire"=0.7,
		"bullet"=0.7,
		"laser"=0.7,
		"energy"=0.7,
		"bomb"=0.7
		)

	pen_reduction = 5 // blocks 7.62x55 on the Phazon

	origin_tech = Tc_MATERIALS + "=9;" + Tc_BLUESPACE + "=10;" + Tc_MAGNETS + "=3"

/obj/item/mecha_parts/component/armor/alien/attach(var/obj/mecha/target, var/mob/living/user)
	. = ..()
	if(.)

		if(istype(target, /obj/mecha/combat/phazon))
			step_delay = -3

		else
			step_delay = -1

/obj/item/mecha_parts/component/armor/killdozer
	name = "concrete mecha plating"
	desc = "An absurdly heavy matrix of steel and concrete."
	armor_soak = 1
	max_integrity = 1000
	step_delay = 1000
	always_repair = TRUE
	damage_absorption = list(
		"brute"=0.01,
		"fire"=0.05,
		"bullet"=0.01,
		"laser"=0.05,
		"energy"=0.05,
		"bomb"=0.1
		)

	pen_reduction = 100 // blocks a lot of things
