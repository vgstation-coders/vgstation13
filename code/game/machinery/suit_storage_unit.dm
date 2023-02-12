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
	var/mob/living/carbon/human/occupant = null
	var/obj/item/clothing/suit/space/suit = null
	var/obj/item/clothing/head/helmet/space/helmet = null
	var/obj/item/clothing/mask/mask = null  //All the stuff that's gonna be stored insiiiiiiiiiiiiiiiiiiide, nyoro~n
	var/obj/item/clothing/shoes/boots = null
	var/suit_type = null
	var/helmet_type = null
	var/boot_type = null
	var/mask_type = null //Erro's idea on standarising SSUs whle keeping creation of other SSU types easy: Make a child SSU, name it something then set the TYPE vars to your desired suit output. New() should take it from there by itself.
	var/isopen = 0
	var/islocked = 0
	var/isUV = 0
	var/issuperUV = 0
	var/safetieson = 1
	var/cycletime_left = 0
	var/department = "null"
	var/image/openimage
	var/image/closeimage

	machine_flags = SCREWTOGGLE | EMAGGABLE

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag
	)


//The units themselves/////////////////

/obj/machinery/suit_storage_unit/standard_unit
	suit_type = /obj/item/clothing/suit/space
	helmet_type = /obj/item/clothing/head/helmet/space
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/atmos
	name = "Atmospheric Suit Storage Unit"
	department = "atmos"
	suit_type = /obj/item/clothing/suit/space/rig/atmos
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots/atmos
	req_access = list(access_atmospherics)

/obj/machinery/suit_storage_unit/prison
	name = "Prisoner Suit Storage Unit"
	department = "jail"
	suit_type = /obj/item/clothing/suit/space/prison
	helmet_type = /obj/item/clothing/head/helmet/space/prison
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/engie
	name = "Engineering Suit Storage Unit"
	department = "engie"
	suit_type = /obj/item/clothing/suit/space/rig/engineer
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots
	req_access = list(access_engine_minor)

/obj/machinery/suit_storage_unit/engie/empty
	isopen = 1
	suit_type = null
	helmet_type = null
	mask_type = null
	boot_type = null

/obj/machinery/suit_storage_unit/elite
	name = "Advanced Suit Storage Unit"
	department = "ce"
	suit_type = /obj/item/clothing/suit/space/rig/engineer/elite
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots/elite
	req_access = list(access_ce)

/obj/machinery/suit_storage_unit/mining
	name = "Miners Suit Storage Unit"
	department = "mine"
	suit_type = /obj/item/clothing/suit/space/rig/mining
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots
	req_access = list(access_mining)

/obj/machinery/suit_storage_unit/excavation
	name = "Excavation Suit Storage Unit"
	department = "sci"
	suit_type = /obj/item/clothing/suit/space/rig/arch
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots
	req_access = list(access_science)

/obj/machinery/suit_storage_unit/ror
	name = "Survivor's Suit Storage Unit"
	department = "sci"
	suit_type = /obj/item/clothing/suit/space/rig/ror
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/security
	name = "Security Suit Storage Unit"
	department = "sec"
	suit_type = /obj/item/clothing/suit/space/rig/security
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots
	req_access = list(access_security)
	holds_armory_items = TRUE

/obj/machinery/suit_storage_unit/captain
	name = "Command Suit Storage Unit"
	department = "cap"
	suit_type = /obj/item/clothing/suit/space/rig/captain
	helmet_type = null
	mask_type = /obj/item/clothing/mask/gas
	boot_type = /obj/item/clothing/shoes/magboots/captain
	req_access = list(access_captain)

/obj/machinery/suit_storage_unit/medical
	name = "Medical Suit Storage Unit"
	department = "med"
	suit_type = /obj/item/clothing/suit/space/rig/medical
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots
	req_access = list(access_medical)

/obj/machinery/suit_storage_unit/medical/empty
	isopen = 1
	suit_type = null
	helmet_type = null
	mask_type = null
	boot_type = null

/obj/machinery/suit_storage_unit/meteor_eod //Used for meteor rounds
	name = "Bomb Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/bomb_suit
	helmet_type = /obj/item/clothing/head/bomb_hood
	mask_type = /obj/item/clothing/mask/gas
	boot_type = /obj/item/clothing/shoes/jackboots

