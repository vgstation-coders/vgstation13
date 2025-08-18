#define MECHA_INT_FIRE 1
#define MECHA_INT_TEMP_CONTROL 2
#define MECHA_INT_SHORT_CIRCUIT 4
#define MECHA_INT_TANK_BREACH 8
#define MECHA_INT_CONTROL_LOST 16

#define MELEE 1
#define RANGED 2

#define MECHA_HAND 1
#define MECHA_BACK 2

#define STATE_BOLTSHIDDEN 0
#define STATE_BOLTSEXPOSED 1
#define STATE_BOLTSOPENED 2

/obj/mecha
	name = "Mecha"
	desc = "Exosuit"
	icon = 'icons/mecha/mecha.dmi'
	density = 1 //Dense. To raise the heat.
	opacity = 1 ///opaque. Menacing.
	anchored = 1 //no pulling around.
	layer = MOB_LAYER //icon draw layer
	plane = MOB_PLANE
	infra_luminosity = 15 //byond implementation is bugged. This is supposedly infrared brightness. Lower for combat mechs.
	var/list/hud_list = list()
	var/initial_icon
	var/can_move = 1
	var/mob/living/carbon/occupant = null
	var/step_in = 10 //make a step in step_in/10 sec.
	var/dir_in = SOUTH//What direction will the mech face when entered/powered on? Defaults to South.
	var/step_energy_drain = 10 //How much energy we consume in a single step
	health = 300 //health is health
	var/deflect_chance = 0 //chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	//the values in this list show how much damage will pass through, not how much will be absorbed.
	var/list/damage_absorption = list("brute"=1,"fire"=1,"bullet"=1,"laser"=1,"energy"=1,"bomb"=1)
	var/obj/item/weapon/cell/cell = null
	var/cell_type = /obj/item/weapon/cell/high/mecha
	var/state = STATE_BOLTSHIDDEN
	var/list/log = new //Holds the log of what the mecha has done (Attacked, fired at, been attacked by, gone into maintenance mode, etc.)
	var/last_message = 0 // Used in occupant_message()
	var/add_req_access = TRUE //Whether somebody can add access to this mecha, from their own ID
	var/maint_access = TRUE //Whether an external user can activate the mecha's maintenance mode through using an ID on them
	var/dna	//Holds the DNA string of the user, should they choose to DNA lock the mech
	var/list/proc_res = list() //stores proc owners, like proc_res["functionname"] = owner reference, for equipment overrides of mecha procs.
	var/lights = FALSE //Whether lights are active or inactive
	var/light_range_on = 8 //the distance in tiles the light radiates.
	var/light_brightness_on = 2 //the brightness of the light. does not affect distance, but intensity.
	var/light_range_off = 2 //the amount of light passively produced by the mech when lights are off (cockpit glow)
	var/light_brightness_off = 1 //the brightness of the passively produced light
	var/rad_protection = 50 	//How much the mech shields its pilot from radiation.
	var/lock_dir = FALSE //Whether we've locked ourselves to a direction
	//inner atmos
	var/use_internal_tank = FALSE //Whether we are drawing from the internal tank, or from standing tile atmosphere
	var/internal_tank_valve = ONE_ATMOSPHERE //How much atmosphere to draw from the internal tank
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/atmospherics/unary/portables_connector/connected_port = null

	var/cursor_enabled = 0 //whether to display the mecha cursor

	var/obj/item/device/radio/radio = null
	var/obj/item/device/radio/electropack/electropack = null
	var/obj/item/mecha_parts/mecha_tracking/tracking = null
	var/starts_with_tracking_beacon = TRUE

	var/max_temperature = 340 //Maximum temperature of a fire this mecha can withstand before it begins taking damage. Controlled by the mecha's hull. 340 k = about 65 degrees Celcius, reasonable for a unprotected machine.
	var/max_pressure = HAZARD_HIGH_PRESSURE * 3 // It's metal, it probably shouldn't take damage at the human threshold
	var/internal_damage_threshold = 50 //health percentage below which internal damage is possible
	var/internal_damage = 0 //bitflags for what forms of damage we have (MECHA_INT_TEMP_CONTROL, MECHA_INT_SHORT_CIRCUIT, etc)

	var/list/operation_req_access = list()//required access level for mecha operation
	var/list/internals_req_access = list(access_engine_minor,access_robotics)//required access level to open cell compartment

	var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature
	var/datum/global_iterator/pr_inertial_movement //controls inertial movement in spesss
	var/datum/global_iterator/pr_give_air //moves air from tank to cabin
	var/datum/global_iterator/pr_internal_damage //processes internal damage

	var/dash_dir = null
	var/wreckage
	var/enclosed = TRUE
	var/silicon_pilot
	var/silicon_icon_state = null
	var/mech_maints_ready = FALSE
	var/enter_delay = 1
#warn set this back to 40

	var/list/equipment = new
	var/obj/item/mecha_parts/mecha_equipment/selected

	var/obj/item/weapon/mecha_fist/fist = null

	var/turf/crashing = null
	var/list/mech_parts = list()

	var/lock_controls = 0
	var/list/intrinsic_spells = null

	var/list/never_deflect = list(
		/obj/item/projectile/ion,
		/obj/item/projectile/bullet/APS,
	)

	var/list/mech_sprites = list() //sprites alternatives for a given mech. Only have to enter the name of the paint scheme
	var/paintable = 0

	var/damage_minimum = 5				//Incoming damage lower than this won't actually deal damage. Scrapes shouldn't be a real thing.
	var/internal_damage_minimum = 15	//At least this much damage to trigger some real bad hurt.
	var/weight_max = 100			//How many points of slowdown are negated from equipment? Added to the mech's base step_in.
	var/penetration_reduction = 1
	var/can_lock = TRUE // If the mecha can be dna or id locked

//mechaequipt2 stuffs
	var/list/hull_equipment = new
	var/list/weapon_equipment = new
	var/list/utility_equipment = new
	var/list/universal_equipment = new
	var/list/special_equipment = new
	var/max_hull_equip = 2
	var/max_weapon_equip = 2
	var/max_utility_equip = 2
	var/max_universal_equip = 2
	var/max_special_equip = 1

	var/list/starting_equipment = null	// List containing starting tools.

// Mech Components, similar to Cyborg, but Bigger.
	var/list/internal_components = list(
		MECH_HULL = null,
		MECH_ACTUATOR = null,
		MECH_ARMOR = null,
		MECH_GAS = null,
		MECH_ELECTRIC = null
		)

	var/list/starting_components = list(
		/obj/item/mecha_parts/component/hull,
		/obj/item/mecha_parts/component/actuator,
		/obj/item/mecha_parts/component/armor,
		/obj/item/mecha_parts/component/gas,
		/obj/item/mecha_parts/component/electrical
		)

	var/overload = FALSE
	var/defense_mode = FALSE
	var/emp_gear_proof = FALSE // Does this mecha's chassis have a random chance to drop gear when EMP'd?

	var/base_color = null // Mecha padding color. Used to paint visible equipment in special color.

	var/list/cargo = new
	var/cargo_capacity = 0
	var/obj/structure/ore_box/ore_box //to save on locate()
	var/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/hydraulic_clamp // Throws mech cargo stuff into mainline mechas.

/obj/mecha/get_cell()
	return cell

/obj/mecha/New()
	hud_list[DIAG_HEALTH_HUD] = new/image/hud('icons/mob/hud.dmi', src, "huddiagmax")
	hud_list[DIAG_CELL_HUD] = new/image/hud('icons/mob/hud.dmi', src, "hudbattmax")
	..()
	for(var/path in starting_components)
		var/obj/item/mecha_parts/component/C = new path(src)
		C.attach(src)
		mech_parts.Add(C)
	add_radio()
	add_cabin()
	if(!add_airtank() || !enclosed) //we check this here in case mecha does not have an internal tank available by default - WIP
		removeVerb(/obj/mecha/verb/connect_to_port)
		removeVerb(/obj/mecha/verb/toggle_internal_tank)
	add_cell()
	add_fist()
	if(starts_with_tracking_beacon)
		add_tracking_beacon()
	add_iterators()
	removeVerb(/obj/mecha/verb/disconnect_from_port)
	log_message("[src.name] created.")
	loc.Entered(src)
	mechas_list += src //global mech list
	icon_state = initial_icon
	icon_state += "-open"
	UpdateIcon()

/obj/mecha/Destroy()
	go_out(loc, TRUE)
	var/turf/T = get_turf(src)
	tag = "\ref[src]" //better safe then sorry
	if(istype(src, /obj/mecha/working/))
		var/obj/mecha/working/W = src
		if(W.cargo)
			for(var/obj/O in W.cargo) //Dump contents of stored cargo
				O.forceMove(T)
				W.cargo -= O
				T.Entered(O, src)

	if(prob(30) && src.enclosed) // no enclosed space no explosion :)
		explosion(T, 0, 0, 1, 3)
	if(wreckage)
		var/obj/effect/decal/mecha_wreckage/WR = new wreckage(T)
		hull_equipment.Cut()
		weapon_equipment.Cut()
		utility_equipment.Cut()
		universal_equipment.Cut()
		special_equipment.Cut()
		WR.icon_state = initial_icon + "-broken"
		for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
			if(E.salvageable && prob(30))
				WR.crowbar_salvage += E
				E.forceMove(WR)
				E.equip_ready = 1
				E.reliability = round(rand(E.reliability/3,E.reliability))
			else
				E.forceMove(T)
				qdel(E)
		for(var/slot in internal_components)
			var/obj/item/mecha_parts/component/C = internal_components[slot]
			if(istype(C))
				C.damage_part(rand(10, 20))
				C.detach()
				WR.crowbar_salvage += C
				C.forceMove(WR)
		if(cell)
			WR.crowbar_salvage += cell
			cell.forceMove(WR)
			cell.charge = rand(0, cell.charge)
			cell = null
		if(internal_tank)
			WR.crowbar_salvage += internal_tank
			internal_tank.forceMove(WR)
			internal_tank = null
	else
		for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
			E.forceMove(T)
			qdel(E)
		for(var/slot in internal_components)
			var/obj/item/mecha_parts/component/C = internal_components[slot]
			if(istype(C))
				C.detach()
				qdel(C)
	equipment.Cut() //Equipment is handled above, either by being deleted, or by being moved to the wreckage.
	mech_parts.Cut() //We don't need this list anymore, too.
	internal_components.Cut()
	mechas_list -= src //global mech list
	if(cell)
		QDEL_NULL(cell)
	if(internal_tank)
		QDEL_NULL(internal_tank)
	if(cabin_air)
		QDEL_NULL(cabin_air)
	connected_port = null
	if(radio)
		QDEL_NULL(radio)
	if(fist)
		QDEL_NULL(fist)
	if(electropack)
		QDEL_NULL(electropack)
	if(tracking)
		QDEL_NULL(tracking)
	if(pr_int_temp_processor)
		QDEL_NULL(pr_int_temp_processor)
	if(pr_inertial_movement)
		QDEL_NULL(pr_inertial_movement)
	if(pr_give_air)
		QDEL_NULL(pr_give_air)
	if(pr_internal_damage)
		QDEL_NULL(pr_internal_damage)
	selected = null
	..()

