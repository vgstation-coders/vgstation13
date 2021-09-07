/***********************Wall-mounted Lanterns************************/

//Pretty large snowflake overall because it's too different from lights to inherit them
/obj/item/mounted/frame/hanging_lantern_hook
	name = "wall-mounted lantern hook"
	desc = "Attach to wall to create a lantern hanging hook."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "hanginglantern-construct-frame"
	sheets_refunded = 1

/obj/item/mounted/frame/hanging_lantern_hook/do_build(turf/on_wall, mob/user)
	new /obj/structure/hanging_lantern/hook(get_turf(user), get_dir(user, on_wall), 1)
	qdel(src)

/obj/structure/hanging_lantern
	name = "wall-mounted lantern hook"
	desc = "Produces a steady, reliable and warm light in the absence of electricity or even cilivization."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "hanginglantern1"
	anchored = 1
	plane = ABOVE_HUMAN_PLANE
	layer = LIGHTBULB_LAYER
	var/tmp/flickering = 0 //SPOOK
	var/obj/item/device/flashlight/lantern/lantern = null
	var/start_with_lantern = /obj/item/device/flashlight/lantern/on
	var/busy = 0

/obj/structure/hanging_lantern/New(turf/T, var/build_dir)

	..()
	dir = build_dir

	if(start_with_lantern)
		lantern = new start_with_lantern(src)

	update()

/obj/structure/hanging_lantern/attack_hand(mob/user)

	if(lantern)
		user.visible_message("<span class='notice'>[user] takes \the [lantern] off of the \the [src].</span>", \
		"<span class='notice'>You take \the [lantern] off of the \the [src].</span>")
		playsound(src, 'sound/machines/click.ogg', 20, 1)
		lantern.forceMove(user.loc)
		lantern.add_fingerprint(user)
		user.put_in_hands(lantern)
		lantern = null
		update()

/obj/structure/hanging_lantern/examine(mob/user)
	..()
	if(lantern)
		to_chat(user, "There is a [lantern.name] hanging on the hook. [lantern.on ? "It is lit":"It is unlit"].")
	else
		to_chat(user, "This one isn't producing any light, most likely missing something important.")


/obj/structure/hanging_lantern/attackby(obj/item/weapon/W as obj, mob/user as mob)

	add_fingerprint(user)

	if(W.is_wrench(user) && !busy)
		if(lantern)
			user << "<span class='warning'>Remove \the [lantern] from \the [src] first.</span>"
			return
		busy = 1
		W.playtoolsound(src, 75)
		user.visible_message("<span class='warning'>[user] begins deconstructing \the [src].</span>", \
		"<span class='notice'>You begin deconstructing \the [src].</span>")
		if(do_after(user, src, 30))
			new /obj/item/mounted/frame/hanging_lantern_hook(get_turf(user))
			user.visible_message("<span class='warning'>[user] deconstructs \the [src].</span>", \
			"<span class='notice'>You deconstruct \the [src].</span>")
			busy = 0
			qdel(src)
		else
			busy = 0

	else if(istype(W, /obj/item/device/flashlight/lantern))
		if(lantern)
			user << "<span class='warning'>There already is \a [lantern.name] on \the [src].</span>"
			return 1
		if(user.drop_item(W, src))
			user.visible_message("<span class='notice'>[user] puts \a [W.name] on the \the [src].</span>", \
			"<span class='notice'>You put \a [W.name] on the \the [src].</span>")
			playsound(src, 'sound/machines/click.ogg', 20, 1)
			lantern = W
			update()
			return 1

/obj/structure/hanging_lantern/update_icon()

	if(lantern)
		icon_state = "hanginglantern[lantern.on]"
	else
		icon_state = "hanginglantern-construct"

/obj/structure/hanging_lantern/proc/flicker(var/duration = rand(20, 60))
	if(lantern.on && light_type == LIGHT_SOFT)
		light_type = LIGHT_SOFT_FLICKER
		set_light()
		spawn(duration)
			light_type = LIGHT_SOFT
			animate(light_obj)
			animate(shadow_obj)
			set_light()

/obj/structure/hanging_lantern/proc/update()
	update_icon()
	update_brightness()

/obj/structure/hanging_lantern/proc/update_brightness()
	if(lantern)
		light_range = lantern.light_range
		light_power = lantern.light_power
		light_color = lantern.light_color
	else
		light_range = 0
		light_power = 0
		light_color = 0

	set_light(light_range, light_power, light_color)

/obj/structure/hanging_lantern/proc/toggle_lantern()
	if(lantern)
		lantern.on = !lantern.on
		lantern.update_brightness()
	update()

/obj/structure/hanging_lantern/verb/toggle_lantern_verb()
	set name = "Toggle Mounted Lantern"
	set desc = "Toggle the lantern mounted on a nearby lantern hook."
	set category = "Object"
	set src in view(1)

	if(!lantern)
		return 0
	if(!isliving(usr))
		return 0
	if(!usr.dexterity_check())
		to_chat(usr, "<span class='warning>You don't have the dexterity to do this!</span>")
		return 0

	toggle_lantern()
	usr.visible_message("<span class='notice'>[usr] toggles \the [lantern] hanging on \the [src] [lantern.on ? "on":"off"].</span>", \
						"<span class='notice'>You toggle \the [lantern] hanging on \the [src] [lantern.on ? "on":"off"].</span>")

/obj/structure/hanging_lantern/spook(mob/dead/observer/ghost)
	if(..(ghost, TRUE))
		flicker()

/obj/structure/hanging_lantern/attack_ghost(var/mob/user)
	if(!can_spook())
		return
	add_hiddenprint(user)
	flicker(1)
	investigation_log(I_GHOST, "|| was made to flicker by [key_name(user)][user.locked_to ? ", who was haunting [user.locked_to]" : ""]")

/obj/structure/hanging_lantern/Destroy()

	if(lantern)
		lantern.forceMove(get_turf(src))
		lantern = null

	..()

/obj/structure/hanging_lantern/hook

	icon_state = "hanginglantern-construct"
	start_with_lantern = 0

/obj/structure/hanging_lantern/dim
	start_with_lantern = /obj/item/device/flashlight/lantern/on/dim
