/obj/effect/rune/friendly_cult
	desc = "A strange collection of symbols drawn in blood. You recognize it as a friendly cultist rune."
	runeset_identifier = "friendly_cult"
	
/obj/effect/rune/friendly_cult/trigger(var/mob/living/user, var/talisman_trigger=0)
	user.delayNextAttack(5)

	//if(!issiliconcultist(user))
		//to_chat(user, "<span class='danger'>You can't mouth the arcane scratchings without fumbling over them. Maybe you should ask a cyborg for help.</span>")
		//return
	
	if(!word1 || !word2 || !word3 || prob(user.getBrainLoss()))
		return fizzle(user)

	if(active_spell)
		active_spell.midcast(user)
		return

	reveal()

	active_spell = get_rune_spell(user, src, "ritual", word1, word2, word3)

	if(!active_spell)
		return fizzle(user)
	else if(active_spell.destroying_self)
		active_spell = null
		
/obj/effect/rune/friendly_cult/can_read_rune(var/mob/user) //Overload for specific criteria.
	return 1

/obj/effect/rune/friendly_cult/examine(var/mob/user)
	..()
		
	if(can_read_rune(user))
		var/datum/rune_spell/friendly_cult/rune_name = get_rune_spell(null, null, "examine", word1,word2,word3)
		if(rune_name)
			to_chat(user, initial(rune_name.desc))