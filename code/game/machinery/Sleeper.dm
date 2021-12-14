/////////////////////////////////////////
// THE SLEEPER ITSELF
/////////////////////////////////////////

/obj/machinery/sleeper
	name = "sleeper"
	icon = 'icons/obj/cryogenics3.dmi'
	icon_state = "sleeper_0"
	density = TRUE
	anchored = TRUE
	var/base_icon = "sleeper"
	var/mob/living/occupant = null
	var/available_options = list(INAPROVALINE = "Inaprovaline", STOXIN2 = "Soporific Rejuvenant", DERMALINE = "Dermaline", BICARIDINE = "Bicaridine", DEXALIN = "Dexalin")
	var/amounts = list(5, 10)
	var/sedativeblock = FALSE //To prevent people from being surprisesoporific'd
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | EJECTNOTDEL | EMAGGABLE
	component_parts = newlist(
		/obj/item/weapon/circuitboard/sleeper,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator
	)
	light_color = LIGHT_COLOR_CYAN
	light_range_on = 3
	light_power_on = 2
	var/on = FALSE
	var/target_time = 0
	var/setting
	var/automatic = FALSE
	var/auto_eject_after = 1 //Boot the mooch off after waking 'em up
	var/drag_delay = 20
	var/cools = 0
	var/works_in_crit = FALSE //Will it let you inject chemicals into people in critical condition

/obj/machinery/sleeper/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)) && occupant)
		set_light(light_range_on, light_power_on)
	else
		kill_light()

/obj/machinery/sleeper/New()
	..()
	if(map.nameShort == "deff")
		icon = 'maps/defficiency/medbay.dmi'
	RefreshParts()

/obj/machinery/sleeper/Destroy()
	go_out() //Eject everything
	..()

/obj/machinery/sleeper/update_icon()
	icon_state = "[base_icon]_[occupant ? "1" : "0"]"

/obj/machinery/sleeper/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		T += SP.rating
	if(T >= 12 || (emagged)) //Congrats you got T4 components... or an emag.
		works_in_crit = TRUE
	else
		works_in_crit = FALSE
	switch(T)
		if(0 to 5)
			available_options = list(INAPROVALINE = "Inaprovaline", STOXIN2 = "Soporific Rejuvenant", KELOTANE = "Kelotane", BICARIDINE = "Bicaridine", DEXALIN = "Dexalin")
		if(6 to 8)
			available_options = list(INAPROVALINE = "Inaprovaline", STOXIN2 = "Soporific Rejuvenant", DERMALINE = "Dermaline", BICARIDINE = "Bicaridine", DEXALIN = "Dexalin", IMIDAZOLINE = "Imidazoline" , INACUSIATE = "Inacusiate" ,  TRICORDRAZINE = "Tricordrazine")
		else
			available_options = list(INAPROVALINE = "Inaprovaline", STOXIN2 = "Soporific Rejuvenant", DERMALINE = "Dermaline", BICARIDINE = "Bicaridine", DEXALIN = "Dexalin", IMIDAZOLINE = "Imidazoline" , INACUSIATE = "Inacusiate" ,  TRICORDRAZINE = "Tricordrazine" , ALKYSINE = "Alkysine" , TRAMADOL = "Tramadol" , PEPTOBISMOL  = "Peptobismol")

