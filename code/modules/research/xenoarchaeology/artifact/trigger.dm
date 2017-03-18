#define TRIGGER_TOUCH "touch"
#define TRIGGER_ENERGY "energy"
#define TRIGGER_FORCE "force"
#define TRIGGER_REAGENT "reagent"
#define TRIGGER_GAS "gas"
#define TRIGGER_TEMPERATURE "temperature"

/datum/artifact_trigger
	var/triggertype = ""
	var/obj/machinery/artifact/my_artifact
	var/datum/artifact_effect/my_effect

/datum/artifact_trigger/New(var/atom/location)
	..()
	if(location)
		my_effect = location
		my_artifact = my_effect.holder
	else
		return

/datum/artifact_trigger/proc/CheckTrigger()

/datum/artifact_trigger/proc/Triggered(var/toucher = null, var/context = null, var/item = null)
	if(my_effect.IsPrimary())
		if(my_effect.effect != EFFECT_TOUCH)
			var/log = "|| effect [my_effect.artifact_id]([my_effect]) triggered"
			if(my_effect.activated)
				log += " off"
			else
				log += " on"
			log += " by [context]([my_effect.trigger])"
			if(item)
				log += " || [item]"
			if(toucher)
				log += " || attacked by [key_name(toucher)]."
			my_artifact.investigation_log(I_ARTIFACT, log)
			my_effect.ToggleActivate()

	else if(!my_effect.IsPrimary() && prob(25))	//secondary effects only have a 1/4 chance to trigger
		if(my_effect.effect != EFFECT_TOUCH)
			var/log = "|| effect [my_effect.artifact_id]([my_effect]) triggered"
			if(my_effect.activated)
				log += " off"
			else
				log += " on"
			log += " by [context]([my_effect.trigger])"
			if(item)
				log += " || [item]"
			if(toucher)
				log += " || attacked by [key_name(toucher)]."
			my_artifact.investigation_log(I_ARTIFACT, log)
			my_effect.ToggleActivate(2)

/datum/artifact_trigger/Destroy()
	my_artifact = null
	my_effect = null
