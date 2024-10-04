//Cult Construct HUD
//Shows a construct's current/max health, similar to medhuds

/datum/visioneffect/construct
	name = "cult construct hud"

/datum/visioneffect/construct/process_hud(var/mob/M)
	if(!M)
		return
	if(!M.client)
		return
	var/client/C = M.client
	var/image/holder
	var/turf/T
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

