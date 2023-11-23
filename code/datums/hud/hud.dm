/*
hud.dm
A datum that defines huds and how to implement them with respect to the mob types and one another.

*/

/datum/hud
	var/name
	var/vision_flags = 0 //Contains SEE_TURFS, SEE_MOBS, SEE_OBJS

	//This SETS mob.see_in_dark, so it will replace the owner's vision if it is better
	//Humans have 2 by default (1 = themselves, 2 = them+1 tile around them)
	var/see_in_dark = 0

	//This MODIFIES mob.see_in_dark, so it will modify whatever see_in_dark the mob has. This applies after the above setting.
	//Sunglasses will modify this by -1 for example.
	var/darkness_view = 0

	var/see_invisible = 0
	var/seedarkness = TRUE

/datum/hud/proc/process_hud(var/mob/M)
	if(!M)
		return
	if(!M.client)
		return

/*
Helper procs and procs used in mobs
*/

//General mob HUD processing
/mob/proc/regular_hud_updates()
	clean_up_hud()
	handle_hud_vision_updates()

//Handles HUD Cleanup
/mob/proc/clean_up_hud()
	//Reset the HUDs for all mobs before redrawing them.
	if(client)
		for(var/image/hud in client.images)
			if(findtext(hud.icon_state, "hud", 1, 4))
				client.images -= hud
	//Maintain a list of security and medical HUD users for easy access to medbot/beepsky messages
	//Move this to the glasses themselves, not a HUD feature?
	if(src in med_hud_users)
		med_hud_users -= src
	if(src in sec_hud_users)
		sec_hud_users -= src

//Checks what HUDs the mob has and applies their effects
/mob/proc/handle_hud_vision_updates()
	for(var/datum/hud/H in huds)
		H.process_hud(src)

//This is the current life.dm proc to handle glasses behavior
/mob/proc/handle_glasses_vision_updates(var/obj/item/clothing/glasses/G)
	if(istype(G))
		if(G.see_in_dark)
			see_in_dark = max(see_in_dark, G.see_in_dark)
		see_in_dark += G.darkness_view
		if(G.vision_flags) //MESONS
			change_sight(adding = G.vision_flags)
			if(!druggy)
				see_invisible = SEE_INVISIBLE_MINIMUM
		if(G.see_invisible)
			see_invisible = G.see_invisible

	seedarkness = G.seedarkness
	update_darkness()



//Helper proc to determine if someone is visible to the HUD systems
/proc/check_HUD_visibility(var/atom/target, var/mob/user)
	if (user in confusion_victims)
		return FALSE
	if(user.see_invisible < target.invisibility)
		return FALSE
	if(target.alpha <= 1)
		return FALSE
	if(ismob(target))
		var/mob/M = target
		for(var/i in M.alphas)
			if(M.alphas[i] <= 1)
				return FALSE
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		for(var/i in C.body_alphas)
			if(C.body_alphas[i] <= 1)
				return FALSE
	return TRUE
