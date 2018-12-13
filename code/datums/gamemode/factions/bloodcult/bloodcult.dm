//CULT 3.0 BY DEITY LINK (2018)
//BASED ON THE ORIGINAL GAME MODE BY URIST MCDORF

var/veil_thickness = CULT_PROLOGUE

/client/proc/set_veil_thickness()
	set category = "Special Verbs"
	set name = "Set Veil Thickness"
	set desc = "Debug verb for Cult 3.0 shenanigans"

	if(!check_rights(R_ADMIN))
		return

	veil_thickness = input(usr, "Enter a value (default = [CULT_PROLOGUE])", "Debug Veil Thickness", veil_thickness) as num

	if (veil_thickness == CULT_ACT_III)
		spawn_bloodstones()

	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (cult)
		for (var/datum/role/cultist/C in cult.members)
			C.update_cult_hud()

	for (var/obj/structure/cult/spire/S in cult_spires)
		S.upgrade()

	for (var/obj/effect/rune/R in rune_list)
		R.update_icon()

/proc/spawn_bloodstones(var/turf/source = null)
	//Called at the beginning of ACT III, this is basically the cult's declaration of war on the crew
	//Spawns 4 structures, one in each quarters of the station
	//When spawning, those structures break and convert stuff around them, and add a wall layer in case of space exposure.
	var/list/places_to_spawn = list()
	for (var/i = 1 to 4)
		for (var/j = 10; j > 0; j--)
			var/turf/T = get_turf(pick(range(j*3,locate(map.center_x+j*4*(((round(i/2) % 2) == 0) ? -1 : 1 ),map.center_y+j*4*(((i % 2) == 0) ? -1 : 1 ),map.zMainStation))))
			if(!is_type_in_list(T,list(/turf/space,/turf/unsimulated,/turf/simulated/shuttle)))
				places_to_spawn += T
				break
	//A 5th bloodstone will spawn if a proper turf was given as arg (up to 100 tiles from the station center, and not in space
	if (source && (source.z == map.zMainStation) && !isspace(source.loc) && get_dist(locate(map.center_x,map.center_y,map.zMainStation),source)<100)
		places_to_spawn.Add(source)
	for (var/T in places_to_spawn)
		new /obj/structure/cult/bloodstone(T)

	//Cultists can use those bloodstones to locate the rest of them, they work just like station holomaps
	var/i = 1
	for(var/obj/structure/cult/bloodstone/B in bloodstone_list)
		var/datum/holomap_marker/newMarker = new()
		newMarker.id = HOLOMAP_MARKER_BLOODSTONE
		newMarker.filter = HOLOMAP_FILTER_CULT
		newMarker.x = B.x
		newMarker.y = B.y
		newMarker.z = B.z
		holomap_markers[HOLOMAP_MARKER_BLOODSTONE+"_[i]"] = newMarker
		i++

	var/icon/canvas = icon('icons/480x480.dmi', "cultmap")
	var/icon/map_base = icon(holoMiniMaps[map.zMainStation])
	map_base.Blend("#E30000",ICON_MULTIPLY)
	canvas.Blend(map_base,ICON_OVERLAY)
	for(var/marker in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[marker]
		if(holomarker.z == map.zMainStation && holomarker.filter & HOLOMAP_FILTER_CULT)
			if(map.holomap_offset_x.len >= map.zMainStation)
				canvas.Blend(icon(holomarker.icon,holomarker.id), ICON_OVERLAY, holomarker.x-8+map.holomap_offset_x[map.zMainStation]	, holomarker.y-8+map.holomap_offset_y[map.zMainStation])
			else
				canvas.Blend(icon(holomarker.icon,holomarker.id), ICON_OVERLAY, holomarker.x-8, holomarker.y-8)

	extraMiniMaps |= HOLOMAP_EXTRA_CULTMAP
	extraMiniMaps[HOLOMAP_EXTRA_CULTMAP] = canvas

	for(var/obj/structure/cult/bloodstone/B in bloodstone_list)
		if (B.loc)
			B.holomap_datum = new /datum/station_holomap/cult()
			B.holomap_datum.initialize_holomap(B.loc)
		else
			qdel(B)
			message_admins("Blood Cult: A blood stone was somehow spawned in nullspace. It has been destroyed.")

/proc/cult_risk(var/mob/M)//too many conversions/soul-stoning might bring the cult to the attention of Nanotrasen prematurely
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!cult)
		return
	if (cult.warning)
		return
	if (veil_thickness == CULT_MENDED || veil_thickness >= CULT_ACT_III)
		return

	var/living_cultists = 0
	var/living_noncultists = 0
	for (var/mob/living/L in player_list)
		if (L.stat != DEAD)
			if (iscultist(L))
				living_cultists++
			else
				living_noncultists++

	var/rate = 40//the percent of living cultist at which the risk starts appearing
	var/risk = min((living_cultists*((100-rate)/50) - living_noncultists*(rate/50)) * 25, 100)//the risk increases very rapidly. at 2-3 cultists over the limit, the exposure is guarranted

	if (risk > 0)
		if(prob(risk))
			message_admins("With a chance of [risk]%, the cult's activities have been prematurely exposed.")
			cult.warning = TRUE
			command_alert(/datum/command_alert/cult_detected)
		else
			message_admins("With a chance of [risk]%, the cult's activities have avoided raising suspicion for now...")
			if (M)
				to_chat(M,"<span class='warning'>Be mindful, overzealous conversions and soul trapping will bring attention to us unwanted attention. You should focus on the objective with your current force.</span>")


