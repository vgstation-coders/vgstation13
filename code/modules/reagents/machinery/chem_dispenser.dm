#define FORMAT_DISPENSER_NAME 15

/obj/machinery/chem_dispenser
	name = "\improper Chem Dispenser"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = 1
	idle_power_usage = 40
	var/energy = 0
	var/max_energy = 50
	var/rechargerate = 2
	var/amount = 30
	var/obj/item/weapon/reagent_containers/container = null
	var/recharged = 0
	var/custom = 0
	var/useramount = 30 // Last used amount
	var/list/dispensable_reagents = list(HYDROGEN,LITHIUM,CARBON,NITROGEN,OXYGEN,FLUORINE,
	SODIUM,ALUMINUM,SILICON,PHOSPHORUS,SULFUR,CHLORINE,POTASSIUM,IRON,
	COPPER,MERCURY,RADIUM,WATER,ETHANOL,SUGAR,SACID,TUNGSTEN)

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	var/targetMoveKey = null //To prevent borgs from leaving without their beakers.


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

	RefreshParts()
	if(dispensable_reagents)
		dispensable_reagents = sortList(dispensable_reagents)

/obj/machinery/chem_dispenser/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += M.rating-1
	max_energy = initial(max_energy)+(T * 50 / 4)

	T = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/Ma in component_parts)
		T += Ma.rating-1
	rechargerate = initial(rechargerate) + (T / 2)

/*
	for(var/obj/item/weapon/stock_parts/scanning_module/Ml in component_parts)
		T += Ml.rating
	//Who even knows what to use the scanning module for
*/

/obj/machinery/chem_dispenser/proc/user_moved(var/list/args)
	var/event/E = args["event"]
	if(!targetMoveKey)
		E.handlers.Remove("\ref[src]:user_moved")
		return

	var/turf/T = args["loc"]

	if(!Adjacent(T))
		if(E.holder)
			var/atom/movable/holder = E.holder
			holder.on_moved.Remove(targetMoveKey)
		detach()

/obj/machinery/chem_dispenser/proc/recharge()
	if(stat & (BROKEN|NOPOWER))
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

/obj/machinery/chem_dispenser/proc/can_use(var/mob/living/silicon/robot/R)
	if(!isMoMMI(R) && !istype(R.module,/obj/item/weapon/robot_module/medical)) //default chem dispenser can only be used by MoMMIs and Mediborgs
		return 0
	else
		if(!isMoMMI(R))
			targetMoveKey =  R.on_moved.Add(src, "user_moved")
		return 1

/obj/machinery/chem_dispenser/process()
	if(recharged < 0)
		recharge()
		recharged = 15
	else
		recharged -= 1

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
/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(stat & (BROKEN|NOPOWER))
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
			containerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
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
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "chem_dispenser.tmpl", "[src.name] 5000", 390, 630)
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
	if(stat & (NOPOWER|BROKEN))
		return 0 // don't update UIs attached to this object

	if(href_list["amount"])
		if(href_list["amount"] == "0")
			var/num = input("Enter desired output amount", "Amount", useramount) as num
			if (num)
				amount = round(text2num(num), 5)
				custom = 1
		else
			custom = 0
			amount = round(text2num(href_list["amount"]), 5) // round to nearest 5
		amount = Clamp(amount, 5, 100) // Since the user can actually type the commands himself, some sanity checking
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
				qdel(B)
				B = null
				return
		var/space = R.maximum_volume - R.total_volume

		R.add_reagent(reagent, min(amount, energy * 10, space))
		energy = max(energy - min(amount, energy * 10, space) / 10, 0)

/obj/machinery/chem_dispenser/kick_act(mob/living/H)
	..()
	if(container)
		detach()

/obj/machinery/chem_dispenser/proc/detach()
	targetMoveKey=null

	if(container)
		var/obj/item/weapon/reagent_containers/B = container
		B.forceMove(loc)
		if(istype(container, /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg))
			var/obj/item/weapon/reagent_containers/glass/beaker/large/cyborg/borgbeak = container
			borgbeak.return_to_modules()
		container = null
		return 1

/obj/machinery/chem_dispenser/AltClick()
	if(!usr.incapacitated() && Adjacent(usr) && container && !(stat & (NOPOWER|BROKEN) && usr.dexterity_check()))
		detach()
		return
	return ..()

