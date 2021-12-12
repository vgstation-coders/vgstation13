
/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'
	var/health = 50
	var/maxHealth = 50
	var/sound_damaged = null
	var/sound_destroyed = null
	var/conceal_cooldown = 0
	var/timeleft = 0
	var/timetotal = 0
	var/list/contributors = list()//list of cultists currently participating in the ritual
	var/image/progbar = null//progress bar
	var/cancelling = 3//check to abort the ritual if interrupted
	var/custom_process = 0

/obj/structure/cult/proc/conceal()
	var/obj/structure/cult/concealed/C = new(loc)
	C.pixel_x = pixel_x
	C.pixel_y = pixel_y
	forceMove(C)
	C.held = src
	C.icon = icon
	C.icon_state = icon_state

/obj/structure/cult/proc/reveal()
	conceal_cooldown = 1
	spawn (100)
		if (src && loc)
			conceal_cooldown = 0

/obj/structure/cult/concealed
	density = 0
	anchored = 1
	alpha = 127
	invisibility = INVISIBILITY_OBSERVER
	var/obj/structure/cult/held = null

/obj/structure/cult/concealed/reveal()
	if (held)
		held.forceMove(loc)
		held.reveal()
		held = null
	qdel(src)

/obj/structure/cult/concealed/conceal()
	return

/obj/structure/cult/concealed/takeDamage(var/damage)
	return

//if you want indestructible buildings, just make a custom takeDamage() proc
/obj/structure/cult/proc/takeDamage(var/damage)
	health -= damage
	if (health <= 0)
		if (sound_destroyed)
			playsound(src, sound_destroyed, 100, 1)
		qdel(src)
	else
		update_icon()

//duh
/obj/structure/cult/cultify()
	return
/obj/structure/cult/clockworkify()
	return

//nuh-uh
/obj/structure/cult/acidable()
	return 0

/obj/structure/cult/ex_act(var/severity)
	switch(severity)
		if (1)
			takeDamage(100)
		if (2)
			takeDamage(20)
		if (3)
			takeDamage(4)

/obj/structure/cult/blob_act()
	playsound(src, sound_damaged, 75, 1)
	takeDamage(20)

/obj/structure/cult/bullet_act(var/obj/item/projectile/Proj)
	takeDamage(Proj.damage)
	return ..()

/obj/structure/cult/attackby(var/obj/item/weapon/W, var/mob/user, params)
	if (istype(W))
		if(user.a_intent == I_HELP || W.force == 0)
			visible_message("<span class='warning'>\The [user] gently taps \the [src] with \the [W].</span>")
		else
			user.delayNextAttack(8)
			user.do_attack_animation(src, W)
			if (W.hitsound)
				playsound(src, W.hitsound, 50, 1, -1)
			if (sound_damaged)
				playsound(src, sound_damaged, 75, 1)
			takeDamage(W.force)
			if (W.attack_verb)
				visible_message("<span class='warning'>\The [user] [pick(W.attack_verb)] \the [src] with \the [W].</span>")
			else
				visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W].</span>")
			..()


/obj/structure/cult/attack_paw(var/mob/user)
	return attack_hand(user)


/obj/structure/cult/attack_hand(var/mob/living/user)
	if(user.a_intent == I_HURT)
		user.delayNextAttack(8)
		user.visible_message("<span class='danger'>[user.name] [pick("kicks","punches")] \the [src]!</span>", \
							"<span class='danger'>You strike at \the [src]!</span>", \
							"You hear stone cracking.")
		takeDamage(user.get_unarmed_damage(src))
		if (sound_damaged)
			playsound(src, sound_damaged, 75, 1)
	else if(iscultist(user))
		cultist_act(user)
	else
		noncultist_act(user)

/obj/structure/cult/proc/cultist_act(var/mob/user)

	return 1

/obj/structure/cult/proc/noncultist_act(var/mob/user)
	to_chat(user,"<span class='sinister'>You feel madness taking its toll, trying to figure out \the [name]'s purpose</span>")
	//might add some hallucinations or brain damage later, checks for cultist chaplains, etc
	return 1

/obj/structure/cult/attack_construct(var/mob/user)
	if (!Adjacent(user))
		return 0
	if(istype(user,/mob/living/simple_animal/construct/builder))
		cultist_act(user)
		return 1
	return 0


/obj/structure/cult/beam_connect(var/obj/effect/beam/B)
	..()
	last_beamchecks["\ref[B]"]=world.time+1
	apply_beam_damage(B) // Contact damage for larger beams (deals 1/10th second of damage)
	if(!custom_process && !(src in processing_objects))
		processing_objects.Add(src)


/obj/structure/cult/beam_disconnect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)
	last_beamchecks.Remove("\ref[B]") // RIP
	if(beams.len == 0)
		if(!custom_process)
			processing_objects.Remove(src)

/obj/structure/cult/apply_beam_damage(var/obj/effect/beam/B)
	var/lastcheck=last_beamchecks["\ref[B]"]

	// Standard damage formula / 2
	var/damage = ((world.time - lastcheck)/10)  * (B.get_damage() / 20)

	// Actually apply damage
	takeDamage(damage)

	// Update check time.
	last_beamchecks["\ref[B]"]=world.time

/obj/structure/cult/handle_beams()
	// New beam damage code (per-tick)
	for(var/obj/effect/beam/B in beams)
		apply_beam_damage(B)

/obj/structure/cult/process()
	handle_beams()

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Spawned from the Raise Structure rune. Available from the beginning. Trigger progress to ACT I
//      CULT ALTAR       //Allows communication with Nar-Sie for advice and info on the Cult's current objective.
//                       //ACT II : Allows Soulstone crafting, Used to sacrifice the target on the Station
///////////////////////////ACT III : Can plant an empty Soul Blade in it to prompt observers to become the blade's shade
#define ALTARTASK_NONE	0
#define ALTARTASK_GEM	1
#define ALTARTASK_SACRIFICE	2

/obj/structure/cult/altar
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "altar"
	health = 100
	maxHealth = 100
	sound_damaged = 'sound/effects/stone_hit.ogg'
	sound_destroyed = 'sound/effects/stone_crumble.ogg'
	layer = TABLE_LAYER
	pass_flags_self = PASSTABLE
	var/obj/item/weapon/melee/soulblade/blade = null
	var/lock_type = /datum/locking_category/buckle/bed
	var/altar_task = ALTARTASK_NONE
	var/gem_delay = 300
	var/narsie_message_cooldown = 0

	var/list/watching_mobs = list()
	var/list/watcher_maps = list()
	var/datum/station_holomap/cult/holomap_datum


/obj/structure/cult/altar/New()
	..()
	flick("[icon_state]-spawn", src)
	var/image/I = image(icon, "altar_overlay")
	I.plane = relative_plane(ABOVE_HUMAN_PLANE)
	overlays.Add(I)
	for (var/mob/living/carbon/C in loc)
		Crossed(C)

	var/datum/holomap_marker/holomarker = new()
	holomarker.id = HOLOMAP_MARKER_CULT_ALTAR
	holomarker.filter = HOLOMAP_FILTER_CULT
	holomarker.x = src.x
	holomarker.y = src.y
	holomarker.z = src.z
	holomap_markers[HOLOMAP_MARKER_CULT_ALTAR+"_\ref[src]"] = holomarker

	holomap_datum = new
	holomap_datum.initialize_holomap(get_turf(src), cursor_icon = "altar-here")


/obj/structure/cult/altar/Destroy()

	stopWatching()
	if (blade)
		if (loc)
			blade.forceMove(loc)
		else
			qdel(blade)
	blade = null
	flick("[icon_state]-break", src)

	holomap_markers -= HOLOMAP_MARKER_CULT_ALTAR+"_\ref[src]"

	..()

