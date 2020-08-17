/*
	Faction Datums
		Used for keeping a collection of people (In this case ROLES) under one banner, making for easier
		objective syncing, communication, etc.

	@name: String: Name of the faction
	@ID: List(String): Identifying strings for shorthand finding this faction.
	@desc: String: Description of the faction, their intentions, how they do things, etc. Something for lorewriters to use.
	@initial_role: String(DEFINE): On initial setup via gamemode or faction creation, set the new minds role ID to this.
	@late_role: String(DEFINE): On later recruitment, set the new minds role ID to this. TRAITOR for example
	@required_pref: String(DEFINE): What preference is required to be recruited to this faction.
	@restricted_species: list(String): Only species on this list can be part of this faction
		(Vox Raiders, Skellington Pirates, Bewildering Basfellians, etc.)
	@members: List(Reference): Who is a member of this faction - ROLES, NOT MINDS
	@max_roles: Integer: How many members this faction is limited to. Set to 0 for no limit
	@accept_latejoiners: Boolean: Whether or not this faction accepts newspawn latejoiners
	@objectives: objectives datum: What are the goals of this faction?
	@faction_scoreboard_data: This is intended to be used on GetScoreboard() to list things like nuclear ops purchases.

	//TODO LATER
	@faction_icon_state: String: The image name of the icon that appears next to people of this faction
	@faction_icon: icon file reference: Where the icon is stored (currently most are stored in logos.dmi)
*/

var/list/factions_with_hud_icons = list()

/datum/faction
	var/name = "unknown faction"
	var/ID = null
	var/desc = "This faction is bound to do something nefarious"
	var/initial_role
	var/late_role
	var/required_pref = ""
	var/list/restricted_species = list()
	var/list/members = list()
	var/max_roles = 0
	var/accept_latejoiners = FALSE
	var/datum/objective_holder/objective_holder
	var/datum/role/initroletype = /datum/role
	var/datum/role/roletype = /datum/role
	var/logo_state = "synd-logo"
	var/list/hud_icons = list()
	var/datum/role/leader
	var/list/faction_scoreboard_data = list()
	var/stage = FACTION_DORMANT //role_datums_defines.dm
	var/playlist

	var/minor_victory = FALSE

	// This datum represents all data that is exported to the statistics file at the end of the round.
	// If you want to store faction-specific data as statistics, you'll need to define your own datum.
	// See dynamic_stats.dm
	var/datum/stat/faction/stat_datum = null
	var/datum/stat/faction/stat_datum_type = /datum/stat/faction

/datum/faction/New()
	..()
	objective_holder = new
	objective_holder.faction = src
	if (hud_icons.len)
		factions_with_hud_icons.Add(src)

	for (var/datum/faction/F in factions_with_hud_icons)
		update_hud_icons()

	stat_datum = new stat_datum_type()

/datum/faction/proc/OnPostSetup()
	for(var/datum/role/R in members)
		R.OnPostSetup()

/datum/faction/proc/Dismantle()
	for(var/datum/role/R in members)
		var/datum/gamemode/G = ticker.mode
		G.orphaned_roles += R
		members -= R
	qdel(objective_holder)
	var/datum/gamemode/dynamic/D = ticker.mode
	D.factions -= src
	qdel(src)

//Initialization proc, checks if the faction can be made given the current amount of players and/or other possibilites
/datum/faction/proc/can_setup()
	return TRUE

//For when you want your faction to have specific objectives (Vampire, suck blood. Cult, sacrifice the head of personnel's dog, etc.)
/datum/faction/proc/forgeObjectives()

/datum/faction/proc/AnnounceObjectives()
	for(var/datum/role/R in members)
		R.AnnounceObjectives()

/datum/faction/proc/ShuttleDocked(state)

/datum/faction/proc/HandleNewMind(var/datum/mind/M) //Used on faction creation
	for(var/datum/role/R in members)
		if(R.antag == M)
			return 0
	if(M.GetRole(initial_role))
		WARNING("Mind already had a role of [initial_role]!")
		return 0
	var/datum/role/newRole = new initroletype(null, src, initial_role)
	if(!newRole.AssignToRole(M))
		newRole.Drop()
		return 0
	return newRole

/datum/faction/proc/HandleRecruitedMind(var/datum/mind/M, var/override = FALSE)
	for(var/datum/role/R in members)
		if(R.antag == M)
			return R
	if(M.GetRole(late_role))
		WARNING("Mind already had a role of [late_role]!")
		return (M.GetRole(late_role))
	var/datum/role/R = new roletype(null,src,late_role) // Add him to our roles
	if(!R.AssignToRole(M, override))
		R.Drop()
		return 0
	R.OnPostSetup()
	return R

