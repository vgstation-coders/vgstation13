/datum/component/ai/hand_control/Initialize()
	..()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_DROP, .proc/on_command_drop)
	RegisterSignal(parent, COMSIG_ACTVHANDBYITEM, .proc/on_command_activate_hand_by_item)
	RegisterSignal(parent, COMSIG_THROWAT, .proc/on_command_throw_at)
	RegisterSignal(parent, COMSIG_ACTVEMPTYHAND, .proc/on_command_activate_empty_hand)
	RegisterSignal(parent, COMSIG_ITMATKSELF, .proc/on_command_active_item_attack_self)
	RegisterSignal(parent, COMSIG_EQUIPACTVHAND, .proc/on_command_equip_active_hand)

/datum/component/ai/hand_control/proc/on_command_drop()
	var/mob/living/carbon/M = parent
	if(M.get_active_hand())
		M.drop_item()

/datum/component/ai/hand_control/proc/on_command_activate_hand_by_item(var/obj/item/target)
	var/mob/living/carbon/M = parent
	for(var/j = 1 to M.held_items.len)
		if(M.held_items[j] == target)
			M.active_hand = j
			break

/datum/component/ai/hand_control/proc/on_command_activate_empty_hand()
	var/mob/living/carbon/M = parent
	for(var/j = 1 to M.held_items.len)
		if(M.held_items[j] == null)
			M.active_hand = j
			break

/datum/component/ai/hand_control/proc/on_command_throw_at(var/atom/target)
	var/mob/living/carbon/M = parent
	M.throw_mode_on()
	M.ClickOn(target)
	M.throw_mode_off()

/datum/component/ai/hand_control/proc/on_command_active_item_attack_self()
	var/mob/living/carbon/M = parent
	var/obj/item/I = M.get_active_hand()
	if(I)
		I.attack_self(M)

/datum/component/ai/hand_control/proc/on_command_equip_active_hand()
	var/mob/living/carbon/M = parent
	var/obj/item/I = M.get_active_hand()
	if(I)
		M.equip_to_appropriate_slot(I)
