/datum/wires/explosive
	wire_count = 1

var/const/WIRE_EXPLODE = 1

/datum/wires/explosive/proc/explode()
	return

/datum/wires/explosive/UpdatePulsed(var/index)
	switch(index)
		if(WIRE_EXPLODE)
			explode()

/datum/wires/explosive/UpdateCut(var/index, var/mended, var/mob/user)
	switch(index)
		if(WIRE_EXPLODE)
			if(!mended)
				explode()

/datum/wires/explosive/plastic
	holder_type = /obj/item/weapon/c4

/datum/wires/explosive/plastic/CanUse(var/mob/living/L)
	if(!..())
		return 0
	var/obj/item/weapon/c4/P = holder
	if(P.open_panel)
		return 1
	return 0

/datum/wires/explosive/plastic/explode()
	var/obj/item/weapon/c4/P = holder
	P.explode(get_turf(P))
