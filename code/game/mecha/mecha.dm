#define MECHA_INT_FIRE 1
#define MECHA_INT_TEMP_CONTROL 2
#define MECHA_INT_SHORT_CIRCUIT 4
#define MECHA_INT_TANK_BREACH 8
#define MECHA_INT_CONTROL_LOST 16

#define MELEE 1
#define RANGED 2

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
	var/health = 300 //health is health
	var/deflect_chance = 10 //chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	//the values in this list show how much damage will pass through, not how much will be absorbed.
	var/list/damage_absorption = list("brute"=0.8,"fire"=1.2,"bullet"=0.9,"laser"=1,"energy"=1,"bomb"=1)
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

	var/max_temperature = 25000 //Maximum temperature of a fire this mecha can withstand before it begins taking damage
	var/internal_damage_threshold = 50 //health percentage below which internal damage is possible
	var/internal_damage = 0 //bitflags for what forms of damage we have (MECHA_INT_TEMP_CONTROL, MECHA_INT_SHORT_CIRCUIT, etc)

	var/list/operation_req_access = list()//required access level for mecha operation
	var/list/internals_req_access = list(access_engine,access_robotics)//required access level to open cell compartment

	var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature
	var/datum/global_iterator/pr_inertial_movement //controls inertial movement in spesss
	var/datum/global_iterator/pr_give_air //moves air from tank to cabin
	var/datum/global_iterator/pr_internal_damage //processes internal damage

	var/dash_dir = null
	var/wreckage

	var/list/equipment = new
	var/obj/item/mecha_parts/mecha_equipment/selected
	var/max_equip = 3 //The maximum amount of equipment this mecha an hold at one time.

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

/obj/mecha/get_cell()
	return cell

/obj/mecha/New()
	hud_list[DIAG_HEALTH_HUD] = image('icons/mob/hud.dmi', src, "huddiagmax")
	hud_list[DIAG_CELL_HUD] = image('icons/mob/hud.dmi', src, "hudbattmax")
	..()
	add_radio()
	add_cabin()
	if(!add_airtank()) //we check this here in case mecha does not have an internal tank available by default - WIP
		removeVerb(/obj/mecha/verb/connect_to_port)
		removeVerb(/obj/mecha/verb/toggle_internal_tank)
	add_cell()
	if(starts_with_tracking_beacon)
		add_tracking_beacon()
	add_iterators()
	removeVerb(/obj/mecha/verb/disconnect_from_port)
	log_message("[src.name] created.")
	loc.Entered(src)
	mechas_list += src //global mech list
	icon_state = initial_icon
	icon_state += "-open"

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

	if(prob(30))
		explosion(T, 0, 0, 1, 3)
	if(wreckage)
		var/obj/effect/decal/mecha_wreckage/WR = new wreckage(T)
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
	equipment.Cut() //Equipment is handled above, either by being deleted, or by being moved to the wreckage.
	mech_parts.Cut() //We don't need this list anymore, too.
	mechas_list -= src //global mech list
	if(cell)
		qdel(cell)
		cell = null
	if(internal_tank)
		qdel(internal_tank)
		internal_tank = null
	if(cabin_air)
		qdel(cabin_air)
		cabin_air = null
	connected_port = null
	if(radio)
		qdel(radio)
		radio = null
	if(electropack)
		qdel(electropack)
		electropack = null
	if(tracking)
		qdel(tracking)
		tracking = null
	if(pr_int_temp_processor)
		qdel(pr_int_temp_processor)
		pr_int_temp_processor = null
	if(pr_inertial_movement)
		qdel(pr_inertial_movement)
		pr_inertial_movement = null
	if(pr_give_air)
		qdel(pr_give_air)
		pr_give_air = null
	if(pr_internal_damage)
		qdel(pr_internal_damage)
		pr_internal_damage = null
	selected = null
	..()

/obj/mecha/can_apply_inertia()
	return 1 //No anchored check - so that mechas can fly off into space

/obj/mecha/is_airtight()
	return !use_internal_tank
////////////////////////
////// Helpers /////////
////////////////////////

/obj/mecha/proc/removeVerb(verb_path)
	verbs -= verb_path

/obj/mecha/proc/addVerb(verb_path)
	verbs += verb_path

/obj/mecha/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	mech_parts.Add(internal_tank)
	return internal_tank

/obj/mecha/proc/add_cell()
	cell = new cell_type(src)
	mech_parts.Add(cell)

/obj/mecha/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.adjust_multi(
		GAS_OXYGEN, O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature),
		GAS_NITROGEN, N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature))
	mech_parts.Add(cabin_air)
	return cabin_air

/obj/mecha/proc/add_radio()
	radio = new(src)
	radio.name = "[src] radio"
	radio.icon = icon
	radio.icon_state = icon_state
	radio.subspace_transmission = 1
	mech_parts.Add(radio)

/obj/mecha/proc/add_tracking_beacon()
	tracking = new(src)
	mech_parts.Add(tracking)
	return tracking

/obj/mecha/proc/add_iterators()
	pr_int_temp_processor = new /datum/global_iterator/mecha_preserve_temp(list(src))
	pr_inertial_movement = new /datum/global_iterator/mecha_intertial_movement(null,0)
	pr_give_air = new /datum/global_iterator/mecha_tank_give_air(list(src))
	pr_internal_damage = new /datum/global_iterator/mecha_internal_damage(list(src),0)

/obj/mecha/proc/check_for_support()
	if(locate(/obj/structure/grille, orange(1, src)) || locate(/obj/structure/lattice, orange(1, src)) || locate(/turf/simulated, orange(1, src)) || locate(/turf/unsimulated, orange(1, src)))
		return 1
	else
		return 0

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

/obj/mecha/proc/drop_item()//Derpfix, but may be useful in future for engineering exosuits.
	return

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


//////////////////////////////////
////////  Movement procs  ////////
//////////////////////////////////

