// WARNING
// Event handlers (i.e.: procs that are registered with `proc/register_event` MUST NOT sleep()).

// Declare children of this type path to use as identifiers for the events.
/event

// Called by human/proc/apply_radiation()
// Arguments:
// mob/carbon/living/human/user: The human.
// rads: The amount of radiation.
/event/irradiate

// Called whenever an atom's z-level changes.
// Seems to be invoked all over the place, actually. Someone should sort this out.
// Arguments:
// atom/movable/user: The atom that moved.
// to_z: The new z.
// from_z: The old z.
/event/z_transition

// TODO: docs
/event/post_z_transition

// Called whenever an /atom/movable moves.
// Arguments:
// atom/movable/mover: the movable itself.
/event/moved

// Called whenever an /atom/movable relay-moves.
// Arguments:
// atom/movable/mover: the movable itself.
/event/relaymoved

// Called right before an /atom/movable attempts to move or change dir.
/event/before_move

// Called right after an /atom/movable attempts to move or change dir..
/event/after_move

// Called when an /atom/movable attempts to change dir.
/event/face

// Called whenever a datum is destroyed.
// Currently, as an optimization, only /atom/movable invokes this but
// it can be changed to /datum if the need arises.
/event/destroyed
// Arguments:
// datum/thing: the datum being destroyed.

// Called whenever an atom's density changes.
// Arguments:
// atom/atom: the atom whose density changed.
/event/density_change

// Called whenever a mob uses the "resist" verb.
// Arguments:
// mob/user: the mob that's resisting
/event/resist

// Called whenever a mob casts a spell.
// Arguments:
// spell/spell: the spell that's being cast.
// mob/user: the mob that's casting the spell.
// list/targets: the list of targets the spell is being cast against. May not always be a list.
/event/spellcast

// Called whenever a mob attacks something with an empty hand.
// Arguments:
// atom/atom: The atom that's being attacked.
/event/uattack

// Called whenever a mob attacks something while restrained.
// Arguments:
// atom/atom: The atom that's being attacked.
/event/ruattack

// Called by mob/Logout().
// Arguments:
// mob/user: The mob that's logging out.
/event/logout

// Called by mob/living/Login().
// Arguments:
// mob/user: The living mob that's logging in.
/event/living_login

// Called by new_player.dm when a character latejoins
// Arguments:
// mob/living/carbon/human/character: The character that has arrived on the station.
// rank: The character's job. Should be something like "Chemist", NOT the job datum.
/event/late_arrival

// Called whenever a mob takes damage.
// Truthy return values will prevent the damage.
// Arguments:
// kind: the kind of damage the mob is being dealt.
// amount: the amount of damage the mob is being dealt.
/event/damaged

// Called whenever a mob dies.
// Arguments:
// mob/user: The mob that's dying.
// body_destroyed: Whether the mob is about to be gibbed.
/event/death

// Called by /mob/proc/ClickOn.
// The list of modifiers can be changed by the event listeners.
// Arguments:
// mob/user: the user that's doing the clicking.
// list/modifiers: list of key modifiers (shift, alt, etcetera).
// atom/target: the atom that's being clicked on.
/event/clickon

// Called when an atom is attacked with an empty hand.
// Arguments:
// mob/user: the guy who is attacking.
// atom/target: the atom that's being attacked.
/event/attackhand

// Called whenever an atom bumps into another.
// Currently only used by xenoarch artifacts and humans, should probably be moved to the base proc.
// Arguments:
// atom/movable/bumper: the atom that is bumping.
// atom/target: the atom that's being bumped into.
/event/bumped

// Called when mind/transfer_to() finishes.
// Arguments:
// datum/mind/mind: the mind that just got transferred.
/event/after_mind_transfer

// Called when mob equips an item
// Arguments:
// atom/item: the item
// slot: the slot
/event/equipped

// Called when mob unequippes an item
// Arguments:
// atom/item: the item
/event/unequipped

// Called when movable moves into a new turf
// Arguments:
// atom/movable/mover: thing that moved
// location: turf it entered
// oldloc: atom it exited
/event/entered

