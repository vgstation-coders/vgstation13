
var/global/list/analyzed_anomalies = list()
var/anomaly_report_num = 0

/obj/item/weapon/disk/hdd/anomaly
	name = "Encrypted HDD"
	desc = "Additional Anomaly data has been encrypted into this HDD, pertaining to the Alden-Saraspova equation. A Deconstructive Analyzer can decipher it."
	origin_tech = Tc_ANOMALY+"=5"
	mech_flags = MECH_SCAN_FAIL

//////////////////////////////////////////////////////////////////////////////////

/obj/machinery/artifact_analyser
	name = "anomaly analyzer"
	desc = "Studies the emissions of anomalous materials to discover their uses."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "xenoarch_console"
	anchored = TRUE
	density = TRUE
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	light_range_on = 1
	var/scan_in_progress = FALSE
	var/scan_num = 0
	var/obj/machinery/artifact_scanpad/owned_scanner = null
	var/scan_completion_time = 0
	var/scan_duration = 120
	var/atom/movable/scanned_atom

/obj/machinery/artifact_analyser/New()
	..()
	reconnect_scanner()
	update_icon()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/anom/analyser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module
	)

	RefreshParts()

/obj/machinery/artifact_analyser/RefreshParts()
	var/scancount = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/SP in component_parts)
		scancount += SP.rating-1

	scan_duration = initial(scan_duration) - scancount*10

/obj/machinery/artifact_harvester/Destroy()
	if (owned_scanner)
		owned_scanner.analyser_console = null
		owned_scanner = null
	..()

/obj/machinery/artifact_analyser/power_change()
	..()
	update_icon()

/obj/machinery/artifact_analyser/update_icon()
	if(stat & (FORCEDISABLE|NOPOWER))
		icon_state = "xenoarch_console"
		kill_moody_light()
	else
		icon_state = "[initial(icon_state)][scan_in_progress]"
		update_moody_light('icons/lighting/moody_lights.dmi', "overlay_xenoarch_console")
	if(owned_scanner)
		owned_scanner.update_icon()


/obj/machinery/artifact_analyser/proc/reconnect_scanner()
	//connect to a nearby scanner pad
	owned_scanner = locate(/obj/machinery/artifact_scanpad) in get_step(src, dir)
	if(!owned_scanner)
		owned_scanner = locate(/obj/machinery/artifact_scanpad) in orange(1, src)
	if(owned_scanner)
		owned_scanner.analyser_console = src
		owned_scanner.desc = "Place anomalies here for scanning. Exotic anomalies may provide data that will be encrypted for use by R&D."

/obj/machinery/artifact_analyser/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(!isliving(user))
		return
	src.add_fingerprint(user)

	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return

	if(!owned_scanner)
		reconnect_scanner()
	if(!owned_scanner)
		visible_message("<span class='warning'>[src] buzzes: No scan possible, unable to locate analysis pad.</span>")
	else if(scan_in_progress)
		var/confirm = alert(user,"Do you wish to halt scanning? It is currently in progress","Confirm scan halt","Yes","No") == "Yes"
		if(confirm)
			scan_in_progress = FALSE
			update_icon()
			visible_message("<span class='warning'>[src] buzzes: Scanning halted.</span>")
			if(scanned_atom && istype(scanned_atom, /obj/machinery/artifact))
				var/obj/machinery/artifact/A = scanned_atom
				A.anchored = FALSE
				A.being_used = FALSE
	else if(owned_scanner)
		var/artifact_in_use = FALSE
		for(var/atom/movable/AM in owned_scanner.loc)
			if(AM == owned_scanner)
				continue
			if(AM.invisibility)
				continue
			if(istype(AM, /obj/machinery/artifact))
				var/obj/machinery/artifact/A = AM
				if(A.being_used)
					artifact_in_use = TRUE
				else
					A.anchored = TRUE
					A.being_used = TRUE

			if(artifact_in_use)
				visible_message("<span class='warning'>[src] buzzes: Cannot harvest. Too much interference.</span>")
			else
				scanned_atom = AM
				scan_in_progress = TRUE
				update_icon()
				scan_completion_time = world.time + scan_duration
				visible_message("<span class='notice'>[src] states: Scanning begun.</span>")
				flick("xenoarch_console-flick",src)
			break
		if(!scanned_atom)
			visible_message("<span class='warning'>[src] buzzes: Unable to isolate scan target.</span>")

