/spell/aoe_turf/lightbulb
	name = "Break Lightbulbs"
	desc = "Breaks the lightbulbs around you."
	user_type = USER_TYPE_WIZARD
	abbreviation = "LB"

	charge_max = 300
	spell_flags = null
	invocation = "EAIS' RAUG"
	invocation_type = SpI_WHISPER
	selection_type = "range"
	range = 6
	inner_radius = -1

	cooldown_min = 150

	hud_state = "blackout"

	price = 0.5 * Sp_BASE_PRICE

/spell/aoe_turf/lightbulb/cast(list/targets)

	for(var/turf/T in targets)
		for(var/obj/machinery/light/L in T)
			L.broken()
			sleep(1)

