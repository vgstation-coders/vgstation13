/datum/artifact_trigger/touch
	triggertype = "touch"

/datum/artifact_trigger/touch/New()
	..()

/datum/artifact_trigger/touch/owner_attackhand(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]

	if(my_effect.IsPrimary())
		Triggered()
		my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [context] ([my_effect.trigger]) || touched by [key_name(toucher)].")
	else if(!my_effect.IsPrimary())
		Triggered()
		my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [context] ([my_effect.trigger]) || touched by [key_name(toucher)].")
	..()