/obj/mecha/special_thrown_behaviour()
	dash_dir = dir
	throwing = 2//dashing through windows and grilles

/obj/mecha/can_apply_inertia()
	return 1 //No anchored check - so that mechas can fly off into space

/obj/mecha/is_airtight()
	return !use_internal_tank

/obj/mecha/examine(mob/user)
	..()
	var/integrity = health/initial(health)*100
	switch(integrity)
		if(85 to 100)
			to_chat(user, "<span class='info'>It's fully intact.</span>")
		if(65 to 85)
			to_chat(user, "<span class='notice'>It's slightly damaged.</span>")
		if(45 to 65)
			to_chat(user, "<span class='warning'>It's badly damaged.</span>")
		if(25 to 45)
			to_chat(user, "<span class='warning'>It's heavily damaged.</span>")
		else
			to_chat(user, "<span class='danger'>It's falling apart.</span>")

	if(equipment && equipment.len)
		to_chat(user, "It's equipped with:")
		for(var/obj/item/mecha_parts/mecha_equipment/ME in equipment)
			to_chat(user, "[bicon(ME)] [ME]")

	var/obj/item/mecha_parts/component/armor/AC = internal_components[MECH_ARMOR]
	var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]

	var/armor_condition = get_damage_string(AC)
	var/hull_condition = get_damage_string(HC)

	if(AC)
		var/repair_text = AC.integrity >= 5 && AC.integrity < AC.max_integrity ? " <span class='info'>It can be welded for repairs.</span>" : ""
		to_chat(user, "The [AC] appears [armor_condition].[repair_text]")
	else
		to_chat(user, "<span class='warning'>It lacks any armor plating.</span>")

	if(HC)
		var/repair_text = HC.integrity >= 5 && HC.integrity < HC.max_integrity ? " <span class='info'>It can be welded for repairs.</span>" : ""
		to_chat(user, "The [HC] appears [hull_condition].[repair_text]")
	else
		to_chat(user, "<span class='danger'>It lacks a proper hull structure.</span>")

	if(!HC || HC.integrity <= 0)
		to_chat(user, "<span class='warning'>The maintenance panel is exposed and accessible.</span>")

	if(enclosed)
		return
	if(silicon_pilot)
		to_chat(user, "<span class='info'>[src] appears to be piloting itself..</span>")
	else
		to_chat(user, "<span class='info'>You can see [occupant] inside.</span>")
	return

/obj/mecha/proc/get_damage_string(var/obj/item/mecha_parts/component/C)
	if(!C)
		return "<span class='danger'>missing</span>"

	var/eff = C.get_efficiency() * 100
	switch(eff)
		if(95 to 100)
			return "<span class='info'>pristine</span>"
		if(80 to 94)
			return "<span class='notice'>slightly worn</span>"
		if(60 to 79)
			return "<span class='warning'>moderately damaged</span>"
		if(35 to 59)
			return "<span class='warning'>heavily damaged</span>"
		if(6 to 34)
			return "<span class='danger'>critically damaged</span>"
		else
			return "<span class='danger'>completely destroyed</span>"

/obj/mecha/proc/drop_item()//Derpfix, but may be useful in future for engineering exosuits.
	return


#warn
/*
Issues:

Shotgun is awful to load 1 by 1

Fire damage comes from tank

Hull enclosure doesn't control atmos vulnerability

Throws and melees do not work...
*/

/obj/mecha/Hear(var/datum/speech/speech, var/rendered_message="")
	if(speech.speaker == occupant && radio.broadcasting)
		radio.talk_into(speech)
 	return

/obj/mecha/proc/click_action(atom/target,mob/user)
	if(!src.occupant || src.occupant != user )
		return
	if(user.stat)
		return
	if(state)
		occupant_message("<span class='red'>Maintenance protocols in effect.</span>")
		return
	if(!get_charge())
		return
	if(src == target)
		var/obj/item/mecha_parts/mecha_equipment/passive/rack/R = get_equipment(/obj/item/mecha_parts/mecha_equipment/passive/rack)
		if(R)
			R.rack.AltClick(user)
		return
	var/dir_to_target = get_dir(src,target)
	if(dir_to_target && !(dir_to_target & src.dir))//wrong direction
		return
	if(hasInternalDamage(MECHA_INT_CONTROL_LOST))
		target = safepick(view(3,target))
		if(!target)
			return
	if(get_dist(src, target)>1)
		if(selected && selected.is_ranged())
			selected.action(target)
	else if(selected && selected.is_melee())
		selected.action(target)
	else
		src.melee_action(target)
	return


/obj/mecha/proc/melee_action(atom/target)
	return

/obj/mecha/proc/range_action(atom/target)
	return

////////////////////////////////////////
////////  Health related procs  ////////
////////////////////////////////////////

/obj/mecha/proc/take_flat_damage(amount, type="brute")
	if(amount)
		health -= amount
		update_health()
		log_append_to_last("Took [amount] points of damage.",1)
	return

/obj/mecha/proc/get_damage_absorption()
	var/obj/item/mecha_parts/component/armor/AC = internal_components[MECH_ARMOR]
	if(!istype(AC))
		return
	else
		if(AC.get_efficiency() > 0.25)
			return AC.damage_absorption
	return

/obj/mecha/proc/components_handle_damage(var/damage, var/type = BRUTE)
	var/obj/item/mecha_parts/component/armor/AC = internal_components[MECH_ARMOR]
	damage *= src.damage_absorption[type]
	if(AC)
		var/armor_efficiency = AC.get_efficiency()
		var/damage_change = armor_efficiency * (damage * AC.armor_soak) * AC.damage_absorption[type]
		AC.damage_part(damage_change, type)
		damage -= damage_change
		if(AC.integrity < 5)
			AC.damage_part(AC.integrity) // No 0.1% health armor
	var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]
	if(HC)
		if(HC.integrity)
			var/hull_absorb = round(rand(5, 10) / 10, 0.1) * (damage * HC.hull_soak)
			HC.damage_part(hull_absorb, type)
			damage -= hull_absorb
	for(var/component_key in internal_components)
		if(component_key == MECH_HULL || component_key == MECH_ARMOR)
			continue
		var/obj/item/mecha_parts/component/C = internal_components[component_key]
		if(C && prob(C.relative_size))
			var/damage_part_amt = round(damage / 2, 0.1)
			C.damage_part(damage_part_amt)
			damage -= damage_part_amt
	return damage

/obj/mecha/take_damage(incoming_damage, damage_type = "brute", skip_break, mute, var/violent = TRUE)
	if(incoming_damage)
		var/damage = absorbDamage(incoming_damage,damage_type)
		if(violent)
			damage = components_handle_damage(damage,damage_type)
		health -= damage
		update_health()
		CheckEnclosed()
		CheckLocks()
		SetPressure()
		log_append_to_last("Took [damage] points of damage. Damage type: \"[damage_type]\".",1)
	return

/obj/mecha/proc/absorbDamage(damage,damage_type)
	return call((proc_res["dynabsorbdamage"]||src), "dynabsorbdamage")(damage,damage_type)

/obj/mecha/proc/dynabsorbdamage(damage,damage_type)
	return damage*(listgetindex(get_damage_absorption(),damage_type) || 1)

/obj/mecha/proc/update_health()
	if(src.health > 0)
		spark(src, 2, FALSE)
	else
		qdel(src)

/obj/mecha/attack_hand(mob/living/user as mob, monkey = FALSE)
	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = deflect_chance

	if(!ArmC)
		temp_deflect_chance = 1

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))

	if(monkey)
		src.log_message("Attack by paw. Attacker - [user].",1)
	else
		src.log_message("Attack by hand. Attacker - [user].",1)
	var/obj/item/mecha_parts/mecha_equipment/passive/rack/R = get_equipment(/obj/item/mecha_parts/mecha_equipment/passive/rack)
	if(R && operation_allowed(user))
		R.rack.AltClick(user)
		return
	user.do_attack_animation(src, user)
	if ((M_HULK in user.mutations) && !prob(temp_deflect_chance))
		src.take_damage(15)
		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		user.visible_message("<span class='red'><b>[user] hits [src.name], doing some damage.</b></span>", "<span class='red'><b>You hit [src.name] with all your might. The metal creaks and bends.</b></span>")
	else
		user.visible_message("<span class='red'><b>[user] hits [src.name]. Nothing happens.</b></span>","<span class='red'><b>You hit [src.name] with no visible effect.</b></span>")
		src.log_append_to_last("Armor saved.")

	user.delayNextAttack(10)

/obj/mecha/attack_paw(mob/user as mob)
	return src.attack_hand(user, TRUE)


