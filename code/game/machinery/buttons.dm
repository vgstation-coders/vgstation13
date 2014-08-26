/obj/machinery/driver_button
	name = "\improper mass driver button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mass driver."
	var/id_tag = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

/obj/machinery/ignition_switch
	name = "\improper ignition switch"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mounted igniter."
	var/id_tag = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

/obj/machinery/flasher_button
	name = "\improper flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	var/id_tag = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

/obj/machinery/crema_switch
	name = "\improper crematorium igniter"
	desc = "Burn baby burn!"
	icon = 'icons/obj/power.dmi'
	icon_state = "crema_switch"
	anchored = 1.0
	req_access = list(access_crematorium)
	var/on = 0
	var/otherarea = null
	var/id = 1

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0