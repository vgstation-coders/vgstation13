/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	hitsound = "sound/weapons/whip.ogg"
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 3
	w_class = 3.0
	var/mopquality = 5 //governs how many reagents it can hold
	flags = FPRINT | TABLEPASS
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked", "slapped", "whipped")

/obj/item/weapon/mop/New()
	. = ..()
	create_reagents(mopquality)

/obj/item/weapon/mop/proc/clean(turf/simulated/A as turf)
	reagents.reaction(A,1,10) //Mops magically make chems ten times more efficient than usual, aka equivalent of 50 units of whatever you're using
	A.clean_blood()
	for(var/obj/effect/O in A)
		if(istype(O,/obj/effect/rune) || istype(O,/obj/effect/decal/cleanable) || istype(O,/obj/effect/overlay))
			qdel(O)

/obj/effect/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/mop))
		return
	..()

/obj/item/weapon/mop/afterattack(atom/A, mob/user as mob)
	if(!user.Adjacent(A))
		return

	if(istype(A, /mob/living))
		if(!(reagents.total_volume < 1)) //Slap slap slap
			A.visible_message("<span class='danger'>[user] covers [A] in the [src]'s contents</span>")
			reagents.reaction(A,1,10) //I hope you like my polyacid cleaner mix
			reagents.clear_reagents()

	if(istype(A, /turf/simulated) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		if(reagents.total_volume < 1)
			user << "<span class='notice'>Your [src] is dry!</span>"
			return
		user.visible_message("<span class='warning'>[user] begins to clean \the [get_turf(A)].</span>")
		if(do_after(user, 30))
			if(A)
				clean(get_turf(A))
				reagents.remove_any(1) //Might be a tad wonky with "special mop mixes", but fuck it
				user << "<span class='notice'>You have finished scrubbing \the [get_turf(A)]!</span>"

/obj/item/weapon/mop/rag
	name = "rag" //changed to "rag" from "damp rag" - Hinaichigo
	desc = "For cleaning up messes, you suppose."
	force = 1.0
	throwforce = 2.0
	throw_range = 5
	w_class = 1
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	mopquality = 3

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is stuffing the [src.name] down \his throat! It looks like \he's trying to commit suicide.</b>"
		return (OXYLOSS)

/obj/item/weapon/mop/rag/attack(atom/target as obj|turf|area, mob/user as mob , flag)
	if(ismob(target) && target.reagents && reagents.total_volume)
		user.visible_message("\red \The [target] has been smothered with \the [src] by \the [user]!", "\red You smother \the [target] with \the [src]!", "You hear some struggling and muffled cries of surprise")
		reagents.reaction(target, TOUCH)
		spawn(5) src.reagents.clear_reagents()
		return
	else
		..()

/obj/item/weapon/mop/rag/examine()
	if (!usr)
		return
	usr << "That's \a [src]."
	usr << desc
	return

/obj/item/weapon/mop/makeshift
	desc = "He has no style, he has no grace, this janitor is a fucking disgrace."
	name = "makeshift mop"
	icon_state = "mop_makeshift"
	mopquality = 3