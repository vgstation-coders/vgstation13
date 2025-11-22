/datum/artifact_effect/cellbattery
	effecttype = "cellbattery"
	valid_artifact_styles = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_ANCIENT, ARTIFACT_STYLE_PRECURSOR, ARTIFACT_STYLE_RELIQUARY)
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_hint = EFFECT_HINT_ELECTROMAGNETIC_ENERGY
	var/recharge = 1
	copy_for_battery = list("recharge")

/datum/artifact_effect/cellbattery/New()
	..()
	if(prob(50))
		recharge = 0

/datum/artifact_effect/cellbattery/DoEffectTouch(var/mob/user)
	var/obj/item/weapon/cell/target_cell = user.get_cell()
	if(target_cell)
		if(isrobot(user))
			to_chat(user, "<span class='[recharge ? "notice" : "warning"]'>SYSTEM ALERT: Large energy [recharge ? "boost" : "drain"] detected!</span>")

		if (recharge)
			target_cell.give(500)
		else
			target_cell.use(min(500, target_cell.charge))


/datum/artifact_effect/cellbattery/DoEffectAura()
	if(holder)
		for(var/atom/movable/C in range(effectrange, get_turf(holder)))
			var/obj/item/weapon/cell/target_cell = C.get_cell()
			if(target_cell)
				if(isrobot(C))
					if (prob(1))
						to_chat(C, "<span class='[recharge ? "notice" : "warning"]'>SYSTEM ALERT: Energy [recharge ? "boost" : "drain"] detected!</span>")

				if (recharge)
					target_cell.give(200)
				else
					target_cell.use(min(200, target_cell.charge))

		if (recharge)
			for(var/obj/machinery/power/battery/S in range(effectrange, holder))
				S.charge = min(S.capacity, S.charge + 2000)
		else
			for(var/obj/machinery/power/battery/S in range(effectrange, holder))
				S.charge = max(0, S.charge - 2000)


/datum/artifact_effect/cellbattery/DoEffectPulse()
	if(holder)
		for(var/atom/movable/C in range(effectrange, get_turf(holder)))
			var/obj/item/weapon/cell/target_cell = C.get_cell()
			if(target_cell)
				if(isrobot(C) )
					to_chat(C, "<span class='[recharge ? "notice" : "warning"]'>SYSTEM ALERT: Large energy [recharge ? "boost" : "drain"] detected!</span>")
				if (recharge)
					target_cell.give(300 * chargelevelmax)
				else
					target_cell.use(min(300 * chargelevelmax, target_cell.charge))

		if (recharge)
			for(var/obj/machinery/power/battery/S in range(effectrange, holder))
				S.charge = min(S.capacity, S.charge + 3000 * chargelevelmax)
		else
			for(var/obj/machinery/power/battery/S in range(effectrange, holder))
				S.charge = max(0, S.charge - 3000 * chargelevelmax)

