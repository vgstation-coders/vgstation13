//ma physical forms
/obj/item/vgc_assembly
    name = "vg-station component assembly"
    desc = "holds alot of components" //maybe make this show the circuit someday

/obj/item/vgc_assembly/New(var/datum/vgassembly/nvga)
    vga = nvga

/obj/item/vgc_assembly/Destroy()
    vga = null
    ..()

/obj/item/vgc_obj //basically holds a parentless component
    name = "vg-station component"
    desc = "used to make logic happen"
    var/datum/vgcomponent/vgc = null

/obj/item/vgc_obj/New(var/datum/vgcomponent/nvgc)
    vgc = nvgc

/obj/item/vgc_obj/Destroy()
    vgc = null
    ..()

/obj/item/vgc_obj/door_controller
    name="door controller"
    desc="controls doors"

/obj/item/vgc_obj/debugger
    name="debugger"
    desc="you should not have this"

/obj/item/vgc_logictool
    name="logictool"
    desc="to look at embedded assemblies TODO"