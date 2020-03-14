
var/global/list/synth_designs = list(
list("category" = "resources", "name" = "sulfuric acid bottle", "path" = /obj/item/weapon/reagent_containers/glass/bottle/sacid, "cost" = 100),
list("category" = "resources", "name" = "20 iron", "path" = /obj/item/stack/sheet/metal/bigstack, "cost" = 100),
list("category" = "resources", "name" = "20 glass", "path" = /obj/item/stack/sheet/glass/glass/bigstack, "cost" = 100),
list("category" = "resources", "name" = "20 plasteel", "path" = /obj/item/stack/sheet/plasteel/bigstack, "cost" = 100),
list("category" = "resources", "name" = "20 plasmaglass", "path" = /obj/item/stack/sheet/glass/plasmaglass/bigstack, "cost" = 100),
list("category" = "resources", "name" = "20 wood", "path" = /obj/item/stack/sheet/wood/bigstack, "cost" = 100),
list("category" = "resources", "name" = "20 plastic", "path" = /obj/item/stack/sheet/mineral/plastic/bigstack, "cost" = 200),
list("category" = "resources", "name" = "aluminum foam grenade", "path" = /obj/item/weapon/grenade/chem_grenade/metalfoam, "cost" = 100),
list("category" = "resources", "name" = "iron foam grenade", "path" = /obj/item/weapon/grenade/chem_grenade/ironfoam, "cost" = 100),
list("category" = "resources", "name" = "camera assembly", "path" = /obj/item/weapon/camera_assembly, "cost" = 100),


list("category" = "tools", "name" = "socket wrench", "path" = /obj/item/weapon/wrench/socket, "cost" = 1000), //One gigawatt
list("category" = "tools", "name" = "foam extinguisher", "path" = /obj/item/weapon/extinguisher/foam, "cost" = 1000),
list("category" = "tools", "name" = "empty O2 tank", "path" = /obj/item/weapon/tank/oxygen/empty, "cost" = 1000),
list("category" = "tools", "name" = "empty plasma tank", "path" = /obj/item/weapon/tank/plasma/empty, "cost" = 1000),
list("category" = "tools", "name" = "flare gun ammunition", "path" =/obj/item/ammo_storage/box/flare, cost = 700),
list("category" = "tools", "name" = "flare gun", "path" =/obj/item/weapon/gun/projectile/flare, cost = 2000),

list("category" = "machinery", "name" = "air pump", "path" = /obj/machinery/portable_atmospherics/pump, "cost" = 500),
list("category" = "machinery", "name" = "portable scrubber", "path" = /obj/machinery/portable_atmospherics/scrubber, "cost" = 500),
list("category" = "machinery", "name" = "space heater", "path" = /obj/machinery/space_heater, "cost" = 500),
list("category" = "machinery", "name" = "air conditioner", "path" = /obj/machinery/space_heater/air_conditioner, "cost" = 500),
list("category" = "machinery", "name" = "cart", "path" = /obj/machinery/cart/cargo, "cost" = 200),
list("category" = "machinery", "name" = "tractor", "path" = /obj/structure/bed/chair/vehicle/tractor, "cost" = 2000),
list("category" = "machinery", "name" = "rad collector", "path" = /obj/machinery/power/rad_collector, "cost" = 1000),
list("category" = "machinery", "name" = "emitter", "path" = /obj/machinery/power/emitter, "cost" = 1000),
list("category" = "machinery", "name" = "prism", "path" = /obj/machinery/prism, "cost" = 2000),
list("category" = "machinery", "name" = "MSGS", "path" = /obj/machinery/atmospherics/binary/msgs/unanchored, "cost" = 2000),
)

/obj/machinery/power/antiquesynth
	name = "antique matter synthesizer"
	desc = "An ancient piece of salvaged tech from a period before matter synthesizers were small enough to be moved around. This one is designed with industrial purposes in mind and consumes huge amounts of power."

	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "scanner_0old"

	use_power = 1
	density = 1
	anchored = 0
	machine_flags = WRENCHMOVE | FIXED2WORK | EMAGGABLE
	req_access = list(access_engine)

	var/consumption = 0 //How much are we set to draw off the net? Clamped between 0 and 2 GIGAWATT (2,000,000,000 Watts)
	var/on = 0
	var/charge = 0 //How much we've stored. Also capped at 2 GIGAWATT.
	var/charged_last_tick = 0
	var/category = "resources" //which list to display
	var/list/categories = list(list("category" = "resources"), list("category" = "tools"), list("category" = "machinery")) //Yes it is necessary to write the list like this

