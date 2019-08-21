#define FED_PING_DELAY 40

#define SCAN_COUNT_MIN_WEAKSTR 3
#define SCAN_COUNT_MIN_TARGET 4

#define INCUBATOR_DISH1_GROWTH	1
#define INCUBATOR_DISH1_REAGENT	2
#define INCUBATOR_DISH1_MAJOR	4
#define INCUBATOR_DISH1_MINOR	8
#define INCUBATOR_DISH2_GROWTH	16
#define INCUBATOR_DISH2_REAGENT	32
#define INCUBATOR_DISH2_MAJOR	64
#define INCUBATOR_DISH2_MINOR	128
#define INCUBATOR_DISH3_GROWTH	256
#define INCUBATOR_DISH3_REAGENT	512
#define INCUBATOR_DISH3_MAJOR	1024
#define INCUBATOR_DISH3_MINOR	2048

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

	idle_power_usage = 100
	active_power_usage = 200

	var/obj/item/weapon/virusdish/dish1
	var/obj/item/weapon/virusdish/dish2
	var/obj/item/weapon/virusdish/dish3

	var/major_dish1 = 0
	var/major_dish2 = 0
	var/major_dish3 = 0

	var/minor_dish1 = list(
		"strength" = 0,
		"robustness" = 0,
		"effects" = 0,
		)
	var/minor_dish2 = list(
		"strength" = 0,
		"robustness" = 0,
		"effects" = 0,
		)
	var/minor_dish3 = list(
		"strength" = 0,
		"robustness" = 0,
		"effects" = 0,
		)

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
		visible_message("<span class='notice'>\The [user] adds \the [VD] to \the [src].</span>","<span class='notice'>You add \the [VD] to \the [src].</span>")
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

	else if (href_list["ejectdish"])
		switch (href_list["ejectdish"])
			if ("1")
				if(dish1)
					dish1.forceMove(src.loc)
					if (Adjacent(usr))
						dish1.forceMove(usr.loc)
						usr.put_in_hands(dish1)
					dish1.update_icon()
					dish1 = null
					major_dish1 = 0
					minor_dish1 = list(
						"strength" = 0,
						"robustness" = 0,
						"effects" = 0,
						)
					updates &= ~INCUBATOR_DISH1_GROWTH
					updates_new &= ~INCUBATOR_DISH1_GROWTH
					updates &= ~INCUBATOR_DISH1_MAJOR
					updates_new &= ~INCUBATOR_DISH1_MAJOR
					updates &= ~INCUBATOR_DISH1_MINOR
					updates_new &= ~INCUBATOR_DISH1_MINOR
					update_icon()
			if ("2")
				if(dish2)
					dish2.forceMove(src.loc)
					if (Adjacent(usr))
						dish2.forceMove(usr.loc)
						usr.put_in_hands(dish2)
					dish2.update_icon()
					dish2 = null
					major_dish2 = 0
					minor_dish2 = list(
						"strength" = 0,
						"robustness" = 0,
						"effects" = 0,
						)
					updates &= ~INCUBATOR_DISH2_GROWTH
					updates_new &= ~INCUBATOR_DISH2_GROWTH
					updates &= ~INCUBATOR_DISH2_MAJOR
					updates_new &= ~INCUBATOR_DISH2_MAJOR
					updates &= ~INCUBATOR_DISH2_MINOR
					updates_new &= ~INCUBATOR_DISH2_MINOR
					update_icon()
			if ("3")
				if(dish3)
					dish3.forceMove(src.loc)
					if (Adjacent(usr))
						dish3.forceMove(usr.loc)
						usr.put_in_hands(dish3)
					dish3.update_icon()
					dish3 = null
					major_dish3 = 0
					minor_dish3 = list(
						"strength" = 0,
						"robustness" = 0,
						"effects" = 0,
						)
					updates &= ~INCUBATOR_DISH3_GROWTH
					updates_new &= ~INCUBATOR_DISH3_GROWTH
					updates &= ~INCUBATOR_DISH3_MAJOR
					updates_new &= ~INCUBATOR_DISH3_MAJOR
					updates &= ~INCUBATOR_DISH3_MINOR
					updates_new &= ~INCUBATOR_DISH3_MINOR
					update_icon()

	else if (href_list["insertdish"])
		var/mob/living/M
		if (isliving(usr))
			M = usr
		if (!M)
			return
		var/obj/item/weapon/virusdish/VD = M.get_active_hand()
		if (istype(VD))
			addDish(VD,M,text2num(href_list["insertdish"]))
		update_icon()

	else if (href_list["examinedish"])
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

	else if (href_list["flushdish"])
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
	. = ..()
	if(stat & (BROKEN))
		to_chat(user, "<span class='notice'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return

	if(stat & (NOPOWER))
		to_chat(user, "<span class='notice'>Deprived of power, \the [src] is unresponsive.</span>")
		updates = 0
		updates_new = 0
		major_dish1 = 0
		major_dish2 = 0
		major_dish3 = 0
		minor_dish1 = list(
			"strength" = 0,
			"robustness" = 0,
			"effects" = 0,
			)
		minor_dish2 = list(
			"strength" = 0,
			"robustness" = 0,
			"effects" = 0,
			)
		minor_dish3 = list(
			"strength" = 0,
			"robustness" = 0,
			"effects" = 0,
			)
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
		dat += "<A href='?src=\ref[src];ejectdish=1'>[dish1.name] (Growth: <b>[dish1.growth]%</b>)</a> <A href='?src=\ref[src];examinedish=1'>(?)</a>[dish1.reagents.is_empty() ? "" : " <A href='?src=\ref[src];flushdish=1'>Flush Reagents ([dish1.reagents.total_volume]u)</a>"][major_dish1 ? " (Major Mutations: [major_dish1])" : ""][((minor_dish1["strength"] != 0) || (minor_dish1["robustness"] != 0) || (minor_dish1["effects"] != 0)) ? " (Minor Mutations: str=[minor_dish1["strength"]]|rob=[minor_dish1["robustness"]]|eff=[minor_dish1["effects"]])" : ""]"
	else
		dat += "<A href='?src=\ref[src];insertdish=1'>Insert a dish</a>"
	dat += "<BR>"
	if(dish2)
		dat += "<A href='?src=\ref[src];ejectdish=2'>[dish2.name] (Growth: <b>[dish2.growth]%</b>)</a> <A href='?src=\ref[src];examinedish=2'>(?)</a>[dish2.reagents.is_empty() ? "" : " <A href='?src=\ref[src];flushdish=2'>Flush Reagents ([dish2.reagents.total_volume]u)</a>"][major_dish2 ? " (Major Mutations: [major_dish2])" : ""][((minor_dish2["strength"] != 0) || (minor_dish2["robustness"] != 0) || (minor_dish2["effects"] != 0)) ? " (Minor Mutations: str=[minor_dish2["strength"]]|rob=[minor_dish2["robustness"]]|eff=[minor_dish2["effects"]])" : ""]"
	else
		dat += "<A href='?src=\ref[src];insertdish=2'>Insert a dish</a>"
	dat += "<BR>"
	if(dish3)
		dat += "<A href='?src=\ref[src];ejectdish=3'>[dish3.name] (Growth: <b>[dish3.growth]%</b>)</a> <A href='?src=\ref[src];examinedish=3'>(?)</a>[dish3.reagents.is_empty() ? "" : " <A href='?src=\ref[src];flushdish=3'>Flush Reagents ([dish3.reagents.total_volume]u)</a>"][major_dish3 ? " (Major Mutations: [major_dish3])" : ""][((minor_dish3["strength"] != 0) || (minor_dish3["robustness"] != 0) || (minor_dish3["effects"] != 0)) ? " (Minor Mutations: str=[minor_dish3["strength"]]|rob=[minor_dish3["robustness"]]|eff=[minor_dish3["effects"]])" : ""]"
	else
		dat += "<A href='?src=\ref[src];insertdish=3'>Insert a dish</a>"
	dat += "<hr>"
	var/datum/browser/popup = new(user, "\ref[src]", "Pathogenic Incubator", 980, 200, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/disease2/incubator/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(on)
		use_power = 2
		if (dish1)
			dish1.incubate(mutatechance,growthrate)
		if (dish2)
			dish2.incubate(mutatechance,growthrate)
		if (dish3)
			dish3.incubate(mutatechance,growthrate)
	else
		use_power = 1

	update_icon()
	updateUsrDialog()

/obj/machinery/disease2/incubator/proc/update_major(var/obj/item/weapon/virusdish/dish)
	if (!istype(dish))
		return
	if (dish == dish1)
		updates_new |= INCUBATOR_DISH1_MAJOR
		updates &= ~INCUBATOR_DISH1_MAJOR
		major_dish1++
	else if (dish == dish2)
		updates_new |= INCUBATOR_DISH2_MAJOR
		updates &= ~INCUBATOR_DISH2_MAJOR
		major_dish2++
	else if (dish == dish3)
		updates_new |= INCUBATOR_DISH3_MAJOR
		updates &= ~INCUBATOR_DISH3_MAJOR
		major_dish3++

/obj/machinery/disease2/incubator/proc/update_minor(var/obj/item/weapon/virusdish/dish,var/str=0,var/rob=0,var/eff=0)
	if (!istype(dish))
		return
	if (dish == dish1)
		updates_new |= INCUBATOR_DISH1_MINOR
		updates &= ~INCUBATOR_DISH1_MINOR
		minor_dish1["strength"] += str
		minor_dish1["robustness"] += rob
		minor_dish1["effects"] += eff
	else if (dish == dish2)
		updates_new |= INCUBATOR_DISH2_MINOR
		updates &= ~INCUBATOR_DISH2_MINOR
		minor_dish2["strength"] += str
		minor_dish2["robustness"] += rob
		minor_dish2["effects"] += eff
	else if (dish == dish3)
		updates_new |= INCUBATOR_DISH3_MINOR
		updates &= ~INCUBATOR_DISH3_MINOR
		minor_dish3["strength"] += str
		minor_dish3["robustness"] += rob
		minor_dish3["effects"] += eff

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
			var/image/incubator_light = image(icon,"incubator_light")
			incubator_light.plane = LIGHTING_PLANE
			incubator_light.layer = ABOVE_LIGHTING_LAYER
			overlays += incubator_light
			var/image/incubator_glass = image(icon,"incubator_glass")
			incubator_glass.plane = LIGHTING_PLANE
			incubator_glass.layer = ABOVE_LIGHTING_LAYER
			incubator_glass.blend_mode = BLEND_ADD
			overlays += incubator_glass
		else
			set_light(2,1)

	if (dish1)
		add_dish_sprite(dish1,1)
	if (dish2)
		add_dish_sprite(dish2,2)
	if (dish3)
		add_dish_sprite(dish3,3)

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
		if (dish.reagents.total_volume < 0.02)
			var/update = FALSE
			switch(slot)
				if (0)
					if (!(updates & INCUBATOR_DISH1_REAGENT))
						updates += INCUBATOR_DISH1_REAGENT
						update = TRUE
				if (1)
					if (!(updates & INCUBATOR_DISH2_REAGENT))
						updates += INCUBATOR_DISH2_REAGENT
						update = TRUE
				if (2)
					if (!(updates & INCUBATOR_DISH3_REAGENT))
						updates += INCUBATOR_DISH3_REAGENT
						update = TRUE
			if (update)
				var/image/reagents_light = image(icon,"incubator_reagents_update")
				reagents_light.pixel_y = -5 * slot
				reagents_light.plane = LIGHTING_PLANE
				reagents_light.layer = ABOVE_LIGHTING_LAYER
				overlays += reagents_light
			else
				var/image/reagents_light = image(icon,"incubator_reagents")
				reagents_light.pixel_y = -5 * slot
				reagents_light.plane = LIGHTING_PLANE
				reagents_light.layer = ABOVE_LIGHTING_LAYER
				overlays += reagents_light
		switch(slot)
			if (0)
				if (updates_new & INCUBATOR_DISH1_MAJOR)
					if (!(updates & INCUBATOR_DISH1_MAJOR))
						updates += INCUBATOR_DISH1_MAJOR
						var/image/effect_light = image(icon,"incubator_major_update")
						effect_light.pixel_y = -5 * slot
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						overlays += effect_light
						alert_noise("beep")
					else
						var/image/effect_light = image(icon,"incubator_major")
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						effect_light.pixel_y = -5 * slot
						overlays += effect_light
				if (updates_new & INCUBATOR_DISH1_MINOR)
					if (!(updates & INCUBATOR_DISH1_MINOR))
						updates += INCUBATOR_DISH1_MINOR
						var/image/effect_light = image(icon,"incubator_minor_update")
						effect_light.pixel_y = -5 * slot
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						overlays += effect_light
					else
						var/image/effect_light = image(icon,"incubator_minor")
						effect_light.pixel_y = -5 * slot
						overlays += effect_light
			if (1)
				if (updates_new & INCUBATOR_DISH2_MAJOR)
					if (!(updates & INCUBATOR_DISH2_MAJOR))
						updates += INCUBATOR_DISH2_MAJOR
						var/image/effect_light = image(icon,"incubator_major_update")
						effect_light.pixel_y = -5 * slot
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						overlays += effect_light
						alert_noise("beep")
					else
						var/image/effect_light = image(icon,"incubator_major")
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						effect_light.pixel_y = -5 * slot
						overlays += effect_light
				if (updates_new & INCUBATOR_DISH2_MINOR)
					if (!(updates & INCUBATOR_DISH2_MINOR))
						updates += INCUBATOR_DISH2_MINOR
						var/image/effect_light = image(icon,"incubator_minor_update")
						effect_light.pixel_y = -5 * slot
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						overlays += effect_light
					else
						var/image/effect_light = image(icon,"incubator_minor")
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						effect_light.pixel_y = -5 * slot
						overlays += effect_light
			if (2)
				if (updates_new & INCUBATOR_DISH3_MAJOR)
					if (!(updates & INCUBATOR_DISH3_MAJOR))
						updates += INCUBATOR_DISH3_MAJOR
						var/image/effect_light = image(icon,"incubator_major_update")
						effect_light.pixel_y = -5 * slot
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						overlays += effect_light
						alert_noise("beep")
					else
						var/image/effect_light = image(icon,"incubator_major")
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						effect_light.pixel_y = -5 * slot
						overlays += effect_light
				if (updates_new & INCUBATOR_DISH3_MINOR)
					if (!(updates & INCUBATOR_DISH3_MINOR))
						updates += INCUBATOR_DISH3_MINOR
						var/image/effect_light = image(icon,"incubator_minor_update")
						effect_light.pixel_y = -5 * slot
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						overlays += effect_light
					else
						var/image/effect_light = image(icon,"incubator_minor")
						effect_light.plane = LIGHTING_PLANE
						effect_light.layer = ABOVE_LIGHTING_LAYER
						effect_light.pixel_y = -5 * slot
						overlays += effect_light



/obj/machinery/disease2/incubator/breakdown()
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
	..()

#undef INCUBATOR_DISH1_GROWTH
#undef INCUBATOR_DISH1_REAGENT
#undef INCUBATOR_DISH1_MAJOR
#undef INCUBATOR_DISH1_MINOR
#undef INCUBATOR_DISH2_GROWTH
#undef INCUBATOR_DISH2_REAGENT
#undef INCUBATOR_DISH2_MAJOR
#undef INCUBATOR_DISH2_MINOR
#undef INCUBATOR_DISH3_GROWTH
#undef INCUBATOR_DISH3_REAGENT
#undef INCUBATOR_DISH3_MAJOR
#undef INCUBATOR_DISH3_MINOR
