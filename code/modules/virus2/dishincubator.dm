#define FED_PING_DELAY 40
#define INCUBATOR_MAX_SIZE 100

#define SCAN_COUNT_MIN_WEAKSTR 3
#define SCAN_COUNT_MIN_TARGET 4

/obj/machinery/disease2/incubator
	name = "pathogenic incubator"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/virology.dmi'
	icon_state = "incubator"

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL

	var/obj/item/weapon/virusdish/dish
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/radiation = 0

	var/on = 0
	var/power = 0

	var/foodsupply = 0
	var/toxins = 0
	var/strength = 0
	var/weaken = 0
	var/mutatechance = 5
	var/growthrate = 3
	var/view_virus_info = FALSE
	var/effect_focus = 0 //What effect of the disease are we focusing on?

	var/fully_fed = FALSE
	var/scancount //What level of scanner are we up to?

/obj/machinery/disease2/incubator/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/incubator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/reagent_containers/glass/beaker,
	)

	RefreshParts()

/obj/machinery/disease2/incubator/RefreshParts()
	scancount = 0
	var/lasercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/scanning_module))
			scancount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser))
			lasercount += SP.rating-1
	mutatechance = initial(mutatechance) * max(1, scancount)
	growthrate = initial(growthrate) + lasercount

/obj/machinery/disease2/incubator/attackby(var/obj/B as obj, var/mob/user as mob)
	. = ..()
	if(.)
		return
	if(!is_operational())
		return FALSE
	if(istype(B, /obj/item/weapon/reagent_containers/glass) || istype(B,/obj/item/weapon/reagent_containers/syringe))
		if(beaker)
			to_chat(user, "\A [beaker] is already loaded into the machine.")
			return FALSE

		if(user.drop_item(B, src))
			beaker =  B
			to_chat(user, "You add \the [B] to \the [src]!")
			updateUsrDialog()
			return TRUE
	else
		if(istype(B,/obj/item/weapon/virusdish))
			if(dish)
				to_chat(user, "A dish is already loaded into the machine.")
				return FALSE

			if(user.drop_item(B, src))
				dish =  B
				to_chat(user, "You add the dish to \the [src]!")
				updateUsrDialog()
				return TRUE


/obj/machinery/disease2/incubator/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["close"])
		usr << browse(null, "\ref[src]")
		usr.unset_machine()
		return 1

	usr.set_machine(src)

	if (href_list["ejectchem"])
		if(beaker)
			beaker.forceMove(src.loc)
			beaker = null
	if (href_list["power"])
		on = !on
		if(on)
			icon_state = "incubator_on"
			if(dish && dish.virus2)
				dish.virus2.log += "<br />[timestamp()] Incubation starting by [key_name(usr)] {food=[foodsupply],rads=[radiation]}"
		else
			icon_state = "incubator"
	if (href_list["ejectdish"])
		if(dish)
			dish.forceMove(src.loc)
			dish = null
	if (href_list["rad"])
		radiation++
		if(radiation == 3)
			radiation = 0
	if (href_list["flush"])
		switch(href_list["flush"])
			if("fud")
				foodsupply = 0
			if("tox")
				toxins = 0
			if("str")
				strength = 0
			if("wek")
				weaken = 0
	if(href_list["target"])
		effect_focus++
		if(effect_focus > dish.virus2.effects.len)
			effect_focus = 0
	if(href_list["virus"])
		if (!dish)
			say("No viral culture sample detected.")
		else
			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in beaker.reagents.reagent_list
			if (!B)
				say("No suitable breeding environment detected.")
			else
				if (!B.data["virus2"])
					B.data["virus2"] = list()
				var/datum/disease2/disease/D = dish.virus2.getcopy()
				D.log += "<br />[timestamp()] Injected into blood via [src] by [key_name(usr)]"
				var/list/virus = list("[dish.virus2.uniqueID]" = D)
				B.data["virus2"] += virus
				say("Injection complete.")
	if(href_list["toggle_view"])
		view_virus_info = !view_virus_info
	src.add_fingerprint(usr)
	src.updateUsrDialog()

