/obj/item/weapon/clockslab
	name = "clockwork slab"
	desc = "An bizarre, ticking, glowing device rapidly displaying information."
	icon = 'icons/obj/clockwork/slab.dmi'
	icon_state ="slab"
	throw_speed = 1
	throw_range = 5
	w_class = 2
	flags = FPRINT

	var/datum/html_interface/clockslab/slab/interface

	var/nextcomponent 		= CLOCKSLAB_TICKS_UNTARGETED	//How much process() calls left before we spit out a new component,
	var/target_component								//Which component we're targeting to make, slower but targeted.
	var/list/components = list()

/obj/item/weapon/clockslab/New()
	. = ..()

	processing_objects += src
	components = CLOCK_COMP_IDS.Copy()
	for(var/a in components)	//Make it an assoc list with the assoc value being 0s
		components[a] = 0

/obj/item/weapon/clockslab/Destroy()
	. = ..()

	processing_objects -= src

/obj/item/weapon/clockslab/process()
	var/mob/living/carbon/M = get(src, /mob/living/carbon)
	if(!istype(M))	//Not being held by a valid mob.
		return

	var/list/L = recursive_type_check(M, type)
	if(L.len > 1)	//The user is trying to CHEAT by having 2 slabs.
		return

	if(!isclockcult(M))	//The mob doesn't obey Ratvar.
		return

	if(nextcomponent++ <= 0)	//Done.
		create_component(target_component)

//Will spawn a component, random if no ID specified, mob is for overflow handling.
/obj/item/weapon/clockslab/proc/create_component(var/id = pick(CLOCK_COMP_IDS), var/mob/living/carbon/M)
	var/i = 0	//Get the total amount of components.
	for(var/c in components)
		i += components[c]

	if(i >= CLOCKSLAB_CAPACITY)	//No room, time to handle overflow.
		var/obj/item/weapon/clock_component/C = getFromPool(get_clockcult_comp_by_id(id))
		if(!M)	//No mob, this shouldn't happen but just in case let's drop it on the floor.
			if(!loc)	//Uuuuuuh... this is getting weirder by the minute.
				qdel(src)
				returnToPool(C)
				return

			getFromPool(get_clockcult_comp_by_id(id))

		//Try to insert it into a storage obj on the mob.
		for(var/obj/item/weapon/storage/S in recursive_contents_check(M, /obj/item/weapon/storage))
			if(S.can_be_inserted(C, 1))
				S.handle_item_insertion(C, 1))
				break

		if(!C.loc)	//We didn't manage to insert it somewhere.
			C.forceMove(M.loc)

	else	//We have room.
		components[id]++

/obj/item/weapon/clockslab/examine(mob/user)
	..()
	if(isclockcult(user))
		user << "The word of Ratvar, The One Who Judges, The Clockwork Justiciar. Contains the details of all the powers his followers can possibly call upon. Without the Justiciar's presence, they're all weakened, however."
	else
		user << "...and not a word of it makes any sense to you."

/obj/item/weapon/clockslab/attack_self(mob/living/user as mob)
	. = ..()
	if(.)
		return

	if(iscultist(user))	//Cultists be scared to shit.
		user << "<span class='sinister'>You reek of blood. You’ve got a lot of nerve to even look at that slab.</span>"
		return 1

	//INSERT SMART UI CALLING CODE HERE.

/obj/item/weapon/clockslab/Topic(var/href, var/list/href_list)
	. = ..()
	if(.)
		return

	if(!isclockcult(usr))
		usr << "<span class='warning'>You don't even have any idea what any of this means, better not touch it...</span>"
		return 1

	//Target a component for production, note that this resets the timer.
	if(href_list["target"])
		if(!(href_list["target"] in CLOCK_COMP_IDS + "null"))
			return 1	//Go away href exploiters.

		if(target == "null")
			target = null

		else
			target = href_list["target"]

		next_component = target ? CLOCKSLAB_TICKS_TARGETED : CLOCKSLAB_TICKS_UNTARGETED
		return 1

/obj/item/weapon/clockslab/proc/invoke_power(var/mob/user)
