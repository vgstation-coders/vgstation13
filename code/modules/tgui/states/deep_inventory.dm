 /**
  * tgui state: deep_inventory_state
  *
  * Checks that the src_object is in the user's deep (backpack, box, toolbox, etc) inventory.
 **/

/var/datum/ui_state/deep_inventory_state/deep_inventory_state = new

/datum/ui_state/deep_inventory_state/can_use_topic(src_object, mob/user)
	if(!locate(src_object) in user)
		return UI_CLOSE
	return user.shared_ui_interaction(src_object)
