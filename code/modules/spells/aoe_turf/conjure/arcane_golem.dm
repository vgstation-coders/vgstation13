/spell/aoe_turf/conjure/arcane_golem
	name = "Forge Arcane Golem"
	desc = "Creates a fragile construct that follows you around. It knows a basic version of all of your spells, and will cast them simultaneously with you - at the same target. If cast while an arcane golem is already summoned, your arcane golems will be teleported to you instead. It's unable to learn Mind Transfer and Forge Arcane Golem."

	charge_max = 20 SECONDS
	cooldown_min = 1 SECONDS

	spell_levels = list(Sp_SPEED = 0, Sp_AMOUNT = 0)
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 1, Sp_AMOUNT = 2) //each level of power grants 1 additional target.

	spell_flags = NEEDSCLOTHES | Z2NOCAST
	invocation = "ARCANUM VIRIUM CONGREGABO"
	invocation_type = SpI_SHOUT
	range = 0

	summon_type = list(/mob/living/simple_animal/hostile/arcane_golem)
	duration = 0

	hud_state = "wiz_summon_golem"

	var/golem_limit = 1
	var/list/golems = list()

	var/list/forbidden_spells = list(\
	/spell/aoe_turf/conjure/arcane_golem,\
	/spell/targeted/mind_transfer,\
	)

/spell/aoe_turf/conjure/arcane_golem/cast(list/targets, mob/user)
	//Link the golem to its master
	newVars = list("master_spell" = src)
	user.on_spellcast.Add(src, "copy_spellcast")

	check_golems()

	if(golems.len < golem_limit)
		//Can summon a golem
		return ..()
	else
		//Teleport golems to caster
		for(var/mob/living/L in golems)
			L.forceMove(get_step(user, pick(alldirs)))

/spell/aoe_turf/conjure/arcane_golem/proc/check_golems()
	for(var/mob/living/simple_animal/hostile/arcane_golem/AG in golems)
		if(!AG.master_spell)
			continue

		var/mob/master = AG.master_spell.holder
		if(AG.isDead() || !istype(master) || master.isDead())
			AG.master_spell = null
			golems.Remove(AG)

/spell/aoe_turf/conjure/arcane_golem/on_creation(mob/living/simple_animal/hostile/arcane_golem/AG, mob/user)
	for(var/spell/S in user.spell_list)
		if(is_type_in_list(S, forbidden_spells))
			continue

		var/spell/copy = new S.type
		copy.spell_flags = S.spell_flags & ~NEEDSCLOTHES //Remove robes requirement
		copy.charge_max = 0 //This is gonna suck with player controlled golems

		AG.add_spell(copy)

	AG.faction = "\ref[user]"
	to_chat(user, "<span class='sinister'>You infuse \the [AG] with your mana and knowledge. If it dies, your arcane abilities will be affected.</span>")
	src.golems.Add(AG)

/spell/aoe_turf/conjure/arcane_golem/proc/copy_spellcast(list/arguments)
	var/spell/spell_to_copy = arguments["spell"]
	var/target = arguments["target"]

	if(!istype(spell_to_copy) || !istype(spell_to_copy.holder))
		return

	var/turf/caster_turf = get_turf(spell_to_copy.holder)
	if(!istype(caster_turf))
		return

	var/cast_dir = spell_to_copy.holder.dir

	//Convert the target argument to a list of targets
	var/list/targets
	if(istype(target, /list))
		var/list/L = target
		targets = L.Copy()
	else if(!isnull(target))
		targets = list(target)

	for(var/mob/living/simple_animal/hostile/arcane_golem/AG in golems)
		var/spell/cast_spell = locate(spell_to_copy.type) in AG.spell_list
		if(!istype(cast_spell))
			continue

		AG.change_dir(cast_dir) //Face the same direction as the wizard

		//If the spell is targeted, OR the target can't be picked by the computer (because there's a popup menu or something like that)
		//Use the same target as the main caster
		if(!(cast_spell.spell_flags & WAIT_FOR_CLICK) && !(cast_spell.autocast_flags & AUTOCAST_NOTARGET))
			targets = cast_spell.choose_targets(AG)

		//Golems cast spells AFTER the wizard
		spawn(rand(1,3))
			AG.cast_spell(cast_spell, targets.Copy())

//UPGRADES
/spell/aoe_turf/conjure/arcane_golem/apply_upgrade(upgrade_type)
	switch(upgrade_type)
		if(Sp_AMOUNT)
			spell_levels[Sp_AMOUNT]++
			golem_limit++

			return "You can now sustain [golem_limit] golems at once."

	return ..()

///INFO

/spell/aoe_turf/conjure/arcane_golem/get_upgrade_info(upgrade_type)
	switch(upgrade_type)
		if(Sp_AMOUNT)
			return "Gain the ability to sustain [golem_limit + 1] golems at once."

	return ..()