/obj/machinery/power/antiquesynth/proc/toggle_power()
	on = !on
	if(!get_powernet())
		on = FALSE
		visible_message("<span class='warning'>The [src] buzzes and shuts off.</span>")
	update_icon()

/obj/machinery/power/antiquesynth/update_icon()
	return
	//Maybe I'll add more?

/obj/machinery/power/antiquesynth/process()
	charged_last_tick = 0
	if(!on)
		return
	if(!anchored || !get_powernet())
		toggle_power()
		return
	if(charge >= 2*GIGAWATT)
		charge = min(charge, 2*GIGAWATT)
		return //We can't get more charged than this!
	if(avail()>consumption)
		charged_last_tick = 1
		charge += consumption
		add_load(consumption)
		nanomanager.update_uis(src)

/obj/machinery/power/antiquesynth/attack_ai(mob/user)
	if(isAdminGhost(user))
		attack_hand(user)
	else
		to_chat(user, "<span class='warning'>You aren't equipped to interface with technology this old!</span>")

/obj/machinery/power/antiquesynth/attack_hand(mob/user)
	return ui_interact(user)

/obj/machinery/power/antiquesynth/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if (gcDestroyed || !get_turf(src) || !anchored)
		if(!ui)
			ui = nanomanager.get_open_ui(user, src, ui_key)
		if(ui)
			ui.close()
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["name"] = name
	data["powered"] = !(stat & NOPOWER)
	data["charge"] = charge/MEGAWATT //Charge given in megawatts not watts
	data["charging"] = charged_last_tick
	data["consumption"] = round(consumption/MEGAWATT,0.1) //ditto
	data["active"] = on
	data["synthList"] = synth_designs
	data["selectedCategory"] = category
	data["categories"] = categories

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "antiquems.tmpl", "Antique Matter Synthesizer", 520, 460)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		//ui.set_auto_update(1)

/obj/machinery/power/antiquesynth/Topic(href, href_list)
	if(..())
		return
	if(usr.incapacitated() || (!Adjacent(usr)&&!isAdminGhost(usr)) || !usr.dexterity_check())
		return
	if(!allowed(usr) && !emagged)
		to_chat(usr,"<span class='warning'>Access denied.</span>")
		return
	if(issilicon(usr))
		to_chat(usr,"<span class='warning'>You are not compatible with this device.</span>")
		return

	if(href_list["toggle"])
		toggle_power()
	if(href_list["set_draw"])
		consumption = input("Megajoules to draw per tick: ", "1MW = 1000kW = 1000000W", consumption/MEGAWATT) as num
		consumption = round(Clamp(consumption*MEGAWATT, 0, 2*GIGAWATT)) //we're storing the actual number of watts but only displaying the users the mw conversion
	if(href_list["synth"])
		locate_data(href_list["synth"]) //Even though the list contains a path, hrefs only pass text so let's use name here instead of path
	if(href_list["category"])
		category = href_list["category"]
	update_icon()
	return 1

/obj/machinery/power/antiquesynth/proc/locate_data(var/name)
	for(var/element in synth_designs)
		if(element["name"] == name)
			synth(element["path"],element["cost"])
			return //Exit

/obj/machinery/power/antiquesynth/proc/synth(var/obj/O,var/cost)
	if(charge >= cost*MEGAWATT)
		charge = max(0, charge - cost*MEGAWATT)
		nanomanager.update_uis(src)
		new O(get_turf(src))
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
	spark(src, 10, FALSE)


/obj/machinery/power/antiquesynth/wrenchAnchor(var/mob/user)
	if(!..())
		return
	if(anchored)
		connect_to_network()
	else
		disconnect_from_network()
	power_change()
	update_icon()
