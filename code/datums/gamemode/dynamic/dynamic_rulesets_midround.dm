
//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/autotraitor
	name = "Syndicate Sleeper Agent"
	role_category = ROLE_TRAITOR
	restricted_from_jobs = list("Cyborg","Mobile MMI","Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_candidates = 1
	weight = 5
	cost = 5
	requirements = list(40,30,20,10,10,10,10,10,10,10)

/datum/dynamic_ruleset/midround/autotraitor/acceptable(var/population=0,var/threat=0)
	var/player_count = mode.living_players.len
	var/antag_count = mode.living_antags.len
	var/max_traitors = round(player_count / 10) + 1
	if ((antag_count < max_traitors) && prob(mode.threat_level))//adding traitors if the antag population is getting low
		return ..()
	else
		return 0

/datum/dynamic_ruleset/midround/autotraitor/trim_candidates()
	..()
	for(var/mob/living/player in living_players)
		if(player.z == map.zCentcomm)
			living_players -= player//we don't autotator people on Z=2
			continue
		if(player.mind && (player.mind.antag_roles.len > 0))
			living_players -= player//we don't autotator people with roles already

/datum/dynamic_ruleset/midround/autotraitor/execute()
	var/mob/M = pick(living_players)
	assigned += M
	candidates -= M
	var/datum/role/traitor/newTraitor = new
	newTraitor.AssignToRole(M.mind,1)
	newTraitor.OnPostSetup(FALSE)
	newTraitor.Greet(GREET_AUTOTATOR)
	return 1
