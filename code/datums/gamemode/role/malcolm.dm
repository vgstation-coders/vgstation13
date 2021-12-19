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

/datum/role/wilkerson/malcolm/ForgeObjectives()
	AppendObjective(/datum/objective/wilkerson/malcolm)

/datum/role/wilkerson/malcolm/process()
	if(host && istype(host, /mob/living/carbon/monkey/malcolm))
		var/mob/living/carbon/monkey/malcolm/M = host
		var/distMiddle = get_dist(M, M.theMiddle)
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


//HAL AND LOIS///////
/datum/role/wilkerson/parents
	var/wilkWepType = /obj/item/weapon/gun/hookshot/whip/wilkerson

/datum/role/wilkerson/parents/process()
	if(host && host.stat)
		parentRevive()

/datum/role/wilkerson/parents/proc/parentRevive()
	var/datum/faction/wilkersons/wFac = faction
	var/turf/revT = null
	if(characterName == HAL)
		revT = get_turf(pick(wFac.halBeacons))
	if(characterName == LOIS)
		revT = get_turf(pick(wFac.loisBeacons))
	if(revT)
		parentEggHatch(revT)

/datum/role/wilkerson/parents/proc/parentEggHatch(var/turf/revT)
	var/obj/effect/ourEgg = new /obj/effect/wilkersonEgg(revT)
	host.forceMove(ourEgg)
	animate(ourEgg, transform = matrix()*5, time = 10 SECONDS)
	spawn(10 SECONDS)
		playsound(ourEgg, 'sound/effects/squelch1.ogg', 100, 1)
		host.forceMove(revT)
		host.rejuvinate(1)
		host.wilkersonOutfit()
		visible_message("<span class='warning'>\The [ourEgg] hatches!</span>")
		new /obj/effect/decal/cleanable/egg_smudge(revT)
		if(host.loc != ourEgg)	//Just in case
			qdel(ourEgg)

/datum/role/wilkerson/parents/proc/wilkersonOutfit()
	var/obj/item/ourWep = new wilkWepType(get_turf(host))
	host.put_in_hands(ourWep)
	new /obj/item/weapon/storage/pill_bottle/wilkerson(get_turf(host))
	new /obj/item/weapon/storage/backpack(get_turf(host))

/datum/role/wilkerson/parents/hal
	characterName = HAL
	wilkWepType = /obj/item/weapon/gun/hookshot/whip/wilkerson/hal

/datum/role/wilkerson/hal/ForceObjectives()
	AppendObjective(/datum/objective/wilkerson/hal)

/datum/role/wilkerson/parents/lois
	characterName = LOIS
	wilkWepType = /obj/item/weapon/gun/hookshot/whip/wilkerson/lois

/datum/role/wilkerson/lois/ForceObjectives()
	AppendObjective(/datum/objective/wilkerson/lois)
