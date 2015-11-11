// Hey turns out some dumbass decided to make /obj/machinery/door a non abstract class that's completely designed to be an airlock (there's even flavour text for this...), so now we gotta override a million things!
/obj/machinery/door/clockcult
	name			= "Clockwork door"
	desc			= "Not your usual door."

	// icon 
	// icon_state

	explosion_block	= 1 

	machine_flags	= 0 // Nice abstraction oldcoders.
	autoclose		= 1 // No, we really can't trust people to close the door behind their fucking back.

/obj/machinery/door/clockcult/New()
	. = ..()

	global.clockcult_TC++

/obj/machinery/door/clockcult/Destroy()
	. = ..()

	global.clockcult_TC--

// Hey ideally I would ONLY override bump_open() but that would end with stupid shit like mechs and bots opening it.
// Because oldcoders don't know what an abstract class is.
/obj/machinery/door/clockcult/Bumped(var/atom/movable/AM)
	if(ismob(AM))
		var/mob/M = AM

		// You can only bump open one airlock per second.
		// This is apperently to prevent spam.
		if(world.time - M.last_bumped <= DOOR_BUMP_DELAY)
			return
		M.last_bumped = world.time

		mob_interaction(M)

		return

	// Let's not do non Neovegre mechs because the mechs don't actually involve the mob riding it touching the airlock.
	// I assume for normal airlocks the mech uses RC magic or something.
	// Yes you could say that normal airlocks shouldn't open for the Neoverge, but to that I say this is a gamemode based on magic.
	// Of course next argument will be that due to magic clockcult people in mechs can use magic from inside the mech.
	// Commented out until the Neovegre is actually implemented.
	/*
	if(istype(AM, /obj/mecha/neovegre))
		open()
		return
	*/

// Hey look we'll do proper code here!
/obj/machinery/door/clockcult/proc/mob_interaction(var/mob/user)
	if(isclockcult(user))
		if(density)
			open()
		else
			close()
		return 1

	if(iscult(user)) // Burn his hand(s).
		user << "<span class='clockwork'>\"Do you really think it'll open?\"</span>"
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/datum/organ/external/O = H.organs_by_name[pick("l_hand", "r_hand")] // Yes this will give them a 50% chance to not be harmed if they're missing a hand but eh.
			if(O)
				O.take_damage(burn = 10)

		return 1

	door_animate("deny")

// Now we override this so it calls our sensible non copy pasta mob_interaction().
/obj/machinery/door/clockcult/attackby(var/obj/item/W, var/mob/user)
	return attack_hand(user)

/obj/machinery/door/clockcult/attack_hand(var/mob/user)
	return mob_interaction(user)

/obj/machinery/door/clockcult/CanAStarPass(var/obj/item/weapon/card/id/ID)
	return !density