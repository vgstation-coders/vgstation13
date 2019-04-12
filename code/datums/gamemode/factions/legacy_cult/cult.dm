/* Legacy cult (Cult 2.0), by Deity and Urist */

/datum/faction/cult
	ID = list(CULT)
	var/eldergod
	var/deity_name

/datum/faction/cult/AdminPanelEntry()
	var/list/dat = ..()
	dat += "<br/><a href='?src=\ref[src];cult_mindspeak_global=\ref[src]'>Voice of [deity_name]</a>"
	return dat

/datum/faction/cult/proc/grant_runeword(mob/living/carbon/human/cult_mob, var/word)
	return

// -- Cult of Nar'Sie

// For randomisation & all
var/global/list/engwords = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")
var/global/list/rnwords = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")

/datum/faction/cult/narsie
	name = "Ancient Cult of Nar-Sie"
	ID = LEGACY_CULT
	desc = "A group of shady blood-obsessed individuals whose souls are devoted to Nar-Sie, the Geometer of Blood.\
	From his teachings, they were granted the ability to perform blood magic rituals allowing them to fight and grow their ranks, and given the goal of pushing his agenda.\
	Nar-Sie's ultimate goal is to tear open a breach through reality so he can pull the station into his realm and feast on the crew's blood and souls."
	deity_name = "Nar-Sie"
	var/list/allwords = list("travel","self","see","hell","blood","join","tech","destroy", "other", "hide")
	var/list/startwords = list("blood","join","self","hell")
	var/list/bloody_floors = list()
	hud_icons = list("cult-logo")

	var/datum/objective/current_objective
	var/list/objs = list()
	var/harvested = 0

	var/list/cult_words = list()
	var/cult_state = CULT_PRELUDE

	var/datum/rune_controller/rune_controller

	initroletype = /datum/role/legacy_cultist
	roletype = /datum/role/legacy_cultist
	required_pref = CULTIST