/obj/structure/cult/altar/attackby(var/obj/item/I, var/mob/user, params)
	if (altar_task)
		return ..()
	if(istype(I,/obj/item/weapon/melee/soulblade) || (istype(I,/obj/item/weapon/melee/cultblade) && !istype(I,/obj/item/weapon/melee/cultblade/nocult)))
		if (blade)
			to_chat(user,"<span class='warning'>You must remove \the [blade] planted into \the [src] first.</span>")
			return 1
		var/turf/T = get_turf(user)
		playsound(T, 'sound/weapons/bloodyslice.ogg', 50, 1)
		user.drop_item(I, T, 1)
		I.forceMove(src)
		blade = I
		update_icon()
		var/mob/living/carbon/human/C = locate() in loc
		if (C && C.resting)
			C.unlock_from()
			C.update_canmove()
			lock_atom(C, lock_type)
			C.apply_damage(blade.force, BRUTE, LIMB_CHEST)
			if (C == user)
				user.visible_message("<span class='danger'>\The [user] holds \the [I] above their stomach and impales themselves on \the [src]!</span>","<span class='danger'>You hold \the [I] above your stomach and impale yourself on \the [src]!</span>")
			else
				user.visible_message("<span class='danger'>\The [user] holds \the [I] above \the [C]'s stomach and impales them on \the [src]!</span>","<span class='danger'>You hold \the [I] above \the [C]'s stomach and impale them on \the [src]!</span>")
		else
			to_chat(user, "You plant \the [blade] on top of \the [src]</span>")
			if (istype(blade) && !blade.shade)
				var/icon/logo_icon = icon('icons/logos.dmi', "shade-blade")
				for(var/mob/M in observers)
					if(!M.client || isantagbanned(M) || jobban_isbanned(M, CULTIST) || M.client.is_afk())
						continue
					if (iscultist(M))
						var/datum/role/cultist/cultist = iscultist(M)
						if (cultist.second_chance)
							to_chat(M, "[bicon(logo_icon)]<span class='recruit'>\The [user] has planted a Soul Blade on an altar, opening a small crack in the veil that allows you to become the blade's resident shade. (<a href='?src=\ref[src];signup=\ref[M]'>Possess now!</a>)</span>[bicon(logo_icon)]")
		return 1
	if (istype(I, /obj/item/weapon/grab))
		if (blade)
			to_chat(user,"<span class='warning'>You must remove \the [blade] planted on \the [src] first.</span>")
			return 1
		var/obj/item/weapon/grab/G = I
		if(iscarbon(G.affecting))
			if (blade)
				to_chat(user,"<span class='warning'>You must remove \the [blade] planted on \the [src] first.</span>")
				return 1
			var/mob/living/carbon/C = G.affecting
			C.unlock_from()
			if (!do_after(user,C,15))
				return
			if (ishuman(C))
				C.resting = 1
				C.update_canmove()
			C.forceMove(loc)
			qdel(G)
			to_chat(user, "<span class='warning'>You move \the [C] on top of \the [src]</span>")
			return 1
	if(user.drop_item(I, loc))
		if((I.loc == loc) && params)
			I.setPixelOffsetsFromParams(params, user, pixel_x, pixel_y)
			return 1
	..()

/obj/structure/cult/altar/update_icon()
	icon_state = "altar"
	overlays.len = 0
	if (blade)
		var/image/I
		if (!istype(blade))
			I = image(icon, "altar-cultblade")
		else if (blade.shade)
			I = image(icon, "altar-soulblade-full")
		else
			I = image(icon, "altar-soulblade")
		I.plane = relative_plane(ABOVE_HUMAN_PLANE)
		I.pixel_y = 3
		overlays.Add(I)
	var/image/I = image(icon, "altar_overlay")
	I.plane = relative_plane(ABOVE_HUMAN_PLANE)
	overlays.Add(I)

	if (health < maxHealth/3)
		overlays.Add("altar_damage2")
	else if (health < 2*maxHealth/3)
		overlays.Add("altar_damage1")

//We want people on top of the altar to appear slightly higher
/obj/structure/cult/altar/Crossed(var/atom/movable/mover)
	if (iscarbon(mover))
		mover.pixel_y += 7 * PIXEL_MULTIPLIER

/obj/structure/cult/altar/Uncrossed(var/atom/movable/mover)
	if (iscarbon(mover))
		mover.pixel_y -= 7 * PIXEL_MULTIPLIER

//They're basically the height of regular tables
/obj/structure/cult/altar/Cross(var/atom/movable/mover, var/turf/target, var/height=1.5, var/air_group = 0)
	if(air_group || (height==0))
		return 1

	if(ismob(mover))
		var/mob/M = mover
		if(M.flying)
			return 1
	if(istype(mover) && mover.checkpass(pass_flags_self))
		return 1
	else
		return 0

/obj/structure/cult/altar/MouseDropTo(var/atom/movable/O, var/mob/user)
	if (altar_task)
		return
	if (!istype(O))
		return
	if(user.incapacitated() || user.lying)
		return
	if(O.anchored || !Adjacent(user) || !user.Adjacent(O))
		return
	if (user.get_active_hand() == O)
		if(!user.drop_item(O))
			return
	else
		if(!ismob(O))
			return
		if(O.loc == user || !isturf(O.loc) || !isturf(user.loc))
			return
		if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon))
			return
		var/mob/living/L = O
		if(!istype(L) || L.locked_to || L == user)
			return
		if (blade)
			to_chat(user,"<span class='warning'>You must remove \the [blade] planted on \the [src] first.</span>")
			return 1
		var/mob/living/carbon/C = O

		if (!do_after(user,C,15))
			return
		C.unlock_from()

		if (ishuman(C))
			C.resting = 1
			C.update_canmove()

		add_fingerprint(C)

	O.forceMove(loc)
	to_chat(user, "<span class='warning'>You move \the [O] on top of \the [src]</span>")
	return 1


/obj/structure/cult/altar/proc/checkPosition()
	for(var/mob/M in watching_mobs)
		if(get_dist(src,M) > 1)
			stopWatching(M)

/obj/structure/cult/altar/proc/stopWatching(var/mob/user)
	if(!user)
		for(var/mob/M in watching_mobs)
			if(M.client)
				spawn(5)//we give it time to fade out
					M.client.images -= watcher_maps["\ref[M]"]
				M.unregister_event(/event/face, src, /obj/structure/cult/altar/proc/checkPosition)
				animate(watcher_maps["\ref[M]"], alpha = 0, time = 5, easing = LINEAR_EASING)

		watching_mobs = list()
	else
		if(user.client)
			spawn(5)//we give it time to fade out
				if(!(user in watching_mobs))
					user.client.images -= watcher_maps["\ref[user]"]
					watcher_maps -= "\ref[user]"
			user.unregister_event(/event/face, src, /obj/structure/cult/altar/proc/checkPosition)
			animate(watcher_maps["\ref[user]"], alpha = 0, time = 5, easing = LINEAR_EASING)

			watching_mobs -= user

/obj/structure/cult/altar/conceal()
	if (blade || altar_task)
		return
	anim(location = loc,target = loc,a_icon = icon, flick_anim = "[icon_state]-conceal")
	for (var/mob/living/carbon/C in loc)
		Uncrossed(C)
	..()

/obj/structure/cult/altar/reveal()
	flick("[icon_state]-spawn", src)
	..()
	for (var/mob/living/carbon/C in loc)
		Crossed(C)

