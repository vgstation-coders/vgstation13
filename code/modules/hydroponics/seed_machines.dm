/obj/item/weapon/disk/botany
	name = "flora data disk"
	desc = "A small disk used for carrying data on plant genetics."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "disk_botany"
	var/list/genes = list()
	var/genesource = "unknown"

/obj/item/weapon/disk/botany/New()
	..()
	pixel_x = rand(-5,5) * PIXEL_MULTIPLIER
	pixel_y = rand(-5,5) * PIXEL_MULTIPLIER

/obj/item/weapon/disk/botany/attack_self(var/mob/user as mob)
	if(genes.len)
		var/choice = alert(user, "Are you sure you want to wipe the disk?", "Xenobotany Data", "No", "Yes")
		if(src && user && genes && choice && choice == "Yes" && (user.get_active_hand() == src || istype(loc,/obj/item/weapon/gripper/service)))
			to_chat(user, "You wipe the disk data.")
			name = initial(name)
			desc = initial(desc)
			genes = list()
			genesource = "unknown"

/obj/machinery/botany
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "hydrotray3"
	density = 1
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL

	var/obj/item/seeds/loaded_seed // Currently loaded seed packet.
	var/obj/item/weapon/disk/botany/loaded_disk //Currently loaded data disk.

	var/open = 0
	var/active = 0
	var/action_time = 50
	var/last_action = 0
	var/eject_disk = 0
	var/failed_task = 0
	var/disk_needs_genes = 0
	var/time_coeff = 1

/obj/machinery/botany/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/ML in component_parts)
		T += ML.rating
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/MA in component_parts)
		T += MA.rating
	time_coeff = T

/obj/machinery/botany/process()

	..()
	if(!active)
		return

	if(world.time > last_action + action_time/time_coeff)
		finished_task()

/obj/machinery/botany/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/botany/attack_hand(mob/user as mob)
	ui_interact(user)

/obj/machinery/botany/proc/finished_task()
	active = 0
	if(failed_task)
		failed_task = 0
		visible_message("[bicon(src)] [src] pings unhappily, flashing a red warning light.")
		playsound(src, 'sound/machines/buzz-two.ogg', 50, 0)
	else
		visible_message("[bicon(src)] [src] pings happily.")
		playsound(src, 'sound/machines/notify.ogg', 50, 0)

	if(eject_disk)
		eject_disk = 0
		if(loaded_disk)
			loaded_disk.forceMove(get_turf(src))
			visible_message("[bicon(src)] [src] beeps and spits out [loaded_disk].")
			playsound(src, 'sound/machines/twobeep.ogg', 50, 0)
			loaded_disk = null

	nanomanager.update_uis(src)

/obj/machinery/botany/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if(istype(AM,/obj/item/seeds))
		if(loaded_seed)
			return FALSE
		var/obj/item/seeds/S = AM
		if(S.seed && S.seed.immutable > 0)
			return FALSE
		S.forceMove(src)
		loaded_seed = AM
		nanomanager.update_uis(src)
		return TRUE

	if(istype(AM,/obj/item/weapon/disk/botany))
		if(loaded_disk)
			return FALSE
		var/obj/item/weapon/disk/botany/B = AM

		if(B.genes && B.genes.len)
			if(!disk_needs_genes)
				return FALSE
		else
			if(disk_needs_genes)
				return FALSE

		AM.forceMove(src)

		loaded_disk = AM
		nanomanager.update_uis(src)
		return TRUE
	return FALSE

/obj/machinery/botany/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/seeds))
		if(loaded_seed)
			to_chat(user, "There is already a seed loaded.")
			return
		var/obj/item/seeds/S = W
		if(S.seed && S.seed.immutable > 0)
			to_chat(user, "That seed is not compatible with our genetics technology.")
		else
			user.drop_item(S, src, force_drop = 1)
			if(S.loc != src) //How did you do that? Gimme that fucking seed pack.
				S.forceMove(src)
			loaded_seed = W
			to_chat(user, "You load [W] into [src].")
			nanomanager.update_uis(src)
		return

	if(istype(W,/obj/item/weapon/disk/botany))
		if(loaded_disk)
			to_chat(user, "There is already a data disk loaded.")
			return
		else
			var/obj/item/weapon/disk/botany/B = W

			if(B.genes && B.genes.len)
				if(!disk_needs_genes)
					to_chat(user, "That disk already has gene data loaded.")
					return
			else
				if(disk_needs_genes)
					to_chat(user, "That disk does not have any gene data loaded.")
					return

			if(!user.drop_item(W, src))
				return

			loaded_disk = W
			to_chat(user, "You load [W] into [src].")
			nanomanager.update_uis(src)

		return
	return ..()

