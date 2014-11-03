/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/computer/sleep_console
	name = "sleeper console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeperconsole"
	circuit = "/obj/item/weapon/circuitboard/sleeperconsole"
	var/obj/machinery/sleeper/connected = null
	anchored = 1 //About time someone fixed this.
	density = 1
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"

/obj/machinery/computer/sleep_console/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		else
	return

/obj/machinery/computer/sleep_console/New()
	..()
	spawn(5)
		if(orient == "RIGHT")
			icon_state = "sleeperconsole-r"
			src.connected = locate(/obj/machinery/sleeper, get_step(src, EAST))
		else
			src.connected = locate(/obj/machinery/sleeper, get_step(src, WEST))
		return

/obj/machinery/computer/sleep_console/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/sleep_console/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/sleep_console/attack_hand(mob/user as mob)
	if(..())
		return
	if(src.connected)
		var/mob/living/occupant = src.connected.occupant
		var/dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
		if(occupant)
			var/t1
			switch(occupant.stat)
				if(0)
					t1 = "Conscious"
				if(1)
					t1 = "<font color='blue'>Unconscious</font>"
				if(2)
					t1 = "<font color='red'><B>Dead</B></font>"
				else
			dat += text("[(occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>")]\tHealth %: [occupant.health] ([t1])</FONT><BR>")
			if(iscarbon(occupant))
				var/mob/living/carbon/C = occupant
				dat += text("[(C.pulse == PULSE_NONE || C.pulse == PULSE_THREADY ? "<font color='red'>" : "<font color='blue'>")]\t-Pulse, bpm: [C.get_pulse(GETPULSE_TOOL)]</FONT><BR>")
			dat += text("[(occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")]\t-Brute Damage %: [occupant.getBruteLoss()]</FONT><BR>")
			dat += text("[(occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")]\t-Respiratory Damage %: [occupant.getOxyLoss()]</FONT><BR>")
			dat += text("[(occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")]\t-Toxin Content %: [occupant.getToxLoss()]</FONT><BR>")
			dat += text("[(occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")]\t-Burn Severity %: [occupant.getFireLoss()]</FONT><BR>")
			dat += text("<HR>Paralysis Summary %: [occupant.paralysis] ([round(occupant.paralysis / 4)] seconds left!)<BR>")
			if(occupant.reagents)
				for(var/chemical in connected.available_chemicals)
					dat += "[connected.available_chemicals[chemical]]: [occupant.reagents.get_reagent_amount(chemical)] units<br>"
			dat += "<HR><A href='?src=\ref[src];refresh=1'>Refresh meter readings each second</A><BR>"
			for(var/chemical in connected.available_chemicals)
				dat += "Inject [connected.available_chemicals[chemical]]: "
				for(var/amount in connected.amounts)
					dat += "<a href ='?src=\ref[src];chemical=[chemical];amount=[amount]'>[amount] units</a> "
				dat += "<br>"
		else
			dat += "The sleeper is empty."
		dat += text("<BR><BR><A href='?src=\ref[];mach_close=sleeper'>Close</A>", user)
		user << browse(dat, "window=sleeper;size=400x500")
		onclose(user, "sleeper")
	return

/obj/machinery/computer/sleep_console/Topic(href, href_list)
	if(..())
		return
	if((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.set_machine(src)
		if(href_list["chemical"])
			if(src.connected)
				if(src.connected.occupant)
					if(src.connected.occupant.stat == DEAD)
						usr << "<span class='warning'>The sleeper fails to inject the patient. The patient's state is too degraded to allow medication.</span>"
					else if(src.connected.occupant.health > (config.health_threshold_crit - (25 * src.connected.scan_level)) || href_list["chemical"] == "inaprovaline")
						src.connected.inject_chemical(usr,href_list["chemical"],text2num(href_list["amount"]))
					else
						usr << "<span class='warning'>The sleeper fails to inject the patient. The patient's state is too degraded to allow medication.</span>"
		if(href_list["refresh"])
			src.updateUsrDialog()
		src.add_fingerprint(usr)
	return

/obj/machinery/computer/sleep_console/process()
	if(stat & (NOPOWER|BROKEN))
		return
	src.updateUsrDialog()
	return

/obj/machinery/computer/sleep_console/power_change()
	return
	// no change - sleeper works without power (you just can't inject more)

/////////////////////////////////////////
// THE SLEEPER ITSELF
/////////////////////////////////////////

/obj/machinery/sleeper
	name = "sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper_0"
	density = 1
	anchored = 1
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"
	var/mob/living/occupant = null
	var/available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "kelotane" = "Kelotane", "dermaline" = "Dermaline", "bicaridine" = "Bicaridine")
	var/amounts = list(5, 10)
	var/manip_level = 1
	var/scan_level = 0 //I have my reasons

	l_color = "#7BF9FF"
	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)) && occupant)
			SetLuminosity(2)
		else
			SetLuminosity(0)

