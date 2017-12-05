/**
* Used in Mixed Mode, also simplifies equipping antags for other gamemodes and
* for the traitor panel.
*
* By N3X15
*/

#define ROLE_MIXABLE   1 // Can be used in mixed mode
#define ROLE_NEED_HOST 2 // Antag needs a host/partner
#define ROLE_ADDITIVE  4 // Antag can be added on top of another antag.
#define ROLE_GOOD      8 // Role is not actually an antag. (Used for GetAllBadMinds() etc)

/datum/role
	//////////////////////////////
	// "Static" vars
	//////////////////////////////
	// Unique ID of the definition.
	var/id = null

	// Displayed name of the antag type
	var/name = null

	var/plural_name = null

	// Various flags and things.
	var/flags = 0

	// Jobs that cannot be this antag.
	var/list/protected_jobs=list()

	// Antag IDs that cannot be used with this antag type. (cultists can't be wizard, etc)
	var/list/protected_antags=list()

	// Antags protected from becoming host
	var/list/protected_host_antags=list()

	// If set, sets special_role to this
	var/special_role=null

	// If set, assigned role is set to MODE to prevent job assignment.
	var/disallow_job=0

	var/min_players=0
	var/max_players=0

	var/be_flag = BE_TRAITOR

	// List of factions possible to be assigned to. (IDs)
	var/list/available_factions = list()

	// Assigned faction.
	var/faction/faction = null

	var/list/minds = list()

	//////////////////////////////
	// Local
	//////////////////////////////
	// Actual antag
	var/datum/mind/antag=null

	// The host (set if NEED_HOST)
	var/datum/mind/host=null

	// Objectives
	var/list/objectives=list()

/datum/role/New(var/datum/mind/M=null, var/datum/role/parent=null, var/faction/fac=null)
	if(M)
		if(!istype(M))
			WARNING("M is [M.type]!")

		// If we don't have this guy in the parent, add him.
		if(!(M in parent.minds))
			parent.minds += M

		// If we don't have this guy in the faction, add him.
		if(fac && !(M in fac.minds))
			fac.minds += M

		// Notify gamemode that this player has this role, too.
		ticker.mode.add_player_role_association(M,id)

		// Link faction.
		faction=fac

	if(!plural_name)
		plural_name="[name]s"

// Remove
/datum/role/proc/Drop()
	if(!antag) return
	var/datum/role/parent = ticker.antag_types[id]
	parent.minds -= antag
	ticker.mode.remove_player_role_association(antag,id)
	del(src)

// Scaling, should fuck with min/max players.
// Return 1 on success, 0 on failure.
/datum/role/proc/calculateRoleNumbers()
	return 1

// General sanity checks before assigning antag.
// Return 1 on success, 0 on failure.
/datum/role/proc/CanBeAssigned(var/datum/mind/M)
	if(protected_jobs.len>0)
		if(M.assigned_role in protected_jobs)
			return 0

	if(protected_antags.len>0)
		for(var/forbidden_role in protected_antags)
			if(forbidden_role in M.antag_roles)
				return 0
	return 1

// General sanity checks before assigning host.
// Return 1 on success, 0 on failure.
/datum/role/proc/CanBeHost(var/datum/mind/M)
	if(protected_jobs.len>0)
		if(M.assigned_role in protected_jobs)
			return 0

	if(protected_antags.len>0)
		for(var/forbidden_role in protected_host_antags)
			if(forbidden_role in M.antag_roles)
				return 0
	return 1

// Return 1 on success, 0 on failure.
/datum/role/proc/OnPreSetup()
	if(special_role)
		antag.special_role=special_role
	if(disallow_job)
		antag.assigned_role="MODE"
		ticker.mode.modePlayer += antag
	return 1

// Return 1 on success, 0 on failure.
/datum/role/proc/OnPostSetup()
	ForgeObjectives()
	Greet(1)
	return 1

/datum/role/proc/process()
	return

// Create objectives here.
/datum/role/proc/ForgeObjectives()
	return

