/datum/disease/japanesefever
	name = "Japanese Fever"
	max_stages = 5
	spread = "On contact"
	spread_type = CONTACT_GENERAL
	cure = "Flushing the body with the most powerful cleaning solvent."
	cure_id = BLEACH
	agent = "Unknown"
	affected_species = list("Human")
	permeability_mod = 1
	var/revelation_had = 0

/datum/disease/japanesefever/stage_act()
	..()
	switch(stage)
		if(1) //Setup stage.
			to_chat(affected_mob, "<span class='warning'>You feel very, VERY cute!</span>")
			stage = 5
		if(5)
			if(revelation_had != 1 && prob(2))
				if(prob(50))
					to_chat(affected_mob, "<span class='notice'>You feel like meeting some new friends~</span>")
				else
					to_chat(affected_mob, "<span class='notice'>You feel like being the cutest girl in the world! Nyaaaaa~</span>")
			if(!revelation_had && prob(1))
				revelation_had = 1
				to_chat(affected_mob, "<span class='warning'>A sense of dread hits you out of nowhere. Is this really who you are? Who you want to be? An abodimation of a human being, unable to function in regular society?</span>")
				spawn(100)
					to_chat(affected_mob, "<span class='warning'>Clarity hits you like a punch to the gut. You want to rip your hair out, tear apart all these damned clothes and never look at anything pink again. It's disgusting. DISGUSTING.</span>")
					spawn(100)
						to_chat(affected_mob, "<span class='warning'>How - no, why did it end up like this? Only the most miserable creature could invent such brain rotting material like anime. You can almost see his sadonic smirk in your head. You want to kill him.</span>")
						spawn(100)
							to_chat(affected_mob, "<span class='notice'>A gentle flushing sensation spreads throughout your body.</span>")
							spawn(30)
								to_chat(affected_mob, "<span class='notice'>Oh... that feels good...</span>")
								spawn(60)
									to_chat(affected_mob, "<span class='notice'>You can't WAIT to be a cute girl for everybody, nya!.</span>")
									revelation_had = 2
		else
			return
			
/datum/disease/japanesefever/AffectSpeech(var/datum/speech/speech)
	var/message = speech.message
	var/listA = list("cute","adorable","cuddly")
	for(var/word in listA)
		message = replacetext(message, word, "kawaii~")

	var/listB = list("idiot","dumbass","dummy","retard","faggot","nigger","spic","motherfucker","fucker","dumbshit","dipshit","dumbfuck","autist","savant","troglodyte")
	for(var/word in listB)
		message = replacetext(message, word, pick("BAKA","meanie"))
		
	var/listC = list("heya","hi","hello","greetings")
	for(var/word in listC)
		message = replacetext(message, word, "ohaiyo~")

	var/listD = list("tajaran","catbeast")
	for(var/word in listD)
		message = replacetext(message, word, "catfriend")

	var/listE = list("ugh","fuck","sigh","damnit","damn","shit")
	for(var/word in listE)
		message = replacetext(message, word, "uwa~")
		
	var/listF = list("honestly", "to be honest")
	for(var/word in listF)
		message = replacetext(message, word, "desu~")
		
	var/listG = list("captain","cap","cappy","boss","hos","head of security","head of shitcurity","hop","head of personnel","head of personell","head of personnell","rd","research director","cmo","chief medical officer","qm","quartermaster")
	for(var/word in listG)
		message = replacetext(message, word, pick("sempai", "senpai"))
		
	message = replacetext(message, "sorry", "gomen")
	message = replacetext(message, "apologies", "gomenasai")
	message = replacetext(message, "sexual", "l-lewd...")
	message = replacetext(message, "r", "w")
	
	if(prob(50))
		message += " Nya~"
	else
		message += " Ugu~"
	speech.message = message
	
/datum/disease/japanesefever/cure()
	to_chat(affected_mob, "<span class='notice'>Oh thank god, the bleach seems to have worked. You feel absolutely DISGUSTED.</span>")
	..()