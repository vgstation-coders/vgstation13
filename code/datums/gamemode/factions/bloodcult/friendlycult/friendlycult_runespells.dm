#define RUNE_STAND	1

/datum/friendly_rune_spell
	var/name = "default name"
	var/desc = "default description"
	var/obj/spell_holder = null				
	var/mob/activator = null				
	var/datum/friendly_cultword/word1 = null			
	var/datum/friendly_cultword/word2 = null
	var/datum/friendly_cultword/word3 = null
	var/invocation = "Lo'Rem Ip'Sum~"
	var/rune_flags = null //if set to RUNE_STAND (or 1), the user will need to stand right above the rune to use cast the spell
	var/destroying_self = 0  //some sanity var to prevent abort loops, ignore

	//optional 
	var/cost_invoke = 0//blood cost upon cast
	var/cost_upkeep = 0//blood cost upon upkeep proc
	var/list/contributors = list()//list of cultists currently participating in the ritual
	var/image/progbar = null//progress bar
	var/remaining_cost = 0//how much blood to gather for the ritual to succeed
	var/accumulated_blood = 0//how much blood has been gathered so far
	var/cancelling = 3//check to abort the ritual due to blood flow being interrupted
	var/list/ingredients = list()//items that should be on the rune for it to work
	var/list/ingredients_found = list()//items that should be on the rune for it to work
	var/constructs_can_use = 1

	var/walk_effect = 0 //if set to 1, procs Added() when step over

/datum/friendly_rune_spell/New(var/mob/user, var/obj/holder, var/use = "ritual", var/mob/target)
	spell_holder = holder
	activator = user

	switch (use)
		if ("ritual")
			pre_cast()
		if ("touch")
			if (target)
				cast_touch(target)//skipping regular precast

/datum/friendly_rune_spell/Destroy()
	destroying_self = 1
	if (spell_holder)
		if (istype(spell_holder, /obj/effect/friendly_rune))
			var/obj/effect/friendly_rune/rune_holder = spell_holder
			rune_holder.active_spell = null
		spell_holder = null
	word1 = null
	word2 = null
	word3 = null
	activator = null
	..()

/datum/friendly_rune_spell/proc/invoke(var/mob/user, var/text="", var/whisper=0)
	if (user.checkTattoo(TATTOO_SILENT))
		return
	if (!whisper)
		user.say(text,"C")
	else
		user.whisper(text)

/datum/friendly_rune_spell/proc/pre_cast()
	if(istype (spell_holder,/obj/effect/friendly_rune))
		if((rune_flags & RUNE_STAND) && (activator.loc != spell_holder.loc))
			abort(RITUALABORT_STAND)
		else
			invoke(activator,invocation)
			cast()

/datum/friendly_rune_spell/proc/midcast(var/mob/add_cultist)
	return
	
/datum/friendly_rune_spell/proc/blood_pay()
	var/data = use_available_blood(activator, cost_invoke)
	if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
		to_chat(activator, "<span class='warning'>This ritual requires more blood than you can offer.</span>")
		return 0
	else
		return 1

/datum/friendly_rune_spell/proc/Added(var/mob/M)

/datum/friendly_rune_spell/proc/Removed(var/mob/M)

/datum/friendly_rune_spell/proc/cast_touch(var/mob/M)
	return

/datum/friendly_rune_spell/proc/cast()
	spell_holder.visible_message("<span class='warning'>This rune wasn't properly set up, tell a coder.</span>")
	qdel(src)

