/datum/component/decal
	dupe_mode = COMPONENT_DUPE_ALLOWED

	var/cleanable
	var/description
	var/mutable_appearance/pic

/datum/component/decal/Initialize(_icon, _icon_state, _dir, _cleanable=CLEAN_GOD, _color, _layer=TURF_LAYER, _description)
	if(!isatom(parent) || !generate_appearance(_icon, _icon_state, _dir, _layer, _color))
		. = COMPONENT_INCOMPATIBLE
		CRASH("A turf decal was applied incorrectly to [parent.type]: icon:[_icon ? _icon : "none"] icon_state:[_icon_state ? _icon_state : "none"]")
	description = _description
	cleanable = _cleanable

	if(_dir) // If no dir is assigned at start then it follows the atom's dir
		RegisterSignal(COMSIG_ATOM_DIR_CHANGE, .proc/rotate_react)
	if(_cleanable)
		RegisterSignal(COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_react)
	if(_description)
		RegisterSignal(COMSIG_PARENT_EXAMINE, .proc/examine)
	apply()

/datum/component/decal/Destroy()
	remove()
	return ..()

/datum/component/decal/OnTransfer(atom/thing)
	remove()
	remove(thing)
	apply(thing)

/datum/component/decal/proc/generate_appearance(_icon, _icon_state, _dir, _layer, _color)
	if(!_icon || !_icon_state)
		return FALSE
	// It has to be made from an image or dir breaks because of a byond bug
	var/temp_image = image(_icon, null, _icon_state, _layer, _dir)
	pic = new(temp_image)
	pic.color = _color
	return TRUE

/datum/component/decal/proc/apply(atom/thing)
	var/atom/master = thing || parent
	master.add_overlay(pic, TRUE)
	if(isitem(master))
		addtimer(CALLBACK(master, /obj/item/.proc/update_slot_icon), 0, TIMER_UNIQUE)

/datum/component/decal/proc/remove(atom/thing)
	var/atom/master = thing || parent
	master.cut_overlay(pic, TRUE)
	if(isitem(master))
		addtimer(CALLBACK(master, /obj/item/.proc/update_slot_icon), 0, TIMER_UNIQUE)

/datum/component/decal/proc/rotate_react(old_dir, new_dir)
	if(old_dir == new_dir)
		return
	remove()
	pic.dir = turn(pic.dir, dir2angle(old_dir) - dir2angle(new_dir))
	apply()

/datum/component/decal/proc/clean_react(strength)
	if(strength >= cleanable)
		qdel(src)

/datum/component/decal/proc/examine(mob/user)
	to_chat(user, description)