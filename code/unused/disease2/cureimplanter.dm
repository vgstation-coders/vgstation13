/obj/item/weapon/cureimplanter
	name = "Hypospray injector"
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter1"
	var/datum/disease2/resistance/resistance = null
	var/works = 0
	var/datum/disease2/disease/virus2 = null
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL


/obj/item/weapon/cureimplanter/attack(mob/target as mob, mob/user as mob)
	if(ismob(target))
		for(var/mob/O in viewers(world.view, user))
			if (target != user)
				O.show_message(text("<span class='danger'>[] is trying to inject [] with [src.name]!</span>", user, target), 1)
			else
				O.show_message("<span class='danger'>[user] is trying to inject themselves with [src.name]!</span>", 1)
		if(!do_mob(user, target,60)) return


		for(var/mob/O in viewers(world.view, user))
			if (target != user)
				O.show_message(text("<span class='warning'>[] injects [] with [src.name]!</span>", user, target), 1)
			else
				O.show_message("<span class='warning'>[user] injects themself with [src.name]!</span>", 1)


		var/mob/living/carbon/M = target

		if(works == 0 && prob(25))
			M.resistances2 += resistance
			if(M.virus2)
				M.virus2.cure_added(resistance)
		else if(works == 1)
			M.adjustToxLoss(rand(20,50))
		else if(works == 2)
			M.adjustToxLoss(rand(50,100))
		else if(works == 3)
			infect_virus2(M,virus2,1)
