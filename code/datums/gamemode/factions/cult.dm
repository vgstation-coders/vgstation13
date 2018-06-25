/datum/faction/cult
	ID = CULT
	var/eldergod
	var/deity_name

/datum/faction/cult/narsie
	name = "Cult of Nar-Sie"
	ID = list(CULT, CULT_NARSIE)
	desc = "A group of shady blood-obsessed individuals whose souls are devoted to Nar-Sie, the Geometer of Blood.\
	From his teachings, they were granted the ability to perform blood magic rituals allowing them to fight and grow their ranks, and given the goal of pushing his agenda.\
	Nar-Sie's ultimate goal is to tear open a breach through reality so he can pull the station into his realm and feast on the crew's blood and souls."
	deity_name = "Geometer of Blood"
	var/list/allwords = list("travel","self","see","hell","blood","join","tech","destroy", "other", "hide")
	var/list/startwords = list("blood","join","self","hell")
	var/list/bloody_floors = list()
	var/narsie_condition_cleared

/datum/faction/cult/narsie/GetObjectivesMenuHeader()
	var/icon/logo = icon('icons/logos.dmi', "cult-logo")
	var/header = {"<BR><img src='data:image/png;base64,[icon2base64(logo)]'> <FONT size = 2><B>Cult of Nar-Sie</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]'>"}
	return header

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
	if(!cultwords["travel"])
		runerandom()
	if (!word)
		word=pick(allwords)
	var/wordexp = "[cultwords[word]] is [word]..."
	to_chat(cult_mob, "<span class='sinister'>You remember one thing from the dark teachings of your master... [wordexp]</span>")
	cult_mob.mind.store_memory("<B>You remember that</B> [wordexp]", 0, 0)

/datum/faction/cult/AdminPanelEntry()
	var/list/dat = ..()
	dat += "<a href='?_src_=holder;cult_mindspeak=\ref[src]'>Voice of [deity_name]</a>"
	return dat

/datum/faction/cult/machine
	name = "Cult of Ratvar"
	desc = "When engineers go just too far."
	deity_name = "The Exiled One"
