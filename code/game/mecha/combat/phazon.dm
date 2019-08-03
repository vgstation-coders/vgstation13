/obj/mecha/combat/phazon
	desc = "An exosuit which can only be described as 'What the Fuck?'."
	name = "Phazon"
	icon_state = "phazon"
	initial_icon = "phazon"
	step_in = 1
	dir_in = 1 //Facing North.
	step_energy_drain = 3
	health = 200
	deflect_chance = 30
	damage_absorption = list("brute"=0.7,"fire"=0.7,"bullet"=0.7,"laser"=0.7,"energy"=0.7,"bomb"=0.7)
	max_temperature = 25000
	infra_luminosity = 3
	wreckage = /obj/effect/decal/mecha_wreckage/phazon
	add_req_access = 1
	//operation_req_access = list()
	internal_damage_threshold = 25
	force = 15
	var/phasing = 0
	var/phasing_energy_drain = 200
	max_equip = 4


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
			flick("phazon-phase", src)
			src.forceMove(new_turf)
			src.use_power(phasing_energy_drain)
			spawn(step_in*3)
				can_move = 1
	else
		. = ..()

/spell/mech/phazon/phasing
	name = "Phasing"
	desc = "Phase through walls."
	charge_max = 10
	charge_counter = 10
	hud_state = "phazon-phase"
	override_icon = 'icons/mecha/mecha.dmi'

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
