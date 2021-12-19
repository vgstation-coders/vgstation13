/obj/item/weapon/reagent_containers/succorphant
	name = "succorphant"
	desc = "Colloquially referred to as 'space leech'. These parasitic creatures have a surprisingly malleable diet. Less malleable is the source of that diet: humanoid veins."
	icon = ''
	icon_state = ""
	w_class = W_CLASS_TINY
	amount_per_transfer_from_this = 0
	possible_transfer_amounts = list()
	volume = 100
	succPow = 1
	var/mob/living/carbon/human/host = null
	var/alive = TRUE
	var/fat = FALSE

/obj/item/weapon/reagent_containers/succorphant/angler_effect(obj/item/weapon/bait/baitUsed)
	succPow = round(1, baitUsed.catchAttraction/2)	//He's HUNGRY
	volume += (baitUsed.catchPower + baitUsed.catchSizeAdd)*baitUsed.catchSizeMult	//200-250u total should be the norm.

/obj/item/weapon/reagent_containers/succorphant/attack_self(mob/user)
	to_chat(user, "<span class ='notice'>You attempt to attach \the [src] to your body.</span>")
	if(alive && !fat)
		attachSucc(user)

/obj/item/weapon/reagent_containers/succorphant/throw_impact(atom/hit_atom)
	..()
	if(alive && !fat)
		if(isliving(hit_atom))
			attachSucc(hit_atom)

/obj/item/weapon/reagent_containers/succorphant/attackby(obj/item/W as obj, mob/user as mob)
	if(alive)	//This might need to be made post-attack
		if(istype(W, /obj/item/weapon/reagent_containers/syringe))
			to_chat(user, "<span class ='notice'>\The [src]'s body tenses and shivers from pain before finally going limp!</span>")
			deadLeech()

/obj/item/weapon/reagent_containers/succorphant/proc/attachSucc(var/mob/living/sTarget)
	if(canSucc(sTarget))
		host = sTarget
		forceMove(host)
		host.overlays += image(icon dmi, icon_state)	//when you make the DMI, fill it in
		processing_objects.Add(src)

/obj/item/weapon/reagent_containers/succorphant/proc/canSucc(mob/sTarget)
	if(!ishuman(sTarget))
		to_chat(succH, "<span class ='notice'>\The [src] isn't interested in you.</span>")
		return FALSE
	var/mob/living/carbon/human/succH = sTarget
	if(istype(succH.wear_suit, /obj/item/clothing/suit/space)
		return FALSE
	if(succH.species.anatomy_flags & NO_BLOOD)
		to_chat(succH, "<span class ='notice'>\The [src] briefly attaches itself to you but quickly realizes you can't satisfy its appetite.</span>")
		return FALSE
	return TRUE

/obj/item/weapon/reagent_containers/succorphant/process()
	if(!host)
		processing_objects.Remove(src)
		return
	if(!host.reagents)
		host.take_blood(src, succPow)
	else
		host.reagents.trans_to(src, succPow)
	if(reagents.has_any_reagents(list(SALTWATER, SODIUMCHLORIDE)))
		deadLeech()
	if(reagents.is_full() && !fat)
		becomeFat()

/obj/item/weapon/reagent_containers/succorphant/proc/becomeFat()
	fat = TRUE
	icon_state = "succorphant_fat"
	dropFromHost()
	visible_message(src, "<span class ='notice'>\The [src], looking satisfied, releases its grip and falls from its host</span>")

/obj/item/weapon/reagent_containers/succorphant/attempt_heating(atom/A, mob/user)
	if(A.is_hot())
		to_chat(user, "<span class ='notice'>\The [src] let's out a tiny scream and shrivels up!</span>")
		deadLeech()

/obj/item/weapon/reagent_containers/succorphant/proc/deadLeech()
	alive = FALSE
	if(!fat)
		icon_state = succorphant_dead
	else
		icon_state = succorphant_fat_dead
	if(host)
		dropFromHost()

/obj/item/weapon/reagent_containers/succorphant/proc/dropFromHost()
	var/turf/T = get_turf(src)
	forceMove(T)
	host.overlays -= image(icon dmi, icon_state)
	host = null
	processing_objects.Remove(src)
