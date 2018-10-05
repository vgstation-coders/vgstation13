/**
	Put /obj/smithing_placeholder into a heatsource that is 90% of the melting temperature of that material to heat it up temporarily (spawn 10 seconds)

	If struck by a blunt object (preferably a hammer, but a toolbox can work) enough times before it cools, it will make the object.

	Can then choose to keep striking it to potentially increase its quality, but each time doubles the chance of failure per swing.
**/

/obj/item/smithing_placeholder
	name = "placeholder"
	desc = "You should not be able to see this"
	var/obj/result
	var/malleable = FALSE
	var/strikes_required
	var/strikes

/obj/item/smithing_placeholder/New(loc, var/obj/item/stack/S, var/obj/result)
	..()
	if(istype(S, /obj/item/stack/sheet/))
		var/obj/item/stack/sheet/SS = S
		mat = materials_list.getMaterial(SS.mat_type)
	else if(S.material_type)
		mat = S.material_type
	result = result
	appearance = result.appearance

/obj/item/smithing_placeholder/afterattack(atom/A, mob/living/user, flags, params, struggle = 0)
	if(isobj(A))
		var/obj/O = A
		if(!malleable && O.is_hot() >= ((material_type.melt_temperature/10)*9)) //90% of the melting temperature
			malleable = TRUE
			spawn(O.thermal_energy_transfer()/10)
				to_chat(user, "<span class = 'notice'>\The [src] cools down.</span>")
				malleable = FALSE
		if(O.is_open_container() && O.reagents.has_reagent(WATER, 60))
			quench(O, user)

/obj/item/smithing_placeholder/attackby(obj/item/I, mob/user)
	if(ishammer(I))
		strike(I, user)
	else if (!malleable && I.is_hot() && I.is_hot() >= ((material_type.melt_temperature/10)*9))
		malleable = TRUE
		spawn(I.thermal_energy_transfer()/10)
			to_chat(user, "<span class = 'notice'>\The [src] cools down.</span>")
			malleable = FALSE

/obj/item/smithing_placeholder/proc/strike(atom/A, mob/user)
	if(malleable)
		playsound(loc, 'sound/items/hammer_strike.ogg', 50, 1)
		switch(A.type)
			if(/obj/item/weapon/hammer)
				strikes++
			if(/obj/item/weapon/storage/toolbox)
				strikes+=0.25
		if(strikes == strikes_required)
			to_chat(user, "<span class = 'notice'>\The [src] seems to have taken shape nicely.</span>")
		if(strikes > strikes_required)
			if(prob(5*(strikes/strikes_required)))
				to_chat(user, "<span class = 'warning'>\The [src] becomes brittle and unmalleable.</span>")
				var/obj/item/weapon/ore/slag/S = new /obj/item/weapon/ore/slag(loc)
				recycle(S.materials)
				qdel(src)
				return
	else
		to_chat(user, "<span class = 'warning'>\The [src] has gone cool. It can not be manipulated in this state.</span>")
		return

/obj/item/smithing_placeholder/proc/quench(obj/O, mob/user)
	if(strikes < strikes_required)
		to_chat(user, "<span class = 'warning'>\The [src] is not finished yet!</span>")
		return 0
	playsound(loc, 'sound/machines/hiss.ogg', 50, 1)
	O.reagents.remove_reagents(WATER, 20)
	result.forceMove(loc)
	result.gen_quality(strikes/strikes_required)
	if(result.quality > SUPERIOR)
		result.gen_description()
	qdel(src)