/datum/faction/proc/HandleRecruitedRole(var/datum/role/R)
	ticker.mode.orphaned_roles.Remove(R)
	members.Add(R)
	R.faction = src
	update_faction_icons()

/datum/faction/proc/HandleRemovedRole(var/datum/role/R)
	update_hud_removed(R)
	R.faction.members.Remove(R)
	R.faction = null
	ticker.mode.orphaned_roles.Add(R)
	if(leader == R)
		leader = null
	update_faction_icons()

/datum/faction/proc/AppendObjective(var/objective_type,var/duplicates=0)
	if(!duplicates && locate(objective_type) in objective_holder.GetObjectives())
		return FALSE
	var/datum/objective/O
	if(istype(objective_type, /datum/objective)) //Passed an actual objective
		O = objective_type
	else
		O = new objective_type
	if(objective_holder.AddObjective(O, null, src))
		return TRUE
	return FALSE

/datum/faction/proc/GetObjectives()
	return objective_holder.GetObjectives()

/datum/faction/proc/CheckObjectives()
	return objective_holder.GetObjectiveString(check_success = TRUE)

/datum/faction/proc/GetScoreboard()
	var/count = 1
	var/score_results = ""
	if(objective_holder.objectives.len > 0)
		score_results += "<ul>"
		for (var/datum/objective/objective in objective_holder.GetObjectives())
			var/successful = objective.IsFulfilled()
			objective.extraInfo()
			score_results += "<B>Objective #[count]</B>: [objective.explanation_text] [successful ? "<font color='green'><B>Success!</B></font>" : "<span class='red'>Fail.</span>"]"
			feedback_add_details("[ID]_objective","[objective.type]|[successful ? "SUCCESS" : "FAIL"]")
			count++
			if (count <= objective_holder.objectives.len)
				score_results += "<br>"
	if (count>1)
		if (IsSuccessful())
			score_results += "<br><font color='green'><B>\The [name] was successful!</B></font>"
			feedback_add_details("[ID]_success","SUCCESS")
		else if (minor_victory)
			score_results += "<br><font color='green'><B>\The [name] has achieved a minor victory.</B> [minorVictoryText()]</font>"
			feedback_add_details("[ID]_success","MINOR_VICTORY")
		else
			score_results += "<br><span class='red'><B>\The [name] has failed.</B></span>"
			feedback_add_details("[ID]_success","FAIL")

	if(objective_holder.objectives.len > 0)
		score_results += "</ul>"

	score_results += "<FONT size = 2><B>members:</B></FONT><br>"
	var/i = 1
	for(var/datum/role/R in members)
		var/results = R.GetScoreboard()
		if(results)
			score_results += results
		if(R.objectives.objectives.len <= 0)
			if (i < members.len)
				score_results += "<br>"
		i++

	stat_collection.add_faction(src)

	return score_results

/datum/faction/Topic(href, href_list)
	..()
	if(href_list["destroyfac"])
		if(!usr.check_rights(R_ADMIN))
			message_admins("[usr] tried to destroy a faction without permissions.")
			return
		if(alert(usr, "Are you sure you want to destroy [name]?",  "Destroy Faction" , "Yes" , "No") != "Yes")
			return
		message_admins("[key_name(usr)] destroyed faction [name].")
		Dismantle()

/datum/faction/proc/IsSuccessful()
	var/win = TRUE
	if(objective_holder.objectives.len > 0)
		for (var/datum/objective/objective in objective_holder.GetObjectives())
			if(!objective.IsFulfilled())
				win = FALSE
	return win

