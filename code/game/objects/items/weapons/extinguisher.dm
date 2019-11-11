#define REAGENT_USE 5 // amount of reagent used on each spray

/obj/item/weapon/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher. Typically used for everything except putting out fires."
	icon = 'icons/obj/items.dmi'
	icon_state = "fire_extinguisher0"
	item_state = "fire_extinguisher"
	hitsound = 'sound/weapons/smash.ogg'
	flags = FPRINT
	siemens_coefficient = 1
	throwforce = 10
	w_class = W_CLASS_MEDIUM
	throw_speed = 2
	throw_range = 10
	force = 10
	starting_materials = list(MAT_IRON = 90)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	attack_verb = list("slams", "whacks", "bashes", "thunks", "batters", "bludgeons", "thrashes")
	var/max_water = 50
	var/last_use = 1.0
	var/safety = 1
	var/can_cram_item = 1
	var/sprite_name = "fire_extinguisher"

/obj/item/weapon/extinguisher/New()
	. = ..()
	create_reagents(max_water)
	reagents.add_reagent(WATER, max_water)

/obj/item/weapon/extinguisher/empty/New()
	. = ..()
	reagents.clear_reagents()

/obj/item/weapon/extinguisher/examine(mob/user)
	..()
	to_chat(user, "The safety is [safety ? "on" : "off"].")
	if(!is_open_container())
		reagents.get_examine(user)
	for(var/thing in src)
		to_chat(user, "<span class='warning'>\A [thing] is jammed into the nozzle!</span>")

/obj/item/weapon/extinguisher/mini
	name = "fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	item_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	flags = FPRINT
	throwforce = 2
	w_class = W_CLASS_SMALL
	force = 3
	starting_materials = null
	max_water = 30
	sprite_name = "miniFE"
	can_cram_item = 0 //Too small

/obj/item/weapon/extinguisher/foam
	name = "foam fire extinguisher"
	desc = "A modern foam fire supression system."
	icon_state = "foam_extinguisher0"
	item_state = "foam_extinguisher"
	sprite_name = "foam_extinguisher"
	can_cram_item = 0 //Foam extinguisher, cannot propel items

/obj/item/weapon/extinguisher/proc/pack_check(mob/user) //Checks the user for a nonempty chempack.
	var/mob/living/M = user
	if(M && M.back && istype(M.back, /obj/item/weapon/reagent_containers/chempack))
		var/obj/item/weapon/reagent_containers/chempack/P = M.back
		if(!P.safety)
			if(!P.is_empty())
				transfer_sub(P, src, 5, user)
				return 2
			else
				to_chat(user, "<span class='notice'>[P] is empty!</span>")
				return 1
		else
			return 0

/obj/item/weapon/extinguisher/attack_self(mob/user as mob)
	safety = !safety
	icon_state = "[sprite_name][!safety]"
	to_chat(user, "<span class='notice'>The safety is now [safety ? "on" : "off"].</span>")

