/obj/mecha/medical/odysseus
	desc = "These exosuits are developed and produced by Vey-Med. (&copy; All rights reserved)."
	name = "Odysseus"
	icon_state = "odysseus"
	initial_icon = "odysseus"
	step_in = 2
	max_temperature = 15000
	health = 120
	wreckage = /obj/effect/decal/mecha_wreckage/odysseus
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6
	var/obj/item/clothing/glasses/hud/health/mech/hud
	paintable = 1
	mech_sprites = list(
		"odysseus",
		"medgax",
		"paramed",
		"urinetrouble"
	)

/obj/mecha/medical/odysseus/New()
	..()
	hud = new /obj/item/clothing/glasses/hud/health/mech(src)
	mech_parts.Add(hud)

/obj/mecha/medical/odysseus/Destroy()
	QDEL_NULL(hud)
	return ..()

/obj/mecha/medical/odysseus/moved_inside(var/mob/living/carbon/human/H as mob)
	if(..())
		if(H.glasses)
			occupant_message("<span class='red'>[H.glasses] prevent you from using [src] [hud]</span>")
		else
			H.glasses = hud
		return 1
	else
		return 0

/obj/mecha/medical/odysseus/go_out()
	if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant
		if(H.glasses == hud)
			H.glasses = null
	..()
	return

//TODO - Check documentation for client.eye and client.perspective...
/obj/item/clothing/glasses/hud/health/mech
	name = "Integrated Medical Hud"



//A adminspawn only syndicate variant with slightly more armor, health and a pre-loaded laser gun. Yeah this is the most uncreative shit ever but it's a starting point if someone wants to expand on this.
/obj/mecha/medical/odysseus/murdysseus
	name = "MURDYSSEUS"
	desc = "A terrifying combat-modified Medical Exosuit. You doubt this thing has ever heard of the Hippocratic Oath."
	icon_state = "murdysseus"
	initial_icon = "murdysseus"
	deflect_chance = 20
	health = 240
	wreckage = /obj/effect/decal/mecha_wreckage/odysseus/murdysseus
	paintable = 0
	max_equip = 4

/obj/mecha/medical/odysseus/murdysseus/New()
	..()
	new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser(src)
	new /obj/item/mecha_parts/mecha_equipment/tool/sleeper(src)
	new /obj/item/mecha_parts/mecha_equipment/tool/syringe_gun(src)
	new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	return
