/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Used to monitor the vitals of a patient during surgery."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/operating
	var/mob/living/carbon/human/patient
	var/obj/structure/table/optable/table
	var/list/advanced_surgeries = list()
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/operating/Initialize()
	. = ..()
	find_table()

/obj/machinery/computer/operating/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/disk/surgery))
		user.visible_message("[user] begins to load \the [O] in \the [src]...",
			"You begin to load a surgery protocol from \the [O]...",
			"You hear the chatter of a floppy drive.")
		var/obj/item/disk/surgery/D = O
		if(do_after(user, 10, target = src))
			advanced_surgeries |= D.surgeries
		return TRUE
	return ..()

/obj/machinery/computer/operating/proc/find_table()
	for(var/direction in GLOB.cardinals)
		table = locate(/obj/structure/table/optable, get_step(src, direction))
		if(table)
			table.computer = src
			break

/obj/machinery/computer/operating/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "operating_computer", name, 350, 470, master_ui, state)
		ui.open()

/obj/machinery/computer/operating/ui_data(mob/user)
	var/list/data = list()
	data["table"] = table
	if(table)
		data["patient"] = list()
		if(table.check_patient())
			patient = table.patient
			switch(patient.stat)
				if(CONSCIOUS)
					data["patient"]["stat"] = "Conscious"
					data["patient"]["statstate"] = "good"
				if(SOFT_CRIT)
					data["patient"]["stat"] = "Conscious"
					data["patient"]["statstate"] = "average"
				if(UNCONSCIOUS)
					data["patient"]["stat"] = "Unconscious"
					data["patient"]["statstate"] = "average"
				if(DEAD)
					data["patient"]["stat"] = "Dead"
					data["patient"]["statstate"] = "bad"
			data["patient"]["health"] = patient.health
			data["patient"]["blood_type"] = patient.dna.blood_type
			data["patient"]["maxHealth"] = patient.maxHealth
			data["patient"]["minHealth"] = HEALTH_THRESHOLD_DEAD
			data["patient"]["bruteLoss"] = patient.getBruteLoss()
			data["patient"]["fireLoss"] = patient.getFireLoss()
			data["patient"]["toxLoss"] = patient.getToxLoss()
			data["patient"]["oxyLoss"] = patient.getOxyLoss()
			if(patient.surgeries.len)
				data["procedures"] = list()
				for(var/datum/surgery/procedure in patient.surgeries)
					var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
					var/chems_needed = surgery_step.get_chem_list()
					var/alternative_step
					var/alt_chems_needed = ""
					if(surgery_step.repeatable)
						var/datum/surgery_step/next_step = procedure.get_surgery_next_step()
						if(next_step)
							alternative_step = capitalize(next_step.name)
							alt_chems_needed = next_step.get_chem_list()
						else
							alternative_step = "Finish operation"
					data["procedures"] += list(list(
						"name" = capitalize(procedure.name),
						"next_step" = capitalize(surgery_step.name),
						"chems_needed" = chems_needed,
						"alternative_step" = alternative_step,
						"alt_chems_needed" = alt_chems_needed
					))
	return data