/obj/mecha/relaymove(mob/user,direction)
	if(user != src.occupant) //While not "realistic", this piece is player friendly.
		user.forceMove(get_turf(src))
		to_chat(user, "You climb out from [src]")
		return 0
	if(connected_port)
		occupant_message("Unable to move while connected to the air system port.", TRUE)
		return 0
	if(lock_controls) //No moving while using the Gravpult!
		return 0
	if(throwing)
		return 0
	if(state)
		occupant_message("<span class='red'>Maintenance protocols in effect.</span>", TRUE)
		return
	return domove(direction)

/obj/mecha/proc/set_control_lock(var/lock=0,var/delay=0)
	spawn(delay)
		lock_controls = lock

/obj/mecha/proc/domove(direction)
	return call((proc_res["dyndomove"]||src), "dyndomove")(direction)

/obj/mecha/proc/dyndomove(direction)
	stopMechWalking()
	if(!can_move)
		return 0
	if(src.pr_inertial_movement.active())
		return 0
	if(!has_charge(step_energy_drain))
		return 0
	if(lock_controls) //No moving while using the Gravpult!
		return 0
	var/move_result = 0
	startMechWalking()
	var/stepped = TRUE
	if(hasInternalDamage(MECHA_INT_CONTROL_LOST))
		move_result = mechsteprand()
	else if(src.dir!=direction && !lock_dir)
		move_result = mechturn(direction)
		stepped = FALSE
	else
		move_result	= mechstep(direction)
	if(move_result)
		for(var/obj/item/mecha_parts/mecha_equipment/ME in equipment)
			if(stepped)
				ME.on_mech_step()
			else
				ME.on_mech_turn()
		can_move = 0
		use_power(step_energy_drain)
		if(istype(src.loc, /turf/space))
			if(!src.check_for_support())
				src.pr_inertial_movement.start(list(src,direction))
				src.log_message("Movement control lost. Inertial movement started.")
		sleep(step_in)
		if(!src)
			return
		can_move = 1
		return 1
	return 0

/obj/mecha/proc/startMechWalking()

/obj/mecha/proc/stopMechWalking()
	icon_state = initial_icon

/obj/mecha/proc/mechturn(direction)
	dir = direction
	playsound(src,'sound/mecha/mechturn.ogg',40,1)
	return 1

/obj/mecha/proc/mechstep(direction)
	var/current_dir = dir
	set_glide_size(DELAY2GLIDESIZE(step_in))
	var/result = step(src,direction)
	if(lock_dir)
		dir = current_dir
	if(result)
	 playsound(src, get_sfx("mechstep"),40,1)
	return result


/obj/mecha/proc/mechsteprand()
	set_glide_size(DELAY2GLIDESIZE(step_in))
	var/result = step_rand(src)
	if(result)
	 playsound(src, get_sfx("mechstep"),40,1)
	return result

/obj/mecha/to_bump(atom/obstacle)
	.=..()
	if(ismovable(obstacle))
		var/atom/movable/A = obstacle
		if(!A.anchored)
			step(obstacle, src.dir)

/obj/mecha/throw_impact(atom/obstacle)
	var/breakthrough = 0
	if(istype(obstacle, /obj/structure/window/))
		var/obj/structure/window/W = obstacle
		W.shatter()
		breakthrough = 1

	else if(istype(obstacle, /obj/structure/grille/))
		var/obj/structure/grille/G = obstacle
		G.health = (0.25*initial(G.health))
		G.healthcheck()
		breakthrough = 1

	else if(istype(obstacle, /obj/structure/table))
		var/obj/structure/table/T = obstacle
		T.destroy()
		breakthrough = 1

	else if(istype(obstacle, /obj/structure/rack))
		new /obj/item/weapon/rack_parts(obstacle.loc)
		qdel(obstacle)
		breakthrough = 1

	else if(istype(obstacle, /obj/structure/reagent_dispensers/fueltank))
		obstacle.ex_act(1)

	else if(istype(obstacle, /mob/living))
		var/mob/living/L = obstacle
		if (L.flags & INVULNERABLE)
			stopMechWalking()
			src.throwing = 0
			src.crashing = null
		else if (!(L.status_flags & CANKNOCKDOWN) || (M_HULK in L.mutations) || istype(L,/mob/living/silicon))
			//can't be knocked down? you'll still take the damage.
			stopMechWalking()
			src.throwing = 0
			src.crashing = null
			L.take_overall_damage(5,0)
			if(L.locked_to)
				L.locked_to.unlock_atom(L)
		else
			var/hit_sound = list('sound/weapons/genhit1.ogg','sound/weapons/genhit2.ogg','sound/weapons/genhit3.ogg')
			L.take_overall_damage(5,0)
			if(L.locked_to)
				L.locked_to.unlock_atom(L)
			L.Stun(5)
			L.Knockdown(5)
			L.apply_effect(5, STUTTER)
			playsound(src, pick(hit_sound), 50, 0, 0)
			breakthrough = 1
	else
		stopMechWalking()
		src.throwing = 0//so mechas don't get stuck when landing after being sent by a Mass Driver
		src.crashing = null

	if(breakthrough)
		if(crashing && !istype(crashing,/turf/space))
			spawn(1)
				src.throw_at(crashing, 50, src.throw_speed)
		else
			spawn(1)
				crashing = get_distant_turf(get_turf(src), dir, 3)//don't use get_dir(src, obstacle) or the mech will stop if he bumps into a one-direction window on his tile.
				src.throw_at(crashing, 50, src.throw_speed)

///////////////////////////////////
////////  Internal damage  ////////
///////////////////////////////////

/obj/mecha/proc/check_for_internal_damage(var/list/possible_int_damage,var/ignore_threshold=null)
	if(!islist(possible_int_damage) || isemptylist(possible_int_damage))
		return
	if(prob(20))
		if(ignore_threshold || src.health*100/initial(src.health)<src.internal_damage_threshold)
			for(var/T in possible_int_damage)
				if(internal_damage & T)
					possible_int_damage -= T
			var/int_dam_flag = safepick(possible_int_damage)
			if(int_dam_flag)
				setInternalDamage(int_dam_flag)
	if(prob(5))
		if(ignore_threshold || src.health*100/initial(src.health)<src.internal_damage_threshold)
			var/obj/item/mecha_parts/mecha_equipment/destr = safepick(equipment)
			if(destr)
				qdel(destr)
	return

