//CULT 3.0 BY DEITY LINK (2018)
//BASED ON THE ORIGINAL GAME MODE BY URIST MCDORF

/* In this file:

	* faction code

	> special procs:
		* get_available_blood
			-> returns a /list with information on nearby available blood. For use by use_available_blood().
		* use_available_blood
			-> actually removes the blood from containers, displays flavor texts, and returns a /list with informations on the success/failure of the proc.
		* spawn_bloodstones
			-> called at the start of ACT III, or by set_veil_thickness. Triggers the rise of bloodstones accross the station Z level.
		* prepare_cult_holomap
			-> initialize the cult holomap displayed by Altars, and Bloodstones when it gets checked by a cultist
		* cult_risk
			-> rolls for a chance to reveal the presence of the cult to the crew prior to ACT III, called after a ritual that increases the cultist count.
		> /obj/item procs:
			* get_cult_power
				-> returns the item's cult power. set manually for each item in bloodcult_items.dm.
		> /mob procs:
			* get_cult_power
				-> returns the combined cult power of every item worn by that mob.
		> /client procs:
			* set_veil_thickness
				-> debug proc that lets you manipulate what powers are currently available to cult, disregarding the current completion of their objectives
				-> WARNING: setting to "3" will trigger the rise of bloodstones.

*/

var/veil_thickness = CULT_PROLOGUE

//CULT_PROLOGUE		Default thickness, only communication and raise structure runes enabled.
//CULT_ACT_I		Altar raised. cultists can now convert.
//CULT_ACT_II		Cultist amount reached. Cultists are now looking for the sacrifice.
//CULT_ACT_III		Sacrifice complete. Cult is now going loud, spreading blood and protecting bloodstones while the crew tries to destroy them.
//CULT_ACT_IV		Bloodspill threshold reached. A bloodstone becomes the anchor stone. Cultists must summon Nar-Sie here, whereas crew members must destroy it.
//CULT_EPILOGUE		The cult succeeded. The station is no longer reachable from space or through teleportation, and is now part of hell. Nar-Sie hunts the survivors.
//CULT_MENDED		The cult failed (bloodstones all destroyed or rift closed). cult magic permanently disabled, living cultists progressively die by themselves.


///////////////////////////////FACTION CODE - START/////////////////////////////////

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
	//var/target_change = FALSE
	//var/change_cooldown = 0
	var/cult_win = FALSE
	var/warning = FALSE

	var/list/cult_reminders = list()

/datum/faction/bloodcult/check_win()
	return cult_win

/datum/faction/bloodcult/IsSuccessful()
	return cult_win

/datum/faction/bloodcult/proc/fail()
	if(veil_thickness == CULT_MENDED || veil_thickness == CULT_EPILOGUE)
		return
	stage(CULT_MENDED)

/datum/faction/bloodcult/HandleRecruitedRole(var/datum/role/R)
	. = ..()
	if (cult_reminders.len)
		to_chat(R.antag.current, "<span class='notice'>The other cultists have left some useful reminders for you. They will be stored in your memory.</span>")
	for (var/reminder in cult_reminders)
		R.antag.store_memory("Cult reminder: [reminder].")

/datum/faction/bloodcult/AdminPanelEntry(var/datum/admins/A)
	var/list/dat = ..()
	dat += "<br><a href='?src=\ref[src];cult_mindspeak_global=1'>Voice of Nar-Sie</a>"
	dat += "<br><a href='?src=\ref[src];cult_progress=1'>(debug) Cult Progression Skip</a>"
	return dat

/datum/faction/bloodcult/Topic(href, href_list)
	..()
	if (href_list["cult_mindspeak_global"])
		var/message = input("What message shall we send?",
                    "Voice of Nar-Sie",
                    "")
		for (var/datum/role/R in members)
			var/mob/M = R.antag.current
			if (M && R.antag.GetRole(CULTIST))//failsafe for cultist brains put in MMIs
				to_chat(M, "<span class='danger'>Nar-Sie</span> murmurs... <span class='sinister'>[message]</span>")

		for(var/mob/dead/observer/O in player_list)
			to_chat(O, "<span class='game say'><span class='danger'>Nar-Sie</span> murmurs, <span class='sinister'>[message]</span></span>")

		message_admins("Admin [key_name_admin(usr)] has talked with the Voice of Nar-Sie.")
		log_narspeak("[key_name(usr)] Voice of Nar-Sie: [message]")
	if (href_list["cult_progress"])
		if (alert(usr, "Skip to the next Act?","Cult Progression Skip","Yes","No") == "No")
			return

		stage(veil_thickness+1,forced=TRUE)

		message_admins("Admin [key_name_admin(usr)] has advanced the Blood Cult to the next Act.")
		log_admin("Admin [key_name_admin(usr)] has advanced the Blood Cult to the next Act.")

