/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:

			mind.transfer_to(new_mob)

	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

/datum/mind
	var/key
	var/name				//replaces mob/var/original_name
	var/mob/living/current
	var/mob/living/original	//TODO: remove.not used in any meaningful way ~Carn. First I'll need to tweak the way silicon-mobs handle minds.
	var/active = 0

	var/memory

	var/assigned_role
	var/special_role
	var/list/wizard_spells // So we can track our wizmen spells that we learned from the book of magicks.

	var/role_alt_title

	var/datum/job/assigned_job
	var/datum/religion/faith

	var/list/kills=list()
	var/list/datum/objective/special_verbs = list()
	var/list/antag_roles = list()		// All the antag roles we have.


	var/datum/faction/faction 			//associated faction

	// the world.time since the mob has been brigged, or -1 if not at all
	var/brigged_since = -1

		//put this here for easier tracking ingame
	var/datum/money_account/initial_account

	var/total_TC = 0
	var/spent_TC = 0

	//fix scrying raging mages issue.
	var/isScrying = 0
	var/list/heard_before = list()

	var/nospells = 0 //Can't cast spells.
	var/hasbeensacrificed = FALSE

	var/miming = null //Toggle for the mime's abilities.

/datum/mind/New(var/key)
	src.key = key

/datum/mind/proc/transfer_to(mob/living/new_character)
	if(!istype(new_character))
		error("transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob. Please inform Carn")

	if (!current)
		transfer_to_without_current(new_character)
		return

	new_character.attack_log += current.attack_log
	new_character.attack_log += "\[[time_stamp()]\]: mind transfer from [current] to [new_character]"

	for (var/role in antag_roles)
		var/datum/role/R = antag_roles[role]
		R.PreMindTransfer(current)

	if(current)					//remove ourself from our old body's mind variable
		current.mind = null
	if(new_character.mind)		//remove any mind currently in our new body's mind variable
		new_character.mind.current = null

	nanomanager.user_transferred(current, new_character)

	if(active)
		new_character.key = key		//now transfer the key to link the client to our new body

	var/mob/old_character = current
	current = new_character		//link ourself to our new body
	new_character.mind = src	//and link our new body to ourself

	for (var/role in antag_roles)
		var/datum/role/R = antag_roles[role]
		R.PostMindTransfer(new_character, old_character)

	if (hasFactionsWithHUDIcons())
		update_faction_icons()

/datum/mind/proc/transfer_to_without_current(var/mob/living/new_character)
	new_character.attack_log += "\[[time_stamp()]\]: mind transfer from a body-less observer to [new_character]"

	if(new_character.mind)		//remove any mind currently in our new body's mind variable
		new_character.mind.current = null

	if(active)
		new_character.key = key		//now transfer the key to link the client to our new body

	current = new_character		//link ourself to our new body
	new_character.mind = src	//and link our new body to ourself

	//If the original body was fully destroyed there is no way for the roles to check for any spells it had, so store that shit in roles.

	if (hasFactionsWithHUDIcons())
		update_faction_icons()

/datum/mind/proc/store_memory(new_text)
	if(lentext(memory) > MAX_PAPER_MESSAGE_LEN)
		to_chat(current, "<span class = 'warning'>Your memory, however hazy, is full.</span>")
		return
	if(lentext(new_text) > MAX_MESSAGE_LEN)
		to_chat(current, "<span class = 'warning'>That's a lot to memorize at once.</span>")
		return
	if(new_text)
		memory += "[new_text]<BR>"


/datum/mind/proc/hasFactionsWithHUDIcons()
	for(var/role in antag_roles)
		var/datum/role/R = antag_roles[role]
		if (R.faction in factions_with_hud_icons)
			return 1
	return 0

/datum/mind/proc/show_memory(mob/recipient)
	var/output = "<TITLE>Your memory</TITLE><B>[current.real_name]'s memory</B><HR>"

	if (memory)
		output += memory
		output += "<hr>"

	if(antag_roles.len)
		for(var/role in antag_roles)
			var/datum/role/R = antag_roles[role]
			output += R.GetMemory(src,FALSE)//preventing edits
		output += "<hr>"

	// -- Religions --
	if (faith) // This way they can get their religion changed
		output += "<b>Religion:</b> [faith.name] <br/> \
				   <b>Leader:</b> [faith.religiousLeader] <br/>"

		if (faith.religiousLeader == src)
			output += "You can convert people by [faith.convert_method] <br />"
	recipient << browse(output,"window=memory;size=700x500")


