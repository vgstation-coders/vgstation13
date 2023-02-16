//////Kitchen Spike

/obj/structure/kitchenspike
	name = "meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals."
	density = 1
	anchored = 1

	var/mob/living/occupant = null

	var/list/allowed_mobs = list(
		/mob/living/carbon/monkey/diona = "spikebloodynymph",
		/mob/living/carbon/monkey = "spikebloody",
		/mob/living/carbon/alien = "spikebloodygreen",
		/mob/living/simple_animal/hostile/alien = "spikebloodygreen"
		) //Associated with icon states

/obj/structure/kitchenspike/attack_paw(mob/user as mob)
	return src.attack_hand(usr)

/obj/structure/kitchenspike/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (W.is_wrench(user))
		if(occupant)
			to_chat(user, "<span class='warning'>You can't disassemble [src] with meat and gore all over it.</span>")
			return
		var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(get_turf(src))
		M.amount = 2
		qdel(src)
		return

	if(istype(W,/obj/item/weapon/grab))
		return handleGrab(W,user)

/obj/structure/kitchenspike/proc/handleGrab(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(!istype(G))
		return

	var/mob/living/our_mob = G.affecting
	if(!istype(our_mob))
		return

	if(occupant)
		to_chat(user, "<span class='warning'>[occupant.name] is already hanging from \the [src], finish collecting its meat first!</span>")
		return

	for(var/T in allowed_mobs)
		if(istype(our_mob, T))
			if(our_mob.abiotic())
				to_chat(user, "<span class='warning'>Subject may not have abiotic items on.</span>")
				return
			else
				src.occupant = our_mob

				if(allowed_mobs[T])
					src.icon_state = allowed_mobs[T]
				else
					src.icon_state = "spikebloody"

				user.visible_message("<span class='warning'>[user] has forced [our_mob] onto the spike, killing it instantly!</span>")

				add_attacklogs(user, our_mob, "meatspiked", admin_warn = FALSE)

				our_mob.death(0)
				our_mob.ghostize()

				our_mob.forceMove(src)
				if(iscarbon(our_mob))
					var/mob/living/carbon/C = our_mob
					if(C.stomach_contents && C.stomach_contents.len)
						C.drop_stomach_contents()
						user.visible_message("<span class='warning'>\The [C]'s stomach contents drop to the ground!</span>")

				occupant.meat_amount++

				qdel(G)
				return

/obj/structure/kitchenspike/attack_hand(mob/user)
	if(..())
		return

	if(occupant)
		if(occupant.meat_amount > occupant.meat_taken)
			if(arcanetampered || occupant.arcanetampered)
				new /obj/item/weapon/reagent_containers/food/snacks/tofu(get_turf(src))
				occupant.meat_taken++
			else
				occupant.drop_meat(get_turf(src))

			if(occupant.meat_amount > occupant.meat_taken)
				to_chat(user, "You remove some meat from \the [occupant].")
				return
			else
				to_chat(user, "You remove the last piece of meat from \the [src]!")

	clean()

/obj/structure/kitchenspike/proc/clean()
	icon_state = initial(icon_state)
	if(occupant)
		QDEL_NULL(occupant)

/obj/structure/kitchenspike/suicide_act(var/mob/living/user)
	user.forceMove(get_turf(src))
	to_chat(viewers(user), "<span class='danger'>[user] is placing \himself onto the [src]! It looks like \he's trying to commit suicide.</span>")
	while(user.meat_taken < user.meat_amount)
		user.drop_meat(get_turf(src))
	user.gib()
	return(SUICIDE_ACT_CUSTOM)
