#define MAX_PRISONER_LIMIT 1

var/global/can_request_prisoner = TRUE
var/list/current_prisoners = list()

/datum/role/prisoner
	name = PRISONER
	id = PRISONER
	special_role = PRISONER
	required_pref = ROLE_MINOR
	wikiroute = ROLE_MINOR
	logo_state = "prisoner-logo"

	var/moneyBonus = 100

/datum/role/prisoner/Greet()
	to_chat(antag.current, "<B><span class='warning'>You are a syndicate prisoner!</span></B>")
	to_chat(antag.current, "You were transferred to this station through a request by the station's security team. You know nothing about this station or the people aboard it.")
	to_chat(antag.current, "<span class='danger'>Do your best to survive or escape, but remember that every move you make could be your last.</span>")


/datum/role/prisoner/OnPostSetup()
	var/mob/living/carbon/human/H = antag.current
	var/datum/outfit/special/prisoner/outfit = new /datum/outfit/special/prisoner
	outfit.equip(H)

	H.name = name
	H.real_name = name
	H.randomise_appearance_for()

	H.regenerate_icons()

	var/obj/structure/bed/chair/chair = pick(prisonerstart)
	antag.current.forceMove(get_turf(chair))
	chair.buckle_mob(H, H)

	var/obj/item/weapon/handcuffs/C = new /obj/item/weapon/handcuffs(H)
	H.equip_to_slot(C, slot_handcuffed)

	command_alert("A request for a prisoner transfer by the security department has been approved. The prisoner will arrive at auxilary docking in approximately 1 minute.", "Prisoner Transfer",1)
	mob_rename_self(H, "prisoner")

	var/obj/docking_port/destination/transport/station/dock = locate(/obj/docking_port/destination/transport/station) in all_docking_ports
	spawn(59 SECONDS)	//its secretly 59 seconds to make sure they cant unbuckle themselves beforehand
		transport_shuttle.move_to_dock(dock)

	current_prisoners += src
	if (current_prisoners.len >= MAX_PRISONER_LIMIT)
		can_request_prisoner = FALSE

	return TRUE

/datum/role/prisoner/proc/AliveAndOnStation()
	if(antag.current.isDead())	
		return FALSE	
	if(antag.current.z != STATION_Z)
		return FALSE
	var/area/A = get_area(antag.current)
	if (isspace(A))
		return FALSE
	return TRUE


/datum/role/prisoner/ForgeObjectives()
	AppendObjective(/datum/objective/survive)
	AppendObjective(/datum/objective/escape_prisoner)
	AppendObjective(/datum/objective/minimize_casualties)

#undef MAX_PRISONER_LIMIT