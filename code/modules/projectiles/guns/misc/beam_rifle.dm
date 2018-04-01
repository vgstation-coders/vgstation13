
#define ZOOM_LOCK_AUTOZOOM_FREEMOVE 0
#define ZOOM_LOCK_AUTOZOOM_ANGLELOCK 1
#define ZOOM_LOCK_CENTER_VIEW 2
#define ZOOM_LOCK_OFF 3

#define AUTOZOOM_PIXEL_STEP_FACTOR 48

#define AIMING_BEAM_ANGLE_CHANGE_THRESHOLD 0.1

/obj/item/gun/energy/beam_rifle
	name = "particle acceleration rifle"
	desc = "An energy-based anti material marksman rifle that uses highly charged particle beams moving at extreme velocities to decimate whatever is unfortunate enough to be targetted by one. \
		<span class='boldnotice'>Hold down left click while scoped to aim, when weapon is fully aimed (Tracer goes from red to green as it charges), release to fire. Moving while aiming or \
		changing where you're pointing at while aiming will delay the aiming process depending on how much you changed.</span>"
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "esniper"
	item_state = "esniper"
	fire_sound = 'sound/weapons/beam_sniper.ogg'
	slot_flags = SLOT_BACK
	force = 15
	materials = list()
	recoil = 4
	ammo_x_offset = 3
	ammo_y_offset = 3
	modifystate = FALSE
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/beam_rifle/hitscan)
	cell_type = /obj/item/stock_parts/cell/beam_rifle
	canMouseDown = TRUE
	pin = null
	var/aiming = FALSE
	var/aiming_time = 12
	var/aiming_time_fire_threshold = 5
	var/aiming_time_left = 12
	var/aiming_time_increase_user_movement = 3
	var/scoped_slow = 1
	var/aiming_time_increase_angle_multiplier = 0.3
	var/last_process = 0

	var/lastangle = 0
	var/aiming_lastangle = 0
	var/mob/current_user = null
	var/list/obj/effect/projectile/tracer/current_tracers

	var/structure_piercing = 2				//Amount * 2. For some reason structures aren't respecting this unless you have it doubled. Probably with the objects in question's Bump() code instead of this but I'll deal with this later.
	var/structure_bleed_coeff = 0.7
	var/wall_pierce_amount = 0
	var/wall_devastate = 0
	var/aoe_structure_range = 1
	var/aoe_structure_damage = 50
	var/aoe_fire_range = 2
	var/aoe_fire_chance = 40
	var/aoe_mob_range = 1
	var/aoe_mob_damage = 30
	var/impact_structure_damage = 60
	var/projectile_damage = 30
	var/projectile_stun = 0
	var/projectile_setting_pierce = TRUE
	var/delay = 65
	var/lastfire = 0

	//ZOOMING
	var/zoom_current_view_increase = 0
	var/zoom_target_view_increase = 10
	var/zooming = FALSE
	var/zoom_lock = ZOOM_LOCK_OFF
	var/zooming_angle
	var/current_zoom_x = 0
	var/current_zoom_y = 0
	var/zoom_animating = 0

	var/static/image/charged_overlay = image(icon = 'icons/obj/guns/energy.dmi', icon_state = "esniper_charged")
	var/static/image/drained_overlay = image(icon = 'icons/obj/guns/energy.dmi', icon_state = "esniper_empty")

	var/datum/action/item_action/zoom_lock_action/zoom_lock_action
	var/datum/component/mobhook

/obj/item/gun/energy/beam_rifle/debug
	delay = 0
	cell_type = /obj/item/stock_parts/cell/infinite
	aiming_time = 0
	recoil = 0
	pin = /obj/item/device/firing_pin

/obj/item/gun/energy/beam_rifle/equipped(mob/user)
	set_user(user)
	. = ..()

/obj/item/gun/energy/beam_rifle/pickup(mob/user)
	set_user(user)
	. = ..()

/obj/item/gun/energy/beam_rifle/dropped(mob/user)
	set_user()
	. = ..()

