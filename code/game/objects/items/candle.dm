/obj/item/candle
	name = "red candle"
	desc = "A candle made out of wax, used for moody lighting and solar flares"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = W_CLASS_TINY
	heat_production = 1000
	source_temperature = TEMPERATURE_FLAME
	light_color = LIGHT_COLOR_FIRE

	var/wax = 200
	var/lit = 0
	var/flavor_text

/obj/item/candle/update_icon()
	var/i
	if(wax > 150)
		i = 1
	else if(wax > 80)
		i = 2
	else i = 3
	icon_state = "candle[i][lit ? "_lit" : ""]"

/obj/item/candle/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(W.is_hot() || W.sharpness_flags & (HOT_EDGE))
		light("<span class='notice'>[user] lights [src] with [W].</span>")

/obj/item/candle/proc/light(var/flavor_text = "<span class='notice'>[usr] lights [src].</span>", var/quiet = 0)
	if(!src.lit)
		src.lit = 1
		if(!quiet)
			visible_message(flavor_text)
		set_light(CANDLE_LUM)
		processing_objects.Add(src)

/obj/item/candle/process()
	if(!lit)
		return
	wax--
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	if(env.molar_density("oxygen") < (5 / CELL_VOLUME))
		src.lit = 0
		set_light(0)
		processing_objects.Remove(src)
		update_icon()
		return
	if(!wax)
		new/obj/item/trash/candle(src.loc)
		if(istype(src.loc, /mob))
			src.dropped()
		qdel(src)
		return
	update_icon()
	if(istype(T)) //Start a fire if possible
		T.hotspot_expose(source_temperature, 5, surfaces = 0)

/obj/item/candle/attack_self(mob/user as mob)
	if(lit)
		lit = 0
		update_icon()
		set_light(0)

/obj/item/candle/is_hot()
	if(lit)
		return source_temperature
	return 0

/obj/item/weapon/match/is_hot()
	if(lit)
		return source_temperature
	return 0
