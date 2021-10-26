
/spell/pulse_demon
    user_type = USER_TYPE_PULSEDEMON
    school = "pulse demon"
    override_base = "pulsedemon"
    hud_state = "pd_icon_base"

/spell/pulse_demon/cable_zap
    name = "Cable Hop"
    abbreviation = "CH"
    desc = "Jump to another cable in view"

    range = 20
    spell_flags = WAIT_FOR_CLICK
    duration = 20

    hud_state = "pd_cablehop"

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