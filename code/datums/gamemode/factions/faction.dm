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

/datum/faction/New()
	..()
	objective_holder = new
	objective_holder.faction = src
	if (hud_icons.len)
		factions_with_hud_icons.Add(src)

	for (var/datum/faction/F in factions_with_hud_icons)
		update_hud_icons()

/datum/faction/proc/OnPostSetup()
	forgeObjectives()
	for(var/datum/role/R in members)
		R.OnPostSetup()

//Initialization proc, checks if the faction can be made given the current amount of players and/or other possibilites
/datum/faction/proc/can_setup()
	return TRUE

//For when you want your faction to have specific objectives (Vampire, suck blood. Cult, sacrifice the head of personnel's dog, etc.)
/datum/faction/proc/forgeObjectives()

/datum/faction/proc/HandleNewMind(var/datum/mind/M) //Used on faction creation
	for(var/datum/role/R in members)
		if(R.antag == M)
			WARNING("Mind was already a role in this faction")
			return 0
	if(M.GetRole(initial_role))
		warning("Mind already had a role of [initial_role]!")
		return 0
	var/datum/role/newRole = new initroletype(src,null, initial_role)
	if(!newRole.AssignToRole(M))
		newRole.Drop()
		return 0
	members.Add(newRole)
	return 1

/datum/faction/proc/HandleRecruitedMind(var/datum/mind/M)
	for(var/datum/role/R in members)
		if(R.antag == M)
			WARNING("Mind was already a role in this faction")
			return 0
	if(M.GetRole(late_role))
		warning("Mind already had a role of [late_role]!")
		return 0
	var/datum/role/R = new roletype(fac = src, new_id = late_role)
	if(!R.AssignToRole(M))
		R.Drop()
		return 0
	members.Add(R)
	return 1

/datum/faction/proc/HandleRecruitedRole(var/datum/role/R)
	ticker.mode.orphaned_roles.Remove(R)
	members.Add(R)
	R.faction = src
	update_faction_icons()

/datum/faction/proc/HandleRemovedRole(var/datum/role/R)
	R.faction.members.Remove(R)
	R.faction = null
	ticker.mode.orphaned_roles.Add(R)
	if(leader == R)
		leader = null
	update_hud_removed(R)