/datum/mind/proc/role_panel()
	if(!ticker || !ticker.mode)
		alert("Ticker and Game Mode aren't initialized yet!", "Alert")
		return

	var/out = {"<TITLE>Role Panel</TITLE><B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""] - key=<b>[key]</b> [active?"(synced)":"(not synced)"]<br>
		Assigned job: [assigned_role] - <a href='?src=\ref[src];job_edit=1'>(edit)</a><hr>"}
	if(current && current.client)
		out += "Desires roles: [current.client.GetRolePrefs()]<BR>"
	else
		out += "Body destroyed or logged out."
	out += "<font size='5'><b>Roles and Factions</b></font><br>"

	if(!antag_roles.len)
		out += "<i>This mob has no roles.</i><br>"
	else
		for(var/role in antag_roles)
			var/datum/role/R = antag_roles[role]
			out += R.GetMemory(src, TRUE)//allowing edits

	out += "<br><a href='?src=\ref[src];add_role=1'>(add a new role)</a>"

	//<a href='?src=\ref[src];obj_announce=1'>Announce objectives</a><br><br>"} TODO: make sure that works

	usr << browse(out, "window=role_panel[src];size=700x500")

/datum/mind/proc/get_faction_list()
	var/list/all_factions = list()
	for(var/datum/faction/F in ticker.mode.factions)
		all_factions.Add(F.name)
		all_factions[F.name] = F
	all_factions += "-----"
	for(var/factiontype in subtypesof(/datum/faction))
		var/datum/faction/F = factiontype
		if (!(initial(F.name) in all_factions))
			all_factions.Add(initial(F.name))
			all_factions[initial(F.name)] = F
	all_factions += "-----"
	all_factions += "NEW CUSTOM FACTION"
	return all_factions

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return
	if (href_list["job_edit"])
		var/new_job = input("Select new job", "Assigned job", assigned_role) as null|anything in get_all_jobs()
		if (!new_job)
			return
		assigned_role = new_job

	if (href_list["greet_role"])
		var/datum/role/R = locate(href_list["greet_role"])
		var/chosen_greeting
		var/custom_greeting
		if (R.greets.len)
			chosen_greeting = input("Choose a greeting", "Assigned role", null) as null|anything in R.greets
			if (chosen_greeting == GREET_CUSTOM)
				custom_greeting = input("Choose a custom greeting", "Assigned role", "") as null|text

			if ((chosen_greeting && chosen_greeting != GREET_CUSTOM) || (chosen_greeting == GREET_CUSTOM && custom_greeting))
				R.Greet(chosen_greeting,custom_greeting)



	if (href_list["add_role"])
		var/list/available_roles = list()
		for(var/role in subtypesof(/datum/role))
			var/datum/role/R = role
			if (initial(R.id) && !(initial(R.id) in antag_roles))
				available_roles.Add(initial(R.id))
				available_roles[initial(R.id)] = R

		if(!available_roles.len)
			alert("This mob already has every available roles! Geez, calm down!", "Assigned role")
			return

		var/new_role = input("Select new role", "Assigned role", null) as null|anything in available_roles
		if (!new_role)
			return

		var/joined_faction
		var/list/all_factions = list()
		if (alert("Do you want that role to be part of a faction?", "Assigned role", "Yes", "No") == "Yes")
			all_factions = get_faction_list()
			joined_faction = input("Select new faction", "Assigned faction", null) as null|anything in all_factions


		var/role_type = available_roles[new_role]
		var/datum/role/newRole = new role_type
		if(!newRole)
			WARNING("Role killed itself or was otherwise missing!")
			return

		var/chosen_greeting
		var/custom_greeting
		if (newRole.greets.len)
			if (alert("Do you want to greet them as their new role?", "Assigned role", "Yes", "No") == "Yes")
				chosen_greeting = input("Choose a greeting", "Assigned role", null) as null|anything in newRole.greets
				if (chosen_greeting == "custom")
					custom_greeting = input("Choose a custom greeting", "Assigned role", "") as null|text

		if(!newRole.AssignToRole(src,1))//it shouldn't fail since we're using our admin powers to force the role
			newRole.Drop()//but just in case
			return

		if (joined_faction && joined_faction != "-----")
			if (joined_faction == "NEW CUSTOM FACTION")
				to_chat(usr, "<span class='danger'>Sorry, that feature is not coded yet. - Deity Link</span>")
			else if (istype(all_factions[joined_faction], /datum/faction))//we got an existing faction
				var/datum/faction/joined = all_factions[joined_faction]
				joined.HandleRecruitedRole(newRole)
			else //we got an inexisting faction, gotta create it first!
				var/datum/faction/joined = ticker.mode.CreateFaction(all_factions[joined_faction], null, 1)
				if (joined)
					joined.HandleRecruitedRole(newRole)

		if (isninja(current))
			if ((alert("Throw the ninja into the station from space?", "Alert", "Yes", "No") == "Yes"))
				current.ThrowAtStation()

		newRole.OnPostSetup(FALSE)
		if ((chosen_greeting && chosen_greeting != "custom") || (chosen_greeting == "custom" && custom_greeting))
			newRole.Greet(chosen_greeting,custom_greeting)

	else if(href_list["role_edit"])
		var/datum/role/R = locate(href_list["role_edit"])

		if(href_list["remove_role"])
			R.Drop()

		else if(href_list["remove_from_faction"])
			if(!R.faction)
				to_chat(usr, "<span class='warning'>Can't leave a faction when you already don't belong to any! (This message shouldn't have to appear. Tell a coder.)</span>")
			else if(R in R.faction.members)
				R.faction.HandleRemovedRole(R)

		else if(href_list["add_to_faction"])
			if(R.faction)
				to_chat(usr, "<span class='warning'>A role can only belong to one faction! (This message shouldn't have to appear. Tell a coder.)</span>")
			else
				var/list/all_factions = get_faction_list()
				var/join_faction = input("Select new faction", "Assigned faction", null) as null|anything in all_factions
				if (!join_faction || join_faction == "-----")
					return
				else if (join_faction == "NEW CUSTOM FACTION")
					to_chat(usr, "<span class='danger'>Sorry, that feature is not coded yet. - Deity Link</span>")
				else if (istype(all_factions[join_faction], /datum/faction))//we got an existing faction
					var/datum/faction/joined = all_factions[join_faction]
					joined.HandleRecruitedRole(R)
				else //we got an inexisting faction, gotta create it first!
					var/datum/faction/joined = ticker.mode.CreateFaction(all_factions[join_faction], null, 1)
					if (joined)
						joined.HandleRecruitedRole(R)

	else if (href_list["obj_add"])
		var/datum/objective_holder/obj_holder = locate(href_list["obj_holder"])

		var/list/available_objectives = list()

		for(var/objective_type in subtypesof(/datum/objective))
			var/datum/objective/O = objective_type
			available_objectives.Add(initial(O.name))
			available_objectives[initial(O.name)] = O

		var/new_obj = input("Select a new objective", "New Objective", null) as null|anything in available_objectives

		if(new_obj == null)
			return
		var/obj_type = available_objectives[new_obj]

		var/datum/objective/new_objective = new obj_type(usr, obj_holder.faction)

		if (new_objective.flags & FACTION_OBJECTIVE)
			var/datum/faction/fac = input("To which faction shall we give this?", "Faction-wide objective", null) as null|anything in ticker.mode.factions
			fac.handleNewObjective(new_objective)
			message_admins("[usr.key]/([usr.name]) gave \the [new_objective.faction.ID] the objective: [new_objective.explanation_text]")
			log_admin("[usr.key]/([usr.name]) gave \the [new_objective.faction.ID] the objective: [new_objective.explanation_text]")
			role_panel()
			return TRUE // It's a faction objective, let's not move any further.

		if (obj_holder.owner)//so objectives won't target their owners.
			new_objective.owner = obj_holder.owner

		var/setup = TRUE
		if (istype(new_objective,/datum/objective/target))
			var/datum/objective/target/new_O = new_objective
			if (alert("Do you want to specify a target?", "New Objective", "Yes", "No") == "Yes")
				setup = new_O.select_target()

		if(!setup)
			alert("Couldn't set-up a proper target.", "New Objective")
			return

		if (obj_holder.owner)
			obj_holder.AddObjective(new_objective, src)
			message_admins("[usr.key]/([usr.name]) gave [key]/([name]) the objective: [new_objective.explanation_text]")
			log_admin("[usr.key]/([usr.name]) gave [key]/([name]) the objective: [new_objective.explanation_text]")
		else if (new_objective.faction && istype(new_objective, /datum/objective/custom)) //is it a custom objective with a faction modifier?
			new_objective.faction.AppendObjective(new_objective)
			message_admins("[usr.key]/([usr.name]) gave \the [new_objective.faction.ID] the objective: [new_objective.explanation_text]")
			log_admin("[usr.key]/([usr.name]) gave \the [new_objective.faction.ID] the objective: [new_objective.explanation_text]")
		else if (obj_holder.faction) //or is it just an explicit faction obj?
			obj_holder.faction.AppendObjective(new_objective)
			message_admins("[usr.key]/([usr.name]) gave \the [obj_holder.faction.ID] the objective: [new_objective.explanation_text]")
			log_admin("[usr.key]/([usr.name]) gave \the [obj_holder.faction.ID] the objective: [new_objective.explanation_text]")

	else if (href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		var/datum/objective_holder/obj_holder = locate(href_list["obj_holder"])

		ASSERT(istype(objective) && istype(obj_holder))

		if (obj_holder.owner)
			log_admin("[usr.key]/([usr.name]) removed [key]/([name])'s objective ([objective.explanation_text])")
		else if (obj_holder.faction)
			message_admins("[usr.key]/([usr.name]) removed \the [obj_holder.faction.ID]'s objective ([objective.explanation_text])")
			log_admin("[usr.key]/([usr.name]) removed \the [obj_holder.faction.ID]'s objective ([objective.explanation_text])")
			objective.faction.handleRemovedObjective(objective)

		obj_holder.objectives.Remove(objective)

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])

		ASSERT(istype(objective))

		if (objective.faction)
			objective.faction.handleForcedCompletedObjective(objective)
		else
			objective.force_success = !objective.force_success
		log_admin("[usr.key]/([usr.name]) toggled [key]/([name]) [objective.explanation_text] to [objective.force_success ? "completed" : "incomplete"]")


	else if(href_list["obj_gen"])
		var/owner = locate(href_list["obj_owner"])
		if(istype(owner, /datum/role))
			var/datum/role/R = owner
			var/list/prev_objectives = R.objectives.objectives.Copy()
			R.ForgeObjectives()
			var/list/unique_objectives_role = find_unique_objectives(R.objectives.objectives, prev_objectives)
			if (!unique_objectives_role.len)
				alert(usr, "No new objectives generated.", "Alert", "OK")
			else
				for (var/datum/objective/objective in unique_objectives_role)
					log_admin("[usr.key]/([usr.name]) gave [key]/([name]) the objective: [objective.explanation_text]")
		else if(istype(owner, /datum/faction))
			var/datum/faction/F = owner
			var/list/faction_objectives = F.GetObjectives()
			var/list/prev_objectives = faction_objectives.Copy()
			F.forgeObjectives()
			var/list/unique_objectives_faction = find_unique_objectives(F.GetObjectives(), prev_objectives)
			if (!unique_objectives_faction.len)
				alert(usr, "No new objectives generated.", "Alert", "OK")
			else
				for (var/datum/objective/objective in unique_objectives_faction)
					message_admins("[usr.key]/([usr.name]) gave \the [F.ID] the objective: [objective.explanation_text]")
					log_admin("[usr.key]/([usr.name]) gave \the [F.ID] the objective: [objective.explanation_text]")

	else if(href_list["role"]) //Something role specific
		var/datum/role/R = locate(href_list["role"])
		R.Topic(href, href_list)

	else if (href_list["obj_announce"])
		to_chat(src.current, "<span class='notice'>Your objectives are:</span>")
		for (var/role in antag_roles)
			var/datum/role/R = antag_roles[role]
			R.AnnounceObjectives()
	role_panel()

