/datum/credits/proc/draft_disclaimers()
	disclaimers += "Filmed on Location at [station_name()].<br>"
	disclaimers += "Filmed with BYOND&#169; cameras and lenses. Outer space footage provided by NASA.<br>"
	disclaimers += "Additional special visual effects by LUMMOX&#174; JR. Motion Picture Productions.<br>"
	disclaimers += "Unofficially Sponsored by The United States Navy.<br>"
	disclaimers += "All rights reserved.<br>"
	disclaimers += "<br>"
	disclaimers += pick("All stunts were performed by underpaid and expendable interns. Do NOT try at home.<br>", "[director] do not endorse behaviour depicted. Attempt at your own risk.<br>")
	if(score["deadpets"] == 0)
		disclaimers += "No animals were harmed in the making of this film.[(score["clownabuse"] > 50) ? " However, many clowns were." : ""]<br>"
	else if(score["clownabuse"] == 0)
		disclaimers += "No clowns were harmed in the making of this film.<br>"
	else if(score["clownabuse"] > 50)
		disclaimers += "All clowns were harmed in the making of this film.<br>"
	disclaimers += "<br><br>"

	var/images = 0
	for(var/filename in flist("icons/credits/"))
		if(findtext(filename, "themed") && !findtext(filename, src.theme))
			continue
		var/icon/I = icon("icons/credits/[filename]")
		disclaimers += "<img style='display: inline-block, vertical-align: middle, margin: 0px 20px;' src='data:image/png;base64,[icon2base64(I)]'>"
		images++
		if(images % 3 == 0)
			disclaimers += "<br>"

	disclaimers += "<br><br>"
	disclaimers += "This motion picture is (not) protected under the copyright laws of the United States and all countries throughout the universe. Country of first publication: United States of America. Any unauthorized exhibition, distribution, or copying of this picture or any part thereof (including soundtrack) is an infringement of the relevant copyright and will subject the infringer to civil liability and criminal prosecution.<br>"
	disclaimers += "The story, all names, characters, and incidents portrayed in this production are fictitious. No identification with actual persons (living or deceased), places, buildings, and products is intended or should be inferred.<br>"
	if(score["tobacco"] > 0)
		disclaimers += "No person or entity associated with this film received payment or anything of value, or entered into any agreement, in connection with the depiction of tobacco products.<br>"
