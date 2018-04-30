/**
	Telescope

	Functions much like binoculars, but must be mounted to use.
	While using, can see much further away, but should you move, you're no longer 'looking' through it.
	Can be used to find details about the star the station is in orbit of.
*/

/obj/structure/telescope
	name = "telescope"
	desc = "Used for bringing things far away up close, at least visually."
	icon = 'icons/obj/objects.dmi'
	icon_state = "telescope"
	anchored = 1
	plane = ABOVE_HUMAN_PLANE
	var/event_key
	var/mob/living/viewer //Who is looking in this?

/obj/structure/telescope/Destroy()
	if(viewer && event_key)
		viewer.on_moved.Remove(event_key)
		viewer = null
	event_key = null
	..()

/obj/structure/telescope/attack_hand(mob/user)
	..()
	if(event_key)
		to_chat(user, "<span class = 'notice'>Somebody is already using that.</span>")
		return
	if(!(user.dir & dir))
		to_chat(user, "<span class = 'notice'>You're looking in the wrong end!</span>")
		return
	viewer = user
	event_key = user.on_moved.Add(src, "mob_moved")
	user.visible_message("<span class = 'notice'>\The [user] looks through \the [src].</span>")
	if(user && user.client)
		var/client/C = user.client
		C.changeView(C.view + 7)

/obj/structure/telescope/attackby(obj/item/W, mob/user)
	..()
	if(event_key)
		to_chat(user, "<span class = 'notice'>Somebody is using that!</span>")
		return
	if(iswrench(W))
		playsound(src, 'sound/items/Ratchet.ogg', 100, 1)
		if(do_after(user, src, 50))
			visible_message("<span class = 'warning'>\The [user] deconstructs \the [src].")
			new /obj/item/telescope(src.loc)
			qdel(src)


/obj/structure/telescope/verb/rotate_cw()
	set name = "Rotate (Clockwise)"
	set category = "Object"
	set src in oview(1)

	src.dir = turn(src.dir, -90)
	evaluate_sun()
	return 1

/obj/structure/telescope/verb/rotate_ccw()
	set name = "Rotate (Counter-Clockwise)"
	set category = "Object"
	set src in oview(1)

	src.dir = turn(src.dir, 90)
	evaluate_sun()
	return 1

/obj/structure/telescope/proc/mob_moved(var/list/args, var/mob/holder)
	holder.on_moved.Remove(event_key)
	viewer = null
	event_key = null
	if(holder && holder.client)
		var/client/C = holder.client
		C.changeView(C.view - 7)

/obj/structure/telescope/proc/evaluate_sun()
	var/time = world.time
	var/angle = ((sun.rotationRate * time / 100) % 360 + 360) % 360
	if(!(viewer && is_in_sun(get_turf(src), 14) && angle2dir(angle) & dir)) //Are we in the sun, and are we facing it.
		return
	to_chat(viewer, "<span class = 'notice'>You can see the star '[sun.name]'!</span>")
	switch(sun.heat)
		if(0 to 249)
			to_chat(viewer, "<span class = 'notice'>Something looks wrong with it.</span>")
		if(250 to 500)
			to_chat(viewer, "<span class = 'notice'>It looks rather dim.</span>")
		if(501 to 1000)
			to_chat(viewer, "<span class = 'notice'>It looks rather bright.</span>")
		if(1001 to 2000)
			to_chat(viewer, "<span class = 'notice'>It looks really bright!</span>")
		if(2000 to INFINITY)
			to_chat(viewer, "<span class = 'warning'>It looks almost dangerously bright.</span>")

	switch(sun.severity)
		if(0 to 9)
			to_chat(viewer, "<span class = 'notice'>It seems stable. </span><span class = 'warning'>Too stable.</span>")
		if(10 to 30)
			to_chat(viewer, "<span class = 'notice'>Everything looks peaceful on the surface.</span>")
		if(31 to 50)
			to_chat(viewer, "<span class = 'warning'>It seems to flicker every so often.</span>")
		if(51 to 75)
			to_chat(viewer, "<span class = 'warning'>You can see the star jetissoning material from itself.</span>")
		if(76 to INFINITY)
			to_chat(viewer, "<span class = 'warning'>This monster in the sky seems to be actively trying to destroy itself and its surroundings.</span>")

	if(viewer.has_eyes() && prob(sun.severity))
		to_chat(viewer, "<span class = 'warning'>Your eyes burn!</span>")
		if(!ishuman(viewer))
			return
		var/mob/living/carbon/human/H = viewer
		var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
		E.damage += rand(1,5)+sun.severity/50

/obj/item/telescope
	name = "telescope"
	desc = "A tripod-mounted telescope, not mounted on the tripod."
	icon = 'icons/obj/objects.dmi'
	icon_state = "telescope_frame"
	w_class = W_CLASS_LARGE
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND
	anchored = 1 //No pull, only carry

/obj/item/telescope/attackby(obj/item/W, mob/user)
	..()
	if(iswrench(W) && isturf(loc))
		visible_message("<span class = 'notice'>\the [user] begins to construct \the [src].</span>")
		playsound(src, 'sound/items/Ratchet.ogg', 100, 1)
		if(do_after(user, src, 50))
			new /obj/structure/telescope(src.loc)
			qdel(src)