/datum/mind/proc/make_AI_Malf()
	if(!isAI(current))
		return
	if(ismalf(current))
		return
	var/datum/faction/F = ticker.mode.CreateFaction(/datum/faction/malf, 0, 1) //Each malf AI is under its own faction
	if(!F)
		return 0
	return F.HandleNewMind(src)

/datum/mind/proc/make_Nuke()
	if(isnukeop(current))
		return

	var/datum/faction/F = find_active_faction_by_type(/datum/faction/syndicate/nuke_op)
	if(!F)
		F = ticker.mode.CreateFaction(/datum/faction/syndicate/nuke_op, 0, 1)
		if(!F)
			return 0
		return F.HandleNewMind(src)
	return F.HandleRecruitedMind(src)

// check whether this mind's mob has been brigged for the given duration
// have to call this periodically for the duration to work properly
/datum/mind/proc/is_brigged(duration)
	var/turf/T = current.loc
	if(!istype(T))
		brigged_since = -1
		return 0

	var/is_currently_brigged = 0

	if(istype(T.loc,/area/security/brig))
		is_currently_brigged = 1
		for(var/obj/item/weapon/card/id/card in current)
			is_currently_brigged = 0
			break // if they still have ID they're not brigged
		for(var/obj/item/device/pda/P in current)
			if(P.id)
				is_currently_brigged = 0
				break // if they still have ID they're not brigged

	if(!is_currently_brigged)
		brigged_since = -1
		return 0

	if(brigged_since == -1)
		brigged_since = world.time

	return (duration <= world.time - brigged_since)

