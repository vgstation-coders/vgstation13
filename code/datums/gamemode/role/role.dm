/**
* Used in Dynamic Mode, also simplifies equipping antags for other gamemodes and
* for the role panel.

		###VARS###
	===Static Vars===
	@id: String: The unique ID of the role
	@name: String: The name of the role (Traitor, Changeling)
	@plural_name: String: The name of a multitude of this role (Traitors, Changelings)
	@protection_jobs: list(String): Jobs that can not have this role.
	@protected_antags: list(String): Antagonists that can not have this role. (Cultists can't be wizards)
	@disallow_job: Boolean: If this role is recruited to at roundstart, the person recruited is not assigned a position on station (Wizard, Nuke Op, Vox Raider)
	@min_players: int: minimum amount of players that can have this role (4 cultists)
	@max_players: int: maximum amount of players that can have this role (No more than 5 nuclear operatives)
	@faction: Faction: What faction this role is associated with.
	@minds: List(mind): The minds associated with this role (Wizards and their apprentices, Nuclear operatives and their commander)
	@antag: mind: The actual antag mind.
	@objectives: Objective Holder: Where the objectives associated with the role will go.

		###PROCS###
	@New(mind/M = null, role/parent=null,faction/F=null):
		initializes the role. Adds the mind to the parent role, adds the mind to the faction, and informs the gamemode the mind is in a role.
	@Drop():
		Drops the antag mind from the parent role, informs the gamemode the mind now doesn't have a role, and deletes the role datum.
	@CanBeAssigned(Mind)
		General sanity checks before assigning the person to the role, such as checking if they're part of the protected jobs or antags.
	@PreMindTransfer(Old_character, Mob/Living)
		Things to do to the *old* body prior to the mind transfer.
	@PostMindTransfer(New_character, Mob/Living, Old_character, Mob/Living)
		Things to do to the *new* body after the mind transfer is completed.

	@update_perception()
		Called on Life() to handle the role's additional alphas to the dark plane.
*/

/datum/role
	//////////////////////////////
	// "Static" vars
	//////////////////////////////
	// Unique ID of the definition.
	var/id = null

	// Displayed name of the antag type
	var/name = null

	var/plural_name = null

	// Jobs that cannot be this antag.
	var/list/restricted_jobs = list()

	// Jobs that have a much lower chance to be this antag.
	var/list/protected_jobs = list()
	var/protected_traitor_prob = PROB_PROTECTED_REGULAR

	// Jobs that can only be this antag
	var/list/required_jobs=list()

	// Antag IDs that cannot be used with this antag type. (cultists can't be wizard, etc)
	var/list/protected_antags=list()

	// If set, sets special_role to this
	var/special_role=null

	// The required preference for this role
	var/required_pref = ""

	// If set, assigned role is set to MODE to prevent job assignment.
	var/disallow_job=0

	var/min_players=0
	var/max_players=0

	// Assigned faction.
	var/datum/faction/faction = null

	var/list/minds = list()

	var/is_antag = TRUE // Is role antag or not?

	//////////////////////////////
	// Local
	//////////////////////////////
	// Actual antag
	var/datum/mind/antag=null
	var/destroyed = FALSE //Whether or not it has been gibbed

	var/list/uplink_items_bought = list() //migrated from mind, used in GetScoreboard()

	// Objectives
	var/datum/objective_holder/objectives=new
	var/logo_icon = 'icons/logos.dmi'
	var/logo_state = "synd-logo"

	var/default_admin_voice = "Supreme Leader"
	var/admin_voice_style = "radio" // check stylesheet.dm for a list of all possible styles
	var/list/voice_per_admin = list()
	var/admin_voice_say = "says"

	var/list/greets = list(GREET_DEFAULT,GREET_CUSTOM)

	var/wikiroute
	var/threat_generated = 0
	var/threat_level_inflated = 0

	var/list/current_powers = list()
	var/list/available_powers = list()		//holds instances of each power
	var/datum/power_holder/power_holder
	var/powerpoints = 0

	// This datum represents all data that is exported to the statistics file at the end of the round.
	// If you want to store faction-specific data as statistics, you'll need to define your own datum.
	// See dynamic_stats.dm
	var/datum/stat/role/stat_datum = null
	var/datum/stat/role/stat_datum_type = /datum/stat/role