/obj/item/gun/energy/beam_rifle/ui_action_click(owner, action)
	if(istype(action, /datum/action/item_action/zoom_lock_action))
		zoom_lock++
		if(zoom_lock > 3)
			zoom_lock = 0
		switch(zoom_lock)
			if(ZOOM_LOCK_AUTOZOOM_FREEMOVE)
				to_chat(owner, "<span class='boldnotice'>You switch [src]'s zooming processor to free directional.</span>")
			if(ZOOM_LOCK_AUTOZOOM_ANGLELOCK)
				to_chat(owner, "<span class='boldnotice'>You switch [src]'s zooming processor to locked directional.</span>")
			if(ZOOM_LOCK_CENTER_VIEW)
				to_chat(owner, "<span class='boldnotice'>You switch [src]'s zooming processor to center mode.</span>")
			if(ZOOM_LOCK_OFF)
				to_chat(owner, "<span class='boldnotice'>You disable [src]'s zooming system.</span>")
	reset_zooming()

/obj/item/gun/energy/beam_rifle/proc/smooth_zooming(delay_override = null)
	if(!check_user() || !zooming || zoom_lock == ZOOM_LOCK_OFF || zoom_lock == ZOOM_LOCK_CENTER_VIEW)
		return
	if(zoom_animating && delay_override != 0)
		return smooth_zooming(zoom_animating + delay_override)	//Automatically compensate for ongoing zooming actions.
	var/total_time = SSfastprocess.wait
	if(delay_override)
		total_time = delay_override
	zoom_animating = total_time
	animate(current_user.client, pixel_x = current_zoom_x, pixel_y = current_zoom_y , total_time, SINE_EASING, ANIMATION_PARALLEL)
	zoom_animating = 0

/obj/item/gun/energy/beam_rifle/proc/set_autozoom_pixel_offsets_immediate(current_angle)
	if(zoom_lock == ZOOM_LOCK_CENTER_VIEW || zoom_lock == ZOOM_LOCK_OFF)
		return
	current_zoom_x = sin(current_angle) + sin(current_angle) * AUTOZOOM_PIXEL_STEP_FACTOR * zoom_current_view_increase
	current_zoom_y = cos(current_angle) + cos(current_angle) * AUTOZOOM_PIXEL_STEP_FACTOR * zoom_current_view_increase

/obj/item/gun/energy/beam_rifle/proc/handle_zooming()
	if(!zooming || !check_user())
		return
	current_user.client.change_view(world.view + zoom_target_view_increase)
	zoom_current_view_increase = zoom_target_view_increase
	set_autozoom_pixel_offsets_immediate(zooming_angle)
	smooth_zooming()

/obj/item/gun/energy/beam_rifle/proc/start_zooming()
	if(zoom_lock == ZOOM_LOCK_OFF)
		return
	zooming = TRUE

/obj/item/gun/energy/beam_rifle/proc/stop_zooming(mob/user)
	if(zooming)
		zooming = FALSE
		reset_zooming(user)

/obj/item/gun/energy/beam_rifle/proc/reset_zooming(mob/user)
	if(!user)
		user = current_user
	if(!user || !user.client)
		return FALSE
	zoom_animating = 0
	animate(user.client, pixel_x = 0, pixel_y = 0, 0, FALSE, LINEAR_EASING, ANIMATION_END_NOW)
	zoom_current_view_increase = 0
	user.client.change_view(CONFIG_GET(string/default_view))
	zooming_angle = 0
	current_zoom_x = 0
	current_zoom_y = 0

/obj/item/gun/energy/beam_rifle/update_icon()
	cut_overlays()
	var/obj/item/ammo_casing/energy/primary_ammo = ammo_type[1]
	if(cell.charge > primary_ammo.e_cost)
		add_overlay(charged_overlay)
	else
		add_overlay(drained_overlay)

/obj/item/gun/energy/beam_rifle/attack_self(mob/user)
	projectile_setting_pierce = !projectile_setting_pierce
	to_chat(user, "<span class='boldnotice'>You set \the [src] to [projectile_setting_pierce? "pierce":"impact"] mode.</span>")
	aiming_beam()

