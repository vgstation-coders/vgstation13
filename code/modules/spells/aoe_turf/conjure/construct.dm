//////////////////////////////Construct Spells/////////////////////////

/spell/aoe_turf/conjure/construct
	name = "Artificer"
	desc = "This spell conjures a construct which may be controlled by Shades"
	user_type = USER_TYPE_ARTIFACT

	school = "conjuration"
	charge_max = 600
	spell_flags = 0
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0

	summon_type = list(/obj/structure/constructshell)

	hud_state = "artificer"

/spell/aoe_turf/conjure/construct/lesser
	user_type = USER_TYPE_CULT

	charge_max = 1800
	summon_type = list(/obj/structure/constructshell/cult)
	hud_state = "const_shell"
	override_base = "const"

/spell/aoe_turf/conjure/floor
	name = "Floor Construction"
	desc = "This spell constructs a cult floor"
	user_type = USER_TYPE_CULT

	charge_max = 20
	spell_flags = Z2NOCAST | CONSTRUCT_CHECK
	invocation = "none"
	invocation_type = SpI_NONE
	range = 3
	summon_type = list(/turf/simulated/floor/engine/cult)

	hud_state = "const_floor"
	cast_sound = 'sound/items/welder.ogg'

/spell/aoe_turf/conjure/floor/choose_targets(mob/user = usr)
	return list(get_turf(user))

/spell/aoe_turf/conjure/floor/conjure_animation(var/atom/movable/overlay/animation, var/turf/target)
	animation.icon_state = "cultfloor"
	flick("cultfloor",animation)
	spawn(10)
		qdel(animation)
		animation = null

/spell/aoe_turf/conjure/wall
	name = "Lesser Construction"
	desc = "This spell constructs a cult wall"
	user_type = USER_TYPE_CULT

	charge_max = 100
	spell_flags = Z2NOCAST | CONSTRUCT_CHECK
	invocation = "none"
	invocation_type = SpI_NONE
	range = 3
	summon_type = list(/turf/simulated/wall/cult)

	hud_state = "const_wall"
	cast_sound = 'sound/items/welder.ogg'

/spell/aoe_turf/conjure/wall/choose_targets(mob/user = usr)
	return list(get_turf(user))

/spell/aoe_turf/conjure/wall/conjure_animation(var/atom/movable/overlay/animation, var/turf/target)
	animation.icon_state = "cultwall"
	flick("cultwall",animation)
	spawn(10)
		qdel(animation)
		animation = null

/spell/aoe_turf/conjure/wall/reinforced
	name = "Greater Construction"
	desc = "This spell constructs a reinforced metal wall"
	user_type = USER_TYPE_CULT

	charge_max = 300
	spell_flags = Z2NOCAST
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0
	cast_delay = 50
	cast_sound = 'sound/items/welder.ogg'

	summon_type = list(/turf/simulated/wall/r_wall)

/spell/aoe_turf/conjure/soulstone
	name = "Summon Soulstone"
	desc = "This spell reaches into Nar-Sie's realm, summoning one of the legendary fragments across time and space"
	user_type = USER_TYPE_CULT

	charge_max = 3000
	spell_flags = 0
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0

	summon_type = list(/obj/item/device/soulstone)

	hud_state = "const_stone"
	override_base = "const"

/spell/aoe_turf/conjure/pylon
	name = "Red Pylon"
	desc = "This spell conjures a fragile crystal from Nar-Sie's realm. Makes for a convenient light source."
	user_type = USER_TYPE_CULT

	charge_max = 200
	spell_flags = CONSTRUCT_CHECK|IGNORESPACE|IGNOREDENSE|NODUPLICATE
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0

	summon_type = list(/obj/structure/cult/pylon)

	cast_sound = 'sound/items/welder.ogg'
	hud_state = "const_pylon"

/spell/aoe_turf/conjure/pylon/cast(list/targets)
	..()
	var/turf/spawn_place = pick(targets)
	for(var/obj/structure/cult/pylon/P in spawn_place.contents)
		if(P.isbroken)
			P.repair(usr)
		continue
	return

/spell/aoe_turf/conjure/forcewall/lesser
	name = "Shield"
	desc = "Allows you to pull up a shield to protect yourself and allies from incoming threats"
	user_type = USER_TYPE_CULT

	charge_max = 300
	spell_flags = 0
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0
	summon_type = list(/obj/effect/forcefield/cult)
	duration = 200

	hud_state = "const_juggwall"

//Code for the Juggernaut construct's forcefield, that seemed like a good place to put it.
/obj/effect/forcefield/cult
	desc = "That eerie looking obstacle seems to have been pulled from another dimension through sheer force"
	name = "Juggerwall"
	icon = 'icons/effects/effects.dmi'
	icon_state = "m_shield_cult"
	light_color = LIGHT_COLOR_RED
	luminosity = 2
	invisibility = 0

/obj/effect/forcefield/cult/cultify()
	return
