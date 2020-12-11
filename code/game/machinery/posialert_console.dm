/*************************
*** Posi-Alert Console ***
*************************/

/obj/machinery/posialert_console
	name = "posi-alert console"
	desc = "A console that can notify crew members that there are positronic personalities available for download!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "posialert0"
	anchored = TRUE
	density = FALSE

	//this var will allow ghosts to interact with it when true
	//however, if ghosts are rowdy, living people can turn it off
	var/allow_ghosts = TRUE
	//I don't want the console to spam the living, so maybe a 1-2 minute CD
	var/ghost_cooldown = 0

/obj/machinery/posialert_console/New()
	update_ghost_overlay()
	return ..()

/obj/machinery/posialert_console/attack_hand(mob/user, ignore_brain_damage)
	if(isobserver(user))
		return
	allow_ghosts = !allow_ghosts
	update_ghost_overlay()
	to_chat(user, "<span class='notice'>You turn [allow_ghosts ? "on" : "off"] \the [src].</span>")
	playsound(get_turf(src), 'sound/machines/twobeep.ogg', 50, 1)
	log_game("[key_name(user)] has turned [allow_ghosts ? "on" : "off"] the posi-alert console.")
	return

/obj/machinery/posialert_console/attack_ghost(mob/user)
	if(isAdminGhost(user))
		var/alert = alert(user, "Do you wish to turn [allow_ghosts ? "off" : "on"] \the [src]?", "Confirm", "Yes", "No", "Cancel")
		if(alert == "Yes")
			message_admins("[key_name(user)] has turned [allow_ghosts ? "off" : "on"] \the [src]")
			log_admin("[key_name(user)] has turned [allow_ghosts ? "off" : "on"] \the [src]")
			allow_ghosts = !allow_ghosts
			update_ghost_overlay()
			return
	if(!allow_ghosts)
		to_chat(user, "Someone has turned off \the [src]. Better luck next time!")
		return ..()
	if(stat & NOPOWER)
		to_chat(user, "\The [src] is currently unpowered. Better luck next time!")
		return ..()
	if(ghost_cooldown > world.time)
		to_chat(user, "\The [src] is still on cooldown, come back later!")
		return ..()
	ghost_cooldown = world.time + 1 MINUTES //hopefully 1 minute is enough. at least its adjustable!
	log_game("[key_name(user)] has activated the posi-alert console.")
	visible_message("<span class='notice'>There are positronic personalities available for download!</span>")
	playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1)
	flick("posialert1",src)

/obj/machinery/posialert_console/proc/update_ghost_overlay()
	var/ghost_overlay = allow_ghosts ? "posialert2" : "posialert3"
	overlays.Cut()
	overlays += image(icon, ghost_overlay)
