// Devices to help with exploration and survival in unknown environments

//// Bluespace Emergency Recall Tool (BERT)
// A single-use device that allows the user to set a recall point and teleport back to it when activated.
// Emagging the device makes it always show as ready (even when teleblocked) and stuns the user when activated.
/obj/item/device/bert
	name = "\improper Bluespace Emergency Recall Tool"
	desc = "A single-use device that sends the user back to their point of origin when activated. Useful for escaping dangerous situations."
	icon_state = "bert"

	w_class = W_CLASS_TINY
	w_type = RECYK_ELECTRONIC
	flags = FPRINT
	var/turf/recall_point
	var/firing = FALSE
	var/sabotaged = FALSE
	var/blocked = FALSE
	var/blocking_reason = "Bluespace recall is unavailable in this location."

/obj/item/device/bert/attack_self(var/mob/living/user)
	if(firing)
		return
	var/area/A = get_area(user)
	if(!isopensurface(A))
		to_chat(user, "<span class='warning'>\The [src] emits a buzz and nothing happens. Space radiation interferes with Bluespace recall; BERT can only be used on planets.</span>")
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 1)
		return
	var/jammed = (A.jammed || A.flags & (NO_TELEPORT|NO_PORTALS))? TRUE : FALSE
	if(jammed)
		to_chat(user, "<span class='warning'>\The [src] emits a buzz and nothing happens. It seems teleportation is jammed in this area.</span>")
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 1)
		return
	if(blocked)
		to_chat(user, "<span class='warning'>\The [src] emits a buzz and nothing happens. [blocking_reason]</span>")
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 1)
		return
	if(recall_point)
		if(alert(user, "Recall to your set point?", name, "Yes", "No") != "Yes")
			return
		if(user.incapacitated() || !Adjacent(user))
			return

		firing = TRUE
		update_icon()
		spawn(1 SECONDS)
			if(sabotaged)
				to_chat(user, "<span class='warning'>\The [src] malfunctions violently, throwing you off balance!</span>")
				user.apply_effects(10, 10)
				spark(src, 5, surfaceburn=TRUE)
				playsound(user, 'sound/effects/lightning/chainlightning2.ogg', 50, 1)
				qdel(src)
				return
			to_chat(user, "<span class='notice'>\The [src] activates, and you feel a sudden shift as you're transported back to your recall point!</span>")
			playsound(user, 'sound/effects/teleport.ogg', 50, 1)
			do_teleport(user, recall_point, aijamming = TRUE)
			user.Dizzy(30)
			shake_camera(user, 10, 2)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.vomit(instant = TRUE)
			recall_point = null
			qdel(src)
			return
	else
		if(alert(user, "Set current location as recall point?", name, "Yes", "No") != "Yes")
			return
		if(user.incapacitated() || !Adjacent(user))
			return

		recall_point = get_turf(src)
		to_chat(user, "<span class='notice'>\The [src] makes a noise as it calibrates to your current location.</span>")
		playsound(user, 'sound/machines/ping.ogg', 50, 1)
		update_icon()
		processing_objects += src

/obj/item/device/bert/emag_act(mob/user)
	. = ..()
	sabotaged = TRUE
	spark(src, 5)
	to_chat(user, "<span class='warning'>You hear a faint sizzling sound from the [src] as you tamper with it.</span>")

/obj/item/device/bert/update_icon()
	..()
	if(firing)
		icon_state = "bert_firing"
	else if(recall_point)
		if(blocked && !sabotaged)
			icon_state = "bert_bad"
		else
			icon_state = "bert_ready"
	else
		icon_state = "bert"

/obj/item/device/bert/process()
	..()
	var/to_block = FALSE
	if(!recall_point)
		processing_objects -= src
		return
	var/turf/T = get_turf(src)
	if(recall_point.z != T.z)
		to_block = TRUE
		blocking_reason = "Bluespace recall range does not extend across z-levels."
	if(T.planet)
		if(recall_point.planet && T.planet != recall_point.planet)
			to_block = TRUE
			blocking_reason = "Bluespace recall range does not extend across planets."
	var/area/A = get_area(src)
	if(A.jammed || A.flags & (NO_TELEPORT|NO_PORTALS))
		to_block = TRUE
		blocking_reason = "It seems teleportation is jammed in this area."
	blocked = to_block
	update_icon()

