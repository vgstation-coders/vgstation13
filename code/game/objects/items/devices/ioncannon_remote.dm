#define ION_COOLDOWN	15 MINUTES

/obj/item/device/loic_remote
	name = "\improper strange remote"
	desc = "Press the big button to upset people."
	icon = 'icons/obj/device.dmi'
	icon_state = "batterer"
	w_class = W_CLASS_TINY
	flags = FPRINT
	var/last_used = 0

/obj/item/device/loic_remote/process()
	if(world.time - last_used > ION_COOLDOWN)		//Set the icon back to the default if the cooldown expires
		icon_state = "batterer"
		processing_objects.Remove(src)


/obj/item/device/loic_remote/attack_self(var/mob/user)
	if(world.time - last_used < ION_COOLDOWN)
		to_chat(user, "<span class='notice'>The Low Orbit Ion Cannon is still on cooldown.</span>")
		return
	if(alert(user, "A cryptic message appears on the screen: \"Activate the Low Orbit Ion-Cannon?\".", name, "Yes", "No") != "Yes")
		return
	if(user.incapacitated() || !Adjacent(user))
		return
	generate_ion_law()
	command_alert(/datum/command_alert/ion_storm_malicious)
	last_used = world.time
	icon_state = "battererburnt"
	processing_objects.Add(src)

	to_chat(user, "<span class='notice'>\The [src]'s screen flashes green for a moment.</span>")

	message_admins("[key_name_admin(user)] generated an ion law using a LOIC remote.")
	log_admin("[key_name(user)] generated an ion law using a LOIC remote.")

	for (var/obj/machinery/computer/communications/C in machines)
		if(! (C.stat & (BROKEN|NOPOWER) ) )
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "'[command_name()] Update.'"
			P.info = "Station Time: <B>[worldtime2text()]</B><br><br>Malicious Interference with standard AI-Subsystems detected.<br><br>Signal traced to <B>[get_area(src).name]</B>. Investigation recommended."
			P.update_icon()
			C.messagetitle.Add("[command_name()] Update")
			C.messagetext.Add(P.info)

	


		

#undef ION_COOLDOWN
    