/obj/item/gun/energy/beam_rifle/proc/update_slowdown()
	if(aiming)
		slowdown = scoped_slow
	else
		slowdown = initial(slowdown)

/obj/item/gun/energy/beam_rifle/Initialize()
	. = ..()
	current_tracers = list()
	START_PROCESSING(SSprojectiles, src)
	zoom_lock_action = new(src)

/obj/item/gun/energy/beam_rifle/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	set_user(null)
	QDEL_LIST(current_tracers)
	QDEL_NULL(mobhook)
	return ..()

/obj/item/gun/energy/beam_rifle/emp_act(severity)
	chambered = null
	recharge_newshot()

/obj/item/gun/energy/beam_rifle/proc/aiming_beam(force_update = FALSE)
	var/diff = abs(aiming_lastangle - lastangle)
	check_user()
	if(diff < AIMING_BEAM_ANGLE_CHANGE_THRESHOLD && !force_update)
		return
	aiming_lastangle = lastangle
	var/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/P = new
	P.gun = src
	P.wall_pierce_amount = wall_pierce_amount
	P.structure_pierce_amount = structure_piercing
	P.do_pierce = projectile_setting_pierce
	if(aiming_time)
		var/percent = ((100/aiming_time)*aiming_time_left)
		P.color = rgb(255 * percent,255 * ((100 - percent) / 100),0)
	else
		P.color = rgb(0, 255, 0)
	var/turf/curloc = get_turf(src)
	var/turf/targloc = get_turf(current_user.client.mouseObject)
	if(!istype(targloc))
		if(!istype(curloc))
			return
		targloc = get_turf_in_angle(lastangle, curloc, 10)
	P.preparePixelProjectile(targloc, current_user, current_user.client.mouseParams, 0)
	P.fire(lastangle)

/obj/item/gun/energy/beam_rifle/process()
	if(!aiming)
		last_process = world.time
		return
	check_user()
	handle_zooming()
	aiming_time_left = max(0, aiming_time_left - (world.time - last_process))
	aiming_beam(TRUE)
	last_process = world.time

/obj/item/gun/energy/beam_rifle/proc/check_user(automatic_cleanup = TRUE)
	if(!istype(current_user) || !isturf(current_user.loc) || !(src in current_user.held_items) || current_user.incapacitated())	//Doesn't work if you're not holding it!
		if(automatic_cleanup)
			stop_aiming()
			set_user(null)
		return FALSE
	return TRUE

/obj/item/gun/energy/beam_rifle/proc/process_aim()
	if(istype(current_user) && current_user.client && current_user.client.mouseParams)
		var/angle = mouse_angle_from_client(current_user.client)
		switch(angle)
			if(316 to 360)
				current_user.setDir(NORTH)
			if(0 to 45)
				current_user.setDir(NORTH)
			if(46 to 135)
				current_user.setDir(EAST)
			if(136 to 225)
				current_user.setDir(SOUTH)
			if(226 to 315)
				current_user.setDir(WEST)
		var/difference = abs(closer_angle_difference(lastangle, angle))
		delay_penalty(difference * aiming_time_increase_angle_multiplier)
		lastangle = angle

/obj/item/gun/energy/beam_rifle/proc/on_mob_move()
	check_user()
	if(aiming)
		delay_penalty(aiming_time_increase_user_movement)
		process_aim()
		aiming_beam(TRUE)

/obj/item/gun/energy/beam_rifle/proc/start_aiming()
	aiming_time_left = aiming_time
	aiming = TRUE
	process_aim()
	aiming_beam(TRUE)
	zooming_angle = lastangle
	start_zooming()

/obj/item/gun/energy/beam_rifle/proc/stop_aiming(mob/user)
	set waitfor = FALSE
	aiming_time_left = aiming_time
	aiming = FALSE
	QDEL_LIST(current_tracers)
	stop_zooming(user)

