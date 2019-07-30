
#define CENTRIFUGE_LIGHTSPECIAL_OFF			0
#define CENTRIFUGE_LIGHTSPECIAL_BLINKING	1
#define CENTRIFUGE_LIGHTSPECIAL_ON			2


/obj/machinery/disease2/centrifuge
	name = "isolation centrifuge"
	desc = "Used to isolate pathogen and antibodies in blood. Make sure to keep the vials balanced when spinning for optimal efficiency."
	icon = 'icons/obj/virology.dmi'
	icon_state = "centrifuge"
	density = TRUE
	anchored = TRUE

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL

	var/datum/browser/popup = null

	var/on = 0

	var/list/vials = list(null,null,null,null)
	var/list/vial_valid = list(0,0,0,0)
	var/list/vial_task = list(
		list(0,0,0,0,0,),
		list(0,0,0,0,0,),
		list(0,0,0,0,0,),
		list(0,0,0,0,0,),
		)

	light_color = "#8DC6E9"
	light_range = 2
	light_power = 1

	idle_power_usage = 100
	active_power_usage = 300

	var/base_efficiency = 1
	var/upgrade_efficiency = 0.3 // the higher, the better will upgrade affect efficiency

	var/efficiency = 1

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

	if(stat & (BROKEN))
		to_chat(user, "<span class='warning'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return FALSE

	if(.)
		return

	if (istype(I,/obj/item/weapon/reagent_containers/glass/beaker/vial))
		special = CENTRIFUGE_LIGHTSPECIAL_OFF
		if (on)
			to_chat(user,"<span class='warning'>You cannot add or remove vials while the centrifuge is active. Turn it Off first.</span>")
			return
		var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial = I
		for (var/i = 1 to vials.len)
			if(!vials[i])
				vials[i] = vial
				vial_valid[i] = vial_has_antibodies(vial)
				user.visible_message("<span class='notice'>\The [user] adds \the [vial] to \the [src].</span>","<span class='notice'>You add \the [vial] to \the [src].</span>")
				playsound(loc, 'sound/machines/click.ogg', 50, 1)
				user.drop_item(vial, loc, 1)
				vial.forceMove(src)
				update_icon()
				updateUsrDialog()
				return TRUE

		to_chat(user,"<span class='warning'>There is no room for more vials.</span>")
		return FALSE


/obj/machinery/disease2/centrifuge/proc/vial_has_antibodies(var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial)
	if (!vial)
		return FALSE

	var/datum/reagent/blood/blood = locate() in vial.reagents.reagent_list
	if (blood && blood.data && blood.data["immunity"])
		var/list/immune_system = blood.data["immunity"]
		if (istype(immune_system) && immune_system.len > 0)
			var/list/antibodies = immune_system[2]
			for (var/antibody in antibodies)
				if (antibodies[antibody] >= 30)
					return TRUE

//Also handles luminosity
/obj/machinery/disease2/centrifuge/update_icon()
	overlays.len = 0
	icon_state = "centrifuge"

	if (stat & (NOPOWER))
		icon_state = "centrifuge0"

	if (stat & (BROKEN))
		icon_state = "centrifugeb"

	if(stat & (BROKEN|NOPOWER))
		set_light(0)
	else
		if (on)
			icon_state = "centrifuge_moving"
			set_light(2,2)
			var/image/centrifuge_light = image(icon,"centrifuge_light")
			centrifuge_light.plane = LIGHTING_PLANE
			centrifuge_light.layer = ABOVE_LIGHTING_LAYER
			overlays += centrifuge_light
			var/image/centrifuge_glow = image(icon,"centrifuge_glow")
			centrifuge_glow.plane = LIGHTING_PLANE
			centrifuge_glow.layer = ABOVE_LIGHTING_LAYER
			centrifuge_glow.blend_mode = BLEND_ADD
			overlays += centrifuge_glow
		else
			set_light(2,1)

		switch (special)
			if (CENTRIFUGE_LIGHTSPECIAL_BLINKING)
				var/image/centrifuge_light = image(icon,"centrifuge_special_update")
				centrifuge_light.plane = LIGHTING_PLANE
				centrifuge_light.layer = ABOVE_LIGHTING_LAYER
				overlays += centrifuge_light
				special = CENTRIFUGE_LIGHTSPECIAL_ON
			if (CENTRIFUGE_LIGHTSPECIAL_ON)
				var/image/centrifuge_light = image(icon,"centrifuge_special")
				centrifuge_light.plane = LIGHTING_PLANE
				centrifuge_light.layer = ABOVE_LIGHTING_LAYER
				overlays += centrifuge_light

	for (var/i = 1 to vials.len)
		if(vials[i])
			add_vial_sprite(vials[i],i)

/obj/machinery/disease2/centrifuge/proc/add_vial_sprite(var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial, var/slot = 1)
	overlays += "centrifuge_vial[slot][on ? "_moving" : ""]"
	if(vial.reagents.total_volume)
		var/image/filling = image(icon, "centrifuge_vial[slot]_filling[on ? "_moving" : ""]")
		filling.icon += mix_color_from_reagents(vial.reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(vial.reagents.reagent_list)
		overlays += filling

/obj/machinery/disease2/centrifuge/proc/add_vial_dat(var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial, var/list/vial_task = list(0,0,0,0,0), var/slot = 1)
	var/dat = ""
	var/valid = vial_valid[slot]

	var/datum/reagent/blood/blood = locate() in vial.reagents.reagent_list
	if (!blood)
		var/datum/reagent/vaccine/vaccine = locate() in vial.reagents.reagent_list
		if (!vaccine)
			dat += "<A href='?src=\ref[src];ejectvial=[slot]'>[vial.name] (no blood detected)</a>"
		else
			var/vaccines = ""
			for (var/A in vaccine.data["antigen"])
				vaccines += "[A]"
			if (vaccines == "")
				vaccines = "blank"
			dat += "<A href='?src=\ref[src];ejectvial=[slot]'>[vial.name] (Vaccine ([vaccines]))</a>"
	else
		if (vial_task[1])
			switch (vial_task[1])
				if ("dish")
					var/target = vial_task[2]
					var/progress = vial_task[3]
					dat += "<A href='?src=\ref[src];ejectvial=[slot]'>[vial.name] (isolating [target]: [round(progress)]%)</a> <A href='?src=\ref[src];interrupt=[slot]'>X</a>"
				if ("vaccine")
					var/target = vial_task[2]
					var/progress = vial_task[3]
					dat += "<A href='?src=\ref[src];ejectvial=[slot]'>[vial.name] (synthesizing vaccine ([target]): [round(progress)]%)</a> <A href='?src=\ref[src];interrupt=[slot]'>X</a>"

		else
			if(blood.data && blood.data["virus2"])
				var/list/blood_diseases = blood.data["virus2"]
				if (blood_diseases && blood_diseases.len > 0)
					dat += "<A href='?src=\ref[src];ejectvial=[slot]'>[vial.name] (pathogen detected)</a> <A href='?src=\ref[src];isolate=[slot]'>ISOLATE TO DISH</a> [valid ? "<A href='?src=\ref[src];synthvaccine=[slot]'>SYNTHESIZE VACCINE</a>" : "(not enough antibodies for a vaccine)"]"
				else
					dat += "<A href='?src=\ref[src];ejectvial=[slot]'>[vial.name] (no pathogen detected)</a> [valid ? "<A href='?src=\ref[src];synthvaccine=[slot]'>SYNTHESIZE VACCINE</a>" : "(not enough antibodies for a vaccine)"]"
	return dat

/obj/machinery/disease2/centrifuge/attack_hand(var/mob/user)
	. = ..()
	if(stat & (BROKEN))
		to_chat(user, "<span class='notice'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return

	if(stat & (NOPOWER))
		to_chat(user, "<span class='notice'>Deprived of power, \the [src] is unresponsive.</span>")
		for (var/i = 1 to vials.len)
			if(vials[i])
				var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial = vials[i]
				playsound(loc, 'sound/machines/click.ogg', 50, 1)
				vial.forceMove(loc)
				vials[i] = null
				vial_valid[i] = 0
				vial_task[i] = list(0,0,0,0,0)
				update_icon()
				sleep(1)
		return

	if(.)
		return

	user.set_machine(src)

	special = CENTRIFUGE_LIGHTSPECIAL_OFF

	var/dat = ""
	dat += "Power status: <A href='?src=\ref[src];power=1'>[on?"On":"Off"]</a>"
	dat += "<hr>"
	for (var/i = 1 to vials.len)
		if(vials[i])
			dat += add_vial_dat(vials[i],vial_task[i],i)
		else
			dat += "<A href='?src=\ref[src];insertvial=[i]'>Insert a vial</a>"
		if(i < vials.len)
			dat += "<BR>"
	dat += "<hr>"

	popup = new(user, "\ref[src]", "Isolation Centrifuge", 666, 189, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/disease2/centrifuge/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(on)
		use_power = 2

		//first of all, let's see how (un)balanced are those vials.
		//we're not taking reagent density into account because even my autism has its limits
		var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial1 = vials[1]//left
		var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial2 = vials[2]//up
		var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial3 = vials[3]//right
		var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial4 = vials[4]//down
		var/vial_unbalance_X = 0
		if (vial1)
			vial_unbalance_X += 5 + vial1.reagents.total_volume
		if (vial3)
			vial_unbalance_X -= 5 + vial3.reagents.total_volume
		var/vial_unbalance_Y = 0
		if (vial2)
			vial_unbalance_Y += 5 + vial2.reagents.total_volume
		if (vial4)
			vial_unbalance_Y -= 5 + vial4.reagents.total_volume

		var/vial_unbalance = abs(vial_unbalance_X) + abs(vial_unbalance_Y) // vials can contain up to 25 units, so maximal unbalance is 60.

		efficiency = base_efficiency / (1 + vial_unbalance / 60) // which will at most double the time taken.

		for (var/i = 1 to vials.len)
			if(vials[i])
				var/list/v_task = vial_task[i]
				if (v_task[1])
					vial_task[i] = centrifuge_act(vials[i],vial_task[i])
	else
		use_power = 1

	update_icon()
	updateUsrDialog()

/obj/machinery/disease2/centrifuge/proc/centrifuge_act(var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial, var/list/vial_task = list(0,0,0,0,0))
	var/list/result = list(0,0,0,0,0)
	if (!vial)
		return result
	result = vial_task
	switch (result[1])
		if ("dish")
			result[3] += (efficiency * 2) / (1 + 0.3 * result[5])//additional pathogen in the sample will lengthen the process
			if (result[3] >= 100)
				print_dish(result[4])
				result = list(0,0,0,0,0)
		if ("vaccine")
			if (result[4] > 50)
				result[3] += (efficiency * 2) * max(1,result[4]-50)
			else if (result[4] < 50)
				result[3] += (efficiency * 2) / max(1,50-result[4])
			else
				result[3] += (efficiency * 2)
			if (result[3] >= 100)
				special = CENTRIFUGE_LIGHTSPECIAL_BLINKING
				var/amt= vial.reagents.get_reagent_amount(BLOOD)
				vial.reagents.remove_reagent(BLOOD,amt)
				var/data = list("antigen" = list(result[2]))
				vial.reagents.add_reagent(VACCINE,amt,data)
				result = list(0,0,0,0,0)
				alert_noise("ping")
	return result

/obj/machinery/disease2/centrifuge/Topic(href, href_list)

	if(..())
		return 1

	if(href_list["close"])
		usr << browse(null, "\ref[src]")
		usr.unset_machine()
		return 1

	usr.set_machine(src)

	special = CENTRIFUGE_LIGHTSPECIAL_OFF

	if (href_list["power"])
		on = !on
		update_icon()

	else if (href_list["insertvial"])
		var/mob/living/user
		if (isliving(usr))
			user = usr
		if (!user)
			return
		var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial = user.get_active_hand()
		if (istype(vial))
			if (on)
				to_chat(user,"<span class='warning'>You cannot add or remove vials while the centrifuge is active. Turn it Off first.</span>")
				return
			else
				var/i = text2num(href_list["insertvial"])
				if (!vials[i])
					vials[i] = vial
					vial_valid[i] = vial_has_antibodies(vial)
					user.visible_message("<span class='notice'>\The [user] adds \the [vial] to \the [src].</span>","<span class='notice'>You add \the [vial] to \the [src].</span>")
					playsound(loc, 'sound/machines/click.ogg', 50, 1)
					user.drop_item(vial, loc, 1)
					vial.forceMove(src)
				else
					to_chat(user,"<span class='warning'>There is already a vial in that slot.</span>")
					return

	else if (href_list["ejectvial"])
		if (on)
			to_chat(usr,"<span class='warning'>You cannot add or remove vials while the centrifuge is active. Turn it Off first.</span>")
			return
		else
			var/i = text2num(href_list["ejectvial"])
			if (vials[i])
				var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial = vials[i]
				vial.forceMove(src.loc)
				if (Adjacent(usr))
					vial.forceMove(usr.loc)
					usr.put_in_hands(vial)
				vials[i] = null
				vial_valid[i] = 0
				vial_task[i] = list(0,0,0,0,0)

	else if (href_list["interrupt"])
		var/i = text2num(href_list["interrupt"])
		vial_task[i] = list(0,0,0,0,0)

	else if (href_list["isolate"])
		var/i = text2num(href_list["isolate"])
		vial_task[i] = isolate(vials[i],usr)

	else if (href_list["synthvaccine"])
		var/i = text2num(href_list["synthvaccine"])
		vial_task[i] = cure(vials[i],usr)

	update_icon()
	add_fingerprint(usr)
	updateUsrDialog()
	attack_hand(usr)

/obj/machinery/disease2/centrifuge/proc/isolate(var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial,var/mob/user)
	var/list/result = list(0,0,0,0,0)
	if (!vial)
		return result

	var/datum/reagent/blood/blood = locate() in vial.reagents.reagent_list
	if (blood && blood.data && blood.data["virus2"])
		var/list/blood_viruses = blood.data["virus2"]
		if (istype(blood_viruses) && blood_viruses.len > 0)
			var/list/pathogen_list = list()
			for (var/ID in blood_viruses)
				var/datum/disease2/disease/D = blood_viruses[ID]
				var/pathogen_name = "Unknown [D.form]"
				if(ID in virusDB)
					var/datum/data/record/rec = virusDB[ID]
					pathogen_name = rec.fields["name"]
				pathogen_list[pathogen_name] = ID

			popup.close()
			user.unset_machine()
			var/choice = input(user, "Choose a pathogen to isolate on a growth dish.", "Isolate to dish") as null|anything in pathogen_list
			user.set_machine()
			if (!choice)
				return result
			var/ID = pathogen_list[choice]
			var/datum/disease2/disease/target = blood_viruses[ID]

			result[1] = "dish"
			result[2] = "Unknown [target.form]"
			if(ID in virusDB)
				var/datum/data/record/rec = virusDB[ID]
				result[2] = rec.fields["name"]
			result[3] = 0
			result[4] = target
			result[5] = pathogen_list.len

	return result

/obj/machinery/disease2/centrifuge/proc/cure(var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial,var/mob/user)
	var/list/result = list(0,0,0,0,0)
	if (!vial)
		return result

	var/datum/reagent/blood/blood = locate() in vial.reagents.reagent_list
	if (blood && blood.data && blood.data["immunity"])
		var/list/immune_system = blood.data["immunity"]
		if (istype(immune_system) && immune_system.len > 0)
			if (immune_system[1] < 1)
				to_chat(user,"<span class='warning'>Impossible to acquire antibodies from this blood sample. It seems that it came from a donor with a poor immune system, either due to recent cloning or a radium overload.</span>")
				return result

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
				return result

			popup.close()
			user.unset_machine()
			var/choice = input(user, "Choose an antibody to develop into a vaccine. This will destroy the blood sample. The higher the concentration, the faster the vaccine is synthesized.", "Synthesize Vaccine") as null|anything in antibody_choices
			user.set_machine()
			if (!choice)
				return result

			var/antibody = antibody_choices[choice]

			if (antibodies[antibody] < 49)
				to_chat(user,"<span class='warning'>The time it takes to synthesize a vaccine can be drastically reduced if the blood sample is taken from a subject with higher antibody concentration. Try using spaceacillin to raise it to at least 50% before taking a sample.</span>")

			result[1] = "vaccine"
			result[2] = antibody
			result[3] = 0
			result[4] = antibodies[antibody]

	return result

/obj/machinery/disease2/centrifuge/proc/print_dish(var/datum/disease2/disease/D)
	special = CENTRIFUGE_LIGHTSPECIAL_BLINKING
	alert_noise("ping")
	anim(target = src, a_icon = icon, flick_anim = "centrifuge_print", sleeptime = 10)
	anim(target = src, a_icon = icon, flick_anim = "centrifuge_print_color", sleeptime = 10, col = D.color)
	visible_message("\The [src] prints a growth dish.")
	spawn(10)
		var/obj/item/weapon/virusdish/dish = new/obj/item/weapon/virusdish(src.loc)
		dish.contained_virus = D.getcopy()
		dish.contained_virus.infectionchance = dish.contained_virus.infectionchance_base
		dish.update_icon()
		dish.name = "growth dish (Unknown [dish.contained_virus.form])"
		if ("[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]" in virusDB)
			var/datum/data/record/v = virusDB["[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]"]
			dish.name = "growth dish ([v.fields["name"]][v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""])"


/obj/machinery/disease2/centrifuge/breakdown()
	for (var/i = 1 to vials.len)
		if(vials[i])
			var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial = vials[i]
			vial.forceMove(loc)
	vials = list(null,null,null,null)
	vial_valid = list(0,0,0,0)
	vial_task = list(
		list(0,0,0,0,0,),
		list(0,0,0,0,0,),
		list(0,0,0,0,0,),
		list(0,0,0,0,0,),
		)
	special = CENTRIFUGE_LIGHTSPECIAL_OFF
	..()

#undef CENTRIFUGE_LIGHTSPECIAL_OFF
#undef CENTRIFUGE_LIGHTSPECIAL_BLINKING
#undef CENTRIFUGE_LIGHTSPECIAL_ON
