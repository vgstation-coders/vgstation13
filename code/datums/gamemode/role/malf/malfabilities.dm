/datum/malf_module
	var/name = "Malf Module"
	var/desc = "This does something."
	var/icon_state = "placeholder"

	var/mob/living/silicon/ai/malf 

/datum/malf_module/New(var/mob/living/silicon/ai/A)
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M) || !A.mind)
		return
	M.purchased_modules += src
	malf = A
	on_purchase()
	return TRUE

/datum/malf_module/proc/on_purchase()
	return

/datum/malf_module/active
	var/activate_cost

/datum/malf_module/active/proc/activate()
	return

/datum/malf_module/active/New(var/mob/living/silicon/ai/A)
	if(!..())
		return
	var/datum/mind_ui/malf_top_panel/malfUI = malf.mind.activeUIs["Malf Top Panel"]
	if(!istype(malfUI))
		return
	
	var/obj/abstract/mind_ui_element/hoverable/malf_power/E = new /obj/abstract/mind_ui_element/hoverable/malf_power(null, malfUI, src)
	malfUI.elements += E
	malfUI.SortPowers()
	malfUI.SendToClient()
	malfUI.Display()


/datum/malf_module/active/coreshield
	name = "Firewall"
	desc = "Deploy a firewall to reduce damage to your core."
	icon_state = "firewall"
	activate_cost = 5


/datum/malf_module/active/coreshield/on_purchase()
	malf.vis_contents += new /obj/effect/overlay/ai_shield

/datum/malf_module/active/coreshield/activate()
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