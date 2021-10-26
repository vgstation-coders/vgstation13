#define MALCOLM "Malcolm"
#define REESE "Reese"
#define DEWEY "Dewey"
#define HAL "Hal"
#define LOIS "Lois"

/datum/role/wilkerson
	id = INTHEMIDDLE
	name = INTHEMIDDLE
	plural_name = "wilkersons"
	restricted_jobs = list("AI", "Cyborg", "Mobile MMI")
	special_role = INTHEMIDDLE
	default_admin_voice = "Stevie"
	logo_state = "malcolm-logo"
	var/characterName = null

/datum/role/wilkerson/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	to_chat(antag.current, )


/datum/role/wilkerson/malcolm
	characterName = MALCOLM
	var/turf/theMiddle = null

/datum/role/wilkerson/malcolm/ForgeObjectives()
	AppendObjective(/datum/objective/wilkerson/malcolm)

/datum/role/wilkerson/malcolm/process()
	..()
	if(host && theMiddle)
		var/distMiddle = get_dist(host, theMiddle)
		if(distMiddle <= 2)
			faction.inTheMiddle()
		else if(distMiddle < 100)	//No cheesing malcolm into space or something
			faction.notInTheMiddle()

/datum/role/wilkerson/reese
	characterName = REESE

/datum/role/wilkerson/reese/ForgeObjectives()
	AppendObjective(/datum/objective/wilkerson/malcolm)

/datum/role/wilkerson/dewey
	characterName = DEWEY

/datum/role/wilkerson/reese/ForgeObjectives()
	AppendObjective(/datum/objective/wilkerson/malcolm)

/datum/role/wilkerson/hal
	characterName = HAL

/datum/role/wilkerson/hal/ForceObjectives()
	AppendObjective(/datum/objective/wilkerson/hal)

/datum/role/wilkerson/lois
	characterName = LOIS

/datum/role/wilkerson/lois/ForceObjectives()
	AppendObjective(/datum/objective/wilkerson/lois)