/datum/faction/cult/narsie/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/logos.dmi', "cult-logo")
	var/header = {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position:relative; top:10px;'> <FONT size = 2><B>Cult of Nar-Sie</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top:10px;'><BR>"}
	return header

/datum/faction/cult/narsie/OnPostSetup()
	rune_controller = new()
	forgeObjectives()
	for(var/datum/role/R in members)
		R.OnPostSetup(equip = TRUE)

// Related to word randomisation
/datum/faction/cult/narsie/proc/randomiseWords()
	// For randomisation & all
	var/list/runewords= rnwords
	for (var/word in engwords)
		cult_words[word] = pick(runewords)
		runewords -= cult_words[word]

/datum/faction/cult/narsie/HandleNewMind(var/datum/mind/M)
	if (!..())
		return
	if (has_enough_adepts())
		getNewObjective()

/datum/faction/cult/narsie/HandleRecruitedMind(var/datum/mind/M, var/override = FALSE)
	if (!..())
		return
	if (has_enough_adepts())
		getNewObjective()

// Urist-runes naming & recognition procs.
// Those procs are a mess

/datum/faction/cult/narsie/proc/get_uristrune_name(var/word1, var/word2, var/word3)
	if((word1 == cult_words["travel"] && word2 == cult_words["self"]))
		return "Travel Self"
	else if((word1 == cult_words["join"] && word2 == cult_words["blood"] && word3 == cult_words["self"]))
		return "Convert"
	else if((word1 == cult_words["hell"] && word2 == cult_words["join"] && word3 == cult_words["self"]))
		return "Tear Reality"
	else if((word1 == cult_words["see"] && word2 == cult_words["blood"] && word3 == cult_words["hell"]))
		return "Summon Tome"
	else if((word1 == cult_words["hell"] && word2 == cult_words["destroy"] && word3 == cult_words["other"]))
		return "Armor"
	else if((word1 == cult_words["destroy"] && word2 == cult_words["see"] && word3 == cult_words["technology"]))
		return "EMP"
	else if((word1 == cult_words["travel"] && word2 == cult_words["blood"] && word3 == cult_words["self"]))
		return "Drain"
	else if((word1 == cult_words["see"] && word2 == cult_words["hell"] && word3 == cult_words["join"]))
		return "See Invisible"
	else if((word1 == cult_words["blood"] && word2 == cult_words["join"] && word3 == cult_words["hell"]))
		return "Raise Dead"
	else if((word1 == cult_words["hide"] && word2 == cult_words["see"] && word3 == cult_words["blood"]))
		return "Hide Runes"
	else if((word1 == cult_words["hell"] && word2 == cult_words["travel"] && word3 == cult_words["self"]))
		return "Astral Journey"
	else if((word1 == cult_words["hell"] && word2 == cult_words["technology"] && word3 == cult_words["join"]))
		return "Imbue Talisman"
	else if((word1 == cult_words["hell"] && word2 == cult_words["blood"] && word3 == cult_words["join"]))
		return "Sacrifice"
	else if((word1 == cult_words["blood"] && word2 == cult_words["see"] && word3 == cult_words["hide"]))
		return "Reveal Runes"
	else if((word1 == cult_words["destroy"] && word2 == cult_words["travel"] && word3 == cult_words["self"]))
		return "Wall"
	else if((word1 == cult_words["travel"] && word2 == cult_words["technology"] && word3 == cult_words["other"]))
		return "Free Cultist"
	else if((word1 == cult_words["join"] && word2 == cult_words["other"] && word3 == cult_words["self"]))
		return "Summon Cultist"
	else if((word1 == cult_words["hide"] && word2 == cult_words["other"] && word3 == cult_words["see"]))
		return "Deafen"
	else if((word1 == cult_words["destroy"] && word2 == cult_words["see"] && word3 == cult_words["other"]))
		return "Blind"
	else if((word1 == cult_words["destroy"] && word2 == cult_words["see"] && word3 == cult_words["blood"]))
		return "Blood Boil"
	else if((word1 == cult_words["self"] && word2 == cult_words["other"] && word3 == cult_words["technology"]))
		return "Communicate"
	else if((word1 == cult_words["travel"] && word2 == cult_words["other"]))
		return "Travel Other"
	else if((word1 == cult_words["join"] && word2 == cult_words["hide"] && word3 == cult_words["technology"]))
		return "Stun"
	else
		return null

/datum/faction/cult/narsie/proc/is_sacrifice_target(var/datum/mind/M)
	if (istype(current_objective, /datum/objective/target/assassinate/sacrifice))
		var/datum/objective/target/assassinate/sacrifice/S = current_objective
		if(S.target == M)
			return TRUE
	return FALSE

/datum/faction/cult/narsie/proc/has_enough_bloody_floors()
	if (istype(current_objective, /datum/objective/spray_blood))
		var/datum/objective/spray_blood/blood_jectie = current_objective
		return blood_jectie.IsFulfilled()
	return FALSE

/datum/faction/cult/narsie/proc/has_enough_adepts()
	if (istype(current_objective, /datum/objective/convert_people))
		var/datum/objective/convert_people/conv = current_objective
		return conv.IsFulfilled()
	return FALSE

/datum/faction/cult/narsie/grant_runeword(mob/living/carbon/human/cult_mob, var/word)
	if (!word)
		if(startwords.len > 0)
			word=pick(startwords)
			startwords -= word
	if(!cult_words["travel"]) // This checks weather or not we randomised words.
		randomiseWords()
	if (!word)
		word=pick(allwords)
	var/wordexp = "[cult_words[word]] is [word]..."
	to_chat(cult_mob, "<span class='sinister'>You remember one thing from the dark teachings of your master... [wordexp]</span>")
	cult_mob.mind.store_memory("<B>You remember that</B> [wordexp]", 0, 0)

/datum/faction/cult/narsie/AdminPanelEntry()
	var/list/dat = ..()
	dat += "<br/><a href='?src=\ref[src];check_words=\ref[src]'>Check cult words.</a>"
	if (current_objective)
		dat += "<br/>Our current objective is : [current_objective.name] ([current_objective.explanation_text])"
	else
		dat += "<br/>No current objective."
	return dat

#define OBJ_SAC 		"sacrifice"
#define OBJ_SPRAY_BLOOD "spray bood"
#define OBJ_CONVERT 	"convert"
#define OBJ_SUMMON		"summon"

// -- Objectives --

/datum/faction/cult/narsie/forgeObjectives()
	var/datum/objective/next_objective
	var/new_obj = pick_objective()
	switch (new_obj)
		if (OBJ_SAC)
			next_objective = new /datum/objective/target/assassinate/sacrifice
		if (OBJ_SPRAY_BLOOD)
			next_objective = new /datum/objective/spray_blood
		if (OBJ_CONVERT)
			next_objective = new /datum/objective/convert_people
		if (OBJ_SUMMON)
			next_objective = new /datum/objective/summon_narsie
			cult_state = CULT_SUMMON

	objs += new_obj
	current_objective = next_objective
	next_objective.faction = src
	AppendObjective(next_objective)


/datum/faction/cult/narsie/proc/pick_objective()
	var/list/possible_objectives = list()

	if (!(OBJ_SPRAY_BLOOD in objs))
		possible_objectives |= OBJ_SPRAY_BLOOD

	if(!(OBJ_SAC in objs))
		var/datum/objective/target/assassinate/sacrifice/S = new
		S.faction = src
		if (S.get_targets())
			possible_objectives |= OBJ_SAC

	if(!(OBJ_CONVERT in objs))
		var/datum/objective/convert_people/C = new
		C.faction = src
		if (C.get_number())
			possible_objectives |= OBJ_CONVERT

	if(!possible_objectives.len)//No more possible objectives, time to summon Nar-Sie
		message_admins("No suitable objectives left! Nar-Sie objective unlocked.")
		return OBJ_SUMMON
	else
		return pick(possible_objectives)

/datum/faction/cult/narsie/proc/getNewObjective(var/debug = FALSE) // Placeholder values for chances waiting for the real ones.
	if (!debug) // Debug = we're getting a new objective because something bad happened, we want to erase it from the scoreboard.
		current_objective.force_success = TRUE // Because people can deconvert or clean up floors but you'll still have succeded in that objective
		AnnounceObjectiveCompletion()
	var/datum/objective/next_objective
	switch (cult_state)
		if (CULT_PRELUDE)
			if (members.len <= 4) // We only got 4 members : to the summon phase
				cult_state = CULT_SUMMON
				next_objective = new /datum/objective/summon_narsie
				message_admins("Only 4 cultists left : Nar-Sie objective unlocked.")
			else
				cult_state = CULT_INTERMEDIATE
				var/new_obj = pick_objective()
				switch (new_obj)
					if (OBJ_SAC)
						next_objective = new /datum/objective/target/assassinate/sacrifice
					if (OBJ_SPRAY_BLOOD)
						next_objective = new /datum/objective/spray_blood
					if (OBJ_CONVERT)
						next_objective = new /datum/objective/convert_people
					if (OBJ_SUMMON)
						next_objective = new /datum/objective/summon_narsie

		if (CULT_INTERMEDIATE)
			cult_state = CULT_SUMMON
			next_objective = new /datum/objective/summon_narsie

		if (CULT_SUMMON)
			cult_state = CULT_FINALE
			var/obj_type = pick(/datum/objective/massacre, /datum/objective/hijack/cult, /datum/objective/harvest)
			next_objective = new obj_type

	current_objective = next_objective
	next_objective.faction = src
	AppendObjective(next_objective)
	for (var/datum/role/R in members)
		R.AnnounceObjectives()

#undef OBJ_SAC
#undef OBJ_SPRAY_BLOOD
#undef OBJ_CONVERT

/datum/faction/cult/narsie/proc/AnnounceObjectiveCompletion()
	var/text = current_objective.feedbackText()
	if (text)
		for (var/datum/role/R in members)
			if (R.antag.current)
				to_chat(R.antag.current, text)

/datum/faction/cult/narsie/handleNewObjective(var/datum/objective/O)
	if (current_objective)
		message_admins("Trying to add objective [O] to [src], which already has an objective. Remove the objective first.")
		return FALSE
	. = ..()
	if (!.)
		return FALSE
	current_objective = O
	for (var/datum/role/R in members)
		R.AnnounceObjectives()

/datum/faction/cult/narsie/handleRemovedObjective(var/datum/objective/O)
	ASSERT(O)
	if (!current_objective)
		message_admins("Trying to remove objective [O] to [src], but the faction has no current objective.")
		return FALSE
	if (!(O in objective_holder.objectives) || current_objective != O) // We're trying to remove an objective that's already been completed, or something that never was in our objectives
		return FALSE
	current_objective = null
	objective_holder.objectives.Remove(O)
	for (var/datum/role/R in members)
		to_chat(R.antag.current, "<span class='sinister'>Nar-Sie's plans have changed. We do not need to do the current objective : [O.name]. A new objective should be annouced soon.")
	qdel(O)

/datum/faction/cult/narsie/handleForcedCompletedObjective(var/datum/objective/O)
	ASSERT(O)
	if (!current_objective)
		message_admins("Trying to force completion of objective [O] to [src], but the faction has no current objective.")
		return FALSE
	if (!(O in objective_holder.objectives) || current_objective != O) // Same as previous
		message_admins("Trying to force completion of objective [O] to [src], but this isn't the faction's current objective.")
		return FALSE
	getNewObjective()

// -- Topic/hrefs --
/datum/faction/cult/narsie/Topic(href, href_list)
	if (href_list["cult_mindspeak_global"])
		if (!usr.client.holder)
			return FALSE
		var/message = input("What message shall we send?",
                    "Voice of [deity_name]",
                    "")
		for (var/datum/role/R in members)
			var/mob/M = R.antag.current
			if (M)
				to_chat(M, "<span class='danger'>[deity_name]</span> murmurs... <span class='sinister'>[message]</span>")

	if (href_list["cult_mindspeak"])
		if (!usr.client.holder)
			return FALSE
		var/message = input("What message shall we send?",
                    "Voice of [deity_name]",
                    "")
		var/datum/role/R = locate(href_list["cult_mindspeak"])
		var/mob/M = R.antag.current
		if (M)
			to_chat(M, "<span class='danger'>[deity_name]</span> murmurs... <span class='sinister'>[message]</span>")

	if (href_list["check_words"])
		if (!usr.client.holder)
			return FALSE
		for (var/word in cult_words)
			to_chat(usr, "[cult_words[word]] is [word].")

// -- Process : reroll the sac target

/datum/faction/cult/narsie/process()
	if (!istype(current_objective, /datum/objective/target/assassinate/sacrifice))
		return
	var/datum/objective/target/assassinate/sacrifice/S = current_objective

	if (!S.target)
		message_admins("No longer a valid target for the sacrifice: rerolling.")
		reroll_sac(S)
		return

	if (S.target.current.z != map.zMainStation && S.target.current.z != map.zAsteroid) // Our target is in deep space, and we can't really have that
		message_admins("Sacrifice target is in deep space, or dead : rerolling.")
		reroll_sac(S)
		return


/datum/faction/cult/narsie/proc/reroll_sac(var/datum/objective/target/assassinate/sacrifice/S)
	log_admin("LEGACY CULT: rerolling sacrifice.")
	var/list/possible_targets = S.get_targets()
	S.target = pick(possible_targets)
	if (!S.target) // No targets still ? Time to reroll the objective.
		log_admin("LEGACY CULT: qdeling the objective...")
		objective_holder.objectives -= current_objective
		qdel(current_objective)
		current_objective = null
		getNewObjective(debug = TRUE) // This objective never happened.
		return
	for (var/datum/role/R in members)
		to_chat(R.antag.current, "<span class='sinister'>Our target escaped! We have a new objective...</span>")
		R.AnnounceObjectives()

// -- Clockwork Cult

/datum/faction/cult/machine
	name = "Cult of Ratvar"
	desc = "When engineers go just too far."
	deity_name = "The Exiled One"