/datum/faction/bloodcult/HandleNewMind(var/datum/mind/M)
	..()
	M.special_role = "Cultist"

/datum/faction/bloodcult/OnPostSetup()
	initialize_runesets()
	AppendObjective(/datum/objective/bloodcult_reunion)


/datum/faction/bloodcult/minorVictoryText()
	return "The cult completed its sacrificial ritual, but not in time to summon Nar-Sie."

/*
/datum/faction/bloodcult/process()
	..()

	if (change_cooldown > 0)
		change_cooldown -= 1 SECONDS
		if (change_cooldown <= 0)
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
		target_change = FALSE
		change_cooldown = SACRIFICE_CHANGE_COOLDOWN
*/

/datum/faction/bloodcult/stage(var/new_act,var/A,var/forced=FALSE)
	//This proc is called to update the faction's current objectives, and veil thickness
	if (veil_thickness == CULT_MENDED)
		return//it's over, you lost

	if (new_act == CULT_MENDED)
		veil_thickness = CULT_MENDED
		..()
		command_alert(/datum/command_alert/bloodstones_broken)
		for (var/obj/structure/cult/bloodstone/B in bloodstone_list)
			B.takeDamage(B.maxHealth+1)
		for (var/obj/effect/rune/R in global_runesets["blood_cult"].rune_list)
			R.update_icon()
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
				if (O.conversions >= O.convert_target || forced)
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
			minor_victory = TRUE // At any rate, we achieve a minor win.
			if (O)
				O.target_sacrificed = TRUE
				veil_thickness = CULT_ACT_III
				emergency_shuttle.force_shutdown()//No shuttle calls until the cult either wins or fails.
				spawn_bloodstones(A)
				..()
				command_alert(/datum/command_alert/bloodstones_raised)
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
			if (M && iscultist(M))
				to_chat(M,"<span class='danger'>[new_obj.name]</span><b>: [new_obj.explanation_text]</b>")
				//ACT 1
				if (istype(new_obj,/datum/objective/bloodcult_followers))
					to_chat(M,"<b>As our ritual progresses through its Acts, the veil gets thinner, and dormant runes awaken. Summon a tome (<span class='danger'>See Blood Hell</span>) to see the available runes and learn their uses.</b>")
				//ACT 2
				if (istype(new_obj,/datum/objective/bloodcult_sacrifice))
					var/datum/objective/bloodcult_sacrifice/O = new_obj
					if (O.sacrifice_target)
						if (M == O.sacrifice_target)
							to_chat(M,"<b>There is no greater honor than purposefuly relinquishing your body for the coming of Nar-Sie.</b>")
						to_chat(M,"<b>Should the target's body be annihilated, or should they flee the station, you may commune with Nar-Sie at an altar to have him designate a new target.</b>")
					else
						to_chat(M,"<b>There are no elligible targets aboard the station, how did you guys even manage that one?</b>")//if there's literally no humans aboard the station
						to_chat(M,"<b>Commune with Nar-Sie at an altar to have him designate a new target.</b>")

		for (var/datum/role/cultist/C in members)
			C.update_cult_hud()

		for (var/obj/structure/cult/spire/S in cult_spires)//spires update their appearance on Act 2 and 3, signaling new available tattoos.
			S.upgrade()

		for (var/obj/effect/rune/R in global_runesets["blood_cult"].rune_list)//runes now available will start pulsing
			R.update_icon()

		if (istype(new_obj,/datum/objective/bloodcult_bloodbath))
			var/datum/objective/bloodcult_bloodbath/O = new_obj
			O.max_bloodspill = max(O.max_bloodspill,bloody_floors.len)
			if (O.IsFulfilled())
				stage(CULT_ACT_IV)

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
					stage(CULT_ACT_IV)


/datum/faction/bloodcult/proc/remove_bloody_floor(var/turf/T)
	if (!istype(T))
		return
	for (var/obj/structure/cult/bloodstone/B in bloodstone_list)
		B.update_icon()
	bloody_floors -= T

/datum/faction/bloodcult/proc/minor_victory()
	for(var/datum/role/cultist/C in members)
		var/mob/M = C.antag.current
		if (M && iscultist(M))
			to_chat(M,"<span class='sinister'>While the sacrifice was correctly completed, we were not fast enough to prevent our ennemies from fleeing.</span>")
			to_chat(M, "<span class='sinister'>This changes nothing. We will find another way.</span>")
			for (var/datum/objective/O in objective_holder.objectives)
				O.force_success = TRUE
	minor_victory = TRUE