/obj/mecha/attack_alien(mob/living/user as mob)
	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = deflect_chance

	if(!ArmC)
		temp_deflect_chance = 1

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))

	user.do_attack_animation(src, user)
	src.log_message("Attack by alien. Attacker - [user].",1)
	if(!prob(temp_deflect_chance))
		src.take_damage(15)
		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		playsound(src, 'sound/weapons/slash.ogg', 50, 1, -1)
		to_chat(user, "<span class='warning'>You slash at the armored suit!</span>")
		visible_message("<span class='warning'>The [user] slashes at [src.name]'s armor!</span>")
	else
		src.log_append_to_last("Armor saved.")
		playsound(src, 'sound/weapons/slash.ogg', 50, 1, -1)
		to_chat(user, "<span class='good'>Your claws had no effect!</span>")
		src.occupant_message("<span class='notice'>The [user]'s claws are stopped by the armor.</span>")
		visible_message("<span class='notice'>The [user] rebounds off [src.name]'s armor!</span>")

	user.delayNextAttack(10)

/obj/mecha/attack_animal(mob/living/simple_animal/user as mob)
	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = deflect_chance

	if(!ArmC)
		temp_deflect_chance = 1

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))

	user.do_attack_animation(src, user)
	src.log_message("Attack by simple animal. Attacker - [user].",1)
	if(user.melee_damage_upper == 0)
		user.emote("[user.friendly] [src]")
	else
		add_logs(user, src, "attacked", admin = user.ckey ? TRUE : FALSE) //Only add this to the server logs if they're controlled by a player.
		if(!prob(temp_deflect_chance))
			var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
			src.take_damage(damage)
			src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
			visible_message("<span class='warning'><B>[user]</B> [user.attacktext] [src]!</span>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
		else
			src.log_append_to_last("Armor saved.")
			playsound(src, 'sound/weapons/slash.ogg', 50, 1, -1)
			src.occupant_message("<span class='notice'>The [user]'s attack is stopped by the armor.</span>")
			visible_message("<span class='notice'>The [user] rebounds off [src.name]'s armor!</span>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
	user.delayNextAttack(10)

/obj/mecha/hitby(atom/movable/A as mob|obj) //wrapper
	. = ..()
	if(.)
		return
	src.log_message("Hit by [A].",1)
	call((proc_res["dynhitby"]||src), "dynhitby")(A)

/obj/mecha/proc/dynhitby(atom/movable/A)
	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = deflect_chance
	var/temp_damage_minimum = damage_minimum

	if(!ArmC || ArmC.integrity <= 0)
		temp_deflect_chance = src.deflect_chance + (defense_mode ? 25 : 0)
		temp_damage_minimum = src.damage_minimum

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))
		temp_damage_minimum = round(ArmC.get_efficiency() * ArmC.damage_minimum) + src.damage_minimum

	if(istype(A, /obj/item/mecha_parts/mecha_tracking) && !tracking && prob(25))
		A.forceMove(src)
		tracking = A
		src.visible_message("The [A] fastens firmly to [src].")
		return

	if(prob(temp_deflect_chance) || istype(A, /mob))
		src.occupant_message("<span class='notice'>The [A] bounces off the armor.</span>")
		src.visible_message("The [A] bounces off the [src.name] armor")
		src.log_append_to_last("Armor saved.")
		if(istype(A, /mob/living))
			var/mob/living/M = A
			M.take_organ_damage(10)

	else if(istype(A, /obj))
		var/obj/O = A
		if(O.throwforce)

			var/pass_damage = O.throwforce
			var/pass_damage_reduc_mod = 1
			if(pass_damage <= temp_damage_minimum)//Too little to go through.
				src.occupant_message("<span class='notice'>\The [A] bounces off the armor.</span>")
				src.visible_message("\The [A] bounces off \the [src] armor")
				return

				pass_damage_reduc_mod = 1

			for(var/obj/item/mecha_parts/mecha_equipment/armor/antiproj_armor_booster/ME in equipment)
				pass_damage = ME.handle_ranged_contact(A, pass_damage)

			pass_damage = (pass_damage*pass_damage_reduc_mod)//Applying damage reduction
			src.take_damage(pass_damage)	//The take_damage() proc handles armor values
			if(pass_damage > internal_damage_minimum)	//Only decently painful attacks trigger a chance of mech damage.
				src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	return


/obj/mecha/bullet_act(var/obj/item/projectile/Proj) //wrapper
	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]
	var/chance = 75
	if(!enclosed && occupant && !silicon_pilot)
		if(ArmC && ArmC.integrity > 0)
			chance = 20
		if(prob(chance))
			occupant.bullet_act(Proj)
			visible_message("<span class='warning'>[occupant] is hit by \the [Proj]!")
			Proj.on_hit(src,0)
	src.log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).",1)
	call((proc_res["dynbulletdamage"]||src), "dynbulletdamage")(Proj) //calls equipment
	return ..()

/obj/mecha/proc/dynbulletdamage(var/obj/item/projectile/Proj, var/penetrating = FALSE)

	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = 0
	var/temp_damage_minimum = 0
	var/penetration_reduction = 0
	var/temp_proj_penetration = 0

	if(istype(Proj, /obj/item/projectile/beam))
		if(!Proj.penetration)
			temp_proj_penetration = 3 // Lasers get a pen of 3

	if(!ArmC || ArmC.integrity <= 5)
		temp_deflect_chance = src.deflect_chance + (defense_mode ? 25 : 0)
		temp_damage_minimum = src.damage_minimum
		penetration_reduction = src.penetration_reduction

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))
		temp_damage_minimum = round(ArmC.get_efficiency() * ArmC.damage_minimum) + src.damage_minimum
		penetration_reduction = ArmC.pen_reduction + src.penetration_reduction

	if(prob(temp_deflect_chance))
		src.occupant_message("<span class='notice'>The armor deflects incoming projectile.</span>")
		src.visible_message("The [src.name] armor deflects the projectile")
		src.log_append_to_last("Armor saved.")
		return

	if(Proj.flag == "taser")
		use_power(200)
		return

	if(!(Proj.nodamage))
		var/ignore_threshold
		if(istype(Proj, /obj/item/projectile/beam/pulse))	//ATM, this is literally only for the pulse rifles used mostly by deathsquads.
			ignore_threshold = 1

		var/damage = Proj.damage
		for(var/obj/item/mecha_parts/mecha_equipment/armor/antiproj_armor_booster/ME in equipment)
			damage = ME.dynbulletdamage(Proj, damage)

		if(damage < temp_damage_minimum)//too pathetic to really damage you.
			src.occupant_message("<span class='notice'>The armor deflects incoming projectile.</span>")
			src.visible_message("The [src.name] armor deflects\the [Proj]")
			return

		src.take_damage(damage, Proj.flag)	//The take_damage() proc handles armor values
		if(prob(25))
			spark(src, 2, FALSE)
		if(damage >= internal_damage_minimum)	//Only decently painful attacks trigger a chance of mech damage.
			src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),ignore_threshold)

		//AP projectiles have a chance to cause additional damage
		var/penetration = Proj.penetration + temp_proj_penetration
		if(penetration_reduction)
			penetration -= penetration_reduction
			penetration = max(0, penetration)
		if(penetration > 0)
			var/hit_occupant = 1 //only allow the occupant to be hit once
			for(var/i in 1 to min(Proj.penetration, round(Proj.damage/2)))
				if(src.occupant && hit_occupant && prob(75))
					occupant.bullet_act(Proj)
					visible_message("<span class='warning'>[occupant] is hit by \the [Proj]!")
					Proj.on_hit(src,2)
					hit_occupant = 0
					penetrating = TRUE
				else
					if(damage > internal_damage_minimum)	//Only decently painful attacks trigger a chance of mech damage.
						src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT), 1)
				if(Proj.penetration > 0)
					Proj.penetration--

	Proj.on_hit(src) //on_hit just returns if it's argument is not a living mob so does this actually do anything?
	return

/obj/mecha/ex_act(severity)
	src.log_message("Affected by explosion of severity: [severity].",1)
//	if(prob(temp_deflect_chance))
//		severity++
//		src.log_append_to_last("Armor saved, changing severity to [severity].")
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(30))
				src.take_damage(initial(src.health)*1.5, "bomb")
				src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
			else
				src.take_damage(initial(src.health))
				src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
		if(3.0)
			src.take_damage(initial(src.health)/5, "bomb")
			src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
	return

/*Will fix later -Sieve
/obj/mecha/attack_blob(mob/user as mob)
	src.log_message("Attack by blob. Attacker - [user].",1)
	if(!prob(src.deflect_chance))
		src.take_damage(6)
		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		playsound(src, 'sound/effects/blobattack.ogg', 50, 1, -1)
		to_chat(user, "<span class='warning'>You smash at the armored suit!</span>")
		for (var/mob/V in viewers(src))
			if(V.client && !(V.blinded))
				V.show_message("<span class='warning'>The [user] smashes against [src.name]'s armor!</span>", 1)
	else
		src.log_append_to_last("Armor saved.")
		playsound(src, 'sound/effects/blobattack.ogg', 50, 1, -1)
		to_chat(user, "<span class='good'>Your attack had no effect!</span>")
		src.occupant_message("<span class='notice'>The [user]'s attack is stopped by the armor.</span>")
		for (var/mob/V in viewers(src))
			if(V.client && !(V.blinded))
				V.show_message("<span class='notice'>The [user] rebounds off the [src.name] armor!</span>", 1)
	return
*/

/obj/mecha/blob_act()
	take_damage(30, damage_type = "brute")
	return

/obj/mecha/emp_act(severity)
	var/obj/item/mecha_parts/component/electrical/zap = internal_components[MECH_ELECTRIC]
	if(get_charge())
		if(!zap || zap.integrity <= 0) // Only EMP the cell if there's no electrical hub
			cell.emp_act(severity*1.25)
		take_damage(50 / severity, damage_type = "energy", violent = FALSE)
		src.log_message("EMP detected",1)
		check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
		for(var/obj/item/mecha_parts/mecha_equipment/M in equipment)
			M.emp_act(severity)
		for(var/slot in internal_components)
			var/obj/item/mecha_parts/component/C = internal_components[slot]
			if(istype(C))
				C.emp_act(severity)
		return

