#define FORMAT_DISPENSER_NAME 15

/obj/machinery/chem_dispenser
	name = "\improper Chem Dispenser"
	desc = "It dispenses chemicals."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 40
	slimeadd_message = "You throw the slime into the dispenser's tank"
	slimes_accepted = SLIME_BLACK|SLIME_PYRITE
	slimeadd_success_message = "A new option appears on the dispenser screen"
	var/energy = 0
	var/max_energy = 50
	var/rechargerate = 2
	var/amount = 30
	var/obj/item/weapon/reagent_containers/container = null
	var/beaker_height
	var/recharged = 0
	var/custom = 0
	var/useramount = 30 // Last used amount
	var/required_quirk = MODULE_CAN_HANDLE_CHEMS
	var/template_path = "chem_dispenser.tmpl"
	var/list/slime_reagents = list("black" = DSYRUP, "pyrite" = COLORFUL_REAGENT)
	var/list/dispensable_reagents = list(
		HYDROGEN,
		LITHIUM,
		CARBON,
		NITROGEN,
		OXYGEN,
		FLUORINE,
		SODIUM,
		ALUMINUM,
		SILICON,
		PHOSPHORUS,
		SULFUR,
		CHLORINE,
		POTASSIUM,
		IRON,
		COPPER,
		MERCURY,
		RADIUM,
		WATER,
		ETHANOL,
		SUGAR,
		SACID,
		TUNGSTEN
		)
	var/upgraded = 0
	var/list/upgrade_chems = list(
		PLASMA
		)
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EMAGGABLE
/*
USE THIS CHEMISTRY DISPENSER FOR MAPS SO THEY START AT 100 ENERGY
*/

/obj/machinery/chem_dispenser/mapping
	max_energy = 100
	energy = 100

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/chem_dispenser/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/chem_dispenser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)
	if(Holiday != APRIL_FOOLS_DAY)
		verbs -= /obj/machinery/chem_dispenser/verb/undeploy_dispenser

	RefreshParts()
	if(dispensable_reagents)
		dispensable_reagents = sortList(dispensable_reagents)

/obj/machinery/chem_dispenser/RefreshParts()
	var/R = 0
	var/T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += M.rating-1
		R += M.rating
	max_energy = initial(max_energy)+(T * 50 / 4)

	T = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/Ma in component_parts)
		T += Ma.rating-1
		R += Ma.rating
	rechargerate = initial(rechargerate) + (T / 2)

	for(var/obj/item/weapon/stock_parts/scanning_module/Ml in component_parts) //Now we know what to use the scanning module for
		R += Ml.rating

	if(R >= 28) //Tier 4 parts
		upgraded = 1
	else
		upgraded = 0
	update_chem_list()

/obj/machinery/chem_dispenser/proc/update_chem_list()
	dispensable_reagents.Remove(upgrade_chems) //Reset the list
	if(upgraded)
		dispensable_reagents.Add(upgrade_chems)

/obj/machinery/chem_dispenser/proc/recharge()
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		return
	var/oldenergy = energy
	energy = min(energy + rechargerate, max_energy)
	if(energy != oldenergy)
		use_power(3000) // This thing uses up alot of power (this is still low as shit for creating reagents from thin air)
		nanomanager.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
	nanomanager.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/emag_act()
	..()
	dispensable_reagents = shuffle(dispensable_reagents)

/obj/machinery/chem_dispenser/proc/can_use(var/mob/living/silicon/robot/R)
	if(!R)
		return FALSE

	if(HAS_MODULE_QUIRK(R, required_quirk))
		return TRUE

	to_chat(R, "Your programming forbids interaction with this device.")
	return FALSE

/obj/machinery/chem_dispenser/process()
	if(recharged < 0)
		recharge()
		recharged = 15
	else
		recharged -= 1

