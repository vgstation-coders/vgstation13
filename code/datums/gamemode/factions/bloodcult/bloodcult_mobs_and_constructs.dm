
/////////////////Juggernaut///////////////
/mob/living/simple_animal/construct/armoured/perfect
	icon_state = "juggernaut2"
	icon_living = "juggernaut2"
	icon_dead = "juggernaut2"
	construct_spells = list(
		/spell/aoe_turf/conjure/forcewall/greater,
		/spell/juggerdash,
		)
	see_in_dark = 7
	var/dash_dir = null
	var/turf/crashing = null
	spell_on_use_inhand = /spell/juggerdash //standard jug gets forcewall, but this seems better for perfect

/mob/living/simple_animal/construct/armoured/perfect/to_bump(var/atom/obstacle)
	if(src.throwing)
		var/breakthrough = 0
		if(istype(obstacle, /obj/structure/window/))
			var/obj/structure/window/W = obstacle
			W.shatter()
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/grille/))
			var/obj/structure/grille/G = obstacle
			G.health = (0.25*initial(G.health))
			G.healthcheck()
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/table))
			var/obj/structure/table/T = obstacle
			T.destroy()
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/rack))
			new /obj/item/weapon/rack_parts(obstacle.loc)
			qdel(obstacle)
			breakthrough = 1

		else if(istype(obstacle, /turf/simulated/wall))
			var/turf/simulated/wall/W = obstacle
			if (W.hardness <= 60)
				playsound(W, 'sound/weapons/heavysmash.ogg', 75, 1)
				W.dismantle_wall(1)
				breakthrough = 1
			else
				src.throwing = 0
				src.crashing = null

		else if(istype(obstacle, /obj/structure/reagent_dispensers/fueltank))
			obstacle.ex_act(1)

		else if(istype(obstacle, /mob/living))
			var/mob/living/L = obstacle
			if (L.flags & INVULNERABLE)
				src.throwing = 0
				src.crashing = null
			else if (!(L.status_flags & CANKNOCKDOWN) || (M_HULK in L.mutations) || istype(L,/mob/living/silicon))
				//can't be knocked down? you'll still take the damage.
				src.throwing = 0
				src.crashing = null
				L.take_overall_damage(5,0)
				if(L.locked_to)
					L.locked_to.unlock_atom(L)
			else
				L.take_overall_damage(5,0)
				if(L.locked_to)
					L.locked_to.unlock_atom(L)
				L.Stun(2)
				L.Knockdown(2)
				L.apply_effect(5, STUTTER)
				playsound(src, 'sound/weapons/heavysmash.ogg', 50, 0, 0)
				breakthrough = 1
		else
			src.throwing = 0
			src.crashing = null

		if(breakthrough)
			if(crashing && !istype(crashing,/turf/space))
				spawn(1)
					src.throw_at(crashing, 50, src.throw_speed)
			else
				spawn(1)
					crashing = get_distant_turf(get_turf(src), dash_dir, 2)
					src.throw_at(crashing, 50, src.throw_speed)

	if(istype(obstacle, /obj))
		var/obj/O = obstacle
		if(!O.anchored)
			step(obstacle,src.dir)
		else
			obstacle.Bumped(src)
	else if(istype(obstacle, /mob))
		step(obstacle,src.dir)
	else
		obstacle.Bumped(src)


////////////////////Wraith/////////////////////////


/mob/living/simple_animal/construct/wraith/perfect
	icon_state = "wraith2"
	icon_living = "wraith2"
	icon_dead = "wraith2"
	see_in_dark = 7
	construct_spells = list(
		/spell/targeted/ethereal_jaunt/shift/alt,
		/spell/wraith_warp,
		/spell/aoe_turf/conjure/path_entrance,
		/spell/aoe_turf/conjure/path_exit,
		)
	var/warp_ready = FALSE

/mob/living/simple_animal/construct/wraith/perfect/toggle_throw_mode()
	var/spell/wraith_warp/WW = locate() in spell_list
	WW.perform(src)


////////////////////Artificer/////////////////////////

/mob/living/simple_animal/construct/builder/perfect
	icon_state = "artificer2"
	icon_living = "artificer2"
	icon_dead = "artificer2"
	see_in_dark = 7
	construct_spells = list(
		/spell/aoe_turf/conjure/struct,
		/spell/aoe_turf/conjure/wall,
		/spell/aoe_turf/conjure/floor,
		/spell/aoe_turf/conjure/door,
		/spell/aoe_turf/conjure/pylon,
		/spell/aoe_turf/conjure/construct/lesser/alt,
		/spell/aoe_turf/conjure/soulstone,
		/spell/aoe_turf/conjure/hex,
		)
	var/mob/living/simple_animal/construct/heal_target = null
	var/obj/effect/overlay/artificerray/ray = null
	var/heal_range = 2
	var/list/minions = list()