/datum/role/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id, var/override = FALSE)
	// Link faction.
	faction=fac
	if(!faction)
		ticker.mode.orphaned_roles += src
	else
		faction.members += src

	if(new_id)
		id = new_id

	if(M && !AssignToRole(M, override))
		Drop()
		return 0

	if(!plural_name)
		plural_name="[name]s"

	objectives.owner = M
	stat_datum = new stat_datum_type()

	return 1

/datum/role/proc/AssignToRole(var/datum/mind/M, var/override = 0, var/msg_admins = TRUE)
	if(!istype(M) && !override)
		stack_trace("M is [M.type]!")
		return 0
	if(!CanBeAssigned(M) && !override)
		stack_trace("[M.name] was to be assigned to [name] but failed CanBeAssigned!")
		return 0

	antag = M
	M.antag_roles.Add(id)
	M.antag_roles[id] = src
	objectives.owner = M

	if (!OnPreSetup())
		return FALSE

	if(msg_admins)
		message_admins("[key_name(M)] is now \an [id].[M.current ? " [formatJumpTo(M.current)]" : ""]")
	return 1

/datum/role/proc/RemoveFromRole(var/datum/mind/M, var/msg_admins = TRUE) //Called on deconvert
	M.antag_roles[id] = null
	M.antag_roles.Remove(id)
	if(msg_admins)
		message_admins("[key_name(M)] is <span class='danger'>no longer</span> \an [id].[M.current ? " [formatJumpTo(M.current)]" : ""]")
	antag = null

// Destroy this role
/datum/role/proc/Drop()
	if(faction && (src in faction.members))
		faction.update_hud_removed(src)
		faction.members.Remove(src)
		update_faction_icons()

	if(!faction)
		ticker.mode.orphaned_roles.Remove(src)

	if(antag)
		RemoveFromRole(antag)
	qdel(src)

// Scaling, should fuck with min/max players.
// Return 1 on success, 0 on failure.
/datum/role/proc/calculateRoleNumbers()
	return 1

// General sanity checks before assigning antag.
// Return 1 on success, 0 on failure.
/datum/role/proc/CanBeAssigned(var/datum/mind/M)
	if(restricted_jobs.len>0)
		if(M.assigned_role in restricted_jobs)
			return 0

	if(protected_antags.len>0)
		for(var/forbidden_role in protected_antags)
			if(forbidden_role in M.antag_roles)
				return 0

	if(required_jobs.len>0)
		if(!(M.assigned_role in required_jobs))
			return 0

	if(is_type_in_list(src, M.antag_roles)) //No double double agent agent
		return 0
	return 1

// Return 1 on success, 0 on failure.
/datum/role/proc/OnPreSetup()
	if(special_role)
		antag.special_role=special_role
	if(disallow_job)
		var/datum/job/job = job_master.GetJob(antag.assigned_role)
		if(job)
			job.current_positions--
		antag.assigned_role="MODE"
	return 1

//remove all power-related spells
/datum/role/proc/removespells()
	for(var/datum/power/P in current_powers)
		P.remove_spell()

//Remove and re-grant role-related power spells
/datum/role/proc/refreshpowers()
	for(var/datum/power/P in current_powers)
		P.remove_spell()
		P.grant_spell()

// Return 1 on success, 0 on failure.
/datum/role/proc/OnPostSetup(var/laterole = FALSE)
	return 1

/datum/role/proc/update_antag_hud()
	return

/datum/role/proc/process()
	return

/datum/role/proc/check_win()
	return

// called on Life()

/datum/role/proc/update_perception()
	return

// Create objectives here.
/datum/role/proc/ForgeObjectives()
	return

/datum/role/proc/AppendObjective(var/objective_type,var/duplicates=0)
	if(!duplicates && locate(objective_type) in objectives)
		return FALSE
	var/datum/objective/O
	if(istype(objective_type, /datum/objective)) //Passed an actual objective
		O = objective_type
	else
		O = new objective_type
	if(objectives.AddObjective(O, antag))
		return TRUE
	return FALSE

