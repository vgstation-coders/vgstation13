
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
        if (PD.charge < charge_cost)
            to_chat(PD, "<span class='warning'>You are too low on power, this spell needs a charge of [PD.charge] to cast.</span>")
            return FALSE
    else //only pulse demons allowed
        message_admins("[user.real_name] has a pulse demon spell... and they aren't a pulse demon!")
        return FALSE

/spell/pulse_demon/cast(var/list/targets, var/mob/living/carbon/human/user)
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        PD.charge -= charge_cost

/spell/pulse_demon/empower_spell()
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

    charge_cost /= 1.5
    return temp

/spell/pulse_demon/is_valid_target(var/atom/target, mob/user, options)
    if(options)
        return (target in options)
    return (target in view_or_range(range, user, selection_type))

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
    if(!cable || !istype(cable))
        to_chat(user,"<span class='warning'>...Where's the cable?</span>")
        return
    var/obj/item/projectile/beam/lightning/L = new /obj/item/projectile/beam/lightning(T)
    var/datum/powernet/PN = cable.get_powernet()
    if(PN)
        L.damage = PN.get_electrocute_damage()
    if(L.damage <= 0)
        qdel(L)
        to_chat(user,"<span class='warning'>There is no power to jolt you across!</span>")
    else
        playsound(target, 'sound/effects/eleczap.ogg', 75, 1)
        L.tang = adjustAngle(get_angle(target,T))
        L.icon = midicon
        L.icon_state = "[L.tang]"
        L.firer = user
        L.def_zone = LIMB_CHEST
        L.original = target
        L.current = target
        L.starting = target
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
    purchase_cost = 100000
    upgrade_cost = 50000

/spell/pulse_demon/emag/cast(list/targets, mob/user = usr)
    var/atom/target = targets[1]
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        if(PD.controlling_area == get_area(target))
            if(istype(target,/obj/machinery))
                var/obj/machinery/M = target
                M.emag(PD)
                ..()
                return
            target.emag_act(PD)
            ..()
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
    purchase_cost = 50000
    upgrade_cost = 20000

/spell/pulse_demon/emp/cast(list/targets, mob/user = usr)
    var/atom/target = targets[1]
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/mob/living/simple_animal/hostile/pulse_demon/PD = user
        if(PD.controlling_area == get_area(target))
            target.emp_act(1)
            ..()
        else
            to_chat(holder, "You need to be in an APC for this!")

/spell/pulse_demon/overload_machine
    name = "Overload Machine"
    abbreviation = "OM"
    desc = "Overloads the electronics in a machine, causing an explosion. Must be inside a compromised APC to use."

    range = 10
    spell_flags = WAIT_FOR_CLICK
    duration = 20

    hud_state = "overload"
    charge_cost = 50000
    purchase_cost = 200000
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