/mob/living/simple_animal/construct/builder/perfect/Life()
	if(timestopped)
		return 0
	. = ..()
	if(. && heal_target)
		heal_target.health = min(heal_target.maxHealth, heal_target.health + round(heal_target.maxHealth/10))
		heal_target.update_icons()
		anim(target = heal_target, a_icon = 'icons/effects/effects.dmi', flick_anim = "const_heal", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
		move_ray()
		process_construct_hud(src)

/mob/living/simple_animal/construct/builder/perfect/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	. = ..()
	if (ray)
		move_ray()

/mob/living/simple_animal/construct/builder/perfect/proc/start_ray(var/mob/living/simple_animal/construct/target)
	if (!istype(target))
		return
	if (locate(src) in target.healers)
		to_chat(src, "<span class='warning'>You are already healing \the [target].</span>")
		return
	if (ray)
		end_ray()
	target.healers.Add(src)
	heal_target = target
	ray = new (loc)
	to_chat(src, "<span class='notice'>You are now healing \the [target].</span>")
	move_ray()

/mob/living/simple_animal/construct/builder/perfect/proc/move_ray()
	if(heal_target && ray && heal_target.health < heal_target.maxHealth && get_dist(heal_target, src) <= heal_range && isturf(loc) && isturf(heal_target.loc))
		ray.forceMove(loc)
		var/disty = heal_target.y - src.y
		var/distx = heal_target.x - src.x
		var/newangle
		if(!disty)
			if(distx >= 0)
				newangle = 90
			else
				newangle = 270
		else
			newangle = arctan(distx/disty)
			if(disty < 0)
				newangle += 180
			else if(distx < 0)
				newangle += 360
		var/matrix/M = matrix()
		if (ray.oldloc_source && ray.oldloc_target && get_dist(src,ray.oldloc_source) <= 1 && get_dist(heal_target,ray.oldloc_target) <= 1)
			animate(ray, transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle),time = 1)
		else
			ray.transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle)
		ray.oldloc_source = src.loc
		ray.oldloc_target = heal_target.loc
	else
		end_ray()

/mob/living/simple_animal/construct/builder/perfect/proc/end_ray()
	if (heal_target)
		heal_target.healers.Remove(src)
		heal_target = null
	if (ray)
		qdel(ray)
		ray = null

/obj/effect/overlay/artificerray
	name = "ray"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "artificer_ray"
	layer = FLY_LAYER
	plane = LYING_MOB_PLANE
	anchored = 1
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -29
	var/turf/oldloc_source = null
	var/turf/oldloc_target = null

/obj/effect/overlay/artificerray/cultify()
	return

/obj/effect/overlay/artificerray/ex_act()
	return

/obj/effect/overlay/artificerray/emp_act()
	return

/obj/effect/overlay/artificerray/blob_act()
	return

/obj/effect/overlay/artificerray/singularity_act()
	return


/mob/living/simple_animal/hostile/hex
	name = "\improper Hex"
	desc = "A lesser construct, crafted by an Artificer."
	stop_automated_movement_when_pulled = 1
	ranged_cooldown_cap = 1
	icon = 'icons/mob/mob.dmi'
	icon_state = "hex"
	icon_living = "hex"
	icon_dead = "hex"
	speak_chance = 0
	turns_per_move = 8
	response_help = "gently taps"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0.2
	maxHealth = 50
	health = 50
	can_butcher = 0
	ranged = 1
	retreat_distance = 4
	minimum_distance = 4
	projectilesound = 'sound/effects/forge.ogg'
	projectiletype = /obj/item/projectile/bloodslash
	move_to_delay = 1
	mob_property_flags = MOB_SUPERNATURAL
	harm_intent_damage = 10
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "grips"
	attack_sound = 'sound/weapons/rapidslice.ogg'
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	speed = 5
	supernatural = 1
	faction = "cult"
	flying = 1
	environment_smash_flags = 0
	var/mob/living/simple_animal/construct/builder/perfect/master = null
	var/no_master = TRUE


