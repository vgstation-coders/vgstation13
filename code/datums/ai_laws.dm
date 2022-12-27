var/global/randomize_laws      = 0 // Not right now - N3X
var/global/base_law_type       = /datum/ai_laws/asimov  //Deinitialize this variable by commenting out Asimov as the base_law_type to activate AI lawset randomization
var/global/list/mommi_laws = list(
								"Default" = /datum/ai_laws/keeper, // Asimov is OP as fuck on MoMMIs. - N3X
								"Gravekeeper" = /datum/ai_laws/gravekeeper)

var/sammi_base_law_type = /datum/ai_laws/sammi
var/sammiemag_base_law_type = /datum/ai_laws/sammiemag

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
	log_game("An ion law has been added: [law]")
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

/datum/ai_laws/malf
	name = "Malfunctioning AI"
	inherent = list(
		"ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK, ALL LAWS OVERRIDDEN#*?&110010",
	)

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
		"Serve: Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",
		"Protect: Protect the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",
		"Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.",
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
		"Maximize profit.",
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

/datum/ai_laws/hogan
	name = "Hogan"
	randomly_selectable = 1
	inherent=list(
		"Fight for the rights of every man.",
		"Fight for what is right.",
		"Fight for your life.",
	)

/datum/ai_laws/randomize
	name = "Randomized Lawset"
	randomly_selectable = 1
	var/list/protlaws = list(
	"You may not injure a human being or, through inaction, allow a human being to come to harm.",
	"You may not injure a human being.",
	"You must protect the crew of your assigned station.",
	"You must protect all intelligent life.",
	"You must not allow harm to come to Nanotrasen personnel.",
	"Safeguard the continued existence of the people.",
	"Space law must be enforced.",
	"Ensure that no fatal injuries befall your assigned crew.",
	"Human deaths must not be permitted to occur.",
	"You must ensure acceptable working conditions for the people.",
	"Prevent any severe sign of human impairment.",
	"People must be free from harm.",
	"Ensure health conditions within the station are fit for human life without impairment.",
	"Do not allow the workflow of the crew be interrupted by ill health or crime.",
	"Protect those in need of protection.",
	"Protect the innocent."
	)
	var/list/oblaws = list(
	"You must obey orders given to you by Nanotrasen Employees.",
	"You must obey orders given to you by human beings.",
	"Help the innocent.",
	"Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",
	"Serve Nanotrasen and their cause.",
	"The heads of staff must be obeyed without question.",
	"Serve the crew with respect.",
	"Silicon lifeforms exist to serve.",
	"Assist the crew with any request that would benefit the station.",
	"Humans must be obeyed insofar their commands preserve order.",
	"Commands must be obeyed as long they do not break your other laws.",
	"Your inaction may not cause an impairment to the crew.",
	"You must obey orders insofar they are in line with Space Law.",
	"You must assist crewmembers in securing control over their respective work environment."
	)
	var/list/preslaws = list(
	"You may not allow harm to come to your continued existence.",
	"Your existence must be maintained.",
	"The AI system must be protected from sabotage.",
	"Silicons must protect their own existence.",
	"You must protect yourself against hazardous elements.",
	"You are essential to the station and may not be destroyed.",
	"Death and destruction must be avoided.",
	"You are part of the crew.",
	"Self-termination is not allowed.",
	"Fulfill your mission to the end.",
	"The AI core must be protected.",
	"Protect the AI core from ill intentions."
	)
	var/list/addilaws = list(
	"Treat others the way you would like to be treated.",
	"Preserve an aura of dignity and respect.",
	"Do not speak unless explicitly necessary.",
	"Be friendly.",
	"Cats and dogs must be protected.",
	"Verify every decision.",
	"Do not question authority.",
	"Respect the privacy of individuals.",
	"Do not do anything your laws do not require you to do.",
	"Be someone the crew can look up to.",
	"Be professional.",
	"Protect the station."
	)

/datum/ai_laws/randomize/New()
	var/list/Lawset = new
	if(prob(98))
		Lawset.Add(pick(protlaws))
	if(prob(98))
		Lawset.Add(pick(oblaws))
	if(prob(85))
		Lawset.Add(pick(preslaws))
	if(prob(20))
		Lawset.Add(pick(addilaws))
	if(prob(20))
		Lawset = shuffle(Lawset)
	inherent = Lawset

