/**
	Rigsuit modification station

	Person inserts the modules they want to install into the machine
	Steps inside
	Machine locks them in place
	Spend N*5 SECONDS for each module to be installed
	Close up, re initialize the suit, eject the user.

	If malfunctioning, during the close up stage,  chop their limbs off?

**/

#define SUIT_INDEX 1
#define HELMET_INDEX 2
#define ACCESS_REQUIREMENT_INDEX 3
/obj/machinery/suit_modifier
	name = "spacesuit modification station"
	desc = "A man-sized machine, akin to a coffin, meant to install modifications into a worn spacesuit."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "suitmodifier"
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE

	var/list/modules_to_install = list()
	var/obj/item/weapon/cell/cell = null
	var/atom/movable/suit_overlay
	var/activated = FALSE
	var/static/list/plasmaman_suits
	var/static/list/vox_suits
	var/apply_multiplier = 1
	idle_power_usage = 50
	active_power_usage = 300

/proc/build_plasmaman_suit_list()
	return build_suit_list(/datum/species/plasmaman, /obj/item/clothing/suit/space/plasmaman, /obj/item/clothing/head/helmet/space/plasmaman)

/proc/build_vox_suit_list()
	return build_suit_list(/datum/species/vox, /obj/item/clothing/suit/space/vox, /obj/item/clothing/head/helmet/space/vox)

/proc/build_suit_list(datum/species/species, suit_base_path, helmet_base_path)
	// This thing is using outfit datums to build an associative list of
	// "job title string" -> list(suit_type_path, helmet_type_path, access_required)
	. = list()
	for(var/path in subtypesof(/datum/outfit))
		var/datum/outfit/entry = new path
		var/datum/job/associated_job = locate(entry.associated_job) in job_master.occupations
		if(!associated_job)
			continue
		var/list/items_to_spawn = entry.items_to_spawn
		if(!length(items_to_spawn))
			continue
		var/list/species_items = items_to_spawn[species]
		if(!length(species_items))
			continue
		var/obj/item/clothing/suit/space/suit = species_items[slot_wear_suit_str]
		var/obj/item/clothing/head/helmet/space/head = species_items[slot_head_str]
		if(!ispath(suit, suit_base_path))
			continue
		if(!ispath(head, helmet_base_path))
			continue
		. += associated_job.title
		.[associated_job.title] = list(suit, head, associated_job.get_access())

/obj/machinery/suit_modifier/New()
	..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/suit_modifier,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/micro_laser
	)
	if(world.has_round_started())
		initialize()

/obj/machinery/suit_modifier/RefreshParts()
	var/avg_rate = 0
	var/amount = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		avg_rate += M.rating
		amount++
	apply_multiplier = (avg_rate / amount)
	avg_rate = 0
	amount = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/ML in component_parts)
		avg_rate += ML.rating
		amount++
	active_power_usage = 300 / (avg_rate / amount)

/obj/machinery/suit_modifier/initialize()
	suit_overlay = new
	suit_overlay.icon = 'icons/obj/stationobjs.dmi'
	suit_overlay.plane = ABOVE_HUMAN_PLANE
	vis_contents += suit_overlay
	if(!plasmaman_suits)
		plasmaman_suits = build_plasmaman_suit_list()
	if(!vox_suits)
		vox_suits = build_vox_suit_list()

/obj/machinery/suit_modifier/Destroy()
	..()
	vis_contents.Cut()
	QDEL_NULL(suit_overlay)

/obj/machinery/suit_modifier/examine(mob/user)
	..()
	if(modules_to_install.len)
		to_chat(user, "<span class = 'notice'>There is:</span>")
		for(var/obj/item/rig_module/RM in modules_to_install)
			to_chat(user, "<span class = 'notice'>[RM.name]:</span>")
		to_chat(user, "<span class = 'notice'>within \the [src].</span>")


