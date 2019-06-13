#define FED_PING_DELAY 40

#define SCAN_COUNT_MIN_WEAKSTR 3
#define SCAN_COUNT_MIN_TARGET 4

#define INCUBATOR_DISH1_GROWTH	1
#define INCUBATOR_DISH1_EFFECT	2
#define INCUBATOR_DISH1_ANTIGEN	4
#define INCUBATOR_DISH2_GROWTH	8
#define INCUBATOR_DISH2_EFFECT	16
#define INCUBATOR_DISH2_ANTIGEN	32
#define INCUBATOR_DISH3_GROWTH	64
#define INCUBATOR_DISH3_EFFECT	128
#define INCUBATOR_DISH3_ANTIGEN	256

/obj/machinery/disease2/incubator
	name = "pathogenic incubator"
	desc = "Uses radiation to accelerate the incubation of pathogen. The dishes must be filled with reagents for the incubation to have any effects."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/virology.dmi'
	icon_state = "incubator"

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL
	light_color = "#6496FA"
	light_range = 2
	light_power = 1

	var/obj/item/weapon/virusdish/dish1
	var/obj/item/weapon/virusdish/dish2
	var/obj/item/weapon/virusdish/dish3


	var/on = 0

	var/updates = 0
	var/updates_new = 0

	var/mutatechance = 5
	var/growthrate = 3

/obj/machinery/disease2/incubator/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/incubator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
	)

	RefreshParts()

/obj/machinery/disease2/incubator/RefreshParts()
	var/scancount = 0
	var/lasercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/scanning_module))
			scancount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser))
			lasercount += SP.rating-1
	mutatechance = initial(mutatechance) * max(1, scancount)
	growthrate = initial(growthrate) + lasercount