/datum/mind/proc/make_traitor()
	if(istraitor(current))
		return
	var/datum/faction/F = find_active_faction_by_type(/datum/faction/syndicate/traitor)
	if(!F)
		F = ticker.mode.CreateFaction(/datum/faction/syndicate/traitor, 0, 1)
		if(!F)
			return FALSE
	return F.HandleNewMind(src)


// --
/datum/mind/proc/GetRole(var/role_id)
	if (role_id in antag_roles)
		return antag_roles[role_id]
	return FALSE

/datum/mind/proc/GetRoleByType(var/type)
	for(var/datum/role/R in antag_roles)
		if(istype(R, type))
			return R

/datum/mind/proc/GetFactionFromRole(var/role_id)
	var/datum/role/R = GetRole(role_id)
	if(R)
		return R.GetFaction()
	return FALSE

//Initialisation procs
/mob/proc/mind_initialize() // vgedit: /mob instead of /mob/living
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		mind.original = src
		if(ticker)
			ticker.minds += mind
		else
			world.log << "## DEBUG: mind_initialize(): No ticker ready yet! Please inform Carn"
	if(!mind.name)
		mind.name = real_name
	mind.current = src

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)
		mind.assigned_role = "Assistant"	//defualt

//MONKEY
/mob/living/carbon/monkey/mind_initialize()
	..()