/obj/item/gun/energy/beam_rifle/proc/set_user(mob/user)
	if(user == current_user)
		return
	stop_aiming(current_user)
	QDEL_NULL(mobhook)
	if(istype(current_user))
		LAZYREMOVE(current_user.mousemove_intercept_objects, src)
		current_user = null
	if(istype(user))
		current_user = user
		LAZYOR(current_user.mousemove_intercept_objects, src)
		mobhook = user.AddComponent(/datum/component/redirect, list(COMSIG_MOVABLE_MOVED), CALLBACK(src, .proc/on_mob_move))

/obj/item/gun/energy/beam_rifle/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	if(aiming)
		process_aim()
		aiming_beam()
		if(zoom_lock == ZOOM_LOCK_AUTOZOOM_FREEMOVE)
			zooming_angle = lastangle
			set_autozoom_pixel_offsets_immediate(zooming_angle)
			smooth_zooming(2)
	return ..()

/obj/item/gun/energy/beam_rifle/onMouseDown(object, location, params, mob/mob)
	if(istype(mob))
		set_user(mob)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	if((object in mob.contents) || (object == mob))
		return
	start_aiming()
	return ..()

/obj/item/gun/energy/beam_rifle/onMouseUp(object, location, params, mob/M)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	process_aim()
	if(aiming_time_left <= aiming_time_fire_threshold && check_user())
		sync_ammo()
		afterattack(M.client.mouseObject, M, FALSE, M.client.mouseParams, passthrough = TRUE)
	stop_aiming()
	QDEL_LIST(current_tracers)
	return ..()

/obj/item/gun/energy/beam_rifle/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(target in user.contents) //can't shoot stuff inside us.
			return
		if(!ismob(target) || user.a_intent == INTENT_HARM) //melee attack
			return
		if(target == user && user.zone_selected != BODY_ZONE_PRECISE_MOUTH) //so we can't shoot ourselves (unless mouth selected)
			return
	if(!passthrough && (aiming_time > aiming_time_fire_threshold))
		return
	if(lastfire > world.time + delay)
		return
	lastfire = world.time
	. = ..()
	stop_aiming()

/obj/item/gun/energy/beam_rifle/proc/sync_ammo()
	for(var/obj/item/ammo_casing/energy/beam_rifle/AC in contents)
		AC.sync_stats()

/obj/item/gun/energy/beam_rifle/proc/delay_penalty(amount)
	aiming_time_left = CLAMP(aiming_time_left + amount, 0, aiming_time)

/obj/item/ammo_casing/energy/beam_rifle
	name = "particle acceleration lens"
	desc = "Don't look into barrel!"
	var/wall_pierce_amount = 0
	var/wall_devastate = 0
	var/aoe_structure_range = 1
	var/aoe_structure_damage = 30
	var/aoe_fire_range = 2
	var/aoe_fire_chance = 66
	var/aoe_mob_range = 1
	var/aoe_mob_damage = 20
	var/impact_structure_damage = 50
	var/projectile_damage = 40
	var/projectile_stun = 0
	var/structure_piercing = 2
	var/structure_bleed_coeff = 0.7
	var/do_pierce = TRUE
	var/obj/item/gun/energy/beam_rifle/host

/obj/item/ammo_casing/energy/beam_rifle/proc/sync_stats()
	var/obj/item/gun/energy/beam_rifle/BR = loc
	if(!istype(BR))
		stack_trace("Beam rifle syncing error")
	host = BR
	do_pierce = BR.projectile_setting_pierce
	wall_pierce_amount = BR.wall_pierce_amount
	wall_devastate = BR.wall_devastate
	aoe_structure_range = BR.aoe_structure_range
	aoe_structure_damage = BR.aoe_structure_damage
	aoe_fire_range = BR.aoe_fire_range
	aoe_fire_chance = BR.aoe_fire_chance
	aoe_mob_range = BR.aoe_mob_range
	aoe_mob_damage = BR.aoe_mob_damage
	impact_structure_damage = BR.impact_structure_damage
	projectile_damage = BR.projectile_damage
	projectile_stun = BR.projectile_stun
	delay = BR.delay
	structure_piercing = BR.structure_piercing
	structure_bleed_coeff = BR.structure_bleed_coeff