/obj/structure/cult/altar/cultist_act(var/mob/user,var/menu="default")
	.=..()
	if (!.)
		return
	if(user in watching_mobs)
		stopWatching(user)
		return
	if (altar_task)
		switch (altar_task)
			if (ALTARTASK_GEM)
				to_chat(user, "<span class='warning'>You must wait before the Altar's current task is over.</span>")
			if (ALTARTASK_SACRIFICE)
				if (user in contributors)
					return
				if (!user.checkTattoo(TATTOO_SILENT))
					if (prob(5))
						user.say("Let me show you the dance of my people!","C")
					else
						user.say("Barhah hra zar'garis!","C")
				contributors.Add(user)
				if (user.client)
					user.client.images |= progbar
		return
	if(is_locking(lock_type))
		var/mob/M = get_locked(lock_type)[1]
		if(M != user)
			if (do_after(user,src,20))
				M.visible_message("<span class='notice'>\The [M] was freed from \the [src] by \the [user]!</span>","You were freed from \the [src] by \the [user].")
				unlock_atom(M)
				if (blade)
					blade.forceMove(loc)
					blade.attack_hand(user)
					to_chat(user, "<span class='warning'>You remove \the [blade] from \the [src]</span>")
					blade = null
					playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
					update_icon()
		// TODO UPHEAVAL PART 2, might bring back sacrifices later, for now you can still stab people on altars
		/*
		var/choices = list(
			list("Remove Blade", "radial_altar_remove", "Pull the blade off, freeing the victim."),
			list("Sacrifice", "radial_altar_sacrifice", "Initiate the sacrifice ritual. The ritual can only proceed if the proper victim has been nailed to the altar."),
			)
		var/task = show_radial_menu(user,loc,choices,'icons/obj/cult_radial3.dmi',"radial-cult2")
		if (!is_locking(lock_type) || !Adjacent(user) || !task)
			return
		switch (task)
			if ("Remove Blade")
				var/mob/M = get_locked(lock_type)[1]
				if(M != user)
					if (do_after(user,src,20))
						M.visible_message("<span class='notice'>\The [M] was freed from \the [src] by \the [user]!</span>","You were freed from \the [src] by \the [user].")
						unlock_atom(M)
						if (blade)
							blade.forceMove(loc)
							blade.attack_hand(user)
							to_chat(user, "<span class='warning'>You remove \the [blade] from \the [src]</span>")
							blade = null
							playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
							update_icon()
			if ("Sacrifice")
				// First we'll check for any blockers around it since we'll dance using forceMove to allow up to 8 dancers without them bumping into each others
				// Of course this means that walls and objects placed AFTER the start of the dance can be crossed by dancing but that's good enough.
				for (var/turf/T in orange(1,src))
					if (T.density)
						to_chat(user, "<span class='warning'>The [T] would hinder the ritual. Either dismantle it or use an altar located in a more spacious area.</span>")
						return
					var/atom/A = T.has_dense_content()
					if (A && (A != src) && !ismob(A)) // mobs get a free pass
						to_chat(user, "<span class='warning'>\The [A] would hinder the ritual. Either move it or use an altar located in a more spacious area.</span>")
						return
				var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
				if (cult)
					if (is_locking(lock_type))
						altar_task = ALTARTASK_SACRIFICE
						timeleft = 30
						timetotal = timeleft
						update_icon()
						contributors.Add(user)
						update_progbar()
						if (user.client)
							user.client.images |= progbar
						var/image/I = image('icons/obj/cult.dmi',"build")
						I.pixel_y = 8
						src.overlays += I
						if (!user.checkTattoo(TATTOO_SILENT))
							if (prob(5))
								user.say("Let me show you the dance of my people!","C")
							else
								user.say("Barhah hra zar'garis!","C")
						if (user.client)
							user.client.images |= progbar
							/*
						for(var/mob/M in range(src,40))
							if (M.z == z && M.client)
								if (get_dist(M,src)<=20)
									M.playsound_local(src, get_sfx("explosion"), 50, 1)
									shake_camera(M, 2, 1)
								else
									M.playsound_local(src, 'sound/effects/explosionfar.ogg', 50, 1)
									shake_camera(M, 1, 1)
									*/
						spawn()
							dance_start()
			*/
	else if (blade)
		blade.forceMove(loc)
		blade.attack_hand(user)
		to_chat(user, "You remove \the [blade] from \the [src]</span>")
		blade = null
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
		update_icon()
		return
	else
		var/choices = list(
			list("Consult Roster", "radial_altar_roster", "Check the names and status of all of the cult's members."),
			list("Look through Veil", "radial_altar_map", "Check the veil for tears to locate other occult constructions."),
			list("Commune with Nar-Sie", "radial_altar_commune", "Make contact with Nar-Sie."),
			list("Conjure Soul Gem", "radial_altar_gem", "Order the altar to sculpt you a Soul Gem, to capture the soul of your enemies."),
			)
		var/task = show_radial_menu(user,loc,choices,'icons/obj/cult_radial3.dmi',"radial-cult2")
		if (is_locking(lock_type) || !Adjacent(user) || !task)
			return
		switch (task)
			if ("Consult Roster")
				var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
				if (!cult)
					return
				var/dat = {"<body style="color:#FFFFFF" bgcolor="#110000">"}
				dat += "<b>Our cult can currently grow up to [cult.cultist_cap] members.</b>"
				dat += "<ul>"
				for (var/datum/role/cultist/C in cult.members)
					var/datum/mind/M = C.antag
					var/conversion = ""
					var/cult_role = ""
					switch (C.cultist_role)
						if (CULTIST_ROLE_ACOLYTE)
							cult_role = "Acolyte"
						if (CULTIST_ROLE_MENTOR)
							cult_role = "Mentor"
						else
							cult_role = "Herald"
					if (C.conversion.len > 0)
						conversion = pick(C.conversion)
					var/origin_text = ""
					switch (conversion)
						if ("converted")
							origin_text = "Converted by [C.conversion[conversion]]"
						if ("resurrected")
							origin_text = "Resurrected by [C.conversion[conversion]]"
						if ("soulstone")
							origin_text = "Soul captured by [C.conversion[conversion]]"
						if ("altar")
							origin_text = "Volunteer shade"
						if ("sacrifice")
							origin_text = "Sacrifice"
						else
							origin_text = "Founder"
					var/mob/living/carbon/H = C.antag.current
					var/extra = ""
					if (H && istype(H))
						if (H.isInCrit())
							extra = " - <span style='color:#FFFF00'>CRITICAL</span>"
						else if (H.isDead())
							extra = " - <span style='color:#FF0000'>DEAD</span>"
					dat += "<li><b>[M.name] ([cult_role])</b></li> - [origin_text][extra]"
				for(var/obj/item/weapon/handcuffs/cult/cuffs in cult.bindings)
					if (iscarbon(cuffs.loc))
						var/mob/living/carbon/C = cuffs.loc
						if (C.handcuffed == cuffs && cuffs.gaoler && cuffs.gaoler.antag)
							var/datum/mind/gaoler = cuffs.gaoler.antag
							var/extra = ""
							if (C && istype(C))
								if (C.isInCrit())
									extra = " - <span style='color:#FFFF00'>CRITICAL</span>"
								else if (C.isDead())
									extra = " - <span style='color:#FF0000'>DEAD</span>"
							dat += "<li><span style='color:#FFFF00'><b>[C.real_name]</b></span></li> - Prisoner of [gaoler.name][extra]"
				dat += {"</ul></body>"}
				user << browse("<TITLE>Cult Roster</TITLE>[dat]", "window=cultroster;size=600x400")
				onclose(user, "cultroster")
			if ("Look through Veil")
				if(user.hud_used && user.hud_used.holomap_obj)
					if(!("\ref[user]" in watcher_maps))
						var/image/personnal_I = prepare_cult_holomap()
						var/turf/T = get_turf(src)
						if(map.holomap_offset_x.len >= T.z)
							holomap_datum.cursor.pixel_x = (T.x-8+map.holomap_offset_x[T.z])*PIXEL_MULTIPLIER
							holomap_datum.cursor.pixel_y = (T.y-8+map.holomap_offset_y[T.z])*PIXEL_MULTIPLIER
						else
							holomap_datum.cursor.pixel_x = (T.x-8)*PIXEL_MULTIPLIER
							holomap_datum.cursor.pixel_y = (T.y-8)*PIXEL_MULTIPLIER
						if (T.z == map.zMainStation)
							personnal_I.overlays += holomap_datum.cursor
						watcher_maps["\ref[user]"] = personnal_I
					var/image/I = watcher_maps["\ref[user]"]
					I.loc = user.hud_used.holomap_obj
					I.alpha = 0
					animate(watcher_maps["\ref[user]"], alpha = 255, time = 5, easing = LINEAR_EASING)
					watching_mobs |= user
					user.client.images |= watcher_maps["\ref[user]"]
					user.register_event(/event/face, src, /obj/structure/cult/altar/proc/checkPosition)
			if ("Commune with Nar-Sie")
				if(narsie_message_cooldown)
					to_chat(user, "<span class='warning'>This altar has already sent a message in the past 30 seconds, wait a moment.</span>")
					return
				var/input = stripped_input(user, "Please choose a message to transmit to Nar-Sie through the veil. Know that he can be fickle, and abuse of this ritual will leave your body asunder. Communion does not guarantee a response. There is a 30 second delay before you may commune again, be clear, full and concise.", "To abort, send an empty message.", "")
				if(!input || !Adjacent(user))
					return
				NarSie_announce(input, usr)
				to_chat(usr, "<span class='notice'>Your communion has been received.</span>")
				var/turf/T = get_turf(usr)
				log_say("[key_name(usr)] (@[T.x],[T.y],[T.z]) has communed with Nar-Sie: [input]")
				narsie_message_cooldown = 1
				spawn(30 SECONDS)
					narsie_message_cooldown = 0
			if ("Conjure Soul Gem")
				altar_task = ALTARTASK_GEM
				update_icon()
				overlays += "altar-soulstone1"
				spawn (gem_delay/3)
					update_icon()
					overlays += "altar-soulstone2"
					sleep (gem_delay/3)
					update_icon()
					overlays += "altar-soulstone3"
					sleep (gem_delay/3)
					altar_task = ALTARTASK_NONE
					update_icon()
					var/obj/item/soulstone/gem/gem = new (loc)
					gem.pixel_y = 4

/obj/structure/cult/altar/noncultist_act(var/mob/user)//Non-cultists can still remove blades planted on altars.
	if(is_locking(lock_type))
		var/mob/M = get_locked(lock_type)[1]
		if(M != user)
			if (do_after(user,src,20))
				M.visible_message("<span class='notice'>\The [M] was freed from \the [src] by \the [user]!</span>","You were freed from \the [src] by \the [user].")
				unlock_atom(M)
				if (blade)
					blade.forceMove(loc)
					blade.attack_hand(user)
					to_chat(user, "You remove \the [blade] from \the [src]</span>")
					blade = null
					playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
					update_icon()
	else if (blade)
		blade.forceMove(loc)
		blade.attack_hand(user)
		to_chat(user, "You remove \the [blade] from \the [src]</span>")
		blade = null
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
		update_icon()
		return
	else
		to_chat(user,"<span class='sinister'>You feel madness taking its toll, trying to figure out \the [name]'s purpose.</span>")
	return 1



/obj/structure/cult/altar/Topic(href, href_list)
	if(href_list["signup"])
		var/mob/M = usr
		if(!isobserver(M) || !iscultist(M))
			return
		var/mob/dead/observer/O = M
		var/obj/item/weapon/melee/soulblade/blade = locate() in src
		if (!istype(blade))
			to_chat(usr, "<span class='warning'>The blade was removed from \the [src].</span>")
			return
		if (blade.shade)
			to_chat(usr, "<span class='warning'>Another shade was faster, and is currently possessing \the [blade].</span>")
			return
		var/mob/living/simple_animal/shade/shadeMob = new(blade)
		blade.shade = shadeMob
		shadeMob.status_flags |= GODMODE
		shadeMob.canmove = 0
		var/datum/role/cultist/cultist = iscultist(M)
		cultist.second_chance = 0
		shadeMob.real_name = M.mind.name
		shadeMob.name = "[shadeMob.real_name] the Shade"
		M.mind.transfer_to(shadeMob)
		O.can_reenter_corpse = 1
		O.reenter_corpse()

		/* Only cultists get brought back this way now, so let's assume they kept their identity.
		spawn()
			var/list/shade_names = list("Orenmir","Felthorn","Sparda","Vengeance","Klinge")
			shadeMob.real_name = pick(shade_names)
			shadeMob.real_name = copytext(sanitize(input(shadeMob, "You have no memories of your previous life, if you even had one. What name will you give yourself?", "Give yourself a new name", "[shadeMob.real_name]") as null|text),1,MAX_NAME_LEN)
			shadeMob.name = "[shadeMob.real_name] the Shade"
			if (shadeMob.mind)
				shadeMob.mind.name = shadeMob.real_name
		*/
		shadeMob.cancel_camera()
		shadeMob.give_blade_powers()
		blade.dir = NORTH
		blade.update_icon()
		update_icon()
		//Automatically makes them cultists
		var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
		if (!cult)
			cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
		var/datum/role/cultist/newCultist = cult.HandleRecruitedMind(shadeMob.mind, TRUE)
		newCultist.Greet(GREET_SOULBLADE)
		newCultist.conversion.Add("altar")


/obj/structure/cult/altar/dance_start()//This is executed at the end of the sacrifice ritual
	//var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	//if (cult)
	//	cult.change_cooldown = max(cult.change_cooldown,60 SECONDS)
	. = ..()//true if the ritual was successful
	altar_task = ALTARTASK_NONE
	update_icon()
	if (. &&  is_locking(lock_type))
		var/mob/M = get_locked(lock_type)[1]

		if (istype(blade) && !blade.shade)//If an empty soul blade was the tool used for the ritual, let's make them its shade.
			var/mob/living/simple_animal/shade/new_shade = M.change_mob_type( /mob/living/simple_animal/shade , null, null, 1 )
			blade.forceMove(loc)
			blade.blood = blade.maxblood
			new_shade.forceMove(blade)
			blade.shade = new_shade
			blade.update_icon()
			blade = null
			for(var/mob/living/L in dview(world.view, loc, INVISIBILITY_MAXIMUM))
				if (L.client)
					L.playsound_local(loc, 'sound/effects/convert_failure.ogg', 75, 0, -4)
			playsound(loc, get_sfx("soulstone"), 50,1)
			var/obj/effect/cult_ritual/conversion/anim = new(loc)
			anim.icon_state = ""
			flick("rune_convert_refused",anim)
			anim.Die()

			if (!iscultist(new_shade))
				var/datum/role/cultist/newCultist = new
				newCultist.AssignToRole(new_shade.mind,1)
				var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
				if (!cult)
					cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
				cult.HandleRecruitedRole(newCultist)
				newCultist.OnPostSetup()
				newCultist.Greet(GREET_SACRIFICE)
				newCultist.conversion.Add("sacrifice")

			new_shade.status_flags |= GODMODE
			new_shade.canmove = 0
			new_shade.name = "[M.real_name] the Shade"
			new_shade.real_name = "[M.real_name]"
			new_shade.give_blade_powers()
			playsound(src, get_sfx("soulstone"), 50,1)
		else
			M.gib()

#undef ALTARTASK_NONE
#undef ALTARTASK_GEM
#undef ALTARTASK_SACRIFICE

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Spawned from the Raise Structure rune. Available from Act II, upgrades at each subsequent Act
//      CULT SPIRE       //Can be used by cultists to acquire arcane tattoos. One of each tier.
//                       //
///////////////////////////
var/list/cult_spires = list()

/obj/structure/cult/spire
	name = "spire"
	desc = "A blood-red needle surrounded by dangerous looking...teeth?."
	icon = 'icons/obj/cult_64x64.dmi'
	icon_state = ""
	health = 100
	maxHealth = 100
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -4 * PIXEL_MULTIPLIER
	sound_damaged = 'sound/effects/stone_hit.ogg'
	sound_destroyed = 'sound/effects/stone_crumble.ogg'
	plane = EFFECTS_PLANE
	layer = BELOW_PROJECTILE_LAYER
	light_color = "#FF0000"
	var/stage = 1

/obj/structure/cult/spire/New()
	..()
	cult_spires += src
	set_light(1)
	//TODO (UPHEAVAL PART 2) appearance changes with cult score
	stage = 1
	flick("spire[stage]-spawn",src)
	spawn(10)
		update_stage()

	var/datum/holomap_marker/holomarker = new()
	holomarker.id = HOLOMAP_MARKER_CULT_SPIRE
	holomarker.filter = HOLOMAP_FILTER_CULT
	holomarker.x = src.x
	holomarker.y = src.y
	holomarker.z = src.z
	holomap_markers[HOLOMAP_MARKER_CULT_SPIRE+"_\ref[src]"] = holomarker

/obj/structure/cult/spire/Destroy()
	cult_spires -= src
	holomap_markers -= HOLOMAP_MARKER_CULT_SPIRE+"_\ref[src]"
	..()

/obj/structure/cult/spire/proc/upgrade()
	var/new_stage = clamp(stage, 1, 3)
	if (new_stage>stage)
		stage = new_stage
		alpha = 255
		overlays.len = 0
		color = null
		flick("spire[new_stage]-morph", src)
		spawn(3)
			update_stage()

/obj/structure/cult/spire/proc/update_stage()
	animate(src, alpha = 128, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)
	animate(alpha = 144, color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)
	animate(alpha = 160, color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)
	animate(alpha = 176, color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)
	animate(alpha = 192, color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)
	animate(alpha = 208, color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 224, color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 240, color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 255, color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)
	animate(alpha = 240, color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 224, color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 208, color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 192, color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 176, color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 160, color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)
	animate(alpha = 144, color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)
	overlays.len = 0
	var/image/I_base = image('icons/obj/cult_64x64.dmi',"spire[stage]")
	I_base.plane = relative_plane(EFFECTS_PLANE)
	I_base.layer = BELOW_PROJECTILE_LAYER
	I_base.appearance_flags |= RESET_COLOR//we don't want the stone to pulse
	var/image/I_spire = image('icons/obj/cult_64x64.dmi',"spire[stage]-light")
	I_spire.plane = ABOVE_LIGHTING_PLANE
	I_spire.layer = NARSIE_GLOW
	overlays += I_base
	overlays += I_spire


/obj/structure/cult/spire/conceal()
	overlays.len = 0
	kill_light()
	anim(location = loc,target = loc,a_icon = 'icons/obj/cult_64x64.dmi', flick_anim = "spire[stage]-conceal", lay = BELOW_PROJECTILE_LAYER, offX = pixel_x, offY = pixel_y, plane = EFFECTS_PLANE)
	..()
	var/obj/structure/cult/concealed/C = loc
	if (istype(C))
		C.icon_state = "spire[stage]"

/obj/structure/cult/spire/reveal()
	..()
	set_light(1)
	flick("spire[stage]-spawn", src)
	animate(src)
	alpha = 255
	color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0)
	spawn(10)
		update_stage()


