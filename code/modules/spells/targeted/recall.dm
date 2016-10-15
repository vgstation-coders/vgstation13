/spell/targeted/recall
	name = "Recall"
	desc = "This spell allows a wizard to put a 'mark' on almost any object, then teleport it to them at will. Middle click the spell icon or use the 'clear mark' spell to clear the marked object."
	abbreviation = "RC"

	school = "abjuration"
	charge_max = 100
	spell_flags = SELECTABLE | WAIT_FOR_CLICK
	hud_state = "wiz_recall"
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 2, Sp_POWER = 1)

	var/has_object = 0
	var/obj/marked
	var/icon/marked_icon

	var/allow_anchored = 0

	var/static/list/prohibited = list( //Items that are prohibited because, frankly, it would cause more unfun for everyone else than fun for the user if they could be retrieved.
		/obj/machinery/power/apc,								//APCs
		/obj/machinery/atmospherics,							//pipes, vents, pumps, the cryo tubes, the gas miners, etc.
		/obj/machinery/alarm,									//air alarms
		/obj/machinery/firealarm,								//fire alarms
		/obj/machinery/status_display,							//status displays
		/obj/machinery/newscaster,								//newscasters
		/obj/item/device/radio/intercom,						//intercoms
		/obj/structure/extinguisher_cabinet,					//fire extinguisher cabinets
		/obj/machinery/computer/security/telescreen,			//TV screens
		/obj/machinery/camera,									//AI cameras
		/obj/machinery/requests_console,						//requests consoles
		/obj/machinery/door_control,							//door control buttons
		/obj/structure/closet/fireaxecabinet,					//fire axe cabinets
		/obj/machinery/light_switch,							//light switches                  //list taken from subspacetunneler.dm
		/obj/structure/sign,									//area signs
		/obj/structure/closet/walllocker,						//defib lockers, wall-mounted O2 lockers, etc.
		/obj/machinery/recharger/defibcharger/wallcharger,		//wall-mounted defib chargers
		/obj/structure/noticeboard,								//notice boards
		/obj/machinery/space_heater/campfire/stove/fireplace,	//fireplaces
		/obj/structure/painting,								//paintings
		/obj/item/weapon/storage/secure/safe,					//wall-mounted safes
		/obj/machinery/door_timer,								//brig cell timers
		/obj/structure/closet/secure_closet/brig,				//brig cell closets
		/obj/machinery/disposal,								//disposal bins
		/obj/machinery/light,									//light bulbs and tubes
		/obj/machinery/sleep_console,							//sleeper consoles
		/obj/machinery/sleeper,									//sleepers
		/obj/machinery/body_scanconsole,						//body scanner consoles
		/obj/machinery/bodyscanner,								//body scanners
		/obj/machinery/media/receiver/boombox/wallmount,		//sound systems
		/obj/machinery/keycard_auth,							//keycard authentication devices
		)


/spell/targeted/recall/is_valid_target(var/obj/target)
	if(!istype(target))
		return 0
	if(target.anchored && !allow_anchored)
		return 0
	for(var/J in prohibited)
		if(istype(target, J))
			return 0

	return target

/spell/targeted/recall/before_channel(mob/user)
	if(has_object)
		if(cast_check(0, user))
			if(!marked || marked.loc == null) //if it's deleted or something
				to_chat(user, "<span class='danger'>You can't find your marked object anywhere!</span>")
				clear_marked()
				return 1
			if(marked.anchored && !allow_anchored)
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
			marked_icon = image(target.icon, target.icon_state, layer = HUD_ITEM_LAYER)
			connected_button.overlays += marked_icon
			to_chat(user, "You place a magic mark on \the [target].")
			channel_spell(force_remove = 1)
	return 1

/spell/targeted/recall/empower_spell()
	spell_levels[Sp_POWER]++
	allow_anchored = 1

	var/upgrade_desc = "You have increased the array of objects that can be moved."

	return upgrade_desc

/spell/targeted/recall/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_POWER)
		return "Increases the variety of objects that can be marked, letting anchored structures and machines be moved."
	return ..()

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

/spell/targeted/recall/on_added(mob/user)
	if(alert(user, "The marked object is cleared by middle-clicking the spell icon. You can also have a dedicated spell for clearing the mark. Do you want this?",,"Yes","No") == "Yes")
		var/spell/clear_mark/clear_mark = new /spell/clear_mark
		if(user.mind)
			if(!user.mind.wizard_spells)
				user.mind.wizard_spells = list()
			user.mind.wizard_spells += clear_mark
		user.add_spell(clear_mark)

/spell/targeted/recall/on_removed(mob/user)
	for(var/spell/clear_mark/spell in user.spell_list)
		spell.recall = null
		user.remove_spell(spell)

/spell/clear_mark
	name = "Remove Mark"
	desc = "Clears any magic mark you've previously set"

	school = "abjuration"
	charge_max = 10
	spell_flags = 0
	hud_state = "wiz_clear_mark"
	level_max = list(Sp_TOTAL = 0)

	var/spell/targeted/recall/recall

/spell/clear_mark/choose_targets(mob/user = usr)
	return list(user)

/spell/clear_mark/cast(list/targets, mob/user)
	if(recall.has_object)
		if(!recall.marked)
			to_chat(user, "You remove your magic mark.")
		else
			to_chat(user, "You remove the mark from \the [recall.marked].")
		recall.clear_marked()

/spell/clear_mark/on_added(mob/user)
	var/spell = /spell/targeted/recall
	if(!(locate(spell) in user.spell_list))
		user.remove_spell(src)
		return
	for(var/spell/targeted/recall/recallspell in user.spell_list)
		recall = recallspell