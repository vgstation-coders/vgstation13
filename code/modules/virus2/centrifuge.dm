
#define CENTRIFUGE_LIGHTSPECIAL_OFF			0
#define CENTRIFUGE_LIGHTSPECIAL_BLINKING	1
#define CENTRIFUGE_LIGHTSPECIAL_ON			2

#define CENTRIFUGE_TASK_TYPE_DISH    "dish"
#define CENTRIFUGE_TASK_TYPE_VACCINE "vaccine"

/obj/machinery/disease2/centrifuge
	name = "isolation centrifuge"
	desc = "Used to isolate pathogen and antibodies in blood. Make sure to keep the vials balanced when spinning for optimal efficiency."
	icon = 'icons/obj/virology.dmi'
	icon_state = "centrifuge"
	density = TRUE
	anchored = TRUE

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL

	var/datum/browser/popup = null

	var/on = FALSE

	// Contains nullable instances of /isolation_centrifuge_vial.
	var/list/vial_data = list(null, null, null, null)

	light_color = "#8DC6E9"
	light_range = 2
	light_power = 1

	idle_power_usage = 100
	active_power_usage = 300

	var/base_efficiency = 1
	var/upgrade_efficiency = 0.3 // the higher, the better will upgrade affect efficiency

	// Current efficiency calculated based on factors like vial imbalance.
	var/efficiency = 1
	var/last_imbalance = 0

	var/special = CENTRIFUGE_LIGHTSPECIAL_OFF


/obj/machinery/disease2/centrifuge/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/centrifuge,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator
	)

	RefreshParts()


/obj/machinery/disease2/centrifuge/RefreshParts()
	var/manipcount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipcount += SP.rating
	base_efficiency = 1 + upgrade_efficiency * (manipcount-2)


