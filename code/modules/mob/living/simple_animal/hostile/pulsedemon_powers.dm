
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
    if(isturf(target))
        var/turf/T = target
        return ((target in view_or_range(range, user, selection_type)) && (locate(/obj/structure/cable) in T.contents))
    return

/spell/pulse_demon/cable_zap/cast(list/targets, mob/user = usr)
    var/turf/T = get_turf(user)
    var/turf/target = get_turf(targets[1])
    var/obj/item/projectile/beam/lightning/L = new /obj/item/projectile/beam/lightning(T)
    L.damage = 15
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