/datum/wires/vending
	holder_type = /obj/machinery/vending
	wire_count = 5

/datum/wires/vending/New()
	wire_names=list(
		"[VENDING_WIRE_THROW]" 		= "Firing",
		"[VENDING_WIRE_CONTRABAND]" = "Contraband",
		"[VENDING_WIRE_ELECTRIFY]" 	= "Shock",
		"[VENDING_WIRE_IDSCAN]" 	= "ID Scan",
		"[VENDING_WIRE_SHUTUP]" 	= "Speaker"
	)
	..()

var/const/VENDING_WIRE_THROW = 1
var/const/VENDING_WIRE_CONTRABAND = 2
var/const/VENDING_WIRE_ELECTRIFY = 4
var/const/VENDING_WIRE_IDSCAN = 8
var/const/VENDING_WIRE_SHUTUP = 16

/datum/wires/vending/CanUse(var/mob/living/L)
	if(!..())
		return 0
	var/obj/machinery/vending/V = holder
	if(!istype(L, /mob/living/silicon))
		if(V.seconds_electrified)
			var/obj/I = L.get_active_hand()
			if(V.shock(L, 100, get_conductivity(I)))
				return 0
	if(V.panel_open)
		return 1
	return 0

/datum/wires/vending/GetInteractWindow()
	var/obj/machinery/vending/V = holder
	. += ..()
	. += "<BR>The orange light is [V.seconds_electrified ? "on" : "off"].<BR>"
	. += "The red light is [V.shoot_inventory ? "off" : "blinking"].<BR>"
	. += "The green light is [V.extended_inventory ? "on" : "off"].<BR>"
	. += "A [V.scan_id ? "purple" : "yellow"] light is on.<BR>"
	. += "The speaker indicator is [V.shut_up ? "off" : "on"].<BR>"
	. += "The return box printer is <B>[V.cardboard ? "loaded</B>. Ready for disassembly." : "unloaded</B>. Insert cardboard."]<BR>"

/datum/wires/vending/UpdateCut(var/index, var/mended)
	var/obj/machinery/vending/V = holder
	if(V.unhackable)
		return
	..()
	switch(index)
		if(VENDING_WIRE_THROW)
			V.shoot_inventory = !mended
		if(VENDING_WIRE_CONTRABAND)
			V.extended_inventory = 0
		if(VENDING_WIRE_ELECTRIFY)
			if(mended)
				V.seconds_electrified = 0
			else
				V.seconds_electrified = -1
		if(VENDING_WIRE_IDSCAN)
			V.scan_id = 1
		if(VENDING_WIRE_SHUTUP)
			V.shut_up = 1
	SStgui.update_uis(holder)


/datum/wires/vending/UpdatePulsed(var/index)
	var/obj/machinery/vending/V = holder
	if(V.unhackable)
		return
	..()
	switch(index)
		if(VENDING_WIRE_THROW)
			V.shoot_inventory = !V.shoot_inventory
		if(VENDING_WIRE_CONTRABAND)
			V.extended_inventory = !V.extended_inventory
		if(VENDING_WIRE_ELECTRIFY)
			V.seconds_electrified = 30
		if(VENDING_WIRE_IDSCAN)
			V.scan_id = !V.scan_id
		if(VENDING_WIRE_SHUTUP)
			V.shut_up = !V.shut_up
	SStgui.update_uis(holder)
