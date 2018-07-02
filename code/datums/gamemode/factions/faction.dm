/*
	Faction Datums
		Used for keeping a collection of people under one banner, making for easier
		objective syncing, communication, etc.

	@name: String: Name of the faction
	@desc: String: Description of the faction, their intentions, how they do things, etc. Something for lorewriters to use.
	@restricted_species: list(String): Only species on this list can be part of this faction
		(Vox Raiders, Skellington Pirates, Bewildering Basfellians, etc.)
	@members: List(Reference): Who is a member of this faction
	@max_roles: Integer: How many members this faction is limited to. Set to 0 for no limit
	@objectives: objectives datum: What are the goals of this faction?

	//TODO LATER
	@faction_icon_state: String: The image name of the icon that appears next to people of this faction
	@faction_icon: icon file reference: Where the icon is stored (currently most are stored in mob.dmi)
*/

/datum/faction
	var/name = "unknown faction"
	var/desc = "This faction is bound to do something nefarious"
	var/list/restricted_species = list()
	var/list/members = list()
	var/max_roles = 0
	var/datum/objective_holder/objective_holder

/datum/faction/proc/onPostSetup()
	objective_holder = new
	forgeObjectives()

//Initialization proc, checks if the faction can be made given the current amount of players and/or other possibilites
/datum/faction/proc/can_setup()
	return TRUE

/datum/faction/proc/forgeObjectives()


/*
	appendObjective proc
		Basically adds an objective to the objective holder, and
			TODO LATER
				Tells the faction of this new objective
*/
/datum/faction/proc/appendObjective(var/datum/objective/O)
	ASSERT(O)
	objective_holder.AddObjective(O)

/datum/faction/proc/CheckAllObjectives(var/individuals = FALSE)
	var/dat
	dat += GetObjectivesMenuHeader()
	dat += {"<BR><FONT size = 2><B>Faction Objectives</B></FONT>"}
	dat += objective_holder.GetObjectiveString(check_success = 1)

	if(individuals)
		for(var/datum/role/R in members)
			dat += R.ReturnObjectivesString(check_success = 1)
	return dat

/datum/faction/proc/GetScoreboard()
	var/list/score_results = list()
	/*for(var/datum/role/R in members) 	NO ROLE DATUMS YET
		var/results = R.GetScoreboard()
		if(results)
			score_results.Add(results)*/

	return score_results

/datum/faction/proc/GetObjectivesMenuHeader() //Returns what will show when the factions objective completion is summarized


/datum/faction/syndicate
	name = "The Syndicate"
	desc = "A coalition of companies that actively work against Nanotrasen's intentions. Seen as Freedom fighters by some, Rebels and Malcontents by others."


/datum/faction/syndicate/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/mob/mob.dmi', "synd-logo")
	var/header = {"<BR><img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Syndicate</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

/datum/faction/syndicate/traitor
	name = "Traitors to NT"
	desc = "Operatives of the syndicate, implanted into the crew in one way or another."

/datum/faction/syndicate/nuke_op
	name = "Syndicate nuclear operatives"
	desc = "The culmination of succesful NT traitors, who have managed to steal a nuclear device.\
	Load up, grab the nuke, don't forget where you've parked, find the nuclear auth disk, and give them hell."

/datum/faction/changeling
	name = "Changeling Hivemind"
	desc = "An almost parasitic, shapeshifting entity that assumes the identity of its victims. Commonly used as smart bioweapons by the syndicate,\
	or simply wandering malignant vagrants happening upon a meal of identity that can carry them to further feeding grounds."

/datum/faction/changeling/GetObjectivesMenuHeader()
	var/icon/logo_left = icon('icons/mob/mob.dmi', "changelogoa")
	var/icon/logo_right = icon('icons/mob/mob.dmi', "changelogob")
	var/header = {"<BR><img src='data:image/png;base64,[icon2base64(logo_left)]'> <FONT size = 2><B>Changelings Hivemind</B></FONT> <img src='data:image/png;base64,[icon2base64(logo_right)]'>"}
	return header

/datum/faction/wizard
	name = "Wizard Federation"
	desc = "A conglomeration of magically adept individuals, with no obvious heirachy, instead acting as equal individuals in the pursuit of magic-oriented endeavours.\
	Their motivations for attacking seemingly peaceful enclaves or operations are as yet unknown, but they do so without respite or remorse.\
	This has led to them being identified as enemies of humanity, and should be treated as such."

/datum/faction/wizard/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/mob/mob.dmi', "wizard-logo")
	var/header = {"<BR><img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Wizard Federation</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

/datum/faction/cult
	name = "Cult of Nar-Sie"
	desc = "A group of shady blood-obsessed individuals whose souls are devoted to Nar-Sie, the Geometer of Blood.\
	From his teachings, they were granted the ability to perform blood magic rituals allowing them to fight and grow their ranks, and given the goal of pushing his agenda.\
	Nar-Sie's ultimate goal is to tear open a breach through reality so he can pull the station into his realm and feast on the crew's blood and souls."

/datum/faction/cult/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/mob/mob.dmi', "cult-logo")
	var/header = {"<BR><img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Cult of Nar-Sie</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

/datum/faction/vampire
	name = "Space Vampires"
	desc = "Beings cursed to wander the galaxy to satiate their lust for blood, \
	usually pointed towards NT station by the syndicate in exchange for causing chaos and completing objectives for them.\
	Vampirism is still not fully understood, but those afflicted can quickly become a force to be reckoned with if allowed to indulge."

/datum/faction/vampire/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/mob/mob.dmi', "vampire-logo")
	var/header = {"<BR><img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Vampiric wanderers</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

/datum/faction/revolution
	name = "Revolutionaries"
	desc = "Viva!"

/datum/faction/revolution/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/mob/mob.dmi', "rev-logo")
	var/header = {"<BR><img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Revolutionaries</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header