/obj/structure/cult/spire/cultist_act(var/mob/user,var/menu="default")
	.=..()
	if (!.)
		return

	// For now spires work as cult telecomms relay. Might give them another role later, maybe soul gem production instead of altars

	/*
	if (!ishuman(user))
		to_chat(user,"<span class='warning'>Only humans can bear the arcane markings granted by this [name].</span>")
		return

	var/mob/living/carbon/human/H = user
	var/datum/role/cultist/C = iscultist(H)

	var/list/available_tattoos = list("tier1","tier2","tier3")
	for (var/tattoo in C.tattoos)
		var/datum/cult_tattoo/CT = C.tattoos[tattoo]
		available_tattoos -= "tier[CT.tier]"

	var/tattoo_tier = 0
	if (available_tattoos.len <= 0)
		to_chat(user,"<span class='warning'>You cannot bear any additional mark.</span>")
		return
	if ("tier1" in available_tattoos)
		tattoo_tier = 1
	else if ("tier2" in available_tattoos)
		tattoo_tier = 2
	else if ("tier3" in available_tattoos)
		tattoo_tier = 3

	if (!tattoo_tier)
		return

	var/list/choices = list()
	if (stage >= tattoo_tier)
		for (var/subtype in subtypesof(/datum/cult_tattoo))
			var/datum/cult_tattoo/T = new subtype
			if (T.tier == tattoo_tier)
				choices += list(list(T.name, "radial_[T.icon_state]", T.desc)) //According to BYOND docs, when adding to a list, "If an argument is itself a list, each item in the list will be added." My solution to that, because I am a genius, is to add a list within a list.
				to_chat(H, "<span class='danger'>[T.name]</span>: [T.desc]")
	else
		to_chat(user,"<span class='warning'>Come back to acquire another mark once your cult is a step closer to its goal.</span>")
		return

	var/tattoo = show_radial_menu(user,loc,choices,'icons/obj/cult_radial2.dmi',"radial-cult2")//spawning on loc so we aren't offset by pixel_x/pixel_y, or affected by animate()

	for (var/tat in C.tattoos)
		var/datum/cult_tattoo/CT = C.tattoos[tat]
		if (CT.tier == tattoo_tier)//the spire won't let cultists get multiple tattoos of the same tier.
			return

	if (!Adjacent(user))//stay here you bloke!
		return

	for (var/subtype in subtypesof(/datum/cult_tattoo))
		var/datum/cult_tattoo/T = new subtype
		if (T.name == tattoo)
			var/datum/cult_tattoo/new_tattoo = T
			C.tattoos[new_tattoo.name] = new_tattoo

			anim(target = loc, a_icon = 'icons/effects/32x96.dmi', flick_anim = "tattoo_send", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
			spawn (3)
				C.update_cult_hud()
				new_tattoo.getTattoo(H)
				anim(target = H, a_icon = 'icons/effects/32x96.dmi', flick_anim = "tattoo_receive", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
				sleep(1)
				H.update_mutations()
				var/atom/movable/overlay/tattoo_markings = anim(target = H, a_icon = 'icons/mob/cult_tattoos.dmi', flick_anim = "[new_tattoo.icon_state]_mark", sleeptime = 30, lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
				animate(tattoo_markings, alpha = 0, time = 30)

			available_tattoos -= "tier[new_tattoo.tier]"
			if (available_tattoos.len > 0)
				cultist_act(user)
			break
	*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Spawned from the Raise Structure rune. Available from Act II
//      CULT FORGE       //Also a source of heat
//                       //
///////////////////////////


/obj/structure/cult/forge
	name = "forge"
	desc = "Molten rocks flow down its cracks producing a searing heat, better not stand too close for long."
	icon = 'icons/obj/cult_64x64.dmi'
	icon_state = ""
	health = 100
	maxHealth = 100
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -16 * PIXEL_MULTIPLIER
	sound_damaged = 'sound/effects/stone_hit.ogg'
	sound_destroyed = 'sound/effects/stone_crumble.ogg'
	plane = EFFECTS_PLANE
	layer = BELOW_PROJECTILE_LAYER
	light_color = LIGHT_COLOR_ORANGE
	custom_process = 1
	var/heating_power = 40000
	var/set_temperature = 50
	var/mob/forger = null
	var/template = null
	var/obj/effect/cult_ritual/forge/forging = null


/obj/structure/cult/forge/New()
	..()
	processing_objects.Add(src)
	set_light(2)
	flick("forge-spawn",src)
	spawn(10)
		setup_overlays()

	var/datum/holomap_marker/holomarker = new()
	holomarker.id = HOLOMAP_MARKER_CULT_FORGE
	holomarker.filter = HOLOMAP_FILTER_CULT
	holomarker.x = src.x
	holomarker.y = src.y
	holomarker.z = src.z
	holomap_markers[HOLOMAP_MARKER_CULT_FORGE+"_\ref[src]"] = holomarker

/obj/structure/cult/forge/Destroy()
	if (forging)
		qdel(forging)
	forging = null
	forger = null
	processing_objects.Remove(src)
	holomap_markers -= HOLOMAP_MARKER_CULT_FORGE+"_\ref[src]"
	..()

/obj/structure/cult/forge/proc/setup_overlays()
	animate(src, alpha = 255, time = 10, loop = -1)
	animate(alpha = 240, time = 2)
	animate(alpha = 224, time = 2)
	animate(alpha = 208, time = 1.5)
	animate(alpha = 192, time = 1.5)
	animate(alpha = 176, time = 1)
	animate(alpha = 160, time = 1)
	animate(alpha = 144, time = 1)
	animate(alpha = 128, time = 3)
	animate(alpha = 144, time = 1)
	animate(alpha = 160, time = 1)
	animate(alpha = 176, time = 1)
	animate(alpha = 192, time = 1.5)
	animate(alpha = 208, time = 1.5)
	animate(alpha = 224, time = 2)
	animate(alpha = 240, time = 2)
	overlays.len = 0
	var/image/I_base = image('icons/obj/cult_64x64.dmi',"forge")
	I_base.plane = relative_plane(EFFECTS_PLANE)
	I_base.layer = BELOW_PROJECTILE_LAYER
	I_base.appearance_flags |= RESET_ALPHA //we don't want the stone to pulse
	var/image/I_lave = image('icons/obj/cult_64x64.dmi',"forge-lightmask")
	I_lave.plane = ABOVE_LIGHTING_PLANE
	I_lave.layer = NARSIE_GLOW
	I_lave.blend_mode = BLEND_ADD
	overlays += I_base
	overlays += I_lave

/obj/structure/cult/forge/process()
	..()
	if (isturf(loc))
		var/turf/simulated/L = loc
		if(istype(L))
			L.hotspot_expose(TEMPERATURE_FLAME, 125, surfaces = 1)//we start fires in plasma atmos
			var/datum/gas_mixture/env = L.return_air()
			if (env.total_moles > 0)//we cannot manipulate temperature in a vacuum
				if(env.temperature != set_temperature + T0C)
					var/datum/gas_mixture/removed = env.remove_volume(0.5 * CELL_VOLUME)
					if(removed)
						var/heat_capacity = removed.heat_capacity()
						if(heat_capacity)
							if(removed.temperature < set_temperature + T0C)
								removed.temperature = min(removed.temperature + heating_power/heat_capacity, 1000)
					env.merge(removed)
		if(!istype(loc,/turf/space))
			for (var/mob/living/carbon/M in view(src,3))
				M.bodytemperature += (6-round(M.get_cult_power()/30))/((get_dist(src,M)+1))//cult gear reduces the heat buildup
		if (forging)
			if (forger)
				if (!Adjacent(forger))
					if (forger.client)
						forger.client.images -= progbar
					forger = null
					return
				else
					timeleft--
					update_progbar()
					if (timeleft<=0)
						playsound(L, 'sound/effects/forge_over.ogg', 50, 0, -3)
						if (forger.client)
							forger.client.images -= progbar
						qdel(forging)
						forging = null
						var/obj/item/I = new template(L)
						if (istype(I))
							I.plane = relative_plane(EFFECTS_PLANE)
							I.layer = PROJECTILE_LAYER
							I.pixel_y = 12
						else
							I.forceMove(get_turf(forger))
						forger = null
						template = null
					else
						anim(target = loc, a_icon = 'icons/obj/cult_64x64.dmi', flick_anim = "forge-work", lay = NARSIE_GLOW, offX = pixel_x, offY = pixel_y, plane = ABOVE_LIGHTING_PLANE)
						playsound(L, 'sound/effects/forge.ogg', 50, 0, -4)
						forging.overlays.len = 0
						var/image/I = image('icons/obj/cult_64x64.dmi',"[forging.icon_state]-mask")
						I.plane = ABOVE_LIGHTING_PLANE
						I.layer = NARSIE_GLOW
						I.blend_mode = BLEND_ADD
						I.alpha = (timeleft/timetotal)*255
						forging.overlays += I



/obj/structure/cult/forge/conceal()
	overlays.len = 0
	kill_light()
	anim(location = loc,target = loc,a_icon = 'icons/obj/cult_64x64.dmi', flick_anim = "forge-conceal", lay = BELOW_PROJECTILE_LAYER, offX = pixel_x, offY = pixel_y, plane = EFFECTS_PLANE)
	..()
	var/obj/structure/cult/concealed/C = loc
	if (istype(C))
		C.icon_state = "forge"

/obj/structure/cult/forge/reveal()
	..()
	animate(src)
	alpha = 255
	set_light(2)
	flick("forge-spawn", src)
	spawn(10)
		animate(src, alpha = 255, time = 10, loop = -1)
		animate(alpha = 240, time = 2)
		animate(alpha = 224, time = 2)
		animate(alpha = 208, time = 1.5)
		animate(alpha = 192, time = 1.5)
		animate(alpha = 176, time = 1)
		animate(alpha = 160, time = 1)
		animate(alpha = 144, time = 1)
		animate(alpha = 128, time = 3)
		animate(alpha = 144, time = 1)
		animate(alpha = 160, time = 1)
		animate(alpha = 176, time = 1)
		animate(alpha = 192, time = 1.5)
		animate(alpha = 208, time = 1.5)
		animate(alpha = 224, time = 2)
		animate(alpha = 240, time = 2)
		var/image/I_base = image('icons/obj/cult_64x64.dmi',"forge")
		I_base.plane = relative_plane(EFFECTS_PLANE)
		I_base.layer = BELOW_PROJECTILE_LAYER
		I_base.appearance_flags |= RESET_ALPHA //we don't want the stone to pulse
		var/image/I_lave = image('icons/obj/cult_64x64.dmi',"forge-lightmask")
		I_lave.plane = ABOVE_LIGHTING_PLANE
		I_lave.layer = NARSIE_GLOW
		I_lave.blend_mode = BLEND_ADD
		overlays += I_base
		overlays += I_lave

/obj/structure/cult/forge/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/fag = I
		fag.light("<span class='notice'>\The [user] lights \the [fag] by bringing its tip close to \the [src]'s molten flow.</span>")
		return 1
	if(istype(I,/obj/item/candle))
		var/obj/item/candle/stick = I
		stick.light("<span class='notice'>\The [user] lights \the [stick] by bringing its wick close to \the [src]'s molten flow.</span>")
		return 1
	if(istype(I,/obj/item/weapon/talisman) || istype(I,/obj/item/weapon/paper) || istype(I,/obj/item/weapon/tome))
		I.ashify_item(user)
		return 1
	..()

/obj/structure/cult/proc/update_progbar()
	if (!progbar)
		progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = src, "icon_state" = "prog_bar_0")
		progbar.pixel_z = WORLD_ICON_SIZE
		progbar.plane = HUD_PLANE
		progbar.pixel_x = 16 * PIXEL_MULTIPLIER
		progbar.pixel_y = 16 * PIXEL_MULTIPLIER
		progbar.appearance_flags = RESET_ALPHA|RESET_COLOR
		progbar.layer = HUD_ABOVE_ITEM_LAYER
	progbar.icon_state = "prog_bar_[round((100 - min(1, timeleft / timetotal) * 100), 10)]"

/obj/structure/cult/altar/update_progbar()
	if (!progbar)
		progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = src, "icon_state" = "prog_bar_0")
		progbar.pixel_z = WORLD_ICON_SIZE
		progbar.plane = HUD_PLANE
		progbar.layer = HUD_ABOVE_ITEM_LAYER
	progbar.icon_state = "prog_bar_[round((100 - min(1, timeleft / timetotal) * 100), 10)]"

/obj/structure/cult/forge/cultist_act(var/mob/user,var/menu="default")
	.=..()
	if (!.)
		return

	if (template)
		if (forger)
			if (forger == user)
				to_chat(user, "You are already working at this forge.")
			else
				to_chat(user, "\The [forger] is currently working at this forge already.")
		else
			to_chat(user, "You resume working at the forge.")
			forger = user
			if (forger.client)
				forger.client.images |= progbar
		return


	var/list/choices = list(
		list("Forge Blade", "radial_blade", "A powerful ritual blade, the signature weapon of the bloodthirsty cultists. Features a notch in which a Soul Gem can fit."),
		list("Forge Construct Shell", "radial_constructshell", "A polymorphic sculpture that can be shaped into a powerful ally by inserting a full Soul Gem or Shard."),
		list("Forge Helmet", "radial_helmet", "This protective helmet offers the same enhancing powers that a Cult Hood provides, on top of being space proof."),
		list("Forge Armor", "radial_armor", "This protective armor offers the same enhancing powers that Cult Robes provide, on top of being space proof."),
	)

	var/task = show_radial_menu(user,loc,choices,'icons/obj/cult_radial.dmi',"radial-cult")//spawning on loc so we aren't offset by pixel_x/pixel_y, or affected by animate()
	if (template || !Adjacent(user) || !task )
		return
	var/forge_icon = ""
	switch (task)
		if ("Forge Blade")
			template = /obj/item/weapon/melee/cultblade
			timeleft = 10
			forge_icon = "forge_blade"
		if ("Forge Armor")
			template = /obj/item/clothing/suit/space/cult
			timeleft = 23
			forge_icon = "forge_armor"
		if ("Forge Helmet")
			template = /obj/item/clothing/head/helmet/space/cult
			timeleft = 8
			forge_icon = "forge_helmet"
		if ("Forge Construct Shell")
			template = /obj/structure/constructshell/cult/alt
			timeleft = 25
			forge_icon = "forge_shell"
	timetotal = timeleft
	forger = user
	update_progbar()
	if (forger.client)
		forger.client.images |= progbar
	forging = new (loc,forge_icon)

/obj/effect/cult_ritual/forge
	icon = 'icons/obj/cult_64x64.dmi'
	icon_state = ""
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -16 * PIXEL_MULTIPLIER
	plane = EFFECTS_PLANE
	layer = PROJECTILE_LAYER

/obj/effect/cult_ritual/forge/New(var/turf/loc, var/i_forge="")
	..()
	icon_state = i_forge
	var/image/I = image('icons/obj/cult_64x64.dmi',"[i_forge]-mask")
	I.plane = ABOVE_LIGHTING_PLANE
	I.layer = NARSIE_GLOW
	I.blend_mode = BLEND_ADD
	overlays += I


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Spawns next to blood stones
//    OBSIDIAN PILLAR    //
//                       //
///////////////////////////

/obj/structure/cult/pillar
	name = "obsidian pillar"
	icon_state = "pillar-enter"
	icon = 'icons/obj/cult_64x64.dmi'
	pixel_x = -16 * PIXEL_MULTIPLIER
	health = 200
	maxHealth = 200
	sound_damaged = 'sound/effects/stone_hit.ogg'
	sound_destroyed = 'sound/effects/stone_crumble.ogg'
	plane = EFFECTS_PLANE
	layer = BELOW_PROJECTILE_LAYER
	var/alt = 0

/obj/structure/cult/pillar/New()
	..()
	var/turf/T = loc
	if (!T)
		qdel(src)
		return
	for (var/obj/O in loc)
		if(O == src)
			continue
		O.ex_act(2)
		if(!O.gcDestroyed && (istype(O, /obj/structure) || istype(O, /obj/machinery)))
			qdel(O)
	T.ChangeTurf(/turf/simulated/floor/engine/cult)
	T.turf_animation('icons/effects/effects.dmi',"cultfloor", 0, 0, MOB_LAYER-1, anim_plane = TURF_PLANE)

/obj/structure/cult/pillar/Destroy()
	new /obj/effect/decal/cleanable/ash(loc)
	..()


/obj/structure/cult/pillar/alt
	icon_state = "pillaralt-enter"
	alt = 1

/obj/structure/cult/pillar/update_icon()
	icon_state = "pillar[alt ? "alt": ""]2"
	overlays.len = 0
	if (health < maxHealth/3)
		icon_state = "pillar[alt ? "alt": ""]0"
	else if (health < 2*maxHealth/3)
		icon_state = "pillar[alt ? "alt": ""]1"

/obj/structure/cult/pillar/conceal()
	return

/obj/structure/cult/pillar/ex_act(var/severity)
	switch(severity)
		if (1)
			takeDamage(200)
		if (2)
			takeDamage(100)
		if (3)
			takeDamage(20)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Re-added as a cosmetic structure by admin request
//      BLOOD STONE      //
//                       //
///////////////////////////

/obj/structure/cult/bloodstone
	name = "blood stone"
	icon_state = "bloodstone-enter1"
	icon = 'icons/obj/cult_64x64.dmi'
	pixel_x = -16 * PIXEL_MULTIPLIER
	health = 600
	maxHealth = 600
	sound_damaged = 'sound/effects/stone_hit.ogg'
	sound_destroyed = 'sound/effects/stone_crumble.ogg'
	plane = EFFECTS_PLANE
	layer = BELOW_PROJECTILE_LAYER
	light_color = "#FF0000"

/obj/structure/cult/bloodstone/New()
	..()
	set_light(3)

/obj/structure/cult/bloodstone/proc/flashy_entrance()
	for (var/obj/O in loc)
		if (O != src && !istype(O,/obj/item/weapon/melee/soulblade))
			O.ex_act(2)
	safe_space()
	for(var/mob/M in player_list)
		if (M.z == z && M.client)
			if (get_dist(M,src)<=20)
				M.playsound_local(src, get_sfx("explosion"), 50, 1)
				shake_camera(M, 4, 1)
			else
				M.playsound_local(src, 'sound/effects/explosionfar.ogg', 50, 1)
				shake_camera(M, 1, 1)
	spawn(10)
		var/list/pillars = list()
		icon_state = "bloodstone-enter2"
		for(var/mob/M in player_list)
			if (M.z == z && M.client)
				if (get_dist(M,src)<=20)
					M.playsound_local(src, get_sfx("explosion"), 50, 1)
					shake_camera(M, 4, 1)
				else
					M.playsound_local(src, 'sound/effects/explosionfar.ogg', 50, 1)
					shake_camera(M, 1, 1)
		var/turf/T1 = locate(x-2,y-2,z)
		pillars += new /obj/structure/cult/pillar(T1)
		var/turf/T2 = locate(x+2,y-2,z)
		pillars += new /obj/structure/cult/pillar/alt(T2)
		var/turf/T3 = locate(x-2,y+2,z)
		pillars += new /obj/structure/cult/pillar(T3)
		var/turf/T4 = locate(x+2,y+2,z)
		pillars += new /obj/structure/cult/pillar/alt(T4)
		sleep(10)
		icon_state = "bloodstone-enter3"
		for(var/mob/M in player_list)
			if (M.z == z && M.client)
				if (get_dist(M,src)<=20)
					M.playsound_local(src, get_sfx("explosion"), 50, 1)
					shake_camera(M, 4, 1)
				else
					M.playsound_local(src, 'sound/effects/explosionfar.ogg', 50, 1)
					shake_camera(M, 1, 1)
		for (var/obj/structure/cult/pillar/P in pillars)
			P.update_icon()
		sleep(10)
		update_icon()

/obj/structure/cult/bloodstone/Destroy()
	new /obj/effect/decal/cleanable/ash(loc)
	new /obj/item/weapon/ectoplasm(loc)
	..()

/obj/structure/cult/bloodstone/attack_construct(var/mob/user)
	if (!Adjacent(user))
		return 0
	cultist_act(user)
	return 1

/obj/structure/cult/bloodstone/cultist_act(var/mob/user)
	.=..()
	if (!.)
		return
	if(isliving(user))
		var/obj/effect/cult_ritual/dance/dance_center = locate() in loc
		if (dance_center)
			dance_center.add_dancer(user)
		else
			dance_center = new(loc, user)

		if (prob(5))
			user.say("Let me show you the dance of my people!","C")
		else
			user.say("Tok-lyr rqa'nap g'lt-ulotf!","C")

/obj/structure/cult/bloodstone/conceal()
	return

/obj/structure/cult/bloodstone/takeDamage(var/damage)
	health -= damage
	if (health <= 0)
		if (sound_destroyed)
			playsound(src, sound_destroyed, 100, 1)
		qdel(src)
	else
		update_icon()

/obj/structure/cult/bloodstone/ex_act(var/severity)
	switch(severity)
		if (1)
			takeDamage(250)
		if (2)
			takeDamage(50)
		if (3)
			takeDamage(10)

/obj/structure/cult/bloodstone/update_icon()
	icon_state = "bloodstone-9"
	overlays.len = 0
	var/image/I_base = image('icons/obj/cult_64x64.dmi',"bloodstone-base")
	I_base.appearance_flags |= RESET_COLOR//we don't want the stone to pulse
	overlays += I_base
	if (health < maxHealth/3)
		overlays.Add("bloodstone_damage2")
	else if (health < 2*maxHealth/3)
		overlays.Add("bloodstone_damage1")

/obj/structure/cult/bloodstone/proc/set_animate()
	animate(src, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)
	update_icon()

/*
var/list/bloodstone_list = list()

/obj/structure/cult/bloodstone
	name = "blood stone"
	icon_state = "bloodstone-enter1"
	icon = 'icons/obj/cult_64x64.dmi'
	pixel_x = -16 * PIXEL_MULTIPLIER
	health = 600
	maxHealth = 600
	sound_damaged = 'sound/effects/stone_hit.ogg'
	sound_destroyed = 'sound/effects/stone_crumble.ogg'
	plane = EFFECTS_PLANE
	layer = BELOW_PROJECTILE_LAYER
	light_color = "#FF0000"

	var/list/watching_mobs = list()
	var/list/watcher_maps = list()
	var/datum/station_holomap/holomap_datum
	var/anchor = FALSE

/obj/structure/cult/bloodstone/New()
	..()
	var/datum/holomap_marker/newMarker = new()
	newMarker.id = HOLOMAP_MARKER_BLOODSTONE
	newMarker.filter = HOLOMAP_FILTER_CULT
	newMarker.x = x
	newMarker.y = y
	newMarker.z = z
	holomap_markers[HOLOMAP_MARKER_BLOODSTONE+"_\ref[src]"] = newMarker

	holomap_datum = new /datum/station_holomap/cult()
	holomap_datum.initialize_holomap(get_turf(src))

	bloodstone_list.Add(src)
	for (var/obj/O in loc)
		if (O != src && !istype(O,/obj/item/weapon/melee/soulblade))
			O.ex_act(2)
	safe_space()
	set_light(3)
	for(var/mob/M in player_list)
		if (M.z == z && M.client)
			if (get_dist(M,src)<=20)
				M.playsound_local(src, get_sfx("explosion"), 50, 1)
				shake_camera(M, 4, 1)
			else
				M.playsound_local(src, 'sound/effects/explosionfar.ogg', 50, 1)
				shake_camera(M, 1, 1)

	spawn(10)
		var/list/pillars = list()
		icon_state = "bloodstone-enter2"
		for(var/mob/M in player_list)
			if (M.z == z && M.client)
				if (get_dist(M,src)<=20)
					M.playsound_local(src, get_sfx("explosion"), 50, 1)
					shake_camera(M, 4, 1)
				else
					M.playsound_local(src, 'sound/effects/explosionfar.ogg', 50, 1)
					shake_camera(M, 1, 1)
		var/turf/T1 = locate(x-2,y-2,z)
		pillars += new /obj/structure/cult/pillar(T1)
		var/turf/T2 = locate(x+2,y-2,z)
		pillars += new /obj/structure/cult/pillar/alt(T2)
		var/turf/T3 = locate(x-2,y+2,z)
		pillars += new /obj/structure/cult/pillar(T3)
		var/turf/T4 = locate(x+2,y+2,z)
		pillars += new /obj/structure/cult/pillar/alt(T4)
		sleep(10)
		icon_state = "bloodstone-enter3"
		for(var/mob/M in player_list)
			if (M.z == z && M.client)
				if (get_dist(M,src)<=20)
					M.playsound_local(src, get_sfx("explosion"), 50, 1)
					shake_camera(M, 4, 1)
				else
					M.playsound_local(src, 'sound/effects/explosionfar.ogg', 50, 1)
					shake_camera(M, 1, 1)
		for (var/obj/structure/cult/pillar/P in pillars)
			P.update_icon()

/obj/structure/cult/bloodstone/Destroy()
	bloodstone_list.Remove(src)
	new /obj/effect/decal/cleanable/ash(loc)
	new /obj/item/weapon/ectoplasm(loc)

	var/datum/holomap_marker/holomarker = new()
	holomarker.id = HOLOMAP_MARKER_BLOODSTONE_BROKEN
	holomarker.filter = HOLOMAP_FILTER_CULT
	holomarker.x = src.x
	holomarker.y = src.y
	holomarker.z = src.z
	holomap_markers[HOLOMAP_MARKER_BLOODSTONE+"_\ref[src]"] = holomarker

	/* --no need to update the map
	if(holomarker.z == map.zMainStation && holomarker.filter & HOLOMAP_FILTER_CULT)
		if(map.holomap_offset_x.len >= map.zMainStation)
			updated_map.Blend(icon(holomarker.icon,holomarker.id), ICON_OVERLAY, holomarker.x-8+map.holomap_offset_x[map.zMainStation]	, holomarker.y-8+map.holomap_offset_y[map.zMainStation])
		else
			updated_map.Blend(icon(holomarker.icon,holomarker.id), ICON_OVERLAY, holomarker.x-8, holomarker.y-8)
	extraMiniMaps[HOLOMAP_EXTRA_CULTMAP] = updated_map
	*/
	for(var/obj/structure/cult/bloodstone/B in bloodstone_list)
		if (B != src && !B.loc)
			message_admins("Blood Cult: A blood stone was somehow spawned in nullspace. It has been destroyed.")
			qdel(B)

	if (bloodstone_list.len <= 0 || anchor)
		var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
		if (cult)
			cult.fail()
		if(anchor)
			global_anchor_bloodstone = null
	..()

