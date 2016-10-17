/mob/proc/add_spell(var/spell/spell_to_add, var/spell_base = "wiz_spell_ready", var/master_type = /obj/screen/movable/spell_master)
	if(ispath(spell_to_add, /spell))
		spell_to_add = new spell_to_add

	if(!spell_masters)
		spell_masters = list()

	spell_to_add.holder = src
	if(spell_masters.len)
		for(var/obj/screen/movable/spell_master/spell_master in spell_masters)
			if(spell_master.type == master_type)
				spell_list.Add(spell_to_add)
				spell_master.add_spell(spell_to_add)
				spell_to_add.on_added(src)
				return 1

	var/obj/screen/movable/spell_master/new_spell_master = getFromPool(master_type) //we're here because either we didn't find our type, or we have no spell masters to attach to
	if(client)
		src.client.screen += new_spell_master
	new_spell_master.spell_holder = src
	new_spell_master.add_spell(spell_to_add)
	if(spell_base)
		new_spell_master.icon_state = spell_base
	spell_masters.Add(new_spell_master)
	spell_list.Add(spell_to_add)
	spell_to_add.on_added(src)
	return 1

/mob/proc/cast_spell(spell/spell_to_cast, list/targets)
	if(ispath(spell_to_cast, /spell))
		spell_to_cast = locate(spell_to_cast) in spell_list

		if(!istype(spell_to_cast))
			return FALSE

	spell_to_cast.perform(src, 0, targets)

/mob/proc/remove_spell(var/spell/spell_to_remove)
	if(!spell_to_remove || !istype(spell_to_remove))
		return

	if(!(spell_to_remove in spell_list))
		return

	if(!spell_masters || !spell_masters.len)
		return

	spell_to_remove.on_removed(src)
	if(mind && mind.wizard_spells)
		mind.wizard_spells.Remove(spell_to_remove)
	spell_list.Remove(spell_to_remove)
	for(var/obj/screen/movable/spell_master/spell_master in spell_masters)
		spell_master.remove_spell(spell_to_remove)
	return 1

/mob/proc/silence_spells(var/amount = 0)
	if(!(amount >= 0))
		return

	if(!spell_masters || !spell_masters.len)
		return

	for(var/obj/screen/movable/spell_master/spell_master in spell_masters)
		spell_master.silence_spells(amount)
