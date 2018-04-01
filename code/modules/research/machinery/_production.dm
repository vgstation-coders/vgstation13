/obj/machinery/rnd/production
	name = "technology fabricator"
	desc = "Makes researched and prototype items with materials and energy."
	container_type = OPENCONTAINER
	layer = BELOW_OBJ_LAYER
	var/consoleless_interface = FALSE			//Whether it can be used without a console.
	var/efficiency_coeff = 1				//Materials needed / coeff = actual.
	var/list/categories = list()
	var/datum/component/material_container/materials			//Store for hyper speed!
	var/allowed_department_flags = ALL
	var/production_animation				//What's flick()'d on print.
	var/allowed_buildtypes = NONE
	var/list/datum/design/cached_designs
	var/list/datum/design/matching_designs
	var/department_tag = "Unidentified"			//used for material distribution among other things.
	var/datum/techweb/stored_research
	var/datum/techweb/host_research

	var/screen = RESEARCH_FABRICATOR_SCREEN_MAIN
	var/selected_category

/obj/machinery/rnd/production/Initialize()
	. = ..()
	create_reagents(0)
	materials = AddComponent(/datum/component/material_container,
		list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TITANIUM, MAT_BLUESPACE, MAT_PLASTIC), 0,
		FALSE, list(/obj/item/stack), CALLBACK(src, .proc/is_insertion_ready), CALLBACK(src, .proc/AfterMaterialInsert))
	materials.precise_insertion = TRUE
	RefreshParts()
	matching_designs = list()
	cached_designs = list()
	stored_research = new
	host_research = SSresearch.science_tech
	update_research()

/obj/machinery/rnd/production/proc/update_research()
	host_research.copy_research_to(stored_research, TRUE)
	update_designs()

/obj/machinery/rnd/production/proc/update_designs()
	cached_designs.Cut()
	for(var/i in stored_research.researched_designs)
		var/datum/design/d = stored_research.researched_designs[i]
		if((isnull(allowed_department_flags) || (d.departmental_flags & allowed_department_flags)) && (d.build_type & allowed_buildtypes))
			cached_designs |= d

/obj/machinery/rnd/production/RefreshParts()
	calculate_efficiency()

/obj/machinery/rnd/production/attack_hand(mob/user)
	interact(user)									//remove this snowflake shit when the refactor of storage components or some other pr that unsnowflakes attack_hand on machinery is in

/obj/machinery/rnd/production/ui_interact(mob/user)
	if(!consoleless_interface)
		return ..()
	user.set_machine(src)
	var/datum/browser/popup = new(user, "rndconsole", name, 460, 550)
	popup.set_content(generate_ui())
	popup.open()

/obj/machinery/rnd/production/Destroy()
	QDEL_NULL(stored_research)
	return ..()

/obj/machinery/rnd/production/proc/calculate_efficiency()
	efficiency_coeff = 1
	if(reagents)		//If reagents/materials aren't initialized, don't bother, we'll be doing this again after reagents init anyways.
		reagents.maximum_volume = 0
		for(var/obj/item/reagent_containers/glass/G in component_parts)
			reagents.maximum_volume += G.volume
			G.reagents.trans_to(src, G.reagents.total_volume)
	if(materials)
		materials.max_amount = 0
		for(var/obj/item/stock_parts/matter_bin/M in component_parts)
			materials.max_amount += M.rating * 75000
	var/total_rating = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total_rating += M.rating
	total_rating = max(1, total_rating)
	efficiency_coeff = total_rating

//we eject the materials upon deconstruction.
/obj/machinery/rnd/production/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	materials.retrieve_all()
	return ..()

/obj/machinery/rnd/production/proc/do_print(path, amount, list/matlist, notify_admins)
	if(notify_admins)
		investigate_log("[key_name(usr)] built [amount] of [path] at [src]([type]).", INVESTIGATE_RESEARCH)
		message_admins("[ADMIN_LOOKUPFLW(usr)] has built [amount] of [path] at a [src]([type]).")
	for(var/i in 1 to amount)
		var/obj/item/I = new path(get_turf(src))
		if(!istype(I, /obj/item/stack/sheet) && !istype(I, /obj/item/stack/ore/bluespace_crystal))
			I.materials = matlist.Copy()
	SSblackbox.record_feedback("nested tally", "item_printed", amount, list("[type]", "[path]"))

/obj/machinery/rnd/production/proc/check_mat(datum/design/being_built, M)	// now returns how many times the item can be built with the material
	var/list/all_materials = being_built.reagents_list + being_built.materials

	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)

	return round(A / max(1, (all_materials[M]/efficiency_coeff)))

