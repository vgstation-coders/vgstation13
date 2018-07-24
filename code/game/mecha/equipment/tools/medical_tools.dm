/obj/item/mecha_parts/mecha_equipment/tool/sleeper
	name = "\improper Mounted Sleeper"
	desc = "Mounted Sleeper. (Can be attached to: Medical Exosuits)"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper_0"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_BIOTECH + "=3"
	energy_drain = 20
	range = MELEE
	reliability = 1000
	equip_cooldown = 20
	var/mob/living/carbon/occupant = null
	var/datum/global_iterator/pr_mech_sleeper
	var/inject_amount = 10
	salvageable = 0

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/can_attach(obj/mecha/medical/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/New()
	..()
	pr_mech_sleeper = new /datum/global_iterator/mech_sleeper(list(src),0)
	pr_mech_sleeper.set_delay(equip_cooldown)
	return

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/allow_drop()
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/Exit(atom/movable/O)
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/action(var/mob/living/carbon/target)
	if(!action_checks(target))
		return
	if(!istype(target))
		return
	if(target.abiotic())
		occupant_message("<span class='notice'><B>Subject cannot have abiotic items on.</B></span>") //Leaving this one in for balance concerns
	if(target.locked_to)
		occupant_message("[target] will not fit into the sleeper because they are buckled to [target.locked_to].")
		return
	if(occupant)
		occupant_message("The sleeper is already occupied")
		return
	for(var/mob/living/carbon/slime/M in range(1,target))
		if(M.Victim == target)
			occupant_message("[target] will not fit into the sleeper because they have a slime latched onto their head.")
			return
	occupant_message("You start putting [target] into [src].")
	chassis.visible_message("[chassis] starts putting [target] into the [src].")
	var/C = chassis.loc
	var/T = target.loc
	if(do_after_cooldown(target,2) && chassis.Adjacent(target))
		if(chassis.loc!=C || target.loc!=T)
			return
		if(occupant)
			occupant_message("<font color=\"red\"><B>The sleeper is already occupied!</B></font>")
			return
		target.forceMove(src)
		occupant = target
		target.reset_view(src)
		/*
		if(target.client)
			target.client.perspective = EYE_PERSPECTIVE
			target.client.eye = chassis
		*/
		set_ready_state(0)
		pr_mech_sleeper.start()
		occupant_message("<font color='blue'>[target] successfully loaded into [src]. Life support functions engaged.</font>")
		chassis.visible_message("[chassis] loads [target] into [src].")
		log_message("[target] loaded. Life support functions engaged.")
	return

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/proc/go_out()
	if(!occupant)
		return
	occupant.forceMove(get_turf(src))
	occupant_message("[occupant] ejected. Life support functions disabled.")
	log_message("[occupant] ejected. Life support functions disabled.")
	occupant.reset_view()
	/*
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	*/
	occupant = null
	pr_mech_sleeper.stop()
	set_ready_state(1)

	chassis.empty_bad_contents()

	return

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/detach()
	if(occupant)
		occupant_message("Unable to detach [src] - equipment occupied.")
		return
	pr_mech_sleeper.stop()
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/get_equip_info()
	var/output = ..()
	if(output)
		var/temp = ""
		if(occupant)
			temp = "<br />\[Occupant: [occupant] (Health: [occupant.health]%)\]<br /><a href='?src=\ref[src];view_stats=1'>View stats</a>|<a href='?src=\ref[src];eject=1'>Eject</a>"
		return "[output] [temp]"
	return

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/Topic(href,href_list)
	if(..())
		return TRUE
	var/datum/topic_input/topic_filter = new /datum/topic_input(href,href_list)
	if(topic_filter.get("eject"))
		go_out()
	if(topic_filter.get("view_stats"))
		chassis.occupant << browse(get_occupant_stats(),"window=msleeper")
		onclose(chassis.occupant, "msleeper")
		return
	if(topic_filter.get("inject"))
		inject_reagent(topic_filter.getType("inject",/datum/reagent),topic_filter.getObj("source"))
	return

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/proc/get_occupant_stats()
	if(!occupant)
		return
	return {"<html>
				<head>
				<title>[occupant] statistics</title>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>
				<style>
				h3 {margin-bottom:2px;font-size:14px;}
				#lossinfo, #reagents, #injectwith {padding-left:15px;}
				</style>
				</head>
				<body>
				<h3>Health statistics</h3>
				<div id="lossinfo">
				[get_occupant_dam()]
				</div>
				<h3>Reagents in bloodstream</h3>
				<div id="reagents">
				[get_occupant_reagents()]
				</div>
				<div id="injectwith">
				[get_available_reagents()]
				</div>
				</body>
				</html>"}

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/proc/get_occupant_dam()
	var/t1
	switch(occupant.stat)
		if(0)
			t1 = "Conscious"
		if(1)
			t1 = "Unconscious"
		if(2)
			t1 = "*dead*"
		else
			t1 = "Unknown"
	return {"<font color="[occupant.health > 50 ? "blue" : "red"]"><b>Health:</b> [occupant.health]% ([t1])</font><br />
				<font color="[occupant.bodytemperature > 50 ? "blue" : "red"]"><b>Core Temperature:</b> [src.occupant.bodytemperature-T0C]&deg;C ([src.occupant.bodytemperature*1.8-459.67]&deg;F)</font><br />
				<font color="[occupant.getBruteLoss() < 60 ? "blue" : "red"]"><b>Brute Damage:</b> [occupant.getBruteLoss()]%</font><br />
				<font color="[occupant.getOxyLoss() < 60 ? "blue" : "red"]"><b>Respiratory Damage:</b> [occupant.getOxyLoss()]%</font><br />
				<font color="[occupant.getToxLoss() < 60 ? "blue" : "red"]"><b>Toxin Content:</b> [occupant.getToxLoss()]%</font><br />
				<font color="[occupant.getFireLoss() < 60 ? "blue" : "red"]"><b>Burn Severity:</b> [occupant.getFireLoss()]%</font><br />
				"}

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/proc/get_occupant_reagents()
	if(occupant.reagents)
		for(var/datum/reagent/R in occupant.reagents.reagent_list)
			if(R.volume > 0)
				. += "[R]: [round(R.volume,0.01)]<br />"
	return . || "None"

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/proc/get_available_reagents()
	var/output
	var/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/SG = locate(/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun) in chassis
	if(SG && SG.reagents && islist(SG.reagents.reagent_list))
		for(var/datum/reagent/R in SG.reagents.reagent_list)
			if(R.volume > 0)
				output += "<a href=\"?src=\ref[src];inject=\ref[R];source=\ref[SG]\">Inject [R.name]</a><br />"
	return output


/obj/item/mecha_parts/mecha_equipment/tool/sleeper/proc/inject_reagent(var/datum/reagent/R,var/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/SG)
	if(!R || !occupant || !SG || !(SG in chassis.equipment))
		return 0
	var/to_inject = min(R.volume, inject_amount)
	if(to_inject && occupant.reagents.get_reagent_amount(R.id) + to_inject <= inject_amount*2)
		occupant_message("Injecting [occupant] with [to_inject] units of [R.name].")
		log_message("Injecting [occupant] with [to_inject] units of [R.name].")
		SG.reagents.trans_id_to(occupant,R.id,to_inject)
		update_equip_info()
	return

/obj/item/mecha_parts/mecha_equipment/tool/sleeper/update_equip_info()
	if(..())
		send_byjax(chassis.occupant,"msleeper.browser","lossinfo",get_occupant_dam())
		send_byjax(chassis.occupant,"msleeper.browser","reagents",get_occupant_reagents())
		send_byjax(chassis.occupant,"msleeper.browser","injectwith",get_available_reagents())
		return 1
	return

/datum/global_iterator/mech_sleeper/process(var/obj/item/mecha_parts/mecha_equipment/tool/sleeper/S)
	if(!S.chassis)
		S.set_ready_state(1)
		return stop()
	if(!S.chassis.has_charge(S.energy_drain))
		S.set_ready_state(1)
		S.log_message("Deactivated.")
		S.occupant_message("[src] deactivated - no power.")
		return stop()
	var/mob/living/carbon/M = S.occupant
	if(!M)
		return
	if(M.health > 0)
		M.adjustOxyLoss(-1)
		M.updatehealth()
	M.AdjustStunned(-4)
	M.AdjustKnockdown(-4)
	M.AdjustStunned(-4)
	M.Paralyse(2)
	M.Knockdown(2)
	M.Stun(2)
	if(M.reagents.get_reagent_amount(INAPROVALINE) < 5)
		M.reagents.add_reagent(INAPROVALINE, 5)
	S.chassis.use_power(S.energy_drain)
	S.update_equip_info()
	return


/obj/item/mecha_parts/mecha_equipment/tool/cable_layer //why the fuck is this under medical_tools?
	name = "\improper Cable Layer"
	icon_state = "mecha_wire"
	var/chassis_on_moved_key
	var/turf/old_turf
	var/obj/structure/cable/last_piece
	var/obj/item/stack/cable_coil/cable
	var/max_cable = 1000

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/New()
	cable = new(src)
	cable.amount = 0
	..()

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/can_attach(obj/mecha/working/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/attach()
	..()
	chassis_on_moved_key = chassis.on_moved.Add(src, "layCable")

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/detach()
	chassis.on_moved.Remove(chassis_on_moved_key)
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/destroy()
	chassis.on_moved.Remove(chassis_on_moved_key)
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/action(var/obj/item/stack/cable_coil/target)
	if(!action_checks(target))
		return
	var/result = load_cable(target)
	var/message
	if(isnull(result))
		message = "<font color='red'>Unable to load [target] - no cable found.</font>"
	else if(!result)
		message = "Reel is full."
	else
		message = "[result] meters of cable successfully loaded."
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
	occupant_message(message)
	return

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/Topic(href,href_list)
	if(..())
		return TRUE
	if(href_list["toggle"])
		set_ready_state(!equip_ready)
		occupant_message("[src] [equip_ready?"dea":"a"]ctivated.")
		log_message("[equip_ready?"Dea":"A"]ctivated.")
		return
	if(href_list["cut"])
		if(cable && cable.amount)
			var/m = round(input(chassis.occupant,"Please specify the length of cable to cut","Cut cable",min(cable.amount,30)) as num, 1)
			m = min(m, cable.amount)
			if(m)
				use_cable(m)
				var/obj/item/stack/cable_coil/CC = getFromPool(/obj/item/stack/cable_coil, get_turf(chassis))
				CC.amount = m
		else
			occupant_message("There's no more cable on the reel.")
	return

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[Cable: [cable ? cable.amount : 0] m\][(cable && cable.amount) ? "- <a href='?src=\ref[src];toggle=1'>[!equip_ready?"Dea":"A"]ctivate</a>|<a href='?src=\ref[src];cut=1'>Cut</a>" : null]"
	return

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/proc/load_cable(var/obj/item/stack/cable_coil/CC)
	if(istype(CC) && CC.amount)
		var/cur_amount = cable? cable.amount : 0
		var/to_load = max(max_cable - cur_amount,0)
		if(to_load)
			to_load = min(CC.amount, to_load)
			if(!cable)
				cable = getFromPool(/obj/item/stack/cable_coil, src)
				cable.amount = 0
			cable.amount += to_load
			CC.use(to_load)
			return to_load
		else
			return 0
	return

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/proc/use_cable(amount)
	if(!cable || cable.amount<1)
		set_ready_state(1)
		occupant_message("Cable depleted, [src] deactivated.")
		log_message("Cable depleted, [src] deactivated.")
		return
	if(cable.amount < amount)
		occupant_message("No enough cable to finish the task.")
		return
	cable.use(amount)
	update_equip_info()
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/proc/reset()
	last_piece = null

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/proc/dismantleFloor(var/turf/new_turf)
	if(istype(new_turf, /turf/simulated/floor))
		var/turf/simulated/floor/T = new_turf
		if(!T.is_plating())
			if(!T.broken && !T.burnt)
				new T.floor_tile.type(T)
			T.make_plating()
	return !new_turf.intact

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/proc/layCable(var/list/args)
	var/turf/new_turf = args["loc"]
	if(equip_ready || !istype(new_turf) || !dismantleFloor(new_turf))
		return reset()
	var/fdirn = turn(chassis.dir,180)
	for(var/obj/structure/cable/LC in new_turf)		// check to make sure there's not a cable there already
		if(LC.d1 == fdirn || LC.d2 == fdirn)
			return reset()
	if(!use_cable(1))
		return reset()
	var/obj/structure/cable/NC = getFromPool(/obj/structure/cable, new_turf)
	NC.cableColor("red")
	NC.d1 = 0
	NC.d2 = fdirn
	NC.update_icon()

	var/datum/powernet/PN
	if(last_piece && last_piece.d2 != chassis.dir)
		last_piece.d1 = min(last_piece.d2, chassis.dir)
		last_piece.d2 = max(last_piece.d2, chassis.dir)
		last_piece.update_icon()
		PN = last_piece.powernet

	if(!PN)
		PN = new()
	NC.powernet = PN
	PN.cables += NC
	NC.mergeConnectedNetworks(NC.d2)

	//NC.mergeConnectedNetworksOnTurf()
	last_piece = NC
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun
	name = "\improper Exosuit-Mounted Syringe Gun"
	desc = "Exosuit-mounted chem synthesizer with syringe gun. Reagents inside are held in stasis, so no reactions will occur. (Can be attached to: Medical Exosuits)"
	icon = 'icons/obj/gun.dmi'
	icon_state = "syringegun"
	var/list/syringes
	var/list/known_reagents
	var/list/processed_reagents
	var/max_syringes = 10
	var/max_volume = 75 //max reagent volume
	var/synth_speed = 5 //[num] reagent units per cycle
	energy_drain = 10
	var/mode = 0 //0 - fire syringe, 1 - analyze reagents.
	var/datum/global_iterator/mech_synth/synth
	range = MELEE|RANGED
	equip_cooldown = 10
	origin_tech = Tc_MATERIALS + "=3;" + Tc_BIOTECH + "=4;" + Tc_MAGNETS + "=4;" + Tc_PROGRAMMING + "=3"

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/New()
	..()
	flags |= NOREACT
	syringes = new
	known_reagents = list(INAPROVALINE="Inaprovaline",ANTI_TOXIN="Anti-Toxin (Dylovene)")
	processed_reagents = new
	create_reagents(max_volume)
	synth = new (list(src),0)

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/detach()
	synth.stop()
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/Destroy()
	synth.stop()
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/critfail()
	..()
	flags &= ~NOREACT
	return

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/can_attach(obj/mecha/medical/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[<a href=\"?src=\ref[src];toggle_mode=1\">[mode? "Analyze" : "Launch"]</a>\]<br />\[Syringes: [syringes.len]/[max_syringes] | Reagents: [reagents.total_volume]/[reagents.maximum_volume]\]<br /><a href='?src=\ref[src];show_reagents=1'>Reagents list</a>"
	return

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/action(atom/movable/target)
	if(!action_checks(target))
		return
	if(istype(target,/obj/item/weapon/reagent_containers/syringe))
		return load_syringe(target)
	if(istype(target,/obj/item/weapon/storage))//Loads syringes from boxes
		for(var/obj/item/weapon/reagent_containers/syringe/S in target.contents)
			load_syringe(S)
		return
	if(mode)
		return analyze_reagents(target)
	if(!syringes.len)
		occupant_message("<span class=\"alert\">No syringes loaded.</span>")
		return
	if(reagents.total_volume<=0)
		occupant_message("<span class=\"alert\">No available reagents to load syringe with.</span>")
		return
	set_ready_state(0)
	chassis.use_power(energy_drain)
	var/turf/trg = get_turf(target)
	var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
	S.forceMove(get_turf(chassis))
	reagents.trans_to(S, min(S.volume, reagents.total_volume))
	syringes -= S
	S.icon = 'icons/obj/chemical.dmi'
	S.icon_state = "syringeproj"
	playsound(chassis, 'sound/items/syringeproj.ogg', 50, 1)
	log_message("Launched [S] from [src], targeting [target].")
	spawn(-1)
		src = null //if src is deleted, still process the syringe
		for(var/i=0, i<6, i++)
			if(!S)
				break
			if(step_towards(S,trg))
				var/list/mobs = new
				for(var/mob/living/carbon/M in S.loc)
					mobs += M
				var/mob/living/carbon/M = safepick(mobs)
				if(M)
					S.icon_state = initial(S.icon_state)
					S.icon = initial(S.icon)
					S.reagents.trans_to(M, S.reagents.total_volume)
					M.take_organ_damage(2)
					S.visible_message("<span class=\"attack\"> [M] was hit by the syringe!</span>")
					break
				else if(S.loc == trg)
					S.icon_state = initial(S.icon_state)
					S.icon = initial(S.icon)
					S.update_icon()
					break
			else
				S.icon_state = initial(S.icon_state)
				S.icon = initial(S.icon)
				S.update_icon()
				break
			sleep(1)
	do_after_cooldown()
	return 1


/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/Topic(href,href_list)
	if(..())
		return TRUE
	var/datum/topic_input/topic_filter = new (href,href_list)
	if(topic_filter.get("toggle_mode"))
		mode = !mode
		update_equip_info()
		return
	if(topic_filter.get("select_reagents"))
		processed_reagents.len = 0
		var/m = 0
		var/message
		for(var/i=1 to known_reagents.len)
			if(m>=synth_speed)
				break
			var/reagent = topic_filter.get("reagent_[i]")
			if(reagent && (reagent in known_reagents))
				message = "[m ? ", " : null][known_reagents[reagent]]"
				processed_reagents += reagent
				m++
		if(processed_reagents.len)
			message += " added to production"
			synth.start()
			occupant_message(message)
			occupant_message("Reagent processing started.")
			log_message("Reagent processing started.")
		return
	if(topic_filter.get("show_reagents"))
		chassis.occupant << browse(get_reagents_page(),"window=msyringegun")
	if(topic_filter.get("purge_reagent"))
		var/reagent = topic_filter.get("purge_reagent")
		if(reagent)
			reagents.del_reagent(reagent)
		return
	if(topic_filter.get("purge_all"))
		reagents.clear_reagents()
		return
	return

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/proc/get_reagents_page()
	var/output = {"<html>
						<head>
						<title>Reagent Synthesizer</title>
						<script language='javascript' type='text/javascript'>
						[js_byjax]
						</script>
						<style>
						h3 {margin-bottom:2px;font-size:14px;}
						#reagents, #reagents_form {}
						form {width: 90%; margin:10px auto; border:1px dotted #999; padding:6px;}
						#submit {margin-top:5px;}
						</style>
						</head>
						<body>
						<h3>Current reagents:</h3>
						<div id="reagents">
						[get_current_reagents()]
						</div>
						<h3>Reagents production:</h3>
						<div id="reagents_form">
						[get_reagents_form()]
						</div>
						</body>
						</html>
						"}
	return output

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/proc/get_reagents_form()
	var/r_list = get_reagents_list()
	var/inputs
	if(r_list)

		inputs += {"<input type=\"hidden\" name=\"src\" value=\"\ref[src]\">
			<input type=\"hidden\" name=\"select_reagents\" value=\"1\">
			<input id=\"submit\" type=\"submit\" value=\"Apply settings\">"}
	var/output = {"<form action="byond://" method="get">
						[r_list || "No known reagents"]
						[inputs]
						</form>
						[r_list? "<span style=\"font-size:80%;\">Only the first [synth_speed] selected reagent\s will be added to production</span>" : null]
						"}
	return output

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/proc/get_reagents_list()
	var/output
	for(var/i=1 to known_reagents.len)
		var/reagent_id = known_reagents[i]
		output += {"<input type="checkbox" value="[reagent_id]" name="reagent_[i]" [(reagent_id in processed_reagents)? "checked=\"1\"" : null]> [known_reagents[reagent_id]]<br />"}
	return output

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/proc/get_current_reagents()
	var/output
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.volume > 0)
			output += "[R]: [round(R.volume,0.001)] - <a href=\"?src=\ref[src];purge_reagent=[R.id]\">Purge Reagent</a><br />"
	if(output)
		output += "Total: [round(reagents.total_volume,0.001)]/[reagents.maximum_volume] - <a href=\"?src=\ref[src];purge_all=1\">Purge All</a>"
	return output || "None"

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/proc/load_syringe(obj/item/weapon/reagent_containers/syringe/S)
	if(syringes.len<max_syringes)
		if(get_dist(src,S) >= 2)
			occupant_message("The syringe is too far away.")
			return 0
		for(var/obj/structure/D in S.loc)//Basic level check for structures in the way (Like grilles and windows)
			if(!(D.Cross(S,src.loc)))
				occupant_message("Unable to load syringe.")
				return 0
		for(var/obj/machinery/door/D in S.loc)//Checks for doors
			if(!(D.Cross(S,src.loc)))
				occupant_message("Unable to load syringe.")
				return 0
		S.reagents.trans_to(src, S.reagents.total_volume)
		S.forceMove(src)
		syringes += S
		occupant_message("Syringe loaded.")
		update_equip_info()
		return 1
	occupant_message("The [src] syringe chamber is full.")
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/proc/analyze_reagents(atom/A)
	if(get_dist(src,A) >= 4)
		occupant_message("The object is too far away.")
		return 0
	if(!A.reagents || istype(A,/mob))
		occupant_message("<span class=\"alert\">No reagent info gained from [A].</span>")
		return 0
	occupant_message("Analyzing reagents...")
	var/any_success = FALSE
	for(var/datum/reagent/R in A.reagents.reagent_list)
		if(R.dupeable)
			if(R.reagent_state == 2 && add_known_reagent(R.id,R.name))
				occupant_message("Reagent analyzed, identified as [R.name] and added to database.")
				send_byjax(chassis.occupant,"msyringegun.browser","reagents_form",get_reagents_form())
				any_success = TRUE
				continue
		occupant_message("<span class=\"alert\">Analysis of [R.name] failed, unit not equipped for synthesis of this reagent.</span>")
	if(any_success)
		occupant_message("Analysis complete.")
		return 1

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/proc/add_known_reagent(r_id,r_name)
	set_ready_state(0)
	do_after_cooldown()
	if(!(r_id in known_reagents))
		known_reagents += r_id
		known_reagents[r_id] = r_name
		return 1
	return 0


/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/update_equip_info()
	if(..())
		send_byjax(chassis.occupant,"msyringegun.browser","reagents",get_current_reagents())
		send_byjax(chassis.occupant,"msyringegun.browser","reagents_form",get_reagents_form())
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/on_reagent_change()
	..()
	update_equip_info()
	return

/datum/global_iterator/mech_synth
	delay = 100

/datum/global_iterator/mech_synth/process(var/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/S)
	if(!S.chassis)
		return stop()
	var/energy_drain = S.energy_drain*10
	if(!S.processed_reagents.len || S.reagents.total_volume >= S.reagents.maximum_volume || !S.chassis.has_charge(energy_drain))
		S.occupant_message("<span class=\"alert\">Reagent processing stopped.</a>")
		S.log_message("Reagent processing stopped.")
		return stop()
	if(anyprob(S.reliability))
		S.critfail()
	var/amount = S.synth_speed / S.processed_reagents.len
	for(var/reagent in S.processed_reagents)
		S.reagents.add_reagent(reagent,amount)
		S.chassis.use_power(energy_drain)
	return 1