// Called when movable moves from a turf
// Arguments:
// atom/movable/mover: thing that moved
// location: turf it exited
// newloc: atom it is entering
/event/exited

// Called by attack_hand
// Arguments:
// mob/toucher: the mob doing the touching
// atom/touched: the thing being touched
/event/touched

// Called by to_bump
// Currently only implemented for humans.
// Arguments:
// atom/movable/bumper: the atom that is bumping.
// atom/bumped: the atom that's being bumped into.
/event/to_bump

// Called by hitby
// Currently only implemented for humans.
// Arguments:
// mob/victim: the mob being hit
// obj/item/item: the item that's hitting the victim
/event/hitby

// Called by attacked_by
// Arguments:
// mob/attacker: the mob doing the attack
// mob/attacked: the victim of the attack
// obj/item/item: the item being used to attack with
/event/attacked_by

// Called by unarmed_attack_mob
// Probably should be merged with /event/uattack.
// Arguments:
// mob/attacker: the mob doing the attack
// mob/attacked: the victim of the attack
/event/unarmed_attack

// Called by beam_connect
// Arguments:
// obj/effect/beam/beam: the beam connecting with the atom
/event/beam_connect

// Called by bullet_act
// Arguments:
// obj/item/projectile/projectile: the projectile hitting the atom
/event/projectile

// Called by ex_act
// Arguments:
// severity: the severity of the explosion
/event/explosion

// Called by /obj/effect/beam/emitter/proc/set_power
// Arguments:
// obj/effect/beam/beam: the beam
/event/beam_power_change

// Called by attackby
// Used by artifacts and cooktops.
// Arguments:
// mob/living/attacker: the mob attacking the atom
// obj/item/item: the item being used for the attack
/event/attackby

// Called by throw_impact
// Arguments:
// atom/hit_atom: the atom hit by the throw impact
// speed: the speed at which the thrown atom was thrown
// mob/living/user: the mob who threw the atom, if any
// thrown_atom: the atom that was thrown
/event/throw_impact

//Called by examine
//Arguments:
//mob/user: the mob doing the examining
/event/examined

/event/ui_act

// Called by attack_self
// Arguments:
// mob/living/user
/event/item_attack_self

// Called when a PDA's ringtone is about to be changed.
// Arguments:
// mob/user: who's changing the ringtone
// new_ringtone: the new ringtone, string
/event/pda_change_ringtone

// Called when a radio's frequency is about to be changed
// Arguments:
// mob/user: who's changing the frequency
// new_frequency: the new frequency, number
/event/radio_new_frequency

// Called when a mob performs an emote
// Arguments:
// emote: the name of the emote being performed
// mob/source: the mob performing the emote
/event/emote

// Called by mob/living/Hear
// Arguments:
// datum/speech/speech: the speech datum being heard
/event/hear

// Called by area/Entered
// Arguments:
// atom/movable/enterer: the movable entering the area
/event/area_entered

// Called by area/Exited
// Arguments:
// atom/movable/exiter: the movable exiting the area
/event/area_exited

// Arguments:
// mob/killer: the person who killed
// mob/victim: the person who got killed
/event/kill

// Arguments:
// time: shuttle timer
// direction: shuttle direction
/event/shuttletimer

// Called by miscellaneous functions not covered by entered, equipped and unequipped events for cameranet updates
// Arguments:
// atom/movable/mover: the atom changing status on the cameranet
/event/camera_sight_changed

// Called by both area/Entered and area/Exited if the atom changing areas is a mob
// Arguments:
// mob: the mob changing areas
// newarea: the new area being entered
// oldarea: the old area being left
/event/mob_area_changed

// Note: the following are used by datum/component/ai subtypes to give instructions to each other.
// AI components are expected to INVOKE_EVENT these to send commands to other components
// on the same datum without having to hold references to them.
// They may need to be reworked, and they are currently undocumented.
/event/comp_ai_friend_attacked