/obj/item/device/bert/examine(mob/user)
	desc = initial(desc)
	if(blocked)
		desc += "\nThe device error light is on, indicating an inability to recall to the set point."
	else if(recall_point)
		desc += "\nThe device is set to recall to a specific location."
	..()

/obj/item/device/bert/Destroy()
	processing_objects -= src
	..()

//// Pacification Beacon
// A device that emits a calming field, reducing aggression against the holder in nearby creatures.
// Only works for two minutes before becoming useless.
/obj/item/device/pacification_beacon
	name = "Pacification Beacon"
	desc = "A device that emits a calming field, reducing aggression against the holder in nearby creatures. Psyonic batteries only permit a total active time of two minutes before rendering the device inert."
	icon_state = "pacifier"
	w_class = W_CLASS_TINY
	w_type = RECYK_ELECTRONIC
	flags = FPRINT
	var/active = FALSE
	var/max_time = 2 MINUTES
	var/used_time = 0
	var/mob/living/holder

/obj/item/device/pacification_beacon/proc/clear_aura(var/mob/living/target)
	if(!target)
		return
	target.pacify_aura = initial(target.pacify_aura)
	target.hallucination = initial(target.hallucination)

/obj/item/device/pacification_beacon/proc/deactivate()
	if(!active)
		return
	active = FALSE
	processing_objects -= src
	clear_aura(holder)
	holder = null
	update_icon()

/obj/item/device/pacification_beacon/attack_self(var/mob/living/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!active)
		if(used_time >= max_time)
			to_chat(user, "<span class='warning'>\The [src] is spent and no longer functional.</span>")
			return
		active = TRUE
		to_chat(user, "<span class='notice'>You activate \the [src]. A calming field radiates from it.</span>")
		playsound(user, 'sound/machines/signal.ogg', 50, 1)
		processing_objects += src
		holder = user
	else
		to_chat(user, "<span class='notice'>You deactivate \the [src]. The calming field dissipates.</span>")
		deactivate()
	update_icon()

/obj/item/device/pacification_beacon/dropped(var/mob/living/user)
	..()
	clear_aura(holder)
	holder = null

/obj/item/device/pacification_beacon/equipped(var/mob/living/user, var/slot)
	..()
	if(active && isliving(user))
		holder = user

/obj/item/device/pacification_beacon/process()
	if(!active)
		processing_objects -= src
		return
	if(!holder || !(src in holder.contents))
		clear_aura(holder)
		holder = null
		return
	holder.pacify_aura = TRUE
	holder.hallucination = max(holder.hallucination, 50)
	used_time += 2 SECONDS
	if(used_time >= max_time)
		to_chat(holder, "<span class='warning'>\The [src] emits a final pulse before shutting down completely.</span>")
		playsound(holder, 'sound/machines/alert.ogg', 50, 1)
		deactivate()

/obj/item/device/pacification_beacon/update_icon()
	..()
	if(active)
		icon_state = "pacifier_active"
	else
		icon_state = "pacifier"

/obj/item/device/pacification_beacon/examine(mob/user)
	desc = initial(desc)
	if(used_time >= max_time)
		desc += "\nThe device is completely spent."
	else
		if(active)
			desc += "\nThe device is currently active."
		desc += "\nRemaining active time: [(max_time - used_time)/10]s."
	..()

/obj/item/device/pacification_beacon/Destroy()
	deactivate()
	..()

//// Shuttle Holopainter
// A device that allows the user to change the color of the shuttle walls or floors.
/obj/item/device/shuttle_holopainter
	name = "Shuttle Holopainter"
	desc = "A handheld device that installs a holographic color overlay on the shuttle's surfaces. Select a color then install it into the shuttle's control console to apply the change."
	icon_state = "shuttle_mod"
	w_class = W_CLASS_TINY
	w_type = RECYK_ELECTRONIC
	flags = FPRINT | EMAGGABLE
	var/target = "Walls"
	var/preset = null
	var/sel_color = null