/datum/faction/proc/AppendObjective(var/datum/objective/O)
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
	var/icon/logo = icon('icons/logos.dmi', logo_state)
	var/header = {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'> <FONT size = 2><B>[name]</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'>"}
	return header


/datum/faction/proc/DeclareAll()
	for(var/datum/role/R in members)
		R.Declare()

/datum/faction/proc/AdminPanelEntry(var/datum/admins/A)
	var/dat = "<br>"
	dat += GetObjectivesMenuHeader()
	dat += "<br><b>Faction objectives</b><br>"
	dat += objective_holder.GetObjectiveString(0,1,A)
	dat += "<br> - <b>Members</b> - <br>"
	if(!members.len)
		dat += "<i>Unpopulated</i>"
	else
		for(var/datum/role/R in members)
			dat += R.AdminPanelEntry()
	return dat

/datum/faction/proc/process()
	for (var/datum/role/R in members)
		R.process()

/datum/faction/proc/check_win()
	return

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
		if(R.antag && R.antag.current && R.antag.current.client)
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
	for(var/datum/role/R in members)
		if(R.antag && R.antag.current && R.antag.current.client)
			for(var/image/I in R.antag.current.client.images)
				if(I.icon_state in hud_icons && ((I.loc == Removed_R.antag.current) || (I.loc == Removed_R.antag.current.loc)))
					R.antag.current.client.images -= I

	if(Removed_R.antag && Removed_R.antag.current && Removed_R.antag.current.client)
		for(var/image/I in Removed_R.antag.current.client.images)
			if(I.icon_state in hud_icons)
				Removed_R.antag.current.client.images -= I


/////////////////////////////THESE FACTIONS SHOULD GET MOVED TO THEIR OWN FILES ONCE THEY'RE GETTING ELABORATED/////////////////////////

//________________________________________________

/datum/faction/changeling
	name = "Changeling Hivemind"
	ID = HIVEMIND
	initial_role = CHANGELING
	late_role = CHANGELING
	required_pref = ROLE_CHANGELING
	desc = "An almost parasitic, shapeshifting entity that assumes the identity of its victims. Commonly used as smart bioweapons by the syndicate,\
	or simply wandering malignant vagrants happening upon a meal of identity that can carry them to further feeding grounds."
	roletype = /datum/role/changeling
	logo_state = "change-logoa"

/datum/faction/changeling/GetObjectivesMenuHeader()
	var/icon/logo_left = icon('icons/logos.dmi', "change-logoa")
	var/icon/logo_right = icon('icons/logos.dmi', "change-logob")
	var/header = {"<img src='data:image/png;base64,[icon2base64(logo_left)]' style='position: relative; top: 10;'> <FONT size = 2><B>[name]</B></FONT> <img src='data:image/png;base64,[icon2base64(logo_right)]' style='position: relative; top: 10;'>"}
	return header

//________________________________________________

/datum/faction/wizard
	name = "Wizard Federation"
	ID = WIZFEDERATION
	initial_role = WIZARD
	late_role = WIZARD
	required_pref = ROLE_WIZARD
	desc = "A conglomeration of magically adept individuals, with no obvious heirachy, instead acting as equal individuals in the pursuit of magic-oriented endeavours.\
	Their motivations for attacking seemingly peaceful enclaves or operations are as yet unknown, but they do so without respite or remorse.\
	This has led to them being identified as enemies of humanity, and should be treated as such."
	initroletype = /datum/role/wizard
	roletype = /datum/role/wizard
	logo_state = "wizard-logo"
	hud_icons = list("wizard-logo","apprentice-logo")

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


/datum/faction/wizard/ragin
	accept_latejoiners = TRUE
	var/max_wizards

/datum/faction/wizard/ragin/check_win()
	if(members.len == max_roles)
		return 1
//________________________________________________

#define ADD_REVOLUTIONARY_FAIL_IS_COMMAND -1
#define ADD_REVOLUTIONARY_FAIL_IS_JOBBANNED -2
#define ADD_REVOLUTIONARY_FAIL_IS_IMPLANTED -3
#define ADD_REVOLUTIONARY_FAIL_IS_REV -4

/datum/faction/revolution
	name = "Revolutionaries"
	ID = REVOLUTION
	required_pref = ROLE_REV
	initial_role = HEADREV
	late_role = REV
	desc = "Viva!"
	logo_state = "rev-logo"
	initroletype = /datum/role/revolutionary/leader
	roletype = /datum/role/revolutionary

/datum/faction/revolution/HandleRecruitedMind(var/datum/mind/M)
	if(M.assigned_role in command_positions)
		return ADD_REVOLUTIONARY_FAIL_IS_COMMAND

	var/mob/living/carbon/human/H = M.current

	if(jobban_isbanned(H, "revolutionary"))
		return ADD_REVOLUTIONARY_FAIL_IS_JOBBANNED

	for(var/obj/item/weapon/implant/loyalty/L in H) // check loyalty implant in the contents
		if(L.imp_in == H) // a check if it's actually implanted
			return ADD_REVOLUTIONARY_FAIL_IS_IMPLANTED

	if(isrev(H)) //HOW DO YOU FUCK UP THIS BADLY.
		return ADD_REVOLUTIONARY_FAIL_IS_REV

	return ..()

/datum/faction/revolution/forgeObjectives()
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/target/assassinate/A = new(auto_target = FALSE)
		if(A.set_target(head_mind))
			AppendObjective(A)

/datum/faction/strike_team
	name = "Custom Strike Team"//obviously this name is a placeholder getting replaced by the admin setting up the squad
	required_pref = ROLE_STRIKE
	ID = CUSTOMSQUAD
	logo_state = "nano-logo"

//________________________________________________

/datum/faction/strike_team/ert
	name = "Emergency Response Team"
	ID = ERT
	logo_state = "ert-logo"

//________________________________________________

/datum/faction/strike_team/deathsquad
	name = "Nanotrasen Deathsquad"
	ID = DEATHSQUAD
	logo_state = "death-logo"

//________________________________________________

/datum/faction/strike_team/syndiesquad
	name = "Syndicate Deep-Strike squad"
	ID = SYNDIESQUAD
	logo_state = "elite-logo"
