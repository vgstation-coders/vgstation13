// Defers MouseEntered inputs to only apply to the most recently hovered over atom in the tick
// Ported from TGStation.

var/datum/subsystem/mouse_entered/SSmouse_entered

/datum/subsystem/mouse_entered
	name = "MouseEntered"
	priority = FIRE_PRIORITY_MOUSE_ENTERED
	wait = 1
	flags = SS_NO_INIT | SS_TICKER | SS_FIRE_IN_LOBBY

	var/list/hovers = list()

/datum/subsystem/mouse_entered/New()
	NEW_SS_GLOBAL(SSmouse_entered)

/datum/subsystem/mouse_entered/fire(resumed)
	for(var/hovering_client in hovers)
		var/atom/hovered_atom = hovers[hovering_client]
		if(isnull(hovered_atom))
			continue

		hovered_atom.on_mouse_enter(hovering_client)

		// This intentionally runs `= null` and not `-= hovering_client`, as we want to prevent the list from shrinking,
		// which could cause problems given the heat of MouseEntered.
		// Lummox has teased this for 515: https://www.byond.com/forum/post/2621745
		// ...though you're most likely reading this on BYOND version 600.
		hovers[hovering_client] = null
