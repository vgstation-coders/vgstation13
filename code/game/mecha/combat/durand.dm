/obj/mecha/combat/durand
	desc = "It's time to light some fires and kick some tires."
	name = "Durand Mk. II"
	icon_state = "durand"
	initial_icon = "durand"
	step_in = 4
	dir_in = 1 //Facing North.
	health = 400
	deflect_chance = 20
	damage_absorption = list("brute"=0.5,"fire"=1.1,"bullet"=0.65,"laser"=0.85,"energy"=0.9,"bomb"=0.8)
	max_temperature = 30000
	infra_luminosity = 8
	force = 40
	var/defence = 0
	var/defence_deflect = 35
	wreckage = /obj/effect/decal/mecha_wreckage/durand

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
	if(defence)
		occupant_message("<span class='red'>Unable to move while in defence mode</span>", TRUE)
		return 0
	. = ..()

/spell/mech/durand/defence_mode
	name = "Defence Mode"
	desc = "Reduce incoming damage in exchange for preventing movement."
	hud_state = "durand-lockdown"
	override_icon = 'icons/mecha/mecha.dmi'
	charge_max = 10
	charge_counter = 10

/spell/mech/durand/defence_mode/cast(list/targets, mob/user)
	var/obj/mecha/combat/durand/Durand = linked_mech
	Durand.defence = !Durand.defence
	if(Durand.defence)
		Durand.icon_state = 0
		if(!istype(Durand,/obj/mecha/combat/durand/old))
			flick("durand-lockdown-a",Durand)
			Durand.icon_state = Durand.initial_icon + "-lockdown"
		Durand.deflect_chance = Durand.defence_deflect
		Durand.occupant_message("<span class='notice'>You enable [Durand] defence mode.</span>")
		playsound(src.linked_mech, 'sound/mecha/mechlockdown.ogg', 60, 1)
	else
		Durand.deflect_chance = initial(Durand.deflect_chance)
		if(!istype(Durand,/obj/mecha/combat/durand/old))
			Durand.icon_state = Durand.initial_icon
		Durand.occupant_message("<span class='red'>You disable [Durand] defence mode.</span>")
	Durand.log_message("Toggled defence mode.")
	return

/obj/mecha/combat/durand/get_stats_part()
	var/output = ..()
	output += "<b>Defence mode: [defence?"on":"off"]</b>"
	return output

/obj/mecha/combat/durand/old
	desc = "A retired, third-generation combat exosuit utilized by the Nanotrasen corporation. Originally developed to combat hostile alien lifeforms."
	name = "Durand"
	icon_state = "old_durand"
	initial_icon = "old_durand"
	step_in = 4
	dir_in = 1 //Facing North.
	health = 400
	deflect_chance = 20
	damage_absorption = list("brute"=0.5,"fire"=1.1,"bullet"=0.65,"laser"=0.85,"energy"=0.9,"bomb"=0.8)
	max_temperature = 30000
	infra_luminosity = 8
	force = 40
	wreckage = /obj/effect/decal/mecha_wreckage/durand/old
