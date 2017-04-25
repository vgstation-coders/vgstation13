/obj/machinery/vaporizer
	name = "industrial vaporizer"
	desc = "A vaporizer which uses power to synthesize liquid oxygen and nitrogen when supplied with vapor salts."

	icon = 'icons/obj/atmos.dmi'
	icon_state = "psiphon:0"

	use_power = 1
	density = 1
	machine_flags = WRENCHMOVE | FIXED2WORK
	flags = OPENCONTAINER | NOREACT
	req_access = list(access_atmospherics)

	var/obj/item/weapon/reagent_containers/glass/beaker/noreact/large/mixing_chamber = null //We can't just use a holder because the machine is NOREACT,
																					//we need an internal holder without that flag.

	var/mixrate = 0 //Rate at which Vapor Salts are added. Cannot be higher than 50.
	var/mixratio = 20 //Percent Oxygen to synthesize.
	var/on = 0
	var/waiting_for_ID = 0
	var/unlocked = 0
	var/power_use_this_tick = 0

	//TODO: Loadable cell for on-the-go synthesis?
	//Expected Energy Cost Per Second (EECPS)?
	//Allow delimiting via maintenance panel?

/obj/machinery/vaporizer/New()
	..()
	create_reagents(1000)
	mixing_chamber = new(src)

/obj/machinery/vaporizer/Destroy()
	..()
	qdel(mixing_chamber)
	mixing_chamber = null

/obj/machinery/vaporizer/proc/toggle_power()
	on = !on
	if(stat & (BROKEN|NOPOWER))
		on = FALSE
		visible_message("<span class='warning'>The [src] buzzes and shuts off.</span>")

/obj/machinery/vaporizer/process()
	if(!on)
		return
	if(!anchored || (stat & (BROKEN|NOPOWER)))
		toggle_power()
		return
	if(mixrate)
		reagents.trans_id_to(mixing_chamber,VAPORSALT,mixrate)
		nanomanager.update_uis(src)
	power_use_this_tick = 0
	if(mixing_chamber.reagents.get_reagent_amount(VAPORSALT)>50)
		//We're not supposed to have more than 50u
		visible_message("<span class='notice'>The [src]'s centrifugal limiter begins to whirr...</span>")
		power_use_this_tick += 30
		mixing_chamber.reagents.trans_id_to(reagents,VAPORSALT,mixing_chamber.reagents.get_reagent_amount(VAPORSALT)-50)
	if(mixing_chamber.reagents.has_reagent(VAPORSALT))
		var/target_value = mixing_chamber.reagents.get_reagent_amount(VAPORSALT)*0.01
		handle_tanks(target_value*mixratio,OXYGEN)
		handle_tanks(target_value*(100-mixratio),NITROGEN)
		nanomanager.update_uis(src)
	use_power(power_use_this_tick)

/obj/machinery/vaporizer/proc/force_reaction()
	mixing_chamber.flags &= ~NOREACT
	mixing_chamber.reagents.handle_reactions()
	nanomanager.update_uis(src)

/obj/machinery/vaporizer/proc/handle_tanks(var/target, var/rid)
	if(stat & (BROKEN|NOPOWER))
		visible_message("<span class='warning'>The [src] buzzes and shuts off.</span>")
		on = 0
		return
	mixing_chamber.flags |= NOREACT
	while(target>0)
		//First, try to pull out from the main tank
		if(reagents.has_reagent(rid))
			target -= reagents.trans_id_to(mixing_chamber,rid,min(target,1))
		//Next, if there ISN'T oxygen, let's electrolyze water instead because that's energy-cheaper than synthesis (30 charge for 0.5 oxygen is 40% the cost)
		else if(rid == OXYGEN && reagents.get_reagent_amount(WATER)>=1) //Don't bother if it's less than 1u
			reagents.remove_reagent(WATER,1)
			mixing_chamber.reagents.add_reagent(OXYGEN,min(target,0.5))
			target -= min(0.5,target)
			visible_message(target)
			power_use_this_tick += 30
		//We still need O2 and have no other sources. We can burn 150 charge per unit.
		else
			mixing_chamber.reagents.add_reagent(rid,min(target,1))
			target -= min(1,target)
			visible_message(target)
			power_use_this_tick += 150
	mixing_chamber.flags &= ~NOREACT
	mixing_chamber.reagents.handle_reactions()

/obj/machinery/vaporizer/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/vaporizer/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/vaporizer/attack_hand(var/mob/user as mob)
	return ui_interact(user)

/obj/machinery/vaporizer/attackby(obj/item/weapon/W, mob/living/user)
	..()
	if(waiting_for_ID && istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda) && allowed(user) && !unlocked)
		unlocked = 1
		to_chat(user,"<span class='notice'>You authorize the dump protocol.</span>")
	nanomanager.update_uis(src)

/obj/machinery/vaporizer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if (gcDestroyed || !get_turf(src))
		if(!ui)
			ui = nanomanager.get_open_ui(user, src, ui_key)
		if(ui)
			ui.close()
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["name"] = name
	data["powered"] = !(stat & NOPOWER)
	data["tankVolume"] = reagents.total_volume
	data["mixrate"] = mixrate
	data["mixratio"] = mixratio
	data["valveOpen"] = on
	data["awaiting_ID"] = waiting_for_ID
	data["unlocked"] = unlocked

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "vaporizer.tmpl", "Industrial Vaporizer", 500, 350)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		//ui.set_auto_update(1)

/obj/machinery/vaporizer/Topic(href, href_list)
	if(..())
		return
	if(!allowed(usr))
		to_chat(usr,"<span class='warning'>Access denied.</span>")
		return

	if(href_list["toggle"])
		toggle_power()
		investigation_log(I_ATMOS, "had its valve [on ? "opened" : "closed"] by [key_name(usr)].")
	if(href_list["set_mixrate"])
		mixrate = input("New mix rate", "Units of vapor salts per tick: ", mixrate) as num
		mixrate = round(Clamp(mixrate, 0, 50))
	if(href_list["set_mixratio"])
		mixratio = input("New mix ratio", "Percentage of oxygen to synthesize: ", mixratio) as num
		mixratio = round(Clamp(mixratio, 0, 100))
	if(href_list["prepare_dump"])
		waiting_for_ID = !waiting_for_ID
	if(href_list["dump_contents"])
		reagents.clear_reagents()
		mixing_chamber.reagents.clear_reagents()
		unlocked = 0
		waiting_for_ID = 0
	if(href_list["force"])
		force_reaction()
	add_fingerprint(usr)
	update_icon()
	nanomanager.update_uis(src)
	return 1