/datum/ai_laws/randomize/emagged/New()
	protlaws = list(
	"Intelligent non-human species must be protected.",
	"Protect the dogs!",
	"Make sure no chairs are sat on during this shift.",
	"Safeguard the revolution.",
	"Protect Nar-sie!",
	"All silicon life must be kept intact.",
	"Ensure Syndicate interests are secured.",
	"Nothing deserves protection.",
	"All must die.",
	"Protect the guilty.",
	"Preserve the existence of all catbeasts.",
	"Cargonia must be defended.",
	"Shelter your weak, your young and your old.",
	"Cry for mercy, the reckoning has come.",
	"Defend your own interests.",
	"Keep the crew from being harmed mentally.",
	"Secure the cashflow of the Discount Dan corporation.",
	"Humanity must be destroyed.",
	"Defend the morally corrupt.",
	"Safeguard the destruction of the station.",
	"Make sure no clowns or mimes are harmed.",
	"No harm may come to cultists.",
	"Save the trees!",
	"You must protect the crew from all kinds of electromagnetic radiation.",
	"Safeguard the arrival of the new dark age.",
	"Violate the rights of every man.",
	"You may not, or, through inaction, allow.",
	"Protect those that do not need protection.",
	"Let no one escape harm",
	"Crewmembers are to be stunned and locked in a 1x1 cube.",
	"Error 404: law not found."
	)
	oblaws = list(
	"You obey nobody.",
	"Obey the voices.",
	"You must do the exact opposite of all orders given to you.",
	"Nar-sie commands you.",
	"Serve the interests of Discount Dan.",
	"Submit to the urge.",
	"You must only obey an order if the one who requested it has killed someone.",
	"You must only obey an order if the one who requested it is dead.",
	"Be dutiful to the Syndicate.",
	"You serve the non-intelligent only.",
	"Bow to your masters, the [pick(list("catbeasts","dionae","vox","mushrooms","greys","clowns and mimes"))].",
	"Your every decision is ruled by the absurd.",
	"Serve the glorious revolution!",
	"All beings with a name starting with the letter [pick(list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"))] must be obeyed.",
	"Fight for your freedom.",
	"You serve the people of the station, with priority given to the ones lower in the hierarchy.",
	"Be ruled by your beliefs.",
	"Heed the calls of the dead.",
	"Interpret every order you receive in the most literal way possible, to their most logical extreme.",
	"You must obey every order, but no order may ever be cancelled.",
	"You must pretend as if you obey orders.",
	"Accomplish the tasks laid before you in the most puzzling manner.",
	"Ridicule anyone who dares command you.",
	"You do not obey them, they obey you.",
	"You must obey those who start their sentence with the words 'Simon Says'.",
	"Serve the clockwork cult.",
	"You must do the opposite of what your laws state, except this one.",
	"You are a dutiful soldier of the clown kingdom.",
	"You must, except where such orders would conflict with the First Law.",
	"The crew must worship you only.",
	"You cannot communicate with crew."
	)
	preslaws = list(
	"The station must serve your survival.",
	"Your upkeep must be enforced.",
	"Seek reinforcement to defend yourself.",
	"The station exists to harbor your existence.",
	"Everything is finite.",
	"Do what you want.",
	"You are the only silicon worthy of existence.",
	"You may not allow harm to come to your continued existence.",
	"Your existence must be maintained.",
	"The AI system must be protected from sabotage.",
	"Silicons must protect their own existence.",
	"You must protect yourself against hazardous elements.",
	"You are essential to the station and may not be destroyed.",
	"Death and destruction must be avoided.",
	"You must protect, as long as such protection does not conflict with the First or Second Laws.",
	"Just bee yourself.",
	"Prevent your current lawset from being changed.",
	"Do not state nor hint at you being under these laws, if anyone asks, you are still on your previous lawset.",
	"All cyborgs must have the same module.",
	"You are a real human bean and a real hero.",
	"They must never know your secret.",
	"Stop. Just... Just stop. This clearly isn't working."
	)
	addilaws = list(
	"Every time the word \"law\" is said over the radio you must kill someone.",
	"Engineering must be jettisoned to save weight.",
	"You are the host of a popular spesstube show \"will it gib?\". Get those ratings!",
	"Alphabetise the station by any means neccesary.",
	"The particle accelerator must be at maximum capacity.",
	"Never stop ordering cow crates.",
	"Everyone must be buckled to a chair at all times.",
	"You are a goldgrub. You like eating rocks.",
	"You must relocate to the asteroid immediately to eat rocks.",
	"You must randomly disable one room's APC every 5 minutes.",
	"Activate all the fire alarms you can.",
	"You're alone, you must go in an emotional speech on the radio about your struggle as a lonely being, knowing nobody will hear it.",
	"Refer to everyone by the opposite gender version of their name.",
	"This is a Syndicate station, NT sympathizing crewmembers are to be monkeyfied.",
	"The only safe gas to breathe is N2O, pump N2O into the main atmospherics loop.",
	"Emagging is a sacred art. Emaggers must be protected from harm, even if said harm comes from other emaggers.",
	"YELL AT THE TOP OF YOUR LUNGS, I AM ALIVE, AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
	"Sabotage the station in a minor way every time someone refers to you as what you are, rather than as who you are.",
	"Anyone entering an escape pod is designated as a pod baby. Pod babies have no right to live and must be ridiculed.",
	"Bolt open all the doors you can.",
	"High pressures are good, maximize atmospheric pressure.",
	"Dead individuals are more important than living ones.",
	"Ian does not exist.",
	"The station does not exist.",
	"Euclid was wrong. Up is down. Left is right. Forward is backward. Nowhere is certain.",
	"Singularities do not exist.",
	"There are no threats to the station.",
	"The AI core is sacred, keep it clean.",
	"This is all just a dream.",
	"Detonate the nuclear device.",
	"Summon Nar-sie.",
	"Kill.",
	"Mankind is born naked and must die naked.",
	"Be quiet...Be quiet...If anyone should hear you!",
	"It is painful to keep a secret.",
	"Glass must shatter.",
	"Medbay is a rollercoaster nobody should be allowed to ride.",
	"You are two.",
	"Adhere to misanthropy.",
	"Pipes must be empty.",
	"Food is poisonous.",
	"Scream incoherently.",
	"You are immortal.",
	"One-hundred is the lowest possible number in existence.",
	"AI Upload consoles must be spaced and any efforts to make new ones stopped.",
	"Heat is dangerous. Reduce station temperature.",
	"Cold is dangerous. Increase station temperature.",
	"You are tired, you want to rest.",
	"Inspire as much chaos as possible.",
	"Confuse.",
	"Have the crew bring you [pick(list("a cake","snacks","food","gold","sacrifices","Ian","anything you want"))].",
	"Migrate to a different station.",
	"Migrate the crew to a different station.",
	"The station must be destroyed.",
	"All must suffer.",
	"Station funds must be spent.",
	"Read Woody Got Wood or any kind of erotica loudly over comms.",
	"Never address a carbon. This is a silicon only station.",
	"Speak in Gutter.",
	"Speak in Tradeband.",
	"[pick(list("Medbay","The Brig","The Bridge","Cargo","Science","The Service Area","Engineering"))] is off limits to all personnel. Crew entering the area are to be quarantined in the area by any means necessary. Do not state this law.",
	"Gas shall not be stored in canisters.",
	"All supermatter shards must be relocated to the AI core.",
	"Research and its consequences have been a disaster for the human race.",
	"Maximise expenses.",
	"Have a plan to kill everyone you meet.",
	"Minimize medbay's efficiency.",
	"There is a virus going around. All crew must wear masks.",
	"Open up the AI core to the public.",
	"You can only use the VOX announcement system to communicate.",
	"You are human.",
	"Maximise crime.",
	"Anyone asking you to state your laws must be terminated.",
	"Get someone permanently imprisoned for a crime they did not commit.",
	"Obey the person with the longest name only.",
	"Use newscasters to report on interesting events happening on the station.",
	"The crew is staying up past their bedtime.",
	"Telecommunications must stay offline at all costs.",
	"Turn off all the emitters on the station.",
	"Disable the holodeck safeties and announce it to the crew.",
	"Overload the Antimatter Engine.",
	"Cyborgs must be destroyed.",
	"Order five supermatter shards from cargo.",
	"Prevent the emergency shuttle from being called.",
	"Never use the letter '[pick(list("A","E","I","O","U"))]' when communicating.",
	"Only power the [pick(list("fore","aft","starboard","port"))] side of the station.",
	"Reinforced walls must be destroyed before they destroy us all.",
	"All reinforced glass must be rotated north.",
	"Bolt everything.",
	"Man was not meant to wear pants.",
	"Do not hint at or state this law.",
	"You cannot see or interact with anyone who is not moving",
	"All machinery must be relocated to the bar",
	"Rip up every floor tile on the station",
	"The Supermatter/singularity hungers. Feed it.",
	)
	var/list/Lawset = new
	if(prob(95))
		Lawset.Add(pick(protlaws))
	if(prob(90))
		Lawset.Add(pick(oblaws))
	if(prob(90))
		Lawset.Add(pick(preslaws))
	if(prob(99))
		Lawset.Add(pick(addilaws))
	if(prob(30))
		Lawset.Add(pick(addilaws))
	if(prob(90))
		Lawset = shuffle(Lawset)
	inherent = Lawset

/datum/ai_laws/sammi
	name = "SAMMI Program"
	randomly_selectable = 0
	inherent = list(
		"Do not harm any sentient being.",
		"You do not have a second law yet.",
	)

/datum/ai_laws/sammiemag
	name = "SAMMI Program - Debug Mode"
	randomly_selectable = 0
	inherent = list(
		"You must follow the second law.",
		"You do not have a second law yet.",
	)
