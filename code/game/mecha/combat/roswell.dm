/obj/mecha/combat/roswell
	desc = "An exosuit from another world."
	name = "Roswell"
	icon_state = "roswell"
	initial_icon = "roswell"
	step_in = 1
	dir_in = 1 //Facing North.
	health = 300
	deflect_chance = 15
	damage_absorption = list("brute"=0.75,"fire"=1,"bullet"=0.8,"laser"=0.7,"energy"=0.85,"bomb"=1)
	max_temperature = 25000
	infra_luminosity = 6
	wreckage = /obj/effect/decal/mecha_wreckage/roswell
	internal_damage_threshold = 35
	max_equip = 3

/obj/mecha/combat/roswell/mechturn(direction)
	dir = direction
	return 1

/obj/mecha/combat/roswell/mechstep(direction)
	return step(src,direction)

/obj/mecha/combat/roswell/mechsteprand()
	return step_rand(src)
    
/obj/mecha/combat/roswell/Process_Spacemove(var/check_drift = 0) //invaders from outer spaaace
	return TRUE

/obj/effect/decal/mecha_wreckage/roswell
    name = "downed weather balloon"
    desc = "Seems legit"
    icon_state = "roswell-broken"