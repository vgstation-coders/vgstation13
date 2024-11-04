#define REAGENT_USE 5 // amount of reagent used on each spray

/obj/item/weapon/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
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
	force = 10.0
	starting_materials = list(MAT_IRON = 90) // TODO: Check against autolathe.
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	attack_verb = list("slams", "whacks", "bashes", "thunks", "batters", "bludgeons", "thrashes")
	slimeadd_message = "You attach the slime extract to the extinguisher's funnel"
	slimes_accepted = SLIME_BLUE
	slimeadd_success_message = "It feels much colder now"
	var/max_water = 50
	var/last_use = 1.0
	var/safety = 1
	var/sprite_name = "fire_extinguisher"

/obj/item/weapon/extinguisher/New()
	. = ..()
	create_reagents(max_water)
	reagents.add_reagent(WATER, max_water)

/obj/item/weapon/extinguisher/empty/New()
	. = ..()
	reagents.clear_reagents()

/obj/item/weapon/extinguisher/mini
	name = "fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	item_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	flags = FPRINT
	throwforce = 2
	w_class = W_CLASS_SMALL
	force = 3.0
	starting_materials = null
	max_water = 30
	sprite_name = "miniFE"

/obj/item/weapon/extinguisher/foam
	name = "foam fire extinguisher"
	desc = "A modern foam fire supression system."
	icon_state = "foam_extinguisher0"
	item_state = "foam_extinguisher"
	sprite_name = "foam_extinguisher"

/proc/pack_check(mob/user, var/obj/item/weapon/extinguisher/E) //Checks the user for a nonempty chempack.
	var/mob/living/M = user
	if (M && M.back && istype(M.back,/obj/item/weapon/reagent_containers/chempack))
		var/obj/item/weapon/reagent_containers/chempack/P = M.back
		if (!P.safety)
			if (!P.is_empty())
				transfer_sub(P, E, 5, user)
				return 2
			else
				to_chat(user, "<span class='notice'>\The [P] is empty!</span>")
				return 1
		else
			return 0

/obj/item/weapon/extinguisher/examine(mob/user)
	..()
	if(!is_open_container())
		reagents.get_examine(user)
	for(var/thing in src)
		to_chat(user, "<span class='warning'>\A [thing] is jammed into the nozzle!</span>")

/obj/item/weapon/extinguisher/attack_self(mob/user as mob)
	safety = !safety
	src.icon_state = "[sprite_name][!safety]"
	src.desc = "The safety is [safety ? "on" : "off"]."
	to_chat(user, "The safety is [safety ? "on" : "off"].")
	return

/obj/item/weapon/extinguisher/attackby(obj/item/W, mob/user)
	if(user.stat || user.restrained() || user.lying)
		return
	if (W.is_wrench(user))
		if(!is_open_container())
			user.visible_message("[user] begins to unwrench the fill cap on \the [src].","<span class='notice'>You begin to unwrench the fill cap on \the [src].</span>")
			if(do_after(user, src, 25))
				user.visible_message("[user] removes the fill cap on \the [src].","<span class='notice'>You remove the fill cap on \the [src].</span>")
				W.playtoolsound(src, 100)
				flags |= OPENCONTAINER
		else
			user.visible_message("[user] begins to seal the fill cap on \the [src].","<span class='notice'>You begin to seal the fill cap on \the [src].</span>")
			if(do_after(user, src, 25))
				user.visible_message("[user] fastens the fill cap on \the [src].","<span class='notice'>You fasten the fill cap on \the [src].</span>")
				W.playtoolsound(src, 100)
				flags &= ~OPENCONTAINER
		return
	if (istype(W, /obj/item) && !is_open_container() && !istype(src, /obj/item/weapon/extinguisher/foam) && !istype(W, /obj/item/weapon/storage/evidencebag))
		if(W.is_open_container())
			return //We're probably trying to fill it
		if(W.w_class > W_CLASS_TINY)
			to_chat(user, "\The [W] won't fit into the nozzle!")
			return
		if(locate(/obj) in src)
			to_chat(user, "There's already something crammed into the nozzle.")
			return
		if(isrobot(user) && !isMoMMI(user)) // MoMMI's can but borgs can't
			to_chat(user, "You're a robot. No.")
			return
		if(user.drop_item(W, src))
			to_chat(user, "You cram \the [W] into the nozzle of \the [src].")
			message_admins("[user]/[user.ckey] has crammed \a [W] into a [src].")

