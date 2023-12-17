//The infamous, legendary hud that lets you see who's valid... antag hud!
//This will display over all other HUDs currently implemented
//Very spoilery, use only as an admin or if someone is completely out of the round

/datum/visioneffect/antag
	name = "antag hud"
	priority = 1

/datum/visioneffect/antag/on_clean_up(var/mob/M)
	..()
	if(!M)
		return
	if(M.client)
		for(var/image/hud in M.client.images)
			if(findtext(hud.icon_state, "-logo"))
				M.client.images -= hud

/datum/visioneffect/antag/process_hud(var/mob/M)
	if(!M.client)
		return
	var/client/C = M.client
	var/turf/T
	T = get_turf(M)
	for(var/mob/living/target in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(target.mind && (target.mind.antag_roles.len > 0 || issilicon(target) || target.hud_list[SPECIALROLE_HUD]) )
			M.client.images -= target.hud_list[SPECIALROLE_HUD]
			var/icon/I_base = new

			var/F = 1
			for(var/R in target.mind.antag_roles)
				var/datum/role/role = target.mind.antag_roles[R]
				var/icon/J = icon('icons/role_HUD_icons.dmi',role.logo_state)
				I_base.Insert(J,null,frame = F, delay = 10/target.mind.antag_roles.len)
				F++

			var/image/I = image(I_base)
			I.loc = target
			I.appearance_flags |= RESET_COLOR|RESET_ALPHA
			I.pixel_x = 20 * PIXEL_MULTIPLIER
			I.pixel_y = 20 * PIXEL_MULTIPLIER
			I.plane = ANTAG_HUD_PLANE
			target.hud_list[SPECIALROLE_HUD] = I
			M.client.images += I

		if(issilicon(target))//If the silicon mob has no law datum, no inherent laws, or a law zero, add them to the hud.
			var/mob/living/silicon/silicon_target = target
			if(!silicon_target.laws||(silicon_target.laws&&(silicon_target.laws.zeroth||!silicon_target.laws.inherent.len))||silicon_target.mind.special_role=="traitor")
				if(isrobot(silicon_target))//Different icons for robutts and AI.
					M.client.images += image('icons/mob/hud.dmi',silicon_target,"hudmalborg")
				else
					M.client.images += image('icons/mob/hud.dmi',silicon_target,"hudmalai")
