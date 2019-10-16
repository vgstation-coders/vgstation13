var/list/uristrune_cache = list() 

/spell/cult
	panel = "Cult"
	override_base = "cult"
	user_type = USER_TYPE_CULT

/spell/cult/trace_rune //Abstract, base for all blood-based rune systems
	name = "Trace Rune"
	desc = "(1 BLOOD) Use available blood to write down words. Three words form a rune."
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
	var/runeset_identifier = null
	var/datum/runeword/word = null
	var/obj/effect/rune/rune = null
	var/datum/rune_spell/spell = null
	var/continue_drawing = 0
	var/blood_cost = 1	

/spell/cult/trace_rune/choose_targets(var/mob/user = usr)
	return list(user)
	
/spell/cult/trace_rune/before_channel(mob/user)
	if(continue_drawing) //Resets the current spell (tome selection) if continue_drawing is not 1.
		continue_drawing = 0
	else
		spell = null
	return 0
	
/spell/cult/trace_rune/spell_do_after(var/mob/user, var/delay, var/numticks = 3)
	return ..()
	//Each variant of rune is handled in their respective class.
	
/spell/cult/trace_rune/cast(var/list/targets, var/mob/living/carbon/user)
	if(rune)
		if(rune.word1 && rune.word2 && rune.word3)
			to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
			return
		else if(rune.runeset_identifier != runeset_identifier)
			to_chat(user, "<span class='warning'>This type of rune is incompatible with the one on the ground.</span>")
			return
	if(write_rune_word(get_turf(user), data["blood"], word = global_runesets[runeset_identifier].words[word]) > 1)
		continue_drawing = 1
		perform(user) //Recursion for drawing runes in a row with tome. 
			
////////////////////BLOOD CULT DRAW RUNE////////////////////////

/spell/cult/trace_rune/blood_cult
	name = "Trace Rune"
	desc = "(1 BLOOD) Use available blood to write down words. Three words form a rune."

	cast_delay = 15

	runeset_identifier = "blood_cult"
	
/spell/cult/trace_rune/blood_cult/before_channel(mob/user)
	if(continue_drawing) //Resets the current spell (tome selection) if continue_drawing is not 1.
		continue_drawing = 0
	else
		spell = null

	if (user.checkTattoo(TATTOO_FAST))
		cast_delay = 5

	var/mob/living/carbon/C = user
	var/muted = C.muted()
	if (muted)
		to_chat(user,"<span class='danger'>You find yourself unable to focus your mind on the words of Nar-Sie.</span>")
	return muted

/spell/cult/trace_rune/blood_cult/spell_do_after(var/mob/user, var/delay, var/numticks = 3)

	if(block)     //Part of class spell, gets reset back to 0 after done casting. Prevents spamming.
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
			
	var/obj/item/weapon/tome/tome = locate() in user.held_items

	if(spell) //If player already begun drawing a rune with help of a tome
		if(!tome)
			to_chat(user, "<span class='warning'>Without reading the tome, you have trouble continuing to draw the arcane words.</span>")
			return 0		
		else
			var/datum/runeword/blood_cult/instance
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
	else if(tome) //Else if they want to begin starting to draw with the help of a tome, grab all the available runes they can draw
		var/list/available_runes = list()
		var/i = 1
		for(var/blood_spell in subtypesof(/datum/rune_spell/blood_cult))
			var/datum/rune_spell/blood_cult/instance = blood_spell
			if(initial(instance.Act_restriction) <= veil_thickness)
				available_runes.Add("\Roman[i]-[initial(instance.name)]")
				available_runes["\Roman[i]-[initial(instance.name)]"] = instance
			i++
		if(tome.state == TOME_CLOSED)
			tome.icon_state = "tome-open"
			tome.item_state = "tome-open"
			flick("tome-flickopen",tome)
			playsound(user, "pageturn", 50, 1, -5)
			tome.state = TOME_OPEN
		var/spell_name = input(user,"Draw a rune with the help of the Arcane Tome.", "Trace Complete Rune", null) as null|anything in available_runes
		spell = available_runes[spell_name]	
		var/datum/runeword/blood_cult/instance
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

		
	else //Otherwise they want to begin drawing each word manually
		word = input(user,"Choose a word to add to the rune.", "Trace Rune Word", null) as null|anything in global_runesets[runeset_identifier].words
	if (!word)
		return 0

	data = use_available_blood(user, blood_cost) 
	if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
		return 0

	if(rune)
		user.visible_message("<span class='warning'>\The [user] chants and paints more symbols on the floor.</span>",\
				"<span class='warning'>You add another word to the rune.</span>",\
				"<span class='warning'>You hear chanting.</span>")
	else
		user.visible_message("<span class='warning'>\The [user] begins to chant and paint symbols on the floor.</span>",\
				"<span class='warning'>You begin drawing a rune on the floor.</span>",\
				"<span class='warning'>You hear some chanting.</span>")

	if(!user.checkTattoo(TATTOO_SILENT))
		user.whisper("...[global_runesets[runeset_identifier].words[word].rune]...")
	return ..()

