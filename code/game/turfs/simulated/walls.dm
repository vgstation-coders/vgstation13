/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'icons/turf/walls.dmi'
	var/mineral = "metal"
	var/rotting = 0
	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/walltype = "metal"
	var/hardness = 60 //Higher numbers are harder (so that it actually makes sense). Walls are 60 hardness, reinforced walls are 90 hardness. No hardness over 100, PLEASE
	var/engraving
	var/engraving_quality //engraving on the wall
	var/del_suppress_resmoothing = 0 // Do not resmooth neighbors on Destroy. (smoothwall.dm)

	var/dismantle_type = /turf/simulated/floor/plating
	var/girder_type = /obj/structure/girder

	soot_type = null

	explosion_block = 1

	holomap_draw_override = HOLOMAP_DRAW_FULL
	var/mob/living/peeper = null

/turf/simulated/wall/initialize()
	..()
	var/turf/simulated/open/OS = GetAbove(src)
	if(istype(OS))
		OS.ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/wall/canSmoothWith()
	var/static/list/smoothables = list(
		/turf/simulated/wall,
		/obj/structure/falsewall,
		/obj/structure/falserwall,
	)
	return smoothables

/turf/simulated/wall/cannotSmoothWith()
	var/static/list/unsmoothables = list(
		/turf/simulated/wall/shuttle
	)
	return unsmoothables

/turf/simulated/wall/examine(mob/user)
	..()
	if(rotting)
		to_chat(user, "It is covered in wallrot and looks weakened")
	if(thermite)
		to_chat(user, "<span class='danger'>It's doused in thermite!</span>")
	if(src.engraving)
		to_chat(user, src.engraving)

/turf/simulated/wall/dismantle_wall(devastated = 0, explode = 0)
	if(mineral == "metal")
		new /obj/item/stack/sheet/metal(src, 2)
	else if(mineral == "wood")
		new /obj/item/stack/sheet/wood(src, 2)
	else
		var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
		if(M)
			new M(src, 2)

	if(devastated)
		new /obj/item/stack/sheet/metal(src)
	else
		if(girder_type)
			new girder_type(src)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/effect/cult_shortcut))
			qdel(O)
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)

	reset_view()
	ChangeTurf(dismantle_type)
	update_near_walls()

/turf/simulated/wall/ex_act(severity)
	if(rotting)
		severity = 1.0
	switch(severity)
		if(1.0)
			src.ChangeTurf(get_underlying_turf()) //You get NOTHING, you LOSE
			return
		if(2.0)
			if(prob(50))
				dismantle_wall(0,1)
			else
				dismantle_wall(1,1)
			return
		if(3.0)
			if(prob(40))
				dismantle_wall(0,1)
			return
	return

/turf/simulated/wall/mech_drill_act(severity)
	return dismantle_wall()

/turf/simulated/wall/blob_act(var/destroy = 0)
	..()
	if(prob(50) || rotting || destroy)
		dismantle_wall()

/turf/simulated/wall/attack_animal(var/mob/living/simple_animal/M)
	M.delayNextAttack(8)
	if(M.environment_smash_flags & SMASH_WALLS)
		if(istype(src, /turf/simulated/wall/r_wall))
			if(M.environment_smash_flags & SMASH_RWALLS)
				playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
				dismantle_wall(1)
				M.visible_message("<span class='danger'>[M] smashes through \the [src].</span>", \
				"<span class='attack'>You smash through \the [src].</span>")
			else
				to_chat(M, "<span class='info'>\The [src] is far too strong for you to destroy.</span>")
		else
			playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
			dismantle_wall(1)
			M.visible_message("<span class='danger'>[M] smashes through \the [src].</span>", \
			"<span class='attack'>You smash through \the [src].</span>")
			return

/turf/simulated/wall/attack_paw(mob/user as mob)

	return src.attack_hand(user)

