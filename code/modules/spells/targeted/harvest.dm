/spell/targeted/harvest
	name = "Harvest"
	desc = "Jaunt back to Nar-Sie's location."
	user_type = USER_TYPE_CULT

	school = "transmutation"
	charge_max = 200
	spell_flags = Z2NOCAST | CONSTRUCT_CHECK | INCLUDEUSER
	invocation = ""
	invocation_type = SpI_NONE
	range = 0
	max_targets = 0

	overlay = 1
	overlay_icon = 'icons/effects/effects.dmi'
	overlay_icon_state = "rune_teleport"
	overlay_lifespan = 0

	hud_state = "const_harvest"

/spell/targeted/harvest/cast(list/targets, mob/user)//because harvest is already a proc
	..()
	var/turf/destination = null
	for(var/obj/machinery/singularity/narsie/large/N in narsie_list)
		destination = get_turf(N)
		break
	if(destination)
		var/turf/T = get_turf(holder)
		var/atom/movable/overlay/landing_animation = anim(target = T, a_icon = 'icons/effects/effects.dmi', flick_anim = "cult_jaunt_prepare", lay = SNOW_OVERLAY_LAYER, plane = EFFECTS_PLANE)
		playsound(T, 'sound/effects/cultjaunt_prepare.ogg', 75, 0, -3)
		spawn(10)
			playsound(T, 'sound/effects/cultjaunt_land.ogg', 30, 0, -3)
			new /obj/effect/bloodcult_jaunt/visible(T,null,destination,T, activator = src)
			flick("cult_jaunt_land",landing_animation)
	else
		to_chat(user, "<span class='danger'>...something's wrong!</span>")//There shouldn't be an instance of Harvesters when Nar-Sie isn't in the world.

