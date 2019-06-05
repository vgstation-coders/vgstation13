/spell/cult/friendly_trace_rune //For cyborg module
	name = "Trace Rune"
	desc = "(1 BLOOD) Use available blood to write down words. Three words form a rune."
	hud_state = "cult_word"
	override_base = "vamp"
	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 0
	range = 0
	spell_flags = null
	insufficient_holder_msg = "<span class='warning'>You cannot write another word just yet.</span>"
	still_recharging_msg = "<span class='warning'>You cannot write another word just yet.</span>"

	cast_delay = 15

	var/list/data = list()
	var/datum/friendly_cultword/word = null
	var/obj/effect/rune/rune = null
	var/datum/rune_spell/spell = null
	var/remember = 0
	var/blood_cost = 1
	
/spell/cult/friendly_trace_rune/choose_targets(var/mob/user = usr)
	return list(user)
	
/spell/cult/friendly_trace_rune/before_channel(mob/user)
	if (remember)
		remember = 0
	else
		spell = null//so we're not stuck trying to write the same spell over and over again

	return 1
	
/spell/cult/friendly_trace_rune/spell_do_after(var/mob/user, var/delay, var/numticks = 3)

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
			to_chat(user, "<span class='warning'>You can feel the presence of a concealed rune here, you have to reveal it before you can add more words to it.</span>")
			return 0
		else if (rune.word1 && rune.word2 && rune.word3)
			to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
			return 0


	else
		var/list/available_runes = list()
		var/i = 1
		for(var/subtype in subtypesof(/datum/friendly_rune_spell))
			var/datum/friendly_rune_spell/instance = subtype
			available_runes.Add("\Roman[i]-[initial(instance.name)]")
			available_runes["\Roman[i]-[initial(instance.name)]"] = instance
			i++
		var/spell_name = input(user,"Choose a rune to draw.", "Trace Complete Rune", null) as null|anything in available_runes
		spell = available_runes[spell_name]
		var/datum/friendly_cultword/instance
		
		if (!rune)
			instance = initial(spell.word1)
		else if (rune.word1.type != initial(spell.word1))
			to_chat(user, "<span class='warning'>This rune's first word conflicts with the [initial(spell.name)] rune's syntax.</span>")
			return 0
		else if (!rune.word2)
			instance = initial(spell.word2)
		else if (rune.word2.type != initial(spell.word2))
			to_chat(user, "<span class='warning'>This rune's second word conflicts with the [initial(spell.name)] rune's syntax.</span>")
			return 0
		else if (!rune.word3)
			instance = initial(spell.word3)
		else //Should never happen
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

	var/datum/friendly_cultword/r_word = friendly_cultwords[word]
	user.whisper("...[r_word.rune]...")
	
	return ..()

/spell/cult/friendly_trace_rune/cast(var/list/targets, var/mob/user)
	..()
	if (rune && rune.word1 && rune.word2 && rune.word3)
		to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
		return
	if (write_rune_word(get_turf(user) ,data["blood"] ,word = friendly_cultwords[word]) > 1)
		remember = 1
		perform(user)


/spell/cult/friendly_erase_rune
	name = "Erase Rune"
	desc = "Remove the last word written of the friendly rune you're standing above."
	hud_state = "cult_erase"
	override_base = "vamp"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 0
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

/spell/cult/friendly_erase_rune/choose_targets(var/mob/user = usr)
	return list(user)

/spell/cult/friendly_erase_rune/cast(var/list/targets, var/mob/living/carbon/user)
	..()
	var/removed_word = friendly_erase_rune_word(get_turf(user))
	if (removed_word)
		to_chat(user, "<span class='notice'>You hastily scrub away the [removed_word] rune.</span>")
	else
		to_chat(user, "<span class='warning'>There aren't any rune words left to erase.</span>")


		
/proc/iscultistsilicon(var/user)
	if(istype(user, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/target = user
		if(target.module && /obj/item/borg/upgrade/cult in target.module.upgrades)
			return 1
	return 0