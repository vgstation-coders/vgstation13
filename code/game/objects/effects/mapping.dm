//Effects that are used in mapping (various markers, spawners etc.)
/obj/effect/mapping
	name = "mapping effect"
	icon = 'icons/effects/mapping.dmi'
	invisibility = 101

/obj/effect/mapping/playable_mob
	name = "DO NOT USE"
	icon_state = "event_playable"

	var/role_description = null
	var/list/allowed_mobs = list()

/obj/effect/mapping/playable_mob/proc/notify_observer(mob/dead/observer/O)
	return

/obj/effect/mapping/playable_mob/proc/link_mob(mob/living/L)
	allowed_mobs.Add(L)
	L.on_destroyed.Add(src, "check_mobs")

//Remove references, allowing the mob to be garbage collected on deletion
/obj/effect/mapping/playable_mob/proc/check_mobs()
	for(var/mob/living/L in allowed_mobs)
		if(isnull(L.loc))
			allowed_mobs.Remove(L)

/obj/effect/mapping/playable_mob/Topic(href,href_list)
	if(href_list["signup"])
		var/client/C = get_client_by_ckey(href_list["signup"])
		if(!istype(C) || (C.ckey != usr.ckey))
			return

		var/mob/dead/observer/O = C.mob
		var/mob/dead/observer/body = locate(href_list["body"])

		if(!check_observer(O))
			return

		volunteer(O, body)
	if(href_list["teleport"])
		var/mob/dead/observer/O = locate(href_list["teleport"])

		if(!check_observer(O))
			return

		O.forceMove(get_turf(src))

/obj/effect/mapping/playable_mob/proc/volunteer(mob/dead/observer/O, mob/living/body)
	//O: observer that is volunteering
	//body: mob

	if(istype(body, /mob/living))
		if(!isnull(body.client))
			to_chat(O, "<span class='info'>The role has already been taken.</span>")
			return
		if(!allowed_mobs.Find(body))
			to_chat(O, "<span class='info'>The role is no longer available.</span>")
			return
	else
		return

	body.key = O.key
	message_admins("<span class='adminnotice'>[key_name(usr)] has joined the role [src.name] ([formatJumpTo(get_turf(body))])</span>")
	to_chat(body, {"<span class='userdanger'>Unless specified otherwise, you forget all the information about the round that you've gained from your previous character(s).
	Using such knowledge will lead to a ban.</span>"})
	if(role_description)
		to_chat(body, "<span class='info'>Additional information about the role:</span>")
		to_chat(body, "[role_description]")
	else
		to_chat(body, "<span class='info'>No additional information about the role has been provided.</span>")

/obj/effect/mapping/playable_mob/proc/check_observer(var/mob/dead/observer/O)
	if(!istype(O))
		to_chat(O, "<span class='info'>You must be a ghost to do this.</span>")
		return 0
	if(O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		to_chat(O, "<span class='info'>You are unable to do this because you enabled antagHUD.</span>")
		return 0
	if(jobban_isbanned(O, "Syndicate")) // Antag-banned
		to_chat(O, "<span class='info'>You are unable to do this because you are banned from antagonist roles.</span>")
		return 0
	if(!O.client)
		return 0
	if(!O.client.is_afk(ALIEN_SELECT_AFK_BUFFER)) // Filter AFK
		to_chat(O, "<span class='info'>You are unable to do this because you are AFK.</span>")
		return 0

	return 1


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
	allowed_mobs = list()

	for(var/obj/effect/mapping/playable_mob/team/T in objects)
		if(!existing_teams.Find(T.name))
			existing_teams[T.name] = list()

		var/list/L = existing_teams[T.name]
		var/mob/living/linked = locate(/mob/living) in get_turf(T)

		L.Add(linked)
		link_mob(linked)
		objects.Remove(T)

	for(var/team_index in existing_teams)
		var/list/L = existing_teams[team_index]

		for(var/mob/dead/observer/O in player_list)
			notify_observer(O, L, team_index)

/obj/effect/mapping/playable_mob/team/notify_observer(mob/dead/observer/O, list/team, name)
	//Instead of passing a \ref[O], pass the mob's ckey (prevents many less-noticeable and rare but still nasty bugs)
	to_chat(O, "<span class='recruit'>[team.len] roles in team \"[name]\" are available (<a href='?src=\ref[src];signup=[O.ckey];body=[existing_teams.Find(name)]'>Join</a> | <a href='?src=\ref[src];teleport=\ref[O]'>Teleport</a>)</span>")

/obj/effect/mapping/playable_mob/team/Topic(href,href_list)
	if(href_list["signup"])
		var/client/C = get_client_by_ckey(href_list["signup"])
		if(!istype(C) || (C.ckey != usr.ckey))
			return

		var/mob/dead/observer/O = C.mob
		var/team_index = text2num(href_list["body"])

		if(!team_index)
			return
		if(!check_observer(O))
			return

		//The line below is slightly confusing
		//existing_teams is a list of team tags associated with list of mobs ->  list("red team" = list(), "blue team" = list())
		//team_index is a number
		//existing_teams[team_index] returns the item at value (team_index), which is the team tag (like "red team" or "blue team"
		//existing_teams[existing_teams[team_index]] gives you the list of mobs
		var/list/L = existing_teams[existing_teams[team_index]]
		if(!istype(L) || !L.len)
			return

		var/mob/living/new_body = pick(L)
		if(!istype(new_body))
			return
		L.Remove(new_body)

		volunteer(O, new_body)
	else
		return ..()

/obj/effect/mapping/playable_mob/team/check_mobs()
	for(var/mob/living/L in allowed_mobs)
		if(isnull(L.loc) || L.isDead())
			allowed_mobs.Remove(L)

			for(var/T in existing_teams)
				var/list/team = existing_teams[T]
				if(istype(team))
					team.Remove(L)

//Individual marker: every marker sends a prompt to every observer. Example:
//"prison guard" position available. __Click_here__ to join as a prison guard.
//"inmate" position available. __Click_here__ to join as an inmate.
/obj/effect/mapping/playable_mob/single
	name = "minor character"

/obj/effect/mapping/playable_mob/single/spawned_by_map_element(datum/map_element/ME, list/objects)
	.=..()

	//Find linked mob and send a message to all observers
	var/mob/living/linked = locate(/mob/living) in get_turf(src)
	allowed_mobs = list()
	link_mob(linked)

	for(var/mob/dead/observer/O in player_list)
		notify_observer(O, linked)

/obj/effect/mapping/playable_mob/single/notify_observer(mob/dead/observer/O, mob/living/body)
	//Instead of passing a \ref[O], pass the mob's ckey (prevents many less-noticeable and rare but still nasty bugs)
	to_chat(O, "<span class='recruit'>\"[src.name]\" role is available (<a href='?src=\ref[src];signup=[O.ckey];body=\ref[body]'>Join</a> | <a href='?src=\ref[src];teleport=\ref[O]'>Teleport</a>)</span>")