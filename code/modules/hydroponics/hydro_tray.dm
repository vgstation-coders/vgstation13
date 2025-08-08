var/list/hydro_trays = list()

/obj/machinery/portable_atmospherics/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "hydrotray"
	anchored = 1
	dir = EAST
	flags = OPENCONTAINER | PROXMOVE // PROXMOVE could be added and removed as necessary if it causes lag
	volume = 100
	layer = HYDROPONIC_TRAY_LAYER
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 10
	active_power_usage = 50
	slimeadd_message = "You attach the slime extract to SRCTAG's internal mechanisms"
	slimes_accepted = SLIME_GREEN
	slimeadd_success_message = "A faint whiff of clonexadone is emitted from them"
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | MULTIOUTPUT

	var/draw_warnings = 1 // Set to 0 to stop it from drawing the alert lights.
	var/tmp/update_icon_after_process = 0 // Will try to only call update_icon() when necessary.
	var/last_update_icon = 0 // Since we're calling it more frequently than process(), let's at least make sure we're only calling it once per tick.
	var/delayed_update_icon = 0
	var/is_soil = 0
	var/is_plastic = 0

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
	var/growth_level = 0

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
	var/internal_light_range = 1	//light range provided by the tray's internal light. Can be improved with better capacitors.
	var/light_on = 0

	var/lid_toggling = 0

	var/key_name_last_user = ""

	var/image/visible_gas = null

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
	hydro_trays += src
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

/obj/machinery/portable_atmospherics/hydroponics/Destroy()
	hydro_trays -= src
	..()

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
	internal_light_range = capcount

/obj/machinery/portable_atmospherics/hydroponics/emp_act(var/severity)
	if(is_soil || is_plastic)
		return
	switch(severity)
		if(1)
			if(prob(75))
				close_lid()
				if (light_on)
					light_toggle()
		if(2)
			if(prob(35))
				close_lid()
				if (light_on)
					light_toggle()


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
	check_light()
	update_icon()

//Calls necessary sanity when a plant is removed from the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/remove_plant()
	pestlevel = 0
	seed = null
	dead = 0
	age = 0
	growth_level = 0
	sampled = 0
	harvest = 0
	improper_light = 0
	improper_kpa = 0
	improper_heat = 0
	check_light()
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

	seed.harvest(user, src)
	after_harvest()
	return

/obj/machinery/portable_atmospherics/hydroponics/proc/autoharvest()
	if(!seed || !harvest || arcanetampered)
		return

	seed.autoharvest(get_output())
	after_harvest()

/obj/machinery/portable_atmospherics/hydroponics/power_change()
	..()
	check_light()
	update_icon()

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
	to_chat(user, "You remove the dead plant from \the [src].")

	update_icon()
	return

 // If a weed growth is sufficient, this proc is called.