/mob/living/simple_animal/hostile/hex/New()
	..()
	setupglow(rgb(255,255,255))
	animate(src, pixel_y = 4 * PIXEL_MULTIPLIER , time = 10, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 2 * PIXEL_MULTIPLIER, time = 10, loop = -1, easing = SINE_EASING)

/mob/living/simple_animal/hostile/hex/proc/setupglow(glowcolor)
	overlays = 0
	var/overlay_layer = ABOVE_LIGHTING_LAYER
	var/overlay_plane = ABOVE_LIGHTING_PLANE
	if(layer != MOB_LAYER) // ie it's hiding
		overlay_layer = FLOAT_LAYER
		overlay_plane = FLOAT_PLANE

	var/icon/glowicon = icon(icon,"glow-[icon_state]")
	glowicon.Blend(glowcolor, ICON_ADD)
	var/image/glow = image(icon = glowicon, layer = overlay_layer)
	glow.plane = relative_plane(overlay_plane)
	overlays += glow

/mob/living/simple_animal/hostile/hex/Destroy()
	if (master)
		master.minions.Remove(src)
	master = null
	..()

/mob/living/simple_animal/hostile/hex/Life()
	if(timestopped)
		return 0
	. = ..()
	if (!no_master)
		if (!master || master.gcDestroyed || master.isDead())
			adjustBruteLoss(20)//we shortly die out after our master's demise

/mob/living/simple_animal/hostile/hex/Cross(var/atom/movable/mover, var/turf/target, var/height=1.5, var/air_group = 0)
	if(istype(mover, /obj/item/projectile/bloodslash))//stop hitting yourself ffs!
		return 1
	return ..()

/mob/living/simple_animal/hostile/hex/death(var/gibbed = FALSE)
	..(TRUE) //If they qdel, they gib regardless
	for(var/i=0;i<3;i++)
		new /obj/item/weapon/ectoplasm (src.loc)
	visible_message("<span class='warning'>\The [src] collapses in a shattered heap. </span>")
	qdel (src)

/mob/living/simple_animal/hostile/hex/Found(var/atom/the_target)
	if(ismob(the_target))
		var/mob/M = the_target
		if(isanycultist(M))
			return 0
	return ..(the_target)


/mob/living/simple_animal/hostile/hex/CanAttack(var/atom/the_target)
	if(ismob(the_target))
		var/mob/M = the_target
		if(isanycultist(M))
			return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/hex/cultify()
	return


////////////////////////////////////////////////////////////////////////////////////////
var/list/astral_projections = list()

/mob/living/simple_animal/astral_projection
	name = "astral projection"
	real_name = "astral projection"
	desc = "A fragment of a cultist's soul, freed from the laws of physics."
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost-narsie"
	icon_living = "ghost-narsie"
	icon_dead = "ghost-narsie"
	maxHealth = 1
	health = 1
	melee_damage_lower = 0
	melee_damage_upper = 0
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = 1
	stop_automated_movement = TRUE
	faction = "cult"
	supernatural = TRUE
	flying = TRUE
	mob_property_flags = MOB_SUPERNATURAL
	speed = 0.5
	forced_density = 1
	density = 0
	lockflags = 0
	canmove = 0
	blinded = 0
	anchored = 1
	flags = HEAR | TIMELESS | INVULNERABLE
	universal_understand = 1
	universal_speak = 1
	plane = GHOST_PLANE
	layer = GHOST_LAYER
	invisibility = INVISIBILITY_CULTJAUNT
	see_invisible = SEE_INVISIBLE_CULTJAUNT
	incorporeal_move = INCORPOREAL_GHOST
	alpha = 127
	now_pushing = 1 //prevents pushing atoms

	//keeps track of whether we're in "ghost" form or "slightly less ghost" form
	var/tangibility = FALSE

	//the cultist's original body
	var/mob/living/anchor

	var/image/incorporeal_appearance
	var/image/tangible_appearance

	var/time_last_speech = 0//speech bubble cooldown

	//sechud stuff
	var/cardjob = "hudunknown"

	//convertibility HUD
	var/list/propension = list()

	var/projection_destroyed = FALSE
	var/direct_delete = FALSE