/obj/machinery/sleeper/New()
	..()
	spawn(5)
		if(orient == "RIGHT")
			icon_state = "sleeper_0-r"
		return
	return

	component_parts = newlist(
		/obj/item/weapon/circuitboard/sleeper,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/sleeper/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/SM in component_parts)
		T += SM.rating //First rank is two times more efficient, second rank is two and a half times, third is three times. For reference, there's TWO scanning modules
	scan_level = T/2 - 1 //If 1, don't modify
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/MA in component_parts)
		T += MA.rating //Ditto above
	manip_level = T/2
	T = 0

	//This is where we modify available chemicals depending on manipulator level
	if(manip_level >= 2 && manip_level < 3)
		available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "dermaline" = "Dermaline", "bicaridine" = "Bicaridine", "imidazoline" = "Imidazoline", "dexalin" = "Dexalin", "hyronalin" = "Hyronalin")
	else if(manip_level >= 3)
		available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "dermaline" = "Dermaline", "bicaridine" = "Bicaridine", "imidazoline" = "Imidazoline", "dexalinp" = "Dexalin Plus", "arithrazine" = "Arithrazine" , "tricordrazine" = "Tricordrazine", "anti_toxin" = "Anti-Toxin (Dylovene)", "ryetalyn" = "Ryetalyn", "alkysine" = "Alkysine")
	else //We estimate it's < 2
		available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "kelotane" = "Kelotane", "bicaridine" = "Bicaridine")

