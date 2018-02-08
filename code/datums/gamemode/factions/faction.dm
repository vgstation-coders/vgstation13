/*
	Faction Datums
		Used for keeping a collection of people (In this case ROLES) under one banner, making for easier
		objective syncing, communication, etc.

	@name: String: Name of the faction
	@ID: List(String): Identifying strings for shorthand finding this faction.
	@desc: String: Description of the faction, their intentions, how they do things, etc. Something for lorewriters to use.
	@initial_role: String(DEFINE): On initial setup via gamemode or faction creation, set the new minds role ID to this. HEADCULTIST for example
	@late_role: String(DEFINE): On later recruitment, set the new minds role ID to this. TRAITOR for example
	@required_pref: String(DEFINE): What preference is required to be recruited to this faction.
	@restricted_species: list(String): Only species on this list can be part of this faction
		(Vox Raiders, Skellington Pirates, Bewildering Basfellians, etc.)
	@members: List(Reference): Who is a member of this faction - ROLES, NOT MINDS
	@max_roles: Integer: How many members this faction is limited to. Set to 0 for no limit
	@accept_latejoiners: Boolean: Whether or not this faction accepts newspawn latejoiners
	@objectives: objectives datum: What are the goals of this faction?

	//TODO LATER
	@faction_icon_state: String: The image name of the icon that appears next to people of this faction
	@faction_icon: icon file reference: Where the icon is stored (currently most are stored in mob.dmi)
*/

/datum/faction
	var/name = "unknown faction"
	var/list/ID = list("unknown")
	var/desc = "This faction is bound to do something nefarious"
	var/initial_role
	var/late_role
	var/required_pref = ""
	var/list/restricted_species = list()
	var/list/members = list()
	var/max_roles = 0
	var/accept_latejoiners = FALSE
	var/datum/objective_holder/objective_holder
	var/datum/role/roletype = /datum/role


/datum/faction/proc/OnPostSetup()
	objective_holder = new
	forgeObjectives()
	for(var/datum/role/R in members)
		R.OnPostSetup()

//Initialization proc, checks if the faction can be made given the current amount of players and/or other possibilites
/datum/faction/proc/can_setup()
	return TRUE

//For when you want your faction to have specific objectives (Vampire, suck blood. Cult, sacrifice the head of personnel's dog, etc.)
/datum/faction/proc/forgeObjectives()

/datum/faction/proc/HandleNewMind(var/datum/mind/M) //Used on faction creation
	var/newRole = new roletype(M, src, initial_role)
	if(!newRole)
		WARNING("Role killed itself or was otherwise missing!")
		return 0
	members.Add(newRole)
	return 1

/datum/faction/proc/HandleRecruitedMind(var/datum/mind/M)
	var/datum/R = new roletype(M, src, late_role)
	if(!R)
		return 0
	members.Add(R)
	return 1

/datum/faction/proc/appendObjective(var/datum/objective/O)
	ASSERT(O)
	objective_holder.AddObjective(O)

/datum/faction/proc/GetObjectives()
	return objective_holder.GetObjectives()

/datum/faction/proc/CheckObjectives()
	return objective_holder.GetObjectiveString(check_success = TRUE)

/datum/faction/proc/GetScoreboard()
	var/list/score_results = list()
	for(var/datum/role/R in members)
		var/results = R.GetScoreboard()
		if(results)
			score_results.Add(results)

	return score_results

/datum/faction/proc/GetObjectivesMenuHeader() //Returns what will show when the factions objective completion is summarized

/datum/faction/proc/DeclareAll()
	for(var/datum/role/R in members)
		R.Declare()

/datum/faction/proc/AdminPanelEntry()
	var/dat = list()
	dat += GetObjectivesMenuHeader()
	dat += "<h2>Faction objectives</h2>"
	dat += CheckObjectives()
	dat += "<h2>Members</h2><br>"
	if(!members.len)
		dat += "<b>Unpopulated</b>"
	else
		for(var/datum/role/R in members)
			dat += R.AdminPanelEntry()
	return dat

/datum/faction/proc/process()
	return

/datum/faction/proc/check_win()
	return

/datum/faction/syndicate
	name = "The Syndicate"
	ID = SYNDICATE
	required_pref = ROLE_TRAITOR
	desc = "A coalition of companies that actively work against Nanotrasen's intentions. Seen as Freedom fighters by some, Rebels and Malcontents by others."


