
//cael - some changes here. the analysis pad is entirely new

/obj/machinery/artifact_analyser
	name = "Artifact Analyser"
	desc = "Studies the structure of artifacts to discover their uses."
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1
	var/working = 0
	var/accuO = 0
	var/accuT = 0
	var/accuE1 = 0
	var/accuE2 = 0
	var/aorigin = "None"
	var/atrigger = "None"
	var/aeffect1 = "None"
	var/aeffect2 = "None"
	var/list/origin_bonuses
	var/list/trigger_bonuses
	var/list/function_bonuses
	var/list/range_bonuses
	var/cur_id = ""
	var/scan_num = 0
	var/obj/machinery/artifact/cur_artifact = null
	var/obj/machinery/analyser_pad/owned_pad = null
	var/list/allorigins = list("Ancient Robots","Martian","Wizard Federation","Extradimensional","Precursor")
	var/list/alltriggers = list("Contact with Living Organism","Heavy Impact","Contact with Energy Source","Contact with Hydrogen","Contact with Corrosive Substance","Contact with Volatile Substance","Contact with Toxins","Exposure to Heat")
	var/list/alleffects = list("Healing Device","Anti-biological Weapon","Non-lethal Stunning Trap","Mechanoid Repair Module","Mechanoid Deconstruction Device","Power Generator","Power Drain","Stellar Mineral Attractor","Agriculture Regulator","Shield Generator","Space-Time Displacer")
	var/list/allranges = list("Constant Short-Range Energy Field","Medium Range Energy Pulses","Long Range Energy Pulses","Extreme Range Energy Pulses","Requires contact with subject")

/obj/machinery/artifact_analyser/New()
	..()
	origin_bonuses = new/list()
	origin_bonuses["ancient"] = 0
	origin_bonuses["martian"] = 0
	origin_bonuses["wizard"] = 0
	origin_bonuses["eldritch"] = 0
	origin_bonuses["precursor"] = 0
	trigger_bonuses = new/list()
	trigger_bonuses["ancient"] = 0
	trigger_bonuses["martian"] = 0
	trigger_bonuses["wizard"] = 0
	trigger_bonuses["eldritch"] = 0
	trigger_bonuses["precursor"] = 0
	function_bonuses = new/list()
	function_bonuses["ancient"] = 0
	function_bonuses["martian"] = 0
	function_bonuses["wizard"] = 0
	function_bonuses["eldritch"] = 0
	function_bonuses["precursor"] = 0
	range_bonuses = new/list()
	range_bonuses["ancient"] = 0
	range_bonuses["martian"] = 0
	range_bonuses["wizard"] = 0
	range_bonuses["eldritch"] = 0
	range_bonuses["precursor"] = 0
	//
	spawn(10)
		owned_pad = locate() in orange(1, src)

