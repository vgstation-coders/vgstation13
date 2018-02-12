
//SPELL I
/spell/trace_rune
	name = "Trace Rune"
	desc = "Use available blood to write down words. Three words form a rune."
	panel = "Cult"
	hud_state = "cult_word"
	override_base = "cult"

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

/spell/trace_rune/choose_targets(var/mob/user = usr)
	return list(user)


/spell/trace_rune/before_channel(mob/user)
	var/mob/living/carbon/C = user
	var/muted = C.muted()
	if (muted)
		to_chat(user,"<span class='danger'>You find yourself unable to focus your mind on the words of Nar-Sie.</span>")
	return muted


/spell/trace_rune/spell_do_after(var/mob/user, var/delay, var/numticks = 3)

	if(block)
		return 0

	block = 1

	if(!istype(user.loc, /turf))
		to_chat(user, "<span class='warning'>You do not have enough space to write a proper rune.</span>")
		return 0

	var/turf/T = user.loc

	rune = locate() in T
	if (rune && rune.word1 && rune.word2 && rune.word3)
		to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
		return 0

	word = input(user,"Choose a word to add to the rune.", "Trace Rune", null) as null|anything in cultwords

	if (!word)
		return 0

	data = use_available_blood(user, CULT_COST_RUNE)
	if (data["result"] == "failure")
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

/spell/trace_rune/cast(var/list/targets, var/mob/living/carbon/user)
	..()
	if (rune && rune.word1 && rune.word2 && rune.word3)
		to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
		return
	if (write_rune_word(get_turf(user) ,data["blood"] ,word = cultwords[word]) > 1)
		perform(user)//imediately try writing another word

//SPELL II
/spell/erase_rune
	name = "Erase Rune"
	desc = "Remove the last word written of the rune you're standing above."
	panel = "Cult"
	hud_state = "cult_erase"
	override_base = "cult"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 0
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

/spell/erase_rune/choose_targets(var/mob/user = usr)
	return list(user)

/spell/erase_rune/cast(var/list/targets, var/mob/living/carbon/user)
	..()
	var/removed_word = erase_rune_word(get_turf(user))
	if (removed_word)
		to_chat(user, "<span class='notice'>You retrace your steps, carefully undoing the lines of the [removed_word] rune.</span>")
	else
		to_chat(user, "<span class='warning'>There aren't any rune words left to erase.</span>")
