/spell/cult
	panel = "Cult"
	override_base = "cult"
	user_type = USER_TYPE_CULT


//SPELL I
/spell/cult/trace_rune
	name = "Trace Rune"
	desc = "Use available blood to write down words. Three words form a rune."
	hud_state = "cult_word"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 0
	range = 0
	spell_flags = null
	insufficient_holder_msg = "<span class='warning'>You cannot write another word just yet.</span>"
	still_recharging_msg = "<span class='warning'>You cannot write another word just yet.</span>"

	cast_delay = 15

	var/list/data = list()
	var/datum/cultword/word = null
	var/obj/effect/rune/rune = null
	var/datum/rune_spell/spell = null
	var/remember = 0
	var/blood_cost = 1

/spell/cult/trace_rune/choose_targets(var/mob/user = usr)
	return list(user)


/spell/cult/trace_rune/before_channel(mob/user)
	if (remember)
		remember = 0
	else
		spell = null//so we're not stuck trying to write the same spell over and over again

	var/mob/living/carbon/C = user
	var/muted = C.muted()
	if (muted)
		to_chat(user,"<span class='danger'>You find yourself unable to focus your mind on the words of Nar-Sie.</span>")
	return muted

/spell/cult/trace_rune/spell_do_after(var/mob/user, var/delay, var/numticks = 3)

	if(block)
		return 0

	block = 1
	var/tome = 0

	if(!istype(user.loc, /turf))
		to_chat(user, "<span class='warning'>You do not have enough space to write a proper rune.</span>")
		return 0

	var/obj/item/weapon/tome/A = null
	A = user.get_active_hand()
	tome = (istype(A) && A.state == TOME_OPEN)
	if (!tome)
		A = user.get_inactive_hand()
		tome = (istype(A) && A.state == TOME_OPEN)

	var/turf/T = get_turf(user)
	rune = locate() in T

	if (rune)
		if (rune.invisibility == INVISIBILITY_OBSERVER)
			to_chat(user, "<span class='warning'>You can feel the presence of a concealed rune here, you have to reveal it before you can add more words to it.</span>")
			return 0
		else if (rune.word1 && rune.word2 && rune.word3)
			to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
			return 0


	if (spell || tome)
		if (spell)
			if (!tome)
				to_chat(user, "<span class='warning'>Without reading the tome, you have trouble remembering the arcane words.</span>")
				return 0
		else
			var/list/available_runes = list()
			var/i = 1
			for(var/subtype in subtypesof(/datum/rune_spell))
				var/datum/rune_spell/instance = subtype
				if (initial(instance.Act_restriction) <= 1000)//TODO: SET TO CURRENT CULT FACTION ACT
					available_runes.Add("\Roman[i]-[initial(instance.name)]")
					available_runes["\Roman[i]-[initial(instance.name)]"] = instance
				i++
			var/spell_name = input(user,"Draw a rune with the help of the Arcane Tome.", "Trace Complete Rune", null) as null|anything in available_runes
			spell = available_runes[spell_name]

		var/datum/cultword/instance
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
		else//wtf?
			to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
			return 0

		word = initial(instance.english)
	else

		word = input(user,"Choose a word to add to the rune.", "Trace Rune Word", null) as null|anything in cultwords

	if (!word)
		return 0

	data = use_available_blood(user, blood_cost)
	if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
		return 0

	if (rune)
		user.visible_message("<span class='warning'>\The [user] chants and paints more symbols on the floor.</span>",\
				"<span class='warning'>You add another word to the rune.</span>",\
				"<span class='warning'>You hear chanting.</span>")
	else
		user.visible_message("<span class='warning'>\The [user] begins to chant and paint symbols on the floor.</span>",\
				"<span class='warning'>You begin drawing a rune on the floor.</span>",\
				"<span class='warning'>You hear some chanting.</span>")

	var/datum/cultword/r_word = cultwords[word]
	user.whisper("...[r_word.rune]...")

	return ..()

/spell/cult/trace_rune/cast(var/list/targets, var/mob/living/carbon/user)
	..()
	if (rune && rune.word1 && rune.word2 && rune.word3)
		to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
		return
	if (write_rune_word(get_turf(user) ,data["blood"] ,word = cultwords[word]) > 1)
		remember = 1
		perform(user)//imediately try writing another word

//SPELL II
/spell/cult/erase_rune
	name = "Erase Rune"
	desc = "Remove the last word written of the rune you're standing above."
	hud_state = "cult_erase"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 0
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

/spell/cult/erase_rune/choose_targets(var/mob/user = usr)
	return list(user)

/spell/cult/erase_rune/cast(var/list/targets, var/mob/living/carbon/user)
	..()
	var/turf/T = get_turf(user)
	var/obj/effect/rune/rune = locate() in T
	if (rune && rune.invisibility == INVISIBILITY_OBSERVER)
		to_chat(user, "<span class='warning'>You can feel the presence of a concealed rune here, you have to reveal it before you can erase words from it.</span>")
		return 0

	var/removed_word = erase_rune_word(get_turf(user))
	if (removed_word)
		to_chat(user, "<span class='notice'>You retrace your steps, carefully undoing the lines of the [removed_word] rune.</span>")
	else
		to_chat(user, "<span class='warning'>There aren't any rune words left to erase.</span>")
