/obj/item/mounted/frame/light_fixture
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	flags = FPRINT
	var/fixture_type = "tube"
	mount_reqs = list("simfloor")

/obj/item/mounted/frame/light_fixture/check_buildon(var/atom/A, mob/user)
	if (isturf(A))
		for (var/obj/structure/window/W in A)
			if (isfullwindow(W))
				return 1
			else if (user.dir == opposite_dirs[W.dir]) // At least one border window can support us
				return 1
	else
		if (iswindow(A))
			if (isfullwindow(A))
				return 1
			else if (user.dir == opposite_dirs[A.dir])
				return 1

	return 0

/obj/item/mounted/frame/light_fixture/do_build(turf/on_wall, mob/user)
	to_chat(user, "You begin attaching [src] to \the [on_wall].")
	playsound(src, 'sound/machines/click.ogg', 75, 1)
	var/constrdir = user.dir
	var/constrloc = get_turf(user)
	if (!do_after(user, on_wall, 30))
		return
	var/obj/machinery/light_construct/newlight
	switch(fixture_type)
		if("bulb")
			newlight = new /obj/machinery/light_construct/small(constrloc)
		if("tube")
			newlight = new /obj/machinery/light_construct(constrloc)
		else
			newlight = new /obj/machinery/light_construct/small(constrloc)
	newlight.dir = constrdir
	newlight.fingerprints = src.fingerprints
	newlight.fingerprintshidden = src.fingerprintshidden
	newlight.fingerprintslast = src.fingerprintslast

	user.visible_message("[user] attaches \the [src] to \the [on_wall].", \
		"You attach \the [src] to \the [on_wall].")
	qdel(src)

/obj/item/mounted/frame/light_fixture/small
	name = "small light fixture frame"
	desc = "Used for building small lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-item"
	flags = FPRINT
	fixture_type = "bulb"
	sheets_refunded = 1
