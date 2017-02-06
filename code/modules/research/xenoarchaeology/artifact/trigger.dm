/datum/artifact_trigger
	var/atom/holder
	var/triggertype = ""
	var/obj/machinery/artifact/my_artifact
	var/datum/artifact_effect/my_effect
	var/key0

/datum/artifact_trigger/New(var/atom/location)
	..()
	my_effect = location
	spawn(0)
		key0 = my_artifact.on_attackhand.Add(src, "owner_attackhand")

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

/datum/artifact_trigger/proc/owner_attackhand(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]

	if (my_effect.effect == EFFECT_TOUCH)
		if (my_effect.IsContained())
			my_effect.Blocked()
		else
			my_effect.DoEffectTouch(toucher)
			my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [context] ([my_effect.trigger]) || touched by [key_name(toucher)].")