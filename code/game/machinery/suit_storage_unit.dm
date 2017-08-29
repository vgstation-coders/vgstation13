//////////////////////////////////////
// SUIT STORAGE UNIT /////////////////
//////////////////////////////////////


/obj/machinery/suit_storage_unit
	name = "Suit Storage Unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a UV-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\"."
	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "suitstorage-closed-00" //order is: [has helmet][has suit]
	anchored = 1
	density = 1
	var/mob/living/carbon/human/OCCUPANT = null
	var/obj/item/clothing/suit/space/SUIT = null
	var/obj/item/clothing/head/helmet/space/HELMET = null
	var/obj/item/clothing/mask/MASK = null  //All the stuff that's gonna be stored insiiiiiiiiiiiiiiiiiiide, nyoro~n
	var/obj/item/clothing/shoes/BOOTS = null
	var/SUIT_TYPE = null
	var/HELMET_TYPE = null
	var/BOOT_TYPE = null
	var/MASK_TYPE = null //Erro's idea on standarising SSUs whle keeping creation of other SSU types easy: Make a child SSU, name it something then set the TYPE vars to your desired suit output. New() should take it from there by itself.
	var/isopen = 0
	var/islocked = 0
	var/isUV = 0
	var/issuperUV = 0
	var/safetieson = 1
	var/cycletime_left = 0
	var/department = "null"
	var/image/openimage
	var/image/closeimage

	machine_flags = SCREWTOGGLE


//The units themselves/////////////////

/obj/machinery/suit_storage_unit/standard_unit
	SUIT_TYPE = /obj/item/clothing/suit/space
	HELMET_TYPE = /obj/item/clothing/head/helmet/space
	MASK_TYPE = /obj/item/clothing/mask/breath
	BOOT_TYPE = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/atmos
	name = "Atmospheric Suit Storage Unit"
	department = "atmos"
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/atmos
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/atmos
	MASK_TYPE = /obj/item/clothing/mask/breath
	BOOT_TYPE = /obj/item/clothing/shoes/magboots/atmos

/obj/machinery/suit_storage_unit/prison
	name = "Prisoner Suit Storage Unit"
	department = "jail"
	SUIT_TYPE = /obj/item/clothing/suit/space/prison
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/prison
	MASK_TYPE = /obj/item/clothing/mask/breath
	BOOT_TYPE = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/engie
	name = "Engineering Suit Storage Unit"
	department = "engie"
	SUIT_TYPE = /obj/item/clothing/suit/space/rig
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig
	MASK_TYPE = /obj/item/clothing/mask/breath
	BOOT_TYPE = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/elite
	name = "Advanced Suit Storage Unit"
	department = "ce"
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/elite
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/elite
	MASK_TYPE = /obj/item/clothing/mask/breath
	BOOT_TYPE = /obj/item/clothing/shoes/magboots/elite

/obj/machinery/suit_storage_unit/mining
	name = "Miners Suit Storage Unit"
	department = "mine"
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/mining
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/mining
	MASK_TYPE = /obj/item/clothing/mask/breath
	BOOT_TYPE = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/excavation
	name = "Excavation Suit Storage Unit"
	department = "sci"
	SUIT_TYPE = /obj/item/clothing/suit/space/anomaly
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/anomaly
	MASK_TYPE = /obj/item/clothing/mask/breath
	BOOT_TYPE = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/security
	name = "Security Suit Storage Unit"
	department = "sec"
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/security
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/security
	MASK_TYPE = /obj/item/clothing/mask/breath
	BOOT_TYPE = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/medical
	name = "Medical Suit Storage Unit"
	department = "med"
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/medical
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/medical
	MASK_TYPE = /obj/item/clothing/mask/breath
	BOOT_TYPE = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/medical/empty
	isopen = 1
	SUIT_TYPE = null
	HELMET_TYPE = null
	MASK_TYPE = null
	BOOT_TYPE = null

/obj/machinery/suit_storage_unit/meteor_eod //Used for meteor rounds
	name = "Bomb Suit Storage Unit"
	SUIT_TYPE = /obj/item/clothing/suit/bomb_suit
	HELMET_TYPE = /obj/item/clothing/head/bomb_hood
	MASK_TYPE = /obj/item/clothing/mask/gas
	BOOT_TYPE = /obj/item/clothing/shoes/jackboots

