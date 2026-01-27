/obj/item/device/techsiphon
	name = "tech siphon"
	desc = "A device capable of siphoning research data onto it. Must be used on servers or a completed research archive."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "disk"

	var/siphon_time = 2 SECONDS		// change this later
	var/datum/research/our_files

/obj/item/device/techsiphon/New()
	..()
	our_files = new(src)

/obj/item/device/techsiphon/examine(mob/user)
	. = ..()
	for(var/ID in our_files.known_tech)
		var/datum/tech/T = our_files.known_tech[ID]
		to_chat(user,"<span class='info'>[T.id] research is level [T.level].")


/obj/item/device/techsiphon/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /obj/machinery/r_n_d/server))
		var/obj/machinery/r_n_d/server/server = target
		if(!server.panel_open)
			to_chat(user, "<span class='warning'>You need to open the panel first.</span>")
			return
		visible_message("<span class='notice'>[src] flashes and lets out a beep as it begins loading stored research onto itself.</span>")
		playsound(server, 'sound/machines/twobeep.ogg', 50, 1)
		var/cancelled = FALSE
		for(var/ID in server.files.known_tech)
			if(do_after(user, server, siphon_time))
				var/datum/tech/server_tech  = server.files.known_tech[ID]
				var/datum/tech/our_tech = our_files.known_tech[ID]
				if(server_tech > our_tech)
					to_chat(user, "<span class='notice'>[server_tech.name] research was successfully loaded onto [src]. New Level: [server_tech.level].</span>")
					playsound(server, "sound/machines/heps.ogg", 30, 1)
					our_tech.level = server_tech.level
					server_tech.level = 1						// Oh well.
				else
					to_chat(user, "<span class='warning'>Skipping [server_tech.name] research... [server_tech.name] research level [server_tech.level] already exists.</span>")
			else
				playsound(server, 'sound/machines/buzz-sigh.ogg', 50, 1)
				to_chat(user, "<span class='warning'>Procedure cancelled.</span>")
				cancelled = TRUE
				break
		if(!cancelled)
			playsound(loc, "sound/machines/paistartup.ogg", 50, 1)
			to_chat(user, "<span class='notice'>Transfer complete. Caw.</span>")

