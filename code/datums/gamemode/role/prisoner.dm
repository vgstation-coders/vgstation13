/datum/role/prisoner
	name = PRISONER
	id = PRISONER
	special_role = PRISONER
	required_pref = ROLE_MINOR
	wikiroute = ROLE_MINOR
	logo_state = "prisoner-logo"

/datum/role/prisoner/Greet()
	to_chat(antag.current, "<B><span class='warning'>You are a syndicate prisoner!</span></B>")
	to_chat(antag.current, "You were transferred to this station through a request by the station's security team. You know nothing about this station or the people aboard it.")
	to_chat(antag.current, "<span class='danger'>Do your best to survive or escape, but remember that every move you make could be your last.</span>")


/datum/role/prisoner/OnPostSetup()
	var/mob/living/carbon/human/H = antag.current
	var/datum/outfit/special/prisoner/outfit = new /datum/outfit/special/prisoner
	outfit.equip(H)
	
	if(prob(50))
		H.setGender(MALE)
	else
		H.setGender(FEMALE)

	var/name = random_name(H.gender)
	H.name = name
	H.real_name = name
	H.my_appearance.h_style = random_hair_style(H.gender)
	H.my_appearance.f_style = random_facial_hair_style(H.gender)
	H.my_appearance.s_tone = random_skin_tone()

	H.UpdateAppearance()
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

	return TRUE

/datum/role/prisoner/ForgeObjectives()
	AppendObjective(/datum/objective/survive)
