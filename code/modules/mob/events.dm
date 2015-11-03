/mob
	var/event/on_update_icons // Called when update_icons() gets called.
	var/event/on_stun // Called when the mob gets stunned (AFTER the stun gets applied, but before canmove gets updated).
	var/event/on_weaken // Called when the mob gets weakened (AFTER the weakening gets applied, but before canmove gets updated).

/mob/New()
	. = ..()
	on_update_icons	= new("owner" = src)
	on_stun			= new("owner" = src)
	on_weaken		= new("owner" = src)

/mob/Destroy()
	. = ..()
	qdel(on_update_icons)
	on_update_icons = null

	qdel(on_stun)
	on_stun = null

	qdel(on_weaken)
	on_weaken = null