/obj/machinery/artifact_analyser/attack_hand(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	user.machine = src
	var/dat = "<B>Artifact Analyser</B><BR>"
	dat += "<HR><BR>"
	if(!owned_pad)
		dat += "<B><font color=red>Unable to locate analysis pad.</font><BR></b>"
		dat += "<HR><BR>"
	else if (!working)
		dat += "<B>Artifact ID:</B> [cur_id]<BR>"
		dat += "<B>Artifact Origin:</B> [aorigin] ([accuO]%)<BR>"
		dat += "<B>Activation Trigger:</B> [atrigger] ([accuT]%)<BR>"
		dat += "<B>Artifact Function:</B> [aeffect1] ([accuE1]%)<BR>"
		dat += "<B>Artifact Range:</B> [aeffect2] ([accuE2]%)<BR><BR>"
		dat += "<HR><BR>"
		dat += "Artifact ID is determined from unique energy emission signatures.<br>"
		dat += "<A href='?src=\ref[src];analyse=1'>Analyse Artifact (Scan number #[scan_num+1])</a><BR>"
		dat += "<A href='?src=\ref[src];upload=1'>Upload/update artifact scan</a><BR>"
		dat += "<A href='?src=\ref[src];print=1'>Print Page</a><BR>"
	else
		dat += "<B>Please wait. Analysis in progress.</B><BR>"
		dat += "<HR><BR>"
	//
	dat += "<A href='?src=\ref[src];close=1'>Close<BR>"
	user << browse(dat, "window=artanalyser;size=450x500")
	onclose(user, "artanalyser")

/obj/machinery/artifact_analyser/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(350)
	//
	if(!owned_pad)
		for(var/obj/machinery/analyser_pad/pad in range(1))
			owned_pad = pad
			break

/obj/machinery/artifact_analyser/proc/AA_FailedAnalysis(var/failtype)
	switch(failtype)
		if(1)
			aorigin = "Failed to Identify"
			if (prob(20)) aorigin = pick(allorigins)
		if(2)
			atrigger = "Failed to Identify"
			if (prob(20)) atrigger = pick(alltriggers)
		if(3)
			aeffect1 = "Failed to Identify"
			if (prob(20)) aeffect1 = pick(alleffects)
		if(4)
			aeffect2 = "Failed to Identify"
			if (prob(20)) aeffect2 = pick(allranges)

/obj/machinery/artifact_analyser/proc/AA_Analyse()
	if(!cur_artifact)
		return
	accuO = 5 + rand(0,10) + origin_bonuses[cur_artifact.origin] + cur_artifact.activated * 50
	accuT = 5 + rand(0,10) + trigger_bonuses[cur_artifact.origin] + cur_artifact.activated * 50
	accuE1 = 5 + rand(0,10) + function_bonuses[cur_artifact.origin] + cur_artifact.activated * 50
	accuE2 = 5 + rand(0,10) + range_bonuses[cur_artifact.origin] + cur_artifact.activated * 50

	//keep any correctly determined properties the same
	var/origin_correct = 0
	var/trigger_correct = 0
	var/function_correct = 0
	var/range_correct = 0
	if(cur_id == cur_artifact.display_id)
		if(aorigin == cur_artifact.origin)
			origin_correct = 1

		if(atrigger == cur_artifact.my_effect.trigger)
			trigger_correct = 1
		else if(atrigger == cur_artifact.my_effect.triggerX)
			trigger_correct = 1

		if(aeffect1 == cur_artifact.my_effect.effecttype)
			function_correct = 1

		if(aeffect2 == cur_artifact.my_effect.effectmode)
			range_correct = 1

	if (accuO > 100) accuO = 100
	if (accuT > 100) accuT = 100
	if (accuE1 > 100) accuE1 = 100
	if (accuE2 > 100) accuE2 = 100
	// Roll to generate report
	if (prob(accuO) || origin_correct)
		switch(cur_artifact.origin)
			if("ancient") aorigin = "Ancient Robots"
			if("martian") aorigin = "Martian"
			if("wizard") aorigin = "Wizard Federation"
			if("eldritch") aorigin = "Extradimensional"
			if("precursor") aorigin = "Precursor"
			else aorigin = "Unknown Origin"
		origin_bonuses[cur_artifact.origin] += 10
	else
		AA_FailedAnalysis(1)
		origin_bonuses[cur_artifact.origin] += 5
	if (prob(accuT) || trigger_correct)
		switch(cur_artifact.my_effect.trigger)
			if("touch") atrigger = "Contact with Living Organism"
			if("force") atrigger = "Heavy Impact"
			if("energy") atrigger = "Contact with Energy Source"
			if("chemical")
				switch(cur_artifact.my_effect.triggerX)
					if("hydrogen") atrigger = "Contact with Hydrogen"
					if("corrosive") atrigger = "Contact with Corrosive Substance"
					if("volatile") atrigger = "Contact with Volatile Substance"
					if("toxin") atrigger = "Contact with Toxins"
			if("heat") atrigger = "Exposure to Heat"
			else atrigger = "Unknown Trigger"
		trigger_bonuses[cur_artifact.origin] += 5
	else
		AA_FailedAnalysis(2)
		trigger_bonuses[cur_artifact.origin] += 1
	if (prob(accuE1) || function_correct)
		switch(cur_artifact.my_effect.effecttype)
			if("healing")  aeffect1 = "Healing Device"
			if("injure") aeffect1 = "Anti-biological Weapon"
			// if("stun") aeffect1 = "Non-lethal Stunning Trap"
			if("roboheal") aeffect1 = "Mechanoid Repair Module"
			if("robohurt") aeffect1 = "Mechanoid Deconstruction Device"
			if("cellcharge") aeffect1 = "Power Generator"
			if("celldrain") aeffect1 = "Power Drain"
			if("planthelper") aeffect1 = "Agriculture Regulator"
			if("forcefield") aeffect1 = "Shield Generator"
			if("teleport") aeffect1 = "Space-Time Displacer"
			else aeffect1 = "Unknown Effect"
		function_bonuses[cur_artifact.origin] += 5
	else
		AA_FailedAnalysis(3)
		function_bonuses[cur_artifact.origin] += 1
	if (prob(accuE2) || range_correct)
		switch(cur_artifact.my_effect.effectmode)
			if("aura") aeffect2 = "Constant Short-Range Energy Field"
			if("pulse")
				if(cur_artifact.my_effect.aurarange > 7) aeffect2 = "Long Range Energy Pulses"
				else aeffect2 = "Medium Range Energy Pulses"
			if("worldpulse") aeffect2 = "Extreme Range Energy Pulses"
			if("contact") aeffect2 = "Requires contact with subject"
			else aeffect2 = "Unknown Range"
		range_bonuses[cur_artifact.origin] += 5
	else
		AA_FailedAnalysis(4)
		range_bonuses[cur_artifact.origin] += 1

	cur_artifact.name = "alien artifact ([cur_artifact.display_id])"
	cur_artifact.desc = "A large alien device. It has a small tag near the bottom that reads \"[cur_artifact.display_id]\"."
	cur_id = cur_artifact.display_id
	cur_artifact.my_effect.artifact_id = cur_artifact.display_id

/obj/machinery/artifact_analyser/Topic(href, href_list)
	if(..()) return 1
	if(href_list["analyse"])
		if(owned_pad)
			var/turf/pad_turf = get_turf(owned_pad)
			var/findarti = 0
			for(var/obj/machinery/artifact/A in pad_turf.contents)
				findarti++
				cur_artifact = A
			if (findarti == 1)
				if(cur_artifact && cur_artifact.being_used)
					var/message = "<b>[src]</b> states, \"Cannot analyse. Excess energy drain is disrupting signal.\""
					visible_message(message, message)
				else
					cur_artifact.anchored = 1
					cur_artifact.being_used = 1
					working = 1
					icon_state = "analyser_processing"
					var/time = rand(30,50) + max(0, 300 - scan_num * 10)
					/*for(var/i = artifact_research.starting_tier, i <= artifact_research.max_tiers, i++)
						for(var/datum/artiresearch/R in artifact_research.researched_items[i])
							if (R.bonustype == "analyser") time -= R.bonusTime*/
					time *= 10
					var/message = "<b>[src]</b> states, \"Commencing analysis.\""
					visible_message(message, message)
					use_power(500)
					spawn(time)
						working = 0
						icon_state = "analyser"
						cur_artifact.anchored = 0
						cur_artifact.being_used = 0
						if(cur_artifact.loc == pad_turf)
							AA_Analyse()
							scan_num++
							message = "<b>[src]</b> states, \"Analysis complete.\""
							visible_message(message, message)
							use_power(500)
			else if (findarti > 1)
				var/message = "<b>[src]</b> states, \"Cannot analyse. Error isolating energy signature.\""
				visible_message(message, message)
			else
				var/message = "<b>[src]</b> states, \"Cannot analyse. No noteworthy energy signature isolated.\""
				visible_message(message, message)

	if(href_list["upload"] && cur_id != "")
		//add new datum to every DB in the world
		for(var/obj/machinery/computer/artifact_database/DB in machines)
			var/update = 0
			for(var/datum/catalogued_artifact/CA in DB.catalogued_artifacts)
				if(CA.display_id == cur_id)
					//already there, so update it
					update = 1
					CA.origin = aorigin + " ([accuO]%)"
					CA.trigger = atrigger + " ([accuT]%)"
					CA.effecttype = aeffect1 + " ([accuE1]%)"
					CA.effectmode = aeffect2 + " ([accuE2]%)"
			if(!update)
				//not there, so add it
				var/datum/catalogued_artifact/CA = new()
				CA.display_id = cur_id
				CA.origin = aorigin + " ([accuO]%)"
				CA.trigger = atrigger + " ([accuT]%)"
				CA.effecttype = aeffect1 + " ([accuE1]%)"
				CA.effectmode = aeffect2 + " ([accuE2]%)"
				DB.catalogued_artifacts.Add(CA)
			use_power(100)

	if(href_list["print"])
		var/r = "Artifact Analysis Report (Scan #[scan_num])<hr>"
		r += "<B>Artifact ID:</B> [cur_id] (determined from unique energy emission signatures)<BR>"
		r += "<B>Artifact Origin:</B> [aorigin] ([accuO]%)<BR>"
		r += "<B>Activation Trigger:</B> [atrigger] ([accuT]%)<BR>"
		r += "<B>Artifact Function:</B> [aeffect1] ([accuE1]%)<BR>"
		r += "<B>Artifact Range:</B> [aeffect2] ([accuE2]%)<BR><BR>"
		var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(loc)
		P.name = "Artifact Analysis Report #[scan_num]"
		P.info = r
		for(var/mob/O in hearers(src, null))
			O.show_message("[bicon(src)] <span class='notice'>The [name] prints a sheet of paper.</span>")
		use_power(10)

	if(href_list["close"])
		usr << browse(null, "window=artanalyser")
		usr.machine = null

	updateDialog()

//stick artifacts onto this then switch the analyser on
/obj/machinery/analyser_pad
	name = "artifact analysis pad"
	desc = "Studies the structure of artifacts to discover their uses."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tele0"
	anchored = 1
	density = 0

/obj/machinery/analyser_pad/New()
	..()
	/*spawn(10)
		for(var/obj/machinery/artifact_analyser/analyser in orange(1))
			to_chat(world, "pad found analyser")
			if(!analyser.owned_pad)
				analyser.owned_pad = src
				to_chat(world, "pad set analyser to self")
				break*/