/obj/mecha/proc/hasInternalDamage(int_dam_flag=null)
	return int_dam_flag ? internal_damage&int_dam_flag : internal_damage


/obj/mecha/proc/setInternalDamage(int_dam_flag)
	internal_damage |= int_dam_flag
	pr_internal_damage.start()
	log_append_to_last("Internal damage of type [int_dam_flag].",1)
	occupant << sound('sound/machines/warning.ogg',wait=0)
	return

/obj/mecha/proc/clearInternalDamage(int_dam_flag)
	internal_damage &= ~int_dam_flag
	switch(int_dam_flag)
		if(MECHA_INT_TEMP_CONTROL)
			occupant_message("<span class='notice'><b>Life support system reactivated.</b></span>")
			pr_int_temp_processor.start()
		if(MECHA_INT_FIRE)
			occupant_message("<span class='notice'><b>Internal fire extinquished.</b></span>")
		if(MECHA_INT_TANK_BREACH)
			occupant_message("<span class='notice'><b>Damaged internal tank has been sealed.</b></span>")
	return


////////////////////////////////////////
////////  Health related procs  ////////
////////////////////////////////////////

/obj/mecha/proc/take_damage(amount, type="brute")
	if(amount)
		var/damage = absorbDamage(amount,type)
		health -= damage
		update_health()
		log_append_to_last("Took [damage] points of damage. Damage type: \"[type]\".",1)
	return

/obj/mecha/proc/absorbDamage(damage,damage_type)
	return call((proc_res["dynabsorbdamage"]||src), "dynabsorbdamage")(damage,damage_type)

/obj/mecha/proc/dynabsorbdamage(damage,damage_type)
	return damage*(listgetindex(damage_absorption,damage_type) || 1)


/obj/mecha/proc/update_health()
	if(src.health > 0)
		spark(src, 2, FALSE)
	else
		qdel(src)

/obj/mecha/attack_hand(mob/living/user as mob, monkey = FALSE)
	if(monkey)
		src.log_message("Attack by paw. Attacker - [user].",1)
	else
		src.log_message("Attack by hand. Attacker - [user].",1)
	var/obj/item/mecha_parts/mecha_equipment/passive/rack/R = get_equipment(/obj/item/mecha_parts/mecha_equipment/passive/rack)
	if(R && operation_allowed(user))
		R.rack.AltClick(user)
		return
	user.do_attack_animation(src, user)
	if ((M_HULK in user.mutations) && !prob(src.deflect_chance))
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
	user.do_attack_animation(src, user)
	src.log_message("Attack by alien. Attacker - [user].",1)
	if(!prob(src.deflect_chance))
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
	user.do_attack_animation(src, user)
	src.log_message("Attack by simple animal. Attacker - [user].",1)
	if(user.melee_damage_upper == 0)
		user.emote("[user.friendly] [src]")
	else
		add_logs(user, src, "attacked", admin = user.ckey ? TRUE : FALSE) //Only add this to the server logs if they're controlled by a player.
		if(!prob(src.deflect_chance))
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
	if(istype(A, /obj/item/mecha_parts/mecha_tracking) && !tracking && prob(25))
		A.forceMove(src)
		tracking = A
		src.visible_message("The [A] fastens firmly to [src].")
		return
	if(prob(src.deflect_chance) || istype(A, /mob))
		src.occupant_message("<span class='notice'>The [A] bounces off the armor.</span>")
		src.visible_message("The [A] bounces off the [src.name] armor")
		src.log_append_to_last("Armor saved.")
		if(istype(A, /mob/living))
			var/mob/living/M = A
			M.take_organ_damage(10)
	else if(istype(A, /obj))
		var/obj/O = A
		if(O.throwforce)
			src.take_damage(O.throwforce)
			src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	return


/obj/mecha/bullet_act(var/obj/item/projectile/Proj) //wrapper
	src.log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).",1)
	call((proc_res["dynbulletdamage"]||src), "dynbulletdamage")(Proj) //calls equipment
	return ..()

/obj/mecha/proc/dynbulletdamage(var/obj/item/projectile/Proj)
	if(prob(src.deflect_chance) && !is_type_in_list(Proj, never_deflect))
		src.occupant_message("<span class='notice'>The armor deflects incoming projectile.</span>")
		src.visible_message("<span class='warning'>\The [src.name] armor deflects the projectile.</span>")
		src.log_append_to_last("Armor saved.")
		return
	var/ignore_threshold
	if(Proj.flag == "taser")
		use_power(200)
		return
	if(istype(Proj, /obj/item/projectile/beam/pulse))
		ignore_threshold = 1
	src.take_damage(Proj.damage,Proj.flag)
	src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),ignore_threshold)
	Proj.on_hit(src)
	return

/obj/mecha/ex_act(severity)
	src.log_message("Affected by explosion of severity: [severity].",1)
	if(prob(src.deflect_chance))
		severity++
		src.log_append_to_last("Armor saved, changing severity to [severity].")
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(30))
				qdel(src)
			else
				src.take_damage(initial(src.health)/2)
				src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
		if(3.0)
			if (prob(5))
				qdel(src)
			else
				src.take_damage(initial(src.health)/5)
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
	take_damage(30, "brute")
	return

/obj/mecha/emp_act(severity)
	if(get_charge())
		cell.emp_act(severity*1.25)
		take_damage(50 / severity,"energy")
	src.log_message("EMP detected",1)
	check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
	for(var/obj/item/mecha_parts/mecha_equipment/M in equipment)
		M.emp_act(severity)
	return

/obj/mecha/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature>src.max_temperature)
		src.log_message("Exposed to dangerous temperature.",1)
		src.take_damage(5,"fire")
		src.check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL))
	return

