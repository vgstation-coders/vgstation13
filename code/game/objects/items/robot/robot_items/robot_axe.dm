/obj/item/weapon/pickaxe/plasmacutter/heat_axe
	name = "heat axe type7 \"Caesar\""
	desc = "And Caesar’s spirit, ranging for revenge, With Ate by his side come hot from hell, Shall in these confines with a monarch’s voice Cry “Havoc!” and let slip the dogs of war."
	icon = 'icons/obj/syndieweapons.dmi'
	icon_state = "heataxe_0"
	damtype = BRUTE
	heat_production = 0
	force = 4
	sharpness = 0
	sharpness_flags = 0
	origin_tech = Tc_SYNDICATE + "=6"
	attack_verb = list("chops", "cleaves", "tears", "cuts")
	digspeed = 50
	drill_sound = 'sound/items/metal_impact.ogg'
	var/active = FALSE
	var/overheat = FALSE

/obj/item/weapon/pickaxe/plasmacutter/heat_axe/attack_self(mob/living/user)
	toggleActive()

/obj/item/weapon/pickaxe/plasmacutter/heat_axe/is_hot()
	if(active)
		return source_temperature
	return initial(source_temperature)

/obj/item/weapon/pickaxe/plasmacutter/heat_axe/is_sharp()
	if(active)
		return sharpness
	return FALSE

/obj/item/weapon/pickaxe/plasmacutter/heat_axe/update_icon()
	icon_state = "heataxe_[active ? "1" : "0"]"

/obj/item/weapon/pickaxe/plasmacutter/heat_axe/dropped()
	toggleActive()

/obj/item/weapon/pickaxe/plasmacutter/heat_axe/proc/toggleActive()
	active = !active
	force = active ? 25 : initial(force)
	damtype = active ? BURN : BRUTE
	digspeed = active ? 15 : initial(digspeed)
	drill_sound = active ? 'sound/items/Welder2.ogg' : initial(drill_sound)
	sharpness = active ? 1.4 : initial(sharpness)
	heat_production = active ? 5000 : initial(heat_production)
	w_class = active? W_CLASS_LARGE : initial(w_class)
	sharpness_flags = active ? (INSULATED_EDGE | SHARP_BLADE | HOT_EDGE) : initial(sharpness_flags)
	hitsound = active ? 'sound/weapons/blade1.ogg' : 'sound/weapons/empty.ogg'
	playsound(src, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 50, 1) //Placeholder
	update_icon()
	(active && isrobot(loc)) ? processing_objects.Add(src) : processing_objects.Remove(src)

/obj/item/weapon/pickaxe/plasmacutter/heat_axe/process()
	if(isrobot(loc)) //Sanity is never enough.
		var/mob/living/silicon/robot/robot = loc
		if(active && robot && robot.cell)
			var/consume = rand(100,250)
			if(robot.cell.charge <= consume)
				toggleActive()
			robot.cell.use(consume)
	else
		toggleActive()

/obj/item/weapon/pickaxe/plasmacutter/heat_axe/proc/HellFire(var/mob/living/victim)
	if(isliving(victim) && active) //Just to be sure.
		victim.adjust_fire_stacks(1)
		if(victim.IgniteMob())
			to_chat(victim, "<span class='danger'>You are lit on fire from the intense heat of the [name]!</span>")

/obj/item/weapon/pickaxe/plasmacutter/heat_axe/preattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag)
		return
	if(ismecha(target) && active)
		var/obj/mecha/M = target
		if(M.occupant)
			HellFire(M.occupant)
	..()

/obj/item/weapon/pickaxe/plasmacutter/heat_axe/attack(mob/living/target, mob/living/user)
	if(target)
		HellFire(target)
	..()