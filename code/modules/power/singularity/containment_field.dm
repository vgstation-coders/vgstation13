//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/containment_field
	name = "Containment Field"
	desc = "An energy field."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "Contain_F"
	anchored = 1
	density = 0
	use_power = MACHINE_POWER_USE_NONE
	luminosity = 4

	flags = FPRINT | PROXMOVE

	var/obj/machinery/field_generator/FG1 = null
	var/obj/machinery/field_generator/FG2 = null
	var/hasShocked = 0 //Used to add a delay between shocks. In some cases this used to crash servers by spawning hundreds of sparks every second.

/obj/machinery/containment_field/Destroy()
	if(FG1 && !FG1.clean_up)
		FG1.cleanup()
	if(FG2 && !FG2.clean_up)
		FG2.cleanup()
	..()

/obj/machinery/containment_field/attack_hand(mob/user as mob)
	if(get_dist(src, user) > 1)
		return 0
	else
		shock(user)
		return 1


/obj/machinery/containment_field/blob_act()
	return 0


/obj/machinery/containment_field/ex_act(severity)
	return 0

/obj/machinery/containment_field/HasProximity(atom/movable/AM as mob|obj)
	if(Adjacent(AM)) //checking for windows and shit
		if(istype(AM,/mob/living/silicon) && prob(40))
			shock(AM)
			return 1
		if(istype(AM,/mob/living/carbon) && prob(50))
			shock(AM)
			return 1
	return 0



/obj/machinery/containment_field/shock(const/mob/living/user)
	if(hasShocked)
		return 0

	if(isnull(FG1) || isnull(FG2))
		qdel(src)
		return 0

	if(isliving(user))
		hasShocked = 1
		var/shock_damage = min(rand(30, 40), rand(30, 40))
		user.electrocute_act(shock_damage, src)

		if(iscarbon(user))
			var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
			user.throw_at(target, 200, 4)

		sleep(20)
		hasShocked = 0

/obj/machinery/containment_field/proc/set_master(var/master1,var/master2)
	if(!master1 || !master2)
		return 0
	FG1 = master1
	FG2 = master2
	return 1

/obj/machinery/containment_field/dissolvable()
	return 0