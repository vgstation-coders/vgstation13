/obj/item/candle
	name = "red candle"
	desc = "A candle made out of wax, used for moody lighting and solar flares."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle"
	item_state = "candle1"
	w_class = W_CLASS_TINY
	heat_production = 1000
	source_temperature = TEMPERATURE_FLAME
	light_color = LIGHT_COLOR_FIRE
	light_type = LIGHT_SOFT_FLICKER

	var/wax = 200
	var/lit = 0
	var/flavor_text
	var/trashtype = /obj/item/trash/candle

/obj/item/candle/update_icon()
	overlays.len = 0
	var/i
	if(wax > 150)
		i = 1
	else if(wax > 80)
		i = 2
	else i = 3
	icon_state = "candle[i]"
	if (lit)
		var/image/I = image(icon,src,"[icon_state]_lit")
		I.blend_mode = BLEND_ADD
		if (isturf(loc))
			I.plane = ABOVE_LIGHTING_PLANE
		else
			I.plane = ABOVE_HUD_PLANE // inventory
		overlays += I

/obj/item/candle/dropped()
	..()
	update_icon()

/obj/item/candle/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	if (lit && source_temperature)
		if (istype(W, /obj/item/candle))
			var/obj/item/candle/C = W
			C.light("<span class='notice'>[user] lights [C] with [src].</span>")
		else if (istype(W,/obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/fag = W
			fag.light("<span class='notice'>[user] lights \the [fag] using \the [src]'s flame.</span>")
	if(source_temperature && (W.is_hot() || W.sharpness_flags & (HOT_EDGE)))
		light("<span class='notice'>[user] lights [src] with [W].</span>")

/obj/item/candle/proc/light(var/flavor_text = "<span class='notice'>[usr] lights [src].</span>", var/quiet = 0)
	if(!lit)
		lit = 1
		if(!quiet)
			visible_message(flavor_text)
		set_light(CANDLE_LUM)
		processing_objects.Add(src)
		update_icon()

/obj/item/candle/process()
	if(!lit)
		return
	wax--
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	if(env.molar_density(GAS_OXYGEN) < (5 / CELL_VOLUME))
		src.lit = 0
		kill_light()
		processing_objects.Remove(src)
		update_icon()
		return
	if(!wax)
		new trashtype(src.loc)
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
		kill_light()

/obj/item/candle/is_hot()
	if(lit)
		return source_temperature
	return 0

/obj/item/weapon/match/is_hot()
	if(lit)
		return source_temperature
	return 0

/obj/item/candle/Crossed(var/obj/Proj)
	if(isbeam(Proj))
		var/obj/item/projectile/beam/P = Proj//could be a laser beam or an emitter beam, both feature the get_damage() proc, for now...
		if(P.get_damage() != 0)
			light("", 1)


/obj/item/candle/holo
	name = "holo candle"
	desc = "A small disk projecting the image of a candle, used for futuristic lighting. It has a multitool port on it for changing colors."
	icon_state = "holocandle_base"
	//item_state = "candle1"
	heat_production = 0
	source_temperature = 0
	light_color = LIGHT_COLOR_FIRE
	wax = "red" //Repurposed var for the "wax" color.

/obj/item/candle/holo/New()
	..()
	update_icon()

/obj/item/candle/holo/update_icon()
	overlays.len = 0
	switch(wax)
		if("red")
			light_color = LIGHT_COLOR_FIRE
		if("blue")
			light_color = LIGHT_COLOR_BLUE
		if("purple")
			light_color = LIGHT_COLOR_PURPLE
		if("green")
			light_color = LIGHT_COLOR_GREEN
		if("yellow")
			light_color = LIGHT_COLOR_YELLOW
	var/image/I_stick = image(icon,src,"holocandle_[wax]")
	if (lit)
		var/image/I_flame = image(icon,src,"holocandle_lit")
		I_stick.overlays += I_flame
	I_stick.blend_mode = BLEND_ADD
	I_stick.alpha = 200
	if (isturf(loc))
		I_stick.plane = ABOVE_LIGHTING_PLANE
	else
		I_stick.plane = ABOVE_HUD_PLANE
	overlays += I_stick

/obj/item/candle/holo/attack_self(mob/user)
	lit = !lit
	update_icon()
	light("<span class='notice'>[user] flips \the [src]'s switch.</span>")

/obj/item/candle/holo/attackby(obj/item/weapon/W, mob/user)
	var/list/choices = list("red","blue","purple","green","yellow")
	if(W.is_multitool(user))
		wax = input("What color would do you want?","Color Selection") as anything in choices
		update_icon()
	..()

/obj/item/candle/holo/light(var/flavor_text = "<span class='notice'>[usr] lights [src].</span>", var/quiet = 0)
	if(lit)
		set_light(CANDLE_LUM,2,light_color)
	else
		kill_light()
	visible_message(flavor_text)

/obj/item/candle/holo/Crossed()
	return