/obj/machinery/disease2/incubator/attackby(var/obj/I, var/mob/user)
	. = ..()

	if(stat & (BROKEN))
		to_chat(user, "<span class='warning'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return FALSE

	if(.)
		return

	if (istype(I,/obj/item/weapon/virusdish))
		addDish(I,user)
		updateUsrDialog()
		return TRUE

/obj/machinery/disease2/incubator/proc/addDish(var/obj/item/weapon/virusdish/VD,var/mob/user,var/force_slot = 0)
	if (VD.open)
		if (!force_slot)
			if (!dish1)
				dish1 = VD
			else if (!dish2)
				dish2 = VD
			else if (!dish3)
				dish3 = VD
			else
				to_chat(user,"<span class='warning'>There is no more room inside \the [src]. Remove a dish first.</span>")
				return null
		else
			switch (force_slot)
				if (1)
					if (!dish1)
						dish1 = VD
					else
						to_chat(user,"<span class='warning'>This slot is already occupied. Remove the dish first.</span>")
						return null
				if (2)
					if (!dish2)
						dish2 = VD
					else
						to_chat(user,"<span class='warning'>This slot is already occupied. Remove the dish first.</span>")
						return null
				if (3)
					if (!dish3)
						dish3 = VD
					else
						to_chat(user,"<span class='warning'>This slot is already occupied. Remove the dish first.</span>")
						return null
		visible_message("<span class='notice'>\The [user] inserts \the [VD] in \the [src].</span>","<span class='notice'>You insert \the [VD] in \the [src].</span>")
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		user.drop_item(VD, loc, 1)
		VD.forceMove(src)
		update_icon()
		return VD
	else
		to_chat(user, "<span class='warning'>You must open the dish's lid before it can be put inside the incubator. Be sure to wear proper protection first (at least a sterile mask and latex gloves).</span>")

/obj/machinery/disease2/incubator/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["close"])
		usr << browse(null, "\ref[src]")
		usr.unset_machine()
		return 1

	usr.set_machine(src)

	if (href_list["power"])
		on = !on
		update_icon()
		if(on)
			if(dish1 && dish1.contained_virus)
				dish1.contained_virus.log += "<br />[timestamp()] Incubation started by [key_name(usr)]"
			if(dish2 && dish2.contained_virus)
				dish2.contained_virus.log += "<br />[timestamp()] Incubation started by [key_name(usr)]"
			if(dish3 && dish3.contained_virus)
				dish3.contained_virus.log += "<br />[timestamp()] Incubation started by [key_name(usr)]"
	if (href_list["ejectdish"])
		switch (href_list["ejectdish"])
			if ("1")
				if(dish1)
					dish1.forceMove(src.loc)
					if (Adjacent(usr))
						dish1.forceMove(usr.loc)
					dish1 = null
					updates &= ~INCUBATOR_DISH1_GROWTH
					updates_new &= ~INCUBATOR_DISH1_GROWTH
					updates &= ~INCUBATOR_DISH1_EFFECT
					updates_new &= ~INCUBATOR_DISH1_EFFECT
					updates &= ~INCUBATOR_DISH1_ANTIGEN
					updates_new &= ~INCUBATOR_DISH1_ANTIGEN
					update_icon()
			if ("2")
				if(dish2)
					dish2.forceMove(src.loc)
					if (Adjacent(usr))
						dish2.forceMove(usr.loc)
					dish2 = null
					updates &= ~INCUBATOR_DISH2_GROWTH
					updates_new &= ~INCUBATOR_DISH2_GROWTH
					updates &= ~INCUBATOR_DISH2_EFFECT
					updates_new &= ~INCUBATOR_DISH2_EFFECT
					updates &= ~INCUBATOR_DISH2_ANTIGEN
					updates_new &= ~INCUBATOR_DISH2_ANTIGEN
					update_icon()
			if ("3")
				if(dish3)
					dish3.forceMove(src.loc)
					if (Adjacent(usr))
						dish3.forceMove(usr.loc)
					dish3 = null
					updates &= ~INCUBATOR_DISH3_GROWTH
					updates_new &= ~INCUBATOR_DISH3_GROWTH
					updates &= ~INCUBATOR_DISH3_EFFECT
					updates_new &= ~INCUBATOR_DISH3_EFFECT
					updates &= ~INCUBATOR_DISH3_ANTIGEN
					updates_new &= ~INCUBATOR_DISH3_ANTIGEN
					update_icon()

	if (href_list["insertdish"])
		var/mob/living/M
		if (isliving(usr))
			M = usr
		if (!M)
			return
		var/obj/item/weapon/virusdish/VD = M.get_active_hand()
		if (istype(VD))
			addDish(VD,M,text2num(href_list["insertdish"]))
		update_icon()

	if (href_list["examinedish"])
		switch (href_list["examinedish"])
			if ("1")
				if(dish1)
					dish1.examine(usr)
			if ("2")
				if(dish2)
					dish2.examine(usr)
			if ("3")
				if(dish3)
					dish3.examine(usr)

	if (href_list["flushdish"])
		switch (href_list["flushdish"])
			if("1")
				dish1.reagents.clear_reagents()
			if("2")
				dish2.reagents.clear_reagents()
			if("3")
				dish3.reagents.clear_reagents()
	src.add_fingerprint(usr)
	src.updateUsrDialog()

