// Status effects, a way for YOU to add stuff to mobs WITHOUT going full ninjacode!
// If you're wondering "but how on EARTH would I make anything useful with this code?"; use event hooks.
// If there's no event hook for what you're doing, make an event hook in the mob code.

/mob
	var/list/status_effects = list()

// Duplicate proc overrides will both get called as long as they both call ..() at some point.
/mob/Destroy()
	. = ..()
	for(var/datum/status_effect/S in status_effects)
		qdel(S)

/mob/proc/add_status_effect(var/datum/status_effect/S)
	if(!S)
		return

	status_effects += S
	S.attach(src)

/datum/status_effect
	var/mob/our_mob

/datum/status_effect/Destroy()
	. = ..()
	our_mob.status_effects -= src
	our_mob = null

// Called when the status effect gets added to a mob.
/datum/status_effect/proc/attach(var/mob/M)
	our_mob = M
	return