/obj/item/weapon/extinguisher/attackby(obj/item/W, mob/user)
	if(user.stat || user.restrained() || user.lying)
		return
	if(iswrench(W))
		if(!is_open_container())
			user.visible_message("<span class='notice'>[user] begins to unwrench the fill cap on [src].</span>",
			"<span class='notice'>You begin to unwrench the fill cap on [src].</span>")
			if(do_after(user, src, 25))
				user.visible_message("<span class='notice'>[user] removes the fill cap on [src].</span>",
				"<span class='notice'>You remove the fill cap on [src].</span>")
				playsound(src,'sound/items/Ratchet.ogg', 100, 1)
				flags |= OPENCONTAINER
		else
			user.visible_message("<span class='notice'>[user] begins to seal the fill cap on [src].</span>",
			"<span class='notice'>You begin to seal the fill cap on [src].</span>")
			if(do_after(user, src, 25))
				user.visible_message("<span class='notice'>[user] fastens the fill cap on [src].</span>",
				"<span class='notice'>You fasten the fill cap on [src].</span>")
				playsound(src,'sound/items/Ratchet.ogg', 100, 1)
				flags &= ~OPENCONTAINER
		return

	if(istype(W, /obj/item) && !is_open_container() && !istype(W, /obj/item/weapon/storage/evidencebag))
		if(W.is_open_container())
			return //We're probably trying to fill it
		if(!can_cram_item)
			to_chat(user, "<span class='warning'>[src] can't possibly hold and fire any item!</span>")
			return
		if(W.w_class > W_CLASS_TINY)
			to_chat(user, "<span class='warning'>[W] won't fit into the nozzle!</span>")
			return
		if(locate(/obj) in src)
			to_chat(user, "<span class='warning'>There's already something crammed into the nozzle.</span>")
			return
		if(isrobot(user) && !isMoMMI(user)) //MoMMI's can but borgs can't
			to_chat(user, "<span class='warning'>You're a robot. No.</span>")
			return
		if(user.drop_item(W, src))
			to_chat(user, "<span class='notice'>You cram [W] into [src]'s nozzle.</span>")
			message_admins("[user]/[user.ckey] has crammed \a [W] into a [src].")

