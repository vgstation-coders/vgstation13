
/*
	Wrapper for /datum/sound for use in sound_emitters.
	Facilitates temporarily overriding sound datum vars without messing up the master copy.

	Support for tracking of how much a sound has played-back and set `offset` accordingly
	  for pausing/resuming sounds best done here
*/

/datum/managed_sound
	// Avoid modifying base_sound directly, prefer making a new managed_sound
	var/sound/base_sound = null
	var/volume_override = null // mutators apply separately to this - think of this as the source volume itself changing temporarily
	var/frequency_override = null
	var/volume_mutator = 1 // 1 means no change (multiply volume by 1)

/datum/managed_sound/New(sound/S)
	base_sound = S

/datum/managed_sound/proc/copy()
	var/datum/managed_sound/M = new /datum/managed_sound(copy_sound(base_sound))
	M.volume_override = volume_override
	return M

/datum/managed_sound/proc/reset()
	volume_override = null
	frequency_override = null
	volume_mutator = 1

/datum/managed_sound/proc/update_atom(atom/new_atom)
	if (!istype(new_atom))
		return
	base_sound.atom = new_atom

/datum/managed_sound/proc/mutate_volume(var/factor)
	if (!volume_override)
		volume_override = base_sound.volume
	volume_override *= factor

// get copy of base_sound with override+mutators applied
/datum/managed_sound/proc/get()
	var/sound/S = copy_sound(base_sound)
	if (volume_override)
		S.volume = volume_override
	if (frequency_override)
		S.frequency = frequency_override

	S.volume *= volume_mutator

	return S

/datum/managed_sound/proc/operator""()
	return "managed_sound: base_sound file: [base_sound?.file], base_sound atom: [base_sound?.atom], volume_override: [volume_override], volume_mutator: [volume_mutator]"

/proc/copy_sound(sound/copy_from)
	if (!copy_from)
		return
	var/sound/new_sound = sound(copy_from.file)
	new_sound.atom = copy_from.atom
	new_sound.channel = copy_from.channel
	new_sound.frequency = copy_from.frequency
	new_sound.repeat = copy_from.repeat
	new_sound.status = copy_from.status
	new_sound.transform = copy_from.transform
	new_sound.volume = copy_from.volume
	return new_sound
