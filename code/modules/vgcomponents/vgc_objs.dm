/*
Base Assembly
*/
/obj/item/vgc_assembly
	name = "vg-station component assembly"
	desc = "holds alot of components" //maybe make this show the circuit someday
	icon = 'icons/obj/remote.dmi'
	icon_state = "remote_3b"
	var/datum_type = /datum/vgassembly

/obj/item/vgc_assembly/New(var/datum/vgassembly/nvga)
	..()
	if(!istype(nvga, datum_type))
		nvga = new datum_type()
	nvga.attachTo(src)

/obj/item/vgc_assembly/Destroy()
	vga = null
	..()

/obj/item/vgc_assembly/examine(mob/user, size, show_name)
	. = ..()
	vga.showCircuit(user)

/obj/item/vgc_assembly/proc/attachTo(var/obj/O)
	vga.attachTo(O)
	qdel(src)

/obj/item/vgc_assembly/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/vgc_obj))
		var/obj/item/vgc_obj/CO = W
		CO.Install(vga)
		to_chat(user, "You install \the [W.name] into \the [vga.name].")
		return 1
	else if(istype(W, /obj/item/vgc_logictool))
		vga.showCircuit(user)
		to_chat(user, "You bring up the circuit on \the [W.name].")
		return 1

	vga.touched(W, user)
	return 1

/obj/item/vgc_assembly/robot_small
	datum_type = /datum/vgassembly/robot_small
	icon = 'icons/obj/vgassemblies/bots.dmi'
	icon_state = "bot_small"

/obj/item/vgc_assembly/attachable_small
	datum_type = /datum/vgassembly/attachable_small

/obj/item/vgc_assembly/attachable_big
	datum_type = /datum/vgassembly/attachable_big

/obj/item/vgc_assembly/handheld
	datum_type = /datum/vgassembly/handheld

/obj/item/vgc_assembly/tablet
	datum_type = /datum/vgassembly/tablet

//TODO this should probably not be an item
/obj/item/vgc_assembly/robot_big
	datum_type = /datum/vgassembly/robot_big
	icon = 'icons/obj/vgassemblies/bots.dmi'
	icon_state = "bot_big"

//TODO this should probably not be an item
/obj/item/vgc_assembly/anchored
	datum_type = /datum/vgassembly/anchored
	anchored = 1


/*
Testing stuff
*/
/obj/item/vgc_assembly/doorTest/New()
	var/datum/vgc_assembly/robot_big/A = new ()
	..(A)
	var/datum/vgcomponent/doorController/D = new ()
	var/datum/vgcomponent/signaler/S = new ()
	D.Install(vga)
	D.saved_access = get_absolutely_all_accesses()
	S.Install(vga) //default 1457 30
	S.addOutput(D,"signaled", "toggle")

	new /obj/item/device/assembly/signaler(get_turf(src))

/obj/item/vgc_assembly/debugTest/New()
	var/datum/vgc_assembly/robot_big/A = new ()
	..(A)
	var/datum/vgcomponent/debugger/D = new ()
	var/datum/vgcomponent/signaler/S = new ()
	var/datum/vgcomponent/processor/cleaner/C = new ()
	D.Install(vga)
	S.Install(vga) //default 1457 30
	C.Install(vga)
	S.addOutput(D, "signaled")
	D.addOutput(C, "toggle")

	new /obj/item/device/assembly/signaler(get_turf(src))

/obj/item/vgc_assembly/debugkit/New()
	var/datum/vgc_assembly/robot_big/A = new ()
	..(A)
	for(var/T in typesof(/datum/vgcomponent))
		var/datum/vgcomponent/C = new T()
		if(C.name == "VGComponent") //its the default one! BAIL
			continue
		C.Install(vga)

	//spawn utilities
	new /obj/item/vgc_logictool(get_turf(src))

/*
Base Component
*/
/obj/item/vgc_obj
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "circuit_+"
	var/datum/vgcomponent/vgc = null
	var/datum_type = /datum/vgcomponent

/obj/item/vgc_obj/New(var/datum/vgcomponent/nvgc)
	..()
	if(!istype(nvgc, datum_type))
		nvgc = new datum_type()
	vgc = nvgc
	name = vgc.name
	desc = vgc.desc

/obj/item/vgc_obj/Destroy()
	vgc = null
	..()

/obj/item/vgc_obj/attack_self(mob/user)
	if(!vgc)
		return

	if(vgc.has_settings)
		vgc.openSettings(user)

/obj/item/vgc_obj/proc/Install(var/datum/vgassembly/vga)
	if(vgc.Install(vga))
		qdel(src)

/*
Components
*/
/obj/item/vgc_obj/door_controller
	datum_type = /datum/vgcomponent/doorController

/obj/item/vgc_obj/door_controller/attackby(obj/item/weapon/W, mob/user) //setting access
	if(!vgc)
		return //how

	if(!istype(vgc, datum_type))
		return

	if(!istype(W, /obj/item/weapon/card/id))
		return

	var/datum/vgcomponent/doorController/DC = vgc
	DC.setAccess(W)
	to_chat(user, "You set \the [src.name]'s access")

/obj/item/vgc_obj/cleaner
	datum_type = /datum/vgcomponent/processor/cleaner

/obj/item/vgc_obj/debugger
	datum_type = /datum/vgcomponent/debugger

/obj/item/vgc_obj/signaler
	datum_type = /datum/vgcomponent/signaler

/obj/item/vgc_obj/button
	datum_type = /datum/vgcomponent/button

/obj/item/vgc_obj/button/toggle
	datum_type = /datum/vgcomponent/button/toggle

/obj/item/vgc_obj/gate_button
	datum_type = /datum/vgcomponent/gate_button

/obj/item/vgc_obj/speaker
	datum_type = /datum/vgcomponent/speaker

/obj/item/vgc_obj/keyboard
	datum_type = /datum/vgcomponent/keyboard

/obj/item/vgc_obj/prox_sensor
	datum_type = /datum/vgcomponent/processor/prox_sensor

/obj/item/vgc_obj/add
	datum_type = /datum/vgcomponent/algorithmic/add

/obj/item/vgc_obj/sub
	datum_type = /datum/vgcomponent/algorithmic/sub

/obj/item/vgc_obj/mult
	datum_type = /datum/vgcomponent/algorithmic/mult

/obj/item/vgc_obj/div1
	datum_type = /datum/vgcomponent/algorithmic/div1

/obj/item/vgc_obj/div2
	datum_type = /datum/vgcomponent/algorithmic/div2

/obj/item/vgc_obj/appender
	datum_type = /datum/vgcomponent/appender

/obj/item/vgc_obj/index_getter
	datum_type = /datum/vgcomponent/index_getter

/obj/item/vgc_obj/list_iterator
	datum_type = /datum/vgcomponent/list_iterator

/obj/item/vgc_obj/typecheck
	datum_type = /datum/vgcomponent/typecheck

/obj/item/vgc_obj/typecheck/preattack(var/atom/A, mob/user, proximity_flag)
	if(!vgc || !A || !user)
		return //how

	if(!istype(vgc, datum_type))
		return

	if(proximity_flag != 1)
		return

	var/datum/vgcomponent/typecheck/V = vgc

	if(!V.waitingForType)
		return

	V.costum_type = A.type
	V.waitingForType = 0
	to_chat(user, "You copied \the [A]'s type into \the [src.name]'s memory")

/*
Logictool
*/
/obj/item/vgc_logictool
	name="logictool"
	desc="to look at embedded assemblies"
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "meter"
