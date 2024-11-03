/obj/item/canned_heat
	name = "canned heat"
	desc = "1000K to be precise. Not safe for your heels."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "canned_heat"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	flags = FPRINT
	w_class = W_CLASS_TINY
	mech_flags = MECH_SCAN_FAIL
	var/list/open_sounds = list('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')
	var/open = FALSE
	var/heat = 1000

/obj/item/canned_heat/update_icon()
	overlays.len = 0
	if (open)
		overlays += image(icon = 'icons/obj/drinks.dmi', icon_state = "soda_open")

/obj/item/canned_heat/attack_self(var/mob/user)
	if (!open)
		to_chat(user, "You pull back the tab of \the [src] with a satisfying pop.")
		open = TRUE
		playsound(user, pick(open_sounds), 50, 1)
		update_icon()
		heat_up(user)
	else if (user.a_intent == I_HURT)
		var/turf/T = get_turf(user)
		user.drop_item(src, T, 1)
		var/obj/item/trash/soda_cans/crushed_can = new (T, icon_state = icon_state)
		crushed_can.name = "crushed [name]"
		user.put_in_active_hand(crushed_can)
		playsound(user, 'sound/items/can_crushed.ogg', 75, 1)
		qdel(src)

/obj/item/canned_heat/proc/heat_up(var/mob/user)
	if (istype(user.loc, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = user.loc
		var/datum/gas_mixture/air = P.parent.air
		air.temperature += heat
		air.update_values()
		for(var/mob/M in player_list)//most of the time it's gonna be faster to loop through the player list, than through the contents of all turfs in the zone
			if (istype(M.loc, /obj/machinery/atmospherics/pipe))
				var/obj/machinery/atmospherics/pipe/P_other = M.loc
				if (P.parent == P_other.parent)
					M.playsound_local(P_other.loc,'sound/items/canned_heat.ogg', 30, 0, null, FALLOFF_SOUNDS, 0)
					to_chat(M, "<span class='warning'>You feel canned heat in your heels tonight!</span>")
	else if (istype(user.loc, /obj/structure/inflatable/shelter))
		var/obj/structure/inflatable/shelter/S = user.loc
		var/datum/gas_mixture/air = S.cabin_air
		air.temperature += heat
		air.update_values()
		for (var/mob/M in S.contents)
			M.playsound_local(S.loc,'sound/items/canned_heat.ogg', 30, 0, null, FALLOFF_SOUNDS, 0)
			to_chat(M, "<span class='warning'>You feel canned heat in your heels tonight!</span>")
	else
		var/turf/T = get_turf(src)
		if (!T)
			return
		if (!istype(T, /turf/simulated))
			if (istype(T, /turf/space))
				to_chat(user, "<span class='warning'>The heat disperses into space...</span>")
			else
				to_chat(user, "<span class='warning'>The heat disperses into nothing...</span>")
			return
		var/turf/simulated/TS = T
		var/zone/target_zone = TS.zone
		if (!target_zone)
			to_chat(user, "<span class='warning'>The heat disperses into nothing...</span>")
			return

		target_zone.air.temperature += heat
		target_zone.air.update_values()
		for(var/mob/M in player_list)//most of the time it's gonna be faster to loop through the player list, than through the contents of all turfs in the zone
			if (isturf(M.loc))
				var/turf/U = M.loc
				if (U in target_zone.contents)
					M.playsound_local(U,'sound/items/canned_heat.ogg', 30, 0, null, FALLOFF_SOUNDS, 0)
					to_chat(M, "<span class='warning'>You feel canned heat in your heels tonight!</span>")