/obj/machinery/chem_dispenser/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is placing \his mouth under the nozzles of the [src] and filling it with a lethal mixture! It looks like \he's trying to commit suicide.</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 80, 1)
	var/list/reagents_to_add = list(PACID, SACID, MINDBREAKER, IMPEDREZENE, LUBE)
	if(prob(10))
		user.reagents.add_reagent(pick(reagents_to_add),25)
	if(prob(10)) //smoke
		user.reagents.add_reagent(SUGAR,5)
		user.reagents.add_reagent(POTASSIUM,5)
		user.reagents.add_reagent(PHOSPHORUS,5)
	if(prob(10)) //boom
		user.reagents.add_reagent(POTASSIUM,50)
		user.reagents.add_reagent(WATER,50)
	if(prob(10)) //emp
		user.reagents.add_reagent(IRON,25)
		user.reagents.add_reagent(URANIUM,25)
	if(prob(10)) //fire
		user.reagents.add_reagent(ALUMINUM,5)
		user.reagents.add_reagent(PLASMA,5)
		user.reagents.add_reagent(SACID,5)
	if(prob(10)) //flash
		user.reagents.add_reagent(ALUMINUM,5)
		user.reagents.add_reagent(POTASSIUM,5)
		user.reagents.add_reagent(SULFUR,5)
	return(SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_TOXLOSS|SUICIDE_ACT_OXYLOSS|SUICIDE_ACT_FIRELOSS)

/obj/machinery/chem_dispenser/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return

/obj/machinery/chem_dispenser/blob_act()
	if (prob(50))
		qdel(src)

 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  * @param ui /datum/nanoui This parameter is passed by the nanoui process() proc when updating an open ui
  *
  * @return nothing
  */
