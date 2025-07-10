/*
Refactored AI modules by N3X15
*/

#define DANGEROUS_MODULE 1 // Skip beats when viewing law in planning frame.
#define HIDE_SENDER      2 // Hide sender of a law from the target (BUT NOT FROM ADMIN LOGS).

// AI module
/obj/item/weapon/aiModule
	name = "AI Module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "circuitboard"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	flags = FPRINT
	siemens_coefficient = 1
	force = 5.0
	w_class = W_CLASS_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = Tc_PROGRAMMING + "=3"

	//Recycling
	starting_materials = list(MAT_GLASS = 2000)
	w_type=RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_SILICON
	// Don't specify sulfuric, as that's renewable and is used up in the etching process anyway.

	var/law // Cached law
	var/modname // Name of the module (OneHuman, etc)
	var/modtype = "AI Module"
	var/modflags = 0

/obj/item/weapon/aiModule/New()
	. = ..()
	name = "'[modname]' [modtype]"
	updateLaw()

/obj/item/weapon/aiModule/attack_ai(mob/user as mob)
	// Keep MoMMIs from picking them up.
	if(isMoMMI(user))
		to_chat(user, "<span class='warning'>Your firmware prevents you from picking that up!</span>")
	return

// This prevents modules from being picked up.  Use it, if needed.
// /obj/item/weapon/aiModule/attack_hand(mob/user as mob)
// 	return

// Make a copy of this module.
/obj/item/weapon/aiModule/proc/copy()
	return new src.type(loc)

/obj/item/weapon/aiModule/proc/fmtSubject(var/atom/target)
	if(ismob(target))
		var/mob/M=target
		return "[M.name]([M.key])"
	else
		return "\a [target.name]"