//CULT_PROLOGUE		Default thickness, only communication and raise structure runes enabled
//CULT_ACT_I		Altar raised. cultists can now convert.
//CULT_ACT_II		Cultist amount reached. cultists are now looking for the sacrifice
//CULT_ACT_III		Sacrifice complete. cult is now going loud, spreading blood and protecting bloodstones while the crew tries to destroy them
//CULT_ACT_IV		Bloodspill threshold reached. bloodstones become indestructible, rift opens above one of them. cultists must open it, crew must close it.
//CULT_EPILOGUE		The cult succeeded. The station is no longer reachable from space or through teleportation, and is now part of hell. Nar-Sie hunts the survivors.
//CULT_MENDED		The cult failed (bloodstones all destroyed or rift closed). cult magic permanently disabled, living cultists progressively die by themselves.

/datum/faction/bloodcult
	name = "Cult of Nar-Sie"
	ID = BLOODCULT
	initial_role = CULTIST
	late_role = CULTIST
	desc = "A group of shady blood-obsessed individuals whose souls are devoted to Nar-Sie, the Geometer of Blood.\
	From his teachings, they were granted the ability to perform blood magic rituals allowing them to fight and grow their ranks, and given the goal of pushing his agenda.\
	Nar-Sie's goal is to tear open a breach through reality so he can pull the station into his realm and feast on the crew's blood and souls."
	roletype = /datum/role/cultist
	logo_state = "cult-logo"
	hud_icons = list("cult-logo")
	var/list/bloody_floors = list()
	var/target_change = FALSE
	var/change_cooldown = 0
	var/cult_win = FALSE
	var/warning = FALSE

/datum/faction/bloodcult/check_win()
	return cult_win

/datum/faction/bloodcult/proc/fail()
	if (cult_win || veil_thickness == CULT_MENDED)
		return
	progress(CULT_MENDED)

/datum/faction/bloodcult/AdminPanelEntry(var/datum/admins/A)
	var/list/dat = ..()
	dat += "<br><a href='?src=\ref[src];cult_mindspeak_global=1'>Voice of Nar-Sie</a>"
	return dat

/datum/faction/bloodcult/Topic(href, href_list)
	..()
	if (href_list["cult_mindspeak_global"])
		var/message = input("What message shall we send?",
                    "Voice of Nar-Sie",
                    "")
		for (var/datum/role/R in members)
			var/mob/M = R.antag.current
			if (M)
				to_chat(M, "<span class='danger'>Nar-Sie</span> murmurs... <span class='sinister'>[message]</span>")

		for(var/mob/dead/observer/O in player_list)
			to_chat(O, "<span class='game say'><span class='danger'>Nar-Sie</span> murmurs, <span class='sinister'>[message]</span></span>")

		message_admins("Admin [key_name_admin(usr)] has talked with the Voice of Nar-Sie.")
		log_narspeak("[key_name(usr)] Voice of Nar-Sie: [message]")

/datum/faction/bloodcult/HandleNewMind(var/datum/mind/M)
	..()
	M.special_role = "Cultist"

