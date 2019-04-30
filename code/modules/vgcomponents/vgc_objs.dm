//ma physical forms
/obj/item/vgc_assembly
	name = "vg-station component assembly"
	desc = "holds alot of components" //maybe make this show the circuit someday
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "infrared"

/obj/item/vgc_assembly/New(var/datum/vgassembly/nvga)
	vga = nvga

/obj/item/vgc_assembly/Destroy()
	vga = null
	..()

/obj/item/vgc_assembly/examine(mob/user, size, show_name)
	. = ..()
	vga.showCircuit(user)

/obj/item/vgc_obj //basically holds a parentless component
	name = "vg-station component"
	desc = "used to make logic happen"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "circuit_+"
	var/datum/vgcomponent/vgc = null

/obj/item/vgc_obj/New(var/datum/vgcomponent/nvgc)
	vgc = nvgc

/obj/item/vgc_obj/Destroy()
	vgc = null
	..()

/obj/item/vgc_obj/door_controller
	name="door controller"
	desc="controls doors"

/obj/item/vgc_obj/door_controller/attackby(obj/item/weapon/W, mob/user) //setting access
	if(!vgc)
		return //how
	
	if(!istype(vgc, /datum/vgcomponent/doorController))
		return

	if(!istype(W, /obj/item/weapon/card/id))
		return
	
	var/datum/vgcomponent/doorController/DC = vgc
	DC.setAccess(W)

/obj/item/vgc_obj/debugger
	name="debugger"
	desc="you should not have this"

/obj/item/vgc_obj/signaler
	name="signaler"
	desc="receives and sends signals"

/obj/item/vgc_logictool
	name="logictool"
	desc="to look at embedded assemblies"

/obj/item/vgc_assembly/doorTest/New()
	var/datum/vgassembly/A = new ()
	..(A)
	var/datum/vgcomponent/doorController/D = new ()
	var/datum/vgcomponent/signaler/S = new ()
	D.Install(vga)
	D.saved_access = get_absolutely_all_accesses()
	S.Install(vga) //default 1457 30
	S.setOutput("signalled", D)