/obj/mecha/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]

	var/turf/T = get_turf(loc)
	. = FALSE
	if(!istype(T))
		return
	var/datum/gas_mixture/environment = T.return_air()
	if(!istype(environment))
		return

	if(HC && HC.integrity > 0)
		max_temperature += HC.max_temperature

	if(exposed_temperature>src.max_temperature && environment.return_pressure() >= HAZARD_HIGH_PRESSURE) // Has to be a sufficient pressure for fire to hurt mechs.
		src.log_message("Exposed to dangerous temperature.",1)
		src.take_damage(5, damage_type = "fire", violent = FALSE) // For now, make it so hull&armor doesn't take damage from fire.
		src.check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL))

	if(enclosed)
		return
	for(var/mob/living/cookedalive as anything in occupant)
		if(cookedalive.fire_stacks < 5)
			cookedalive.adjust_fire_stacks(1)
			cookedalive.ignite()

	return

/obj/mecha/proc/dynattackby(obj/item/weapon/W as obj, mob/living/user as mob)
	user.delayNextAttack(8)
	user.do_attack_animation(src, W)

	var/obj/item/mecha_parts/component/armor/ArmC = internal_components[MECH_ARMOR]

	var/temp_deflect_chance = deflect_chance
	var/temp_damage_minimum = damage_minimum

	if(!ArmC)
		temp_deflect_chance = src.deflect_chance + (defense_mode ? 25 : 0)
		temp_damage_minimum = src.damage_minimum

	else
		temp_deflect_chance = round(ArmC.get_efficiency() * ArmC.deflect_chance + (defense_mode ? 25 : 0))
		temp_damage_minimum = round(ArmC.get_efficiency() * ArmC.damage_minimum) + src.damage_minimum

	if(prob(temp_deflect_chance))		//Does your attack get deflected outright.
		src.occupant_message("<span class='notice'>\The [W] bounces off [src.name].</span>")
		to_chat(user, "<span class='danger'>\The [W] bounces off [src.name].</span>")
		src.log_append_to_last("Armor saved.")

	else if(W.force < temp_damage_minimum)	//Is your attack too PATHETIC to do anything. 3 damage to a person shouldn't do anything to a mech.
		src.occupant_message("<span class='notice'>\The [W] bounces off the armor.</span>")
		src.visible_message("\The [W] bounces off \the [src] armor")
		return

	else
		src.occupant_message("<font color='red'><b>[user] hits [src] with [W].</b></font>")
		user.visible_message("<font color='red'><b>[user] hits [src] with [W].</b></font>", "<font color='red'><b>You hit [src] with [W].</b></font>")

		var/pass_damage = W.force
		for(var/obj/item/mecha_parts/mecha_equipment/armor/antiproj_armor_booster/ME in equipment)
			pass_damage = ME.handle_projectile_contact(W, user, pass_damage)
		src.take_damage(pass_damage,W.damtype)	//The take_damage() proc handles armor values
		if(pass_damage > internal_damage_minimum)	//Only decently painful attacks trigger a chance of mech damage.
			src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	return

//////////////////////////////////
////////  Misc procs  ////////
//////////////////////////////////

/obj/mecha/proc/get_health()
	return (health/initial(health)*100)

/obj/mecha/proc/get_mecha_occupancy_state()
	if((silicon_pilot) && silicon_icon_state)
		return silicon_icon_state
	if(occupant)
		return icon_state
	return "[icon_state]-open"

/obj/mecha/proc/TryMaints(var/mob/user, var/obj/item/weapon/card/id/id_card)
	if(!user in range(1))
		return

	if(occupant && state == STATE_BOLTSEXPOSED)
		to_chat(user, "<span class='notice'>You attempt to enable [src]'s maintenance protocols..</span>")
		visible_message("<span class='warning'>[user] is attempting to enable maintenance protocols on [src]!</span>")
		if(!do_after(user, 3, src))
			return
	if(state == STATE_BOLTSHIDDEN)
		state = STATE_BOLTSEXPOSED
		to_chat(user, "The securing bolts are now exposed.")
		log_message("Maintenance protocols engaged.")
		if(occupant)
			occupant_message("<span class='red'>Maintenance protocols engaged.</span>")
			occupant << sound('sound/mecha/mechlockdown.ogg', wait=0)
	else if(state == STATE_BOLTSEXPOSED)
		state = STATE_BOLTSHIDDEN
		to_chat(user, "The securing bolts are now hidden.")
		log_message("Maintenance protocols terminated.")
		if(occupant)
			occupant_message("Maintenance protocols terminated.")
			occupant << sound('sound/mecha/mechentry.ogg', wait=0)
	else
		to_chat(user, "You can't toggle maintenance mode with the securing bolts unfastened.")
		return

/obj/mecha/proc/is_killdozer()
	for(var/obj/I in equipment)
		if(istype(I, /obj/item/mecha_parts/mecha_equipment/passive/killdozer_kit))
			return TRUE
	return FALSE

//////////////////////
////// AttackBy //////
//////////////////////

/obj/mecha/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/mmi))
		var/device_name = "MMI"
		if(istype(W, /obj/item/device/mmi/posibrain))
			device_name = "positronic"
		if(mmi_move_inside(W, user))
			to_chat(user, "[src]-[device_name] interface initialized successfully")
		else
			to_chat(user, "[src]-[device_name] interface initialization failed.")
		return

	if(istype(W, /obj/item/mecha_parts/mecha_equipment))
		var/obj/item/mecha_parts/mecha_equipment/E = W
		spawn()
			if(E.can_attach(src))
				user.drop_item()
				E.attach(src)
				user.visible_message("[user] attaches [W] to [src]", "You attach [W] to [src]")
				UpdateIcon()
			else
				to_chat(user, "You were unable to attach [W] to [src]")
		return

	if(istype(W, /obj/item/mecha_parts/mecha_equipment))
		var/obj/item/mecha_parts/mecha_equipment/E = W
		spawn()
			if((E.can_attach(src) || is_killdozer()))
				if(user.drop_item(W))
					E.attach(src)
					user.visible_message("[user] attaches [W] to [src]", "You attach [W] to [src]")
					playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			else
				to_chat(user, "You were unable to attach [W] to [src]")
		return

	if(istype(W, /obj/item/mecha_parts/component) && state == STATE_BOLTSOPENED)
		var/obj/item/mecha_parts/component/MC = W
		if(MC.attach(src))
			user.drop_item()
			MC.forceMove(src)
			mech_parts.Add(MC)
			user.visible_message("[user] installs \the [W] in \the [src]", "You install \the [W] in \the [src].")
			CheckEnclosed()
			SetPressure()
			CheckLocks()
		return
	if(istype(W, /obj/item/ammo_storage/box) || (istype(W, /obj/item/weapon/storage/box)))
		resupply_box(W, user)
		return
	if(istype(W, /obj/item/ammo_casing))
		resupply_single(W, user)
		return
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(add_req_access || maint_access)
			if(internals_access_allowed(usr))
				var/obj/item/weapon/card/id/id_card
				if(istype(W, /obj/item/weapon/card/id))
					id_card = W
				else
					var/obj/item/device/pda/pda = W
					id_card = pda.id
				output_maintenance_dialog(id_card, user)
				return
			else
				to_chat(user, "<span class='warning'>Invalid ID: Access denied.</span>")
		else
			to_chat(user, "<span class='warning'>Maintenance protocols disabled by operator.</span>")
	else if(W.is_wrench(user))
		if(state==STATE_BOLTSEXPOSED)
			state = STATE_BOLTSOPENED
			to_chat(user, "You undo the securing bolts, allowing access to the component compartment (wirecutters) and cell compartment (pry bar).")
			mech_maints_ready = TRUE
			W.playtoolsound(src, 50)
		else if(state==STATE_BOLTSOPENED)
			state = STATE_BOLTSEXPOSED
			mech_maints_ready = FALSE
			to_chat(user, "You tighten the securing bolts.")
			W.playtoolsound(src, 50)
		return

	else if(W.is_wirecutter(user))
		if(state==STATE_BOLTSOPENED)
			var/list/removable_components = list()
			for(var/slot in internal_components)
				var/obj/item/mecha_parts/component/MC = internal_components[slot]
				if(istype(MC))
					removable_components[MC.name] = MC
				else
					to_chat(user, "<span class='notice'>\The [src] appears to be missing \the [slot].</span>")
			var/remove = input(user, "Which component do you want to pry out?", "Remove Component") as null|anything in removable_components
			if(!remove)
				return
			var/obj/item/mecha_parts/component/RmC = removable_components[remove]
			RmC.detach()
			mech_parts.Remove(RmC)
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You pry out \the [RmC] from \the [src].</span>")
			src.log_message("Internal component removed - [RmC]")
			CheckEnclosed()
			SetPressure()
			CheckLocks()
		return

	else if(iscrowbar(W))
		if(state==STATE_BOLTSOPENED)
			var/list/removable_components = list()
			if(cell)
				removable_components += "power cell"
			if(tracking)
				removable_components += "exosuit tracking beacon"
			if(electropack)
				removable_components += "electropack"
			var/obj/remove = input(user, "Which component do you want to pry out?", "Remove Component") as null|anything in removable_components
			if(!remove)
				return
			switch(remove)
				if ("power cell")
					if(!cell)
						return
					cell.forceMove(loc)
					mech_parts.Remove(cell)
					cell = null
				if ("exosuit tracking beacon")
					if(!tracking)
						return
					tracking.forceMove(loc)
					mech_parts.Remove(tracking)
					tracking = null
				if ("electropack")
					if(!electropack)
						return
					electropack.forceMove(loc)
					mech_parts.Remove(electropack)
					electropack = null
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You pry out \the [remove] from \the [src].</span>")
			src.log_message("Internal component removed - [remove]")
		return

	else if(istype(W, /obj/item/stack/cable_coil))
		if(state == STATE_BOLTSOPENED && hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
			var/obj/item/stack/cable_coil/CC = W
			if(CC.amount > 1)
				CC.use(2)
				clearInternalDamage(MECHA_INT_SHORT_CIRCUIT)
				to_chat(user, "You replace the fused wires.")
			else
				to_chat(user, "There's not enough wire to finish the task.")
		return
	else if(W.is_screwdriver(user))
		if(hasInternalDamage(MECHA_INT_TEMP_CONTROL))
			clearInternalDamage(MECHA_INT_TEMP_CONTROL)
			to_chat(user, "You repair the damaged temperature controller.")
		return
	else if(istype(W, /obj/item/weapon/cell))
		if(state==STATE_BOLTSOPENED)
			if(!cell)
				if(user.drop_item(W, src))
					to_chat(user, "You install the powercell.")
					cell = W
					mech_parts.Add(cell)
					log_message("Powercell installed.")
			else
				to_chat(user, "There's already a powercell installed.")
		return
	else if(istype(W, /obj/item/mecha_parts/mecha_tracking))
		if(state==STATE_BOLTSOPENED)
			if(!tracking)
				if(user.drop_item(W, src))
					to_chat(user, "You install the tracking beacon and safeties.")
					tracking = W
					mech_parts.Add(tracking)
					log_message("Exosuit tracking beacon installed.")
			else
				to_chat(user, "There's already a tracking beacon installed.")
		return
	else if(istype(W, /obj/item/device/radio/electropack))
		if(state==STATE_BOLTSOPENED)
			if(!electropack)
				if(user.drop_item(W, src))
					to_chat(user, "You rig the electropack to the cockpit.")
					electropack = W
					mech_parts.Add(electropack)
					log_message("Emergency ejection routines installed.") //not exactly a legitimate upgrade!
			else
				to_chat(user, "There's already an electropack installed.")
		return

	if(istype(W, /obj/item/mecha_parts/component) && state == STATE_BOLTSOPENED)
		var/obj/item/mecha_parts/component/MC = W
		spawn()
			if(MC.attach(src))
				user.drop_item()
				MC.forceMove(src)
				user.visible_message("[user] installs \the [W] in \the [src]", "You install \the [W] in \the [src].")
		return

	if(iswelder(W) && user.a_intent == I_DISARM) // You can weldbreak into a mech
		var/obj/item/tool/weldingtool/WT = W
		var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]
		var/obj/item/mecha_parts/component/armor/AC = internal_components[MECH_ARMOR]

		if(AC && AC.integrity > 0)
			user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s armor plating.</span>", \
				"<span class='notice'>You begin slicing through \the [src]'s armor plating.</span>", \
				"<span class='warning'>You hear welding noises.</span>")
			if(WT.do_weld(user, src, 15 SECONDS, 5))
				TryWeldBreak(AC, user, WT)
				return

		else if(HC && HC.integrity > 0)
			user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s hull.</span>", \
				"<span class='notice'>You begin slicing through \the [src]'s hull.</span>", \
				"<span class='warning'>You hear welding noises.</span>")
			if(WT.do_weld(user, src, 15 SECONDS, 5))
				TryWeldBreak(HC, user, WT)
				return

	if(iswelder(W) && user.a_intent == I_HELP)
		var/obj/item/tool/weldingtool/WT = W
		var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]
		var/obj/item/mecha_parts/component/armor/AC = internal_components[MECH_ARMOR]
		if (WT.remove_fuel(0,user))
			if (hasInternalDamage(MECHA_INT_TANK_BREACH))
				clearInternalDamage(MECHA_INT_TANK_BREACH)
				to_chat(user, "<span class='notice'>You repair the damaged gas tank.</span>")
		else
			return
		if((src.health<initial(src.health)) || (HC.integrity<HC.max_integrity) || (AC.integrity<AC.max_integrity))
			if(src.health<initial(src.health))
				to_chat(user, "<span class='notice'>You repair some damage to [src.name].</span>")
				src.health += min(10, initial(src.health)-src.health)
			else if(HC.can_repair && (HC.integrity<HC.max_integrity))
				to_chat(user, "<span class='notice'>You repair some damage to [HC.name].</span>")
				HC.integrity += min(10, HC.max_integrity-HC.integrity)
			else if(AC.can_repair && (AC.integrity<AC.max_integrity))
				to_chat(user, "<span class='notice'>You repair some damage to [AC.name].</span>")
				AC.integrity += min(10, AC.max_integrity-AC.integrity)
		else
			to_chat(user, "The [src.name] is at full integrity")
		return

	dynattackby(W, user)
	return

