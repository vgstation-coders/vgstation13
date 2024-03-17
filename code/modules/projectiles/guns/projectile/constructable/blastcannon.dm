/obj/item/weapon/gun/projectile/blastcannon
	name = "pipe gun"
	desc = "A pipe welded onto a gun stock. You're not sure how you could even use this."
	icon = 'icons/obj/gun.dmi'
	icon_state = "blastcannon_empty"
	item_state = "blastcannon_empty"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	item_state = null
	w_class = W_CLASS_MEDIUM
	force = 5
	flags = FPRINT
	siemens_coefficient = 1
	ejectshell = 0
	caliber = null
	ammo_type = null
	fire_sound = null
	fire_volume = 100
	conventional_firearm = 0
	silenced = 1
	var/obj/item/device/transfer_valve/bomb = null
	var/obj/item/toy/bomb/toybomb = null
	var/datum/gas_mixture/bomb_air_contents_1 = null
	var/datum/gas_mixture/bomb_air_contents_2 = null
	var/ignorecap = 0
	var/overcap = 0
	var/bomb_appearance = null
	var/widening_rate = 5


/obj/item/weapon/gun/projectile/blastcannon/Destroy()
	if(bomb)
		QDEL_NULL(bomb)
	bomb_appearance = null
	bomb_air_contents_1 = null
	bomb_air_contents_2 = null
	..()

/obj/item/weapon/gun/projectile/blastcannon/attack_self(mob/user as mob)
	if(bomb)
		bomb.forceMove(user.loc)
		user.put_in_hands(bomb)
		to_chat(user, "You detach \the [bomb] from \the [src].")
		bomb = null
		bomb_appearance = null
		name = "pipe gun"
		desc = "A pipe welded onto a gun stock. You're not sure how you could even use this."
		w_class = W_CLASS_MEDIUM
	else if (toybomb)
		toybomb.forceMove(user.loc)
		user.put_in_hands(toybomb)
		to_chat(user, "You detach \the [toybomb] from \the [src].")
		toybomb = null
		bomb_appearance = null
		name = "pipe gun"
		desc = "A pipe welded onto a gun stock. You're not sure how you could even use this."
		w_class = W_CLASS_MEDIUM
	update_icon()

/obj/item/weapon/gun/projectile/blastcannon/pickup(mob/user as mob)
	..()
	update_icon()

/obj/item/weapon/gun/projectile/blastcannon/dropped(mob/user as mob)
	..()
	update_icon()

/obj/item/weapon/gun/projectile/blastcannon/update_icon()
	overlays.len = 0
	item_state = "blastcannon_empty"
	if(!bomb_appearance)
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_hands()
		return

	var/image/bomb_icon = image('icons/obj/weaponsmithing.dmi', src, "nothing")
	bomb_icon.appearance = bomb_appearance
	bomb_icon.plane = FLOAT_PLANE
	bomb_icon.layer = FLOAT_LAYER
	bomb_icon.pixel_x = 2 * PIXEL_MULTIPLIER
	bomb_icon.pixel_y = 9 * PIXEL_MULTIPLIER

	item_state = "blastcannon_ttv"
	if(iscarbon(loc))
		var/mob/living/carbon/M = loc
		M.update_inv_hands()

	overlays += bomb_icon

/obj/item/weapon/gun/projectile/blastcannon/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/device/transfer_valve))
		if(bomb)
			to_chat(user, "<span class='warning'>There's already a [bomb.name] attached to \the [src]!</span>")
			return
		if(toybomb)
			to_chat(user, "<span class='warning'>There's already a [toybomb.name] attached to \the [src]!</span>")
			return
		var/obj/item/device/transfer_valve/T = W
		if(!T.tank_one || !T.tank_two)
			to_chat(user, "<span class='warning'>Nothing's going to happen if there[!T.tank_one && !T.tank_two ? " aren't any tanks" : "'s only one tank"] attached to \the [W]!</span>")
			return
		bomb_appearance = W.appearance
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			bomb_appearance = null
			return 1
		bomb = W
		user.visible_message("[user] attaches \the [W] to \the [src].","You attach \the [W] to \the [src].")
		name = "blast cannon"
		desc = "A weapon of devastating force, the explosive power from the tank transfer valve is funneled straight out of its barrel."
		w_class = W_CLASS_LARGE
	if (istype(W, /obj/item/toy/bomb))
		if(bomb)
			to_chat(user, "<span class='warning'>There's already a [bomb.name] attached to \the [src]!</span>")
			return
		if(toybomb)
			to_chat(user, "<span class='warning'>There's already a [toybomb.name] attached to \the [src]!</span>")
			return
		bomb_appearance = W.appearance
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			bomb_appearance = null
			return 1
		toybomb = W
		user.visible_message("[user] attaches \the [W] to \the [src].","You attach \the [W] to \the [src]. It fits there perfectly.")
		name = "blast cannon"
		desc = "A weapon of devastating force, the explosive power from the tank transfer valve is funneled straight out of its barrel."
		w_class = W_CLASS_LARGE

	update_icon()

/obj/item/weapon/gun/projectile/blastcannon/examine(var/mob/user)
	..()
	if(Adjacent(user))
		to_chat(user, "<span class='warning'>Upon closer inspection, that valve and the tanks mounted on it appear to be made of...cheap plastic?</span>")

