///////////////////////////////////
////////  Mecha wreckage   ////////
///////////////////////////////////


/obj/effect/decal/mecha_wreckage
	name = "Exosuit wreckage"
	desc = "Remains of some unfortunate mecha. Completely unrepairable."
	icon = 'icons/mecha/mecha.dmi'
	density = 1
	anchored = 0
	opacity = 0
	var/list/welder_salvage = list(/obj/item/stack/sheet/plasteel,/obj/item/stack/sheet/metal,/obj/item/stack/rods)
	var/list/wirecutters_salvage = list(/obj/item/stack/cable_coil)
	var/list/crowbar_salvage

/obj/effect/decal/mecha_wreckage/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group)
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	return ..()

/obj/effect/decal/mecha_wreckage/New()
	..()
	crowbar_salvage = new
	return

/obj/effect/decal/mecha_wreckage/ex_act(severity)
	if(severity < 2)
		spawn // Why.
			qdel(src)
	return

/obj/effect/decal/mecha_wreckage/proc/add_salvagable(var/obj/O, const/salvage_prob=30)
	// Mecha equipment is ~special~
	if(istype(O, /obj/item/mecha_parts/mecha_equipment))
		add_salvagable_equipment(O)
		return

	if(prob(salvage_prob))
		crowbar_salvage += O
		O.forceMove(src)
	else
		qdel(O)

/obj/effect/decal/mecha_wreckage/proc/add_salvagable_equipment(var/obj/item/mecha_parts/mecha_equipment/E, const/salvage_prob=30)
	if(E.salvageable && prob(salvage_prob))
		crowbar_salvage += E
		E.forceMove(src)
		E.equip_ready = 1
		E.reliability = round(rand(E.reliability/3,E.reliability))
	else
		E.forceMove(get_turf(src))
		qdel(E)

/obj/effect/decal/mecha_wreckage/bullet_act(var/obj/item/projectile/Proj)
	return

/obj/effect/decal/mecha_wreckage/examine(var/mob/user)
	..()
	if(!isemptylist(welder_salvage))
		to_chat(user, "<span class='info'>Looks like you might be able to cut something out, if you have a welder.</span>")
	if(!isemptylist(wirecutters_salvage))
		to_chat(user, "<span class='info'>There are some salvagable wires that you can reach with wirecutters.</span>")
	if(!isemptylist(crowbar_salvage))
		to_chat(user, "<span class='info'>You might be able to pry something out.</span>")

/obj/effect/decal/mecha_wreckage/proc/die()
	qdel(src)

/obj/effect/decal/mecha_wreckage/proc/check_salvage(var/mob/user)
	if(isemptylist(welder_salvage) && isemptylist(wirecutters_salvage) && isemptylist(crowbar_salvage))
		die()
		to_chat(user, "<span class='info'>You finished salvaging \the [src]!</span>")

/obj/effect/decal/mecha_wreckage/proc/pick_random_loot(var/list/possible, const/max_loot=2, const/loot_prob=40)
	var/list/provided = list()
	for(var/i = 1 to max_loot)
		if(!isemptylist(possible) && prob(loot_prob))
			provided += pick_n_take(possible)
	return provided

/obj/effect/decal/mecha_wreckage/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(isemptylist(welder_salvage))
			to_chat(user, "You don't see anything that can be cut with [W].")
			return
		if (WT.remove_fuel(1,user))
			var/type = prob(70)?pick(welder_salvage):null
			if(type)
				var/N = new type(get_turf(user))
				user.visible_message("[user] cuts [N] from [src]", "You cut [N] from [src]", "You hear a sound of welder nearby")
				welder_salvage -= type
				check_salvage(user)
			else
				to_chat(user, "You failed to salvage anything valuable from [src].")
		else
			return
	if(iswirecutter(W))
		if(isemptylist(wirecutters_salvage))
			to_chat(user, "You don't see anything that can be cut with [W].")
			return
		var/type = prob(70)?pick(wirecutters_salvage):null
		if(type)
			var/N = new type(get_turf(user))
			user.visible_message("[user] cuts [N] from [src].", "You cut [N] from [src].")
			wirecutters_salvage -= type
			check_salvage(user)
		else
			to_chat(user, "You failed to salvage anything valuable from [src].")
	if(iscrowbar(W))
		if(!isemptylist(crowbar_salvage))
			var/obj/S = pick(crowbar_salvage)
			if(S)
				S.forceMove(get_turf(user))
				crowbar_salvage -= S
				user.visible_message("[user] pries [S] from [src].", "You pry [S] from [src].")
				check_salvage(user)
			else
				to_chat(user, "You failed to salvage anything valuable from [src].")
		else
			to_chat(user, "You don't see anything that can be pried with [W].")
	else
		..()
	return


/obj/effect/decal/mecha_wreckage/gygax
	name = "Gygax wreckage"
	icon_state = "gygax-broken"

/obj/effect/decal/mecha_wreckage/gygax/New()
	..()
	var/list/parts = list(/obj/item/mecha_parts/part/gygax_torso,
								/obj/item/mecha_parts/part/gygax_head,
								/obj/item/mecha_parts/part/gygax_left_arm,
								/obj/item/mecha_parts/part/gygax_right_arm,
								/obj/item/mecha_parts/part/gygax_left_leg,
								/obj/item/mecha_parts/part/gygax_right_leg)
	welder_salvage += pick_random_loot(parts)

/obj/effect/decal/mecha_wreckage/gygax/dark
	name = "Dark Gygax wreckage"
	icon_state = "darkgygax-broken"

