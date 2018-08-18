/obj/item/clothing/accessory/holomap_chip/syndicate_robot
	name = "syndicate robot holomap chip"
	marker_prefix = "robot"
	holomap_filter = HOLOMAP_FILTER_NUKEOPS
	holomap_color = "#13B40B"
	actions_types = list(/datum/action/item_action/toggle_minimap/robot)

/datum/action/item_action/toggle_minimap/robot
	icon_icon = 'icons/obj/clothing/accessories.dmi'
	button_icon_state = "holochip_op"

/datum/action/item_action/toggle_minimap/robot/Trigger()
	var/obj/item/clothing/accessory/holomap_chip/syndicate_robot/HC = target
	if(!istype(HC))
		return
	HC.togglemap()

/obj/item/clothing/accessory/holomap_chip/syndicate_robot/togglemap()
	if(usr.isUnconscious())
		return

	if(!isrobot(usr))
		to_chat(usr, "<span class='warning'>Only robots can use this device.</span>")
		return

	var/mob/living/silicon/robot/R = usr

	if(activator)
		deactivate_holomap()
		to_chat(R, "<span class='notice'>You disable the holomap.</span>")
	else
		activator = R
		processing_objects.Add(src)
		process()
		to_chat(R, "<span class='notice'>You enable the holomap.</span>")

/obj/item/clothing/accessory/holomap_chip/syndicate_robot/handle_sanity(var/turf/T)
	if((!activator) || (!isrobot(loc)) || (!activator.client) || (holoMiniMaps[T.z] == null))
		return FALSE
	return TRUE