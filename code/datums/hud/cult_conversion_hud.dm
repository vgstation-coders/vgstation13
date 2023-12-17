//Cult Conversion HUD

/datum/visioneffect/cult_conversion
	name = "cult conversion hud"
	see_invisible = SEE_INVISIBLE_OBSERVER

/datum/visioneffect/cult_conversion/on_clean_up(var/mob/caster)
	..()
	if(caster.client)
		for(var/image/hud in caster.client.images)
			if(findtext(hud.icon_state, "convertible"))
				caster.client.images -= hud

/datum/visioneffect/cult_conversion/process_hud(var/mob/caster)
	..()
	if(!caster.client)
		return
	var/turf/T
	T = get_turf(caster)
	for(var/mob/living/carbon/target in dview(caster.client.view+DATAHUD_RANGE_OVERHEAD, T, INVISIBILITY_MAXIMUM))
		if(!check_HUD_visibility(target, caster))
			continue
		if(target.mind)
			caster.client.images -= target.hud_list[CONVERSION_HUD]
			target.update_convertibility()
			caster.client.images += target.hud_list[CONVERSION_HUD]
