/*
CONTAINS:
T-RAY
HEALTH ANALYZER
GAS ANALYZER
MASS SPECTROMETER
REAGENT SCANNER
BREATHALYZER
*/

#define CAN_REVIVE_NO 0 // Human cannot be revived.
#define CAN_REVIVE_GHOSTING 1 // Human is observing but can otherwise be revived.
#define CAN_REVIVE_IN_BODY 2 // Human can be revived AND is in body.


/obj/item/device/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner that can pick up the faintest traces of energy, used to detect the invisible."
	icon_state = "t-ray0"
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	starting_materials = list(MAT_IRON = 500, MAT_GLASS = 100)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = Tc_MAGNETS + "=1;" + Tc_ENGINEERING + "=1"

	var/on = 0
	var/base_state = "t-ray"
	var/ray_range = 1

/obj/item/device/t_scanner/Destroy()
	if(on)
		processing_objects.Remove(src)
	..()

/obj/item/device/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = "[base_state][on]"

	if(on)
		processing_objects.Add(src)


/obj/item/device/t_scanner/process()
	if(!on)
		processing_objects.Remove(src)
		return null

	for(var/turf/T in trange(ray_range, get_turf(src)))

		if(!T.intact)
			continue

		for(var/obj/O in T.contents)
			O.t_scanner_expose()

		for(var/mob/living/M in T.contents)
			var/oldalpha = M.alpha
			if(M.alpha < 255 && istype(M))
				M.alpha = 255
				spawn(10)
					if(M)
						M.alpha = oldalpha

		var/mob/living/M = locate() in T
		if(M && M.invisibility == 2)
			M.invisibility = 0
			spawn(10)
				if(M)
					M.invisibility = INVISIBILITY_LEVEL_TWO

/obj/item/device/t_scanner/advanced
	name = "\improper P-ray scanner"
	desc = "A petahertz-ray emitter and scanner that can pick up the faintest traces of energy, used to detect the invisible. Has a significantly better range than t-ray scanners."
	icon_state = "p-ray0"
	origin_tech = Tc_MAGNETS + "=3;" + Tc_ENGINEERING + "=3"

	base_state = "p-ray"
	ray_range = 3

/obj/item/device/healthanalyzer
	name = "health analyzer"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	icon_state = "health"
	item_state = "healthanalyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	starting_materials = list(MAT_IRON = 200)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = Tc_MAGNETS + "=1;" + Tc_BIOTECH + "=1"
	attack_delay = 0
	var/tmp/last_scantime = 0
	var/last_reading = null
	var/mode = 1

/obj/item/device/healthanalyzer/attack(mob/living/M as mob, mob/living/user as mob)
	if(!user.hallucinating())
		if(last_scantime + 1 SECONDS < world.time)
			last_reading = healthanalyze(M, user, mode, silent = FALSE)
			last_scantime = world.time
		else
			last_reading = healthanalyze(M, user, mode, silent = TRUE)
	else
		if(M.isDead())
			user.show_message("<span class='game say'><b>\The [src] beeps</b>, \"It's dead, Jim.\"</span>", MESSAGE_HEAR ,"<span class='notice'>\The [src] glows black.</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] glows [pick("red", "green", "blue", "pink")]! You wonder what that would mean.</span>")
	src.add_fingerprint(user)


/obj/item/device/healthanalyzer/afterattack(var/atom/A, var/mob/user)
	. = ..()
	if(.)
		return

	if (A.Adjacent(user) && isitem(A))
		var/obj/item/I = A
		if(I.virus2 && I.virus2.len > 0)
			playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
			for(var/ID in I.virus2)
				var/datum/disease2/disease/D = I.virus2[ID]
				if(ID in virusDB)
					var/datum/data/record/V = virusDB[ID]
					to_chat(user,"<span class='warning'>Warning: [V.fields["name"]][V.fields["nickname"] ? " \"[V.fields["nickname"]]\"" : ""] detected on \the [src]. Antigen: [D.get_antigen_string()]</span>")
				else
					to_chat(user,"<span class='warning'>Warning: Unknown [D.form] detected on \the [src].</span>")
		else
			to_chat(user,"<span class='notice'>No pathogen detected on \the [src].</span>")


