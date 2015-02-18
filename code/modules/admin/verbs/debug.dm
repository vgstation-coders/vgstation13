/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!check_rights(R_DEBUG))	return

	if(Debug2)
		Debug2 = 0
		message_admins("[key_name(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		Debug2 = 1
		message_admins("[key_name(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")

	feedback_add_details("admin_verb","DG2") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/Dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"

	if(!check_rights(R_DEBUG)) return

	spawn(0)
		var/target = null
		var/targetselected = 0
		var/lst[] // List reference
		lst = new/list() // Make the list
		var/returnval = null
		var/class = null

		switch(alert("Proc owned by something?",,"Yes","No"))
			if("Yes")
				targetselected = 1
				class = input("Proc owned by...","Owner",null) as null|anything in list("Obj","Mob","Area or Turf","Client")
				switch(class)
					if("Obj")
						target = input("Enter target:","Target",usr) as obj in world
					if("Mob")
						target = input("Enter target:","Target",usr) as mob in world
					if("Area or Turf")
						target = input("Enter target:","Target",usr.loc) as area|turf in world
					if("Client")
						var/list/keys = list()
						for(var/client/C)
							keys += C
						target = input("Please, select a player!", "Selection", null, null) as null|anything in keys
					else
						return
			if("No")
				target = null
				targetselected = 0

		var/procname = input("Proc path, eg: /proc/fake_blood","Path:", null) as text|null
		if(!procname)	return

		var/argnum = input("Number of arguments","Number:",0) as num|null
		if(!argnum && (argnum!=0))	return

		lst.len = argnum // Expand to right length
		//TODO: make a list to store whether each argument was initialised as null.
		//Reason: So we can abort the proccall if say, one of our arguments was a mob which no longer exists
		//this will protect us from a fair few errors ~Carn

		var/i
		for(i=1, i<argnum+1, i++) // Lists indexed from 1 forwards in byond

			// Make a list with each index containing one variable, to be given to the proc
			class = input("What kind of variable?","Variable Type") in list("text","num","type","reference","mob reference","icon","file","client","mob's area","CANCEL")
			switch(class)
				if("CANCEL")
					return

				if("text")
					lst[i] = input("Enter new text:","Text",null) as text

				if("num")
					lst[i] = input("Enter new number:","Num",0) as num

				if("type")
					lst[i] = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

				if("reference")
					lst[i] = input("Select reference:","Reference",src) as mob|obj|turf|area in world

				if("mob reference")
					lst[i] = input("Select reference:","Reference",usr) as mob in world

				if("file")
					lst[i] = input("Pick file:","File") as file

				if("icon")
					lst[i] = input("Pick icon:","Icon") as icon

				if("client")
					var/list/keys = list()
					for(var/mob/M in world)
						keys += M.client
					lst[i] = input("Please, select a player!", "Selection", null, null) as null|anything in keys

				if("mob's area")
					var/mob/temp = input("Select mob", "Selection", usr) as mob in world
					lst[i] = temp.loc

		if(targetselected)
			if(!target)
				usr << "<font color='red'>Error: callproc(): owner of proc no longer exists.</font>"
				return
			if(!hascall(target,procname))
				usr << "<font color='red'>Error: callproc(): target has no such call [procname].</font>"
				return
			log_admin("[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(target,procname)(arglist(lst)) // Pass the lst as an argument list to the proc
		else
			//this currently has no hascall protection. wasn't able to get it working.
			log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(procname)(arglist(lst)) // Pass the lst as an argument list to the proc

		usr << "<font color='blue'>[procname] returned: [returnval ? returnval : "null"]</font>"
		feedback_add_details("admin_verb","APC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/Cell()
	set category = "Debug"
	set name = "Air Status in Location"
	if(!mob)
		return
	var/turf/T = mob.loc

	if (!( istype(T, /turf) ))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = ""

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\verbs\debug.dm:145: t+= "Nitrogen : [env.nitrogen]\n"
	t += {"Nitrogen : [env.nitrogen]
Oxygen : [env.oxygen]
Plasma : [env.toxins]
CO2: [env.carbon_dioxide]
Pressure: [env.return_pressure()]"}
	// END AUTOFIX
	usr.show_message(t, 1)
	feedback_add_details("admin_verb","ASL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		alert("Invalid mob")

/client/proc/cmd_admin_mommify(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make MoMMI"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has MoMMIfied [M.key].")
		spawn(10)
			M:MoMMIfy()

	else
		alert("Invalid mob")

/client/proc/cmd_admin_animalize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(!ticker)
		alert("Wait until the game starts")
		return

	if(!M)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(istype(M, /mob/new_player))
		alert("The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(10)
		M.Animalize()


/client/proc/makepAI(var/turf/T in mob_list)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	var/list/available = list()
	for(var/mob/C in mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = input("Choose a player to play the pAI", "Spawn pAI") in available
	if(!choice)
		return 0
	if(!istype(choice, /mob/dead/observer))
		var/confirm = input("[choice.key] isn't ghosting right now. Are you sure you want to yank him out of them out of their body and place them in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return 0
	var/obj/item/device/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)
	pai.name = input(choice, "Enter your pAI name:", "pAI Name", "Personal AI") as text
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/paiCandidate/candidate in paiController.pai_candidates)
		if(candidate.key == choice.key)
			paiController.pai_candidates.Remove(candidate)
	feedback_add_details("admin_verb","MPAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_alienize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Alien"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has alienized [M.key].")
		spawn(10)
			M:Alienize()
			feedback_add_details("admin_verb","MKAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into an alien.")
		message_admins("\blue [key_name_admin(usr)] made [key_name(M)] into an alien.", 1)
	else
		alert("Invalid mob")

/client/proc/cmd_admin_slimeize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make slime"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has slimeized [M.key].")
		spawn(10)
			M:slimeize()
			feedback_add_details("admin_verb","MKMET") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into a slime.")
		message_admins("\blue [key_name_admin(usr)] made [key_name(M)] into a slime.", 1)
	else
		alert("Invalid mob")

/*
/client/proc/cmd_admin_monkeyize(var/mob/M in world)
	set category = "Fun"
	set name = "Make Monkey"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/target = M
		log_admin("[key_name(src)] is attempting to monkeyize [M.key].")
		spawn(10)
			target.monkeyize()
	else
		alert("Invalid mob")

/client/proc/cmd_admin_changelinginize(var/mob/M in world)
	set category = "Fun"
	set name = "Make Changeling"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] a changeling.")
		spawn(10)
			M.absorbed_dna[M.real_name] = M.dna.Clone()
			M.make_changeling()
			if(M.mind)
				M.mind.special_role = "Changeling"
	else
		alert("Invalid mob")
*/
/*
/client/proc/cmd_admin_abominize(var/mob/M in world)
	set category = null
	set name = "Make Abomination"

	usr << "Ruby Mode disabled. Command aborted."
	return
	if(!ticker)
		alert("Wait until the game starts.")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] an abomination.")

	//	spawn(10)
	//		M.make_abomination()

*/
/*
/client/proc/make_cultist(var/mob/M in world) // -- TLE, modified by Urist
	set category = "Fun"
	set name = "Make Cultist"
	set desc = "Makes target a cultist"
	if(!cultwords["travel"])
		runerandom()
	if(M)
		if(M.mind in ticker.mode.cult)
			return
		else
			if(alert("Spawn that person a tome?",,"Yes","No")=="Yes")
				M << "\red You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie. A tome, a message from your new master, appears on the ground."
				new /obj/item/weapon/tome(M.loc)
			else
				M << "\red You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie."
			var/glimpse=pick("1","2","3","4","5","6","7","8")
			switch(glimpse)
				if("1")
					M << "\red You remembered one thing from the glimpse... [cultwords["travel"]] is travel..."
				if("2")
					M << "\red You remembered one thing from the glimpse... [cultwords["blood"]] is blood..."
				if("3")
					M << "\red You remembered one thing from the glimpse... [cultwords["join"]] is join..."
				if("4")
					M << "\red You remembered one thing from the glimpse... [cultwords["hell"]] is Hell..."
				if("5")
					M << "\red You remembered one thing from the glimpse... [cultwords["destroy"]] is destroy..."
				if("6")
					M << "\red You remembered one thing from the glimpse... [cultwords["technology"]] is technology..."
				if("7")
					M << "\red You remembered one thing from the glimpse... [cultwords["self"]] is self..."
				if("8")
					M << "\red You remembered one thing from the glimpse... [cultwords["see"]] is see..."

			if(M.mind)
				M.mind.special_role = "Cultist"
				ticker.mode.cult += M.mind
			src << "Made [M] a cultist."
*/

//TODO: merge the vievars version into this or something maybe mayhaps
/client/proc/cmd_debug_del_all()
	set category = "Debug"
	set name = "Del-All"

	// to prevent REALLY stupid deletions
	var/blocked = list(/obj, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/human, /mob/dead, /mob/dead/observer, /mob/living/silicon, /mob/living/silicon/robot, /mob/living/silicon/ai)
	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in typesof(/obj) + typesof(/mob) - blocked
	if(hsbitem)
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				del(O)
		log_admin("[key_name(src)] has deleted all instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all instances of [hsbitem].", 0)
	feedback_add_details("admin_verb","DELA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.", 0)
	feedback_add_details("admin_verb","MPWN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_tog_aliens()
	set category = "Server"
	set name = "Toggle Aliens"

	aliens_allowed = !aliens_allowed
	log_admin("[key_name(src)] has turned aliens [aliens_allowed ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned aliens [aliens_allowed ? "on" : "off"].", 0)
	feedback_add_details("admin_verb","TAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Grant Full Access"

	if (!ticker)
		alert("Wait until the game starts")
		return
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if (H.wear_id)
			var/obj/item/weapon/card/id/id = H.wear_id
			if(istype(H.wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = H.wear_id
				id = pda.id
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		else
			var/obj/item/weapon/card/id/id = new/obj/item/weapon/card/id(M);
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.name = "[id.registered_name]'s ID Card ([id.assignment])"
			H.equip_to_slot_or_del(id, slot_wear_id)
			H.update_inv_wear_id()
	else
		alert("Invalid mob")
	feedback_add_details("admin_verb","GFA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins("\blue [key_name_admin(usr)] has granted [M.key] full access.", 1)

/client/proc/cmd_assume_direct_control(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(!check_rights(R_DEBUG|R_ADMIN))	return
	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
	message_admins("\blue [key_name_admin(usr)] assumed direct control of [M].", 1)
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = src.mob
	M.ckey = src.ckey
	if( isobserver(adminmob) )
		del(adminmob)
	feedback_add_details("admin_verb","ADC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_areatest()
	set category = "Mapping"
	set name = "Test areas"

	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()

	for(var/area/A in world)
		if(!(A.type in areas_all))
			areas_all.Add(A.type)

	for(var/obj/machinery/power/apc/APC in world)
		var/area/A = get_area(APC)
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)

	for(var/obj/machinery/alarm/alarm in world)
		var/area/A = get_area(alarm)
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)

	for(var/obj/machinery/requests_console/RC in world)
		var/area/A = get_area(RC)
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)

	for(var/obj/machinery/light/L in world)
		var/area/A = get_area(L)
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)

	for(var/obj/machinery/light_switch/LS in world)
		var/area/A = get_area(LS)
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)

	for(var/obj/item/device/radio/intercom/I in world)
		var/area/A = get_area(I)
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)

	for(var/obj/machinery/camera/C in world)
		var/area/A = get_area(C)
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	world << "<b>AREAS WITHOUT AN APC:</b>"
	for(var/areatype in areas_without_APC)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT AN AIR ALARM:</b>"
	for(var/areatype in areas_without_air_alarm)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT A REQUEST CONSOLE:</b>"
	for(var/areatype in areas_without_RC)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT ANY LIGHTS:</b>"
	for(var/areatype in areas_without_light)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT A LIGHT SWITCH:</b>"
	for(var/areatype in areas_without_LS)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT ANY INTERCOMS:</b>"
	for(var/areatype in areas_without_intercom)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT ANY CAMERAS:</b>"
	for(var/areatype in areas_without_camera)
		world << "* [areatype]"

/client/proc/cmd_admin_dress(var/mob/living/carbon/human/M in mob_list)
	set category = "Fun"
	set name = "Select equipment"
	if(!ishuman(M))
		alert("Invalid mob")
		return
	//log_admin("[key_name(src)] has alienized [M.key].")
	var/list/dresspacks = list(
		"strip",
		"Engineer RIG",
		"CE RIG",
		"Mining RIG",
		"Syndi RIG",
		"Wizard RIG",
		"Medical RIG",
		"Atmos RIG",
		"standard space gear",
		"tournament standard red",
		"tournament standard green",
		"tournament gangster",
		"tournament chef",
		"tournament janitor",
		"pirate",
		"space pirate",
		"soviet admiral",
		"tunnel clown",
		"masked killer",
		"assassin",
		"death commando",
		"syndicate commando",
		"special ops officer",
		"blue wizard",
		"red wizard",
		"marisa wizard",
		"emergency rescue team",
		"nanotrasen representative",
		"nanotrasen officer",
		"nanotrasen captain"
		)
	var/dostrip = input("Do you want to strip [M] before equipping them? (0=no, 1=yes)", "STRIPTEASE") as null|anything in list(0,1)
	if(isnull(dostrip))
		return
	var/dresscode = input("Select dress for [M]", "Robust quick dress shop") as null|anything in dresspacks
	if (isnull(dresscode))
		return
	feedback_add_details("admin_verb","SEQ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	if(dostrip)
		for (var/obj/item/I in M)
			if (istype(I, /obj/item/weapon/implant))
				continue
			del(I)
	switch(dresscode)
		if ("strip")
			//do nothing
		if ("standard space gear")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)

			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space(M), slot_head)
			var /obj/item/weapon/tank/jetpack/J = new /obj/item/weapon/tank/jetpack/oxygen(M)
			M.equip_to_slot_or_del(J, slot_back)
			J.toggle()
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(M), slot_wear_mask)
			J.Topic(null, list("stat" = 1))
		if ("Engineer RIG","CE RIG","Mining RIG","Syndi RIG","Wizard RIG","Medical RIG","Atmos RIG")
			if(dresscode=="Engineer RIG")
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig(M), slot_head)
			else if(dresscode=="CE RIG")
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/elite(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/elite(M), slot_head)
			else if(dresscode=="Mining RIG")
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/mining(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/mining(M), slot_head)
			else if(dresscode=="Syndi RIG")
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/syndi(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/syndi(M), slot_head)
			else if(dresscode=="Wizard RIG")
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/wizard(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/wizard(M), slot_head)
			else if(dresscode=="Medical RIG")
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/medical(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/medical(M), slot_head)
			else if(dresscode=="Atmos RIG")
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/atmos(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/atmos(M), slot_head)
			var /obj/item/weapon/tank/jetpack/J = new /obj/item/weapon/tank/jetpack/oxygen(M)
			M.equip_to_slot_or_del(J, slot_back)
			J.toggle()
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(M), slot_wear_mask)
			J.Topic(null, list("stat" = 1))

		if ("tournament standard red","tournament standard green") //we think stunning weapon is too overpowered to use it on tournaments. --rastaf0
			if (dresscode=="tournament standard red")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/red(M), slot_w_uniform)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/green(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)

			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/thunderdome(M), slot_head)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/utensil/knife/large(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/smokebomb(M), slot_r_store)


		if ("tournament gangster") //gangster are supposed to fight each other. --rastaf0
			M.equip_to_slot_or_del(new /obj/item/clothing/under/det(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)

			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/det_suit(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/det_hat(M), slot_head)

			M.equip_to_slot_or_del(new /obj/item/weapon/cloaking_device(M), slot_r_store)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/ammo_storage/box/a357(M), slot_l_store)

		if ("tournament chef") //Steven Seagal FTW
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chef(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/chef(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/chefhat(M), slot_head)

			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/rollingpin(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/utensil/knife/large(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/utensil/knife/large(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/utensil/knife/large(M), slot_s_store)

		if ("tournament janitor")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/janitor(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			var/obj/item/weapon/storage/backpack/backpack = new(M)
			for(var/obj/item/I in backpack)
				del(I)
			M.equip_to_slot_or_del(backpack, slot_back)

			M.equip_to_slot_or_del(new /obj/item/weapon/mop(M), slot_r_hand)
			var/obj/item/weapon/reagent_containers/glass/bucket/bucket = new(M)
			bucket.reagents.add_reagent("water", 70)
			M.equip_to_slot_or_del(bucket, slot_l_hand)

			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/chem_grenade/cleaner(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/chem_grenade/cleaner(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)

		if ("pirate")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(M), slot_r_hand)

		if ("space pirate")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/pirate(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/pirate(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(M), slot_r_hand)

		if ("soviet soldier")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(M), slot_head)

		if("tunnel clown")//Tunnel clowns rule!
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/chaplain_hood(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/chaplain_hoodie(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(M), slot_r_store)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.assignment = "Tunnel Clown!"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/weapon/fire_axe = new(M)
			M.equip_to_slot_or_del(fire_axe, slot_r_hand)

		if("masked killer")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/overalls(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/latex(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/welding(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/utensil/knife/large(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/scalpel(M), slot_r_store)

			var/obj/item/weapon/fire_axe = new(M)
			M.equip_to_slot_or_del(fire_axe, slot_r_hand)

			for(var/obj/item/carried_item in M.contents)
				if(!istype(carried_item, /obj/item/weapon/implant))//If it's not an implant.
					carried_item.add_blood(M)//Oh yes, there will be blood...

		if("assassin")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wcoat(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/cloaking_device(M), slot_r_store)

			var/obj/item/weapon/storage/secure/briefcase/sec_briefcase = new(M)
			for(var/obj/item/briefcase_item in sec_briefcase)
				del(briefcase_item)
			for(var/i=3, i>0, i--)
				sec_briefcase.contents += new /obj/item/weapon/spacecash/c1000
			sec_briefcase.contents += new /obj/item/weapon/gun/energy/crossbow
			sec_briefcase.contents += new /obj/item/weapon/gun/projectile/mateba
			sec_briefcase.contents += new /obj/item/ammo_storage/box/a357
			sec_briefcase.contents += new /obj/item/weapon/plastique
			M.equip_to_slot_or_del(sec_briefcase, slot_l_hand)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Reaper"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/syndicate/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.assignment = "Reaper"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("death commando")//Was looking to add this for a while.
			M.equip_death_commando()

		if("syndicate commando")
			M.equip_syndicate_commando()

		if("nanotrasen representative")
			M.equip_if_possible(new /obj/item/clothing/under/rank/centcom/representative(M), slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/centcom(M), slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/white(M), slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset/heads/hop(M), slot_ears)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "NanoTrasen Navy Representative"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_if_possible(pda, slot_r_store)
			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), slot_l_store)
			M.equip_if_possible(new /obj/item/weapon/clipboard(M), slot_belt)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.item_state = "id_inv"
			W.access = get_all_accesses()
			W.access += list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Death Commando","Research Officer")
			W.assignment = "NanoTrasen Navy Representative"
			W.registered_name = M.real_name
			M.equip_if_possible(W, slot_wear_id)

		if("nanotrasen officer")
			M.equip_if_possible(new /obj/item/clothing/under/rank/centcom/officer(M), slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/centcom(M), slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/white(M), slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset/heads/captain(M), slot_ears)
			M.equip_if_possible(new /obj/item/clothing/head/beret/centcom/officer(M), slot_head)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "NanoTrasen Navy Officer"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_if_possible(pda, slot_r_store)
			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), slot_l_store)
			M.equip_if_possible(new /obj/item/weapon/gun/energy(M), slot_belt)

			var/obj/item/weapon/card/id/centcom/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "NanoTrasen Navy Officer"
			W.registered_name = M.real_name
			M.equip_if_possible(W, slot_wear_id)


		if("nanotrasen captain")
			M.equip_if_possible(new /obj/item/clothing/under/rank/centcom/captain(M), slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/centcom(M), slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/white(M), slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset/heads/captain(M), slot_ears)
			M.equip_if_possible(new /obj/item/clothing/head/beret/centcom/captain(M), slot_head)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "NanoTrasen Navy Captain"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_if_possible(pda, slot_r_store)
			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), slot_l_store)
			M.equip_if_possible(new /obj/item/weapon/gun/energy(M), slot_belt)

			var/obj/item/weapon/card/id/centcom/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "NanoTrasen Navy Captain"
			W.registered_name = M.real_name
			M.equip_if_possible(W, slot_wear_id)

		if("emergency rescue team")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/ert(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Emergency Response Team"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("special ops officer")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate/combat(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/swat/officer(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/havana(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/beret/centcom(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse_rifle/M1911(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/weapon/lighter/zippo(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Special Operations Officer"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("blue wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/spellbook(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/staff(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)

		if("red wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/spellbook(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/staff(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)

		if("marisa wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/marisa(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/marisa(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/marisa(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/spellbook(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/staff(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)
		if("soviet admiral")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/hgpiratecap(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/hgpirate(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/mateba(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), slot_w_uniform)
			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Admiral"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

	M.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("\blue [key_name_admin(usr)] changed the equipment of [key_name_admin(M)] to [dresscode]..", 1)
	return

/client/proc/startSinglo()

	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing through the station"

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	log_admin("[key_name(usr)] set up the singulo.")
	message_admins("\blue [key_name_admin(usr)] set up the singulo.", 1)

	for(var/obj/machinery/power/emitter/E in world)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field_generator/F in world)
		if(F.anchored)
			F.Varedit_start = 1
	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in world)
			if(G.anchored)
				var/obj/machinery/singularity/S = new /obj/machinery/singularity(get_turf(G), 50)
				spawn(0)
					del(G)
				S.energy = 1750
				S.current_size = 7
				S.icon = 'icons/effects/224x224.dmi'
				S.icon_state = "singularity_s7"
				S.pixel_x = -96
				S.pixel_y = -96
				S.grav_pull = 0
				//S.consume_range = 3
				S.dissipate = 0
				//S.dissipate_delay = 10
				//S.dissipate_track = 0
				//S.dissipate_strength = 10

	for(var/obj/machinery/power/rad_collector/Rad in world)
		if(Rad.anchored)
			if(!Rad.P)
				var/obj/item/weapon/tank/plasma/Plasma = new/obj/item/weapon/tank/plasma(Rad)
				Plasma.air_contents.toxins = 70
				Rad.drain_ratio = 0
				Rad.P = Plasma
				Plasma.loc = Rad

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in world)
		if(SMES.anchored)
			SMES.connect_to_network() // Just in case.
			SMES.chargemode = 1
			SMES.online=1

/client/proc/cheat_power()

	set category = "Debug"
	set name = "Free Power"
	set desc = "Replaces all SMES on the map with magical ones."

	if(alert("Are you sure? This will completely fuck over your round!",,"Yes","No") != "Yes")
		return

	log_admin("[key_name(usr)] haxed the powergrid with magic SMES.")
	message_admins("\blue [key_name_admin(usr)] haxed the powergrid with magic SMES.", 1)

	for(var/obj/machinery/power/smes/SMES in world)
		var/turf/T=SMES.loc
		del(SMES)
		var/obj/machinery/power/smes/magical/magic = new(T)
		// Manually set up our powernets since stupid seems to reign in the powernet code.
		magic.connect_to_network()
		magic.output=200000 // AKA rape
		magic.online=1

	//world << "<b>LET THERE BE JUICE</b>"


// Getting tired of doing this shit every fucking round when I'm testing something atmos-related
/client/proc/setup_atmos()

	set category = "Debug"
	set name = "Start Atmos"
	set desc = "WOW ATMOS DID THEIR JOBS!!!1"

	if(alert("Are you sure? This will completely fuck over your round!",,"Yes","No") != "Yes")
		return

	log_admin("[key_name(usr)] haxed atmos.")
	message_admins("\blue [key_name_admin(usr)] haxed atmos.", 1)

	for(var/obj/machinery/atmospherics/binary/pump/P in world)
		//if(p.name == "Air to Distro")
		P.target_pressure=4500
	for(var/obj/machinery/atmospherics/unary/vent_pump/high_volume/P in world)
		if(P.id_tag=="air_out")
			P.internal_pressure_bound=4500
	for(var/obj/machinery/atmospherics/trinary/filter/F in world)
		F.target_pressure=4500

	//world << "<b>LET THERE BE AIR</b>"


/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs", "Clients"))
		if("Players")
			usr << list2text(player_list,",")
		if("Admins")
			usr << list2text(admins,",")
		if("Mobs")
			usr << list2text(mob_list,",")
		if("Living Mobs")
			usr << list2text(living_mob_list,",")
		if("Dead Mobs")
			usr << list2text(dead_mob_list,",")
		if("Clients")
			usr << list2text(clients,",")


/client/proc/cmd_admin_toggle_block(var/mob/M,var/block)
	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon))
		M.dna.SetSEState(block,!M.dna.GetSEState(block))
		genemutcheck(M,block,null,MUTCHK_FORCED)
		M.update_mutations()
		var/state="[M.dna.GetSEState(block)?"on":"off"]"
		var/blockname=assigned_blocks[block]
		message_admins("[key_name_admin(src)] has toggled [M.key]'s [blockname] block [state]!")
		log_admin("[key_name(src)] has toggled [M.key]'s [blockname] block [state]!")
	else
		alert("Invalid mob")


/client/proc/cmd_admin_dump_instances()
	set category = "Debug"
	set name = "Dump Instance Counts"
	set desc = "MEMORY PROFILING IS TOO HIGH TECH"
	var/date_string = time2text(world.realtime, "YYYY-MM-DD")
	var/F=file("data/logs/profiling/[date_string]_instances.csv")
	fdel(F)
	F << "Types,Number of Instances"
	for(var/key in type_instances)
		F << "[key],[type_instances[key]]"

	usr << "\blue Dumped to [F]"

#ifdef PROFILE_MACHINES
/client/proc/cmd_admin_dump_macprofile()
	set category = "Debug"
	set name = "Dump Machine and Object Profiling"

	var/date_string = time2text(world.realtime, "YYYY-MM-DD")
	var/F =file("data/logs/profiling/[date_string]_machine_profiling.csv")
	fdel(F)
	F << "type,nanoseconds"
	for(var/typepath in machine_profiling)
		var/ns = machine_profiling[typepath]
		F << "[typepath],[ns]"

	usr << "\blue Dumped to [F]"
	var/FF = file("data/logs/profiling/[date_string]_object_profiling.csv")
	fdel(FF)
	FF << "type,nanoseconds"
	for(var/typepath in object_profiling)
		var/ns = object_profiling[typepath]
		FF << "[typepath],[ns]"

	usr << "\blue Dumped to [FF]."


/client/proc/cmd_admin_dump_machine_type_list()
	set category = "Debug"
	set name = "Dump Machine type list"

	if(!machines.len && !power_machines.len)
		usr << "Machines has no length!"
		return
	var/date_string = time2text(world.realtime, "YYYY-MM-DD")
	var/F =file("data/logs/profiling/[date_string]_machine_instances.csv")
	fdel(F)
	F << "type,count"
	var/list/machineinstances = list()
	for(var/atom/typepath in machines)
		if(!typepath.type in machineinstances)
			machineinstances["[typepath.type]"] = 0
		machineinstances["[typepath.type]"] += 1
	for(var/T in machineinstances)
		var/count = machineinstances[T]
		F << "[T],[count]"

	usr << "\blue Dumped to [F]."
	F =file("data/logs/profiling/[date_string]_power_machine_instances.csv")
	fdel(F)
	F << "type,count"
	machineinstances.len = 0
	for(var/atom/typepath in power_machines)
		if(!typepath.type in machineinstances)
			machineinstances["[typepath.type]"] = 0
		machineinstances["[typepath.type]"] += 1
	for(var/T in machineinstances)
		var/count = machineinstances[T]
		F << "[T],[count]"

	usr << "\blue Dumped to [F]."
#endif

/client/proc/cmd_admin_dump_delprofile()
	set category = "Debug"
	set name = "Dump Del Profiling"

	var/date_string = time2text(world.realtime, "YYYY-MM-DD")
	var/F =file("data/logs/profiling/[date_string]_del_profiling.csv")
	fdel(F)
	F << "type,deletes"
	for(var/typepath in del_profiling)
		var/ns = del_profiling[typepath]
		F << "[typepath],[ns]"

	usr << "\blue Dumped to [F]."
	F =file("data/logs/profiling/[date_string]_gdel_profiling.csv")
	fdel(F)
	F << "type,soft deletes"
	for(var/typepath in gdel_profiling)
		var/ns = gdel_profiling[typepath]
		F << "[typepath],[ns]"

	usr << "\blue Dumped to [F]."

	F =file("data/logs/profiling/[date_string]_ghdel_profiling.csv")
	fdel(F)
	F << "type,hard deletes"
	for(var/typepath in ghdel_profiling)
		var/ns = ghdel_profiling[typepath]
		F << "[typepath],[ns]"

	usr << "\blue Dumped to [F]."

/client/proc/gib_money()
	set category = "Fun"
	set name = "Dispense Money"
	set desc = "Honk"

	var/response = input(src,"How much moneys?") as num
	if( response < 1) return
	dispense_cash(response, mob.loc)

var/global/blood_virus_spreading_disabled = 0
/client/proc/disable_bloodvirii()
	set category = "Debug"
	set name = "Disable Blood Virus Spreading"

	//usr << "\red Proc disabled."

	blood_virus_spreading_disabled = !blood_virus_spreading_disabled
	if(blood_virus_spreading_disabled)
		message_admins("[src.ckey] disabled findAirborneVirii.")
	else
		message_admins("[src.ckey] enabled findAirborneVirii.")

/client/proc/reload_style_sheet()
	set category = "Server"
	set name = "Reload Style Sheet"
	set desc = "Reload the Style Sheet (be careful)."

	for(var/client/C in clients)
		winset(C, null, "outputwindow.output.style=[config.world_style_config];")
	message_admins("The style sheet has been reloaded by [src.ckey]")

/client/proc/reset_style_sheet()
	set category = "Server"
	set name = "Reset Style Sheet"
	set desc = "Reset the Style Sheet (restore to default)."

	for(var/client/C in clients)
		winset(C, null, "outputwindow.output.style=[world_style];")
	config.world_style_config = world_style
	message_admins("The style sheet has been reset by [src.ckey]")

/client/proc/cmd_admin_cluwneize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Cluwne"
	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		M:Cluwneize()
		message_admins("\blue [key_name_admin(usr)] made [key_name(M)] into a cluwne.", 1)
		feedback_add_details("admin_verb","MKCLU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(src)] has cluwne-ified [M.key].")
	else
		alert("Invalid mob, needs to be a human.")

client/proc/make_invulnerable(var/mob/M in mob_list)
	set name = "Toggle Invulnerability"
	set desc = "Make the target atom invulnerable to all form of damage."
	set category = "Fun"

	var/isinvuln = 0
	if(M.flags & INVULNERABLE)
		isinvuln = 1

	switch(isinvuln)
		if(0)
			if(alert(usr, "Make the target atom invulnerable to all form of damage?", "Toggle Invulnerability", "Yes", "No") != "Yes")
				return

			M.flags |= INVULNERABLE
		if(1)
			if(alert(usr, "Make the target atom vulnerable again?", "Toggle Invulnerability", "Yes", "No") != "Yes")
				return

			M.flags &= ~INVULNERABLE
	log_admin("[ckey(key)]/([mob]) has toggled [M]'s invulnerability [(M.flags & INVULNERABLE) ? "on" : "off"]")
	message_admins("[ckey(key)]/([mob]) has toggled [M]'s invulnerability [(M.flags & INVULNERABLE) ? "on" : "off"]")

client/proc/delete_all_adminbus()
	set name = "Delete every Adminbus"
	set desc = "When the world cannot handle them anymore."
	set category = "Fun"

	if(alert(usr, "Delete every single Adminbus in the game world?", "Delete Adminbus", "Yes", "No") != "Yes")
		return

	for(var/obj/structure/stool/bed/chair/vehicle/adminbus/AB in world)
		AB.Adminbus_Deletion()

client/proc/mob_list()
	set name = "show mob list"
	set category = "Debug"
	if(!holder) return
	usr << "mob list length is [mob_list.len]"
	var/foundnull = 0
	for(var/mob/V in mob_list)
		var/msg = "mob ([V]) is in slot [mob_list.Find(V)]"
		if(!ismob(V))
			if(isnull(V))
				foundnull++
			msg = "<span class='danger'><font size=3>Non mob found in mob list [isnull(V) ? "null entry found at mob_list.Find(V)" : "[V]'s type is [V.type]"]</span></font>"
		usr << msg
	if(foundnull)
		usr << "Found [foundnull] null entries in the mob list, running null clearer."
		listclearnulls(mob_list)

client/proc/cure_disease()
	set name = "Cure Disease"
	set category = "Debug"
	if(!holder) return

	var/list/disease_by_name = list("-Cure All-" = null) + disease2_list + active_diseases

	var/disease_name = input(src, "Disease to cure?") as null|anything in sortTim(disease_by_name, /proc/cmp_text_asc)
	if(!disease_name) return
	var/count = 0
	if(disease_name == "-Cure All-")
		for(var/mob/living/carbon/C in mob_list)
			for(var/ID in C.virus2)
				if(ID && C.virus2[ID])
					var/datum/disease2/disease/DD = C.virus2[ID]
					DD.cure(C)
					count++
			for(var/datum/disease/D in C.viruses)
				if(D)
					D.cure(1)
					count++
					active_diseases -= D
	else
		for(var/mob/living/carbon/C in mob_list)
			for(var/ID in C.virus2)
				if(ID == disease_name)
					var/datum/disease2/disease/DD = C.virus2[ID]
					DD.cure(C)
					count++
			for(var/datum/disease/D in C.viruses)
				if(D && D.name == disease_name)
					D.cure(1)
					count++
					active_diseases -= D
	src << "<span class='notice'>Cured [count] mob\s of [disease_name == "-Cure All-" ? "all diseases." : "[disease_name]"]</span>"
	log_admin("[src]/([ckey(src.key)] Cured all mobs of [disease_name == "-Cure All-" ? "all diseases." : "[disease_name]"]")
	message_admins("[src]/([ckey(src.key)] Cured all mobs of [disease_name == "-Cure All-" ? "all diseases." : "[disease_name]"]")