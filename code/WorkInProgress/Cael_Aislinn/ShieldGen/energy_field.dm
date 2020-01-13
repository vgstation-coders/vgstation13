
//---------- actual energy field

/obj/effect/energy_field
	name = "energy wall"
	desc = "Sparkles, tingles, and stops you in your tracks."
	icon = 'code/WorkInProgress/Cael_Aislinn/ShieldGen/shielding.dmi'
	icon_state = "shieldsparkles"
	anchored = 1
	plane = ABOVE_HUMAN_PLANE
	density = 0
	invisibility = 101
	var/strength = 0

/obj/effect/energy_field/ex_act(var/severity)
	Stress(0.5 + severity)

/obj/effect/energy_field/bullet_act(var/obj/item/projectile/Proj)
	Stress(Proj.damage / 10)

/obj/effect/energy_field/proc/Stress(var/severity)
	strength -= severity

	//if we take too much damage, drop out - the generator will bring us back up if we have enough power
	if(strength < 1)
		invisibility = 101
		setDensity(FALSE)
	else if(strength >= 1)
		invisibility = 0
		setDensity(TRUE)

/obj/effect/energy_field/proc/Strengthen(var/severity)
	strength += severity

	//if we take too much damage, drop out - the generator will bring us back up if we have enough power
	if(strength >= 1)
		invisibility = 0
		setDensity(TRUE)
	else if(strength < 1)
		invisibility = 101
		setDensity(FALSE)

/obj/effect/energy_field/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return !density
