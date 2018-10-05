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

	summon_type = list(/obj/structure/cult_legacy/pylon)

	cast_sound = 'sound/items/welder.ogg'
	hud_state = "const_pylon"

/spell/aoe_turf/conjure/pylon/cast(list/targets)
	..()
	var/turf/spawn_place = pick(targets)
	for(var/obj/structure/cult_legacy/pylon/P in spawn_place.contents)
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

/obj/effect/forcefield/cult/New()
	..()
	set_light(2)

/obj/effect/forcefield/cult/cultify()
	return


/spell/aoe_turf/conjure/forcewall/greater
	name = "Juggerwall"
	desc = "Raise a temporary line of indestructible walls to block your enemies' path and protect your allies."
	user_type = USER_TYPE_CULT

	charge_max = 300
	spell_flags = 0
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0
	summon_type = list(/obj/effect/forcefield/cult/large)
	duration = 200

	hud_state = "const_juggwall2
	override_base = "cult""

/spell/aoe_turf/conjure/forcewall/greater/on_creation(var/obj/effect/forcefield/cult/large/AM, var/mob/user)
	AM.layer++
	var/turf/turf_left = null
	var/turf/turf_right = null
	switch	(user.dir)
		if (SOUTH)
			turf_left = get_step(AM, EAST)
			turf_right = get_step(AM, WEST)
		if (NORTH)
			turf_left = get_step(AM, WEST)
			turf_right = get_step(AM, EAST)
		if (EAST)
			turf_left = get_step(AM, NORTH)
			turf_right = get_step(AM, SOUTH)
		if (WEST)
			turf_left = get_step(AM, SOUTH)
			turf_right = get_step(AM, NORTH)
	if (!turf_left.density && !turf_left.has_dense_content())
		AM.side1 = new (AM.loc)
		AM.side1.icon_state += "_side"
		AM.side1.dir = get_dir(AM, turf_left)
		spawn (1)
			AM.side1.forceMove(turf_left)
	if (!turf_right.density && !turf_right.has_dense_content())
		AM.side2 = new (AM.loc)
		AM.side2.icon_state += "_side"
		AM.side2.dir = get_dir(AM, turf_right)
		spawn (1)
			AM.side2.forceMove(turf_right)
	if (!AM.side1 && AM.side2)
		var/turf/extra = get_step(turf_right,AM.side2.dir)
		if (!extra.density && !extra.has_dense_content())
			spawn (2)
				AM.side2.forceMove(extra)
				AM.side1 = new (AM.loc)
				AM.side1.icon_state += "_mid"
				AM.side1.dir = get_dir(AM, turf_right)
				AM.side1.forceMove(turf_right)
	if (AM.side1 && !AM.side2)
		var/turf/extra = get_step(turf_left,AM.side1.dir)
		if (!extra.density && !extra.has_dense_content())
			spawn (2)
				AM.side1.forceMove(get_step(turf_left,AM.side1.dir))
				AM.side2 = new (AM.loc)
				AM.side2.icon_state += "_mid"
				AM.side2.dir = get_dir(AM, turf_left)
				AM.side2.forceMove(turf_left)


//Code for the Juggernaut construct's forcefield, that seemed like a good place to put it.
/obj/effect/forcefield/cult/large
	desc = "That eerie looking obstacle seems to have been pulled from another dimension through sheer force"
	name = "Juggerwall"
	icon = 'icons/effects/effects.dmi'
	icon_state = "juggerwall"
	light_color = LIGHT_COLOR_RED
	luminosity = 2
	invisibility = 0
	explosion_block = 200
	var/obj/effect/forcefield/cult/large/side1 = null
	var/obj/effect/forcefield/cult/large/side2 = null

/obj/effect/forcefield/cult/large/Destroy()
	if (loc)
		new /obj/effect/red_afterimage(loc,src)
	if (side1)
		qdel(side1)
	if (side2)
		qdel(side2)
	side1 = null
	side2 = null
	..()
	..()
