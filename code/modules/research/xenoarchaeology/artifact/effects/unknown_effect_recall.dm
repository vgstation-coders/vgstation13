// When activated, creates a list of all objects around it.
// When deactivated, those objects get warped back to their original position from when activated.

/datum/artifact_effect/recall
	effecttype = "recall"
	effect = ARTIFACT_EFFECT_PULSE
	valid_style_types = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_WIZARD, ARTIFACT_STYLE_ANCIENT, ARTIFACT_STYLE_PRECURSOR, ARTIFACT_STYLE_RELIQUARY)
	effect_type = 6

	var/list/current_recorded_items = list()


/datum/artifact_effect/recall/New(atom/location, generate_trigger)
	..()

	// Use different randomization for charge time/difference than base effects.
	// Since charge time is the recall time in our case.
	// Also as much as I think it would be hilarious,
	// it would be super busted to do recall on the WHOLE STATION
	// (200 range is possible with default effect randomization)
	switch(pick(100;1, 33;2))
		if(1)
			//short range, long effect time
			chargelevelmax = rand(25, 40)
			effectrange = rand(1, 2)
		if(2)
			// long range, low-ish effect time
			chargelevelmax = rand(5, 30)
			effectrange = rand(4, 11)


/datum/artifact_effect/recall/DoEffectPulse(atom/holder)
	if (IsContained())
		Blocked()
		return

	for (var/datum/recall_effect_item/item in current_recorded_items)
		var/atom/movable/AM = item.object.get()
		if (!AM || AM.gcDestroyed || !item.source_location)
			// object or source turf was deleted.
			continue

		if (AM.loc == item.source_location)
			// Object didn't move, avoid redundant forceMove() calls and such.
			continue

		if (!prob(100 * CLAMP01(GetAnomalySusceptibility(AM))))
			continue

		// Check if object can be released if it's held.
		if (AM.locked_to)
			if (!AM.locked_to.RecallEffectTryUnlock(AM))
				continue

		else if (AM.loc)
			if (!AM.loc.RecallEffectTryRelease(AM))
				continue

		AM.forceMove(item.source_location)

	current_recorded_items.Cut()
	ForceDeactivate()


/datum/artifact_effect/recall/OnToggleActivate()
	current_recorded_items.Cut()

	chargelevel = 0

	if (!activated)
		// Was de-activated.
		return

	if (IsContained())
		Blocked()
		return

	for (var/atom/movable/AM in range(effectrange, get_turf(holder)))
		if (!AM.RecallCanRegister() || !isturf(AM.loc))
			continue

		var/datum/recall_effect_item/item = new
		item.object = makeweakref(AM)
		item.source_location = AM.loc

		current_recorded_items += item


/datum/recall_effect_item
	var/datum/weakref/object
	var/turf/source_location


// Can this object be CONSIDERED by the recall artifact?
/atom/movable/proc/RecallCanRegister()
	return anchored || locked_to

/obj/mecha/RecallCanRegister()
	// Mechs are considered permanently anchored so...
	return TRUE

/obj/machinery/singularity/RecallCanRegister()
	// What COULD possibly go wrong?
	return TRUE


// Called if a recall artifact wants to recall an atom contained in this atom.
// Return TRUE if the atom was released for the recall effect to take away.
// This is cooperative with the container to avoid breaking shit horribly.
/atom/proc/RecallEffectTryRelease(var/atom/movable/object)
	return FALSE

// The above but for atom locking.
/atom/proc/RecallEffectTryUnlock(var/atom/movable/object)
	return FALSE

// Definitions for some common objects.
/obj/structure/closet/RecallEffectTryRelease(var/atom/movable/object)
	return TRUE

/turf/RecallEffectTryRelease(var/atom/movable/object)
	return TRUE

/obj/item/weapon/storage/RecallEffectTryRelease(atom/movable/object)
	remove_from_storage(object, null)
	return TRUE

/obj/mecha/RecallEffectTryRelease(atom/movable/object)
	if (object == occupant)
		go_out()
		return occupant == null

	return FALSE

/mob/RecallEffectTryRelease(atom/movable/object)
	return u_equip(object)

/obj/machinery/sleeper/RecallEffectTryRelease(atom/movable/object)
	return go_out()

/obj/machinery/bodyscanner/RecallEffectTryRelease(atom/movable/object)
	return go_out()

/obj/structure/disposalholder/RecallEffectTryRelease(atom/movable/object)
	return TRUE

/obj/machinery/disposal/RecallEffectTryRelease(atom/movable/object)
	return TRUE

/obj/structure/transit_tube_pod/RecallEffectTryRelease(atom/movable/object)
	return TRUE

/obj/structure/bed/RecallEffectTryUnlock(var/atom/movable/object)
	unlock_atom(object)
	return TRUE
