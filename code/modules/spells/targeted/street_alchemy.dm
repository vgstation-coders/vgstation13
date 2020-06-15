/spell/targeted/alchemy
	name = "Street Alchemy"
	desc = "Gather all reagents contained in a target into an elixir. The elixir may be consumed."
	abbreviation = "SA"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	school = "transmutation"
	charge_max = 150
	cooldown_min = 15
	invocation_type = SpI_NONE
	range = 10 //If you can see it, you can steal it
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK | NEEDSHUMAN | INCLUDEUSER
	hud_state = "wiz_stAlch"
	price = 0.5 * Sp_BASE_PRICE
	spell_levels = list(Sp_SPEED = 0, Sp_POWER = 0, Sp_RANGE = 0)
	level_max = list(Sp_TOTAL = 4, Sp_SPEED = 3, Sp_POWER = 1, Sp_RANGE = 1)

/spell/targeted/alchemy/apply_upgrade(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return quicken_spell()
		if(Sp_POWER)
			spell_levels[Sp_POWER]++
			name = "Permeating " + name
			return "Thrown elixirs now transfer reagents."
		if(Sp_RANGE)
			spell_levels[Sp_RANGE]++
			return "You now pilfer in an area around the target."

/spell/targeted/alchemy/get_upgrade_info(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return "Reduce this spell's cooldown."
		if(Sp_POWER)
			return "Thrown elixirs transfer their contents into living targets."
		if(Sp_RANGE)
			return "Pilfers reagents in an area around the target."

/spell/targeted/alchemy/cast(list/targets, mob/user)
	for(var/target in targets)
		if(spell_levels[Sp_RANGE])
			aoeAlchemy(target, user)
			return
		singleAlchemy(target, user)

/spell/targeted/alchemy/proc/singleAlchemy(target, mob/user)
	var/obj/item/weapon/reagent_containers/pill/streetAlchElixir/A = null
	if(spell_levels[Sp_POWER])
		A = new /obj/item/weapon/reagent_containers/pill/streetAlchElixir/hypoElixir(src)
	else
		A = new /obj/item/weapon/reagent_containers/pill/streetAlchElixir(src)
	if(user.find_empty_hand_index())
		user.put_in_hands(A)
	if(iscarbon(target))
		mobAlchemy(target, user, A)
	if((istype(target, /obj/structure)) || (istype(target, /obj/item/weapon/storage)) || (istype(target, /obj/item/weapon/reagent_containers)) || (istype(target, /obj/machinery)))
		itemAlchemy(target, user, A)
	if(A.is_empty())
		to_chat(user, "You fail to perform alchemy.")
		user.drop_item(A, force_drop = 1)
		qdel(A)
		return
	to_chat(user, "You perform alchemy.")
	playsound(user, "sound/effects/bubbles.ogg", 75, 1)

/spell/targeted/alchemy/proc/aoeAlchemy(target, mob/user)
	var/obj/item/weapon/reagent_containers/pill/streetAlchElixir/A = null
	if(spell_levels[Sp_POWER])
		A = new /obj/item/weapon/reagent_containers/pill/streetAlchElixir/hypoElixir(src)
	else
		A = new /obj/item/weapon/reagent_containers/pill/streetAlchElixir(src)
	if(user.find_empty_hand_index())
		user.put_in_hands(A)
	for(var/T in range(2, target))
		if(iscarbon(T))
			mobAlchemy(T, user, A)
		if((istype(T, /obj/structure)) || (istype(T, /obj/item/weapon/storage)) || (istype(T, /obj/item/weapon/reagent_containers)) || (istype(T, /obj/machinery)))
			itemAlchemy(T, user, A)
	if(A.is_empty())
		to_chat(user, "You fail to perform alchemy.")
		user.drop_item(A, force_drop = 1)
		qdel(A)
		return
	to_chat(user, "You perform alchemy.")
	playsound(user, "sound/effects/bubbles.ogg", 75, 1)

/spell/targeted/alchemy/proc/mobAlchemy(var/mob/living/carbon/C, mob/user, var/A)
	for(var/S in get_contents_in_object(C))
		if(istype(S, /obj/item/weapon/reagent_containers))
			var/obj/item/weapon/reagent_containers/F = S
			F.reagents.trans_to(A, F.reagents.total_volume)
	C.reagents.trans_to(A, C.reagents.total_volume)
	playsound(C, "sound/effects/bubbles.ogg", 75, 1)

/spell/targeted/alchemy/proc/itemAlchemy(var/obj/C, mob/user, var/A)
//	if(istype(C, /obj/machinery/vending))
//		var/obj/machinery/vending/V = C
//		for(var/obj/item/weapon/reagent_containers/product in V.products)
//			var/P = initial(product)
//			A.reagents += P.reagent_list
	if(C.contents)
		for(var/obj/item/i in C.contents)
			if(i.contents)
				for(var/obj/item/weapon/reagent_containers/ii in i.contents)
					if(ii.reagents)
						ii.reagents.trans_to(A, ii.reagents.total_volume)
				if(i.reagents)
					i.reagents.trans_to(A,i.reagents.total_volume)
	if(C.reagents)
		C.reagents.trans_to(A,C.reagents.total_volume)

/obj/item/weapon/reagent_containers/pill/streetAlchElixir
	name = "alchemic elixir"
	desc = "An elixir of various reagents gathered through legitimate alchemical practice."
	icon = 'icons/obj/potions.dmi'
	icon_state = "streetalch_elixir"
	item_state = "beaker"
	volume = 1000
	flags = NOREACT
	layer = ABOVE_OBJ_LAYER

/obj/item/weapon/reagent_containers/pill/streetAlchElixir/examine(mob/user)
	..()
	if(get_dist(user,src) > 3)
		to_chat(user, "<span class='info'>You can't make out the contents.</span>")
		return
	if(reagents)
		reagents.get_examine(user)

/obj/item/weapon/reagent_containers/pill/streetAlchElixir/hypoElixir

/obj/item/weapon/reagent_containers/pill/streetAlchElixir/hypoElixir/throw_impact(atom/hit_atom)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		src.reagents.trans_to(H,src.reagents.total_volume)
		to_chat(H, "You feel something infuse into your body.")
		playsound(H, "sound/effects/bubbles.ogg", 75, 1)
	qdel(src)