/obj/machinery/disease2/incubator/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	user.set_machine(src)
	var/dat = ""
	dat += "Power status: <A href='?src=\ref[src];power=1'>[on?"On":"Off"]</a>"
	dat += "<BR>"
	dat += "Radiation setting: [radiation?(radiation==1?"Minor":"Major"):"Inactive"] (<A href='?src=\ref[src];rad=1'>Toggle radiation level</a>)"
	if(scancount >= SCAN_COUNT_MIN_TARGET && dish)
		dat += "<BR>Target individual symptom:<A href='?src=\ref[src];target=1'>[effect_focus==0?"inactive":effect_focus]</A>"
	dat += "<BR>"
	dat += "<hr>"
	if(dish)
		dat += "Pathogen dish: [dish]"
		dat += "<br>Growth level: [dish.growth]"
		if(scancount >= SCAN_COUNT_MIN_WEAKSTR && dish.analysed)
			if(view_virus_info)
				dat += "<BR>[dish.info]"
			dat += "<BR><A href='?src=\ref[src];toggle_view=1'>Toggle pathogen information</a>"
		dat += "<BR>Eject pathogen dish: <A href='?src=\ref[src];ejectdish=1'> Eject</a>"
	else
		dat += "Please insert dish into the incubator.<BR>"
	dat += "<hr>"
	dat += "Toxins: [toxins]: <A href='?src=\ref[src];flush=tox'>Flush</a>"
	if(scancount >= SCAN_COUNT_MIN_WEAKSTR)
		dat += "<BR>Strengthening agent: [strength]: <A href='?src=\ref[src];flush=str'>Flush</a>"
		dat += "<BR>Weakening agent: [weaken]: <A href='?src=\ref[src];flush=wek'>Flush</a>"
	dat += "<BR>Food supply: [foodsupply]: <A href='?src=\ref[src];flush=fud'>Flush</a>"
	if(beaker)
		dat += "<BR>"
		dat += "Eject chemicals: <A href='?src=\ref[src];ejectchem=1'> Eject</a>"
		dat += "<BR>"
		if(dish)
			dat += "Breed viral culture in beaker: <A href='?src=\ref[src];virus=1'> Start</a>"
			dat += "<BR>"
	var/datum/browser/popup = new(user, "\ref[src]", "Pathogenic Incubator", 575, 400, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/disease2/incubator/process()
	var/change = FALSE
	if(on)
		use_power(50,EQUIP)
		if(!powered(EQUIP))
			on = FALSE
			icon_state = "incubator"
			change = TRUE
		if (dish && dish.virus2)
			if(dish.growth >= INCUBATOR_MAX_SIZE)
				if(icon_state != "incubator_fed")
					icon_state = "incubator_fed"
				if(!fully_fed)
					fully_fed = TRUE
					alert_noise("ping")
			else if(foodsupply)
				fully_fed = FALSE
				foodsupply -= 1
				dish.growth = min(growthrate + dish.growth, INCUBATOR_MAX_SIZE)
				change = TRUE
			if(radiation && prob(mutatechance))
				if(radiation == 1)
					dish.virus2.minormutate(effect_focus)
				else if(radiation == 2)
					dish.virus2.log += "<br />[timestamp()] MAJORMUTATE (incubator rads)"
					dish.virus2.majormutate()
					if(dish.info && dish.analysed)
						dish.info = "OUTDATED : [dish.info]"
						dish.analysed = 0
				alert_noise("beep")
				flick("incubator_mut", src)
			if(toxins && prob(mutatechance))
				dish.virus2.infectionchance -= 1
				toxins--
				change = TRUE
			if(strength && prob(mutatechance))
				dish.virus2.minorstrength(effect_focus)
				strength--
				change = TRUE
			if(weaken && prob(mutatechance))
				dish.virus2.minorweak(effect_focus)
				weaken--
				change = TRUE
	else
		icon_state = "incubator"

	if(beaker)
		if(!beaker.reagents.remove_reagent(VIRUSFOOD,5))
			foodsupply += 10
			change = TRUE
		if(beaker.reagents.remove_any_reagents(TOXINS,1))
			toxins += 1
			change = TRUE
		if(scancount >= SCAN_COUNT_MIN_WEAKSTR)
			if(!beaker.reagents.remove_reagent(CREATINE,1))
				strength += 10
				change = TRUE
			if(!beaker.reagents.remove_reagent(SPACEACILLIN,1))
				weaken += 10
				change = TRUE
	if(change)
		updateUsrDialog()

#undef INCUBATOR_MAX_SIZE
