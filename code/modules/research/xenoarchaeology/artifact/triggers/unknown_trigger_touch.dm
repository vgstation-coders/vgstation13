/datum/artifact_trigger/touch
	triggertype = TRIGGER_TOUCH
	scanned_trigger = SCAN_PHYSICAL
	var/key_attackhand

/datum/artifact_trigger/touch/New()
	..()
	key_attackhand = my_artifact.on_attackhand.Add(src, "owner_attackhand")

/datum/artifact_trigger/touch/proc/owner_attackhand(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]

	Triggered(toucher, context, 0)

	if(my_effect.effect == ARTIFACT_EFFECT_TOUCH)
		if (my_effect.IsContained())
			my_effect.Blocked()
		else if(my_effect.IsPrimary() || prob(25))
			my_effect.DoEffectTouch(toucher)
			my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [context] ([my_effect.trigger]) || touched by [key_name(toucher)].")

/datum/artifact_trigger/touch/Destroy()
	my_artifact.on_attackhand.Remove(key_attackhand)
	..()