/obj/effect/blob/core
	name = "blob core"
	icon_state = "core"
	desc = "A part of a blob. It is large and pulsating."
	health = 200
	maxHealth = 200
	fire_resist = 2
	custom_process=1
	destroy_sound = "sound/effects/blobkill.ogg"
	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 30 seconds
	var/last_resource_collection
	var/point_rate = 1
	var/mob/camera/blob/creator = null
	layer = BLOB_CORE_LAYER
	var/core_warning_delay = 0
	var/previous_health = 200
	var/no_ghosts_allowed = FALSE

	icon_new = "core"
	icon_classic = "blob_core"


/obj/effect/blob/core/New(loc, var/h = 200, var/client/new_overmind = null, var/new_rate = 2, var/mob/camera/blob/C = null,newlook = "new",no_morph = 0)
	if (looks == "new")
		looks = newlook
	blob_cores += src
	processing_objects.Add(src)
	creator = C
	if (!asleep && icon_size == 64)
		if(new_overmind)
			if (!no_morph)
				flick("core_spawn",src)
		else
			icon_state = "cerebrate"
			icon_new = "cerebrate"
			if (!no_morph)
				flick("morph_core",src)
	playsound(src, get_sfx("gib"),50,1)
	if(!overmind && !asleep)
		if (new_overmind)
			create_overmind(new_overmind)
		else
			recruit_overmind()
	point_rate = new_rate
	last_resource_collection = world.time
	..(loc, looks)

/obj/effect/blob/core/Destroy()
	blob_cores -= src

	for(var/mob/camera/blob/O in blob_overminds)
		if(overmind && (O != overmind))
			to_chat(O,"<span class='danger'>A blob core has been destroyed! [overmind] lost his life!</span> <b><a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></b>")
		else
			to_chat(O,"<span class='warning'>A blob core has been destroyed. It had no overmind in control.</span> <b><a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></b>")

	if(overmind)
		for(var/obj/effect/blob/resource/R in blob_resources)
			if(R.overmind == overmind)
				R.overmind = null
				R.update_icon()
		QDEL_NULL(overmind)
	processing_objects.Remove(src)
	..()

/obj/effect/blob/core/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/core/update_health()
	if(overmind)
		overmind.update_health()
		if((health < previous_health) && (core_warning_delay <= world.time))
			core_warning_delay = world.time + (3 SECONDS)
			to_chat(overmind,"<span class='danger'>YOUR CORE IS UNDER ATTACK!</span> <b><a href='?src=\ref[overmind];blobjump=\ref[loc]'>(JUMP)</a></b>")

	previous_health = health
	..()

/obj/effect/blob/core/update_looks(var/right_now = 0)
	..()
	var/icon/I = new(icon)
	light_color = I.GetPixel(1,1,"core_color")
	set_light(1, 3, light_color)

/obj/effect/blob/core/Life()
	if(timestopped)
		return 0 //under effects of time magick

	if(overmind)
		var/points_to_collect = clamp(point_rate*round((world.time-last_resource_collection)/10), 0, 10)
		overmind.add_points(points_to_collect)
		last_resource_collection = world.time

	if(health < maxHealth)
		health = min(maxHealth, health + 1)
		update_icon()

	if(asleep)
		return

	if(!spawning)//no expanding on the first Life() tick

		if(icon_size == 64)
			if (icon_state == "cerebrate")
				anim(target = loc, a_icon = icon, flick_anim = "cerebratepulse", sleeptime = 15, lay = ABOVE_LIGHTING_LAYER, offX = -16, offY = -16, alph = 200, plane = ABOVE_LIGHTING_PLANE)
			else
				anim(target = loc, a_icon = icon, flick_anim = "corepulse", sleeptime = 15, lay = ABOVE_LIGHTING_LAYER, offX = -16, offY = -16, alph = 200, plane = ABOVE_LIGHTING_PLANE)
			for(var/mob/M in viewers(src))
				M.playsound_local(loc, adminblob_beat, 50, 0, null, FALLOFF_SOUNDS, 0)

		var/turf/T = get_turf(overmind) //The overmind's mind can expand the blob
		var/obj/effect/blob/O = locate() in T //As long as it is 'thinking' about a blob already
		for(var/i = 1; i < 8; i += i)
			Pulse(0, i, overmind)
			if(istype(O))
				O.Pulse(5, i, overmind) //Pulse starting at 5 instead of 0 like a node
		for(var/b_dir in alldirs)
			if(!prob(5))
				continue
			var/obj/effect/blob/normal/B = locate() in get_step(src, b_dir)
			if(B)
				B.change_to(/obj/effect/blob/shield)
	else
		spawning = 0
	..()

/obj/effect/blob/core/VisiblePulse(var/pulse = 0)
	if (pulse > 0)
		return
	..(pulse)

/obj/effect/blob/core/run_action()
	return 0

/obj/effect/blob/core/proc/recruit_overmind()
	var/list/possible_candidates = get_candidates(BLOBOVERMIND)
	var/icon/logo_icon = icon('icons/logos.dmi', "blob-logo")
	for(var/client/candidate in possible_candidates)
		if(istype(candidate.eye,/obj/item/projectile/meteor/blob/core))
			continue
		to_chat(candidate.mob, "[bicon(logo_icon)]<span class='recruit'>A blob core is looking for someone to become its overmind. (<a href='?src=\ref[src];blob_recruit=\ref[candidate.mob]'>Apply now!</a>)</span>[bicon(logo_icon)]")

