/datum/component/ai/area_territorial
	var/enter_signal
	var/list/enter_args
	var/area/territory = null

/datum/component/ai/area_territorial/proc/SetArea(var/area/new_area)
	if(territory)
		territory.unregister_event(/event/comp_ai_cmd_area_enter, src, .proc/area_enter)
	territory = new_area
	territory.register_event(/event/comp_ai_cmd_area_enter, src, .proc/area_enter)

/datum/component/ai/area_territorial/proc/area_enter(var/obj/enterer)
	if(!isliving(enterer)) //Piss off, ghost!
		return
	var/list/signal_args = enter_args.Copy()
	signal_args.Add(args)
	INVOKE_EVENT(parent, enter_signal, signal_args)