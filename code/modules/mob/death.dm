//This is the proc for gibbing a mob. Cannot gib ghosts.
//added different sort of gibs and animations. N
/mob/proc/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

//	anim(target = src, a_icon = 'icons/mob/mob.dmi', /*flick_anim = "dust-m"*/, sleeptime = 15)

	dead_mob_list -= src

	qdel(src)

//This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
//Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here.
//Dusting robots does not eject the MMI, so it's a bit more powerful than gib() /N
/mob/proc/dust()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

//	anim(target = src, a_icon = 'icons/mob/mob.dmi', /*flick_anim = "dust-m"*/, sleeptime = 15)
	new /obj/effect/decal/cleanable/ash(loc)

	dead_mob_list -= src

	qdel(src)


/mob/proc/death(gibbed)
	timeofdeath = world.time
	INVOKE_EVENT(on_death, list("user" = src,"body_destroyed" = gibbed))
	living_mob_list -= src
	dead_mob_list += src
	stat_collection.add_death_stat(src)
	if(client)
		client.color = initial(client.color)
	for(var/obj/item/I in src)
		I.OnMobDeath(src)
	if(spell_masters && spell_masters.len)
		for(var/obj/abstract/screen/movable/spell_master/spell_master in spell_masters)
			spell_master.on_holder_death(src)
	if(transmogged_from)
		var/obj/transmog_body_container/C = transmogged_from
		var/mob/living/L = C.contained_mob
		transmogrify()
		L.visible_message("<span class='danger'>\The [L]'s body shifts and contorts!</span>")
		if(istype(L))
			L.adjustOxyLoss(max(L.health,200))	//if you die while transmogrified, you die for real
			L.updatehealth()
		return

//This proc should be used when you're restoring a guy to life. It will remove him from the dead mob list, and add him to the living mob list. It will also remove any verbs
//that his dead body has
/mob/proc/resurrect()
	living_mob_list |= src
	dead_mob_list -= src

	verbs -= /mob/living/proc/butcher
