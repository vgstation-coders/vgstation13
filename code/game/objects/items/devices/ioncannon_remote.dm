

/obj/item/device/loic_remote
	name = "\improper strange remote"
	desc = "Press the big button to upset people."
	icon = 'icons/obj/device.dmi'
	icon_state = "batterer"
	w_class = W_CLASS_TINY
	flags = FPRINT
	var/cooldown = 0
	mech_flags = MECH_SCAN_FAIL

/obj/item/device/loic_remote/New()
	processing_objects.Add(src)

/obj/item/device/loic_remote/process()
	update_icon()

/obj/item/device/loic_remote/update_icon()
	icon_state = "batterer[cooldown-world.time < 0 ? "" : "burnt"]"

/obj/item/device/loic_remote/examine(mob/user)
	..()
	if(cooldown-world.time < 0)
		to_chat(user, "<span class='notice'>It is ready to fire.</span>")
	else
		to_chat(user, "<span class='notice'>The Low Orbit Ion Cannon can fire again in [altFormatTimeDuration(cooldown-world.time)].</span>")
/obj/item/device/loic_remote/attack_self(var/mob/user)
	if(cooldown - world.time > 0)
		to_chat(user, "<span class='notice'>The Low Orbit Ion Cannon is still on cooldown.</span>")
		return
	if(alert(user, "A cryptic message appears on the screen: \"Activate the Low Orbit Ion-Cannon?\".", name, "Yes", "No") != "Yes")
		return
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!is_type_in_list(get_area(src), the_station_areas))
		to_chat(user, "The remote can't establish a connection. You need to be on the station.")
		return
	if(cooldown - world.time > 0)	//check again for the cooldown in case people prep a bunch of popups
		to_chat(user, "<span class='notice'>The Low Orbit Ion Cannon is still on cooldown.</span>")
		return
	generate_ion_law()
	command_alert(/datum/command_alert/ion_storm_malicious)
	cooldown = world.time + 15 MINUTES

	to_chat(user, "<span class='notice'>\The [src]'s screen flashes green for a moment.</span>")

	message_admins("[key_name_admin(user)] generated an ion law using a LOIC remote.")
	log_admin("[key_name(user)] generated an ion law using a LOIC remote.")
	if(recursive_type_check(user,/obj/item/device/roganbot/killbot))
		playsound(user.loc,'sound/effects/2003M/Ion_cannon_activated.ogg',100)

	for (var/obj/machinery/computer/communications/C in machines)
		if(! (C.stat & (FORCEDISABLE|BROKEN|NOPOWER) ) )
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "'[command_name()] Update.'"
			P.info = "Station Time: <B>[worldtime2text()]</B><br><br>Malicious Interference with standard AI-Subsystems detected.<br><br>Signal traced to <B>[get_area(src).name]</B>. Investigation recommended."
			P.update_icon()
			C.messagetitle.Add("[command_name()] Update")
			C.messagetext.Add(P.info)