/datum/faction/bloodcult/GetScoreboard()
	.=..()
	if(veil_thickness == CULT_EPILOGUE)
		var/obj/machinery/singularity/narsie/large/L = locate() in narsie_list //There should only be one
		if(L.wounded)
			. += "<BR><font color = 'green'><B>Though defeated, the crew managed to deal [L.wounded] damaging blows to \the [L].</B></font>"




///////////////////////////////FACTION CODE - END/////////////////////////////////












//When cultists need to pay in blood to use their spells, they have a few options at their disposal:
// * If their hands are bloody, they can use the few units of blood on them.
// * If there is a blood splatter on the ground that still has a certain amount of fresh blood in it, they can use that?
// * If they are grabbing another person, they can stab their nails in their vessels to draw some blood from them
// * If they are standing above a bleeding person, they can dip their fingers into their wounds.
// * If they are holding a container that has blood in it (such as a beaker or a blood pack), they can pour/squeeze blood from them
// * If they are standing above a container that has blood in it, they can dip their fingers into them
// * Finally if there are no alternative blood sources, you can always use your own blood.

/*	get_available_blood
	user: the mob (generally a cultist) trying to spend blood
	amount_needed: the amount of blood required

	returns: a /list with information on nearby available blood. For use by use_available_blood().
*/
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
		BLOODCOST_USER = null,
		)
	var/turf/T = get_turf(user)
	var/amount_gathered = 0

	data[BLOODCOST_RESULT] = user

	if (amount_needed == 0)//the cost was probably 1u, and already paid for by blood communion from another cultist
		data[BLOODCOST_RESULT] = BLOODCOST_TRIBUTE
		return data

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
			if(!(H.species.anatomy_flags & NO_BLOOD))
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
		if(H.species.anatomy_flags & NO_BLOOD)
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

	var/mob/living/silicon/robot/robot_user = user
	if(istype(robot_user))
		var/module_items = robot_user.get_equipped_items() //This function allows robot modules to be used as blood sources. Somewhat important, considering silicons have no blood.
		for(var/obj/item/weapon/gripper/G_held in module_items)
			if (!istype(G_held) || !G_held.wrapped || !istype(G_held.wrapped,/obj/item/weapon/reagent_containers))
				continue
			var/obj/item/weapon/reagent_containers/gripper_item = G_held.wrapped
			if(round(gripper_item.reagents.get_reagent_amount(BLOOD)))
				var/blood_volume = round(gripper_item.reagents.get_reagent_amount(BLOOD))
				if (blood_volume)
					data[BLOODCOST_TARGET_HELD] = gripper_item
					if (gripper_item.is_open_container())
						var/blood_gathered = min(amount_needed-amount_gathered,blood_volume)
						data[BLOODCOST_AMOUNT_HELD] = blood_gathered
						amount_gathered += blood_gathered
					else
						data[BLOODCOST_LID_HELD] = 1

				if (amount_gathered >= amount_needed)
					data[BLOODCOST_RESULT] = BLOODCOST_TARGET_HELD
					return data

		for(var/obj/item/weapon/reagent_containers/G_held in module_items)
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

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_CONTAINER
		return data

	//Does the user have blood? (the user can pay in blood without having to bleed first)
	if(istype(H_user) && !(H_user.species.anatomy_flags & NO_BLOOD))
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