/obj/machinery/sleeper/emag(mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You short out the overdose prevention system on \the [src].</span>")
		emagged = 1
		return 1
	return

/obj/machinery/sleeper/interact(var/mob/user)
	var/dat = list()
	if(on)
		dat += "<B>Performing anaesthesic emergence...</B>" //Best I could come up with
		dat += "<HR><A href='?src=\ref[src];toggle_autoeject=1'>Auto-eject occupant: [auto_eject_after ? "Yes" : "No"]</A><BR>"
	else
		dat += "<b>Occupant statistics:</b><BR>"
		if(occupant)
			var/occupant_status = "???"
			switch(occupant.stat)
				if(CONSCIOUS)
					occupant_status = "conscious"
				if(UNCONSCIOUS)
					occupant_status = "<span class='average'>unconscious</span>"
				if(DEAD)
					occupant_status = "<span class='average'>*dead*</span>"
			dat += "\tHealth: <span class='[occupant.health > 50 ? "" : "average"]'>[round(occupant.health, 0.1)]</span> ([occupant_status])<br>"
			if(iscarbon(occupant))
				var/mob/living/carbon/C = occupant
				dat += "<span class='[C.pulse == PULSE_NONE || C.pulse >= PULSE_2FAST ? "average" : ""]'>\t-Pulse, bpm: [C.get_pulse(GETPULSE_TOOL)]</span><br>"
			var/bruteloss = occupant.getBruteLoss()
			dat += "<span class='[bruteloss < 60 ? "" : "average"]'>\t-Brute damage: [round(bruteloss, 0.1)]</span><br>"
			var/oxyloss = occupant.getOxyLoss()
			dat += "<span class='[oxyloss < 60 ? "" : "average"]'>\t-Respiratory damage: [round(oxyloss, 0.1)]</span><br>"
			var/toxloss = occupant.getToxLoss()
			dat += "<span class='[toxloss < 60 ? "" : "average"]'>\t-Toxin content: [round(toxloss, 0.1)]</span><br>"
			var/fireloss = occupant.getFireLoss()
			dat += "<span class='[fireloss < 60 ? "" : "average"]'>\t-Burn severity: [round(fireloss, 0.1)]</span><br>"

			var/sleepytime = max(occupant.paralysis, occupant.sleeping)
			dat += "<hr>Paralysis summary: [sleepytime] ([round(sleepytime * 2)] seconds left!)<br>"
			dat += "<a href='?src=\ref[src];wakeup=1'>Begin wake-up cycle</a><br>"
			if(occupant.reagents)
				for(var/chemical in available_options)
					if (emagged && (occupant.reagents.get_reagent_amount(chemical) > 20))
						dat += "<span style='float: left'>[available_options[chemical]]: 20 units</span><span style='float: right'>"
					else
						dat += "<span style='float: left'>[available_options[chemical]]: [round(occupant.reagents.get_reagent_amount(chemical), 0.1)] units</span><span style='float: right'>"

					for(var/amount in amounts)
						dat += " <a href='?src=\ref[src];chemical=[chemical];amount=[amount]'>Inject [amount]u</a>"
					dat += "</span><br>"

			dat += "<HR><A href='?src=\ref[src];refresh=1'>Refresh</A><BR>"

		else
			dat += "The sleeper is empty."
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "\ref[src]", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/sleeper/Topic(href, href_list)
	if(..())
		return TRUE
	if(usr.loc == src)
		return TRUE
	else
		usr.set_machine(src)
		if(href_list["chemical"])
			if(occupant)
				if(occupant.stat == DEAD)
					to_chat(usr, "<span class='danger'>This person has no life for to preserve anymore. Take them to a department capable of reanimating them.</span>")
				else if(href_list["chemical"] == STOXIN2 && sedativeblock)
					if(sedativeblock < 3)
						to_chat(usr, "<span class='warning'>Sedative injections not yet ready. Please try again in a few seconds.</span>")
					else //if this guy is seriously just mashing the soporific button...
						to_chat(usr, "[pick( \
						"<span class='warning'>This guy just got jammed into the machine, give them a breath before trying to pump them full of drugs.</span>", \
						"<span class='warning'>Give it a rest.</span>", \
						"<span class='warning'>Aren't you going to tuck them in before putting them to sleep?</span>", \
						"<span class='warning'>Slow down just a second, they aren't going anywhere... right?</span>", \
						"<span class='warning'>Just got to make sure you're not tripping the fuck out of an innocent bystander, stay tight.</span>", \
						"<span class='warning'>The occupant is still moving around!</span>", \
						"<span class='warning'>Sorry pal, safety procedures.</span>", \
						"<span class='warning'>But it's not bedtime yet!</span>")]")
					sedativeblock++
				else if((!works_in_crit && occupant.health < 0) && (href_list["chemical"] != INAPROVALINE))
					to_chat(usr, "<span class='danger'>This person is not in good enough condition for sleepers to be effective! Use another means of treatment, such as cryogenics!</span>")
				else
					if(!(href_list["chemical"] in available_options)) //href exploitu go home
						to_chat(usr,"<span class='warning'>That's odd. You could've sworn the [href_list["chemical"]] button was there just a second ago!")
					else
						inject_chemical(usr,href_list["chemical"],text2num(href_list["amount"]))
		if(href_list["wakeup"])
			wakeup(usr)
		if(href_list["toggle_autoeject"])
			auto_eject_after = !auto_eject_after
		if(href_list["refresh"])
			process()
		add_fingerprint(usr)
	return

/obj/machinery/sleeper/proc/put_mob(mob/living/L, mob/user)
	if(!istype(L))
		return
	if(istype(L, /mob/living/simple_animal) || istype(L, /mob/living/silicon)) //animals and robutts dont fit
		return

	if(L.locked_to)
		var/datum/locking_category/category = L.locked_to.get_lock_cat_for(L)
		if(!istype(category, /datum/locking_category/buckle/bed/roller))
			return
	else if(L.anchored)
		return

	if(user)
		if(!ishigherbeing(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
			return
		if(isrobot(user))
			var/mob/living/silicon/robot/robit = usr
			if(!HAS_MODULE_QUIRK(robit, MODULE_CAN_HANDLE_MEDICAL))
				to_chat(user, "<span class='warning'>You do not have the means to do this!</span>")
				return

	for(var/mob/living/carbon/slime/S in range(1,L))
		if(S.Victim == L)
			if(user)
				to_chat(user, "<span class='warning'>[L] will not fit into \the [src] because they have a slime latched onto their head.</span>")
			return

	if(occupant)
		if(user)
			to_chat(user, "<span class='notice'>\The [src] is already occupied!</span>")
		return

	if(user && user.pulling == L)
		user.stop_pulling()
	if(user)
		add_fingerprint(user)
	L.unlock_from() //We checked above that they can ONLY be buckled to a rollerbed to allow this to happen!
	L.forceMove(src)
	L.reset_view()
	occupant = L
	to_chat(L, "<span class='notice'><b>You feel an anaesthetising air surround you. You go numb as your senses turn inward.</b></span>")
	process()
	for(var/obj/OO in src)
		OO.forceMove(loc)
	add_fingerprint(user)
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(light_range_on, light_power_on)
	update_icon()

	if(user)
		if(L == user)
			visible_message("[user] climbs into \the [src].")
		else
			visible_message("[user] places \the [L] into \the [src].")
	else
		visible_message("\the [L] is placed into \the [src].")

	sedativeblock = TRUE
	sleep(drag_delay)
	sedativeblock = FALSE

/obj/machinery/sleeper/MouseDropTo(atom/movable/O as mob|obj, mob/user as mob)
	if(!ismob(O)) //mobs only
		return
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O)) //no you can't pull things out of your ass
		return
	if(user.incapacitated() || user.lying) //are you cuffed, dying, lying, stunned or other
		return
	if(!Adjacent(user) || !user.Adjacent(src) || user.contents.Find(src)) // is the mob too far away from you, or are you too far away from the source
		return

	var/mob/living/L = O
	if(!istype(L))
		return

	put_mob(L, user)

/obj/machinery/sleeper/MouseDropFrom(over_object, src_location, var/turf/over_location, src_control, over_control, params)
	if(!ishigherbeing(usr) && !isrobot(usr) || usr.incapacitated() || usr.lying)
		return
	if(!occupant)
		to_chat(usr, "<span class='warning'>The sleeper is unoccupied!</span>")
		return
	if(isrobot(usr))
		var/mob/living/silicon/robot/robit = usr
		if(!HAS_MODULE_QUIRK(robit, MODULE_CAN_HANDLE_MEDICAL))
			to_chat(usr, "<span class='warning'>You do not have the means to do this!</span>")
			return
	over_location = get_turf(over_location)
	if(!istype(over_location) || over_location.density)
		return
	if(!Adjacent(over_location))
		return
	if(!(occupant == usr) && (!Adjacent(usr) || !usr.Adjacent(over_location)))
		return
	for(var/atom/movable/A in over_location.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	if(occupant == usr)
		visible_message("[usr] climbs out of \the [src].")
	else
		visible_message("[usr] removes [occupant.name] from \the [src].")
	go_out(over_location, ejector = usr)


/obj/machinery/sleeper/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if(isliving(AM))
		var/mob/living/L = AM
		if(L.lying)
			if(put_mob(L))
				return TRUE
	return FALSE

/obj/machinery/sleeper/allow_drop()
	return FALSE

/obj/machinery/sleeper/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(loc)
			A.blob_act()
		qdel(src)
	return

/obj/machinery/sleeper/crowbarDestroy(mob/user, obj/item/tool/crowbar/I)
	if(occupant)
		to_chat(user, "<span class='warning'>You cannot disassemble \the [src], it's occupied.</span>")
		return 0
	return ..()

/obj/machinery/sleeper/attackby(obj/item/weapon/obj_used, mob/user)

	if(!istype(obj_used, /obj/item/weapon/grab))
		return ..()
	else
		if(..())
			return TRUE

	var/obj/item/weapon/grab/tar_grab = obj_used
	if(!(ismob(tar_grab.affecting)) || tar_grab.affecting.locked_to)
		return

	if(occupant)
		to_chat(user, "<span class='notice'><B>The sleeper is already occupied!</B></span>")
		return

	for(var/mob/living/carbon/slime/tar_slime in range(1,tar_grab.affecting))
		if(tar_slime.Victim == tar_grab.affecting)
			to_chat(usr, "[tar_grab.affecting.name] will not fit into \the [src] because they have a slime latched onto their head.")
			return

	visible_message("[user] places [tar_grab.affecting.name] into \the [src].")

	var/mob/tar_mob = tar_grab.affecting
	if(!isliving(tar_mob))
		return
	put_mob(tar_mob, user)

/obj/machinery/sleeper/attack_hand(mob/user)
	if(!isobserver(user) && (user.loc == src || (!Adjacent(user)&&!issilicon(user)) || user.incapacitated()))
		return
	interact(user)

/obj/machinery/sleeper/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(loc)
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
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

/obj/machinery/sleeper/proc/cook(var/cook_setting)
	if(!(cook_setting in available_options))
		return
	var/cooktime = available_options[cook_setting]
	target_time = world.time + cooktime
	on = TRUE
	setting = cook_setting
	update_icon()

/obj/machinery/sleeper/proc/wakeup(mob/living/user)
	if(on)
		to_chat(user, "<span class='warning'>\The [src] is busy.</span>")
		return FALSE
	if(!occupant)
		to_chat(user, "<span class='warning'>There's no occupant in \the [src]!</span>")
		return FALSE
	if(occupant.stat == CONSCIOUS)
		to_chat(user, "<span class='warning'>The occupant is already awake.</span>")
		return FALSE
	if(occupant.stat == DEAD)
		to_chat(user, "<span class='warning'>Can't wake up.</span>")
		return FALSE
	. = TRUE //Returning TRUE means we successfully began the wake-up cycle. We will return immediately as the spawn() begins, not at the end.
	on = TRUE
	process()
	var/sleeptime = min(5 SECONDS, 4*max(occupant.sleeping, occupant.paralysis))
	spawn(sleeptime)
		if(!src || !on) //the !src check is redundant from the nature of spawn() if I understand correctly, but better be safe than sorry
			return
		if(occupant)
			occupant.sleeping = 0
			occupant.paralysis = 0
			occupant.resting = 0
		on = FALSE
		if(auto_eject_after)
			go_out(ejector = user)
		process()

/obj/machinery/sleeper/Exited(var/atom/movable/O) // Used for teleportation from within the sleeper.
	if (O == occupant)
		occupant = null
		update_icon()

/obj/machinery/sleeper/proc/go_out(var/exit = loc, var/mob/ejector)
	var/mob/old_occupant = occupant
	if(!occupant)
		return FALSE
	for(var/atom/movable/x in contents)
		if(x in component_parts)
			continue
		x.forceMove(loc)
	if(!old_occupant.gcDestroyed)
		old_occupant.forceMove(exit)
		old_occupant.reset_view()
		if(istype(ejector) && ejector != old_occupant)
			var/obj/structure/bed/roller/B = locate() in exit
			if(B)
				B.buckle_mob(old_occupant, ejector)
				ejector.start_pulling(B)
	update_icon()
	return TRUE

/obj/machinery/sleeper/proc/inject_chemical(mob/living/user as mob, chemical, amount)
	if(!occupant)
		to_chat(user, "<span class='warning'>There's no occupant in the sleeper!</span>")
		return
	if(isnull(occupant.reagents))
		to_chat(user, "<span class='warning'>The occupant appears to somehow lack a bloodstream. Please consult a shrink.</span>")
		return
	if(!emagged && occupant.reagents.get_reagent_amount(chemical) + amount > 20)
		to_chat(user, "<span class='warning'>Overdose Prevention System: The occupant already has enough [available_options[chemical]] in their system.</span>")
		return
	occupant.reagents.add_reagent(chemical, amount)

	if(emagged) // Fake reagent chat reports if over 20 units.
		if(occupant.reagents.get_reagent_amount(chemical) < 20)
			to_chat(user, "<span class='notice'>Occupant now has [occupant.reagents.get_reagent_amount(chemical)] units of [available_options[chemical]] in their bloodstream.</span>")
			return
		to_chat(user, "<span class='notice'>Occupant now has 20 units of [available_options[chemical]] in their bloodstream.</span>")
		return

	to_chat(user, "<span class='notice'>Occupant now has [occupant.reagents.get_reagent_amount(chemical)] units of [available_options[chemical]] in their bloodstream.</span>")
	return

/obj/machinery/sleeper/verb/eject()
	set name = "Eject Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.isUnconscious())
		return
	go_out(ejector = usr)
	add_fingerprint(usr)
	kill_light()
	return

/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.isUnconscious() || !(ishuman(usr) || ismonkey(usr)))
		return

	if(occupant)
		to_chat(usr, "<span class='notice'><B>\The [src] is already occupied!</B></span>")
		return
	if(usr.incapacitated() || usr.lying) //are you cuffed, dying, lying, stunned or other
		return
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting your life sucked out of you.")
			return
	if(usr.locked_to)
		return
	visible_message("[usr] starts climbing into \the [src].")
	if(do_after(usr, src, drag_delay))
		if(occupant)
			to_chat(usr, "<span class='notice'><B>The sleeper is already occupied!</B></span>")
			return
		if(usr.locked_to)
			return
		usr.stop_pulling()
		usr.forceMove(src)
		usr.reset_view()
		occupant = usr
		process()
		for(var/obj/O in src)
			qdel(O)
		add_fingerprint(usr)
		if(!(stat & (BROKEN|NOPOWER)))
			set_light(light_range_on, light_power_on)
		update_icon()
		return
	return


/obj/machinery/sleeper/AltClick()
	if(!usr.incapacitated() && Adjacent(usr) && !(stat & (NOPOWER|BROKEN) && usr.dexterity_check()))
		if(wakeup(usr))
			visible_message("<span class='notice'>\The [src] pings softly: 'Initiating wake-up cycle...' </span>")

/obj/machinery/sleeper/process()
	if(stat & (NOPOWER|BROKEN))
		return
	updateUsrDialog()
	return


/obj/machinery/sleeper/upgraded
	name = "advanced sleeper"
	component_parts = newlist(
		/obj/item/weapon/circuitboard/sleeper,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/manipulator/nano/pico,
		/obj/item/weapon/stock_parts/manipulator/nano/pico
	)


/////////////////////////////////////////
// MANCROWAVE
/////////////////////////////////////////

/obj/machinery/sleeper/mancrowave
	name = "thermal homeostasis regulator"
	desc = "The new generation 'minicrowave' from Mancrowave Inc. It has the same satisfying ping as the classic."
	base_icon = "mancrowave"
	icon_state = "mancrowave_open"
	component_parts = newlist(
		/obj/item/weapon/circuitboard/sleeper/mancrowave,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser
	)
	setting = "Thermoregulate"
	available_options = list("Thermoregulate" = 50)
	light_color = LIGHT_COLOR_ORANGE
	automatic = TRUE
	drag_delay = 0
	machine_flags = SCREWTOGGLE | CROWDESTROY | EMAGGABLE | EJECTNOTDEL
	var/galize = 0

/obj/machinery/sleeper/mancrowave/New()
	..()
	if(Holiday == APRIL_FOOLS_DAY)
		base_icon = "galo"
		icon_state = "galo_open"
		galize = 1
	else if(map.nameShort == "deff")
		icon = 'maps/defficiency/medbay.dmi'
	update_icon()

/obj/machinery/sleeper/mancrowave/go_out(var/exit = loc, var/ejector)
	if(on && !emagged)
		return FALSE
	else
		on = FALSE
		..()

/obj/machinery/sleeper/mancrowave/update_icon()
	if(!occupant)
		icon_state = "[base_icon]_open"
		kill_light()
		return
	if(emagged)
		light_color = LIGHT_COLOR_RED
		icon_state = "[base_icon]_emagged"
	else

		light_color = LIGHT_COLOR_ORANGE
		icon_state = "[base_icon]_running"
	if(on)
		set_light(light_range_on, light_power_on)
	else
		kill_light()

/obj/machinery/sleeper/mancrowave/emag(mob/user)
	if(!emagged)
		emagged = TRUE
		if(user)
			to_chat(user, "<span class='warning'>You short out the safety features of \the [src], and feel like a MAN!	</span>")
		available_options = list("Thermoregulate" = 50,"Rare" = 500,"Medium" = 600,"Well Done" = 700)
		update_icon()
		name = "THE MANCROWAVE"
		return 1
	return -1 //WHY DO YOU DO THIS TO ME

/obj/machinery/sleeper/mancrowave/RefreshParts()

/obj/machinery/sleeper/mancrowave/interact(var/mob/user)
	var/dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
	if(occupant)
		var/t1
		switch(occupant.stat)
			if(CONSCIOUS)
				t1 = "Conscious"
			if(UNCONSCIOUS)
				t1 = "<font color='blue'>Unconscious</font>"
			if(DEAD)
				t1 = "<font color='red'>*dead*</font>"
			else
		dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
		if(iscarbon(occupant))
			var/mob/living/carbon/C = occupant
			dat += text("[]\t-Pulse, bpm: []</FONT><BR>", (C.pulse == PULSE_NONE || C.pulse == PULSE_2SLOW || C.pulse == PULSE_THREADY ? "<font color='red'>" : "<font color='blue'>"), C.get_pulse(GETPULSE_TOOL))
			dat +=  text("[]\t -Core Temperature: []&deg;C </FONT><BR></span>", (C.undergoing_hypothermia() ? "<font color='red'>" : "<font color='blue'>"), C.bodytemperature-T0C)
		dat += "<HR><b>Cook settings:</b><BR>"
		for(var/cook_setting in available_options)
			dat += "<a href ='?src=\ref[src];cook=[cook_setting]'>[cook_setting] - [available_options[cook_setting]/10] seconds</a>"
			dat += "<br>"
	else
		dat += "\The [src] is empty."
	dat += "<HR><A href='?src=\ref[src];refresh=1'>Refresh meter readings each second</A><BR>"
	dat += "<A href='?src=\ref[src];auto=1'>Turn [automatic ? "off": "on" ] Automatic Thermoregulation.</A><BR>"
	dat += "[(emagged) ? "<A href='?src=\ref[src];security=1'>Re-enable Security Features.</A><BR>" : ""]"
	dat += "[(on) ? "<A href='?src=\ref[src];turnoff=1'>\[EMERGENCY STOP\]</A> <i>: cancels the current job.</i><BR>" : ""]"
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=\ref[src]'>Close</A>", user)
	user << browse(dat, "window=\ref[src];size=400x500")
	onclose(user, "\ref[src]")


/obj/machinery/sleeper/mancrowave/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["cook"])
		if(on)
			to_chat(usr, "<span class='danger'>\The [src] is already turned on!</span>")
			return
		if(occupant)
			if((locate(/obj/item/weapon/disk/nuclear) in get_contents_in_object(occupant)) && href_list["cook"] != "Thermoregulate" )
				to_chat(usr, "<span class='danger'>Even with the safety features turned off, \the [src] refuses to cook something inside of it!</span>")
			else
				cook(href_list["cook"])
	if(href_list["refresh"])
		updateUsrDialog()
	if(href_list["auto"])
		automatic = !automatic
	if(href_list["turnoff"])
		on = FALSE
		go_out(ejector = usr)
		update_icon()
	if(href_list["security"])
		if(on)
			to_chat(usr, "<span class='danger'>The security features of \the [src] cannot be re-enabled when it is on!</span>")
			return
		emagged = FALSE
		name = "thermal homeostasis regulator"
		available_options = list("Thermoregulate" = 50)
		update_icon()
	add_fingerprint(usr)
	updateUsrDialog()

