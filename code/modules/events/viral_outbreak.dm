
/datum/event/viral_outbreak
	var/level = 0

/datum/event/viral_outbreak/can_start(var/list/active_with_role)
	if(active_with_role["Medical"] > 1)
		return 25
	return 0

/datum/event/viral_outbreak/setup()
	announceWhen = rand(0, 3000)
	endWhen = announceWhen + 1

/datum/event/viral_outbreak/announce()
	biohazard_alert(level)

/datum/event/viral_outbreak/start()
	var/datum/disease2/disease/D = get_random_weighted_disease(WOUTBREAK)

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

	level = clamp(round((D.get_total_badness()+1)/2),1,8)

	spread_disease_among_crew(D,"Major Outbreak")