/obj/structure/cult/bloodstone/attack_construct(var/mob/user)
	if (!Adjacent(user))
		return 0
	cultist_act(user)
	return 1

/obj/structure/cult/bloodstone/cultist_act(var/mob/user)
	.=..()
	if (!.)
		return
	if(isliving(user))
		if(user in watching_mobs)
			stopWatching(user)
		else
			if (anchor)
				if (user in contributors)
					return
				if (!user.checkTattoo(TATTOO_SILENT))
					if (prob(5))
						user.say("Let me show you the dance of my people!","C")
					else
						user.say("Tok-lyr rqa'nap g'lt-ulotf!","C")
				contributors.Add(user)
				if (user.client)
					update_progbar()
					user.client.images |= progbar
			else if(user.hud_used && user.hud_used.holomap_obj)
				if(!("\ref[user]" in watcher_maps))
					var/image/personnal_I = prepare_cult_holomap()
					var/turf/T = get_turf(src)
					if(map.holomap_offset_x.len >= T.z)
						holomap_datum.cursor.pixel_x = (T.x-9+map.holomap_offset_x[T.z])*PIXEL_MULTIPLIER
						holomap_datum.cursor.pixel_y = (T.y-9+map.holomap_offset_y[T.z])*PIXEL_MULTIPLIER
					else
						holomap_datum.cursor.pixel_x = (T.x-9)*PIXEL_MULTIPLIER
						holomap_datum.cursor.pixel_y = (T.y-9)*PIXEL_MULTIPLIER
					personnal_I.overlays += holomap_datum.cursor
					watcher_maps["\ref[user]"] = personnal_I
				var/image/I = watcher_maps["\ref[user]"]
				I.loc = user.hud_used.holomap_obj
				I.alpha = 0
				animate(watcher_maps["\ref[user]"], alpha = 255, time = 5, easing = LINEAR_EASING)
				watching_mobs |= user
				user.client.images |= watcher_maps["\ref[user]"]
				user.register_event(/event/face, src, /obj/structure/cult/bloodstone/proc/checkPosition)

