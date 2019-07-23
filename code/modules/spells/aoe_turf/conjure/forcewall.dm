/spell/aoe_turf/conjure/forcewall
	name = "Forcewall"
	desc = "Create a wall of pure energy at your location."
	user_type = USER_TYPE_WIZARD
	specialization = DEFENSIVE
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

/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon = 'icons/effects/effects.dmi'
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
	return

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