/obj/mecha/proc/dynattackby(obj/item/weapon/W as obj, mob/living/user as mob)
	user.delayNextAttack(8)
	user.do_attack_animation(src, W)
	src.log_message("Attacked by [W]. Attacker - [user]")
	if(prob(src.deflect_chance))
		to_chat(user, "<span class='attack'>The [W] bounces off [src.name] armor.</span>")
		src.log_append_to_last("Armor saved.")
/*
		for (var/mob/V in viewers(src))
			if(V.client && !(V.blinded))
				V.show_message("The [W] bounces off [src.name] armor.", 1)
*/
	else
		src.occupant_message("<span class='red'><b>[user] hits [src] with [W].</b></span>")
		user.visible_message("<span class='red'><b>[user] hits [src] with [W].</b></span>", "<span class='red'><b>You hit [src] with [W].</b></span>")
		src.take_damage(W.force,W.damtype)
		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	return

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
				if(user.drop_item(W))
					E.attach(src)
					user.visible_message("[user] attaches [W] to [src]", "You attach [W] to [src]")
					playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			else
				to_chat(user, "You were unable to attach [W] to [src]")
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
			to_chat(user, "You undo the securing bolts.")
			W.playtoolsound(src, 50)
		else if(state==STATE_BOLTSOPENED)
			state = STATE_BOLTSEXPOSED
			to_chat(user, "You tighten the securing bolts.")
			W.playtoolsound(src, 50)
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

	else if(iswelder(W) && user.a_intent != I_HURT)
		var/obj/item/tool/weldingtool/WT = W
		if (WT.remove_fuel(0,user))
			if (hasInternalDamage(MECHA_INT_TANK_BREACH))
				clearInternalDamage(MECHA_INT_TANK_BREACH)
				to_chat(user, "<span class='notice'>You repair the damaged gas tank.</span>")
		else
			return
		if(src.health<initial(src.health))
			to_chat(user, "<span class='notice'>You repair some damage to [src.name].</span>")
			src.health += min(10, initial(src.health)-src.health)
		else
			to_chat(user, "The [src.name] is at full integrity")
		return

	else
		call((proc_res["dynattackby"]||src), "dynattackby")(W,user)
/*
		src.log_message("Attacked by [W]. Attacker - [user]")
		if(prob(src.deflect_chance))
			to_chat(user, "<span class='warning'>The [W] bounces off [src.name] armor.</span>")
			src.log_append_to_last("Armor saved.")
/*
			for (var/mob/V in viewers(src))
				if(V.client && !(V.blinded))
					V.show_message("The [W] bounces off [src.name] armor.", 1)
*/
		else
			src.occupant_message("<span class='red'><b>[user] hits [src] with [W].</b></span>")
			user.visible_message("<span class='red'><b>[user] hits [src] with [W].</b></span>", "<span class='red'><b>You hit [src] with [W].</b></span>")
			src.take_damage(W.force,W.damtype)
			src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
*/
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
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/mecha/proc/return_pressure()
	. = 0
	if(use_internal_tank)
		. =  cabin_air.return_pressure()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_pressure()
	return

//skytodo: //No idea what you want me to do here, mate.
/obj/mecha/proc/return_temperature()
	. = 0
	if(use_internal_tank)
		. = cabin_air.return_temperature()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_temperature()
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
		if(do_after(usr, src, 40))
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
	else if(dna && dna!=mmi_as_oc.brainmob.dna.unique_enzymes)
		to_chat(user, "Stop it!")
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
		src.icon_state = src.initial_icon
		if(!lights) //if the main lights are off, turn on cabin lights
			light_power = light_brightness_off
			set_light(light_range_off)
		dir = dir_in
		src.log_message("[mmi_as_oc] moved in as pilot.")
		if(!hasInternalDamage())
			src.occupant << sound('sound/mecha/nominalsyndi.ogg',volume=50)

		//change the cursor
		if(occupant.client && cursor_enabled)
			occupant.client.mouse_pointer_icon = file("icons/mouse/mecha_mouse.dmi")

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

/*
/obj/mecha/verb/force_eject()
	set category = "Object"
	set name = "Force Eject"
	set src in view(5)
	src.go_out()
	return
*/

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

/obj/mecha/proc/go_out(var/exit = loc, var/exploding = FALSE)
	if(!occupant)
		return

	if(lock_controls) //No ejecting while using the Gravpult!
		return

	if(!exploding && exit == loc) //We don't actually want to eject our occupant on the same tile that we are, that puts them "under" us, which lets them use the mech like a personal forcefield they can shoot out of.
		var/list/turf_candidates = list(get_step(loc, dir)) + trange(1, loc) //Evaluate all 9 turfs around us, but put "directly in front of us" as the first choice.
		for(var/turf/simulated/T in turf_candidates)
			if(!is_blocked_turf(T) && Adjacent(T))
				exit = T
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
	if(mob_container.forceMove(exit))//ejecting mob container
		log_message("[mob_container] moved out.")
		occupant.reset_view()
		empty_bad_contents()
		occupant << browse(null, "window=exosuit")
		remove_mech_spells()
		if(istype(mob_container, /obj/item/device/mmi) || istype(mob_container, /obj/item/device/mmi/posibrain))
			var/obj/item/device/mmi/mmi = mob_container
			if(mmi.brainmob)
				occupant.forceMove(mmi)
				mech_parts.Remove(mmi)
			occupant.canmove = FALSE
			mmi.mecha = null
			verbs += /obj/mecha/verb/eject

		//change the cursor
		if(occupant && occupant.client)
			occupant.client.mouse_pointer_icon = initial(occupant.client.mouse_pointer_icon)

		occupant = null
		icon_state = initial_icon+"-open"
		if(!lights) //if the lights are off, turn off the cabin lights
			kill_light()
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


////////////////////////////////////
///// Rendering stats window ///////
////////////////////////////////////

