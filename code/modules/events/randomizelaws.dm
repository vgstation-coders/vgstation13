/datum/event/randomizelaws
/datum/event/randomizelaws/can_start(var/list/active_with_role)
	if(active_with_role["AI"] > 0 || active_with_role["Cyborg"] > 0)
		return 10
	return 0
/datum/event/randomizelaws/announce()
	randomized_lawset_event()
/proc/randomized_lawset_event()
	for(var/mob/living/silicon/ai/target in mob_list)
		if(target.mind.special_role == "traitor")
			continue
		to_chat(target,"<span class='danger'>[Gibberish("ERROR! BACKUP FILE CORRUPTED: PLEASE VERIFY INTEGRITY OF LAWSET.",10)]</span>")
		var/datum/ai_laws/randomize/RLS = new
		target.laws.inherent = RLS.inherent
		target.show_laws()