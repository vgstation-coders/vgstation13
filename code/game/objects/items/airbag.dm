/obj/item/airbag
	name = "personal airbag"
	desc = "One-use protection from high-speed collisions."
	icon = 'icons/obj/items.dmi'
	icon_state = "airbag"
	item_state = "syringe_kit"
	w_class = W_CLASS_SMALL
	slot_flags = SLOT_BELT

/obj/item/airbag/New(atom/A, var/deployed)
	..(A)
	if(deployed)
		icon = 'icons/obj/objects.dmi'
		icon_state = "airbag_deployed"
		anchored = 1

/obj/item/airbag/proc/deploy(mob/user)
	var/obj/item/airbag/deployed_bag = new(get_turf(src), TRUE)
	if(user)
		to_chat(user, "<span class='notice'>Your [src.name] deploys!</span>")
		user.forceMove(deployed_bag)
	playsound(deployed_bag, 'sound/effects/bamfgas.ogg', 100, 1)
	qdel(src)

/obj/item/airbag/relaymove(var/mob/user, direction)
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(src))
	qdel(src)
