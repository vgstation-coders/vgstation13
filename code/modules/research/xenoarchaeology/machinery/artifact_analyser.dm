
/obj/machinery/artifact_analyser
	name = "anomaly analyser"
	desc = "Studies the emissions of anomalous materials to discover their uses."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "xenoarch_console"
	anchored = TRUE
	density = TRUE
	var/scan_in_progress = FALSE
	var/scan_num = 0
	var/obj/scanned_obj
	var/obj/machinery/artifact_scanpad/owned_scanner = null
	var/scan_completion_time = 0
	var/scan_duration = 120
	var/obj/scanned_object
	var/report_num = 0

/obj/machinery/artifact_analyser/New()
	..()
	reconnect_scanner()
	update_icon()

/obj/machinery/artifact_analyser/update_icon()
	icon_state = "[initial(icon_state)][scan_in_progress]"
	if(owned_scanner)
		owned_scanner.update_icon()

/obj/machinery/artifact_analyser/proc/reconnect_scanner()
	//connect to a nearby scanner pad
	owned_scanner = locate(/obj/machinery/artifact_scanpad) in get_step(src, dir)
	if(!owned_scanner)
		owned_scanner = locate(/obj/machinery/artifact_scanpad) in orange(1, src)
	if(owned_scanner)
		owned_scanner.owner_console = src

/obj/machinery/artifact_analyser/attack_hand(var/mob/user as mob)
	if(..())
		return
	src.add_fingerprint(user)
	interact(user)

/obj/machinery/artifact_analyser/interact(mob/user)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN) || get_dist(src, user) > 1)
		user.unset_machine(src)
		return

	var/dat = "<B>Anomalous material analyser</B><BR>"
	dat += "<HR>"
	if(!owned_scanner)
		owned_scanner = locate() in orange(1, src)

	if(!owned_scanner)
		dat += "<b><font color=red>Unable to locate analysis pad.</font></b><br>"
	else if(scan_in_progress)
		dat += "Please wait. Analysis in progress.<br>"
		dat += "<a href='?src=\ref[src];halt_scan=1'>Halt scanning.</a><br>"
	else
		dat += "Scanner is ready.<br>"
		dat += "<a href='?src=\ref[src];begin_scan=1'>Begin scanning.</a><br>"

	dat += "<br>"
	dat += "<hr>"
	dat += "<a href='?src=\ref[src]'>Refresh</a> <a href='?src=\ref[src];close=1'>Close</a>"
	user << browse(dat, "window=artanalyser;size=450x500")
	user.set_machine(src)
	onclose(user, "artanalyser")

/obj/machinery/artifact_analyser/process()
	if(scan_in_progress && world.time > scan_completion_time)
		//finish scanning
		scan_in_progress = FALSE
		update_icon()
		updateDialog()

		//print results
		var/results = ""
		if(!owned_scanner)
			reconnect_scanner()
		if(!owned_scanner)
			results = "Error communicating with scanner."
		else if(!scanned_object || scanned_object.loc != owned_scanner.loc)
			results = "Unable to locate scanned object. Ensure it was not moved in the process."
		else
			results = get_scan_info(scanned_object)

		src.visible_message("<b>[name]</b> states, \"Scanning complete.\"")
		var/obj/item/weapon/paper/P = new(src.loc)
		P.name = "[src] report #[++report_num]"
		P.info = "<b>[src] analysis report #[report_num]</b><br>"
		P.info += "<br>"
		P.info += "[bicon(scanned_object)] [results]"
		P.stamped = list(/obj/item/weapon/stamp)
		P.overlays = list("paper_stamp-qm")

		if(!findtext(P.info, "Mundane"))
			P.origin_tech = Tc_ANOMALY+"=5"
			P.info += "<br>"
			P.info += "<br><i>Additional data has been encrypted into this report, pertaining to the Alden-Saraspova equation. A Deconstructive Analyzer can decipher it.</i>"

		if(scanned_object && istype(scanned_object, /obj/machinery/artifact))
			var/obj/machinery/artifact/A = scanned_object
			A.anchored = FALSE
			A.being_used = FALSE

/obj/machinery/artifact_analyser/Topic(href, href_list)
	if(..())
		return
	if(href_list["begin_scan"])
		if(!owned_scanner)
			reconnect_scanner()
		if(owned_scanner)
			var/artifact_in_use = FALSE
			for(var/obj/O in owned_scanner.loc)
				if(O == owned_scanner)
					continue
				if(O.invisibility)
					continue
				if(istype(O, /obj/machinery/artifact))
					var/obj/machinery/artifact/A = O
					if(A.being_used)
						artifact_in_use = TRUE
					else
						A.anchored = TRUE
						A.being_used = TRUE

				if(artifact_in_use)
					src.visible_message("<b>[name]</b> states, \"Cannot harvest. Too much interference.\"")
				else
					scanned_object = O
					scan_in_progress = TRUE
					update_icon()
					scan_completion_time = world.time + scan_duration
					src.visible_message("<b>[name]</b> states, \"Scanning begun.\"")
				break
			if(!scanned_object)
				src.visible_message("<b>[name]</b> states, \"Unable to isolate scan target.\"")
	if(href_list["halt_scan"])
		scan_in_progress = FALSE
		update_icon()
		src.visible_message("<b>[name]</b> states, \"Scanning halted.\"")
		if(scanned_object && istype(scanned_object, /obj/machinery/artifact))
			var/obj/machinery/artifact/A = scanned_object
			A.anchored = FALSE
			A.being_used = FALSE

	if(href_list["close"])
		usr.unset_machine(src)
		usr << browse(null, "window=artanalyser")

	updateDialog()

//hardcoded responses, oh well
/obj/machinery/artifact_analyser/proc/get_scan_info(var/obj/scanned_obj)
	switch(scanned_obj.type)
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
		if(/obj/structure/cult_legacy/pylon)
			return "Tribal pylon - Item resembles statues/emblems built by cargo cult civilisations to honour energy systems from post-warp civilisations."
		if(/obj/mecha/working/hoverpod)
			return "Vacuum capable repair pod - Item is a remarkably intact single man repair craft capable of flight in a vacuum. Outer shell composed of primarily \
			post-warp hull alloys, with internal wiring and circuitry consistent with modern electronics and engineering."
		if(/obj/machinery/replicator)
			return "Automated construction unit - Item appears to be able to synthesize synthetic items, some with simple internal circuitry. Method unknown, \
			phasing suggested?"
		if(/obj/structure/crystal)
			return "Crystal formation - Pseudo organic crystalline matrix, unlikely to have formed naturally. No known technology exists to synthesize this exact composition."
		if(/obj/machinery/artifact)
			//the fun one
			var/obj/machinery/artifact/A = scanned_obj
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
			return "[scanned_obj.name] - Mundane application, composed of carbo-ferritic alloy composite."