/obj/machinery/portable_atmospherics/hydroponics/proc/weed_invasion()
	//Remove the seed if something is already planted.
	if(seed)
		remove_plant()
	seed = SSplant.seeds[pick(list("reishi","nettles","amanita","mushrooms","plumphelmet","towercap","harebells","dandelions","glowshroom","grass"))]
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

	else if(isshovel(O))
		if(closed_system)
			to_chat(user, "<span class='warning'>You can't dig soil while the lid is shut.</span>")
			return
		if(arcanetampered)
			to_chat(user,"<span class='sinister'>You cannot dig into the soil.</span>")
			return
		if(dead)
			remove_dead(user)
			return
		if(seed)
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
				S.paint_layers = C.paint_layers.Copy()
				qdel(C)

				if(seed.large)
					S.icon_state += "-large"

				var/plant_appearance = ""
				if(dead)
					plant_appearance = "dead"
				else if(harvest)
					if (harvest > 1)
						plant_appearance = "harvest-[harvest]"
					else
						plant_appearance = "harvest"
				else
					plant_appearance = "stage-[growth_level]"

				S.plant_image = image(seed.plant_dmi,plant_appearance)
				S.plant_name = seed.display_name
				S.name = "potted [S.plant_name]"
				S.plantname = seed.name

				if (seed.pollen && harvest >= seed.pollen_at_level)
					S.pollen = seed.pollen
					S.add_particles(seed.pollen)
					S.adjust_particles(PVAR_SPAWNING, 0.05, seed.pollen)
					S.adjust_particles(PVAR_PLANE, FLOAT_PLANE, seed.pollen)
					S.adjust_particles(PVAR_POSITION, generator("box", list(-12,4), list(12,12)), seed.pollen)

				if (seed.moody_lights)
					S.update_moody_light_index("plant", seed.plant_dmi, "[plant_appearance]-moody")
				else if (seed.biolum)
					var/image/luminosity_gradient = image(icon, src, "moody_plant_mask")
					luminosity_gradient.blend_mode = BLEND_INSET_OVERLAY
					var/image/mask = image(seed.plant_dmi, src, plant_appearance)
					mask.appearance_flags = KEEP_TOGETHER
					mask.overlays += luminosity_gradient
					S.update_moody_light_index("plant", image_override = mask)

				if(seed.biolum)
					S.set_light(get_biolum())
					if(seed.biolum_colour)
						S.light_color = seed.biolum_colour

				remove_plant()
				S.update_icon()
				update_icon()
			else
				C.being_potted = FALSE
			return

	else if(istype(O,/obj/item/tool/scalpel) || O.is_wirecutter(user))
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
		if(closed_system)
			to_chat(user, "You carefully pass \the [O] through the tray's access port, and take a sample from the [seed.display_name].")
		else
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
			if(closed_system)
				user.visible_message("<span class='alert'>[user] starts uprooting the weeds.</span>", "<span class='alert'>You pass \the [O] through the access port and remove the weeds from the [src].</span>")
			else
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

	else if(O.is_wrench(user) && is_soil) //Soil isn't a portable atmospherics machine by any means
		return //Don't call parent. I mean, soil shouldn't be a child of portable_atmospherics at all, but that's not very feasible.

	else if(istype(O, /obj/item/apiary))//Because not everyone is gonna read the changelog
		to_chat(user,"<span class='warning'>[is_soil ? "" : "You're not sure why you'd put an apiary in an hydroponics tray of all things. Like, it doesn't really makes much sense does it? "]You should build the kit directly on top of the floor.</span>")

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

/obj/machinery/portable_atmospherics/hydroponics/proc/get_biolum()
	return (1 + Ceiling(seed.potency/10))

/obj/machinery/portable_atmospherics/hydroponics/wrenchAnchor(var/mob/user, var/obj/item/I, var/time_to_wrench = 3 SECONDS)
	. = ..()
	if (.)
		power_change()//calls update_icon()

/obj/machinery/portable_atmospherics/hydroponics/wind_act(var/differential, var/list/connecting_turfs)
	if (seed)
		seed.wind_act(src, differential, connecting_turfs)

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

/obj/machinery/portable_atmospherics/hydroponics/reagent_transfer_message(var/transfer_amt)
	if (closed_system)
		return "<span class='notice'>You open \the [src.name]'s injection port and transfer [transfer_amt] units of the solution in it.</span>"
	else
		return "<span class='notice'>You transfer [transfer_amt] units of the solution to \the [src.name].</span>"

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
		to_chat(user, "You can grow plants in there.[(is_soil||is_plastic) ? "" : " It's full of sensors that will inform you of the plant's well-being"]")
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

		if(!is_soil && !is_plastic)

			var/turf/T = loc
			var/datum/gas_mixture/environment

			if(closed_system)
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

/obj/machinery/portable_atmospherics/hydroponics/proc/receive_pulse(var/pulse_strength)
	if (seed && !closed_system)//if the lid is closed, the plant is radiation immune.
		pulse_strength /= 50
		if (prob(pulse_strength))
			if (age <= 4)
				//young plants mutate more easily
				if (length(seed.mutants))
					mutate_species()
				else
					mutate()
			else if (prob(pulse_strength/2))
				//older plants have between 1.125% and 1.875% chance to mutate per burst
				//at 15 burst total this amounts to about 19% chance of at least one small mutation occurring
				mutate()

/obj/machinery/portable_atmospherics/hydroponics/proc/hydrovision(mob/user)
	hydro_hud_scan(user, src)
	return FALSE

/obj/machinery/portable_atmospherics/hydroponics/verb/close_lid()
	set name = "Toggle Tray Lid"
	set category = "Object"
	set src in view(1)

	if(!usr || usr.isUnconscious() || usr.restrained())
		return
	if (lid_toggling)
		return
	lid_toggling = 1
	add_fingerprint(usr)
	closed_system = !closed_system
	to_chat(usr, "You [closed_system ? "close" : "open"] the tray's lid.")

	var/cargo_cart_offset = 0
	if (istype(locked_to,/obj/machinery/cart/cargo))
		cargo_cart_offset = CARGO_CART_OFFSET

	if (closed_system)
		anim(target = src, a_icon = icon, flick_anim = "back_anim", sleeptime = 5, lay = HYDROPONIC_TRAY_BACK_LID_LAYER+cargo_cart_offset, offY = pixel_y)
		anim(target = src, a_icon = icon, flick_anim = "front_anim", sleeptime = 5, lay = HYDROPONIC_TRAY_FRONT_LID_LAYER+cargo_cart_offset, offY = pixel_y)
		playsound(src, 'sound/machines/pressurehiss.ogg', 20, 1)
		spawn(5)
			playsound(src, 'sound/items/Deconstruct.ogg', 20, 1)
			lid_toggling = 0
			update_icon()
	else
		lid_toggling = 2
		update_icon()
		playsound(src, 'sound/effects/turret/open.wav', 20, 1)
		playsound(src, 'sound/items/Deconstruct.ogg', 20, 1)
		anim(target = src, a_icon = icon, flick_anim = "back_anim_rewind", sleeptime = 5, lay = HYDROPONIC_TRAY_BACK_LID_LAYER+cargo_cart_offset, offY = pixel_y)
		anim(target = src, a_icon = icon, flick_anim = "front_anim_rewind", sleeptime = 5, lay = HYDROPONIC_TRAY_FRONT_LID_LAYER+cargo_cart_offset, offY = pixel_y)
		spawn(5)
			playsound(src, 'sound/machines/click.ogg', 20, 1)
			lid_toggling = 0


/obj/machinery/portable_atmospherics/hydroponics/verb/light_toggle()
	set name = "Toggle Light"
	set category = "Object"
	set src in view(1)
	if(!usr || usr.isUnconscious() || usr.restrained())
		return
	light_on = !light_on
	playsound(src,'sound/misc/click.ogg',30,0,-1)
	check_light()
	update_icon()
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

/obj/machinery/portable_atmospherics/hydroponics/variable_edited(variable_name, old_value, new_value)
	.=..()
	update_icon()

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

/obj/machinery/portable_atmospherics/hydroponics/CtrlClick(var/mob/user)
	if (anchored)
		if((usr.incapacitated() || !Adjacent(usr)))
			return
		close_lid()
	else
		..()

/obj/machinery/portable_atmospherics/hydroponics/AltClick(var/mob/user)
	if(!is_soil && !is_plastic && (isAdminGhost(user) || (!user.incapacitated() && Adjacent(user) && user.dexterity_check())))
		if(issilicon(user) && !attack_ai(user))
			return ..()
		var/list/choices = list(
			list("Toggle Tray Lid", "radial_lid"),
			list("Toggle Light", "radial_light"),
			list("Set Tray Label", "radial_label"),
		)

		var/task = show_radial_menu(usr,loc,choices,custom_check = new /callback(src, nameof(src::radial_check()), user))
		if(!radial_check(usr))
			return

		switch(task)
			if("Toggle Tray Lid")
				close_lid()
			if("Toggle Light")
				light_toggle()
			if("Set Tray Label")
				set_label()
		return
	return ..()

/obj/machinery/portable_atmospherics/hydroponics/proc/radial_check(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

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

/obj/machinery/portable_atmospherics/hydroponics/on_reagent_change()
	. = ..()
	delayed_update_icon = 1
	spawn(1)
		//since reagents might change multiple times during a tick as they get processed, let's wait for the tick after they've all been processed.
		//thanks to last_update_icon, this call should regardless only happen once per tick.
		update_icon()

/datum/locking_category/hydro_tray
