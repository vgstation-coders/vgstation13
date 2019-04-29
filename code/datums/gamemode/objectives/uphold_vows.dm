/datum/objective/uphold_vow
	name = "Uphold Vow"
	explanation_text = "Keep your vow."
	var/datum/mind/target
	var/vow_text
	var/approved = TRUE

/datum/objective/uphold_vow/PostAppend()
	explanation_text = "Keep your vow, \"[vow_text]\" to [target]."
	return TRUE

/datum/objective/uphold_vow/IsFulfilled()
	return approved

/datum/objective/uphold_vow/proc/PollMind()
	if(!target)
		return TRUE //Default yes!
	var/approval
	approval = alert(target.current,"[owner.name] vowed to you: \"[vow_text]\". Was it upheld? No answer defaults as yes.","Vow","Yes","No")
	switch(approval)
		if("Yes")
			to_chat(target.current,"<span class='info'>Your vow feedback was noted.</span>")
			approved = TRUE
		if("No")
			to_chat(target.current,"<span class='info'>Your vow feedback was noted.</span>")
			approved = FALSE
		else
			to_chat(target.current,"<span class='warning'>You took too long to decide on your answer!</span>")
			approved = TRUE