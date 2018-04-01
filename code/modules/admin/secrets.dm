/datum/admins/proc/Secrets()
	if(!check_rights(0))
		return

	var/list/dat = list("<B>The first rule of adminbuse is: you don't talk about the adminbuse.</B><HR>")

	dat +={"
			<B>General Secrets</B><BR>
			<BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=list_job_debug'>Show Job Debug</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=admin_log'>Admin Log</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=show_admins'>Show Admin List</A><BR>
			<BR>
			"}

	if(check_rights(R_ADMIN,0))
		dat += {"
			<B>Admin Secrets</B><BR>
			<BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=clear_virus'>Cure all diseases currently in existence</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=list_bombers'>Bombing List</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=check_antagonist'>Show current traitors and objectives</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=list_signalers'>Show last [length(GLOB.lastsignalers)] signalers</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=list_lawchanges'>Show last [length(GLOB.lawchanges)] law changes</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=showailaws'>Show AI Laws</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=showgm'>Show Game Mode</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=manifest'>Show Crew Manifest</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=DNA'>List DNA (Blood)</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=fingerprints'>List Fingerprints</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=ctfbutton'>Enable/Disable CTF</A><BR><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=tdomereset'>Reset Thunderdome to default state</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=set_name'>Rename Station Name</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=reset_name'>Reset Station Name</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=night_shift_set'>Set Night Shift Mode</A><BR>
			<BR>
			<B>Shuttles</B><BR>
			<BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=moveferry'>Move Ferry</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=togglearrivals'>Toggle Arrivals Ferry</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=moveminingshuttle'>Move Mining Shuttle</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=movelaborshuttle'>Move Labor Shuttle</A><BR>
			<BR>
			"}

	if(check_rights(R_FUN,0))
		dat += {"
			<B>Fun Secrets</B><BR>
			<BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=virus'>Trigger a Virus Outbreak</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=monkey'>Turn all humans into monkeys</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=anime'>Chinese Cartoons</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=allspecies'>Change the species of all humans</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=power'>Make all areas powered</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=unpower'>Make all areas unpowered</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=quickpower'>Power all SMES</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=tripleAI'>Triple AI mode (needs to be used in the lobby)</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=traitor_all'>Everyone is the traitor</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=guns'>Summon Guns</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=magic'>Summon Magic</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=events'>Summon Events (Toggle)</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=onlyone'>There can only be one!</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=delayed_onlyone'>There can only be one! (40-second delay)</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=retardify'>Make all players retarded</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=eagles'>Egalitarian Station Mode</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=blackout'>Break all lights</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=whiteout'>Fix all lights</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=floorlava'>The floor is lava! (DANGEROUS: extremely lame)</A><BR>
			<BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=flipmovement'>Flip client movement directions</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=randommovement'>Randomize client movement directions</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=custommovement'>Set each movement direction manually</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=resetmovement'>Reset movement directions to default</A><BR>
			<BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=changebombcap'>Change bomb cap</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=masspurrbation'>Mass Purrbation</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=massremovepurrbation'>Mass Remove Purrbation</A><BR>
			"}

	dat += "<BR>"

	if(check_rights(R_DEBUG,0))
		dat += {"
			<B>Security Level Elevated</B><BR>
			<BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=maint_access_engiebrig'>Change all maintenance doors to engie/brig access only</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=maint_access_brig'>Change all maintenance doors to brig access only</A><BR>
			<A href='?src=[REF(src)];[HrefToken()];secrets=infinite_sec'>Remove cap on security officers</A><BR>
			<BR>
			"}

	usr << browse(dat.Join(), "window=secrets")
	return





/datum/admins/proc/Secrets_topic(item,href_list)
	var/datum/round_event/E
	var/ok = 0
	switch(item)
		if("admin_log")
			var/dat = "<B>Admin Log<HR></B>"
			for(var/l in GLOB.admin_log)
				dat += "<li>[l]</li>"
			if(!GLOB.admin_log.len)
				dat += "No-one has done anything this round!"
			usr << browse(dat, "window=admin_log")

		if("list_job_debug")
			var/dat = "<B>Job Debug info.</B><HR>"
			for(var/line in SSjob.job_debug)
				dat += "[line]<BR>"
			dat+= "*******<BR><BR>"
			for(var/datum/job/job in SSjob.occupations)
				if(!job)
					continue
				dat += "job: [job.title], current_positions: [job.current_positions], total_positions: [job.total_positions] <BR>"
			usr << browse(dat, "window=jobdebug;size=600x500")

		if("show_admins")
			var/dat = "<B>Current admins:</B><HR>"
			if(GLOB.admin_datums)
				for(var/ckey in GLOB.admin_datums)
					var/datum/admins/D = GLOB.admin_datums[ckey]
					dat += "[ckey] - [D.rank.name]<br>"
				usr << browse(dat, "window=showadmins;size=600x500")

		if("tdomereset")
			if(!check_rights(R_ADMIN))
				return
			var/delete_mobs = alert("Clear all mobs?","Confirm","Yes","No","Cancel")
			if(delete_mobs == "Cancel")
				return

			log_admin("[key_name(usr)] reset the thunderdome to default with delete_mobs==[delete_mobs].", 1)
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] reset the thunderdome to default with delete_mobs==[delete_mobs].</span>")

			var/area/thunderdome = locate(/area/tdome/arena)
			if(delete_mobs == "Yes")
				for(var/mob/living/mob in thunderdome)
					qdel(mob) //Clear mobs
			for(var/obj/obj in thunderdome)
				if(!istype(obj, /obj/machinery/camera))
					qdel(obj) //Clear objects

			var/area/template = locate(/area/tdome/arena_source)
			template.copy_contents_to(thunderdome)

		if("clear_virus")

			var/choice = input("Are you sure you want to cure all disease?") in list("Yes", "Cancel")
			if(choice == "Yes")
				message_admins("[key_name_admin(usr)] has cured all diseases.")
				for(var/thing in SSdisease.active_diseases)
					var/datum/disease/D = thing
					D.cure(0)
		if("set_name")
			if(!check_rights(R_ADMIN))
				return
			var/new_name = input(usr, "Please input a new name for the station.", "What?", "") as text|null
			if(!new_name)
				return
			set_station_name(new_name)
			log_admin("[key_name(usr)] renamed the station to \"[new_name]\".")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] renamed the station to: [new_name].</span>")
			priority_announce("[command_name()] has renamed the station to \"[new_name]\".")
		if("night_shift_set")
			if(!check_rights(R_ADMIN))
				return
			var/val = alert(usr, "What do you want to set night shift to? This will override the automatic system until set to automatic again.", "Night Shift", "On", "Off", "Automatic")
			switch(val)
				if("Automatic")
					if(CONFIG_GET(flag/enable_night_shifts))
						SSnightshift.can_fire = TRUE
						SSnightshift.fire()
					else
						SSnightshift.update_nightshift(FALSE, TRUE)
				if("On")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(TRUE, TRUE)
				if("Off")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(FALSE, TRUE)

		if("reset_name")
			if(!check_rights(R_ADMIN))
				return
			var/new_name = new_station_name()
			set_station_name(new_name)
			log_admin("[key_name(usr)] reset the station name.")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] reset the station name.</span>")
			priority_announce("[command_name()] has renamed the station to \"[new_name]\".")

		if("list_bombers")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Bombing List</B><HR>"
			for(var/l in GLOB.bombers)
				dat += text("[l]<BR>")
			usr << browse(dat, "window=bombers")

		if("list_signalers")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Showing last [length(GLOB.lastsignalers)] signalers.</B><HR>"
			for(var/sig in GLOB.lastsignalers)
				dat += "[sig]<BR>"
			usr << browse(dat, "window=lastsignalers;size=800x500")

		if("list_lawchanges")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Showing last [length(GLOB.lawchanges)] law changes.</B><HR>"
			for(var/sig in GLOB.lawchanges)
				dat += "[sig]<BR>"
			usr << browse(dat, "window=lawchanges;size=800x500")

		if("moveminingshuttle")
			if(!check_rights(R_ADMIN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send Mining Shuttle"))
			if(!SSshuttle.toggleShuttle("mining","mining_home","mining_away"))
				message_admins("[key_name_admin(usr)] moved mining shuttle")
				log_admin("[key_name(usr)] moved the mining shuttle")

		if("movelaborshuttle")
			if(!check_rights(R_ADMIN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send Labor Shuttle"))
			if(!SSshuttle.toggleShuttle("laborcamp","laborcamp_home","laborcamp_away"))
				message_admins("[key_name_admin(usr)] moved labor shuttle")
				log_admin("[key_name(usr)] moved the labor shuttle")

		if("moveferry")
			if(!check_rights(R_ADMIN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send CentCom Ferry"))
			if(!SSshuttle.toggleShuttle("ferry","ferry_home","ferry_away"))
				message_admins("[key_name_admin(usr)] moved the CentCom ferry")
				log_admin("[key_name(usr)] moved the CentCom ferry")

		if("togglearrivals")
			if(!check_rights(R_ADMIN))
				return
			var/obj/docking_port/mobile/arrivals/A = SSshuttle.arrivals
			if(A)
				var/new_perma = !A.perma_docked
				A.perma_docked = new_perma
				SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Permadock Arrivals Shuttle", "[new_perma ? "Enabled" : "Disabled"]"))
				message_admins("[key_name_admin(usr)] [new_perma ? "stopped" : "started"] the arrivals shuttle")
				log_admin("[key_name(usr)] [new_perma ? "stopped" : "started"] the arrivals shuttle")
			else
				to_chat(usr, "<span class='admin'>There is no arrivals shuttle</span>")
		if("showailaws")
			if(!check_rights(R_ADMIN))
				return
			output_ai_laws()
		if("showgm")
			if(!check_rights(R_ADMIN))
				return
			if(!SSticker.HasRoundStarted())
				alert("The game hasn't started yet!")
			else if (SSticker.mode)
				alert("The game mode is [SSticker.mode.name]")
			else alert("For some reason there's a SSticker, but not a game mode")
		if("manifest")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Showing Crew Manifest.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
			for(var/datum/data/record/t in GLOB.data_core.general)
				dat += "<tr><td>[t.fields["name"]]</td><td>[t.fields["rank"]]</td></tr>"
			dat += "</table>"
			usr << browse(dat, "window=manifest;size=440x410")
		if("DNA")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Showing DNA from blood.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				if(H.ckey)
					dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.dna.blood_type]</td></tr>"
			dat += "</table>"
			usr << browse(dat, "window=DNA;size=440x410")
		if("fingerprints")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Showing Fingerprints.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				if(H.ckey)
					dat += "<tr><td>[H]</td><td>[md5(H.dna.uni_identity)]</td></tr>"
			dat += "</table>"
			usr << browse(dat, "window=fingerprints;size=440x410")

		if("monkey")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Monkeyize All Humans"))
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				spawn(0)
					H.monkeyize()
			ok = 1

		if("allspecies")
			if(!check_rights(R_FUN))
				return
			var/result = input(usr, "Please choose a new species","Species") as null|anything in GLOB.species_list
			if(result)
				SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Species Change", "[result]"))
				log_admin("[key_name(usr)] turned all humans into [result]", 1)
				message_admins("\blue [key_name_admin(usr)] turned all humans into [result]")
				var/newtype = GLOB.species_list[result]
				for(var/mob/living/carbon/human/H in GLOB.carbon_list)
					H.set_species(newtype)

		if("tripleAI")
			if(!check_rights(R_FUN))
				return
			usr.client.triple_ai()
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Triple AI"))

		if("power")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Power All APCs"))
			log_admin("[key_name(usr)] made all areas powered", 1)
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] made all areas powered</span>")
			power_restore()

		if("unpower")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Depower All APCs"))
			log_admin("[key_name(usr)] made all areas unpowered", 1)
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] made all areas unpowered</span>")
			power_failure()

		if("quickpower")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Power All SMESs"))
			log_admin("[key_name(usr)] made all SMESs powered", 1)
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] made all SMESs powered</span>")
			power_restore_quick()

		if("traitor_all")
			if(!check_rights(R_FUN))
				return
			if(!SSticker.HasRoundStarted())
				alert("The game hasn't started yet!")
				return
			var/objective = copytext(sanitize(input("Enter an objective")),1,MAX_MESSAGE_LEN)
			if(!objective)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Traitor All", "[objective]"))
			for(var/mob/living/H in GLOB.player_list)
				if(!(ishuman(H)||istype(H, /mob/living/silicon/)))
					continue
				if(H.stat == DEAD || !H.client || !H.mind || ispAI(H))
					continue
				if(is_special_character(H))
					continue
				var/datum/antagonist/traitor/human/T = new()
				T.give_objectives = FALSE
				var/datum/objective/new_objective = new
				new_objective.owner = H
				new_objective.explanation_text = objective
				T.add_objective(new_objective)
				H.mind.add_antag_datum(T)
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] used everyone is a traitor secret. Objective is [objective]</span>")
			log_admin("[key_name(usr)] used everyone is a traitor secret. Objective is [objective]")

		if("changebombcap")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Bomb Cap"))

			var/newBombCap = input(usr,"What would you like the new bomb cap to be. (entered as the light damage range (the 3rd number in common (1,2,3) notation)) Must be above 4)", "New Bomb Cap", GLOB.MAX_EX_LIGHT_RANGE) as num|null
			if (!CONFIG_SET(number/bombcap, newBombCap))
				return

			message_admins("<span class='boldannounce'>[key_name_admin(usr)] changed the bomb cap to [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]</span>")
			log_admin("[key_name(usr)] changed the bomb cap to [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]")

		if("blackout")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Break All Lights"))
			message_admins("[key_name_admin(usr)] broke all lights")
			for(var/obj/machinery/light/L in GLOB.machines)
				L.break_light_tube()

		if("anime")
			if(!check_rights(R_FUN))
				return
			var/animetype = alert("Would you like to have the clothes be changed?",,"Yes","No","Cancel")

			var/droptype
			if(animetype =="Yes")
				droptype = alert("Make the uniforms Nodrop?",,"Yes","No","Cancel")

			if(animetype == "Cancel" || droptype == "Cancel")
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Chinese Cartoons"))
			message_admins("[key_name_admin(usr)] made everything kawaii.")
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				SEND_SOUND(H, sound('sound/ai/animes.ogg'))

				if(H.dna.species.id == "human")
					if(H.dna.features["tail_human"] == "None" || H.dna.features["ears"] == "None")
						var/obj/item/organ/ears/cat/ears = new
						var/obj/item/organ/tail/cat/tail = new
						ears.Insert(H, drop_if_replaced=FALSE)
						tail.Insert(H, drop_if_replaced=FALSE)
					var/list/honorifics = list("[MALE]" = list("kun"), "[FEMALE]" = list("chan","tan"), "[NEUTER]" = list("san")) //John Robust -> Robust-kun
					var/list/names = splittext(H.real_name," ")
					var/forename = names.len > 1 ? names[2] : names[1]
					var/newname = "[forename]-[pick(honorifics["[H.gender]"])]"
					H.fully_replace_character_name(H.real_name,newname)
					H.update_mutant_bodyparts()
					if(animetype == "Yes")
						var/seifuku = pick(typesof(/obj/item/clothing/under/schoolgirl))
						var/obj/item/clothing/under/schoolgirl/I = new seifuku
						var/olduniform = H.w_uniform
						H.temporarilyRemoveItemFromInventory(H.w_uniform, TRUE, FALSE)
						H.equip_to_slot_or_del(I, slot_w_uniform)
						qdel(olduniform)
						if(droptype == "Yes")
							I.flags_1 |= NODROP_1
				else
					to_chat(H, "You're not kawaii enough for this.")

		if("whiteout")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Fix All Lights"))
			message_admins("[key_name_admin(usr)] fixed all lights")
			for(var/obj/machinery/light/L in GLOB.machines)
				L.fix()

		if("floorlava")
			SSweather.run_weather(/datum/weather/floor_is_lava)

		if("virus")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Virus Outbreak"))
			switch(alert("Do you want this to be a random disease or do you have something in mind?",,"Make Your Own","Random","Choose"))
				if("Make Your Own")
					AdminCreateVirus(usr.client)
				if("Random")
					E = new /datum/round_event/disease_outbreak()
				if("Choose")
					var/virus = input("Choose the virus to spread", "BIOHAZARD") as null|anything in typesof(/datum/disease)
					E = new /datum/round_event/disease_outbreak{}()
					var/datum/round_event/disease_outbreak/DO = E
					DO.virus_type = virus

		if("retardify")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Braindamage"))
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				to_chat(H, "<span class='boldannounce'>You suddenly feel stupid.</span>")
				H.adjustBrainLoss(60, 80)
			message_admins("[key_name_admin(usr)] made everybody retarded")

		if("eagles")//SCRAW
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Egalitarian Station"))
			for(var/obj/machinery/door/airlock/W in GLOB.machines)
				if(is_station_level(W.z) && !istype(get_area(W), /area/bridge) && !istype(get_area(W), /area/crew_quarters) && !istype(get_area(W), /area/security/prison))
					W.req_access = list()
			message_admins("[key_name_admin(usr)] activated Egalitarian Station mode")
			priority_announce("CentCom airlock control override activated. Please take this time to get acquainted with your coworkers.", null, 'sound/ai/commandreport.ogg')

		if("guns")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Guns"))
			var/survivor_probability = 0
			switch(alert("Do you want this to create survivors antagonists?",,"No Antags","Some Antags","All Antags!"))
				if("Some Antags")
					survivor_probability = 25
				if("All Antags!")
					survivor_probability = 100

			rightandwrong(SUMMON_GUNS, usr, survivor_probability)

		if("magic")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Magic"))
			var/survivor_probability = 0
			switch(alert("Do you want this to create survivors antagonists?",,"No Antags","Some Antags","All Antags!"))
				if("Some Antags")
					survivor_probability = 25
				if("All Antags!")
					survivor_probability = 100

			rightandwrong(SUMMON_MAGIC, usr, survivor_probability)

		if("events")
			if(!check_rights(R_FUN))
				return
			if(!SSevents.wizardmode)
				if(alert("Do you want to toggle summon events on?",,"Yes","No") == "Yes")
					summonevents()
					SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Activate"))

			else
				switch(alert("What would you like to do?",,"Intensify Summon Events","Turn Off Summon Events","Nothing"))
					if("Intensify Summon Events")
						summonevents()
						SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Intensify"))
					if("Turn Off Summon Events")
						SSevents.toggleWizardmode()
						SSevents.resetFrequency()
						SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Disable"))

		if("dorf")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Dwarf Beards"))
			for(var/mob/living/carbon/human/B in GLOB.carbon_list)
				B.facial_hair_style = "Dward Beard"
				B.update_hair()
			message_admins("[key_name_admin(usr)] activated dorf mode")

		if("onlyone")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("There Can Be Only One"))
			usr.client.only_one()
			sound_to_playing_players('sound/misc/highlander.ogg')

		if("delayed_onlyone")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("There Can Be Only One"))
			usr.client.only_one_delayed()
			sound_to_playing_players('sound/misc/highlander_delayed.ogg')

		if("maint_access_brig")
			if(!check_rights(R_DEBUG))
				return
			for(var/obj/machinery/door/airlock/maintenance/M in GLOB.machines)
				M.check_access()
				if (ACCESS_MAINT_TUNNELS in M.req_access)
					M.req_access = list(ACCESS_BRIG)
			message_admins("[key_name_admin(usr)] made all maint doors brig access-only.")
		if("maint_access_engiebrig")
			if(!check_rights(R_DEBUG))
				return
			for(var/obj/machinery/door/airlock/maintenance/M in GLOB.machines)
				M.check_access()
				if (ACCESS_MAINT_TUNNELS in M.req_access)
					M.req_access = list()
					M.req_one_access = list(ACCESS_BRIG,ACCESS_ENGINE)
			message_admins("[key_name_admin(usr)] made all maint doors engineering and brig access-only.")
		if("infinite_sec")
			if(!check_rights(R_DEBUG))
				return
			var/datum/job/J = SSjob.GetJob("Security Officer")
			if(!J)
				return
			J.total_positions = -1
			J.spawn_positions = -1
			message_admins("[key_name_admin(usr)] has removed the cap on security officers.")

		if("ctfbutton")
			if(!check_rights(R_ADMIN))
				return
			toggle_all_ctf(usr)
		if("masspurrbation")
			if(!check_rights(R_FUN))
				return
			mass_purrbation()
			message_admins("[key_name_admin(usr)] has put everyone on \
				purrbation!")
			log_admin("[key_name(usr)] has put everyone on purrbation.")
		if("massremovepurrbation")
			if(!check_rights(R_FUN))
				return
			mass_remove_purrbation()
			message_admins("[key_name_admin(usr)] has removed everyone from \
				purrbation.")
			log_admin("[key_name(usr)] has removed everyone from purrbation.")

		if("flipmovement")
			if(!check_rights(R_FUN))
				return
			if(alert("Flip all movement controls?","Confirm","Yes","Cancel") == "Cancel")
				return
			var/list/movement_keys = SSinput.movement_keys
			for(var/i in 1 to movement_keys.len)
				var/key = movement_keys[i]
				movement_keys[key] = turn(movement_keys[key], 180)
			message_admins("[key_name_admin(usr)] has flipped all movement directions.")
			log_admin("[key_name(usr)] has flipped all movement directions.")

		if("randommovement")
			if(!check_rights(R_FUN))
				return
			if(alert("Randomize all movement controls?","Confirm","Yes","Cancel") == "Cancel")
				return
			var/list/movement_keys = SSinput.movement_keys
			for(var/i in 1 to movement_keys.len)
				var/key = movement_keys[i]
				movement_keys[key] = turn(movement_keys[key], 45 * rand(1, 8))
			message_admins("[key_name_admin(usr)] has randomized all movement directions.")
			log_admin("[key_name(usr)] has randomized all movement directions.")

		if("custommovement")
			if(!check_rights(R_FUN))
				return
			if(alert("Are you sure you want to change every movement key?","Confirm","Yes","Cancel") == "Cancel")
				return
			var/list/movement_keys = SSinput.movement_keys
			var/list/new_movement = list()
			for(var/i in 1 to movement_keys.len)
				var/key = movement_keys[i]

				var/msg = "Please input the new movement direction when the user presses [key]. Ex. northeast"
				var/title = "New direction for [key]"
				var/new_direction = text2dir(input(usr, msg, title) as text|null)
				if(!new_direction)
					new_direction = movement_keys[key]

				new_movement[key] = new_direction
			SSinput.movement_keys = new_movement
			message_admins("[key_name_admin(usr)] has configured all movement directions.")
			log_admin("[key_name(usr)] has configured all movement directions.")

		if("resetmovement")
			if(!check_rights(R_FUN))
				return
			if(alert("Are you sure you want to reset movement keys to default?","Confirm","Yes","Cancel") == "Cancel")
				return
			SSinput.setup_default_movement_keys()
			message_admins("[key_name_admin(usr)] has reset all movement keys.")
			log_admin("[key_name(usr)] has reset all movement keys.")

	if(E)
		E.processing = FALSE
		if(E.announceWhen>0)
			if(alert(usr, "Would you like to alert the crew?", "Alert", "Yes", "No") == "No")
				E.announceWhen = -1
		E.processing = TRUE
	if (usr)
		log_admin("[key_name(usr)] used secret [item]")
		if (ok)
			to_chat(world, text("<B>A secret has been activated by []!</B>", usr.key))
