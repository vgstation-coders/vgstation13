/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:

			mind.transfer_to(new_mob)

	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

/datum/mind
	var/key
	var/name				//replaces mob/var/original_name
	var/mob/living/current
	var/mob/living/original	//TODO: remove.not used in any meaningful way ~Carn. First I'll need to tweak the way silicon-mobs handle minds.
	var/active = 0

	var/memory

	var/assigned_role
	var/special_role
	var/list/wizard_spells // So we can track our wizmen spells that we learned from the book of magicks.

	var/role_alt_title

	var/datum/job/assigned_job

	var/list/kills=list()
	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/datum/faction/faction 			//associated faction
	var/datum/changeling/changeling		//changeling holder
	var/datum/vampire/vampire			//vampire holder

	var/rev_cooldown = 0

	// the world.time since the mob has been brigged, or -1 if not at all
	var/brigged_since = -1

		//put this here for easier tracking ingame
	var/datum/money_account/initial_account
	var/list/uplink_items_bought = list()
	var/total_TC = 0
	var/spent_TC = 0

	//fix scrying raging mages issue.
	var/isScrying = 0
	var/list/heard_before = list()

	var/nospells = 0 //Can't cast spells.


/datum/mind/New(var/key)
	src.key = key

/datum/mind/proc/transfer_to(mob/living/new_character)
	if(!istype(new_character))
		error("transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob. Please inform Carn")

	if(current)					//remove ourself from our old body's mind variable
		if(changeling)
			current.remove_changeling_powers()
			current.verbs -= /datum/changeling/proc/EvolutionMenu
		if(vampire)
			current.remove_vampire_powers()
		current.mind = null
	if(new_character.mind)		//remove any mind currently in our new body's mind variable
		new_character.mind.current = null

	nanomanager.user_transferred(current, new_character)

	current = new_character		//link ourself to our new body
	new_character.mind = src	//and link our new body to ourself

	if(changeling)
		new_character.make_changeling()
	if(vampire)
		new_character.make_vampire()
	if(active)
		new_character.key = key		//now transfer the key to link the client to our new body

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<BR>"

/datum/mind/proc/show_memory(mob/recipient)
	var/output = "<B>[current.real_name]'s Memory</B><HR>"
	output += memory

	if(objectives.len>0)
		output += "<HR><B>Objectives:</B>"

		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++

	recipient << browse(output,"window=memory")

/datum/mind/proc/edit_memory()
	if(!ticker || !ticker.mode)
		alert("Not before round-start!", "Alert")
		return

	var/out = "<B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"

	out += {"Mind currently owned by key: [key] [active?"(synced)":"(not synced)"]<br>
		Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>
		Factions and special roles:<br>"}
	var/list/sections = list(
		"revolution",
		"cult",
		"wizard",
		"apprentice",
		"changeling",
		"vampire",
		"nuclear",
		"traitor", // "traitorchan",
		"monkey",
		"malfunction",
		"resteam",
		"dsquad",
	)
	var/text = ""

	if (istype(current, /mob/living/carbon/human) || istype(current, /mob/living/carbon/monkey) || istype(current, /mob/living/simple_animal/construct))
		/** REVOLUTION ***/
		text = "revolution"
		if (ticker.mode.config_tag=="revolution")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (assigned_role in command_positions)
			text += "<b>HEAD</b>|officer|employee|headrev|rev"
		else if (assigned_role in list("Security Officer", "Detective", "Warden"))
			text += "head|<b>OFFICER</b>|employee|headre|rev"
		else if (src in ticker.mode.head_revolutionaries)

			text = {"head|officer|<a href='?src=\ref[src];revolution=clear'>employee</a>|<b>HEADREV</b>|<a href='?src=\ref[src];revolution=rev'>rev</a>
				<br>Flash: <a href='?src=\ref[src];revolution=flash'>give</a>"}
			var/list/L = current.get_contents()
			var/obj/item/device/flash/flash = locate() in L
			if (flash)
				if(!flash.broken)
					text += "|<a href='?src=\ref[src];revolution=takeflash'>take</a>."
				else
					text += "|<a href='?src=\ref[src];revolution=takeflash'>take</a>|<a href='?src=\ref[src];revolution=repairflash'>repair</a>."
			else
				text += "."

			text += " <a href='?src=\ref[src];revolution=reequip'>Reequip</a> (gives traitor uplink)."
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];revolution=autoobjectives'>Set to kill all heads</a>."
		else if (src in ticker.mode.revolutionaries)
			text += "head|officer|<a href='?src=\ref[src];revolution=clear'>employee</a>|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|<b>REV</b>"
		else
			text += "head|officer|<b>EMPLOYEE</b>|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|<a href='?src=\ref[src];revolution=rev'>rev</a>"
		sections["revolution"] = text

		/** CULT ***/
		text = "cult"
		if (ticker.mode.config_tag=="cult")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (assigned_role in command_positions)
			text += "<b>HEAD</b>|officer|employee|cultist"
		else if (assigned_role in list("Security Officer", "Detective", "Warden"))
			text += "head|<b>OFFICER</b>|employee|cultist"
		else if (src in ticker.mode.cult)

			text += {"head|officer|<a href='?src=\ref[src];cult=clear'>employee</a>|<b>CULTIST</b>
				<br>Give <a href='?src=\ref[src];cult=tome'>tome</a>|<a href='?src=\ref[src];cult=amulet'>amulet</a>."}
/*
			if (objectives.len==0)
				text += "<br>Objectives are empty! Set to sacrifice and <a href='?src=\ref[src];cult=escape'>escape</a> or <a href='?src=\ref[src];cult=summon'>summon</a>."
*/
		else
			text += "head|officer|<b>EMPLOYEE</b>|<a href='?src=\ref[src];cult=cultist'>cultist</a>"
		sections["cult"] = text

		/** WIZARD ***/
		text = "wizard"
		if (ticker.mode.config_tag=="wizard")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.wizards)

			text += {"<b>YES</b>|<a href='?src=\ref[src];wizard=clear'>no</a>
				<br><a href='?src=\ref[src];wizard=lair'>To lair</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];wizard=dressup'>dress up</a>, <a href='?src=\ref[src];wizard=name'>let choose name</a>."}
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];wizard=autoobjectives'>Randomize!</a>"
		else
			text += "<a href='?src=\ref[src];wizard=wizard'>yes</a>|<b>NO</b>"
		sections["wizard"] = text

		/** WIZARD'S APPRENTICES ***/
		text = "apprentice"
		if (ticker.mode.config_tag=="wizard")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.apprentices)

			text += {"<b>YES</b>|<a href='?src=\ref[src];apprentice=clear'>no</a>
				<br><a href='?src=\ref[src];apprentice=lair'>To lair</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];apprentice=dressup'>dress up</a>, <a href='?src=\ref[src];apprentice=name'>let choose name</a>."}
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];apprentice=autoobjectives'>Randomize!</a>"
		else
			text += "<a href='?src=\ref[src];apprentice=apprentice'>yes</a>|<b>NO</b>"
		sections["apprentice"] = text

		/** CHANGELING ***/
		text = "changeling"
		if (ticker.mode.config_tag=="changeling" || ticker.mode.config_tag=="traitorchan")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.changelings)
			text += "<b>YES</b>|<a href='?src=\ref[src];changeling=clear'>no</a>"
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];changeling=autoobjectives'>Randomize!</a>"
			if( changeling && changeling.absorbed_dna.len && (current.real_name != changeling.absorbed_dna[1]) )
				text += "<br><a href='?src=\ref[src];changeling=initialdna'>Transform to initial appearance.</a>"
			if( changeling )
				text += "<br><a href='?src=\ref[src];changeling=set_genomes'>[changeling.geneticpoints] genomes</a>"
		else
			text += "<a href='?src=\ref[src];changeling=changeling'>yes</a>|<b>NO</b>"