/obj/machinery/rnd/production/proc/user_try_print_id(id, amount)
	if((!istype(linked_console) && requires_console) || !id)
		return FALSE
	if(istext(amount))
		amount = text2num(amount)
	if(isnull(amount))
		amount = 1
	var/datum/design/D = (linked_console || requires_console)? linked_console.stored_research.researched_designs[id] : get_techweb_design_by_id(id)
	if(!istype(D))
		return FALSE
	if(!(isnull(allowed_department_flags) || (D.departmental_flags & allowed_department_flags)))
		say("Warning: Printing failed: This fabricator does not have the necessary keys to decrypt design schematics. Please update the research data with the on-screen button and contact Nanotrasen Support!")
		return FALSE
	if(D.build_type && !(D.build_type & allowed_buildtypes))
		say("This machine does not have the necessary manipulation systems for this design. Please contact Nanotrasen Support!")
		return FALSE
	var/power = 1000
	amount = CLAMP(amount, 1, 50)
	for(var/M in D.materials)
		power += round(D.materials[M] * amount / 35)
	power = min(3000, power)
	use_power(power)
	var/list/efficient_mats = list()
	for(var/MAT in D.materials)
		efficient_mats[MAT] = D.materials[MAT]/efficiency_coeff
	if(!materials.has_materials(efficient_mats, amount))
		say("Not enough materials to complete prototype[amount > 1? "s" : ""].")
		return FALSE
	for(var/R in D.reagents_list)
		if(!reagents.has_reagent(R, D.reagents_list[R]*amount/efficiency_coeff))
			say("Not enough reagents to complete prototype[amount > 1? "s" : ""].")
			return FALSE
	materials.use_amount(efficient_mats, amount)
	for(var/R in D.reagents_list)
		reagents.remove_reagent(R, D.reagents_list[R]*amount/efficiency_coeff)
	busy = TRUE
	if(production_animation)
		flick(production_animation, src)
	var/timecoeff = D.lathe_time_factor / efficiency_coeff
	addtimer(CALLBACK(src, .proc/reset_busy), (30 * timecoeff * amount) ** 0.5)
	addtimer(CALLBACK(src, .proc/do_print, D.build_path, amount, efficient_mats, D.dangerous_construction), (32 * timecoeff * amount) ** 0.8)
	return TRUE

/obj/machinery/rnd/production/proc/search(string)
	matching_designs.Cut()
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = stored_research.researched_designs[v]
		if(!(D.build_type & allowed_buildtypes) || !(isnull(allowed_department_flags) || (D.departmental_flags & allowed_department_flags)))
			continue
		if(findtext(D.name,string))
			matching_designs.Add(D)

/obj/machinery/rnd/production/proc/generate_ui()
	var/list/ui = list()
	ui += ui_header()
	switch(screen)
		if(RESEARCH_FABRICATOR_SCREEN_MATERIALS)
			ui += ui_screen_materials()
		if(RESEARCH_FABRICATOR_SCREEN_CHEMICALS)
			ui += ui_screen_chemicals()
		if(RESEARCH_FABRICATOR_SCREEN_SEARCH)
			ui += ui_screen_search()
		if(RESEARCH_FABRICATOR_SCREEN_CATEGORYVIEW)
			ui += ui_screen_category_view()
		else
			ui += ui_screen_main()
	for(var/i in 1 to length(ui))
		if(!findtextEx(ui[i], RDSCREEN_NOBREAK))
			ui[i] += "<br>"
		ui[i] = replacetextEx(ui[i], RDSCREEN_NOBREAK, "")
	return ui.Join("")

/obj/machinery/rnd/production/proc/ui_header()
	var/list/l = list()
	l += "<div class='statusDisplay'><b>[host_research.organization] [department_tag] Department Lathe</b>"
	l += "Security protocols: [(obj_flags & EMAGGED)? "<font color='red'>Disabled</font>" : "<font color='green'>Enabled</font>"]"
	l += "<A href='?src=[REF(src)];switch_screen=[RESEARCH_FABRICATOR_SCREEN_MATERIALS]'><B>Material Amount:</B> [materials.total_amount] / [materials.max_amount]</A>"
	l += "<A href='?src=[REF(src)];switch_screen=[RESEARCH_FABRICATOR_SCREEN_CHEMICALS]'><B>Chemical volume:</B> [reagents.total_volume] / [reagents.maximum_volume]</A>"
	l += "<a href='?src=[REF(src)];sync_research=1'>Synchronize Research</a>"
	l += "<a href='?src=[REF(src)];switch_screen=[RESEARCH_FABRICATOR_SCREEN_MAIN]'>Main Screen</a></div>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/rnd/production/proc/ui_screen_materials()
	var/list/l = list()
	l += "<div class='statusDisplay'><h3>Material Storage:</h3>"
	for(var/mat_id in materials.materials)
		var/datum/material/M = materials.materials[mat_id]
		l += "* [M.amount] of [M.name]: "
		if(M.amount >= MINERAL_MATERIAL_AMOUNT) l += "<A href='?src=[REF(src)];ejectsheet=[M.id];eject_amt=1'>Eject</A> [RDSCREEN_NOBREAK]"
		if(M.amount >= MINERAL_MATERIAL_AMOUNT*5) l += "<A href='?src=[REF(src)];ejectsheet=[M.id];eject_amt=5'>5x</A> [RDSCREEN_NOBREAK]"
		if(M.amount >= MINERAL_MATERIAL_AMOUNT) l += "<A href='?src=[REF(src)];ejectsheet=[M.id];eject_amt=50'>All</A>[RDSCREEN_NOBREAK]"
		l += ""
	l += "</div>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/rnd/production/proc/ui_screen_chemicals()
	var/list/l = list()
	l += "<div class='statusDisplay'><A href='?src=[REF(src)];disposeall=1'>Disposal All Chemicals in Storage</A>"
	l += "<h3>Chemical Storage:</h3>"
	for(var/datum/reagent/R in reagents.reagent_list)
		l += "[R.name]: [R.volume]"
		l += "<A href='?src=[REF(src)];dispose=[R.id]'>Purge</A>"
	l += "</div>"
	return l

