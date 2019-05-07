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

/obj/item/vgc_obj/button/toggle
	datum_type = /datum/vgcomponent/button/toggle

/obj/item/vgc_obj/splitter
	datum_type = /datum/vgcomponent/splitter

/obj/item/vgc_obj/speaker
	datum_type = /datum/vgcomponent/speaker

/obj/item/vgc_obj/keyboard
	datum_type = /datum/vgcomponent/keyboard

/obj/item/vgc_obj/prox_sensor
	datum_type = /datum/vgcomponent/prox_sensor

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

	if(!vgc.waitingForType)
		return
	
	vgc.costum_type = A.type
	vgc.waitingForType = 0
	to_chat(user, "You copied \the [A]'s type into \the [src.name]'s memory")

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

/obj/item/vgc_assembly/full_house/New()
	var/datum/vgassembly/A = new ()
	..(A)
	for(var/T in typesof(/datum/vgcomponent))
		var/datum/vgcomponent/C = new T()
		if(!C.name) //unspawnable components tend to have no name
			return
		C.Install(vga)

	//spawn utilities
	var/obj/item/vgc_logictool/tool = new (get_turf(src))