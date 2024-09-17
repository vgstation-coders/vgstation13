/obj/item/device/radstorm_remote
	name = "\improper suspicious radio"
	desc = "Press the button for free powers!"
	icon = 'icons/obj/device.dmi'
	icon_state = "rad_remote"
	w_class = W_CLASS_TINY
	flags = FPRINT
	var/cooldown = 0
	mech_flags = MECH_SCAN_FAIL

/obj/item/device/radstorm_remote/New()
	processing_objects.Add(src)

/obj/item/device/radstorm_remote/process()
	update_icon()

/obj/item/device/radstorm_remote/update_icon()
	icon_state = "[cooldown-world.time < 0 ? "rad_remote" : "rad_remote_off"]"

/obj/item/device/radstorm_remote/examine(mob/user)
	..()
	if(cooldown-world.time < 0)
		to_chat(user, "<span class='notice'>It is ready to fire.</span>")
	else
		to_chat(user, "<span class='notice'>The bluespace artillery piece can fire again in [altFormatTimeDuration(cooldown-world.time)].</span>")
/obj/item/device/radstorm_remote/attack_self(var/mob/user)
	for(var/datum/event/radiation_storm/I in events)
		to_chat(user, "<span class='notice'>There's a radiation storm ongoing!</span>")
		return
	if(cooldown - world.time > 0)
		to_chat(user, "<span class='notice'>The bluespace artillery is still being reloaded.</span>")
		return
	if(alert(user, "A cryptic message appears on the screen: \"Fire the Orbital Intercept?\".", name, "Yes", "No") != "Yes")
		return
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!is_type_in_list(get_area(src), the_station_areas))
		to_chat(user, "The remote can't establish a connection. You need to be on the station.")
		return
	if(cooldown - world.time > 0)	//check again for the cooldown in case people prep a bunch of popups
		to_chat(user, "<span class='notice'>The bluespace artillery is still being reloaded.</span>")
		return

	var/datum/event/radiation_storm/D = new /datum/event/radiation_storm(FALSE)
	D.syndiestorm = TRUE
	D.setup()
	events.Add(D)

	cooldown = world.time + 15 MINUTES

	to_chat(user, "<span class='notice'>\The [src] locks in and sends the go for launch!</span>")

	message_admins("[key_name_admin(user)] generated a rad storm using a radstorm remote.")
	log_admin("[key_name(user)] generated a rad storm using a radstorm remote.")

	for (var/obj/machinery/computer/communications/C in machines)
		if(! (C.stat & (FORCEDISABLE|BROKEN|NOPOWER) ) )
			sleep(10 SECONDS) //the same delay after the boom
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "'[command_name()] Update.'"
			P.info = "Station Time: <B>[worldtime2text()]</B><br><br>Suspicious signal intercepted with a signature matching that of the explosion that precluded the radiation storm.<br><br>Signal traced to <B>[get_area(src).name]</B>. Investigation recommended."
			P.update_icon()
			C.messagetitle.Add("[command_name()] Update")
			C.messagetext.Add(P.info)
