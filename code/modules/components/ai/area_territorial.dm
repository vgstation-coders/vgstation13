/datum/component/ai/area_territorial
	var/list/on_enter
	var/area/territory = null
	var/event_key

/datum/component/ai/area_territorial/proc/SetArea(var/area/new_area)
	if(territory)
		territory.on_area_enter.Remove(event_key)
	territory = new_area
	event_key = territory.on_area_enter.Add(src, "area_enter")

/** Args end up being whatever custom args you set in the on_enter list, plus "enterer" /atom and "oldArea" /area
	on_enter should be formatted preferably as list("signal" = signal, "args" = list())
 */

/datum/component/ai/area_territorial/proc/area_enter(var/list/args)
	var/mob/M = args["enterer"]
	if(!isliving(M)) //Piss off, ghost!
		return
	var/signal = on_enter["signal"]
	var/list/signal_args = on_enter["args"].Copy()
	signal_args.Add(args)
	SendSignal(signal, signal_args)