/mob/living/simple_animal/astral_projection/New()
	..()
	astral_projections += src

	incorporeal_appearance = image('icons/mob/mob.dmi',"blank")
	tangible_appearance = image('icons/mob/mob.dmi',"blank")
	change_sight(adding = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF)
	see_in_dark = 100
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudunknown")
	add_spell(new /spell/astral_return, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
	add_spell(new /spell/astral_toggle, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)

/mob/living/simple_animal/astral_projection/Login()
	..()
	client.CAN_MOVE_DIAGONALLY = 1

	if (!tangibility)
		overlay_fullscreen("astralborder", /obj/abstract/screen/fullscreen/astral_border)
		update_fullscreen_alpha("astralborder", 255, 5)

	//astral projections can identify cultists
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!cult)
		return
	for(var/datum/role/cultist in cult.members)
		if(cultist.antag && cultist.antag.current)
			var/imageloc = cultist.antag.current
			if(istype(cultist.antag.current.loc,/obj/mecha))
				imageloc = cultist.antag.current.loc
			var/hud_icon = cultist.logo_state
			var/image/I = image('icons/role_HUD_icons.dmi', loc = imageloc, icon_state = hud_icon)
			I.pixel_x = 20 * PIXEL_MULTIPLIER
			I.pixel_y = 20 * PIXEL_MULTIPLIER
			I.plane = ANTAG_HUD_PLANE
			client.images += I


/mob/living/simple_animal/astral_projection/proc/destroy_projection()
	if (projection_destroyed)
		return
	projection_destroyed = TRUE
	astral_projections -= src
	//the projection has ended, let's return to our body
	if (anchor && anchor.stat != DEAD && client)
		if (key)
			if (tangibility)
				var/obj/effect/afterimage/A = new (loc,anchor,10)
				A.dir = dir
				for(var/mob/M in dview(world.view, loc, INVISIBILITY_MAXIMUM))
					if (M.client)
						M.playsound_local(loc, get_sfx("disappear_sound"), 75, 0, -2)
			anchor.key = key
			to_chat(anchor, "<span class='notice'>You reconnect with your body.</span>")
			anchor.ajourn = null
	//if our body was somehow already destroyed however, we'll become a shade right here
	else if(client)
		var/turf/T = get_turf(src)
		if (T)
			var/mob/living/simple_animal/shade/shade = new (T)
			playsound(T, 'sound/hallucinations/growl1.ogg', 50, 1)
			shade.name = "[real_name] the Shade"
			shade.real_name = "[real_name]"
			mind.transfer_to(shade)
			shade.key = key
			update_faction_icons()
			to_chat(shade, "<span class='sinister'>It appears your body was unfortunately destroyed. The remains of your soul made their way to your astral projection where they merge together, forming a shade.</span>")
	invisibility = 101
	setDensity(FALSE)
	sleep(20)
	if (!direct_delete)
		qdel(src)

/mob/living/simple_animal/astral_projection/Destroy()
	if (!projection_destroyed)
		direct_delete = TRUE
		destroy_projection()
	..()

/mob/living/simple_animal/astral_projection/Life()
	. = ..()

	if (anchor)
		var/turf/T = get_turf(anchor)
		var/turf/U = get_turf(src)
		if (T.z != U.z)
			to_chat(src, "<span class='warning'>You cannot sustain the astral projection at such a distance.</span>")
			death()
			return
	else
		death()
		return

	//convertibility HUD
	if (!tangibility && client)
		client.images -= propension
		propension.len = 0

		for(var/mob/living/carbon/C in range(client.view+DATAHUD_RANGE_OVERHEAD, get_turf(src)))
			C.update_convertibility()
			propension += C.hud_list[CONVERSION_HUD]

		client.images += propension

/mob/living/simple_animal/astral_projection/death(var/gibbed = FALSE)
	spawn()
		destroy_projection(src)

/mob/living/simple_animal/astral_projection/examine(mob/user)
	if (!tangibility)
		if ((user == src) && anchor)
			to_chat(user, "<span class='notice'>You check yourself to see how others would see you were you tangible:</span>")
			anchor.examine(user)
		else if (iscultist(user))
			to_chat(user, "<span class='notice'>It's an astral projection.</span>")
		else
			to_chat(user, "<span class='sinister'>Wait something's not right here.</span>")//it's a g-g-g-g-ghost!
	else if (anchor)
		anchor.examine(user)//examining the astral projection alone won't be enough to see through it, although the user might want to make sure they cannot be identified first.

//no pulling stuff around
/mob/living/simple_animal/astral_projection/start_pulling(var/atom/movable/AM)
	return

//no dragging shit into disposals and whatnot
/mob/living/simple_animal/astral_projection/canMouseDrag()
	return FALSE

//no resting
/mob/living/simple_animal/astral_projection/rest_action()
	return

//and certainly no punching, you're barely more than a ghost
/mob/living/simple_animal/astral_projection/unarmed_attack_mob(mob/living/target)
	return

