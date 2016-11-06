//Effects that are used in mapping (various markers, spawners etc.)
/obj/effect/mapping
	name = "mapping effect"
	icon = 'icons/effects/mapping.dmi'
	invisibility = 101

/obj/effect/mapping/playable_mob
	name = "DO NOT USE"
	icon_state = "event_playable"


/obj/effect/mapping/playable_mob/Topic(href,href_list)
	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		var/mob/dead/observer/body = locate(href_list["body"])

		if(!istype(O))
			return

		volunteer(O, body)

/obj/effect/mapping/playable_mob/proc/volunteer(mob/dead/observer/O, mob/living/body)
	//O: observer that is volunteering
	//body: either a mob or a list of mobs. If allow_choosing_
	if(istype(body, /mob/living))
		if(!isnull(body.client))
			to_chat(O, "<span class='info'>The role has already been taken.</span>")
	else
		return

	body.key = O.key
	to_chat(body, "don't metagame, fucker") //todo

/obj/effect/mapping/playable_mob/proc/check_observer(var/mob/dead/observer/O)
	if(O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		return 0
	if(jobban_isbanned(O, "Syndicate")) // Antag-banned
		return 0
	if(!O.client)
		return 0
	if(((O.client.inactivity/10)/60) <= ALIEN_SELECT_AFK_BUFFER) // Filter AFK
		return 1
	return 0


//Team marker: all markers with the same name form a "team"
//Observers are sent a single prompt for every formed team. Example:
//"wild animals": 10 positions found. __Click_here__ to join!
//Joining a team puts you into a random mob

//If you don't want players to be able to select their role, use team markers instead of individual markers
/obj/effect/mapping/playable_mob/team
	name = "wild animals"

	var/list/existing_teams = list()

/obj/effect/mapping/playable_mob/team/spawned_by_map_element(datum/map_element/ME, list/objects)
	.=..()
	//First initialization processes all mob markers and removes them from initialization list (they aren't deleted)
	if(!objects.Find(src))
		return

	//List of team names associated with mobs
	//list( "wild animals" = list(mob,mob) , "hunters" = list(mob,mob,mob) )
	existing_teams = list()

	for(var/obj/effect/mapping/playable_mob/team/T in objects)
		if(!existing_teams.Find(T.name))
			existing_teams[T.name] = list()

		var/list/L = existing_teams[T.name]
		var/mob/living/linked = locate(/mob/living) in get_turf(T)

		L.Add(linked)
		objects.Remove(T)

	to_chat(world, "Set up [existing_teams.len] teams!")
	for(var/team_index in existing_teams)
		var/list/L = existing_teams[team_index]

		for(var/mob/dead/observer/O in player_list)
			to_chat(O, "[team_index] is hiring ([L.len] positions): <a href='?src=\ref[src];signup=\ref[O];body=[existing_teams.Find(team_index)]'>JOIN</a>")

/obj/effect/mapping/playable_mob/team/Topic(href,href_list)
	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		var/team_index = locate(href_list["body"])

		if(!team_index || !istype(O))
			return

		var/list/L = existing_teams[team_index]
		if(!L || !L.len)
			return

		var/mob/living/new_body = pick(L)
		if(!istype(new_body))
			return
		L.Remove(new_body)

		volunteer(O, new_body)

//Individual marker: every marker sends a prompt to every observer. Example:
//"prison guard" position available. __Click_here__ to join as a prison guard.
//"inmate" position available. __Click_here__ to join as an inmate.
/obj/effect/mapping/playable_mob/single
	name = "minor character"

/obj/effect/mapping/playable_mob/single/spawned_by_map_element(datum/map_element/ME, list/objects)
	.=..()

	//Find linked mob and send a message to all observers
	var/mob/living/linked = locate(/mob/living) in get_turf(src)

	for(var/mob/dead/observer/O in player_list)
		to_chat(O, "[src.name] position is available: <a href='?src=\ref[src];signup=\ref[O];body=\ref[linked]'>JOIN</a>")
