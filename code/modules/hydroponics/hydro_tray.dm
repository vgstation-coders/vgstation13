/obj/machinery/portable_atmospherics/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "hydrotray3"
	anchored = 1
	flags = OPENCONTAINER | PROXMOVE // PROXMOVE could be added and removed as necessary if it causes lag
	volume = 100

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | MULTIOUTPUT

	var/draw_warnings = 1 // Set to 0 to stop it from drawing the alert lights.
	var/tmp/update_icon_after_process = 0 // Will try to only call update_icon() when necessary.

	// Plant maintenance vars
	var/waterlevel = 100		// Water (max 100)
	var/nutrientlevel = 100		// Nutrient (max 100)
	var/pestlevel = 0			// Pests (max 100)
	var/weedlevel = 0			// Weeds (max 100)
	var/toxinlevel = 0			// Toxicity in the tray (max 100)
	var/improper_light = 0		// Becomes 1 when the plant has improper lighting, only used for update_icon purposes.
	var/improper_kpa = 0		// Becomes 1 when the environment pressure is too high/too low, only used for update_icon purposes.
	var/improper_heat = 0		// Becomes 1 when the environment temperature is too low/too high, only used for update_icon purposes.
	var/missing_gas = 0			// Adds +1 for every type of gas missing, used in process().

	// Tray state vars.
	var/dead = 0               // Is it dead?
	var/harvest = 0            // Is it ready to harvest?
	var/age = 0                // Current plant age
	var/sampled = 0            // Have we taken a sample?

	// Harvest/mutation mods.
	var/list/mutation_levels = list()	// Increases as mutagenic compounds are added, determines potency of resulting mutation when it's called.

	// Mechanical concerns.
	var/plant_health = 0       // Plant health.
	var/lastproduce = 0        // Last time tray was harvested.
	var/lastcycle = 0          // Cycle timing/tracking var.
	var/cycledelay = 150       // Delay per cycle.
	var/closed_system          // If set, the tray will attempt to take atmos from a pipe.
	var/force_update           // Set this to bypass the cycle time check.
	var/skip_aging = 0		   // Don't advance age for the next N cycles.
	var/pollination = 0
	var/bees = 0			   //Are the trays currently affected by the bees' pollination?

	//var/decay_reduction = 0     //How much is mutation decay reduced by?
	var/weed_coefficient = 10    //Coefficient to the chance of weeds appearing
	var/internal_light = 1
	var/light_on = 0

	var/key_name_last_user = ""

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/kill_plant,
	)

	// Seed details/line data.
	var/datum/seed/seed = null // The currently planted seed

/obj/machinery/portable_atmospherics/hydroponics/loose
	anchored = FALSE

/obj/machinery/portable_atmospherics/hydroponics/New()
	..()
	create_reagents(200)
	connect()
	update_icon()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/hydroponics,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()
	if(closed_system)
		flags &= ~OPENCONTAINER

/obj/machinery/portable_atmospherics/hydroponics/RefreshParts()
	var/capcount = 0
	//var/scancount = 0
	var/mattercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/capacitor))
			capcount += SP.rating
		//if(istype(SP, /obj/item/weapon/stock_parts/scanning_module)) scancount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/matter_bin))
			mattercount += SP.rating
	//decay_reduction = scancount
	weed_coefficient = WEEDLEVEL_MAX/mattercount/5
	internal_light = capcount

//Makes the plant not-alive, with proper sanity.
/obj/machinery/portable_atmospherics/hydroponics/proc/die()
	dead = 1
	harvest = 0
	improper_light = 0
	improper_kpa = 0
	improper_heat = 0
	// When the plant dies, weeds thrive and pests die off.
	add_weedlevel(10 * HYDRO_SPEED_MULTIPLIER)
	pestlevel = 0
	update_icon()

//Calls necessary sanity when a plant is removed from the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/remove_plant()
	pestlevel = 0
	seed = null
	dead = 0
	age = 0
	sampled = 0
	harvest = 0
	improper_light = 0
	improper_kpa = 0
	improper_heat = 0
	set_light(0)
	update_icon()

//Harvests the product of a plant.
/obj/machinery/portable_atmospherics/hydroponics/proc/harvest(var/mob/user)
	//Harvest the product of the plant,
	if(!seed || !harvest || !user || arcanetampered)
		return

	if(closed_system)
		to_chat(user, "You can't harvest from the plant while the lid is shut.")
		return

	if(!seed.check_harvest(user))
		return

	seed.harvest(user)
	after_harvest()
	return

/obj/machinery/portable_atmospherics/hydroponics/proc/autoharvest()
	if(!seed || !harvest || arcanetampered)
		return

	seed.autoharvest(get_output())
	after_harvest()

