//CULT 4.0 BY DEITY LINK (2021)
//BASED ON CULT 3.0 ALSO BY DEITY LINK (2018)
//BASED ON THE ORIGINAL GAME MODE BY URIST MCDORF (somewhere before 2013)


/datum/faction/bloodcult
	name = "Cult of Nar-Sie"
	ID = BLOODCULT
	initial_role = CULTIST
	late_role = CULTIST
	desc = "A group of shady blood-obsessed individuals whose souls are devoted to Nar-Sie, the Geometer of Blood.\
	From his teachings, they were granted the ability to perform blood magic rituals allowing them to grow their ranks and cause chaos.\
	Nar-Sie's goal is to toy with the crew, before tearing open a breach through reality so he can pull the station into his realm and feast on the crew's blood."
	roletype = /datum/role/cultist
	logo_state = "cult-logo"
	hud_icons = list("cult-apprentice-logo", "cult-logo", "cult-master-logo", "shade-blade")
	default_admin_voice = "<span class='danger'>Nar-Sie</span>" // Nar-Sie's name always appear in red in the chat, makes it stand out.
	admin_voice_style = "sinister"
	admin_voice_say = "murmurs..."
	var/list/bloody_floors = list()
	var/cult_win = FALSE

	var/list/cult_reminders = list()

	var/list/bindings = list()

	var/list/cultist_cap = 1	//clamped between 5 and 9 depending on crew size. once the cap goes up it cannot go down.

	var/mentor_count = 0 	//so we don't loop through the member list if we already know there are no mentors in there

	var/list/arch_cultists = list()
	var/list/departments_left = list("Security", "Medical", "Engineering", "Science", "Cargo")

/datum/faction/bloodcult/check_win()
	if(stage <= FACTION_DEFEATED)
		return FALSE
	if(stage < FACTION_ENDGAME)
		if(departments_left.len < 5)
			stage(FACTION_ENDGAME)
			//command_alert(/datum/command_alert/cult_eclipse_start)
			return FALSE
	if(stage == FACTION_ENDGAME)
		if(departments_left.len == 0)
			stage(FACTION_VICTORY)
			cult_win = TRUE
			return TRUE

/datum/faction/bloodcult/IsSuccessful()
	return cult_win


/datum/faction/bloodcult/process()
	..()
	if (cultist_cap > 1) //The first call occurs in OnPostSetup()
		UpdateCap()


/datum/faction/bloodcult/proc/UpdateCap()
	var/living_players = 0
	var/new_cap = 0
	for (var/mob/M in player_list)
		if (!M.client)
			continue
		if (istype(M,/mob/new_player))
			continue
		if (M.stat != DEAD)
			living_players++
	new_cap =  clamp(round(living_players / 3),5,9)
	if (new_cap > cultist_cap)
		cultist_cap = new_cap
		for (var/datum/role/R in members)
			var/mob/M = R.antag.current
			to_chat(M, "<span class='sinister'>The station population is now large enough for <span class='userdanger'>[cultist_cap]</span> cultists.</span>")

/datum/faction/bloodcult/proc/CanConvert()
	var/cultist_count = 0
	for (var/datum/role/R in members)
		var/mob/M = R.antag.current
		if (isliving(M)) //humans, shades and constructs all count. The dead count for half a member (unless they have no body left).
			if (M.isDead())
				cultist_count += 0.5
			else
				cultist_count += 1

	return (cultist_count < cultist_cap)

/datum/faction/bloodcult/HandleRecruitedRole(var/datum/role/R)
	. = ..()
	if (cult_reminders.len)
		to_chat(R.antag.current, "<span class='notice'>Other cultists have shared some of their knowledge. It will be stored in your memory (check your Notes under the IC tab).</span>")
	for (var/reminder in cult_reminders)
		R.antag.store_memory("Shared Cultist Knowledge: [reminder].")

/datum/faction/bloodcult/AdminPanelEntry(var/datum/admins/A)
	var/list/dat = ..()
	
	dat += "<br>"
	dat += "<a href='?src=\ref[src];unlockRitual=1'>\[Unlock Ritual\]</A><br>"
	dat += "<br>"

	return dat

/datum/faction/bloodcult/Topic(href, href_list)
	..()

	if(!usr.check_rights(R_ADMIN))
		message_admins("[usr] tried to access bloodcult faction Topic() without permissions.")
		return

	if(href_list["unlockRitual"])
		var/datum/bloodcult_ritual/R = input(usr,"Select a ritual to unlock.", "Unlock", null) as null|anything in locked_rituals
		if(R)
			R.Unlock(TRUE)
			locked_rituals -= R
			

/datum/faction/bloodcult/HandleNewMind(var/datum/mind/M)
	..()
	M.special_role = "Cultist"

/datum/faction/bloodcult/OnPostSetup()
	initialize_rune_words()
	AppendObjective(/datum/objective/bloodcult)
	initialize_rituals()
	for (var/datum/role/R in members)
		var/mob/M = R.antag.current
		to_chat(M, "<span class='sinister'>Our communion must remain small and secretive.</span>")
	UpdateCap()
	if (cultist_cap < 9)
		for (var/datum/role/R in members)
			var/mob/M = R.antag.current
			to_chat(M, "<span class='sinister'>This number might rise up to 9 as more people arrive aboard the station.</span>")
	AnnounceObjectives()
	..()


/datum/faction/bloodcult/proc/GetDepartmentName(var/area/D)
	if(istype(D, /area/science))
		return "Science"
	else if(istype(D, /area/security))
		return "Security"
	else if(istype(D, /area/supply))
		return "Cargo"
	else if(istype(D, /area/medical))
		return "Medical"
	else if(istype(D, /area/engineering))
		return "Engineering"
	else
		return D.name
/datum/faction/bloodcult/proc/IsValidDepartment(var/area/D)
	var/list/valid_areas = list(/area/security, /area/science, /area/supply, /area/engineering, /area/medical)
	if(is_type_in_list(D, valid_areas))
		return TRUE
	return FALSE