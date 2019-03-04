#define DISEASE_SPLICER_BURNING_TICKS 5
#define DISEASE_SPLICER_SPLICING_TICKS 5
#define DISEASE_SPLICER_SCANNING_TICKS 5

/obj/machinery/computer/diseasesplicer
	name = "disease splicer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "virus"
	circuit = "/obj/item/weapon/circuitboard/splicer"

	var/datum/disease2/effect/memorybank = null
	var/analysed = FALSE // If the buffered effect came from a dish that had been analyzed this is TRUE
	var/obj/item/weapon/virusdish/dish = null
	var/burning = 0 // Time in process ticks until disk burning is over

	var/splicing = 0 // Time in process ticks until splicing is over
	var/scanning = 0 // Time in process ticks until scan is over
	var/spliced = FALSE // If at least one effect has been spliced into the current dish this is TRUE

	light_color = LIGHT_COLOR_GREEN

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

	if(istype(I, /obj/item/weapon/disk/disease))
		var/obj/item/weapon/disk/disease/disk = I
		visible_message("<span class='notice'>[user] swipes \the [disk] against \the [src].</span>", "<span class='notice'>You swipe \the [disk] against \the [src], copying the data into the machine's buffer.</span>")
		memorybank = disk.effect

	attack_hand(user)

/obj/machinery/computer/diseasesplicer/ui_interact(var/mob/user, var/ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/list/data = list(
		"splicing" = splicing,
		"scanning" = scanning,
		"burning" = burning
	)

	if(dish && dish.virus2)
		data["dish_name"] = dish.virus2.name()

	if(memorybank)
		data["memorybank"] = "[analysed ? memorybank.name : "Unknown DNA strand"] (Stage [memorybank.stage])"

	if(!dish)
		data["dish_error"] = "no dish inserted"
	else if(!dish.virus2)
		data["dish_error"] = "no virus in dish"
	else if(dish.growth < 50)
		data["dish_error"] = "not enough cells"
	else
		var/list/effects_list = list()
		for(var/datum/disease2/effect/_effect in dish.virus2.effects)
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
	if(..())
		return

	ui_interact(user)

/obj/machinery/computer/diseasesplicer/process()
	if(stat & (NOPOWER|BROKEN))
		return
	if(scanning || splicing || burning)
		use_power(500)

	if(scanning)
		scanning -= 1
		if(!scanning)
			nanomanager.update_uis(src)
			alert_noise("beep")
	if(splicing)
		splicing -= 1
		if(!splicing)
			nanomanager.update_uis(src)
			alert_noise("ping")
	if(burning)
		burning -= 1
		if(!burning)
			nanomanager.update_uis(src)
			var/obj/item/weapon/disk/disease/d = new /obj/item/weapon/disk/disease(loc)
			if(analysed)
				d.name = "\improper [memorybank.name] GNA disk (Stage: [memorybank.stage])"
			else
				d.name = "unknown GNA disk (Stage: [memorybank.stage])"
			d.effect = memorybank
			alert_noise("ping")

/obj/machinery/computer/diseasesplicer/proc/buffer2dish()
	if(!memorybank || !dish || !dish.virus2)
		return

	var/list/effects = dish.virus2.effects
	for(var/x = 1 to effects.len)
		var/datum/disease2/effect/e = effects[x]
		if(e.stage == memorybank.stage)
			effects[x] = memorybank.getcopy(dish.virus2)
			log_debug("[dish.virus2.form] [dish.virus2.uniqueID] had [memorybank.name] spliced into to replace [e.name] by [key_name(usr)].")
			dish.virus2.log += "<br />[timestamp()] [memorybank.name] spliced in by [key_name(usr)] (replaces [e.name])"
			break

	splicing = DISEASE_SPLICER_SPLICING_TICKS
	spliced = TRUE

/obj/machinery/computer/diseasesplicer/proc/dish2buffer(var/target_stage)
	if(!dish || !dish.virus2)
		return
	var/list/effects = dish.virus2.effects
	for(var/x = 1 to effects.len)
		var/datum/disease2/effect/e = effects[x]
		if(e.stage == target_stage)
			memorybank = e
			break
	scanning = DISEASE_SPLICER_SCANNING_TICKS
	analysed = dish.analysed
	qdel(dish)
	dish = null

/obj/machinery/computer/diseasesplicer/Topic(href, href_list)
	if(..())
		return TRUE

	if(scanning || splicing || burning)
		return FALSE

	add_fingerprint(usr)

	if(href_list["erase_buffer"])
		memorybank = null

	if(href_list["eject_dish"])
		if(!dish)
			return
		if(spliced)
			//Here we generate a new ID so the spliced pathogen gets it's own entry in the database instead of being shown as the old one.
			dish.virus2.uniqueID = rand(0, 10000)
			dish.info = dish.virus2.get_info()
			dish.virus2.addToDB()
			spliced = FALSE
		dish.forceMove(loc)
		dish = null

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
