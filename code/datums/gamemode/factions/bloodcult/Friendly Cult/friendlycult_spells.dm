

/spell/cult/trace_rune/friendly_cult
	name = "Trace Friendly Rune"
	desc = "(1 BLOOD) Use available blood to write down words. Three words form a friendly rune."

	cast_delay = 15
	override_base = "grey"
	runeset_identifier = "friendly_cult"
	
/spell/cult/erase_rune/friendly_cult
	override_base = "grey"
	
/spell/cult/trace_rune/friendly_cult/spell_do_after(var/mob/user, var/delay, var/numticks = 3)
	if(block)
		return 0
	block = 1

	if(!istype(user.loc, /turf))
		to_chat(user, "<span class='warning'>You do not have enough space to write a proper rune.</span>")
		return 0

	var/turf/T = get_turf(user)
	rune = locate() in T 

	if(rune)
		if (rune.invisibility == INVISIBILITY_OBSERVER)
			to_chat(user, "<span class='warning'>You can feel the presence of a concealed rune here. You have to reveal it before you can add more words to it.</span>")
			return 0
		else if (rune.word1 && rune.word2 && rune.word3)
			to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
			return 0

	if(spell)
		var/datum/runeword/friendly_cult/instance
		if(!rune)
			instance = initial(spell.word1)
		else if (rune.word1.type != initial(spell.word1))
			to_chat(user, "<span class='warning'>This rune's first word conflicts with the [initial(spell.name)] rune's syntax.</span>")
			to_chat(user, "<span class='warning'>[rune.word1.type] --- [spell.word1.type]</span>")
			return 0
		else if (!rune.word2)
			instance = initial(spell.word2)
		else if (rune.word2.type != initial(spell.word2))
			to_chat(user, "<span class='warning'>This rune's second word conflicts with the [initial(spell.name)] rune's syntax.</span>")
			return 0
		else if (!rune.word3)
			instance = initial(spell.word3)
		else
			to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
			return 0
		word = initial(instance.english)
	else
		var/list/available_runes = list()
		var/i = 1
		for(var/friendly_spell in subtypesof(/datum/rune_spell/friendly_cult))
			var/datum/rune_spell/friendly_cult/instance = friendly_spell
			available_runes.Add("\Roman[i]-[initial(instance.name)]")
			available_runes["\Roman[i]-[initial(instance.name)]"] = instance
			i++
		var/spell_name = input(user,"Draw a rune.", "Trace Complete Rune", null) as null|anything in available_runes
		spell = available_runes[spell_name]	
		var/datum/runeword/friendly_cult/instance
		if(!rune)
			instance = initial(spell.word1)
		else if (rune.word1.type != initial(spell.word1))
			to_chat(user, "<span class='warning'>This rune's first word conflicts with the [initial(spell.name)] rune's syntax.</span>")
			to_chat(user, "<span class='warning'>[rune.word1.type] --- [spell.word1.type]</span>")
			return 0
		else if (!rune.word2)
			instance = initial(spell.word2)
		else if (rune.word2.type != initial(spell.word2))
			to_chat(user, "<span class='warning'>This rune's second word conflicts with the [initial(spell.name)] rune's syntax.</span>")
			return 0
		else if (!rune.word3)
			instance = initial(spell.word3)
		else
			to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
			return 0
		word = initial(instance.english)		

	if(!word)
		return 0

	data = use_available_blood(user, blood_cost) 
	if(data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
		return 0

	if(rune)
		user.visible_message("<span class='warning'>\The [user] chants and paints more symbols on the floor.</span>",\
				"<span class='warning'>You add another word to the rune.</span>",\
				"<span class='warning'>You hear chanting.</span>")
	else
		user.visible_message("<span class='warning'>\The [user] begins to chant and paint symbols on the floor.</span>",\
				"<span class='warning'>You begin drawing a rune on the floor.</span>",\
				"<span class='warning'>You hear some chanting.</span>")

	user.whisper("...[global_runesets[runeset_identifier].words[word].rune]...")
	return ..()
		
/proc/issiliconcultist(var/user)
	if(istype(user, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/target = user
		if(target.module && /obj/item/borg/upgrade/cult in target.module.upgrades)
			return 1
	return 0