/datum/faction/bloodcult/OnPostSetup()
	initialize_cultwords()
	AppendObjective(/datum/objective/bloodcult_reunion)

/datum/faction/bloodcult/process()
	..()
	if (change_cooldown > 0)
		change_cooldown -= 1 SECONDS
		if (change_cooldown <= 0)
			target_change = FALSE
			var/datum/objective/bloodcult_sacrifice/O = locate() in objective_holder.objectives
			if (O && !O.IsFulfilled())
				O.failed_targets += O.sacrifice_target
				spawn()
					if (O.replace_target())
						for(var/datum/role/cultist/C in members)
							var/mob/M = C.antag.current
							if (M)
								to_chat(M,"<span class='danger'>The sacrifice wasn't performed in time.</span><b> A new target has been assigned. [O.explanation_text]</b>")
								if (M == O.sacrifice_target)
									to_chat(M,"<b>There is no greater honor than purposefuly relinquishing your body for the coming of Nar-Sie, but you may wait for another target to be selected should you be afraid of death.</b>")
								else if (iscultist(O.sacrifice_target))
									to_chat(M,"<b>Chance has rolled its dice, and one of ours was selected. If for whatever reasons you do not want to take their life, you will have to wait for a new selection.</b>")
	if (target_change)
		change_cooldown = SACRIFICE_CHANGE_COOLDOWN

/datum/faction/bloodcult/proc/progress(var/new_act,var/A)
	//This proc is called to update the faction's current objectives, and veil thickness
	if (veil_thickness == CULT_MENDED)
		return//it's over, you lost

	if (new_act == CULT_MENDED)
		veil_thickness = CULT_MENDED
		spawn (5 SECONDS)
			emergency_shuttle.shutdown = 0//The shuttle docks to the station immediately afterwards.
			emergency_shuttle.online = 1
			emergency_shuttle.shuttle_phase("station",0)
		set_security_level("blue")
		ticker.StopThematic()
		command_alert(/datum/command_alert/bloodstones_broken)
		for (var/obj/structure/cult/bloodstone/B in bloodstone_list)
			B.takeDamage(B.maxHealth+1)
		for (var/datum/role/cultist/C in members)
			C.update_cult_hud()
		return

	if (new_act <= veil_thickness)
		return

	var/datum/objective/new_obj = null

	switch(new_act)
		if (CULT_ACT_I)
			var/datum/objective/bloodcult_reunion/O = locate() in objective_holder.objectives
			if (O)
				O.altar_built = TRUE
				veil_thickness = CULT_ACT_I
				new_obj = new /datum/objective/bloodcult_followers
		if (CULT_ACT_II)
			var/datum/objective/bloodcult_followers/O = locate() in objective_holder.objectives
			if (O)
				O.conversions++
				if (O.conversions >= O.convert_target)
					veil_thickness = CULT_ACT_II
					new_obj = new /datum/objective/bloodcult_sacrifice
					for(var/datum/role/cultist/C in members)
						var/mob/M = C.antag.current
						for(var/obj/item/weapon/implant/loyalty/I in M)
							I.forceMove(get_turf(M))
							I.implanted = 0
							M.visible_message("<span class='warning'>\The [I] pops out of \the [M]'s head.</span>")
		if (CULT_ACT_III)
			var/datum/objective/bloodcult_sacrifice/O = locate() in objective_holder.objectives
			if (O)
				O.target_sacrificed = TRUE
				veil_thickness = CULT_ACT_III
				emergency_shuttle.force_shutdown()//No shuttle calls until the cult either wins or fails.
				spawn_bloodstones(A)
				spawn(5 SECONDS)
					command_alert(/datum/command_alert/bloodstones_raised)
					ticker.StartThematic("endgame")
					sleep(2 SECONDS)
					set_security_level("red")
				new_obj = new /datum/objective/bloodcult_bloodbath
		if (CULT_ACT_IV)
			var/datum/objective/bloodcult_bloodbath/O = locate() in objective_holder.objectives
			if (O)
				veil_thickness = CULT_ACT_IV
				command_alert(/datum/command_alert/bloodstones_anchor)
				new_obj = new /datum/objective/bloodcult_tearinreality
		if (CULT_EPILOGUE)
			var/datum/objective/bloodcult_tearinreality/O = locate() in objective_holder.objectives
			if (O)
				O.NARSIE_HAS_RISEN = TRUE
				veil_thickness = CULT_EPILOGUE
				new_obj = new /datum/objective/bloodcult_feast

	if (new_obj) //If not null, then we have likely advanced a stage
		AppendObjective(new_obj)
		for(var/datum/role/cultist/C in members)
			var/mob/M = C.antag.current
			if (M)
				to_chat(M,"<span class='danger'>[new_obj.name]</span><b>: [new_obj.explanation_text]</b>")
				if (istype(new_obj,/datum/objective/bloodcult_sacrifice))
					var/datum/objective/bloodcult_sacrifice/O = new_obj
					if (M == O.sacrifice_target)
						to_chat(M,"<b>There is no greater honor than purposefuly relinquishing your body for the coming of Nar-Sie, but you may wait for another target to be selected should you be afraid of death.</b>")
					else if (iscultist(O.sacrifice_target))
						to_chat(M,"<b>Chance has rolled its dice, and one of ours was selected. If for whatever reasons you do not want to take their life, you will have to wait for a new selection.</b>")

		for (var/datum/role/cultist/C in members)
			C.update_cult_hud()

		for (var/obj/structure/cult/spire/S in cult_spires)
			S.upgrade()

		for (var/obj/effect/rune/R in rune_list)
			R.update_icon()

		if (istype(new_obj,/datum/objective/bloodcult_bloodbath))
			var/datum/objective/bloodcult_bloodbath/O = new_obj
			O.max_bloodspill = max(O.max_bloodspill,bloody_floors.len)
			if (O.IsFulfilled())
				progress(CULT_ACT_IV)

