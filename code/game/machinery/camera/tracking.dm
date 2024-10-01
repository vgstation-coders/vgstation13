/mob/living/silicon/ai
	var/atom/movable/currently_tracking = null

/mob/living/silicon/ai/proc/get_camera_list()


	track.cameras.len = 0

	if(src.stat == 2)
		return

	var/list/L = list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		L.Add(C)

	camera_sort(L)

	var/list/T = list()

	for (var/obj/machinery/camera/C in L)
		var/list/tempnetwork = C.network&src.network
		if (tempnetwork.len)
			T[text("[][]", C.c_tag, (C.can_use() ? null : " (Deactivated)"))] = C

	track.cameras = T
	return T


/mob/living/silicon/ai/proc/ai_camera_list(var/camera)
	if (!camera)
		return 0

	var/obj/machinery/camera/C = track.cameras[camera]
	src.eyeobj.forceMove(C)

	return

// Used to allow the AI is write in mob names/camera name from the CMD line.
/datum/trackable
	var/list/names = list()
	var/list/namecounts = list()
	var/list/humans = list()
	var/list/others = list()
	var/list/cameras = list()

	var/list/mecha_names = list()
	var/list/mecha_namecounts = list()
	var/list/mechas = list()

/mob/living/silicon/ai/proc/trackable_atoms()
	track.names.len = 0
	track.namecounts.len = 0
	track.humans.len = 0
	track.others.len = 0

	track.mecha_names.len = 0
	track.mecha_namecounts.len = 0
	track.mechas.len = 0

	if(stat == 2)
		return list()

	for(var/mob/living/target_mob in mob_list)
		if(!can_track_atom(target_mob))
			continue

		var/name = target_mob.name
		if (name in track.names)
			track.namecounts[name]++
			name = text("[] ([])", name, track.namecounts[name])
		else
			track.names.Add(name)
			track.namecounts[name] = 1
		if(ishuman(target_mob))
			track.humans[name] = target_mob
		else
			track.others[name] = target_mob

	for(var/obj/mecha/target_mecha in mechas_list)
		if(!can_track_atom(target_mecha))
			continue

		var/name = target_mecha.name
		if(name in track.mecha_names)
			track.mecha_namecounts[name]++
			name = "[name] ([track.mecha_namecounts[name]])"
		else
			track.mecha_names.Add(name)
			track.mecha_namecounts[name] = 1
		track.mechas[name] = target_mecha

	var/list/targets = sortList(track.humans) + sortList(track.mechas) + sortList(track.others)
	return targets

/mob/living/silicon/ai/verb/ai_camera_track(var/target_name as null|anything in trackable_atoms())
	set name = "track"
	set hidden = 1 //Don't display it on the verb lists. This verb exists purely so you can type "track Oldman Robustin" and follow his ass

	if(!target_name)
		return

	var/atom/target = track.humans[target_name]
	if(isnull(target))
		target = track.mechas[target_name]
	if(isnull(target))
		target = track.others[target_name]
	if(isnull(target))
		warning("AI tracking failed: target_name ([target_name]) was not found in any of the lists")
	else
		ai_actual_track(target)

/mob/living/silicon/ai/proc/open_nearest_door(mob/living/target as mob)
	if(!istype(target))
		return
	spawn(0)
		if(!can_track_atom(target))
			to_chat(src, "Target is not trackable by any means.")
			return
		var/obj/machinery/door/airlock/tobeopened
		var/dist = -1
		for(var/obj/machinery/door/airlock/D in range(3,target))
			if(!D.density)
				continue
			if(dist < 0)
				dist = get_dist(D, target)
//				to_chat(world, dist)
				tobeopened = D
			else
				if(dist > get_dist(D, target))
					dist = get_dist(D, target)
//					to_chat(world, dist)
					tobeopened = D
//					to_chat(world, "found [tobeopened.name] closer")
				else
//					to_chat(world, "[D.name] not close enough | [get_dist(D, target)] | [dist]")
		if(tobeopened)
			switch(alert(src, "Do you want to open \the [tobeopened] for [target]?","Doorknob_v2a.exe","Yes","No"))
				if("Yes")
					var/nhref = "src=\ref[tobeopened];aiEnable=7"
					tobeopened.Topic(nhref, params2list(nhref), tobeopened, 1)
					to_chat(src, "<span class='notice'>You've opened \the [tobeopened] for [target].</span>")
				if("No")
					to_chat(src, "<span class='warning'>You deny the request.</span>")
		else
			to_chat(src, "<span class='warning'>You've failed to open an airlock for [target]</span>")
		return