/obj/machinery/suit_modifier/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/rig_module) && user.drop_item(I, src))
		say("\The [I] installed.", class = "binaryradio")
		modules_to_install.Add(I)
		return
	if(istype(I, /obj/item/weapon/cell) && !cell && user.drop_item(I, src))
		say("\The [I] installed.", class = "binaryradio")
		cell = I
		return
	.=..()

/obj/machinery/suit_modifier/attack_hand(mob/user)
	if(!isliving(user))
		return
	if(is_locking(/mob/living/carbon/human))
		playsound(src, 'sound/machines/buzz-two.ogg', 50, 0)
		say("Unit Occupied.", class = "binaryradio")
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.loc == loc)
		var/obj/worn_suit = H.get_item_by_slot(slot_wear_suit)
		if(istype(worn_suit, /obj/item/clothing/suit/space/rig))
			var/obj/item/clothing/suit/space/rig/worn_rig = worn_suit
			if(!modules_to_install.len && !cell)
				if(worn_rig.modules.len)
					say("Installed modules detected.", class = "binaryradio")
					process_module_removal(H)
					return
				say("No upgrade available.", class = "binaryradio")
				return
			process_module_installation(H)
			return
		if(istype(worn_suit, /obj/item/clothing/suit/space/plasmaman))
			process_suit_paint(H, plasmaman_suits)
		else if(istype(worn_suit, /obj/item/clothing/suit/space/vox))
			process_suit_paint(H, vox_suits)
		else
			say("Unable to detect compatible spacesuit on [H].", class = "binaryradio")
	else if((modules_to_install.len || cell) && !activated)
		var/obj/removed = input(user, "Choose an upgrade to remove from [src].", src) as null|anything in modules_to_install + cell
		if(!removed || activated || !user.Adjacent(src) || user.incapacitated())
			return
		user.put_in_hands(removed)
		if(removed.loc == src)
			removed.forceMove(get_turf(src))
		if(removed == cell)
			cell = null
		else
			modules_to_install -= removed

/obj/machinery/suit_modifier/proc/activation_animation()
	flick("suitmodifier_activate", suit_overlay)
	sleep(12)

/obj/machinery/suit_modifier/proc/working_animation()
	flick("suitmodifier_working", suit_overlay)
	sleep(38)

	flick("suitmodifier_close", suit_overlay)
	sleep(22)

	suit_overlay.icon_state = "suitmodifier_closed"
	sleep(20)

/obj/machinery/suit_modifier/proc/finished_animation()
	suit_overlay.icon_state = null
	playsound(src, 'sound/machines/pressurehiss.ogg', 40, 1)
	new /obj/effect/smoke(get_turf(src))

/proc/filter_suit_list(mob/living/carbon/human/guy, list/suit_list)
	var/guy_access = guy.GetAccess()
	var/list/filtered_suit_list = list()
	for(var/entry in suit_list)
		if(can_access(guy_access, suit_list[entry][ACCESS_REQUIREMENT_INDEX]))
			filtered_suit_list += entry
			filtered_suit_list[entry] = list(suit_list[entry][SUIT_INDEX], suit_list[entry][HELMET_INDEX])
	return filtered_suit_list

