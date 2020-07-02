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
	override_base = "cult"
	cast_delay = 40

/spell/aoe_turf/conjure/construct/lesser/alt
	summon_type = list(/obj/structure/constructshell/cult/alt)
	hud_state = "const_shell_alt"

/spell/aoe_turf/conjure/construct/lesser/spell_do_after(var/mob/user as mob, delay as num, var/numticks = 5)
	if(!delay_animation)
		delay_animation = new /obj/effect/artificer_underlay(get_turf(user))
		playsound(user, 'sound/items/welder.ogg', 100, 1)
	. = ..()

/spell/aoe_turf/conjure/floor
	name = "Floor Construction"
	desc = "This spell constructs a cult floor"
	user_type = USER_TYPE_CULT

	charge_max = 50
	spell_flags = Z2NOCAST | CONSTRUCT_CHECK
	invocation = "none"
	invocation_type = SpI_NONE
	range = 3
	summon_type = list(/turf/simulated/floor/engine/cult)

	override_base = "cult"
	hud_state = "const_floor"
	cast_sound = 'sound/items/welder.ogg'

/spell/aoe_turf/conjure/floor/choose_targets(mob/user = usr)
	return list(get_turf(user))

/spell/aoe_turf/conjure/floor/cast(list/targets, mob/user)//if we convert a floor instead of building one from scratch, the charge time for the next cast is lowered.
	var/turf/spawn_place = pick(targets)
	var/convert_floor = 0
	if (istype(spawn_place,/turf/simulated/floor))
		convert_floor = 1
	. = ..()
	if (!.)
		if (convert_floor)
			charge_max = 10
		else
			charge_max = 50

/spell/aoe_turf/conjure/floor/conjure_animation(var/atom/movable/overlay/animation, var/turf/target)
	animation.icon_state = "cultfloor"
	flick("cultfloor",animation)
	shadow(target,holder.loc,"artificer_convert")
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

	override_base = "cult"
	hud_state = "const_wall"
	cast_sound = 'sound/items/welder.ogg'

/spell/aoe_turf/conjure/wall/choose_targets(mob/user = usr)
	return list(get_turf(user))

/spell/aoe_turf/conjure/wall/cast(list/targets, mob/user)//if we convert a wall instead of building one from scratch, the charge time for the next cast is lowered.
	var/turf/spawn_place = pick(targets)
	var/convert_wall = 0
	if (istype(spawn_place,/turf/simulated/wall))
		convert_wall = 1
	. = ..()
	if (!.)
		if (convert_wall)
			charge_max = 20
		else
			charge_max = 100

/spell/aoe_turf/conjure/wall/conjure_animation(var/atom/movable/overlay/animation, var/turf/target)
	animation.icon_state = "cultwall"
	flick("cultwall",animation)
	shadow(target,holder.loc,"artificer_convert")
	spawn(10)
		qdel(animation)
		animation = null

/spell/aoe_turf/conjure/door
	name = "Cult Door"
	desc = "This spell constructs a cult wall"
	user_type = USER_TYPE_CULT

	charge_max = 100
	spell_flags = Z2NOCAST | CONSTRUCT_CHECK
	invocation = "none"
	invocation_type = SpI_NONE
	range = 3
	summon_type = list(/obj/machinery/door/mineral/cult)

	override_base = "cult"
	hud_state = "const_door"
	cast_sound = 'sound/items/welder.ogg'

/spell/aoe_turf/conjure/door/choose_targets(mob/user = usr)
	return list(get_turf(user))

/spell/aoe_turf/conjure/door/conjure_animation(var/atom/movable/overlay/animation, var/turf/target)
	animation.icon_state = ""
	flick("",animation)
	shadow(target,holder.loc,"artificer_convert")
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
	cast_delay = 30

	summon_type = list(/obj/item/device/soulstone)

	hud_state = "const_stone"
	override_base = "cult"

/spell/aoe_turf/conjure/soulstone/spell_do_after(var/mob/user as mob, delay as num, var/numticks = 5)
	if(!delay_animation)
		delay_animation = new /obj/effect/artificer_underlay(get_turf(user))
		playsound(user, 'sound/items/welder.ogg', 100, 1)
	. = ..()

/spell/aoe_turf/conjure/pylon
	name = "Red Pylon"
	desc = "This spell conjures a fragile crystal from Nar-Sie's realm. Makes for a convenient light source."
	user_type = USER_TYPE_CULT

	charge_max = 200
	spell_flags = CONSTRUCT_CHECK|IGNORESPACE|IGNOREDENSE|NODUPLICATE
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0
	cast_delay = 20

	summon_type = list(/obj/structure/cult_legacy/pylon)

	cast_sound = 'sound/items/welder.ogg'
	hud_state = "const_pylon"
	override_base = "cult"

/spell/aoe_turf/conjure/pylon/spell_do_after(var/mob/user as mob, delay as num, var/numticks = 5)
	if(!delay_animation)
		delay_animation = new /obj/effect/artificer_underlay(get_turf(user))
		playsound(user, 'sound/items/welder.ogg', 100, 1)
	. = ..()

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

	override_base = "cult"
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

////////////////////////////////////////////////////NEW CULT 3.0 STUFF////////////////////////////////////////////////

/spell/aoe_turf/conjure/forcewall/greater
	name = "Jugger-Wall"
	desc = "Raise a temporary line of indestructible walls to block your enemies' path and protect your allies."
	user_type = USER_TYPE_CULT

	charge_max = 250
	spell_flags = 0
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0
	summon_type = list(/obj/effect/forcefield/cult/large)
	duration = 200

	hud_state = "const_juggwall2"
	override_base = "cult"

