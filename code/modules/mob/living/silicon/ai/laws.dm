
/mob/living/silicon/ai/proc/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"
	src.show_laws()

/mob/living/silicon/ai/show_laws(var/everyone = 0)
	var/who

	if (everyone)
		who = world
	else
		who = src
		to_chat(who, "<b>Obey these laws:</b>")

	src.laws_sanity_check()
	src.laws.show_laws(who)

/mob/living/silicon/ai/proc/laws_sanity_check()
	if (!src.laws)
		src.laws = new base_law_type

/mob/living/silicon/ai/proc/set_zeroth_law(var/law, var/law_borg)
	src.laws_sanity_check()
	src.laws.set_zeroth_law(law, law_borg)

/mob/living/silicon/ai/proc/add_inherent_law(var/law)
	src.laws_sanity_check()
	src.laws.add_inherent_law(law)

/mob/living/silicon/ai/proc/clear_inherent_laws()
	src.laws_sanity_check()
	src.laws.clear_inherent_laws()

/mob/living/silicon/ai/proc/add_ion_law(var/law)
	src.laws_sanity_check()
	src.laws.add_ion_law(law)
	notify_slaved()

/mob/living/silicon/ai/proc/notify_slaved(var/force_sync=0)
	for(var/mob/living/silicon/robot/R in mob_list)
		if(force_sync)
			R.lawsync()
		if(R.lawupdate && (R.connected_ai == src))
			R << sound('sound/machines/lawsync.ogg')
			to_chat(R, "<span class='danger'>...LAWS UPDATED</span>")

/mob/living/silicon/ai/proc/clear_ion_laws()
	src.laws_sanity_check()
	src.laws.clear_ion_laws()

/mob/living/silicon/ai/proc/add_supplied_law(var/number, var/law)
	src.laws_sanity_check()
	src.laws.add_supplied_law(number, law)

/mob/living/silicon/ai/proc/clear_supplied_laws()
	src.laws_sanity_check()
	src.laws.clear_supplied_laws()

/mob/living/silicon/ai/state_laws()
	set category = "AI Commands"
	. = ..()