/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if(stat & (BROKEN|NOPOWER|FORCEDISABLE))
		return
	if((user.stat && !isobserver(user)) || user.restrained())
		return
	if(!chemical_reagents_list || !chemical_reagents_list.len)
		return
	// this is the data which will be sent to the ui
	var/data[0]
	data["amount"] = amount
	data["energy"] = energy
	data["maxEnergy"] = max_energy
	data["isBeakerLoaded"] = container ? 1 : 0
	data["custom"] = custom

	var containerContents[0]
	var containerCurrentVolume = 0
	if(container && container.reagents && container.reagents.reagent_list.len)
		for(var/datum/reagent/R in container.reagents.reagent_list)
			var/reg_name = R.name
			if (istype(R,/datum/reagent/vaccine))
				var/datum/reagent/vaccine/vaccine = R
				var/vaccines = ""
				for (var/A in vaccine.data["antigen"])
					vaccines += "[A]"
				if (vaccines == "")
					vaccines = "blank"
				reg_name = "[reg_name] ([vaccines])"
			containerContents.Add(list(list("name" = reg_name, "volume" = R.volume))) // list in a list because Byond merges the first list...
			containerCurrentVolume += R.volume
	data["beakerContents"] = containerContents

	if (container)
		data["beakerCurrentVolume"] = containerCurrentVolume
		data["beakerMaxVolume"] = container.volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	var chemicals[0]
	for (var/re in dispensable_reagents)
		var/datum/reagent/temp = chemical_reagents_list[re]
		if(temp) //formats name because Space Mountain Wind and theoretically others in the future are too long
			chemicals.Add(list(list("title" = copytext(temp.name,1,FORMAT_DISPENSER_NAME), "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals
	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, template_path, "[src.name]", 390, 630)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/chem_dispenser/Topic(href, href_list)
	if(..())
		return
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return 0 // don't update UIs attached to this object

	if(href_list["amount"])
		if(href_list["amount"] == "0")
			var/num = input("Enter desired output amount", "Amount", useramount) as num
			if (num)
				amount = round(text2num(num), 1)
				custom = 1
		else
			custom = 0
			amount = round(text2num(href_list["amount"]), 1)
		amount = clamp(amount, 1, container ? container.volume : 100)
		if (custom)
			useramount = amount

	if(href_list["dispense"])
		dispense_reagent(href_list["dispense"], amount)

	if(href_list["ejectBeaker"])
		if(container)
			detach()

	add_fingerprint(usr)
	return 1 // update UIs attached to this object

/obj/machinery/chem_dispenser/proc/dispense_reagent(reagent, amount)
	if (dispensable_reagents.Find(reagent) && container != null)
		var/obj/item/weapon/reagent_containers/B = src.container
		var/datum/reagents/R = B.reagents
		if(!R)
			if(!B.gcDestroyed)
				B.create_reagents(B.volume)
			else
				QDEL_NULL(B)
				return
		var/space = R.maximum_volume - R.total_volume
		var/reagent_temperature = dispensable_reagents[reagent] ? dispensable_reagents[reagent] : T0C+20
		R.add_reagent(reagent, min(amount, energy * 10, space), reagtemp = reagent_temperature)
		energy = max(energy - min(amount, energy * 10, space) / 10, 0)

/obj/machinery/chem_dispenser/kick_act(mob/living/H)
	..()
	if(container)
		detach()

/obj/machinery/chem_dispenser/proc/detach()
	if(container)
		var/obj/item/weapon/reagent_containers/B = container
		B.forceMove(loc)
		container = null
		update_icon()
		return 1

/obj/machinery/chem_dispenser/AltClick()
	if(!usr.incapacitated() && Adjacent(usr) && container && !(stat & (FORCEDISABLE|NOPOWER|BROKEN) && usr.dexterity_check()))
		detach()
		return
	return ..()

/obj/machinery/chem_dispenser/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(container)
		to_chat(user, "You can't reach the maintenance panel with \a [container] in the way!")
		return
	return ..()

/obj/machinery/chem_dispenser/proc/can_insert(var/obj/item/I)
	return istype(I, /obj/item/weapon/reagent_containers/glass) || istype(I, /obj/item/weapon/reagent_containers/food/drinks)

/obj/machinery/chem_dispenser/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if(can_insert(AM))
		if(src.container)
			return FALSE
		if(istype(AM,/obj/item))
			var/obj/item/I = AM
			if(I.w_class > W_CLASS_SMALL)
				return FALSE
		else if(!panel_open)
			AM.forceMove(src)

			container =  AM
			AM.pixel_x = x_coord_to_nozzle(16) // put in the middle for now
			update_icon()

			nanomanager.update_uis(src) // update all UIs attached to src
			return TRUE
		else
			return FALSE
	return FALSE

/obj/machinery/chem_dispenser/splashable()
	return FALSE

/obj/machinery/chem_dispenser/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob, params) //to be worked on
	if(..())
		return 1

	if(isrobot(user))
		if(!can_use(user))
			return

	if(can_insert(D))
		if(src.container)
			to_chat(user, "\A [src.container] is already loaded into the machine.")
			return
		if(D.w_class > W_CLASS_SMALL)
			to_chat(user, "<span class='warning'>\The [D] is too big to fit.</span>")
			return
		else if(!panel_open)
			if(!user.drop_item(D, src, failmsg = TRUE))
				return

			container =  D
			D.pixel_x = x_coord_to_nozzle(text2num(params2list(params)["icon-x"]) * PIXEL_MULTIPLIER)
			to_chat(user, "You add \the [D] to the machine!")
			update_icon()

			nanomanager.update_uis(src) // update all UIs attached to src
			return 1
		else
			to_chat(user, "You can't add \a [D] to the machine while the panel is open.")
			return

/obj/machinery/chem_dispenser/slime_act(primarytype, mob/user)
	. = ..()
	if(. && (slimes_accepted & primarytype))
		switch(primarytype)
			if(SLIME_BLACK)
				dispensable_reagents.Add(slime_reagents["black"])
			if(SLIME_PYRITE)
				dispensable_reagents.Add(slime_reagents["pyrite"])

/obj/machinery/chem_dispenser/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return

	if(isrobot(user))
		if(!can_use(user))
			return

	ui_interact(user)

/obj/machinery/chem_dispenser/update_icon()

	overlays.len = 0

	if(container)

		var/image/overlay

		if(istype(container, /obj/item/weapon/reagent_containers/glass/beaker/bluespace) || istype(container, /obj/item/weapon/reagent_containers/glass/beaker/noreact))
			overlay = image('icons/obj/chemical.dmi', src, "dispenser_overlay_bluesp")
		else if(istype(container, /obj/item/weapon/reagent_containers/food/drinks/soda_cans))
			overlay = image('icons/obj/chemical.dmi', src, "dispenser_overlay_soda")
		else
			overlay = image('icons/obj/chemical.dmi', src, "dispenser_overlay_glassb")

		overlay.pixel_y = beaker_height * PIXEL_MULTIPLIER //used for children
		if(container.pixel_x)
			overlay.pixel_x = container.pixel_x
		else
			overlay.pixel_x = pick(-7,-3, 1, 5, 8) * PIXEL_MULTIPLIER //puts the beaker under a random nozzle
		overlays += overlay

//Returns the pixel_x that our beaker overlay should have to match up with where the user clicked.
/obj/machinery/chem_dispenser/proc/x_coord_to_nozzle(x_coord)
	switch(x_coord)
		if(0 to 10)
			return -7
		if(11 to 14)
			return -3
		if(15 to 18)
			return 1
		if(19 to 21)
			return 5
		if(22 to INFINITY)
			return 8
	return 0

//Cafe stuff

/obj/machinery/chem_dispenser/brewer/
	name = "Space-Brewery"
	icon_state = "brewer"
	pass_flags = PASSTABLE
	required_quirk = MODULE_CAN_HANDLE_FOOD
	slime_reagents = list("black" = BLOOD, "pyrite" = BANANA)
	dispensable_reagents = list(
		TEA = COOKTEMP_READY,
		GREENTEA = COOKTEMP_READY,
		REDTEA = COOKTEMP_READY,
		COFFEE = COOKTEMP_READY,
		MILK = COOKTEMP_READY,
		CREAM = COOKTEMP_READY,
		WATER = COOKTEMP_READY,
		HOT_COCO = COOKTEMP_READY,
		SOYMILK = COOKTEMP_READY
		)//everything is HOT out of here

/obj/machinery/chem_dispenser/brewer/New()
	. = ..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/chem_dispenser/brewer,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)
	RefreshParts()