/obj/item/device/shuttle_holopainter/attack_self(var/mob/living/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	preset = null
	sel_color = null
	var/opts = list("Walls", "Floors", "Reset to Default")
	target = input(user, "Select target to modify:", "Shuttle Holopainter", "Walls") as anything in opts
	if(target == "Reset to Default")
		sel_color = null
		overlays.Cut()
		to_chat(user, "<span class='notice'>You reset \the [src]. Surfaces will be restored to their default appearance.</span>")
		return
	opts = list("Preset", "Custom Color")
	var/use_preset = input(user, "Use a preset shuttle turf type or specify a color?", "Shuttle Holopainter", "Custom Color") as anything in opts
	if(use_preset == "Preset")
		if(target == "Floors")
			var/list/types = list(
				"White",
				"Blue",
				"Yellow",
				"Red",
				"Purple",
				"Plated",
				"Cult"
			)
			preset = input(user, "Select a preset type:", "Shuttle Holopainter") as anything in types
			to_chat(user, "<span class='notice'>You set \the [src] to change shuttle floor types to [preset]. Install it into a shuttle control console to apply the change.</span>")
		else if(target == "Walls")
			var/list/types = list(
				"White Smoothed",
				"Black Smoothed",
				"White Unsmoothed",
				"Black Unsmoothed",
				"Syndicate",
				"Layered"
			)
			preset = input(user, "Select a preset type:", "Shuttle Holopainter") as anything in types
			to_chat(user, "<span class='notice'>You set \the [src] to change shuttle wall types to [preset]. Install it into a shuttle control console to apply the change.</span>")
	else
		sel_color = input(user, "Select a new color:", "Character Preference") as color|null
		if(!sel_color)
			sel_color = "#ffffff"
		to_chat(user, "<span class='notice'>You set \the [src] to modify [target] to color [sel_color]. Install it into a shuttle control console to apply the change.</span>")
	overlays.Cut()
	var/image/olay = image(icon,src,"shuttle_mod_olay")
	olay.color = sel_color ? sel_color : "#ffffff"
	overlays += olay

/obj/item/device/shuttle_holopainter/emag_act(mob/user)
	. = ..()
	playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
	to_chat(user, "<span class='notice'>Entertainment preset selected.</span>")
	emagged = TRUE


/obj/item/device/shuttle_holopainter/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/weapon/stamp/clown))
		playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
		to_chat(user, "<span class='notice'>Entertainment preset selected.</span>")
		emagged = TRUE

//// Phasic Gas Dowser
// A device that points the user towards the nearest gas vent.
/obj/item/weapon/pinpointer/gas_dowser
	name = "Phasic Gas Dowser"
	desc = "A handheld device that detects and points towards the nearest natural gas vent on a planet. Essential for locating extractable gas deposits."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinoff"
	watches_nuke = FALSE
	pinpointable = FALSE
	var/datum/vent/target_vent
	var/selected_gas = null
	var/static/list/possible_gasses = list(
		"Any",
		GAS_OXYGEN,
		GAS_NITROGEN,
		GAS_CARBON,
		GAS_PLASMA,
		GAS_SLEEPING,
		GAS_CRYOTHEUM,
		GAS_RADON
	)

/obj/item/weapon/pinpointer/gas_dowser/New()
	..()
	overlays += image(icon,src,"dowser")

/obj/item/weapon/pinpointer/gas_dowser/attack_self()
	if(!active)
		var/turf/my_turf = get_turf(src)
		if(!my_turf?.planet)
			to_chat(usr, "<span class='warning'>\The [src] can only be used on a planet.</span>")
			return
		var/gas_choice = input(usr, "Select a gas type to search for:", "Phasic Gas Dowser") as null|anything in possible_gasses
		if(!gas_choice)
			return
		if(usr.incapacitated() || !Adjacent(usr))
			return
		selected_gas = gas_choice == "Any" ? null : gas_choice
		active = TRUE
		to_chat(usr, "<span class='notice'>You activate \the [src]. It begins scanning for [gas_choice == "Any" ? "any" : gas_choice] gas vents.</span>")
		playsound(src, 'sound/items/healthanalyzer.ogg', 30, 1)
		fast_objects += src
	else
		active = FALSE
		icon_state = "pinoff"
		target_vent = null
		selected_gas = null
		to_chat(usr, "<span class='notice'>You deactivate \the [src].</span>")
		fast_objects -= src

/obj/item/weapon/pinpointer/gas_dowser/process()
	var/turf/my_turf = get_turf(src)
	if(!my_turf?.planet)
		icon_state = "pinonnull"
		return

	target_vent = null
	if(!my_turf)
		return
	var/datum/planet_type/my_planet = my_turf.planet
	if(!my_planet)
		return

	var/list/valid_vents = list()
	var/turf/vent_turf
	for(var/datum/vent/V in my_planet.vents)
		if(selected_gas && V.gas_type != selected_gas)
			continue
		if(V.mols < V.initial_mols * 0.25)
			continue
		vent_turf = V.turf_ref?.get()
		if(!vent_turf)
			continue
		if(vent_turf.z != my_turf.z)
			continue
		valid_vents += V
	if(valid_vents.len)
		target_vent = pick(valid_vents)
	if(target_vent)
		if(vent_turf)
			point_at(vent_turf)
		else
			icon_state = "pinonnull"
	else
		icon_state = "pinonnull"

