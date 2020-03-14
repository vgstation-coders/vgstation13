#define DISEASE_SPLICER_BURNING_TICKS 5
#define DISEASE_SPLICER_SPLICING_TICKS 5
#define DISEASE_SPLICER_SCANNING_TICKS 5

/obj/machinery/computer/diseasesplicer
	name = "disease splicer"
	icon = 'icons/obj/virology.dmi'
	icon_state = "splicer"
	circuit = "/obj/item/weapon/circuitboard/splicer"

	var/datum/disease2/effect/memorybank = null
	var/analysed = FALSE // If the buffered effect came from a dish that had been analyzed this is TRUE
	var/obj/item/weapon/virusdish/dish = null
	var/burning = 0 // Time in process ticks until disk burning is over

	var/splicing = 0 // Time in process ticks until splicing is over
	var/scanning = 0 // Time in process ticks until scan is over
	var/spliced = FALSE // If at least one effect has been spliced into the current dish this is TRUE

	idle_power_usage = 100
	active_power_usage = 600

	light_color = "#00FF00"

/obj/machinery/computer/diseasesplicer/attackby(var/obj/I, var/mob/user)
	if(!(istype(I,/obj/item/weapon/virusdish) || istype(I,/obj/item/weapon/disk/disease)))
		return ..()

	if(istype(I, /obj/item/weapon/virusdish))
		if(dish)
			to_chat(user, "<span class='warning'>A virus containment dish is already inside \the [src].</span>")
			return
		if(!user.drop_item(I, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [I]!</span>")
			return
		dish = I
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		update_icon()

	if(istype(I, /obj/item/weapon/disk/disease))
		var/obj/item/weapon/disk/disease/disk = I
		visible_message("<span class='notice'>[user] swipes \the [disk] against \the [src].</span>", "<span class='notice'>You swipe \the [disk] against \the [src], copying the data into the machine's buffer.</span>")
		memorybank = disk.effect
		anim(target = src, a_icon = icon, flick_anim = "splicer_disk", sleeptime = 15)
		spawn(2)
			update_icon()

	attack_hand(user)

/obj/machinery/computer/diseasesplicer/ui_interact(var/mob/user, var/ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/list/data = list(
		"splicing" = splicing,
		"scanning" = scanning,
		"burning" = burning
	)

	if(dish && dish.contained_virus)
		if (dish.analysed)
			data["dish_name"] = dish.contained_virus.name()
		else
			data["dish_name"] = "Unknown [dish.contained_virus.form]"

	if(memorybank)
		data["memorybank"] = "[analysed ? memorybank.name : "Unknown DNA strand"] (Stage [memorybank.stage])"

	if(!dish)
		data["dish_error"] = "no dish inserted"
	else if(!dish.contained_virus)
		data["dish_error"] = "no pathogen in dish"
	else if(!dish.analysed)
		data["dish_error"] = "dish not analysed"
	else if(dish.growth < 50)
		data["dish_error"] = "not enough cells"
	else
		var/list/effects_list = list()
		for(var/datum/disease2/effect/_effect in dish.contained_virus.effects)
			var/list/effect_data = list(
				"name" = dish.analysed ? _effect.name : "Unknown DNA strand",
				"stage" = _effect.stage
			)
			effects_list += list(effect_data)
		data["dish_effects"] = effects_list

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "disease_splicer.tmpl", name, 690, 330)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/diseasesplicer/attack_hand(var/mob/user)
	. = ..()

	if(stat & (NOPOWER|BROKEN))
		eject_dish()
		return

	if(.)
		return

	ui_interact(user)

/obj/machinery/computer/diseasesplicer/process()
	if(stat & (NOPOWER|BROKEN))
		return
	if(scanning || splicing || burning)
		use_power = 2
	else
		use_power = 1

	if(scanning)
		scanning -= 1
		if(!scanning)
			update_icon()
			nanomanager.update_uis(src)
			alert_noise("beep")
	if(splicing)
		splicing -= 1
		if(!splicing)
			update_icon()
			nanomanager.update_uis(src)
			alert_noise("ping")
	if(burning)
		burning -= 1
		if(!burning)
			update_icon()
			anim(target = src, a_icon = icon, flick_anim = "splicer_print", sleeptime = 15)
			nanomanager.update_uis(src)
			var/obj/item/weapon/disk/disease/d = new /obj/item/weapon/disk/disease(src)
			if(analysed)
				d.name = "\improper [memorybank.name] GNA disk (Stage: [memorybank.stage])"
			else
				d.name = "unknown GNA disk (Stage: [memorybank.stage])"
			d.effect = memorybank
			alert_noise("ping")
			spawn(10)
				d.forceMove(loc)
				d.pixel_x = -6
				d.pixel_y = 3


/obj/machinery/computer/diseasesplicer/update_icon()
	..()
	overlays.len = 0

	if (dish)
		var/image/dish_outline = image(icon,"smalldish2-outline")
		dish_outline.alpha = 128
		dish_outline.pixel_x = -1
		dish_outline.pixel_y = -13
		overlays += dish_outline
		var/image/dish_content = image(icon,"smalldish2-empty")
		dish_content.alpha = 128
		dish_content.pixel_x = -1
		dish_content.pixel_y = -13
		if (dish.contained_virus)
			dish_content.icon_state = "smalldish2-color"
			dish_content.color = dish.contained_virus.color
		overlays += dish_content

	if(stat & (BROKEN|NOPOWER))
		return

	if (dish && dish.contained_virus)
		if (dish.analysed)
			var/image/scan_pattern = image(icon,"pattern-[dish.contained_virus.pattern]b")
			scan_pattern.color = "#00FF00"
			scan_pattern.pixel_x = -2
			scan_pattern.pixel_y = 4
			overlays += scan_pattern
		else
			overlays += image(icon,"splicer_unknown")

	if(scanning || splicing)
		var/image/splicer_glass = image(icon,"splicer_glass")
		splicer_glass.plane = LIGHTING_PLANE
		splicer_glass.layer = ABOVE_LIGHTING_LAYER
		splicer_glass.blend_mode = BLEND_ADD
		overlays += splicer_glass

	if (memorybank)
		var/image/buffer_light = image(icon,"splicer_buffer")
		buffer_light.plane = LIGHTING_PLANE
		buffer_light.layer = ABOVE_LIGHTING_LAYER
		overlays += buffer_light

/obj/machinery/computer/diseasesplicer/proc/buffer2dish()
	if(!memorybank || !dish || !dish.contained_virus)
		return

	var/list/effects = dish.contained_virus.effects
	for(var/x = 1 to effects.len)
		var/datum/disease2/effect/e = effects[x]
		if(e.stage == memorybank.stage)
			effects[x] = memorybank.getcopy(dish.contained_virus)
			log_debug("[dish.contained_virus.form] #[add_zero("[dish.contained_virus.uniqueID]", 4)][dish.contained_virus.childID ? "-[add_zero("[dish.contained_virus.childID]", 2)]" : ""] had [memorybank.name] spliced into to replace [e.name] by [key_name(usr)].")
			dish.contained_virus.log += "<br />[timestamp()] [memorybank.name] spliced in by [key_name(usr)] (replaces [e.name])"
			break

	splicing = DISEASE_SPLICER_SPLICING_TICKS
	spliced = TRUE
	update_icon()

/obj/machinery/computer/diseasesplicer/proc/dish2buffer(var/target_stage)
	if(!dish || !dish.contained_virus)
		return
	var/list/effects = dish.contained_virus.effects
	for(var/x = 1 to effects.len)
		var/datum/disease2/effect/e = effects[x]
		if(e.stage == target_stage)
			memorybank = e
			break
	scanning = DISEASE_SPLICER_SCANNING_TICKS
	analysed = dish.analysed
	qdel(dish)
	dish = null
	update_icon()
	anim(target = src, a_icon = icon, flick_anim = "splicer_scan", sleeptime = 15)

/obj/machinery/computer/diseasesplicer/proc/eject_dish()
	if(!dish)
		return
	if(spliced)
		//Here we generate a new ID so the spliced pathogen gets it's own entry in the database instead of being shown as the old one.
		dish.contained_virus.subID = rand(0, 9999)
		var/list/randomhexes = list("7","8","9","a","b","c","d","e")
		var/colormix = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
		dish.contained_virus.color = BlendRGB(dish.contained_virus.color,colormix,0.25)
		dish.contained_virus.addToDB()
		say("Updated pathogen database with new spliced entry.")
		dish.info = dish.contained_virus.get_info()
		dish.name = "growth dish ([dish.contained_virus.name(TRUE)])"
		spliced = FALSE
		dish.contained_virus.update_global_log()
	dish.forceMove(loc)
	if (Adjacent(usr))
		dish.forceMove(usr.loc)
		usr.put_in_hands(dish)
	dish = null
	update_icon()

/obj/machinery/computer/diseasesplicer/Topic(href, href_list)
	if(..())
		return TRUE

	if(scanning || splicing || burning)
		return FALSE

	add_fingerprint(usr)

	if(href_list["erase_buffer"])
		memorybank = null
		update_icon()

	if(href_list["eject_dish"])
		eject_dish()

	var/target_stage = text2num(href_list["dish_effect_to_buffer"])
	if(target_stage)
		dish2buffer(target_stage)

	else if(href_list["splice_buffer_to_dish"])
		buffer2dish()

	else if(href_list["burn_buffer_to_disk"])
		burning = DISEASE_SPLICER_BURNING_TICKS

	return TRUE

#undef DISEASE_SPLICER_BURNING_TICKS
#undef DISEASE_SPLICER_SPLICING_TICKS
#undef DISEASE_SPLICER_SCANNING_TICKS
