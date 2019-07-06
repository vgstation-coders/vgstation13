/spell/aoe_turf/ring_of_fire
	name = "Ring of Fire"
	desc = "Summon a stationary ring of flames around your current location for 10 seconds. While the ring is active, you are fully immune to fire and burns."
	user_type = USER_TYPE_WIZARD
	specialization = OFFENSIVE
	school = "conjuration"
	charge_max = 300
	cooldown_min = 100

	spell_levels = list(Sp_SPEED = 0, Sp_MOVE = 0)
	level_max = list(Sp_TOTAL = 4, Sp_SPEED = 3, Sp_MOVE = 1)

	spell_flags = NEEDSCLOTHES
	spell_aspect_flags = SPELL_FIRE
	charge_type = Sp_RECHARGE
	invocation = "E ROHA"
	invocation_type = SpI_SHOUT
	hud_state = "wiz_firering"
	price = Sp_BASE_PRICE / 2

	duration = 100
	range = 3
	selection_type = "range"
	var/move_with_user = 0

/spell/aoe_turf/ring_of_fire/choose_targets(mob/user = usr)
	return trange(range, get_turf(user)) - trange(range - 1, get_turf(user))

/spell/aoe_turf/ring_of_fire/cast(list/targets, mob/user)

	if (user.is_pacified())
		return

	var/obj/effect/ring = new /obj/effect/ring_of_fire(get_turf(user), targets, duration)

	if(move_with_user)
		user.lock_atom(ring, /datum/locking_category/ring_of_fire)

	to_chat(user, "<span class='danger'>You summon a ring of fire around yourself.</span>")

	if(isliving(user))
		var/mob/living/L = user

		if(!L.mutations.Find(M_RESIST_HEAT) || !L.mutations.Find(M_UNBURNABLE))
			to_chat(L, "<span class='info'>You feel completely resistant to fire.</span>")

		L.mutations.Add(M_RESIST_HEAT, M_UNBURNABLE)
		L.update_mutations()

		spawn(duration)
			L.mutations.Remove(M_RESIST_HEAT, M_UNBURNABLE)
			L.update_mutations()

			if(!L.mutations.Find(M_UNBURNABLE))
				to_chat(L, "<span class='info'>You are no longer fully resistant to fire.</span>")

	..()

/spell/aoe_turf/ring_of_fire/apply_upgrade(upgrade_type)
	switch(upgrade_type)
		if(Sp_MOVE)
			spell_levels[Sp_MOVE]++
			move_with_user = 1
			desc = "Summon a ring of flames around yourself for 10 seconds. The ring moves together with you, and while it's active you are immune to fire and burns."
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

	var/list/processing_locking_cats = list()

	for(var/turf/T in locations)
		//Create the flames at their intended location
		var/obj/effect/fire_blast/ring_of_fire/F = new /obj/effect/fire_blast/ring_of_fire(T, fire_duration = duration)

		var/lock_id = "\ref[F]"
		var/datum/locking_category/ring_of_fire/locking_cat = add_lock_cat(/datum/locking_category/ring_of_fire, lock_id)
		//Lock_atom notes their intended location, and moves all of them to the caster's turf
		lock_atom(F, lock_id)

		processing_locking_cats.Add(locking_cat)

	//This subprocess moves all flames to their intended location
	spawn()
		while(processing_locking_cats.len)
			for(var/datum/locking_category/ring_of_fire/ROF in processing_locking_cats)
				if(ROF.x_offset == ROF.target_x_offset && ROF.y_offset == ROF.target_y_offset)
					processing_locking_cats.Remove(ROF)
					continue
				if(!ROF.locked || !ROF.locked.len || !ROF.owner || !ROF.owner.loc)
					processing_locking_cats.Remove(ROF)
					continue

				ROF.x_offset += sgn(ROF.target_x_offset - ROF.x_offset)
				ROF.y_offset += sgn(ROF.target_y_offset - ROF.y_offset)
				ROF.update_locks()

			sleep(5)

	spawn(duration)
		qdel(src)

/obj/effect/fire_blast/ring_of_fire
	fire_damage = 8
	spread = 0

/datum/locking_category/ring_of_fire
	var/target_x_offset
	var/target_y_offset

/datum/locking_category/ring_of_fire/lock(atom/movable/AM)
	target_x_offset = AM.x - owner.x
	target_y_offset = AM.y - owner.y
	x_offset = 0
	y_offset = 0

	..()
