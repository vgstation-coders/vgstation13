
/obj/machinery/artifact_harvester
	name = "Exotic Particle Harvester"
	icon = 'icons/obj/virology.dmi'
	icon_state = "incubator_old"	//incubator_old_on
	anchored = 1
	density = 1
	idle_power_usage = 50
	active_power_usage = 750
	use_power = 1
	var/harvesting = 0
	var/obj/item/weapon/anobattery/inserted_battery
	var/obj/machinery/artifact/cur_artifact
	var/datum/artifact_effect/isolated_primary
	var/datum/artifact_effect/isolated_secondary
	var/obj/machinery/artifact_scanpad/owned_scanner = null
	var/chargerate = 0
	var/harvester = "" // Logs who started a harvest.
	var/obj/effect/artifact_field/artifact_field

/obj/machinery/artifact_harvester/New()
	..()
	//connect to a nearby scanner pad
	owned_scanner = locate(/obj/machinery/artifact_scanpad) in get_step(src, dir)
	if(!owned_scanner)
		owned_scanner = locate(/obj/machinery/artifact_scanpad) in orange(1, src)

/obj/machinery/artifact_harvester/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I,/obj/item/weapon/anobattery))
		if(!inserted_battery)
			if(user.drop_item(I, src))
				to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
				src.inserted_battery = I
				updateDialog()
		else
			to_chat(user, "<span class='warning'>There is already a battery in [src].</span>")
	else
		return..()

/obj/machinery/artifact_harvester/attack_hand(var/mob/user as mob)
	src.add_fingerprint(user)
	interact(user)

