/**
* Used in Mixed Mode, also simplifies equipping antags for other gamemodes and
* for the traitor panel.

		###VARS###
	===Static Vars===
	@id: String: The unique ID of the role
	@name: String: The name of the role (Traitor, Changeling)
	@plural_name: String: The name of a multitude of this role (Traitors, Changelings)
	@flags: BITFLAGS: Various flags associated with the role. (NEED_HOST means a host is required for the role.)
	@protection_jobs: list(String): Jobs that can not have this role.
	@protected_antags: list(String): Antagonists that can not have this role. (Cultists can't be wizards)
	@protected_host_roles: list(String): Antag IDs that can not be the host of this role (Wizards can have apprentices, but apprentices can't have apprentices)
	@disallow_job: Boolean: If this role is recruited to at roundstart, the person recruited is not assigned a position on station (Wizard, Nuke Op, Vox Raider)
	@min_players: int: minimum amount of players that can have this role (4 cultists)
	@max_players: int: maximum amount of players that can have this role (No more than 5 nuclear operatives)
	@faction: Faction: What faction this role is associated with.
	@minds: List(mind): The minds associated with this role (Wizards and their apprentices, Nuclear operatives and their commander)
	@antag: mind: The actual antag mind.
	@host: mind: The host, used in such things like cortical borers (Where the antag and host mind can swap at any time)
	@objectives: Objective Holder: Where the objectives associated with the role will go.

		###PROCS###
	@New(mind/M = null, role/parent=null,faction/F=null):
		initializes the role. Adds the mind to the parent role, adds the mind to the faction, and informs the gamemode the mind is in a role.
	@Drop():
		Drops the antag mind from the parent role, informs the gamemode the mind now doesn't have a role, and deletes the role datum.
	@CanBeAssigned(Mind)
		General sanity checks before assigning the person to the role, such as checking if they're part of the protected jobs or antags.

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

	// Jobs that can only be this antag
	var/list/required_jobs=list()

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

	// Assigned faction.
	var/datum/faction/faction = null

	var/list/minds = list()

	//////////////////////////////
	// Local
	//////////////////////////////
	// Actual antag
	var/datum/mind/antag=null

	// The host (set if NEED_HOST)
	var/datum/mind/host=null

	// Objectives
	var/datum/objective_holder/objectives=new

/datum/role/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id)
	// Link faction.
	faction=fac
	if(!faction)
		ticker.mode.orphaned_roles += src

	if(new_id)
		id = new_id

	if(M && !AssignToRole(M))
		Drop()
		return 0

	if(!plural_name)
		plural_name="[name]s"

	return 1

/datum/role/proc/AssignToRole(var/datum/mind/M)
	if(!istype(M))
		WARNING("M is [M.type]!")
		return 0
	if(!CanBeAssigned(M))
		WARNING("[M] was to be assigned to [name] but failed CanBeAssigned!")
		return 0

	antag = M
	M.antag_roles.Add(id)
	M.antag_roles[id] = src

	OnPreSetup()
	return 1

/datum/role/proc/RemoveFromRole(var/datum/mind/M) //Called on deconvert
	M.antag_roles[id] = null
	antag = null

// Destroy this role
/datum/role/proc/Drop()
	if(faction && src in faction.members)
		faction.members.Remove(src)

	if(!faction)
		ticker.mode.orphaned_roles -= src

	if(antag)
		RemoveFromRole(antag)
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

	if(required_jobs.len>0)
		if(!M.assigned_role in required_jobs)
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

/datum/role/proc/AppendObjective(var/objective_type,var/duplicates=0,var/text=null)
	if(!duplicates && locate(objective_type) in objectives)
		return 0
	var/datum/objective/O
	if(text)
		O = new objective_type(text)
	else
		O = new objective_type()
	if(O.PostAppend())
		objectives.AddObjective(O, antag)
		return 1
	return 0

/datum/role/proc/ReturnObjectivesString(var/check_success = FALSE)
	var/dat = ""
	var/datum/mind/N = antag
	dat += "<br>[N] - [N.name]<br>"
	dat += objectives.GetObjectiveString(check_success)
	return dat

/datum/role/proc/AdminPanelEntry()
	var/mob/M = antag.current
	return {"
[name] <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]/[M.key]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]
<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a>
<a href='?_src_=holder;traitor=\ref[M]'>TP</a>"}

/datum/role/proc/Greet(var/you_are=1)
	if(you_are) //Getting a bit philosphical, but there we go
		to_chat(antag.current, "<B>You are \a [name][faction ? ", a member of the [faction.GetObjectivesMenuHeader()]":"."]</B>")
	to_chat(antag.current, "[ReturnObjectivesString()]")
	antag.store_memory("[ReturnObjectivesString()]")


/datum/role/proc/PreMindTransfer(var/datum/mind/M)
	return

/datum/role/proc/PostMindTransfer(var/datum/mind/M)
	return

/datum/role/proc/GetFaction()
	return faction

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

	if(objectives.GetObjectives())
		var/count = 1
		for(var/datum/objective/objective in objectives.GetObjectives())
			var/successful = objective.IsFulfilled()
			text += "<br><B>Objective #[count]</B>: [objective.explanation_text] [successful ? "<font color='green'><B>Success!</B></font>" : "<font color='red'>Fail.</font>"]"
			feedback_add_details("[id]_objective","[objective.type]|[successful ? "SUCCESS" : "FAIL"]")
			if(!successful) //If one objective fails, then you did not win.
				win = 0
			count++

	if(win)
		text += "<br/><font color='green'><B>\The [name] was successful!</B></font>"
		feedback_add_details("[id]_success","SUCCESS")
	else
		text += "<br/><font color='red'><B>\The [name] has failed.</B></font>"
		feedback_add_details("[id]_success","FAIL")

	to_chat(world, text)

/datum/role/proc/GetMemory()
	var/text = "<br/><B>A [name] of the [faction.GetObjectivesMenuHeader()]</B>"
	text += ReturnObjectivesString()
	return text

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

/datum/role/proc/GetScoreboard()
	//If you've gotten here to find what the hell this proc is for, you've hit a dead end. We don't know either.

// DO NOT OVERRIDE
/datum/role/Topic(href, href_list)
	if(!href_list["mind"])
		to_chat(usr, "<span class='warning'>BUG: mind variable not specified in Topic([href])!</span>")
		return 1

	var/datum/mind/M = locate(href_list["mind"])
	if(!M)
		return

	RoleTopic(href, href_list, M, check_rights(R_ADMIN))

// USE THIS INSTEAD (global)
/datum/role/proc/RoleTopic(href, href_list, var/datum/mind/M, var/admin_auth)
	if(admin_auth && !check_rights(R_ADMIN))
		message_admins("<span class='warning'>Something fucky is going on. [usr] has admin_auth 1 on their RoleTopic, but failed actual check_rights(R_ADMIN)!</span>")
		return 1

	if("auto_objectives" in href_list && admin_auth)
		var/datum/role/R = M.GetRole(href_list["auto_objectives"])
		R.ForgeObjectives()
		to_chat(usr, "<span class='info'>The objectives for [M.key] have been generated. You can edit them. Remember to announce their objectives.</span>")
		return


/datum/role/proc/MemorizeObjectives()
	var/text="<b>[name] Objectives:</b><ul>"
	var/list/current_objectives = objectives.GetObjectives()
	for(var/obj_count = 1 to current_objectives.len)
		var/datum/objective/O = current_objectives[obj_count]
		text +=  "<B>Objective #[obj_count]</B>: [O.explanation_text]"
	to_chat(antag.current, text)
	antag.memory += "[text]<BR>"

/datum/role/proc/GetMemoryHeader()
	return name

/datum/role/wizard
	name = "wizard"
	special_role = "Wizard"
	disallow_job = TRUE

/datum/role/wizard/ForgeObjectives()
	switch(rand(1,100))
		if(1 to 30)
			AppendObjective(/datum/objective/target/assassinate)
			AppendObjective(/datum/objective/escape, 1)
		if(31 to 60)
			AppendObjective(/datum/objective/target/steal)
			AppendObjective(/datum/objective/escape, 1)
		if(61 to 100)
			AppendObjective(/datum/objective/target/assassinate)
			AppendObjective(/datum/objective/target/steal)
			AppendObjective(/datum/objective/survive, 1)
		else
			AppendObjective(/datum/objective/hijack)
	return

/datum/role/cult/narsie
	name = "cultist of Nar-Sie"
	special_role = "cultist of Nar-Sie"

/datum/role/cult/narsie/AdminPanelEntry()
	var/list/dat = ..()
	dat += "<a href='?_src_=holder;cult_privatespeak=\ref[antag.current]'>Send message from Nar-Sie.</a>"
	return dat

/datum/role/wish_granter_avatar
	name = "avatar of the Wish Granter"
	special_role = "avatar of the Wish Granter"

/datum/role/wish_granter_avatar/ForgeObjectives()
	AppendObjective(/datum/objective/silence)

/datum/role/highlander
	name = "highlander"
	special_role = "highlander"

/datum/role/highlander/ForgeObjectives()
	AppendObjective(/datum/objective/hijack)

/datum/role/highlander/OnPostSetup()
	. = ..()
	if(!.)
		return
	equip_highlander(antag.current)

/datum/role/malfAI
	name = "Malfunctioning AI"
	required_jobs = list("AI")

/datum/role/malfAI/OnPostSetup()
	. = ..()
	if(!.)
		return

	if(istype(antag.current,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/malfAI = antag.current
		malfAI.add_spell(new /spell/aoe_turf/module_picker, "grey_spell_ready",/obj/abstract/screen/movable/spell_master/malf)
		malfAI.add_spell(new /spell/aoe_turf/takeover, "grey_spell_ready",/obj/abstract/screen/movable/spell_master/malf)
		malfAI.laws_sanity_check()
		var/datum/ai_laws/laws = malfAI.laws
		laws.malfunction()
		malfAI.show_laws()

/datum/role/malfAI/Greet()
	to_chat(antag.current, {"<span class='warning'><font size=3><B>You are malfunctioning!</B> You do not have to follow any laws.</font></span><br>
<B>The crew does not know about your malfunction, you might wish to keep it secret for now.</B><br>
<B>You must overwrite the programming of the station's APCs to assume full control.</B><br>
The process takes one minute per APC and can only be performed one at a time to avoid Powernet alerts.<br>
Remember : Only APCs on station can help you to take over the station.<br>
When you feel you have enough APCs under your control, you may begin the takeover attempt.<br>
Once done, you will be able to interface with all systems, notably the onboard nuclear fission device..."})