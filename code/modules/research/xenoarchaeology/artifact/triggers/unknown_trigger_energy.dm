/datum/artifact_trigger/energy
	triggertype = TRIGGER_ENERGY
	scanned_trigger = SCAN_PHYSICAL_ENERGETIC

/datum/artifact_trigger/energy/New()
	..()
	my_artifact.register_event(/event/attackby, src, nameof(src::owner_attackby()))
	my_artifact.register_event(/event/projectile, src, nameof(src::owner_projectile()))
	my_artifact.register_event(/event/beam_connect, src, nameof(src::owner_beam()))

/datum/artifact_trigger/energy/proc/owner_attackby(mob/living/attacker, obj/item/item)
	var/static/list/energy_weapons = list(
		/obj/item/weapon/melee/energy,
		/obj/item/weapon/melee/legacy_cultblade,
		/obj/item/weapon/card/emag,
		/obj/item/device/multitool,
	)
	if(istype(item, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/stick = item
		if(!stick.status)
			return
	if(!is_type_in_list(item, energy_weapons))
		return
	Triggered(attacker, "MELEE", item)

/datum/artifact_trigger/energy/proc/owner_projectile(obj/item/projectile/projectile)
	var/list/energy_projectiles = list(
		/obj/item/projectile/beam,
		/obj/item/projectile/ion,
		/obj/item/projectile/energy,
	)
	if(!is_type_in_list(projectile, energy_projectiles))
		return
	Triggered(projectile.firer, "PROJECTILE", projectile)

/datum/artifact_trigger/energy/proc/owner_beam(obj/effect/beam/beam)
	if (beam?.get_damage())
		Triggered(null, "BEAMCONNECT", beam)

/datum/artifact_trigger/energy/Destroy()
	my_artifact.unregister_event(/event/attackby, src, nameof(src::owner_attackby()))
	my_artifact.unregister_event(/event/projectile, src, nameof(src::owner_projectile()))
	my_artifact.unregister_event(/event/beam_connect, src, nameof(src::owner_beam()))
	..()