/obj/structure/cult/bloodstone/proc/checkPosition()
	for(var/mob/M in watching_mobs)
		if(get_dist(src,M) > 1)
			stopWatching(M)

/obj/structure/cult/bloodstone/proc/stopWatching(var/mob/user)
	if(!user)
		for(var/mob/M in watching_mobs)
			if(M.client)
				spawn(5)//we give it time to fade out
					M.client.images -= watcher_maps["\ref[M]"]
				M.unregister_event(/event/face, src, /obj/structure/cult/bloodstone/proc/checkPosition)
				animate(watcher_maps["\ref[M]"], alpha = 0, time = 5, easing = LINEAR_EASING)

		watching_mobs = list()
	else
		if(user.client)
			spawn(5)//we give it time to fade out
				if(!(user in watching_mobs))
					user.client.images -= watcher_maps["\ref[user]"]
					watcher_maps -= "\ref[user]"
			user.unregister_event(/event/face, src, /obj/structure/cult/bloodstone/proc/checkPosition)
			animate(watcher_maps["\ref[user]"], alpha = 0, time = 5, easing = LINEAR_EASING)

			watching_mobs -= user

/obj/structure/cult/bloodstone/update_icon()
	icon_state = "bloodstone-0"
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (cult)
		var/datum/objective/bloodcult_bloodbath/O = locate() in cult.objective_holder.objectives
		if (O)
			icon_state = "bloodstone-[max(0,min(9,round(cult.bloody_floors.len*100/O.target_bloodspill/10)))]"
	overlays.len = 0
	var/image/I_base = image('icons/obj/cult_64x64.dmi',"bloodstone-base")
	I_base.appearance_flags |= RESET_COLOR//we don't want the stone to pulse
	overlays += I_base
	if (health < maxHealth/3)
		overlays.Add("bloodstone_damage2")
	else if (health < 2*maxHealth/3)
		overlays.Add("bloodstone_damage1")