/obj/item/ammo_casing/energy/beam_rifle/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	. = ..()
	var/obj/item/projectile/beam/beam_rifle/hitscan/HS_BB = BB
	if(!istype(HS_BB))
		return
	HS_BB.impact_direct_damage = projectile_damage
	HS_BB.stun = projectile_stun
	HS_BB.impact_structure_damage = impact_structure_damage
	HS_BB.aoe_mob_damage = aoe_mob_damage
	HS_BB.aoe_mob_range = CLAMP(aoe_mob_range, 0, 15)				//Badmin safety lock
	HS_BB.aoe_fire_chance = aoe_fire_chance
	HS_BB.aoe_fire_range = aoe_fire_range
	HS_BB.aoe_structure_damage = aoe_structure_damage
	HS_BB.aoe_structure_range = CLAMP(aoe_structure_range, 0, 15)	//Badmin safety lock
	HS_BB.wall_devastate = wall_devastate
	HS_BB.wall_pierce_amount = wall_pierce_amount
	HS_BB.structure_pierce_amount = structure_piercing
	HS_BB.structure_bleed_coeff = structure_bleed_coeff
	HS_BB.do_pierce = do_pierce
	HS_BB.gun = host

/obj/item/ammo_casing/energy/beam_rifle/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread)
	var/turf/curloc = get_turf(user)
	if(!istype(curloc) || !BB)
		return FALSE
	var/obj/item/gun/energy/beam_rifle/gun = loc
	if(!targloc && gun)
		targloc = get_turf_in_angle(gun.lastangle, curloc, 10)
	else if(!targloc)
		return FALSE
	var/firing_dir
	if(BB.firer)
		firing_dir = BB.firer.dir
	if(!BB.suppressed && firing_effect_type)
		new firing_effect_type(get_turf(src), firing_dir)
	BB.preparePixelProjectile(target, user, params, spread)
	BB.fire(gun? gun.lastangle : null, null)
	BB = null
	return TRUE

/obj/item/ammo_casing/energy/beam_rifle/hitscan
	projectile_type = /obj/item/projectile/beam/beam_rifle/hitscan
	select_name = "beam"
	e_cost = 5000
	fire_sound = 'sound/weapons/beam_sniper.ogg'

/obj/item/projectile/beam/beam_rifle
	name = "particle beam"
	icon = ""
	hitsound = 'sound/effects/explosion3.ogg'
	damage = 0				//Handled manually.
	damage_type = BURN
	flag = "energy"
	range = 150
	jitter = 10
	var/obj/item/gun/energy/beam_rifle/gun
	var/structure_pierce_amount = 0				//All set to 0 so the gun can manually set them during firing.
	var/structure_bleed_coeff = 0
	var/structure_pierce = 0
	var/do_pierce = TRUE
	var/wall_pierce_amount = 0
	var/wall_pierce = 0
	var/wall_devastate = 0
	var/aoe_structure_range = 0
	var/aoe_structure_damage = 0
	var/aoe_fire_range = 0
	var/aoe_fire_chance = 0
	var/aoe_mob_range = 0
	var/aoe_mob_damage = 0
	var/impact_structure_damage = 0
	var/impact_direct_damage = 0
	var/turf/cached
	var/list/pierced = list()

/obj/item/projectile/beam/beam_rifle/proc/AOE(turf/epicenter)
	set waitfor = FALSE
	if(!epicenter)
		return
	new /obj/effect/temp_visual/explosion/fast(epicenter)
	for(var/mob/living/L in range(aoe_mob_range, epicenter))		//handle aoe mob damage
		L.adjustFireLoss(aoe_mob_damage)
		to_chat(L, "<span class='userdanger'>\The [src] sears you!</span>")
	for(var/turf/T in range(aoe_fire_range, epicenter))		//handle aoe fire
		if(prob(aoe_fire_chance))
			new /obj/effect/hotspot(T)
	for(var/obj/O in range(aoe_structure_range, epicenter))
		if(!isitem(O))
			if(O.level == 1)	//Please don't break underfloor items!
				continue
			O.take_damage(aoe_structure_damage * get_damage_coeff(O), BURN, "laser", FALSE)