/obj/machinery/suit_modifier/proc/process_suit_paint(mob/living/carbon/human/guy, list/suit_list)
	if(activated)
		return
	lock_atom(guy)
	var/obj/item/clothing/suit/space/chosen_job = input(guy, "What kind of paint do you wish to apply?") as null|anything in filter_suit_list(guy, suit_list)
	if(!chosen_job || activated || guy.incapacitated() || guy.loc != loc)
		unlock_atom(guy)
		return
	var/obj/item/clothing/suit/space/chosen_suit = suit_list[chosen_job][SUIT_INDEX]
	var/obj/item/clothing/head/helmet/space/plasmaman/chosen_helmet = suit_list[chosen_job][HELMET_INDEX]
	activated = TRUE
	use_power = MACHINE_POWER_USE_ACTIVE
	activation_animation()
	working_animation()
	var/obj/item/clothing/suit/space/suit = guy.get_item_by_slot(slot_wear_suit)
	suit.desc = "The colors are a bit dodgy."
	suit.icon_state = initial(chosen_suit.icon_state)
	guy.update_inv_wear_suit()
	var/obj/item/clothing/head/helmet/space/helmet = guy.get_item_by_slot(slot_head)
	if(istype(helmet))
		helmet.icon_state = initial(chosen_helmet.icon_state)
		desc = "The colors are a bit dodgy."
		if(istype(helmet, /obj/item/clothing/head/helmet/space/plasmaman))
			var/obj/item/clothing/head/helmet/space/plasmaman/special_snowflake = helmet
			special_snowflake.base_state = initial(chosen_helmet.base_state)
		guy.update_inv_head()
	finished_animation()
	unlock_atom(guy)
	use_power = MACHINE_POWER_USE_IDLE
	activated = FALSE

/obj/machinery/suit_modifier/proc/process_module_installation(var/mob/living/carbon/human/H)
	if(activated)
		return
	lock_atom(H)
	activated = TRUE
	use_power = MACHINE_POWER_USE_ACTIVE
	activation_animation()
	var/obj/item/clothing/suit/space/rig/R = H.is_wearing_item(/obj/item/clothing/suit/space/rig, slot_wear_suit)
	R.deactivate_suit()
	for(var/obj/item/rig_module/RM in modules_to_install)
		var/install_result=RM.can_install(R)
		if(!install_result[1]) //more versatile check, allows for custom install conditions.
			say(install_result[2], class = "binaryradio")
			continue
		if(do_after(H, src, 8 SECONDS / apply_multiplier, needhand = FALSE))
			say("Installing [RM] into \the [R].", class = "binaryradio")
			R.modules.Add(RM)
			RM.rig = R
			RM.forceMove(R)
			modules_to_install.Remove(RM)
	working_animation()
	if(cell) //Can't answer the prompt if you're incapacitated.
		var/choice = alert(H, "Do you wish to install [cell]?", src, "Yes", "No")
		if((choice == "Yes") && H.Adjacent(src) && !H.incapacitated())
			say("Installing [cell] into to \the [R].", class = "binaryradio")
			if(R.cell)
				R.cell.forceMove(get_turf(src))
			cell.forceMove(R)
			R.cell = cell
			cell = null
	finished_animation()
	unlock_atom(H)
	R.initialize_suit()
	use_power = MACHINE_POWER_USE_IDLE
	activated = FALSE

/obj/machinery/suit_modifier/proc/process_module_removal(var/mob/living/carbon/human/H)
	if(activated)
		return
	lock_atom(H)
	activated = TRUE
	use_power = MACHINE_POWER_USE_ACTIVE
	activation_animation()
	var/obj/item/clothing/suit/space/rig/R = H.is_wearing_item(/obj/item/clothing/suit/space/rig, slot_wear_suit)
	R.deactivate_suit()
	if(R.modules.len)
		// if we have something that's not a rig_module here we have a problem
		var/obj/item/rig_module/RM = input(H, "Choose an upgrade to remove from [R].", R) as null|anything in R.modules
		if(!RM|| !H.Adjacent(src) || H.incapacitated())
			unlock_atom(H)
			activated = FALSE
			return
		working_animation()
		say("Uninstalling [RM] from \the [R].", class = "binaryradio")
		if(do_after(H, src, 8 SECONDS / apply_multiplier, needhand = FALSE))
			R.modules.Remove(RM)
			RM.rig = null
			RM.forceMove(get_turf(src))
		finished_animation()
	unlock_atom(H)
	R.initialize_suit()
	use_power = MACHINE_POWER_USE_IDLE
	activated = FALSE

/obj/machinery/suit_modifier/get_cell()
	return cell

#undef SUIT_INDEX
#undef HELMET_INDEX
#undef ACCESS_REQUIREMENT_INDEX
