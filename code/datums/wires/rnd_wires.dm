/datum/wires/rnd
	holder_type = /obj/machinery/r_n_d
	wire_count = 5

/datum/wires/rnd/New()
	wire_names=list(
		"[RND_WIRE_DISABLE]"	= "Disable",
		"[RND_WIRE_SHOCK]" 		= "Shock",
		"[RND_WIRE_HACK]" 		= "Hack",
		"[RND_WIRE_AUTOMAKE]"	= "Automake",
		"[RND_WIRE_JOBFINISHED]"= "Job finished"
	)
	..()

var/const/RND_WIRE_DISABLE = 1
var/const/RND_WIRE_SHOCK = 2
var/const/RND_WIRE_HACK = 4
var/const/RND_WIRE_AUTOMAKE = 8
var/const/RND_WIRE_JOBFINISHED = 16

/datum/wires/rnd/CanUse(var/mob/living/L)
	if(!..())
		return 0
	var/obj/machinery/r_n_d/rnd = holder
	if(rnd.panel_open)
		return 1
	return 0

/datum/wires/rnd/GetInteractWindow()
	var/obj/machinery/r_n_d/rnd = holder
	. += ..()
	. += "The red light is [rnd.disabled ? "off" : "on"].<BR>"
	. += "The green light is [rnd.shocked ? "off" : "on"].<BR>"
	. += "The blue light is [rnd.hacked ? "off" : "on"].<BR>"
	. += "The yellow light is [rnd.auto_make ? "on": "off"].<BR>"


/datum/wires/rnd/UpdateCut(var/index, var/mended, var/mob/user)
	var/obj/machinery/r_n_d/rnd = holder
	..()
	switch(index)
		if(RND_WIRE_DISABLE)
			rnd.disabled = !mended
		if(RND_WIRE_SHOCK)
			rnd.shocked = (mended ? 0 : -1)
		if(RND_WIRE_HACK)
			rnd.hacked = 0
			rnd.update_hacked()
		if(RND_WIRE_AUTOMAKE)
			rnd.auto_make = 0


/datum/wires/rnd/UpdatePulsed(var/index)
	var/obj/machinery/r_n_d/rnd = holder
	..()
	switch(index)
		if(RND_WIRE_DISABLE)
			rnd.disabled = !rnd.disabled
		if(RND_WIRE_SHOCK)
			rnd.shocked += 30
		if(RND_WIRE_HACK)
			rnd.hacked = !rnd.hacked
			rnd.update_hacked()
		if(RND_WIRE_AUTOMAKE)
			rnd.auto_make = !rnd.auto_make