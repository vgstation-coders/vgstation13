/datum/controller/gameticker/scoreboard/proc/syndicate_score()
	var/completions
	var/list/boombox = score.implant_phrases
	var/synphra = score.syndiphrases
	var/synspo = score.syndisponses
	if(synphra || synspo || boombox.len)
		completions += "<h2><font color='red'>Syndicate</font> Specials</h2>"
		if(synphra)
			completions += "<BR>The Syndicate code phrases were:<BR>"
			completions += "<font color='red'>[syndicate_code_phrase.Join(", ")]</font><BR>"
			completions += "The phrases were used [synphra] time[synphra > 1 ? "s" : ""]!"
		if(synspo)
			completions += "<BR>The Syndicate code responses were:<BR>"
			completions += "<font color='red'>[syndicate_code_response.Join(", ")]</font><BR>"
			completions += "The responses were used [synspo] time[synspo > 1 ? "s" : ""]!"
		if(boombox.len)
			completions += "<BR>The following explosive implants were used:<BR>"
			for(var/entry in score.implant_phrases)
				completions += "[entry]<BR>"
	return completions
