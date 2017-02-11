#define TRIGGER_TOUCH 0
#define TRIGGER_ENERGY 1
#define TRIGGER_FORCE 2
#define TRIGGER_REAGENT 3
#define TRIGGER_GAS 4
#define TRIGGER_TEMPERATURE 5

/datum/artifact_trigger
	var/triggertype = ""
	var/obj/machinery/artifact/my_artifact
	var/datum/artifact_effect/my_effect

/datum/artifact_trigger/New(var/atom/location)
	..()
	my_effect = location

/datum/artifact_trigger/proc/CheckTrigger()

/datum/artifact_trigger/proc/Triggered(var/toucher = null, var/context = null, var/item = null)
	if(my_effect.IsPrimary())
		my_effect.ToggleActivate()

		var/log = "|| effect [my_effect.artifact_id]([my_effect]) triggered by [context]([my_effect.trigger]) ||"
		if(item)
			log += " [item] ||"
		if(toucher)
			log += " attacked by [key_name(toucher)]."
		my_artifact.investigation_log(I_ARTIFACT, log)

	else if(!my_effect.IsPrimary() && prob(25))
		my_effect.ToggleActivate(2)

		var/log = "|| effect [my_effect.artifact_id]([my_effect]) triggered by [context]([my_effect.trigger]) ||"
		if(item)
			log += " [item] ||"
		if(toucher)
			log += " attacked by [key_name(toucher)]."
		my_artifact.investigation_log(I_ARTIFACT, log)

/datum/artifact_trigger/Destroy()
	my_artifact = null
	my_effect = null
