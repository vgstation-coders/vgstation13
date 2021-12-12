/obj/machinery/disease2/diseaseanalyser
	name = "disease analyzer"
	desc = "For analysing pathogenic dishes of sufficient growth."
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"
	anchored = TRUE
	density = TRUE
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL
	light_color = "#6496FA"
	light_range = 2
	light_power = 1

	idle_power_usage = 100
	active_power_usage = 100//1000 extra power once per analysis

	var/process_time = 5
	var/minimum_growth = 100
	var/obj/item/weapon/virusdish/dish = null
	var/last_scan_name = ""
	var/last_scan_info = ""

	var/mob/scanner = null

/obj/machinery/disease2/diseaseanalyser/New()
	. = ..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/diseaseanalyser,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
	)

	RefreshParts()

/obj/machinery/disease2/diseaseanalyser/RefreshParts()
	var/scancount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/scanning_module))
			scancount += SP.rating-1
	minimum_growth = round((initial(minimum_growth) - (scancount * 6)))

/obj/machinery/disease2/diseaseanalyser/attackby(var/obj/I, var/mob/user)
	. = ..()

	if(stat & (BROKEN))
		to_chat(user, "<span class='warning'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return

	if (scanner)
		to_chat(user, "<span class='warning'>\The [scanner] is currently busy using this analyzer.</span>")
		return

	if(.)
		return

	if (dish)
		if (istype(I,/obj/item/weapon/virusdish))
			to_chat(user, "<span class='warning'>There is already a dish in there. Alt+Click or perform the analysis to retrieve it first.</span>")
		else if (istype(I,/obj/item/weapon/reagent_containers))
			dish.attackby(I,user)
	else
		if (istype(I,/obj/item/weapon/virusdish))
			var/obj/item/weapon/virusdish/D = I
			if (D.open)
				visible_message("<span class='notice'>\The [user] inserts \the [I] in \the [src].</span>","<span class='notice'>You insert \the [I] in \the [src].</span>")
				playsound(loc, 'sound/machines/click.ogg', 50, 1)
				user.drop_item(I, loc, 1)
				I.forceMove(src)
				dish = I
				update_icon()
			else
				to_chat(user, "<span class='warning'>You must open the dish's lid before it can be analysed. Be sure to wear proper protection first (at least a sterile mask and latex gloves).</span>")

/obj/machinery/disease2/diseaseanalyser/attack_ghost(var/mob/dead/observer/user)
	if(!can_spook())
		return FALSE
	if(stat & (BROKEN))
		to_chat(user, "<span class='warning'>\The [src] is broken.</span>")
		return
	if (scanner)
		to_chat(user, "<span class='warning'>\The [scanner] is currently busy using this analyzer.</span>")
		return
	if(!user.can_poltergeist())
		to_chat(user, "Your poltergeist abilities are still cooling down.")
		return FALSE
	add_hiddenprint(user)
	icon_state = "analyser_processing"
	flick("analyser_turnon",src)
	set_light(2,2)
	playsound(loc, "sound/machines/heps.ogg", 50, 1)
	spawn(1 SECONDS)
		update_icon()
		flick("analyser_turnoff",src)

/obj/machinery/disease2/diseaseanalyser/attack_hand(var/mob/user)
	. = ..()
	if(stat & (BROKEN))
		to_chat(user, "<span class='notice'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return

	if(stat & (NOPOWER))
		to_chat(user, "<span class='notice'>Deprived of power, \the [src] is unresponsive.</span>")
		if (dish)
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			dish.forceMove(loc)
			dish = null
			update_icon()
		return

	if(.)
		return

	if (scanner)
		to_chat(user, "<span class='warning'>\The [scanner] is currently busy using this analyzer.</span>")
		return

	if (!dish)
		to_chat(user, "<span class='notice'>Place an open growth dish first to analyse its pathogen.</span>")
		return

	if (dish.growth < minimum_growth)
		alert_noise("buzz")
		say("Pathogen growth insufficient. Minimal required growth: [minimum_growth]%.")
		to_chat(user,"<span class='notice'>Add some virus food to the dish and incubate.</span>")
		if (minimum_growth == 100)
			to_chat(user,"<span class='notice'>Replacing the machine's scanning modules with better parts will lower the growth requirement.</span>")
		dish.forceMove(loc)
		dish = null
		update_icon()
		return

	scanner = user
	icon_state = "analyser_processing"
	flick("analyser_turnon",src)

	spawn (1)
		var/image/I = image(icon,"analyser_light")
		I.plane = ABOVE_LIGHTING_PLANE
		I.layer = ABOVE_LIGHTING_LAYER
		overlays += I

	use_power(1000)
	set_light(2,2)
	playsound(loc, "sound/machines/heps.ogg", 50, 1)

	if(do_after(user, src, 5 SECONDS))
		if(stat & (BROKEN|NOPOWER))
			return
		alert_noise()
		if (dish.contained_virus.addToDB())
			say("Added new pathogen to database.")
		var/datum/data/record/v = virusDB["[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]"]
		dish.info = dish.contained_virus.get_info()
		last_scan_name = dish.contained_virus.name(TRUE)
		if (v)
			last_scan_name += v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""

		dish.name = "growth dish ([last_scan_name])"
		last_scan_info = dish.info
		var/datum/browser/popup = new(user, "\ref[dish]", dish.name, 600, 500, src)
		popup.set_content(dish.info)
		popup.open()
		dish.analysed = TRUE
		dish.update_icon()
		dish.forceMove(loc)
		dish = null
	else
		alert_noise("buzz")

	update_icon()
	flick("analyser_turnoff",src)
	scanner = null

/obj/machinery/disease2/diseaseanalyser/update_icon()
	overlays.len = 0
	icon_state = "analyser"

	if (stat & (NOPOWER))
		icon_state = "analyser0"

	if (stat & (BROKEN))
		icon_state = "analyserb"

	if(stat & (BROKEN|NOPOWER))
		kill_light()
	else
		set_light(2,1)

	if (dish)
		overlays += "smalldish-outline"
		if (dish.contained_virus)
			var/image/I = image(icon,"smalldish-color")
			I.color = dish.contained_virus.color
			overlays += I
		else
			overlays += "smalldish-empty"

/obj/machinery/disease2/diseaseanalyser/verb/PrintPaper()
	set name = "Print last analysis"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return

	if(usr.isUnconscious() || usr.restrained())
		return

	if(stat & (BROKEN))
		to_chat(usr, "<span class='notice'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return

	if(stat & (NOPOWER))
		to_chat(usr, "<span class='notice'>Deprived of power, \the [src] is unresponsive.</span>")
		return

	var/turf/T = get_turf(src)
	playsound(T, "sound/effects/fax.ogg", 50, 1)
	anim(target = src, a_icon = icon, flick_anim = "analyser-paper", sleeptime = 30)
	visible_message("\The [src] prints a sheet of paper.")
	spawn(10)
		var/obj/item/weapon/paper/P = new(T)
		P.name = last_scan_name
		P.info = last_scan_info
		P.pixel_x = 8
		P.pixel_y = -8
		P.update_icon()

/obj/machinery/disease2/diseaseanalyser/process()
	if(stat & (NOPOWER|BROKEN))
		scanner = null
		return

	if (scanner && !(scanner in range(src,1)))
		alert_noise("buzz")
		update_icon()
		flick("analyser_turnoff",src)
		scanner = null


/obj/machinery/disease2/diseaseanalyser/AltClick()
	if((!usr.Adjacent(src) || usr.incapacitated()) && !isAdminGhost(usr))
		return ..()

	if (dish && !scanner)
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		dish.forceMove(loc)
		dish = null
		update_icon()

/obj/machinery/disease2/diseaseanalyser/breakdown()
	if (dish)
		dish.forceMove(loc)
	dish = null
	scanner = null
	..()


//////////////////////////////////////////////////////GENERAL DISEASE2 MACHINE PROCS/////////////////////////////////

/obj/machinery/disease2/power_change()
	..()
	update_icon()

/obj/machinery/disease2/proc/breakdown()
	stat |= BROKEN
	update_icon()

/obj/machinery/disease2/ex_act(var/severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				qdel(src)
			else
				breakdown()
		if(3)
			if(prob(35))
				breakdown()

/obj/machinery/disease2/emp_act(var/severity)
	if(stat & (BROKEN))
		return
	switch(severity)
		if(1)
			if(prob(75))
				breakdown()
		if(2)
			if(prob(35))
				breakdown()

/obj/machinery/disease2/attack_construct(var/mob/user)
	if(stat & (BROKEN))
		return
	if (!Adjacent(user))
		return 0
	if(istype(user,/mob/living/simple_animal/construct/armoured))
		shake(1, 3)
		playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
		add_hiddenprint(user)
		breakdown()
		return 1
	return 0

/obj/machinery/disease2/kick_act(var/mob/living/carbon/human/user)
	..()
	if(stat & (BROKEN))
		return
	if (prob(5))
		breakdown()

/obj/machinery/disease2/attack_paw(var/mob/user)
	if(istype(user,/mob/living/carbon/alien/humanoid))
		if(stat & (BROKEN))
			return
		breakdown()
		user.do_attack_animation(src, user)
		visible_message("<span class='warning'>\The [user] slashes at \the [src]!</span>")
		playsound(src, 'sound/weapons/slash.ogg', 100, 1)
		add_hiddenprint(user)
	else if (!usr.dexterity_check())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
	else
		attack_hand(user)