/*	use_available_blood
	user: the mob (generally a cultist) trying to spend blood
	amount_needed: the amount of blood required
	previous_result: the result of the previous call of this proc if any, to prevent the same flavor text from displaying every single call of this proc in a row
	tribute: set to 1 when called by a contributor to Blood Communion

	returns: a /list with information on the success/failure of the proc, and in the former case, information the blood that was used (color, type, dna)
*/
/proc/use_available_blood(var/mob/user, var/amount_needed = 0,var/previous_result = "", var/tribute = 0)
	//Blood Communion
	var/communion = 0
	var/communion_data = null
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
					communion_data = data//in which case, the blood will carry the data that paid for it
					break

	//Getting nearby blood sources
	var/list/data = get_available_blood(user, amount_needed-total_accumulated)

	var/datum/reagent/blood/blood

	//Flavour text and blood data transfer
	switch (data[BLOODCOST_RESULT])
		if (BLOODCOST_TRIBUTE)//if the drop of blood was paid for through blood communion, let's get the reference to the blood they used because we can
			blood = new()
			blood.data["blood_colour"] = DEFAULT_BLOOD
			if (communion_data && communion_data[BLOODCOST_RESULT])
				switch(communion_data[BLOODCOST_RESULT])
					if (BLOODCOST_TARGET_HANDS)
						var/mob/living/carbon/human/HU = communion_data[BLOODCOST_USER]
						blood.data["blood_colour"] = HU.hand_blood_color
						if (HU.blood_DNA && HU.blood_DNA.len)
							var/blood_DNA = pick(HU.blood_DNA)
							blood.data["blood_DNA"] = blood_DNA
							blood.data["blood_type"] = HU.blood_DNA[blood_DNA]
					if (BLOODCOST_TARGET_SPLATTER)
						var/obj/effect/decal/cleanable/blood/B = communion_data[BLOODCOST_TARGET_SPLATTER]
						blood = new()
						blood.data["blood_colour"] = B.basecolor
						if (B.blood_DNA.len)
							var/blood_DNA = pick(B.blood_DNA)
							blood.data["blood_DNA"] = blood_DNA
							blood.data["blood_type"] = B.blood_DNA[blood_DNA]
						blood.data["virus2"] = B.virus2
					if (BLOODCOST_TARGET_GRAB)
						var/mob/living/carbon/human/HU = communion_data[BLOODCOST_TARGET_GRAB]
						blood = get_blood(HU.vessel)
						if (!blood.data["virus2"])
							blood.data["virus2"] = list()
						blood.data["virus2"] |= filter_disease_by_spread(virus_copylist(HU.virus2),required = SPREAD_BLOOD)
					if (BLOODCOST_TARGET_BLEEDER)
						var/mob/living/carbon/human/HU = communion_data[BLOODCOST_TARGET_BLEEDER]
						blood = get_blood(HU.vessel)
						if (!blood.data["virus2"])
							blood.data["virus2"] = list()
						blood.data["virus2"] |= filter_disease_by_spread(virus_copylist(HU.virus2),required = SPREAD_BLOOD)
					if (BLOODCOST_TARGET_HELD)
						var/obj/item/weapon/reagent_containers/G = communion_data[BLOODCOST_TARGET_HELD]
						blood = locate() in G.reagents.reagent_list
					if (BLOODCOST_TARGET_BLOODPACK)
						var/obj/item/weapon/reagent_containers/blood/B = communion_data[BLOODCOST_TARGET_BLOODPACK]
						blood = locate() in B.reagents.reagent_list
					if (BLOODCOST_TARGET_CONTAINER)
						var/obj/item/weapon/reagent_containers/G = communion_data[BLOODCOST_TARGET_CONTAINER]
						blood = locate() in G.reagents.reagent_list
					if (BLOODCOST_TARGET_USER)
						var/mob/living/carbon/human/HU = communion_data[BLOODCOST_USER]
						blood = get_blood(HU.vessel)
						if (!blood.data["virus2"])
							blood.data["virus2"] = list()
						blood.data["virus2"] |= filter_disease_by_spread(virus_copylist(HU.virus2),required = SPREAD_BLOOD)
			if (!tribute && previous_result != BLOODCOST_TRIBUTE)
				user.visible_message("<span class='warning'>Drips of blood seem to appear out of thin air around \the [user], and fall onto the floor!</span>",
									"<span class='rose'>An ally has lent you a drip of their blood for your ritual.</span>",
									"<span class='warning'>You hear a liquid flowing.</span>")
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
		if (data[BLOODCOST_TARGET_BLOODPACK])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_BLOODPACK]
			var/obj/item/weapon/reagent_containers/G = data[BLOODCOST_TARGET_BLOODPACK]
			G.reagents.remove_reagent(BLOOD, data[BLOODCOST_AMOUNT_BLOODPACK])
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

