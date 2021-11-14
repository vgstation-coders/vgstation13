/datum/component/ai/area_territorial
	var/enter_signal
	var/list/enter_args
	var/area/territory = null

/datum/component/ai/area_territorial/proc/SetArea(var/area/new_area)
	if(territory)
		territory.unregister_event(/event/comp_ai_cmd_area_enter, src, .proc/area_enter)
	territory = new_area
	territory.register_event(/event/comp_ai_cmd_area_enter, src, .proc/area_enter)

/** Args end up being whatever custom args you set in the on_enter list, plus "enterer" /atom and "oldArea" /area
	on_enter should be formatted preferably as list("signal" = signal, "args" = list())
 */

/datum/component/ai/area_territorial/proc/area_enter(var/list/args)
	var/mob/M = args["enterer"]
	if(!isliving(M)) //Piss off, ghost!
		return
	var/list/signal_args = enter_args.Copy()
	signal_args.Add(args)
	INVOKE_EVENT(src, enter_signal, signal_args)