/obj/machinery/chem_dispenser/brewer/update_chem_list()
	return

/obj/machinery/chem_dispenser/brewer/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is placing \his mouth under the nozzles of the [src] and filling it! It looks like \he's trying to commit suicide.</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 80, 1)
	return(SUICIDE_ACT_FIRELOSS|SUICIDE_ACT_TOXLOSS)

/obj/machinery/chem_dispenser/brewer/mapping
	max_energy = 100
	energy = 100

//Soda/booze dispensers.

/obj/machinery/chem_dispenser/soda_dispenser/
	name = "Soda Dispenser"
	icon_state = "soda_dispenser"
	pass_flags = PASSTABLE
	beaker_height = -5
	required_quirk = MODULE_CAN_HANDLE_FOOD
	slime_reagents = list("black" = TRICORDRAZINE, "pyrite" = BANANA)
	dispensable_reagents = list(SPACEMOUNTAINWIND, SODAWATER, LEMON_LIME, DR_GIBB, COLA, ICE = T0C, TONIC)

/obj/machinery/chem_dispenser/soda_dispenser/New()
	. = ..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/chem_dispenser/soda_dispenser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)
	RefreshParts()

/obj/machinery/chem_dispenser/soda_dispenser/update_chem_list()
	return

/obj/machinery/chem_dispenser/soda_dispenser/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is placing \his mouth under the nozzles of the [src] and filling it! It looks like \he's trying to commit suicide.</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 80, 1)
	return(SUICIDE_ACT_TOXLOSS)

/obj/machinery/chem_dispenser/soda_dispenser/mapping
	max_energy = 100
	energy = 100

/obj/machinery/chem_dispenser/booze_dispenser/
	name = "Booze Dispenser"
	icon_state = "booze_dispenser"
	pass_flags = PASSTABLE
	beaker_height = -6
	required_quirk = MODULE_CAN_HANDLE_FOOD
	slime_reagents = list("black" = TRICORDRAZINE, "pyrite" = BANANA)
	dispensable_reagents = list(
		BEER,
		WHISKEY,
		TEQUILA,
		VODKA,
		VERMOUTH,
		RUM,
		COGNAC,
		WINE,
		SAKE,
		TRIPLESEC,
		BITTERS,
		CINNAMONWHISKY,
		SCHNAPPS,
		BLUECURACAO,
		KAHLUA,
		ALE,
		ICE = (T0C-20),
		WATER,
		GIN,
		SODAWATER,
		COLA,
		CREAM,
		TOMATOJUICE,
		ORANGEJUICE,
		LIMEJUICE,
		TONIC
		)

