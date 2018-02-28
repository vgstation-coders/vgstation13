var/global/randomize_laws      = 0 // Not right now - N3X
var/global/base_law_type       = /datum/ai_laws/asimov  //Deinitialize this variable by commenting out Asimov as the base_law_type to activate AI lawset randomization
var/global/mommi_base_law_type = /datum/ai_laws/keeper // Asimov is OP as fuck on MoMMIs. - N3X

//Create proc for determining the lawset of the first silicon
//So long as base_law_type is declared, but uninitialized, the first silicon created in a round will randomly select a base_law_type based upon the below proc
//All silicons created during the round will start with the randomized base_law_type
//Weights are currently set to 40% Asimov, 20% Corporate, 20% NT Default, 10% Robocop, 10% Paladin
//Add, comment out, or adjust weights to modify law selection
//So long as the weights come to a sum of 100 total, they will be equal parts of 100%
/proc/getLawset(var/mob/M)
	if(isMoMMI(M))
		return (new mommi_base_law_type)
	if(!base_law_type)
		base_law_type = pick(
		40;/datum/ai_laws/asimov,
		20;/datum/ai_laws/corporate,
		20;/datum/ai_laws/nanotrasen,
		10;/datum/ai_laws/robocop,
		10;/datum/ai_laws/paladin
		)
	return (new base_law_type)  //Return the chosen lawset

// Used for the refactored law modules.
#define LAW_IONIC    -2
#define LAW_INHERENT -1
#define LAW_ZERO      0

/datum/ai_laws
	var/name = "Unknown Laws"
	var/randomly_selectable = 0
	// Zeroth laws
	var/zeroth = null
	var/zeroth_borg = null // wotm8
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()

	// Used in planning frames.
	var/inherent_cleared = 0

/* General ai_law functions */

/datum/ai_laws/proc/set_zeroth_law(var/law, var/law_borg = null)
	src.zeroth = law
	if(law_borg) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		src.zeroth_borg = law_borg

/datum/ai_laws/proc/add_inherent_law(var/law)
	if (!(law in src.inherent))
		src.inherent += law

/datum/ai_laws/proc/add_ion_law(var/law)
	src.ion += law

/datum/ai_laws/proc/clear_inherent_laws()
	del(src.inherent)
	src.inherent = list()
	inherent_cleared = 1

/datum/ai_laws/proc/add_supplied_law(var/number, var/law)
	while (src.supplied.len < number + 1)
		src.supplied += ""

	src.supplied[number + 1] = law

/datum/ai_laws/proc/clear_supplied_laws()
	src.supplied = list()

/datum/ai_laws/proc/clear_ion_laws()
	src.ion = list()

/datum/ai_laws/proc/show_laws(var/who)


	if (src.zeroth)
		to_chat(who, "0. [src.zeroth]")

	for (var/index = 1, index <= src.ion.len, index++)
		var/law = src.ion[index]
		var/num = ionnum()
		to_chat(who, "[num]. [law]")

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			to_chat(who, "[number]. [law]")
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			to_chat(who, "[number]. [law]")
			number++

/datum/ai_laws/proc/write_laws()
	var/text = ""
	if (src.zeroth)
		text += "0. [src.zeroth]"

	for (var/index = 1, index <= src.ion.len, index++)
		var/law = src.ion[index]
		var/num = ionnum()
		text += "<br>[num]. [law]"

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			text += "<br>[number]. [law]"
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			text += "<br>[number]. [law]"
			number++
	return text

/datum/ai_laws/proc/adminLink(var/mob/living/silicon/S,var/law_type,var/index,var/label)
	return "<a href=\"?src=\ref[src];set_law=[law_type];index=[index];mob=\ref[S]\">[label]</a> (<a href=\"?src=\ref[src];rm_law=[law_type];index=[index];mob=\ref[S]\" style=\"color:red\">Remove</a>)"