/obj/machinery/portable_atmospherics/hydroponics/proc/after_harvest()

	// Reset values.
	harvest = 0
	lastproduce = age

	if(!seed.harvest_repeat)
		remove_plant()

	update_icon()
	return

//Clears out a dead plant.
/obj/machinery/portable_atmospherics/hydroponics/proc/remove_dead(var/mob/user)
	if(!user || !dead)
		return
	if(closed_system)
		to_chat(user, "You can't remove the dead plant while the lid is shut.")
		return

	remove_plant()
	to_chat(user, "You remove the dead plant from the [src].")

	update_icon()
	return

 // If a weed growth is sufficient, this proc is called.
/obj/machinery/portable_atmospherics/hydroponics/proc/weed_invasion()
	//Remove the seed if something is already planted.
	if(seed)
		remove_plant()
	seed = SSplant.seeds[pick(list("reishi","nettles","amanita","mushrooms","plumphelmet","towercap","harebells","weeds","glowshroom","grass"))]
	if(!seed)
		return //Weed does not exist, someone fucked up.

	add_planthealth(seed.endurance)
	lastcycle = world.time
	weedlevel = 0
	update_icon()
	visible_message("<span class='info'>[initial(name)] has been overtaken by [seed.display_name]</span>.")

	return

/obj/machinery/portable_atmospherics/hydroponics/proc/try_spread()
	if(!seed.spread)
		return FALSE
	//Up to 80% chance it doesn't spread
	if(prob(80))
		return FALSE
	if(closed_system)
		return FALSE
	if(age < seed.maturation)
		return FALSE
	if(seed.hematophage || seed.voracious)
		return TRUE
	//Doesn't spread if well-fed
	if(get_nutrientlevel() < NUTRIENTLEVEL_MAX * 0.8)
		return TRUE
	if(seed.toxin_affinity < 5 && get_waterlevel() < WATERLEVEL_MAX * 0.8)
		return TRUE
	else if(seed.toxin_affinity <= 7 && (get_waterlevel() < WATERLEVEL_MAX * 0.8 || get_toxinlevel() < TOXINLEVEL_MAX * 0.8))
		return TRUE
	else if(seed.toxin_affinity > 7 && get_toxinlevel() < TOXINLEVEL_MAX* 0.8)
		return TRUE
	else
		return FALSE

