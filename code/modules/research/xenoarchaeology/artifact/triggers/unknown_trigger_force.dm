#define FORCE_THRESHOLD 10

/datum/artifact_trigger/force
	triggertype = TRIGGER_FORCE
	scanned_trigger = SCAN_PHYSICAL_ENERGETIC
	var/key_attackby
	var/key_explode
	var/key_projectile

/datum/artifact_trigger/force/New()
	..()
	my_artifact.register_event(/event/attackby, src, nameof(src::owner_attackby()))
	my_artifact.register_event(/event/explosion, src, nameof(src::owner_explode()))
	my_artifact.register_event(/event/projectile, src, nameof(src::owner_projectile()))
	my_artifact.register_event(/event/bumped, src, nameof(src::owner_bumped()))

/datum/artifact_trigger/force/proc/owner_attackby(mob/living/attacker, obj/item/item)
	if(item.force < FORCE_THRESHOLD)
		return
	Triggered(attacker, "MELEE", item)

/datum/artifact_trigger/force/proc/owner_explode(severity)
	Triggered(null, "EXPLOSION", null)

/datum/artifact_trigger/force/proc/owner_projectile(obj/item/projectile/projectile)
	var/static/list/valid_projectiles = list(
		/obj/item/projectile/bullet,
		/obj/item/projectile/hivebotbullet,
	)
	if(!is_type_in_list(projectile, valid_projectiles))
		return
	Triggered(projectile.firer, "PROJECTILE", projectile)

/datum/artifact_trigger/force/proc/owner_bumped(atom/movable/bumper, atom/bumped)
	var/obj/item/thrown_item = bumper
	if(!istype(thrown_item))
		return
	if(thrown_item.throwforce < FORCE_THRESHOLD)
		return
	Triggered(usr, "THROW", thrown_item)

/datum/artifact_trigger/force/Destroy()
	my_artifact.unregister_event(/event/attackby, src, nameof(src::owner_attackby()))
	my_artifact.unregister_event(/event/explosion, src, nameof(src::owner_explode()))
	my_artifact.unregister_event(/event/projectile, src, nameof(src::owner_projectile()))
	my_artifact.unregister_event(/event/bumped, src, nameof(src::owner_bumped()))
	..()