/obj/effect/blob/core/Topic(href, href_list)
	if(usr.stat != DEAD)
		return

	if(href_list["blob_recruit"])//We don't have time to wait for the recruiter, just grab whoever applied first!
		if(!overmind)
			create_overmind(usr.client)
		else
			to_chat(usr, "<span class='warning'>Looks like someone applied first. First arrived, first served. Better luck next time.</span>")

/obj/effect/blob/core/attack_ghost(var/mob/user)
	if (no_ghosts_allowed)
		to_chat(user, "<span class='warning'>This [src] cannot be controlled by ghosts.</span>")
		return
	if (!overmind)
		var/confirm = alert("Take control of this blob core?", "Take Control", "Yes", "No")
		if(confirm == "Yes")
			if(!overmind)
				create_overmind(user.client)
			else
				to_chat(user, "<span class='warning'>Someone has already taken control of this core.</span>")

/obj/effect/blob/core/proc/create_overmind(var/client/new_overmind)
	if(!new_overmind)
		return 0

	if (jobban_isbanned(new_overmind.mob, BLOBOVERMIND) || isantagbanned(new_overmind.mob))
		to_chat(usr, "<span class='warning'>You are banned from this role.</span>")
		return 0

	if(overmind)
		QDEL_NULL(overmind)

	var/mob/camera/blob/B = new(src.loc)
	B.key = new_overmind.key
	B.blob_core = src
	src.overmind = B

	var/datum/faction/blob_conglomerate/conglomerate = find_active_faction_by_type(/datum/faction/blob_conglomerate)
	if(conglomerate) //Faction exists
		if(!conglomerate.get_member_by_mind(B.mind)) //We are not a member yet
			var/ded = TRUE
			if(conglomerate.members.len)
				for(var/datum/role/R in conglomerate.members)
					if (R.antag && R.antag.current && !(R.antag.current.isDead()))
						ded = FALSE
						break
			if(ded)
				conglomerate.HandleNewMind(B.mind)
			else
				conglomerate.HandleRecruitedMind(B.mind)

	else //No faction? Make one and you're the overmind.
		conglomerate = ticker.mode.CreateFaction(/datum/faction/blob_conglomerate)
		if(conglomerate)
			conglomerate.HandleNewMind(B.mind)

	if (icon_state == "cerebrate")
		icon_state = "core"
		icon_new = "core"
		flick("morph_cerebrate",src)

	B.special_blobs += src
	B.DisplayUI("Blob")

	if(!B.blob_core.creator)//If this core is the first of its lineage (created by game mode/event/admins, instead of another overmind) it gets to choose its looks.
		var/new_name = "Blob Overmind ([rand(1, 999)])"
		B.name = new_name
		B.real_name = new_name
		B.mind.name = new_name
		for(var/mob/camera/blob/O in blob_overminds)
			if(O != B)
				to_chat(O,"<span class='notice'>[B] has appeared and just started a new blob! <a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></span>")

		B.verbs += /mob/camera/blob/proc/create_core
		spawn()
			var/can_choose_from = blob_looks_player
			var/chosen = input(B,"Select a blob looks", "Blob Looks", blob_looks_player[1]) as null|anything in can_choose_from
			if(chosen)
				for(var/obj/effect/blob/nearby_blob in range(src,5))
					nearby_blob.looks = chosen
					nearby_blob.update_looks(1)

	else
		var/new_name = "Blob Cerebrate ([rand(1, 999)])"
		B.name = new_name
		B.real_name = new_name
		B.mind.name = new_name
		for(var/mob/camera/blob/O in blob_overminds)
			if(O != B)
				to_chat(O,"<span class='notice'>A new blob cerebrate has started thinking inside a blob core! [B] joins the blob! <a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></span>")

	return 1

/obj/effect/blob/core/update_icon(var/spawnend = 0)
	if(icon_size == 64)

		if (looks == "AME_new")
			icon_state = "core"
			var/hurt_percentage = round((health * 100) / maxHealth)
			if (hurt_percentage < 25)
				icon_state = "core_fuck"
			else if (hurt_percentage < 50)
				icon_state = "core_critical"

		spawn(1)
			overlays.len = 0
			underlays.len = 0

			underlays += image(icon,"roots")

			if(!spawning)
				for(var/obj/effect/blob/B in orange(src,1))
					overlays += image(icon,"coreconnect",dir = get_dir(src,B))
			if(spawnend)
				spawn(10)
					update_icon()

			..()


/obj/effect/blob/update_icon(var/spawnend = 0)
	if(icon_size == 64)
		if(health < maxHealth)
			var/hurt_percentage = round((health * 100) / maxHealth)
			var/hurt_icon
			switch(hurt_percentage)
				if(0 to 25)
					hurt_icon = "hurt_100"
				if(26 to 50)
					hurt_icon = "hurt_75"
				if(51 to 75)
					hurt_icon = "hurt_50"
				else
					hurt_icon = "hurt_25"
			overlays += image(icon,hurt_icon)
