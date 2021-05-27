
/datum/event/viral_infection
	var/level = 0

/datum/event/viral_infection/can_start(var/list/active_with_role)
	if(active_with_role["Medical"] > 1)
		return 40
	return 0

/datum/event/viral_infection/setup()
	announceWhen = rand(0, 300)
	endWhen = announceWhen + 1

/datum/event/viral_infection/announce()
	biohazard_alert(level)

/datum/event/viral_infection/start()
	var/datum/disease2/disease/D = get_random_weighted_disease(WINFECTION)

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

	level = clamp(round((D.get_total_badness()+1)/2),1,8)

	spread_disease_among_crew(D,"Minor Outbreak")
