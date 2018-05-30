/* Legacy cult (Cult 2.0), by Deity and Urist */

/datum/faction/cult
	ID = list(CULT)
	var/eldergod
	var/deity_name

/datum/faction/cult/AdminPanelEntry()
	var/list/dat = ..()
	dat += "<a href='?_src_=holder;cult_mindspeak=\ref[src]'>Voice of [deity_name]</a>"
	return dat

// -- Cult of Nar'Sie

// For randomisation & all
var/global/list/engwords = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")
var/global/list/rnwords = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")

/datum/faction/cult/narsie
	name = "Cult of Nar-Sie"
	ID = list(LEGACY_CULT)
	desc = "A group of shady blood-obsessed individuals whose souls are devoted to Nar-Sie, the Geometer of Blood.\
	From his teachings, they were granted the ability to perform blood magic rituals allowing them to fight and grow their ranks, and given the goal of pushing his agenda.\
	Nar-Sie's ultimate goal is to tear open a breach through reality so he can pull the station into his realm and feast on the crew's blood and souls."
	deity_name = "Geometer of Blood"
	var/list/allwords = list("travel","self","see","hell","blood","join","tech","destroy", "other", "hide")
	var/list/startwords = list("blood","join","self","hell")
	var/list/bloody_floors = list()
	var/narsie_condition_cleared

	var/list/cult_words = list()

	roletype = /datum/role/legacy_cultist

/datum/faction/cult/narsie/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/logos.dmi', "cult-logo")
	var/header = {"<BR><img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Cult of Nar-Sie</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

/datum/faction/cult/narsie/proc/randomiseWords()
	// For randomisation & all
	var/global/list/engwords = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")
	var/global/list/rnwords = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")

/datum/faction/cult/proc/is_sacrifice_target(var/datum/mind/M)
	for(var/datum/objective/target/sacrifice/S in GetObjectives())
		if(S.target == M)
			return TRUE
	return FALSE

/datum/faction/cult/HandleNewMind(var/datum/mind/M)
	..()
	if(M.current)
		grant_runeword(M.current)

/datum/faction/cult/proc/grant_runeword(mob/living/carbon/human/cult_mob, var/word)
	return

/datum/faction/cult/narsie/grant_runeword(mob/living/carbon/human/cult_mob, var/word)
	if (!word)
		if(startwords.len > 0)
			word=pick(startwords)
			startwords -= word
	if(!cult_words["travel"])
		runerandom()
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

// -- Clockwork Cult

/datum/faction/cult/machine
	name = "Cult of Ratvar"
	desc = "When engineers go just too far."
	deity_name = "The Exiled One"
