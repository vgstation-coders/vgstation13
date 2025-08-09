/spell/aoe_turf/lightbulb
	name = "Break Lightbulbs"
	desc = "This spell breaks lightbulbs within 7 tiles of you."
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	abbreviation = "LB"

	charge_cooldown_max = 15 SECONDS
	spell_flags = null
	invocation = "EAIS' RAUG"
	invocation_type = SP_INV_WHISPER
	selection_type = "range"
	range = 7
	inner_radius = -1

	cooldown_min = 5 SECONDS

	hud_state = "blackout"

	price = 0.25 * SP_BASE_PRICE

/spell/aoe_turf/lightbulb/cast(list/targets)

	for(var/turf/T in targets)
		for(var/obj/machinery/light/L in T)
			L.broken()
			sleep(1)