/obj/machinery/disease2/incubator/attack_hand(var/mob/user)
	if(stat & (BROKEN))
		to_chat(user, "<span class='notice'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return

	if(stat & (NOPOWER))
		to_chat(user, "<span class='notice'>Deprived of power, \the [src] is unresponsive.</span>")
		updates = 0
		updates_new = 0
		if (dish1)
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			dish1.forceMove(loc)
			dish1 = null
			update_icon()
		sleep(1)
		if (dish2)
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			dish2.forceMove(loc)
			dish2 = null
			update_icon()
		sleep(1)
		if (dish3)
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			dish3.forceMove(loc)
			dish3 = null
			update_icon()
		return

	if(.)
		return

	user.set_machine(src)

	var/dat = ""
	dat += "Power status: <A href='?src=\ref[src];power=1'>[on?"On":"Off"]</a>"
	dat += "<hr>"
	if(dish1)
		dat += "<A href='?src=\ref[src];ejectdish=1'>[dish1] (Growth: <b>[dish1.growth]%</b>)</a> <A href='?src=\ref[src];examinedish=1'>(?)</a>[dish1.reagents.is_empty() ? "" : " <A href='?src=\ref[src];flushdish=1'>Flush Reagents</a>"]"
	else
		dat += "<A href='?src=\ref[src];insertdish=1'>Insert a dish</a>"
	dat += "<BR>"
	if(dish2)
		dat += "<A href='?src=\ref[src];ejectdish=2'>[dish2] (Growth: <b>[dish2.growth]%</b>)</a> <A href='?src=\ref[src];examinedish=2'>(?)</a>[dish2.reagents.is_empty() ? "" : " <A href='?src=\ref[src];flushdish=2'>Flush Reagents</a>"]"
	else
		dat += "<A href='?src=\ref[src];insertdish=2'>Insert a dish</a>"
	dat += "<BR>"
	if(dish3)
		dat += "<A href='?src=\ref[src];ejectdish=3'>[dish3] (Growth: <b>[dish3.growth]%</b>)</a> <A href='?src=\ref[src];examinedish=3'>(?)</a>[dish3.reagents.is_empty() ? "" : " <A href='?src=\ref[src];flushdish=3'>Flush Reagents</a>"]"
	else
		dat += "<A href='?src=\ref[src];insertdish=3'>Insert a dish</a>"
	dat += "<hr>"
	var/datum/browser/popup = new(user, "\ref[src]", "Pathogenic Incubator", 575, 400, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/disease2/incubator/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(on)
		use_power(200)
		if (dish1)
			dish1.incubate(mutatechance,growthrate)
		if (dish2)
			dish2.incubate(mutatechance,growthrate)
		if (dish3)
			dish3.incubate(mutatechance,growthrate)
	else
		use_power(100)

	update_icon()
	updateUsrDialog()

/obj/machinery/disease2/incubator/proc/update_effect(var/obj/item/weapon/virusdish/dish)
	if (!istype(dish))
		return
	if (dish == dish1)
		updates_new |= INCUBATOR_DISH1_EFFECT
	else if (dish == dish2)
		updates_new |= INCUBATOR_DISH2_EFFECT
	else if (dish == dish3)
		updates_new |= INCUBATOR_DISH3_EFFECT

/obj/machinery/disease2/incubator/proc/update_antigen(var/obj/item/weapon/virusdish/dish)
	if (!istype(dish))
		return
	if (dish == dish1)
		updates_new |= INCUBATOR_DISH1_ANTIGEN
	else if (dish == dish2)
		updates_new |= INCUBATOR_DISH2_ANTIGEN
	else if (dish == dish3)
		updates_new |= INCUBATOR_DISH3_ANTIGEN

/obj/machinery/disease2/incubator/power_change()
	..()
	update_icon()

/obj/machinery/disease2/incubator/update_icon()
	overlays.len = 0
	icon_state = "incubator"

	if (stat & (NOPOWER))
		icon_state = "incubator0"

	if (stat & (BROKEN))
		icon_state = "incubatorb"

	if (on)
		light_color = "#E1C400"
	else
		light_color = "#6496FA"

	if(stat & (BROKEN|NOPOWER))
		set_light(0)
	else
		if (on)
			set_light(2,2)
			overlays += "incubator_light"
			var/image/incubator_light = image(icon,"incubator_glassy")
			incubator_light.plane = LIGHTING_PLANE
			incubator_light.layer = ABOVE_LIGHTING_LAYER
			overlays += incubator_light
		else
			set_light(2,1)

	if (dish1)
		add_dish_sprite(dish1,1)
	if (dish2)
		add_dish_sprite(dish2,2)
	if (dish3)
		add_dish_sprite(dish3,3)

	if(on && !(stat & (BROKEN|NOPOWER)))
		var/image/incubator_glass = image(icon,"incubator_glass")
		incubator_glass.plane = LIGHTING_PLANE
		incubator_glass.layer = ABOVE_LIGHTING_LAYER
		incubator_glass.blend_mode = BLEND_ADD
		overlays += incubator_glass

/obj/machinery/disease2/incubator/proc/add_dish_sprite(var/obj/item/weapon/virusdish/dish, var/slot = 1)
	slot--
	var/image/dish_outline = image(icon,"smalldish2-outline")
	dish_outline.alpha = 128
	dish_outline.pixel_y = -5 * slot
	overlays += dish_outline
	var/image/dish_content = image(icon,"smalldish2-empty")
	dish_content.alpha = 128
	dish_content.pixel_y = -5 * slot
	if (dish.contained_virus)
		dish_content.icon_state = "smalldish2-color"
		dish_content.color = dish.contained_virus.color
	overlays += dish_content

	//updating the light indicators
	if (dish.contained_virus && !(stat & (BROKEN|NOPOWER)))
		var/image/grown_gauge = image(icon,"incubator_growth7")
		grown_gauge.plane = LIGHTING_PLANE
		grown_gauge.layer = ABOVE_LIGHTING_LAYER
		grown_gauge.pixel_y = -5 * slot
		if (dish.growth < 100)
			grown_gauge.icon_state = "incubator_growth[min(6,max(1,round(dish.growth*70/1000)))]"
		else
			var/update = FALSE
			switch(slot)
				if (0)
					if (!(updates & INCUBATOR_DISH1_GROWTH))
						updates += INCUBATOR_DISH1_GROWTH
						update = TRUE
						alert_noise("ping")
				if (1)
					if (!(updates & INCUBATOR_DISH2_GROWTH))
						updates += INCUBATOR_DISH2_GROWTH
						update = TRUE
						alert_noise("ping")
				if (2)
					if (!(updates & INCUBATOR_DISH3_GROWTH))
						updates += INCUBATOR_DISH3_GROWTH
						update = TRUE
						alert_noise("ping")
			if (update)
				var/image/grown_light = image(icon,"incubator_grown_update")
				grown_light.pixel_y = -5 * slot
				grown_light.plane = LIGHTING_PLANE
				grown_light.layer = ABOVE_LIGHTING_LAYER
				overlays += grown_light
			else
				var/image/grown_light = image(icon,"incubator_grown")
				grown_light.pixel_y = -5 * slot
				grown_light.plane = LIGHTING_PLANE
				grown_light.layer = ABOVE_LIGHTING_LAYER
				overlays += grown_light
		overlays += grown_gauge
		switch(slot)
			if (0)
				if (updates_new & INCUBATOR_DISH1_EFFECT)
					if (!(updates & INCUBATOR_DISH1_EFFECT))
						updates += INCUBATOR_DISH1_EFFECT
						var/image/effect_light = image(icon,"incubator_effect_update")
						effect_light.pixel_y = -5 * slot
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						overlays += effect_light
						alert_noise("beep")
					else
						var/image/effect_light = image(icon,"incubator_effect")
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						effect_light.pixel_y = -5 * slot
						overlays += effect_light
				if (updates_new & INCUBATOR_DISH1_ANTIGEN)
					if (!(updates & INCUBATOR_DISH1_ANTIGEN))
						updates += INCUBATOR_DISH1_ANTIGEN
						var/image/effect_light = image(icon,"incubator_antigen_update")
						effect_light.pixel_y = -5 * slot
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						overlays += effect_light
						alert_noise("beep")
					else
						var/image/effect_light = image(icon,"incubator_antigen")
						effect_light.pixel_y = -5 * slot
						overlays += effect_light
			if (1)
				if (updates_new & INCUBATOR_DISH2_EFFECT)
					if (!(updates & INCUBATOR_DISH2_EFFECT))
						updates += INCUBATOR_DISH2_EFFECT
						var/image/effect_light = image(icon,"incubator_effect_update")
						effect_light.pixel_y = -5 * slot
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						overlays += effect_light
						alert_noise("beep")
					else
						var/image/effect_light = image(icon,"incubator_effect")
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						effect_light.pixel_y = -5 * slot
						overlays += effect_light
				if (updates_new & INCUBATOR_DISH2_ANTIGEN)
					if (!(updates & INCUBATOR_DISH2_ANTIGEN))
						updates += INCUBATOR_DISH2_ANTIGEN
						var/image/effect_light = image(icon,"incubator_antigen_update")
						effect_light.pixel_y = -5 * slot
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						overlays += effect_light
						alert_noise("beep")
					else
						var/image/effect_light = image(icon,"incubator_antigen")
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						effect_light.pixel_y = -5 * slot
						overlays += effect_light
			if (2)
				if (updates_new & INCUBATOR_DISH3_EFFECT)
					if (!(updates & INCUBATOR_DISH3_EFFECT))
						updates += INCUBATOR_DISH3_EFFECT
						var/image/effect_light = image(icon,"incubator_effect_update")
						effect_light.pixel_y = -5 * slot
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						overlays += effect_light
						alert_noise("beep")
					else
						var/image/effect_light = image(icon,"incubator_effect")
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						effect_light.pixel_y = -5 * slot
						overlays += effect_light
				if (updates_new & INCUBATOR_DISH3_ANTIGEN)
					if (!(updates & INCUBATOR_DISH3_ANTIGEN))
						updates += INCUBATOR_DISH3_ANTIGEN
						var/image/effect_light = image(icon,"incubator_antigen_update")
						effect_light.pixel_y = -5 * slot
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						overlays += effect_light
						alert_noise("beep")
					else
						var/image/effect_light = image(icon,"incubator_antigen")
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						effect_light.pixel_y = -5 * slot
						overlays += effect_light



/obj/machinery/disease2/incubator/proc/breakdown()
	stat |= BROKEN
	updates = 0
	updates_new = 0
	if (dish1)
		dish1.forceMove(loc)
	if (dish2)
		dish2.forceMove(loc)
	if (dish3)
		dish3.forceMove(loc)
	dish1 = null
	dish2 = null
	dish3 = null
	update_icon()

/obj/machinery/disease2/incubator/ex_act(var/severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				qdel(src)
			else
				breakdown()
		if(3)
			if(prob(35))
				breakdown()

/obj/machinery/disease2/incubator/emp_act(var/severity)
	if(stat & (BROKEN|NOPOWER))
		return
	switch(severity)
		if(1)
			if(prob(75))
				breakdown()
		if(2)
			if(prob(35))
				breakdown()

/obj/machinery/disease2/incubator/attack_construct(var/mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	if (!Adjacent(user))
		return 0
	if(istype(user,/mob/living/simple_animal/construct/armoured))
		shake(1, 3)
		playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
		add_hiddenprint(user)
		breakdown()
		return 1
	return 0

/obj/machinery/disease2/incubator/kick_act(var/mob/living/carbon/human/user)
	..()
	if(stat & (BROKEN|NOPOWER))
		return
	if (prob(5))
		breakdown()

/obj/machinery/disease2/incubator/attack_paw(var/mob/living/carbon/alien/humanoid/user)
	if(!istype(user))
		return
	if(stat & (BROKEN|NOPOWER))
		return
	breakdown()
	user.do_attack_animation(src, user)
	visible_message("<span class='warning'>\The [user] slashes at \the [src]!</span>")
	playsound(src, 'sound/weapons/slash.ogg', 100, 1)
	add_hiddenprint(user)

#undef INCUBATOR_DISH1_GROWTH
#undef INCUBATOR_DISH1_EFFECT
#undef INCUBATOR_DISH1_ANTIGEN
#undef INCUBATOR_DISH2_GROWTH
#undef INCUBATOR_DISH2_EFFECT
#undef INCUBATOR_DISH2_ANTIGEN
#undef INCUBATOR_DISH3_GROWTH
#undef INCUBATOR_DISH3_EFFECT
#undef INCUBATOR_DISH3_ANTIGEN