/obj/effect/decal/mecha_wreckage/marauder
	name = "Marauder wreckage"
	icon_state = "marauder-broken"

/obj/effect/decal/mecha_wreckage/marauder/New()
	..()
	var/list/parts = list(
		/obj/item/mecha_parts/part/marauder_torso,
		/obj/item/mecha_parts/part/marauder_head,
		/obj/item/mecha_parts/part/marauder_left_arm,
		/obj/item/mecha_parts/part/marauder_right_arm,
		/obj/item/mecha_parts/part/marauder_left_leg,
		/obj/item/mecha_parts/part/marauder_right_leg,
		)

	welder_salvage += pick_random_loot(parts)

/obj/effect/decal/mecha_wreckage/mauler
	name = "Mauler Wreckage"
	icon_state = "mauler-broken"
	desc = "The syndicate won't be very happy about this..."

/obj/effect/decal/mecha_wreckage/seraph
	name = "Seraph wreckage"
	icon_state = "seraph-broken"

/obj/effect/decal/mecha_wreckage/ripley
	name = "Ripley wreckage"
	icon_state = "ripley-broken"

/obj/effect/decal/mecha_wreckage/ripley/New()
	..()
	var/list/parts = list(/obj/item/mecha_parts/part/ripley_torso,
								/obj/item/mecha_parts/part/ripley_left_arm,
								/obj/item/mecha_parts/part/ripley_right_arm,
								/obj/item/mecha_parts/part/ripley_left_leg,
								/obj/item/mecha_parts/part/ripley_right_leg)
	welder_salvage += pick_random_loot(parts)

/obj/effect/decal/mecha_wreckage/ripley/firefighter
	name = "Firefighter wreckage"
	icon_state = "firefighter-broken"

/obj/effect/decal/mecha_wreckage/ripley/firefighter/New()
	..()
	var/list/parts = list(/obj/item/mecha_parts/part/ripley_torso,
								/obj/item/mecha_parts/part/ripley_left_arm,
								/obj/item/mecha_parts/part/ripley_right_arm,
								/obj/item/mecha_parts/part/ripley_left_leg,
								/obj/item/mecha_parts/part/ripley_right_leg,
								/obj/item/clothing/suit/fire)
	welder_salvage += pick_random_loot(parts)

/obj/effect/decal/mecha_wreckage/ripley/deathripley
	name = "Death-Ripley wreckage"
	icon_state = "deathripley-broken"

/obj/effect/decal/mecha_wreckage/honker
	name = "Honker wreckage"
	icon_state = "honker-broken"

/obj/effect/decal/mecha_wreckage/honker/New()
	..()
	var/list/parts = list(
							/obj/item/mecha_parts/chassis/honker,
							/obj/item/mecha_parts/part/honker_torso,
							/obj/item/mecha_parts/part/honker_head,
							/obj/item/mecha_parts/part/honker_left_arm,
							/obj/item/mecha_parts/part/honker_right_arm,
							/obj/item/mecha_parts/part/honker_left_leg,
							/obj/item/mecha_parts/part/honker_right_leg)
	welder_salvage += pick_random_loot(parts)

/obj/effect/decal/mecha_wreckage/durand
	name = "Durand wreckage"
	icon_state = "durand-broken"

/obj/effect/decal/mecha_wreckage/durand/New()
	..()
	var/list/parts = list(
								/obj/item/mecha_parts/part/durand_torso,
								/obj/item/mecha_parts/part/durand_head,
								/obj/item/mecha_parts/part/durand_left_arm,
								/obj/item/mecha_parts/part/durand_right_arm,
								/obj/item/mecha_parts/part/durand_left_leg,
								/obj/item/mecha_parts/part/durand_right_leg)
	welder_salvage += pick_random_loot(parts)


/obj/effect/decal/mecha_wreckage/durand/old
	name = "Durand wreckage"
	icon_state = "old_durand-broken"

/obj/effect/decal/mecha_wreckage/phazon
	name = "Phazon wreckage"
	icon_state = "phazon-broken"


/obj/effect/decal/mecha_wreckage/odysseus
	name = "Odysseus wreckage"
	icon_state = "odysseus-broken"

/obj/effect/decal/mecha_wreckage/odysseus/New()
	..()
	var/list/parts = list(
								/obj/item/mecha_parts/part/odysseus_torso,
								/obj/item/mecha_parts/part/odysseus_head,
								/obj/item/mecha_parts/part/odysseus_left_arm,
								/obj/item/mecha_parts/part/odysseus_right_arm,
								/obj/item/mecha_parts/part/odysseus_left_leg,
								/obj/item/mecha_parts/part/odysseus_right_leg)
	welder_salvage += pick_random_loot(parts)

/obj/effect/decal/mecha_wreckage/clarke
	name = "Clarke wreckage"
	icon_state = "clarke-broken"

/obj/effect/decal/mecha_wreckage/clarke/New()
	..()
	var/list/parts = list(
								/obj/item/mecha_parts/part/clarke_torso,
								/obj/item/mecha_parts/part/clarke_head,
								/obj/item/mecha_parts/part/clarke_left_arm,
								/obj/item/mecha_parts/part/clarke_right_arm,
								/obj/item/mecha_parts/part/clarke_left_tread,
								/obj/item/mecha_parts/part/clarke_right_tread)
	welder_salvage += pick_random_loot(parts)

/obj/effect/decal/mecha_wreckage/vehicle
	name = "(BUG) BASE VEHICLE WRECKAGE"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "pussywagon_destroyed"
	desc = "Remains of some unfortunate vehicle. Completely unrepairable."