// Allows for a trait to be extracted from a seed packet, destroying that seed.
/obj/machinery/botany/extractor
	name = "lysis-isolation centrifuge"
	icon_state = "traitcopier"

	var/datum/seed/genetics // Currently scanned seed genetic structure.

/obj/machinery/botany/extractor/New()
	..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/botany_centrifuge,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/matter_bin,
	)

	RefreshParts()
	update_icon()

/obj/machinery/botany/extractor/power_change()
	..()
	update_icon()

/obj/machinery/botany/extractor/update_icon()
	if(stat & (FORCEDISABLE|NOPOWER))
		kill_moody_light()
		icon_state = "traitcopier-off"
	else
		update_moody_light('icons/lighting/moody_lights.dmi', "overlay_traitcopier")
		icon_state = "traitcopier"

/obj/machinery/botany/extractor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)

	if(!user)
		return

	var/list/data = list()
	var/static/list/gene_tag_list = list(
		list("tag" = GENE_PHYTOCHEMISTRY),
		list("tag" = GENE_MORPHOLOGY),
		list("tag" = GENE_BIOLUMINESCENCE),
		list("tag" = GENE_ECOLOGY),
		list("tag" = GENE_ECOPHYSIOLOGY),
		list("tag" = GENE_METABOLISM),
		list("tag" = GENE_DEVELOPMENT),
		list("tag" = GENE_XENOPHYSIOLOGY)
	)
	data["geneTags"] = gene_tag_list

	data["activity"] = active

	if(loaded_disk)
		data["disk"] = 1
	else
		data["disk"] = 0

	if(loaded_seed)
		data["loaded"] = "[loaded_seed.name]"
	else
		data["loaded"] = 0

	if(genetics)
		data["hasGenetics"] = 1
		data["sourceName"] = genetics.display_name
		if(!genetics.roundstart)
			data["sourceName"] += " (variety #[genetics.uid])"
	else
		data["hasGenetics"] = 0
		data["sourceName"] = 0

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "botany_isolator.tmpl", "Lysis-isolation Centrifuge UI", 470, 450)
		ui.set_initial_data(data)
		ui.open()
		//ui.set_auto_update(1)

/obj/machinery/botany/Topic(href, href_list)

	if(..())
		return 1
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()

	if(href_list["eject_packet"])
		if(!loaded_seed)
			return
		loaded_seed.forceMove(get_turf(src))

		if(loaded_seed.seed.name == "new line" || isnull(SSplant.seeds[loaded_seed.seed.name]))
			loaded_seed.seed.uid = SSplant.seeds.len + 1
			loaded_seed.seed.name = "[loaded_seed.seed.uid]"
			SSplant.seeds[loaded_seed.seed.name] = loaded_seed.seed

		loaded_seed.update_seed()
		visible_message("[bicon(src)] [src] beeps and spits out [loaded_seed].")

		loaded_seed = null

	if(href_list["eject_disk"])
		if(!loaded_disk)
			return
		loaded_disk.forceMove(get_turf(src))
		visible_message("[bicon(src)] [src] beeps and spits out [loaded_disk].")

		loaded_disk = null

	usr.set_machine(src)
	src.add_fingerprint(usr)