/mob/living/silicon/ai/proc/can_track_atom(var/atom/target)
	if(!target || target.gcDestroyed || target == src)
		return FALSE

	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	if(T.z == map.zCentcomm || T.z > 6)
		return FALSE

	if(!check_HUD_visibility(target, src))
		return FALSE

	if(ismob(target))
		var/mob/target_mob = target
		if(target_mob.digitalcamo)
			return FALSE
		for(var/obj/item/I in target_mob.get_all_slots())
			if(I.blocks_tracking)
				return FALSE
			if(target_mob.is_wearing_item(I,slot_wear_id))
				var/obj/item/ourID = I.GetID()
				if(ourID && ourID.blocks_tracking)
					return FALSE

	if(isalien(target))
		return FALSE

	if(istype(target.loc, /obj/effect/dummy))
		return FALSE

	if(!near_camera(target))
		return FALSE

	return TRUE

/mob/living/silicon/ai/proc/ai_actual_track(var/atom/movable/target)
	if(!istype(target) || !eyeobj)
		return

	if(!can_track_atom(target))
		to_chat(src, "Target is not trackable by any means.")
		return

	stop_ai_tracking()
	currently_tracking = target
	eyeobj.forceMove(get_turf(currently_tracking))
	currently_tracking.lock_atom(eyeobj,/datum/locking_category/ai_eye)

	currently_tracking.register_event(/event/after_move,src,nameof(src::on_camera_change()))
	currently_tracking.register_event(/event/destroyed,src,nameof(src::stop_ai_tracking()))
	currently_tracking.register_event(/event/equipped,src,nameof(src::on_camera_change()))
	currently_tracking.register_event(/event/unequipped,src,nameof(src::on_camera_change()))
	currently_tracking.register_event(/event/camera_sight_changed,src,nameof(src::on_camera_change()))
	to_chat(src, "Now tracking [currently_tracking.name] on camera.")

/datum/locking_category/ai_eye

/mob/living/silicon/ai/proc/on_camera_change()
	if(eyeobj && currently_tracking)
		var/cantrack = can_track_atom(currently_tracking)
		if(!eyeobj.locked_to && cantrack)
			to_chat(src, "Target is trackable again.")
			currently_tracking.lock_atom(eyeobj,/datum/locking_category/ai_eye)
		else if(!cantrack && eyeobj.locked_to == currently_tracking)
			to_chat(src, "Target is no longer trackable.")
			eyeobj.unlock_from()

/mob/living/silicon/ai/proc/stop_ai_tracking()
	if(currently_tracking)
		to_chat(src, "No longer tracking [currently_tracking.name] on camera.")
		currently_tracking.unregister_event(/event/after_move,src,nameof(src::on_camera_change()))
		currently_tracking.unregister_event(/event/destroyed,src,nameof(src::stop_ai_tracking()))
		currently_tracking.unregister_event(/event/equipped,src,nameof(src::on_camera_change()))
		currently_tracking.unregister_event(/event/unequipped,src,nameof(src::on_camera_change()))
		currently_tracking.unregister_event(/event/camera_sight_changed,src,nameof(src::on_camera_change()))
		if(eyeobj?.locked_to == currently_tracking)
			eyeobj.unlock_from()
		currently_tracking = null

/proc/near_camera(var/mob/living/M)
	if (!isturf(M.loc))
		return 0
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(!(R.camera && R.camera.can_use()) && !cameranet.checkCameraVis(M))
			return 0
	else if(!cameranet.checkCameraVis(M))
		return 0
	return 1

/obj/machinery/camera/attack_ai(var/mob/living/silicon/ai/user as mob)
	if (!istype(user))
		return
	if (!src.can_use())
		return
	user.eyeobj.forceMove(get_turf(src))


/mob/living/silicon/ai/attack_ai(var/mob/user as mob)
	ai_camera_list()

/proc/camera_sort(list/L)
	var/obj/machinery/camera/a
	var/obj/machinery/camera/b

	for (var/i = L.len, i > 0, i--)
		for (var/j = 1 to i - 1)
			a = L[j]
			b = L[j + 1]
			if (a.c_tag_order != b.c_tag_order)
				if (a.c_tag_order > b.c_tag_order)
					L.Swap(j, j + 1)
			else
				if (sorttext(a.c_tag, b.c_tag) < 0)
					L.Swap(j, j + 1)
	return L