/*
/obj/mecha/attack_ai(var/mob/living/silicon/ai/user as mob)
	if(!istype(user, /mob/living/silicon/ai))
		return
	var/output = {"<b>Assume direct control over [src]?</b>
						<a href='?src=\ref[src];ai_take_control=\ref[user];duration=3000'>Yes</a><br>
						"}
	user << browse(output, "window=mecha_attack_ai")
	return
*/

/////////////////////////////////////
////////  Atmospheric stuff  ////////
/////////////////////////////////////

/obj/mecha/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()
	return

/obj/mecha/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)
	return

/obj/mecha/return_air()
	var/obj/item/mecha_parts/component/gas/GC = internal_components[MECH_GAS]
	if(use_internal_tank && (GC && prob(GC.get_efficiency() * 100)))
		return cabin_air
	return get_turf_air()

/obj/mecha/proc/return_pressure()
	. = 0
	var/obj/item/mecha_parts/component/gas/GC = internal_components[MECH_GAS]
	if(use_internal_tank && (GC && prob(GC.get_efficiency() * 100)))
		. =  cabin_air.return_pressure()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_pressure()
	return

//skytodo: //No idea what you want me to do here, mate.
/obj/mecha/proc/return_temperature()
	. = 0
	var/obj/item/mecha_parts/component/gas/GC = internal_components[MECH_GAS]
	if(use_internal_tank && (GC && prob(GC.get_efficiency() * 100)))
		. = cabin_air.temperature
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.temperature
	return

/obj/mecha/proc/connect(obj/machinery/atmospherics/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != src.loc)
		return 0

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src

	//Actually enforce the air sharing
	var/datum/pipe_network/network = connected_port.return_network(src)
	if(network && !(internal_tank.return_air() in network.gases))
		network.gases += internal_tank.return_air()
		network.update = 1
	log_message("Connected to gas port.")
	return 1

/obj/mecha/proc/disconnect()
	if(!connected_port)
		return 0

	var/datum/pipe_network/network = connected_port.return_network(src)
	if(network)
		network.gases -= internal_tank.return_air()

	connected_port.connected_device = null
	connected_port = null
	src.log_message("Disconnected from gas port.")
	return 1


/////////////////////////
////////  Verbs  ////////
/////////////////////////


/obj/mecha/verb/connect_to_port()
	set name = "Connect to port"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(!src.occupant)
		return
	if(usr!=src.occupant)
		return
	var/obj/machinery/atmospherics/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/unary/portables_connector/) in loc
	if(possible_port)
		if(connect(possible_port))
			src.occupant_message("<span class='notice'>[name] connects to the port.</span>")
			src.verbs += /obj/mecha/verb/disconnect_from_port
			src.verbs -= /obj/mecha/verb/connect_to_port
			return
		else
			src.occupant_message("<span class='warning'>[name] failed to connect to the port.</span>")
			return
	else
		src.occupant_message("Nothing happens.")


/obj/mecha/verb/disconnect_from_port()
	set name = "Disconnect from port"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(!src.occupant)
		return
	if(usr!=src.occupant)
		return
	if(disconnect())
		src.occupant_message("<span class='notice'>[name] disconnects from the port.</span>")
		src.verbs -= /obj/mecha/verb/disconnect_from_port
		src.verbs += /obj/mecha/verb/connect_to_port
	else
		src.occupant_message("<span class='warning'>[name] is not connected to the port at the moment.</span>")

/obj/mecha/verb/toggle_lights()
	set name = "Toggle Lights"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=occupant)
		return
	lights = !lights
	if(lights)
		light_power = light_brightness_on
		set_light(light_range_on)
	else
		light_power = light_brightness_off
		set_light(light_range_off)
	src.occupant_message("Toggled lights [lights?"on":"off"].")
	log_message("Toggled lights [lights?"on":"off"].")
	return

/obj/mecha/verb/toggle_cursor()
	set name = "Toggle Cursor"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.occupant)
		return
	cursor_enabled = !cursor_enabled
	if(cursor_enabled)
		if(src.occupant && src.occupant.client)
			src.occupant.client.mouse_pointer_icon = file("icons/mouse/mecha_mouse.dmi")
	else
		if(src.occupant && src.occupant.client)
			src.occupant.client.mouse_pointer_icon = initial(src.occupant.client.mouse_pointer_icon)
	src.occupant_message("Toggled cursor [cursor_enabled?"on":"off"].")
	log_message("Toggled cursor [cursor_enabled?"on":"off"].")
	return


/obj/mecha/verb/toggle_internal_tank()
	set name = "Toggle internal airtank usage."
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.occupant)
		return

	var/obj/item/mecha_parts/component/gas/GC = internal_components[MECH_GAS]
	if(!GC)
		to_chat(occupant, "<span class='warning'>The life support systems don't seem to respond.</span>")
		return

	if(!prob(GC.get_efficiency() * 100))
		to_chat(occupant, "<span class='warning'>\The [GC] shudders and barks, before returning to how it was before.</span>")
		return

	use_internal_tank = !use_internal_tank
	src.occupant_message("Now taking air from [use_internal_tank?"internal airtank":"environment"].")
	src.log_message("Now taking air from [use_internal_tank?"internal airtank":"environment"].")
	return

/obj/mecha/MouseDropTo(mob/M as mob, mob/user as mob)
	if(M != user)
		return
	move_inside(M, user)