/datum/role/proc/ReturnObjectivesString(var/check_success = FALSE, var/check_name = TRUE)
	var/dat = ""
	if(check_name)
		var/datum/mind/N = antag
		dat += "<br>[N] - [N.name]<br>"
	dat += objectives.GetObjectiveString(check_success)
	return dat

/datum/role/proc/AdminPanelEntry(var/show_logo = FALSE,var/datum/admins/A)
	var/icon/logo = icon(logo_icon, logo_state)
	if(!antag)
		return {"Mind destroyed. That shouldn't ever happen."}
	if (!ismob(usr))
		return
	var/mob/user = usr
	if (!(user.ckey in voice_per_admin))
		voice_per_admin[user.ckey] = default_admin_voice
	var/mob/M = antag.current
	if (M)
		return {"[show_logo ? "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> " : "" ]
	[name] <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]/[antag.key]</a>[M.client ? "" : " <i> - ([loggedOutHow()])</i>"][M.stat == DEAD ? " <b><font color=red> - (DEAD)</font></b>" : ""]
	 - <a href='?src=\ref[usr];priv_msg=\ref[M]'>(admin PM)</a>
	 - <a href='?_src_=holder;traitor=\ref[M]'>(role panel)</a>
	 - <a href='?src=\ref[src]&mind=\ref[antag]&role_speak=\ref[M]'>(Message as:</a><a href='?src=\ref[src]&mind=\ref[antag]&role_set_speaker=\ref[M]'>\[[voice_per_admin[user.ckey]]\])</a>"}
	else
		return {"[show_logo ? "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> " : "" ]
	[name] [antag.name]/[antag.key]<b><font color=red> - (DESTROYED)</font></b>
	 - <a href='?src=\ref[usr];priv_msg=\ref[M]'>(priv msg)</a>
	 - <a href='?_src_=holder;traitor=\ref[M]'>(role panel)</a>
	 - <a href='?src=\ref[src]&mind=\ref[antag]&role_speak=\ref[M]'>(Message as:</a><a href='?src=\ref[src]&mind=\ref[antag]&role_set_speaker=\ref[M]'>\[[voice_per_admin[user.ckey]]\])</a>"}


/datum/role/proc/loggedOutHow()
	return "logged out"

/datum/role/proc/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon(logo_icon, logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>[custom]</B>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>You are \a [name][faction ? ", a member of the [faction.GetObjectivesMenuHeader()]":"."]</B>")

/datum/role/proc/PreMindTransfer(var/mob/living/old_character)
	return

/datum/role/proc/PostMindTransfer(var/mob/living/new_character, var/mob/living/old_character)
	return

/datum/role/proc/GetFaction()
	return faction

/datum/role/proc/GetScoreboard()
	var/win = 1
	var/text = ""
	var/mob/M
	if (antag)
		M = antag.current
	if (!M)
		var/icon/sprotch = icon('icons/effects/blood.dmi', "sprotch")
		text += "<img src='data:image/png;base64,[icon2base64(sprotch)]' style='position:relative; top:10px;'/>"
	else
		var/icon/flat = getFlatIcon(M, SOUTH, 0, 1)
		if(M.stat == DEAD)
			if (ishuman(M) || ismonkey(M))
				flat.Turn(90)
			var/icon/ded = icon('icons/effects/blood.dmi', "floor1-old")
			ded.Blend(flat,ICON_OVERLAY)
			text += "<img class='icon' src='data:image/png;base64,[iconsouth2base64(ded)]' style='position:relative; top:10px;'>"
		else
			text += "<img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]' style='position:relative; top:10px;'>"

	var/icon/logo = icon(logo_icon, logo_state)
	text += "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative;top:10px;'/><b>[antag ? "[antag.key]" : "(somebody)"]</b> was <b>[antag ? "[antag.name]" : "(someone)"]</b> ("
	if(M)
		if(!antag.GetRole(id))
			text += "removed"
		else if(M.stat == DEAD)
			text += "died"
		else
			text += "survived"
		if(antag.current.real_name != antag.name)
			text += " as <b>[antag.current.real_name]</b>"
	else
		text += "body destroyed"
		win = 0
	text += ")"

	if(objectives.objectives.len > 0)
		var/count = 1
		text += "<ul>"
		var/fully_freeform = TRUE
		for(var/datum/objective/objective in objectives.GetObjectives())
			var/freeform = objective.flags & FREEFORM_OBJECTIVE
			if (!freeform)
				fully_freeform = FALSE
			var/successful = objective.IsFulfilled()
			text += "<B>Objective #[count]</B>: [objective.explanation_text] [freeform ? "" : "[successful ? "<font color='green'><B>Success!</B></font>" : "<font color='red'>Fail.</font>"]"]"
			feedback_add_details("[id]_objective","[objective.type]|[freeform ? "FREEFORM" : "[successful ? "SUCCESS" : "FAIL"]"]")
			if(!successful) //If one objective fails, then you did not win.
				win = 0
			if (count < objectives.objectives.len)
				text += "<br>"
			count++
		if (!faction && !fully_freeform)
			if(win)
				text += "<br><font color='green'><B>\The [name] was successful!</B></font>"
				feedback_add_details("[id]_success","SUCCESS")
			else
				text += "<br><font color='red'><B>\The [name] has failed.</B></font>"
				feedback_add_details("[id]_success","FAIL")
	if(objectives.objectives.len > 0)
		text += "</ul>"

	stat_collection.add_role(src, win)

	return text

/datum/role/proc/extraPanelButtons()
	var/dat = ""
	//example:
	//dat = " - <a href='?src=\ref[M];spawnpoint=\ref[src]'>(move to spawn)</a>"
	return dat

/datum/role/proc/GetMemory(var/datum/mind/M, var/admin_edit = FALSE)
	var/icon/logo = icon(logo_icon, logo_state)
	var/text = "<b><img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [name]</b>"
	if (admin_edit)
		text += " - <a href='?src=\ref[M];role_edit=\ref[src];remove_role=1'>(remove)</a> - <a href='?src=\ref[M];greet_role=\ref[src]'>(greet)</a>[extraPanelButtons()]"
	text += "<br>faction: "
	if (faction)
		text += faction.name
	else
		text += "<i>none</i> <br/>"
	if (admin_edit)
		text += " - "
		if (faction)
			text += "<a href='?src=\ref[M];role_edit=\ref[src];remove_from_faction=1'>(remove)</a>"
		else
			text += "<a href='?src=\ref[M];role_edit=\ref[src];add_to_faction=1'>(add)</a>"
	text += "<br>"
	if (objectives.objectives.len)
		text += "<b>personal objectives</b><br><ul>"
	text += objectives.GetObjectiveString(0,admin_edit,M, src)
	if (objectives.objectives.len)
		text += "</ul>"
	if (faction && faction.objective_holder)
		if (faction.objective_holder.objectives.len)
			if (objectives.objectives.len)
				text += "<br>"
			text += "<b>faction objectives</b><ul>"
			text += "<br/>"
		text += faction.objective_holder.GetObjectiveString(0,admin_edit,M)
		if (faction.objective_holder.objectives.len)
			text += "</ul>"
	text += "<br>"
	return text
/*
/datum/role_controls
	var/list/controls[0] // Associative, Label = html
	var/list/warnings[0] // Just a list

/datum/role_controls/proc/Render(var/_type)
	var/html = ""
	if(warnings.len)
		html += "<ul class='warnings'>"
		for(var/warning in warnings)
			html += "<li>[warning]</li>"
		html += "</ul>"
	if(controls.len)
		html += "<table>"
		for(var/label in controls)
			html += "<tr><th>[label]</th><td>[controls[label]]</td></tr>"
		html += "</table>"
	if(html == "")
		html += "<em>No controls defined in [_type]/EditMemory()!</em>"
	return html

// Called from the global instance, NOT the one in /datum/mind!
/datum/role/proc/EditMemory(var/datum/mind/M)
	var/datum/role_controls/RC = new
	if (!M.GetRole(id))
		RC.controls["Enabled:"] = "<a href='?src=\ref[M];add_role=[id]'>No</a>"
	else
		RC.controls["Enabled:"] = "<a href='?src=\ref[M];remove_role=[id]'>Yes</a>"
	return RC

// DO NOT OVERRIDE, does formatting.
/datum/role/proc/GetEditMemoryMenu(var/datum/mind/M)
	var/datum/role_controls/RC = EditMemory(M)
	return {"
<fieldset>
	<legend>[name]</legend>
	[RC.Render()]
</fieldset>
"}
*/

// DO NOT OVERRIDE
/datum/role/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		to_chat(usr, "You are not an admin.")
		return 0

	if(!href_list["mind"])
		to_chat(usr, "<span class='warning'>BUG: mind variable not specified in Topic([href])!</span>")
		return 1
	var/datum/mind/M = locate(href_list["mind"])
	if(!M)
		return
	RoleTopic(href, href_list, M, check_rights(R_ADMIN))

// USE THIS INSTEAD (global)
/datum/role/proc/RoleTopic(href, href_list, var/datum/mind/M, var/admin_auth)
	if (!ismob(usr))
		return
	var/mob/user = usr

	if (href_list["role_speak"])
		if(!usr.check_rights(R_ADMIN))
			message_admins("[usr] tried to access RoleTopic() without permissions.")
			return
		if (!(user.ckey in voice_per_admin))
			voice_per_admin[user.ckey] = default_admin_voice

		var/message = input("What message shall we send as [voice_per_admin[user.ckey]]?",
                    "Role Message",
                    "")
		if (!message)
			return

		var/mob/mob = M.current

		if (mob)
			to_chat(mob, "<b>[voice_per_admin[user.ckey]]</b> [admin_voice_say] <span class='[admin_voice_style]'>\"[message]\"</span>")

		for(var/mob/dead/observer/O in player_list)
			to_chat(O, "<span class='game say'><b>[voice_per_admin[user.ckey]]</b> [admin_voice_say] (to [mob]) <span class='[admin_voice_style]'>\"[message]\"</span></span>")

		message_admins("Admin [key_name_admin(usr)] has talked to [key_name(mob)] as [voice_per_admin[user.ckey]].")
		log_rolespeak("[key_name(usr)] as [voice_per_admin[user.ckey]] to [key_name(mob)]: \"[message]\"")

	if (href_list["role_set_speaker"])
		if(!usr.check_rights(R_ADMIN))
			message_admins("[usr] tried to access faction RoleTopic() without permissions.")
			return
		if (!(user.ckey in voice_per_admin))
			voice_per_admin[user.ckey] = default_admin_voice

		var/mob/mob = M.current

		if (mob)
			var/new_name = input("What should you call yourself when messaging [mob]?",
	                    "Change Messager Name",
	                    "[voice_per_admin[user.ckey]]")
			if (new_name)
				voice_per_admin[user.ckey] = new_name
		user.client.holder.check_antagonists()

/datum/role/proc/ShuttleDocked(state)
	if(objectives.objectives.len)
		for(var/datum/objective/O in objectives.objectives)
			O.ShuttleDocked(state)

/datum/role/proc/AnnounceObjectives()
	var/text = ""
	if (objectives.objectives.len)
		text += "<b>[capitalize(name)] objectives:</b><ul>"
		var/obj_count = 1
		for(var/datum/objective/O in objectives.objectives)
			text += "<b>Objective #[obj_count++]</b>: [O.explanation_text]<br>"
		text += "</ul>"
	if (faction && faction.objective_holder)
		if (faction.objective_holder.objectives.len)
			if (objectives.objectives.len)
				text += "<br>"
			text += "<b>Faction objectives:</b><ul>"
			var/obj_count = 1
			for(var/datum/objective/O in faction.objective_holder.objectives)
				text += "<b>Objective #[obj_count++]</b>: [O.explanation_text]<br>"
			text += "</ul>"
	to_chat(antag.current, text)

/datum/role/proc/GetMemoryHeader()
	return name

// -- Custom reagent reaction for your antag - now in a (somewhat) maintable fashion

/datum/role/proc/handle_reagent(var/reagent_id)
	return

/datum/role/proc/handle_splashed_reagent(var/reagent_id)
	return

//Does the role have special clothing restrictions?
/datum/role/proc/can_wear(var/obj/item/clothing/C)
	return TRUE

// What do they display on the player StatPanel ?
/datum/role/proc/StatPanel()
	return ""

/datum/role/proc/increment_threat(var/amount)
	var/datum/gamemode/dynamic/D = ticker.mode
	if(!istype(D))
		return //It's not dynamic!
	threat_generated += amount
	if(D.midround_threat >= D.midround_threat_level)
		D.create_midround_threat(amount)
		if(!threat_level_inflated) //Our first time raising the cap
			D.threat_log += "[worldtime2text()]: [name] started increasing the threat cap."
		threat_level_inflated += amount
	else
		D.refund_midround_threat(amount)

/datum/role/proc/decrement_threat(var/amount)
	var/datum/gamemode/dynamic/D = ticker.mode
	if(!istype(D))
		return
	D.spend_midround_threat(amount)
	D.threat_log += "[worldtime2text()]: [name] has decreased the threat amount by [amount]."

/////////////////////////////THESE ROLES SHOULD GET MOVED TO THEIR OWN FILES ONCE THEY'RE GETTING ELABORATED/////////////////////////

//________________________________________________

/datum/role/bomberman
	name = BOMBERMAN
	id = BOMBERMAN
	special_role = BOMBERMAN
	logo_state = "bomb-logo"

//________________________________________________

/datum/role/syndicate_elite_commando
	name = SYNDIESQUADIE
	id = SYNDIESQUADIE
	special_role = SYNDIESQUADIE
	logo_state = "elite-logo"

//________________________________________________

/datum/role/wish_granter_avatar
	name = WISHGRANTERAVATAR
	id = WISHGRANTERAVATAR
	special_role = WISHGRANTERAVATAR
	logo_state = "wish-logo"

/datum/role/wish_granter_avatar/ForgeObjectives()
	AppendObjective(/datum/objective/silence)

//________________________________________________

/datum/role/highlander
	name = HIGHLANDER
	special_role = HIGHLANDER
	id = HIGHLANDER
	logo_state = "high-logo"

/datum/role/highlander/ForgeObjectives()
	AppendObjective(/datum/objective/hijack)

/datum/role/highlander/OnPostSetup(var/laterole = FALSE)
	. = ..()
	if(!.)
		return
	equip_highlander(antag.current)

//________________________________________________

/datum/role/greytide
	name = IMPLANTSLAVE
	id = IMPLANTSLAVE
	logo_state = "greytide-logo"

/datum/role/greytide/Drop(silent = TRUE)
	if (!silent)
		antag.current.visible_message("<span class='userdanger'>[antag.current] briefly convulses!</span>" ,"<span class='userdanger'>Your loyalty to the greytide fades and vanishes. You are free of your actions again.</span>")
	for (var/datum/role/greytide_leader/big_boss in faction.members)
		big_boss.former_minions[antag.key] = antag.name
	return ..()

/datum/role/greytide/PostMindTransfer(var/mob/living/new_character, var/mob/living/old_character)
	for(var/obj/item/weapon/implant/I in new_character)
		if(istype(I, /obj/item/weapon/implant/traitor))
			return
	Drop()
	return ..()


/datum/role/greytide_leader
	name = IMPLANTLEADER
	id = IMPLANTLEADER
	logo_state = "greytide_leader-logo"
	var/list/former_minions = list()

/datum/role/greytide_leader/AdminPanelEntry(var/show_logo = FALSE,var/datum/admins/A)
	if (!(former_minions.len))
		return ..()
	// else...
	var/icon/logo_slave = icon(logo_icon, "greytide-logo")
	var/list/dat = list()
	dat += ..()
	dat += "<br/>The greytide leader's former slaves were: <br/>"
	for (var/ckey in former_minions)
		dat += "[show_logo ? "<img src='data:image/png;base64,[icon2base64(logo_slave)]' style='position: relative; top: 10;'/> " : "" ] <b>[ckey]</b> as <b>[former_minions[ckey]]</b> <br/>"
	return jointext(dat, "")

/datum/role/greytide_leader/GetScoreboard()
	if (!(former_minions.len))
		return ..()
	// else...
	var/icon/logo_slave = icon(logo_icon, "greytide-logo")
	var/list/dat = list()
	dat += ..()
	dat += "<br/>The greytide leader's former slaves were: <br/>"
	for (var/ckey in former_minions)
		dat += "<img src='data:image/png;base64,[icon2base64(logo_slave)]' style='position: relative; top: 10;'/> <b>[ckey]</b> as <b>[former_minions[ckey]]</b><br/>"
	return jointext(dat, "")
