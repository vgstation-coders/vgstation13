/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_closed"
	anchored = 1
	density = FALSE
	var/obj/item/weapon/extinguisher/has_extinguisher = new/obj/item/weapon/extinguisher
	var/opened = 0

/obj/structure/extinguisher_cabinet/empty
	has_extinguisher = null
	opened = 1

/obj/structure/extinguisher_cabinet/New()
	..()
	update_icon()

/obj/structure/extinguisher_cabinet/attackby(obj/item/O, mob/user)
	if(isrobot(user) || isalien(user))
		return
	if(istype(O, /obj/item/weapon/extinguisher))
		if(!has_extinguisher && opened)
			if(user.drop_item(O, src))
				has_extinguisher = O
				to_chat(user, "<span class='notice'>You place [O] in [src].</span>")
		else
			opened = !opened
	else if(iswelder(O))
		weld(O, user)
	else
		opened = !opened
	update_icon()


/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	if(isrobot(user) || isalien(user))
		return
	if(has_extinguisher)
		user.put_in_hands(has_extinguisher)
		to_chat(user, "<span class='notice'>You take [has_extinguisher] from [src].</span>")
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(has_extinguisher)
		has_extinguisher.forceMove(loc)
		to_chat(user, "<span class='notice'>You telekinetically remove [has_extinguisher] from [src].</span>")
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_paw(mob/user)
	attack_hand(user)
	return


/obj/structure/extinguisher_cabinet/update_icon()
	if(!opened)
		icon_state = "extinguisher_closed"
		return
	if(has_extinguisher)
		if(istype(has_extinguisher, /obj/item/weapon/extinguisher/mini))
			icon_state = "extinguisher_mini"
		else
			icon_state = "extinguisher_full"
	else
		icon_state = "extinguisher_empty"


/obj/structure/extinguisher_cabinet/proc/weld(var/obj/item/weapon/weldingtool/WE, var/mob/user)
	if(!istype(WE))
		return
	if(has_extinguisher)
		to_chat(user, "<span class='notice'>There is still an extinguisher inside.</span>")
		return
	if(!opened)
		to_chat(user, "<span class='notice'>\The [src] needs to be open before you can dismantle it.</span>")
		return
	if(!WE.remove_fuel(1, user))
		return
	to_chat(user, "<span class='notice'>You cut \the [src] off of the wall.</span>")
	qdel(src)