/obj/machinery/suit_storage_unit/trauma_team
	name = "Trauma Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/rig/traumateam
	mask_type = /obj/item/clothing/mask/gas
	boot_type = /obj/item/clothing/shoes/magboots/trauma

/obj/machinery/suit_storage_unit/New()
	. = ..()
	openimage = image(icon,src, "[department]_open")
	closeimage = image(icon,src, "[department]_close")
	update_icon()
	if(suit_type)
		suit = new suit_type(src)
	if(helmet_type)
		helmet = new helmet_type(src)
	if(mask_type)
		mask = new mask_type(src)
	if(boot_type)
		boots = new boot_type(src)

/obj/machinery/suit_storage_unit/update_icon()
	overlays.len = 0
	if((stat & (FORCEDISABLE|NOPOWER)) || (stat & BROKEN))
		icon_state = "suitstorage-off"
		if(department != "null")
			overlays += openimage
		return
	if(!isopen)
		icon_state = "suitstorage-closed-[issuperUV][isUV]"
		if(department != "null")
			overlays += closeimage
	else
		icon_state = "suitstorage-open-[helmet ? "1" : "0"][suit ? "1" : "0"]"
		if(department != "null")
			overlays += openimage

/obj/machinery/suit_storage_unit/power_change()
	if( powered() )
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			islocked = 0
			isopen = 1
			dump_everything(include_suit=FALSE)
			update_icon()


/obj/machinery/suit_storage_unit/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(50))
				dump_everything() //So suits dont survive all the time
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				dump_everything()
				qdel(src)
			return
		else
			return

/obj/machinery/suit_storage_unit/emag_act(var/mob/user)
	emagged = TRUE
	spark(src)
	to_chat(user, "<span class='danger'>You short out the locking mechanism, dumping the contents</span>")
	dump_everything()

