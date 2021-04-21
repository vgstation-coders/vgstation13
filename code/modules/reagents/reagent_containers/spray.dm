/obj/item/weapon/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = OPENCONTAINER|FPRINT
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_GLASS = 3500)
	w_type = RECYK_GLASS
	throw_speed = 2
	throw_range = 10
	amount_per_transfer_from_this = 10
	volume = 250
	possible_transfer_amounts = null
	var/melted = 0

	var/delay_spraying = TRUE // Whether to delay the next attack after using it

	//! List of things to avoid spraying on close range. TODO Remove snowflake, handle this in every attackby() properly.
	var/list/ignore_spray_types = list(/obj/item/weapon/storage, /obj/structure/table, /obj/structure/rack, /obj/structure/closet, /obj/structure/sink)

/obj/item/weapon/reagent_containers/spray/attackby(obj/item/weapon/W, mob/user)
	if(user.is_in_modules(src))
		return
	if(!melted)
		if(W.is_hot())
			to_chat(user, "You slightly melt the plastic on the top of \the [src] with \the [W].")
			melted = 1
	if(melted)
		if(istype(W, /obj/item/stack/rods))
			to_chat(user, "You press \the [W] into the melted plastic on the top of \the [src].")
			var/obj/item/stack/rods/R = W
			if(src.loc == user)
				user.drop_item(src, force_drop = 1)
				var/obj/item/weapon/gun_assembly/I = new (get_turf(user), "spraybottle_assembly")
				user.put_in_hands(I)
			else
				new /obj/item/weapon/gun_assembly(get_turf(src.loc), "spraybottle_assembly")
			R.use(1)
			qdel(src)


/obj/item/weapon/reagent_containers/spray/afterattack(atom/A as mob|obj, mob/user as mob, var/adjacency_flag, var/click_params)
	if (adjacency_flag && is_type_in_list(A, ignore_spray_types))
		return

	if (delay_spraying)
		user.delayNextAttack(8)

	if (istype(A, /obj/structure/reagent_dispensers) && adjacency_flag)
		transfer(A, user, can_send = FALSE, can_receive = TRUE)
		return

	if (is_empty()) //If empty, checks for a nonempty chempack on the user.
		var/mob/living/M = user
		if (M && M.back && istype(M.back,/obj/item/weapon/reagent_containers/chempack))
			var/obj/item/weapon/reagent_containers/chempack/P = M.back
			if (!P.safety)
				if (!P.is_empty())
					if (istype(src,/obj/item/weapon/reagent_containers/spray/chemsprayer)) //The chemsprayer uses three times its amount_per_transfer_from_this per spray.
						transfer_sub(P, src, amount_per_transfer_from_this*3, user)
					else
						transfer_sub(P, src, amount_per_transfer_from_this, user)
				else
					to_chat(user, "<span class='notice'>\The [P] is empty!</span>")
					return
			else
				to_chat(user, "<span class='notice'>\The [src] is empty!</span>")
				return
		else
			to_chat(user, "<span class='notice'>\The [src] is empty!</span>")
			return

	// Log reagents
	reagents.log_bad_reagents(user, src)
	user.investigation_log(I_CHEMS, "sprayed [amount_per_transfer_from_this]u from \a [src] ([type]) containing [reagents.get_reagent_ids(1)] towards [A] ([A.x], [A.y], [A.z]).")

	// Override for your custom puff behaviour
	make_puff(A, user)

/obj/item/weapon/reagent_containers/spray/attack_self(var/mob/user)
	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	to_chat(user, "<span class='notice'>You switched [amount_per_transfer_from_this == 10 ? "on" : "off"] the pressure nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>")

/obj/item/weapon/reagent_containers/spray/restock()
	if(name == "Polyacid spray")
		reagents.add_reagent(PACID, 2)
	else if(name == "Lube spray")
		reagents.add_reagent(LUBE, 2)

/obj/item/weapon/reagent_containers/spray/proc/make_puff(var/atom/target, var/mob/user)
	// Create the chemical puff
	var/transfer_amount = amount_per_transfer_from_this
	if (!can_transfer_an_APTFT() && !is_empty()) //If it doesn't contain enough reagents to fulfill its amount_per_transfer_from_this, but also isn't empty, it'll spray whatever it has left.
		transfer_amount = reagents.total_volume
	var/mix_color = mix_color_from_reagents(reagents.reagent_list)
	var/obj/effect/decal/chemical_puff/D = new /obj/effect/decal/chemical_puff(get_turf(src), mix_color, amount_per_transfer_from_this)
	reagents.trans_to(D, transfer_amount, 1/3)

	// Move the puff toward the target
	spawn(0)
		for (var/i = 0, i < 3, i++)
			step_towards(D, target)
			D.react()
			sleep(3)

		qdel(D)

	playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)

//space cleaner
/obj/item/weapon/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"