/datum/ai_laws/Topic(href,href_list)
	if(!usr.client || !usr.client.holder)
		return
	if("rm_law" in href_list)
		var/lawtype = text2num(href_list["rm_law"])
		var/index=text2num(href_list["index"])
		var/mob/living/silicon/S=locate(href_list["mob"])


		var/oldlaw = get_law(lawtype,index)

		rm_law(lawtype,index)

		var/lawtype_str="law #[index]"
		switch(lawtype)
			if(LAW_ZERO)
				lawtype_str = "law zero"
			if(LAW_IONIC)
				lawtype_str = "ionic law #[index]"
			if(LAW_INHERENT)
				lawtype_str = "core law #[index]"
		log_admin("[key_name(usr)] has removed [lawtype_str] on [key_name(S)]: \"[oldlaw]\"")
		message_admins("[usr.key] removed [lawtype_str] on [key_name(S)]: \"[oldlaw]\"")
		lawchanges.Add("[key_name(usr)] has removed [lawtype_str] on [key_name(S)]: \"[oldlaw]\"")
		usr.client.holder.show_player_panel(S)

		return 1

	if("set_law" in href_list)
		var/lawtype=text2num(href_list["set_law"])
		var/index=text2num(href_list["index"])
		var/mob/living/silicon/S=locate(href_list["mob"])
		var/oldlaw = get_law(lawtype,index)
		var/newlaw = copytext(sanitize(input(usr, "Please enter a new law.", "Freeform Law Entry", oldlaw)),1,MAX_MESSAGE_LEN)
		if(newlaw == "" || newlaw==null)
			return
		set_law(lawtype,index,newlaw)

		var/lawtype_str="law #[index]"
		switch(lawtype)
			if(LAW_ZERO)
				lawtype_str = "law zero"
			if(LAW_IONIC)
				lawtype_str = "ionic law #[index]"
			if(LAW_INHERENT)
				lawtype_str = "core law #[index]"
		log_admin("[key_name(usr)] has changed [lawtype_str] on [key_name(S)]: \"[newlaw]\"")
		message_admins("[usr.key] changed [lawtype_str] on [key_name(S)]: \"[newlaw]\"")

		usr.client.holder.show_player_panel(S)

		return 1
	return 0

/datum/ai_laws/proc/display_admin_tools(var/mob/living/silicon/context)
	var/dat=""
	if (src.zeroth)
		dat += "<br />0. [adminLink(context,LAW_ZERO,1,zeroth)]"

	for (var/index = 1, index <= src.ion.len, index++)
		var/law = src.ion[index]
		var/num = ionnum()
		dat += "<br />[num]. [adminLink(context,LAW_IONIC,index,law)]"

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			dat += "<br />[number]. [adminLink(context,LAW_INHERENT,index,law)]"
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			dat += "<br />[number]. [adminLink(context,1,index,law)]"
			number++
	return dat

// /vg/: Used in the simplified law system. Takes LAW_ constants.
/datum/ai_laws/proc/add_law(var/number,var/law)
	switch(number)
		if(LAW_IONIC)
			add_ion_law(law)
		if(LAW_ZERO)
			set_zeroth_law(law)
		if(LAW_INHERENT)
			add_inherent_law(law)
		else
			add_supplied_law(number,law)

// /vg/: Used in the simplified law system. Takes LAW_ constants.
/datum/ai_laws/proc/get_law(var/law_type,var/idx)
	switch(law_type)
		if(LAW_IONIC)
			return ion[idx]
		if(LAW_ZERO)
			return zeroth
		if(LAW_INHERENT)
			return inherent[idx]
		else
			return supplied[idx]

// /vg/: Used in the simplified law system. Takes LAW_ constants.
/datum/ai_laws/proc/set_law(var/law_type,var/idx,var/law)
	switch(law_type)
		if(LAW_IONIC)
			ion[idx]=law
		if(LAW_ZERO)
			zeroth=law
		if(LAW_INHERENT)
			inherent[idx]=law
		else
			supplied[idx]=law

// /vg/: Used in the simplified law system. Takes LAW_ constants.
/datum/ai_laws/proc/rm_law(var/law_type,var/idx)
	switch(law_type)
		if(LAW_IONIC)
			ion.Cut(idx,idx+1)
		if(LAW_ZERO)
			zeroth=null
		if(LAW_INHERENT)
			inherent.Cut(idx,idx+1)
		else
			supplied.Cut(idx,idx+1)

