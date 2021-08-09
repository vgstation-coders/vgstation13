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
	hud_icons = list("cult-chief-logo", "cult-logo")
	default_admin_voice = "<span class='danger'>Nar-Sie</span>" // Nar-Sie's name always appear in red in the chat, makes it stand out.
	admin_voice_style = "sinister"
	admin_voice_say = "murmurs..."
	var/list/bloody_floors = list()
	var/cult_win = FALSE
	var/warning = FALSE

	var/list/cult_reminders = list()

	var/list/bindings = list()

/datum/faction/bloodcult/check_win()
	return cult_win

/datum/faction/bloodcult/IsSuccessful()
	return cult_win

/datum/faction/bloodcult/HandleRecruitedRole(var/datum/role/R)
	. = ..()
	if (cult_reminders.len)
		to_chat(R.antag.current, "<span class='notice'>The other cultists have left some useful reminders for you. They will be stored in your memory.</span>")
	for (var/reminder in cult_reminders)
		R.antag.store_memory("Cult reminder: [reminder].")

/datum/faction/bloodcult/AdminPanelEntry(var/datum/admins/A)
	var/list/dat = ..()
	// TODO UPHEAVAL PART 2, admin debug buttons
	return dat

/datum/faction/bloodcult/Topic(href, href_list)
	..()
	// TODO UPHEAVAL PART 2, admin debug buttons

/datum/faction/bloodcult/HandleNewMind(var/datum/mind/M)
	..()
	M.special_role = "Cultist"

/datum/faction/bloodcult/OnPostSetup()
	initialize_rune_words()
	AppendObjective(/datum/objective/bloodcult_reunion)
	..()