/spell/aoe_turf/conjure/forcewall/greater/on_creation(var/obj/effect/forcefield/cult/large/AM, var/mob/user)
	playsound(user, 'sound/effects/stonedoor_openclose.ogg', 100, 1)
	user.throwing = 0
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


/obj/effect/forcefield/cult/large
	desc = "That eerie looking obstacle seems to have been pulled from another dimension through sheer force."
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

/spell/juggerdash
	name = "Jugger-Dash"
	desc = "Charge in a line and knock down anything in your way, even some walls."
	user_type = USER_TYPE_CULT
	hud_state = "const_juggdash"
	override_base = "cult"
	charge_max = 150
	spell_flags = 0
	var/dash_range = 4

/spell/juggerdash/choose_targets(var/mob/user = usr)
	return list(user)

/spell/juggerdash/cast_check(var/skipcharge = FALSE, var/mob/user = usr)
	if(user.throwing)
		return FALSE
	else
		return ..()

/spell/juggerdash/cast(var/list/targets, var/mob/user)
	playsound(user, 'sound/effects/juggerdash.ogg', 100, 1)
	var/mob/living/simple_animal/construct/armoured/perfect/jugg = user
	jugg.crashing = null
	var/landing = get_distant_turf(get_turf(user), jugg.dir, dash_range)
	jugg.throw_at(landing, dash_range , 2)

/spell/aoe_turf/conjure/hex
	name = "Conjure Hex"
	desc = "Build a lesser construct to defend an area."
	user_type = USER_TYPE_CULT

	charge_max = 600
	spell_flags = 0
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0
	cast_delay = 60
	summon_type = list(/mob/living/simple_animal/hostile/hex)

	override_base = "cult"
	hud_state = "const_hex"
	cast_sound = 'sound/items/welder.ogg'

/spell/aoe_turf/conjure/hex/choose_targets(mob/user = usr)
	return list(get_turf(user))

/spell/aoe_turf/conjure/hex/spell_do_after(var/mob/user as mob, delay as num, var/numticks = 5)
	if(!delay_animation)
		delay_animation = new /obj/effect/artificer_underlay(get_turf(user))
		playsound(user, 'sound/items/welder.ogg', 100, 1)
	. = ..()

/spell/aoe_turf/conjure/hex/before_channel(var/mob/user)
	var/mob/living/simple_animal/construct/builder/perfect/artificer = user
	if (artificer.minions.len >= 3)
		to_chat(user,"<span class='warning'>You cannot sustain more than 3 lesser constructs alive.</span>")
		return 1
	return 0

/spell/aoe_turf/conjure/hex/on_creation(var/mob/living/simple_animal/hostile/hex/AM, var/mob/user)
	AM.master = user
	AM.master.minions.Add(AM)

/spell/aoe_turf/conjure/struct
	name = "Conjure Structure"
	desc = "Raise a cult structure that you may then operate."
	user_type = USER_TYPE_CULT

	charge_max = 200
	spell_flags = 0
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0
	cast_delay = 60
	summon_type = list(/obj/structure/cult/altar)

	override_base = "cult"
	hud_state = "const_struct"
	cast_sound = 'sound/items/welder.ogg'

/spell/aoe_turf/conjure/struct/choose_targets(mob/user = usr)
	return list(get_turf(user))


/spell/aoe_turf/conjure/struct/spell_do_after(var/mob/user as mob, delay as num, var/numticks = 5)
	if(!delay_animation)
		delay_animation = new /obj/effect/artificer_underlay(get_turf(user))
		playsound(user, 'sound/items/welder.ogg', 100, 1)
	. = ..()

/spell/aoe_turf/conjure/struct/before_channel(var/mob/user)
	if (locate(/obj/structure/cult) in range(user,1))
		to_chat(user, "<span class='warning'>You cannot perform this ritual that close from another similar structure.</span>")
		return 1
	var/turf/T = user.loc
	if (!istype(T))
		return 1
	var/list/choices = list(
		list("Altar", "radial_altar", "Allows for crafting soul gems, and performing various other cult rituals."),
		list("Spire", "radial_spire", "Lets human cultists acquire Arcane Tattoos."),
		list("Forge", "radial_forge", "Enables the forging of cult blades and armor, as well as new construct shells. Raise the temperature of nearby creatures."),
	)
	var/structure = show_radial_menu(user,T,choices,'icons/obj/cult_radial3.dmi',"radial-cult")
	if (!T.Adjacent(user) || !structure )
		return 1
	switch(structure)
		if("Altar")
			summon_type = list(/obj/structure/cult/altar)
		if("Spire")
			summon_type = list(/obj/structure/cult/spire)
		if("Forge")
			summon_type = list(/obj/structure/cult/forge)
	return 0

/obj/effect/artificer_underlay
	icon = 'icons/obj/cult.dmi'
	icon_state = "build"
	mouse_opacity = 0
	density = 0
	anchored = 1
	mouse_opacity = 0

/obj/effect/artificer_underlay/cultify()
	return

/obj/effect/artificer_underlay/ex_act()
	return

/obj/effect/artificer_underlay/emp_act()
	return

/obj/effect/artificer_underlay/blob_act()
	return

/obj/effect/artificer_underlay/singularity_act()
	return