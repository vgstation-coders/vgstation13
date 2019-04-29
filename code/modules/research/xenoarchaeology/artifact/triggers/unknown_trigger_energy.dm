/datum/artifact_trigger/energy
	triggertype = TRIGGER_ENERGY
	scanned_trigger = SCAN_PHYSICAL_ENERGETIC
	var/key_attackby
	var/key_projectile

/datum/artifact_trigger/energy/New()
	..()
	key_attackby = my_artifact.on_attackby.Add(src, "owner_attackby")
	key_projectile = my_artifact.on_projectile.Add(src, "owner_projectile")

/datum/artifact_trigger/energy/proc/owner_attackby(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]
	var/obj/item/weapon/item = event_args[3]

	if(istype(item,/obj/item/weapon/melee/baton) && item:status ||\
			istype(item,/obj/item/weapon/melee/energy) ||\
			istype(item,/obj/item/weapon/melee/legacy_cultblade) ||\
			istype(item,/obj/item/weapon/card/emag) ||\
			istype(item,/obj/item/device/multitool))
		Triggered(toucher, context, item)

/datum/artifact_trigger/energy/proc/owner_projectile(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]
	var/item = event_args[3]

	if(istype(item,/obj/item/projectile/beam) ||\
		istype(item,/obj/item/projectile/ion) ||\
		istype(item,/obj/item/projectile/energy))
		Triggered(toucher, context, item)

/datum/artifact_trigger/energy/Destroy()
	my_artifact.on_attackby.Remove(key_attackby)
	my_artifact.on_projectile.Remove(key_projectile)
	..()