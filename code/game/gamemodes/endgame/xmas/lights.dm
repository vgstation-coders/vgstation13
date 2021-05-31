// "How the hell do these lights WORK?"
// Well my man, it's simple.
// If you enable RGB+Mask in DM when viewing the lights state
// You will see that there's 4 lights, corresponding to the 4 channels of an RGBA image:
// R, G, B, A
// With the magic of colour matrices™, I can control these 4 channels to have a colour.
/obj/machinery/xmas_light
	name = "christmas lights"
	desc = "A bunch of lightbulbs in varying colours, attached to a wire."

	// TODO: hahahahaha
	icon = 'icons/obj/machines/xmas_lights.dmi'
	icon_state = "lights_big"

	anchored = TRUE

	power_channel = LIGHT
	idle_power_usage = 5
	active_power_usage = 10

	use_auto_lights = TRUE
	light_range_on = 2
	light_power_on = 2

	var/image/lights
	var/static/list/colors = list(
		list(5, 0, 0, 1),
		list(0, 5, 0, 1),
		list(0, 0, 5, 1),
		list(5, 5, 0, 1),
		list(0, 5, 5, 1),
		list(5, 0, 5, 1)
	)


/obj/machinery/xmas_light/New(loc, var/newdir)
	..()
	if(newdir)
		dir = newdir
	lights = image(icon, icon_state = "overlay_big", dir = dir)
	var/list/cl = list(0, 0, 0, 0)
	for (var/x = 1 to 4)
		cl = pick(colors) + cl

	lights.color = cl
	overlays += lights


/obj/machinery/xmas_light/power_change()
	..()
	update_icon()


/obj/machinery/xmas_light/update_icon()
	overlays.len = 0
	if (stat & (NOPOWER|BROKEN))
		return

	overlays += lights


/obj/machinery/xmas_light/update_dir()
	..()
	lights.dir = dir
	update_icon()
