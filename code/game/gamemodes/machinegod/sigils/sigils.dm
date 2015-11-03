/obj/effect/sigil
	name = "sigil"
	desc = "An odd circle."
	anchored = 1
	icon = 'icons/obj/clockwork/sigils.dmi'
	icon_state = "ritual"
	color = "#B39700"
	var/actcolor = ""
	var/visibility = 0
	unacidable = 1
	layer = TURF_LAYER

	var/dead = 0 // For cascade and whatnot.

	var/atom/movable/overlay/h_animation = null
	var/culttrigger = 0 //Can Ratvar cultists trigger this?

/obj/effect/sigil/attackby(var/obj/item/W, var/mob/user)
	if(istype(W, /obj/item/weapon/nullrod))
		visible_message("<span class='notice'>[user] waves \the [W] around over \the [src], completely negating it!")
		animate(src, alpha = 0, 5)
		dead = 1 //So it doesn't get activated before this spawn() is done.
		spawn(50)
			qdel(src)

/obj/effect/sigil/Crossed(var/atom/movable/AM)
	Bumped(AM)

/obj/effect/sigil/Bumped(var/mob/M)
	if(iscarbon(M) || issilicon(M))
		if(culttrigger && isclockcult(M))
			activation(M)
		else
			activation(M)

/obj/effect/sigil/cultify() //PURGE
	qdel(src)

/obj/effect/sigil/proc/activation(var/mob/M as mob) //What does it do when it's triggered?
	if(M.stat & DEAD)
		return 1

	if(dead)
		return 1

	var/nullblock = 0
	for(var/turf/TR in range(src,1))
		if(findNullRod(TR))
			nullblock = 1
			break

	if(nullblock)
		M << "<span class='warning'>The null rod negates the sigil's power.</span>"
		return 1

	var/turf/T = get_turf(M)
	T.turf_animation('icons/obj/clockwork/sigils.dmi', "pulse", 0, 0, 5, 'sound/machines/notify.ogg', actcolor)
	animate(src, color = actcolor, 5)
	spawn(5)
		animate(src, color = initial(color), 5)
