#define COLD_TRIGGER 225
#define HOT_TRIGGER 375

/datum/artifact_trigger/temperature
	triggertype = TRIGGER_TEMPERATURE
	scanned_trigger = SCAN_ATMOS
	var/heat_triggered = 0
	var/key_attackby
	var/key_explode

/datum/artifact_trigger/temperature/New()
	..()
	heat_triggered = prob(50)

	key_attackby = my_artifact.on_attackby.Add(src, "owner_attackby")
	key_explode = my_artifact.on_explode.Add(src, "owner_explode")

/datum/artifact_trigger/temperature/CheckTrigger()
	var/turf/T = get_turf(my_artifact)
	var/datum/gas_mixture/env = T.return_air()
	if(env)
		if(!my_effect.activated)
			if(!heat_triggered && env.temperature < COLD_TRIGGER)
				Triggered(0, "COLDAIR", 0)
			else if(heat_triggered && env.temperature > HOT_TRIGGER)
				Triggered(0, "HOTAIR", 0)
		else
			if(!heat_triggered && env.temperature > COLD_TRIGGER)
				Triggered(0, "COLDAIR", 0)
			else if(heat_triggered && env.temperature < HOT_TRIGGER)
				Triggered(0, "HOTAIR", 0)

/datum/artifact_trigger/temperature/proc/owner_attackby(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]
	var/obj/item = event_args[3]

	if(heat_triggered && item.is_hot())
		Triggered(toucher, context, item)

/datum/artifact_trigger/temperature/proc/owner_explode(var/list/event_args, var/source)
	var/context = event_args[2]
	Triggered(0, context, 0)

/datum/artifact_trigger/temperature/Destroy()
	my_artifact.on_attackby.Remove(key_attackby)
	my_artifact.on_explode.Remove(key_explode)
	..()