/obj/item/device/healthanalyzer/attack_self(mob/living/user as mob)
	. = ..()
	if(.)
		return
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(last_reading)
		to_chat(user, "<span class='bnotice'>Accessing Prior Scan Result</span>")
		to_chat(user, last_reading)

//Note : Used directly by other objects. Could benefit of OOP, maybe ?
proc/healthanalyze(mob/living/M as mob, mob/living/user as mob, var/mode = 0, var/skip_checks = 0, var/silent = 0)
	var/message = ""
	if(!skip_checks)
		if(((M_CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
			user.visible_message("<span class='warning'>[user] analyzes the floor's vitals!</span>", \
			"<span class='warning'>You analyze the floor's vitals!</span>")
			playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
			to_chat(user, {"<span class='notice'>Analyzing Results for the floor:<br>Overall Status: Healthy</span>
Key: <span class='notice'>Suffocation</span>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<span class='red'>Brute</span>
Damage Specifics: <span class='notice'>0</span> - <font color='green'>0</font> - <font color='#FFA500'>0</font> - <span class='red'>0</span>
[(M.undergoing_hypothermia()) ?  "<span class='warning'>" : "<span class='notice'>"]Body Temperature: ???&deg;C (???&deg;F)</span>
<span class='notice'>Localized Damage, Brute/Burn:</span>
<span class='notice'>No limb damage detected.</span>
Blood Level Unknown: ???% ???cl
Subject's pulse: ??? BPM"})
			return
	if(!silent)
		user.visible_message("<span class='notice'>[user] analyzes [M]'s vitals.</span>", ignore_self = TRUE)
		playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
	var/fake_oxy = max(rand(1, 40), M.getOxyLoss(), (300 - (M.getToxLoss() + M.getFireLoss() + M.getBruteLoss())))
	var/OX = M.getOxyLoss() > 50   ? "<b>[M.getOxyLoss()]</b>"   : M.getOxyLoss()
	var/TX = M.getToxLoss() > 50   ? "<b>[M.getToxLoss()]</b>"   : M.getToxLoss()
	var/BU = M.getFireLoss() > 50  ? "<b>[M.getFireLoss()]</b>"  : M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 ? "<b>[M.getBruteLoss()]</b>" : M.getBruteLoss()
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 ? "<b>[fake_oxy]</b>" : fake_oxy
		message += "<span class='notice'>Analyzing Results for [M]:<br>Overall Status: Dead</span><br>"
	else
		message += "<span class='notice'>Analyzing Results for [M]:<br>Overall Status: [M.stat > 1 ? "Dead" : "[M.health - M.halloss]% Healthy"]</span>"
	if(isanimal(M))
		to_chat(user, message)//Simple animal, we don't care about anything else.
		return message
	message += "<br>Key: <span class='notice'>Suffocation</span>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<span class='red'>Brute</span>"
	message += "<br>Damage Specifics: <span class='notice'>[OX]</span> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <span class='red'>[BR]</span>"
	message += "<br>[(M.undergoing_hypothermia()) ?  "<span class='warning'>" : "<span class='notice'>"]Body Temperature: [round(M.bodytemperature-T0C,0.1)]&deg;C ([round(M.bodytemperature*1.8-459.67,0.1)]&deg;F)</span>"
	if(M.tod && M.isDead())
		message += "<br><span class='notice'>Time of Death: [M.tod]</span>"
	if(istype(M, /mob/living/carbon/human) && mode)
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_organs(1, 1)
		message += "<br><span class='notice'>Localized Damage, Brute/Burn:</span>"
		if(length(damaged))
			for(var/datum/organ/external/org in damaged)
				var/organ_msg = "<br>"
				organ_msg += capitalize(org.display_name)
				organ_msg += ": "
				organ_msg += "<span class='red'>[org.brute_dam ? org.brute_dam : 0]</span>"
				organ_msg += "/<font color='#FFA500'>[org.burn_dam ? org.burn_dam : 0]</font>"
				if(org.status & ORGAN_BLEEDING)
					organ_msg += "<span class='danger'>\[BLEEDING\]</span>"
				if(org.status & org.is_peg())
					organ_msg += "<span class='bnotice'>\[WOOD DETECTED?\]</span>"
				if(org.status & org.is_robotic())
					organ_msg += "<span class='bnotice'>\[METAL DETECTED?\]</span>"
				message += organ_msg
		else
			message += "<br><span class='notice'>No limb damage detected.</span>"

	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 ? "<span class='notice'><b>Severe oxygen deprivation detected</b></span>" : "Subject bloodstream oxygen level normal"

	if(hardcore_mode_on && ishuman(M) && eligible_for_hardcore_mode(M))
		var/mob/living/carbon/human/H = M
		if(H.nutrition < STARVATION_MIN)
			message += "<br><span class='danger'>Warning: Subject starving.</span>"

	if(M.virus2.len)
		for(var/ID in M.virus2)
			var/datum/disease2/disease/D = M.virus2[ID]
			if(ID in virusDB)
				var/datum/data/record/V = virusDB[ID]
				message += "<br><span class='warning'>[V.fields["name"]][V.fields["nickname"] ? " \"[V.fields["nickname"]]\"" : ""] detected in subject's blood. Strength: [D.strength]. Antigen: [D.get_antigen_string()]</span>"
			else
				message += "<br><span class='warning'>Unknown [D.form] detected in subject's blood. Strength: [D.strength]</span>"
	else
		message += "<br><span class='notice'>No pathogen detected in subject's blood.</span>"

	for(var/datum/disease/D in M.viruses)
		if(!D.hidden[SCANNER])
			message += "<br><span class='warning'><b>Warning: [D.form] Detected</b><br>Name: [D.name].<br>Type: [D.spread].<br>Stage: [D.stage]/[D.max_stages].<br>Possible Cure: [D.cure]</span>"

	if(M.getCloneLoss())
		message += "<br><span class='warning'>Genetic decomposition detected.</span>"
	if(M.has_brain_worms())
		message += "<br><span class='warning'>Strange MRI readout. Further scanning required.</span>"
	else if(M.getBrainLoss() >= 100 || !M.has_brain())
		message += "<br><span class='warning'>No brain activity has been detected. Subject is braindead.</span>"
	else if(M.getBrainLoss() >= 60)
		message += "<br><span class='warning'>Severe brain damage detected. Potential mental retardation.</span>"
	else if(M.getBrainLoss() >= 10)
		message += "<br><span class='warning'>Significant brain damage detected. Potential Concussion.</span>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/bone_fracture
		var/infection
		var/cancer
		for(var/name in H.organs_by_name)
			var/datum/organ/external/e = H.organs_by_name[name]
			if(!bone_fracture && e.is_broken())
				message += text("<br><span class='warning'>Bone fractures detected.</span>")
				bone_fracture = TRUE
			for(var/datum/wound/W in e.wounds)
				if(W.internal)
					message += text("<br><span class='danger'>Internal bleeding detected.</span>")
					break
			if(!infection && e.has_infected_wound())
				message += "<br><span class='warning'>Infected wound detected.</span>"
				infection = TRUE
			if(!cancer && e.cancer_stage > CANCER_STAGE_LARGE_TUMOR) //Health analyzers can detect large tumors and above in external limbs, if all else fails
				cancer = TRUE
				message += text("<br><span class='danger'>Serious cancerous growth detected. </span>")
		if(H.vessel)
			var/blood_volume = round(H.vessel.get_reagent_amount(BLOOD))
			var/blood_percent =  round((blood_volume / 560) * 100)
			switch(blood_volume)
				if(BLOOD_VOLUME_SAFE to 1000000000)
					message += "<br><span class='notice'>Blood Level Normal: [blood_percent]% ([blood_volume]cl)</span>"
				if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
					message += "<br><span class='warning'>Warning: Blood Level Low: [blood_percent]% [blood_volume]cl</span>" //Still about fine
				if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
					message += "<br><span class='danger'>Danger: Blood Level Serious: [blood_percent]% [blood_volume]cl</span>"
				if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
					message += "<br><span class='danger'>Danger: Blood Level Critical: [blood_percent]% [blood_volume]cl</span>"
				if(-1000000000 to BLOOD_VOLUME_SURVIVE)
					message += "<br><span class='danger'>Danger: Blood Level Fatal: [blood_percent]% [blood_volume]cl</span>"
		message += "<br><span class='notice'>Subject's pulse: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : "blue"]'>[H.get_pulse(GETPULSE_TOOL)] BPM</font></span>"
		if (H.isDead())
			var/revive_status = check_can_revive(H)

			if (revive_status == CAN_REVIVE_NO)
				message += "<br><span class='danger'>No brainwaves detected. Subject cannot be revived.</span>"

			else if (revive_status == CAN_REVIVE_GHOSTING)
				message += "<br><span class='notice'>Faint brainwaves detected. Subject may be revivable.</span>"

			else if (revive_status == CAN_REVIVE_IN_BODY)
				message += "<br><span class='notice'>Faint brainwaves detected. Subject can be revived.</span>"

	to_chat(user, message)//Here goes

	return message //To read last scan

/proc/check_can_revive(mob/living/carbon/human/target)
	ASSERT(istype(target))
	ASSERT(target.isDead())

	if (!target.mind)
		return CAN_REVIVE_NO

	if (target.client)
		return CAN_REVIVE_IN_BODY

	var/mob/dead/observer/ghost = mind_can_reenter(target.mind)
	if (!ghost)
		return CAN_REVIVE_NO

	var/mob/ghostmob = ghost.get_top_transmogrification()
	if (!ghostmob)
		return CAN_REVIVE_NO

	return CAN_REVIVE_GHOSTING

/obj/item/device/healthanalyzer/verb/toggle_mode()
	set name = "Switch mode"
	set category = "Object"

	mode = !mode
	to_chat(usr, "The scanner will [mode ? "now show specific limb damage" : "no longer show specific limb damage"].")

/obj/item/device/analyzer
	desc = "A hand-held environment scanner which reports data about gas mixtures."
	name = "atmospheric analyzer"
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = W_CLASS_SMALL
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 20)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = Tc_MAGNETS + "=1;" + Tc_ENGINEERING + "=1"

/obj/item/device/analyzer/attack_self(mob/user as mob)

	. = ..()
	if(.)
		return

	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	var/atom/location = is_holder_of(user, src) ? user.loc : get_turf(src) //If user isn't the holder we're either in a mech's equipment loadout or something weird so get the outside environment

	if(!location) //Somehow
		return

	var/datum/gas_mixture/environment = location.return_air()

	var/unit_vol = environment && environment.volume > CELL_VOLUME ? CELL_VOLUME : null

	to_chat(user, output_gas_scan(environment, location, 1, unit_vol))

	src.add_fingerprint(user)
	return

/obj/item/device/analyzer/scope
	desc = "A hand-held environment scanner which can gather data about gas mixtures at a distance by analyzing how light travels through the gases."
	name = "atmospheric analysis scope"
	icon_state = "atmos_scope"
	origin_tech = Tc_MAGNETS + "=3;" + Tc_ENGINEERING + "=3"

/obj/item/device/analyzer/scope/afterattack(atom/A, mob/user)
	. = ..()
	if(.)
		return
	if(!isturf(A))
		return

	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	var/turf/T = A
	var/datum/gas_mixture/environment = T.return_air()
	to_chat(user, output_gas_scan(environment, T, 1, CELL_VOLUME))
	add_fingerprint(user)

//If human_standard is enabled, the message will be formatted to show which values are dangerous
//If unit_vol is specified, it will output the values for that volume of the scanned gas. Really for analyzing areas.
/obj/item/device/analyzer/proc/output_gas_scan(var/datum/gas_mixture/scanned, var/atom/container, human_standard = 1, unit_vol)
	if(!scanned)
		return "<span class='warning'>No gas mixture found.</span>"
	scanned.update_values()
	if(unit_vol)
		var/datum/gas_mixture/unit = new() //Unless something goes horribly wrong, this will be cleaned up by the GC at the end of the proc.
		unit.volume = unit_vol
		unit.copy_from(scanned)
		scanned = unit
	var/pressure = scanned.return_pressure()
	var/total_moles = scanned.total_moles()
	var/message = ""
	if(!container || istype(container, /turf))
		message += "<span class='bnotice'>Results:</span>"
	else
		message += "<span class='bnotice'><B>[bicon(container)] Results of [container] scan:</span></B>"
	if(total_moles)
		message += "<br>[human_standard && abs(pressure - ONE_ATMOSPHERE) > 10 ? "<span class='bad'>" : "<span class='notice'>"] Pressure: [round(pressure, 0.1)] kPa</span>"
		var/o2_concentration = scanned[GAS_OXYGEN]/total_moles
		var/n2_concentration = scanned[GAS_NITROGEN]/total_moles
		var/co2_concentration = scanned[GAS_CARBON]/total_moles
		var/plasma_concentration = scanned[GAS_PLASMA]/total_moles
		var/heat_capacity = scanned.heat_capacity()

		var/unknown_concentration =  1 - (o2_concentration + n2_concentration + co2_concentration + plasma_concentration)

		if(n2_concentration > 0.01)
			message += "<br>[human_standard && abs(n2_concentration - N2STANDARD) > 20 ? "<span class='bad'>" : "<span class='notice'>"] Nitrogen: [round(scanned[GAS_NITROGEN], 0.1)] mol, [round(n2_concentration*100)]%</span>"
		if(o2_concentration > 0.01)
			message += "<br>[human_standard && abs(o2_concentration - O2STANDARD) > 2 ? "<span class='bad'>" : "<span class='notice'>"] Oxygen: [round(scanned[GAS_OXYGEN], 0.1)] mol, [round(o2_concentration*100)]%</span>"
		if(co2_concentration > 0.01)
			message += "<br>[human_standard ? "<span class='bad'>" : "<span class='notice'>"] CO2: [round(scanned[GAS_CARBON], 0.1)] mol, [round(co2_concentration*100)]%</span>"
		if(plasma_concentration > 0.01)
			message += "<br>[human_standard ? "<span class='bad'>" : "<span class='notice'>"] Plasma: [round(scanned[GAS_PLASMA], 0.1)] mol, [round(plasma_concentration*100)]%</span>"
		if(unknown_concentration > 0.01)
			message += "<br><span class='notice'>Unknown: [round(unknown_concentration*100)]%</span>"

		message += "<br>[human_standard && !IsInRange(scanned.temperature, BODYTEMP_COLD_DAMAGE_LIMIT, BODYTEMP_HEAT_DAMAGE_LIMIT) ? "<span class='bad'>" : "<span class='notice'>"] Temperature: [round(scanned.temperature-T0C)]&deg;C"
		message += "<br><span class='notice'>Heat capacity: [round(heat_capacity, 0.01)]</span>"
	else
		message += "<br><span class='warning'>No gasses detected[container && !istype(container, /turf) ? " in \the [container]." : ""]!</span>"
	return message

/obj/item/device/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	name = "mass-spectrometer"
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = W_CLASS_SMALL
	flags = FPRINT | OPENCONTAINER
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 20)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_MAGNETS + "=2;" + Tc_BIOTECH + "=2"
	var/details = 0

/obj/item/device/mass_spectrometer/New()
	. = ..()
	create_reagents(5)

/obj/item/device/mass_spectrometer/on_reagent_change()
	if(reagents.total_volume)
		icon_state = initial(icon_state) + "_s"
	else
		icon_state = initial(icon_state)

/obj/item/device/mass_spectrometer/attack(mob/living/M as mob, mob/living/user as mob)
	if(!M.reagents)
		return
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(reagents.total_volume)
			to_chat(user, "<span class='warning'>This device already has a blood sample!</span>")
			return
		if(!user.dexterity_check())
			to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
			return
		if(!C.dna)
			return
		if(M_HUSK in C.mutations)
			return

		var/datum/reagent/B = C.take_blood(src, src.reagents.maximum_volume)
		if(B)
			update_icon()
			user.visible_message("<span class='warning'>[user] takes a blood sample from [C].</span>", \
			"<span class='notice'>You take a blood sample from [C]</span>")
			playsound(src, 'sound/items/hypospray.ogg', 50, 1) //It uses the same thing as the hypospray, in reverse. SCIENCE!

/obj/item/device/mass_spectrometer/attack_self(mob/user as mob)
	. = ..()
	if(.)
		return

	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != BLOOD)
				reagents.clear_reagents()
				to_chat(user, "<span class='warning'>The sample was contaminated! Please insert another sample.</span>")
				return
			else
				blood_traces = params2list(R.data["trace_chem"])
				break
		var/dat
		if(blood_traces.len)
			dat = "Trace Chemicals Found:"
			for(var/R in blood_traces)
				dat += "<br>[R] [details ? "([blood_traces[R]] units)":""]"
		else
			dat = "No trace chemicals found in the sample."
		to_chat(user, "<span class='notice'>[dat]</span>")
		reagents.clear_reagents()
	return

/obj/item/device/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = Tc_MAGNETS + "=4;" + Tc_BIOTECH + "=2"

/obj/item/device/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents."
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = W_CLASS_SMALL
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 20)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_MAGNETS + "=2;" + Tc_BIOTECH + "=2"
	var/details = 0
	var/recent_fail = 0

