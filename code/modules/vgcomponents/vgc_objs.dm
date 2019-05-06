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
	vga = nvga
	vga._parent = src

/obj/item/vgc_assembly/Destroy()
	vga = null
	..()

/obj/item/vgc_assembly/examine(mob/user, size, show_name)
	. = ..()
	vga.showCircuit(user)

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

/obj/item/vgc_obj/debugger
	datum_type = /datum/vgcomponent/debugger

/obj/item/vgc_obj/signaler
	datum_type = /datum/vgcomponent/signaler

/obj/item/vgc_obj/button
	datum_type = /datum/vgcomponent/button

/obj/item/vgc_obj/splitter
	datum_type = /datum/vgcomponent/splitter

/obj/item/vgc_obj/speaker
	datum_type = /datum/vgcomponent/speaker

/obj/item/vgc_obj/keyboard
	datum_type = /datum/vgcomponent/keyboard

/*
Logictool
*/
/obj/item/vgc_logictool
	name="logictool"
	desc="to look at embedded assemblies"
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "meter"

/*
Testing stuff
*/
/obj/item/vgc_assembly/doorTest/New()
	var/datum/vgassembly/A = new ()
	..(A)
	var/datum/vgcomponent/doorController/D = new ()
	var/datum/vgcomponent/signaler/S = new ()
	D.Install(vga)
	D.saved_access = get_absolutely_all_accesses()
	S.Install(vga) //default 1457 30
	S.setOutput("signaled", D, "toggle")

/obj/item/vgc_assembly/debugTest/New()
	var/datum/vgassembly/A = new ()
	..(A)
	var/datum/vgcomponent/debugger/D = new ()
	var/datum/vgcomponent/signaler/S = new ()
	D.Install(vga)
	S.Install(vga) //default 1457 30
	S.setOutput("signaled", D)