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
	name = "vg-station component"
	desc = "used to make logic happen"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "circuit_+"
	var/datum/vgcomponent/vgc = null
	var/datum_type = /datum/vgcomponent

/obj/item/vgc_obj/New(var/datum/vgcomponent/nvgc)
	..()
	if(!istype(nvgc, datum_type))
		nvgc = new datum_type()
	vgc = nvgc

/obj/item/vgc_obj/Destroy()
	vgc = null
	..()

/*
Components
*/
/obj/item/vgc_obj/door_controller
	name="door controller"
	desc="controls doors"
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
	to_chat(user, "you set the doorcontroller's access")

/obj/item/vgc_obj/debugger
	name="debugger"
	desc="you should not have this"
	datum_type = /datum/vgcomponent/debugger

/obj/item/vgc_obj/signaler
	name="signaler"
	desc="receives and sends signals"
	datum_type = /datum/vgcomponent/signaler

/obj/item/vgc_obj/button
	name="button"
	desc="press to send a signal"
	datum_type = /datum/vgcomponent/button

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