/event/comp_ai_cmd_get_best_target
/event/comp_ai_cmd_add_target
/event/comp_ai_cmd_remove_target
/event/comp_ai_cmd_find_targets

/event/comp_ai_cmd_can_attack
/event/comp_ai_cmd_move
/event/comp_ai_cmd_attack
/event/comp_ai_cmd_evaluate_target
/event/comp_ai_cmd_get_damage_type

/event/comp_ai_cmd_set_busy
/event/comp_ai_cmd_get_busy

/event/comp_ai_cmd_set_target
/event/comp_ai_cmd_get_target

/event/comp_ai_cmd_set_state
/event/comp_ai_cmd_get_state

/event/comp_ai_cmd_say
/event/comp_ai_cmd_specific_say

/event/comp_ai_cmd_order

/event/comp_ai_cmd_retaliate

/datum
	/// Associative list of type path -> list(),
	/// where the type path is a descendant of /event_type.
	/// The inner list is itself an associative list of string -> list(),
	/// where string is the \ref of an object + the proc to be called.
	/// The list associated with the string above contains the hard-ref
	/// to an object and the proc to be called.
	var/list/list/registered_events

/**
  * Calls all registered event handlers with the specified parameters, if any.
  * Arguments:
  * * event/event_type Required. The typepath of the event to invoke.
  * * list/arguments Optional. List of parameters to be passed to the event handlers.
  */
#define INVOKE_EVENT(target, event_type, arguments...) (target.registered_events?[event_type] && target.invoke_event(event_type, list(##arguments)))

#define EVENT_HANDLER_OBJREF_INDEX 1
#define EVENT_HANDLER_PROCNAME_INDEX 2

/datum/proc/invoke_event(event/event_type, list/arguments)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/list/event_handlers = registered_events[event_type]
	for(var/key in event_handlers)
		var/list/handler = event_handlers[key]
		var/objRef = handler[EVENT_HANDLER_OBJREF_INDEX]
		var/procName = handler[EVENT_HANDLER_PROCNAME_INDEX]
		// not |= because `null |= list()` is a runtime error
		// but `null = null | list()` is not.
		. = . | call(objRef, procName)(arglist(arguments))

/**
  * Registers a proc to be called on an object whenever the specified event_type
  * is invoked on this datum.
  * Arguments:
  * * event/event_type Required. The typepath of the event to register.
  * * datum/target Required. The object that the proc will be called on.
  * * procname Required. The proc to be called.
  */
/datum/proc/register_event(event/event_type, datum/target, procname)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!registered_events)
		registered_events = list()
	if(!registered_events[event_type])
		registered_events[event_type] = list()
	var/key = "[ref(target)]:[procname]"
	registered_events[event_type][key] = list(
		EVENT_HANDLER_OBJREF_INDEX = target,
		EVENT_HANDLER_PROCNAME_INDEX = procname
	)

/**
  * Unregisters a proc so that it is no longer called when the specified
  * event is invoked.
  * Arguments:
  * * event/event_type Required. The typepath of the event to unregister.
  * * datum/target Required. The object that's been previously registered.
  * * procname Required. The proc of the object.
  */
/datum/proc/unregister_event(event/event_type, datum/target, procname)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!registered_events)
		return
	if(!registered_events[event_type])
		return
	var/key = "[ref(target)]:[procname]"
	registered_events[event_type] -= key
	if(!registered_events[event_type].len)
		registered_events -= event_type
	if(!registered_events.len)
		registered_events = null

/**
  * Checks if a datum has a registered event.
  * Arguments:
  * * event/event_type Required. The typepath of the event to unregister.
  * * datum/target Required. The object that's been previously registered.
  * * procname Required. The proc of the object.
  */
/datum/proc/has_event(event/event_type, datum/target, procname)
	if(!target || !procname)
		return registered_events && registered_events[event_type]
	return registered_events && registered_events[event_type] && registered_events[event_type]["[ref(target)]:[procname]"]

#undef EVENT_HANDLER_OBJREF_INDEX
#undef EVENT_HANDLER_PROCNAME_INDEX