/obj/item/weapon/extinguisher/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		if((istype(target, /obj/structure/reagent_dispensers)))
			target.reagents.trans_to(src, 50, log_transfer = TRUE, whodunnit = user)
			to_chat(user, "<span class='notice'>\The [src] is now refilled</span>")
			playsound(src, 'sound/effects/refill.ogg', 50, 1, -6)
			return

		if(is_open_container() && reagents.total_volume)
			to_chat(user, "<span class='notice'>You empty \the [src] onto [target].</span>")
			user.investigation_log(I_CHEMS, "has splashed [reagents.get_reagent_ids(1)] from \a [src] ([type]) onto \the [target].")
			if(reagents.has_reagent(FUEL))
				message_admins("[user.name] ([user.ckey]) poured welding fuel onto [target]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
				log_game("[user.name] ([user.ckey]) poured welding fuel onto [target]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return
	if (!safety && !is_open_container())
		if (src.reagents.total_volume < 1)
			var/pack = pack_check(user, src)
			if (!pack) //Only display the "extinguisher empty" warning if the user is not wearing a chempack, since chempacks are designed to be used with empty items.
				to_chat(user, "<span class='warning'>\The [src] is empty!</span>")
				return
			else if (pack == 1)
				return

		if (world.time < src.last_use + 20)
			return
		user.delayNextAttack(5, 1)

		reagents.log_bad_reagents(user, src)
		user.investigation_log(I_CHEMS, "sprayed [REAGENT_USE]u from \a [src] ([type]) containing [reagents.get_reagent_ids(1)] towards [target] ([target.x], [target.y], [target.z]).")

		src.last_use = world.time

		playsound(src, 'sound/effects/extinguish.ogg', 75, 1, -3)

		var/direction = get_dir(src,target)

		if(user.locked_to && isobj(user.locked_to) && !user.locked_to.anchored )
			spawn()
				var/obj/B = user.locked_to
				var/movementdirection = turn(direction,180)
				for(var/i in list(1,1,1,1,2,2,3,3,3))
					B.set_glide_size(DELAY2GLIDESIZE(i))
					if(!step(B, movementdirection))
						B.change_dir(turn(movementdirection, 180)) //don't turn around when hitting a wall
						break
					B.change_dir(turn(movementdirection, 180)) //face away from where we're going
					sleep(i)

		for(var/obj/thing in src)
			thing.forceMove(get_turf(src))
			thing.throw_at(target,10,thing.throw_speed*3)
			user.visible_message(
				"<span class='danger'>[user] fires [src] and launches [thing] at [target]!</span>",
				"<span class='danger'>You fire [src] and launch [thing] at [target]!</span>")
			break

		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))

		var/list/the_targets = list(T,T1,T2)

		for(var/a=0, a<REAGENT_USE, a++)
			spawn(0)
				var/datum/reagents/R = new/datum/reagents(5)
				R.my_atom = src
				reagents.trans_to_holder(R,1)
				var/obj/effect/water/spray/W = new /obj/effect/water/spray/( get_turf(src))
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
				for(var/b=0, b<5, b++)
					step_towards(W,my_target)
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
	else
		return ..()
	return




/obj/item/weapon/extinguisher/foam/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		if((istype(target, /obj/structure/reagent_dispensers/watertank)))
			var/obj/o = target
			o.reagents.trans_to(src, 50)
			to_chat(user, "<span class='notice'>\The [src] is now refilled</span>")
			playsound(src, 'sound/effects/refill.ogg', 50, 1, -6)
			return

	if (!safety && !is_open_container())
		if (src.reagents.total_volume < 1)
			var/pack = pack_check(user, src)
			if (!pack)
				to_chat(user, "<span class='warning'>\The [src] is empty!</span>")
				return
			else if (pack == 1)
				return

		if (world.time < src.last_use + 20)
			return
		user.delayNextAttack(5, 1)
		src.last_use = world.time

		playsound(src, 'sound/effects/extinguish.ogg', 75, 1, -3)

		var/direction = get_dir(src,target)

		if(user.locked_to && isobj(user.locked_to) && !user.locked_to.anchored )
			spawn(0)
				var/obj/B = user.locked_to
				var/movementdirection = turn(direction,180)
				for(var/i in list(1,1,1,1,2,2,3,3,3))
					B.set_glide_size(DELAY2GLIDESIZE(i))
					if(!step(B, movementdirection))
						B.change_dir(turn(movementdirection, 180)) //don't turn around when hitting a wall
						break
					B.change_dir(turn(movementdirection, 180)) //face away from where we're going
					sleep(i)

		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))

		var/list/the_targets = list(T,T1,T2)

		for(var/a=0, a<REAGENT_USE, a++)
			spawn(0)
				var/datum/reagents/R = new/datum/reagents(5)
				R.my_atom = src
				reagents.trans_to_holder(R,1)
				var/obj/effect/foam/fire/W
				if(has_slimes & SLIME_BLUE)
					W=new /obj/effect/foam/fire/enhanced(get_turf(src),R)
				else
					W = new /obj/effect/foam/fire(get_turf(src),R)
				var/turf/my_target = pick(the_targets)
				if(!W || !src)
					return
				for(var/b=0, b<5, b++)
					var/turf/oldturf = get_turf(W)
					step_towards(W,my_target)
					if(!W || !W.reagents)
						return
					W.reagents.reaction(get_turf(W), TOUCH)
					for(var/atom/atm in get_turf(W))
						if(!W)
							return
						W.reagents.reaction(atm, TOUCH)                      // Touch, since we sprayed it.
						if(W.reagents.has_reagent(WATER))
							if(isliving(atm)) // For extinguishing mobs on fire
								var/mob/living/M = atm                           // Why isn't this handled by the reagent? - N3X
								M.extinguish()
							if(atm.on_fire) // For extinguishing objects on fire
								atm.extinguish()
							if(atm.molten) // Molten shit.
								atm.molten=0
								atm.solidify()

					var/obj/effect/foam/fire/F = locate() in oldturf
					if(!istype(F) && oldturf != get_turf(src))
						F = new /obj/effect/foam/fire( get_turf(oldturf) , W.reagents)
					if(W.loc == my_target)
						break
					sleep(2)

		user.apply_inertia(get_dir(target, user))
	else
		return ..()
	return

#undef REAGENT_USE
