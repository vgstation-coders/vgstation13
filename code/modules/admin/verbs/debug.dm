//how long we keep proc call results (datums and lists)
#define PROC_RESULT_KEEP_TIME 5 MINUTES

/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!check_rights(R_DEBUG))
		return

	if(Debug2)
		Debug2 = 0
		message_admins("[key_name(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		Debug2 = 1
		message_admins("[key_name(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")

	feedback_add_details("admin_verb","DG2") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/* 21st sept 2010
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

	if(!check_rights(R_DEBUG))
		return

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
		if(!procname)
			return

		if(target && !hascall(target, procname))
			to_chat(usr, "<span class='red'>Error: callproc(): target has no such call [procname].</span>")
			return

		var/argnum = input("Number of arguments","Number:",0) as num|null
		if(!argnum && (argnum!=0))
			return

		lst.len = argnum // Expand to right length
		//TODO: make a list to store whether each argument was initialised as null.
		//Reason: So we can abort the proccall if say, one of our arguments was a mob which no longer exists
		//this will protect us from a fair few errors ~Carn

		var/i
		for(i = 1, i < argnum + 1, i++) // Lists indexed from 1 forwards in byond
			lst[i] = variable_set(src)

		if(targetselected)
			if(!target)
				to_chat(usr, "<span class='red'>Error: callproc(): owner of proc no longer exists.</span>")
				return

			log_admin("[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(target,procname)(arglist(lst)) // Pass the lst as an argument list to the proc
		else
			//this currently has no hascall protection. wasn't able to get it working.
			log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(procname)(arglist(lst)) // Pass the lst as an argument list to the proc

		if(isnull(returnval))
			returnval = "null"
		else if(returnval == "")
			returnval = "\"\" (empty string)"
		to_chat(usr, "<span class='notice'>[procname] returned: [returnval]</span>")
		feedback_add_details("admin_verb","APC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/callatomproc(var/datum/target as anything)
	set category = "Debug"
	set name = "Atom ProcCall"

	if(!check_rights(R_DEBUG))
		return

	spawn(0)
		var/lst[] // List reference
		lst = new/list() // Make the list
		var/returnval = null

		var/procname = input("Proc path, eg: /proc/fake_blood","Path:", null) as text|null
		if(!procname)
			return

		if(!hascall(target, procname))
			to_chat(usr, "<span class='red'>Error: callatomproc(): target has no such call [procname].</span>")
			return

		var/argnum = input("Number of arguments","Number:",0) as num|null
		if(!argnum && (argnum!=0))
			return

		lst.len = argnum // Expand to right length
		//TODO: make a list to store whether each argument was initialised as null.
		//Reason: So we can abort the proccall if say, one of our arguments was a mob which no longer exists
		//this will protect us from a fair few errors ~Carn

		var/i
		for(i = 1, i < argnum + 1, i++) // Lists indexed from 1 forwards in byond
			lst[i] = variable_set(src)

		log_admin("[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
		returnval = call(target,procname)(arglist(lst)) // Pass the lst as an argument list to the proc

		if(isnull(returnval))
			returnval = "null"
		else if(returnval == "")
			returnval = "\"\" (empty string)"

		var/returntext = returnval
		if(istype(returnval, /datum))
			returntext = "[returnval] <a href='?_src_=vars;Vars=\ref[returnval]'>\[VV\]</A>"
			spawn(PROC_RESULT_KEEP_TIME)
				returnval = null
		else if(istype(returnval, /list))
			returntext = "<a href='?_src_=vars;List=\ref[returnval]'>\[List\]</A>"
			spawn(PROC_RESULT_KEEP_TIME)
				returnval = null

		to_chat(usr, "<span class='notice'>[procname] returned: [returntext]</span>")
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

	t += {"Nitrogen : [env[GAS_NITROGEN]]
Oxygen : [env[GAS_OXYGEN]]
Plasma : [env[GAS_PLASMA]]
CO2: [env[GAS_CARBON]]
Pressure: [env.pressure]"}
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
		. = M:Robotize()

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
		. = M:MoMMIfy()

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
	. = M.Animalize()


/client/proc/makepAI(var/turf/T)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	if(!T)
		T = get_turf(usr)
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
			feedback_add_details("admin_verb","MKAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			return M:Alienize()

		log_admin("[key_name(usr)] made [key_name(M)] into an alien.")
		message_admins("<span class='notice'>[key_name_admin(usr)] made [key_name(M)] into an alien.</span>", 1)
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
			feedback_add_details("admin_verb","MKMET") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			return M:slimeize()
		log_admin("[key_name(usr)] made [key_name(M)] into a slime.")
		message_admins("<span class='notice'>[key_name_admin(usr)] made [key_name(M)] into a slime.</span>", 1)
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

	to_chat(usr, "Ruby Mode disabled. Command aborted.")
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
				to_chat(M, "<span class='warning'>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie. A tome, a message from your new master, appears on the ground.</span>")
				new /obj/item/weapon/tome_legacy(M.loc)
			else
				to_chat(M, "<span class='warning'>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</span>")
			var/glimpse=pick("1","2","3","4","5","6","7","8")
			switch(glimpse)
				if("1")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["travel"]] is travel...</span>")
				if("2")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["blood"]] is blood...</span>")
				if("3")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["join"]] is join...</span>")
				if("4")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["hell"]] is Hell...</span>")
				if("5")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["destroy"]] is destroy...</span>")
				if("6")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["technology"]] is technology...</span>")
				if("7")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["self"]] is self...</span>")
				if("8")
					to_chat(M, "<span class='warning'>You remembered one thing from the glimpse... [cultwords["see"]] is see...</span>")

			if(M.mind)
				M.mind.special_role = "Cultist"
				ticker.mode.cult += M.mind
				to_chat(M, "<span class='sinister'>You can now speak and understand the forgotten tongue of the occult.</span>")
				M.add_language(LANGUAGE_CULT)
			to_chat(src, "Made [M] a cultist.")
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
				qdel(O)
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
	message_admins("<span class='notice'>[key_name_admin(usr)] has granted [M.key] full access.</span>", 1)

/client/proc/cmd_assume_direct_control(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(!check_rights(R_DEBUG|R_ADMIN))
		return
	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
	message_admins("<span class='notice'>[key_name_admin(usr)] assumed direct control of [M].</span>", 1)
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = src.mob
	M.ckey = src.ckey
	if( isobserver(adminmob) )
		qdel(adminmob)
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

	for(var/area/A in areas)
		if(A && !(A.type in areas_all))
			areas_all.Add(A.type)

	for(var/obj/machinery/power/apc/APC in power_machines)
		var/area/A = get_area(APC)
		if(A && !(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)

	for(var/obj/machinery/alarm/alarm in machines)
		var/area/A = get_area(alarm)
		if(A && !(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)

	for(var/obj/machinery/requests_console/RC in allConsoles)
		var/area/A = get_area(RC)
		if(A && !(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)

	for(var/obj/machinery/light/L in alllights)
		var/area/A = get_area(L)
		if(A && !(A.type in areas_with_light))
			areas_with_light.Add(A.type)

	for(var/obj/machinery/light_switch/LS in world)
		var/area/A = get_area(LS)
		if(A && !(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)

	for(var/obj/item/device/radio/intercom/I in world)
		var/area/A = get_area(I)
		if(A && !(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)

	for(var/obj/machinery/camera/C in cameranet.cameras)
		var/area/A = get_area(C)
		if(A && !(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	to_chat(world, "<b>AREAS WITHOUT AN APC:</b>")
	for(var/areatype in areas_without_APC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT AN AIR ALARM:</b>")
	for(var/areatype in areas_without_air_alarm)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A REQUEST CONSOLE:</b>")
	for(var/areatype in areas_without_RC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY LIGHTS:</b>")
	for(var/areatype in areas_without_light)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A LIGHT SWITCH:</b>")
	for(var/areatype in areas_without_LS)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY INTERCOMS:</b>")
	for(var/areatype in areas_without_intercom)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY CAMERAS:</b>")
	for(var/areatype in areas_without_camera)
		to_chat(world, "* [areatype]")

/client/proc/startSinglo()
	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing through the station"

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	log_admin("[key_name(usr)] set up the singulo.")
	message_admins("<span class='notice'>[key_name_admin(usr)] set up the singulo.</span>", 1)

	for(var/obj/machinery/power/emitter/E in power_machines)
		if(E.anchored)
			//We now have a toggle proc, so here goes
			E.turn_on()
			E.investigation_log(I_SINGULO,"turned <font color='green'>on</font> <font color='red'>via Start Singularity Debug verb.</font>")

	for(var/obj/machinery/field_generator/F in field_gen_list)
		if(F.anchored)
			//The gentleman who coded this was nice enough to add a proc
			F.turn_on()
			F.investigation_log(I_SINGULO,"<font color='green'>activated</font> <font color='red'>via Start Singularity Debug verb.</font>")

	for(var/obj/machinery/power/rad_collector/Rad in rad_collectors)
		if(Rad.anchored)
			if(!Rad.P)
				var/obj/item/weapon/tank/plasma/Plasma = new/obj/item/weapon/tank/plasma(Rad)
				Plasma.air_contents[GAS_PLASMA] = 100 //Don't need to explain, space magic
				Plasma.air_contents.temperature = 73.15 //Perfect freezer cooling
				Plasma.air_contents.update_values()
				Rad.drain_ratio = 0
				Rad.P = Plasma

			if(!Rad.active)
				Rad.toggle_power()
				Rad.locked = 1

	sleep(200) //Field generators take 15 seconds to warm up, so we'll give 20

	for(var/obj/machinery/the_singularitygen/G in machines)
		if(G.anchored)
			var/obj/machinery/singularity/S = new /obj/machinery/singularity(get_turf(G), 50)
			spawn(0)
				qdel(G)
			S.energy = 1250 //No energy dissipates
			S.current_size = 7
			S.icon = 'icons/effects/224x224.dmi'
			S.icon_state = "singularity_s7"
			S.pixel_x = -96 * PIXEL_MULTIPLIER
			S.pixel_y = -96 * PIXEL_MULTIPLIER
			S.grav_pull = 0
			S.dissipate = 0
			S.consume_range = 0 //Can't be too sure

	sleep(50) //Extra five seconds for the radiation collectors to get their shit together

	for(var/obj/machinery/power/battery/smes/SMES in power_machines)
		if(SMES.anchored)
			SMES.connect_to_network() //Just in case.
			SMES.chargemode = 1
			SMES.online = 1

/client/proc/cheat_power()
	set category = "Debug"
	set name = "Free Power"
	set desc = "Replaces all SMES on the map with magical ones."

	if(alert("Are you sure? This will completely fuck over your round!",,"Yes","No") != "Yes")
		return

	log_admin("[key_name(usr)] haxed the powergrid with magic SMES.")
	message_admins("<span class='notice'>[key_name_admin(usr)] haxed the powergrid with magic SMES.</span>", 1)

	for(var/obj/machinery/power/battery/smes/SMES in power_machines)
		var/turf/T=SMES.loc
		qdel(SMES)
		var/obj/machinery/power/battery/smes/infinite/magic = new(T)
		// Manually set up our powernets since stupid seems to reign in the powernet code.
		magic.connect_to_network()
		magic.output=200000 // AKA rape
		magic.online=1

//	to_chat(world, "<b>LET THERE BE JUICE</b>")


// Getting tired of doing this shit every fucking round when I'm testing something atmos-related
/client/proc/setup_atmos()
	set category = "Debug"
	set name = "Start Atmos"
	set desc = "WOW ATMOS DID THEIR JOBS!!!1"

	if(alert("Are you sure? This will completely fuck over your round!",,"Yes","No") != "Yes")
		return

	log_admin("[key_name(usr)] haxed atmos.")
	message_admins("<span class='notice'>[key_name_admin(usr)] haxed atmos.</span>", 1)

	for(var/obj/machinery/atmospherics/binary/pump/P in atmos_machines)
		//if(p.name == "Air to Distro")
		P.target_pressure=4500
	for(var/obj/machinery/atmospherics/unary/vent_pump/high_volume/P in atmos_machines)
		if(P.id_tag=="air_out")
			P.internal_pressure_bound=4500
	for(var/obj/machinery/atmospherics/trinary/filter/F in atmos_machines)
		F.target_pressure=4500

//	to_chat(world, "<b>LET THERE BE AIR</b>")


/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs", "Clients"))
		if("Players")
			to_chat(usr, jointext(player_list,","))
		if("Admins")
			to_chat(usr, jointext(admins,","))
		if("Mobs")
			to_chat(usr, jointext(mob_list,","))
		if("Living Mobs")
			to_chat(usr, jointext(living_mob_list,","))
		if("Dead Mobs")
			to_chat(usr, jointext(dead_mob_list,","))
		if("Clients")
			to_chat(usr, jointext(clients,","))


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

	to_chat(usr, "<span class='notice'>Dumped to [F]</span>")

/client/proc/cmd_admin_find_bad_blood_tracks()
	set category = "Debug"
	set name = "Find broken blood tracks"
	if(!holder)
		return
	message_admins("[src] used find broken blood tracks")
	var/date_string = time2text(world.realtime, "YYYY-MM-DD")
	var/F =file("data/logs/profiling/[date_string]_broken_blood.log")
	fdel(F)
	for(var/obj/effect/decal/cleanable/blood/tracks/T in blood_list)
		if(!T.loc)
			F << "Found [T] in a null location but still in the blood list"
			F << "--------------------------------------"
			continue
		var/dat
		for(var/b in cardinal)
			if(isnull(T.setdirs["[b]"]))
				dat += ("[T] ([formatJumpTo(T)]) had a bad directional [b] or bad list [T.setdirs.len]")
				dat += ("Setdirs keys:")
				for(var/key in T.setdirs)
					dat += (key)
		dat += "--------------------------------------"
		F << dat

	to_chat(usr, "<span class='notice'>Dumped to [F]</span>")

#ifdef PROFILE_MACHINES
/client/proc/cmd_admin_dump_machine_type_list()
	set category = "Debug"
	set name = "Dump Machine type list"

	if(!machines.len && !power_machines.len)
		to_chat(usr, "Machines has no length!")
		return
	var/date_string = time2text(world.realtime, "YYYY-MM-DD")
	var/F =file("data/logs/profiling/[date_string]_machine_instances.csv")
	fdel(F)
	F << "type,count"
	var/list/machineinstances = list()
	for(var/atom/typepath in machines)
		if(!(typepath.type in machineinstances))
			machineinstances["[typepath.type]"] = 0
		machineinstances["[typepath.type]"] += 1
	for(var/T in machineinstances)
		var/count = machineinstances[T]
		F << "[T],[count]"

	to_chat(usr, "<span class='notice'>Dumped to [F].</span>")
	F =file("data/logs/profiling/[date_string]_power_machine_instances.csv")
	fdel(F)
	F << "type,count"
	machineinstances.len = 0
	for(var/atom/typepath in power_machines)
		if(!(typepath.type in machineinstances))
			machineinstances["[typepath.type]"] = 0
		machineinstances["[typepath.type]"] += 1
	for(var/T in machineinstances)
		var/count = machineinstances[T]
		F << "[T],[count]"

	to_chat(usr, "<span class='notice'>Dumped to [F].</span>")
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

	to_chat(usr, "<span class='notice'>Dumped to [F].</span>")
	F =file("data/logs/profiling/[date_string]_gdel_profiling.csv")
	fdel(F)
	F << "type,soft deletes"
	for(var/typepath in gdel_profiling)
		var/ns = gdel_profiling[typepath]
		F << "[typepath],[ns]"

	to_chat(usr, "<span class='notice'>Dumped to [F].</span>")

	F =file("data/logs/profiling/[date_string]_ghdel_profiling.csv")
	fdel(F)
	F << "type,hard deletes"
	for(var/typepath in ghdel_profiling)
		var/ns = ghdel_profiling[typepath]
		F << "[typepath],[ns]"

	to_chat(usr, "<span class='notice'>Dumped to [F].</span>")

/client/proc/gib_money()
	set category = "Fun"
	set name = "Dispense Money"
	set desc = "Honk"

	var/response = input(src,"How much moneys?") as num
	if( response < 1)
		return
	dispense_cash(response, mob.loc)

var/global/blood_virus_spreading_disabled = 0
/client/proc/disable_bloodvirii()
	set category = "Debug"
	set name = "Disable Blood Virus Spreading"

//	to_chat(usr, "<span class='warning'>Proc disabled.</span>")

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
		winset(C, null, "window1.msay_output.style=[config.world_style_config];")
	message_admins("The style sheet has been reloaded by [src.ckey]")

/client/proc/reset_style_sheet()
	set category = "Server"
	set name = "Reset Style Sheet"
	set desc = "Reset the Style Sheet (restore to default)."

	for(var/client/C in clients)
		winset(C, null, "window1.msay_output.style=[world_style];")
	config.world_style_config = world_style
	message_admins("The style sheet has been reset by [src.ckey]")

/client/proc/cmd_admin_cluwneize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Cluwne"
	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		return M:Cluwneize()
		message_admins("<span class='notice'>[key_name_admin(usr)] made [key_name(M)] into a cluwne.</span>", 1)
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

	for(var/obj/structure/bed/chair/vehicle/adminbus/AB in world)
		AB.Adminbus_Deletion()

client/proc/delete_all_bomberman()
	set name = "Remove all that Bomberman shit"
	set desc = "4th wall ointment."
	set category = "Fun"

	if(!check_rights(R_FUN))
		return

	if(alert(usr, "Remove all Bomberman-related objects in the game world?", "Remove Bomberman", "Yes", "No") != "Yes")
		return

	for(var/datum/bomberman_arena/target in arenas)
		target.close()
		if(target in arenas)
			arenas -= target

	for(var/obj/structure/bomberflame/O in bombermangear)
		qdel(O)

	for(var/obj/structure/bomberman/O in bombermangear)
		qdel(O)

	for(var/obj/item/weapon/bomberman/O in bombermangear)
		if(istype(O.loc, /mob/living/carbon/))
			var/mob/living/carbon/C = O.loc
			C.u_equip(O,1)
			O.forceMove(C.loc)
			//O.dropped(C)
		qdel(O)

	for(var/obj/item/clothing/suit/space/bomberman/O in bombermangear)
		if(istype(O.loc, /mob/living/carbon/))
			var/mob/living/carbon/C = O.loc
			C.u_equip(O,1)
			O.forceMove(C.loc)
			//O.dropped(C)
		qdel(O)

	for(var/obj/item/clothing/head/helmet/space/bomberman/O in bombermangear)
		if(istype(O.loc, /mob/living/carbon/))
			var/mob/living/carbon/C = O.loc
			C.u_equip(O,1)
			O.forceMove(C.loc)
			//O.dropped(C)
		qdel(O)

	for(var/obj/structure/softwall/O in bombermangear)
		qdel(O)

	for(var/turf/unsimulated/wall/bomberman/T in world)
		T.ChangeTurf(/turf/simulated/wall)


	for(var/obj/structure/powerup/O in bombermangear)
		qdel(O)

client/proc/create_bomberman_arena()
	set name = "Create a Bomberman Arena"
	set desc = "Create a customizable Bomberman-type arena."
	set category = "Fun"

	if(!check_rights(R_FUN))
		return

	var/list/arena_sizes = list(
		"15x13 (2 players)",
		"15x15 (4 players)",
		"39x23 (10 players)",
		)
	var/arena_type = input("What size for the arena?", "Arena Construction") in arena_sizes | null

	if(!arena_type)
		return

	var/turf/T = get_turf(src.mob)
	var/datum/bomberman_arena/A = new /datum/bomberman_arena(T, arena_type, src.mob)
	arenas += A

client/proc/control_bomberman_arena()
	set name = "Arena Control Panel"
	set desc = "Control or Remove an existing Bomberman-type arena."
	set category = "Fun"

	if(!check_rights(R_FUN))
		return

	if(!arenas.len)
		to_chat(usr, "There are no arenas in the world!")
		return

	var/datum/bomberman_arena/arena_target = input("Which arena do you wish to control?", "Arena Control Panel") in arenas
	to_chat(usr, "Arena Control Panel: [arena_target]")
	var/arena_status = ""
	switch(arena_target.status)
		if(ARENA_SETUP)
			arena_status = "SETUP"
		if(ARENA_AVAILABLE)
			arena_status = "AVAILABLE"
		if(ARENA_INGAME)
			arena_status = "IN-GAME"
		if(ARENA_ENDGAME)
			arena_status = "END-GAME"
	to_chat(usr, "status: <b>[arena_status]</b>")
	to_chat(usr, "violence mode: [arena_target.violence ? "ON" : "OFF"]")
	to_chat(usr, "opacity mode: [arena_target.opacity ? "ON" : "OFF"]")
	if(arena_status == "SETUP")
		to_chat(usr, "<span class='warning'>Arena Under Construction</span>")
	if(arena_status == "AVAILABLE")
		var/i = 0
		for(var/datum/bomberman_spawn/S in arena_target.spawns)
			if(S.availability)
				i++
		to_chat(usr, "Available spawn points: <b>[i]</b>")
	if((arena_status == "IN-GAME") || (arena_status == "END-GAME"))
		var/j = "players: "
		for(var/datum/bomberman_spawn/S in arena_target.spawns)
			if(S.player_client)
				j += "<b>[S.player_client.key]</b>, "
		to_chat(usr, "[j]")

	var/list/choices = list(
		"CANCEL",
		"Close Arena(space)",
		"Close Arena(floors)",
		"Reset Arena",
		"Toggle Violence",
		"Toggle Opacity",
		"View Variables",
		)

	if(arena_status == "AVAILABLE")
		choices += "Force Start"

	var/datum/bomberman_arena/choice = input("Which action do you wish to take?", "Arena Control Panel") in choices
	switch(choice)
		if("CANCEL")
			return
		if("Close Arena(space)")
			arena_target.close()
			if(arena_target in arenas)
				arenas -= arena_target
		if("Close Arena(floors)")
			arena_target.close(0)
			if(arena_target in arenas)
				arenas -= arena_target
		if("Reset Arena")
			arena_target.reset()
		if("Toggle Violence")
			arena_target.violence = !arena_target.violence
		if("Toggle Opacity")
			arena_target.opacity = !arena_target.opacity
			for(var/obj/structure/softwall/L in arena_target.swalls)
				L.opacity = arena_target.opacity
			for(var/turf/unsimulated/wall/bomberman/L in arena_target.turfs)
				L.opacity = arena_target.opacity
		if("View Variables")
			debug_variables(arena_target)
		if("Force Start")
			arena_target.start()



client/proc/mob_list()
	set name = "show mob list"
	set category = "Debug"

	if(!holder)
		return
	to_chat(usr, "mob list length is [mob_list.len]")
	var/foundnull = 0
	for(var/mob/V in mob_list)
		var/msg = "mob ([V]) is in slot [mob_list.Find(V)]"
		if(!ismob(V))
			if(isnull(V))
				foundnull++
			msg = "<span class='danger'><font size=3>Non mob found in mob list [isnull(V) ? "null entry found at mob_list.Find(V)" : "[V]'s type is [V.type]"]</span></font>"
		to_chat(usr, msg)
	if(foundnull)
		to_chat(usr, "Found [foundnull] null entries in the mob list, running null clearer.")
		listclearnulls(mob_list)

client/proc/check_bomb()
	set name = "Check Bomb Impact"
	set category = "Debug"

	var/newmode = alert("Use the new method?","Check Bomb Impact", "Yes","No")


	var/turf/epicenter = get_turf(usr)
	var/devastation_range = 0
	var/heavy_impact_range = 0
	var/light_impact_range = 0
	var/list/choices = list("Small Bomb", "Medium Bomb", "Big Bomb", "Custom Bomb")
	var/choice = input("What size explosion would you like to produce?") in choices
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			devastation_range = 1
			heavy_impact_range = 2
			light_impact_range = 3
		if("Medium Bomb")
			devastation_range = 2
			heavy_impact_range = 3
			light_impact_range = 4
		if("Big Bomb")
			devastation_range = 3
			heavy_impact_range = 5
			light_impact_range = 7
		if("Custom Bomb")
			devastation_range = input("Devastation range (in tiles):") as num
			heavy_impact_range = input("Heavy impact range (in tiles):") as num
			light_impact_range = input("Light impact range (in tiles):") as num

	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range)

	var/x0 = epicenter.x
	var/y0 = epicenter.y

	var/list/wipe_colors = list()
	for (var/turf/T in trange(max_range, epicenter))
		wipe_colors += T
		var/dist = cheap_pythag(T.x - x0, T.y - y0)

		if(newmode == "Yes")
			var/turf/Trajectory = T
			while(Trajectory != epicenter)
				Trajectory = get_step_towards(Trajectory,epicenter)
				if(Trajectory.density && Trajectory.explosion_block)
					dist += Trajectory.explosion_block

				for (var/obj/machinery/door/D in Trajectory.contents)
					if(D.density && D.explosion_block)
						dist += D.explosion_block

		if (dist < devastation_range)
			T.color = "red"
		else if (dist < heavy_impact_range)
			T.color = "yellow"
		else if (dist < light_impact_range)
			T.color = "blue"
		else
			continue

	sleep(100)
	for (var/turf/T in wipe_colors)
		T.color = null

/client/proc/set_teleport_pref()
	set name = "Set Teleport-Here Preferences"
	set category = "Fun"

	teleport_here_pref = alert("Do you want to teleport atoms in a flashy way or a discreet way?","Teleport-Here Preferences", "Flashy","Stealthy")

	switch(teleport_here_pref)
		if("Flashy")
			flashy_level =  input("How much flashy do you want it to be? 0=no effect; 1=flash; 2=screen-shake; 3=global X HAS RISEN announcement","Flashy Preferences") as num
		if("Stealthy")
			stealthy_level = input("How long do you want the fade-in to last? (in tenth of seconds)","Stealthy Preferences") as num

client/proc/cure_disease()
	set name = "Cure Disease"
	set category = "Debug"
	if(!holder)
		return

	var/list/disease_by_name = list("-Cure All-" = null) + disease2_list + active_diseases

	var/disease_name = input(src, "Disease to cure?") as null|anything in sortTim(disease_by_name, /proc/cmp_text_asc)
	if(!disease_name)
		return
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
	to_chat(src, "<span class='notice'>Cured [count] mob\s of [disease_name == "-Cure All-" ? "all diseases." : "[disease_name]"]</span>")
	log_admin("[src]/([ckey(src.key)] Cured all mobs of [disease_name == "-Cure All-" ? "all diseases." : "[disease_name]"]")
	message_admins("[src]/([ckey(src.key)] Cured all mobs of [disease_name == "-Cure All-" ? "all diseases." : "[disease_name]"]")

client/proc/check_convertables()
	set name = "Check Convertables (Cult v2.0)"
	set category = "Debug"
	if(!holder || !ticker || !ticker.mode)
		return
	var/datum/faction/cult/narsie = find_active_faction_by_type(/datum/faction/cult/narsie)
	var/dat = ""
	for(var/mob/M in player_list)
		if(!M.mind)
			dat += "[M.real_name]/([ckey(M.key)]): <font color=grey><b>NO MIND</b></font></br>"
		else if(!istype(M,/mob/living/carbon/human))
			dat += "[M.real_name]/([ckey(M.key)]): <b>NOT HUMAN</b></br>"
		else if(!is_convertable_to_cult_legacy(M.mind))
			dat += "[M.real_name]/([ckey(M.key)]): <font color=red><b>UNCONVERTABLE</b></font></br>"
		else if(jobban_isbanned(M, "cultist"))
			dat += "[M.real_name]/([ckey(M.key)]): <font color=red><b>JOBBANNED</b></font></br>"
		else if(M.mind in narsie.members)
			dat += "[M.real_name]/([ckey(M.key)]): <font color=blue><b>CULTIST</b></font></br>"
		else
			dat += "[M.real_name]/([ckey(M.key)]): <font color=green><b>CONVERTABLE</b></font></br>"

	to_chat(usr, dat)

/client/proc/spawn_datum(var/object as text)
	set category = "Debug"
	set desc = "(datum path) Spawn a datum (turfs NOT supported)"
	set name = "Create Datum"

	if(!check_rights(R_SPAWN))
		return

	//Parse and strip any changed variables (added in curly brackets at the end of the input string)
	var/variables_start = findtext(object,"{")

	var/list/varchanges = list()
	if(variables_start)
		var/parameters = copytext(object,variables_start+1,length(object))//removing the last '}'
		varchanges = readlist(parameters, ";")

		object = copytext(object, 1, variables_start)


	var/list/matches = get_matching_types(object, /datum) - typesof(/turf, /area) //Exclude non-movable atoms

	if(matches.len == 0)
		to_chat(usr, "Unable to find any matches.")
		return

	var/chosen
	if(matches.len == 1)
		chosen = matches[1]
	else
		chosen = input("Select a datum type", "Spawn Datum", matches[1]) as null|anything in matches
		if(!chosen)
			return

	var/list/lst = list()
	var/argnum = input("Number of arguments","Number:",0) as num|null
	if(!argnum && (argnum!=0))
		return

	lst.len = argnum // Expand to right length

	for(var/i = 1 to argnum) // Lists indexed from 1 forwards in byond
		lst[i] = variable_set(src)

	holder.marked_datum = new chosen(arglist(lst))

	to_chat(usr, "<span class='notify'>A reference to the new [chosen] has been stored in your marked datum. <a href='?_src_=vars;Vars=\ref[holder.marked_datum]'>Click here to access it</a></span>")
	log_admin("[key_name(usr)] spawned the datum [chosen] to his marked datum.")
	feedback_add_details("admin_verb","SD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(varchanges.len)
		_preloader = new(varchanges, chosen)
		//_preloaded calls load() automatically on atom/New(). However, this proc can also create datums, which don't do that - call load() manually
		_preloader.load(holder.marked_datum)

/client/proc/vv_marked_datum()
	set category	= "Debug"
	set desc		= "Opens a VV menu for your marked datum."
	set name		= "View Marked Datum's Vars"

	if(!check_rights(R_DEBUG))
		return

	if(!holder.marked_datum)
		to_chat(usr, "<span class='warning'>You do not have a marked datum!</span>")
		return

	debug_variables(holder.marked_datum)

/client/proc/check_spiral()
	set name = "Check Spiral Block"
	set category = "Debug"

	var/turf/epicenter = get_turf(usr)
	var/max_range = input("Set the max range") as num
	var/inward = alert("Which way?","Spiral Block", "Inward","Outward")
	if(inward == "Inward")
		spiral_block(epicenter,max_range,1,1)
	else
		spiral_block(epicenter,max_range,0,1)

/client/proc/check_striketeams()
	set name = "Check StrikeTeams"
	set category = "Debug"

	if(!sent_strike_teams || sent_strike_teams.len <= 0)
		to_chat(usr, "<span class='warning'>No strike teams have been sent so far!</span>")
		return

	var/teamToDebug = input(usr,"Choose a Strike Team.", "Check StrikeTeams") in sent_strike_teams

	debug_variables(sent_strike_teams[teamToDebug])

/client/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the Runtime Viewer"

	if (!check_rights(R_DEBUG))
		return

	error_cache.show_to(src)

/client/proc/emergency_shuttle_panel()
	set name = "Emergency Shuttle Panel"
	set category = "Debug"
	if(holder)
		holder.emergency_shuttle_panel()
		log_admin("[key_name(usr)] checked the Emergency Shuttle Panel.")
	feedback_add_details("admin_verb","ESP")

/client/proc/bee_count()
	set category = "Debug"
	set name = "Check Bee Count"
	set desc = "Check how many bee datums or mobs currently exist in the world."

	var/contained_bees = 0
	for (var/obj/machinery/apiary/A in apiaries_list)
		contained_bees += A.worker_bees_inside
		contained_bees += A.queen_bees_inside
	to_chat(usr, "<span class='notice'>There are currently [bees_count] bee datums, spread between [bee_mobs_count] swarms (or possibly held in bug nets).</span>")
	to_chat(usr, "<span class='notice'>Additionally, there are [contained_bees] bees currently contained within apiaries.</span>")


/client/proc/diseases_panel()
	set name = "Diseases Panel"
	set category = "Admin"
	if(holder)
		holder.diseases_panel()
		log_admin("[key_name(usr)] checked the Diseases Panel.")
	feedback_add_details("admin_verb","DIS")
	return

/client/proc/start_line_profiling()
	set category = "Profile"
	set name = "Start line profiling"
	set desc = "Starts tracking line by line profiling for code lines that support it"

	PROFILE_START

	message_admins("<span class='adminnotice'>[key_name_admin(src)] started line by line profiling.</span>")
	feedback_add_details("admin_verb","Start line profiling")
	log_admin("[key_name(src)] started line by line profiling.")

/client/proc/stop_line_profiling()
	set category = "Profile"
	set name = "Stop line profiling"
	set desc = "Stops tracking line by line profiling for code lines that support it"

	PROFILE_STOP

	message_admins("<span class='adminnotice'>[key_name_admin(src)] stopped line by line profiling.</span>")
	feedback_add_details("admin_verb","Stop line profiling")
	log_admin("[key_name(src)] stopped line by line profiling.")

/client/proc/show_line_profiling()
	set category = "Profile"
	set name = "Show line profiling"
	set desc = "Shows tracked profiling info from code lines that support it"

	var/sortlist = list(
		"Avg time"		=	/proc/cmp_profile_avg_time_dsc,
		"Total Time"	=	/proc/cmp_profile_time_dsc,
		"Call Count"	=	/proc/cmp_profile_count_dsc
	)
	var/sort = input(src, "Sort type?", "Sort Type", "Avg time") as null|anything in sortlist
	if (!sort)
		return
	sort = sortlist[sort]
	profile_show(src, sort)
