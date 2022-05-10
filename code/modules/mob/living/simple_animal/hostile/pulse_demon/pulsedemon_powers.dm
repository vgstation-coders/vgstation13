/datum/pulse_demon_upgrade
    var/ability_name = "Pulse demon upgrade"
    var/ability_desc = "An upgrade for a pulse demon's inate abilities"
    var/mob/living/simple_animal/hostile/pulse_demon/host
    var/condition = TRUE // So we know if we can display this in the menu
    var/upgrade_cost = 0

/datum/pulse_demon_upgrade/New(mob/living/simple_animal/hostile/pulse_demon/PD)
    host = PD
    update_condition_and_cost()

// Called on purchase and setup for handling in the menu
/datum/pulse_demon_upgrade/proc/update_condition_and_cost()
    if(!host)
        message_admins("Somebody set up a pulse demon upgrade ([ability_name]) without assigning the host!")
        return

/datum/pulse_demon_upgrade/proc/on_purchase()
    if(!host)
        message_admins("Somebody set up a pulse demon upgrade ([ability_name]) without assigning the host!")
        return FALSE
    if(host.charge < upgrade_cost)
        to_chat(host,"<span class='warning'>You cannot afford this upgrade.</span>")
        return FALSE

    host.charge -= upgrade_cost
    return TRUE

/datum/pulse_demon_upgrade/takeover
    ability_name = "Faster takeover time"
    ability_desc = "Allows hijacking of electronics in less time."

/datum/pulse_demon_upgrade/takeover/update_condition_and_cost()
    condition = host.takeover_time >= 1
    upgrade_cost = 10000 * (100 / host.takeover_time)

/datum/pulse_demon_upgrade/takeover/on_purchase()
    if(..())
        host.takeover_time /= 1.5
        to_chat(host,"<span class='notice'>You will now take [host.takeover_time] seconds to hijack machinery.</span>")
        update_condition_and_cost()

/datum/pulse_demon_upgrade/absorbing
    ability_name = "Faster power absorbing"
    ability_desc = "Allows more power absorbed per second."

/datum/pulse_demon_upgrade/absorbing/update_condition_and_cost()
    condition = host.charge_absorb_amount <= 600000
    upgrade_cost = host.charge_absorb_amount * 10

/datum/pulse_demon_upgrade/absorbing/on_purchase()
    if(..())
        host.charge_absorb_amount *= 1.5
        to_chat(host,"<span class='notice'>You will now absorb [host.charge_absorb_amount]W per second while in a power source.</span>")
        update_condition_and_cost()

/datum/pulse_demon_upgrade/drain
    ability_name = "Slower health drain"
    ability_desc = "Allows less health to be drained when not on a power source."

/datum/pulse_demon_upgrade/drain/update_condition_and_cost()
    condition = host.health_drain_rate >= 1
    upgrade_cost = 10000 * (100 / host.health_drain_rate)

/datum/pulse_demon_upgrade/drain/on_purchase()
    if(..())
        host.health_drain_rate /= 1.5
        to_chat(host,"<span class='notice'>You will now drain [host.health_drain_rate] health per second while not on a power source.</span>")
        update_condition_and_cost()

/datum/pulse_demon_upgrade/regeneration
    ability_name = "Faster health regeneration"
    ability_desc = "Allows more health to be regenerated when on a power source."

/datum/pulse_demon_upgrade/regeneration/update_condition_and_cost()
    condition = host.health_regen_rate <= host.maxHealth
    upgrade_cost = host.health_regen_rate * 10000

/datum/pulse_demon_upgrade/regeneration/on_purchase()
    if(..())
        host.health_regen_rate *= 1.5
        to_chat(host,"<span class='notice'>You will now drain [host.health_regen_rate] health per second while on a power source.</span>")
        update_condition_and_cost()

/datum/pulse_demon_upgrade/health
    ability_name = "Increased max health"
    ability_desc = "Increases the limit of your current health."

/datum/pulse_demon_upgrade/health/update_condition_and_cost()
    condition = host.maxHealth <= 200
    upgrade_cost = host.maxHealth * 1000

/datum/pulse_demon_upgrade/health/on_purchase()
    if(..())
        host.maxHealth *= 1.5
        host.health *= 1.5
        to_chat(host,"<span class='notice'>Your maximum health is now [host.maxHealth].</span>")
        update_condition_and_cost()

