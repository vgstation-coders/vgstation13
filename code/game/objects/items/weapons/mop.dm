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
	flags = FPRINT | TABLEPASS
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked", "slapped", "whipped")

/obj/item/weapon/mop/New(loc)
	. = ..(loc)
	create_reagents(5)

/obj/effect/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/mop))
		return
	..()

/obj/item/weapon/mop/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not Adjacent
		return

	if(reagents.total_volume < 1)
		user << "<span class='notice'>Your mop is dry!</span>"
		return

	var/surface = target

	if(istype(target, /obj/effect/rune) || istype(target, /obj/effect/decal/cleanable) || istype(target, /obj/effect/overlay))
		surface = target.loc

	target = null

	/* lack proper checks of protection at mobs
	if(isliving(surface))
		user.visible_message("<span class='danger'>[user] covers [surface] with the mop's contents</span>")
		reagents.reaction(surface, TOUCH, 10) //I hope you like my polyacid cleaner mix
		reagents.clear_reagents()
	*/

	if(istype(surface, /turf/simulated))
		user.visible_message("<span class='warning'>[user] begins to clean \the [surface] with [src].</span>")

		if(do_after(user, 30))
			clean(surface)
			user << "<span class='notice'>You have finished mopping!</span>"

/obj/item/weapon/mop/proc/clean(atom/surface)
	surface.wipe(src)

/atom/proc/wipe(atom/source)
	return 0

/turf/simulated/wipe(atom/source)
	if(source.reagents.has_reagent("water", 1) || source.reagents.has_reagent("holywater", 1))
		clean_blood()

		for(var/obj/effect/O in src)
			if(istype(O, /obj/effect/rune) || istype(O, /obj/effect/decal/cleanable) || istype(O, /obj/effect/overlay))
				qdel(O)

	source.reagents.reaction(src, TOUCH, 10)
	return source.reagents.remove_any(1)
