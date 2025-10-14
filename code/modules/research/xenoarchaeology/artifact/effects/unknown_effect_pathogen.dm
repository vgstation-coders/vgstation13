
/datum/artifact_effect/pathogen
	effecttype = "pathogen"
	valid_artifact_styles = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_PRECURSOR)
	effect = ARTIFACT_EFFECT_PULSE
	var/datum/disease2/disease/pathogen
	effect_hint = EFFECT_HINT_ATOMIC_SYNTHESIS

/datum/artifact_effect/pathogen/New()
	..()

	var/virus_choice = pick(subtypesof(/datum/disease2/disease) - typesof(/datum/disease2/disease/predefined))
	pathogen = new virus_choice

	var/list/anti = list(
		ANTIGEN_BLOOD	= 0,
		ANTIGEN_COMMON	= 0,
		ANTIGEN_RARE	= 0,
		ANTIGEN_ALIEN	= 1,
		)
	var/list/bad = list(
		EFFECT_DANGER_HELPFUL	= 0,
		EFFECT_DANGER_FLAVOR	= 0,
		EFFECT_DANGER_ANNOYING	= 0,
		EFFECT_DANGER_HINDRANCE	= 0,
		EFFECT_DANGER_HARMFUL	= 0,
		EFFECT_DANGER_DEADLY	= 1,
		)

	pathogen.origin = "Xenoarch Artifact"

	pathogen.makerandom(list(60,100),list(75,100),anti,bad,null)

/datum/artifact_effect/pathogen/DoEffectPulse()
	if(holder)

		var/list/L = list()
		L["[pathogen.uniqueID]-[pathogen.subID]"] = pathogen

		for (var/i = 1 to max(1,round(chargelevelmax/20)))
			new /obj/effect/pathogen_cloud/core(get_turf(holder), null, virus_copylist(L), FALSE)

		return 1
