
datum/event/viral_outbreak

/datum/event/viral_outbreak/can_start(var/list/active_with_role)
	if(active_with_role["Medical"] > 1)
		return 25
	return 0

datum/event/viral_outbreak/setup()
	announceWhen = rand(0, 3000)
	endWhen = announceWhen + 1

datum/event/viral_outbreak/announce()
	biohazard_alert_major()

datum/event/viral_outbreak/start()
	var/virus_choice = pick(subtypesof(/datum/disease2/disease) - /datum/disease2/disease/bacteria)
	var/datum/disease2/disease/D = new virus_choice

	var/list/anti = list(
		ANTIGEN_BLOOD	= 0,
		ANTIGEN_COMMON	= 1,
		ANTIGEN_RARE	= 2,
		ANTIGEN_ALIEN	= 2,
		)
	var/list/bad = list(
		EFFECT_DANGER_HELPFUL	= 0,
		EFFECT_DANGER_FLAVOR	= 1,
		EFFECT_DANGER_ANNOYING	= 1,
		EFFECT_DANGER_HINDRANCE	= 1,
		EFFECT_DANGER_HARMFUL	= 2,
		EFFECT_DANGER_DEADLY	= 3,
		)
	D.origin = "Major Outbreak"

	D.makerandom(list(80,100),list(60,100),anti,bad,src)

	var/list/candidates = list()
	for(var/mob/living/candidate in player_list)
		if(candidate.z == STATION_Z && candidate.client && candidate.stat != DEAD && candidate.can_be_infected() && candidate.immune_system.CanInfect(D))
			candidates += candidate

	if(!candidates.len)
		return

	var/infected = 1 + round(candidates.len/10)

	for (var/i = 1 to infected)
		var/mob/living/candidate = pick(candidates)
		candidates -= candidate
		candidate.infect_disease2(D,1, "Major Outbreak")