//slime
/mob/living/carbon/slime/mind_initialize()
	..()
	mind.assigned_role = "slime"

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	mind.assigned_role = "Alien"
	//XENO HUMANOID
/mob/living/carbon/alien/humanoid/queen/mind_initialize()
	..()
	mind.special_role = "Queen"

/mob/living/carbon/alien/humanoid/hunter/mind_initialize()
	..()
	mind.special_role = "Hunter"

/mob/living/carbon/alien/humanoid/drone/mind_initialize()
	..()
	mind.special_role = "Drone"

/mob/living/carbon/alien/humanoid/sentinel/mind_initialize()
	..()
	mind.special_role = "Sentinel"
	//XENO LARVA
/mob/living/carbon/alien/larva/mind_initialize()
	..()
	mind.special_role = "Larva"

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = "AI"

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = "[isMoMMI(src) ? "Mobile MMI" : "Cyborg"]"

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = "pAI"
	mind.special_role = ""

//BLOB
/mob/camera/overmind/mind_initialize()
	..()
	mind.special_role = "Blob"

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"

/mob/living/simple_animal/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"

/mob/living/simple_animal/construct/builder/mind_initialize()
	..()
	mind.assigned_role = "Artificer"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/wraith/mind_initialize()
	..()
	mind.assigned_role = "Wraith"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/armoured/mind_initialize()
	..()
	mind.assigned_role = "Juggernaut"
	mind.special_role = "Cultist"

/mob/living/simple_animal/vox/armalis/mind_initialize()
	..()
	mind.assigned_role = "Armalis"
	mind.special_role = "Vox Raider"

/proc/get_ghost_from_mind(var/datum/mind/mind)
	if(!mind)
		return
	for(var/mob/M in player_list)
		M = M.get_bottom_transmogrification()
		if(isobserver(M))
			if(M.mind == mind)
				return M

/proc/mind_can_reenter(var/datum/mind/mind)
	var/mob/dead/observer/G = get_ghost_from_mind(mind)
	var/mob/M
	if(G)
		M = G.get_top_transmogrification()
		if(M.client && G.can_reenter_corpse)
			return G
