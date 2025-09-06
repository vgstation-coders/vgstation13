/obj/mecha/combat/gygax
	desc = "A lightweight, security exosuit. Popular among private and corporate security."
	name = "Gygax"
	icon_state = "gygax"
	initial_icon = "gygax"
	base_color = "#ED5F3B"
	step_in = 2
	dir_in = 1 //Facing North.
	health = 250
	deflect_chance = 0
	damage_absorption = list("brute"=0.9,"fire"=1,"bullet"=1,"laser"=0.9,"energy"=1,"bomb"=1)
	infra_luminosity = 6
	var/overload_coeff = 2
	wreckage = /obj/effect/decal/mecha_wreckage/gygax
	internal_damage_threshold = 35
	paintable = 1
	mech_sprites = list(
		"gygax",
		"gygax_old",
		"darkgygax_old",
		"pobeda"
	)

	damage_minimum = 0
	weight_max = 500
	penetration_reduction = 3 // blocks .380

	max_hull_equip = 1
	max_weapon_equip = 2
	max_utility_equip = 2
	max_universal_equip = 1
	max_special_equip = 1

	starting_components = list(
		/obj/item/mecha_parts/component/hull,
		/obj/item/mecha_parts/component/actuator,
		/obj/item/mecha_parts/component/armor/marshal,
		/obj/item/mecha_parts/component/gas,
		/obj/item/mecha_parts/component/electrical,
		/obj/item/mecha_parts/component/coupler
		)


/obj/mecha/combat/gygax/dark
	desc = "A lightweight exosuit used by Nanotrasen Death Squads. A significantly upgraded Gygax security mech."
	name = "Dark Gygax"
	icon_state = "darkgygax"
	initial_icon = "darkgygax"
	base_color = "#4E4E4E"
	health = 300
	deflect_chance = 10
	damage_absorption = list("brute"=0.8,"fire"=1,"bullet"=0.8,"laser"=0.8,"energy"=0.8,"bomb"=1)
	max_temperature = 10000 // Syndie & Centcom mechs get some forgiveness here.
	overload_coeff = 1
	wreckage = /obj/effect/decal/mecha_wreckage/gygax/dark
	step_energy_drain = 5
	mech_sprites = list(
		"darkgygax",
	)
	paintable = 0
	cell_type = /obj/item/weapon/cell/hyper

	penetration_reduction = 5
	weight_max = 460
	emp_gear_proof = TRUE

	max_hull_equip = 2
	max_weapon_equip = 2
	max_utility_equip = 2
	max_universal_equip = 1
	max_special_equip = 1

	starting_components = list(
		/obj/item/mecha_parts/component/hull,
		/obj/item/mecha_parts/component/actuator/hispeed,
		/obj/item/mecha_parts/component/armor/marshal/reinforced,
		/obj/item/mecha_parts/component/gas,
		/obj/item/mecha_parts/component/electrical,
		/obj/item/mecha_parts/component/coupler
		)


/obj/mecha/combat/gygax/New()
	..()
	intrinsic_spells = list(new /spell/mech/gygax/overload(src))

/obj/mecha/combat/gygax/dark/New()
	..()
	new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot(src)
	new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang(src)
	new /obj/item/mecha_parts/mecha_equipment/teleporter(src)
	new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	UpdateIcon()
	max_ammo()
	return

/spell/mech/gygax/overload
	name = "Overload"
	desc = "Greatly enhance the mech's speed at the cost of integrity per step."
	charge_cooldown_max = 10
	charge_counter = 10
	hud_state = "gygax-gofast"
	override_icon = 'icons/mecha/mecha.dmi'

/spell/mech/gygax/overload/update_spell_icon()
	var/obj/mecha/combat/gygax/Gygax = linked_mech
	hud_state = Gygax.initial_icon + "-gofast"

/spell/mech/gygax/overload/cast(list/targets, mob/user)
	var/obj/mecha/combat/gygax/Gygax = linked_mech
	if(Gygax.overload)
		Gygax.overload = 0
		Gygax.step_in = initial(Gygax.step_in)
		Gygax.step_energy_drain = initial(Gygax.step_energy_drain)
		Gygax.occupant_message("<span class='notice'>You disable leg actuators overload.</span>")
		Gygax.weight_tolerance = initial(Gygax.weight_tolerance)
		flick("[Gygax.initial_icon]-gofast-aoff",Gygax)
		Gygax.icon_state = Gygax.initial_icon
	else
		Gygax.overload = 1
		Gygax.step_in = min(1, round(Gygax.step_in/2))
		Gygax.step_energy_drain = Gygax.step_energy_drain*Gygax.overload_coeff
		Gygax.occupant_message("<span class='red'>You enable leg actuators overload.</span>")
		Gygax.weight_tolerance = 1
		flick("[Gygax.initial_icon]-gofast-aon",Gygax)
		Gygax.icon_state = Gygax.initial_icon + "-gofast"
	Gygax.log_message("Toggled leg actuators overload.")
	return

/*
/obj/mecha/combat/gygax/startMechWalking()
	if(overload)
		icon_state = initial_icon + "-gofast-move"
	else
		icon_state = initial_icon + "-move"
*/

/obj/mecha/combat/gygax/stopMechWalking()
	return // ok

/obj/mecha/combat/gygax/dyndomove(direction)
	if(!..())
		return
	if(overload)
		health--
		if(health < initial(health) - initial(health)/3)
			overload = 0
			step_in = initial(step_in)
			step_energy_drain = initial(step_energy_drain)
			src.occupant_message("<span class='red'>Leg actuators damage threshold exceded. Disabling overload.</span>")
	return


/obj/mecha/combat/gygax/get_stats_part()
	var/output = ..()
	output += "<b>Leg actuators overload: [overload?"on":"off"]</b>"
	return output