/obj/structure/cult/bloodstone/proc/set_animate()
	animate(src, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)
	update_icon()

/obj/structure/cult/bloodstone/conceal()
	return

/obj/structure/cult/bloodstone/takeDamage(var/damage)
	if(veil_thickness == CULT_EPILOGUE)
		return
	var/backup = (health > (2*maxHealth/3)) + (health > (maxHealth/3))
	health -= damage
	if (health <= 0)
		if (sound_destroyed)
			playsound(src, sound_destroyed, 100, 1)
		qdel(src)
	else
		if (backup > (health > (2*maxHealth/3)) + (health > (maxHealth/3)))
			summon_backup()
		update_icon()

/obj/structure/cult/bloodstone/proc/summon_backup()
	var/list/possible_floors = list()
	for (var/turf/simulated/floor/F in orange(1,get_turf(src)))
		possible_floors.Add(F)
	var/monsters_to_spawn = 1
	if (health < (maxHealth / 2))
		monsters_to_spawn++
	for (var/i = 1 to monsters_to_spawn)
		if (possible_floors.len <= 0)
			break
		var/turf/T = pick(possible_floors)
		if (T)
			possible_floors.Remove(T)
			new /obj/effect/cult_ritual/backup_spawn(T)

/obj/structure/cult/bloodstone/dance_start()
	while(!gcDestroyed && loc && anchor)
		for (var/mob/M in contributors)
			if (!iscultist(M) || get_dist(src,M) > 1 || (M.stat != CONSCIOUS))
				if (M.client)
					M.client.images -= progbar
				contributors.Remove(M)
				continue
		if (contributors.len > 0)
			timeleft -= 1 + round(contributors.len/3)//Additional dancers will complete the ritual faster
			if (timeleft <= 0)
				break
			update_progbar()
			dance_step()
			sleep(3)
			dance_step()
			sleep(3)
			dance_step()
			sleep(6)
		else
			timeleft = min(timeleft+1,60)
			sleep(10)
	for (var/mob/M in contributors)
		if (M.client)
			M.client.images -= progbar
		contributors.Remove(M)
	anchor = FALSE
	for (var/obj/structure/teleportwarp/TW in src.loc)
		qdel(TW)
	if (!gcDestroyed && loc)
		new /obj/machinery/singularity/narsie/large(src.loc)
		SSpersistence_map.setSavingFilth(FALSE)
	return 1

