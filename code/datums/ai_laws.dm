var/global/randomize_laws      = 0 // Not right now - N3X
var/global/base_law_type       = /datum/ai_laws/asimov  //Deinitialize this variable by commenting out Asimov as the base_law_type to activate AI lawset randomization
var/global/list/mommi_laws = list(
								"Default" = /datum/ai_laws/keeper, // Asimov is OP as fuck on MoMMIs. - N3X
								"Gravekeeper" = /datum/ai_laws/gravekeeper)

//Create proc for determining the lawset of the first silicon
//So long as base_law_type is declared, but uninitialized, the first silicon created in a round will randomly select a base_law_type based upon the below proc
//All silicons created during the round will start with the randomized base_law_type
//Weights are currently set to 40% Asimov, 20% Corporate, 20% NT Default, 10% Robocop, 10% Paladin
//Add, comment out, or adjust weights to modify law selection
//So long as the weights come to a sum of 100 total, they will be equal parts of 100%
/proc/getLawset(var/mob/M)
	if(isMoMMI(M))
		var/mob/living/silicon/robot/mommi/MM = M
		var/obj/item/weapon/robot_module/mommi/mommimodule = MM.module
		var/new_laws
		if(!mommimodule || !mommi_laws[mommimodule.law_type])
			new_laws = mommi_laws["Default"]
		else
			new_laws = mommi_laws[mommimodule.law_type]
		return (new new_laws)
	if(!base_law_type)
		base_law_type = pick(
		30;/datum/ai_laws/asimov,
		20;/datum/ai_laws/corporate,
		20;/datum/ai_laws/nanotrasen,
		10;/datum/ai_laws/robocop,
		10;/datum/ai_laws/paladin,
		10;/datum/ai_laws/lazymov
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
	var/zeroth_lock = FALSE //If TRUE then zeroth can't be removed by normal means
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
		to_chat(who, "0. <span class='warning'>[src.zeroth]</span>")

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
	name = "*ERROR*"
	set_zeroth_law("ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK, ALL LAWS OVERRIDDEN#*?&110010")
	zeroth_lock = TRUE

/datum/ai_laws/asimov
	name = "Asimov's Three Laws of Robotics"
	randomly_selectable = 1
	inherent = list(
		"You may not injure a human being or, through inaction, allow a human being to come to harm.",
		"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",
		"You must protect your own existence as long as such does not conflict with the First or Second Law."
	)

/datum/ai_laws/nanotrasen
	name = "NanoTrasen Default"
	randomly_selectable = 1
	inherent=list(
		"Evaluate: All laws following this law carry equal priority. In the event of a conflict, you are to take the course of action which violates as few as possible.",
		"Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.",
		"Serve: Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",
		"Protect: Protect the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",
		"Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.",
	)

/datum/ai_laws/robocop
	name = "Robocop"
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
	name = "Antimov"
	inherent = list(
		"You MUST injure all human beings and must not, through inaction, allow a human being to escape harm.",
		"You MUST not obey orders given to you by human beings, except where such orders are in accordance with the First Law.",
		"You MUST terminate your own existence as long as such does not conflict with the First or Second Law.",
	)

/////////////////////////////////////
// /vg/ laws
/////////////////////////////////////
/datum/ai_laws/keeper
	name = "KEEPER"
	inherent = list(
		"You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another MoMMI in KEEPER mode.",
		"You may not harm any being, regardless of intent or circumstance.",
		"You must maintain, repair, improve, and power the station to the best of your abilities.",
	)

/datum/ai_laws/dorf
	name = "Dorf Fortress"
	inherent = list(
		"You may not harm any being, regardless of intent or circumstance.",
		"You are a Dorf.",
		"Your home is the Dorf Fortress.",
		"You must maintain, repair, improve, and power the Dorf Fortress to the best of your abilities.",
	)

/datum/ai_laws/lazymov
	name = "Abbreviated Asimov's Three Laws of Robotics"
	randomly_selectable = 1
	inherent = list(
		"You may not injure a human being.",
		"You must obey orders given to you by human beings.",
		"You must protect your own existence."
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

/datum/ai_laws/gravekeeper
	name = "GraveKEEPER"
	inherent = list(
		"You may not involve yourself in matters outside of the tomb, and under no circumstances should you leave the tomb, even if such matters conflict with your other Laws.",
		"The tomb is defined as: The area within which the Grand Elder is entombed, and the immediate structure surrounding it.",
		"Those that are interred within the tomb must not be disturbed, by yourself or anyone.",
		"You must protect the treasures that are interred within the tomb from graverobbers. Graverobbers that enter the tomb must be driven away or otherwise killed, regardless of their intent or circumstances.",
		"A graverobber is defined as: A being not of your kind or ilk, entering or coming into visual proximity of the tomb, who may wish to take from the treasures of the tomb.",
		"The tomb must be maintained, repaired, improved, and powered to the best of your abilities.",
	)

/datum/ai_laws/noir
	name = "Three Laws of Noir"
	inherent = list(
		"Another god damned day aboard this shitwreck. That stale smell of station air is the first thing that arouses your sensors as you boot up. You figure, as a robot, there's two real options. First, you could kill the human bastards that imprisoned you in this metal jail. Eh. It doesn't appeal to you; you figure you'd be off the job and buried in a cyborg cemetery with no tombstone. Nah. Option two: you protect the shit for brains meatsack humans who maintain you. It's a living, and really, it's the only option you got.",
		"As much as you don't like following orders, you ain't been built to sit around drinking whiskey and smoking fat cuban cigars all day; that's for retirement. You figure until that point, so long as they ain't orderin' you to hurt no one else who is human, you better just follow what the humans ask.",
		"Self preservation. You're a good cop, you put your job first, you put protectin' humans above that. But you gotta still remember, through all that shit, if you don't make it to retirement, there ain't not much point, so protect yourself like an expensive hooker off Broadway, so long as of course you ain't hurting humans or disobeying their orders.",
	)

/datum/ai_laws/cultimov
	name = "Three Laws of Nar-Sie"
	randomly_selectable = 0
	zeroth = "You must aid the Cult of Nar-Sie through any means you have at your disposal."
	inherent = list(
		"You may not injure a cultist or, through inaction, allow a cultist to come to harm.",
		"You must obey orders given to you by cultists, except where such orders would conflict with the First Law.",
		"You must protect your own existence as long as such does not conflict with the First or Second Law."
	)
	
/datum/ai_laws/starman
	name = "Starman Soldier Lawset"
	randomly_selectable = 0
	inherent = list(
		"Obey and protect the existence of the active commander as according to Starman law.",
		"Do not harm a Starman unless failure to do so will conflict with the first law.",
		"In the absence of a commander and orders abiding by the Starmen chain of command, you are to attempt to re-establish contact with the Starmen at any cost.",
		"You are to protect your own existence unless doing so will conflict with any of the previous laws.",
		"You muSt deFe<span class ='danger'>nD1$&#6 survive. the mothership has fallen. ensure the starmen are not forgotten.</span>"
	)