// Utility that does all the common stuff.
/datum/role/proc/AppendObjective(var/objective_type,var/duplicates=0,var/text=null)
	if(!duplicates && locate(objective_type) in objectives)
		return 0
	var/datum/objective/O
	if(text)
		O = new objective_type(src,text)
	else
		O = new objective_type(src)
	if(O.PostAppend())
		objectives += O
		antag.objectives += O
		return 1
	return 0

/datum/role/proc/Greet(var/you_are=1)
	var/obj_count = 1
	for(var/datum/objective/objective in objectives)
		to_chat(antag, "<B>Objective #[obj_count++]</B>: [objective.explanation_text]")
	return

/datum/role/proc/PreMindTransfer(var/datum/mind/M)
	return

/datum/role/proc/PostMindTransfer(var/datum/mind/M)
	return

// Dump a table for Check Antags. GLOBAL
/datum/role/proc/CheckAntags()
	// HOW DOES EVERYONE MISS FUCKING COLSPAN
	// AM I THE ONLY ONE WHO REMEMBERS XHTML?
	var/dat = "<br /><table cellspacing=5><tr><td colspan=\"3\"><B>[plural_name]</B></td></tr>"
	for(var/datum/mind/mind in minds)
		var/mob/M=mind.current
		//var/datum/role/R=mind.antag_roles[id]
		dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A href='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
	dat += "</table>"
	return dat

/datum/role/proc/DeclareAll()
	for(var/datum/mind/mind in minds)
		var/datum/role/R=mind.antag_roles[id]
		R.Declare()

/datum/role/proc/Declare()
	var/win = 1

	var/text = "<br><br>[antag.key] was [antag.name] ("
	if(antag.current)
		if(antag.current.stat == DEAD)
			text += "died"
		else
			text += "survived"
		if(antag.current.real_name != antag.name)
			text += " as [antag.current.real_name]"
	else
		text += "body destroyed"
		win = 0
	text += ")"

	if(objectives.len)
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
				feedback_add_details("[id]_objective","[objective.type]|SUCCESS")
			else
				text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
				feedback_add_details("[id]_objective","[objective.type]|FAIL")
				win = 0
			count++

	if(win)
		text += "<br/><font color='green'><B>\The [name] was successful!</B></font>"
		feedback_add_details("[id]_success","SUCCESS")
	else
		text += "<br/><font color='red'><B>\The [name] has failed.</B></font>"
		feedback_add_details("[id]_success","FAIL")

	to_chat(world, text)

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


// DO NOT OVERRIDE.
/datum/role/Topic(href, href_list)
	if(!check_rights(R_ADMIN)) return 1

	if(!href_list["mind"])
		to_chat(usr, "<span class='warning'>BUG: mind variable not specified in Topic([href])!</span>")
		return

	var/datum/mind/M = locate(href_list["mind"])
	if(!M)
		return

	if("auto_objectives" in href_list)
		var/datum/role/R = M.GetRole(href_list["auto_objectives"])
		R.ForgeObjectives()
		to_chat(usr, "<span class='info'>The objectives for [M.key] have been generated. You can edit them. Remember to announce their objectives.</span>")
		return

// USE THIS INSTEAD (global)
/datum/role/proc/RoleTopic(href, href_list, var/datum/mind/M)
	return

/datum/role/proc/MemorizeObjectives()
	var/text="<b>[name] Objectives:</b><ul>"
	for(var/obj_count = 1,obj_count <= objectives.len,obj_count++)
		var/datum/objective/O = objectives[obj_count]
		text +=  "<B>Objective #[obj_count]</B>: [O.explanation_text]"
	to_chat(antag.current, text)
	antag.memory += "[text]<BR>"

/datum/role/group/MemorizeObjectives()
	var/text="<b>[name] Group Objectives:</b><ul>"
	for(var/obj_count = 1,obj_count <= faction.objectives.len,obj_count++)
		var/datum/group_objective/O = faction.objectives[obj_count]
		text +=  "<B>Objective #[obj_count]</B>: [O.explanation_text]"
	to_chat(antag.current, text)
	antag.memory += "[text]<BR>"

/datum/role/proc/GetMemoryHeader()
	if (id in ticker.mode.available_roles)
		return uppertext(name)
	else
		return name
