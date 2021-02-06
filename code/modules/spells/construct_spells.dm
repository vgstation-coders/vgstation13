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


/spell/wraith_warp
	name = "Wraith Warp"
	desc = "This spell lets you cut through space itself to quickly get around. You can also perform a throw to cast this spell."
	user_type = USER_TYPE_CULT
	selection_type = "range"

	charge_max = 50
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
		to_chat(user,"<span class='notice'>Click on a turf in range to warp there.</span>")
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
