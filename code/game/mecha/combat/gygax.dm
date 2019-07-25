/obj/mecha/combat/gygax
	desc = "A lightweight, security exosuit. Popular among private and corporate security."
	name = "Gygax"
	icon_state = "gygax"
	initial_icon = "gygax"
	step_in = 3
	dir_in = 1 //Facing North.
	health = 300
	deflect_chance = 15
	damage_absorption = list("brute"=0.75,"fire"=1,"bullet"=0.8,"laser"=0.7,"energy"=0.85,"bomb"=1)
	max_temperature = 25000
	infra_luminosity = 6
	var/overload = 0
	var/overload_coeff = 2
	wreckage = /obj/effect/decal/mecha_wreckage/gygax
	internal_damage_threshold = 35
	max_equip = 3

/obj/mecha/combat/gygax/dark
	desc = "A lightweight exosuit used by Nanotrasen Death Squads. A significantly upgraded Gygax security mech."
	name = "Dark Gygax"
	icon_state = "darkgygax"
	initial_icon = "darkgygax"
	health = 400
	deflect_chance = 25
	damage_absorption = list("brute"=0.6,"fire"=0.8,"bullet"=0.6,"laser"=0.5,"energy"=0.65,"bomb"=0.8)
	max_temperature = 45000
	overload_coeff = 1
	wreckage = /obj/effect/decal/mecha_wreckage/gygax/dark
	max_equip = 4
	step_energy_drain = 5

/obj/mecha/combat/gygax/New()
	..()
	intrinsic_spells = list(new /spell/mech/gygax/overload(src))

/obj/mecha/combat/gygax/dark/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	ME.attach(src)
	return

/obj/mecha/combat/gygax/dark/add_cell(var/obj/item/weapon/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.charge = 30000
	cell.maxcharge = 30000

/spell/mech/gygax/overload
	name = "Overload"
	desc = "Greatly enhance the mech's speed at the cost of integrity per step."
	charge_max = 10
	charge_counter = 10
	hud_state = "gygax-gofast"
	override_icon = 'icons/mecha/mecha.dmi'

/spell/mech/gygax/overload/cast(list/targets, mob/user)
	var/obj/mecha/combat/gygax/Gygax = linked_mech
	if(Gygax.overload)
		Gygax.overload = 0
		Gygax.step_in = initial(Gygax.step_in)
		Gygax.step_energy_drain = initial(Gygax.step_energy_drain)
		Gygax.occupant_message("<span class='notice'>You disable leg actuators overload.</span>")
		if(!istype(Gygax,/obj/mecha/combat/gygax/dark))
			flick("gygax-gofast-aoff",Gygax)
			Gygax.icon_state = Gygax.initial_icon
	else
		Gygax.overload = 1
		Gygax.step_in = min(1, round(Gygax.step_in/2))
		Gygax.step_energy_drain = Gygax.step_energy_drain*Gygax.overload_coeff
		Gygax.occupant_message("<span class='red'>You enable leg actuators overload.</span>")
		if(!istype(Gygax,/obj/mecha/combat/gygax/dark))
			flick("gygax-gofast-aon",Gygax)
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
	if(overload)
		icon_state = initial_icon + "-gofast"
	else
		icon_state = initial_icon

/obj/mecha/combat/gygax/dark/stopMechWalking()
	icon_state = initial_icon

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
