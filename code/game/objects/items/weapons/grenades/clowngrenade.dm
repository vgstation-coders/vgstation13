/obj/item/weapon/grenade/clown_grenade
	name = "Banana Grenade"
	desc = "HONK! brand Bananas. In a special applicator for rapid slipping of wide areas."
	icon_state = "chemg"
	item_state = "flashbang"
	w_class = W_CLASS_SMALL
	force = 2.0
	var/stage = 0
	var/state = 0
	var/path = 0
	var/affected_area = 2

/obj/item/weapon/grenade/clown_grenade/New()
	icon_state = initial(icon_state) +"_locked"

/obj/item/weapon/grenade/clown_grenade/prime()
	..()
	playsound(get_turf(src), 'sound/items/bikehorn.ogg', 25, -3)
	/*
	for(var/turf/simulated/floor/T in view(affected_area, src.loc))
		if(prob(75))
			banana(T)
	*/
	var/i = 0
	var/number = 0
	for(var/direction in alldirs)
		for(i = 0; i < 2; i++)
			number++
			var/obj/item/weapon/bananapeel/traitorpeel/peel = new /obj/item/weapon/bananapeel/traitorpeel(get_turf(src.loc))
		/*	var/direction = pick(alldirs)
			var/spaces = pick(1;150, 2)
			var/a = 0
			for(a = 0; a < spaces; a++)
				step(peel,direction)*/
			var/a = 1
			if(number & 2)
				for(a = 1; a <= 2; a++)
					step(peel,direction)
			else
				step(peel,direction)
	new /obj/item/weapon/bananapeel/traitorpeel(get_turf(src.loc))
	qdel(src)
	return
/*
/obj/item/weapon/grenade/clown_grenade/proc/banana(turf/T as turf)
	if(!T || !istype(T))
		return
	if(locate(/obj/structure/grille) in T)
		return
	if(locate(/obj/structure/window) in T)
		return
	new /obj/item/weapon/bananapeel/traitorpeel(T)
*/

/obj/item/weapon/bananapeel/traitorpeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = W_CLASS_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20

	var/slip_power = 4

/obj/item/weapon/bananapeel/traitorpeel/Crossed(AM as mob|obj)
	var/burned = rand(2,5)
	if(istype(AM, /mob/living))
		var/mob/living/M = AM
		if(M.lying)
			M.take_overall_damage(0, max(0, (burned - 2)))
			M.simple_message("<span class='danger'>Something burns your back!</span>",\
				"<span class='userdanger'>They're eating your back!</span>")
			return
		if(ishuman(M))
			if(M.CheckSlip() < 1)
				return
			else
				M.simple_message("<span class='warning'>Your feet feel like they're on fire!</span>",\
					"<span class='userdanger'>Egads! They bite your feet!</span>")
				M.take_overall_damage(0, max(0, (burned - 2)))

		if(!istype(M, /mob/living/carbon/slime) && !isrobot(M))
			M.stop_pulling()
			step(M, M.dir)
			spawn(1)
				for(var/i = 1 to slip_power)
					step(M, M.dir)
					sleep(1)
			M.take_organ_damage(2) // Was 5 -- TLE
			M.simple_message("<span class='notice'>You slipped on \the [name]!</span>",\
				"<span class='userdanger'>Please, just end the pain!</span>")
			playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
			M.Weaken(10)
			M.take_overall_damage(0, burned)

/obj/item/weapon/bananapeel/traitorpeel/throw_impact(atom/hit_atom)
	var/burned = rand(1,3)
	if(istype(hit_atom ,/mob/living))
		var/mob/living/M = hit_atom
		M.take_organ_damage(0, burned)
	return ..()