/obj/machinery/sleeper/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.resting) //are you cuffed, dying, lying, stunned or other
		return
	if(O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(occupant)
		user << "<span class='notice'>\The [src] is already occupied!</span>"
		return
	if(isrobot(user))
		if(!istype(user:module, /obj/item/weapon/robot_module/medical))
			user << "<span class='warning'>You do not have the means to do this!</span>"
			return
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		user << "<span class='notice'>Subject cannot have abiotic items on.</span>"
		return
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			usr << "<span class='warning'>[L] will not fit into \the [src] because they have a slime latched onto their head.</span>"
			return
	if(L == user)
		visible_message("<span class='notice'>[user] starts climbing into \the [src].</span>")
	else
		visible_message("<span class='notice'>[user] starts placing [L] into \the [src].</span>")

	if(do_after(user, 20))
		if(src.occupant)
			user << "<span class='notice'>\The [src] is already occupied!</span>"
			return
		if(!L) return

		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
		L.loc = src
		src.occupant = L
		src.icon_state = "sleeper_1"
		if(orient == "RIGHT")
			icon_state = "sleeper_1-r"
		L << "<span class='notice'>You feel cool air surround you. You go numb as your senses turn inward.</span>"
		for(var/obj/OO in src)
			OO.loc = src.loc
		src.add_fingerprint(user)
		if(user.pulling == L)
			user.pulling = null
		return
	return

/obj/machinery/sleeper/allow_drop()
	return 0

/obj/machinery/sleeper/process()
	src.updateDialog()
	return

/obj/machinery/sleeper/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
			A.blob_act()
		del(src)
	return


/obj/machinery/sleeper/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if((!( istype(G, /obj/item/weapon/grab)) || !( ismob(G.affecting))))
		return
	if(src.occupant)
		user << "<span class='notice'>\The [src] is already occupied!</span>"
		return

	for(var/mob/living/carbon/slime/M in range(1,G.affecting))
		if(M.Victim == G.affecting)
			usr << "<span class='warning'>[G.affecting] will not fit into \the [src] because they have a slime latched onto their head.</span>"
			return

	visible_message("<span class='notice'>[user] starts placing [G.affecting] into \the [src].</span>")

	if(do_after(user, 20))
		if(src.occupant)
			user << "<span class='notice'>\The [src] is already occupied!</span>"
			return
		if(!G || !G.affecting) return
		var/mob/M = G.affecting
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		src.occupant = M
		src.icon_state = "sleeper_1"
		if(orient == "RIGHT")
			icon_state = "sleeper_1-r"

		M << "<span class='notice'>You feel cool air surround you. You go numb as your senses turn inward.</span>"

		for(var/obj/O in src)
			O.loc = src.loc
		src.add_fingerprint(user)
		del(G)
		return
	return


/obj/machinery/sleeper/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
	return
/obj/machinery/sleeper/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..(severity)

//What ?
/obj/machinery/sleeper/alter_health(mob/living/M as mob)
	if(M.health > 0)
		if(M.getOxyLoss() >= 10)
			var/amount = max(0.15, 1)
			M.adjustOxyLoss(-amount)
		else
			M.adjustOxyLoss(-12)
		M.updatehealth()
	M.AdjustParalysis(-4)
	M.AdjustWeakened(-4)
	M.AdjustStunned(-4)
	M.Paralyse(1)
	M.Weaken(1)
	M.Stun(1)
	if(M:reagents.get_reagent_amount("inaprovaline") < 5)
		M:reagents.add_reagent("inaprovaline", 5)
	return


/obj/machinery/sleeper/proc/go_out()
	if(!src.occupant)
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if(src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	if(orient == "RIGHT")
		icon_state = "sleeper_0-r"
	return


/obj/machinery/sleeper/proc/inject_chemical(mob/living/user as mob, chemical, amount)
	if(src.occupant && src.occupant.reagents)
		if(src.occupant.reagents.get_reagent_amount(chemical) + amount <= 20)
			src.occupant.reagents.add_reagent(chemical, amount)
			user << "<span class='notice'>Occupant now has [src.occupant.reagents.get_reagent_amount(chemical)] units of [available_chemicals[chemical]] in his/her bloodstream.</span>"
			return
	user << "<span class='warning'>There's no occupant in the sleeper or the subject has too many chemicals!</span>"
	return

//Why the fuck is this here ? Isn't the console supposed to handle everything info-related ? This piece of shit isn't even called in this code
/obj/machinery/sleeper/proc/check(mob/living/user as mob)
	if(src.occupant)
		user << text("\blue <B>Occupant ([]) Statistics:</B>", src.occupant)
		var/t1
		switch(src.occupant.stat)
			if(0.0)
				t1 = "Conscious"
			if(1.0)
				t1 = "Unconscious"
			if(2.0)
				t1 = "Dead"
			else
		user << text("[]\t Health %: [] ([])", (src.occupant.health > 50 ? "\blue " : "\red "), src.occupant.health, t1)
		user << text("[]\t -Core Temperature: []&deg;C ([]&deg;F)</FONT><BR>", (src.occupant.bodytemperature > 50 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.bodytemperature-T0C, src.occupant.bodytemperature*1.8-459.67)
		user << text("[]\t -Brute Damage %: []", (src.occupant.getBruteLoss() < 60 ? "\blue " : "\red "), src.occupant.getBruteLoss())
		user << text("[]\t -Respiratory Damage %: []", (src.occupant.getOxyLoss() < 60 ? "\blue " : "\red "), src.occupant.getOxyLoss())
		user << text("[]\t -Toxin Content %: []", (src.occupant.getToxLoss() < 60 ? "\blue " : "\red "), src.occupant.getToxLoss())
		user << text("[]\t -Burn Severity %: []", (src.occupant.getFireLoss() < 60 ? "\blue " : "\red "), src.occupant.getFireLoss())
		user << "<span class='notice'>Expected time till occupant can safely awake: (note: If health is below 20% these times are inaccurate)</span>"
		user << text("\blue \t [] second\s (if around 1 or 2 the sleeper is keeping them asleep.)", src.occupant.paralysis / 5)
	else
		user << "<span class='notice'>There is no one inside!</span>"
	return


/obj/machinery/sleeper/verb/eject()
	set name = "Eject Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	if(orient == "RIGHT")
		icon_state = "sleeper_0-r"
	src.icon_state = "sleeper_0"
	src.go_out()
	add_fingerprint(usr)
	return


/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0 || !(ishuman(usr) || ismonkey(usr)))
		return

	if(src.occupant)
		usr << "<span class='notice'>The sleeper is already occupied!</span>"
		return
	if(usr.restrained() || usr.stat || usr.weakened || usr.stunned || usr.paralysis || usr.resting) //are you cuffed, dying, lying, stunned or other
		return
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			usr << "<span class='warning'>You are too busy getting your life sucked out of you.</span>"
			return
	visible_message("<span class='notice'>[usr] starts climbing into the sleeper.</span>")
	if(do_after(usr, 20))
		if(src.occupant)
			usr << "<span class='notice'>The sleeper is already occupied!</span>"
			return
		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
		src.occupant = usr
		src.icon_state = "sleeper_1"
		if(orient == "RIGHT")
			icon_state = "sleeper_1-r"

		for(var/obj/O in src)
			del(O)
		src.add_fingerprint(usr)
		return
	return