/obj/machinery/suit_storage_unit/New()
	. = ..()
	openimage = image(icon,src, "[department]_open")
	closeimage = image(icon,src, "[department]_close")
	src.update_icon()
	if(SUIT_TYPE)
		SUIT = new SUIT_TYPE(src)
	if(HELMET_TYPE)
		HELMET = new HELMET_TYPE(src)
	if(MASK_TYPE)
		MASK = new MASK_TYPE(src)
	if(BOOT_TYPE)
		BOOTS = new BOOT_TYPE(src)

/obj/machinery/suit_storage_unit/update_icon()
	overlays.len = 0
	if((stat & NOPOWER) || (stat & BROKEN))
		icon_state = "suitstorage-off"
		if(department != "null")
			overlays += openimage
		return
	if(!isopen)
		icon_state = "suitstorage-closed-[issuperUV][isUV]"
		if(department != "null")
			overlays += closeimage
	else
		icon_state = "suitstorage-open-[HELMET ? "1" : "0"][SUIT ? "1" : "0"]"
		if(department != "null")
			overlays += openimage

/obj/machinery/suit_storage_unit/power_change()
	if( powered() )
		stat &= ~NOPOWER
		src.update_icon()
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			src.islocked = 0
			src.isopen = 1
			src.update_icon()


/obj/machinery/suit_storage_unit/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(50))
				src.dump_everything() //So suits dont survive all the time
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				src.dump_everything()
				qdel(src)
			return
		else
			return
	return