/obj/mecha/verb/move_inside()
	set category = "Object"
	set name = "Enter Exosuit"
	set src in oview(1)

	if(usr.incapacitated() || usr.lying)
		return
	if(!Adjacent(usr) || !usr.Adjacent(src))
		return
	if(!ishuman(usr))
		return
	src.log_message("[usr] tries to move in.")
	if (src.occupant)
		to_chat(usr, "<span class='bnotice'>\The [src] is already occupied!</span>")
		src.log_append_to_last("Permission denied.")
		return
/*
	if (usr.abiotic())
		to_chat(usr, "<span class='notice'><B>Subject cannot have abiotic items on.</B></span>")
		return
*/
	if(!operation_allowed(usr))
		to_chat(usr, "<span class='warning'>Access Denied.</span>")
		log_append_to_last("Permission denied.")
		return
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting your life sucked out of you.")
			return

	if(get_equipment(/obj/item/mecha_parts/mecha_equipment/passive/runningboard))
		moved_inside(usr)
		refresh_spells()
		visible_message("<span class='good'>[usr] is instantly lifted into \the [src] by the running board!</span>")
	else
		visible_message("<span class='notice'>[usr] starts to climb into \the [src].</span>")
		if(do_after(usr, src, enter_delay))
			if(!src.occupant)
				moved_inside(usr)
				refresh_spells()
			else if(src.occupant!=usr)
				to_chat(usr, "[src.occupant] was faster. Try better next time, loser.")
		else
			to_chat(usr, "You stop entering the exosuit.")

	for (var/datum/faction/F in factions_with_hud_icons)
		F.update_hud_icons()

/obj/mecha/proc/moved_inside(var/mob/living/carbon/human/H as mob)
	if(!isnull(src.loc) && H && H.client && (H in range(1)))
		H.reset_view(src)
		H.stop_pulling()
		H.unlock_from()
		H.forceMove(src)
		src.occupant = H
		src.add_fingerprint(H)
		src.forceMove(src.loc)
		src.log_append_to_last("[H] moved in as pilot.")
		src.icon_state = src.initial_icon
		UpdateIcon()
		dir = dir_in
		if(!lights) //if the main lights are off, turn on cabin lights
			light_power = light_brightness_off
			set_light(light_range_off)
		playsound(src, 'sound/mecha/mechentry.ogg', 50, 1)
		if(!hasInternalDamage())
			src.occupant << sound('sound/mecha/nominalsyndi.ogg',volume=50)

		//change the cursor
		if(H.client && cursor_enabled)
			H.client.mouse_pointer_icon = file("icons/mouse/mecha_mouse.dmi")

		return 1
	else
		return 0

/obj/mecha/proc/mmi_move_inside(var/obj/item/device/mmi/mmi_as_oc as obj,mob/user as mob)
	if(!mmi_as_oc.brainmob || !mmi_as_oc.brainmob.client)
		to_chat(user, "Consciousness matrix not detected.")
		return 0
	else if(mmi_as_oc.brainmob.stat)
		to_chat(user, "Beta-rhythm below acceptable level.")
		return 0
	else if(occupant)
		to_chat(user, "Occupant detected.")
		return 0
	else if(dna)
		if(!mmi_as_oc.brainmob.dna)
			to_chat(user, "Remove the DNA-lock before proceeding.") //Avoids a posibrain runtime since posibrains don't have DNA
			return 0
		if(mmi_as_oc.brainmob.dna && dna!=mmi_as_oc.brainmob.dna.unique_enzymes)
			to_chat(user, "The DNA-lock rejects \the [mmi_as_oc], the DNAs do not match.") //Gives a clue that the MMI could be inserted if it was the original DNA lock holder.
			return 0
	//Added a message here since people assume their first click failed or something./N
//	to_chat(user, "Installing MMI, please stand by.")

	visible_message("<span class='notice'>\The [user] starts to insert \the [mmi_as_oc] into \the [src].</span>")

	if(do_after(user, src, 40))
		if(!occupant)
			return mmi_moved_inside(mmi_as_oc,user)
		else
			to_chat(user, "Occupant detected.")
	else
		to_chat(user, "You stop inserting \the [mmi_as_oc].")
	return 0

/obj/mecha/proc/mmi_moved_inside(var/obj/item/device/mmi/mmi_as_oc as obj,mob/user as mob)
	if(!isnull(src.loc) && mmi_as_oc && (user in range(1)))
		if(!mmi_as_oc.brainmob || !mmi_as_oc.brainmob.client)
			to_chat(user, "Consciousness matrix not detected.")
			return 0
		else if(mmi_as_oc.brainmob.stat)
			to_chat(user, "Beta-rhythm below acceptable level.")
			return 0
		user.drop_from_inventory(mmi_as_oc)
		var/mob/brainmob = mmi_as_oc.brainmob
		brainmob.reset_view(src)
		occupant = brainmob
		brainmob.forceMove(src) //should allow relaymove
		brainmob.canmove = 1
		mmi_as_oc.forceMove(src)
		mech_parts.Add(mmi_as_oc)
		mmi_as_oc.mecha = src
		src.verbs -= /obj/mecha/verb/eject
		src.Entered(mmi_as_oc)
		src.Move(src.loc)
		src.silicon_pilot = TRUE
		if(src.silicon_icon_state)
			src.icon_state = src.silicon_icon_state
		else
			icon_state = initial_icon
		if(!lights) //if the main lights are off, turn on cabin lights
			light_power = light_brightness_off
			set_light(light_range_off)
		dir = dir_in
		src.log_message("[mmi_as_oc] moved in as pilot.")
		if(!hasInternalDamage())
			src.occupant << sound('sound/mecha/nominalsyndi.ogg',volume=50)
		refresh_spells()

		//change the cursor
		if(occupant.client && cursor_enabled)
			occupant.client.mouse_pointer_icon = file("icons/mouse/mecha_mouse.dmi")

		log_admin("[key_name(user)] has inserted [mmi_as_oc] (played by: [mmi_as_oc.brainmob.ckey]) into the [src] at X=[src.x];Y=[src.y];Z=[src.z]")
		message_admins("[key_name(user)] has inserted [mmi_as_oc] (played by: [mmi_as_oc.brainmob.ckey]) into the [src]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")
		return 1
	else
		return 0

/obj/mecha/verb/view_stats()
	set name = "View Stats"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.occupant)
		return
	//pr_update_stats.start()
	src.occupant << browse(src.get_stats_html(), "window=exosuit")
	return

/obj/mecha/verb/eject()
	set name = "Eject"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0

	if(usr != occupant)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/mecha/verb/lock_direction()
	set name = "Lock direction"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr != src.occupant)
		return
	lock_dir = !lock_dir