/obj/machinery/artifact_analyser/process()
	if(scan_in_progress && world.time > scan_completion_time)
		alert_noise("beep")
		//finish scanning
		scan_in_progress = FALSE
		update_icon()
		updateDialog()

		//print results
		var/results = ""
		var/error = FALSE
		if(!owned_scanner)
			reconnect_scanner()
		if(!owned_scanner)
			error = TRUE
			results = "Error communicating with scanner."
		else if(!scanned_atom || scanned_atom.loc != owned_scanner.loc)
			error = TRUE
			results = "Unable to locate scanned object. Ensure it was not moved in the process."
		else
			results = get_scan_info(scanned_atom)

		visible_message("<span class='notice'>[src] states: Scanning complete.</span>")
		var/obj/item/weapon/paper/anomaly/P = new(src.loc)
		P.artifact = scanned_atom
		P.info = "<b>[src] analysis report for [scanned_atom]</b><br>"
		P.info += "<br>"
		P.info += "[bicon(scanned_atom)] [results]"
		P.stamped = list(/obj/item/weapon/stamp)
		P.overlays = list("paper_stamp-qm")

		if(!findtext(P.info, "Mundane") && !error)
			var/art_id
			var/found = FALSE
			for(var/artifact_id in excavated_large_artifacts)
				if (excavated_large_artifacts[artifact_id] == scanned_atom)
					art_id = artifact_id
					found = TRUE
			if (!found)
				art_id = generate_artifact_id()
				excavated_large_artifacts[art_id] = scanned_atom
			if (!(scanned_atom in analyzed_anomalies))
				var/obj/item/weapon/disk/hdd/anomaly/HDD = new (src.loc)
				analyzed_anomalies += scanned_atom
				HDD.name = "Encrypted HDD ([art_id])"
			P.name = "Exotic Anomaly Report ([art_id])"
		else
			anomaly_report_num++
			P.name = "Mundane Anomaly Report #[anomaly_report_num]"

		if(scanned_atom && istype(scanned_atom, /obj/machinery/artifact))
			var/obj/machinery/artifact/A = scanned_atom
			A.anchored = FALSE
			A.being_used = FALSE
			if (!A.analyzed)
				A.analyzed = TRUE
				if (istype(A.primary_effect) && A.primary_effect.triggered)
					score.artifacts++