/obj/machinery/chem_dispenser/booze_dispenser/New()
	. = ..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/chem_dispenser/booze_dispenser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)
	RefreshParts()

/obj/machinery/chem_dispenser/booze_dispenser/update_chem_list()
	if(!upgraded)
		dispensable_reagents = list(BEER,WHISKEY,TEQUILA,VODKA,VERMOUTH,RUM,COGNAC,WINE,SAKE,TRIPLESEC,BITTERS,CINNAMONWHISKY,SCHNAPPS,
									BLUECURACAO,KAHLUA,ALE,ICE = T0C,WATER,GIN,SODAWATER,COLA,CREAM,TOMATOJUICE,ORANGEJUICE,LIMEJUICE,TONIC)
	else
		dispensable_reagents = list(BEER,WHISKEY,TEQUILA,VODKA,VERMOUTH,RUM,COGNAC,WINE,SAKE,TRIPLESEC,BITTERS,CINNAMONWHISKY,SCHNAPPS,
									BLUECURACAO,KAHLUA,ALE,ICE = T0C,WATER,GIN,SODAWATER,COLA,CREAM,TOMATOJUICE,ORANGEJUICE,LIMEJUICE,TONIC,
									KARMOTRINE)


/obj/machinery/chem_dispenser/booze_dispenser/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is placing \his mouth under the nozzles of the [src] and drowning his sorrows! It looks like \he's trying to commit suicide.</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 80, 1)
	return(SUICIDE_ACT_TOXLOSS)

/obj/machinery/chem_dispenser/booze_dispenser/mapping
	max_energy = 100
	energy = 100

/obj/machinery/chem_dispenser/condiment
	name = "\improper Condiment Dispenser"
	desc = "A dispenser designed to output condiments directly onto food, or into condiment bottles. These were banned for being 'unhygienic' after one too many licking incidents."
	icon_state = "condi_dispenser"
	pass_flags = PASSTABLE
	max_energy = 30
	required_quirk = MODULE_CAN_HANDLE_FOOD
	template_path = "condi_dispenser.tmpl"
	dispensable_reagents = list(
		SODIUMCHLORIDE,
		BLACKPEPPER,
		KETCHUP,
		MUSTARD,
		RELISH,
		CAPSAICIN,
		FROSTOIL,
		LIQUIDBUTTER,
		SOYSAUCE,
		SPRINKLES
		)
	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK

/obj/machinery/chem_dispenser/condiment/update_chem_list()
	return

/obj/machinery/chem_dispenser/condiment/can_insert(obj/item/I)
	return istype(I,/obj/item/weapon/reagent_containers/food/snacks) || istype(I,/obj/item/weapon/reagent_containers/food/condiment)

/obj/machinery/chem_dispenser/condiment/update_icon()
	return //no overlays for this one, it takes special inputs

/obj/machinery/chem_dispenser/condiment/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is placing \his mouth under the nozzles of the [src] and filling it! It looks like \he's trying to commit suicide.</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 80, 1)
	return(SUICIDE_ACT_TOXLOSS)

#undef FORMAT_DISPENSER_NAME

/obj/machinery/chem_dispenser/npc_tamper_act(mob/living/L)
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN))
		return 0

	var/amount = rand(1,25)
	var/reagent = pick(dispensable_reagents)
	message_admins("[key_name(L)] has dispensed [reagent] ([amount]u)! [formatJumpTo(src)]")

	dispense_reagent(reagent, amount)

/obj/machinery/chem_dispenser/verb/undeploy_dispenser()
	set category = "Object"
	set name = "Undeploy dispenser"
	set src in view(1)
	if(usr.incapacitated())
		to_chat(usr, "<span class='notice'>You cannot do this while incapacitated.</span>")
		return
	if(!usr.dexterity_check())
		to_chat(usr, "<span class='notice'>You are not capable of such fine manipulation.</span>")
		return
	move_that_gear_up()
	
