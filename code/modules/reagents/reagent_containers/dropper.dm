/obj/item/reagent_containers/dropper
	name = "dropper"
	desc = "A dropper. Holds up to 5 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1, 2, 3, 4, 5)
	volume = 5
	container_type = TRANSPARENT

/obj/item/reagent_containers/dropper/afterattack(obj/target, mob/user , proximity)
	if(!proximity)
		return
	if(!target.reagents)
		return

	if(reagents.total_volume > 0)
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='notice'>[target] is full.</span>")
			return

		if(!target.is_injectable())
			to_chat(user, "<span class='warning'>You cannot directly fill [target]!</span>")
			return

		var/trans = 0
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)

		if(ismob(target))
			if(ishuman(target))
				var/mob/living/carbon/human/victim = target

				var/obj/item/safe_thing = null
				if(victim.wear_mask)
					if(victim.wear_mask.flags_cover & MASKCOVERSEYES)
						safe_thing = victim.wear_mask
				if(victim.head)
					if(victim.head.flags_cover & MASKCOVERSEYES)
						safe_thing = victim.head
				if(victim.glasses)
					if(!safe_thing)
						safe_thing = victim.glasses

				if(safe_thing)
					if(!safe_thing.reagents)
						safe_thing.create_reagents(100)

					reagents.reaction(safe_thing, TOUCH, fraction)
					trans = reagents.trans_to(safe_thing, amount_per_transfer_from_this)

					target.visible_message("<span class='danger'>[user] tries to squirt something into [target]'s eyes, but fails!</span>", \
											"<span class='userdanger'>[user] tries to squirt something into [target]'s eyes, but fails!</span>")

					to_chat(user, "<span class='notice'>You transfer [trans] unit\s of the solution.</span>")
					update_icon()
					return
			else if(isalien(target)) //hiss-hiss has no eyes!
				to_chat(target, "<span class='danger'>[target] does not seem to have any eyes!</span>")
				return

			target.visible_message("<span class='danger'>[user] squirts something into [target]'s eyes!</span>", \
									"<span class='userdanger'>[user] squirts something into [target]'s eyes!</span>")

			reagents.reaction(target, TOUCH, fraction)
			var/mob/M = target
			var/R
			if(reagents)
				for(var/datum/reagent/A in src.reagents.reagent_list)
					R += A.id + " ("
					R += num2text(A.volume) + "),"
			add_logs(user, M, "squirted", R)

		trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] unit\s of the solution.</span>")
		update_icon()

	else

		if(!target.is_drawable(FALSE)) //No drawing from mobs here
			to_chat(user, "<span class='notice'>You cannot directly remove reagents from [target].</span>")
			return

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty!</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)

		to_chat(user, "<span class='notice'>You fill [src] with [trans] unit\s of the solution.</span>")

		update_icon()

/obj/item/reagent_containers/dropper/update_icon()
	cut_overlays()
	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "dropper")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)