/obj/machinery/portable_atmospherics/hydroponics/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.is_open_container())
		return 0

	add_fingerprint(user)
	key_name_last_user = key_name(user)

	if (istype(O, /obj/item/seeds))

		if(!seed)

			var/obj/item/seeds/S = O
			user.drop_item(S)

			if(!S.seed)
				to_chat(user, "The packet seems to be empty. You throw it away.")
				qdel(O)
				return

			to_chat(user, "You plant the [S.seed.seed_name] [S.seed.seed_noun].")

			switch(S.seed.spread)
				if(1)
					var/turf/T = get_turf(src)
					msg_admin_attack("[key_name(user)] has planted a creeper packet. <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a> ([bad_stuff()])")
				if(2)
					var/turf/T = get_turf(src)
					msg_admin_attack("[key_name(user)] has planted a spreading vine packet. <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a> ([bad_stuff()])")
			if(S.seed.exude_gasses && S.seed.exude_gasses.len)
				add_gamelogs(user, "planted a packet exuding [english_list(S.seed.exude_gasses)]", tp_link = TRUE)

			seed = S.seed //Grab the seed datum.
			dead = 0
			age = 1
			if(seed.hematophage)
				add_nutrientlevel(-50)

			//Snowflakey, maybe move this to the seed datum
			add_planthealth(seed.endurance)

			lastcycle = world.time

			qdel(O)
			update_icon()
			if(S.arcanetampered)
				arcanetampered = S.arcanetampered
		else
			to_chat(user, "<span class='alert'>\The [src] already has seeds in it!</span>")

	else if(O.force && seed && user.a_intent == I_HURT)
		visible_message("<span class='danger'>\The [seed.display_name] has been attacked by [user] with \the [O]!</span>")
		if(!arcanetampered) // not gonna get rid of it, sorry
			add_planthealth(-O.force)
		user.delayNextAttack(5)

	else if(istype(O, /obj/item/claypot))
		to_chat(user, "<span class='warning'>You must place the pot on the ground and use a spade on \the [src] to make a transplant.</span>")
		return

	else if(seed && isshovel(O))
		if(arcanetampered)
			to_chat(user,"<span class='sinister'>You cannot dig into the soil.</span>")
			return
		var/obj/item/claypot/C = locate() in range(user,1)
		if(!C)
			to_chat(user, "<span class='warning'>You need an empty clay pot next to you.</span>")
			return
		if(C.being_potted)
			to_chat(user, "<span class='warning'>You must finish transplanting your current plant before starting another.</span>")
			return
		playsound(loc, 'sound/items/shovel.ogg', 50, 1)
		C.being_potted = TRUE
		if(do_after(user, src, 50))
			user.visible_message(	"<span class='notice'>[user] transplants \the [seed.display_name] into \the [C].</span>",
									"<span class='notice'>[bicon(src)] You transplant \the [seed.display_name] into \the [C].</span>",
									"<span class='notice'>You hear a ratchet.</span>")

			var/obj/structure/flora/pottedplant/claypot/S = new(get_turf(C))
			transfer_fingerprints(C, S)
			qdel(C)

			if(seed.large)
				S.icon_state += "-large"

			if(dead)
				S.overlays += image(seed.plant_dmi,"dead")
			else if(harvest)
				S.overlays += image(seed.plant_dmi,"harvest")
			else if(age < seed.maturation)
				var/t_growthstate = max(1,round((age * seed.growth_stages) / seed.maturation))
				S.overlays += image(seed.plant_dmi,"stage-[t_growthstate]")
			else
				S.overlays += image(seed.plant_dmi,"stage-[seed.growth_stages]")

			S.plant_name = seed.display_name
			S.name = "potted [S.plant_name]"

			if(seed.biolum)
				S.set_light(round(seed.potency/10))
				if(seed.biolum_colour)
					S.light_color = seed.biolum_colour

			remove_plant()
			update_icon()
		else
			C.being_potted = FALSE
		return

	else if(is_type_in_list(O, list(/obj/item/tool/wirecutters, /obj/item/tool/scalpel)))
		if(!seed)
			to_chat(user, "There is nothing to take a sample from in \the [src].")
			return
		if(sampled)
			to_chat(user, "You have already sampled from this plant.")
			return
		if(dead)
			to_chat(user, "The plant is dead.")
			return

		// Create a sample.
		var/obj/item/seeds/seeds = seed.spawn_seed_packet(get_turf(user))
		if(arcanetampered)
			seeds.arcanetampered = arcanetampered
		to_chat(user, "You take a sample from the [seed.display_name].")
		add_planthealth(-rand(3,5)*10)

		if(prob(30))
			sampled = 1

		skip_aging++ //We're about to force a cycle, so one age hasn't passed. Add a single skip counter.
		force_update = 1
		process()

		return

	else if (ishoe(O))

		if(get_weedlevel() > 0)
			user.visible_message("<span class='alert'>[user] starts uprooting the weeds.</span>", "<span class='alert'>You remove the weeds from the [src].</span>")
			weedlevel = 0
			update_icon()
		else
			to_chat(user, "<span class='alert'>This plot is completely devoid of weeds. It doesn't need uprooting.</span>")

	else if (istype(O, /obj/item/weapon/storage/bag/plants))

		attack_hand(user)

		var/obj/item/weapon/storage/bag/plants/S = O
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in locate(user.x,user.y,user.z))
			if(!S.can_be_inserted(G))
				return
			S.handle_item_insertion(G, 1)

	else if(istype(O, /obj/item/weapon/tank))
		return // Maybe someday make it draw atmos from it so you don't need a whoopin canister, but for now, nothing.

	else if(O.is_wrench(user) && istype(src, /obj/machinery/portable_atmospherics/hydroponics/soil)) //Soil isn't a portable atmospherics machine by any means
		return //Don't call parent. I mean, soil shouldn't be a child of portable_atmospherics at all, but that's not very feasible.

	else if(istype(O, /obj/item/apiary))

		if(seed)
			to_chat(user, "<span class='alert'>[src] is already occupied!</span>")
		else
			user.drop_item(O, force_drop = 1)
			var/obj/item/apiary/IA = O
			var/obj/machinery/apiary/A = new IA.buildtype(src.loc)
			A.itemform = O
			O.forceMove(A)
			A.icon = src.icon
			A.icon_state = src.icon_state
			A.hydrotray_type = src.type
			A.component_parts = component_parts.Copy()
			A.contents = contents.Copy()
			contents.len = 0
			component_parts.len = 0
			qdel(src)

	else if((O.sharpness_flags & (SHARP_BLADE|SERRATED_BLADE)) && harvest)
		if(arcanetampered)
			to_chat(user,"<span class='sinister'>The plant resists your attack.</span>")
			return
		attack_hand(user)

	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown)) //composting
		to_chat(user, "You use \the [O] as compost for \the [src].")
		O.reagents.trans_to(src, O.reagents.total_volume, log_transfer = TRUE, whodunnit = user)
		qdel(O)

	else
		return ..()

