/spell/targeted/recall
	name = "Recall"
	desc = "Cast on any movable object to mark it, then future casts will teleport it into your hands if possible, or onto the ground at your feet. Middle click the spell icon to clear the marked object."
	abbreviation = "RC"

	school = "abjuration"
	charge_max = 100
	spell_flags = SELECTABLE | WAIT_FOR_CLICK
	hud_state = "wiz_recall"

	var/has_object = 0
	var/obj/marked
	var/icon/marked_icon


/spell/targeted/recall/is_valid_target(var/obj/target)
	if(!istype(target))
		return 0
	if(target.anchored)
		return 0

	return target

/spell/targeted/recall/before_channel(mob/user)
	if(has_object)
		if(cast_check(0, user))
			if(!marked || marked.loc == null) //if it's deleted or something
				to_chat(user, "<span class='danger'>You can't find your marked object anywhere!</span>")
				clear_marked()
				return 1
			if(marked.anchored)
				to_chat(user, "<span class='danger'>You can't seem to move your marked object!</span>")
				clear_marked()
				return 1
			var/turf/oldloc = get_turf(marked)
			if(istype(marked, /obj/item))
				var/obj/item/I = marked
				if(istype(I.loc, /mob))
					var/mob/M = marked.loc
					if(M == user) //you already have it you dumb
						return 1
					M.drop_item(I, force_drop = 1)
					M.update_icons()
				user.put_in_hands(I)
			else
				marked.forceMove(get_turf(user))
			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(3, 0, oldloc)
			sparks.start()
			take_charge(user)
		return 1
	return 0

/spell/targeted/recall/cast(list/targets, mob/user = user)
	for(var/obj/target in targets)
		if(!has_object)
			has_object = 1
			marked = target
			marked_icon = image(target.icon, target.icon_state)
			connected_button.overlays += marked_icon
			to_chat(user, "You place a magic mark on \the [target].")
			channel_spell(force_remove = 1)
	return 1

/spell/targeted/recall/on_right_click(mob/user)
	if(has_object)
		if(!marked)
			to_chat(user, "You remove your magic mark.")
		else
			to_chat(user, "You remove the mark from \the [marked].")
		clear_marked()
	return 1

/spell/targeted/recall/proc/clear_marked()
	has_object = 0
	marked = null
	connected_button.overlays -= marked_icon
	marked_icon = null