/obj/item/weapon/pinpointer/gas_dowser/examine(mob/user)
	..()
	if(active)
		if(target_vent)
			var/turf/T = target_vent.turf_ref?.get()
			if(T)
				to_chat(user, "<span class='info'>Tracking a [target_vent.gas_type] vent.</span>")
		else
			to_chat(user, "<span class='warning'>No gas vents detected on this planet.</span>")

//// Emergency Shield Projector
// A device that creates a temporary shield barrier to block attacks.
/obj/item/device/emshield_projector
	name = "Emergency Shield Projector"
	desc = "A handheld device that generates a temporary shield barrier surrounding the user, blocking incoming attacks. The shield lasts for thirty seconds or until it absorbs a certain amount of damage. Requires a bluespace crystal to recharge once depleted."
	icon_state = "holoprojector"
	w_class = W_CLASS_TINY
	w_type = RECYK_ELECTRONIC
	flags = FPRINT
	var/active = FALSE
	var/list/shields = list()
	var/max_duration = 30 SECONDS
	var/elapsed_time = 0
	var/max_damage_absorb = 100
	var/damage_absorbed = 0
	var/depleted = FALSE
	var/warning_active = FALSE

/obj/item/device/emshield_projector/attack_self(var/mob/living/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	if(depleted)
		to_chat(user, "<span class='warning'>\The [src] is depleted! Insert a bluespace crystal to recharge it.</span>")
		return
	if(active)
		to_chat(user, "<span class='notice'>You deactivate \the [src]. The emergency shield dissipates.</span>")
		deactivate_field()
		return
	active = TRUE
	warning_active = FALSE
	to_chat(user, "<span class='notice'>You activate \the [src]. A protective emergency shield forms around you!</span>")
	playsound(src, 'sound/effects/portal_open.ogg', 50, 1)
	generate_field(user)
	processing_objects += src
	update_icon()

/obj/item/device/emshield_projector/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/bluespace_crystal))
		if(!depleted && elapsed_time == 0)
			to_chat(user, "<span class='warning'>\The [src] is already fully charged.</span>")
			return
		to_chat(user, "<span class='notice'>You insert \the [W] into \the [src]. Capacity restored.</span>")
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		qdel(W)
		elapsed_time = 0
		depleted = FALSE
		update_icon()
		return
	..()

/obj/item/device/emshield_projector/proc/generate_field(var/mob/living/user)
	var/turf/center = get_turf(user)
	if(!center)
		return
	for(var/dx in -2 to 2)
		for(var/dy in -2 to 2)
			if(abs(dx) <= 1 && abs(dy) <= 1)
				continue
			var/turf/T = locate(center.x + dx, center.y + dy, center.z)
			if(T && !T.density)
				var/obj/structure/emergency_shield/field = new(T)
				field.source_projector = src
				shields += field

/obj/item/device/emshield_projector/proc/absorb_damage(var/damage)
	damage_absorbed += damage
	check_warning_state()
	if(damage_absorbed >= max_damage_absorb)
		collapse_field(TRUE)

/obj/item/device/emshield_projector/proc/deactivate_field()
	if(!active)
		return
	active = FALSE
	warning_active = FALSE
	processing_objects -= src
	for(var/obj/structure/emergency_shield/field in shields)
		if(field)
			qdel(field)
	shields.Cut()
	update_icon()
	playsound(src, 'sound/effects/portal_close.ogg', 50, 1)

/obj/item/device/emshield_projector/proc/collapse_field(var/from_damage = FALSE)
	if(!active)
		return
	active = FALSE
	warning_active = FALSE
	processing_objects -= src
	for(var/obj/structure/emergency_shield/field in shields)
		if(field)
			spark(field, 3)
			qdel(field)
	shields.Cut()
	playsound(src, 'sound/effects/EMPulse.ogg', 50, 1)
	visible_message("<span class='warning'>\The [src]'s shields collapse!</span>")
	depleted = TRUE
	update_icon()