/obj/mecha/MouseDropFrom(over_object, src_location, var/turf/over_location, src_control, over_control, params)
	if(!Adjacent(over_location))
		return
	if(!istype(over_location) || over_location.density)
		return
	if(istype(occupant, /mob/living/carbon/brain))
		return
	if(usr.incapacitated() || !occupant)
		return
	if(usr != occupant)
		if(occupant.isUnconscious())
			visible_message("<span class='notice'>[usr] starts pulling [occupant.name] out of \the [src].</span>")
			if(do_after(usr, src, 30 SECONDS))
				if(!occupant.isUnconscious())
					visible_message("<span class='notice'>[occupant.name] woke up and pushed [usr] away.</span>")
					return
				go_out(over_location)
				add_fingerprint(usr)
		return
	for(var/atom/movable/A in over_location.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	if(istype(over_location))
		go_out(over_location)
	add_fingerprint(usr)

/obj/mecha/proc/empty_bad_contents(var/list/extra_stuff=null) //stuff that shouldn't be there, possibly caused by the driver dropping it while inside the mech
	for(var/obj/O in src)
		if(O in mech_parts) //One of our internal components
			continue
		if(O in equipment) //It's our equipment
			continue
		if(extra_stuff && (O in extra_stuff)) //Something else we need to keep? Say no more!
			continue
		O.forceMove(loc) //Somehow got inside, drop it.

/obj/mecha/Exited(var/atom/movable/O) // Used for teleportation from within the mecha.
	if (O == occupant)
		occupant << browse(null, "window=exosuit")
		remove_mech_spells()
		if(occupant.client)
			occupant.client.mouse_pointer_icon = initial(occupant.client.mouse_pointer_icon)
		occupant = null
		icon_state = initial_icon+"-open"
		for (var/datum/faction/F in factions_with_hud_icons)
			F.update_hud_icons()
	..()

/obj/mecha/proc/go_out(var/exit = loc, var/exploding = FALSE, var/destroyed = FALSE)
	if(!occupant)
		return

	if(lock_controls) //No ejecting while using the Gravpult!
		return

	if(!exploding && exit == loc) //We don't actually want to eject our occupant on the same tile that we are, that puts them "under" us, which lets them use the mech like a personal forcefield they can shoot out of.
		var/list/turf_candidates = list(get_step(loc, dir)) + trange(1, loc) //Evaluate all 9 turfs around us, but put "directly in front of us" as the first choice.
		for(var/turf/simulated/T in turf_candidates)
			if(!is_blocked_turf(T) && Adjacent(T))
				exit = T
				UpdateIcon()
				break

	var/atom/movable/mob_container
	if(ishuman(occupant))
		mob_container = occupant
	else if(isbrain(occupant))
		var/mob/living/carbon/brain/brain = occupant
		mob_container = brain.container
	else
		return

	var/obj/structure/deathsquad_gravpult/G = locate() in get_turf(src)
	if(mob_container)
		log_message("[mob_container] moved out.")
		occupant.reset_view()
		empty_bad_contents()
		occupant << browse(null, "window=exosuit")

		//change the cursor
		if(occupant && occupant.client)
			occupant.client.mouse_pointer_icon = initial(occupant.client.mouse_pointer_icon)

		mob_container.forceMove(exit)

		if(istype(mob_container, /obj/item/device/mmi) || istype(mob_container, /obj/item/device/mmi/posibrain))
			var/obj/item/device/mmi/mmi = mob_container
			if(mmi.brainmob)
				mmi.brainmob.forceMove(mmi)
				mmi.brainmob.canmove = FALSE
				mech_parts.Remove(mmi)
			mmi.mecha = null
			verbs += /obj/mecha/verb/eject

		occupant = null
		icon_state = initial_icon+"-open"
		if(!lights) //if the lights are off, turn off the cabin lights
			set_light(0)
		dir = dir_in
		if(G)
			G.hud_off()

	for (var/datum/faction/F in factions_with_hud_icons)
		F.update_hud_icons()

/obj/mecha/proc/shock_n_boot(var/exit = loc)
	spark(src, 2, FALSE)
	if (occupant)
		to_chat(occupant, "<span class='danger'>You feel a sharp shock!</span>")
		occupant.Knockdown(10)
		occupant.Stun(10)
		spawn(10)
		emergency_eject()

/obj/mecha/proc/emergency_eject(var/exit = loc)
	if (occupant)
		occupant << sound('sound/machines/warning.ogg',wait=0)
		log_message("Emergency ejection.",1)
		occupant_message("<span class='red'>Emergency ejection protocol engaged.</span>")
		spawn(10)
		if (occupant)
			go_out()

/////////////////////////
////// Access stuff /////
/////////////////////////

/obj/mecha/proc/operation_allowed(mob/living/carbon/human/H)
	if(dna)
		if(!(usr.dna.unique_enzymes==dna))
			return FALSE
	if(istype(H))
		for(var/ID in list(H.get_active_hand(), H.wear_id, H.belt))
			if(src.check_access(ID,operation_req_access))
				return 1
	return FALSE


/obj/mecha/proc/internals_access_allowed(mob/living/carbon/human/H)
	if(istype(H))
		for(var/atom/ID in list(H.get_active_hand(), H.wear_id, H.belt))
			if(src.check_access(ID,src.internals_req_access))
				return 1
		return 0


/obj/mecha/check_access(obj/item/weapon/card/id/I, list/access_list)
	if(!istype(access_list))
		return 1
	if(!access_list.len) //no requirements
		return 1
	if(istype(I, /obj/item/device/pda))
		var/obj/item/device/pda/pda = I
		I = pda.id
	if(!istype(I) || !I.access) //not ID or no access
		return 0
	if(access_list==src.operation_req_access)
		for(var/req in access_list)
			if(!(req in I.access)) //doesn't have this access
				return 0
	else if(access_list==src.internals_req_access)
		for(var/req in access_list)
			if(req in I.access)
				return 1
	return 1

////////////////////////////////
/////// Messages and Log ///////
////////////////////////////////

#define OCCUPANT_MESSAGE_INTERVAL 0.5 SECONDS

/obj/mecha/proc/occupant_message(var/message, var/prevent_spam = FALSE)
	if(!message)
		return
	if(!occupant || !occupant.client)
		return
	if(prevent_spam)
		if(world.time - last_message <= OCCUPANT_MESSAGE_INTERVAL)
			return
	to_chat(occupant, "[bicon(src)] [message]")
	last_message = world.time

#undef OCCUPANT_MESSAGE_INTERVAL

/obj/mecha/proc/log_message(message as text,red=null)
	log.len++
	log[log.len] = list("time"=world.timeofday,"message"="[red?"<font color='red'>":null][message][red?"</font>":null]")
	return log.len

/obj/mecha/proc/log_append_to_last(message as text,red=null)
	var/list/last_entry = src.log[src.log.len]
	last_entry["message"] += "<br>[red?"<font color='red'>":null][message][red?"</font>":null]"
	return

//////////////////////
/////// Spells ///////
//////////////////////
/spell/mech
	user_type = USER_TYPE_MECH
	range = 0
	invocation = "none"
	invocation_type = SP_INV_NONE
	panel = "Mech Modules"
	spell_flags = null
	charge_type = SP_RECHARGE
	charge_cooldown_max = 0
	charge_counter = 0
	hud_state = "mecha_equip"
	override_base = "mech"
	var/obj/mecha/linked_mech
	var/obj/item/mecha_parts/mecha_equipment/linked_equipment

/spell/mech/New(var/obj/mecha/M, var/obj/item/mecha_parts/mecha_equipment/ME)
	src.linked_mech = M
	if(ME)
		src.linked_equipment = ME
		name = ME.name
		hud_state = ME.icon_state
		override_icon = ME.icon
	charge_counter = charge_cooldown_max
	desc = "[name]"

/spell/mech/Destroy()
	..()
	linked_mech = null
	linked_equipment = null

/spell/mech/cast(list/targets, mob/user)
	if(linked_mech.selected != linked_equipment)
		linked_equipment.activate()
	else
		linked_equipment.alt_action()

/spell/mech/cast_check(skipcharge = 0, mob/user = usr)
	if((user!=linked_mech.occupant) || (linked_mech.get_charge() <= 0))
		return FALSE
	else
		return ..()

/spell/mech/choose_targets(mob/user = usr)
	return list(user)

/obj/mecha/proc/refresh_spells()
	if(!occupant)
		return
	for(var/spell/mech/MS in intrinsic_spells)
		occupant.add_spell(MS, "mech_spell_ready", /obj/abstract/screen/movable/spell_master/mech)
	for(var/obj/item/mecha_parts/mecha_equipment/W in equipment)
		var/spell/mech/MS
		if(W.linked_spell)
			MS = W.linked_spell
			occupant.add_spell(MS, "mech_spell_ready", /obj/abstract/screen/movable/spell_master/mech)

/obj/mecha/proc/remove_mech_spells()
	for(var/spell/mech/MS in occupant.spell_list)
		occupant.remove_spell(MS)

/obj/mecha/proc/equip_module(var/obj/item/mecha_parts/mecha_equipment/ME)
	if(ME)
		src.selected = ME
		src.occupant_message("You switch to [ME]")
		src.visible_message("[src] raises [ME]")
		send_byjax(src.occupant,"exosuit.browser","eq_list",src.get_equipment_list())

/spell/mech/proc/update_spell_icon() //overwritten by painting a mech

///////////////////////
///// Power stuff /////
///////////////////////

/obj/mecha/proc/has_charge(amount)
	return (get_charge()>=amount)

/obj/mecha/proc/get_charge()
	return call((proc_res["dyngetcharge"]||src), "dyngetcharge")()

/obj/mecha/proc/dyngetcharge()//returns null if no powercell, else returns cell.charge
	if(!src.cell)
		return
	return max(0, src.cell.charge)

/obj/mecha/proc/use_power(amount)
	return call((proc_res["dynusepower"]||src), "dynusepower")(amount)

/obj/mecha/proc/dynusepower(amount)
	var/obj/item/mecha_parts/component/electrical/EC = internal_components[MECH_ELECTRIC]

	if(EC)
		amount = amount * (2 - EC.get_efficiency()) * EC.charge_cost_mod
	else
		amount *= 5

	if(get_charge())
		cell.use(amount)
		return 1
	return 0

/obj/mecha/proc/give_power(amount)
	var/obj/item/mecha_parts/component/electrical/EC = internal_components[MECH_ELECTRIC]

	if(!EC)
		amount /= 4
	else
		amount *= EC.get_efficiency()

	if(!isnull(get_charge()))
		cell.give(amount)
		return 1
	return 0

/obj/mecha/dissolvable()
	return 0

/obj/mecha/beam_connect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)


/obj/mecha/beam_disconnect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)

/obj/mecha/apply_beam_damage(var/obj/effect/beam/B)
	// Actually apply damage
	take_damage(B.get_damage(), damage_type = "emitter laser")

/proc/mech_integrity_to_icon_state(var/integrity_ratio)
	switch(integrity_ratio)
		if(1.0 to INFINITY)
			return "huddiagmax"
		if(0.85 to 1.0)
			return "huddiaggood"
		if(0.70 to 0.85)
			return "huddiaghigh"
		if(0.55 to 0.70)
			return "huddiagmed"
		if(0.40 to 0.55)
			return "huddiaglow"
		if(0.10 to 0.40)
			return "huddiagcrit"
		if(0 to 0.10)
			return "huddiagdead"
	return "huddiagmax"


/obj/item/device/mech_painter
	name = "mecha painter"
	desc = "A device used to paint mechs in various colours and fashions."
	icon = 'icons/obj/RCD.dmi'
	icon_state = "rpd"//placeholder art, someone please sprite it
	force = 0

/obj/item/device/mech_painter/afterattack(var/obj/mecha/M, var/mob/user)
	if(!istype(M))
		return 0
	if (!M.paintable)
		to_chat(user, "<span class='warning'>This mech cannot be painted.</span>")
		return 1
	if (!M.mech_sprites.len)
		to_chat(user, "<span class='warning'>This mech has no other paint-jobs.</span>")
		return 1
	if (M.occupant) //this check seems pointless and I would love to get rid of it, but because there's no way to figure out the current state of the mech when painting it, it's a necessary evil
		to_chat(user, "<span class='warning'>This mech has an occupant. It must be empty before you can paint it.</span>")
		return 1

	var/icontype = input("Select the paint-job!")in M.mech_sprites
//Sanity checks because icontype can be selected at an arbitrary amount of time.
	if(!user.Adjacent(M) || user.incapacitated() || user.lying)
		return 1
	if(M.occupant)
		to_chat(user, "<span class='warning'>This mech has an occupant. It must be empty before you can paint it.</span>")
		return 1
	if(icontype == M.initial_icon)
		to_chat(user, "<span class='warning'>This mech is already painted in that style.</span>")
		return 1
	if(icontype)
		to_chat(user, "<span class='info'>You paint the mech.</span>")
		M.initial_icon = icontype
		M.icon_state = icontype +"-open"
		for(var/spell/mech/MS in M.intrinsic_spells)
			MS.update_spell_icon()
		M.refresh_spells() //I think this does something important
	return 1


//////////////////////////////////////////
////////  Mecha global iterators  ////////
//////////////////////////////////////////


/datum/global_iterator/mecha_preserve_temp  //normalizing cabin air temperature to 20 degrees celsium
	delay = 20

