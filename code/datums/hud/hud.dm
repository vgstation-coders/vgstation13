/*
hud.dm
A datum that defines hud-like in-character vision effects and how to implement them with respect each other.
To use, add an instance to mob/list/huds via mob/proc/apply_hud(/datum/visioneffect/yourchoicehere)
*/

/datum/visioneffect
	var/name
	var/vision_flags = 0 //Contains SEE_TURFS, SEE_MOBS, SEE_OBJS

	//This SETS mob.see_in_dark, so it will replace the owner's vision if it is better
	//Humans have 2 by default (1 = themselves, 2 = them+1 tile around them)
	var/see_in_dark = 0

	//This MODIFIES mob.see_in_dark, so it will modify whatever see_in_dark the mob has. This applies after the above setting.
	//Sunglasses will modify this by -1 for example.
	var/darkness_view = 0

	var/see_invisible = 0
	var/eyeprot = 0
	var/my_dark_plane_alpha_override = null
	var/my_dark_plane_alpha_override_value = 0

	//Determines order of rendering. Equal numbers are rendered in order of application.
	//Higher numbers are rendered later, so if you need your HUD on top at all costs, give it an ARBITARILY_HIGH_NUMBER
	//Currently, almost all implemented datums use 0 and will simply draw in order of application
	var/priority = 0

//process_hud is what the effect should do each time life.dm updates vision
//or vision is otherwise manually updated (such as equipping hudglasses)
/datum/visioneffect/proc/process_hud(var/mob/M)
	if(!M)
		return
	if(!M.client)
		return

//This handles the dark_plane and the related alpha overrides for it over in human.dm
/datum/visioneffect/proc/process_update_perception(var/mob/M)
	if(!M)
		return
	if(!M.client)
		return

//on_apply occurs whenever the visioneffect is first applied to the mob
/datum/visioneffect/proc/on_apply(var/mob/M)
	if(!M)
		return
	if(!M.client)
		return

//on_remove occurs whenever the visioneffect is removed from the mob
/datum/visioneffect/proc/on_remove(var/mob/M)
	if(!M)
		return
	if(!M.client)
		return
	on_clean_up(M)

//on_clean_up handles any special cleanup that has to happen with a hud
/datum/visioneffect/proc/on_clean_up(var/mob/M)
	if(!M)
		return
	if(!M.client)
		return

/*
Helper procs and procs used in mobs
*/
//Sorted by number, ascending
//These visioneffects are drawn in order of the hud list on the mob, first to last.
//They are drawn right on top of each other, so the last ones drawn will be on top.
//So, use a higher priority number to have your effect show up on top.
/proc/sort_visioneffect_priority(var/datum/visioneffect/new_item, var/datum/visioneffect/current_item)
	return new_item.priority < current_item.priority

//A new subtype of images used specifically for these visioneffects
/image/hud

//Handle specific on-apply effects. Useful mainly for scanners like Mesons
/mob/proc/apply_hud(var/datum/visioneffect/V)
	if(!(V in huds)) //Prevent basic dupes of HUD instances
		sorted_insert(huds, V, /proc/sort_visioneffect_priority)
	V.on_apply(src)
	regular_hud_updates()

//Clean up certain HUDs with permanent non-on-update effects, like Mesons
/mob/proc/remove_hud(var/datum/visioneffect/V)
	huds -= V
	V.on_remove(src)
	regular_hud_updates()

//Helper proc for in game admins throwing huds on people
//And for when you want to add a new visioneffect but you don't care about the datum itself
/mob/proc/apply_hud_by_type(type)
	if(!ispath(type, /datum/visioneffect))
		return
	var/datum/visioneffect/V = new type
	sorted_insert(huds, V, /proc/sort_visioneffect_priority)
	V.on_apply(src)
	regular_hud_updates()

//Helper proc to clear out a type of hud on a mob
//Note: This will clear ALL instances, including equipment/organs that provide a visioneffect
/mob/proc/remove_hud_by_type(type)
	for(var/V in huds)
		if(istype(V, type))
			remove_hud(V)
	regular_hud_updates()


//General mob HUD processing proc, call this for any mob that uses vision effects/huds
//This is generally expected to be called on a mob's life.dm proc and when an effect is added/removed
/mob/proc/regular_hud_updates()
	clean_up_hud()
	handle_hud_vision_updates()

//Handles HUD Cleanup
//Called every life.dm tick, or whenever visionupdates need to be updated.
//The HUD is redrawn every tick for reasons
/mob/proc/clean_up_hud()
	//Reset the HUDs for all mobs before redrawing them.
	if(client)
		for(var/image/hud/result in client.images)
			client.images -= result
	for(var/datum/visioneffect/V in huds)
		V.on_clean_up(src)
	//Maintain a list of security and medical HUD users for easy access to medbot/beepsky messages
	//Move this to the glasses themselves, not a HUD feature?
	if(src in med_hud_users)
		med_hud_users -= src
	if(src in sec_hud_users)
		sec_hud_users -= src

//Checks what HUDs the mob has and applies their effects
/mob/proc/handle_hud_vision_updates()
	for(var/datum/visioneffect/V in huds)
		V.process_hud(src)

//Handles HUD special vision effects such as see_in_dark. Has to be handled after the vision updates above.
/mob/proc/handle_vision_effect_updates()
	for(var/datum/visioneffect/V in huds)
		if(V.see_in_dark)
			see_in_dark = max(see_in_dark, V.see_in_dark)
		see_in_dark += V.darkness_view
		if(V.vision_flags) //MESONS
			change_sight(adding = V.vision_flags)
			//if(!druggy)
			//	see_invisible = SEE_INVISIBLE_MINIMUM
		if(V.see_invisible)
			if(see_invisible < V.see_invisible)
				see_invisible = V.see_invisible
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
