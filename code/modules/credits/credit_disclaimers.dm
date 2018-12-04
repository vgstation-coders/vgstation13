/datum/credits/proc/draft_disclaimers()
	var/inline_images = ""
	for(var/filename in flist("icons/credits/"))
		var/icon/I = icon("icons/credits/[filename]")
		inline_images += "<span style='display: inline-block, vertical-align: middle, margin: 0px 20px;'><img style='display: inline-block,' src='data:image/png;base64,[icon2base64(I)]'></span>"

	disclaimers += "Filmed on Location at [station_name()]."
	disclaimers += "Filmed with BYOND&#169; cameras and lenses. Outer space footage provided by NASA."
	disclaimers += "Additional special visual effects by LUMMOX&#174; JR. Motion Picture Productions."
	disclaimers += "Unofficially Sponsored by The United States Navy."
	disclaimers += "All rights reserved."
	disclaimers += "<br>"
	disclaimers += pick("All stunts were performed by underpaid and expendable interns. Do NOT try at home.", "[director] do not endorse behaviour depicted. Attempt at your own risk.")
	if(score["deadpets"] == 0)
		disclaimers += "No animals were harmed in the making of this film.[(score["clownabuse"] > 50) ? " However, many clowns were." : ""]"
	else if(score["clownabuse"] == 0)
		disclaimers += "No clowns were harmed in the making of this film."
	else if(score["clownabuse"] > 50)
		disclaimers += "All clowns were harmed in the making of this film."
	disclaimers += "<br>"
	disclaimers += inline_images
	disclaimers += "<br>"
	disclaimers += "This motion picture is (not) protected under the copyright laws of the United States and all countries throughout the universe. Country of first publication: United States of America. Any unauthorized exhibition, distribution, or copying of this picture or any part thereof (including soundtrack) is an infringement of the relevant copyright and will subject the infringer to civil liability and criminal prosecution."
	disclaimers += "The story, all names, characters, and incidents portrayed in this production are fictitious. No identification with actual persons (living or deceased), places, buildings, and products is intended or should be inferred."
	disclaimers += "No person or entity associated with this film received payment or anything of value, or entered into any agreement, in connection with the depiction of tobacco products."