/obj/item/device/reagent_scanner/preattack(atom/O, mob/user, proximity_flag)
	if(!proximity_flag)
		return
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(O.reagents)
		playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
		var/dat = ""
		if(O.reagents.reagent_list.len)
			for(var/datum/reagent/R in O.reagents.reagent_list)
				var/reagent_percent = (R.volume/O.reagents.total_volume)*100
				dat += "<br><span class='notice'>[R] [details ? "([R.volume] units, [reagent_percent]%[R.data && !istype(R,/datum/reagent/citalopram) && !istype(R,/datum/reagent/paroxetine) && !istype(R,/datum/reagent/incense) && !istype(R,/datum/reagent/antipathogenic) && !istype(R,/datum/reagent/vaccine) ? ", time in system: [R.data*2] seconds" : ""])" : ""]</span>"
		if(dat)
			to_chat(user, "<span class='notice'>Chemicals found in \the [O]:[dat]</span>")
		else
			to_chat(user, "<span class='notice'>No active chemical agents found in \the [O].</span>")
		return TRUE
	else
		return ..()

/obj/item/device/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = Tc_MAGNETS + "=4;" + Tc_BIOTECH + "=2"

/obj/item/device/breathalyzer
	name = "breathalyzer"
	icon = 'icons/obj/breathalyzer.dmi'
	icon_state = "idle"
	item_state = "analyzer"
	desc = "A hand-held scanner that is able to determine the amount of ethanol in the breath of the subject."
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	starting_materials = list(MAT_IRON = 50)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = Tc_ENGINEERING + "=1;" + Tc_BIOTECH + "=1"

	var/legal_limit