/spell/cult/trace_rune/blood_cult/cast(var/list/targets, var/mob/living/carbon/user)
	if(rune)
		if(rune.word1 && rune.word2 && rune.word3)
			to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")
			return
		else if(rune.runeset_identifier != runeset_identifier)
			to_chat(user, "<span class='warning'>This type of rune is incompatible with the one on the ground.</span>")
			return
	if(write_rune_word(get_turf(user), data["blood"], word = global_runesets[runeset_identifier].words[word]) > 1)
		continue_drawing = 1
		perform(user) //Recursion for drawing runes in a row with tome. 
	else
		var/obj/item/weapon/tome/tome = locate() in user.held_items
		if(tome && tome.state == TOME_OPEN)
			tome.icon_state = "tome"
			tome.item_state = "tome"
			flick("tome-stun",tome)
			tome.state = TOME_CLOSED

//SPELL II
/spell/cult/erase_rune //Works on all types of runes unless specified otherwise.
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


//SPELL III
/spell/cult/blood_dagger
	name = "Blood Dagger"
	desc = "(5 BLOOD) Solidify some blood into a sharp weapon. Slash at your enemies to steal their blood. Use the dagger to re-absorb the stolen blood."
	hud_state = "cult_blooddagger"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 10//don't want people going full dio over knocked down bleeding players, stealing and absorbing their blood.
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

/spell/cult/blood_dagger/choose_targets(var/mob/user = usr)
	return list(user)

/spell/cult/blood_dagger/cast(var/list/targets, var/mob/living/carbon/user)
	..()
	var/mob/living/carbon/human/H = user
	var/list/data = use_available_blood(user, 5)
	if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
		return 0
	var/dagger_color = DEFAULT_BLOOD
	var/datum/reagent/blood/source = data["blood"]
	if (source.data["blood_colour"])
		dagger_color = source.data["blood_colour"]
	var/good_hand
	if(H.can_use_hand(H.active_hand))
		good_hand = H.active_hand
	else
		for(var/i = 1 to H.held_items.len)
			if(H.can_use_hand(i))
				good_hand = i
				break
	if(good_hand)
		H.drop_item(H.held_items[good_hand], force_drop = 1)
		var/obj/item/weapon/melee/blood_dagger/BD = new (H)
		BD.originator = user
		if (dagger_color != DEFAULT_BLOOD)
			BD.icon_state += "-color"
			BD.item_state += "-color"
			BD.color = dagger_color
		H.put_in_hand(good_hand, BD)
		H.visible_message("<span class='warning'>\The [user] squeezes the blood in their hand, and it takes the shape of a dagger!</span>",
			"<span class='warning'>You squeeze the blood in your hand, and it takes the shape of a dagger.</span>")
		playsound(H, 'sound/weapons/bloodyslice.ogg', 30, 0,-2)

var/list/arcane_pockets = list()
//SPELL IV
/spell/cult/arcane_dimension
	name = "Arcane Dimension (empty)"
	desc = "Cast while holding an Arcane Tome to discretly store it through the veil."
	hud_state = "cult_pocket_empty"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 0
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

	var/obj/item/weapon/tome/stored_tome = null

/spell/cult/arcane_dimension/New()
	..()
	arcane_pockets.Add(src)

/spell/cult/arcane_dimension/Destroy()
	arcane_pockets.Remove(src)
	..()

/spell/cult/arcane_dimension/choose_targets(var/mob/user = usr)
	return list(user)

/spell/cult/arcane_dimension/cast(var/list/targets, var/mob/living/carbon/user)
	..()
	if (stored_tome)
		stored_tome.forceMove(get_turf(user))
		if (user.get_inactive_hand() && user.get_active_hand())//full hands
			to_chat(user,"<span class='warning'>Your hands being full, your [stored_tome] had nowhere to fall but on the ground.</span>")
		else
			to_chat(user,"<span class='notice'>You hold your hand palm up, and your [stored_tome] drops in it from thin air.</span>")
			user.put_in_hands(stored_tome)
		stored_tome = null
		name = "Arcane Dimension (empty)"
		connected_button.name = name
		desc = "Cast while holding an Arcane Tome to discretly store it through the veil."
		hud_state = "cult_pocket_empty"
		connected_button.overlays.len = 0
		connected_button.MouseExited()
		return

	var/obj/item/weapon/tome/held_tome = locate() in user.held_items
	if (held_tome)
		if (held_tome.state == TOME_OPEN)
			held_tome.icon_state = "tome"
			held_tome.item_state = "tome"
			held_tome.state = TOME_CLOSED
		stored_tome = held_tome
		user.u_equip(held_tome)
		held_tome.loc = null
		to_chat(user,"<span class='notice'>With a swift movement of your arm, you drop \the [held_tome] that disappears into thin air before touching the ground.</span>")
		name = "Arcane Dimension (full)"
		connected_button.name = name
		desc = "Cast to pick up your Arcane Tome back from the veil. You should preferably have a free hand."
		hud_state = "cult_pocket_full"
		connected_button.overlays.len = 0
		connected_button.MouseExited()
