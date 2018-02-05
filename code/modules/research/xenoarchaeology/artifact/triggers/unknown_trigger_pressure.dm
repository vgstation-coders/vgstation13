#define HIGH_PRESSURE_TRIGGER 150
#define LOW_PRESSURE_TRIGGER 50

/datum/artifact_trigger/pressure
	triggertype = TRIGGER_PRESSURE
	scanned_trigger = SCAN_ATMOS
	var/high_triggered = 0
	//possibly make the required pressure random in the futurem, when better facilities are added
	var/key_explode

/datum/artifact_trigger/pressure/New()
	..()
	high_triggered = prob(50)
	key_explode = my_artifact.on_explode.Add(src, "owner_explode")

/datum/artifact_trigger/pressure/CheckTrigger()
	var/turf/T = get_turf(my_artifact)
	var/datum/gas_mixture/env = T.return_air()
	if(env)
		if(!my_effect.activated)
			if(!high_triggered && env.pressure < LOW_PRESSURE_TRIGGER)
				Triggered(0, "LOWPRESSURE", 0)
			else if(high_triggered && env.pressure > HIGH_PRESSURE_TRIGGER)
				Triggered(0, "HIGHPRESSURE", 0)
		else
			if(!high_triggered && env.pressure > LOW_PRESSURE_TRIGGER)
				Triggered(0, "HIGHPRESSURE", 0)
			else if(high_triggered && env.pressure < HIGH_PRESSURE_TRIGGER)
				Triggered(0, "LOWPRESSURE", 0)

/datum/artifact_trigger/pressure/proc/owner_explode(var/list/event_args, var/source)
	var/context = event_args[2]
	Triggered(0, context, 0)

/datum/artifact_trigger/pressure/Destroy()
	my_artifact.on_explode.Remove(key_explode)
	..()