/obj/structure/cult/bloodstone/ex_act(var/severity)
	switch(severity)
		if (1)
			takeDamage(250)
		if (2)
			takeDamage(50)
		if (3)
			takeDamage(10)
*/

/obj/structure/cult/proc/safe_space()
	for(var/turf/T in range(5,src))
		var/dist = cheap_pythag(T.x - src.x, T.y - src.y)
		if (dist <= 2.5)
			T.ChangeTurf(/turf/simulated/floor/engine/cult)
			T.turf_animation('icons/effects/effects.dmi',"cultfloor", 0, 0, MOB_LAYER-1, anim_plane = TURF_PLANE)
			for (var/obj/structure/S in T)
				if (!istype(S,/obj/structure/cult))
					qdel(S)
			for (var/obj/machinery/M in T)
				qdel(M)
		else if (dist <= 4.5)
			if (istype(T,/turf/space))
				T.ChangeTurf(/turf/simulated/floor/engine/cult)
				T.turf_animation('icons/effects/effects.dmi',"cultfloor", 0, 0, MOB_LAYER-1, anim_plane = TURF_PLANE)
			else
				T.cultify()
		else if (dist <= 5.5)
			if (istype(T,/turf/space))
				T.ChangeTurf(/turf/simulated/wall/cult)
				T.turf_animation('icons/effects/effects.dmi',"cultwall", 0, 0, MOB_LAYER-1, anim_plane = TURF_PLANE)
			else
				T.cultify()

//inspired from LoZ:Oracle of Seasons
/obj/structure/cult/proc/dance_start()
	while(timeleft > 0)
		for (var/mob/M in contributors)
			if (!iscultist(M) || get_dist(src,M) > 1 || M.incapacitated() || M.occult_muted())
				if (M.client)
					M.client.images -= progbar
				contributors.Remove(M)
				continue
		if (contributors.len <= 0)
			return 0
		timeleft -= 1 + round(contributors.len/2)//Additional dancers will complete the ritual faster
		update_progbar()
		dance_step()
		sleep(3)
		dance_step()
		sleep(3)
		dance_step()
		sleep(6)
	for (var/mob/M in contributors)
		if (M.client)
			M.client.images -= progbar
		contributors.Remove(M)
	return 1

/obj/structure/cult/proc/dance_step()
	var/dance_move = pick("clock","counter","spin")

	switch(dance_move)
		if ("clock")
			for (var/mob/M in contributors)
				INVOKE_EVENT(M, /event/before_move)
				switch (get_dir(src,M))
					if (NORTHWEST,NORTH)
						M.forceMove(get_step(M,EAST))
						M.dir = EAST
					if (NORTHEAST,EAST)
						M.forceMove(get_step(M,SOUTH))
						M.dir = SOUTH
					if (SOUTHEAST,SOUTH)
						M.forceMove(get_step(M,WEST))
						M.dir = WEST
					if (SOUTHWEST,WEST)
						M.forceMove(get_step(M,NORTH))
						M.dir = NORTH
				INVOKE_EVENT(M, /event/after_move)
				INVOKE_EVENT(M, /event/moved, "mover" = M)
		if ("counter")
			for (var/mob/M in contributors)
				INVOKE_EVENT(M, /event/before_move)
				switch (get_dir(src,M))
					if (NORTHEAST,NORTH)
						M.forceMove(get_step(M,WEST))
						M.dir = WEST
					if (SOUTHEAST,EAST)
						M.forceMove(get_step(M,NORTH))
						M.dir = NORTH
					if (SOUTHWEST,SOUTH)
						M.forceMove(get_step(M,EAST))
						M.dir = EAST
					if (NORTHWEST,WEST)
						M.forceMove(get_step(M,SOUTH))
						M.dir = SOUTH
				INVOKE_EVENT(M, /event/after_move)
				INVOKE_EVENT(M, /event/moved, "mover" = M)
		if ("spin")
			for (var/mob/M in contributors)
				spawn()
					M.dir = SOUTH
					INVOKE_EVENT(M, /event/face)
					sleep(0.75)
					M.dir = EAST
					INVOKE_EVENT(M, /event/face)
					sleep(0.75)
					M.dir = NORTH
					INVOKE_EVENT(M, /event/face)
					sleep(0.75)
					M.dir = WEST
					INVOKE_EVENT(M, /event/face)
					sleep(0.75)
					M.dir = SOUTH
					INVOKE_EVENT(M, /event/face)
