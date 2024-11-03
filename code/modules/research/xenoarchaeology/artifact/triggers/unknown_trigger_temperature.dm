#define COLD_TRIGGER 225
#define HOT_TRIGGER 375

/datum/artifact_trigger/temperature
	triggertype = TRIGGER_TEMPERATURE
	scanned_trigger = SCAN_ATMOS
	var/heat_triggered = 0

/datum/artifact_trigger/temperature/New()
	..()
	heat_triggered = prob(50)

	my_artifact.register_event(/event/attackby, src, nameof(src::owner_attackby()))
	my_artifact.register_event(/event/explosion, src, nameof(src::owner_explode()))

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

/datum/artifact_trigger/temperature/proc/owner_attackby(mob/living/attacker, obj/item/item)
	if(heat_triggered && item.is_hot())
		Triggered(attacker, "MELEE", item)

/datum/artifact_trigger/temperature/proc/owner_explode(severity)
	Triggered(0, "EXPLOSION", 0)

/datum/artifact_trigger/temperature/Destroy()
	my_artifact.unregister_event(/event/attackby, src, nameof(src::owner_attackby()))
	my_artifact.unregister_event(/event/explosion, src, nameof(src::owner_explode()))
	..()