/obj/machinery/chem_dispenser/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(container)
		to_chat(user, "You can't reach the maintenance panel with \a [container] in the way!")
		return
	return ..()

/obj/machinery/chem_dispenser/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob) //to be worked on

	if(..())
		return 1

	if(isrobot(user))
		if(!can_use(user))
			return

	if(istype(D, /obj/item/weapon/reagent_containers/glass) || istype(D, /obj/item/weapon/reagent_containers/food/drinks))
		if(src.container)
			to_chat(user, "\A [src.container] is already loaded into the machine.")
			return
		if(D.w_class > W_CLASS_SMALL)
			to_chat(user, "<span class='warning'>\The [D] is too big to fit.</span>")
			return
		else if(!panel_open)
			if(!user.drop_item(D, src))
				to_chat(user, "<span class='warning'>You can't let go of \the [D]!</span>")
				return

			src.container =  D
			if(user.type == /mob/living/silicon/robot)
				var/mob/living/silicon/robot/R = user
				R.uneq_active()

			to_chat(user, "You add \the [D] to the machine!")

			nanomanager.update_uis(src) // update all UIs attached to src
			return 1
		else
			to_chat(user, "You can't add \a [D] to the machine while the panel is open.")
			return

/obj/machinery/chem_dispenser/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return

	ui_interact(user)
//Cafe stuff

/obj/machinery/chem_dispenser/brewer/
	name = "Space-Brewery"
	icon_state = "brewer"
	dispensable_reagents = list(TEA,GREENTEA,REDTEA, COFFEE,MILK,CREAM,WATER,HOT_COCO, SOYMILK)
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

/obj/machinery/chem_dispenser/brewer/mapping
	max_energy = 100
	energy = 100

/obj/machinery/chem_dispenser/brewer/can_use(var/mob/living/silicon/robot/R)
	if(!isMoMMI(R) && istype(R.module,/obj/item/weapon/robot_module/butler)) //bartending dispensers can be used only by service borgs
		targetMoveKey =  R.on_moved.Add(src, "user_moved")
		return 1
	else
		return 0

//Soda/booze dispensers.

/obj/machinery/chem_dispenser/soda_dispenser/
	name = "Soda Dispenser"
	icon_state = "soda_dispenser"
	dispensable_reagents = list(SPACEMOUNTAINWIND, SODAWATER, LEMON_LIME, DR_GIBB, COLA, ICE, TONIC)
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

/obj/machinery/chem_dispenser/soda_dispenser/mapping
	max_energy = 100
	energy = 100

/obj/machinery/chem_dispenser/soda_dispenser/can_use(var/mob/living/silicon/robot/R)
	if(!isMoMMI(R) && istype(R.module,/obj/item/weapon/robot_module/butler)) //bartending dispensers can be used only by service borgs
		targetMoveKey =  R.on_moved.Add(src, "user_moved")
		return 1
	else
		return 0

/obj/machinery/chem_dispenser/booze_dispenser/
	name = "Booze Dispenser"
	icon_state = "booze_dispenser"
	dispensable_reagents = list(BEER, WHISKEY, TEQUILA, VODKA, VERMOUTH, RUM, COGNAC, WINE, KAHLUA, ALE, ICE, WATER, GIN, SODAWATER, COLA, CREAM,TOMATOJUICE,ORANGEJUICE,LIMEJUICE,TONIC)
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

/obj/machinery/chem_dispenser/booze_dispenser/mapping
	max_energy = 100
	energy = 100

/obj/machinery/chem_dispenser/booze_dispenser/can_use(var/mob/living/silicon/robot/R)
	if(!isMoMMI(R) && istype(R.module,/obj/item/weapon/robot_module/butler)) //bartending dispensers can be used only by service borgs
		targetMoveKey =  R.on_moved.Add(src, "user_moved")
		return 1
	else
		return 0

#undef FORMAT_DISPENSER_NAME

/obj/machinery/chem_dispenser/npc_tamper_act(mob/living/L)
	if(stat & (NOPOWER|BROKEN))
		return 0

	var/amount = rand(1,25)
	var/reagent = pick(dispensable_reagents)
	message_admins("[key_name(L)] has dispensed [reagent] ([amount]u)! [formatJumpTo(src)]")

	dispense_reagent(reagent, amount)
