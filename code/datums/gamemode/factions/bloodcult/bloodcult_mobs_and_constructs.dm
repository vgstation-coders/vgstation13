
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
		anim(target = heal_target, a_icon = 'icons/effects/effects.dmi', flick_anim = "const_heal", lay = NARSIE_GLOW, plane = LIGHTING_PLANE)
		move_ray()
		process_construct_hud(src)

/mob/living/simple_animal/construct/builder/perfect/Move(NewLoc,Dir=0,step_x=0,step_y=0,var/glide_size_override = 0)
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


/mob/living/simple_animal/hostile/hex/New()
	..()

	animate(src, pixel_y = 4 * PIXEL_MULTIPLIER , time = 10, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 2 * PIXEL_MULTIPLIER, time = 10, loop = -1, easing = SINE_EASING)

/mob/living/simple_animal/hostile/hex/proc/setupglow(glowcolor)
	overlays = 0
	var/overlay_layer = ABOVE_LIGHTING_LAYER
	var/overlay_plane = LIGHTING_PLANE
	if(layer != MOB_LAYER) // ie it's hiding
		overlay_layer = FLOAT_LAYER
		overlay_plane = FLOAT_PLANE

	var/icon/glowicon = icon(icon,"glow-[icon_state]")
	glowicon.Blend(glowcolor, ICON_ADD)
	var/image/glow = image(icon = glowicon, layer = overlay_layer)
	glow.plane = overlay_plane
	overlays += glow

/mob/living/simple_animal/hostile/hex/Destroy()
	if (master)
		master.minions.Remove(src)
	master = null
	..()

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
	see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
	incorporeal_move = INCORPOREAL_GHOST
	alpha = 127

	var/tangibility = FALSE

	var/mob/living/anchor
	var/image/incorporeal_appearance
	var/image/tangible_appearance

	//ghost stuff
	var/next_poltergeist = 0
	var/manual_poltergeist_cooldown
	var/time_last_speech = 0

/mob/living/simple_animal/astral_projection/New()
	..()
	incorporeal_appearance = image('icons/mob/mob.dmi',"blank")
	tangible_appearance = image('icons/mob/mob.dmi',"blank")
	change_sight(adding = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF)
	see_in_dark = 100


/mob/living/simple_animal/astral_projection/Login()
	..()
	client.CAN_MOVE_DIAGONALLY = 1

	//astral projections can identify cultists
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (cult)
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


/mob/living/simple_animal/astral_projection/Destroy()
	//the projection has ended, let's return to our body
	if (anchor && anchor.stat != DEAD && client)
		if (key)
			anchor.key = key
			to_chat(anchor, "<span class='notice'>You reconnect with your body.</span>")
	//if our body was somehow already destroyed however, we'll become a shade right here
	else if(client && veil_thickness > CULT_PROLOGUE)
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
	..()

/mob/living/simple_animal/astral_projection/death(var/gibbed = FALSE)
	qdel(src)

/mob/living/simple_animal/astral_projection/rest_action()
	return

/mob/living/simple_animal/astral_projection/proc/ascend(var/mob/living/body)
	if (!body)
		return

	anchor = body

	tangible_appearance = body.appearance

	overlays.len = 0

	if (ishuman(body))
		var/mob/living/carbon/human/H = body
		overlays += get_human_clothing(body)
		//overlays += image('icons/mob/mob.dmi',"ghost-narsie-suit")
		overlays += H.obj_overlays[ID_LAYER]
		overlays += H.obj_overlays[EARS_LAYER]
		overlays += H.obj_overlays[GLASSES_LAYER]
		overlays += H.obj_overlays[GLASSES_OVER_HAIR_LAYER]
		overlays += H.obj_overlays[BELT_LAYER]
		overlays += H.obj_overlays[BACK_LAYER]
		overlays += H.obj_overlays[HEAD_LAYER]
		overlays += H.obj_overlays[HANDCUFF_LAYER]

	incorporeal_appearance = appearance

	key = body.key

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

	mind = body.mind	//we don't transfer the mind but we keep a reference to it.


/mob/living/simple_animal/astral_projection/proc/toggle_tangibility()
	if (tangibility)
		density = 0
		appearance = incorporeal_appearance
		canmove = 0
		incorporeal_move = 1
		flying = 1
		flags = HEAR | TIMELESS | INVULNERABLE
		speed = 0.5
	else
		density = 1
		appearance = tangible_appearance
		canmove = 1
		incorporeal_move = 0
		flying = 0
		flags = HEAR | PROXMOVE
		speed = 1

	tangibility = !tangibility

// Check for last poltergeist activity.
/mob/living/simple_animal/astral_projection/proc/can_poltergeist(var/start_cooldown=1)
	if(isAdminGhost(src))
		return TRUE
	if(world.time >= next_poltergeist)
		if(start_cooldown)
			start_poltergeist_cooldown()
		return TRUE
	return FALSE

/mob/living/simple_animal/astral_projection/proc/start_poltergeist_cooldown()
	if(isnull(manual_poltergeist_cooldown))
		next_poltergeist=world.time + global_poltergeist_cooldown
	else
		next_poltergeist=world.time + manual_poltergeist_cooldown

/mob/living/simple_animal/astral_projection/proc/reset_poltergeist_cooldown()
	next_poltergeist=0


//saycode
/mob/living/simple_animal/astral_projection/say(var/message)
	. = ..(message, "[tangibility ? "" : "C"]")

	if(tangibility && ishuman(anchor) && config.voice_noises && world.time>time_last_speech+5 SECONDS)
		time_last_speech = world.time
		for(var/mob/O in hearers())
			if(!O.is_deaf() && O.client)
				O.client.handle_hear_voice(src)

