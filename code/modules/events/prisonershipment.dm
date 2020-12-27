
var/global/can_request_prisoner = TRUE
var/list/current_prisoners = list()


/datum/event/prisontransfer
	var/datum/recruiter/recruiter = null //for prisoner shit

/datum/event/prisontransfer/can_start()        //Can't fire randomly for now. Must be forced by a security RC console.
	return 0

/datum/event/prisontransfer/start()
	can_request_prisoner = FALSE

	if(!recruiter)
		recruiter = new(src)
		recruiter.display_name = "prisoner"
		recruiter.role = ROLE_PRISONER
		recruiter.jobban_roles = list("minor roles") //has anyone even been banned from minor roles?

		// Role set to Yes or Always
		recruiter.player_volunteering.Add(src, "recruiter_recruiting")
		// Role set to No or Never
		recruiter.player_not_volunteering.Add(src, "recruiter_not_recruiting")

		recruiter.recruited.Add(src, "recruiter_recruited")

		recruiter.request_player()
	

/datum/event/prisontransfer/proc/recruiter_recruiting(var/list/args)
	var/mob/dead/observer/O = args["player"]
	var/controls = args["controls"]
	to_chat(O, "<span class='recruit'>The security department is requesting a prisoner transfer. You have been added to the list of potential ghosts. ([controls])</span>")

/datum/event/prisontransfer/proc/recruiter_not_recruiting(var/list/args)
	var/mob/dead/observer/O = args["player"]
	var/controls = args["controls"]
	to_chat(O, "<span class='recruit'>The security department is requesting a prisoner transfer. ([controls])</span>")


/datum/event/prisontransfer/proc/recruiter_recruited(var/list/args)
	var/mob/dead/observer/O = args["player"]
	can_request_prisoner = TRUE		//This is set to false by the prisoner role if we exceed the limit.
	if(O)
		qdel(recruiter)
		recruiter = null

		command_alert(/datum/command_alert/prisoner_transfer)

		//Make the prisoner
		var/mob/living/carbon/human/H = new /mob/living/carbon/human
		H.ckey = O.ckey
		H.client.changeView()
		var/species = pickweight(list(
			"Human" 	= 4,
			"Vox"		= 1,
			"Plasmaman" = 1,
			"Grey"		= 1,
			"Insectoid"	= 1,
		))

		H.set_species(species)

		//Give them their outfit
		var/datum/outfit/special/prisoner/outfit = new /datum/outfit/special/prisoner
		outfit.equip(H)

		//Randomize their looks (but let them pick a name)
		H.randomise_appearance_for()
		var/randname = random_name(H.gender, H.species.name)
		H.fully_replace_character_name(null,randname)
		H.regenerate_icons()
		H.dna.ResetUIFrom(H)
		H.dna.ResetSE()
		mob_rename_self(H, "prisoner")

		//Send them to the starting location.
		var/obj/structure/bed/chair/chair = pick(prisonerstart)
		H.forceMove(get_turf(chair))
		chair.buckle_mob(H, H)

		//Handcuff them.
		var/obj/item/weapon/handcuffs/C = new /obj/item/weapon/handcuffs(H)
		H.equip_to_slot(C, slot_handcuffed)

		//80% are Normal Syndicate Prisoners with antag status
		if(prob(80))
			var/datum/role/prisoner/P = new /datum/role/prisoner(H.mind)
			P.OnPostSetup()
			P.Greet()
			P.ForgeObjectives()
			P.AnnounceObjectives()

		else	//20% for a special 'innocent' prisoner without antag freedums
			to_chat(H, "<B>You are an <span class='warning'>innocent</span> prisoner!</B>")
			to_chat(H, "You are a Nanotrasen Employee that has been wrongfully accused of espionage! The exact details of your situation are hazy, but you know that you are innocent.")
			to_chat(H, "You were transferred to this station through a request by the station's security team. You know nothing about this station or the people aboard it.")
			to_chat(H, "<span class='danger'>Remember that you are not affiliated with the Syndicate. Protect yourself and work towards freedom, but remember that you have no place left to go.</span>")

		//Update prisoner availability.
		current_prisoners += H
		if (current_prisoners.len >= MAX_PRISONER_LIMIT)
			can_request_prisoner = FALSE

		//Send the shuttle that they spawned on.
		var/obj/docking_port/destination/transport/station/stationdock = locate(/obj/docking_port/destination/transport/station) in all_docking_ports
		var/obj/docking_port/destination/transport/centcom/centcomdock = locate(/obj/docking_port/destination/transport/centcom) in all_docking_ports

		spawn(59 SECONDS)	//its secretly 59 seconds to make sure they cant unbuckle themselves beforehand
			if(!transport_shuttle.move_to_dock(stationdock))
				message_admins("PRISONER TRANSFER SHUTTLE FAILED TO MOVE! PANIC!")
				return

			//Try to send the shuttle back every 15 seconds
			while(transport_shuttle.current_port == stationdock)
				sleep(150)
				if(!can_move_shuttle())
					continue
			
				sleep(50)	//everyone is off, wait 5 more seconds so people don't get ZAS'd out the airlock
				if(!can_move_shuttle())	
					continue
				if(!transport_shuttle.move_to_dock(centcomdock))
					message_admins("The transport shuttle couldn't return to centcomm for some reason.")
					return
				
//putting it in a proc like this just cleans things up, this is identical to the checks for the cargo shuttle except mimics arent allowed
/datum/event/prisontransfer/proc/can_move_shuttle() 
	var/contents = get_contents_in_object(transport_shuttle.linked_area)	
	if (locate(/mob/living) in contents)
		return FALSE
	if (locate(/obj/item/weapon/disk/nuclear) in contents)
		return FALSE
	if (locate(/obj/machinery/nuclearbomb) in contents)
		return FALSE
	if (locate(/obj/item/beacon) in contents)
		return FALSE
	if (locate(/obj/effect/portal) in contents)
		return FALSE
	return TRUE