/obj/item/weapon/extinguisher/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		if(istype(target, /obj/structure/reagent_dispensers))
			var/obj/structure/reagent_dispensers/watertank/tank = target
			tank.reagents.trans_to(src, max_water)
			user.visible_message("<span class='notice'>[user] refills [src] using [tank].</span>",
			"<span class='notice'>You refill [src] using [tank].</span>")
			playsound(src, 'sound/effects/refill.ogg', 50, 1, -6)
			return

		if(istype(target, /obj/structure/sink))
			var/obj/structure/sink/sink = target
			reagents.add_reagent(WATER, max_water)
			user.visible_message("<span class='notice'>[user] refills [src] using [sink].</span>",
			"<span class='notice'>You refill [src] using [sink].</span>")
			playsound(src, 'sound/effects/refill.ogg', 50, 1, -6)
			return

		if(is_open_container() && reagents.total_volume)
			user.visible_message("<span class='notice'>[user] empties [src] onto [target].</span>",
			"<span class='notice'>You empty [src] onto [target].</span>")
			user.investigation_log(I_CHEMS, "has splashed [reagents.get_reagent_ids(1)] from \a [src] ([type]) onto \the [target].")
			if(reagents.has_reagent(FUEL))
				message_admins("[user.name] ([user.ckey]) poured welding fuel onto [target]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
				log_game("[user.name] ([user.ckey]) poured welding fuel onto [target]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			reagents.reaction(target, TOUCH)
			spawn(5) reagents.clear_reagents()
			return

	if(!safety && !is_open_container())
		if(reagents.total_volume < 1)
			var/pack = pack_check(user)
			if(!pack) //Only display the "extinguisher empty" warning if the user is not wearing a chempack, since chempacks are designed to be used with empty items.
				to_chat(user, "<span class='warning'>[src] is empty!</span>")
				return
			else if(pack == 1)
				return

		if(world.time < last_use + 20)
			return
		user.delayNextAttack(5, 1)

		reagents.log_bad_reagents(user, src)
		user.investigation_log(I_CHEMS, "sprayed [REAGENT_USE]u from \a [src] ([type]) containing [reagents.get_reagent_ids(1)] towards [target] ([target.x], [target.y], [target.z]).")

		last_use = world.time

		playsound(src, 'sound/effects/extinguish.ogg', 75, 1, -3)

		var/direction = get_dir(src, target)

		if(user.locked_to && isobj(user.locked_to) && !user.locked_to.anchored)
			spawn()
				var/obj/B = user.locked_to
				var/movementdirection = turn(direction,180)
				for(var/i in list(1, 1, 1, 1, 2, 2, 3, 3, 3))
					B.set_glide_size(DELAY2GLIDESIZE(i))
					if(!step(B, movementdirection))
						B.change_dir(turn(movementdirection, 180)) //don't turn around when hitting a wall
						break
					B.change_dir(turn(movementdirection, 180)) //face away from where we're going
					sleep(i)

		for(var/obj/thing in src)
			thing.forceMove(get_turf(src))
			thing.throw_at(target, 10, thing.throw_speed * 3)
			user.visible_message("<span class='danger'>[user] fires [src] and launches [thing] at [target]!</span>",
			"<span class='danger'>You fire [src] and launch [thing] at [target]!</span>")
			break

		extinguish_act(target, user, direction)
	else
		return ..()

//Separate the actual act of spraying the extinguisher's contents to spare duplicates
/obj/item/weapon/extinguisher/proc/extinguish_act(atom/target, mob/user, direction)

	var/turf/T = get_turf(target)
	var/turf/T1 = get_step(T, turn(direction, 90))
	var/turf/T2 = get_step(T, turn(direction, -90))

	var/list/the_targets = list(T, T1, T2)

	for(var/a = 0, a < REAGENT_USE, a++)
		spawn(0)
			var/datum/reagents/R = new/datum/reagents(5)
			R.my_atom = src
			reagents.trans_to_holder(R, 1)
			var/obj/effect/effect/water/spray/W = new /obj/effect/effect/water/spray/(get_turf(src))
			var/ccolor = mix_color_from_reagents(R.reagent_list)
			if(ccolor)
				W.color = ccolor
			var/turf/my_target = pick(the_targets)
			if(!W)
				return
			W.reagents = R
			R.my_atom = W
			if(!W || !src)
				return
			for(var/b = 0, b < 5, b++)
				step_towards(W, my_target)
				if(!W || !W.reagents)
					return
				W.reagents.reaction(get_turf(W), TOUCH)
				for(var/atom/atm in get_turf(W))
					if(!W)
						return
					W.reagents.reaction(atm, TOUCH)                      // Touch, since we sprayed it.
				if(W.loc == my_target)
					break
				sleep(2)

	user.apply_inertia(get_dir(target, user))

/obj/item/weapon/extinguisher/foam/extinguish_act(atom/target, mob/user, direction)

	var/turf/T = get_turf(target)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))

	var/list/the_targets = list(T, T1, T2)

	for(var/a = 0, a < REAGENT_USE, a++)
		spawn(0)
			var/datum/reagents/R = new/datum/reagents(5)
			R.my_atom = src
			reagents.trans_to_holder(R, 1)
			var/obj/effect/effect/foam/fire/W = new /obj/effect/effect/foam/fire(get_turf(src), R)
			var/turf/my_target = pick(the_targets)
			if(!W || !src)
				return
			for(var/b = 0, b < 5, b++)
				var/turf/oldturf = get_turf(W)
				step_towards(W, my_target)
				if(!W || !W.reagents)
					return
				W.reagents.reaction(get_turf(W), TOUCH)
				for(var/atom/atm in get_turf(W))
					if(!W)
						return
					W.reagents.reaction(atm, TOUCH) //Touch, since we sprayed it.
					if(W.reagents.has_reagent(WATER))
						if(isliving(atm)) //For extinguishing mobs on fire
							var/mob/living/M = atm //Why isn't this handled by the reagent? - N3X
							M.ExtinguishMob()
						if(atm.on_fire) //For extinguishing objects on fire
							atm.extinguish()
						if(atm.molten) //Molten shit.
							atm.molten = 0
							atm.solidify()

				var/obj/effect/effect/foam/fire/F = locate() in oldturf
				if(!istype(F) && oldturf != get_turf(src))
					F = new /obj/effect/effect/foam/fire(get_turf(oldturf), W.reagents)
				if(W.loc == my_target)
					break
				sleep(2)

	user.apply_inertia(get_dir(target, user))

#undef REAGENT_USE