/obj/item/weapon/gun/projectile/blastcannon/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if (istype(A, /obj/item/weapon/storage/backpack ))
		return

	else if (A.loc == user.loc)
		return

	else if (A.loc == user)
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	if(!bomb)
		return

	if(!can_Fire(user, 1))
		return

	else
		if(bomb.damaged)
			click_empty(user)
			return

		bomb_air_contents_1 = bomb.tank_one.air_contents
		bomb_air_contents_2 = bomb.tank_two.air_contents

		bomb_air_contents_2.volume += bomb_air_contents_1.volume
		var/datum/gas_mixture/temp
		temp = bomb_air_contents_1.remove_ratio(1)
		bomb_air_contents_2.merge(temp)

		if(!bomb_air_contents_2)
			return

		if(bomb_air_contents_2)
			bomb_air_contents_2.react()

		var/pressure = bomb_air_contents_2.return_pressure()

		var/heavy_damage_range = 0
		var/medium_damage_range = 0
		var/light_damage_range = 0

		if(pressure > TANK_FRAGMENT_PRESSURE)
			bomb_air_contents_2.react()
			bomb_air_contents_2.react()
			bomb_air_contents_2.react()
			pressure = bomb_air_contents_2.return_pressure()
			var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
			score.largest_TTV = max(score.largest_TTV, range)
			if(!ignorecap && (range > MAX_EXPLOSION_RANGE))
				overcap = range
				range = min(range, MAX_EXPLOSION_RANGE)

			var/transfer_moles1 = (bomb.tank_one.air_contents.return_pressure() * bomb.tank_one.air_contents.volume) / (bomb.tank_one.air_contents.temperature * R_IDEAL_GAS_EQUATION)
			bomb.tank_one.air_contents.remove(transfer_moles1)
			var/transfer_moles2 = (bomb.tank_two.air_contents.return_pressure() * bomb.tank_two.air_contents.volume) / (bomb.tank_two.air_contents.temperature * R_IDEAL_GAS_EQUATION)
			bomb.tank_two.air_contents.remove(transfer_moles2)

			bomb_air_contents_1 = null
			bomb_air_contents_2 = null

			user.visible_message("<span class='danger'>[user] opens \the [bomb] on \his [src.name] and fires a blast wave at \the [A]!</span>","<span class='danger'>You open \the [bomb] on your [src.name] and fire a blast wave at \the [A]!</span>")

			heavy_damage_range = round(range*0.25)
			medium_damage_range = round(range*0.5)
			light_damage_range = round(range)

		else
			user.visible_message("<span class='danger'>[user] opens \the [bomb] on \his [src.name]!</span>","<span class='danger'>You open \the [bomb] on your [src.name]!</span>")
			user.visible_message("\The [bomb] on [user]'s [src.name] hisses pitifully.","\The [bomb] on your [src.name] hisses pitifully.")
			to_chat(user, "<span class='warning'>The bomb is a dud!</span>")
			var/ratio1 = bomb_air_contents_1.volume/bomb_air_contents_2.volume
			var/datum/gas_mixture/temp2
			temp2 = bomb_air_contents_2.remove_ratio(ratio1)
			bomb_air_contents_1.merge(temp2)
			bomb_air_contents_2.volume -=  bomb_air_contents_1.volume

			bomb.tank_one.air_contents = bomb_air_contents_1
			bomb.tank_two.air_contents = bomb_air_contents_2

		if(heavy_damage_range && medium_damage_range && light_damage_range)
			var/obj/item/projectile/bullet/blastwave/B = new(null)
			B.heavy_damage_range = heavy_damage_range
			B.medium_damage_range = medium_damage_range
			B.light_damage_range = light_damage_range
			B.true_range = overcap
			B.widening_rate = widening_rate
			in_chamber = B
			if(Fire(A,user,params, "struggle" = struggle))
				if(ismob(src.loc) && !isanimal(src.loc))
					var/mob/living/M = src.loc
					var/turf/Q = get_turf(M)
					var/turf/target
					var/throwdir = turn(M.dir, 180)
					if(istype(Q, /turf/space)) // if ended in space, then range is unlimited
						target = get_edge_target_turf(Q, throwdir)
					else						// otherwise limit to 10 tiles
						target = get_ranged_target_turf(Q, throwdir, 10)
					M.throw_at(target,100,4)
					if(!(M.flags & INVULNERABLE))
						M.apply_effects(0, 2)
						to_chat(user, "<span class='warning'>You're thrown back by the force of the blast!</span>")

					var/turf/epicenter = get_turf(user)
					message_admins("Blascannon fired with range ([heavy_damage_range], [medium_damage_range], [light_damage_range]) in area [epicenter.loc.name] ([formatJumpTo(epicenter,"JMP")]) [user ? " fired by [user] [user.ckey ? "([user.ckey])" : "(no key)"](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>)([formatJumpTo(user,"JMP")])" : ""]",0,1)
					log_game("Blascannon fired with range ([heavy_damage_range], [medium_damage_range], [light_damage_range]) in area [epicenter.loc.name] [user ? " fired by [user] [user.ckey ? "([user.ckey])" : "(no key)"]" : ""]")
					if (overcap)
						message_admins("If uncapped, its range would have been ([round(overcap*0.25)], [round(overcap*0.5)], [round(overcap)])",0,1)
						log_game("If uncapped, its range would have been ([round(overcap*0.25)], [round(overcap*0.5)], [round(overcap)])")
				bomb.damaged = 1
				bomb.update_icon()
			else
				qdel(B)
				in_chamber = null
