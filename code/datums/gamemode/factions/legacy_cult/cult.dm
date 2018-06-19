/* Legacy cult (Cult 2.0), by Deity and Urist */

#define CULT_PRELUDE 		0 // First objective
#define CULT_INTERMEDIATE	1 // Second (objective)
#define CULT_SUMMON 		2 // Summon objective
#define CULT_FINALE			3 // Nar-Sie cometh

/datum/faction/cult
	ID = list(CULT)
	var/eldergod
	var/deity_name

/datum/faction/cult/AdminPanelEntry()
	var/list/dat = ..()
	dat += "<a href='?_src_=holder;cult_mindspeak=\ref[src]'>Voice of [deity_name]</a>"
	return dat

/datum/faction/cult/proc/grant_runeword(mob/living/carbon/human/cult_mob, var/word)
	return

// -- Cult of Nar'Sie

// For randomisation & all
var/global/list/engwords = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")
var/global/list/rnwords = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")

/datum/faction/cult/narsie
	name = "Ancient Cult of Nar-Sie"
	ID = list(LEGACY_CULT)
	desc = "A group of shady blood-obsessed individuals whose souls are devoted to Nar-Sie, the Geometer of Blood.\
	From his teachings, they were granted the ability to perform blood magic rituals allowing them to fight and grow their ranks, and given the goal of pushing his agenda.\
	Nar-Sie's ultimate goal is to tear open a breach through reality so he can pull the station into his realm and feast on the crew's blood and souls."
	deity_name = "Geometer of Blood"
	var/list/allwords = list("travel","self","see","hell","blood","join","tech","destroy", "other", "hide")
	var/list/startwords = list("blood","join","self","hell")
	var/list/bloody_floors = list()

	var/datum/objective/current_objective
	var/narsie_condition_cleared =  FALSE

	var/list/cult_words = list()
	var/cult_state = CULT_PRELUDE

	roletype = /datum/role/legacy_cultist

/datum/faction/cult/narsie/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/logos.dmi', "cult-logo")
	var/header = {"<BR><img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Cult of Nar-Sie</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

// Related to word randomisation
/datum/faction/cult/narsie/proc/randomiseWords()
	// For randomisation & all
	var/list/runewords= rnwords
	for (var/word in engwords)
		cult_words[word] = pick(runewords)
		runewords -= cult_words[word]

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
	if (istype(current_objective, /datum/objective/target/assasinate/sacrifice))
		var/datum/objective/target/assasinate/sacrifice/S = current_objective
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


/datum/faction/cult/narsie/HandleNewMind(var/datum/mind/M)
	..()
	if(M.current)
		grant_runeword(M.current)

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
	dat += "<a href='?_src_=holder;check_words=\ref[src]'>Check cult words.</a>"
	return dat

/datum/faction/cult/narsie/OnPostSetup()
	randomiseWords()
	var/number_of_cultists = min(members.len, startwords.len)
	for (var/i = 1 to number_of_cultists)
		grant_runeword(members[i]) // No second arg = random word

#define OBJ_SAC 		"sacrifice"
#define OBJ_SPRAY_BLOOD "spray bood"
#define OBJ_CONVERT 	"convert"

/datum/faction/cult/narsie/proc/getNewObjective() // Placeholder values for chances waiting for the real ones.
	current_objective.force_success = TRUE // Because people can deconvert or clean up floors but you'll still have succeded in that objective
	AnnounceObjectiveCompletion()
	var/datum/objective/next_objective
	switch (cult_state)
		if (CULT_PRELUDE)
			if (members.len <= 4) // We only got 4 members : to the summon phase
				cult_state = CULT_SUMMON
				next_objective = new /datum/objective/summon_narsie
			else
				cult_state = CULT_INTERMEDIATE
				var/new_obj = pick(OBJ_SAC, 200, OBJ_SPRAY_BLOOD, 50, OBJ_CONVERT, 100)
				switch (new_obj)
					if (OBJ_SAC)
						next_objective = new /datum/objective/target/assasinate/sacrifice
					if (OBJ_SPRAY_BLOOD)
						next_objective = new /datum/objective/spray_blood
						var/datum/objective/spray_blood/O = next_objective
						O.cult_fac = src
					if (OBJ_CONVERT)
						next_objective = new /datum/objective/convert_people
						var/datum/objective/convert_people/O = next_objective
						O.cult_fac = src
		
		if (CULT_INTERMEDIATE)
			cult_state = CULT_SUMMON
			next_objective = new /datum/objective/summon_narsie
	
		if (CULT_SUMMON)
			cult_state = CULT_FINALE
			next_objective = new /datum/objective/defile

	AppendObjective(next_objective)

#undef OBJ_SAC
#undef OBJ_SPRAY_BLOOD

/datum/faction/cult/narsie/proc/AnnounceObjectiveCompletion()
	var/text = current_objective.feedbackText()
	if (text)
		for (var/datum/role/R in members) // Cultists
			to_chat(R.antag.current, text)
		for (var/datum/mind/M in members) // Constructs
			to_chat(M.current, text)

// -- Clockwork Cult

/datum/faction/cult/machine
	name = "Cult of Ratvar"
	desc = "When engineers go just too far."
	deity_name = "The Exiled One"

#undef CULT_PRELUDE
#undef CULT_INTERMEDIATE
#undef CULT_SUMMON 
#undef CULT_FINALE	