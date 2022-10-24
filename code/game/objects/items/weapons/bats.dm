/obj/item/weapon/bat
	name = "baseball bat"
	desc = "Good for reducing a doubleheader to a zeroheader."
	hitsound = "sound/weapons/baseball_hit_flesh.ogg"
	icon_state = "baseball_bat"
	item_state = "baseball_bat0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	autoignition_temperature = AUTOIGNITION_WOOD
	flags = TWOHANDABLE
	force = 14
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = W_CLASS_LARGE
	w_type = RECYK_WOOD
	var/spiked = 0
	var/can_spike = 1
	var/twohandforce = 16
	var/on_floor_only = 0

/obj/item/weapon/bat/update_wield(mob/user)
	..()
	item_state = "[icon_state][wielded ? 1 : 0]"
	force = wielded ? twohandforce : initial(force)
	if(user)
		user.update_inv_hands()

/obj/item/weapon/bat/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/stack/rods) && !spiked && can_spike)
		if(!ishammer(user.get_inactive_hand()))
			to_chat(user, "<span class='info'>You need to be holding a toolbox or hammer to do that!</span>")
			return
		to_chat(user, "<span class='notice'>You hammer \the [W.name] into \the [src].</span>")
		var/obj/item/stack/rodstack = W
		rodstack.use(1)
		spike()
	if(W.is_wirecutter(user) && spiked)
		var/obj/item/stack/rods/R = new(get_turf(src),1)
		W.playtoolsound(src,50)
		to_chat(user, "<span class='notice'>You remove \the [R] from \the [src].</span>")
		unspike()

/obj/item/weapon/bat/proc/spike()
	name = "spiked bat"
	desc = "A classic among delinquent youths. Not very effective at hitting balls."
	hitsound = "sound/weapons/spikebat_hit.ogg"
	icon_state = "spikebat"
	item_state = "spikebat0"
	force = 10
	sharpness = 0.3
	sharpness_flags = SHARP_TIP
	spiked = 1
	twohandforce = 13

/obj/item/weapon/bat/proc/unspike()
	name = initial(name)
	desc = initial(desc)
	hitsound = initial(hitsound)
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	force = initial(force)
	sharpness = 0
	sharpness_flags = 0
	spiked = 0
	twohandforce = initial(twohandforce)

/obj/item/weapon/bat/IsShield()
	return !spiked && !on_floor_only

/obj/item/weapon/bat/pre_throw(atom/movable/target)
	var/mob/living/carbon/human/user = usr
	if(istype(user))
		var/obj/item/I = user.get_inactive_hand()
		if(!on_floor_only && istype(I) && I != src)
			return hit_away(I,user,target)
		else if(isturf(target.loc) && user.Adjacent(target))
			return hit_away(target,user)

/obj/item/weapon/bat/proc/hit_away(obj/item/I, mob/living/carbon/human/user, atom/target)
	if(istype(user) && istype(I) && !istype(I,/obj/item/offhand) && !istype(I,/obj/item/weapon/grab))
		if(I.cant_drop && I.loc == user)
			to_chat(user, "<span class='warning'>You can't hit away an item stuck to your hand!</span>")
			return
		visible_message("<span class='borange'>[user] hits \the [I] away with \the [src]!</span>")
		playsound(user, 'sound/weapons/baseball_hit.ogg', 75, 1)
		user.remove_from_mob(I)
		I.forceMove(get_turf(user))
		var/throw_mult = user.species.throw_mult
		throw_mult += (user.get_strength()-1)/2 //For each level of strength above 1, add 0.5
		throw_mult *= 2/(2**(I.w_class-1)) //multiplier of 2, 1, 0.5, 0.25 and 0.125 for each increasing w_class
		throw_mult *= max(0,1-(spiked/2)) //spiked bats can hit, but less effectively
		var/range_mult = 1
		if(istype(I.loc,/turf/simulated))
			var/turf/simulated/T = I.loc
			if(T.is_wet() && on_floor_only)
				range_mult *= 2 //slippery floors are good for hockey sticks
		if(!target)
			var/ourdir = get_dir(user,I) || user.dir
			target = get_ranged_target_turf(get_turf(I), ourdir, I.throw_range*throw_mult)
		I.throw_at(target, I.throw_range*throw_mult*range_mult, I.throw_speed*throw_mult)
		return 1

/obj/item/weapon/bat/on_block(damage, atom/movable/blocked)
	if(isliving(loc))
		var/mob/living/H = loc
		if(!H.in_throw_mode || !wielded || damage > 15 || on_floor_only)
			return FALSE
		if(IsShield() < blocked.ignore_blocking)
			return FALSE
		if ((ismob(blocked) && prob(100 - (spiked * 90))) || prob((85 - round(damage * 5)) * (max(0, 1 - (spiked / 2)))))
			visible_message("<span class='borange'>[loc] knocks away \the [blocked] with \the [src]!</span>")
			playsound(loc, 'sound/weapons/baseball_hit.ogg', 75, 1)
			if(ismovable(blocked))
				var/atom/movable/M = blocked
				var/turf/Q = get_turf(M)
				var/turf/target
				var/list/throwdir_chances = list(
					"-45" = 1,
					"0" = H.reagents.get_sportiness(),
					"45" = 1
				)
				var/throwdir = turn(H.dir, text2num(pickweight(throwdir_chances)))
				if(istype(Q, /turf/space)) // if ended in space, then range is unlimited
					target = get_edge_target_turf(Q, throwdir)
				else						// otherwise limit to 10 tiles
					target = get_ranged_target_turf(Q, throwdir, 10)
				M.throw_at(target,100,4)
			H.throw_mode_off()
			return TRUE
		return FALSE

/obj/item/weapon/bat/spiked/New()
	..()
	spike()

/obj/item/weapon/bat/hockey
	name = "hockey stick"
	desc = "Good for reducing a doubleheader to a zeroheader."
	hitsound = "sound/weapons/baseball_hit_flesh.ogg"
	icon_state = "baseball_bat"
	item_state = "baseball_bat0"
	autoignition_temperature = AUTOIGNITION_PLASTIC
	flags = TWOHANDABLE
	force = 10
	throwforce = 7
	twohandforce = 13
	w_type = RECYK_PLASTIC
	on_floor_only = 1
	can_spike = 0

/obj/item/weapon/bat/cricket
	name = "cricket bat"
	desc = "Good for reducing a doubleheader to a zeroheader."
	icon_state = "baseball_bat"
	item_state = "baseball_bat0"

/obj/item/weapon/bat/cricket/spiked/New()
	..()
	spike()

/obj/item/weapon/bat/hurley
	name = "hurley"
	desc = "Camán, step it up." // TODO: something less than a lame pun
	icon_state = "baseball_bat"
	item_state = "baseball_bat0"
	can_spike = 0