/datum/global_iterator/mecha_preserve_temp/process(var/obj/mecha/mecha)
	if(mecha.cabin_air && mecha.cabin_air.return_volume() > 0)
		var/delta = mecha.cabin_air.temperature - T20C
		mecha.cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))

/datum/global_iterator/mecha_tank_give_air
	delay = 15

/datum/global_iterator/mecha_tank_give_air/process(var/obj/mecha/mecha)
	if(mecha.internal_tank)
		var/datum/gas_mixture/tank_air = mecha.internal_tank.return_air()
		var/datum/gas_mixture/cabin_air = mecha.cabin_air

		var/release_pressure = mecha.internal_tank_valve
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		var/transfer_moles = 0
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				transfer_moles = pressure_delta * cabin_air.return_volume() / (cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
				cabin_air.merge(removed)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/datum/gas_mixture/t_air = mecha.get_turf_air()
			pressure_delta = cabin_pressure - release_pressure
			if(t_air)
				pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0) //if location pressure is lower than cabin pressure
				transfer_moles = pressure_delta * cabin_air.return_volume() / (cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
				if(t_air)
					t_air.merge(removed)
				else //just delete the cabin gas, we're in space or some shit
					QDEL_NULL(removed)
	else
		return stop()

/datum/global_iterator/mecha_intertial_movement //inertial movement in space
	delay = 7

/datum/global_iterator/mecha_intertial_movement/process(var/obj/mecha/mecha as obj,direction)
	if(direction)
		if(!step(mecha, direction)||mecha.check_for_support())
			src.stop()
	else
		src.stop()

/datum/global_iterator/mecha_internal_damage // processing internal damage

/datum/global_iterator/mecha_internal_damage/process(var/obj/mecha/mecha)
	if(!mecha.hasInternalDamage())
		return stop()
	if(mecha.hasInternalDamage(MECHA_INT_FIRE))
		if(!mecha.hasInternalDamage(MECHA_INT_TEMP_CONTROL) && prob(5))
			mecha.clearInternalDamage(MECHA_INT_FIRE)
		if(mecha.internal_tank)
			if(mecha.internal_tank.return_pressure()>mecha.internal_tank.maximum_pressure && !(mecha.hasInternalDamage(MECHA_INT_TANK_BREACH)))
				mecha.setInternalDamage(MECHA_INT_TANK_BREACH)
			var/datum/gas_mixture/int_tank_air = mecha.internal_tank.return_air()
			if(int_tank_air && int_tank_air.return_volume()>0) //heat the air_contents
				int_tank_air.temperature = min(mecha.max_temperature*0.8, int_tank_air.temperature+rand(10,15)) // This malfunction isn't supposed to actually melt the mech
		if(mecha.cabin_air && mecha.cabin_air.return_volume()>0)
			mecha.cabin_air.temperature = min(mecha.max_temperature*0.8, mecha.cabin_air.return_temperature()+rand(10,15))
			if(mecha.cabin_air.return_temperature()>mecha.max_temperature)
				mecha.take_damage(4/round(mecha.max_temperature/mecha.cabin_air.return_temperature(),0.1), damage_type = "fire")
	if(mecha.hasInternalDamage(MECHA_INT_TEMP_CONTROL)) //stop the mecha_preserve_temp loop datum
		mecha.pr_int_temp_processor.stop()
	if(mecha.hasInternalDamage(MECHA_INT_TANK_BREACH)) //remove some air from internal tank
		if(mecha.internal_tank)
			var/datum/gas_mixture/int_tank_air = mecha.internal_tank.return_air()
			var/datum/gas_mixture/leaked_gas = int_tank_air.remove_ratio(0.10)
			if(mecha.loc && hascall(mecha.loc,"assume_air"))
				mecha.loc.assume_air(leaked_gas)
			else
				QDEL_NULL(leaked_gas)
	if(mecha.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
		if(mecha.get_charge())
			spark(mecha, 2, FALSE)
			mecha.cell.charge -= min(20,mecha.cell.charge)
			mecha.cell.maxcharge -= min(20,mecha.cell.maxcharge)

/////////////
/obj/item/weapon/mecha_fist/ // An invisible weapon representing the mech's punching force. Used for melee attacks.
	name = "mecha fist"
	desc = "The fist of a powerful mech. You probably shouldn't be seeing this."
	abstract = TRUE

/////////////

//debug
/*
/obj/mecha/verb/test_int_damage()
	set name = "Test internal damage"
	set category = "Exosuit Interface"
	set src in view(0)
	if(!occupant)
		return
	if(usr!=occupant)
		return
	var/output = {"<html>
						<head>
						</head>
						<body>
						<h3>Set:</h3>
						<a href='?src=\ref[src];debug=1;set_i_dam=[MECHA_INT_FIRE]'>MECHA_INT_FIRE</a><br />
						<a href='?src=\ref[src];debug=1;set_i_dam=[MECHA_INT_TEMP_CONTROL]'>MECHA_INT_TEMP_CONTROL</a><br />
						<a href='?src=\ref[src];debug=1;set_i_dam=[MECHA_INT_SHORT_CIRCUIT]'>MECHA_INT_SHORT_CIRCUIT</a><br />
						<a href='?src=\ref[src];debug=1;set_i_dam=[MECHA_INT_TANK_BREACH]'>MECHA_INT_TANK_BREACH</a><br />
						<a href='?src=\ref[src];debug=1;set_i_dam=[MECHA_INT_CONTROL_LOST]'>MECHA_INT_CONTROL_LOST</a><br />
						<hr />
						<h3>Clear:</h3>
						<a href='?src=\ref[src];debug=1;clear_i_dam=[MECHA_INT_FIRE]'>MECHA_INT_FIRE</a><br />
						<a href='?src=\ref[src];debug=1;clear_i_dam=[MECHA_INT_TEMP_CONTROL]'>MECHA_INT_TEMP_CONTROL</a><br />
						<a href='?src=\ref[src];debug=1;clear_i_dam=[MECHA_INT_SHORT_CIRCUIT]'>MECHA_INT_SHORT_CIRCUIT</a><br />
						<a href='?src=\ref[src];debug=1;clear_i_dam=[MECHA_INT_TANK_BREACH]'>MECHA_INT_TANK_BREACH</a><br />
						<a href='?src=\ref[src];debug=1;clear_i_dam=[MECHA_INT_CONTROL_LOST]'>MECHA_INT_CONTROL_LOST</a><br />
 					   </body>
						</html>"}

	occupant << browse(output, "window=ex_debug")
	//src.health = initial(src.health)/2.2
	//src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	return
*/

//////////////////////////////////
////////  Component procs  ////////
//////////////////////////////////

/obj/mecha/proc/CheckLocks() // Checks and sets if the mech is/can still lock
	var/obj/item/mecha_parts/component/electrical/zap = internal_components[MECH_ELECTRIC]
	var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]
	if(!zap || zap.integrity <= 0)
		dna = null
		operation_req_access = list()
		internals_req_access = list()
		can_lock = FALSE
		src.maint_access = TRUE
		return 0

	if(!HC || HC.integrity <= 0)
		can_lock = FALSE
		src.maint_access = TRUE
	else
		can_lock = TRUE
		return 1

/obj/mecha/proc/CheckEnclosed() // Checks and sets if the mech is still enclosed
	var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]
	if(HC && HC.integrity > 0)
		enclosed = TRUE
		SetPressure()
		can_lock = TRUE
	else
		enclosed = FALSE
		can_lock = FALSE
		maint_access = TRUE
		add_req_access = TRUE
		SetPressure()

/obj/mecha/proc/TryWeldBreak(var/obj/item/mecha_parts/component/component, var/mob/living/user, obj/item/weapon/W as obj) // Heeeeeeeeere's Johnny
	if(!component || !user || !W)
		return
	to_chat(user, "<span class='warning'>You cut apart the [src]'s [component]!</span>")
	visible_message("<span class='warning'>The [src]'s [component] is cut apart by [user]!</span>")
	component.damage_part(1000, BRUTE) // Smash

//////////////////////////////////
////////  Icon procs  ////////
//////////////////////////////////

/obj/mecha/proc/UpdateIcon()
	overlays.Cut()
	var/hand = 0
	var/back = 0
	for(var/obj/item/mecha_parts/mecha_equipment/i in equipment)
		if(i.has_equip_overlay)
			if(i.equip_slot == MECHA_HAND && hand < 2)
				draw_layer(i, hand)
				hand++
			else if(i.equip_slot == MECHA_BACK && back < 2)
				draw_layer(i, back)
				back++

/obj/mecha/proc/draw_layer(var/obj/item/mecha_parts/mecha_equipment/equip, entry)
	var/icon_name = "[equip.icon_state][entry ? "_r" : "_l"]"
	var/icon/weapon = icon("icons/mecha/mecha_overlays.dmi", icon_name)
	overlays += weapon
	if(equip.need_colorize)
		var/icon/padding = icon("icons/mecha/mecha_overlays.dmi", "[icon_name]_padding")
		padding.Blend(base_color, ICON_MULTIPLY)
		overlays += padding

//////////////////////////////////
////////  Atmos procs  ////////
//////////////////////////////////

/obj/mecha/proc/SetPressure()
	if(!src || src.health <= 0)
		return

	var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]

	if(HC && HC.integrity >= 0)
		max_pressure += HC.max_pressure

/obj/mecha/proc/pressure_act() // largely copied from ripley
	var/turf/T = get_turf(loc)
	var/obj/item/mecha_parts/component/hull/HC = internal_components[MECH_HULL]

	. = FALSE
	if(!istype(T))
		return

	var/datum/gas_mixture/environment = T.return_air()
	if(!istype(environment))
		return

	var/exposed_pressure = environment.return_pressure()
	if(exposed_pressure > max_pressure)
		if(HC.surprise || HC.pressure_proof)
			return
		src.log_message("Exposed to dangerous pressure.",1)
		src.take_damage(5, damage_type = "brute")
		src.check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL))

#undef STATE_BOLTSHIDDEN
#undef STATE_BOLTSEXPOSED
#undef STATE_BOLTSOPENED