//this should prevent most other edge cases
/mob/living/simple_animal/astral_projection/incapacitated()
	return TRUE

//bullets instantly end us
/mob/living/simple_animal/astral_projection/bullet_act(var/obj/item/projectile/P)
	if (tangibility)
		death()
		return PROJECTILE_COLLISION_MISS//the bullet keeps moving past it

//so does a suicide attempt
/mob/living/simple_animal/astral_projection/attempt_suicide(forced = 0, suicide_set = 1)
	death()

/mob/living/simple_animal/astral_projection/ex_act(var/severity)
	if(tangibility)
		death()

/mob/living/simple_animal/astral_projection/shuttle_act()
	if(tangibility)
		death()

//called once when we are created, shapes our appearance in the image of our anchor
/mob/living/simple_animal/astral_projection/proc/ascend(var/mob/living/body)
	if (!body)
		return
	anchor = body
	//memorizing our anchor's appearance so we can toggle to it
	tangible_appearance = body.appearance

	//getting our ghostly looks
	overlays.len = 0
	if (ishuman(body))
		var/mob/living/carbon/human/H = body
		//instead of just adding an overlay of the body's uniform and suit, we'll first process them a bit so the leg part is mostly erased, for a ghostly look.
		overlays += crop_human_suit_and_uniform(body)
		overlays += H.obj_overlays[ID_LAYER]
		overlays += H.obj_overlays[EARS_LAYER]
		overlays += H.obj_overlays[GLASSES_LAYER]
		overlays += H.obj_overlays[GLASSES_OVER_HAIR_LAYER]
		overlays += H.obj_overlays[BELT_LAYER]
		overlays += H.obj_overlays[BACK_LAYER]
		overlays += H.obj_overlays[HEAD_LAYER]
		overlays += H.obj_overlays[HANDCUFF_LAYER]

	//giving control to the player
	key = body.key

	//name  & examine stuff
	desc = body.desc
	gender = body.gender
	if(body.mind && body.mind.name)
		name = body.mind.name
	else
		if(body.real_name)
			name = body.real_name
		else
			if(gender == MALE)
				name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
			else
				name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
	real_name = name

	//important to trick sechuds
	var/obj/item/weapon/card/id/card = body.get_id_card()
	if(card)
		cardjob = card.GetJobName()

	//memorizing our current appearance so we can toggle back to it later. Has to be done AFTER setting our new name.
	incorporeal_appearance = appearance

	//we don't transfer the mind but we keep a reference to it.
	mind = body.mind


/mob/living/simple_animal/astral_projection/proc/toggle_tangibility()
	if (tangibility)
		setDensity(FALSE)
		appearance = incorporeal_appearance
		canmove = 0
		incorporeal_move = 1
		flying = 1
		flags = HEAR | TIMELESS | INVULNERABLE
		see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
		speed = 0.5
		overlay_fullscreen("astralborder", /obj/abstract/screen/fullscreen/astral_border)
		update_fullscreen_alpha("astralborder", 255, 5)
		var/obj/effect/afterimage/A = new (loc,anchor,10)
		A.dir = dir
	else
		setDensity(TRUE)
		appearance = tangible_appearance
		canmove = 1
		incorporeal_move = 0
		stop_flying()
		flags = HEAR | PROXMOVE
		see_invisible = SEE_INVISIBLE_CULTJAUNT//still can see some hidden things
		speed = 1
		clear_fullscreen("astralborder", animate = 0)
		alpha = 0
		animate(src, alpha = 255, time = 10)
		if (client)
			client.images -= propension

	tangibility = !tangibility

//saycode
/mob/living/simple_animal/astral_projection/say(var/message, bubble_type)
	. = ..(tangibility ? "[message]" : "..[message]",tangibility ? "" : "C")
	//adding a few dots before the message when intangible so the message isn't truncated when formated for cult chat

	if(tangibility && ishuman(anchor) && config.voice_noises && world.time>time_last_speech+5 SECONDS)
		time_last_speech = world.time
		for(var/mob/O in hearers())
			if(!O.is_deaf() && O.client)
				O.client.handle_hear_voice(src)


/mob/living/simple_animal/astral_projection/get_message_mode(message)
	if(!tangibility)
		return MODE_CULTCHAT//chatting while intangible always sends messages to cult chat
	else
		return ..()

/mob/living/simple_animal/astral_projection/cult_chat_check(setting)
	if(!mind)
		return
	if(find_active_faction_by_member(iscultist(src)))//can also use cult chat while tangible when using :x
		return 1
