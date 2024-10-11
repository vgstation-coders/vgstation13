//This is the proc for gibbing a mob. Cannot gib ghosts.
//added different sort of gibs and animations. N
/mob/proc/gib(animation = FALSE, meat = TRUE)
	if(status_flags & BUDDHAMODE)
		return
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

var/global/firstblood = FALSE

/mob/proc/death(gibbed)
	var/turf/place_of_death = get_turf(src)
	if(is_dying)
		var/deathstring = "[src] at ([get_coordinates_string(src)]) had death() called (with var/gibbed = [gibbed]) while already dying!"
		log_debug(deathstring)
		message_admins(deathstring)
		return
	is_dying = TRUE
	timeofdeath = world.time
	INVOKE_EVENT(src, /event/death, "user" = src, "body_destroyed" = gibbed)
	living_mob_list -= src
	dead_mob_list += src
	if(attack_log.len)
		var/lastmsg = attack_log[attack_log.len]
		for(var/mob/living/L in living_mob_list)
			if(L.ckey && findtext(lastmsg,L.ckey))
				INVOKE_EVENT(L, /event/kill, "killer" = L, "victim" = src)
				firstblood = TRUE
				break
	stat_collection.add_death_stat(src,place_of_death)
	if(runescape_skull_display && ticker)//we died, begone skull
		if ("\ref[src]" in ticker.runescape_skulls)
			var/datum/runescape_skull_data/the_data = ticker.runescape_skulls["\ref[src]"]
			ticker.runescape_skulls -= "\ref[src]"
			qdel(the_data)
	if(client)
		client.color = initial(client.color)
	for(var/obj/item/I in src)
		I.OnMobDeath(src)
	for(var/atom/A in arcane_tampered_atoms)
		A.bless()
	if(spell_masters && spell_masters.len)
		for(var/obj/abstract/screen/movable/spell_master/spell_master in spell_masters)
			spell_master.on_holder_death(src)
	if(transmogged_from)
		transmog_death()
	if(client || mind)
		var/mindname = (src.mind && src.mind.name) ? "[src.mind.name]" : "[real_name]"
		var/died_as = (mindname == real_name) ? "" : " (died as [real_name])"
		for(var/mob/M in get_deadchat_hearers())
			var/rendered = "\proper[formatFollow(src)] <span class='game deadsay'> \The <span class='name'>[mindname][died_as]</span> has died at \the <span class='name'>[get_area(place_of_death)]</span>.</span>"
			to_chat(M, rendered)
		log_game("[key_name(src)] has died at [get_area(place_of_death)]. Coordinates: ([get_coordinates_string(src)])")
	is_dying = FALSE

/mob/proc/transmog_death()
	var/obj/transmog_body_container/C = transmogged_from
	var/mob/living/L = C.contained_mob
	transmogrify()
	L.visible_message("<span class='danger'>\The [L]'s body shifts and contorts!</span>")
	if(C.kill_on_death && istype(L))
		L.adjustOxyLoss(max(L.health,200))	//if you die while transmogrified, you die for real
		L.updatehealth()

//This proc should be used when you're restoring a guy to life. It will remove him from the dead mob list, and add him to the living mob list. It will also remove any verbs
//that his dead body has
/mob/proc/resurrect()
	living_mob_list |= src
	dead_mob_list -= src
	if(src.client)
		clear_fullscreens()
	verbs -= /mob/living/proc/butcher
