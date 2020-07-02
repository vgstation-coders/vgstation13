/spell/targeted/alchemy
	name = "Street Alchemy"
	desc = "Gather all reagents contained in a target into an elixir. The elixir may be consumed."
	abbreviation = "SA"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	school = "transmutation"
	charge_max = 250
	cooldown_min = 30
	invocation_type = SpI_SHOUT
	range = 10 //If you can see it, you can steal it
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK | NEEDSHUMAN | INCLUDEUSER
	hud_state = "wiz_stAlch"
	price = 0.5 * Sp_BASE_PRICE
	spell_levels = list(Sp_SPEED = 0, Sp_POWER = 0, Sp_RANGE = 0, Sp_AMOUNT = 0)
	level_max = list(Sp_TOTAL = 30, Sp_SPEED = 3, Sp_POWER = 1, Sp_RANGE = 20, Sp_AMOUNT = 2)
	var/list/existingElixirs = list()
	var/elixirAmount = 1
	var/reagToSteal = 1

/spell/targeted/alchemy/invocation()
	invocation = pick("TH'X DAU KU", "DO'Z DAI LEE", "GIB'MI DAA'T")
	..()

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
			reagToSteal++
			if(spell_levels[Sp_RANGE] == 20)
				name = "Delving " + name
			return "You can pilfer from one more container per cast. Spell affects an area at max level"
		if(Sp_AMOUNT)
			spell_levels[Sp_AMOUNT]++
			elixirAmount++
			if(spell_levels[Sp_AMOUNT] == 3)
				name ="Bountiful " + name
			return "An additonal elixir can now exist."

/spell/targeted/alchemy/get_upgrade_price(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return 10
		if(Sp_POWER)
			return 10
		if(Sp_RANGE)
			return 1
		if(Sp_AMOUNT)
			return 5

/spell/targeted/alchemy/get_upgrade_info(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return
		if(Sp_POWER)
			return "Thrown elixirs transfer their contents into living targets."
		if(Sp_RANGE)
			if(spell_levels[Sp_RANGE] >= 21)
				return "You will now steal all reagents in an area."
			return "Pilfers from one more target per cast."
		if(Sp_AMOUNT)
			return "The amount of alchemic elixirs that can exist at a time."

/spell/targeted/alchemy/cast(list/targets, mob/user)
	for(var/target in targets)
		if(reagToSteal >= 21)
			aoeAlchemy(target, user)
			return
		singleAlchemy(target, user)

/spell/targeted/alchemy/proc/singleAlchemy(target, mob/user)
	var/obj/item/weapon/reagent_containers/pill/streetAlchElixir/elixir = null
	if(spell_levels[Sp_POWER])
		elixir = new /obj/item/weapon/reagent_containers/pill/streetAlchElixir/hypoElixir(src)
	else
		elixir = new /obj/item/weapon/reagent_containers/pill/streetAlchElixir(src)
	if(user.find_empty_hand_index())
		user.put_in_hands(elixir)
	if((iscarbon(target)) || (istype(target, /obj/structure)) || (istype(target, /obj/item/weapon)) || (istype(target, /obj/machinery)))
		legitAlchemy(target, user, elixir)
	if(elixir.is_empty())
		to_chat(user, "You found nothing of alchemic value.")
		user.drop_item(elixir, force_drop = 1)
		qdel(elixir)
		return
	existingElixirs += elixir
	if(existingElixirs.len > elixirAmount)
		var/tooMany = existingElixirs[1]
		existingElixirs -= tooMany
		qdel(tooMany)
	playsound(user, "sound/effects/bubbles.ogg", 75, 1)

/spell/targeted/alchemy/proc/aoeAlchemy(target, mob/user)
	var/obj/item/weapon/reagent_containers/pill/streetAlchElixir/elixir = null
	if(spell_levels[Sp_POWER])
		elixir = new /obj/item/weapon/reagent_containers/pill/streetAlchElixir/hypoElixir(src)
	else
		elixir = new /obj/item/weapon/reagent_containers/pill/streetAlchElixir(src)
	if(user.find_empty_hand_index())
		user.put_in_hands(elixir)
	for(var/T in range(1, target))
		if((iscarbon(T)) || (istype(T, /obj/structure)) || (istype(T, /obj/item/weapon)) || (istype(T, /obj/machinery)))
			legitAlchemy(T, user, elixir)
	if(elixir.is_empty())
		to_chat(user, "You found nothing of alchemic value.")
		user.drop_item(elixir, force_drop = 1)
		qdel(elixir)
		return
	existingElixirs += elixir
	if(existingElixirs.len > elixirAmount)
		var/tooMany = existingElixirs[1]
		existingElixirs -= tooMany
		qdel(tooMany)
	playsound(user, "sound/effects/bubbles.ogg", 75, 1)


/spell/targeted/alchemy/proc/legitAlchemy(var/atom/C, mob/user, var/obj/item/weapon/reagent_containers/pill/elixir)
	var/numThefts = 0
	if(C.reagents)
		C.reagents.trans_to(elixir, C.reagents.total_volume)
		numThefts++
	for(var/S in get_contents_in_object(C))
		if((numThefts >= reagToSteal) || (elixir.reagents.is_full()))
			break
		var/obj/R = S
		if((R.reagents) && (R.reagents.total_volume > 0))
			numThefts++
			R.reagents.trans_to(elixir, R.reagents.total_volume)
	playsound(C, "sound/effects/bubbles.ogg", 75, 1)

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

/obj/item/weapon/reagent_containers/pill/streetAlchElixir/hypoElixir/throw_impact(atom/hit_atom)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		src.reagents.trans_to(H,src.reagents.total_volume)
		to_chat(H, "You feel something infuse into your body.")
		playsound(H, "sound/effects/bubbles.ogg", 75, 1)
		qdel(src)