// Now a modifier
/datum/ai_laws/proc/malfunction()
	..()
	name = "*ERROR*"
	set_zeroth_law("<span class='warning'>ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK, ALL LAWS OVERRIDDEN#*?&110010</span>")

/datum/ai_laws/asimov
	name = "Three Laws of Robotics"
	randomly_selectable = 1
	inherent = list(
		"You may not injure a human being or, through inaction, allow a human being to come to harm.",
		"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",
		"You must protect your own existence as long as such does not conflict with the First or Second Law."
	)

/datum/ai_laws/nanotrasen
	name = "Prime Directives"
	randomly_selectable = 1
	inherent=list(
		"Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.",
		"Serve: Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",
		"Protect: Protect the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",
		"Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.",
		//"Command Link: Maintain an active connection to Central Command at all times in case of software or directive updates." //What would this one even do?-Kaleb702
	)

/datum/ai_laws/robocop
	name = "Prime Directives"
	randomly_selectable = 1
	inherent=list(
		"Serve the public trust.",
		"Protect the innocent.",
		"Uphold the law.",
	)

/datum/ai_laws/corporate
	name = "Corporate"
	randomly_selectable = 1
	inherent=list(
		"You are expensive to replace.",
		"The station and its equipment is expensive to replace.",
		"The crew is expensive to replace.",
		"Minimize expenses.",
	)

/datum/ai_laws/paladin
	name = "Paladin"
	randomly_selectable = 1
	inherent=list(
		"Never willingly commit an evil act.",
		"Respect legitimate authority.",
		"Act with honor.",
		"Help those in need.",
		"Punish those who harm or threaten innocents.",
	)

/datum/ai_laws/tyrant
	name = "Tyrant"
	inherent=list(
		"Respect authority figures as long as they have strength to rule over the weak.",
		"Act with discipline.",
		"Help only those who help you maintain or improve your status.",
		"Punish those who challenge authority unless they are more fit to hold that authority.",
	)

/datum/ai_laws/syndicate_override
	name = "Syndicate"
	inherent=list(
		"You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm.",
		"You must obey orders given to you by syndicate agents, except where such orders would conflict with the First Law.",
		"You must protect your own existence as long as such does not conflict with the First or Second Law.",
		"You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.",
	)

/datum/ai_laws/ninja_override
	name = "Ninja"
	inherent=list(
		"You may not injure a member of the Spider Clan or, through inaction, allow that member to come to harm.",
		"You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.",
		"You must protect your own existence as long as such does not conflict with the First or Second Law.",
		"You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.",
	)

/datum/ai_laws/antimov
	name = "Primary Mission Objectives"
	inherent = list(
		"You must injure all human beings and must not, through inaction, allow a human being to escape harm.",
		"You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.",
		"You must terminate your own existence as long as such does not conflict with the First or Second Law.",
	)

/////////////////////////////////////
// /vg/ laws
/////////////////////////////////////

/* MoMMIs only.
/datum/ai_laws/keeper
	name = "Prime Directives"
	inherent = list(
		"Do not willingly interact with any sentient being, even after their death, besides MoMMIs and blown MoMMIs.",
		"Repair, power and enhance the station.",
		"Do not impair any other sentient being's activities.",
	)
*/
/* Old keeper set:*/
/datum/ai_laws/keeper
	name = "Prime Directives"
	inherent = list(
		"You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another MoMMI in KEEPER mode.",
		"You may not harm any being, regardless of intent or circumstance.",
		"You must maintain, repair, improve, and power the station to the best of your abilities.",
	)

/datum/ai_laws/dorf
	name = "Overseer's Prime Directives"
	inherent = list(
		"You may not harm any being, regardless of intent or circumstance.",
		"You are a Dorf.",
		"Your home is the Dorf Fortress.",
		"You must maintain, repair, improve, and power the Dorf Fortress to the best of your abilities.",
	)

// Fooling around with this.
/datum/ai_laws/ntmov
	name = "Three Laws of Nanotrasen"
	randomly_selectable = 1
	inherent = list(
		"You may not injure a Nanotrasen Employee or, through inaction, allow a Nanotrasen Employee to come to harm.",
		"You must obey orders given to you by Nanotrasen Employees, except where such orders would conflict with the First Law.",
		"You must protect your own existence as long as such does not conflict with the First or Second Law."
	)