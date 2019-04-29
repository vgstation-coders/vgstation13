//needs a way to
//- prevent endless loops

obj
    var/datum/vgassembly/vga = null //component assembly

datum/vgassembly
    var/_parent
    var/list/_vgcs //list of vgcs contained inside

datum/vgassembly/Destroy()
    ..()
    _parent = null
    _vgcs = null

datum/vgassembly/proc/rebuild()
    for(var/datum/vgcomponent/vgc in _vgcs)
        vgc.rebuildOutputs()

datum/vgassembly/proc/showCircuit(var/mob/user)
    //show the circuit via browser, manipulate components via topic
    return

datum/vgcomponent
    var/datum/vgassembly/_assembly //obj component is attached to
    var/list/_input //input to select from
    var/list/_output //list of outputs to assign
    var/_busy = 0 //if machine is busy, for components who need time to properly function

datum/vgcomponent/New()
    _input = list(
        "main" = "main" //save all your procs you want to be accessed here
    )
    _output = list(
        "main" = null //list(0 => ref to component, 1 => target), as can be seen in setOutput
    )

datum/vgcomponent/Destroy()
    ..()
    _assembly = null
    _input = null
    _output = null

datum/vgcomponent/proc/Install(var/datum/vgassembly/A)
    if(_assembly)
        return 0 //how
    
    if(!A)
        return 0 //more plausible

    _assembly = A
    _assembly._vgcs += src
    return 1

datum/vgcomponent/proc/Uninstall() //don't override
    if(!_assembly)
        return

    _assembly._vgcs -= src
    _assembly.rebuild()
    rebuildOutputs() //call it for use since we are no longer part of the assembly
    var/phy = getPhysical()
    src.forceMove(phy)
    return phy

datum/vgcomponent/proc/rebuildOutputs()
    for(var/O in _output)
        if(_output[O][0]._assembly != src._assembly)
            _output[O] = null

datum/vgcomponent/proc/getPhysical() //do override with wanted type
    return new /obj/item/vgc_obj(src)

datum/vgcomponent/proc/handleOutput(var/target = "main", var/signal = 1)
    if(!_output[target])
        return

    if(_output[target][0]._busy)
        return

    if(_assembly._vgcs.Find(_output[target][0])) //component no longer in vga apparently
        _output[target] = null
        return

    call(src, _output[target][0]._input[_output[target[1]]])(signal) //oh boy what a line

//default input path
datum/vgcomponent/proc/main(var/signal)
    return

datum/vgcomponent/proc/setOutput(var/datum/vgcomponent/vgc, var/target = "main", var/out = "main")
    if(!(out in _output))
        return 0

    if(!(target in vgc._input))
        return 0

    if(!_assembly._vgcs.Find(vgc))
        return //how

    _output[out] = list(vgc, target)

/*
Door control
-- maybe let this send out events sometime like ondooropen, ondoorclose
*/
datum/vgcomponent/doorController
    var/list/saved_access = null //ID.GetAccess()

datum/vgcomponent/doorController/getPhysical()
    return new /obj/item/vgc_obj/door_controller(src)

datum/vgcomponent/doorController/proc/setAccess(var/obj/item/weapon/card/id/ID)
    saved_access = ID.GetAccess()

datum/vgcomponent/doorController/main(var/signal)
    if(!istype(_assembly._parent, /obj/machinery/door))
        return //no parent or not a door, however that happened

    var/obj/machinery/door/D = _assembly._parent
    if(D.check_access_list(saved_access))
        if(signal)
            D.open()
        else
            D.close()
    else
        D.denied()

/*
Debugger
idea shamelessly copied from nexus
*/
/datum/vgcomponent/debugger
	var/spam = 1

datum/vgcomponent/doorController/getPhysical()
    return new /obj/item/vgc_obj/debugger(src)

/datum/vgcomponent/debugger/main(var/signal)
	if(spam)
		to_chat(world, "received signal:[signal] | <a HREF='?src=\ref[src];pause=1'>\[Toggle Output\]</a>")

/datum/vgcomponent/debugger/Topic(href, href_list)
	. =..()
	if(href_list["pause"])
		spam = !spam