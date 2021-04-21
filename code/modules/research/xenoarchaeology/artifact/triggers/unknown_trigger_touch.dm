/datum/artifact_trigger/touch
	triggertype = TRIGGER_TOUCH
	scanned_trigger = SCAN_PHYSICAL

/datum/artifact_trigger/touch/New()
	..()
	my_artifact.lazy_register_event(/lazy_event/on_attackhand, src, .proc/owner_attackhand)
	my_artifact.lazy_register_event(/lazy_event/on_bumped, src, .proc/owner_bumped)

/datum/artifact_trigger/touch/proc/activate(mob/user, context)
	Triggered(user, "TOUCH", 0)

	if(my_effect.effect == ARTIFACT_EFFECT_TOUCH)
		if (my_effect.IsContained())
			my_effect.Blocked()
		else if(my_effect.IsPrimary() || prob(25))
			my_effect.DoEffectTouch(user)
			my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [context] ([my_effect.trigger]) || touched by [key_name(user)].")

/datum/artifact_trigger/touch/proc/owner_bumped(mob/user, atom/target)
	activate(user, "BUMPED")

/datum/artifact_trigger/touch/proc/owner_attackhand(mob/user, atom/target)
	activate(user, "TOUCH")

/datum/artifact_trigger/touch/Destroy()
	my_artifact.lazy_unregister_event(/lazy_event/on_attackhand, src, .proc/owner_attackhand)
	my_artifact.lazy_unregister_event(/lazy_event/on_bumped, src, .proc/owner_bumped)
	..()
