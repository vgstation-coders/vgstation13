#define FORCE_THRESHOLD 10

/datum/artifact_trigger/force
	triggertype = "force"

/datum/artifact_trigger/force/New()
	..()
	spawn(0)
		my_artifact.on_attackby.Add(src, "owner_attackby")
		my_artifact.on_explode.Add(src, "owner_explode")
		my_artifact.on_projectile.Add(src, "owner_projectile")

/datum/artifact_trigger/force/proc/owner_attackby(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]
	var/obj/item/weapon/item = event_args[3]

	if(context == "THROW" && item:throwforce >= FORCE_THRESHOLD)
		Triggered()
		my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [context]([my_effect.trigger]) || [item] || attacked by [key_name(toucher)].")
	else if(item.force >= FORCE_THRESHOLD)
		Triggered()
		my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [context]([my_effect.trigger]) || [item] || attacked by [key_name(toucher)].")

/datum/artifact_trigger/force/proc/owner_explode(var/list/event_args, var/source)
	var/context = event_args[2]
	Triggered()
	my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [context]([my_effect.trigger]).")

/datum/artifact_trigger/force/proc/owner_projectile(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]
	var/item = event_args[3]

	if(istype(item,/obj/item/projectile/bullet) ||\
		istype(item,/obj/item/projectile/hivebotbullet))
		Triggered()
		my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) triggered by [context]([my_effect.trigger]) || [item] || attacked by [key_name(toucher)].")