/datum/faction/bloodcult/proc/add_bloody_floor(var/turf/T)
	if (!istype(T))
		return
	if(T && (T.z == map.zMainStation))//F I V E   T I L E S
		if(!(locate("\ref[T]") in bloody_floors))
			bloody_floors[T] = T
			for (var/obj/structure/cult/bloodstone/B in bloodstone_list)
				B.update_icon()
			var/datum/objective/bloodcult_bloodbath/O = locate() in objective_holder.objectives
			if (O && !O.IsFulfilled())
				O.max_bloodspill = max(O.max_bloodspill,bloody_floors.len)
				if (O.IsFulfilled())
					progress(CULT_ACT_IV)


/datum/faction/bloodcult/proc/remove_bloody_floor(var/turf/T)
	if (!istype(T))
		return
	for (var/obj/structure/cult/bloodstone/B in bloodstone_list)
		B.update_icon()
	bloody_floors -= T

/proc/is_convertable_to_cult(datum/mind/mind)
	if(!istype(mind))
		return 0
	if(ishuman(mind.current) && (mind.assigned_role == "Chaplain"))
		return 0
	for(var/obj/item/weapon/implant/loyalty/L in mind.current)
		if(L.imp_in == mind.current)//Checks to see if the person contains an implant, then checks that the implant is actually inside of them
			return 0
	return 1

//When cultists need to pay in blood to use their spells, they have a few options at their disposal:
// * If their hands are bloody, they can use the few units of blood on them.
// * If there is a blood splatter on the ground that still has a certain amount of fresh blood in it, they can use that?
// * If they are grabbing another person, they can stab their nails in their vessels to draw some blood from them
// * If they are standing above a bleeding person, they can dip their fingers into their wounds.
// * If they are holding a container that has blood in it (such as a beaker or a blood pack), they can pour/squeeze blood from them
// * If they are standing above a container that has blood in it, they can dip their fingers into them
// * Finally if there are no alternative blood sources, you can always use your own blood.

