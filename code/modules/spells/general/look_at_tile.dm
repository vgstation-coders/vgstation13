/spell/look_at_tile
	name = "Look at tile"
	desc = "Squint your eyes really hard and project your vision on a nearby unobscured tile."
	abbreviation = "LAT"

	school = "generic"
	user_type = USER_TYPE_OTHER

	charge_type = Sp_RECHARGE
	charge_max = 5 SECONDS
	invocation_type = SpI_NONE
	range = 4
	spell_flags = WAIT_FOR_CLICK | NEEDSHUMAN
	cooldown_min = 5 SECONDS
	selection_type = "range"

	override_base = "genetic"
	hud_state = "look_at_tile"

/spell/look_at_tile/is_valid_target(atom/target, mob/user, options, bypass_range)
	// Handle view/range check
	if (!(target in view(range, user)))
		return

	if (!isturf(target))
		target = get_turf(target)

	// can't squint through cameras!
	if (user.machine)
		return FALSE

	var/turf/T = target

	// Adjacent turfs
	if (T.Adjacent(user))
		if (istype(T, /turf/simulated/wall))
			return T.bullet_marks // Peeper code
		else if (istype(T, /turf/simulated/floor))
			return TRUE

	// Other case: seeing if we can reach the user uninterrupted
	var/turf/current_turf = T
	var/turf/hometurf = get_turf(user)
	var/i = 0
	while(current_turf != hometurf && i < 2*range)
		i++
		message_admins("[i] at [current_turf.x], [current_turf.y]")
		var/vector/V = atoms2vector(current_turf, hometurf)
		var/D = vector2ClosestDir(V)
		current_turf = get_step(current_turf, D)
		if (!(current_turf in view(user)))
			return FALSE
	return TRUE

/spell/look_at_tile/cast(list/targets, mob/user)
	if (targets.len > 1)
		return FALSE

	user.reset_view()
	user.is_using_look_spell = TRUE
	var/turf/T = targets[1]

	user.client.perspective = EYE_PERSPECTIVE
	user.client.eye = T
	user.visible_message("<span class='notice'>[user] leans in and looks in the direction of \the [get_area(T)].</span>", \
	"<span class='notice'>You lean in and look in the direction of \the [get_area(T)].</span>")
	user.register_event(/event/moved, user, /mob/proc/reset_view)
	user.register_event(/event/after_move, user, /mob/proc/reset_view)
	user.register_event(/event/hitby, user, /mob/proc/reset_view)
	user.register_event(/event/touched, user, /mob/proc/reset_view)
	user.register_event(/event/attacked_by, user, /mob/proc/reset_view)