/*	spawn_bloodstones
	source: the turf where the ritual that triggered ACT III took place if any. Serves as the location of the 5th Bloodstone if close enough from the station center.

*/
/proc/spawn_bloodstones(var/turf/source = null)
	//Called at the beginning of ACT III, this is basically the cult's declaration of war on the crew
	//Spawns 4 structures, one in each quarters of the station
	//When spawning, those structures break and convert stuff around them, and add a wall layer in case of space exposure.
	var/list/places_to_spawn = list()
	for (var/i = 1 to 4)
		for (var/j = 10; j > 0; j--)
			var/turf/T = get_turf(pick(range(j*3,locate(map.center_x+j*4*(((round(i/2) % 2) == 0) ? -1 : 1 ),map.center_y+j*4*(((i % 2) == 0) ? -1 : 1 ),map.zMainStation))))
			if(!is_type_in_list(T,list(/turf/space,/turf/unsimulated,/turf/simulated/shuttle)))
				//Adding some blacklisted areas, specifically solars
				if (!istype(T.loc,/area/solar))
					places_to_spawn += T
					break
	//A 5th bloodstone will spawn if a proper turf was given as arg (up to 100 tiles from the station center, and not in space or on a shuttle)
	if (source && (source.z == map.zMainStation) && !isspace(source.loc) && !is_on_shuttle(source) && get_dist(locate(map.center_x,map.center_y,map.zMainStation),source)<100)
		places_to_spawn.Add(source)
	for (var/T in places_to_spawn)
		new /obj/structure/cult/bloodstone(T)

	//Cultists can use those bloodstones to locate the rest of them, they work just like station holomaps

	for(var/obj/structure/cult/bloodstone/B in bloodstone_list)
		if (!B.loc)
			qdel(B)
			message_admins("Blood Cult: A blood stone was somehow spawned in nullspace. It has been destroyed.")
			log_admin("Blood Cult: A blood stone was somehow spawned in nullspace. It has been destroyed.")

/*	prepare_cult_holomap
	returns: the initialized cult holomap

*/
//Instead of updating in realtime, cult holomaps update every time you check them again, saves some CPU.
/proc/prepare_cult_holomap()
	var/image/I = image(extraMiniMaps[HOLOMAP_EXTRA_CULTMAP])
	for(var/marker in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[marker]
		var/image/markerImage = image(holomarker.icon,holomarker.id)
		markerImage.color = holomarker.color
		if(holomarker.z == map.zMainStation && holomarker.filter & HOLOMAP_FILTER_CULT)
			if(map.holomap_offset_x.len >= map.zMainStation)
				markerImage.pixel_x = holomarker.x-8+map.holomap_offset_x[map.zMainStation]
				markerImage.pixel_y = holomarker.y-8+map.holomap_offset_y[map.zMainStation]
			else
				markerImage.pixel_x = holomarker.x-8
				markerImage.pixel_y = holomarker.y-8
			markerImage.appearance_flags = RESET_COLOR
			I.overlays += markerImage
	return I

/*	cult_risk
	M: the cultist responsible for the ritual that called this proc, so they get a warning message if they didn't trigger the announcement

*/
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
		if (issilicon(L)||isborer(L))
			continue
		if (L.stat != DEAD)
			if (iscultist(L))
				living_cultists++
			else
				living_noncultists++

	var/rate = 40//the percent of living cultist at which the risk starts appearing
	var/risk = min((living_cultists*((100-rate)/50) - living_noncultists*(rate/50)) * 25, 100)//the risk increases very rapidly. at 2-3 cultists over the limit, the exposure is guarranted

	if (risk > 0)
		if(prob(risk))
			message_admins("With a chance of [risk]% ([living_cultists] Cultists vs [living_noncultists] non-cultists), the cult's activities have been prematurely exposed.")
			log_admin("With a chance of [risk]% ([living_cultists] Cultists vs [living_noncultists] non-cultists), the cult's activities have been prematurely exposed.")
			cult.warning = TRUE
			command_alert(/datum/command_alert/cult_detected)
		else
			message_admins("With a chance of [risk]% ([living_cultists] Cultists vs [living_noncultists] non-cultists), the cult's activities have avoided raising suspicion for now...")
			log_admin("With a chance of [risk]% ([living_cultists] Cultists vs [living_noncultists] non-cultists), the cult's activities have avoided raising suspicion for now...")
			if (M)
				to_chat(M,"<span class='warning'>Be mindful, overzealous conversions and soul trapping will bring us unwanted attention. You should focus on the objective with your current force.</span>")

/*	get_cult_power
	returns: an int. Set directly in bloodcult_items.dm

*/
/obj/item/proc/get_cult_power()
	return 0

var/static/list/valid_cultpower_slots = list(
	slot_wear_suit,
	slot_head,
	slot_shoes,
	)//might add more slots later as I add more items that could fit in them

/*	get_cult_power
	returns: the combined cult power of every item worn by src.

*/
/mob/proc/get_cult_power()
	var/power = 0
	for (var/slot in valid_cultpower_slots)
		var/obj/item/I = get_item_by_slot(slot)
		if (istype(I))
			power += I.get_cult_power()

	return power

//WARNING: setting to "3" will trigger the rise of bloodstones.
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

	var/datum/runeset/bloodcult_runeset = global_runesets["blood_cult"]
	for (var/obj/effect/rune/R in bloodcult_runeset.rune_list)
		R.update_icon()
