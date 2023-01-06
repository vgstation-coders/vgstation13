/datum/component/ai/area_territorial
	var/enter_signal
	var/list/enter_args
	var/exit_signal
	var/list/exit_args
	var/area/territory = null

/datum/component/ai/area_territorial/proc/SetArea(var/area/new_area)
	unset_area()
	territory = new_area
	territory.register_event(/event/area_entered, src, .proc/area_enter)
	territory.register_event(/event/area_exited, src, .proc/area_exit)

/datum/component/ai/area_territorial/proc/unset_area()
	if(territory)
		territory.unregister_event(/event/area_entered, src, .proc/area_enter)
		territory.unregister_event(/event/area_exited, src, .proc/area_exit)

/datum/component/ai/area_territorial/Destroy()
	unset_area()
	..()

/datum/component/ai/area_territorial/proc/area_enter(atom/movable/enterer)
	if(isliving(enterer)) // No ghosts
		INVOKE_EVENT(parent, enter_signal, enter_args)

/datum/component/ai/area_territorial/proc/area_exit(atom/movable/exiter)
	if(isliving(exiter)) // No ghosts
		INVOKE_EVENT(parent, exit_signal, exit_args)

/datum/component/ai/area_territorial/say
	enter_signal = /event/comp_ai_cmd_specific_say
	exit_signal = /event/comp_ai_cmd_specific_say

/datum/component/ai/area_territorial/signal
	var/id_tag = ""

/datum/component/ai/area_territorial/signal/area_enter(atom/movable/enterer)
	for(var/obj/machinery/M in territory)
		if(M.id_tag == src.id_tag)
			enter_function()

/datum/component/ai/area_territorial/signal/area_exit(atom/movable/enterer)
	for(var/obj/machinery/M in territory)
		if(M.id_tag == src.id_tag)
			exit_function()

/datum/component/ai/area_territorial/signal/proc/enter_function(obj/machinery/M)
	return

/datum/component/ai/area_territorial/signal/proc/exit_function(obj/machinery/M)
	return

/datum/component/ai/area_territorial/signal/door/enter_function(obj/machinery/door/D)
	if(istype(D) && !D.density)
		D.close()

/datum/component/ai/area_territorial/signal/door/exit_function(obj/machinery/door/D)
	if(istype(D) && D.density)
		D.open()