/obj/machinery/suit_storage_unit/attack_hand(mob/user as mob)
	var/dat
	if(..())
		return
	if(stat & (FORCEDISABLE|NOPOWER))
		return
	if(emagged)

		dat += {"<HEAD><TITLE>Suit storage unit</TITLE></HEAD>
			<font color='maroon'><B>Unit locking and storage system is shorted. Please call for a qualified individual to perform maintenance.</font></B><BR><BR>"}
		dat+= text("<HR><A href='?src=\ref[];mach_close=suit_storage_unit'>Close control panel</A>", user)
	else if(panel_open) //The maintenance panel is open. Time for some shady stuff

		dat += {"<HEAD><TITLE>Suit storage unit: Maintenance panel</TITLE></HEAD>
			<Font color ='black'><B>Maintenance panel controls</B></font><HR>
			<font color ='grey'>The panel is ridden with controls, button and meters, labeled in strange signs and symbols that <BR>you cannot understand. Probably the manufactoring world's language.<BR> Among other things, a few controls catch your eye.<BR><BR>"}
		dat+= text("<font color ='black'>A small dial with a \"ë\" symbol embroidded on it. It's pointing towards a gauge that reads []</font>.<BR> <font color='blue'><A href='?src=\ref[];toggleUV=1'> Turn towards []</A><BR>",(issuperUV ? "15nm" : "185nm"),src,(issuperUV ? "185nm" : "15nm") )
		dat+= text("<font color ='black'>A thick old-style button, with 2 grimy LED lights next to it. The [] LED is on.</font><BR><font color ='blue'><A href='?src=\ref[];togglesafeties=1'>Press button</a></font>",(safetieson? "<font color='green'><B>GREEN</B></font>" : "<font color='red'><B>RED</B></font>"),src)
		dat+= text("<HR><BR><A href='?src=\ref[];mach_close=suit_storage_unit'>Close panel</A>", user)
		//user << browse(dat, "window=ssu_m_panel;size=400x500")
		//onclose(user, "ssu_m_panel")
	else if(isUV) //The thing is running its cauterisation cycle. You have to wait.

		dat += {"<HEAD><TITLE>Suit storage unit</TITLE></HEAD>
			<font color ='red'><B>Unit is cauterising contents with selected UV ray intensity. Please wait.</font></B><BR>"}
		//dat+= "<font colr='black'><B>Cycle end in: [cycletimeleft()] seconds. </font></B>"
		//user << browse(dat, "window=ssu_cycling_panel;size=400x500")
		//onclose(user, "ssu_cycling_panel")

	else
		if(!(stat & BROKEN))

			dat += {"<HEAD><TITLE>Suit storage unit</TITLE></HEAD>
				<font color='blue'><font size = 4><B>U-Stor-It Suit Storage Unit, model DS1900</B></FONT><BR>
				<B>Welcome to the Unit control panel.</B><HR>"}
			dat+= text("<font color='black'>Helmet storage compartment: <B>[]</B></font><BR>",(helmet ? helmet.name : "</font><font color ='grey'>No helmet detected.") )
			if(helmet && isopen)
				dat+=text("<A href='?src=\ref[];dispense_helmet=1'>Dispense helmet</A><BR>",src)
			dat+= text("<font color='black'>Suit storage compartment: <B>[]</B></font><BR>",(suit ? suit.name : "</font><font color ='grey'>No exosuit detected.") )
			if(istype(suit, /obj/item/clothing/suit/space/rig))
				var/obj/item/clothing/suit/space/rig/R = suit
				dat += "<font color = 'black'>Rig internal cell charge: [R.cell.percent()]%<BR>"
			if(suit && isopen)
				dat+=text("<A href='?src=\ref[];dispense_suit=1'>Dispense suit</A><BR>",src)
			dat+= text("<font color='black'>Breathmask storage compartment: <B>[]</B></font><BR>",(mask ? mask.name : "</font><font color ='grey'>No breathmask detected.") )
			if(mask && isopen)
				dat+=text("<A href='?src=\ref[];dispense_mask=1'>Dispense mask</A><BR>",src)
			dat+= text("<font color='black'>Boot storage compartment: <B>[]</B></font><BR>",(boots ? boots.name : "</font><font color ='grey'>No boots detected.") )
			if(boots && isopen)
				dat+=text("<A href='?src=\ref[];dispense_boots=1'>Dispense boots</A><BR>",src)
			if(occupant)

				dat += {"<HR><B><font color ='red'>WARNING: Biological entity detected inside the Unit's storage. Please remove.</B></font><BR>
					<A href='?src=\ref[src];eject_guy=1'>Eject extra load</A>"}
			dat+= text("<HR><font color='black'>Unit is: [] - <A href='?src=\ref[];toggle_open=1'>[] Unit</A></font> ",(isopen ? "Open" : "Closed"),src,(isopen ? "Close" : "Open"))
			if(isopen)
				dat+="<HR>"
			else
				dat+= text(" - <A href='?src=\ref[];toggle_lock=1'><font color ='orange'>*[] Unit*</A></font><HR>",src,(islocked ? "Unlock" : "Lock") )
			dat+= text("Unit status: []",(islocked? "<font color ='red'><B>**LOCKED**</B></font><BR>" : "<font color ='green'><B>**UNLOCKED**</B></font><BR>") )
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
			toggleUV(usr)
			updateUsrDialog()
			update_icon()
		if (href_list["togglesafeties"])
			togglesafeties(usr)
			updateUsrDialog()
			update_icon()
		if (href_list["dispense_helmet"])
			dispense_helmet(usr)
			updateUsrDialog()
			update_icon()
		if (href_list["dispense_suit"])
			dispense_suit(usr)
			updateUsrDialog()
			update_icon()
		if (href_list["dispense_mask"])
			dispense_mask(usr)
			updateUsrDialog()
			update_icon()
		if (href_list["dispense_boots"])
			dispense_boots(usr)
			updateUsrDialog()
			update_icon()
		if (href_list["toggle_open"])
			toggle_open(usr)
			updateUsrDialog()
			update_icon()
		if (href_list["toggle_lock"])
			toggle_lock(usr)
			updateUsrDialog()
			update_icon()
		if (href_list["start_UV"])
			start_UV(usr)
			updateUsrDialog()
			update_icon()
		if (href_list["eject_guy"])
			eject_occupant(usr)
			updateUsrDialog()
			update_icon()
	/*if (href_list["refresh"])
		updateUsrDialog()*/
	add_fingerprint(usr)
	return


/obj/machinery/suit_storage_unit/proc/toggleUV(mob/user as mob)
//	var/protected = 0
//	var/mob/living/carbon/human/H = user
	if(!panel_open)
		return

	/*if(istype(H)) //Let's check if the guy's wearing electrically insulated gloves
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(istype(G,/obj/item/clothing/gloves/yellow))
				protected = 1

	if(!protected)
		playsound(src, "sparks", 75, 1, -1)
		to_chat(user, "<span class='red'>You try to touch the controls but you get zapped. There must be a short circuit somewhere.</span>")
		return*/
	else  //welp, the guy is protected, we can continue
		if(issuperUV)
			to_chat(user, "You slide the dial back towards \"185nm\".")
			issuperUV = 0
		else
			to_chat(user, "You crank the dial all the way up to \"15nm\".")
			issuperUV = 1
		return


/obj/machinery/suit_storage_unit/proc/togglesafeties(mob/user as mob)
//	var/protected = 0
//	var/mob/living/carbon/human/H = user
	if(!panel_open) //Needed check due to bugs
		return

	/*if(istype(H)) //Let's check if the guy's wearing electrically insulated gloves
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(istype(G,/obj/item/clothing/gloves/yellow) )
				protected = 1

	if(!protected)
		playsound(src, "sparks", 75, 1, -1)
		to_chat(user, "<span class='red'>You try to touch the controls but you get zapped. There must be a short circuit somewhere.</span>")
		return*/
	else
		to_chat(user, "You push the button. The coloured LED next to it changes.")
		safetieson = !safetieson


/obj/machinery/suit_storage_unit/proc/dispense_helmet(mob/user as mob)
	if(!helmet)
		return //Do I even need this sanity check? Nyoro~n
	else
		helmet.forceMove(loc)
		helmet = null
		return


/obj/machinery/suit_storage_unit/proc/dispense_suit(mob/user as mob)
	if(!suit)
		return
	else
		suit.forceMove(loc)
		suit = null
		return


/obj/machinery/suit_storage_unit/proc/dispense_mask(mob/user as mob)
	if(!mask)
		return
	else
		mask.forceMove(loc)
		mask = null
		return


/obj/machinery/suit_storage_unit/proc/dispense_boots(mob/user as mob)
	if(!boots)
		return
	else
		boots.forceMove(loc)
		boots = null
		return


/obj/machinery/suit_storage_unit/proc/dump_everything(var/include_suit=TRUE)
	islocked = 0 //locks go free
	var/list/objects_allowed = list(suit,mask,helmet,boots)
	for(var/obj/O in contents)
		if(!include_suit && (O in objects_allowed))
			continue
		O.forceMove(get_turf(src))
	if(include_suit)
		suit = null
		helmet = null
		mask = null
		boots = null


/obj/machinery/suit_storage_unit/proc/toggle_open(mob/user as mob)
	if(islocked || isUV)
		to_chat(user, "<span class='red'>Unable to open unit.</span>")
		return
	dump_everything(include_suit=FALSE)
	if(occupant)
		eject_occupant(user)
		return  // eject_occupant opens the door, so we need to return
	isopen = !isopen
	return


/obj/machinery/suit_storage_unit/proc/toggle_lock(mob/user as mob)
	if(occupant && safetieson)
		to_chat(user, "<span class='red'>The Unit's safety protocols disallow locking when a biological form is detected inside its compartments.</span>")
		return
	if(isopen)
		return
	if(!allowed(user))
		to_chat(user, "<span class='red'>Access denied.</span>")
		return
	islocked = !islocked
	return


/obj/machinery/suit_storage_unit/proc/start_UV(mob/user as mob)
	if(isUV || isopen) //I'm bored of all these sanity checks
		return
	if(occupant && safetieson)
		to_chat(user, "<span class='red'><B>WARNING:</B> Biological entity detected in the confines of the Unit's storage. Cannot initiate cycle.</span>")
		return
	if(!helmet && !mask && !suit && !boots && !occupant ) //shit's empty yo
		to_chat(user, "<span class='red'>Unit storage bays empty. Nothing to disinfect -- Aborting.</span>")
		return
	to_chat(user, "You start the Unit's cauterisation cycle.")
	cycletime_left = 20
	isUV = 1
	if(occupant && !islocked)
		islocked = 1 //Let's lock it for good measure
	update_icon()
	updateUsrDialog()

	var/i //our counter
	for(i=0,i<4,i++)
		sleep(50)
		if(occupant)
			if(issuperUV)
				var/burndamage = rand(28,35)
				occupant.take_organ_damage(0,burndamage)
				occupant.bodytemperature += burndamage * TEMPERATURE_DAMAGE_COEFFICIENT
				occupant.audible_scream()
			else
				var/burndamage = rand(6,10)
				occupant.take_organ_damage(0,burndamage)
				occupant.bodytemperature += burndamage * TEMPERATURE_DAMAGE_COEFFICIENT
				occupant.audible_scream()
		if(i==3) //End of the cycle
			if(!issuperUV)
				if(helmet)
					helmet.clean_blood()
					helmet.decontaminate()
				if(suit)
					suit.clean_blood()
					suit.decontaminate()
					if(isrig(suit))
						var/obj/item/clothing/suit/space/rig/rigsuit = suit
						if(rigsuit.H) //Internal helmet
							rigsuit.H.clean_blood()
							rigsuit.H.decontaminate()
						if(rigsuit.G) //Internal Gloves
							rigsuit.G.clean_blood()
							rigsuit.G.decontaminate()
						if(rigsuit.MB) //Internal Boots
							rigsuit.MB.clean_blood()
							rigsuit.MB.decontaminate()
						for(var/obj/item/rig_module/module in rigsuit.modules)
							module.suit_storage_act()
				if(mask)
					mask.clean_blood()
					mask.decontaminate()
				if(boots)
					boots.clean_blood()
					boots.decontaminate()
			else //It was supercycling, destroy everything
				if(helmet)
					helmet = null
					qdel(helmet)
				if(suit)
					suit = null
					qdel(suit)
				if(mask)
					mask = null
					qdel(mask)
				if(boots)
					boots = null
					qdel(boots)
				visible_message("<span class='red'>With a loud whining noise, the Suit Storage Unit's door grinds open. Puffs of ashen smoke come out of its chamber.</span>")
				stat |= BROKEN
				isopen = 1
				islocked = 0
				dump_everything(include_suit=FALSE)
				eject_occupant(occupant) //Mixing up these two lines causes bug. DO NOT DO IT.
			isUV = 0 //Cycle ends
	update_icon()
	updateUsrDialog()

/obj/machinery/suit_storage_unit/proc/eject_occupant(mob/user as mob)
	if (islocked)
		return

	if (!occupant)
		return

	if(occupant.gcDestroyed)
		update_icon()
		isopen = 1
		dump_everything(include_suit=FALSE)
		occupant = null
		return
//	for(var/obj/O in src)
//		O.loc = loc

	if (occupant.client)
		if(user != occupant)
			to_chat(occupant, "<span class='notice'>The machine kicks you out!</span>")
		if(user.loc != loc)
			to_chat(occupant, "<span class='notice'>You leave the not-so-cozy confines of the SSU.</span>")

		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant.forceMove(loc)
	occupant = null
	if(!isopen)
		isopen = 1
		dump_everything(include_suit=FALSE)
	update_icon()
	return


/obj/machinery/suit_storage_unit/verb/get_out()
	set name = "Eject Suit Storage Unit"
	set category = "Object"
	set src in oview(1)

	if (usr.isUnconscious())
		return
	eject_occupant(usr)

	add_fingerprint(usr)
	updateUsrDialog()
	update_icon()
	return


/obj/machinery/suit_storage_unit/verb/move_inside()
	set name = "Hide in Suit Storage Unit"
	set category = "Object"
	set src in oview(1)

	if (usr.isUnconscious())
		return
	if (!isopen)
		to_chat(usr, "<span class='red'>The unit's doors are shut.</span>")
		return
	if ((stat & (FORCEDISABLE|NOPOWER)) || (stat & BROKEN))
		to_chat(usr, "<span class='red'>The unit is not operational.</span>")
		return
	if ( (occupant) || (helmet) || (suit) || boots )
		to_chat(usr, "<span class='red'>It's too cluttered inside for you to fit in!</span>")
		return
	visible_message("[usr] starts squeezing into the suit storage unit!")
	if(do_after(usr, src, 10))
		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.forceMove(src)
		occupant = usr
		isopen = 0 //Close the thing after the guy gets inside
		update_icon()
		add_fingerprint(usr)
		updateUsrDialog()
		return
	else
		occupant = null //Testing this as a backup sanity test
	return

/obj/machinery/suit_storage_unit/togglePanelOpen(var/obj/toggleitem, mob/user)
	..()
	updateUsrDialog()

/obj/machinery/suit_storage_unit/attackby(obj/item/I as obj, mob/user as mob)
	if(((stat & BROKEN) || emagged) && issolder(I))
		var/obj/item/tool/solder/S = I
		if(!S.remove_fuel(4,user))
			return
		S.playtoolsound(loc, 100)
		if(do_after(user, src,4 SECONDS * S.work_speed))
			S.playtoolsound(loc, 100)
			stat &= !BROKEN
			emagged = FALSE
			to_chat(user, "<span class='notice'>You repair the blown out electronics in the suit storage unit.</span>")
	if((stat & (FORCEDISABLE|NOPOWER)) && iscrowbar(I) && !islocked)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You begin prying the equipment out of the suit storage unit</span>")
		if(do_after(user, src,20))
			dump_everything()
			update_icon()
	if(stat & (FORCEDISABLE|NOPOWER))
		return
	if(..())
		return 1
	if ( istype(I, /obj/item/weapon/grab) )
		var/obj/item/weapon/grab/G = I
		if( !(ismob(G.affecting)) )
			return
		if (!isopen)
			to_chat(usr, "<span class='red'>The unit's doors are shut.</span>")
			return
		if ((stat & (FORCEDISABLE|NOPOWER)) || (stat & BROKEN))
			to_chat(usr, "<span class='red'>The unit is not operational.</span>")
			return
		if ( (occupant) || (helmet) || (suit) || boots) //Unit needs to be absolutely empty
			to_chat(user, "<span class='red'>The unit's storage area is too cluttered.</span>")
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
			occupant = M
			isopen = 0 //close ittt

			//for(var/obj/O in src)
			//	O.loc = loc
			add_fingerprint(user)
			QDEL_NULL(G)
			updateUsrDialog()
			update_icon()
			return
		return
	if( istype(I,/obj/item/clothing/suit/space) )
		if(!isopen)
			return
		var/obj/item/clothing/suit/space/S = I
		if(suit)
			to_chat(user, "<span class='notice'>The unit already contains a suit.</span>")
			return
		if(user.drop_item(S, src))
			to_chat(user, "You load the [S.name] into the storage compartment.")
			suit = S
			update_icon()
			updateUsrDialog()
		return
	if( istype(I,/obj/item/clothing/head/helmet) )
		if(!isopen)
			return
		var/obj/item/clothing/head/helmet/H = I
		if(helmet)
			to_chat(user, "<span class='notice'>The unit already contains a helmet.</span>")
			return
		if(user.drop_item(H, src))
			to_chat(user, "You load the [H.name] into the storage compartment.")
			helmet = H
			update_icon()
			updateUsrDialog()
			return
	if( istype(I,/obj/item/clothing/mask) )
		if(!isopen)
			return
		var/obj/item/clothing/mask/M = I
		if(mask)
			to_chat(user, "<span class='notice'>The unit already contains a mask.</span>")
			return
		if(user.drop_item(M, src))
			to_chat(user, "You load the [M.name] into the storage compartment.")
			mask = M
			update_icon()
			updateUsrDialog()
		return
	if( istype(I,/obj/item/clothing/shoes) )
		if(!isopen)
			return
		var/obj/item/clothing/shoes/M = I
		if(boots)
			to_chat(user, "<span class='notice'>The unit already contains shoes.</span>")
			return
		if(user.drop_item(M, src))
			to_chat(user, "You load \the [M.name] into the storage compartment.")
			boots = M
			update_icon()
			updateUsrDialog()
		return
	update_icon()
	updateUsrDialog()
	return

/obj/machinery/suit_storage_unit/attack_paw(mob/user as mob)
	to_chat(user, "<span class='notice'>The console controls are far too complicated for your tiny brain!</span>")
	return

/obj/machinery/suit_storage_unit/process()
	if(suit && istype(suit, /obj/item/clothing/suit/space/rig))
		var/obj/item/clothing/suit/space/rig/R = suit
		if(R.cell && R.cell.charge < R.cell.maxcharge)
			use_power(100)
			R.cell.give(30)

//////////////////////////////REMINDER: Make it lock once you place some fucker inside.
