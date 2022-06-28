/obj/item/weapon/grenade/clown_grenade
	name = "Banana Grenade"
	desc = "A grenade used for rapid slipping of larger areas. Contains banana peels that release acid when slipped on."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	icon_state = "banana"
	item_state = "banana" //banana inhand sprites when
	w_class = W_CLASS_SMALL
	force = 2.0
	var/stage = 0
	var/state = 0
	var/path = 0
	var/affected_area = 2

/obj/item/weapon/grenade/clown_grenade/New()
	icon_state = initial(icon_state)

/obj/item/weapon/grenade/clown_grenade/prime()
	..()
	playsound(src, 'sound/items/bikehorn.ogg', 25, -3)
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
	icon = 'icons/obj/hydroponics/banana.dmi'
	icon_state = "peel"
	item_state = "banana_peel"
	w_class = W_CLASS_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20

	slip_override = 5

/obj/item/weapon/bananapeel/traitorpeel/handle_slip(atom/movable/AM)
	if(isliving(AM))
		var/burned = rand(2,5)
		var/mob/living/M = AM
		if(M.lying)
			M.take_overall_damage(0, max(0, (burned - 2)))
			M.simple_message("<span class='danger'>Something burns your back!</span>",\
				"<span class='userdanger'>They're eating your back!</span>")
			return 0

		if(ishuman(M))
			if(M.CheckSlip())
				M.simple_message("<span class='warning'>Your feet feel like they're on fire!</span>",\
					"<span class='userdanger'>Egads! They bite your feet!</span>")
				M.take_overall_damage(0, max(0, (burned - 2)))
			else
				return 0

		if(!istype(M, /mob/living/carbon/slime) && !isrobot(M))
			slip_n_slide(M, 10, 10, "<span class='userdanger[iscarbon(M) ? " notice" : ""]'>Please, just end the pain!</span>")
			M.take_organ_damage(2) // Was 5 -- TLE
			M.take_overall_damage(0, burned)
		return 1
	return ..()

/obj/item/weapon/bananapeel/traitorpeel/throw_impact(atom/hit_atom)
	var/burned = rand(1,3)
	if(istype(hit_atom ,/mob/living))
		var/mob/living/M = hit_atom
		M.take_organ_damage(0, burned)
	return ..()