/obj/item/device/breathalyzer/New()
	var/datum/reagent/ethanol/E = /datum/reagent/ethanol
	legal_limit = initial(E.slur_start) //inb4 shitcurity arrests people for being over the legal limit
	..()

/obj/item/device/breathalyzer/attack_self(mob/user)
	var/I = input("Set the legal limit of ethanol.", "Legal Limit", legal_limit) as null|num

	if(I)
		legal_limit = max(0, I)
		to_chat(user, "<span class='notice'>You successfully set the legal limit of the breathalyzer.</span>")

/obj/item/device/breathalyzer/attack(mob/living/M, mob/living/user)
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(!ishuman(M))
		return

	var/mob/living/carbon/human/C = M

	if(C.check_body_part_coverage(MOUTH))
		to_chat(src, "<span class='notice'><B>Remove their [C.get_body_part_coverage(MOUTH)] before using the breathalyzer.</B></span>")
		return

	playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)

	var/alcohol = 0

	for(var/datum/reagent/ethanol/E in C.reagents.reagent_list)
		alcohol += E.volume

	var/dat = "<span class='notice'>The breathalyzer reports that [C] has [alcohol] units of ethanol in their blood.</span>"

	if(alcohol >= legal_limit)
		dat += "<br><span class='warning'>This is above the legal limit of [legal_limit]!</span>"
		flick("DRUNK", src)
	else
		flick("SOBER", src)

	to_chat(user, dat)

/obj/item/device/breathalyzer/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Its legal limit is set to [legal_limit] units.</span>")


#undef CAN_REVIVE_NO
#undef CAN_REVIVE_GHOSTING
#undef CAN_REVIVE_IN_BODY