/obj/machinery/artifact_harvester/interact(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	user.set_machine(src)
	var/dat = "<B>Artifact Power Harvester</B><BR>"
	dat += "<HR><BR>"
	//
	if(owned_scanner)
		if(harvesting)
			if(harvesting > 0)
				dat += "Please wait. Harvesting in progress ([(inserted_battery.stored_charge/inserted_battery.capacity)*100]%).<br>"
			else
				dat += "Please wait. Energy dump in progress ([(inserted_battery.stored_charge/inserted_battery.capacity)*100]%).<br>"
			dat += "<A href='?src=\ref[src];stopharvest=1'>Halt early</A><BR>"
		else
			if(artifact_field)
				dat += "<A href='?src=\ref[src];alockoff=1'>Deactivate containment field</a><BR>"
				dat += "<b>Artifact energy signature ID:</b>[cur_artifact.artifact_id == "" ? "???" : "[cur_artifact.artifact_id]"]<BR>"
				dat += "<A href='?src=\ref[src];isolateeffect=1'>Isolate exotic particles</a><BR>"
				if(isolated_primary)
					dat += "<b>Isolated energy signature ID:</b>[isolated_primary.artifact_id == "" ? "???" : "[isolated_primary.artifact_id]"]<BR>"
				if(isolated_secondary)
					dat += "<b>Isolated energy signature ID:</b>[isolated_secondary.artifact_id == "" ? "???" : "[isolated_secondary.artifact_id]"]<BR>"
			else
				dat += "<A href='?src=\ref[src];alockon=1'>Activate containment field</a><BR>"

			if(inserted_battery)
				dat += "<b>[inserted_battery.name]</b> inserted, charge level: [inserted_battery.stored_charge]/[inserted_battery.capacity] ([(inserted_battery.stored_charge/inserted_battery.capacity)*100]%)<BR>"
				dat += "<b>Battery energy signature ID:</b>[inserted_battery.battery_effect.artifact_id == "" ? "???" : "[inserted_battery.battery_effect.artifact_id]"]<BR>"
				dat += "<A href='?src=\ref[src];ejectbattery=1'>Eject battery</a><BR>"
				dat += "<A href='?src=\ref[src];drainbattery=1'>Drain battery of all charge</a><BR>"
				if(isolated_primary)
					dat += "<A href='?src=\ref[src];harvestprimary=1'>Harvest signature ID: [isolated_primary.artifact_id]</a><BR>"
				if(isolated_secondary)
					dat += "<A href='?src=\ref[src];harvestsecondary=1'>Harvest signature ID: [isolated_secondary.artifact_id]</a><BR>"

			else
				dat += "No battery inserted.<BR>"

	else
		dat += "<B><font color=red>Unable to locate analysis pad.</font><BR></b>"
	//
	dat += "<HR>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh</A> <A href='?src=\ref[src];close=1'>Close<BR>"
	user << browse(dat, "window=artharvester;size=450x500")
	onclose(user, "artharvester")

/obj/machinery/artifact_harvester/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(harvesting > 0)
		//chargerate is chargemaxlevel/effectrange
		//creates variable charging rates, with the minimum being 0.5
		inserted_battery.stored_charge += chargerate

		//check if we've finished
		if(inserted_battery.stored_charge >= inserted_battery.capacity)
			inserted_battery.stored_charge = inserted_battery.capacity //Prevents overcharging
			use_power = 1
			harvesting = 0
			src.visible_message("<b>[name]</b> states, \"Battery is full.\"")
			src.investigation_log(I_ARTIFACT, "|| anomaly battery [inserted_battery.battery_effect.artifact_id] harvested by [key_name(harvester)]")
			icon_state = "incubator_old"

	else if(harvesting < 0)
		//dump some charge
		inserted_battery.stored_charge -= 2

		//do the effect
		if(inserted_battery.battery_effect)
			inserted_battery.battery_effect.process()

			//if the effect works by touch, activate it on anyone viewing the console
			/*if(inserted_battery.battery_effect.effect == 0)
				var/list/nearby = viewers(1, src)
				for(var/mob/M in nearby)
					if(M.machine == src)
						inserted_battery.battery_effect.DoEffectTouch(M) THIS IS RETARDED! - Angelite */

		//if there's no charge left, finish
		if(inserted_battery.stored_charge <= 0)
			use_power = 1
			inserted_battery.stored_charge = 0
			harvesting = 0
			if(inserted_battery.battery_effect && inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate()
			src.visible_message("<b>[name]</b> states, \"Battery dump completed.\"")
			icon_state = "incubator_old"

/obj/machinery/artifact_harvester/Topic(href, href_list)

	if(..())
		return

	if (href_list["harvestprimary"])
		if (isolated_primary)
			harvester = usr
				//there should already be a battery inserted, but this is just in case
			if(inserted_battery)
				//see if we can clear out an old effect
				//delete it when the ids match to account for duplicate ids having different effects
				if(inserted_battery.battery_effect && inserted_battery.stored_charge <= 0)
					qdel(inserted_battery.battery_effect)
					inserted_battery.battery_effect = null

				//only charge up
				var/matching_id = 0
				if(inserted_battery.battery_effect)
					matching_id = (inserted_battery.battery_effect.artifact_id == isolated_primary.artifact_id)
				var/matching_effecttype = 0
				if(inserted_battery.battery_effect)
					matching_effecttype = (inserted_battery.battery_effect.type == isolated_primary.type)
				if(!inserted_battery.battery_effect || (matching_id && matching_effecttype))
					chargerate = isolated_primary.chargelevelmax / isolated_primary.effectrange
					harvesting = 1
					use_power = 2
					icon_state = "incubator_old_on"
					var/message = "<b>[src]</b> states, \"Beginning artifact energy harvesting.\""
					src.visible_message(message)

					//duplicate the artifact's effect datum
					if(!inserted_battery.battery_effect)
						var/effecttype = isolated_primary.type
						var/datum/artifact_effect/E = new effecttype(inserted_battery)

						//duplicate it's unique settings
						for(var/varname in list("chargelevelmax","artifact_id","effect","effectrange","effect_type"))
							E.vars[varname] = isolated_primary.vars[varname]

						//duplicate any effect-specific settings
						if(isolated_primary.copy_for_battery && isolated_primary.copy_for_battery.len)
							for(var/varname in isolated_primary.copy_for_battery)
								E.vars[varname] = isolated_primary.vars[varname]

						//copy the new datum into the battery
						inserted_battery.battery_effect = E
						inserted_battery.stored_charge = 0
				else
					var/message = "<b>[src]</b> states, \"Cannot harvest. Incompatible energy signatures detected.\""
					src.visible_message(message)

	if (href_list["harvestsecondary"])
		if (isolated_secondary)
			harvester = usr
				//there should already be a battery inserted, but this is just in case
			if(inserted_battery)
				//see if we can clear out an old effect
				//delete it when the ids match to account for duplicate ids having different effects
				if(inserted_battery.battery_effect && inserted_battery.stored_charge <= 0)
					qdel(inserted_battery.battery_effect)
					inserted_battery.battery_effect = null

				//only charge up
				var/matching_id = 0
				if(inserted_battery.battery_effect)
					matching_id = (inserted_battery.battery_effect.artifact_id == isolated_secondary.artifact_id)
				var/matching_effecttype = 0
				if(inserted_battery.battery_effect)
					matching_effecttype = (inserted_battery.battery_effect.type == isolated_secondary.type)
				if(!inserted_battery.battery_effect || (matching_id && matching_effecttype))
					chargerate = isolated_secondary.chargelevelmax / isolated_secondary.effectrange
					harvesting = 1
					use_power = 2
					icon_state = "incubator_old_on"
					var/message = "<b>[src]</b> states, \"Beginning artifact energy harvesting.\""
					src.visible_message(message)

					//duplicate the artifact's effect datum
					if(!inserted_battery.battery_effect)
						var/effecttype = isolated_secondary.type
						var/datum/artifact_effect/E = new effecttype(inserted_battery)

						//duplicate it's unique settings
						for(var/varname in list("chargelevelmax","artifact_id","effect","effectrange","effect_type"))
							E.vars[varname] = isolated_secondary.vars[varname]

						//duplicate any effect-specific settings
						if(isolated_secondary.copy_for_battery && isolated_secondary.copy_for_battery.len)
							for(var/varname in isolated_secondary.copy_for_battery)
								E.vars[varname] = isolated_secondary.vars[varname]

						//copy the new datum into the battery
						inserted_battery.battery_effect = E
						inserted_battery.stored_charge = 0
				else
					var/message = "<b>[src]</b> states, \"Cannot harvest. Incompatible energy signatures detected.\""
					src.visible_message(message)

	if (href_list["stopharvest"])
		if(harvesting)
			if(harvesting < 0 && inserted_battery.battery_effect && inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate()
			harvesting = 0
			src.visible_message("<b>[name]</b> states, \"Activity interrupted.\"")
			icon_state = "incubator_old"
			src.investigation_log(I_ARTIFACT, "|| anomaly battery [inserted_battery.battery_effect.artifact_id] harvested by [key_name(harvester)]")

	if (href_list["alockon"])
		if(!artifact_field)
			cur_artifact = null
			var/articount = 0
			var/obj/machinery/artifact/analysed
			for(var/obj/machinery/artifact/A in get_turf(owned_scanner))
				analysed = A
				articount++

/*
			var/mundane = 0
			for(var/obj/O in get_turf(owned_scanner))
				if(O.invisibility)
					continue
				if(!istype(O, /obj/machinery/artifact) && !istype(O, /obj/machinery/artifact_scanpad))
					mundane++
					break
			for(var/mob/O in get_turf(owned_scanner))
				if(O.invisibility)
					continue
				mundane++
				break
*/
			if(!analysed)
				var/message = "<b>[src]</b> states, \"Cannot initialize field, no artifact detected.\""
				src.visible_message(message)
				return
			else if(articount == 1)
				cur_artifact = analysed

				var/turf/T = get_turf(owned_scanner)
				artifact_field = new(T)
				src.visible_message("<span class='notice'>[bicon(owned_scanner)] [owned_scanner] activates with a low hum.</span>")
				cur_artifact.anchored = 1
				cur_artifact.contained = 1
				cur_artifact.being_used = 1

	if (href_list["alockoff"])
		if (artifact_field)
			src.visible_message("<span class='notice'>[bicon(owned_scanner)] [owned_scanner] deactivates with a gentle shudder.</span>")
			qdel(artifact_field)
			artifact_field = null
			if(cur_artifact)
				cur_artifact.anchored = 0
				cur_artifact.being_used = 0
				cur_artifact.contained = 0
				cur_artifact = null
				isolated_primary = null
				isolated_secondary = null

	if (href_list["isolateeffect"])
		if (artifact_field && cur_artifact)
			isolated_primary = null
			isolated_secondary = null
			if (cur_artifact.primary_effect.activated || cur_artifact.primary_effect.isolated)
				isolated_primary = cur_artifact.primary_effect
				var/message = "<b>[src]</b> states, \"Exotic particle signature ID: [cur_artifact.primary_effect.artifact_id] successfully isolated.\""
				src.visible_message(message)
			if (cur_artifact.secondary_effect)
				if (cur_artifact.secondary_effect.activated || cur_artifact.secondary_effect.isolated)
					isolated_secondary = cur_artifact.secondary_effect
					var/message = "<b>[src]</b> states, \"Exotic particle signature ID: [cur_artifact.secondary_effect.artifact_id] successfully isolated.\""
					src.visible_message(message)
			if (!isolated_primary && !isolated_secondary)
				var/message = "<b>[src]</b> states, \"Cannot isolate exotic particles, none detected.\""
				src.visible_message(message)
				return

	if (href_list["ejectbattery"])
		if(inserted_battery)
			src.inserted_battery.forceMove(src.loc)
			src.inserted_battery = null

	if (href_list["drainbattery"])
		if(inserted_battery)
			if(inserted_battery.battery_effect && inserted_battery.stored_charge > 0)
				if(alert("This action will dump all charge, safety gear is recommended before proceeding","Warning","Continue","Cancel"))
					if(!inserted_battery.battery_effect.activated)
						inserted_battery.battery_effect.ToggleActivate(0)
					harvesting = -1
					use_power = 2
					icon_state = "incubator_old_on"
					var/message = "<b>[src]</b> states, \"Warning, battery charge dump commencing.\""
					src.visible_message(message)
			else
				var/message = "<b>[src]</b> states, \"Cannot dump energy. Battery is drained of charge already.\""
				src.visible_message(message)
		else
			var/message = "<b>[src]</b> states, \"Cannot dump energy. No battery inserted.\""
			src.visible_message(message)

	if(href_list["close"])
		usr << browse(null, "window=artharvester")
		usr.unset_machine(src)

	updateDialog()

/obj/effect/artifact_field
	name = "energy field"
	icon = 'icons/effects/effects.dmi'
	anchored = 1
	density = 1
	mouse_opacity = 0
	icon_state = "shield2"