/datum/artifact_trigger/touch
	triggertype = "touch"

/datum/artifact_trigger/touch/New()
	..()

/datum/artifact_trigger/touch/owner_attackhand(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]

	if(my_effect.IsPrimary())
		Triggered(toucher, context, 0)
	else if(!my_effect.IsPrimary())
		Triggered(toucher, context, 0)
	..()

/datum/artifact_trigger/touch/Destroy()
	my_artifact.on_attackhand.Remove(key0)