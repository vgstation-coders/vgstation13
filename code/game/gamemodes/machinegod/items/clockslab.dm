/obj/item/weapon/clockslab
	name = "clockwork slab"
	desc = "An bizarre, ticking, glowing device rapidly displaying information."
	icon = 'icons/obj/clockwork/components.dmi'
	icon_state ="slab"
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT

	var/datum/html_interface/clockslab/slab/interface

/obj/item/weapon/clockslab/New()
	. = ..()


/obj/item/weapon/clockslab/examine(mob/user)
	..()
	if(isclockcult(user))
		user << "The word of Ratvar, The One Who Judges, The Clockwork Justiciar. Contains the details of all the powers his followers can possibly call upon. Without the Justiciar's presence, they're all weakened, however."
	else
		user << "...and not a word of it makes any sense to you."

/*
/obj/item/weapon/clockslab/attack_self(mob/living/user as mob)
	usr = user
	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(isclockcult(user))
		//interface mumbo jumbo
*/

/obj/item/weapon/clockslab/Topic(var/href, var/list/href_list)
	. = ..()
	if(.)
		return

	if(!isclockcult(usr))
		usr << "You don't even have any idea what any of this means, better not touch it..."
		return 1

