/spell/aoe_turf/lightbulb
	name = "Break Lightbulbs"
	desc = "This spell breaks lightbulbs within 7 tiles of you."
	user_type = USER_TYPE_WIZARD
	specialization = UTILITY
	abbreviation = "LB"

	charge_max = 150
	spell_flags = null
	invocation = "EAIS' RAUG"
	invocation_type = SpI_WHISPER
	selection_type = "range"
	range = 7
	inner_radius = -1

	cooldown_min = 50

	hud_state = "blackout"

	price = 0.25 * Sp_BASE_PRICE

/spell/aoe_turf/lightbulb/cast(list/targets)

	for(var/turf/T in targets)
		for(var/obj/machinery/light/L in T)
			L.broken()
			sleep(1)