/datum/pulse_demon_upgrade/regencost
    ability_name = "Lower regeneration amount drain"
    ability_desc = "Drains less power per second to regenerate health."

/datum/pulse_demon_upgrade/regencost/update_condition_and_cost()
    condition = host.amount_per_regen >= 1
    upgrade_cost = 10000 * (100 / host.amount_per_regen)

/datum/pulse_demon_upgrade/regencost/on_purchase()
    if(..())
        host.amount_per_regen /= 1.5
        to_chat(host,"<span class='notice'>You will now drain [host.amount_per_regen] per second to regenerate health.</span>")
        update_condition_and_cost()

/mob/living/simple_animal/hostile/pulse_demon/proc/powerMenu()
	var/dat
	dat += {"<B>Select a spell ([charge]W left to purchase with)</B><BR>
			<A href='byond://?src=\ref[src];desc=1'>(Show [show_desc ? "less" : "more"] info)</A><HR>"}
	// Shows only upgrades that meet the conditions
	if(possible_upgrades.len)
		dat += "<B>Upgrades:</B><BR>"
		for(var/datum/pulse_demon_upgrade/PDU in possible_upgrades)
			if(!PDU.condition)
				possible_upgrades.Remove(PDU)
			else
				dat += "<A href='byond://?src=\ref[src];upgrade=1;thing=\ref[PDU]''>[PDU.ability_name] ([PDU.upgrade_cost]W)</A><BR>"
				if(show_desc)
					dat += "<I>[PDU.ability_desc]</I><BR>"
		dat += "<HR>"
	if(spell_list.len > 1)
		dat += "<B>Known abilities:</B><BR>"
		for(var/spell/pulse_demon/S in spell_list)
			if(!istype(S,/spell/pulse_demon/abilities))
				var/icon/spellimg = icon('icons/mob/screen_spells.dmi', S.hud_state)
				dat += "<img class='icon' src='data:image/png;base64,[iconsouth2base64(spellimg)]'> <B>[S.name]</B> "
				dat += "[S.can_improve(Sp_SPEED) || S.can_improve(Sp_POWER) ? "(Upgrade for [S.upgrade_cost]W) " : ""]"
				dat += "[S.can_improve(Sp_SPEED) ? "<A href='byond://?src=\ref[src];quicken=1;spell=\ref[S]'>Quicken</A>" : ""] "
				dat += "[S.can_improve(Sp_POWER) ? "<A href='byond://?src=\ref[src];empower=1;spell=\ref[S]'>Empower</A>" : ""]<BR>"
				if(show_desc)
					dat += "<I>[S.desc]</I><BR>"
		dat += "<HR>"
	if(possible_spells.len)
		dat += "<B>Available abilities:</B><BR>"
		dat += "<I>The number afterwards is the charge cost.</I><BR>"
		for(var/spell/pulse_demon/PDS in possible_spells)
			var/icon/spellimg = icon('icons/mob/screen_spells.dmi', PDS.hud_state)
			dat += "<img class='icon' src='data:image/png;base64,[iconsouth2base64(spellimg)]'> "
			dat += "<B><A href='byond://?src=\ref[src];buy=1;spell=\ref[PDS]'>[PDS.name]</A></B> ([PDS.purchase_cost]W)<BR>"
			if(show_desc)
				dat += "<I>[PDS.desc]</I><BR>"
		dat += "<HR>"
	var/datum/browser/popup = new(src, "abilitypicker", "Pulse Demon Ability Menu", 640, 480)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/hostile/pulse_demon/Topic(href, href_list)
    ..()
    if(href_list["upgrade"])
        var/datum/pulse_demon_upgrade/PDU = locate(href_list["thing"])
        PDU.on_purchase()

    if(href_list["buy"])
        var/spell/pulse_demon/PDS = locate(href_list["spell"])
        if(PDS.purchase_cost > charge)
            to_chat(src,"<span class='warning'>You cannot afford this ability.</span>")
            return

        // Give the power and take away the money.
        add_spell(PDS, "pulsedemon_spell_ready",/obj/abstract/screen/movable/spell_master/pulse_demon)
        charge -= PDS.purchase_cost
        possible_spells.Remove(PDS)

    if(href_list["desc"])
        show_desc = !show_desc

    if(href_list["quicken"])
        var/spell/pulse_demon/PDS = locate(href_list["spell"])
        if(PDS.spell_flags & NO_BUTTON)
            to_chat(src,"<span class='warning'>This cannot be cast, so cannot be quickened.</span>")
            return
        if(PDS.upgrade_cost > charge)
            to_chat(src,"<span class='warning'>You cannot afford this upgrade.</span>")
            return
        if(PDS.spell_levels[Sp_SPEED] >= PDS.level_max[Sp_SPEED])
            to_chat(src,"<span class='warning'>You cannot quicken this ability any further.</span>")
            return

        PDS.quicken_spell()
        charge -= PDS.upgrade_cost

    if(href_list["empower"])
        var/spell/pulse_demon/PDS = locate(href_list["spell"])
        if(PDS.upgrade_cost > charge)
            to_chat(src,"<span class='warning'>You cannot afford this upgrade.</span>")
            return
        if(PDS.spell_levels[Sp_POWER] >= PDS.level_max[Sp_POWER])
            to_chat(src,"<span class='warning'>You cannot empower this ability any further.</span>")
            return

        PDS.empower_spell()
        charge -= PDS.upgrade_cost

    powerMenu()

/spell/pulse_demon
    name = "Pulse Demon Spell"
    desc = "A template pulse demon spell."
    abbreviation = "PD"
    still_recharging_msg = "<span class='warning'>You're still warming up!</span>"

    user_type = USER_TYPE_PULSEDEMON
    school = "pulse demon"
    spell_flags = 0
    level_max = list(Sp_TOTAL = 3, Sp_SPEED = 3, Sp_POWER = 3)

    override_base = "pulsedemon"
    hud_state = "pd_icon_base"
    charge_max = 20 SECONDS
    cooldown_min = 1 SECONDS
    var/charge_cost = 0
    var/purchase_cost = 0
    var/upgrade_cost = 0

/spell/pulse_demon/cast_check(var/skipcharge = 0, var/mob/user = usr)
    . = ..()
    if (!.)
        return FALSE
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        if (PD.charge < charge_cost) // Custom charge handling
            to_chat(PD, "<span class='warning'>You are too low on power, this spell needs a charge of [PD.charge] to cast.</span>")
            return FALSE
    else //only pulse demons allowed
        message_admins("[user.real_name] has a pulse demon spell... and they aren't a pulse demon!")
        return FALSE

/spell/pulse_demon/cast(var/list/targets, var/mob/living/carbon/human/user)
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        PD.charge -= charge_cost // Removing chage here

/spell/pulse_demon/empower_spell() // Makes spells use less charge
	if(!can_improve(Sp_POWER))
		return 0

	spell_levels[Sp_POWER]++

	name = initial(name)
	switch(level_max[Sp_POWER] - spell_levels[Sp_POWER])
		if(3)
			. = "You have improved [name] into Frugal [name]."
			name = "Frugal [name]"
		if(2)
			. = "You have improved [name] into Cheap [name]."
			name = "Cheap [name]"
		if(1)
			. = "You have improved [name] into Renewable [name]."
			name = "Renewable [name]"
		if(0)
			. = "You have improved [name] into Self-Sufficient [name]."
			name = "Self-Sufficient [name]"

	charge_cost /= 1.5
	upgrade_cost *= 1.5

/spell/pulse_demon/quicken_spell()
	. = ..()
	if(.)
		upgrade_cost *= 1.5

/spell/pulse_demon/is_valid_target(var/atom/target)
    return 1

// The menu itself
/spell/pulse_demon/abilities
    name = "Abilities"
    desc = "View and purchase abilities with your electrical charge."
    abbreviation = "AB"
    hud_state = "pd_closed"
    charge_max = 0
    level_max = list()

/spell/pulse_demon/abilities/choose_targets(var/mob/user = usr)
    return list(user) // Self-cast

/spell/pulse_demon/abilities/cast(var/list/targets, var/mob/living/carbon/human/user)
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        PD.powerMenu()

/spell/pulse_demon/toggle_drain
    name = "Toggle power drain"
    desc = "Toggles the draining of power while in an APC, battery or cable"
    abbreviation = "TD"
    hud_state = "pd_toggle"
    charge_max = 0
    level_max = list()

/spell/pulse_demon/toggle_drain/choose_targets(var/mob/user = usr)
    return list(user) // Self-cast

/spell/pulse_demon/toggle_drain/cast(var/list/targets, var/mob/living/carbon/human/user)
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        PD.draining = !PD.draining
        to_chat(user,"<span class='notice'>Draining power is [PD.draining ? "on" : "off"].</span>")

/spell/pulse_demon/cable_zap
    name = "Cable Hop"
    abbreviation = "CH"
    desc = "Jump to another cable in view"

    range = 5
    spell_flags = WAIT_FOR_CLICK
    duration = 20

    hud_state = "pd_cablehop"
    charge_cost = 5000
    purchase_cost = 15000
    upgrade_cost = 10000

// Must be a cable or a clicked on turf with a cable
/spell/pulse_demon/cable_zap/is_valid_target(var/target, mob/user, options)
    if(options)
        return (target in options)
    var/turf/T = get_turf(target)
    if(T)
        return ((target in view_or_range(range, user, selection_type)) && (locate(/obj/structure/cable) in T.contents))
    return ((target in view_or_range(range, user, selection_type)) && istype(target,/obj/structure/cable))

/spell/pulse_demon/cable_zap/cast(list/targets, mob/user = usr)
    var/turf/T = get_turf(user)
    var/turf/target = get_turf(targets[1])
    var/obj/structure/cable/cable = locate() in target
    if(!cable || !istype(cable)) // Sanity
        to_chat(user,"<span class='warning'>...Where's the cable?</span>")
        return
    var/obj/item/projectile/beam/lightning/L = new /obj/item/projectile/beam/lightning(T)
    var/datum/powernet/PN = cable.get_powernet()
    if(PN) // We need actual power in the cable powernet to move
        L.damage = PN.get_electrocute_damage()
    if(L.damage <= 0)
        qdel(L)
        to_chat(user,"<span class='warning'>There is no power to jolt you across!</span>")
    else
        // Ride the lightning
        playsound(target, pick(lightning_sound), 75, 1)
        L.tang = adjustAngle(get_angle(target,T))
        L.icon = midicon
        L.icon_state = "[L.tang]"
        L.firer = user
        L.def_zone = LIMB_CHEST
        L.original = target
        L.current = T
        L.starting = T
        L.yo = target.y - T.y
        L.xo = target.x - T.x
        spawn L.process()
        user.forceMove(target)
        ..()

/spell/pulse_demon/emag
    name = "Electromagnetic Tamper"
    abbreviation = "ES"
    desc = "Unlocks hidden programming in machines. Must be inside a compromised APC to use."

    range = 10
    spell_flags = WAIT_FOR_CLICK
    duration = 20

    hud_state = "pd_emag"
    charge_cost = 20000
    purchase_cost = 200000
    upgrade_cost = 50000

/spell/pulse_demon/emag/cast(list/targets, mob/user = usr)
    var/atom/target = targets[1]
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        if(PD.controlling_area == get_area(target))
            target.emag_act(PD)
            ..()
        // Only works in an APC
        else if(istype(PD.loc,/obj/machinery/power/apc))
            to_chat(holder, "You can only cast this in the area you control!")
        else
            to_chat(holder, "You need to be in an APC for this!")

/spell/pulse_demon/emp
    name = "Electromagnetic Pulse"
    abbreviation = "EP"
    desc = "EMPs a targeted machine. Must be inside a compromised APC to use."

    range = 10
    spell_flags = WAIT_FOR_CLICK
    duration = 20

    hud_state = "wiz_tech"
    charge_cost = 10000
    purchase_cost = 150000
    upgrade_cost = 50000

/spell/pulse_demon/emp/cast(list/targets, mob/user = usr)
    var/atom/target = targets[1]
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        if(PD.controlling_area == get_area(target))
            empulse(get_turf(target),1,1,0)
            ..()
        // Only works in an APC
        else if(istype(PD.loc,/obj/machinery/power/apc))
            to_chat(holder, "You can only cast this in the area you control!")
        else
            to_chat(holder, "You need to be in an APC for this!")

// Similar to malf one
/spell/pulse_demon/overload_machine
    name = "Overload Machine"
    abbreviation = "OM"
    desc = "Overloads the electronics in a machine, causing an explosion. Must be inside a compromised APC to use."

    range = 10
    spell_flags = WAIT_FOR_CLICK
    duration = 20

    hud_state = "overload"
    charge_cost = 50000
    purchase_cost = 300000
    upgrade_cost = 100000

/spell/pulse_demon/overload_machine/is_valid_target(var/atom/target)
    if(istype(target, /obj/item/device/radio/intercom))
        return 1
    if (istype(target, /obj/machinery))
        var/obj/machinery/M = target
        return M.can_overload()
    else
        to_chat(holder, "That is not a machine.")

/spell/pulse_demon/overload_machine/cast(var/list/targets, mob/user)
    var/obj/machinery/M = targets[1]
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        if(PD.controlling_area == get_area(M))
            M.visible_message("<span class='notice'>You hear a loud electrical buzzing sound!</span>")
            spawn(50)
                explosion(get_turf(M), -1, 1, 2, 3, whodunnit = user) //C4 Radius + 1 Dest for the machine
                qdel(M)
            ..()
        // Only works in an APC
        else if(istype(PD.loc,/obj/machinery/power/apc))
            to_chat(holder, "You can only cast this in the area you control!")
        else
            to_chat(holder, "You need to be in an APC for this!")

/spell/pulse_demon/remote_hijack
    name = "Remote Hijack"
    abbreviation = "RH"
    desc = "Remotely hijacks an APC"

    range = 10
    spell_flags = WAIT_FOR_CLICK
    duration = 20

    hud_state = "pd_hijack"
    charge_cost = 10000
    purchase_cost = 100000
    upgrade_cost = 20000

/spell/pulse_demon/remote_hijack/is_valid_target(var/atom/target)
    if(istype(target, /obj/machinery/power/apc))
        var/obj/machinery/power/apc/A = target
        if(!A.pulsecompromised)
            return 1
        else
            to_chat(holder, "This APC is already hijacked.")
    else
        to_chat(holder, "That is not an APC.")

/spell/pulse_demon/remote_hijack/cast(var/list/targets, mob/user)
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        var/obj/machinery/power/apc/A = targets[1]
        PD.hijackAPC(A)

/spell/pulse_demon/remote_drain
    name = "Remote Drain"
    abbreviation = "RD"
    desc = "Remotely drains a power source"

    range = 10
    spell_flags = WAIT_FOR_CLICK
    duration = 20

    hud_state = "pd_drain"
    charge_cost = 10000
    purchase_cost = 50000
    upgrade_cost = 10000

/spell/pulse_demon/remote_drain/is_valid_target(var/atom/target)
    if(istype(target, /obj/machinery/power/apc) || istype(target, /obj/machinery/power/battery))
        return 1
    else
        to_chat(holder, "That is not a valid drainable power source.")

/spell/pulse_demon/remote_drain/cast(var/list/targets, mob/user)
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        var/obj/machinery/power/P = targets[1]
        if(istype(P,/obj/machinery/power/apc))
            var/obj/machinery/power/apc/A = P
            PD.drainAPC(A)
        else if(istype(P,/obj/machinery/power/battery))
            var/obj/machinery/power/battery/B = P
            PD.suckBattery(B)

/spell/pulse_demon/sustaincharge
    level_max = list(Sp_TOTAL = 3, Sp_POWER = 3) // Why would cooldown be here?
    charge_max = 1 SECONDS // See?
    hud_state = "pd_cableleave"
    name = "Self-Sustaining Charge"
    abbreviation = "SC"
    desc = "Toggle that allows leaving cables for brief periods of time, while moving at a slower speed."
    purchase_cost = 500000
    upgrade_cost = 200000

/spell/pulse_demon/sustaincharge/choose_targets(var/mob/user = usr)
	return list(user) // Self-cast

/spell/pulse_demon/sustaincharge/cast(var/list/targets, mob/user)
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        PD.can_leave_cable = !PD.can_leave_cable
        to_chat(user,"<span class='notice'>Leaving cables is [PD.can_leave_cable ? "on" : "off"].</span>")

// Custom proc that instead allows less slowdown when off cable, while less than current max speed
/spell/pulse_demon/sustaincharge/empower_spell()
    if(istype(usr,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = usr
        spell_levels[Sp_POWER]++

        var/temp = ""
        name = initial(name)
        switch(level_max[Sp_POWER] - spell_levels[Sp_POWER])
            if(3)
                temp = "You have improved [name] into Frugal [name]."
                name = "Frugal [name]"
            if(2)
                temp = "You have improved [name] into Cheap [name]."
                name = "Cheap [name]"
            if(1)
                temp = "You have improved [name] into Renewable [name]."
                name = "Renewable [name]"
            if(0)
                temp = "You have improved [name] into Self-Sufficient [name]."
                name = "Self-Sufficient [name]"


        if(PD.move_divide > 1)
            PD.move_divide *= 0.75
        return temp
