/*
/datum/malf_module
	var/mob/living/silicon/ai/malf 
	var/cost = 10
	var/name = "Malf Module"
	var/desc = "This does something."
	var/bought = FALSE

/datum/malf_module/New(var/mob/living/silicon/ai/A)
	malf = A


/datum/malf_module/proc/purchase()
	if(bought)
		return
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	on_purchase()
	M.add_power(-cost)
	bought = TRUE

/datum/malf_module/proc/on_purchase()
	return
*/
/*
/datum/malf_module/active
	var/icon_state = "placeholder"
	var/activate_cost
	var/is_toggle = FALSE
	
/datum/malf_module/active/proc/activate()
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!istype(malf) || !istype(M))
		return FALSE
	if(M.processing_power >= activate_cost)
		M.add_power(-activate_cost)
		return TRUE
	return FALSE


/datum/malf_module/active/on_purchase()
	var/datum/mind_ui/malf_top_panel/malfUI = malf.mind.activeUIs["Malf Top Panel"]
	if(!istype(malfUI))
		return
	
	var/obj/abstract/mind_ui_element/hoverable/malf_power/E
	if(is_toggle)
		E = new /obj/abstract/mind_ui_element/hoverable/malf_power/toggle(null, malfUI, src)
	else
		E = new /obj/abstract/mind_ui_element/hoverable/malf_power(null, malfUI, src)
	E.offset_x = malfUI.current_offset
	E.UpdateUIScreenLoc()
	malfUI.elements += E
	malfUI.current_offset += 40
	malfUI.SendToClient()
	malfUI.Display()
*/

//------------------------------------------------
/*
/datum/malf_module/active/coreshield
	name = "Firewall"
	desc = "Deploy a firewall to reduce damage to your core and make it immune to lasers."
	icon_state = "firewall"
	activate_cost = 5
	is_toggle = TRUE

/datum/malf_module/active/coreshield/on_purchase()
	..()
	malf.vis_contents += new /obj/effect/overlay/ai_shield

/datum/malf_module/active/coreshield/activate()
	if(!..())
		return
	var/obj/effect/overlay/ai_shield/shield
	shield = locate(/obj/effect/overlay/ai_shield) in malf.vis_contents
	if(malf.ai_flags & COREFORTIFY)
		if(shield)
			shield.lower()
		malf.ai_flags &= ~COREFORTIFY
	else
		if(shield)
			shield.raise()
		malf.ai_flags |= COREFORTIFY
	playsound(malf, 'sound/machines/poddoor.ogg', 60, 1)
	to_chat(malf, "<span class='warning'>[malf.ai_flags & COREFORTIFY ? "Firewall Activated" : "Firewall Deactivated"].</span>")
*/