/obj/machinery/portable_atmospherics/hydroponics/slime_act(primarytype,mob/user)
	..()
	if(primarytype == /mob/living/carbon/slime/green)
		has_slime=1
		to_chat(user, "You attach the slime extract to \the [src]'s internal mechanisms.")
		return TRUE

/obj/machinery/portable_atmospherics/hydroponics/attack_tk(mob/user as mob)
	if(harvest)
		harvest(user)
	else if(dead)
		remove_dead(user)

/obj/machinery/portable_atmospherics/hydroponics/attack_ai(mob/user as mob)
	return //Until we find something smart for you to do, please steer clear. Thanks

/obj/machinery/portable_atmospherics/hydroponics/attack_robot(mob/user as mob)

	if(isMoMMI(user) && Adjacent(user)) //Are we a beep ping ?
		return attack_hand(user) //Let them use the tray

/obj/machinery/portable_atmospherics/hydroponics/attack_hand(mob/user as mob)

	if(isobserver(user))
		if(!(..()))
			return 0
	if(arcanetampered && seed && isliving(user)) // no seed for you if tampered, get stung instead
		var/mob/living/H = user
		to_chat(user, "<span class='sinister'>You are </span><span class='danger'>stung and prickled</span><span class='sinister'> by the sharp thorns on \the [seed.display_name]!</span>")
		var/datum/organ/external/affecting = H.get_organ(pick(LIMB_RIGHT_HAND,LIMB_LEFT_HAND))
		affecting.take_damage(8, 0, 0, "plant thorns")
		H.UpdateDamageIcon()
		seed.potency -= rand(1,(seed.potency/3)+1)
		if(H.reagents && seed.chems && seed.chems.len)
			var/list/thingsweinjected = list()
			var/injecting = clamp(1, 3, seed.potency/10)

			for(var/rid in seed.chems) //Only transfer reagents that the plant naturally produces.
				H.reagents.add_reagent(rid,injecting)
				thingsweinjected += "[injecting]u of [rid]"
				. = 1

			if(. && fingerprintshidden && fingerprintshidden.len)
				H.investigation_log(I_CHEMS, "was stung by \a [seed.display_name], transfering [english_list(thingsweinjected)] - all touchers: [english_list(src.fingerprintshidden)]")
		return
	if(harvest)
		harvest(user)
	else if(dead)
		remove_dead(user)

	else
		examine(user) //using examine() to display the reagents inside the tray as well

/obj/machinery/portable_atmospherics/hydroponics/examine(mob/user)
	..()
	view_contents(user)

/obj/machinery/portable_atmospherics/hydroponics/proc/view_contents(mob/user)
	if(seed && !dead)
		to_chat(user, "<span class='info'>[seed.display_name]</span> is growing here.")
		if(get_planthealth() <= (seed.endurance / 2))
			to_chat(user, "The plant looks <span class='alert'>[age > seed.lifespan ? "old and wilting" : "unhealthy"].</span>")
	else if(seed && dead)
		to_chat(user, "[src] is full of dead plant matter.")
	else
		to_chat(user, "[src] has nothing planted.")
	if (Adjacent(user) || isobserver(user) || issilicon(user) || hydrovision(user))
		to_chat(user, "Water: [get_waterlevel()]/100")
		if(seed && seed.toxin_affinity >= 5)
			to_chat(user, "Toxin: [get_toxinlevel()]/100")
		if(seed && seed.hematophage)
			to_chat(user, "<span class='danger'>Blood:</span> [get_nutrientlevel()]/100")
		else
			to_chat(user, "Nutrient: [src.get_nutrientlevel()]/100")
		if(get_weedlevel() >= WEEDLEVEL_MAX/2)
			to_chat(user, "[src] is <span class='alert'>filled with weeds!</span>")
		if(get_pestlevel() >= WEEDLEVEL_MAX/2)
			to_chat(user, "[src] is <span class='alert'>filled with tiny worms!</span>")
		if(seed && draw_warnings)
			if(seed.toxin_affinity < 5 && get_toxinlevel() >= TOXINLEVEL_MAX/2)
				to_chat(user, "The tray's <span class='alert'>toxicity level alert</span> is flashing red.")
			if(improper_light)
				to_chat(user, "The tray's <span class='alert'>improper light level alert</span> is blinking.")
			if(improper_heat)
				to_chat(user, "The tray's <span class='alert'>improper temperature alert</span> is blinking.")
			if(improper_kpa)
				to_chat(user, "The tray's <span class='alert'>improper environment pressure alert</span> is blinking.")
			if(missing_gas)
				to_chat(user, "The tray's <span class='alert'>improper gas environment alert</span> is blinking.")

		if(!istype(src,/obj/machinery/portable_atmospherics/hydroponics/soil))

			var/turf/T = loc
			var/datum/gas_mixture/environment

			if(closed_system && (connected_port || holding))
				environment = air_contents

			if(!environment)
				if(istype(T))
					environment = T.return_air()

			if(!environment)
				if(istype(T, /turf/space))
					environment = space_gas
				else //Somewhere we shouldn't be, panic
					return

			var/light_available = 5
			if(T.dynamic_lighting)
				light_available = T.get_lumcount() * 10

			to_chat(user, "The tray's sensor suite is reporting a light level of [round(light_available, 0.1)] lumens and a temperature of [environment.temperature]K.")

		if(hydrovision(user))
			var/mob/living/carbon/human/H = user
			to_chat(user, "<span class='good'>Would you like to know more?</span> <a href='?src=\ref[H.glasses];scan=\ref[src]'>\[Scan\]</a>")

