/datum/event/viral_infection

/datum/event/viral_infection/can_start(var/list/active_with_role)
	if(active_with_role["Medical"] > 1)
		return 40
	return 0

/datum/event/viral_infection/setup()
	announceWhen = rand(0, 300)
	endWhen = announceWhen + 1

/datum/event/viral_infection/announce()
	biohazard_alert_minor()

/datum/event/viral_infection/start()
	var/virus_choice = pick(subtypesof(/datum/disease2/disease) - /datum/disease2/disease/prion)
	var/datum/disease2/disease/D = new virus_choice

	var/list/anti = list(
		ANTIGEN_BLOOD	= 1,
		ANTIGEN_COMMON	= 1,
		ANTIGEN_RARE	= 2,
		ANTIGEN_ALIEN	= 0,
		)
	var/list/bad = list(
		EFFECT_DANGER_HELPFUL	= 0,
		EFFECT_DANGER_FLAVOR	= 1,
		EFFECT_DANGER_ANNOYING	= 2,
		EFFECT_DANGER_HINDRANCE	= 3,
		EFFECT_DANGER_HARMFUL	= 1,
		EFFECT_DANGER_DEADLY	= 0,
		)
	D.origin = "Minor Outbreak"

	D.makerandom(list(50,90),list(50,90),anti,bad,src)

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
		candidate.infect_disease2(D,1, "Minor Outbreak")