/turf/simulated/wall/attack_hand(mob/living/user as mob)
	user.delayNextAttack(8)
	if(M_HULK in user.mutations)
		user.do_attack_animation(src, user)
		playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
		if(prob(100 - hardness) || rotting)
			dismantle_wall(1)
			user.visible_message("<span class='danger'>[user] smashes through \the [src].</span>", \
			"<span class='notice'>You smash through \the [src].</span>")
			usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			return
		else
			user.visible_message("<span class='warning'>[user] punches \the [src].</span>", \
			"<span class='notice'>You punch \the [src].</span>")
			return

	if(rotting)
		return src.attack_rotting(user) //Stop there, we aren't slamming our hands on a dirty rotten wall

	if (iscultist(user) && !(locate(/obj/effect/cult_shortcut) in src))
		var/datum/cult_tattoo/CT = user.checkTattoo(TATTOO_SHORTCUT)
		if (CT)
			var/mob/living/carbon/C = user
			if (C.occult_muted())
				to_chat(user, "<span class='warning'>The holy aura preying upon your body prevents you from correctly drawing the sigil.</span>")
				return
			var/data = use_available_blood(user, CT.blood_cost)
			if (data[BLOODCOST_RESULT] != BLOODCOST_FAILURE)
				if(do_after(user, src, 30))
					new /obj/effect/cult_shortcut(src)
					user.visible_message("<span class='warning'>[user] has painted a strange sigil on \the [src].</span>", \
						"<span class='notice'>You finish drawing the sigil.</span>")
			return

	if(bullet_marks)
		peeper = user
		peeper.client.perspective = EYE_PERSPECTIVE
		peeper.client.eye = src
		peeper.visible_message("<span class='notice'>[peeper] leans in and looks through \the [src].</span>", \
		"<span class='notice'>You lean in and look through \the [src].</span>")
		src.add_fingerprint(peeper)
		return ..()

	user.visible_message("<span class='notice'>[user] pushes \the [src].</span>", \
	"<span class='notice'>You push \the [src] but nothing happens!</span>")
	playsound(src, 'sound/weapons/Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	return ..()

/turf/simulated/wall/proc/reset_view()
	if(!peeper)
		return
	peeper.client.eye = peeper.client.mob
	peeper.client.perspective = MOB_PERSPECTIVE

/turf/simulated/wall/proc/attack_rotting(mob/user as mob)
	if(istype(src, /turf/simulated/wall/r_wall)) //I wish I didn't have to do typechecks
		to_chat(user, "<span class='notice'>This [src] feels rather unstable.</span>")
		return
	else
		//Should be a normal wall or a mineral wall, SHOULD
		user.visible_message("<span class='warning'>\The [src] crumbles under [user]'s touch.</span>", \
		"<span class='notice'>\The [src] crumbles under your touch.</span>")
		dismantle_wall()
		return

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(W.attack_delay)
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(istype(W,/obj/item/tool/solder) && bullet_marks)
		var/obj/item/tool/solder/S = W
		if(!S.remove_fuel(bullet_marks*2,user))
			return
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You remove the hole[bullet_marks > 1 ? "s" : ""] with \the [W].</span>")
		bullet_marks = 0
		icon = initial(icon)
		reset_view()
		return

	//Get the user's location
	if(!istype(user.loc, /turf) && !istype(user.loc, /obj/mecha))
		return	//Can't do this stuff whilst inside objects and such

	if(rotting)
		if(W.is_hot())
			user.visible_message("<span class='notice'>[user] burns the fungi away with \the [W].</span>", \
			"<span class='notice'>You burn the fungi away with \the [W].</span>")
			remove_rot()
			return
		if(istype(W,/obj/item/weapon/soap))
			user.visible_message("<span class='notice'>[user] forcefully scrubs the fungi away with \the [W].</span>", \
			"<span class='notice'>You forcefully scrub the fungi away with \the [W].</span>")
			remove_rot()
			return
		else if(!W.is_sharp() && W.force >= 10 || W.force >= 20)
			user.visible_message("<span class='warning'>With one strong swing, [user] destroys the rotting [src] with \the [W].</span>", \
			"<span class='notice'>With one strong swing, the rotting [src] crumbles away under \the [W].</span>")
			src.dismantle_wall(1)

			var/pdiff = performWallPressureCheck(src)
			if(pdiff)
				investigation_log(I_ATMOS, "with a pdiff of [pdiff] broken after rotting by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
				message_admins("\The [src] with a pdiff of [pdiff] has been broken after rotting by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite && can_thermite)
		if(W.is_hot()) //HEY CAN THIS SET THE THERMITE ON FIRE ?
			user.visible_message("<span class='warning'>[user] applies \the [W] to the thermite coating \the [src] and waits</span>", \
			"<span class='warning'>You apply \the [W] to the thermite coating \the [src] and wait</span>")
			if(do_after(user, src, 100) && W.is_hot()) //Thermite is hard to light up
				thermitemelt(user) //There, I just saved you fifty lines of redundant typechecks and awful snowflake coding
				user.visible_message("<span class='warning'>[user] sets \the [src] ablaze with \the [W]</span>", \
				"<span class='warning'>You set \the [src] ablaze with \the [W]</span>")
				return

	//Deconstruction
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(engraving)
			if(WT.remove_fuel(1, user))
				to_chat(user, "<span class='notice'>You deform the wall back into its original shape")
				engraving = null
				engraving_quality = null
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				overlays.Cut()
				return
		if(WT.isOn() && WT.get_fuel() >= 1)
			user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s outer plating.</span>", \
			"<span class='notice'>You begin slicing through \the [src]'s outer plating.</span>", \
			"<span class='warning'>You hear welding noises.</span>")
			playsound(src, 'sound/items/Welder.ogg', 100, 1)

			if(WT.do_weld(user, src, 100, 1))
				if(!istype(src))
					return
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				user.visible_message("<span class='warning'>[user] slices through \the [src]'s outer plating.</span>", \
				"<span class='notice'>You slice through \the [src]'s outer plating.</span>", \
				"<span class='warning'>You hear welding noises.</span>")
				var/pdiff = performWallPressureCheck(src)
				if(pdiff)
					investigation_log(I_ATMOS, "with a pdiff of [pdiff] dismantled by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
					message_admins("\The [src] with a pdiff of [pdiff] has been dismantled by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
				dismantle_wall()
		else
			return

	// Drilling peepholes
	if(istype(W,/obj/item/tool/surgicaldrill))
		user.visible_message("<span class='warning'>[user] begins drilling a hole into \the [src].</span>", \
		"<span class='notice'>You begin drilling a hole into \the [src].</span>", \
		"<span class='warning'>You hear drilling noises.</span>")
		//playsound(src, 'sound/items/Welder.ogg', 100, 1)

		if(do_after(user, src, 100*W.toolspeed))
			if(!istype(src))
				return
			//playsound(src, 'sound/items/Welder.ogg', 100, 1)
			user.visible_message("<span class='warning'>[user] drills a hole into \the [src].</span>", \
			"<span class='notice'>You drill a hole into \the [src] to peep through.</span>", \
			"<span class='warning'>You hear drilling noises.</span>")
			add_bullet_mark("peephole",round(Get_Angle(user,src)))

    //CUT_WALL will dismantle the wall
	else if((W.sharpness_flags & (CUT_WALL)) && user.a_intent == I_HURT)
		user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s outer plating.</span>", \
		"<span class='notice'>You begin slicing through \the [src]'s outer plating.</span>", \
		"<span class='warning'>You hear slicing noises.</span>")
		playsound(src, 'sound/items/Welder2.ogg', 100, 1)

		if(do_after(user, src, 100))
			if(!istype(src))
				return
			playsound(src, 'sound/items/Welder2.ogg', 100, 1)
			user.visible_message("<span class='warning'>[user] slices through \the [src]'s outer plating.</span>", \
			"<span class='notice'>You slice through \the [src]'s outer plating.</span>", \
			"<span class='warning'>You hear welding noises.</span>")
			var/pdiff = performWallPressureCheck(src)
			if(pdiff)
				investigation_log(I_ATMOS, "with a pdiff of [pdiff] dismantled by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
				message_admins("\The [src] with a pdiff of [pdiff] has been dismantled by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
			dismantle_wall()

	else if(istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/PK = W
		if(!(PK.diggables & DIG_WALLS))
			return
		if(mineral == "diamond")
			return

		user.visible_message("<span class='warning'>[user] begins [PK.drill_verb] straight into \the [src].</span>", \
		"<span class='notice'>You begin [PK.drill_verb] straight into \the [src].</span>")
		PK.playtoolsound(src, 100)
		if(do_after(user, src, (MINE_DURATION * PK.toolspeed) * 10))
			user.visible_message("<span class='notice'>[user]'s [PK] tears though the last of \the [src], leaving nothing but a girder.</span>", \
			"<span class='notice'>Your [PK] tears though the last of \the [src], leaving nothing but a girder.</span>")
			dismantle_wall()

			var/pdiff = performWallPressureCheck(src)
			if(pdiff)
				investigation_log(I_ATMOS, "with a pdiff of [pdiff] drilled through by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
				message_admins("\The [src] with a pdiff of [pdiff] has been drilled through by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
		return

	else if(istype(W, /obj/item/mounted)) //If we place it, we don't want to have a silly message
		return

	else if(istype(W, /obj/item/tool/crowbar/red))
		playsound(src, "crowbar_hit", 50, 1, -1)
	else
		return attack_hand(user)
	return

//Wall-rot effect, a nasty fungus that destroys walls.
//Side effect : Also rots the code of any .dm it's referenced in, until now
/turf/simulated/wall/proc/rot()
	if(rotting) //The fuck are you doing ?
		return
	else
		rotting = 1
		var/number_rots = rand(2,3)
		for(var/i=0, i < number_rots, i++)
			new /obj/effect/overlay/wallrot(src)

/turf/simulated/wall/remove_rot()
	for(var/obj/effect/overlay/wallrot/overlay in src)
		qdel(overlay)
	rotting = 0

/turf/simulated/wall/proc/thermitemelt(var/mob/user)
	if(mineral == "diamond")
		return
	var/obj/effect/overlay/O = new/obj/effect/overlay(src)
	O.name = "thermite"
	O.desc = "Nothing is going to stop it from burning now."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.setDensity(TRUE)
	O.plane = ABOVE_HUMAN_PLANE

	var/cultwall = 0
	if(istype(src, /turf/simulated/wall/cult))
		cultwall = 1

	if(cultwall)
		src.ChangeTurf(/turf/simulated/floor/engine/cult)
	else
		src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	if(!F)
		if(O)
			visible_message("<span class='danger'>The thermite melts right through \the [src] and the underlying plating, leaving a gaping hole into deep space.</span>") //Good job you big damn hero
			qdel(O)
		return
	F.burn_tile()
	F.icon_state = "[cultwall ? "cultwall_thermite" : "wall_thermite"]"

	var/pdiff = performWallPressureCheck(src)
	if(pdiff)
		investigation_log(I_ATMOS, "with a pdiff of [pdiff] has been thermited through by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
		message_admins("\The [src] with a pdiff of [pdiff] has been thermited by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")

	hotspot_expose(3000, 125, surfaces = 1) //Only works once when the thermite is created, but else it would need to not be an effect to work
	spawn(100)
		if(O)
			visible_message("<span class='danger'>\The [O] melts right through \the [src].</span>")
			qdel(O)
	return

//Generic wall melting proc.
/turf/simulated/wall/melt()
	if(mineral == "diamond")
		return

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	if(!F)
		return
	F.burn_tile()
	F.icon_state = "wall_thermite"
	visible_message("<span class='danger'>\The [src] spontaenously combusts!.</span>") //!!OH SHIT!!
	return

/turf/simulated/wall/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	remove_rot()
	for(var/obj/effect/E in src)
		if(E.name == "sigil")
			qdel(E)
	..()

/turf/simulated/wall/cultify()
	ChangeTurf(/turf/simulated/wall/cult)
	turf_animation('icons/effects/effects.dmi',"cultwall", 0, 0, MOB_LAYER-1, anim_plane = TURF_PLANE)
	return

/turf/simulated/wall/attack_construct(mob/user as mob)
	if(istype(user,/mob/living/simple_animal/construct/builder))
		var/spell/aoe_turf/conjure/wall/S = locate() in user.spell_list
		S.perform(user, 0, list(src))
		//var/obj/abstract/screen/spell/SS = S.connected_button
		//SS.update_charge(1)
		return 1
	return 0

/turf/simulated/wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(75))
			dismantle_wall()
		return
	if(current_size == STAGE_FOUR)
		if(prob(30))
			dismantle_wall()

/turf/simulated/wall/kick_act(mob/living/carbon/human/H)
	if(H.locked_to && isobj(H.locked_to) && H.locked_to != src)
		var/obj/O = H.locked_to
		if(O.onBuckledUserKick(H, src))
			return //don't return 1! we will do the normal "touch" action if so!

	H.visible_message("<span class='danger'>[H] kicks \the [src]!</span>", "<span class='danger'>You kick \the [src]!</span>")

	if(prob(70))
		if(H.foot_impact(src,rand(5,7)))
			to_chat(H, "<span class='userdanger'>Ouch! That hurts!</span>")

/turf/simulated/wall/dissolvable()
	if(flags & INVULNERABLE)
		return FALSE
	else
		return PACID

/turf/simulated/wall/clockworkify()
	ChangeTurf(/turf/simulated/wall/mineral/clockwork)
	turf_animation('icons/effects/effects.dmi',CLOCKWORK_GENERIC_GLOW, 0, 0, MOB_LAYER-1, anim_plane = TURF_PLANE)