/datum/faction/syndicate/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/mob/mob.dmi', "synd-logo")
	var/header = {"<img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Syndicate</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

/datum/faction/syndicate/traitor
	name = "Traitors to NT"
	ID = TRAITOR
	initial_role = TRAITOR
	late_role = TRAITOR
	desc = "Operatives of the syndicate, implanted into the crew in one way or another."

/datum/faction/syndicate/traitor/auto
	name = "Deep cover operatives"
	desc = "Anyone could be a deep cover operative. It could be you, it could be me, it could even be that guy!"
	accept_latejoiners = TRUE

/datum/faction/syndicate/nuke_op
	name = "Syndicate nuclear operatives"
	ID = NUKE_OP
	required_pref = ROLE_OPERATIVE
	initial_role = NUKE_OP
	late_role = NUKE_OP
	desc = "The culmination of succesful NT traitors, who have managed to steal a nuclear device.\
	Load up, grab the nuke, don't forget where you've parked, find the nuclear auth disk, and give them hell."

/datum/faction/syndicate/nuke_op/AdminPanelEntry()
	var/list/dat = ..()
	dat += "<br><h2>Nuclear disk</h2>"
	if(!nukedisk)
		dat += "There's no nuke disk. Panic?<br>"
	else if(isnull(nukedisk.loc))
		dat += "The nuke disk is in nullspace. Panic."
	else
		dat += "[nukedisk.name]"
		var/atom/disk_loc = nukedisk.loc
		while(!istype(disk_loc, /turf))
			if(istype(disk_loc, /mob))
				var/mob/M = disk_loc
				dat += "carried by <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a> "
			if(istype(disk_loc, /obj))
				var/obj/O = disk_loc
				dat += "in \a [O.name] "
			disk_loc = disk_loc.loc
		dat += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z]) [formatJumpTo(nukedisk, "Jump")]"
	return dat

/datum/faction/changeling
	name = "Changeling Hivemind"
	ID = CHANGELING
	initial_role = CHANGELING
	late_role = CHANGELING
	required_pref = ROLE_CHANGELING
	desc = "An almost parasitic, shapeshifting entity that assumes the identity of its victims. Commonly used as smart bioweapons by the syndicate,\
	or simply wandering malignant vagrants happening upon a meal of identity that can carry them to further feeding grounds."
	roletype = /datum/role/changeling

/datum/faction/changeling/GetObjectivesMenuHeader()
	var/icon/logo_left = icon('icons/mob/mob.dmi', "change-logoa")
	var/icon/logo_right = icon('icons/mob/mob.dmi', "change-logob")
	var/header = {"<img src='data:image/png;base64,[icon2base64(logo_left)]'> <FONT size = 2><B>Changelings Hivemind</B></FONT> <img src='data:image/png;base64,[icon2base64(logo_right)]'>"}
	return header

/datum/faction/wizard
	name = "Wizard Federation"
	ID = WIZARD
	initial_role = WIZARD
	late_role = WIZARD
	required_pref = ROLE_WIZARD
	desc = "A conglomeration of magically adept individuals, with no obvious heirachy, instead acting as equal individuals in the pursuit of magic-oriented endeavours.\
	Their motivations for attacking seemingly peaceful enclaves or operations are as yet unknown, but they do so without respite or remorse.\
	This has led to them being identified as enemies of humanity, and should be treated as such."
	roletype = /datum/role/wizard

/datum/faction/wizard/HandleNewMind(var/datum/mind/M)
	..()
	M.special_role = "Wizard"
	M.original = M.current

/datum/faction/wizard/OnPostSetup()
	..()
	if(wizardstart.len == 0)
		for(var/datum/role/wizard in members)
			to_chat(wizard.antag.current, "<span class='danger'>A starting location for you could not be found, please report this bug!</span>")
		log_admin("Failed to set-up a round of wizard. Couldn't find any wizard spawn points.")
		message_admins("Failed to set-up a round of wizard. Couldn't find any wizard spawn points.")
		return 0 //Critical failure.

	for(var/datum/role/wwizard in members)
		wwizard.antag.current.forceMove(pick(wizardstart))
		equip_wizard(wwizard.antag.current)
		name_wizard(wwizard.antag.current)


/datum/faction/wizard/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/mob/mob.dmi', "wizard-logo")
	var/header = {"<img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Wizard Federation</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

/datum/faction/wizard/AdminPanelEntry()
	var/list/dat = ..()
	dat += "<h2>Wizard's apprentices</h2><br>To be implemented."

	// TODO: FIXME: probably don't need this
	/*
		for(var/datum/mind/apprentice in ticker.mode.apprentices)
			var/mob/M = apprentice.current
			if(M)

				dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
					<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
					<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
			else
				dat += "<tr><td><i>Apprentice not found!</i></td></tr>"
		dat += "</table>"*/
	return dat

/datum/faction/vampire/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/mob/mob.dmi', "vampire-logo")
	var/header = {"<img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Vampiric wanderers</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

/datum/faction/revolution
	name = "Revolutionaries"
	ID = REV
	required_pref = ROLE_REV
	initial_role = REV
	late_role = REV
	desc = "Viva!"

/datum/faction/revolution/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/mob/mob.dmi', "rev-logo")
	var/header = {"<img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Revolutionaries</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

/datum/faction/strike_team
	name = "Strike Team 6"
	required_pref = ROLE_STRIKE
	ID = CUSTOMSQUAD

/datum/faction/strike_team/ert
	name = "Emergency Response Team"
	ID = ERT

/datum/faction/strike_team/deathsquad
	name = "Nanotransen Deathsquad"
	ID = DEATHSQUAD

/datum/faction/strike_team/syndiesquad
	name = "Syndicate Deep-strike squad"
	ID = SYNDIESQUAD
