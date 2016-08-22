/spell/aoe_turf/ring_of_fire
	name = "Ring of Fire"
	desc = "Summon a stationary ring of fire around your current location for 10 seconds. While the ring is active, you are immune to fire and high temperatures."
	school = "conjuration"
	charge_max = 300
	cooldown_min = 100

	spell_levels = list(Sp_SPEED = 0, Sp_MOVE = 0)
	level_max = list(Sp_TOTAL = 4, Sp_SPEED = 3, Sp_MOVE = 1)

	spell_flags = NEEDSCLOTHES
	charge_type = Sp_RECHARGE
	invocation = "E ROHA"
	invocation_type = SpI_SHOUT
	hud_state = "wiz_firering"

	duration = 100
	range = 3
	var/move_with_user = 0

/spell/aoe_turf/ring_of_fire/choose_targets(mob/user = usr)
	return trange(range, get_turf(user)) - trange(range - 1, get_turf(user))

/spell/aoe_turf/ring_of_fire/cast(list/targets, mob/user)

	var/obj/effect/ring = new /obj/effect/ring_of_fire(get_turf(user), targets, duration)

	if(move_with_user)
		user.lock_atom(ring, /datum/locking_category/ring_of_fire)

	to_chat(user, "<span class='danger'>You summon a ring of fire around yourself.</span>")

	if(isliving(user))
		to_chat(user, "<span class='info'>You feel resistant to fire.</span>")
		var/mob/living/L = user
		L.mutations.Add(M_RESIST_HEAT)
		L.update_mutations()

		spawn(duration)
			L.mutations.Remove(M_RESIST_HEAT)
			L.update_mutations()

			if(!L.mutations.Find(M_RESIST_HEAT))
				to_chat(L, "<span class='info'>You no longer feel resistant to fire.</span>")

	..()

/spell/aoe_turf/ring_of_fire/apply_upgrade(upgrade_type)
	switch(upgrade_type)
		if(Sp_MOVE)
			spell_levels[Sp_MOVE]++
			move_with_user = 1
			desc = "Summon a ring of fire around yourself for 10 seconds. While the ring is active, you are immune to fire and high temperatures."
			return "The ring will now move together with you."

	return ..()

/spell/aoe_turf/ring_of_fire/get_upgrade_info(upgrade_type)
	switch(upgrade_type)
		if(Sp_MOVE)
			return "Make the ring move together with you."

	return ..()

//Invisible object that keeps all the individual flames together
/obj/effect/ring_of_fire
	anchored = TRUE
	invisibility = 101

/obj/effect/ring_of_fire/New(loc, list/locations, duration)
	..()

	for(var/turf/T in locations)
		var/obj/effect/fire_blast/ring_of_fire/F = getFromPool(/obj/effect/fire_blast/ring_of_fire, T)
		F.duration = duration

		lock_atom(F, /datum/locking_category/ring_of_fire)

	spawn(duration)
		qdel(src)

/obj/effect/fire_blast/ring_of_fire
	fire_damage = 7
	spread = 0

/datum/locking_category/ring_of_fire
	unique = 1 //Create an object for every locked atom

/datum/locking_category/ring_of_fire/lock(atom/movable/AM)
	x_offset = AM.x - owner.x
	y_offset = AM.y - owner.y

	..()
