/*You are a rival corporation's elite operator sent to Space Station 13 in order to teach them a lesson, or something

Your corporation is not a part of the syndicate, they are simply a rival megacorporation similar in size to Nanotrasen

A less retarded version of Ninja. Both in tone and code.*/
/*---------------------------------------------------------------------------------------

Clothing defines!

---------------------------------------------------------------------------------------*/
/obj/item/clothing/suit/space/operator
	name = "Skintight Suit"
	desc = "A black suit made of thousands of layers of microweaved carbon nanotubes. Issued and used by Cyber Connections operators"
	icon_state = "s-ninja"
	item_state = "s-ninja"
	flags_inv = HIDEJUMPSUIT
	armor = list(melee = 65, bullet = 30, laser = 60, energy = 15, bomb = 10, bio = 100, rad = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	w_class = 1
	slowdown = 0
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	//Let's declare some variables
	var/mob/living/carbon/affecting = null//Operator
	var/obj/item/weapon/cell/cell //Fixes a cell slot to the suit.
	var/datum/effect/effect/system/spark_system/spark_system //might remove this later
	var/reagent_list[] = list("tricordrazine","dexalinp","spaceacillin","anti_toxin","nutiment","radium","hyronalin") //Suit reagents... might be fucky at first but should improve with the code itself
	var/stored_research[] //Might get removed entirely if I can't oop the code
	var/obj/item/weapon/disk/tech_disk/t_disk //design disk... again open to being removed!

	//allows for easy reference to worn suit
	var/obj/item/clothing/head/helmet/space/operator/o_hood
	var/obj/item/clothing/gloves/operator/o_gloves
	var/obj/item/clothing/shoes/operator/o_shoes

	var/o_initilized = 0 //Each suit starts in an offline state
	var/o_coold = 0 //cooldown var that can be attached to limit ability spam
	var/o_cost = 1 //base cost of running the suit. reduced from 5 because reasons. might change later
	var/o_acost = 10 //added cost for running multiple powers such as stealth
	var/k_cost = 200 //still using k for "kamakazi", this is how much overdrive mode costs.
	var/k_damage = 2 //damage done by overdrive
	var/o_delay = 30 //how fast the suit does shit
	var/a_transfer = 20 //suit injection amount for reagents
	var/r_maxamount = 300 //max reagent storage (massively increased, subject to balance)

	//support function vars
	var/terminal = 0 //suit computer is disabled
	var/o_stealth = 0 //suit cloaking disabled
	var/o_busy = 0 //the suit isn't multithreaded like this code
	var/overdrive = 0 //if overdrive is on
	var/o_unlock = 0 //kamakazi on lockdown

	var/s_bombs = 10 //number of smoke grenades
	var/a_boost = 20 //number of adrenaline boosters
	//legacy shit that exist so everything doesn't break
	var/flush = 0 //DON'T YOU
	var/o_control = 1 //WORRY ABOUT ME




/obj/item/clothing/head/helmet/space/operator
	name = "Polyweave Helmet and Balaclava"
	desc = "A lightweight helmet and Balaclava combo that protects the user from space and other dangerous things. Issued and used by Cyber Connections operators"
	armor = list(melee = 65, bullet = 30, laser = 60, energy = 15, bomb = 10, bio = 100, rad = 100)
	body_parts_covered = HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	w_class = 0

/obj/item/clothing/mask/gas/voice/operator
	name = "gas mask"
	desc = "A close-fitting mask that connects to an air supply. Has a voice disguising feature. Issued and used by Cyber Connections operators."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	vchange = 1
	siemens_coefficient = 0.2

/obj/item/clothing/gloves/operator
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "cyber gloves"
	icon_state = "s-ninja"
	item_state = "s-ninja"
	siemens_coefficient = 0.2
	var/draining = 0
	var/candrain = 0
	var/mindrain = 200
	var/maxdrain = 400

/obj/item/clothing/shoes/operator
	name = "cyber shoes"
	desc = "A pair of advanced shoes that utilize <span_class='confirm'><B>NANOMACHINES, SON</B></span> to prevent the operator's environment from dicking them about."
	icon_state = "s-ninja"
	permeability_coefficient = 0.01
	flags = NOSLIP
	var/magpulse = 1 //Perma, non-slow magboots. Sorry ZAS!
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0.2

	cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
/*---------------------------------------------------------------------------------------

Clothing defines!

---------------------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------------------

//////////////////        VERBS!          ///////////////////////////////////////////////

---------------------------------------------------------------------------------------*/

/obj/item/clothing/suit/space/operator/New()//for when a new suit is made!
	..()
	verbs += /obj/item/clothing/suit/space/operator/proc/init //suit init verb
	cell = /obj/item/weapon/cell/hyper
	cell.charge = 15000

/obj/item/clothing/suit/space/operator/proc/terminate() //this deletes stuff
	qdel(o_hood)
	del(o_gloves)
	del(o_shoes)
	del(src)

/obj/item/clothing/suit/space/operator/proc/init() //TURN IT ON FOR SCIENCE
	set name = "Activate Suit"
	set desc = "Activates your suit for field operations"
	set category = "Suit Control Panel"

	oinitialize()
	return

/obj/item/clothing/suit/space/operator/proc/deinitialize() //OH GOD TURN IT OFF TURN IT OFF
	set name = "Deactivate Suit"
	set desc = "Disables suit systems"
	set category = "Suit Control Panel"

	if(s_control&&!s_busy)
		deinitialize()
	else
		affecting << "\red Catastrophic system error. Cannot proceed."
	return

/obj/item/clothing/suit/space/operator/proc/terminal()
	set name = "Terminal"
	set desc = "Opens Cyber Connections suit controller interface"
	set category = "Suit Control Panel"

	if (s_control&&!s_busy)
		openos()
	else
		affecting << "\red Catastrophic system error. Cannot proceed."
	return

/obj/item/clothing/suit/space/operator/proc/stealth()
	set name = "Active Camoflauge"
	set desc = "Renders the Operator invisible"
	set category = "Suit Control Panel"

	if (s_control&&!s_busy)
		toggle_stealth()
	else
		affecting << "\red Catastrophic system error. Cannot proceed."
	return

/*---------------------------------------------------------------------------------------

//////////////////        VERBS!          ///////////////////////////////////////////////

---------------------------------------------------------------------------------------*/
//Okay now we are getting into territory where I have no fucking idea what the fuck is going on half the time, pls no bully

//BEGIN THE MECHANICS OF THE SUIT, DOCTOR!

/obj/item/clothing/suit/space/operator/proc/otick(mob/living/carbon/human/U = affecting)

	spawn while(cell.charge>=0) //Sets it so that the suit is on when charged
		//THE SAFETY IS ON
		if(o_initialized&&!affecting)	terminate() //Kills shit if there's no operator inside the suit
		if(!o_initialized)	return //Closes proc if not init
		//Processor processing!
		if(o_coold) o_coold--
		var/A = o_cost
		if(!overdrive)
			if(blade_check(U))
				A = o_acost
			if(o_stealth)
				a = o_acost
		else
			if(prob(o_delay))
				U.adjustBruteLoss(k_damage)
			A = k_cost
		cell.charge-=A
		if(cell.charge<=0)
			if(overdrive)
				U.say("HYEH-H-H-HA WHOOOOO!?")
				U.death()
				return
			cell.charge=0
			cancel_stealth()
		sleep(10)

/* YOU REALLY TURN ME ON! */
/obj/item/clothing/suit/space/operator/proc/oinitialize(delay = o_delay, mob/living/carbon/human/U = loc)
	if(U.mind && U.mind.assigned_role=="MODE" && !o_initialized && !o_busy) //check for several things. Most important being the right person is wearing the suit.
		o_busy = 1
		for(var/i,i<7,i++)
			switch(i)
				if(0)
					U << "<span_class='notice'>Now initializing...</span>"
				if(1)
					U << "<span_class='notice'>Establishing combat seals...</span>"
				if(3)
					U << "<span_class='notice'>Attempting connection with Cyber Connections database...</span> <span_class='confirm'>Succeeded.</span>"
				if(4)
					U << "<span_class='notice'>Generating authorization key from user DNA...\nAttempting logon to secure Cyber Connections server...</span> <span_class='confirm'>Succeeded.</span>"
				if(5)
					U << "<span_class='notice'>Downloading mission specifications...\nUnencrypting using DNA key...</span> <span_class='confirm>Succeeded.</span>"
				if(6)
					U << "<span_class='notice'> All systems nominal.\nMission data added.\nMental uplink connected to Cyber Connections support staff.\nCommand notified that <B>Operation: Sneaking Coyote</B> is engaged, [U.real_name]."
					grant_operation_verbs()
					grant_equip_verbs()
					otick()
			sleep(delay)
		o_busy = 0
	else
		if(!U.mind||U.mind.assigned_role!="MODE")//Only authorized personnel allowed. sorry, greytide!
			U << "You try to initialize the suit..."
			U << "<span_class='notice'>ERROR: USER DNA HASH NOT LOCATED WITHIN CYBER CONNECTIONS DATABASE. LOGGING INCIDENT.</span>"
		else if(o_initilized)
			U << "ERROR: SUIT SYSTEMS ENABLED. PLEASE DISABLE SUIT TO ENABLE SUIT."
		else
			U << "You can't use this."
	return

/* SHUT IT DOWN, SCHLOMO! */
/obj/item/clothing/suit/space/operator/proc/deinitalize(delay = o_delay)
	if(affecting==loc&&!o_busy)
		var/mob/living/carbon/human/U = affecting
		if(!o_initialized)
			U << "The suit isn't on. This shouldn't happen. Report this bug!"
			return
		if(alert("Confirm you wish to disable your suit, operator.",,"Yes","No")=="No")
			return
		if(o_busy||flush)
			U << "ERROR: Cannot disable suit at this time."
			return
		o_busy = 1
		for(var/i = 0,i<7,i++)
			switch(i)
				if(0)
					U << "<span_class='notice'>Disconnecting from Cyber Connections secure network...</span>"
					remove_overdrive(U)
					terminal = 0
				if(1)
					U << "Disabling primary systems... <span_class='notice'><B>SUCEEDED</B></span>"
				if(2)
					U << "Disengaging Nanoweave protection current."
				if(3)
					U << "Disabling combat locks."
				if(4)
					U << "Flushing DNA key..."
				if(5)
					U << "DNA key erased. Database lockout detected."
				if(6)
					U << "Suit offline. Re-enable for function to return."
					blade_check(U,2)
					remove_equip_verbs()
					unlock_suit()
					U.regenerate_icons()
			sleep(delay)
		o_busy = 0
	return
/* wew lads, that was a biggie! Now that the suit can turn on and off, let's get crackin' on the advanced stuff! */
obj/item/clothing/suit/space/operator/proc/openos() //The actual suit control panel! Some of the stuff here is placeholder and is liable to change later. For now is mostly copy-pasted from ninja code... like the rest of this shit.
	if(!affecting) return//Snekky byond
	var/mob/living/carbon/human/U = affecting
	var/dat = {"<html><head><title>Terminal</title></head><body bgcolor=\"#3D5B43\" text=\"#B65B5B\"><style>a, a:link, a:visited, a:active, a:hover { color: #B65B5B; }img {border-style:none;}</style>
	<a href='byond://?src=\ref[src];choice=Refresh'><img src=sos_7.png> Refresh</a>"}
	if(terminal)
		dat += {" | <a href='byond://?src=\ref[src];choice=Return'><img src=sos_1.png> Return</a>
		 | <a href='byond://?src=\ref[src];choice=Close'><img src=sos_8.png> Close</a><br>"}
	if(o_control)
		dat += {"<h2 ALIGN=CENTER>Cyber Connections Terminal v4.7</h2>
		 	Welcome, <b>[U.real_name]</b>.<br>"}
	else
		dat += {"<h2 ALIGN=CENTER>Cyber Connections Termina!^&@ ERROR</b></h2>
		<br>
		<img src=sos_10.png> Current Time: [worldtime2text()]<br>
		<img src=sos_9.png> Battery Life: [round(cell.charge/100)]%<br>
		<img src=sos_11.png> Smoke Bombs: \Roman [o_bombs]<br>
		<img src=sos_14.png> pai Device: ERROR: FUNCTION NOT AVAILABLE"} //This code is basically useless AFAIK, but it keeps breaking unless it's in here
	dat += "<br><br>"
	switch(terminal)
		if(0)
			dat += {"<h4><img src=sos_1.png> Available Functions:</h4>
				<ul>
				<li><a href='byond://?src\ref[src];choice=7'><img src=sos_4.png> Research Stor-FATAL ERROR</a></li>"}
			if(o_control)
				dat += {"<li><a href=byond://?src=\ref[src];choice=Shock'><img src=sos_4.png> Shock [U.realname]</a></li>
					<li><a href=byond://?src=\ref[src];choice=6'><img src=sos_6.png> Activate Abilities</a></li>"}
			dat += {"<li><a href=byond://?src=\ref[src];choice=3'><img src=sos_3.png> Medical Screen</a></li>
				<li><a href=byond://?src=\ref[src];choice=1'><img src=sos_1.png> Atmospheric analyzer</a></li>
				<li><a href=byond://?src=\ref[src];choice=2'><img src=sos_12.png> Messenger</a></li>"}
			if(o_control)
				dat += "<li><a href=byond://?src=\ref[src];choice=4'><img src=sos_6> Other</a></li>"
			dat += "</ul>"
		if(3)
			dat += "<h4><img src=sos_3.png> Medical report:</h4>"
			if(U.dna)
				dat += {"<b>Fingerprint</b>: <i>[md5(U.dna.uni_identity)]</i><br>"
					<b>Generated User ID:</b>: <i>[md5(U.dna.unique_enzymes)]</i><br>"}
			dat += {"<h4>Overall Status: [U.stat > 1 ? "dead" : "[U.health]% healthy"]</h4>
				<h4>Nutrition Status: [U.nutrition]</h4>
				Oxygen loss: [U.getOxyLoss()]
				 | Toxin levels: [U.getToxLoss()]<br>
				Burn severity: [U.getFireLoss()]
				 | Brute trauma: [U.getBruteLoss()]<br>
				Radiation Level: [U.radiation] rad<br>
				Body Temperature: [U.bodytemperature-T0C]&deg;C ([U.bodytemperature*1.8-459.67]&deg;F)<br>"}
			for(var/datum/reagent/R in reagents.reagent_list)
				if(R.id=="radium"&&s_control)//Can only directly inject radium when AI is in control.
					continue
				dat += "<li><a href='byond://?src=\ref[src];choice=Inject;name=[R.name];tag=[R.id]'><img src=sos_2.png> Inject [R.name]: [(reagents.get_reagent_amount(R.id)-(R.id=="radium"?(a_boost*a_transfer):0))/(R.id=="nutriment"?5:a_transfer)] left</a></li>"
			dat += "</ul>"
		if(1)
			dat += "<h4><img src=sos_5.png> Atmospheric Scan:</h4>"//Headers don't need breaks. They are automatically placed.
			var/turf/T = get_turf(U.loc)
			if (isnull(T))
				dat += "Unable to obtain a reading."
			else
				var/datum/gas_mixture/environment = T.return_air()

				var/pressure = environment.return_pressure()
				var/total_moles = environment.total_moles()

				dat += "Air Pressure: [round(pressure,0.1)] kPa"

				if (total_moles)
					var/o2_level = environment.oxygen/total_moles
					var/n2_level = environment.nitrogen/total_moles
					var/co2_level = environment.carbon_dioxide/total_moles
					var/plasma_level = environment.toxins/total_moles
					var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)
					dat += {"<ul>
						<li>Nitrogen: [round(n2_level*100)]%</li>
						<li>Oxygen: [round(o2_level*100)]%</li>
						<li>Carbon Dioxide: [round(co2_level*100)]%</li>
						<li>Plasma: [round(plasma_level*100)]%</li>
						</ul>"}
					if(unknown_level > 0.01)
						dat += "OTHER: [round(unknown_level)]%<br>"

					dat += "Temperature: [round(environment.temperature-T0C)]&deg;C"
		if(2)
			dat += {"<a href='byond://?src=\ref[src];choice=32'><img src=sos_1.png> System Overdrive</a>
				<h4><img src=sos_12.png> Messenger:</h4>
				<h4><img src=sos_6.png> Detected PDAs:</h4>
				<ul>"}
			var/count = 0
			for (var/obj/item/device/pda/P in world)
				if(!P.owner||P.toff)
					continue
				dat += {"<li><a href='byond://?src=ref[src];choice=Message;target=\ref[P]'>[P]</a>
					</li>"}
				count++
			dat += "</ul>"
			if(count==0)
				dat += "None detected.<br>"
		if(32)
			dat += "<h4><img src=sos_1.png> Overload Menu:</h4>"
			if(o_control)
				dat += {"Please input generated user ID:
					<a href='byond://?src=\ref[src];choice=Unlock Overload'><b>ENTER HASH</b></a><br>
					<br>
					Remember, you will not be able to recharge energy during this function. If energy runs out, the suit will auto self-destruct.<br>
					Use with caution. De-initialize the suit when energy is low."}
			else
				//Only leaving this in for funnays. CAN'T LET YOU DO THAT STAR FOX
				dat += {"<b>WARNING</b>: Hostile runtime intrusion detected: operation locked. The Spider Clan is watching you, <b>INTRUDER</b>.
					<b>ERROR</b>: TARANTULA.v.4.77.12 encryption algorithm detected. Unable to decrypt archive.<br>"}
		if(4)
			dat += {"
					<h4><img src=sos_6.png> Operational Guide v4.7</h4>
					<h5>Cyber Connections:</h5>
					A company who's business model involves study and reverse engineering of ancient alien artifacts found in debris floating through space. Much like Nanotrasen, they are in the top 5 of the richest, most powerful corporations in the galaxy. Cyber Connections has no affiliation to the Syndicate and are, in fact, a primary target much like Nanotrasen. Child corporations of Cyber Connections supply most of the equipment used for Research and Development on Space Station 13, as well as xenoarcheology.
					<h5>You:</h5>
					You are a highly trained elite operator of Cyber Connections sent to Space Station 13 for any number of reasons. Think of yourself as Cyber Connection's technological equivalent of Deathsquad. Only your job here isn't to kill everyone, you are a professional. Get in, complete your objectives, and extract.<br>
					Cyber Connections has invested a lot of money into your suit, developing it from the most advanced technologies. It will protect you from many dangers and give you super human abilities. But do not make the mistake of thinking yourself invincible.<br>
					Get in, complete your objectives, get out. That's your unit's motto. You aren't here for a good time.<br>
					Cyber Connections has given you several body modifications, one of which replaced the religious center of your brain with an interface that connects to your suit Uplink, allowing constant contact with a handler. Simply pray to talk to your handler (Note: Lines might be busy, response not guaranteed. We invested quite a lot of money into your suit and expect it will be sufficient in completing your goals.)
					If you do not understand the abilities granted to you by your suit, simply ask your handler.<br>
					<br>
					<br>
					Good luck, operative.<br>
					"} //In other words, admins, prayers from operators equal them trying to contact cyber connections. So for proper IC interaction, don't pretend to be a god, pretend to be someone working at a desk in a space station far off somewhere.
		if(5)
			dat += {"
					<h4>CRITIAL ERROR</h4>
					This function is unavailable at the current time. Please try again later.
					"}
		if(6)
			dat += {"
					<h4><img src=sos_6.png>Activate Abilities:</h4>
					<ul>
					<li><a href='byond://?src=\ref[src];choice=Trigger Ability;name=Phase Jaunt;cost= (10E)'><img src=sos_13.png> Phase Jaunt</a></li>
					<li><a href='byond://?src=\ref[src];choice=Trigger Ability;name=Phase Shift;cost= (20E)'><img src=sos_13.png> Phase Shift</a></li>
					<li><a href='byond://?src=\ref[src];choice=Trigger Ability;name=Energy Blade;cost= (5E)'><img src=sos_13.png> Energy Blade</a></li>
					<li><a href='byond://?src=\ref[src];choice=Trigger Ability;name=Energy Star;cost= (5E)'><img src=sos_13.png> Energy Star</a></li>
					<li><a href='byond://?src=\ref[src];choice=Trigger Ability;name=Energy Net;cost= (20E)'><img src=sos_13.png> Energy Net</a></li>
					<li><a href='byond://?src=\ref[src];choice=Trigger Ability;name=EM Burst;cost= (25E)'><img src=sos_13.png> EM Pulse</a></li>
					<li><a href='byond://?src=\ref[src];choice=Trigger Ability;name=Smoke Bomb;cost='><img src=sos_13.png> Smoke Bomb</a></li>
					<li><a href='byond://?src=\ref[src];choice=Trigger Ability;name=Adrenaline Boost;cost='><img src=sos_13.png> Adrenaline Boost</a></li>
					</ul>
					"}
		if(7)
			dat += "<h4><img src=sos_4.png> Research Stored:</h4>"
			if(t_disk)
				dat += "<a href='byond://?src=\ref[src];choice=Eject Disk'>Eject Disk</a><br>"
			dat += "<ul>"
			if(istype(stored_research,/list))//If there is stored research. Should be but just in case.
				for(var/datum/tech/current_data in stored_research)
					dat += {"<li>
						[current_data.name]: [current_data.level]"}
					// END AUTOFIX
					if(t_disk)//If there is a disk inserted. We can either write or overwrite.
						dat += " <a href='byond://?src=\ref[src];choice=Copy to Disk;target=\ref[current_data]'><i>*Copy to Disk</i></a><br>"
					dat += "</li>"
			dat += "</ul>"
	dat += "</body></html>"
	display_to << browse(dat,"window=terminal;size=400x444;border=1;can_resize=1;can_close=0;can_minimize=0")
	//Well that's a fine howdy'do! Quiet a bit of code for just a bunch of graphics!
	//Now that we've got the terminal's graphics set up, let's get it's procs in order!
/obj/item/clothing/suit/space/operator/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/U = affecting
	var/display_to = U
	if(o_control)
		if(!affecting||U.stat||!o_initialized)
			U << "<span_class='warning'>The suit needs to be on for you to use this function.</span>"
			U << browse(null, "window=terminal")//closes the window
			return
	switch(href_list["choice"])
		if("Close")
			display_to << browse(null, "window=terminal")
			return
		if("Refresh")//goes to end of proc
		if("Return")//goes back
			if(terminal<=9)
				terminal = 0
			else
				terminal = round(terminal/10)
		if("Shock")
			var/damage = min(cell.charge, rand(50,150))//Uses either the current energy left over or between 50 and 150.
			if(damage>1)//So they don't spam it when energy is a factor.
				//spark_system.start()//SPARKS THERE SHALL BE SPARKS
				U.electrocute_act(damage, src,0.1,1)//The last argument is a safety for the human proc that checks for gloves.
				cell.charge -= damage
			else
				A << "<span class='danger'>ERROR:</span> Not enough energy remaining."
		if("Message")
			var/obj/item/device/pda/P = locate(href_list["target"])
			var/t = input(U, "Please enter untraceable message.") as text
			t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
			if(!t||U.stat||U.wear_suit!=src||!s_initialized)//Wow, another one of these. Man...
				display_to << browse(null, "window=spideros")
				return
			if(isnull(P)||P.toff)//So it doesn't freak out if the object no-longer exists.
				display_to << "<span class='warning'>Error: unable to deliver message.</span>"
				display_spideros()
				return
			P.tnote += "<i><b>&larr; From [!s_control?(A):"an unknown source"]:</b></i><br>[t]<br>"
			if (!P.silent)
				playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
				for (var/mob/O in hearers(3, P.loc))
					O.show_message(text("\icon[P] *[P.ttone]*"))
			P.overlays.len = 0
			P.overlays += image('icons/obj/pda.dmi', "pda-r")
		if("Inject")
			if( (href_list["tag"]=="radium"? (reagents.get_reagent_amount("radium"))<=(a_boost*a_transfer) : !reagents.get_reagent_amount(href_list["tag"])) )//Special case for radium. If there are only a_boost*a_transfer radium units left.
				display_to << "<span class='warning'>Error: the suit cannot perform this function. Out of [href_list["name"]].</span>"
			else
				reagents.reaction(U, 2)
				reagents.trans_id_to(U, href_list["tag"], href_list["tag"]=="nutriment"?5:a_transfer)//Nutriment is a special case since it's very potent. Shouldn't influence actual refill amounts or anything.
				display_to << "Injecting..."
				U << "You feel a tiny prick and a sudden rush of substance in to your veins."
		if("Trigger Ability") //Pretty sure this was only for the AI to use... oh well!
			var/ability_name = href_list["name"]+href_list["cost"]//Finds the ability and cost of said ability
			var/proc_arguments//Var used to pass procs along
			var/targets[] = list()//list filled with valid victims
			var/safety = 0 //THE SAFETY IS ON, BOSS
			switch(href_list(["name"])
				if("Phase Shift")
					safety = 1
					for(var/turf/T in oview(5,loc))
						targets.Add(T)
				if("Energy Net")
					safety = 1
					for(var/mob/living/M in oview(5,loc))
						targets.Add(M)
				if(targets.len)
					proc_arguments = pick(targets)
					safety=0
				if(!safety)
					U << "[href_list["name"]] triggers!"
					call(src,ability_name)(proc_arguments)
				else
					U << "No targets in range."
		if("Unlock Overload")
			if(input(U)=="[md5(U.dna.unique_enzymes)]")
				if(!(U.stat||U.wear_suit!=src||!s_initialized))
					if(!(cell.charge<=1||o_busy))
						o_busy = 1
						for(var/i,i<4,i++)
							switch(i)
								if(0)
									U << "<span-class='notice'>Deinitializing failsafes...</span>"
								if(1)
									U << "<span-class='notice'>Disengaging capacitor safeties...</span>"
								if(2)
									U << "<span-class='notice'>Activating bluespace alternator...</span>"
								if(3)
									U << "<span-class='confirm'>ALL SYSTEMS NOMINAL. POWER OUTPUT EXCEEDING 400%.</span>"
									grant_overload(U)//gives verbs and vars as according to plan
									U.regenerate_icons()//update them icons
									operatorblade()
									o_busy = 0
									return
							sleep(o_delay)
					else
						U << "span-class='danger'>ERROR</span> unable to initialize."
				else
					U << browse(null, "window=terminal")
					o_busy = 0
					return
			else
				U << "span-class='warning'>ERROR. INVALID ID.</span>
				o_unlock = 0
				terminal = 0
			o_busy = 0
		if("Eject Disk")
			var/turf/T = get_turf(loc)
			if(!U.get_active_hand())
				U.put_in_hands(t_disk)
				t_disk = null
			else
				if(T)
					t_disk.loc = T
					t_disk = null
				else
					U << "Cannot eject."
		if("Copy to Disk")
			var/datum/tech/current_data = locate(href_list["target"])
			U << "[current_data.name] successfully [(!t_disk.stored) ? "copied" : "overwritten"] to disk."
			t_disk.stored = current_data
		else//note: we left a shitload of pai and ai functions out.
			terminal=text2num(href_list["choice"])//If it's not a defined function, it's a menu.
	display_terminal()//refreshes the screen
	return
//WEW LADS
//Holy fuck that was a hefty bit-o-work
//There used to be more code here... but it was all AI bullshit. We have no room for AIs in our operator suits :^)
/*----------------------------------------------------------------
							SUIT PROCS
----------------------------------------------------------------*/
/obj/item/clothing/suit/space/operator/attack_by(obj/item/I, mob/U)
	if(U==affecting)//Checks if it's the suit's user doing this shit
		if(istype(I, /obj/item/weapon/reagent_containers/glass/))
			var/total_reagent_transfer //keeps track of how much is going in
			for(var/reagent_id in reagent_list)
				var/datum/reagent/R = I.reagents.get_reagent(reagent_id)
				var/ourvolume = reagents.get_reagent_amount(reagent_id) //Because nexis says so
				if(R&&ourvolume<r_maxamount+(reagent_id == "radium"?(a_boost*a_transfer):0)&&R.volume>=a_transfer)
					var/amount_to_transfer = min( (r_maxamount+(reagen_id == "radium"?(aboost*a_transfer):0)-our_volume) ,(round(R.volume/a_transfer))*a_transfer)
					R.volume -= amount_to_transfer
					reagents.add_reagent(reagent_id, amount_to_transfer)
					total_reagent_transfer += amount_to_transfer
					U << "Added [amount_to_transfer] units of [R.name]."
					I.reagents_update_total()
			U << "Replenished a total of [total_reagent_transfer ? total_reagent_transfer : "zero"] chemical units."
		else if(istype(I, /obj/item/weapon/cell/))
			if(o_gloves&&o_gloves.candrain)
				if(I:maxcharge>cell.maxcharge)
					U << "<span-class='notice'>Higher maximum capacity cell detected. Analyzing and rebuilding...</span>"
					if(do_after(U,o_delay))
						U.drop_item()
						I.loc = src
						I:charge = min(I:charge+cell.charge, I:maxcharge)
						var/obj/item/cell/old_cell = cell
						old_cell.charge = 0
						U.put_in_hands(old_cell)
						old_cell.corrupt()
						old_cell.update_icon()
						cell = I
						U << "<span-class='notice'>Upgrade complete. Maximum capacity upgraded.</span>"
				else if(cell.charge<cell.maxcharge)//If our battery is drained, we can do this. Otherwise, what's the point?
					U << "<span-class='notice'>Leeching cell charge...</span>
					if(do_after(U,o_delay))
						U.drop_item()
						I.loc = src
						cell.charge += I.charge
						var/obj/item/cell/old_cell = cell
						old_cell.charge = 0 //destroyes the old cell
						U.put_in_hands(old_cell)
						old_cell.corrupt()
						old_cell.update_icon()
						cell = I
						U << "<span-class='confirm'>SUCCESS</span>"
				else
					U << "<span-class='notice'>ERROR: No such operation available.</span>
			return
		else if(istype(I, /obj/item/weapon/disk/tech_disk))//Allows for stealing research
			var/obj/item/weapon/disk/tech_disk/TD = I
			if(TD.stored)
				U << "<span-class='notice'>Non-public OPFOR Corporate scientific data detected. Analyzing...</span>"
				if(do_after(U,o_delay))
					for(var/datum/tech/current_data in store_research)
						if(current_data.id==TD.stored.id)
							if(current_data.level<TD.stored.level)
								current_data.level = TD.stored.level
							break
					TD.stored = null
					U << "Research documents analyzed and download. Disk formatted."
				else
					U << "ERROR: Procedure interrupted."
			else
				I.loc = src
				t_disk = I
				U << "You slot the [I] into the [src]."
			return
	..()
/obj/item/clothing/suit/space/operator/proc/toggle_stealth()
	var/mob/living/carbon/human/U = affecting
	if(s_active)
		cancel_stealth()
	else
		spawn(0)
			anim(U.loc,U,'icons/mob/mob.dmi',,"cloak",,U.dir)
		s_active=!s_active
		icon_state = U.gender==FEMALE ? "s-ninjasf" : "s-ninjas"
		U.regenerate_icons()
		U.visible_message("[U.name] melts into the air!","Active Camo initialized.","beep")
		U.invisibility = INVISBILITY_OBSERVER//ninjas use spooky ghost technology :O
	return
/obj/item/clothing/suit/space/operator/proc/cancel_stealth()
	var/mob/living/carbon/human/U = affecting
	if(s_active)
		spawn(0)
			anim(U.loc,U,'icons/mob/mob.dmi',,"uncloak",,U.dir)
		s_active=!s_active
		U.invisibility = 0
		U.visible_message("[U.name] fades in from thin air!","Active Camo deinitialized.","boop")
		icon_state = U.gender==FEMALE ? "s-ninjasf" : "s-ninjas"
		U.regenerate_icons()
		return 1
	return 0

/obj/item/clothing/suit/space/operator/proc/examine(mob/user)
	..()
	if(o_initialized)
		if(o_control&&(user==affecting))
			user << "<span-class='notice'>All systems</span> <span-class='confirm'>operational</span>"
			if(!overload)
				user << "<span-class='notice'>Cloak system is [s_active?"active":"inactive"]</span>"
			else
				user << "<span-class='danger'>CAPACITOR SYSTEM OVERLOAD. USER HARM IMMINENT.</span>"
		else
			user << "<span-class='notice'>�rr�R �a��a�� No-�-� f��N� 3RR�r</span>"
//Okay so we got quite a bit out of the way. Cloaking, tech disks, cell draining, cell replacing
//Now we move onto one of the worst coded bits... NIN- ERR OPERATOR GLOVES.

/obj/item/clothing/gloves/operator/proc/drain(target_type as text, target, obj/suit)
	var/obj/item/clothing/suit/space/operator/S = suit
	var/mob/living/carbon/human/U = S.affecting
	var/obj/item/clothing/gloves/operator/G = S.o_gloves
	var/drain = 0//To drain from battery
	var/maxcapacity = 0//safety check for full battery
	var/totaldrain = 0//to keep track of how much was drained.
	G.draining = 1
	if(target_type!="RESEARCH")
		U << "<span_class='notice'>Now charging....</span>
	switch(target_type)
		if("APC")
			var/obj/machinery/power/apc/A = target
			if(A.cell&&A.cell.charge)//checks if the APC has a cell and if that cell has a charge
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5,0,A.loc)
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1//reached max capacity
					if(do_after(U,10))
						spark_system.start()
						playsound(A.loc, "sparks", 50,1)
						A.cell.charge-=drain
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "<span-class='notice'>You gained [totaldrain] energy from the APC.</span>
				A.update_icon()//Note, removed emagging the APC because it always ends up getting the shuttle called when a ninja can't control themselves.
			else
				U << "<span-class='notice'>The APC has run out of charge. Operation aborted.</span>"
				if("RESEARCH")
			var/obj/machinery/A = target
			U << "<span class='notice'>Hacking \the [A]...</span>"
			spawn(0)
				var/turf/location = get_turf(U)
				for(var/mob/living/silicon/ai/AI in player_list)
					AI << "<span class='danger'>Network Alert: Hacking attempt detected[location?" in [location]":". Unable to pinpoint location"]</span>."
			if(A:files&&A:files.known_tech.len)
				for(var/datum/tech/current_data in S.stored_research)
					U << "<span class='notice'>Checking \the [current_data.name] database.</span>"
					if(do_after(U, S.s_delay)&&G.candrain&&!isnull(A))
						for(var/datum/tech/analyzing_data in A:files.known_tech)
							if(current_data.id==analyzing_data.id)
								if(analyzing_data.level>current_data.level)
									U << "<span class='notice'>Database:<span> <b>UPDATED</b>."
									current_data.level = analyzing_data.level
								break//Move on to next.
					else	break//Otherwise, quit processing.
			U << "<span class='notice'>Data analyzed. Process finished.</span>"

		if("WIRE")
			var/obj/structure/cable/A = target
			var/datum/powernet/PN = A.get_powernet()
			while(G.candrain&&!maxcapacity&&!isnull(A))
				drain = (round((rand(G.mindrain,G.maxdrain))/2))
				var/drained = 0
				if(PN&&do_after(U,10))
					drained = min(drain, PN.avail)
					PN.load += drained
					if(drained < drain)//if no power on net, drain apcs
						for(var/obj/machinery/power/terminal/T in PN.nodes)
							if(istype(T.master, /obj/machinery/power/apc))
								var/obj/machinery/power/apc/AP = T.master
								if(AP.operating && AP.cell && AP.cell.charge>0)
									AP.cell.charge = max(0, AP.cell.charge - 5)
									drained += 5
				else	break
				S.cell.charge += drained
				if(S.cell.charge>S.cell.maxcharge)
					totaldrain += (drained-(S.cell.charge-S.cell.maxcharge))
					S.cell.charge = S.cell.maxcharge
					maxcapacity = 1
				else
					totaldrain += drained
				S.spark_system.start()
				if(drained==0)	break
			U << "<span class='notice'>Gained <B>[totaldrain]</B> energy from the power network.</span>"
		else //else... well nothing.
	G.draining = 0
	return
//Toggle proc
/obj/item/clothing/gloves/operator/proc/toggled()
	set name = "Toggle conduit interaction"
	set desc = "Enables the use of gloves as a means to drain research or power from devices."
	set category = "Suit Control Panel"
	var/mob/living/carbon/human/U = loc
	U << "<span-class='notice'>You [candrain?"disable":"enable"] conduit manipulation."
	candrain=!candrain
//Mask code
/obj/item/clothing/mask/gas/voice/operator/proc/assess_targets(list/target_list, mob/living/carbon/U)
	var/icon/tempHud = 'icons/mob/hud.dmi'
	for(var/mob/living/target in target_list)//antag hud. let me know if there's some kind of proc I can replace this with. this is pretty ugly. -kilkun
		if(iscarbon(target))
			switch(target.mind.special_role)
				if("traitor")
					U.client.images += image(tempHud,target,"hudtraitor")
				if("Revolutionary","Head Revolutionary")
					U.client.images += image(tempHud,target,"hudrevolutionary")
				if("Cultist")
					U.client.images += image(tempHud,target,"hudcultist")
				if("Changeling")
					U.client.images += image(tempHud,target,"hudchangeling")
				if("Wizard","Fake Wizard")
					U.client.images += image(tempHud,target,"hudwizard")
				if("Hunter","Sentinel","Drone","Queen")
					U.client.images += image(tempHud,target,"hudalien")
				if("Syndicate")
					U.client.images += image(tempHud,target,"hudoperative")
				if("Death Commando")
					U.client.images += image(tempHud,target,"huddeathsquad")
				if("Space Ninja")
					U.client.images += image(tempHud,target,"hudninja")
				else//If we don't know what role they have but they have one.
					U.client.images += image(tempHud,target,"hudunknown1")
		else//If the silicon mob has no law datum, no inherent laws, or a law zero, add them to the hud.
			var/mob/living/silicon/silicon_target = target
			if(!silicon_target.laws||(silicon_target.laws&&(silicon_target.laws.zeroth||!silicon_target.laws.inherent.len)))
				if(isrobot(silicon_target))//Different icons for robutts and AI.
					U.client.images += image(tempHud,silicon_target,"hudmalborg")
				else
					U.client.images += image(tempHud,silicon_target,"hudmalai")
	return 1
//voice changer
/obj/item/clothing/mask/gas/voice/operator/proc/togglev()
	set name = "Toggle voice"
	set desc = "Toggles the mask's built in voice obfuscation synth on or off."
	set category = "Suit Control Panel"

	var/mob/U = loc //can't toggle this proc if the mask is not worn
	var/vchange = (alert("Would you like to synthesize a new name or turn off the obfuscation algorithm?",,"New name","Turn Off"))
	if(vchange=="New name")
		var/chance = rand(1,3)
		switch(chance)//is it possible to just remove the variable in the first place and just do switch(rand(1,100))?
			if(1)
				name = "[pick(ai_names)]"//The ninja can have an AI name
			if(2)
				name = "[pick(commando_names)]"//Or a classic Death Commando name
			if(3)
				var/names[] = new()
				for(var/mob/living/carbon/human/M in player_list)//generates list of names
					if(M==U||!M.client||!M.real_name)	continue
					names.Add(M.real_name)
				voice = !names.len ? "Cuban Pete" : pick(names)//If there is nobody else, the ninja will mimic cuban pete. Just a cute little easter egg.
		U << "<span-class='notice'>You are now mimicking <B>[voice]</B></span>"
	else
		U << "<span-class='notice'>The voice synthesizer is [voice!="Unknown"?"now":"already"] deactivated</span>"
		voice = "Unknown"
	return
//Vision modes
/obj/item/clothing/mask/gas/voice/operator/proc/switchm()
	set name = "Switch Vision"
	set desc = "Alternates between multiple vision enhancements"
	set category = "Suit Control Panel"
	var/mob/U = loc
	switch(mode)
		if(0)
			mode=1
			U << "Projecting low band IR light"
			U.see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING //This shit wasn't even here before.
			U.see_in_dark = 8//Vision modes were broken because there wasn't anything but user messages.
		if(1)
			mode=2
			U << "Projecting high band FLIR"
			U.vision_flags = SEE_MOBS
			U.see_invisible = SEE_INVISIBLE_MINIMUM
			U.invisa_view = 2
		if(2)
			mode=3
			U.see_invisible = SEE_INVISIBLE_LIVING
			U.sight &= ~SEE_MOBS
			U << "Switching mode to <B>Meson Scanner</B>."
		if(3)
			mode=0
			U.sight &= ~SEE_TURFS
			U << "Switching mode to <B>MILINT HUD</B>."
/obj/item/clothing/mask/voice/operator/examine(mob/user)
	..()
	var/mode
	switch(mode)
		if(0)
			mode = "MILINT HUD"
		if(1)
			mode = "Night Vision"
		if(2)
			mode = "FLIR thermals"
		if(3)
			mode = "Meson Scanner"
	user << "<B>[mode]</B> is active."
	user << "<span-class='notice'>Voice mimicking algorith is set to <B>[voice]</B></span>"
//NET
//Dear god let's hope this works
/obj/effect/energy_net
	name = "Energy Net"
	desc = "A special net used by Cyber Connections operators to wrangle enemy corporate employees"
	icon = "icons/effects/effects.dmi"
	icon_state = "energynet"
	density = 1//can't pass through
	opacity = 0//can see through
	mouse_opacity = 1//you can hit it with shit
	anchored = 0 //you CAN drag things inside the net.
	var/health = 25
	var/mob/living/affecting = null//who it's affecting
	var/mob/living/master = null //who shot it
	proc
		healthcheck()
			if(health <=0)
				density = 0
				if(affecting)
					var/mob/living/carbon/M = affecting
					M.anchored = 0
					for(var/mob/O in viewers(src, 3))
						O << "[M.name] was recovered from the energy net!"
					if(!isnull(master))//If they exist
						master << "<span-class='danger'><B>ERROR:</B> unable to initiate extraction protocol.</span>
				del(src)
			return
	process(var/mob/living/carbon/M as mob)
		var/check = 30
		var/mob_name = affecting.name
		while(!isnull(M)&&!isnull(src)&&check>0)
			check--
			sleep(10)
		while(isnull(M)||M.loc!=loc)
			if(!isnull(master))
				master << "<span-class='danger'><B>ERROR:</B> unable to initiate extraction protocol.</span>
			del(src)
			return
		if(!isnull(src))
			density = 0
			invisibility = 101
			health = INFINITY
			for(var/obj/item/W in M)
				if(istype(M,/mob/living/carbon/human))
					if(W==M:w_uniform)	continue
					if(W==M:shoes)	continue
				M.drop_from_inventory(W)
			spawn(0)
				playsound(M.loc, 'sound/effects/sparks4.ogg', 50, 1)
				anim(M.loc,M,'icons/mob/mob.dmi',,"phaseout",,M.dir)
			M.loc = pick(area/prison)
			M << "You find yourself yanked through space!"
			spawn(0)
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, M.loc)
				spark_system.start()
				playsound(M.loc, 'sound/effects/phasein.ogg', 25, 1)
				playsound(M.loc, 'sound/effects/sparks2.ogg', 50, 1)
				anim(M.loc,M,'icons/mob/mob.dmi',,"phasein",,M.dir)
				del(src)//Wait for everything to finish, delete the net. Else it will stop everything once net is deleted, including the spawn(0).

			for(var/mob/O in viewers(src, 3))
				O.show_message(text("[] vanished!", M), 1, text("You hear sparks flying!"), 2)

			if(!isnull(master))//As long as they still exist.
				master << "<span class='bnotice'>SUCCESS</span>:</span> transport procedure of \the [affecting] complete."

			M.anchored = 0//Important.

		else//And they are free.
			M << "<span class='notice'>You are free of the net!</span>"
		return

	bullet_act(var/obj/item/projectile/Proj)
		health -= Proj.damage
		healthcheck()
		return 0

	ex_act(severity)
		switch(severity)
			if(1.0)
				health-=50
			if(2.0)
				health-=50
			if(3.0)
				health-=prob(50)?50:25
		healthcheck()
		return

	blob_act()
		health-=50
		healthcheck()
		return

	meteorhit()
		health-=50
		healthcheck()
		return

	hitby(AM as mob|obj)
		..()
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span class='danger'>[src] was hit by [AM].</span>"), 1)
		var/tforce = 0
		if(ismob(AM))
			tforce = 10
		else
			tforce = AM:throwforce
		playsound(get_turf(src), 'sound/weapons/slash.ogg', 80, 1)
		health = max(0, health - tforce)
		healthcheck()
		..()
		return

	attack_hand()
		if (M_HULK in usr.mutations)
			usr << text("<span class='notice'>You easily destroy the energy net.</span>")
			for(var/mob/O in oviewers(src))
				O.show_message(text("<span class='attack'>[] rips the energy net apart!</span>", usr), 1)
			health-=50
		healthcheck()
		return

	attack_paw()
		return attack_hand()

	attack_alien()
		if (islarva(usr))
			return
		usr << text("</span><span class='attack'>You claw at the net.</span>")
		for(var/mob/O in oviewers(src))
			O.show_message(text("<span class='attack'>[] claws at the energy net!</span>", usr), 1)
		playsound(get_turf(src), 'sound/weapons/slash.ogg', 80, 1)
		health -= rand(10, 20)
		if(health <= 0)
			usr << text("\</span><span class='attack'>You slice the energy net to pieces.</span>")
			for(var/mob/O in oviewers(src))
				O.show_message(text("<span class='attack'>[] slices the energy net apart!</span>", usr), 1)
		healthcheck()
		return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		var/aforce = W.force
		health = max(0, health - aforce)
		healthcheck()
		..()
		return
//NINJA_EQUIPMENT ENDS HERE
//WEW LADS. That was some intense shit! We purged AI code and rewrote some code! Now that's what I call productive.
//Now let's focus on making the ninja more than a bloke in a tin can.
//NINJA_ABILTIES BEGINS HERE





