/**
	Put /obj/smithing_placeholder into a heatsource that is 90% of the melting temperature of that material to heat it up temporarily (spawn 10 seconds)

	If struck by a blunt object (preferably a hammer, but a toolbox can work) enough times before it cools, it will make the object.

	Can then choose to keep striking it to potentially increase its quality, but each time doubles the chance of failure per swing.
**/

/obj/item/smithing_placeholder
	name = "placeholder"
	desc = "An incomplete object, that requires forging and striking."
	var/obj/result
	var/malleable = FALSE
	var/strikes_required
	var/strikes

/obj/item/smithing_placeholder/Destroy()
	result = null
	..()

/obj/item/smithing_placeholder/New(loc, var/obj/item/stack/S, var/obj/R, var/required_strikes)
	..()
	if(istype(S, /obj/item/stack/sheet/))
		var/obj/item/stack/sheet/SS = S
		var/datum/materials/materials_list = new
		material_type = materials_list.getMaterial(SS.mat_type)
		qdel(materials_list)
	else if(S.material_type)
		material_type = S.material_type
	result = R
	R.forceMove(null)
	var/obj/item/stack/sheet/mineral/M = material_type.sheettype
	appearance = initial(M.appearance)
	desc = initial(desc)
	strikes_required = required_strikes

/obj/item/smithing_placeholder/examine(mob/user)
	..()
	to_chat(user, "<span class = 'notice'>[strikes?"It looks like it has been struck [strikes] times.":"It has not been struck yet."]<br>It is [malleable?"malleable":"not malleable"].[strikes_required<strikes?"<br>It looks to be finished, and just needs quenching.":""]")


/obj/item/smithing_placeholder/afterattack(atom/A, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(isobj(A))
		var/obj/O = A
		if(O.is_hot())
			heat(O.is_hot(), O, user)
		if(O.is_open_container() && O.reagents.has_reagent(WATER, 60))
			quench(O, user)
	if(istype(A, /mob/living/simple_animal/hostile/asteroid/magmaw)) //Until we have flameslimes, lavalizards, crimson pyromancers, or flaming skeletons, this will be hardcoded
		var/mob/living/simple_animal/hostile/asteroid/magmaw/M = A
		if(M.isDead())
			return
		var/temperature
		switch(M.fire_extremity)
			if(0)
				temperature = MELTPOINT_GOLD
			if(1)
				temperature = MELTPOINT_STEEL
			if(2)
				temperature = MELTPOINT_MYTHRIL
		heat(temperature, M, user)

/obj/item/smithing_placeholder/attackby(obj/item/I, mob/user)
	if(ishammer(I))
		strike(I, user)
		user.delayNextAttack(1 SECONDS)
	else if (I.is_hot())
		heat(I.is_hot(), I, user)

/obj/item/smithing_placeholder/attempt_heating(var/atom/A, mob/user)
	if(user)
		to_chat(user, "<span class = 'notice'>You attempt to heat \the [src] with \the [A].</span>")
	heat(A.is_hot(), A, user)

/obj/item/smithing_placeholder/proc/heat(var/temperature, var/atom/A, mob/user)
	if(malleable)
		return
	if(temperature < ((material_type.melt_temperature/10)*9))
		if(user)
			to_chat(user, "<span class = 'warning'>\The [A] is not hot enough.</span>")
		return
	else if(!user)
		visible_message("<span class='notice'>\The [src] begins heating up.</span>")
	if(user)
		to_chat(user, "<span class = 'notice'>You heat \the [src].</span>")
	if(iswelder(A) && user)
		var/obj/item/weapon/weldingtool/W = A
		if(!W.do_weld(user, src, 4 SECONDS/(temperature/material_type.melt_temperature), 5))
			return
	else if(user && !do_after(user, A, 4 SECONDS/(temperature/material_type.melt_temperature)))
		return
	malleable = TRUE
	spawn(2 MINUTES)
		malleable = FALSE


/obj/item/smithing_placeholder/proc/strike(var/obj/A, mob/user)
	if(!malleable)
		to_chat(user, "<span class = 'warning'>\The [src] has gone cool. It can not be manipulated in this state.</span>")
		return
	if(!hasanvil(loc))
		to_chat(user, "<span class = 'warning'>There is no anvil to shape \the [src] over.</span>")
		return
	playsound(loc, 'sound/items/hammer_strike.ogg', 50, 1)
	if(istype(A,/obj/item/weapon/hammer))
		strikes+=max(1, round(A.quality/2))
	else if(istype(A,/obj/item/weapon/storage/toolbox))
		strikes+=0.25
	if(strikes == strikes_required)
		to_chat(user, "<span class = 'notice'>\The [src] seems to have taken shape nicely.</span>")
	if(strikes > strikes_required)
		if(prob(5*(strikes/strikes_required)))
			to_chat(user, "<span class = 'warning'>\The [src] becomes brittle and unmalleable.</span>")
			var/obj/item/stack/ore/slag/S = drop_stack(/obj/item/stack/ore/slag, get_turf(src))
			recycle(S.mats)
			result.recycle(S.mats)
			qdel(result)
			qdel(src)


/obj/item/smithing_placeholder/proc/quench(obj/O, mob/user)
	if(strikes < strikes_required)
		to_chat(user, "<span class = 'warning'>\The [src] is not finished yet!</span>")
		return 0
	playsound(loc, 'sound/machines/hiss.ogg', 50, 1)
	O.reagents.remove_reagent(WATER, 20)
	var/datum/material/mat = material_type
	if(mat)
		result.dorfify(mat, strikes>strikes_required?(strikes/strikes_required):0)
	result.forceMove(get_turf(src))
	qdel(src)
