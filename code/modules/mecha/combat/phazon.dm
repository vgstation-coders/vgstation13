/obj/mecha/combat/phazon
	desc = "An exosuit which can only be described as 'What the Fuck?'."
	name = "Phazon"
	icon_state = "phazon"
	initial_icon = "phazon"
	base_color = "#4D79A0"
	step_in = 0.75
	dir_in = 1 //Facing North.
	step_energy_drain = 3
	health = 150
	deflect_chance = 10
	damage_absorption = list("brute"=0.85,"fire"=0.85,"bullet"=0.85,"laser"=0.85,"energy"=0.85,"bomb"=0.85)
	infra_luminosity = 3
	wreckage = /obj/effect/decal/mecha_wreckage/phazon
	add_req_access = 1
	//operation_req_access = list()
	internal_damage_threshold = 25
	force = 15
	var/phasing = 0
	var/phasing_energy_drain = 200
	mech_sprites = list(
		"phazon",
		"phazon_blanco",
		"plazmus",
		"imperion",
		"janus",
	)
	paintable = 1

	damage_minimum = 0

	weight_max = 200
	penetration_reduction = 5 // blocks 9mm

	max_hull_equip = 2
	max_weapon_equip = 2
	max_utility_equip = 2
	max_universal_equip = 1
	max_special_equip = 1

	weight_max = 200

	starting_components = list(
		/obj/item/mecha_parts/component/hull/durable,
		/obj/item/mecha_parts/component/actuator,
		/obj/item/mecha_parts/component/armor/alien,
		/obj/item/mecha_parts/component/gas,
		/obj/item/mecha_parts/component/electrical
		)

/obj/mecha/combat/phazon/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/tool/red
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/gravcatapult
	ME.attach(src)
	intrinsic_spells = list(new /spell/mech/phazon/phasing(src))
	return

/obj/mecha/combat/phazon/to_bump(var/atom/obstacle)
	if(phasing && get_charge()>=phasing_energy_drain)
		var/turf/new_turf = get_step(src, dir)
		var/datum/zLevel/L = get_z_level(new_turf)
		if (L.teleJammed)
			return
		var/area/A = get_area(new_turf)
		if (A.flags & NO_TELEPORT || A.jammed)
			return
		if(can_move)
			can_move = 0
			flick("[initial_icon]-phase", src)
			src.forceMove(new_turf)
			src.use_power(phasing_energy_drain)
			spawn(step_in*3)
				can_move = 1
	else
		. = ..()

/spell/mech/phazon/phasing
	name = "Phasing"
	desc = "Phase through walls."
	charge_cooldown_max = 10
	charge_counter = 10
	hud_state = "phazon-phase"
	override_icon = 'icons/mecha/mecha.dmi'

/spell/mech/phazon/phasing/update_spell_icon()
	hud_state = "[linked_mech.initial_icon]-phase"

/spell/mech/phazon/phasing/cast(list/targets, mob/user)
	var/obj/mecha/combat/phazon/Phazon = linked_mech
	Phazon.phasing = !Phazon.phasing
	Phazon.occupant_message("<font color=\"[Phazon.phasing?"#00f\">En":"#f00\">Dis"]abled phasing.</font>")

/obj/mecha/combat/phazon/click_action(atom/target,mob/user)
	if(phasing)
		src.occupant_message("Unable to interact with objects while phasing")
		return
	else
		return ..()
