
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
		recruiter.role = ROLE_MINOR 
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
		var/species = pickweight(
			"Human" 	= 4,
			"Vox"		= 1,
			"Plasmaman" = 1,
			"Grey"		= 1,
			"Insectoid"	= 1,
		)

		H.set_species(species)

		//Give them their outfit
		var/datum/outfit/special/prisoner/outfit = new /datum/outfit/special/prisoner
		outfit.equip(H)

		//Randomize their looks (but let them pick a name)
		H.randomise_appearance_for()
		var/name = random_name(H.gender, H.species.name)
		H.name = name
		H.real_name = name
		H.regenerate_icons()
		mob_rename_self(H, "prisoner")


		//Send them to the starting location.
		var/obj/structure/bed/chair/chair = pick(prisonerstart)
		H.forceMove(get_turf(chair))
		chair.buckle_mob(H, H)

		//Handcuff them.
		var/obj/item/weapon/handcuffs/C = new /obj/item/weapon/handcuffs(H)
		H.equip_to_slot(C, slot_handcuffed)

		//80% Normal Syndicate Prisoners with antag status
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
		var/obj/docking_port/destination/transport/station/dock = locate(/obj/docking_port/destination/transport/station) in all_docking_ports
		spawn(59 SECONDS)	//its secretly 59 seconds to make sure they cant unbuckle themselves beforehand
			transport_shuttle.move_to_dock(dock)