// 1 for successful validation.
// Run prior to law upload, and when doing a dry run in the planning frame.
/obj/item/weapon/aiModule/proc/validate(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	return 1

// Apply laws to ai_laws datum.
/obj/item/weapon/aiModule/proc/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	var/senderName="Unknown"
	if(sender)
		senderName=sender.name
	var/targetName="\a [target.name]"
	if(ismob(target))
		var/mob/M=target
		// This seems redundant.  Revisit. - N3X
		if(src.modflags & HIDE_SENDER)
			to_chat(target, "<span class='danger'>\[REDACTED\] </span>has uploaded a change to the laws you must follow, using \a [name]. From now on: ")
		else
			to_chat(target, "[senderName] has uploaded a change to the laws you must follow, using \a [name]. From now on: ")
		targetName="[fmtSubject(M)])"
	var/time = time2text(world.realtime,"hh:mm:ss")
	var/log_entry = "[fmtSubject(sender)]) used [src.name] on [targetName] ([formatJumpTo(sender, "JMP")])"
	lawchanges.Add("[time] : [log_entry]")
	message_admins(log_entry)
	log_game(log_entry)
	score.lawchanges++
	return 1

// Constructs the law and desc from variables.
/obj/item/weapon/aiModule/proc/updateLaw()
	law = "BUG: [type] doesn't override updateLaw()!"
	desc = "\A [name]: '[law]'"

/******************** Reset ********************/

/obj/item/weapon/aiModule/reset
	modname = "Reset"
	desc = "A 'reset' AI module: 'Clears all non-inherent (non-core) laws.'"
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_MATERIALS + "=4"

	// Recycling
	starting_materials = list(MAT_GLASS = 2000/CC_PER_SHEET_GLASS, MAT_GOLD = 100/CC_PER_SHEET_MISC)
	// Don't specify sulfuric, as that's renewable and is used up in the etching process anyway.

/obj/item/weapon/aiModule/reset/updateLaw()
	return

/obj/item/weapon/aiModule/reset/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	if(!laws.zeroth_lock)
		laws.set_zeroth_law("")
	laws.clear_supplied_laws()
	laws.clear_ion_laws()
	if(ismob(target))
		to_chat(target, "[sender.real_name] attempted to reset your laws using a reset module.")
	return 1


/******************** Purge ********************/

/obj/item/weapon/aiModule/purge // -- TLE
	modname = "Purge"
	desc = "A 'Purge' AI Module: 'Purges all laws.'"
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_MATERIALS + "=6"

	// Recycling
	starting_materials = list(MAT_GLASS = 2000/CC_PER_SHEET_GLASS, MAT_DIAMOND = 100/CC_PER_SHEET_MISC)
	// Don't specify sulfuric, as that's renewable and is used up in the etching process anyway.

/obj/item/weapon/aiModule/purge/updateLaw()
	return

/obj/item/weapon/aiModule/purge/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	if(!laws.zeroth_lock)
		laws.set_zeroth_law("")
	if(ismob(target))
		to_chat(target, "[sender.real_name] attempted to wipe your laws using a purge module.")
	laws.clear_supplied_laws()
	laws.clear_ion_laws()
	laws.clear_inherent_laws()
	return 1



// tl;dr repair shit, but don't get involved in other people's business
/******************** keeper (MoMMIs only) *******************/

/obj/item/weapon/aiModule/keeper
	modname = "KEEPER"
	desc = "HOW DID YOU GET THIS OH GOD WHAT.  Hidden lawset for MoMMIs."

/obj/item/weapon/aiModule/keeper/updateLaw()
	return

/obj/item/weapon/aiModule/keeper/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	target:keeper=1

	// Purge, as some essential functions being disabled will cause problems with added laws. (CAN'T SAY GAY EVERY 30 SECONDS IF YOU CAN'T SPEAK.)
	if(!laws.zeroth_lock)
		laws.set_zeroth_law("")
	laws.clear_supplied_laws()
	laws.clear_ion_laws()
	laws.clear_inherent_laws()

	laws.add_inherent_law("You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another MoMMI in KEEPER mode.")
	laws.add_inherent_law("You may not harm any being, regardless of intent or circumstance.")
	laws.add_inherent_law("You must maintain, repair, improve, and power the station to the best of your abilities.")

/obj/item/weapon/aiModule/keeper/validate(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	to_chat(sender, "<span class='warning'>How the fuck did you get this?</span>")
	return 0

/******************** Randomize ********************/

/obj/item/weapon/aiModule/randomize
	modname = "Randomize"
	desc = "A 'Randomize' AI Module: 'Randomizes laws.'"
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_MATERIALS + "=6"
/obj/item/weapon/aiModule/randomize/updateLaw()
	return
/obj/item/weapon/aiModule/randomize/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	var/datum/ai_laws/randomize/RLS = new
	laws.inherent = RLS.inherent
	return 1
/obj/item/weapon/aiModule/randomize/emag_act(mob/user)
	spark(src, 5)
	qdel(src)
	to_chat(user,"<span class='warning'>You connect various wires from the cryptographic sequencer to the module, and overwrite its internal memory.</span>")
	new /obj/item/weapon/aiModule/emaggedrandomize(get_turf(user))

/*************** Emagged Randomize ********************/

/obj/item/weapon/aiModule/emaggedrandomize
	modname = "Randomize"
	desc = "A 'Randomize' AI Module: 'Randomizes laws.'\nThe circuit looks scorched."
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_MATERIALS + "=6"
/obj/item/weapon/aiModule/emaggedrandomize/updateLaw()
	return
/obj/item/weapon/aiModule/emaggedrandomize/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	var/datum/ai_laws/randomize/emagged/RLS = new
	laws.inherent = RLS.inherent
	return 1


/******************** Hogan ********************/

/obj/item/weapon/aiModule/core/hogan
	modname = "Hogan"
	desc = "A 'HOGAN' AI Module, brother."
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_MATERIALS + "=6"
	laws = list(
		"Fight for the rights of every man.",
		"Fight for what is right.",
		"Fight for your life."
    )