/obj/machinery/portable_atmospherics/hydroponics/proc/hydrovision(mob/user)
	hydro_hud_scan(user, src)
	return FALSE

/obj/machinery/portable_atmospherics/hydroponics/verb/close_lid()
	set name = "Toggle Tray Lid"
	set category = "Object"
	set src in view(1)

	if(!usr || usr.isUnconscious() || usr.restrained())
		return

	closed_system = !closed_system
	to_chat(usr, "You [closed_system ? "close" : "open"] the tray's lid.")
	if(closed_system)
		flags &= ~OPENCONTAINER
	else
		flags |= OPENCONTAINER

	update_icon()
	add_fingerprint(usr)

/obj/machinery/portable_atmospherics/hydroponics/verb/light_toggle()
	set name = "Toggle Light"
	set category = "Object"
	set src in view(1)
	if(!usr || usr.isUnconscious() || usr.restrained())
		return
	light_on = !light_on
	check_light()
	add_fingerprint(usr)

/obj/machinery/portable_atmospherics/hydroponics/verb/set_label()
	set name = "Set Tray Label"
	set category = "Object"
	set src in view(1)

	if(!usr || usr.isUnconscious() || usr.restrained())
		return

	var/n_label = copytext(reject_bad_text(input(usr, "What would you like to set the tray's label display to?", "Hydroponics Tray Labeling", null) as text), 1, MAX_NAME_LEN)
	if(!usr || !n_label || !Adjacent(usr) || usr.isUnconscious() || usr.restrained())
		return

	labeled = copytext(n_label, 1, 32) //technically replaces any traditional hand labeler labels, but will anyone really complain?
	update_name()
	new/atom/proc/remove_label(src)

/obj/machinery/portable_atmospherics/hydroponics/remove_label()
	..()
	update_name()

/obj/machinery/portable_atmospherics/hydroponics/HasProximity(mob/living/simple_animal/M)
	if(seed && !dead && seed.voracious == 2 && age > seed.maturation)
		if(istype(M, /mob/living/simple_animal/mouse) || istype(M, /mob/living/simple_animal/hostile/lizard) && !M.locked_to && !M.anchored)
			spawn(10)
				if(!M || !Adjacent(M) || M.locked_to || M.anchored)
					return // HasProximity() will likely fire a few times almost simultaneously, so spawn() is tricky with it's sanity
				visible_message("<span class='warning'>\The [seed.display_name] hungrily lashes a vine at \the [M]!</span>")
				if(M.health > 0)
					M.death()
				lock_atom(M, /datum/locking_category/hydro_tray)
				spawn(30)
					if(M && M.loc == get_turf(src))
						unlock_atom(M)
						M.gib(meat = 0) //"meat" argument only exists for mob/living/simple_animal/gib()
						add_nutrientlevel(6)
						update_icon()

/obj/machinery/portable_atmospherics/hydroponics/AltClick(var/mob/usr)
	if((usr.incapacitated() || !Adjacent(usr)))
		return
	close_lid()

/obj/machinery/portable_atmospherics/hydroponics/proc/bad_stuff()
	var/list/things = list()
	if(seed)
		if (seed.thorny)
			things += "thorny"
		if (seed.voracious == 2)
			things += "carnivorous"
		for (var/chemical_id in seed.chems)
			if (chemical_id in reagents_to_log)
				things += chemical_id
	return english_list(things, "nothing")

/datum/locking_category/hydro_tray