/mob/living/simple_animal/astral_projection/cult_chat_check(setting)
	if(!mind)
		return
	if(find_active_faction_by_member(iscultist(src)))
		return 1
	if(find_active_faction_by_member(mind.GetRole(LEGACY_CULTIST)))
		return 1

#define SPEAK_OVER_GENERAL_CULT_CHAT 0
#define SPEAK_OVER_CHANNEL_INTO_CULT_CHAT 1
#define HEAR_CULT_CHAT 2

/mob/living/simple_animal/construct/handle_inherent_channels(var/datum/speech/speech, var/message_mode)
	if(..())
		return 1
	if(message_mode == MODE_HEADSET && cult_chat_check(SPEAK_OVER_GENERAL_CULT_CHAT))
		var/turf/T = get_turf(src)
		log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Cult channel: [html_encode(speech.message)]")
		for(var/mob/M in mob_list)
			if(M.cult_chat_check(HEAR_CULT_CHAT) || ((M in dead_mob_list) && !istype(M, /mob/new_player)))
				to_chat(M, "<span class='sinister'><b>[src.name]:</b> [html_encode(speech.message)]</span>")
		return 1

#undef SPEAK_OVER_GENERAL_CULT_CHAT
#undef SPEAK_OVER_CHANNEL_INTO_CULT_CHAT
#undef HEAR_CULT_CHAT




//returns an image featuring the mob's uniform and suit with its legs faded out
/mob/living/simple_animal/astral_projection/proc/get_human_clothing(var/mob/living/carbon/human/body)
	if (!body)
		return

	var/image/human_clothes = image('icons/mob/mob.dmi',"blank")

	//couldn't just re-use the code from human/update_icons.dm because we need to manipulate an /icon, not an /image
	//it's not perfect and won't get the accessories or blood stains but that's good enough for the effect we're trying to get here
	if(body.w_uniform)
		var/uniform_icon = 'icons/mob/uniform.dmi'
		var/uniform_icon_state = "grey_s"

		if(body.w_uniform._color)
			uniform_icon_state = "[body.w_uniform._color]_s"

		if(((M_FAT in body.mutations) && (body.species.anatomy_flags & CAN_BE_FAT)) || body.species.anatomy_flags & IS_BULKY)
			if(body.w_uniform.clothing_flags&ONESIZEFITSALL)
				uniform_icon = 'icons/mob/uniform_fat.dmi'

		if(body.w_uniform.wear_override)
			uniform_icon = body.w_uniform.wear_override

		var/obj/item/clothing/under/under_uniform = body.w_uniform
		if(body.species.name in under_uniform.species_fit) //Allows clothes to display differently for multiple species
			if(body.species.uniform_icons && has_icon(body.species.uniform_icons, "[body.w_uniform.icon_state]_s"))
				uniform_icon = body.species.uniform_icons

		if((body.gender == FEMALE) && (body.w_uniform.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(uniform_icon, "[body.w_uniform.icon_state]_s_f"))
				uniform_icon_state = "[body.w_uniform.icon_state]_s_f"

		if(body.w_uniform.icon_override)
			uniform_icon	= body.w_uniform.icon_override

		var/icon/I_uniform = icon(uniform_icon,uniform_icon_state)
		var/icon/mask = icon('icons/mob/mob.dmi',"ajourney_mask")

		mask.Blend(I_uniform, ICON_MULTIPLY)

		human_clothes.overlays += image(mask)

	if(body.wear_suit)
		var/suit_icon = body.wear_suit.icon_override ? body.wear_suit.icon_override : 'icons/mob/suit.dmi'
		var/suit_icon_state = body.wear_suit.icon_state

		var/datum/species/SP = body.species

		if((((M_FAT in body.mutations) && (SP.anatomy_flags & CAN_BE_FAT)) || (SP.anatomy_flags & IS_BULKY)) && !(body.wear_suit.icon_override))
			if(body.wear_suit.clothing_flags&ONESIZEFITSALL)
				suit_icon	= 'icons/mob/suit_fat.dmi'
				if(SP.name in body.wear_suit.species_fit) //Allows clothes to display differently for multiple species
					if(SP.fat_wear_suit_icons && has_icon(SP.fat_wear_suit_icons, body.wear_suit.icon_state))
						suit_icon = SP.wear_suit_icons
				if((body.gender == FEMALE) && (body.wear_suit.clothing_flags & GENDERFIT)) //genderfit
					if(has_icon(suit_icon,"[body.wear_suit.icon_state]_f"))
						suit_icon_state = "[body.wear_suit.icon_state]_f"
		else
			if(SP.name in body.wear_suit.species_fit) //Allows clothes to display differently for multiple species
				if(SP.wear_suit_icons && has_icon(SP.wear_suit_icons, body.wear_suit.icon_state))
					suit_icon = SP.wear_suit_icons
			if((gender == FEMALE) && (body.wear_suit.clothing_flags & GENDERFIT)) //genderfit
				if(has_icon(suit_icon,"[body.wear_suit.icon_state]_f"))
					suit_icon_state = "[body.wear_suit.icon_state]_f"

		var/icon/I_suit = icon(suit_icon,suit_icon_state)
		var/icon/mask = icon('icons/mob/mob.dmi',"ajourney_mask")

		mask.Blend(I_suit, ICON_MULTIPLY)

		human_clothes.overlays += image(mask)

	return human_clothes
