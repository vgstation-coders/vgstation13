/* Using the HUD procs is simple. Call these procs in the life.dm of the intended mob.
Use the regular_hud_updates() proc before process_med_hud(mob) or process_sec_hud(mob) so
the HUD updates properly! */

/proc/process_med_hud(var/mob/M)
	return

/proc/process_sec_hud(var/mob/M, var/advanced = 0)
	return

/proc/process_diagnostic_hud(var/mob/M)
	return

//Artificer HUD
/proc/process_construct_hud(var/mob/M, var/mob/eye)
	if(!M)
		return
	if(!M.client)
		return
	var/client/C = M.client
	var/image/holder
	var/turf/T
	if(eye)
		T = get_turf(eye)
	else
		T = get_turf(M)
	for(var/mob/living/simple_animal/construct/construct in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(construct, M))
			continue

		holder = construct.hud_list[CONSTRUCT_HUD]
		if(holder)
			if(construct.isDead())
				holder.icon_state = "consthealth0"
			else
				holder.icon_state = "consthealth[10*round((construct.health/construct.maxHealth)*10)]"
			holder.plane = ABOVE_LIGHTING_PLANE
			C.images += holder