/obj/machinery/suit_storage_unit/attack_hand(mob/user as mob)
	var/dat
	if(..())
		return
	if(stat & NOPOWER)
		return
	if(src.panel_open) //The maintenance panel is open. Time for some shady stuff

		dat += {"<HEAD><TITLE>Suit storage unit: Maintenance panel</TITLE></HEAD>
			<Font color ='black'><B>Maintenance panel controls</B></font><HR>
			<font color ='grey'>The panel is ridden with controls, button and meters, labeled in strange signs and symbols that <BR>you cannot understand. Probably the manufactoring world's language.<BR> Among other things, a few controls catch your eye.<BR><BR>"}
		dat+= text("<font color ='black'>A small dial with a \"ë\" symbol embroidded on it. It's pointing towards a gauge that reads []</font>.<BR> <font color='blue'><A href='?src=\ref[];toggleUV=1'> Turn towards []</A><BR>",(src.issuperUV ? "15nm" : "185nm"),src,(src.issuperUV ? "185nm" : "15nm") )
		dat+= text("<font color ='black'>A thick old-style button, with 2 grimy LED lights next to it. The [] LED is on.</font><BR><font color ='blue'><A href='?src=\ref[];togglesafeties=1'>Press button</a></font>",(src.safetieson? "<font color='green'><B>GREEN</B></font>" : "<font color='red'><B>RED</B></font>"),src)
		dat+= text("<HR><BR><A href='?src=\ref[];mach_close=suit_storage_unit'>Close panel</A>", user)
		//user << browse(dat, "window=ssu_m_panel;size=400x500")
		//onclose(user, "ssu_m_panel")
	else if(src.isUV) //The thing is running its cauterisation cycle. You have to wait.

		dat += {"<HEAD><TITLE>Suit storage unit</TITLE></HEAD>
			<font color ='red'><B>Unit is cauterising contents with selected UV ray intensity. Please wait.</font></B><BR>"}
		//dat+= "<font colr='black'><B>Cycle end in: [src.cycletimeleft()] seconds. </font></B>"
		//user << browse(dat, "window=ssu_cycling_panel;size=400x500")
		//onclose(user, "ssu_cycling_panel")

	else
		if(!(stat & BROKEN))

			dat += {"<HEAD><TITLE>Suit storage unit</TITLE></HEAD>
				<font color='blue'><font size = 4><B>U-Stor-It Suit Storage Unit, model DS1900</B></FONT><BR>
				<B>Welcome to the Unit control panel.</B><HR>"}
			dat+= text("<font color='black'>Helmet storage compartment: <B>[]</B></font><BR>",(src.HELMET ? HELMET.name : "</font><font color ='grey'>No helmet detected.") )
			if(HELMET && src.isopen)
				dat+=text("<A href='?src=\ref[];dispense_helmet=1'>Dispense helmet</A><BR>",src)
			dat+= text("<font color='black'>Suit storage compartment: <B>[]</B></font><BR>",(src.SUIT ? SUIT.name : "</font><font color ='grey'>No exosuit detected.") )
			if(SUIT && src.isopen)
				dat+=text("<A href='?src=\ref[];dispense_suit=1'>Dispense suit</A><BR>",src)
			dat+= text("<font color='black'>Breathmask storage compartment: <B>[]</B></font><BR>",(src.MASK ? MASK.name : "</font><font color ='grey'>No breathmask detected.") )
			if(MASK && src.isopen)
				dat+=text("<A href='?src=\ref[];dispense_mask=1'>Dispense mask</A><BR>",src)
			dat+= text("<font color='black'>Boot storage compartment: <B>[]</B></font><BR>",(src.BOOTS ? BOOTS.name : "</font><font color ='grey'>No boots detected.") )
			if(BOOTS && src.isopen)
				dat+=text("<A href='?src=\ref[];dispense_boots=1'>Dispense boots</A><BR>",src)
			if(src.OCCUPANT)

				dat += {"<HR><B><font color ='red'>WARNING: Biological entity detected inside the Unit's storage. Please remove.</B></font><BR>
					<A href='?src=\ref[src];eject_guy=1'>Eject extra load</A>"}
			dat+= text("<HR><font color='black'>Unit is: [] - <A href='?src=\ref[];toggle_open=1'>[] Unit</A></font> ",(src.isopen ? "Open" : "Closed"),src,(src.isopen ? "Close" : "Open"))
			if(src.isopen)
				dat+="<HR>"
			else
				dat+= text(" - <A href='?src=\ref[];toggle_lock=1'><font color ='orange'>*[] Unit*</A></font><HR>",src,(src.islocked ? "Unlock" : "Lock") )
			dat+= text("Unit status: []",(src.islocked? "<font color ='red'><B>**LOCKED**</B></font><BR>" : "<font color ='green'><B>**UNLOCKED**</B></font><BR>") )
			dat+= text("<A href='?src=\ref[];start_UV=1'>Start Disinfection cycle</A><BR>",src)
			dat += text("<BR><BR><A href='?src=\ref[];mach_close=suit_storage_unit'>Close control panel</A>", user)
			//user << browse(dat, "window=Suit Storage Unit;size=400x500")
			//onclose(user, "Suit Storage Unit")
		else //Ohhhh shit it's dirty or broken! Let's inform the guy.

			dat += {"<HEAD><TITLE>Suit storage unit</TITLE></HEAD>
				<font color='maroon'><B>Unit chamber is too contaminated to continue usage. Please call for a qualified individual to perform maintenance.</font></B><BR><BR>"}
			dat+= text("<HR><A href='?src=\ref[];mach_close=suit_storage_unit'>Close control panel</A>", user)
			//user << browse(dat, "window=suit_storage_unit;size=400x500")
			//onclose(user, "suit_storage_unit")

	user << browse(dat, "window=suit_storage_unit;size=400x500")
	onclose(user, "suit_storage_unit")
	return


/obj/machinery/suit_storage_unit/Topic(href, href_list) //I fucking HATE this proc
	if(..())
		return 1
	else
		usr.set_machine(src)
		if (href_list["toggleUV"])
			src.toggleUV(usr)
			src.updateUsrDialog()
			src.update_icon()
		if (href_list["togglesafeties"])
			src.togglesafeties(usr)
			src.updateUsrDialog()
			src.update_icon()
		if (href_list["dispense_helmet"])
			src.dispense_helmet(usr)
			src.updateUsrDialog()
			src.update_icon()
		if (href_list["dispense_suit"])
			src.dispense_suit(usr)
			src.updateUsrDialog()
			src.update_icon()
		if (href_list["dispense_mask"])
			src.dispense_mask(usr)
			src.updateUsrDialog()
			src.update_icon()
		if (href_list["dispense_boots"])
			src.dispense_boots(usr)
			src.updateUsrDialog()
			src.update_icon()
		if (href_list["toggle_open"])
			src.toggle_open(usr)
			src.updateUsrDialog()
			src.update_icon()
		if (href_list["toggle_lock"])
			src.toggle_lock(usr)
			src.updateUsrDialog()
			src.update_icon()
		if (href_list["start_UV"])
			src.start_UV(usr)
			src.updateUsrDialog()
			src.update_icon()
		if (href_list["eject_guy"])
			src.eject_occupant(usr)
			src.updateUsrDialog()
			src.update_icon()
	/*if (href_list["refresh"])
		src.updateUsrDialog()*/
	src.add_fingerprint(usr)
	return


/obj/machinery/suit_storage_unit/proc/toggleUV(mob/user as mob)
//	var/protected = 0
//	var/mob/living/carbon/human/H = user
	if(!src.panel_open)
		return

	/*if(istype(H)) //Let's check if the guy's wearing electrically insulated gloves
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(istype(G,/obj/item/clothing/gloves/yellow))
				protected = 1

	if(!protected)
		playsound(get_turf(src), "sparks", 75, 1, -1)
		to_chat(user, "<font color='red'>You try to touch the controls but you get zapped. There must be a short circuit somewhere.</font>")
		return*/
	else  //welp, the guy is protected, we can continue
		if(src.issuperUV)
			to_chat(user, "You slide the dial back towards \"185nm\".")
			src.issuperUV = 0
		else
			to_chat(user, "You crank the dial all the way up to \"15nm\".")
			src.issuperUV = 1
		return


/obj/machinery/suit_storage_unit/proc/togglesafeties(mob/user as mob)
//	var/protected = 0
//	var/mob/living/carbon/human/H = user
	if(!src.panel_open) //Needed check due to bugs
		return

	/*if(istype(H)) //Let's check if the guy's wearing electrically insulated gloves
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(istype(G,/obj/item/clothing/gloves/yellow) )
				protected = 1

	if(!protected)
		playsound(get_turf(src), "sparks", 75, 1, -1)
		to_chat(user, "<font color='red'>You try to touch the controls but you get zapped. There must be a short circuit somewhere.</font>")
		return*/
	else
		to_chat(user, "You push the button. The coloured LED next to it changes.")
		src.safetieson = !src.safetieson


/obj/machinery/suit_storage_unit/proc/dispense_helmet(mob/user as mob)
	if(!src.HELMET)
		return //Do I even need this sanity check? Nyoro~n
	else
		src.HELMET.forceMove(src.loc)
		src.HELMET = null
		return


/obj/machinery/suit_storage_unit/proc/dispense_suit(mob/user as mob)
	if(!src.SUIT)
		return
	else
		src.SUIT.forceMove(src.loc)
		src.SUIT = null
		return


/obj/machinery/suit_storage_unit/proc/dispense_mask(mob/user as mob)
	if(!src.MASK)
		return
	else
		src.MASK.forceMove(src.loc)
		src.MASK = null
		return


/obj/machinery/suit_storage_unit/proc/dispense_boots(mob/user as mob)
	if(!src.BOOTS)
		return
	else
		src.BOOTS.forceMove(src.loc)
		src.BOOTS = null
		return


/obj/machinery/suit_storage_unit/proc/dump_everything()
	src.islocked = 0 //locks go free
	if(src.SUIT)
		src.SUIT.forceMove(src.loc)
		src.SUIT = null
	if(src.HELMET)
		src.HELMET.forceMove(src.loc)
		src.HELMET = null
	if(src.MASK)
		src.MASK.forceMove(src.loc)
		src.MASK = null
	if(src.BOOTS)
		src.BOOTS.forceMove(src.loc)
		src.BOOTS = null
	if(src.OCCUPANT)
		src.eject_occupant(OCCUPANT)
	return


/obj/machinery/suit_storage_unit/proc/toggle_open(mob/user as mob)
	if(src.islocked || src.isUV)
		to_chat(user, "<font color='red'>Unable to open unit.</font>")
		return
	if(src.OCCUPANT)
		src.eject_occupant(user)
		return  // eject_occupant opens the door, so we need to return
	src.isopen = !src.isopen
	return


/obj/machinery/suit_storage_unit/proc/toggle_lock(mob/user as mob)
	if(src.OCCUPANT && src.safetieson)
		to_chat(user, "<font color='red'>The Unit's safety protocols disallow locking when a biological form is detected inside its compartments.</font>")
		return
	if(src.isopen)
		return
	src.islocked = !src.islocked
	return


/obj/machinery/suit_storage_unit/proc/start_UV(mob/user as mob)
	if(src.isUV || src.isopen) //I'm bored of all these sanity checks
		return
	if(src.OCCUPANT && src.safetieson)
		to_chat(user, "<font color='red'><B>WARNING:</B> Biological entity detected in the confines of the Unit's storage. Cannot initiate cycle.</font>")
		return
	if(!src.HELMET && !src.MASK && !src.SUIT && !BOOTS && !src.OCCUPANT ) //shit's empty yo
		to_chat(user, "<font color='red'>Unit storage bays empty. Nothing to disinfect -- Aborting.</font>")
		return
	to_chat(user, "You start the Unit's cauterisation cycle.")
	src.cycletime_left = 20
	src.isUV = 1
	if(src.OCCUPANT && !src.islocked)
		src.islocked = 1 //Let's lock it for good measure
	src.update_icon()
	src.updateUsrDialog()

	var/i //our counter
	for(i=0,i<4,i++)
		sleep(50)
		if(src.OCCUPANT)
			if(src.issuperUV)
				var/burndamage = rand(28,35)
				OCCUPANT.take_organ_damage(0,burndamage)
				OCCUPANT.emote("scream",,, 1)
			else
				var/burndamage = rand(6,10)
				OCCUPANT.take_organ_damage(0,burndamage)
				OCCUPANT.emote("scream",,, 1)
		if(i==3) //End of the cycle
			if(!src.issuperUV)
				if(src.HELMET)
					HELMET.clean_blood()
					HELMET.decontaminate()
				if(src.SUIT)
					SUIT.clean_blood()
					SUIT.decontaminate()
				if(src.MASK)
					MASK.clean_blood()
					MASK.decontaminate()
				if(src.BOOTS)
					BOOTS.clean_blood()
					BOOTS.decontaminate()
			else //It was supercycling, destroy everything
				if(src.HELMET)
					src.HELMET = null
				if(src.SUIT)
					src.SUIT = null
				if(src.MASK)
					src.MASK = null
				if(src.BOOTS)
					src.BOOTS = null
				visible_message("<font color='red'>With a loud whining noise, the Suit Storage Unit's door grinds open. Puffs of ashen smoke come out of its chamber.</font>")
				stat |= BROKEN
				src.isopen = 1
				src.islocked = 0
				src.eject_occupant(OCCUPANT) //Mixing up these two lines causes bug. DO NOT DO IT.
			src.isUV = 0 //Cycle ends
	src.update_icon()
	src.updateUsrDialog()

/obj/machinery/suit_storage_unit/proc/eject_occupant(mob/user as mob)
	if (src.islocked)
		return

	if (!src.OCCUPANT)
		return

	if(OCCUPANT.gcDestroyed)
		update_icon()
		isopen = 1
		OCCUPANT = null
		return
//	for(var/obj/O in src)
//		O.loc = src.loc

	if (src.OCCUPANT.client)
		if(user != OCCUPANT)
			to_chat(OCCUPANT, "<font color='blue'>The machine kicks you out!</font>")
		if(user.loc != src.loc)
			to_chat(OCCUPANT, "<font color='blue'>You leave the not-so-cozy confines of the SSU.</font>")

		src.OCCUPANT.client.eye = src.OCCUPANT.client.mob
		src.OCCUPANT.client.perspective = MOB_PERSPECTIVE
	src.OCCUPANT.forceMove(src.loc)
	src.OCCUPANT = null
	if(!src.isopen)
		src.isopen = 1
	src.update_icon()
	return


/obj/machinery/suit_storage_unit/verb/get_out()
	set name = "Eject Suit Storage Unit"
	set category = "Object"
	set src in oview(1)

	if (usr.isUnconscious())
		return
	src.eject_occupant(usr)
	add_fingerprint(usr)
	src.updateUsrDialog()
	src.update_icon()
	return


/obj/machinery/suit_storage_unit/verb/move_inside()
	set name = "Hide in Suit Storage Unit"
	set category = "Object"
	set src in oview(1)

	if (usr.isUnconscious())
		return
	if (!src.isopen)
		to_chat(usr, "<font color='red'>The unit's doors are shut.</font>")
		return
	if ((stat & NOPOWER) || (stat & BROKEN))
		to_chat(usr, "<font color='red'>The unit is not operational.</font>")
		return
	if ( (src.OCCUPANT) || (src.HELMET) || (src.SUIT) || BOOTS )
		to_chat(usr, "<font color='red'>It's too cluttered inside for you to fit in!</font>")
		return
	visible_message("[usr] starts squeezing into the suit storage unit!")
	if(do_after(usr, src, 10))
		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.forceMove(src)
//		usr.metabslow = 1
		src.OCCUPANT = usr
		src.isopen = 0 //Close the thing after the guy gets inside
		src.update_icon()
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		return
	else
		src.OCCUPANT = null //Testing this as a backup sanity test
	return

/obj/machinery/suit_storage_unit/togglePanelOpen(var/obj/toggleitem, mob/user)
	..()
	src.updateUsrDialog()

/obj/machinery/suit_storage_unit/attackby(obj/item/I as obj, mob/user as mob)
	if((stat & BROKEN) && issolder(I))
		var/obj/item/weapon/solder/S = I
		if(!S.remove_fuel(4,user))
			return
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		if(do_after(user, src,40))
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)
			stat &= !BROKEN
			to_chat(user, "<span class='notice'>You repair the blown out electronics in the suit storage unit.</span>")
	if((stat & NOPOWER) && iscrowbar(I) && !islocked)
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You begin prying the equipment out of the suit storage unit</span>")
		if(do_after(user, src,20))
			dump_everything()
			update_icon()
	if(stat & NOPOWER)
		return
	if(..())
		return 1
	if ( istype(I, /obj/item/weapon/grab) )
		var/obj/item/weapon/grab/G = I
		if( !(ismob(G.affecting)) )
			return
		if (!src.isopen)
			to_chat(usr, "<font color='red'>The unit's doors are shut.</font>")
			return
		if ((stat & NOPOWER) || (stat & BROKEN))
			to_chat(usr, "<font color='red'>The unit is not operational.</font>")
			return
		if ( (src.OCCUPANT) || (src.HELMET) || (src.SUIT) || BOOTS) //Unit needs to be absolutely empty
			to_chat(user, "<font color='red'>The unit's storage area is too cluttered.</font>")
			return
		visible_message("[user] starts putting [G.affecting.name] into the Suit Storage Unit.")
		if(do_after(user, src, 20))
			if(!G || !G.affecting)
				return //derpcheck
			var/mob/M = G.affecting
			if (M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.forceMove(src)
			src.OCCUPANT = M
			src.isopen = 0 //close ittt

			//for(var/obj/O in src)
			//	O.loc = src.loc
			src.add_fingerprint(user)
			qdel(G)
			G = null
			src.updateUsrDialog()
			src.update_icon()
			return
		return
	if( istype(I,/obj/item/clothing/suit/space) )
		if(!src.isopen)
			return
		var/obj/item/clothing/suit/space/S = I
		if(src.SUIT)
			to_chat(user, "<font color='blue'>The unit already contains a suit.</font>")
			return
		if(user.drop_item(S, src))
			to_chat(user, "You load the [S.name] into the storage compartment.")
			src.SUIT = S
			src.update_icon()
			src.updateUsrDialog()
		return
	if( istype(I,/obj/item/clothing/head/helmet) )
		if(!src.isopen)
			return
		var/obj/item/clothing/head/helmet/H = I
		if(src.HELMET)
			to_chat(user, "<font color='blue'>The unit already contains a helmet.</font>")
			return
		if(user.drop_item(H, src))
			to_chat(user, "You load the [H.name] into the storage compartment.")
			src.HELMET = H
			src.update_icon()
			src.updateUsrDialog()
			return
	if( istype(I,/obj/item/clothing/mask) )
		if(!src.isopen)
			return
		var/obj/item/clothing/mask/M = I
		if(src.MASK)
			to_chat(user, "<font color='blue'>The unit already contains a mask.</font>")
			return
		if(user.drop_item(M, src))
			to_chat(user, "You load the [M.name] into the storage compartment.")
			src.MASK = M
			src.update_icon()
			src.updateUsrDialog()
		return
	if( istype(I,/obj/item/clothing/shoes) )
		if(!src.isopen)
			return
		var/obj/item/clothing/shoes/M = I
		if(src.BOOTS)
			to_chat(user, "<font color='blue'>The unit already contains shoes.</font>")
			return
		if(user.drop_item(M, src))
			to_chat(user, "You load \the [M.name] into the storage compartment.")
			src.BOOTS = M
			src.update_icon()
			src.updateUsrDialog()
		return
	src.update_icon()
	src.updateUsrDialog()
	return


/obj/machinery/suit_storage_unit/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)


/obj/machinery/suit_storage_unit/attack_paw(mob/user as mob)
	to_chat(user, "<font color='blue'>The console controls are far too complicated for your tiny brain!</font>")
	return


//////////////////////////////REMINDER: Make it lock once you place some fucker inside.