/obj/machinery/disease2/centrifuge/attackby(var/obj/item/I, var/mob/user)
	. = ..()

	if (stat & (BROKEN))
		to_chat(user, "<span class='warning'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return FALSE

	if (stat & NOPOWER)
		to_chat(user, "<span class='warning'>\The [src] is not powered, please check the area power controller before continuing.</span>")
		return FALSE

	if (.)
		return

	if (!istype(I, /obj/item/weapon/reagent_containers/glass/beaker/vial))
		return FALSE

	special = CENTRIFUGE_LIGHTSPECIAL_OFF
	if (on)
		to_chat(user, "<span class='warning'>You cannot add or remove vials while the centrifuge is active. Turn it Off first.</span>")
		return TRUE

	var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial = I
	for (var/i = 1 to vial_data.len)
		var/isolation_centrifuge_vial/vial_datum = vial_data[i]
		if (vial_datum != null)
			continue

		if (!user.drop_item(vial, src))
			// Can't drop due to glue or something.
			return TRUE

		insert_vial(i, vial, user)
		nanomanager.update_uis(src)
		return TRUE

	to_chat(user, "<span class='warning'>There is no room for more vials.</span>")
	return TRUE


/obj/machinery/disease2/centrifuge/proc/vial_has_antibodies(var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial)
	if (vial == null)
		return FALSE

	var/datum/reagent/blood/blood = locate() in vial.reagents.reagent_list
	if (blood && blood.data && blood.data["immunity"])
		var/list/immune_system = blood.data["immunity"]
		if (istype(immune_system) && immune_system.len > 0)
			var/list/antibodies = immune_system[2]
			for (var/antibody in antibodies)
				if (antibodies[antibody] >= 30)
					return TRUE

	return FALSE


//Also handles luminosity
/obj/machinery/disease2/centrifuge/update_icon()
	overlays.len = 0
	icon_state = "centrifuge"

	if (stat & (NOPOWER))
		icon_state = "centrifuge0"

	if (stat & (BROKEN))
		icon_state = "centrifugeb"

	if(stat & (BROKEN|NOPOWER))
		kill_light()
	else
		if (on)
			icon_state = "centrifuge_moving"
			set_light(2,2)
			var/image/centrifuge_light = image(icon,"centrifuge_light")
			centrifuge_light.plane = ABOVE_LIGHTING_PLANE
			centrifuge_light.layer = ABOVE_LIGHTING_LAYER
			overlays += centrifuge_light
			var/image/centrifuge_glow = image(icon,"centrifuge_glow")
			centrifuge_glow.plane = ABOVE_LIGHTING_PLANE
			centrifuge_glow.layer = ABOVE_LIGHTING_LAYER
			centrifuge_glow.blend_mode = BLEND_ADD
			overlays += centrifuge_glow
		else
			set_light(2,1)

		switch (special)
			if (CENTRIFUGE_LIGHTSPECIAL_BLINKING)
				var/image/centrifuge_light = image(icon,"centrifuge_special_update")
				centrifuge_light.plane = ABOVE_LIGHTING_PLANE
				centrifuge_light.layer = ABOVE_LIGHTING_LAYER
				overlays += centrifuge_light
				special = CENTRIFUGE_LIGHTSPECIAL_ON
			if (CENTRIFUGE_LIGHTSPECIAL_ON)
				var/image/centrifuge_light = image(icon,"centrifuge_special")
				centrifuge_light.plane = ABOVE_LIGHTING_PLANE
				centrifuge_light.layer = ABOVE_LIGHTING_LAYER
				overlays += centrifuge_light

	for (var/i = 1 to 4)
		var/isolation_centrifuge_vial/vial_datum = vial_data[i]
		if (vial_datum != null)
			add_vial_sprite(vial_datum.vial, i)


/obj/machinery/disease2/centrifuge/proc/add_vial_sprite(var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial, var/slot)
	var/spin = on
	if(stat & (BROKEN|NOPOWER))
		spin = FALSE
	overlays += "centrifuge_vial[slot][spin ? "_moving" : ""]"
	if (vial.reagents.total_volume)
		var/image/filling = image(icon, "centrifuge_vial[slot]_filling[spin ? "_moving" : ""]")
		filling.icon += mix_color_from_reagents(vial.reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(vial.reagents.reagent_list)
		overlays += filling


/obj/machinery/disease2/centrifuge/attack_hand(var/mob/user)
	. = ..()

	if (stat & (BROKEN))
		to_chat(user, "<span class='notice'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return

	if (stat & (NOPOWER))
		to_chat(user, "<span class='notice'>Deprived of power, \the [src] is unresponsive.</span>")
		for (var/i = 1 to vial_data.len)
			var/isolation_centrifuge_vial/vial_datum = vial_data[i]
			if (vial_datum == null)
				continue

			var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial = vial_datum.vial
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			vial.forceMove(loc)
			vial_data[i] = null
			update_icon()
			sleep(1)

		return

	if (.)
		return

	ui_interact(user)


/obj/machinery/disease2/centrifuge/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	// this is the data which will be sent to the ui
	var/list/data = list()

	data["on"] = on
	data["imbalance"] = last_imbalance
	data["efficiency"] = efficiency
	data["base_efficiency"] = base_efficiency
	var/list/vial_ui_data = list()
	data["vials"] = vial_ui_data

	for (var/i = 1 to vial_data.len)
		var/isolation_centrifuge_vial/vial_datum = vial_data[i]
		var/list/vial_ui_datum = list()
		// tfw no linq
		vial_ui_data[++vial_ui_data.len] = vial_ui_datum

		var/inserted = vial_datum != null
		vial_ui_datum["inserted"] = inserted
		if (!inserted)
			continue

		vial_ui_datum["name"] = vial_datum.vial.name

		var/datum/reagent/blood/blood = locate() in vial_datum.vial.reagents.reagent_list
		if (blood == null)
			var/datum/reagent/vaccine/vaccine = locate() in vial_datum.vial.reagents.reagent_list
			if (vaccine == null)
				vial_ui_datum["display_reagent"] = null
				continue

			vial_ui_datum["display_reagent"] = "vaccine"
			var/vaccines = ""
			for (var/A in vaccine.data["antigen"])
				vaccines += "[A]"
			if (vaccines == "")
				vaccines = "blank"
			vial_ui_datum["vaccines"] = vaccines
			continue

		vial_ui_datum["display_reagent"] = "blood"
		vial_ui_datum["has_pathogen"] = blood.data && length(blood.data["virus2"]) > 0
		vial_ui_datum["has_antibodies"] = vial_datum.valid_for_antibodies

		if (vial_datum.current_task == null)
			vial_ui_datum["task_type"] = null
			continue

		vial_ui_datum["task_type"] = vial_datum.current_task.task_type
		vial_ui_datum["task_target_name"] = vial_datum.current_task.target_name
		vial_ui_datum["task_progress"] = vial_datum.current_task.progress

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "disease_isolation_centrifuge.tmpl", "Isolation Centrifuge", 700, 500)
		ui.set_initial_data(data)
		ui.open()


/obj/machinery/disease2/centrifuge/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(on)
		use_power = MACHINE_POWER_USE_ACTIVE

		// first of all, let's see how (un)balanced are those vials.
		// we're not taking reagent density into account because even my autism has its limits
		// >his autism doesn't have limits.
		var/isolation_centrifuge_vial/viald1 = vial_data[1] // left
		var/isolation_centrifuge_vial/viald2 = vial_data[2] // up
		var/isolation_centrifuge_vial/viald3 = vial_data[3] // right
		var/isolation_centrifuge_vial/viald4 = vial_data[4] // down

		var/vial_unbalance_X = 0
		if (viald1)
			vial_unbalance_X += 5 + viald1.vial.reagents.total_volume
		if (viald3)
			vial_unbalance_X -= 5 + viald3.vial.reagents.total_volume
		var/vial_unbalance_Y = 0
		if (viald2)
			vial_unbalance_Y += 5 + viald2.vial.reagents.total_volume
		if (viald4)
			vial_unbalance_Y -= 5 + viald4.vial.reagents.total_volume

		last_imbalance = abs(vial_unbalance_X) + abs(vial_unbalance_Y) // vials can contain up to 25 units, so maximal unbalance is 60.

		efficiency = base_efficiency / (1 + last_imbalance / 60) // which will at most double the time taken.

		for (var/isolation_centrifuge_vial/vial_datum in vial_data)
			if (vial_datum.current_task)
				centrifuge_act(vial_datum)

	else
		use_power = MACHINE_POWER_USE_IDLE

	update_icon()
	nanomanager.update_uis(src)


/obj/machinery/disease2/centrifuge/proc/centrifuge_act(var/isolation_centrifuge_vial/vial_datum)
	var/isolation_centrifuge_task/task = vial_datum.current_task
	switch (task.task_type)
		if (CENTRIFUGE_TASK_TYPE_DISH)
			// additional pathogen in the sample will lengthen the process
			task.progress += (efficiency * 2) / (1 + 0.3 * task.pathogen_count)

			if (task.progress >= 100)
				print_dish(task.disease)
				vial_datum.current_task = null

		if (CENTRIFUGE_TASK_TYPE_VACCINE)
			if (task.antibodies_density > 50)
				task.progress += (efficiency * 2) * max(1,task.antibodies_density-50)
			else if (task.antibodies_density < 50)
				task.progress += (efficiency * 2) / max(1,50-task.antibodies_density)
			else
				task.progress += (efficiency * 2)

			if (task.progress >= 100)
				var/amount = vial_datum.vial.reagents.get_reagent_amount(BLOOD)
				vial_datum.vial.reagents.remove_reagent(BLOOD, amount)

				var/data = list("antigen" = list(task.target_name))
				vial_datum.vial.reagents.add_reagent(VACCINE, amount, data)
				isolated_antibodies[task.target_name] = 1
				vial_datum.current_task = null

				alert_noise("ping")
				special = CENTRIFUGE_LIGHTSPECIAL_BLINKING


/obj/machinery/disease2/centrifuge/Topic(href, href_list)
	. = ..()
	if (.)
		return

	special = CENTRIFUGE_LIGHTSPECIAL_OFF

	if (href_list["power"])
		on = !on
		update_icon()
		return TRUE

	if (href_list["insertvial"])
		var/mob/living/user = usr
		if (!isliving(user))
			return TRUE

		var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial = user.get_active_hand()
		if (!istype(vial))
			to_chat(user,"<span class='warning'>You're not holding a vial!</span>")
			return TRUE

		if (on)
			to_chat(user,"<span class='warning'>You cannot add or remove vials while the centrifuge is active. Turn it Off first.</span>")
			return TRUE

		var/i = text2num(href_list["insertvial"])
		if (i < 1 || i > vial_data.len)
			return TRUE

		var/isolation_centrifuge_vial/vial_datum = vial_data[i]
		if (vial_datum != null)
			to_chat(user,"<span class='warning'>There is already a vial in that slot.</span>")
			return TRUE

		if (!user.drop_item(vial, src))
			return TRUE

		insert_vial(i, vial, user)
		return TRUE

	if (href_list["ejectvial"])
		if (on)
			to_chat(usr,"<span class='warning'>You cannot add or remove vials while the centrifuge is active. Turn it Off first.</span>")
			return TRUE

		var/i = text2num(href_list["ejectvial"])
		if (i < 1 || i > vial_data.len)
			return TRUE

		var/isolation_centrifuge_vial/vial_datum = vial_data[i]
		if (vial_datum == null)
			return TRUE

		var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial = vial_datum.vial
		vial.forceMove(loc)
		if (Adjacent(usr))
			usr.put_in_hands(vial)

		vial_data[i] = null

		update_icon()
		return TRUE


	if (href_list["interrupt"])
		var/i = text2num(href_list["interrupt"])
		if (i < 1 || i > vial_data.len)
			return TRUE

		var/isolation_centrifuge_vial/vial_datum = vial_data[i]
		if (vial_datum != null)
			vial_datum.current_task = null
		return TRUE


	if (href_list["isolate"])
		var/i = text2num(href_list["isolate"])
		if (i < 1 || i > vial_data.len)
			return TRUE

		var/isolation_centrifuge_vial/vial_datum = vial_data[i]
		if (vial_datum != null)
			start_isolate(vial_datum, usr)
		return TRUE


	if (href_list["synthvaccine"])
		var/i = text2num(href_list["synthvaccine"])
		if (i < 1 || i > vial_data.len)
			return TRUE

		var/isolation_centrifuge_vial/vial_datum = vial_data[i]
		if (vial_datum != null)
			start_cure(vial_datum, usr)
		return TRUE

	return FALSE


/obj/machinery/disease2/centrifuge/proc/start_isolate(var/isolation_centrifuge_vial/vial_datum, var/mob/user)
	if (vial_datum.current_task != null)
		return

	var/datum/reagent/blood/blood = locate() in vial_datum.vial.reagents.reagent_list
	if (!blood || !blood.data || !blood.data["virus2"])
		return

	var/list/blood_viruses = blood.data["virus2"]
	if (!istype(blood_viruses) || blood_viruses.len == 0)
		return

	var/list/pathogen_list = list()
	for (var/ID in blood_viruses)
		var/datum/disease2/disease/D = blood_viruses[ID]
		var/pathogen_name = "Unknown [D.form]"
		if(ID in virusDB)
			var/datum/data/record/rec = virusDB[ID]
			pathogen_name = rec.fields["name"]
		pathogen_list[pathogen_name] = ID

	nanomanager.close_user_uis(user, src)
	var/choice = input(user, "Choose a pathogen to isolate on a growth dish.", "Isolate to dish") as null|anything in pathogen_list
	ui_interact(user)
	if (choice == null)
		return


	var/ID = pathogen_list[choice]
	var/datum/disease2/disease/target = blood_viruses[ID]

	var/isolation_centrifuge_task/task = new
	task.task_type = CENTRIFUGE_TASK_TYPE_DISH

	if (ID in virusDB)
		var/datum/data/record/rec = virusDB[ID]
		task.target_name = rec.fields["name"]
	else
		task.target_name = "Unknown [target.form]"

	task.pathogen_count = pathogen_list.len
	task.disease = target

	vial_datum.current_task = task

/obj/machinery/disease2/centrifuge/proc/start_cure(var/isolation_centrifuge_vial/vial_datum, var/mob/user)
	if (vial_datum.vial == null || vial_datum.current_task != null)
		return

	var/datum/reagent/blood/blood = locate() in vial_datum.vial.reagents.reagent_list
	if (!blood || !blood.data || !blood.data["immunity"])
		return

	var/list/immune_system = blood.data["immunity"]
	if (!istype(immune_system) || immune_system.len == 0)
		return

	if (immune_system[1] < 1)
		to_chat(user,"<span class='warning'>Impossible to acquire antibodies from this blood sample. It seems that it came from a donor with a poor immune system, either due to recent cloning or a radium overload.</span>")
		return

	var/list/antibodies = immune_system[2]
	var/list/antibody_choices = list()
	for (var/antibody in antibodies)
		if (antibodies[antibody] >= 30)
			if (antibodies[antibody] > 50)
				var/delay = max(1,60 / max(1,(antibodies[antibody] - 50)))
				antibody_choices["[antibody] (Expected Duration: [round(delay)] seconds)"] = antibody
			else if (antibodies[antibody] < 50)
				var/delay = max(1,50 - min(49,antibodies[antibody]))
				antibody_choices["[antibody] (Expected Duration: [round(delay)] minutes)"] = antibody
			else
				antibody_choices["[antibody] (Expected Duration: one minute)"] = antibody

	if (antibody_choices.len <= 0)
		to_chat(user,"<span class='warning'>Impossible to create a vaccine from this blood sample. Antibody levels too low. Minimal level = 30%. The higher the concentration, the faster the vaccine is synthesized.</span>")
		return

	nanomanager.close_user_uis(user, src)
	var/choice = input(user, "Choose an antibody to develop into a vaccine. This will destroy the blood sample. The higher the concentration, the faster the vaccine is synthesized.", "Synthesize Vaccine") as null|anything in antibody_choices
	ui_interact(user)
	if (choice == null)
		return

	var/antibody = antibody_choices[choice]

	if (antibodies[antibody] < 49)
		to_chat(user,"<span class='warning'>The time it takes to synthesize a vaccine can be drastically reduced if the blood sample is taken from a subject with higher antibody concentration. Try using spaceacillin to raise it to at least 50% before taking a sample.</span>")

	var/isolation_centrifuge_task/task = new
	task.task_type = CENTRIFUGE_TASK_TYPE_VACCINE
	task.target_name = antibody
	task.antibodies_density = antibodies[antibody]

	vial_datum.current_task = task


/obj/machinery/disease2/centrifuge/proc/print_dish(var/datum/disease2/disease/D)
	special = CENTRIFUGE_LIGHTSPECIAL_BLINKING
	alert_noise("ping")
	anim(target = src, a_icon = icon, flick_anim = "centrifuge_print", sleeptime = 10)
	anim(target = src, a_icon = icon, flick_anim = "centrifuge_print_color", sleeptime = 10, col = D.color)
	visible_message("\The [src] prints a growth dish.")
	spawn(10)
		var/obj/item/weapon/virusdish/dish = new/obj/item/weapon/virusdish(src.loc)
		dish.pixel_y = -7
		dish.contained_virus = D.getcopy()
		dish.contained_virus.infectionchance = dish.contained_virus.infectionchance_base
		dish.update_icon()
		dish.name = "growth dish (Unknown [dish.contained_virus.form])"
		if ("[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]" in virusDB)
			var/datum/data/record/v = virusDB["[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]"]
			var/virus_name = v.fields["name"]
			var/virus_nickname = v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""
			dish.name = "growth dish ([virus_name][virus_nickname])"


/obj/machinery/disease2/centrifuge/breakdown()
	for (var/i = 1 to vial_data.len)
		var/isolation_centrifuge_vial/vial_datum = vial_data[i]
		vial_datum.vial.forceMove(loc)
		vial_data[i] = null

	special = CENTRIFUGE_LIGHTSPECIAL_OFF
	..()


/obj/machinery/disease2/centrifuge/proc/insert_vial(var/index, var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial, var/mob/user)
	var/isolation_centrifuge_vial/vial_datum = new
	vial_data[index] = vial_datum
	vial_datum.vial = vial
	vial_datum.valid_for_antibodies = vial_has_antibodies(vial)
	user.visible_message(
		"<span class='notice'>\The [user] adds \the [vial] to \the [src].</span>",
		"<span class='notice'>You add \the [vial] to \the [src].</span>")
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	update_icon()


/isolation_centrifuge_task
	var/task_type // CENTRIFUGE_TASK_TYPE_DISH or CENTRIFUGE_TASK_TYPE_VACCINE
	var/target_name // Name of the disease being handled.
	var/progress = 0 // Progress % from 0 -> 100.

	var/datum/disease2/disease/disease // Disease being isolated. Only used when isolating a dish.
	var/pathogen_count = 0 // Amount of pathogens in the sample. Only used when isolating a dish.

	var/antibodies_density = 0 // % of antibodies being isolated. Only used when making a vaccine.


/isolation_centrifuge_vial
	var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial
	var/isolation_centrifuge_task/current_task
	var/valid_for_antibodies


#undef CENTRIFUGE_TASK_TYPE_DISH
#undef CENTRIFUGE_TASK_TYPE_VACCINE

#undef CENTRIFUGE_LIGHTSPECIAL_OFF
#undef CENTRIFUGE_LIGHTSPECIAL_BLINKING
#undef CENTRIFUGE_LIGHTSPECIAL_ON