/obj/machinery/sleeper/mancrowave/process()
	..()
	if(automatic && occupant && !on)
		cook("Thermoregulate")
	if(!istype(occupant,/mob/living/carbon))
		go_out()
		return
	if(!(world.time >= target_time && on)) //If we're currently still cooking
		var/targettemperature = T0C+32+(available_options["[setting]"]/10)
		var/emaggedbonus = (emagged) ? 10 : 1
		var/timefraction = (available_options["[setting]"])/250*emaggedbonus
		var/tempdifference = abs(targettemperature - occupant.bodytemperature)
		if(occupant.bodytemperature < targettemperature)
			occupant.bodytemperature = min(occupant.bodytemperature + tempdifference*(timefraction),targettemperature)
		else
			occupant.bodytemperature = max(occupant.bodytemperature - tempdifference*(timefraction),targettemperature)
	else
		switch(setting)
			if("Thermoregulate")
				occupant.bodytemperature = (T0C + 37)
				occupant.sleeping = 0
				occupant.paralysis = 0
				go_out()
			if("Rare")
				qdel(occupant)
				occupant = null
				for(var/i = 1;i < 5;i++)
					new /obj/item/weapon/reagent_containers/food/snacks/soylentgreen(loc)
			if("Medium")
				qdel(occupant)
				occupant = null
				for(var/i = 1;i < 5;i++)
					new /obj/item/weapon/reagent_containers/food/snacks/badrecipe(loc)
			if("Well Done")
				qdel(occupant)
				occupant = null
				var/obj/effect/decal/cleanable/ash/ashed = new /obj/effect/decal/cleanable/ash(loc)
				ashed.layer = layer + 0.01
		playsound(src, 'sound/machines/ding.ogg', 50, 1)
		on = FALSE
		if(occupant)
			if(ishuman(occupant))
				var/mob/living/carbon/human/H = occupant
				if(isdiona(H))
					if(H.my_appearance.h_style != "Popped Hair")
						to_chat(H, "<span class = 'notice'>Your head pops!</span>")
						playsound(src, 'sound/effects/pop.ogg', 50, 1)
						H.my_appearance.h_style = "Popped Hair"
						H.update_hair()
				else if(isjusthuman(H) && galize == 1)
					H.GALize()
			go_out()
		update_icon()

/obj/machinery/sleeper/mancrowave/galo
	name = "tanning bed"
	desc = "An experimental G4L-0 model thermal homeostasis regulator. Just looking at it makes you feel unusually excited."
	galize = 1

/obj/machinery/sleeper/mancrowave/galo/New()
	..()
	base_icon = "galo"
	icon_state = "galo_open"