/proc/get_available_blood(var/mob/user, var/amount_needed = 0)
	var/data = list(
		BLOODCOST_TARGET_BLEEDER = null,
		BLOODCOST_AMOUNT_BLEEDER = 0,
		BLOODCOST_TARGET_GRAB = null,
		BLOODCOST_AMOUNT_GRAB = 0,
		BLOODCOST_TARGET_HANDS = null,
		BLOODCOST_AMOUNT_HANDS = 0,
		BLOODCOST_TARGET_HELD = null,
		BLOODCOST_AMOUNT_HELD = 0,
		BLOODCOST_LID_HELD = 0,
		BLOODCOST_TARGET_SPLATTER = null,
		BLOODCOST_AMOUNT_SPLATTER = 0,
		BLOODCOST_TARGET_BLOODPACK = null,
		BLOODCOST_AMOUNT_BLOODPACK = 0,
		BLOODCOST_HOLES_BLOODPACK = 0,
		BLOODCOST_TARGET_CONTAINER = null,
		BLOODCOST_AMOUNT_CONTAINER = 0,
		BLOODCOST_LID_CONTAINER = 0,
		BLOODCOST_TARGET_USER = null,
		BLOODCOST_AMOUNT_USER = 0,
		BLOODCOST_RESULT = "",
		BLOODCOST_TOTAL = 0,
		)
	var/turf/T = get_turf(user)
	var/amount_gathered = 0

	//Is there blood on our hands?
	var/mob/living/carbon/human/H_user = user
	if (istype (H_user) && H_user.bloody_hands)
		data[BLOODCOST_TARGET_HANDS] = H_user
		var/blood_gathered = min(amount_needed,H_user.bloody_hands)
		data[BLOODCOST_AMOUNT_HANDS] = blood_gathered
		amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_HANDS
		return data

	//Is there a fresh blood splatter on the turf?
	for (var/obj/effect/decal/cleanable/blood/B in T)
		var/blood_volume = B.amount
		if (blood_volume && B.counts_as_blood)
			data[BLOODCOST_TARGET_SPLATTER] = B
			var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
			data[BLOODCOST_AMOUNT_SPLATTER] = blood_gathered
			amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_SPLATTER
		return data

	//Is the cultist currently grabbing a bleeding mob/corpse that still has blood in it?
	var/obj/item/weapon/grab/Grab = locate() in user
	if (Grab)
		if(ishuman(Grab.affecting))
			var/mob/living/carbon/human/H = Grab.affecting
			if(!(H.species.flags & NO_BLOOD))
				for(var/datum/organ/external/org in H.organs)
					if(org.status & ORGAN_BLEEDING)
						var/blood_volume = round(H.vessel.get_reagent_amount(BLOOD))
						var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
						data[BLOODCOST_TARGET_GRAB] = H
						data[BLOODCOST_AMOUNT_GRAB] = blood_gathered
						amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_GRAB
		return data

	//Is there a bleeding mob/corpse on the turf that still has blood in it?
	for (var/mob/living/carbon/human/H in T)
		if(H.species.flags & NO_BLOOD)
			continue
		if(user != H)
			for(var/datum/organ/external/org in H.organs)
				if(org.status & ORGAN_BLEEDING)
					var/blood_volume = round(H.vessel.get_reagent_amount(BLOOD))
					var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
					data[BLOODCOST_TARGET_BLEEDER] = H
					data[BLOODCOST_AMOUNT_BLEEDER] = blood_gathered
					amount_gathered += blood_gathered
					break
		if (data[BLOODCOST_TARGET_BLEEDER])
			break

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_BLEEDER
		return data

	for(var/obj/item/weapon/reagent_containers/G_held in H_user.held_items) //Accounts for if the person has multiple grasping organs
		if (!istype(G_held) || !round(G_held.reagents.get_reagent_amount(BLOOD)))
			continue
		if(istype(G_held, /obj/item/weapon/reagent_containers/blood)) //Bloodbags have their own functionality
			var/obj/item/weapon/reagent_containers/blood/blood_pack = G_held
			var/blood_volume = round(blood_pack.reagents.get_reagent_amount(BLOOD))
			if (blood_volume)
				data[BLOODCOST_TARGET_BLOODPACK] = blood_pack
				if (blood_pack.holes)
					var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
					data[BLOODCOST_AMOUNT_BLOODPACK] = blood_gathered
					amount_gathered += blood_gathered
				else
					data[BLOODCOST_HOLES_BLOODPACK] = 1
			if (amount_gathered >= amount_needed)
				data[BLOODCOST_RESULT] = BLOODCOST_TARGET_BLOODPACK
				return data

		else
			var/blood_volume = round(G_held.reagents.get_reagent_amount(BLOOD))
			if (blood_volume)
				data[BLOODCOST_TARGET_HELD] = G_held
				if (G_held.is_open_container())
					var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
					data[BLOODCOST_AMOUNT_HELD] = blood_gathered
					amount_gathered += blood_gathered
				else
					data[BLOODCOST_LID_HELD] = 1

			if (amount_gathered >= amount_needed)
				data[BLOODCOST_RESULT] = BLOODCOST_TARGET_HELD
				return data


	//Is there a reagent container on the turf that has blood in it?
	for (var/obj/item/weapon/reagent_containers/G in T)
		var/blood_volume = round(G.reagents.get_reagent_amount(BLOOD))
		if (blood_volume)
			data[BLOODCOST_TARGET_CONTAINER] = G
			if (G.is_open_container())
				var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
				data[BLOODCOST_AMOUNT_CONTAINER] = blood_gathered
				amount_gathered += blood_gathered
				break
			else
				data[BLOODCOST_LID_CONTAINER] = 1

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_CONTAINER
		return data

	//Does the user have blood? (the user can pay in blood without having to bleed first)
	if(istype(H_user) && !(H_user.species.flags & NO_BLOOD))
		var/blood_volume = round(H_user.vessel.get_reagent_amount(BLOOD))
		var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
		data[BLOODCOST_TARGET_USER] = H_user
		data[BLOODCOST_AMOUNT_USER] = blood_gathered
		amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_USER
		return data

	data[BLOODCOST_RESULT] = BLOODCOST_FAILURE
	return data