/obj/item/weapon/reagent_containers/spray/cleaner/New()
	..()
	reagents.add_reagent(CLEANER, 250)

//pepperspray
/obj/item/weapon/reagent_containers/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by UhangInc, used to blind and down an opponent quickly."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "pepperspray"
	item_state = "pepperspray"
	volume = 40
	amount_per_transfer_from_this = 10

/obj/item/weapon/reagent_containers/spray/pepper/New()
	..()
	reagents.add_reagent(CONDENSEDCAPSAICIN, 40)

// Luminol
/obj/item/weapon/reagent_containers/spray/luminol
	name = "spray bottle (luminol)"
	desc = "A spray bottle with an unscrewable top. A label on the side reads 'Contains: Luminol'."

/obj/item/weapon/reagent_containers/spray/luminol/New()
	..()
	reagents.add_reagent(LUMINOL, 250)

// Plant-B-Gone
/obj/item/weapon/reagent_containers/spray/plantbgone // -- Skie
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "plantbgone"
	item_state = "plantbgone"
	volume = 250

/obj/item/weapon/reagent_containers/spray/plantbgone/New()
	..()
	reagents.add_reagent(PLANTBGONE, 250)

/obj/item/weapon/reagent_containers/spray/bugzapper
	name = "Bug Zapper"
	desc = "Kills those pesky bugs!"
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "plantbgone"
	item_state = "plantbgone"
	volume = 250

/obj/item/weapon/reagent_containers/spray/bugzapper/New()
	..()
	reagents.add_reagent(INSECTICIDE, 250)

//chemsprayer
/obj/item/weapon/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagent in a given area."
	icon = 'icons/obj/gun.dmi'
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 3
	w_class = W_CLASS_MEDIUM
	volume = 600
	origin_tech = Tc_COMBAT + "=3;" + Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=3;" + Tc_SYNDICATE + "=5"

	delay_spraying = FALSE

/obj/item/weapon/reagent_containers/spray/chemsprayer/make_puff(var/atom/target, var/mob/user)
	// Create the chemical puffs
	var/mix_color = mix_color_from_reagents(reagents.reagent_list)
	var/Sprays[3]

	for (var/i = 1, i <= 3, i++)
		if (src.reagents.total_volume < 1)
			break

		var/obj/effect/decal/chemical_puff/D = new /obj/effect/decal/chemical_puff(get_turf(src), mix_color, amount_per_transfer_from_this)
		reagents.trans_to(D, amount_per_transfer_from_this)
		Sprays[i] = D

	// Move the puffs towards the target
	var/direction = get_dir(src, target)
	var/turf/T = get_turf(target)
	var/turf/T1 = get_step(T, turn(direction, 90))
	var/turf/T2 = get_step(T, turn(direction, -90))
	var/list/the_targets = list(T, T1, T2)

	for (var/i = 1, i <= Sprays.len, i++)
		spawn()
			var/obj/effect/decal/chemical_puff/D = Sprays[i]
			if (!D)
				continue

			// Spreads the sprays a little bit
			var/turf/my_target = pick(the_targets)
			the_targets -= my_target

			for (var/j = 1, j <= rand(6, 8), j++)
				step_towards(D, my_target)
				D.react(iteration_delay = 0)
				sleep(2)

			qdel(D)

	playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)

/obj/item/weapon/reagent_containers/spray/noreact
	name = "stasis spray"
	icon_state = "cleaner_noreact"
	desc = "The label says 'Finally, a use for that pesky experimental bluespace technology for the whole house to enjoy!'\n\
	A disclaimer towards the bottom states <span class = 'warning'>Warning: Do not use around the house, or in proximity of dogs|children|clowns</span>"
	flags = OPENCONTAINER|FPRINT|NOREACT
	origin_tech = Tc_BLUESPACE + "=3;" + Tc_MATERIALS + "=5"
	amount_per_transfer_from_this = 25


/obj/item/weapon/reagent_containers/spray/noreact/make_puff(var/atom/target, var/mob/user)
	// Create the chemical puff
	var/transfer_amount = amount_per_transfer_from_this
	if (!can_transfer_an_APTFT() && !is_empty()) //If it doesn't contain enough reagents to fulfill its amount_per_transfer_from_this, but also isn't empty, it'll spray whatever it has left.
		transfer_amount = reagents.total_volume
	var/mix_color = mix_color_from_reagents(reagents.reagent_list)
	var/obj/effect/decal/chemical_puff/D = new /obj/effect/decal/chemical_puff(get_turf(src), mix_color, amount_per_transfer_from_this)
	D.flags |= NOREACT
	reagents.trans_to(D, transfer_amount, 1/3)


	// Move the puff toward the target
	spawn(0)
		for (var/i = 0, i < 6, i++)
			step_towards(D, target)
			if(i > 1)
				D.flags &= ~NOREACT
			D.react()
			sleep(3)

		qdel(D)

	playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
