/spell/aoe_turf/conjure/forcewall
	name = "Forcewall"
	desc = "Create a wall of pure energy at your location."
	user_type = USER_TYPE_WIZARD
	specialization = SSDEFENSIVE
	abbreviation = "FW"
	summon_type = list(/obj/effect/forcefield/wizard)
	duration = 300
	charge_max = 10 SECONDS
	cooldown_min = 2 SECONDS
	spell_flags = 0
	invocation = "TARCOL MINTI ZHERI"
	range = 0
	cast_sound = null

	hud_state = "wiz_shield"

	price = 0.5 * Sp_BASE_PRICE //Half of the normal spell price

/spell/aoe_turf/conjure/forcewall/mime
	name = "Invisible wall"
	desc = "Create an invisible wall on your location."
	school = "mime"
	user_type = USER_TYPE_OTHER
	panel = "Mime"
	summon_type = list(/obj/effect/forcefield/mime)
	invocation_type = SpI_EMOTE
	invocation = "mimes placing their hands on a flat surface, and pushing against it."
	charge_max = 300
	cast_sound = null

	override_base = "grey"
	hud_state = "mime_wall"

/*
Unwall spell, sadly has to be targeted to be any fun to use
-kanef
*/
/spell/targeted/mime_unwall
	name = "Invisible un-wall"
	desc = "Create an invisible un-wall on a targeted location, an anomaly allowing the passage of all objects through anything on it."
	school = "mime"
	abbreviation = "FW"
	user_type = USER_TYPE_OTHER
	panel = "Mime"
	specialization = SSOFFENSIVE

	school = "mime"
	charge_max = 300
	cast_sound = null
	cooldown_min = 2 SECONDS
	spell_flags = WAIT_FOR_CLICK
	range = 1
	max_targets = 1
	invocation_type = SpI_EMOTE
	invocation = "mimes placing their hands on a flat surface, and pushing against it."

	override_base = "grey"
	hud_state = "mime_wall"

/spell/targeted/mime_unwall/cast(var/list/targets, mob/user)
	..()
	for(var/atom/target in targets)
		if(isturf(target))
			new /obj/effect/unwall_field(target)
		else
			new /obj/effect/unwall_field(target.loc)

/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon_state = "m_shield"
	anchored = 1.0
	opacity = 0
	density = 1
	invisibility = 100

	var/explosion_block = 20 //making this spell marginally more useful

/obj/effect/forcefield/bullet_act(var/obj/item/projectile/Proj, var/def_zone)
	var/turf/T = get_turf(src.loc)
	if(T)
		for(var/mob/M in T)
			Proj.on_hit(M,M.bullet_act(Proj, def_zone))
	return ..()

/obj/effect/forcefield/wizard
	invisibility = 0

/obj/effect/forcefield/mime
	icon_state = "fuel"
	name = "invisible wall"
	desc = "You have a bad feeling about this."
	invisibility = 0

/obj/effect/forcefield/mime/Cross(atom/movable/mover, turf/target, height = 0)
	if(istype(mover, /obj/item/projectile/bullet/invisible))
		return 1
	..()

/obj/effect/forcefield/cultify()
	new /obj/effect/forcefield/cult(get_turf(src))
	qdel(src)
	return

/*
Unwall fields
-kanef
*/
/obj/effect/unwall_field
	icon_state = "fuel"
	name = "invisible un-wall"
	desc = "You have a REALLY bad feeling about this."
	anchored = 1.0
	opacity = 0
	density = TRUE
	flow_flags = ON_BORDER
	mouse_opacity = 1
	var/duration = 300 // How long the wall lasts, in ticks
	var/static/list/forbidden_passes = list(/turf/unsimulated/wall,/turf/simulated/wall/invulnerable,/obj/structure/grille/invulnerable) // To stop people breaking maps like centcomm or lamprey stuff

/obj/effect/unwall_field/permanent // For future mapping or bus shenanigans
	duration = 0 // Forever

/obj/effect/unwall_field/New()
	..()
	if(duration) // Wait the duration if any and delete it, if zero, don't
		spawn(duration)
			qdel(src)

/obj/effect/unwall_field/Bumped(atom/movable/A)
	if(is_type_in_list(src.loc,forbidden_passes))
		return
	for(var/atom/B in src.loc) // Go through everything, discount passing through forbidden stuff
		if(is_type_in_list(B,forbidden_passes))
			return
	A.forceMove(src.loc)