/proc/use_available_blood(var/mob/user, var/amount_needed = 0,var/previous_result = "", var/tribute = 0)
	//Blood Communion
	var/communion = 0
	var/total_accumulated = 0
	var/total_needed = amount_needed
	if (!tribute && iscultist(user))
		var/datum/role/cultist/mycultist = user.mind.GetRole(CULTIST)
		if (mycultist in blood_communion)
			communion = 1
			amount_needed = max(1,round(amount_needed * 4 / 5))//saving 20% blood
			var/list/tributers = list()
			for (var/datum/role/cultist/cultist in blood_communion)
				if (cultist.antag && cultist.antag.current)
					var/mob/living/L = cultist.antag.current
					if (istype(L) && L != user)
						tributers.Add(L)
			var/total_per_tribute = max(1,round(amount_needed/max(1,tributers.len+1)))
			var/tributer_size = tributers.len
			for (var/i = 1 to tributer_size)
				var/mob/living/L = pick(tributers)//so it's not always the first one that pays the first blood unit.
				tributers.Remove(L)
				var/data = use_available_blood(L, total_per_tribute, "", 1)
				if (data[BLOODCOST_RESULT] != BLOODCOST_FAILURE)
					total_accumulated += data[BLOODCOST_TOTAL]
				if (total_accumulated >= amount_needed - total_per_tribute)//could happen if the cost is less than 1 per tribute
					break

	//Getting nearby blood sources
	var/list/data = get_available_blood(user, amount_needed-total_accumulated)

	var/datum/reagent/blood/blood

	//Flavour text and blood data transfer
	switch (data[BLOODCOST_RESULT])
		if (BLOODCOST_TARGET_HANDS)
			var/mob/living/carbon/human/H = user
			blood = new()
			blood.data["blood_colour"] = H.hand_blood_color
			if (H.blood_DNA && H.blood_DNA.len)
				var/blood_DNA = pick(H.blood_DNA)
				blood.data["blood_DNA"] = blood_DNA
				blood.data["blood_type"] = H.blood_DNA[blood_DNA]
			if (!tribute && previous_result != BLOODCOST_TARGET_HANDS)
				user.visible_message("<span class='warning'>The blood on \the [user]'s hands drips onto the floor!</span>",
									"<span class='rose'>You let the blood smeared on your hands join the pool of your summoning.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_SPLATTER)
			var/obj/effect/decal/cleanable/blood/B = data[BLOODCOST_TARGET_SPLATTER]
			blood = new()
			blood.data["blood_colour"] = B.basecolor
			if (B.blood_DNA.len)
				var/blood_DNA = pick(B.blood_DNA)
				blood.data["blood_DNA"] = blood_DNA
				blood.data["blood_type"] = B.blood_DNA[blood_DNA]
			blood.data["virus2"] = B.virus2
			if (!tribute && previous_result != BLOODCOST_TARGET_SPLATTER)
				user.visible_message("<span class='warning'>The blood on the floor below \the [user] starts moving!</span>",
									"<span class='rose'>You redirect the flow of blood inside the splatters on the floor toward the pool of your summoning.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_GRAB)
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_GRAB]
			blood = get_blood(H.vessel)
			if (!tribute && previous_result != BLOODCOST_TARGET_GRAB)
				user.visible_message("<span class='warning'>\The [user] stabs their nails inside \the [data[BLOODCOST_TARGET_GRAB]], drawing blood from them!</span>",
									"<span class='rose'>You stab your nails inside \the [data[BLOODCOST_TARGET_GRAB]] to draw some blood from them.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_BLEEDER)
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_BLEEDER]
			blood = get_blood(H.vessel)
			if (!tribute && previous_result != BLOODCOST_TARGET_BLEEDER)
				user.visible_message("<span class='warning'>\The [user] dips their fingers inside \the [data[BLOODCOST_TARGET_BLEEDER]]'s wounds!</span>",
									"<span class='rose'>You dip your fingers inside \the [data[BLOODCOST_TARGET_BLEEDER]]'s wounds to draw some blood from them.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_HELD)
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_HELD]
			blood = locate() in G.reagents.reagent_list
			if (!tribute && previous_result != BLOODCOST_TARGET_HELD)
				user.visible_message("<span class='warning'>\The [user] tips \the [data[BLOODCOST_TARGET_HELD]], pouring blood!</span>",
									"<span class='rose'>You tip \the [data[BLOODCOST_TARGET_HELD]] to pour the blood contained inside.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_BLOODPACK)
			var/obj/item/weapon/reagent_containers/blood/B = data[BLOODCOST_TARGET_BLOODPACK]
			blood = locate() in B.reagents.reagent_list
			if (!tribute && previous_result != BLOODCOST_TARGET_BLOODPACK)
				user.visible_message("<span class='warning'>\The [user] squeezes \the [data[BLOODCOST_TARGET_BLOODPACK]], pouring blood!</span>",
									"<span class='rose'>You squeeze \the [data[BLOODCOST_TARGET_BLOODPACK]] to pour the blood contained inside.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_CONTAINER)
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_CONTAINER]
			blood = locate() in G.reagents.reagent_list
			if (!tribute && previous_result != BLOODCOST_TARGET_CONTAINER)
				user.visible_message("<span class='warning'>\The [user] dips their fingers inside \the [data[BLOODCOST_TARGET_CONTAINER]], covering them in blood!</span>",
									"<span class='rose'>You dip your fingers inside \the [data[BLOODCOST_TARGET_CONTAINER]], covering them in blood.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
		if (BLOODCOST_TARGET_USER)
			if (!tribute)
				if (data[BLOODCOST_HOLES_BLOODPACK])
					to_chat(user, "<span class='warning'>You must puncture \the [data[BLOODCOST_TARGET_BLOODPACK]] before you can squeeze blood from it!</span>")
				else if (data[BLOODCOST_LID_HELD])
					to_chat(user, "<span class='warning'>Remove \the [data[BLOODCOST_TARGET_HELD]]'s lid first!</span>")
				else if (data[BLOODCOST_LID_CONTAINER])
					to_chat(user, "<span class='warning'>Remove \the [data[BLOODCOST_TARGET_CONTAINER]]'s lid first!</span>")
			var/mob/living/carbon/human/H = user
			blood = get_blood(H.vessel)
			if (previous_result != BLOODCOST_TARGET_USER)
				if(!tribute && istype(H))
					var/obj/item/weapon/W = H.get_active_hand()
					if (W && W.sharpness_flags & SHARP_BLADE)
						to_chat(user, "<span class='rose'>You slice open your finger with \the [W] to let a bit of blood flow.</span>")
					else
						var/obj/item/weapon/W2 = H.get_inactive_hand()
						if (W2 && W2.sharpness_flags & SHARP_BLADE)
							to_chat(user, "<span class='rose'>You slice open your finger with \the [W] to let a bit of blood flow.</span>")
						else
							to_chat(user, "<span class='rose'>You bite your finger and let the blood pearl up.</span>")
		if (BLOODCOST_FAILURE)
			if (!tribute)
				if (data[BLOODCOST_HOLES_BLOODPACK])
					to_chat(user, "<span class='danger'>You must puncture \the [data[BLOODCOST_TARGET_BLOODPACK]] before you can squeeze blood from it!</span>")
				else if (data[BLOODCOST_LID_HELD])
					to_chat(user, "<span class='danger'>Remove \the [data[BLOODCOST_TARGET_HELD]]'s lid first!</span>")
				else if (data[BLOODCOST_LID_CONTAINER])
					to_chat(user, "<span class='danger'>Remove \the [data[BLOODCOST_TARGET_HELD]]'s lid first!</span>")
				else
					to_chat(user, "<span class='danger'>There is no blood available. Not even in your own body!</span>")

	//Blood is only consumed if there is enough of it
	if (!data[BLOODCOST_FAILURE])
		if (data[BLOODCOST_TARGET_HANDS])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_HANDS]
			var/mob/living/carbon/human/H = user
			H.bloody_hands = max(0, H.bloody_hands - data[BLOODCOST_AMOUNT_HANDS])
			if (!H.bloody_hands)
				H.clean_blood()
				H.update_inv_gloves()
		if (data[BLOODCOST_TARGET_SPLATTER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_SPLATTER]
			var/obj/effect/decal/cleanable/blood/B = data[BLOODCOST_TARGET_SPLATTER]
			B.amount = max(0 , B.amount - data[BLOODCOST_AMOUNT_SPLATTER])
		if (data[BLOODCOST_TARGET_GRAB])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_GRAB]
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_GRAB]
			H.vessel.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_GRAB])
			H.take_overall_damage(data[BLOODCOST_AMOUNT_GRAB] ? 0.1 : 0)
		if (data[BLOODCOST_TARGET_BLEEDER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_BLEEDER]
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_BLEEDER]
			H.vessel.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_BLEEDER])
			H.take_overall_damage(data[BLOODCOST_AMOUNT_BLEEDER] ? 0.1 : 0)
		if (data[BLOODCOST_TARGET_HELD])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_HELD]
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_HELD]
			G.reagents.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_HELD])
		if (data[BLOODCOST_TARGET_CONTAINER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_CONTAINER]
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_CONTAINER]
			G.reagents.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_CONTAINER])
		if (data[BLOODCOST_TARGET_USER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_USER]
			var/mob/living/carbon/human/H = user
			var/blood_before = H.vessel.get_reagent_amount(BLOOD)
			H.vessel.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_USER])
			var/blood_after = H.vessel.get_reagent_amount(BLOOD)
			if (blood_before > BLOOD_VOLUME_SAFE && blood_after < BLOOD_VOLUME_SAFE)
				to_chat(user, "<span class='sinister'>You start looking pale.</span>")
			else if (blood_before > BLOOD_VOLUME_WARN && blood_after < BLOOD_VOLUME_WARN)
				to_chat(user, "<span class='sinister'>You feel weak from the lack of blood.</span>")
			else if (blood_before > BLOOD_VOLUME_OKAY && blood_after < BLOOD_VOLUME_OKAY)
				to_chat(user, "<span class='sinister'>You are about to pass out from the lack of blood.</span>")
			else if (blood_before > BLOOD_VOLUME_BAD && blood_after < BLOOD_VOLUME_BAD)
				to_chat(user, "<span class='sinister'>You have trouble focusing, things will go bad if you keep using your blood.</span>")
			else if (blood_before > BLOOD_VOLUME_SURVIVE && blood_after < BLOOD_VOLUME_SURVIVE)
				to_chat(user, "<span class='sinister'>It will be all over soon.</span>")
			H.take_overall_damage(data[BLOODCOST_AMOUNT_USER] ? 0.1 : 0)

	if (communion && data[BLOODCOST_TOTAL] + total_accumulated >= amount_needed)
		data[BLOODCOST_TOTAL] = max(data[BLOODCOST_TOTAL], total_needed)
	data["blood"] = blood
	return data


/obj/item/proc/get_cult_power()
	return 0

var/static/list/valid_cultpower_slots = list(
	slot_wear_suit,
	slot_head,
	slot_shoes,
	)//might add more slots later as I add more items that could fit in them

/mob/proc/get_cult_power()
	var/power = 0
	for (var/slot in valid_cultpower_slots)
		var/obj/item/I = get_item_by_slot(slot)
		if (istype(I))
			power += I.get_cult_power()

	return power