/obj/item/device/emshield_projector/proc/check_warning_state()
	var/remaining_time = max_duration - elapsed_time
	var/remaining_damage = max_damage_absorb - damage_absorbed
	var/should_warn = (remaining_time <= 5 SECONDS) || (remaining_damage <= max_damage_absorb * 0.2)
	if(should_warn && !warning_active)
		warning_active = TRUE
		update_field_overlays(TRUE)
	else if(!should_warn && warning_active)
		warning_active = FALSE
		update_field_overlays(FALSE)

/obj/item/device/emshield_projector/proc/update_field_overlays(var/show_warning)
	for(var/obj/structure/emergency_shield/field in shields)
		if(field)
			field.set_warning_overlay(show_warning)

/obj/item/device/emshield_projector/process()
	if(!active)
		processing_objects -= src
		return
	elapsed_time += 2 SECONDS
	check_warning_state()
	if(elapsed_time >= max_duration)
		collapse_field()

/obj/item/device/emshield_projector/update_icon()
	..()
	if(active)
		icon_state = "holoprojector_active"
	else if(depleted)
		icon_state = "holoprojector_depleted"
	else
		icon_state = "holoprojector"

/obj/item/device/emshield_projector/examine(mob/user)
	desc = initial(desc)
	if(depleted)
		desc += "\n<span class='warning'>The device is depleted. Insert a bluespace crystal to recharge.</span>"
	else if(active)
		desc += "\nThe device is currently active."
		desc += "\nRemaining time: [(max_duration - elapsed_time)/10]s."
		desc += "\nDamage absorbed: [damage_absorbed]/[max_damage_absorb]."
	else
		desc += "\nRemaining charge: [(max_duration - elapsed_time)/10]s."
	..()

/obj/item/device/emshield_projector/Destroy()
	deactivate_field()
	..()

/obj/structure/emergency_shield
	name = "Emergency Shield"
	desc = "A shimmering energy barrier blocking the way."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles_heavy"
	mouse_opacity = 1
	density = TRUE
	anchored = TRUE
	var/obj/item/device/emshield_projector/source_projector
	var/warning_overlay_active = FALSE

/obj/structure/emergency_shield/proc/set_warning_overlay(var/show_warning)
	if(show_warning && !warning_overlay_active)
		warning_overlay_active = TRUE
		overlays += image(icon, src, "LZ_warn")
	else if(!show_warning && warning_overlay_active)
		warning_overlay_active = FALSE
		overlays.Cut()

/obj/structure/emergency_shield/proc/get_damaged(var/damage, var/mob/attacker)
	if(!source_projector)
		qdel(src)
		return
	spark(src, 2)
	visible_message("<span class='warning'>\The [src] absorbs the impact!</span>")
	source_projector.absorb_damage(damage)

/obj/structure/emergency_shield/bullet_act(var/obj/item/projectile/Proj)
	playsound(src, 'sound/effects/EMPulse.ogg', 25, 1)
	get_damaged(Proj.damage)
	return PROJECTILE_COLLISION_DEFAULT

/obj/structure/emergency_shield/attack_hand(mob/living/user)
	if(user.a_intent == I_HURT)
		user.do_attack_animation(src, user)
		user.delayNextAttack(10)
		user.visible_message("<span class='warning'>[user] punches \the [src]!</span>", "<span class='notice'>You punch \the [src].</span>")
		playsound(src, 'sound/effects/EMPulse.ogg', 25, 1)
		get_damaged(5, user)
	else
		to_chat(user, "<span class='notice'>You touch \the [src]. It feels warm and tingly.</span>")

/obj/structure/emergency_shield/attackby(obj/item/weapon/W, mob/user)
	..()
	playsound(src, 'sound/effects/EMPulse.ogg', 25, 1)
	get_damaged(W.force, user)

/obj/structure/emergency_shield/proc/attack_generic(mob/living/user, damage = 0)
	if(damage <= 0)
		return
	playsound(src, 'sound/effects/EMPulse.ogg', 25, 1)
	get_damaged(damage, user)

/obj/structure/emergency_shield/attack_animal(mob/living/user)
	if(istype(user, /mob/living/simple_animal))
		var/mob/living/simple_animal/M = user
		if(M.melee_damage_upper <= 0)
			return
		attack_generic(M, M.melee_damage_upper/2)

/obj/structure/emergency_shield/ex_act(severity)
	var/damage = 100 / severity
	get_damaged(damage)

/obj/structure/emergency_shield/Destroy()
	if(source_projector)
		source_projector.shields -= src
		source_projector = null
	..()
