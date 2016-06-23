/obj/structure/lamarr
	name = "Lab Cage"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "labcage1"
	desc = "A glass lab container for storing interesting creatures."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete Lamarr
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
				health -= 15
				healthcheck()
		if (3)
			if (prob(50))
				health -= 5
				healthcheck()


/obj/structure/lamarr/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return


/obj/structure/lamarr/blob_act()
	if (prob(75))
		getFromPool(/obj/item/weapon/shard, loc)
		Break()
		qdel(src)

/obj/structure/lamarr/proc/healthcheck()
	if (health <= 0)
		if (!( destroyed ))
			density = 0
			destroyed = 1
			getFromPool(/obj/item/weapon/shard, loc)
			playsound(src, "shatter", 70, 1)
			Break()
	else
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/lamarr/update_icon()
	if(destroyed)
		icon_state = "labcageb[occupied]"
	else
		icon_state = "labcage[occupied]"
	return


/obj/structure/lamarr/attackby(obj/item/weapon/W as obj, mob/user as mob)
	health -= W.force
	healthcheck()
	..()
	return

/obj/structure/lamarr/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/lamarr/attack_hand(mob/user as mob)
	if (destroyed)
		return
	else
		to_chat(usr, text("<span class='notice'>You kick the lab cage.</span>"))
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				to_chat(O, text("<span class='warning'>[] kicks the lab cage.</span>", usr))
		health -= 2
		healthcheck()
		return

/obj/structure/lamarr/proc/Break()
	if(occupied)
		new /obj/item/clothing/mask/facehugger/lamarr(loc)
		occupied = 0
	update_icon()
	return

/obj/item/clothing/mask/facehugger/lamarr
	name = "Lamarr"
	desc = "The worst she might do is attempt to... couple with your head."//hope we don't get sued over a harmless reference, rite?
	sterile = 1
	setGender(FEMALE)

/obj/item/clothing/mask/facehugger/lamarr/New()//to prevent deleting it if aliums are disabled
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

		reagents.clear_reagents()
	..()

/obj/item/clothing/mask/facehugger/lamarr/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers/syringe))
		if(loc == user && user.is_holding_item(W))
			processing_objects.Add(src)
	else
		..(W, user)
		return