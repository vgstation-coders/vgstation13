/mob/proc/add_spell(var/spell/spell_to_add, var/spell_base = "wiz_spell_ready", var/master_type = /obj/abstract/screen/movable/spell_master, var/iswizard = FALSE, var/on_added = TRUE)
	if(ispath(spell_to_add, /spell))
		spell_to_add = new spell_to_add

	if(!spell_masters)
		spell_masters = list()

	spell_to_add.set_holder(src)
	if(spell_masters.len)
		for(var/obj/abstract/screen/movable/spell_master/spell_master in spell_masters)
			if(spell_master.type == master_type)
				spell_list.Add(spell_to_add)
				spell_master.add_spell(spell_to_add)
				if(mind && iswizard)
					if(!mind.wizard_spells)
						mind.wizard_spells = list()
					mind.wizard_spells += spell_to_add
				if(on_added) //If we want to call this spell proc
					spell_to_add.on_added(src)
				return 1

	//Don't do the spellmaster menu stuff if there's not supposed to be a button for the spell
	var/create_spellmaster = !(spell_to_add.spell_flags & NO_BUTTON)
	if(create_spellmaster)
		var/obj/abstract/screen/movable/spell_master/new_spell_master = new master_type //we're here because either we didn't find our type(or we have no spell masters to attach t)
		if(client)
			src.client.screen += new_spell_master
		new_spell_master.spell_holder = src
		new_spell_master.add_spell(spell_to_add)
		if(spell_base)
			new_spell_master.icon_state = spell_base
		spell_masters.Add(new_spell_master)
	spell_list.Add(spell_to_add)
	if(mind && iswizard)
		if(!mind.wizard_spells)
			mind.wizard_spells = list()
		mind.wizard_spells += spell_to_add
	if(on_added)
		spell_to_add.on_added(src)
	return 1

/mob/proc/cast_spell(spell/spell_to_cast, list/targets)
	if(ispath(spell_to_cast, /spell))
		spell_to_cast = locate(spell_to_cast) in spell_list

		if(!istype(spell_to_cast))
			return FALSE

	spell_to_cast.perform(src, 0, targets)

/mob/proc/remove_spell(var/spell/spell_to_remove, var/on_removed = TRUE)
	if(!spell_to_remove || !istype(spell_to_remove))
		return

	if(!(spell_to_remove in spell_list))
		return

	if(!spell_masters || !spell_masters.len)
		return

	var/obj/abstract/screen/movable/spell_master/master = spell_to_remove.connected_button.spellmaster
	if(!(master in spell_masters))
		return
	master.remove_spell(spell_to_remove)

	if(mind && mind.wizard_spells)
		mind.wizard_spells.Remove(spell_to_remove)
	if(on_removed)
		spell_to_remove.on_removed(src)
	spell_list.Remove(spell_to_remove)
	return 1

/mob/proc/silence_spells(var/amount = 0)
	if(!(amount >= 0))
		return

	if(!spell_masters || !spell_masters.len)
		return

	for(var/obj/abstract/screen/movable/spell_master/spell_master in spell_masters)
		spell_master.silence_spells(amount)

//The spell already exists and is merely getting transferred, let's move it to the new character.
//Overrides both on_removed and on_added in order to perform on_transfer()
/proc/transfer_spell(var/mob/living/new_character, var/mob/living/old_character, var/spell/spell_to_transfer)
	if(!old_character || !new_character || !spell_to_transfer || !istype(spell_to_transfer))
		return
	old_character.remove_spell(spell_to_transfer, on_removed = FALSE)
	new_character.add_spell(spell_to_transfer, on_added = FALSE)
	spell_to_transfer.on_transfer()
