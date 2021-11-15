/datum/component/ai/area_territorial
	var/enter_signal
	var/list/enter_args
	var/exit_signal
	var/list/exit_args
	var/area/territory = null

/datum/component/ai/area_territorial/proc/SetArea(var/area/new_area)
	if(territory)
		territory.unregister_event(/event/comp_ai_cmd_area_enter, src, .proc/area_enter)
		territory.unregister_event(/event/comp_ai_cmd_area_exit, src, .proc/area_exit)
	territory = new_area
	territory.register_event(/event/comp_ai_cmd_area_enter, src, .proc/area_enter)
	territory.register_event(/event/comp_ai_cmd_area_exit, src, .proc/area_exit)

/datum/component/ai/area_territorial/proc/area_enter(var/obj/enterer)
	if(isliving(enterer)) // No ghosts
		INVOKE_EVENT(parent, enter_signal, enter_args)

/datum/component/ai/area_territorial/proc/area_exit(var/obj/exiter)
	if(isliving(exiter)) // No ghosts
		INVOKE_EVENT(parent, exit_signal, exit_args)