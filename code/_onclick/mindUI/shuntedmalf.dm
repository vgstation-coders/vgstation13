/datum/mind_ui/malf_shunted
	uniqueID = "Shunted Malf"
	sub_uis_to_spawn = list(
		/datum/mind_ui/shunt_bottom_panel
		)


/datum/mind_ui/malf/Valid()
	var/mob/living/silicon/shuntedAI/A = mind.current
	if (!A)
		return FALSE
	if(ismalf(A))
		return TRUE
	return FALSE

////////////////////////////////////////////////////////////////////
//																  //
//							 BOTTOM PANEL   					  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/shunt_bottom_panel
	uniqueID = "Shunt Bottom Panel"
	y = "BOTTOM"
	display_with_parent = TRUE
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/return_to_core,
	)

/obj/abstract/mind_ui_element/hoverable/return_to_core
	name = "Return To Core"
	icon = 'icons/ui/malf/192x48.dmi'
	layer = MIND_UI_BUTTON
	icon_state = "malf_unshunt"
	offset_x = -96

/obj/abstract/mind_ui_element/hoverable/return_to_core/Click()
	var/mob/living/silicon/shuntedAI/S = GetUser()
	if(!istype(S))
		return
	var/atom/A = S.loc
	new /obj/effect/malf_jaunt(get_turf(S), S, get_turf(S.core), TRUE)
	A.update_icon()

/obj/abstract/mind_ui_element/hoverable/return_to_core/UpdateIcon()
	var/mob/living/silicon/shuntedAI/A = GetUser()
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return
	if(icon_state == "[base_icon_state]-hover")
		return
	if (A.core && !(A.core.stat & DEAD))
		color = null
		icon_state = "malf_unshunt"
	else
		color = null
		icon_state = "malf_unshunt_blocked"


/obj/abstract/mind_ui_element/hoverable/return_to_core/StartHovering()
	if (color == null && icon_state == "malf_unshunt")
		..()