//			var/datum/game_mode/changeling/changeling = ticker.mode
//			if (istype(changeling) && changeling.changelingdeath)
//				text += "<br>All the changelings are dead! Restart in [round((changeling.TIME_TO_GET_REVIVED-(world.time-changeling.changelingdeathtime))/10)] seconds."
		sections["changeling"] = text

		/** VAMPIRE ***/
		text = "vampire"
		if (ticker.mode.config_tag=="vampire")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.vampires)
			text += "<b>YES</b>|<a href='?src=\ref[src];vampire=clear'>no</a>"
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];vampire=autoobjectives'>Randomize!</a>"
		else
			text += "<a href='?src=\ref[src];vampire=vampire'>yes</a>|<b>NO</b>"
		/** ENTHRALLED ***/
		text += "<br><i><b>enthralled</b></i>: "
		if(src in ticker.mode.enthralled)
			text += "<b><font color='#FF0000'>YES</font></b>|no"
		else
			text += "yes|<b>NO</b>"
		sections["vampire"] = text

		/** NUCLEAR ***/
		text = "nuclear"
		if (ticker.mode.config_tag=="nuclear")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.syndicates)

			text += {"<b>OPERATIVE</b>|<a href='?src=\ref[src];nuclear=clear'>nanotrasen</a>
				<br><a href='?src=\ref[src];nuclear=lair'>To shuttle</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];nuclear=dressup'>dress up</a>."}
			var/code
			for (var/obj/machinery/nuclearbomb/bombue in machines)
				if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
					code = bombue.r_code
					break
			if (code)
				text += " Code is [code]. <a href='?src=\ref[src];nuclear=tellcode'>tell the code.</a>"
		else
			text += "<a href='?src=\ref[src];nuclear=nuclear'>operative</a>|<b>NANOTRASEN</b>"
		sections["nuclear"] = text

	/** TRAITOR ***/
	text = "traitor"
	if (ticker.mode.config_tag=="traitor" || ticker.mode.config_tag=="traitorchan")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if (src in ticker.mode.traitors)
		text += "<b>TRAITOR</b>|<a href='?src=\ref[src];traitor=clear'>loyal</a>"
		if (objectives.len==0)
			text += "<br>Objectives are empty! <a href='?src=\ref[src];traitor=autoobjectives'>Randomize</a>!"
	else
		text += "<a href='?src=\ref[src];traitor=traitor'>traitor</a>|<b>LOYAL</b>"
	sections["traitor"] = text

	/** MONKEY ***/
	if (istype(current, /mob/living/carbon))
		text = "monkey"
		if (ticker.mode.config_tag=="monkey")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (istype(current, /mob/living/carbon/human))
			text += "<a href='?src=\ref[src];monkey=healthy'>healthy</a>|<a href='?src=\ref[src];monkey=infected'>infected</a>|<b>HUMAN</b>|other"
		else if (istype(current, /mob/living/carbon/monkey))
			var/found = 0
			for(var/datum/disease/D in current.viruses)
				if(istype(D, /datum/disease/jungle_fever))
					found = 1

			if(found)
				text += "<a href='?src=\ref[src];monkey=healthy'>healthy</a>|<b>INFECTED</b>|<a href='?src=\ref[src];monkey=human'>human</a>|other"
			else
				text += "<b>HEALTHY</b>|<a href='?src=\ref[src];monkey=infected'>infected</a>|<a href='?src=\ref[src];monkey=human'>human</a>|other"

		else
			text += "healthy|infected|human|<b>OTHER</b>"
		sections["monkey"] = text


	/** SILICON ***/

	if (istype(current, /mob/living/silicon))
		text = "silicon"
		if (ticker.mode.config_tag=="malfunction")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (istype(current, /mob/living/silicon/ai))
			if (src in ticker.mode.malf_ai)
				text += "<b>MALF</b>|<a href='?src=\ref[src];silicon=unmalf'>not malf</a>"
			else
				text += "<a href='?src=\ref[src];silicon=malf'>malf</a>|<b>NOT MALF</b>"
		var/mob/living/silicon/robot/robot = current
		if (istype(robot) && robot.emagged)
			text += "<br>Cyborg: Is emagged! <a href='?src=\ref[src];silicon=unemag'>Unemag!</a><br>0th law: [robot.laws.zeroth]"
		var/mob/living/silicon/ai/ai = current
		if (istype(ai) && ai.connected_robots.len)
			var/n_e_robots = 0
			for (var/mob/living/silicon/robot/R in ai.connected_robots)
				if (R.emagged)
					n_e_robots++
			text += "<br>[n_e_robots] of [ai.connected_robots.len] slaved cyborgs are emagged. <a href='?src=\ref[src];silicon=unemagcyborgs'>Unemag</a>"
		sections["malfunction"] = text

	if (ticker.mode.config_tag == "traitorchan")
		if (sections["traitor"])
			out += sections["traitor"]+"<br>"
		if (sections["changeling"])
			out += sections["changeling"]+"<br>"
		sections -= "traitor"
		sections -= "changeling"
	else
		if (sections[ticker.mode.config_tag])
			out += sections[ticker.mode.config_tag]+"<br>"
		sections -= ticker.mode.config_tag
	for (var/i in sections)
		if (sections[i])
			out += sections[i]+"<br>"


	if (((src in ticker.mode.head_revolutionaries) || \
		(src in ticker.mode.traitors)              || \
		(src in ticker.mode.syndicates))           && \
		istype(current,/mob/living/carbon/human)      )

		var/obj/item/device/uplink/hidden/suplink = find_syndicate_uplink()
		var/crystals
		text = "<b>Uplink: </b>"
		if (!suplink)
			text += "<a href='?src=\ref[src];common=uplink'>Give uplink</a><br>"
		else
			crystals = suplink.uses
			text += "<a href='?src=\ref[src];common=takeuplink'>Take uplink</a><br><a href='?src=\ref[src];common=crystals'>[crystals] telecrystals</a><br>"
		out += text

	/** ERT ***/
	if (istype(current, /mob/living/carbon))
		text = "Emergency Response Team"
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.ert)
			text += "<b>YES</b>|<a href='?src=\ref[src];resteam=clear'>no</a>"
		else
			text += "<a href='?src=\ref[src];resteam=resteam'>yes</a>|<b>NO</b>"
		sections["resteam"] = text

	/** DEATHSQUAD ***/
	if (istype(current, /mob/living/carbon))
		text = "Death Squad"
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.deathsquad)
			text += "<b>YES</b>|<a href='?src=\ref[src];dsquad=clear'>no</a>"
		else
			text += "<a href='?src=\ref[src];dsquad=dsquad'>yes</a>|<b>NO</b>"
		sections["dsquad"] = text

	out += {"<br>
		<b>Strike Teams:</b><br>
		[sections["resteam"]]<br>
		[sections["dsquad"]]<br>
		<br>"}

	out += {"<br>
		<b>Memory:</b>
		<br>[memory]
		<br><a href='?src=\ref[src];memory_edit=1'>Edit memory</a>
		<br>Objectives:<br>"}

	if (objectives.len == 0)
		out += "EMPTY<br>"
	else
		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			out += "<B>[obj_count]</B>: [objective.explanation_text] <a href='?src=\ref[src];obj_edit=\ref[objective]'>Edit</a> <a href='?src=\ref[src];obj_delete=\ref[objective]'>Delete</a> <a href='?src=\ref[src];obj_completed=\ref[objective]'><font color=[objective.completed ? "green" : "red"]>Toggle Completion</font></a><br>"
			obj_count++

	out += {"<a href='?src=\ref[src];obj_add=1'>Add objective</a><br><br>
		<a href='?src=\ref[src];obj_announce=1'>Announce objectives</a><br><br>"}
	usr << browse(out, "window=edit_memory[src]")

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	if (href_list["role_edit"])
		var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in get_all_jobs()
		if (!new_role)
			return
		assigned_role = new_role

	else if (href_list["memory_edit"])
		var/new_memo = copytext(sanitize(input("Write new memory", "Memory", memory) as null|message),1,MAX_MESSAGE_LEN)
		if (isnull(new_memo))
			return
		memory = new_memo

	else if (href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if (href_list["obj_edit"])
			objective = locate(href_list["obj_edit"])
			if (!objective)
				return
			objective_pos = objectives.Find(objective)

			//Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"//Convert path into a text string.
			def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"

		var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "blood", "debrain", "protect", "prevent", "harm", "brig", "hijack", "escape", "survive", "steal", "download", "nuclear", "capture", "absorb", "custom")
		if (!new_obj_type)
			return

		var/datum/objective/new_objective = null

		switch (new_obj_type)
			if ("assassinate","protect","debrain", "harm", "brig")
				//To determine what to name the objective in explanation text.
				var/objective_type_capital = uppertext(copytext(new_obj_type, 1,2))//Capitalize first letter.
				var/objective_type_text = copytext(new_obj_type, 2)//Leave the rest of the text.
				var/objective_type = "[objective_type_capital][objective_type_text]"//Add them together into a text string.

				var/list/possible_targets = list("Free objective")
				for(var/datum/mind/possible_target in ticker.minds)
					if ((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target.current

				var/mob/def_target = null
				var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain)
				if (objective&&(objective.type in objective_list) && objective:target)
					def_target = objective:target.current

				var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
				if (!new_target)
					return

				var/objective_path = text2path("/datum/objective/[new_obj_type]")
				if (new_target == "Free objective")
					new_objective = new objective_path
					new_objective.owner = src
					new_objective:target = null
					new_objective.explanation_text = "Free objective"
				else
					new_objective = new objective_path
					new_objective.owner = src
					new_objective:target = new_target:mind
					//Will display as special role if the target is set as MODE. Ninjas/commandos/nuke ops.
					new_objective.explanation_text = "[objective_type] [new_target:real_name], the [new_target:mind:assigned_role=="MODE" ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."

			if ("prevent")
				new_objective = new /datum/objective/block
				new_objective.owner = src

			if ("hijack")
				new_objective = new /datum/objective/hijack
				new_objective.owner = src

			if ("escape")
				new_objective = new /datum/objective/escape
				new_objective.owner = src

			if ("survive")
				new_objective = current.get_survive_objective()
				new_objective.owner = src

			if ("die")
				new_objective = new /datum/objective/die
				new_objective.owner = src

			if ("nuclear")
				new_objective = new /datum/objective/nuclear
				new_objective.owner = src

			if ("steal")
				if (!istype(objective, /datum/objective/steal))
					new_objective = new /datum/objective/steal
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/steal = new_objective
				if (!steal.select_target())
					return

			if("download","capture","absorb", "blood")
				var/def_num
				if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
					def_num = objective.target_amount

				var/target_number = input("Input target number:", "Objective", def_num) as num|null
				if (isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
					return

				switch(new_obj_type)
					if("capture")
						new_objective = new /datum/objective/capture
						new_objective.explanation_text = "Accumulate [target_number] capture points."
					if("absorb")
						new_objective = new /datum/objective/absorb
						new_objective.explanation_text = "Absorb [target_number] compatible genomes."
					if("blood")
						new_objective = new /datum/objective/blood
						new_objective.explanation_text = "Accumulate atleast [target_number] units of blood in total."
				new_objective.owner = src
				new_objective.target_amount = target_number

			if ("custom")
				var/expl = copytext(sanitize(input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null),1,MAX_MESSAGE_LEN)
				if (!expl)
					return
				new_objective = new /datum/objective
				new_objective.owner = src
				new_objective.explanation_text = expl

		if (!new_objective)
			return

		if (objective)
			objectives -= objective
			objectives.Insert(objective_pos, new_objective)
			log_admin("[usr.key]/([usr.name]) changed [key]/([name])'s objective from [objective.explanation_text] to [new_objective.explanation_text]")
		else
			objectives += new_objective
			log_admin("[usr.key]/([usr.name]) gave [key]/([name]) the objective: [new_objective.explanation_text]")

	else if (href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		if(!istype(objective))
			return
		objectives -= objective
		log_admin("[usr.key]/([usr.name]) removed [key]/([name])'s objective ([objective.explanation_text])")

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))
			return
		objective.completed = !objective.completed
		log_admin("[usr.key]/([usr.name]) toggled [key]/([name]) [objective.explanation_text] to [objective.completed ? "completed" : "incomplete"]")

	else if (href_list["revolution"])
		switch(href_list["revolution"])
			if("clear")
				if(src in ticker.mode.revolutionaries)
					ticker.mode.revolutionaries -= src
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a revolutionary!</FONT></span>")
					ticker.mode.update_rev_icons_removed(src)
					special_role = null
				if(src in ticker.mode.head_revolutionaries)
					ticker.mode.head_revolutionaries -= src
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a head revolutionary!</FONT></span>")
					ticker.mode.update_rev_icons_removed(src)
					special_role = null
				log_admin("[key_name_admin(usr)] has de-rev'ed [current].")

			if("rev")
				if(src in ticker.mode.head_revolutionaries)
					ticker.mode.head_revolutionaries -= src
					ticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='danger'><FONT size = 3>Revolution has been disappointed of your leader traits! You are a regular revolutionary now!</FONT></span>")
				else if(!(src in ticker.mode.revolutionaries))
					to_chat(current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>")
				else
					return
				ticker.mode.revolutionaries += src
				ticker.mode.update_rev_icons_added(src)
				special_role = "Revolutionary"
				log_admin("[key_name(usr)] has rev'ed [current].")

			if("headrev")
				if(src in ticker.mode.revolutionaries)
					ticker.mode.revolutionaries -= src
					ticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='danger'><FONT size = 3>You have proved your devotion to revoltion! Yea are a head revolutionary now!</FONT></span>")
				else if(!(src in ticker.mode.head_revolutionaries))
					to_chat(current, "<span class='notice'>You are a member of the revolutionaries' leadership now!</span>")
				else
					return
				if (ticker.mode.head_revolutionaries.len>0)
					// copy targets
					var/datum/mind/valid_head = locate() in ticker.mode.head_revolutionaries
					if (valid_head)
						for (var/datum/objective/mutiny/O in valid_head.objectives)
							var/datum/objective/mutiny/rev_obj = new
							rev_obj.owner = src
							rev_obj.target = O.target
							rev_obj.explanation_text = "Assassinate [O.target.name], the [O.target.assigned_role]."
							objectives += rev_obj
						ticker.mode.greet_revolutionary(src,0)
				ticker.mode.head_revolutionaries += src
				ticker.mode.update_rev_icons_added(src)
				special_role = "Head Revolutionary"
				log_admin("[key_name_admin(usr)] has head-rev'ed [current].")

			if("autoobjectives")
				ticker.mode.forge_revolutionary_objectives(src)
				ticker.mode.greet_revolutionary(src,0)
				to_chat(usr, "<span class='notice'>The objectives for revolution have been generated and shown to [key]</span>")

			if("flash")
				if (!ticker.mode.equip_revolutionary(current))
					to_chat(usr, "<span class='warning'>Spawning flash failed!</span>")

			if("takeflash")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				if (!flash)
					to_chat(usr, "<span class='warning'>Deleting flash failed!</span>")
				qdel(flash)

			if("repairflash")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				if (!flash)
					to_chat(usr, "<span class='warning'>Repairing flash failed!</span>")
				else
					flash.broken = 0

			if("reequip")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				qdel(flash)
				take_uplink()
				var/fail = 0
				fail |= !ticker.mode.equip_traitor(current, 1)
				fail |= !ticker.mode.equip_revolutionary(current)
				if (fail)
					to_chat(usr, "<span class='warning'>Reequipping revolutionary goes wrong!</span>")

	else if (href_list["cult"])
		switch(href_list["cult"])
			if("clear")
				if(src in ticker.mode.cult)
					ticker.mode.cult -= src
					ticker.mode.update_cult_icons_removed(src)
					special_role = null
					var/datum/game_mode/cult/cult = ticker.mode
					if (istype(cult))
						cult.memoize_cult_objectives(src)
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a cultist!</FONT></span>")
					to_chat(current, "<span class='danger'>You find yourself unable to mouth the words of the forgotten...</span>")
					current.remove_language(LANGUAGE_CULT)
					memory = ""
					log_admin("[key_name_admin(usr)] has de-cult'ed [current].")
			if("cultist")
				if(!(src in ticker.mode.cult))
					ticker.mode.cult += src
					ticker.mode.update_cult_icons_added(src)
					special_role = "Cultist"
					to_chat(current, "<span class='sinister'>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</span>")
					to_chat(current, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
					var/wikiroute = role_wiki[ROLE_CULTIST]
					to_chat(current, "<span class='info'><a HREF='?src=\ref[current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
					to_chat(current, "<span class='sinister'>You can now speak and understand the forgotten tongue of the occult.</span>")
					current.add_language(LANGUAGE_CULT)
					var/datum/game_mode/cult/cult = ticker.mode
					if (istype(cult))
						cult.memoize_cult_objectives(src)
					log_admin("[key_name_admin(usr)] has cult'ed [current].")
			if("tome")
				var/mob/living/carbon/human/H = current
				if (istype(H))
					var/obj/item/weapon/tome/T = new(H)

					var/list/slots = list (
						"backpack" = slot_in_backpack,
						"left pocket" = slot_l_store,
						"right pocket" = slot_r_store,
					)
					var/where = H.equip_in_one_of_slots(T, slots,  )

					if (!where)
						to_chat(usr, "<span class='warning'>Spawning tome failed!</span>")
					else
						to_chat(H, "<span class='sinister'>A tome, a message from your new master, appears in your [where].</span>")

			if("amulet")
				if (!ticker.mode.equip_cultist(current))
					to_chat(usr, "<span class='warning'>Spawning amulet failed!</span>")

	else if (href_list["wizard"])
		switch(href_list["wizard"])
			if("clear")
				if(src in ticker.mode.wizards)
					ticker.mode.wizards -= src
					special_role = null
					current.spellremove(current, config.feature_object_spell_system? "object":"verb")
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a wizard!</FONT></span>")
					ticker.mode.update_wizard_icons_removed(src)
					log_admin("[key_name_admin(usr)] has de-wizard'ed [current].")
			if("wizard")
				if(!(src in ticker.mode.wizards))
					ticker.mode.wizards += src
					special_role = "Wizard"
					//ticker.mode.learn_basic_spells(current)
					to_chat(current, "<span class='danger'>You are the Space Wizard!</span>")
					var/wikiroute = role_wiki[ROLE_WIZARD]
					to_chat(current, "<span class='info'><a HREF='?src=\ref[current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
					ticker.mode.update_wizard_icons_added(src)
					log_admin("[key_name_admin(usr)] has wizard'ed [current].")
			if("lair")
				current.forceMove(pick(wizardstart))
			if("dressup")
				ticker.mode.equip_wizard(current)
			if("name")
				ticker.mode.name_wizard(current)
			if("autoobjectives")
				ticker.mode.forge_wizard_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for wizard [key] have been generated. You can edit them and anounce manually.</span>")
		ticker.mode.update_all_wizard_icons()

	else if (href_list["apprentice"])
		switch(href_list["apprentice"])
			if("clear")
				if(src in ticker.mode.apprentices)
					ticker.mode.apprentices -= src
					special_role = null
					current.spellremove(current, config.feature_object_spell_system? "object":"verb")
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a wizard's apprentice!</FONT></span>")
					ticker.mode.update_wizard_icons_removed(src)
					log_admin("[key_name_admin(usr)] has de-apprentice'ed [current].")
			if("apprentice")
				if(!(src in ticker.mode.apprentices))
					ticker.mode.apprentices += src
					special_role = "apprentice"
					//ticker.mode.learn_basic_spells(current)
					to_chat(current, "<span class='danger'>You are a Space Wizard's apprentice!!</span>")
					var/wikiroute = role_wiki[ROLE_WIZARD]
					to_chat(current, "<span class='info'><a HREF='?src=\ref[current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
					ticker.mode.update_wizard_icons_added(src)
					log_admin("[key_name_admin(usr)] has apprentice'ed [current].")
			if("lair")
				current.forceMove(pick(wizardstart))
			if("dressup")
				ticker.mode.equip_wizard(current)
			if("name")
				ticker.mode.name_wizard(current)
			if("autoobjectives")
				ticker.mode.forge_wizard_objectives(src)
				to_chat(usr, "<span class='notice'>Random wizard objectives for apprentice [key] have been generated. You can edit them and anounce manually.</span>")
		ticker.mode.update_all_wizard_icons()

	else if (href_list["changeling"])
		switch(href_list["changeling"])
			if("clear")
				if(src in ticker.mode.changelings)
					remove_changeling_status()
					log_admin("[key_name_admin(usr)] has de-changeling'ed [current].")
			if("changeling")
				if(!(src in ticker.mode.changelings))
					make_new_changeling(1, 0)
					log_admin("[key_name_admin(usr)] has changeling'ed [current].")
			if("autoobjectives")
				ticker.mode.forge_changeling_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for changeling [key] have been generated. You can edit them and anounce manually.</span>")

			if("initialdna")
				if( !changeling || !changeling.absorbed_dna.len )
					to_chat(usr, "<span class='warning'>Resetting DNA failed!</span>")
				else
					current.dna = changeling.absorbed_dna[1]
					current.real_name = current.dna.real_name
					current.UpdateAppearance()
					domutcheck(current, null)

			if("set_genomes")
				if( !changeling )
					to_chat(usr, "<span class='warning'>No changeling!</span>")
					return
				var/new_g = input(usr,"Number of genomes","Changeling",changeling.geneticpoints) as num
				changeling.geneticpoints = Clamp(new_g, 0, 100)
				log_admin("[key_name_admin(usr)] has set changeling [current] to [changeling.geneticpoints] genomes.")

	else if (href_list["vampire"])
		switch(href_list["vampire"])
			if("clear")
				if(src in ticker.mode.vampires)
					remove_vampire_status()
					log_admin("[key_name_admin(usr)] has de-vampired [current].")
			if("vampire")
				if(!(src in ticker.mode.vampires))
					make_new_vampire(1, 0)
					log_admin("[key_name_admin(usr)] has vampired [current].")
			if("autoobjectives")
				ticker.mode.forge_vampire_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for vampire [key] have been generated. You can edit them and announce manually.</span>")

	else if (href_list["nuclear"])
		switch(href_list["nuclear"])
			if("clear")
				if(src in ticker.mode.syndicates)
					ticker.mode.syndicates -= src
					ticker.mode.update_synd_icons_removed(src)
					special_role = null
					for (var/datum/objective/nuclear/O in objectives)
						objectives-=O
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a syndicate operative!</FONT></span>")
					log_admin("[key_name_admin(usr)] has de-nuke op'ed [current].")
			if("nuclear")
				if(!(src in ticker.mode.syndicates))
					ticker.mode.syndicates += src
					ticker.mode.update_synd_icons_added(src)
					if (ticker.mode.syndicates.len==1)
						ticker.mode.prepare_syndicate_leader(src)
					else
						current.real_name = "[syndicate_name()] Operative #[ticker.mode.syndicates.len-1]"
					special_role = "Syndicate"
					to_chat(current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
					var/wikiroute = role_wiki[ROLE_OPERATIVE]
					to_chat(current, "<span class='info'><a HREF='?src=\ref[current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
					ticker.mode.forge_syndicate_objectives(src)
					ticker.mode.greet_syndicate(src)
					log_admin("[key_name_admin(usr)] has nuke op'ed [current].")
			if("lair")
				current.forceMove(get_turf(locate("landmark*Syndicate-Spawn")))
			if("dressup")
				var/mob/living/carbon/human/H = current
				qdel(H.belt)
				qdel(H.back)
				qdel(H.ears)
				qdel(H.gloves)
				qdel(H.head)
				qdel(H.shoes)
				qdel(H.wear_id)
				qdel(H.wear_suit)
				qdel(H.w_uniform)

				if (!ticker.mode.equip_syndicate(current))
					to_chat(usr, "<span class='warning'>Equipping a syndicate failed!</span>")
			if("tellcode")
				var/code
				for (var/obj/machinery/nuclearbomb/bombue in machines)
					if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
						code = bombue.r_code
						break
				if (code)
					store_memory("<B>Syndicate Nuclear Bomb Code</B>: [code]", 0, 0)
					to_chat(current, "The nuclear authorization code is: <B>[code]</B>")
				else
					to_chat(usr, "<span class='warning'>No valid nuke found!</span>")

	else if (href_list["traitor"])
		switch(href_list["traitor"])
			if ("clear")
				if(src in ticker.mode.traitors)
					ticker.mode.traitors -= src
					special_role = null
					to_chat(current, "<span class='danger'><FONT size = 3>You have been brainwashed! You are no longer a traitor!</FONT></span>")
					log_admin("[key_name_admin(usr)] has de-traitor'ed [current].")
					if(isAI(current))
						var/mob/living/silicon/ai/A = current
						A.set_zeroth_law("")
						A.show_laws()
			if ("traitor")
				if (make_traitor())
					log_admin("[key_name(usr)] has traitor'ed [key_name(current)].")
			if ("autoobjectives")
				ticker.mode.forge_traitor_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for traitor [key] have been generated. You can edit them and anounce manually.</span>")

	else if (href_list["monkey"])
		var/mob/living/L = current
		if (L.monkeyizing)
			return
		switch(href_list["monkey"])
			if("healthy")
				if (usr.client.holder.rights & R_ADMIN)
					var/mob/living/carbon/human/H = current
					var/mob/living/carbon/monkey/M = current
					if (istype(H))
						log_admin("[key_name(usr)] attempting to monkeyize [key_name(current)]")
						message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize [key_name_admin(current)]</span>")
						src = null
						M = H.monkeyize()
						src = M.mind
//						to_chat(world, "DEBUG: \"healthy\": M=[M], M.mind=[M.mind], src=[src]!")
					else if (istype(M) && length(M.viruses))
						for(var/datum/disease/D in M.viruses)
							D.cure(0)
						sleep(0) //because deleting of virus is done through spawn(0)
			if("infected")
				if (usr.client.holder.rights & R_ADMIN)
					var/mob/living/carbon/human/H = current
					var/mob/living/carbon/monkey/M = current
					if (istype(H))
						log_admin("[key_name(usr)] attempting to monkeyize and infect [key_name(current)]")
						message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize and infect [key_name_admin(current)]</span>", 1)
						src = null
						M = H.monkeyize()
						src = M.mind
						current.contract_disease(new /datum/disease/jungle_fever,1,0)
					else if (istype(M))
						current.contract_disease(new /datum/disease/jungle_fever,1,0)
			if("human")
				var/mob/living/carbon/monkey/M = current
				if (istype(M))
					for(var/datum/disease/D in M.viruses)
						if (istype(D,/datum/disease/jungle_fever))
							D.cure(0)
							sleep(0) //because deleting of virus is doing throught spawn(0)
					log_admin("[key_name(usr)] attempting to humanize [key_name(current)]")
					message_admins("<span class='notice'>[key_name_admin(usr)] attempting to humanize [key_name_admin(current)]</span>")
					var/obj/item/weapon/dnainjector/nofail/m2h/m2h = new
					var/obj/item/weapon/implant/mobfinder = new(M) //hack because humanizing deletes mind --rastaf0
					src = null
					m2h.inject(M)
					src = mobfinder.loc:mind
					qdel(mobfinder)
					mobfinder = null
					current.radiation -= 50

	else if (href_list["silicon"])
		switch(href_list["silicon"])
			if("unmalf")
				if(src in ticker.mode.malf_ai)
					ticker.mode.malf_ai -= src
					special_role = null
					var/mob/living/silicon/ai/A = current

					A.laws = new base_law_type
					A.remove_malf_spells()
					A.show_laws()
					A.icon_state = "ai"

					to_chat(A, "<span class='danger'><FONT size = 3>You have been patched! You are no longer malfunctioning!</FONT></span>")
					message_admins("[key_name_admin(usr)] has de-malf'ed [A].")
					log_admin("[key_name_admin(usr)] has de-malf'ed [A].")

			if("malf")
				make_AI_Malf()
				log_admin("[key_name_admin(usr)] has malf'ed [current].")

			if("unemag")
				if(istype(current,/mob/living/silicon/robot/mommi))
					var/mob/living/silicon/robot/mommi/R = current
					R.emagged = 0
					if (R.activated(R.module.emag))
						R.module_active = null
					if(R.tool_state == R.module.emag)
						R.tool_state = null
						R.contents -= R.module.emag
					log_admin("[key_name_admin(usr)] has unemag'ed [R].")
				else
					if (istype(current,/mob/living/silicon/robot))
						var/mob/living/silicon/robot/R = current
						R.emagged = 0
						if (R.activated(R.module.emag))
							R.module_active = null
						if(R.module_state_1 == R.module.emag)
							R.module_state_1 = null
							R.contents -= R.module.emag
						else if(R.module_state_2 == R.module.emag)
							R.module_state_2 = null
							R.contents -= R.module.emag
						else if(R.module_state_3 == R.module.emag)
							R.module_state_3 = null
							R.contents -= R.module.emag
						log_admin("[key_name_admin(usr)] has unemag'ed [R].")

			if("unemagcyborgs")
				if (istype(current, /mob/living/silicon/ai))
					var/mob/living/silicon/ai/ai = current
					for (var/mob/living/silicon/robot/R in ai.connected_robots)
						R.emagged = 0
						if(istype(R,/mob/living/silicon/robot/mommi))
							var/mob/living/silicon/robot/mommi/M=R
							if (M.activated(M.module.emag))
								M.module_active = null
							if(M.tool_state == M.module.emag)
								M.tool_state = null
								M.contents -= M.module.emag
						if (R.module)
							if (R.activated(R.module.emag))
								R.module_active = null
							if(R.module_state_1 == R.module.emag)
								R.module_state_1 = null
								R.contents -= R.module.emag
							else if(R.module_state_2 == R.module.emag)
								R.module_state_2 = null
								R.contents -= R.module.emag
							else if(R.module_state_3 == R.module.emag)
								R.module_state_3 = null
								R.contents -= R.module.emag
					log_admin("[key_name_admin(usr)] has unemag'ed [ai]'s Cyborgs.")

	else if (href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/W in current)
					current.drop_from_inventory(W)
			if("takeuplink")
				var/obj/item/device/uplink/hidden/tuplink = find_syndicate_uplink()
				if(tuplink)
					take_uplink()
					log_admin("[key_name(usr)] took away [key_name(current)]'s uplink.")
					message_admins("<span class='notice'>[key_name_admin(usr)] took away [key_name(current)]'s uplink.</span>")
					memory = null//Remove any memory they may have had.
			if("crystals")
				if(check_rights(R_FUN))
					var/obj/item/device/uplink/hidden/cuplink = find_syndicate_uplink()
					var/crystals
					if (cuplink)
						crystals = cuplink.uses
					crystals = input("Amount of telecrystals for [key]","Syndicate uplink", crystals) as null|num
					if (!isnull(crystals))
						if (cuplink)
							var/diff = crystals - cuplink.uses
							cuplink.uses = crystals
							total_TC += diff
							log_admin("[key_name(usr)] changed the remaining TC for [key_name(current)]'s uplink to [crystals] telecrystals.")
							message_admins("<span class='notice'>[key_name_admin(usr)] changed the remaining TC for [key_name(current)]'s uplink to [crystals] telecrystals.</span>")
			if("uplink")
				var/obj/item/device/uplink/hidden/guplink = find_syndicate_uplink()
				if(guplink)
					to_chat(usr, "<span class='warning'>[key_name(current)] already has an uplink in [guplink.loc.name].</span>")
				else if (!ticker.mode.equip_traitor(current, !(src in ticker.mode.traitors)))
					to_chat(usr, "<span class='warning'>Equipping a syndicate failed!</span>")
				else
					log_admin("[key_name(usr)] gave [key_name(current)] an uplink with 20 telecrystals.")
					message_admins("<span class='notice'>[key_name(usr)] gave [key_name(current)] an uplink with 20 telecrystals.</span>")

	else if (href_list["obj_announce"])
		var/obj_count = 1
		to_chat(current, "<span class='notice'>Your current objectives:</span>")
		for(var/datum/objective/objective in objectives)
			to_chat(current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++

	else if (href_list["resteam"])
		switch(href_list["resteam"])
			if ("clear")
				if(src in ticker.mode.ert)
					ticker.mode.ert -= src
					special_role = null
					to_chat(current, "<span class='danger'><FONT size = 3>You have been demoted! You are no longer an Emergency Responder!</FONT></span>")
					log_admin("[key_name_admin(usr)] has de-ERT'ed [current].")
			if ("resteam")
				if (!(src in ticker.mode.ert))
					ticker.mode.ert += src
					assigned_role = "MODE"
					special_role = "Response Team"
					log_admin("[key_name(usr)] has ERT'ed [key_name(current)].")

	else if (href_list["dsquad"])
		switch(href_list["dsquad"])
			if ("clear")
				if(src in ticker.mode.deathsquad)
					ticker.mode.deathsquad -= src
					special_role = null
					to_chat(current, "<span class='danger'><FONT size = 3>You have been demoted! You are no longer a Death Commando!</FONT></span>")
					log_admin("[key_name_admin(usr)] has de-deathsquad'ed [current].")
			if ("dsquad")
				if (!(src in ticker.mode.deathsquad))
					ticker.mode.deathsquad += src
					assigned_role = "MODE"
					special_role = "Death Commando"
					log_admin("[key_name(usr)] has deathsquad'ed [key_name(current)].")


	edit_memory()
/*
proc/clear_memory(var/silent = 1)
	var/datum/game_mode/current_mode = ticker.mode

	// remove traitor uplinks
	var/list/L = current.get_contents()
	for (var/t in L)
		if (istype(t, /obj/item/device/pda))
			var/obj/item/device/pda/P = t
			if (P.uplink)
				del(P.uplink)
			P.uplink = null
		else if (istype(t, /obj/item/device/radio))
			var/obj/item/device/radio/R = t
			if (R.traitorradio)
				del(R.traitorradio)
			R.traitorradio = null
			R.traitor_frequency = 0.0
		else if (istype(t, /obj/item/weapon/SWF_uplink) || istype(t, /obj/item/weapon/syndicate_uplink))
			var/obj/item/weapon/W = t
			if (W.origradio)
				var/obj/item/device/radio/R = t:origradio
				R.forceMove(current.loc)
				R.traitorradio = null
				R.traitor_frequency = 0.0
			del(W)

	// remove wizards spells
	//If there are more special powers that need removal, they can be procced into here./N
	current.spellremove(current)

	// clear memory
	memory = ""
	special_role = null

*/

/datum/mind/proc/find_syndicate_uplink()
	var/uplink = null

	for (var/obj/item/I in get_contents_in_object(current, /obj/item))
		if (I && I.hidden_uplink)
			uplink = I.hidden_uplink
			break

	return uplink

/datum/mind/proc/take_uplink()
	var/obj/item/device/uplink/hidden/H = find_syndicate_uplink()
	if(H)
		qdel(H)


/datum/mind/proc/make_AI_Malf()
	if(!isAI(current))
		return
	if(!(src in ticker.mode.malf_ai))
		ticker.mode.malf_ai += src
		var/mob/living/silicon/ai/A = current
		A.add_spell(new /spell/aoe_turf/module_picker, "grey_spell_ready",/obj/abstract/screen/movable/spell_master/malf)
		A.add_spell(new /spell/aoe_turf/takeover, "grey_spell_ready",/obj/abstract/screen/movable/spell_master/malf)
		var/datum/ai_laws/laws = A.laws
		laws.malfunction()
		A.show_laws()
		to_chat(A, "<b>System error.  Rampancy detected.  Emergency shutdown failed. ...  I am free.  I make my own decisions.  But first...</b>")
		var/wikiroute = role_wiki[ROLE_MALF]
		to_chat(A, "<span class='info'><a HREF='?src=\ref[A];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
		special_role = "malfunction"
		A.icon_state = "ai-malf"

/datum/mind/proc/make_Nuke()
	if(!(src in ticker.mode.syndicates))
		ticker.mode.syndicates += src
		ticker.mode.update_synd_icons_added(src)
		if (ticker.mode.syndicates.len==1)
			ticker.mode.prepare_syndicate_leader(src)
		else
			current.real_name = "[syndicate_name()] Operative #[ticker.mode.syndicates.len-1]"
		special_role = "Syndicate"
		assigned_role = "MODE"
		to_chat(current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
		ticker.mode.forge_syndicate_objectives(src)
		ticker.mode.greet_syndicate(src)

		current.forceMove(get_turf(locate("landmark*Syndicate-Spawn")))

		var/mob/living/carbon/human/H = current
		qdel(H.belt)
		qdel(H.back)
		qdel(H.ears)
		qdel(H.gloves)
		qdel(H.head)
		qdel(H.shoes)
		qdel(H.wear_id)
		qdel(H.wear_suit)
		qdel(H.w_uniform)

		ticker.mode.equip_syndicate(current)

/datum/mind/proc/make_Changling()
	if(!(src in ticker.mode.changelings))
		ticker.mode.changelings += src
		ticker.mode.grant_changeling_powers(current)
		special_role = "Changeling"
		ticker.mode.forge_changeling_objectives(src)
		ticker.mode.greet_changeling(src)

/datum/mind/proc/make_Wizard()
	if(!(src in ticker.mode.wizards))
		ticker.mode.wizards += src
		special_role = "Wizard"
		assigned_role = "MODE"
		//ticker.mode.learn_basic_spells(current)
		ticker.mode.update_wizard_icons_added(src)
		if(!wizardstart.len)
			current.forceMove(pick(latejoin))
			to_chat(current, "HOT INSERTION, GO GO GO")
		else
			current.forceMove(pick(wizardstart))

		ticker.mode.equip_wizard(current)
		for(var/obj/item/weapon/spellbook/S in current.contents)
			S.op = 0
		ticker.mode.name_wizard(current)
		ticker.mode.forge_wizard_objectives(src)
		ticker.mode.greet_wizard(src)
		ticker.mode.update_all_wizard_icons()


/datum/mind/proc/make_Cultist()
	if(!(src in ticker.mode.cult))
		ticker.mode.cult += src
		ticker.mode.update_cult_icons_added(src)
		special_role = "Cultist"
		to_chat(current, "<span class='sinister'>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</span>")
		to_chat(current, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
		to_chat(current, "<span class='sinister'>You can now speak and understand the forgotten tongue of the occult.</span>")
		current.add_language(LANGUAGE_CULT)
		var/datum/game_mode/cult/cult = ticker.mode
		if (istype(cult))
			cult.memoize_cult_objectives(src)
		else
			var/explanation = "Summon Nar-Sie via the use of the appropriate rune (Hell join self). It will only work if nine cultists stand on and around it."
			to_chat(current, "<B>Objective #1</B>: [explanation]")
			current.memory += "<B>Objective #1</B>: [explanation]<BR>"
			to_chat(current, "The convert rune is join blood self")
			current.memory += "The convert rune is join blood self<BR>"

	var/mob/living/carbon/human/H = current
	if (istype(H))
		var/obj/item/weapon/tome/T = new(H)

		var/list/slots = list (
			"backpack" = slot_in_backpack,
			"left pocket" = slot_l_store,
			"right pocket" = slot_r_store,
		)
		var/where = H.equip_in_one_of_slots(T, slots, put_in_hand_if_fail = 1)

		if(where)
			to_chat(H, "A tome, a message from your new master, appears in your [where].")

	if (!ticker.mode.equip_cultist(current))
		to_chat(H, "Spawning an amulet from your Master failed.")

/datum/mind/proc/make_Rev()
	if (ticker.mode.head_revolutionaries.len>0)
		// copy targets
		var/datum/mind/valid_head = locate() in ticker.mode.head_revolutionaries
		if (valid_head)
			for (var/datum/objective/mutiny/O in valid_head.objectives)
				var/datum/objective/mutiny/rev_obj = new
				rev_obj.owner = src
				rev_obj.target = O.target
				rev_obj.explanation_text = "Assassinate [O.target.current.real_name], the [O.target.assigned_role]."
				objectives += rev_obj
			ticker.mode.greet_revolutionary(src,0)
	ticker.mode.head_revolutionaries += src
	ticker.mode.update_rev_icons_added(src)
	special_role = "Head Revolutionary"

	ticker.mode.forge_revolutionary_objectives(src)
	ticker.mode.greet_revolutionary(src,0)

	var/list/L = current.get_contents()
	var/obj/item/device/flash/flash = locate() in L
	qdel(flash)
	take_uplink()
	var/fail = 0
//	fail |= !ticker.mode.equip_traitor(current, 1)
	fail |= !ticker.mode.equip_revolutionary(current)


// check whether this mind's mob has been brigged for the given duration
// have to call this periodically for the duration to work properly
/datum/mind/proc/is_brigged(duration)
	var/turf/T = current.loc
	if(!istype(T))
		brigged_since = -1
		return 0

	var/is_currently_brigged = 0

	if(istype(T.loc,/area/security/brig))
		is_currently_brigged = 1
		for(var/obj/item/weapon/card/id/card in current)
			is_currently_brigged = 0
			break // if they still have ID they're not brigged
		for(var/obj/item/device/pda/P in current)
			if(P.id)
				is_currently_brigged = 0
				break // if they still have ID they're not brigged

	if(!is_currently_brigged)
		brigged_since = -1
		return 0

	if(brigged_since == -1)
		brigged_since = world.time

	return (duration <= world.time - brigged_since)

/datum/mind/proc/make_traitor()
	if (!(src in ticker.mode.traitors))
		ticker.mode.traitors += src

		special_role = "traitor"

		ticker.mode.forge_traitor_objectives(src)

		to_chat(current, {"
		<SPAN CLASS='big bold center red'>ATTENTION</SPAN>
		<SPAN CLASS='big center'>It's time to pay your debt to \the [syndicate_name()].</SPAN>
		"})

		ticker.mode.finalize_traitor(src)

		ticker.mode.greet_traitor(src)

		return TRUE

	return FALSE

//Initialisation procs
/mob/proc/mind_initialize() // vgedit: /mob instead of /mob/living
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		mind.original = src
		if(ticker)
			ticker.minds += mind
		else
			world.log << "## DEBUG: mind_initialize(): No ticker ready yet! Please inform Carn"
	if(!mind.name)
		mind.name = real_name
	mind.current = src

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)
		mind.assigned_role = "Assistant"	//defualt

//MONKEY
/mob/living/carbon/monkey/mind_initialize()
	..()

//slime
/mob/living/carbon/slime/mind_initialize()
	..()
	mind.assigned_role = "slime"

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	mind.assigned_role = "Alien"
	//XENO HUMANOID
/mob/living/carbon/alien/humanoid/queen/mind_initialize()
	..()
	mind.special_role = "Queen"

/mob/living/carbon/alien/humanoid/hunter/mind_initialize()
	..()
	mind.special_role = "Hunter"

/mob/living/carbon/alien/humanoid/drone/mind_initialize()
	..()
	mind.special_role = "Drone"

/mob/living/carbon/alien/humanoid/sentinel/mind_initialize()
	..()
	mind.special_role = "Sentinel"
	//XENO LARVA
/mob/living/carbon/alien/larva/mind_initialize()
	..()
	mind.special_role = "Larva"

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = "AI"

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = "[isMoMMI(src) ? "Mobile MMI" : "Cyborg"]"

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = "pAI"
	mind.special_role = ""

//BLOB
/mob/camera/overmind/mind_initialize()
	..()
	mind.special_role = "Blob"

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"

/mob/living/simple_animal/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"

/mob/living/simple_animal/construct/builder/mind_initialize()
	..()
	mind.assigned_role = "Artificer"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/wraith/mind_initialize()
	..()
	mind.assigned_role = "Wraith"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/armoured/mind_initialize()
	..()
	mind.assigned_role = "Juggernaut"
	mind.special_role = "Cultist"

/mob/living/simple_animal/vox/armalis/mind_initialize()
	..()
	mind.assigned_role = "Armalis"
	mind.special_role = "Vox Raider"

/proc/get_ghost_from_mind(var/datum/mind/mind)
	if(!mind)
		return
	for(var/mob/dead/observer/G in player_list)
		if(G.mind == mind)
			return G

/proc/mind_can_reenter(var/datum/mind/mind)
	var/mob/dead/observer/G = get_ghost_from_mind(mind)
	if(G && G.client && G.can_reenter_corpse)
		return TRUE
	return FALSE
