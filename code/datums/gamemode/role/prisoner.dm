


/datum/role/prisoner
	name = PRISONER
	id = PRISONER
	special_role = PRISONER
	required_pref = ROLE_MINOR
	wikiroute = ROLE_MINOR
	logo_state = "prisoner-logo"

	var/moneyBonus = 100

/datum/role/prisoner/Greet()
	to_chat(antag.current, "<B><span class='warning'>You are a Syndicate prisoner!</span></B>")
	to_chat(antag.current, "You were transferred to this station from another facility. You know nothing about this station or the people aboard it.")
	to_chat(antag.current, "<span class='danger'>Do your best to survive and escape, but remember that every move you make could be your last.</span>")

/datum/role/prisoner/ForgeObjectives()
	AppendObjective(/datum/objective/survive)
	AppendObjective(/datum/objective/escape_prisoner)
	AppendObjective(/datum/objective/minimize_casualties)

/datum/role/prisoner/OnPostSetup(var/laterole = FALSE)
	..()
	//Make the prisoner
	var/mob/living/carbon/human/H = antag.current
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

	//Update prisoner availability.
	current_prisoners += H
	if (current_prisoners.len >= MAX_PRISONER_LIMIT)
		can_request_prisoner = FALSE


