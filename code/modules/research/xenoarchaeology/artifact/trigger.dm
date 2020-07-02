#define TRIGGER_TOUCH "touch"
#define TRIGGER_ENERGY "energy"
#define TRIGGER_FORCE "force"
#define TRIGGER_REAGENT "reagent"
#define TRIGGER_GAS "gas"
#define TRIGGER_TEMPERATURE "temperature"
#define TRIGGER_LIGHT "light"
#define TRIGGER_PRESSURE "pressure"
#define TRIGGER_ELECTRIC "electric"
#define TRIGGER_SPEED "speed"
#define TRIGGER_NOT_VISIBLE "not_visible"
#define TRIGGER_PAY2USE "pay2use"

#define SCAN_PHYSICAL 0
#define SCAN_PHYSICAL_ENERGETIC 1
#define SCAN_CONSTANT_ENERGETIC 2
#define SCAN_ATMOS 3
#define SCAN_OCULAR 4

/datum/artifact_trigger
	var/triggertype = ""
	var/scanned_trigger = ""
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
		if(my_effect.effect != ARTIFACT_EFFECT_TOUCH)
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
		if(my_effect.effect != ARTIFACT_EFFECT_TOUCH)
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


/datum/artifact_trigger/Topic(href, href_list)
	return my_artifact.Topic(href, href_list)
