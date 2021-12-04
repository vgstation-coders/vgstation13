//This could either be split into the proper DM files or placed somewhere else all together, but it'll do for now -Nodrak

/*

A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message. //WHY

*/



// PRESET UPLINKS
// A collection of preset uplinks.
/obj/item/device/radio/uplink
	icon_state = "radio"

/obj/item/device/radio/uplink/New()
	..()
	add_component(/datum/component/uplink)

/obj/item/device/radio/uplink/nukeops/New()
	..()
	var/datum/component/uplink/uplink_component = get_component(/datum/component/uplink)
	uplink_component.telecrystals = 80
	uplink_component.locked = FALSE
	uplink_component.lockable = FALSE
	uplink_component.nuke_ops_inventory = TRUE

/obj/item/device/multitool/uplink/New()
	..()
	var/datum/component/uplink/uplink_comp = add_component(/datum/component/uplink)
	uplink_comp.lockable = FALSE
	uplink_comp.locked = FALSE

/obj/item/device/radio/headset/uplink/New()
	..()
	add_component(/datum/component/uplink)
