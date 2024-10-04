#define CAN_AUTOMAKE_SOMETHING (auto_make_on_detect && scanning_power >= 2 && select_recipe(available_recipes,src))

/obj/machinery/microwave
	name = "Microwave"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	density = 1
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 5
	active_power_usage = 500
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | EJECTNOTDEL | EMAGGABLE | MULTIOUTPUT
	flags = OPENCONTAINER | NOREACT
	pass_flags = PASSTABLE
	log_reagents = 0 //transferred 5u of flour from a flour sack [0x20107e8] to Microwave [0x2007fdd]. transferred 5u of flour from a flour sack [0x20107e8] to Microwave [0x2007fdd]. transferred 5u of flour from a flour sack [0x20107e8] to Microwave [0x2007fdd].
	slimeadd_message = "You place the slime extract into the cooking mechanisms"
	slimes_accepted = SLIME_SILVER
	slimeadd_success_message = "It gives off a distinct shine as a result"
	var/operating = 0 // Is it on?
	var/opened = 0.0
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???
	var/reagent_disposal = 1 //Does it empty out reagents when you eject? Default yes.
	var/auto_make_on_detect = 0 //Default no, scan level >=2 only
	var/global/list/datum/recipe/available_recipes // List of the recipes you can use
	var/global/list/acceptable_items = list(
							/obj/item/weapon/kitchen/utensil,/obj/item/device/pda,/obj/item/device/paicard,
							/obj/item/weapon/cell,/obj/item/weapon/circuitboard,/obj/item/device/aicard
							)// List of the items you can put in
	var/global/list/acceptable_reagents // List of the reagents you can put in
	var/limit = 100
	var/speed_multiplier = 1
	var/scanning_power = 0
	var/global/list/accepts_reagents_from = list(/obj/item/weapon/reagent_containers/glass,
												/obj/item/weapon/reagent_containers/food/drinks,
												/obj/item/weapon/reagent_containers/food/condiment,
												/obj/item/weapon/reagent_containers/dropper)


	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag,
	)

	component_parts = newlist(\
		/obj/item/weapon/circuitboard/microwave,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/scanning_module,\
		/obj/item/weapon/stock_parts/console_screen\
	)

// see code/modules/food/recipes_microwave.dm for recipes
//Cannot use tools - screwdriver and crowbar for recipes. Or at least fix things before you do
//TODO - Get a maint panel sprite and J-J-Jam it in.
//Biiiig Thanks to Kaze_Espada, SuperSayu, Jordie, MrPerson, and HUUUUGE thank you to Arancalos from #coderbus for patiently helping for hours, and practically doing it themselves, to get the microwaves to not have their stock parts as ingredients upon construction. May they enjoy their hard earned plunder.
//HUUUUUUUGE thanks to D3athrow for getting it to the finish line
/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/*******************
*   Initialising
********************/

/obj/machinery/microwave/New()
	. = ..()

	RefreshParts()
	create_reagents(100)

	if (!available_recipes)
		available_recipes = generate_available_recipes(flags = COOKABLE_WITH_MICROWAVE | COOKABLE_WITH_MIXING) //Allow things like salads to be made in a microwave while mixing bowls are unimplemented.
		acceptable_reagents = new
		for (var/datum/recipe/recipe in available_recipes)
			for (var/item in recipe.items)
				acceptable_items |= item
			for (var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
		sortTim(available_recipes, /proc/cmp_microwave_recipe_dsc)

	if(ticker)
		initialize()

/*******************
*   Part Upgrades
********************/
/obj/machinery/microwave/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		T += M.rating-1
	speed_multiplier = initial(speed_multiplier)+(T * 0.5)

	T = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/M in component_parts)
		T += M.rating-1
	scanning_power = initial(scanning_power)+(T)

/*******************
*   Item Adding
********************/

/obj/machinery/microwave/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if(contents.len >= limit)
		return FALSE
	else if(istype(AM, /obj/item/weapon/storage/bag/plants))
		var/obj/item/weapon/storage/bag/B = AM
		for (var/obj/item/weapon/reagent_containers/food/snacks/G in AM.contents)
			B.remove_from_storage(G,src)
			if(CAN_AUTOMAKE_SOMETHING)
				cook()
				break
			if(contents.len >= limit) //Sanity checking so the microwave doesn't overfill
				break
	else if(is_type_in_list(AM,acceptable_items))
		if (istype(AM,/obj/item/stack))
			var/obj/item/stack/ST = AM
			if(ST.amount > 1)
				new ST.type (src,amount=1)
				ST.use(1)
				if(CAN_AUTOMAKE_SOMETHING)
					cook()
		else
			AM.forceMove(src)
			if(CAN_AUTOMAKE_SOMETHING)
				cook()
	else
		return FALSE
	src.updateUsrDialog()
	return TRUE