/obj/machinery/botany/extractor/Topic(href, href_list)

	if(..())
		return 1

	usr.set_machine(src)
	src.add_fingerprint(usr)

	if(href_list["scan_genome"])

		if(!loaded_seed)
			return

		last_action = world.time
		active = 1

		if(loaded_seed && loaded_seed.seed)
			genetics = loaded_seed.seed

		QDEL_NULL(loaded_seed)

	if(href_list["get_gene"])

		if(!genetics || !loaded_disk)
			return

		last_action = world.time
		active = 1

		var/datum/plantgene/P = genetics.get_gene(href_list["get_gene"])
		if(!P)
			return
		loaded_disk.genes += P

		loaded_disk.genesource = "[genetics.display_name]"
		if(!genetics.roundstart)
			loaded_disk.genesource += " (variety #[genetics.uid])"

		loaded_disk.name += " ([href_list["get_gene"]], #[genetics.uid])"
		loaded_disk.desc += " The label reads 'gene [href_list["get_gene"]], sampled from [genetics.display_name]'."
		eject_disk = 1

	if(href_list["clear_buffer"])
		if(!genetics)
			return
		genetics = null
	return 1

// Fires an extracted trait into another packet of seeds with a chance
// of destroying it based on the size/complexity of the plasmid.
/obj/machinery/botany/editor
	name = "bioballistic delivery system"
	icon_state = "traitgun"
	disk_needs_genes = 1
	var/mode = GENEGUN_MODE_SPLICE
	var/times_to_splice = 1

/obj/machinery/botany/editor/New()
	..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/botany_bioballistic,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
	)

	RefreshParts()


/obj/machinery/botany/editor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)

	if(!user)
		return

	var/list/data = list()

	data["activity"] = active
	data["mode"] = mode
	data["times_to_splice"] = times_to_splice

	if(loaded_disk && loaded_disk.genes.len)
		data["disk"] = 1
		data["sourceName"] = loaded_disk.genesource
		data["locus"] = ""

		for(var/datum/plantgene/P in loaded_disk.genes)
			if(data["locus"] != "")
				data["locus"] += ", "

			data["locus"] += P.genetype


	else
		data["disk"] = 0
		data["sourceName"] = 0
		data["locus"] = 0

	if(loaded_seed)
		data["loaded"] = "[loaded_seed.name]"
	else
		data["loaded"] = 0

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "botany_editor.tmpl", "Bioballistic Delivery UI", 470, 450)
		ui.set_initial_data(data)
		ui.open()
		//ui.set_auto_update(1)

/obj/machinery/botany/editor/Topic(href, href_list)

	if(..())
		return 1

	if( href_list["change_splice_amount"])
		var/new_amount = input(usr, "Enter the number of times to perform the SPLICE command: (Between 1 and 10)","Enter Multsplice Coefficient",times_to_splice) as num
		new_amount = clamp(1,new_amount,10)
		times_to_splice = new_amount

	if(href_list["apply_gene"])
		if(!loaded_disk || !loaded_seed)
			return

		last_action = world.time
		active = 1

		if(!isnull(SSplant.seeds[loaded_seed.seed.name]))
			loaded_seed.seed = loaded_seed.seed.diverge(1)
			loaded_seed.seed_type = loaded_seed.seed.name
			loaded_seed.update_seed()

		if(prob(loaded_seed.modified))
			failed_task = 1
			loaded_seed.modified = 101

		for(var/datum/plantgene/gene in loaded_disk.genes)
			if(mode == GENEGUN_MODE_SPLICE)
				for(var/i = 0, i < times_to_splice, i++) //multisplice
					loaded_seed.seed.apply_gene(gene, mode, usr)
			else
				loaded_seed.seed.apply_gene(gene, mode, usr)

	else if(href_list["toggle_mode"])
		switch(mode)
			if(GENEGUN_MODE_SPLICE)
				mode = GENEGUN_MODE_PURGE
			if(GENEGUN_MODE_PURGE)
				mode = GENEGUN_MODE_SPLICE

	usr.set_machine(src)
	src.add_fingerprint(usr)
	return 1

/obj/machinery/botany/editor/process()
	if(!active)
		return
	if(mode == GENEGUN_MODE_SPLICE)
		if(world.time > last_action + ((action_time-times_to_splice-(times_to_splice/2))*times_to_splice)/time_coeff) //this formula slightly decreases splice time as values get higher.
			finished_task()
	else
		if(world.time > last_action + action_time/time_coeff)
			finished_task()
