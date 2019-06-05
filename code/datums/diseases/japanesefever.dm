/datum/disease/japanesefever
	name = "Japanese Fever"
	max_stages = 4
	spread = "On contact"
	spread_type = CONTACT_GENERAL
	cure = "Flushing the body with the most powerful cleaning solvent."
	cure_id = BLEACH
	agent = "Unknown"
	affected_species = list("Human")
	permeability_mod = 1

/datum/disease/japanesefever/stage_act()
	..()
	switch(stage)
		if(1)
			to_chat(affected_mob, "<span class='warning'>You feel very, VERY cute!</span>")
		if(2)
			to_chat(affected_mob, "<span class='warning'>You feel like meeting some new friends~</span>")
		if(3)
			to_chat(affected_mob, "<span class='warning'>You feel like being the cutest girl in the world! Nyaaaaa~</span>")
		if(4)
			to_chat(affected_mob, "<span class='warning'>A sense of dread hits you. Is this really who you are? Who you want to be? An abodimation of a human being, unable to function in regular society?</span>")
			spawn(20)
				to_chat(affected_mob, "<span class='warning'>Clarity hits you like a punch to the gut. You want to rip your hair out, tear apart all these damned clothes and never look at anything pink again. It's disgusting. DISGUSTING.</span>")
				spawn(20)
					to_chat(affected_mob, "<span class='warning'>How - no, why did it end up like this? Only the most miserable creature could invent such brain rotting material like anime. You can almost see his sadonic smirk in your head. You want to kill him.</span>")
					spawn(20)
						to_chat(affected_mob, "<span class='warning'>A gentle flushing sensation spreads throughout your body.</span>")
						spawn(10)
							to_chat(affected_mob, "<span class='warning'>You can't WAIT to be a cute girl for everybody, nya!.</span>")
		else
			return
			
/datum/disease/japanesefever/AffectSpeech(var/datum/speech/speech)
	var/message = speech.message
	var/listA = list("cute","adorable","cuddly")
	for(var/word in listA)
		message = replacetext(message, word, "kawaii~")
	message = replacetext(message, "idiot|dumbass|dummy|retard|faggot|nigger|spic|motherfucker|fucker|dumbshit|dipshit|dumbfuck|autist|savant|troglodyte", pick("BAKA","meanie"))
	message = replacetext(message, "heya|hi|hello|greetings", "hai~")
	message = replacetext(message, "sorry", "gomen")
	message = replacetext(message, "apologies", "gomenasai")
	message = replacetext(message, "sexual", "l-lewd...")
	message = replacetext(message, "tajaran|catbeast", "catfriend")
	message = replacetext(message, "ugh|fuck|sigh|damnit|damn|shit", "uwa~")
	message = replacetext(message, "honestly|to be honest", "desu~")
	message = replacetext(message, "captain|cap|boss|hos|head of security|hop|head of personnel|rd|research director|cmo|chief medical officer|qm|quartermaster", pick("sempai", "senpai"))
	message = replacetext(message, "r", "w")
	
	if(prob(50))
		message += " Nya~"
	else
		message += " Ugu~"
	speech.message = message