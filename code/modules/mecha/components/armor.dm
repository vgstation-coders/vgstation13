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
	step_delay = 1
	var/pen_reduction = 1
	var/deflect_chance = 10
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
	step_delay = 2
	max_integrity = 100
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
	max_integrity = 50
	step_delay = 0
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
	step_delay = 3
	max_integrity = 125
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
	step_delay = 4
	max_integrity = 150
	emp_resistance = 2
	optimal_type = list(/obj/mecha/combat)
	damage_minimum = 15
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
			step_delay = 0
		else
			step_delay = initial(step_delay)

/obj/item/mecha_parts/component/armor/marshal
	name = "marshal mecha plating"
	desc = "A surprisingly thin, lightweight armour panel constructed out of flexible and combat-resistant reinforced plastics."
	icon_state = "armor_marshal"
	step_delay = 2
	max_integrity = 75
	emp_resistance = 3
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

/obj/item/mecha_parts/component/armor/marshal/attach(var/obj/mecha/target, var/mob/living/user)
	. = ..()
	if(.)
		var/typepass = FALSE
		for(var/type in optimal_type)
			if(istype(chassis, type))
				typepass = TRUE

		if(typepass)
			step_delay = 2
		else
			step_delay = initial(step_delay)

/obj/item/mecha_parts/component/armor/marshal/reinforced
	name = "blackops mecha plating"
	desc = "An armour panel that provides top protection, while remaining lightweight, thanks to the cutting-edge ceramics and duraplastics used."
	step_delay = 2
	max_integrity = 150
	deflect_chance = 10
	pen_reduction = 10
	damage_minimum = 5
	damage_absorption = list(
		"brute"=0.6,
		"fire"=0.8,
		"bullet"=0.6,
		"laser"=0.5,
		"energy"=0.65,
		"bomb"=0.8
		)

	origin_tech = Tc_MATERIALS + "=6;" + Tc_COMBAT + "=7;"

/obj/item/mecha_parts/component/armor/military/marauder
	name = "ultra-heavy mecha plating"
	desc = "An advanced matrix of spaced composites, duraplastics and depleted uranium, very heavy, but provides extreme protection."
	step_delay = 3
	max_integrity = 200
	emp_resistance = 3
	optimal_type = list(/obj/mecha/combat/marauder)
	deflect_chance = 25
	damage_minimum = 10
	pen_reduction = 10 // blocks .50 BMG, on the Marauder
	damage_absorption = list(
		"brute"=0.5,
		"fire"=0.7,
		"bullet"=0.45,
		"laser"=0.5,
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
	step_delay = 2
	max_integrity = 100
	var/self_repair = 0.5
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

/obj/item/mecha_parts/component/armor/concrete
	name = "concrete mecha plating"
	desc = "An absurdly heavy matrix of steel and concrete."
	max_integrity = 1000
	damage_absorption = list(
		"brute"=0.01,
		"fire"=0.1,
		"bullet"=0.01,
		"laser"=0.1,
		"energy"=0.1,
		"bomb"=0.1
		)

	pen_reduction = 20 // blocks .50 BMG
/* // killdozer
/obj/item/mecha_parts/component/armor/alien/attach(var/obj/mecha/target, var/mob/living/user)
	. = ..()
	if(.)

		if(istype(target, /obj/mecha/working/ripley/W))
			step_delay = 0

		else
			step_delay = 10
*/
