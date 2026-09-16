/obj/mecha/combat/roswell
	desc = "An exosuit from another world."
	name = "Roswell"
	icon_state = "roswell"
	initial_icon = "roswell"
	step_in = 1
	dir_in = 1 //Facing North.
	health = 200
	deflect_chance = 15
	damage_absorption = list("brute"=1,"fire"=0.9,"bullet"=0.5,"laser"=1,"energy"=0.8,"bomb"=1.2)
	max_temperature = 25000
	infra_luminosity = 6
	wreckage = /obj/effect/decal/mecha_wreckage/roswell
	internal_damage_threshold = 35
	max_equip = 3
	plane = ABOVE_HUMAN_PLANE
	layer = VEHICLE_LAYER
	drifts = FALSE

/obj/mecha/combat/roswell/mechturn(direction)
	dir = direction
	return 1

/obj/mecha/combat/roswell/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		playsound(loc, 'sound/mecha/ufo.ogg', 100)
	return result

/obj/mecha/combat/roswell/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(loc, 'sound/mecha/ufo.ogg', 100)
	return result

/obj/mecha/combat/roswell/preloaded/New()
	..()
	new /obj/item/mecha_parts/mecha_equipment/tool/ayy/abductor(src)
	new /obj/item/mecha_parts/mecha_equipment/tool/ayy/prober(src)

/obj/effect/decal/mecha_wreckage/roswell
    name = "downed weather balloon"
    desc = "Seems legit"
    icon_state = "roswell-broken"