/datum/friendly_rune_spell/proc/abort(var/cause)
	if (destroying_self)
		return
	destroying_self = 1
	switch (cause)
		if (RITUALABORT_ERASED)
			if (istype (spell_holder,/obj/effect/rune))
				spell_holder.visible_message("<span class='warning'>The rune's destruction ended the ritual.</span>")
		if (RITUALABORT_STAND)
			if (activator)
				to_chat(activator, "<span class='warning'>The [name] ritual requires you to stand on top of the rune.</span>")
		if (RITUALABORT_GONE)
			if (activator)
				to_chat(activator, "<span class='warning'>The ritual ends as you move away from the rune.</span>")
		if (RITUALABORT_BLOCKED)
			if (activator)
				to_chat(activator, "<span class='warning'>There is already building blocking the ritual..</span>")
		if (RITUALABORT_BLOOD)
			spell_holder.visible_message("<span class='warning'>Deprived of blood, the channeling is disrupted.</span>")
		if (RITUALABORT_TOOLS)
			if (activator)
				to_chat(activator, "<span class='warning'>The necessary tools have been misplaced.</span>")
		if (RITUALABORT_TOOLS)
			spell_holder.visible_message("<span class='warning'>The ritual ends as the victim gets pulled away from the rune.</span>")
		if (RITUALABORT_CONVERT)
			if (activator)
				to_chat(activator, "<span class='notice'>The conversion ritual successfully brought a new member to the cult. Inform them of the current situation so they can take action.</span>")
		if (RITUALABORT_SACRIFICE)
			if (activator)
				to_chat(activator, "<span class='warning'>Whether because of their defiance, or Nar-Sie's thirst for their blood, the ritual ends leaving behind nothing but a creepy chest.</span>")
		if (RITUALABORT_CONCEAL)
			if (activator)
				to_chat(activator, "<span class='warning'>The ritual is disrupted by the rune's sudden phasing out.</span>")
		if (RITUALABORT_NEAR)
			if (activator)
				to_chat(activator, "<span class='warning'>You cannot perform this ritual that close from another similar structure.</span>")
		if (RITUALABORT_OUTPOST)
			if (activator)
				to_chat(activator, "<span class='sinister'>The veil here is still too dense to allow raising structures from the realm of Nar-Sie. We must raise our structure in the heart of the station.</span>")


	for(var/mob/living/L in contributors)
		if (L.client)
			L.client.images -= progbar
		contributors.Remove(L)

	if (activator && activator.client)
		activator.client.images -= progbar

	if (progbar)
		progbar.loc = null

	if (spell_holder.icon_state == "temp")
		qdel(spell_holder)
	else
		qdel(src)

/datum/friendly_rune_spell/proc/update_progbar()
	if (!progbar)
		progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = spell_holder, "icon_state" = "prog_bar_0")
		progbar.pixel_z = WORLD_ICON_SIZE
		progbar.plane = HUD_PLANE
		progbar.layer = HUD_ABOVE_ITEM_LAYER
		progbar.appearance_flags = RESET_COLOR
	progbar.icon_state = "prog_bar_[round((min(1, accumulated_blood / remaining_cost) * 100), 10)]"
	return

//Called whenever a rune gets activated or examined
/proc/friendly_get_rune_spell(var/mob/user, var/obj/spell_holder, var/use = "ritual", var/datum/friendly_cultword/word1, var/datum/friendly_cultword/word2, var/datum/friendly_cultword/word3)
	if (!word1 || !word2 || !word3)
		return
	for(var/subtype in subtypesof(/datum/friendly_rune_spell))
		var/datum/friendly_rune_spell/instance = subtype
		if (word1.type == initial(instance.word1) && word2.type == initial(instance.word2) && word3.type == initial(instance.word3))
			switch (use)
				if ("ritual")
					return new subtype(user, spell_holder, use)
				if ("examine")
					return instance
				if ("walk")
					if (initial(instance.walk_effect))
						return new subtype(user, spell_holder, use)
					else
						return null
				if ("imbue")
					return subtype
			return new subtype(user, spell_holder, use)
	return null
	
// FRIENDLY CULTIST RUNES

/datum/friendly_rune_spell/consensual_conversion
	name = "Consensual Conversion"
	desc = "This rune politely asks nearby people to find joy in the teachings of Nar-sie. No magic is done except telepathy."
	invocation = "Muh'weih ploggh at e'ntroth!"
	word1 = /datum/friendly_cultword/friend
	word2 = /datum/friendly_cultword/love
	word3 = /datum/friendly_cultword/hug
	
/datum/friendly_rune_spell/consensual_conversion/pre_cast()
	var/mob/living/user = activator
	if(istype(spell_holder,/obj/effect/friendly_rune))
		invoke(user,invocation)
		cast()
		
/datum/friendly_rune_spell/consensual_conversion/cast()
	var/obj/effect/friendly_rune/R = spell_holder
	R.one_pulse()

	new/obj/effect/cult_ritual/stun(R.loc)

	qdel(R)

#undef RUNE_STAND