/obj/item/projectile/beam/beam_rifle/proc/check_pierce(atom/target)
	if(!do_pierce)
		return FALSE
	if(pierced[target])		//we already pierced them go away
		return TRUE
	if(isclosedturf(target))
		if(wall_pierce++ < wall_pierce_amount)
			if(prob(wall_devastate))
				if(iswallturf(target))
					var/turf/closed/wall/W = target
					W.dismantle_wall(TRUE, TRUE)
				else
					target.ex_act(EXPLODE_HEAVY)
			return TRUE
	if(ismovableatom(target))
		var/atom/movable/AM = target
		if(AM.density && !AM.CanPass(src, get_turf(target)) && !ismob(AM))
			if(structure_pierce < structure_pierce_amount)
				if(isobj(AM))
					var/obj/O = AM
					O.take_damage((impact_structure_damage + aoe_structure_damage) * structure_bleed_coeff * get_damage_coeff(AM), BURN, "energy", FALSE)
				pierced[AM] = TRUE
				structure_pierce++
				return TRUE
	return FALSE

/obj/item/projectile/beam/beam_rifle/proc/get_damage_coeff(atom/target)
	if(istype(target, /obj/machinery/door))
		return 0.4
	if(istype(target, /obj/structure/window))
		return 0.5
	return 1

/obj/item/projectile/beam/beam_rifle/proc/handle_impact(atom/target)
	if(isobj(target))
		var/obj/O = target
		O.take_damage(impact_structure_damage * get_damage_coeff(target), BURN, "laser", FALSE)
	if(isliving(target))
		var/mob/living/L = target
		L.adjustFireLoss(impact_direct_damage)
		L.emote("scream")

/obj/item/projectile/beam/beam_rifle/proc/handle_hit(atom/target)
	set waitfor = FALSE
	if(!cached && !QDELETED(target))
		cached = get_turf(target)
	if(nodamage)
		return FALSE
	playsound(cached, 'sound/effects/explosion3.ogg', 100, 1)
	AOE(cached)
	if(!QDELETED(target))
		handle_impact(target)

/obj/item/projectile/beam/beam_rifle/Collide(atom/target)
	if(check_pierce(target))
		permutated += target
		trajectory_ignore_forcemove = TRUE
		forceMove(target)
		trajectory_ignore_forcemove = FALSE
		return FALSE
	if(!QDELETED(target))
		cached = get_turf(target)
	. = ..()

/obj/item/projectile/beam/beam_rifle/on_hit(atom/target, blocked = FALSE)
	if(!QDELETED(target))
		cached = get_turf(target)
	handle_hit(target)
	. = ..()

/obj/item/projectile/beam/beam_rifle/hitscan
	icon_state = ""
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/tracer/beam_rifle
	var/constant_tracer = FALSE

/obj/item/projectile/beam/beam_rifle/hitscan/generate_hitscan_tracers(cleanup = TRUE, duration = 5, impacting = TRUE, highlander)
	set waitfor = FALSE
	if(isnull(highlander))
		highlander = constant_tracer
	if(highlander && istype(gun))
		QDEL_LIST(gun.current_tracers)
		for(var/datum/point/p in beam_segments)
			gun.current_tracers += generate_tracer_between_points(p, beam_segments[p], tracer_type, color, 0)
	else
		for(var/datum/point/p in beam_segments)
			generate_tracer_between_points(p, beam_segments[p], tracer_type, color, duration)
	if(cleanup)
		QDEL_LIST(beam_segments)
		beam_segments = null
		QDEL_NULL(beam_index)

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam
	tracer_type = /obj/effect/projectile/tracer/tracer/aiming
	name = "aiming beam"
	hitsound = null
	hitsound_wall = null
	nodamage = TRUE
	damage = 0
	constant_tracer = TRUE

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/prehit(atom/target)
	qdel(src)
	return FALSE

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/on_hit()
	qdel(src)
	return FALSE
