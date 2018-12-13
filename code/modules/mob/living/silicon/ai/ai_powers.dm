/mob/proc/remove_malf_spells()
	for(var/spell/S in spell_list)
		if(S.panel == MALFUNCTION)
			remove_spell(S)

/spell/aoe_turf/corereturn
	name = "Return to Core"
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 1
	hud_state = "unshunt"
	override_base = "grey"

/spell/aoe_turf/corereturn/before_target(mob/user)
	if(istype(user.loc, /obj/machinery/power/apc))
		return FALSE
	else
		to_chat(user, "<span class='notice'>You are already in your Main Core.</span>")
		return TRUE

/spell/aoe_turf/corereturn/choose_targets(mob/user = usr)
	return list(user.loc)

/spell/aoe_turf/corereturn/cast(var/list/targets, mob/user)
	var/obj/machinery/power/apc/apc = targets[1]
	apc.malfvacate()