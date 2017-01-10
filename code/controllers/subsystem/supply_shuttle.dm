var/datum/subsystem/supply_shuttle/SSsupply_shuttle


/datum/subsystem/supply_shuttle
	name       = "Supply Shuttle"
	init_order = SS_INIT_SUPPLY_SHUTTLE
	flags      = SS_NO_TICK_CHECK
	wait       = 30 SECONDS


/datum/subsystem/supply_shuttle/New()
	NEW_SS_GLOBAL(SSsupply_shuttle)


/datum/subsystem/supply_shuttle/Initialize(timeofday)
	for(var/typepath in (typesof(/datum/supply_packs) - /datum/supply_packs))
		var/datum/supply_packs/P = new typepath()
		supply_shuttle.supply_packs[P.name] = P

	..()


/datum/subsystem/supply_shuttle/fire(resumed = FALSE)
	if(supply_shuttle.moving == 1)
		var/ticksleft = supply_shuttle.eta_timeofday - world.timeofday

		if(ticksleft > 0)
			supply_shuttle.eta = round(ticksleft / 600, 1)
		else
			supply_shuttle.eta = 0
			supply_shuttle.send()
