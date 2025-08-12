/obj/mecha/combat/durand
	desc = "It's time to light some fires and kick some tires."
	name = "Durand Mk. II"
	icon_state = "durand"
	initial_icon = "durand"
	base_color = "#A8ABB3"
	step_in = 3
	dir_in = 1 //Facing North.
	health = 300
	deflect_chance = 10
	damage_absorption = list("brute"=0.7,"fire"=1,"bullet"=0.8,"laser"=1,"energy"=1,"bomb"=1)
	infra_luminosity = 8
	force = 40
	var/defence_deflect = 35
	var/defence_dam_min = 5
	wreckage = /obj/effect/decal/mecha_wreckage/durand
	mech_sprites = list(
		"durand",
		"old_durand",
		"gator",
		"dollhouse"
	)
	paintable = 1


	damage_minimum = 5 			//Big stompy
	weight_max = 400
	penetration_reduction = 5 // blocks 9mm, up to 7.62 with armor

	max_hull_equip = 2
	max_weapon_equip = 2
	max_utility_equip = 2
	max_universal_equip = 1
	max_special_equip = 1

	starting_components = list(
		/obj/item/mecha_parts/component/hull/durable,
		/obj/item/mecha_parts/component/actuator,
		/obj/item/mecha_parts/component/armor/military,
		/obj/item/mecha_parts/component/gas,
		/obj/item/mecha_parts/component/electrical
		)

/obj/mecha/combat/durand/New()
	..()
	intrinsic_spells = list(new /spell/mech/durand/defence_mode(src))
/*
	weapons += new /datum/mecha_weapon/ballistic/lmg(src)
	weapons += new /datum/mecha_weapon/ballistic/scattershot(src)
	selected_weapon = weapons[1]
*/
	return

/obj/mecha/combat/durand/relaymove(mob/user,direction)
	if(defense_mode)
		occupant_message("<span class='red'>Unable to move while in defence mode</span>", TRUE)
		return 0
	. = ..()

/spell/mech/durand/defence_mode
	name = "Defence Mode"
	desc = "Reduce incoming damage in exchange for preventing movement."
	hud_state = "durand-lockdown"
	override_icon = 'icons/mecha/mecha.dmi'
	charge_cooldown_max = 10
	charge_counter = 10

/spell/mech/durand/defence_mode/New()
	..()
	hud_state = "[linked_mech.initial_icon]-lockdown"

/spell/mech/durand/defence_mode/update_spell_icon()
	hud_state = "[linked_mech.initial_icon]-lockdown"

/spell/mech/durand/defence_mode/cast(list/targets, mob/user)
	var/obj/mecha/combat/durand/Durand = linked_mech
	Durand.defense_mode = !Durand.defense_mode
	if(Durand.defense_mode)
		Durand.icon_state = 0
		flick("[Durand.initial_icon]-lockdown-a",Durand)
		Durand.icon_state = Durand.initial_icon + "-lockdown"
		Durand.deflect_chance += Durand.defence_deflect
		Durand.damage_minimum += Durand.defence_dam_min
		Durand.occupant_message("<span class='notice'>You enable [Durand] defence mode.</span>")
		playsound(src.linked_mech, 'sound/mecha/mechlockdown.ogg', 60, 1)
	else
		Durand.deflect_chance = initial(Durand.deflect_chance)
		Durand.damage_minimum = initial(Durand.damage_minimum)
		Durand.icon_state = Durand.initial_icon
		Durand.occupant_message("<span class='red'>You disable [Durand] defence mode.</span>")
	Durand.log_message("Toggled defence mode.")
	return

/obj/mecha/combat/durand/get_stats_part()
	var/output = ..()
	output += "<b>Defence mode: [defense_mode?"on":"off"]</b>"
	return output

/obj/mecha/combat/durand/old
	desc = "A retired, third-generation combat exosuit utilized by the Nanotrasen corporation. Originally developed to combat hostile alien lifeforms."
	name = "Durand"
	icon_state = "old_durand"
	initial_icon = "old_durand"
	wreckage = /obj/effect/decal/mecha_wreckage/durand/old