/obj/machinery/rnd/production/proc/ui_screen_search()
	var/list/l = list()
	var/coeff = efficiency_coeff
	l += "<h2>Search Results:</h2>"
	l += "<form name='search' action='?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><HR>"
	for(var/datum/design/D in matching_designs)
		l += design_menu_entry(D, coeff)
	l += "</div>"
	return l

/obj/machinery/rnd/production/proc/design_menu_entry(datum/design/D, coeff)
	if(!istype(D))
		return
	if(!coeff)
		coeff = efficiency_coeff
	var/list/l = list()
	var/temp_material
	var/c = 50
	var/t
	var/all_materials = D.materials + D.reagents_list
	for(var/M in all_materials)
		t = check_mat(D, M)
		temp_material += " | "
		if (t < 1)
			temp_material += "<span class='bad'>[all_materials[M]/coeff] [CallMaterialName(M)]</span>"
		else
			temp_material += " [all_materials[M]/coeff] [CallMaterialName(M)]"
		c = min(c,t)

	if (c >= 1)
		l += "<A href='?src=[REF(src)];build=[D.id];amount=1'>[D.name]</A>[RDSCREEN_NOBREAK]"
		if(c >= 5)
			l += "<A href='?src=[REF(src)];build=[D.id];amount=5'>x5</A>[RDSCREEN_NOBREAK]"
		if(c >= 10)
			l += "<A href='?src=[REF(src)];build=[D.id];amount=10'>x10</A>[RDSCREEN_NOBREAK]"
		l += "[temp_material][RDSCREEN_NOBREAK]"
	else
		l += "<span class='linkOff'>[D.name]</span>[temp_material][RDSCREEN_NOBREAK]"
	l += ""
	return l

/obj/machinery/rnd/production/Topic(raw, ls)
	if(..())
		return
	add_fingerprint(usr)
	usr.set_machine(src)
	if(ls["switch_screen"])
		screen = text2num(ls["switch_screen"])
	if(ls["build"]) //Causes the Protolathe to build something.
		if(busy)
			say("Warning: Fabricators busy!")
		else
			user_try_print_id(ls["build"], ls["amount"])
	if(ls["search"]) //Search for designs with name matching pattern
		search(ls["to_search"])
		screen = RESEARCH_FABRICATOR_SCREEN_SEARCH
	if(ls["sync_research"])
		update_research()
		say("Synchronizing research with host technology database.")
	if(ls["category"])
		selected_category = ls["category"]
	if(ls["dispose"])  //Causes the protolathe to dispose of a single reagent (all of it)
		reagents.del_reagent(ls["dispose"])
	if(ls["disposeall"]) //Causes the protolathe to dispose of all it's reagents.
		reagents.clear_reagents()
	if(ls["ejectsheet"]) //Causes the protolathe to eject a sheet of material
		materials.retrieve_sheets(text2num(ls["eject_amt"]), ls["ejectsheet"])
	updateUsrDialog()

/obj/machinery/rnd/production/proc/ui_screen_main()
	var/list/l = list()
	l += "<form name='search' action='?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='hidden' name='type' value='proto'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><HR>"

	l += list_categories(categories, RESEARCH_FABRICATOR_SCREEN_CATEGORYVIEW)

	return l

/obj/machinery/rnd/production/proc/ui_screen_category_view()
	if(!selected_category)
		return ui_screen_main()
	var/list/l = list()
	l += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3>"
	var/coeff = efficiency_coeff
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = stored_research.researched_designs[v]
		if(!(selected_category in D.category)|| !(D.build_type & allowed_buildtypes))
			continue
		if(!(isnull(allowed_department_flags) || (D.departmental_flags & allowed_department_flags)))
			continue
		l += design_menu_entry(D, coeff)
	l += "</div>"
	return l

/obj/machinery/rnd/production/proc/list_categories(list/categories, menu_num)
	if(!categories)
		return

	var/line_length = 1
	var/list/l = "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2)
			l += "</tr><tr>"
			line_length = 1

		l += "<td><A href='?src=[REF(src)];category=[C];switch_screen=[menu_num]'>[C]</A></td>"
		line_length++

	l += "</tr></table></div>"
	return l
