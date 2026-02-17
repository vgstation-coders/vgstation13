/obj/item/device/techsiphon
	name = "tech siphon"
	desc = "A device capable of siphoning research data onto it. Must be used on servers or a completed research archive."
	icon = 'icons/obj/shoal.dmi'
	icon_state = "datatheft_off"
	flags = FPRINT
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_SYNDICATE + "=3;" + Tc_MAGNETS + "=3"


	var/siphon_time = 2 SECONDS		// change this later
	var/operating = FALSE
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
	if(!operating && istype(target, /obj/machinery/r_n_d/server))
		var/obj/machinery/r_n_d/server/server = target
		if(!server.panel_open)
			to_chat(user, "<span class='warning'>You need to open the panel first.</span>")
			return
		visible_message("<span class='notice'>[src] flashes and lets out a beep as it begins loading stored research onto itself.</span>")
		playsound(server, 'sound/machines/twobeep.ogg', 50, 1)
		var/cancelled = FALSE
		operating = TRUE
		update_icon()
		var/nothing_transferred = TRUE
		for(var/ID in server.files.known_tech)
			var/datum/tech/server_tech  = server.files.known_tech[ID]
			var/datum/tech/our_tech = our_files.known_tech[ID]
			if(server_tech <= our_tech)
				continue
			if(do_after(user, server, siphon_time))
				to_chat(user, "<span class='notice'>[server_tech.name] research was successfully loaded onto [src]. New Level: [server_tech.level].</span>")
				playsound(server, "sound/machines/heps.ogg", 30, 1)
				our_tech.level = server_tech.level
				server_tech.level = 1						// Oh well.
				nothing_transferred = FALSE
			else
				playsound(server, 'sound/machines/buzz-sigh.ogg', 50, 1)
				to_chat(user, "<span class='warning'>Procedure cancelled.</span>")
				cancelled = TRUE
				break

		if(!cancelled)
			if(nothing_transferred)
				to_chat(user, "<span class='warning'>A message flashes on [src]: 'No new technologies to transfer.'</span>")
			playsound(loc, "sound/machines/paistartup.ogg", 50, 1)
			to_chat(user, "<span class='notice'>Transfer complete. Caw.</span>")
		operating = FALSE
		update_icon()

/obj/item/device/techsiphon/update_icon()
	icon_state = operating ? "datatheft_on" : "datatheft_off"
