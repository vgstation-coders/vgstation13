//Job HUD

/datum/visioneffect/job
	name = "job hud"

/datum/visioneffect/job/process_hud(var/mob/M)
	..()
	if(!M.client)
		return
	var/client/C = M.client
	var/image/holder
	var/turf/T
	var/offset = 0
	if(M.hasHUD(HUD_MEDICAL))
		//hardcoded offset so that job huds will move aside for medical huds
		offset = 8
	offset = offset * PIXEL_MULTIPLIER
	T = get_turf(M)

	for(var/mob/living/simple_animal/astral_projection/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue
		holder = perp.hud_list[ID_HUD]
		if(!holder)
			continue
		holder.icon_state = "hud[ckey(perp.cardjob)]"
		holder.pixel_y = -offset
		C.images += holder

	for(var/mob/living/carbon/human/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue
		holder = perp.hud_list[ID_HUD]
		if(!holder)
			continue
		holder.icon_state = "hudno_id"
		if(perp.head && istype(perp.head,/obj/item/clothing/head/tinfoil)) //Tinfoil hat? Move along.
			holder.pixel_y = -offset
			C.images += holder
			continue
		var/obj/item/weapon/card/id/card = perp.get_id_card()
		if(card)
			holder.icon_state = "hud[ckey(card.GetJobName())]"
		holder.pixel_y = -offset
		C.images += holder
