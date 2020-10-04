/spell/targeted/watertowine
	name = "Water to Wine"
	desc = "Turns all water in a container into wine."
	abbreviation = "WtW"

	school = "evocation"
	invocation = "Th's'n"
	invocation_type = SpI_WHISPER
	range = 7
	spell_flags = GHOSTCAST|STATALLOWED|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "bucket"
	var/convert_from_type = /datum/reagent/water
	var/convert_to_type = /datum/reagent/ethanol/drink/wine

/spell/targeted/watertowine/cast(var/list/targets, mob/user)
	for(var/atom/A in targets)
		var/datum/reagents/thereagents = A.reagents
		thereagents.convert_some_of_type(convert_from_type,convert_to_type, 1000)
