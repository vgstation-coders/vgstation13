#define LIMBGROWER_MAIN_MENU       1
#define LIMBGROWER_CATEGORY_MENU   2
#define LIMBGROWER_CHEMICAL_MENU   3
//use these for the menu system


/obj/machinery/limbgrower
	name = "limb grower"
	desc = "It grows new limbs using Synthflesh."
	icon = 'icons/obj/machines/limbgrower.dmi'
	icon_state = "limbgrower_idleoff"
	density = TRUE
	container_type = OPENCONTAINER
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/limbgrower

	var/operating = FALSE
	var/disabled = FALSE
	var/busy = FALSE
	var/prod_coeff = 1
	var/datum/design/being_built
	var/datum/techweb/stored_research
	var/selected_category
	var/screen = 1
	var/list/categories = list(
							"human",
							"lizard",
							"plasmaman",
							"other"
							)

/obj/machinery/limbgrower/Initialize()
	create_reagents(100)
	stored_research = new /datum/techweb/specialized/autounlocking/limbgrower
	. = ..()

/obj/machinery/limbgrower/ui_interact(mob/user)
	. = ..()
	if(!is_operational())
		return

	var/dat = main_win(user)

	switch(screen)
		if(LIMBGROWER_MAIN_MENU)
			dat = main_win(user)
		if(LIMBGROWER_CATEGORY_MENU)
			dat = category_win(user,selected_category)
		if(LIMBGROWER_CHEMICAL_MENU)
			dat = chemical_win(user)

	var/datum/browser/popup = new(user, "Limb Grower", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/limbgrower/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	..()

/obj/machinery/limbgrower/attackby(obj/item/O, mob/user, params)
	if (busy)
		to_chat(user, "<span class=\"alert\">The Limb Grower is busy. Please wait for completion of previous operation.</span>")
		return

	if(default_deconstruction_screwdriver(user, "limbgrower_panelopen", "limbgrower_idleoff", O))
		updateUsrDialog()
		return

	if(exchange_parts(user, O))
		return

	if(panel_open && default_deconstruction_crowbar(O))
		return

	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

/obj/machinery/limbgrower/Topic(href, href_list)
	if(..())
		return
	if (!busy)
		if(href_list["menu"])
			screen = text2num(href_list["menu"])

		if(href_list["category"])
			selected_category = href_list["category"]

		if(href_list["disposeI"])  //Get rid of a reagent incase you add the wrong one by mistake
			reagents.del_reagent(href_list["disposeI"])

		if(href_list["make"])

			/////////////////
			//href protection
			being_built = stored_research.isDesignResearchedID(href_list["make"]) //check if it's a valid design
			if(!being_built)
				return


			var/synth_cost = being_built.reagents_list["synthflesh"]*prod_coeff
			var/power = max(2000, synth_cost/5)

			if(reagents.has_reagent("synthflesh", being_built.reagents_list["synthflesh"]*prod_coeff))
				busy = TRUE
				use_power(power)
				flick("limbgrower_fill",src)
				icon_state = "limbgrower_idleon"
				addtimer(CALLBACK(src, .proc/build_item),32*prod_coeff)

	else
		to_chat(usr, "<span class=\"alert\">The limb grower is busy. Please wait for completion of previous operation.</span>")

	updateUsrDialog()
	return

/obj/machinery/limbgrower/proc/build_item()
	if(reagents.has_reagent("synthflesh", being_built.reagents_list["synthflesh"]*prod_coeff))	//sanity check, if this happens we are in big trouble
		reagents.remove_reagent("synthflesh",being_built.reagents_list["synthflesh"]*prod_coeff)
		var/buildpath = being_built.build_path
		if(ispath(buildpath, /obj/item/bodypart))	//This feels like spatgheti code, but i need to initilise a limb somehow
			build_limb(buildpath)
		else
			//Just build whatever it is
			new buildpath(loc)
	else
		src.visible_message("<span class=\"error\"> Something went very wrong and there isnt enough synthflesh anymore!</span>")
	busy = FALSE
	flick("limbgrower_unfill",src)
	icon_state = "limbgrower_idleoff"
	updateUsrDialog()

/obj/machinery/limbgrower/proc/build_limb(buildpath)
	//i need to create a body part manually using a set icon (otherwise it doesnt appear)
	var/obj/item/bodypart/limb
	limb = new buildpath(loc)
	if(selected_category=="human" || selected_category=="lizard") // Doing this because plasmamen have their limbs in a different icon file
		limb.icon = 'icons/mob/human_parts_greyscale.dmi'
	else
		limb.icon = 'icons/mob/human_parts.dmi'
	// Set this limb up using the specias name and body zone
	limb.icon_state = "[selected_category]_[limb.body_zone]"
	limb.name = "Synthetic [selected_category] [parse_zone(limb.body_zone)]"
	limb.desc = "A synthetic [selected_category] limb that will morph on its first use in surgery. This one is for the [parse_zone(limb.body_zone)]"
	limb.species_id = selected_category
	limb.should_draw_greyscale = TRUE
	limb.update_icon_dropped()

/obj/machinery/limbgrower/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)
	var/T=1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T -= M.rating*0.2
	prod_coeff = min(1,max(0,T)) // Coeff going 1 -> 0,8 -> 0,6 -> 0,4

