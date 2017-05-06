#define FORCE_THRESHOLD 10

/datum/artifact_trigger/force
	triggertype = TRIGGER_FORCE
	scanned_trigger = SCAN_PHYSICAL_ENERGETIC
	var/key_attackby
	var/key_explode
	var/key_projectile

/datum/artifact_trigger/force/New()
	..()
	key_attackby = my_artifact.on_attackby.Add(src, "owner_attackby")
	key_explode = my_artifact.on_explode.Add(src, "owner_explode")
	key_projectile = my_artifact.on_projectile.Add(src, "owner_projectile")

/datum/artifact_trigger/force/proc/owner_attackby(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]
	var/obj/item/weapon/item = event_args[3]

	if(context == "THROW" && item:throwforce >= FORCE_THRESHOLD)
		Triggered(toucher, context, item)
	else if(item.force >= FORCE_THRESHOLD)
		Triggered(toucher, context, item)

/datum/artifact_trigger/force/proc/owner_explode(var/list/event_args, var/source)
	var/context = event_args[2]
	Triggered(0, context, 0)

/datum/artifact_trigger/force/proc/owner_projectile(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]
	var/item = event_args[3]

	if(istype(item,/obj/item/projectile/bullet) ||\
		istype(item,/obj/item/projectile/hivebotbullet))
		Triggered(toucher, context, item)

/datum/artifact_trigger/force/Destroy()
	my_artifact.on_attackby.Remove(key_attackby)
	my_artifact.on_explode.Remove(key_explode)
	my_artifact.on_projectile.Remove(key_projectile)
	..()