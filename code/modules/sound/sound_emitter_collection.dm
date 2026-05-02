/*
		Experimental datum to more easily facilitate playing a sound globally across all emitters on a common atom type
*/

var/global/datum/sound_emitter_collection/sound_emitter_collection = new

/datum/sound_emitter_collection
	var/list/emitters_by_type = list()

/datum/sound_emitter_collection/New()
	emitters_by_type = list()

/datum/sound_emitter_collection/proc/add(datum/sound_emitter/E)
	if (!E.source)
		CRASH("Attempted to add a sound_emitter ([E]) with no source")
	var/L = emitters_by_type[E.source.type]
	if (!L)
		L = emitters_by_type[E.source.type] = list()
	L |= E

/datum/sound_emitter_collection/proc/remove(datum/sound_emitter/E)
	if (!E.source)
		CRASH("Attempted to add a sound_emitter ([E]) with no source")
	var/L = emitters_by_type[E.source.type]
	if (!L)
		return
	L -= E

// While sound_emitter is an atom var, this will only work on atoms that have initialised that var
/datum/sound_emitter_collection/proc/play_global_sound_on_type(atom/target_type, sound/S)
	if (!target_type)
		return
	var/L = emitters_by_type[target_type]
	if (!L)
		return
	for (var/datum/sound_emitter/E in L)
		var/s = copy_sound(S)
		spawn()
			E.play_once(s)