//hardcoded responses, oh well
/proc/get_scan_info(var/atom/movable/AM)
	switch(AM.type)
		if(/obj/machinery/auto_cloner)
			return "Automated cloning pod - appears to rely on organic nanomachines with a self perpetuating \
			ecosystem involving self cannibalism and a symbiotic relationship with the contained liquid.<br><br>\
			Structure is composed of a carbo-titanium alloy with interlaced reinforcing energy fields, and the contained liquid \
			resembles proto-plasmic residue supportive of single cellular developmental conditions."
		if(/obj/machinery/power/supermatter)
			return "Super dense plasma clump - Appears to have been shaped or hewn, structure is composed of matter 2000% denser than ordinary carbon matter residue.\
			Potential application as unrefined plasma source."
		if(/obj/structure/constructshell)
			return "Tribal idol - Item resembles statues/emblems built by superstitious pre-warp civilisations to honour their gods. Material appears to be a \
			rock/plastcrete composite."
		if(/obj/structure/bed/chair/vehicle/gigadrill)
			return "An old and dusty vehicle with a mining drill - structure composed of titanium-carbide alloy, with tip and drill lines edged in an alloy of diamond and plasma."
		if(/obj/structure/cult/pylon)
			return "Tribal pylon - Item resembles statues/emblems built by cargo cult civilisations to honour energy systems from post-warp civilisations."
		if(/obj/mecha/working/hoverpod)
			return "Vacuum capable repair pod - Item is a remarkably intact single man repair craft capable of flight in a vacuum. Outer shell composed of primarily \
			post-warp hull alloys, with internal wiring and circuitry consistent with modern electronics and engineering."
		if(/obj/machinery/replicator)
			return "Automated construction unit - Item appears to be able to synthesize synthetic items, some with simple internal circuitry. Method unknown, \
			phasing suggested?"
		if(/obj/structure/crystal)
			return "Crystal formation - Pseudo organic crystalline matrix, unlikely to have formed naturally. No known technology exists to synthesize this exact composition."
		if(/obj/machinery/communication)
			return "Ancient Communivation Device - Requires to be wrenched in a powered area. Permits bluespace communication between the bearers of the crystals."
		if(/obj/structure/essence_printer)
			return "Essence Printer - Interaction of a human with the item seem to bind their essence to the stone. Under unknown circumstances, a sentient clone of the human will come out of the stone, whether the original human is alive or dead."
		if(/obj/item/clothing/gloves/warping_claws)
			return "Warping Claws - Permits quick travel by ripping straight through the fabric of space. Those claws are quite cumbersome however, do not expect being able to use any machine while wearing them."
		if(/obj/machinery/singularity_beacon)
			return "Ominous Beacon - Graviton attraction device. Will converge nearby gravitational singularities toward itself so long as it remains powered."
		if(/obj/item/clothing/mask/stone)
			return "Stone Mask - Very ancient. The spikes coming out of it would bury deep into the brain of whoever tried wearing it, obviously killing them."//well this was Dio's first theory when he found out about the mask's spikes.
		if(/obj/item/changeling_vial)
			return "Secure Vial - The organic liquid in it appears to move around periodically, it seems to be some sort of lifeform. The vial would have to be openned to get a better analysis."
		if(/obj/machinery/syndicate_beacon)
			return "Syndicate Beacon - An old deprecated terminal that the Syndicate used to communicate with their agents, before the advent of uplinks that were easier to hide. Surely the Syndicate doesn't read the frequencies used by those anymore."
		if(/obj/item/weapon/bloodcult_pamphlet/oneuse)
			return "Cult Pamphlet - Unable to identify the type of creature whose skin was used to produce this parchment, likewise the ink used appears to be blood but the DNA doesn't match any creature currently known in the galaxy. Potentially huge breakthrough."
		if(/mob/living/simple_animal/hostile/roboduck)
			return "Robot Duck - Scans shows an unreal amount of bullets inside it. Presence of an AI chip might indicate that the robot won't attack unless provoked. Also identified what looks like a digestive system, indicating that it might be able to process its preys into some other forms."
		if(/obj/machinery/cryopod)
			return "Ancient Cryogenic Pod - A machine able to freeze a single occupant in cryogenic suspension for a near indefinite amount of time. Contains equipment to freeze, as well as to thaw the occupant, powered by a nuclear battery."
		if(/obj/machinery/artifact)
			//the fun one
			var/obj/machinery/artifact/A = AM
			var/out = "Energy signature ID - [A.artifact_id]<br><br>"
			out += "Anomalous alien device - Composed of an unknown alloy, "

			//primary effect
			if(A.primary_effect)
				//what kind of effect the artifact has
				switch(A.primary_effect.effect_type)
					if(1)
						out += "concentrated energy emissions"
					if(2)
						out += "intermittent psionic wavefront"
					if(3)
						out += "electromagnetic energy"
					if(4)
						out += "high frequency particles"
					if(5)
						out += "organically reactive exotic particles"
					if(6)
						out += "interdimensional/bluespace? phasing"
					if(7)
						out += "atomic synthesis"
					else
						out += "low level energy emissions"
				out += " have been detected "

				//how the artifact does it's effect
				switch(A.primary_effect.effect)
					if(1)
						out += " emitting in an ambient energy field."
					if(2)
						out += " emitting in periodic bursts."
					else
						out += " interspersed throughout substructure and shell."

				//effect's trigger
				switch(A.primary_effect.trigger.scanned_trigger)
					if(SCAN_PHYSICAL)
						out += " Activation index involves physical interaction with artifact surface."
					if(SCAN_PHYSICAL_ENERGETIC)
						out += " Activation index involves energetic interaction with artifact surface."
					if(SCAN_CONSTANT_ENERGETIC)
						out += " Activation index involves prolonged energetic interaction with artifact surface."
					if(SCAN_ATMOS)
						out += " Activation index involves precise local atmospheric conditions."
					if(SCAN_OCULAR)
						out += " Activation index involves specific ocular conditions around the artifact."
					else
						out += " Unable to determine any data about activation trigger."

			//secondary:
			if(A.secondary_effect)
				//sciencey words go!
				out += "<br><br>Warning, internal scans indicate ongoing [pick("subluminous","subcutaneous","superstructural")] activity operating \
				independantly from primary systems. Auxiliary activity involves "

				//what kind of effect the artifact has
				switch(A.secondary_effect.effect_type)
					if(1)
						out += "concentrated energy emissions"
					if(2)
						out += "intermittent psionic wavefront"
					if(3)
						out += "electromagnetic energy"
					if(4)
						out += "high frequency particles"
					if(5)
						out += "organically reactive exotic particles"
					if(6)
						out += "interdimensional/bluespace? phasing"
					if(7)
						out += "atomic synthesis"
					else
						out += "low level radiation"

				//how the artifact does it's effect
				switch(A.secondary_effect.effect)
					if(1)
						out += " emitting in an ambient energy field."
					if(2)
						out += " emitting in periodic bursts."
					else
						out += " interspersed throughout substructure and shell."

				//effect's trigger
				switch(A.secondary_effect.trigger.scanned_trigger)
					if(SCAN_PHYSICAL)
						out += " Activation index involves physical interaction with artifact surface."
					if(SCAN_PHYSICAL_ENERGETIC)
						out += " Activation index involves energetic interaction with artifact surface."
					if(SCAN_CONSTANT_ENERGETIC)
						out += " Activation index involves prolonged energetic interaction with artifact surface."
					if(SCAN_ATMOS)
						out += " Activation index involves precise local atmospheric conditions."
					if(SCAN_OCULAR)
						out += " Activation index involves specific ocular conditions around the artifact."
					else
						out += " Unable to determine any data about activation trigger."

				out+= " Subsystems indicate anomalous interference with standard attempts at triggering."
			return out
		else
			//it was an ordinary item
			var/result = "[AM.name] - Mundane application, composed of carbo-ferritic alloy composite."//TODO: be more descriptive depending on the type of object
			if (ismob(AM))
				result = "[AM.name] - Mundane creature."
				if (iscarbon(AM))
					result += " carbon-based."
				if (issilicon(AM))
					result += " silicon-based."
			return result
