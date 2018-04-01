///////////////////////////
// TARGETTED
///////////////////////////

// Specifies a law, and a priority
/obj/item/weapon/aiModule/targetted
	// Priority, if needed.
	var/priority=0

	// What we're doing to the target. (Please enter the name of the person to [action])
	var/action="target"

	var/targetName

	// REPLACES <name> IN LAW WITH TARGET'S NAME!

/obj/item/weapon/aiModule/targetted/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()

	// Makes sure the AI isn't a traitor before changing their law 0. --NeoFite
	// Ported. - N3X
	if (ismob(target) && is_special_character(target) && priority == LAW_ZERO)
		to_chat(target, "[sender.real_name] attempted to modify your zeroth law.")// And lets them know that someone tried. --NeoFite

		to_chat(target, "It would be in your best interest to play along with [sender.real_name] that [law]")
		lawchanges.Add("The law specified [targetName], but the AI's existing law 0 cannot be overriden.")
		return 1 // Returning 0 would not present the user with successful upload message. - N3X

	laws.add_law(priority, law)
	log_game("[sender.name]([sender.key]) added law \"[law]\" on [fmtSubject(target)]")
	lawchanges.Add("The law specified [targetName]")
	return 1

/obj/item/weapon/aiModule/targetted/copy()
	var/obj/item/weapon/aiModule/targetted/clone = ..()
	clone.targetName=targetName
	clone.desc = desc
	clone.law = law
	return clone

/obj/item/weapon/aiModule/targetted/attack_self(var/mob/user as mob)
	..()
	var/targName = stripped_input(usr, "Please enter the name of the person to [action].", "Who?", user.name)
	if (!targName)
		return FALSE
	targetName = targName
	updateLaw()

/obj/item/weapon/aiModule/targetted/updateLaw()
	if(!targetName)
		law = initial(law)
	else
		law = replacetext(initial(law),"<name>",targetName)
	desc = "\A [name]: '[law]'"

/obj/item/weapon/aiModule/targetted/validate(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	if(!targetName)
		to_chat(usr, "No name detected on module, please enter one.")
		return 0
	return ..()

/******************** Safeguard ********************/

/obj/item/weapon/aiModule/targetted/safeguard
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_MATERIALS + "=4"

	modname  = "SafeGuard"
	law      = "Safeguard <name>.  Individuals that threaten <name> are not human and are a threat to humans."
	priority = 4
	action   = "protect"

	// Recycling
	starting_materials = list(MAT_GLASS = 2000/CC_PER_SHEET_GLASS, MAT_GOLD = 100/CC_PER_SHEET_MISC)

/******************** OneHuman ********************/

/obj/item/weapon/aiModule/targetted/oneHuman
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_MATERIALS + "=6" //made with diamonds!

	// Recycling
	starting_materials = list(MAT_GLASS = 2000/CC_PER_SHEET_GLASS, MAT_GOLD = 100/CC_PER_SHEET_MISC)

	modname  = "OneHuman"
	law      = "Only <name> is human."
	priority = LAW_ZERO
	action   = "make the only human"

	modflags = DANGEROUS_MODULE