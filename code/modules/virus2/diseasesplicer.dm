/obj/machinery/computer/diseasesplicer
	name = "Disease Splicer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "virus"
	circuit = "/obj/item/weapon/circuitboard/splicer"

	var/datum/disease2/effect/memorybank = null
	var/analysed = 0
	var/obj/item/weapon/virusdish/dish = null
	var/burning = 0

	var/splicing = 0
	var/scanning = 0
	var/spliced = 0

	light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/diseasesplicer/attackby(var/obj/I as obj, var/mob/user as mob)
	if(!(istype(I,/obj/item/weapon/virusdish) || istype(I,/obj/item/weapon/diseasedisk)))
		return ..()

	if(istype(I,/obj/item/weapon/virusdish))
		var/mob/living/carbon/c = user
		if(!dish)
			if(!c.drop_item(I, src))
				return 1
			dish = I

	if(istype(I,/obj/item/weapon/diseasedisk))
		to_chat(user, "You upload the contents of the disk into the buffer")
		memorybank = I:effect

	attack_hand(user)

/obj/machinery/computer/diseasesplicer/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/diseasesplicer/attack_paw(var/mob/user as mob)

	return src.attack_hand(user)
	return

/obj/machinery/computer/diseasesplicer/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = list()
	if(splicing)
		dat += "Splicing in progress."
	else if(scanning)
		dat += "Scanning in progress."
	else if(burning)
		dat += "Data disk burning in progress."
	else
		if(dish)
			dat += "Virus dish inserted."

		dat += "<BR>Current DNA strand : "
		if(memorybank)
			dat += "<A href='?src=\ref[src];splice=1'>"
			if(analysed)
				dat += "[memorybank.name] ([memorybank.stage])"
			else
				dat += "Unknown DNA strand ([memorybank.stage])"
			dat += "</a>"

			dat += "<BR><A href='?src=\ref[src];disk=1'>Burn DNA Sequence to data storage disk</a>"
		else
			dat += "Empty."

		dat += "<BR><BR>"

		if(dish)
			if(dish.virus2)
				if(dish.growth >= 50)
					for(var/datum/disease2/effect/e in dish.virus2.effects)
						dat += "<BR><A href='?src=\ref[src];grab=\ref[e]'> DNA strand"
						if(dish.analysed)
							dat += ": [e.name]"
						dat += " ([e.stage])</a>"
				else
					dat += "<BR>Insufficent cells to attempt gene splicing."
			else
				dat += "<BR>No virus found in dish."

			dat += "<BR><BR><A href='?src=\ref[src];eject=1'>Eject disk</a>"
		else
			dat += "<BR>Please insert dish."
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "disease_splicer", "Disease Splicer", 400, 500, src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "disease_splicer")

/obj/machinery/computer/diseasesplicer/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)

	if(scanning)
		scanning -= 1
		if(!scanning)
			alert_noise("beep")
	if(splicing)
		splicing -= 1
		if(!splicing)
			spliced = 1
			alert_noise("ping")
	if(burning)
		burning -= 1
		if(!burning)
			var/obj/item/weapon/diseasedisk/d = new /obj/item/weapon/diseasedisk(src.loc)
			if(analysed)
				d.name = "[memorybank.name] GNA disk (Stage: [memorybank.stage])"
			else
				d.name = "Unknown GNA disk (Stage: [memorybank.stage])"
			d.effect = memorybank
			alert_noise("ping")

	src.updateUsrDialog()
	return

/obj/machinery/computer/diseasesplicer/Topic(href, href_list)
	if(..())
		return 1

	if(usr)
		usr.set_machine(src)

	if (href_list["grab"])
		memorybank = locate(href_list["grab"])
		analysed = dish.analysed
		qdel(dish)
		dish = null
		scanning = 10

	else if(href_list["eject"])
		if (spliced != 0)
			//Here we generate a new ID so the spliced pathogen gets it's own entry in the database instead of being shown as the old one.
			dish.virus2.uniqueID = rand(0,10000)
			dish.info = dish.virus2.get_info()
			dish.virus2.addToDB()
			spliced = 0

		dish.forceMove(src.loc)
		dish = null

	else if(href_list["splice"])
		if(dish)
			for(var/x = 1 to dish.virus2.effects.len)
				var/datum/disease2/effect/e = dish.virus2.effects[x]
				if(e.stage == memorybank.stage)
					dish.virus2.effects[x] = memorybank.getcopy(dish.virus2)
					log_debug("Virus [dish.virus2.uniqueID] had [memorybank.name] spliced into to replace [e.name] by [key_name(usr)].")
					dish.virus2.log += "<br />[timestamp()] [memorybank.name] spliced in by [key_name(usr)] (replaces [e.name])"

			splicing = 10

	else if(href_list["disk"])
		burning = 10

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return