/datum/faction/proc/GetObjectivesMenuHeader() //Returns what will show when the factions objective completion is summarized
	var/icon/logo = icon('icons/logos.dmi', logo_state)
	var/header = {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position:relative; top:10px;'> <FONT size = 2><B>[name]</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]' style='position:relative; top:10px;'><br>"}
	return header

/datum/faction/proc/AdminPanelEntry(var/datum/admins/A)
	var/dat = "<br>"
	dat += GetObjectivesMenuHeader()
	dat += " <a href='?src=\ref[src];destroyfac=1'>\[Destroy\]</A><br>"
	dat += "<br><b>Faction objectives</b><br>"
	dat += objective_holder.GetObjectiveString(0,1,A)
	dat += "<br> - <b>Members</b> - <br>"
	if(!members.len)
		dat += "<i>Unpopulated</i>"
	else
		for(var/datum/role/R in members)
			dat += R.AdminPanelEntry()
			dat += "<br>"
	return dat

/datum/faction/proc/process()
	for (var/datum/role/R in members)
		R.process()

/datum/faction/proc/stage(var/value)
	stage = value
	switch(value)
		if(FACTION_DEFEATED) //Faction was close to victory, but then lost. Send shuttle and end theme.
			sleep(5 SECONDS)
			emergency_shuttle.shutdown = 0
			emergency_shuttle.online = 1
			OnPostDefeat()
			set_security_level("blue")
			ticker.StopThematic()
		if(FACTION_ENDGAME) //Faction is nearing victory. Set red alert and play endgame music.
			if(playlist)
				ticker.StartThematic(playlist)
			else
				ticker.StartThematic("endgame")
			sleep(2 SECONDS)
			set_security_level("red")

/datum/faction/proc/OnPostDefeat()
	if(emergency_shuttle.location || emergency_shuttle.direction) //If traveling or docked somewhere other than idle at command, don't call.
		return
	emergency_shuttle.incall()
	captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes. Justification: Recovery of assets.")

/datum/faction/proc/check_win()
	return

/datum/faction/proc/minorVictoryText()
	return ""

//updating every icons at the same time allows their animate() to be sync'd, so we can alternate the one on top without any additional proc calls.
/proc/update_faction_icons()
	if (!ticker || !ticker.mode)
		return

	var/offset = 0
	var/list/factions_with_icons = list()
	for (var/datum/faction/F in ticker.mode.factions)
		if (F.hud_icons.len)
			factions_with_icons.Add(F)
			factions_with_icons[F] = offset
			offset++

	for (var/datum/faction/F in factions_with_icons)
		F.update_hud_icons(factions_with_icons[F],factions_with_icons.len)

#define HUDICON_BLINKDURATION 10//the smaller, the faster icons swap to one another
/datum/faction/proc/update_hud_icons(var/offset = 0,var/factions_with_icons = 0)
	//lets ignore this proc if our faction has no icons (for factions where we don't want its members to know each others by default)
	if (!hud_icons.len)
		return

	//let's remove every icons
	for(var/datum/role/R in members)
		if(R.antag && R.antag.current && R.antag.current.client)
			for(var/image/I in R.antag.current.client.images)
				if(I.icon_state in hud_icons)
					R.antag.current.client.images -= I

	//then re-add them
	for(var/datum/role/R in members)
		if(R.antag && R.antag.current && R.antag.current.client && R.antag.GetRole(R.id))//if the mind doesn't have access to the role, they shouldn't see the icons
			for(var/datum/role/R_target in members)
				if(R_target.antag && R_target.antag.current)
					var/imageloc = R_target.antag.current
					if(istype(R_target.antag.current.loc,/obj/mecha))
						imageloc = R_target.antag.current.loc
					var/hud_icon = R_target.logo_state//the icon is based on the member's role
					if (!(R_target.logo_state in hud_icons))
						hud_icon = hud_icons[1]//if the faction doesn't recognize the role, it'll just give it a default one.
					var/image/I = image('icons/role_HUD_icons.dmi', loc = imageloc, icon_state = hud_icon)
					I.pixel_x = 20 * PIXEL_MULTIPLIER
					I.pixel_y = 20 * PIXEL_MULTIPLIER
					I.plane = ANTAG_HUD_PLANE
					if (factions_with_icons > 1)
						animate(I, layer = 1, time = 0.1 + offset * HUDICON_BLINKDURATION, loop = -1)
						animate(layer = 0, time = 0.1)
						animate(layer = 0, time = HUDICON_BLINKDURATION)
						animate(layer = 1, time = 0.1)
						animate(layer = 1, time = 0.1 + HUDICON_BLINKDURATION*(factions_with_icons - 1 - offset))
					R.antag.current.client.images += I
#undef HUDICON_BLINKDURATION

/datum/faction/proc/update_hud_removed(var/datum/role/Removed_R)
	if(Removed_R.antag && Removed_R.antag.current && Removed_R.antag.current.client)
		for(var/image/I in Removed_R.antag.current.client.images)
			if(I.icon_state in hud_icons)
				Removed_R.antag.current.client.images -= I

// Generic proc for added/removed faction objectives
// Override this in the proper faction if you need to notify the players or if the objective is important.

/datum/faction/proc/handleNewObjective(var/datum/objective/O)
	ASSERT(O)
	O.faction = src
	if (O in objective_holder.objectives)
		WARNING("Trying to add an objective ([O]) to faction ([src]) when it already has it.")
		return FALSE

	var/setup = TRUE
	if (istype(O,/datum/objective/target))
		var/datum/objective/target/new_O = O
		if (alert("Do you want to specify a target?", "New Objective", "Yes", "No") == "No")
			setup = new_O.find_target()
		else
			setup = new_O.select_target()
	if(!setup)
		alert("Couldn't set-up a proper target.", "New Objective")
		return
	AppendObjective(O)
	return TRUE

/datum/faction/proc/handleRemovedObjective(var/datum/objective/O)
	ASSERT(O)
	if (!(O in objective_holder.objectives))
		WARNING("Trying to remove an objective ([O]) to faction ([src]) who never had it.")
		return FALSE
	objective_holder.objectives.Remove(O)
	O.faction = null
	qdel(O)

/datum/faction/proc/handleForcedCompletedObjective(var/datum/objective/O)
	ASSERT(O)
	if (!(O in objective_holder.objectives))
		WARNING("Trying to force completion of an objective ([O]) to faction ([src]) who never had it.")
		return FALSE
	O.force_success = !O.force_success

/datum/faction/proc/Declare()
	var/dat = GetObjectivesMenuHeader()
	dat += "<br><b>Faction objectives</b><br>"
	dat += CheckObjectives()
	dat += "<br><b>Faction members.</b><br"
	var/list/score_results = GetScoreboard()
	for(var/i in score_results)
		dat += i

	return dat

/**
	Should the faction make any changes to everybodies statpanel (EVERYBODIES, NOT JUST THE MEMBERS), put it here

	Format it as just information you would want to print to the stat panel, such as return "Time left: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)]"
*/
/datum/faction/proc/get_statpanel_addition()
	return null

/datum/faction/proc/get_member_by_mind(var/datum/mind/M)
	for(var/datum/role/R in members)
		if(R.antag == M)
			return R

/////////////////////////////THESE FACTIONS SHOULD GET MOVED TO THEIR OWN FILES ONCE THEY'RE GETTING ELABORATED/////////////////////////

//________________________________________________

/datum/faction/changeling
	name = "Changeling Hivemind"
	ID = HIVEMIND
	initial_role = CHANGELING
	late_role = CHANGELING
	required_pref = CHANGELING
	desc = "An almost parasitic, shapeshifting entity that assumes the identity of its victims. Commonly used as smart bioweapons by the syndicate,\
	or simply wandering malignant vagrants happening upon a meal of identity that can carry them to further feeding grounds."
	roletype = /datum/role/changeling
	logo_state = "change-logoa"

/datum/faction/changeling/GetObjectivesMenuHeader()
	var/icon/logo_left = icon('icons/logos.dmi', "change-logoa")
	var/icon/logo_right = icon('icons/logos.dmi', "change-logob")
	var/header = {"<img src='data:image/png;base64,[icon2base64(logo_left)]' style='position:relative; top:10px;'> <FONT size = 2><B>[name]</B></FONT> <img src='data:image/png;base64,[icon2base64(logo_right)]' style='position:relative; top:10px;'><br>"}
	return header

//________________________________________________


/datum/faction/strike_team
	name = "Custom Strike Team"//obviously this name is a placeholder getting replaced by the admin setting up the squad
	ID = CUSTOMSQUAD
	logo_state = "nano-logo"

/datum/faction/strike_team/forgeObjectives(var/mission)
	var/datum/objective/custom/c = new /datum/objective/custom
	c.explanation_text = mission
	AppendObjective(c)

//________________________________________________

/datum/faction/strike_team/ert
	name = "Emergency Response Team"
	ID = ERT
	initroletype = /datum/role/emergency_responder
	roletype = /datum/role/emergency_responder
	logo_state = "ert-logo"
	hud_icons = list("ert-logo")

//________________________________________________

/datum/faction/strike_team/deathsquad
	name = "Nanotrasen Deathsquad"
	ID = DEATHSQUAD
	initroletype = /datum/role/death_commando
	roletype = /datum/role/death_commando
	logo_state = "death-logo"
	hud_icons = list("death-logo","creed-logo")

//________________________________________________

/datum/faction/strike_team/syndiesquad
	name = "Syndicate Deep-Strike squad"
	ID = SYNDIESQUAD
	initroletype = /datum/role/syndicate_elite_commando
	roletype = /datum/role/syndicate_elite_commando
	logo_state = "elite-logo"

//________________________________________________

/datum/faction/strike_team/custom
	name = "Custom Strike Team"

/datum/faction/strike_team/custom/New()
	..()
	ID = rand(1,999)

//________________________________________________