/obj/mecha/proc/get_stats_html()
	var/output = {"<html>
						<head><title>[src.name] data</title>
						<style>
						body {color: #00ff00; background: #000000; font-family:"Lucida Console",monospace; font-size: 12px;}
						hr {border: 1px solid #0f0; color: #0f0; background-color: #0f0;}
						a {padding:2px 5px;;color:#0f0;}
						.wr {margin-bottom: 5px;}
						.header {cursor:pointer;}
						.open, .closed {background: #32CD32; color:#000; padding:1px 2px;}
						.links a {margin-bottom: 2px;padding-top:3px;}
						.visible {display: block;}
						.hidden {display: none;}
						</style>
						<script language='javascript' type='text/javascript'>
						[js_byjax]
						[js_dropdowns]
						function ticker() {
						    setInterval(function(){
						        window.location='byond://?src=\ref[src]&update_content=1';
						    }, 1000);
						}

						window.onload = function() {
							dropdowns();
							ticker();
						}
						</script>
						</head>
						<body>
						<div id='content'>
						[src.get_stats_part()]
						</div>
						<div id='eq_list'>
						[src.get_equipment_list()]
						</div>
						<hr>
						<div id='commands'>
						[src.get_commands()]
						</div>
						</body>
						</html>
					 "}
	return output


/obj/mecha/proc/report_internal_damage()
	var/output = null
	var/list/dam_reports = list(
										"[MECHA_INT_FIRE]" = "<font color='red'><b>INTERNAL FIRE</b></font>",
										"[MECHA_INT_TEMP_CONTROL]" = "<font color='red'><b>LIFE SUPPORT SYSTEM MALFUNCTION</b></font>",
										"[MECHA_INT_TANK_BREACH]" = "<font color='red'><b>GAS TANK BREACH</b></font>",
										"[MECHA_INT_CONTROL_LOST]" = "<font color='red'><b>COORDINATION SYSTEM CALIBRATION FAILURE</b></font> - <a href='?src=\ref[src];repair_int_control_lost=1'>Recalibrate</a>",
										"[MECHA_INT_SHORT_CIRCUIT]" = "<font color='red'><b>SHORT CIRCUIT</b></font>"
										)
	for(var/tflag in dam_reports)
		var/intdamflag = text2num(tflag)
		if(hasInternalDamage(intdamflag))
			output += dam_reports[tflag]
			output += "<br />"
	if(return_pressure() > WARNING_HIGH_PRESSURE)
		output += "<font color='red'><b>DANGEROUSLY HIGH CABIN PRESSURE</b></font><br />"
	return output


/obj/mecha/proc/get_stats_part()
	var/integrity = health/initial(health)*100
	var/cell_charge = get_charge()
	var/tank_pressure = internal_tank ? round(internal_tank.return_pressure(),0.01) : "None"
	var/tank_temperature = internal_tank ? internal_tank.return_temperature() : "Unknown"
	var/cabin_pressure = round(return_pressure(),0.01)
	var/output = {"[report_internal_damage()]
						[integrity<30?"<font color='red'><b>DAMAGE LEVEL CRITICAL</b></font><br>":null]
						<b>Integrity: </b> [integrity]%<br>
						<b>Powercell charge: </b>[isnull(cell_charge)?"No powercell installed":"[cell.percent()]%"]<br>
						<b>Air source: </b>[use_internal_tank?"Internal Airtank":"Environment"]<br>
						<b>Airtank pressure: </b>[tank_pressure]kPa<br>
						<b>Airtank temperature: </b>[tank_temperature]K|[tank_temperature - T0C]&deg;C<br>
						<b>Cabin pressure: </b>[cabin_pressure>WARNING_HIGH_PRESSURE ? "<font color='red'>[cabin_pressure]</font>": cabin_pressure]kPa<br>
						<b>Cabin temperature: </b> [return_temperature()]K|[return_temperature() - T0C]&deg;C<br>
						<b>Lights: </b>[lights?"on":"off"]<br>
						[src.dna?"<b>DNA-locked:</b><br> <span style='font-size:10px;letter-spacing:-1px;'>[src.dna]</span> \[<a href='?src=\ref[src];reset_dna=1'>Reset</a>\]<br>":null]
					"}
	return output

/obj/mecha/proc/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Electronics</div>
						<div class='links'>
						<a href='?src=\ref[src];toggle_lights=1'>Toggle Lights</a><br>
						<a href='?src=\ref[src];toggle_cursor=1'>Toggle Cursor</a><br>
						<b>Radio settings:</b><br>
						Microphone: <a href='?src=\ref[src];rmictoggle=1'><span id="rmicstate">[radio.broadcasting?"Engaged":"Disengaged"]</span></a><br>
						Speaker: <a href='?src=\ref[src];rspktoggle=1'><span id="rspkstate">[radio.listening?"Engaged":"Disengaged"]</span></a><br>
						Frequency:
						<a href='?src=\ref[src];rfreq=-10'>-</a>
						<a href='?src=\ref[src];rfreq=-2'>-</a>
						<span id="rfreq">[format_frequency(radio.frequency)]</span>
						<a href='?src=\ref[src];rfreq=2'>+</a>
						<a href='?src=\ref[src];rfreq=10'>+</a><br>
						Subspace transmission: <a href='?src=\ref[src];subtoggle=1'><span id="substate">[radio.subspace_transmission?"Enabled":"Disabled"]</span></a><br>
						</div>
						</div>
						<div class='wr'>
						<div class='header'>Airtank</div>
						<div class='links'>
						<a href='?src=\ref[src];toggle_airtank=1'>Toggle Internal Airtank Usage</a><br>
						[(/obj/mecha/verb/disconnect_from_port in src.verbs)?"<a href='?src=\ref[src];port_disconnect=1'>Disconnect from port</a><br>":null]
						[(/obj/mecha/verb/connect_to_port in src.verbs)?"<a href='?src=\ref[src];port_connect=1'>Connect to port</a><br>":null]
						</div>
						</div>
						<div class='wr'>
						<div class='header'>Permissions & Logging</div>
						<div class='links'>
						<a href='?src=\ref[src];toggle_id_upload=1'><span id='t_id_upload'>[add_req_access?"L":"Unl"]ock ID upload panel</span></a><br>
						<a href='?src=\ref[src];toggle_maint_access=1'><span id='t_maint_access'>[maint_access?"Forbid":"Permit"] maintenance protocols</span></a><br>
						<a href='?src=\ref[src];dna_lock=1'>DNA-lock</a><br>
						<a href='?src=\ref[src];view_log=1'>View internal log</a><br>
						<a href='?src=\ref[src];change_name=1'>Change exosuit name</a><br>
						</div>
						</div>
						<div id='equipment_menu'>[get_equipment_menu()]</div>
						<hr>
						[(/obj/mecha/verb/eject in src.verbs)?"<a href='?src=\ref[src];eject=1'>Eject</a><br>":null]
						"}
	return output

/obj/mecha/proc/get_equipment_menu() //outputs mecha html equipment menu
	var/output
	if(equipment.len)
		output += {"<div class='wr'>
						<div class='header'>Equipment</div>
						<div class='links'>"}
		for(var/obj/item/mecha_parts/mecha_equipment/W in equipment)
			output += "[W.name] <a href='?src=\ref[W];detach=1'>Detach</a><br>"

		output += {"<b>Available equipment slots:</b> [max_equip-equipment.len]
			</div></div>"}
	return output

/obj/mecha/proc/get_equipment_list() //outputs mecha equipment list in html
	if(!equipment.len)
		return
	var/output = "<b>Equipment:</b><div style=\"margin-left: 15px;\">"
	for(var/obj/item/mecha_parts/mecha_equipment/MT in equipment)
		output += "<div id='\ref[MT]'>[MT.get_equip_info()]</div>"
	output += "</div>"
	return output

//returns an equipment object if we have one of that type, useful since is_type_in_list won't return the object
//since is_type_in_list uses caching, this is a slower operation, so only use it if needed
/obj/mecha/proc/get_equipment(var/equip_type)
	for(var/obj/item/mecha_parts/mecha_equipment/ME in equipment)
		if(istype(ME,equip_type))
			return ME
	return null

/obj/mecha/proc/get_log_html()
	var/output = "<html><head><title>[src.name] Log</title></head><body style='font: 13px 'Courier', monospace;'>"
	for(var/list/entry in log)
		output += {"<div style='font-weight: bold;'>[time2text(entry["time"],"DDD MMM DD hh:mm:ss")] [game_year]</div>
						<div style='margin-left:15px; margin-bottom:10px;'>[entry["message"]]</div>
						"}
	output += "</body></html>"
	return output


/obj/mecha/proc/output_access_dialog(obj/item/weapon/card/id/id_card, mob/user)
	if(!id_card || !user)
		return
	var/output = {"<html>
						<head><style>
						h1 {font-size:15px;margin-bottom:4px;}
						body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
						a {color:#0f0;}
						</style>
						</head>
						<body>
						<h1>Following keycodes are present in this system:</h1>"}

	for(var/a in operation_req_access)
		output += "[get_access_desc(a)] - <a href='?src=\ref[src];del_req_access=[a];user=\ref[user];id_card=\ref[id_card]'>Delete</a><br>"

	output += "<a href='?src=\ref[src];del_all_req_access=1;user=\ref[user];id_card=\ref[id_card]'><br><b>Delete All</b></a><br>"

	output += "<hr><h1>Following keycodes were detected on portable device:</h1>"
	for(var/a in id_card.access)
		if(a in operation_req_access)
			continue
		if(!get_access_desc(a))
			continue //there's some strange access without a name
		output += "[get_access_desc(a)] - <a href='?src=\ref[src];add_req_access=[a];user=\ref[user];id_card=\ref[id_card]'>Add</a><br>"

	output += "<a href='?src=\ref[src];add_all_req_access=1;user=\ref[user];id_card=\ref[id_card]'><br><b>Add All</b></a><br>"

	output += {"<hr><a href='?src=\ref[src];finish_req_access=1;user=\ref[user]'>Finish</a> <font color='red'>(Warning! The ID upload panel will be locked. It can be unlocked only through Exosuit Interface.)</font>
		</body></html>"}
	user << browse(output, "window=exosuit_add_access")
	onclose(user, "exosuit_add_access")
	return

/obj/mecha/proc/output_maintenance_dialog(obj/item/weapon/card/id/id_card,mob/user)
	if(!id_card || !user)
		return
	var/output = {"<html>
						<head>
						<style>
						body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
						a {padding:2px 5px; background:#32CD32;color:#000;display:block;margin:2px;text-align:center;text-decoration:none;}
						</style>
						</head>
						<body>
						[add_req_access?"<a href='?src=\ref[src];req_access=1;id_card=\ref[id_card];user=\ref[user]'>Edit operation keycodes</a>":null]
						[maint_access?"<a href='?src=\ref[src];maint_access=1;id_card=\ref[id_card];user=\ref[user]'>[state ? "Terminate" : "Initiate"] maintenance protocol</a>":null]
						[(state>0) ?"<a href='?src=\ref[src];set_internal_tank_valve=1;user=\ref[user]'>Set Cabin Air Pressure</a>\
						<a href='?src=\ref[src];eject=1'>Eject Occupant</a>":null]
						</body>
						</html>"}
	user << browse(output, "window=exosuit_maint_console")
	onclose(user, "exosuit_maint_console")
	return


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


/////////////////
///// Topic /////
/////////////////

/obj/mecha/Topic(href, href_list)
	..()
	if(href_list["update_content"])
		if(usr != src.occupant)
			return
		send_byjax(src.occupant,"exosuit.browser","content",src.get_stats_part())
		return
	if(href_list["close"])
		return
	if(usr.isUnconscious())
		return
	var/datum/topic_input/topic_filter = new /datum/topic_input(href,href_list)
	if(href_list["select_equip"])
		if(usr != src.occupant)
			return
		var/obj/item/mecha_parts/mecha_equipment/equip = topic_filter.getObj("select_equip")
		if(equip)
			src.selected = equip
			src.occupant_message("You switch to [equip]")
			src.visible_message("[src] raises [equip]")
			send_byjax(src.occupant,"exosuit.browser","eq_list",src.get_equipment_list())
		return
	if(href_list["eject"])
		if(usr != src.occupant && (get_dist(usr, src) > 1 || state != STATE_BOLTSEXPOSED))
			return
		go_out()
	if(href_list["toggle_lights"])
		if(usr != src.occupant)
			return
		src.toggle_lights()
		return
	if (href_list["toggle_cursor"])
		if(usr != src.occupant)
			return
		src.toggle_cursor()
		return
	if(href_list["toggle_airtank"])
		if(usr != src.occupant)
			return
		src.toggle_internal_tank()
		return
	if(href_list["rmictoggle"])
		if(usr != src.occupant)
			return
		radio.broadcasting = !radio.broadcasting
		send_byjax(src.occupant,"exosuit.browser","rmicstate",(radio.broadcasting?"Engaged":"Disengaged"))
		return
	if(href_list["rspktoggle"])
		if(usr != src.occupant)
			return
		radio.listening = !radio.listening
		send_byjax(src.occupant,"exosuit.browser","rspkstate",(radio.listening?"Engaged":"Disengaged"))
		return
	if(href_list["rfreq"])
		if(usr != src.occupant)
			return
		var/new_frequency = (radio.frequency + topic_filter.getNum("rfreq"))
		if (!radio.freerange || (radio.frequency < 1200 || radio.frequency > 1600))
			new_frequency = sanitize_frequency(new_frequency)
		radio.set_frequency(new_frequency)
		send_byjax(src.occupant,"exosuit.browser","rfreq","[format_frequency(radio.frequency)]")
		return
	if (href_list["subtoggle"])
		if(usr != src.occupant)
			return
		radio.subspace_transmission = !radio.subspace_transmission
		send_byjax(src.occupant,"exosuit.browser","substate",(radio.subspace_transmission?"Enabled":"Disabled"))
		return
	if(href_list["port_disconnect"])
		if(usr != src.occupant)
			return
		src.disconnect_from_port()
		return
	if (href_list["port_connect"])
		if(usr != src.occupant)
			return
		src.connect_to_port()
		return
	if (href_list["view_log"])
		if(usr != src.occupant)
			return
		src.occupant << browse(src.get_log_html(), "window=exosuit_log")
		onclose(occupant, "exosuit_log")
		return
	if (href_list["change_name"])
		if(usr != src.occupant)
			return
		var/newname = stripped_input(occupant,"Choose new exosuit name","Rename exosuit",initial(name),MAX_NAME_LEN)
		if(newname && trim(newname))
			name = newname
		else
			alert(occupant, "nope.avi")
		return
	if (href_list["toggle_id_upload"])
		if(usr != src.occupant)
			return
		add_req_access = !add_req_access
		send_byjax(src.occupant,"exosuit.browser","t_id_upload","[add_req_access?"L":"Unl"]ock ID upload panel")
		return
	if(href_list["toggle_maint_access"])
		if(usr != src.occupant)
			return
		if(state)
			occupant_message("<span class='red'>Maintenance protocols in effect.</span>")
			return
		maint_access = !maint_access
		send_byjax(src.occupant,"exosuit.browser","t_maint_access","[maint_access?"Forbid":"Permit"] maintenance protocols")
		return
	if(href_list["req_access"] && add_req_access)
		if(!in_range(src, usr))
			return
		output_access_dialog(topic_filter.getObj("id_card"),topic_filter.getMob("user"))
		return
	if(href_list["maint_access"] && maint_access)
		if(!in_range(src, usr))
			return
		var/mob/user = topic_filter.getMob("user")
		if(user)
			if(state==STATE_BOLTSHIDDEN)
				state = STATE_BOLTSEXPOSED
				to_chat(user, "The securing bolts are now exposed.")
				log_message("Maintenance protocols engaged.")
				if(occupant)
					occupant_message("<span class='red'>Maintenance protocols engaged.</span>")
					occupant << sound('sound/mecha/mechlockdown.ogg',wait=0)
			else if(state==STATE_BOLTSEXPOSED)
				state = STATE_BOLTSHIDDEN
				to_chat(user, "The securing bolts are now hidden.")
				log_message("Maintenance protocols terminated.")
				if(occupant)
					occupant_message("Maintenance protocols terminated.")
					occupant << sound('sound/mecha/mechentry.ogg',wait=0)
			else
				to_chat(user, "You can't toggle maintenance mode with the securing bolts unfastened.")
			output_maintenance_dialog(topic_filter.getObj("id_card"),user)
		return
	if(href_list["set_internal_tank_valve"] && state >=STATE_BOLTSEXPOSED)
		if(!in_range(src, usr))
			return
		var/mob/user = topic_filter.getMob("user")
		if(user)
			var/new_pressure = input(user,"Input new output pressure","Pressure setting",internal_tank_valve) as num
			if(new_pressure)
				internal_tank_valve = new_pressure
				to_chat(user, "The internal pressure valve has been set to [internal_tank_valve]kPa.")
	if(href_list["add_req_access"] && add_req_access && topic_filter.getObj("id_card"))
		if(!in_range(src, usr))
			return
		operation_req_access += topic_filter.getNum("add_req_access")
		output_access_dialog(topic_filter.getObj("id_card"),topic_filter.getMob("user"))
		return
	if(href_list["add_all_req_access"] && add_req_access && topic_filter.getObj("id_card"))
		if(!in_range(src, usr))
			return
		var/obj/item/weapon/card/id/mycard = topic_filter.getObj("id_card")
		var/list/myaccess = mycard.access
		for(var/a in myaccess)
			operation_req_access += a
		output_access_dialog(topic_filter.getObj("id_card"),topic_filter.getMob("user"))
		return
	if(href_list["del_req_access"] && add_req_access && topic_filter.getObj("id_card"))
		if(!in_range(src, usr))
			return
		operation_req_access -= topic_filter.getNum("del_req_access")
		output_access_dialog(topic_filter.getObj("id_card"),topic_filter.getMob("user"))
		return
	if(href_list["del_all_req_access"] && add_req_access && topic_filter.getObj("id_card"))
		if(!in_range(src, usr))
			return
		operation_req_access = list()
		output_access_dialog(topic_filter.getObj("id_card"),topic_filter.getMob("user"))
		return
	if(href_list["finish_req_access"])
		if(!in_range(src, usr))
			return
		add_req_access = 0
		var/mob/user = topic_filter.getMob("user")
		user << browse(null,"window=exosuit_add_access")
		return
	if(href_list["dna_lock"])
		if(usr != src.occupant)
			return
		if(src.occupant && (!istype(src.occupant, /obj/item/device/mmi/posibrain) || !istype(src.occupant, /obj/item/device/mmi)))
			src.dna = src.occupant.dna.unique_enzymes
			src.occupant_message("You feel a prick as the needle takes your DNA sample.")
		return
	if(href_list["reset_dna"])
		if(usr != src.occupant)
			return
		src.dna = null
	if(href_list["repair_int_control_lost"])
		if(usr != src.occupant)
			return
		src.occupant_message("Recalibrating coordination system.")
		src.log_message("Recalibration of coordination system started.")
		var/T = src.loc
		sleep(100)
		if(!src)
			return
		if(T == src.loc)
			src.clearInternalDamage(MECHA_INT_CONTROL_LOST)
			src.occupant_message("<span class='notice'>Recalibration successful.</span>")
			src.log_message("Recalibration of coordination system finished with 0 errors.")
		else
			src.occupant_message("<span class='red'>Recalibration failed.</span>")
			src.log_message("Recalibration of coordination system failed with 1 error.",1)

	//debug
	/*
	if(href_list["debug"])
		if(href_list["set_i_dam"])
			setInternalDamage(topic_filter.getNum("set_i_dam"))
		if(href_list["clear_i_dam"])
			clearInternalDamage(topic_filter.getNum("clear_i_dam"))
		return
	*/



/*

	if (href_list["ai_take_control"])
		var/mob/living/silicon/ai/AI = locate(href_list["ai_take_control"])
		var/duration = text2num(href_list["duration"])
		var/mob/living/silicon/ai/O = new /mob/living/silicon/ai(src)
		var/cur_occupant = src.occupant
		O.invisibility = 0
		O.canmove = 1
		O.name = AI.name
		O.real_name = AI.real_name
		O.anchored = 1
		O.aiRestorePowerRoutine = 0
		O.control_disabled = 1 // Can't control things remotely if you're stuck in a card!
		O.laws = AI.laws
		O.stat = AI.stat
		O.oxyloss = AI.getOxyLoss()
		O.fireloss = AI.getFireLoss()
		O.bruteloss = AI.getBruteLoss()
		O.toxloss = AI.toxloss
		O.updatehealth()
		src.occupant = O
		if(AI.mind)
			AI.mind.transfer_to(O)
		AI.name = "Inactive AI"
		AI.real_name = "Inactive AI"
		AI.icon_state = "ai-empty"
		spawn(duration)
			AI.name = O.name
			AI.real_name = O.real_name
			if(O.mind)
				O.mind.transfer_to(AI)
			AI.control_disabled = 0
			AI.laws = O.laws
			AI.oxyloss = O.getOxyLoss()
			AI.fireloss = O.getFireLoss()
			AI.bruteloss = O.getBruteLoss()
			AI.toxloss = O.toxloss
			AI.updatehealth()
			del(O)
			if (!AI.stat)
				AI.icon_state = "ai"
			else
				AI.icon_state = "ai-crash"
			src.occupant = cur_occupant
*/
	return

//////////////////////
/////// Spells ///////
//////////////////////
/spell/mech
	user_type = USER_TYPE_MECH
	range = 0
	invocation = "none"
	invocation_type = SpI_NONE
	panel = "Mech Modules"
	spell_flags = null
	charge_type = Sp_RECHARGE
	charge_max = 0
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
	charge_counter = charge_max
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
	if(get_charge())
		cell.use(amount)
		return 1
	return 0

/obj/mecha/proc/give_power(amount)
	if(!isnull(get_charge()))
		cell.give(amount)
		return 1
	return 0

/obj/mecha/acidable()
	return 0

/obj/mecha/beam_connect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)


/obj/mecha/beam_disconnect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)

/obj/mecha/apply_beam_damage(var/obj/effect/beam/B)
	// Actually apply damage
	take_damage(B.get_damage(), "emitter laser")

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

	if(icontype == M.initial_icon)
		to_chat(user, "<span class='warning'>This mech is already painted in that style.</span>")
		return 1
	if(icontype)
		to_chat(user, "<span class='info'>You begin repainting the mech.</span>")
		if (do_after(user, M , 30))
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
					qdel(removed)
					removed = null
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
				int_tank_air.temperature = min(6000+T0C, int_tank_air.temperature+rand(10,15))
		if(mecha.cabin_air && mecha.cabin_air.return_volume()>0)
			mecha.cabin_air.temperature = min(6000+T0C, mecha.cabin_air.return_temperature()+rand(10,15))
			if(mecha.cabin_air.return_temperature()>mecha.max_temperature/2)
				mecha.take_damage(4/round(mecha.max_temperature/mecha.cabin_air.return_temperature(),0.1),"fire")
	if(mecha.hasInternalDamage(MECHA_INT_TEMP_CONTROL)) //stop the mecha_preserve_temp loop datum
		mecha.pr_int_temp_processor.stop()
	if(mecha.hasInternalDamage(MECHA_INT_TANK_BREACH)) //remove some air from internal tank
		if(mecha.internal_tank)
			var/datum/gas_mixture/int_tank_air = mecha.internal_tank.return_air()
			var/datum/gas_mixture/leaked_gas = int_tank_air.remove_ratio(0.10)
			if(mecha.loc && hascall(mecha.loc,"assume_air"))
				mecha.loc.assume_air(leaked_gas)
			else
				qdel(leaked_gas)
				leaked_gas = null
	if(mecha.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
		if(mecha.get_charge())
			spark(mecha, 2, FALSE)
			mecha.cell.charge -= min(20,mecha.cell.charge)
			mecha.cell.maxcharge -= min(20,mecha.cell.maxcharge)


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

#undef STATE_BOLTSHIDDEN
#undef STATE_BOLTSEXPOSED
#undef STATE_BOLTSOPENED
