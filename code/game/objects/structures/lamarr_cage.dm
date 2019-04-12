/obj/structure/lamarr
	name = "Lab Cage"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "labcage1"
	desc = "A glass lab container for storing interesting creatures."
	density = 1
	anchored = 1
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/lamarr/ex_act(severity)
	switch(severity)
		if (1)
			getFromPool(/obj/item/weapon/shard, loc)
			Break()
			qdel(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()


/obj/structure/lamarr/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	src.healthcheck()
	return


/obj/structure/lamarr/blob_act()
	if (prob(75))
		getFromPool(/obj/item/weapon/shard, loc)
		Break()
		qdel(src)

/obj/structure/lamarr/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			setDensity(FALSE)
			src.destroyed = 1
			getFromPool(/obj/item/weapon/shard, loc)
			playsound(src, "shatter", 70, 1)
			Break()
	else
		playsound(src, 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/lamarr/update_icon()
	if(src.destroyed)
		src.icon_state = "labcageb[src.occupied]"
	else
		src.icon_state = "labcage[src.occupied]"
	return


/obj/structure/lamarr/attackby(obj/item/weapon/W as obj, mob/user as mob)
	src.health -= W.force
	src.healthcheck()
	..()
	return

/obj/structure/lamarr/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/lamarr/attack_hand(mob/user as mob)
	if (src.destroyed)
		return
	else
		to_chat(usr, text("<span class='notice'>You kick the lab cage.</span>"))
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				to_chat(O, text("<span class='warning'>[] kicks the lab cage.</span>", usr))
		src.health -= 2
		healthcheck()
		return

/obj/structure/lamarr/proc/Break()
	if(occupied)
		new /obj/item/clothing/mask/facehugger/lamarr(src.loc)
		occupied = 0
	update_icon()
	return

/obj/structure/lamarr/acidable()
	return 0

/obj/item/clothing/mask/facehugger/lamarr
	name = "Lamarr"
	desc = "The worst she might do is attempt to... couple with your head."//hope we don't get sued over a harmless reference, rite?
	sterile = 1
	gender = FEMALE

/obj/item/clothing/mask/facehugger/lamarr/New()
	..()
	create_reagents(15)

/obj/item/clothing/mask/facehugger/lamarr/process()
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		if(reagents)
			for (var/datum/reagent/current_reagent in reagents.reagent_list)
				if (current_reagent.id == CREATINE)
					to_chat(H, "<span class='warning'>[src]'s body contorts and expands!</span>")
					var/index = H.is_holding_item(src)

					H.drop_item(src, force_drop = 1)
					var/obj/item/weapon/gun/projectile/hivehand/I = new (get_turf(H))

					if(index)
						H.put_in_hand(index, I)
					qdel(src)
					return

		reagents.clear_reagents()
	..()

/obj/item/clothing/mask/facehugger/lamarr/attackby(obj/item/weapon/W, mob/user)
	if(!istype(W, /obj/item/weapon/reagent_containers/syringe))
		..(W, user)

/obj/item/clothing/mask/facehugger/lamarr/on_syringe_injection(var/mob/user, var/obj/item/weapon/reagent_containers/syringe/tool)
	if(!user.is_holding_item(src) && stat != DEAD)
		to_chat(user, "<span class='warning'>[src] is squirming around too much. She needs to be held still.</span>")
		return INJECTION_RESULT_FAIL
	return ..()