/obj/machinery/limbgrower/proc/main_win(mob/user)
	var/dat = "<div class='statusDisplay'><h3>Limb Grower Menu:</h3><br>"
	dat += "<A href='?src=[REF(src)];menu=[LIMBGROWER_CHEMICAL_MENU]'>Chemical Storage</A>"
	dat += materials_printout()
	dat += "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		dat += "<td><A href='?src=[REF(src)];category=[C];menu=[LIMBGROWER_CATEGORY_MENU]'>[C]</A></td>"
		dat += "</tr><tr>"
		//one category per line

	dat += "</tr></table></div>"
	return dat

/obj/machinery/limbgrower/proc/category_win(mob/user,selected_category)
	var/dat = "<A href='?src=[REF(src)];menu=[LIMBGROWER_MAIN_MENU]'>Return to main menu</A>"
	dat += "<div class='statusDisplay'><h3>Browsing [selected_category]:</h3><br>"
	dat += materials_printout()

	for(var/v in stored_research.researched_designs)
		var/datum/design/D = stored_research.researched_designs[v]
		if(!(selected_category in D.category))
			continue
		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='?src=[REF(src)];make=[D.id];multiplier=1'>[D.name]</a>"
		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	return dat


/obj/machinery/limbgrower/proc/chemical_win(mob/user)
	var/dat = "<A href='?src=[REF(src)];menu=[LIMBGROWER_MAIN_MENU]'>Return to main menu</A>"
	dat += "<div class='statusDisplay'><h3>Browsing Chemical Storage:</h3><br>"
	dat += materials_printout()

	for(var/datum/reagent/R in reagents.reagent_list)
		dat += "[R.name]: [R.volume]"
		dat += "<A href='?src=[REF(src)];disposeI=[R.id]'>Purge</A><BR>"

	dat += "</div>"
	return dat

/obj/machinery/limbgrower/proc/materials_printout()
	var/dat = "<b>Total amount:></b> [reagents.total_volume] / [reagents.maximum_volume] cm<sup>3</sup><br>"
	return dat

/obj/machinery/limbgrower/proc/can_build(datum/design/D)
	return (reagents.has_reagent("synthflesh", D.reagents_list["synthflesh"]*prod_coeff)) //Return whether the machine has enough synthflesh to produce the design

/obj/machinery/limbgrower/proc/get_design_cost(datum/design/D)
	var/dat
	if(D.reagents_list["synthflesh"])
		dat += "[D.reagents_list["synthflesh"] * prod_coeff] Synthetic flesh "
	return dat

/obj/machinery/limbgrower/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	for(var/id in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_designs[id]
		if((D.build_type & LIMBGROWER) && ("emagged" in D.category))
			stored_research.add_design(D)
	to_chat(user, "<span class='warning'>A warning flashes onto the screen, stating that safety overrides have been deactivated!</span>")
	obj_flags |= EMAGGED
