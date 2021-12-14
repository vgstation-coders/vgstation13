//////////////////////////////Construct Spells/////////////////////////

proc/findNullRod(var/atom/target)
	if(isholyprotection(target))
		var/turf/T = get_turf(target)
		T.turf_animation('icons/effects/96x96.dmi',"nullding",-WORLD_ICON_SIZE,-WORLD_ICON_SIZE,MOB_LAYER+1,'sound/instruments/piano/Ab7.ogg',anim_plane = EFFECTS_PLANE)
		return 1
	else if(target.contents)
		for(var/atom/A in target.contents)
			if(findNullRod(A))
				return 1
	return 0

///////////////////////////////////JUGGERNAUT///////////////////////////////////////

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

///////////////////////////////////WRAITH///////////////////////////////////////

/spell/wraith_warp
	name = "Wraith Tear"
	desc = "This spell lets you cut through space itself to quickly get around. You can also perform a throw to cast this spell."
	user_type = USER_TYPE_CULT
	selection_type = "range"

	charge_max = 75
	spell_flags = Z2NOCAST | CONSTRUCT_CHECK | WAIT_FOR_CLICK
	invocation = "none"
	invocation_type = SpI_NONE
	range = 7

	override_base = "cult"
	hud_state = "const_warp"
	cast_sound = null


/spell/wraith_warp/channel_spell(mob/user = usr, skipcharge = 0, force_remove = 0)
	if(!..())
		return 0
	return 1

/spell/wraith_warp/is_valid_target(var/target, mob/user, options)
	return (target in view_or_range(range, user, selection_type))

/spell/wraith_warp/cast(list/targets, mob/user)
	var/obj/effect/portal/tear/blood/P1 = new (get_turf(user),3 SECONDS)
	var/obj/effect/portal/tear/blood/P2 = new (get_turf(pick(targets)),3 SECONDS)
	P1.target = P2
	P2.target = P1
	P1.blend_icon(P2)
	P2.blend_icon(P1)
	P1.owner = user
	P2.owner = user
	P1.teleport(user)