/obj/machinery/microwave/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.broken > 0)
		if(src.broken == 2 && O.is_screwdriver(user)) // If it's broken and they're using a screwdriver
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of the microwave.</span>", \
				"<span class='notice'>You start to fix part of the microwave.</span>" \
			)
			if (do_after(user, src,20))
				user.visible_message( \
					"<span class='notice'>[user] fixes part of the microwave.</span>", \
					"<span class='notice'>You have fixed part of the microwave.</span>" \
				)
				src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && O.is_wrench(user)) // If it's broken and they're doing the wrench
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of the microwave.</span>", \
				"<span class='notice'>You start to fix part of the microwave.</span>" \
			)
			if (do_after(user, src,20))
				user.visible_message( \
					"<span class='notice'>[user] fixes the microwave.</span>", \
					"<span class='notice'>You have fixed the microwave.</span>" \
				)
				src.icon_state = "mw"
				src.broken = 0 // Fix it!
				src.dirty = 0 // just to be sure
				src.flags |= OPENCONTAINER
		else
			to_chat(user, "<span class='warning'>It's broken!</span>")
			return 1
	else if(src.dirty==100) // The microwave is all dirty so can't be used!
		var/obj/item/weapon/reagent_containers/R = O
		var/obj/item/weapon/soap/S = O
		if((istype(R) && (R.reagents.amount_cache.len == 1 && R.reagents.has_reagent(CLEANER, 5))) || istype(S)) // If they're trying to clean it then let them
			user.visible_message( \
				"<span class='notice'>[user] starts to clean the microwave.</span>", \
				"<span class='notice'>You start to clean the microwave.</span>" \
			)
			if (do_after(user, src,20))
				if(istype(R))
					R.reagents.remove_reagent(CLEANER,5)
				user.visible_message( \
					"<span class='notice'>[user] has cleaned the microwave.</span>", \
					"<span class='notice'>You have cleaned the microwave.</span>" \
				)
				src.dirty = 0 // It's clean!
				src.broken = 0 // just to be sure
				src.icon_state = "mw"
				src.flags |= OPENCONTAINER
				return 1
		else //Otherwise bad luck!!
			to_chat(user, "<span class='warning'>It's too dirty!</span>")
			return 1
	else if(src.operating)
		to_chat(user, "<span class='warning'>The microwave is currently on, you'll have to try again later.</span>")
		return 1

	if(..())
		return 1

	if(contents.len >= limit)
		to_chat(usr, "The machine cannot hold anymore items.")
		return 1
	else if(istype(O, /obj/item/weapon/storage/bag/plants) || istype(O, /obj/item/weapon/storage/bag/food/borg))
		var/obj/item/weapon/storage/bag/B = O
		for (var/obj/item/weapon/reagent_containers/food/snacks/G in O.contents)
			B.remove_from_storage(G,src)
			if(contents.len >= limit) //Sanity checking so the microwave doesn't overfill
				to_chat(user, "<span class='notice'>You fill \the [src] to the brim.</span>")
				break
			if(CAN_AUTOMAKE_SOMETHING)
				cook()
		updateUsrDialog()

		return 1
	else if(is_type_in_list(O,acceptable_items))
		if (istype(O,/obj/item/stack))
			var/obj/item/stack/ST = O
			if(ST.amount > 1)
				new ST.type (src,amount=1)
				ST.use(1)
				user.visible_message( \
					"<span class='notice'>[user] adds one of [O] to [src].</span>", \
					"<span class='notice'>You add one of [O] to [src].</span>")
				updateUsrDialog()
				if(CAN_AUTOMAKE_SOMETHING)
					cook()
				return 1
		if(user.drop_item(O, src))
			user.visible_message( \
				"<span class='notice'>[user] adds [O] to [src].</span>", \
				"<span class='notice'>You add [O] to [src].</span>")
			updateUsrDialog()
			if(CAN_AUTOMAKE_SOMETHING)
				cook()
			return 1
	else if(is_type_in_list(O,accepts_reagents_from))
		if (!O.reagents)
			return 1
		for (var/datum/reagent/R in O.reagents.reagent_list)
			if (!(R.id in acceptable_reagents))
				to_chat(user, "<span class='warning'>[O] contains substances unsuitable for cookery.</span>")
				return 1
		if(CAN_AUTOMAKE_SOMETHING)
			cook()
		//G.reagents.trans_to(src,G.amount_per_transfer_from_this)
	else if(istype(O,/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		to_chat(user, "<span class='warning'>This is ridiculous. You can not fit [G.affecting] in this [src].</span>")
		return 1
	else if(istype(O,/obj/item/weapon/reagent_containers/food/snacks))//we always accept snacks so we can warm them up
		if(user.drop_item(O, src))
			user.visible_message( \
				"<span class='notice'>[user] adds [O] to [src].</span>", \
				"<span class='notice'>You add [O] to [src].</span>")
			updateUsrDialog()
			return 1
	else
		to_chat(user, "<span class='warning'>You have no idea what you can cook with [O].</span>")
		return 1
	updateUsrDialog()

/obj/machinery/microwave/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/microwave/attack_ai(mob/user as mob)
	if(istype(user,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = user
		if(HAS_MODULE_QUIRK(R, MODULE_CAN_HANDLE_FOOD))
			user.set_machine(src)
			interact(user)
			return 1
		to_chat(user, "<span class='warning'>You aren't equipped to interface with technology this old!</span>")
		return 0
	if(isAdminGhost(user))
		user.set_machine(src)
		interact(user)
		return
	..()

/obj/machinery/microwave/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/microwave/emag_act(mob/user)
	..()
	emagged = 1
	to_chat(user, "<span class='warning'>You mess up \the [src]'s circuitry.</span>")

/*******************
*   Microwave Menu
********************/

/obj/machinery/microwave/interact(mob/user as mob) // The microwave Menu
	var/dat = ""
	if(src.broken > 0)
		dat = {"<TT>Bzzzzttttt</TT>"}
	else if(src.operating)
		dat = {"<TT>Microwaving in progress!<BR>Please wait...!</TT>"}
	else if(src.dirty==100)
		dat = {"<TT>This microwave is dirty!<BR>Please clean it before use!</TT>"}
	else
		if (contents.len==0 && reagents.reagent_list.len==0)
			dat = {"<B>The microwave is empty</B><BR>"}
		else
			dat = src.build_list_of_contents()
			dat = {"<b>Ingredients:</b><br>[dat]<HR><BR>"}
			if (scanning_power >= 2 )
				var/datum/recipe/recipe = select_recipe(available_recipes,src)
				if (!recipe)
					dat += {"<font color = 'red'>ERROR: No matching recipe found!</font><br>"}
					for(var/obj/O in contents) // Informs them if it might blow up
						if((istype(O,/obj/item/weapon/kitchen/utensil) && !(O.melt_temperature == MELTPOINT_PLASTIC)) || istype(O,/obj/item/weapon/cell))
							dat += {"<font color = 'red'>ALERT: Hazardous contents! Do not microwave!</font><br>"}
							break
				else
					var/obj/O = recipe.result
					var/display_name = initial(O.name)
					dat += {"<b>Expected result: </b>[display_name]<br>"}
		if (scanning_power >= 2 )
			dat += {"<a href='?src=\ref[src];action=autotoggle'>Toggle auto-cooking [auto_make_on_detect ? "off" : "on"]<br>"}
		dat += {"\
<A href='?src=\ref[src];action=cook'>Turn on!<BR>\
<A href='?src=\ref[src];action=dispose'>Eject ingredients!<BR><BR><BR>\
<A href='?src=\ref[src];action=reagenttoggle'>[reagent_disposal ? "Disable reagent disposal" : "Enable reagent disposal"]<BR>\
"}

	user << browse("<HEAD><TITLE>Microwave Controls</TITLE></HEAD><TT>[dat]</TT>", "window=microwave")
	onclose(user, "microwave")
	return

/obj/machinery/microwave/examine(mob/user)
	to_chat(user, "[bicon(src)] That's a [name].")
	if(desc)
		to_chat(user, desc)

	if(get_dist(user, src) > 3)
		to_chat(user, "<span class='info'>You can't make out the contents.</span>")
	else
		if(contents.len==0 && reagents.reagent_list.len==0)
			to_chat(user, "It's empty.")
		else
			var/list_of_contents = "It contains:<br>" + src.build_list_of_contents()
			to_chat(user, list_of_contents)

	if(panel_open)
		to_chat(user, "<span class='info'>Its maintenance panel is open.</span>")


/***********************************
*   Microwave Menu Handling/Cooking
************************************/

/obj/machinery/microwave/proc/cook(mob/user)
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN))
		return
	if(operating)
		return
	start()
	if (reagents.total_volume==0 && !(locate(/obj) in contents)) //dry run
		if (!running(10))
			abort()
			return
		stop()
		return

	var/datum/recipe/recipe = select_recipe(available_recipes,src)
	var/obj/cooked

	if (!recipe)
		// Handle the silly stuff first
		for(var/obj/O in contents)
			if(istype(O,/obj/item/weapon/cell))
				var/obj/item/weapon/cell/microwave_cell = O
				src.visible_message("<span class='warning'>[O] sparks violently in the microwave!</span>")
				if (!running(4))
					abort()
					return
				broke()
				playsound(usr, 'sound/machines/ding.ogg', 50, 1)
				empty()
				if(microwave_cell.rigged)
					if(microwave_cell.occupant)
						microwave_cell.occupant.forceMove(get_turf(src))
					explosion(get_turf(src), -1, round(sqrt(microwave_cell.charge)/60), round(sqrt(microwave_cell.charge)/30))
				else
					explosion(get_turf(src), -1,0,2) // Let's not be too harsh on idiots
				return
			if(istype(O,/obj/item/weapon/kitchen/utensil) && !(O.melt_temperature == MELTPOINT_PLASTIC))
				src.visible_message("<span class='warning'>[O] sparks in the microwave!</span>")
				if (!running(4))
					abort()
					return
				broke()
				playsound(src, 'sound/machines/ding.ogg', 50, 1)
				empty()
				explosion(get_turf(src), -1,0,0)
				return
			if(istype(O,/obj/item/device/pda) || istype(O,/obj/item/device/paicard) || istype(O,/obj/item/device/aicard) || istype(O,/obj/item/weapon/circuitboard))
				src.visible_message("<span class='warning'>[O] sparks in the microwave!</span>")
				if (!running(4))
					abort()
					return
				broke()
				playsound(src, 'sound/machines/ding.ogg', 50, 1)
				empty()
				var/obj/item/trash/slag/gunk = new(src)
				gunk.forceMove(src.loc)
				return

		// If there's just one item and no reagents, warm it up
		if ((contents.len == 1) && !reagents.total_volume)
			if(!running(10))
				abort()
				return
			stop()
			cooked = contents[1]//if there's just one item and no reagents, warm it up
			var/cook_temp = COOKTEMP_READY//100°C
			if(emagged || arcanetampered)
				cook_temp = COOKTEMP_EMAGGED//8.000.000°C
				playsound(src, "sound/items/flare_on.ogg", 100, 0)
				cooked.ignite()
			if (cooked.reagents.chem_temp < cook_temp)
				cooked.reagents.chem_temp = cook_temp
				cooked.update_icon()
			cooked.forceMove(src.loc)
			return

		// Otherwise we fucked up
		dirty += 1
		if (prob(max(10,dirty*5)))
			if (!running(4))
				abort()
				return
			muck_start()
			muck_finish()
			cooked = fail()
			cooked.forceMove(src.loc)
			return
		else if (has_extra_item())
			if(!running(4))
				abort()
				return
			broke()
			cooked = fail()
			cooked.forceMove(src.loc)
			return
		else
			if(!running(10))
				abort()
				return
			stop()
			cooked = fail()
			cooked.forceMove(src.loc)
			return
	else
		var/halftime = round(recipe.time/10/2)
		if (!running(halftime))
			abort()
			return
		if (!running(halftime))
			abort()
			cooked = fail()
			cooked.forceMove(src.loc)
			return
		cooked = recipe.make_food(src,user)
		stop()
		if(cooked)
			adjust_cooked_food_reagents_temperature(cooked, recipe)
			cooked.forceMove(get_output())
		return

/obj/machinery/microwave/proc/adjust_cooked_food_reagents_temperature(atom/cooked, datum/recipe/cookedrecipe)
	if (!cooked.reagents)
		return
	//Put the energy used during the cooking into heating the reagents of the food.

	var/cooktime = 10 SECONDS //Use a default to account for burned messes, etc.

	if(cookedrecipe)
		cooktime = cookedrecipe.time
		//If we cooked something like ice cream or salad, abort to avoid hot ice cream.
		if(cookedrecipe.cookable_with == COOKABLE_WITH_MIXING)
			if(!istype(cooked, /obj/item/weapon/reagent_containers/food/snacks/badrecipe)) //Continue and heat up burned messes for valid, salad-like recipes in the case of emagged, etc.
				return

	var/thermal_energy_transfer = cooktime * active_power_usage * 0.9 / (1 SECONDS) //Let's assume 90% efficiency. One area for expansion could be to have this depend on upgrades.
	var/max_temperature = COOKTEMP_HUMANSAFE
	if(emagged || arcanetampered)
		max_temperature = INFINITY //If it's been messed with, let it heat more than that.
	cooked.reagents.heating(thermal_energy_transfer, max_temperature)
	var/cook_temp = COOKTEMP_READY//100°C
	if(emagged || arcanetampered)
		cook_temp = COOKTEMP_EMAGGED//8.000.000°C
		playsound(src, "sound/items/flare_on.ogg", 100, 0)
		cooked.ignite()
	if (cooked.reagents.chem_temp < cook_temp)
		cooked.reagents.chem_temp = cook_temp
		cooked.update_icon()

/obj/machinery/microwave/proc/running(var/seconds as num) // was called wzhzhzh, for some fucking reason
	for (var/i=1 to seconds)
		if (stat & (NOPOWER|BROKEN|FORCEDISABLE))
			return 0
		use_power(500)
		sleep(10/speed_multiplier)
	return 1

/obj/machinery/microwave/proc/has_extra_item()
	for (var/obj/O in contents)
		if ( \
				!istype(O, /obj/item/weapon/reagent_containers/food) && \
				!istype(O, /obj/item/weapon/grown) \
			)
			return 1
	return 0

/obj/machinery/microwave/proc/start()
	src.visible_message("<span class='notice'>The microwave turns on.</span>", "<span class='notice'>You hear a microwave.</span>")
	src.operating = 1
	src.icon_state = "mw1"
	src.updateUsrDialog()

/obj/machinery/microwave/proc/abort()
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = "mw"
	src.updateUsrDialog()

/obj/machinery/microwave/proc/stop()
	playsound(src, 'sound/machines/ding.ogg', 50, 1)
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = "mw"
	src.updateUsrDialog()

/obj/machinery/microwave/proc/dispose()
	if(operating)
		return
	for (var/obj/O in contents)
		O.forceMove(src.loc)
		O.update_icon()
	if (src.reagents.total_volume)
		src.dirty++
		if(reagent_disposal)
			var/mob/user = usr
			var/recovered_reagents = FALSE
			if (user && Adjacent(user))
				for(var/obj/item/weapon/reagent_containers/glass/G in (user.get_active_hand() + user.get_inactive_hand()))
					if(!G.reagents)
						continue
					if(!G.is_open_container())
						continue

					to_chat(user, "<span class='notice'>You recover the reagents from the microwave inside your [G]!</span>")
					reagents.trans_to(G, reagents.total_volume)
					recovered_reagents = TRUE
					break
			if(!recovered_reagents && scanning_power >= 1) //You get one bottle, don't fuck it up
				var/obj/item/weapon/reagent_containers/food/condiment/C = new(get_turf(src))
				reagents.trans_to(C, reagents.total_volume)
			reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You dispose of the microwave contents.</span>")
	src.updateUsrDialog()

/obj/machinery/microwave/proc/muck_start()
	playsound(src, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	src.icon_state = "mwbloody1" // Make it look dirty!!

/obj/machinery/microwave/proc/muck_finish()
	playsound(src, 'sound/machines/ding.ogg', 50, 1)
	src.visible_message("<span class='warning'>The microwave gets covered in muck!</span>")
	src.dirty = 100 // Make it dirty so it can't be used util cleaned
	src.flags &= ~OPENCONTAINER //So you can't add condiments
	src.icon_state = "mwbloody" // Make it look dirty too
	src.operating = 0 // Turn it off again aferwards
	src.updateUsrDialog()

/obj/machinery/microwave/proc/broke()
	spark(src, 2)
	src.icon_state = "mwb" // Make it look all busted up and shit
	src.visible_message("<span class='warning'>The microwave breaks!</span>") //Let them know they're stupid
	src.broken = 2 // Make it broken so it can't be used util fixed
	src.flags &= ~OPENCONTAINER //So you can't add condiments
	src.operating = 0 // Turn it off again aferwards
	src.updateUsrDialog()

/obj/machinery/microwave/proc/fail(var/arcane = FALSE)
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for (var/obj/O in contents-ffuu)
		amount++
		if (O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if (id)
				amount+=O.reagents.get_reagent_amount(id)
		QDEL_NULL(O)
	src.reagents.clear_reagents()
	ffuu.reagents.add_reagent(CARBON, amount)
	ffuu.reagents.add_reagent(TOXIN, amount/10)
	if(emagged || arcanetampered || arcane || Holiday == APRIL_FOOLS_DAY)
		playsound(src, "goon/sound/effects/dramatic.ogg", 100, 0)
	if(arcanetampered || arcane)
		muck_start()
		muck_finish()
		broke()
	var/cook_temp = COOKTEMP_READY//100°C
	if(emagged || arcanetampered)
		cook_temp = COOKTEMP_EMAGGED//8.000.000°C
		playsound(src, "sound/items/flare_on.ogg", 100, 0)
		ffuu.ignite()
	if (ffuu.reagents.chem_temp < cook_temp)
		ffuu.reagents.chem_temp = cook_temp
		ffuu.update_icon()
	return ffuu

/obj/machinery/microwave/proc/empty()
	for (var/obj/O in contents)
		qdel(O)
	src.reagents.clear_reagents()
	return

/obj/machinery/microwave/CtrlClick(mob/user)
	if(isAdminGhost(user) || (!user.incapacitated() && Adjacent(user) && user.dexterity_check() && anchored))
		if(issilicon(user) && !attack_ai(user))
			return ..()
		cook(user) //Cook checks for power, brokenness, and contents internally
		return
	return ..()

/obj/machinery/microwave/AltClick(mob/user)
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return ..()
	if(!anchored)
		return ..()
	if(isAdminGhost(user) || (!user.incapacitated() && Adjacent(user) && user.dexterity_check()))
		if(issilicon(user) && !attack_ai(user))
			return ..()
		var/list/choices = list(
			list("Cook", "radial_cook"),
			list("Eject Ingredients", "radial_eject"),
			list("Toggle Reagent Disposal", (reagent_disposal ? "radial_chem_notrash" : "radial_chem_trash")),
			list("Examine", "radial_examine")
		)

		var/task = show_radial_menu(usr,loc,choices,custom_check = new /callback(src, nameof(src::radial_check()), user))
		if(!radial_check(usr))
			return

		switch(task)
			if("Cook")
				cook(user)
			if("Eject Ingredients")
				dispose()
			if("Toggle Reagent Disposal")
				reagent_disposal = !reagent_disposal
				updateUsrDialog()
			if("Examine")
				usr.examination(src)
		return
	return ..()

/obj/machinery/microwave/proc/radial_check(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/machinery/microwave/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	if(src.operating)
		updateUsrDialog()
		return

	switch(href_list["action"])
		if ("cook")
			cook(usr)

		if ("dispose")
			dispose()

		if ("reagenttoggle")
			reagent_disposal = !reagent_disposal
			updateUsrDialog()

		if ("autotoggle")
			auto_make_on_detect = !auto_make_on_detect
			updateUsrDialog()
	return

/obj/machinery/microwave/npc_tamper_act(mob/living/L)
	//Put a random nearby item inside. 50% chance to start cooking
	var/list/pickable_items = list()

	for(var/obj/item/I in range(1, L))
		if(istype(I, /obj/item/weapon/reagent_containers/food/snacks) || is_type_in_list(I, acceptable_items))
			pickable_items.Add(I)

	if(!pickable_items.len)
		return

	var/obj/item/I = pick(pickable_items)
	if(L.Adjacent(I))
		visible_message("<span class='danger'>\The [L] stuffs \the [I] into \the [src]!</span>")
		attackby(I, L)
	else
		return

	if(prob(50))
		cook()


/obj/machinery/microwave/table_shift()
	pixel_x = -3
	pixel_y = 6

/obj/machinery/microwave/table_unshift()
	pixel_x = 0
	pixel_y = 0


#undef CAN_AUTOMAKE_SOMETHING
