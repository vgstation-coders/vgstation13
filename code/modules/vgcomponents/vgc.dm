//needs a way to
//- prevent endless loops

obj
	var/datum/vgassembly/vga = null //component assembly

datum/vgassembly
	var/_parent
	var/list/_vgcs = list()//list of vgcs contained inside

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
/*
VGComponent

if you make a child, you will need to override
- getPhysical
- New() if you need to designate new inputs/outputs
- main() if you want to use the default input
- Destroy() if you got references to any objs and such (do supercall tho)
*/
datum/vgcomponent
	var/datum/vgassembly/_assembly //obj component is attached to
	var/list/_input //input to select from
	var/list/_output //list of outputs to assign
	var/_busy = 0 //if machine is busy, for components who need time to properly function

datum/vgcomponent/New() //ALWAYS supercall else you wont have the default input/outputs
	//_input["nameThatUserSees"] = "procname"
	_input += list( //can be called by multiple components, save all your procs you want to be accessed here
		"main" = "main"
	)
	_output += list( //can only point to one component: list(0 => ref to component, 1 => target), as can be seen in setOutput
		"main" = null
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
	return getPhysical()

datum/vgcomponent/proc/getPhysical() //do override with wanted type
	return new /obj/item/vgc_obj(src)

//basically removes all assigned outputs which aren't in the assembly anymore
datum/vgcomponent/proc/rebuildOutputs()
	for(var/O in _output)
		if(_output[O][1]._assembly != src._assembly)
			_output[O] = null

datum/vgcomponent/proc/handleOutput(var/target = "main", var/signal = 1)
	if(!_output[target])
		return

	if(_output[target][1]._busy)
		return

	if(_assembly._vgcs.Find(_output[target][1])) //component no longer in vga apparently
		_output[target] = null
		return

	call(src, _output[target][1]._input[_output[target[2]]])(signal) //oh boy what a line

datum/vgcomponent/proc/setOutput(var/out = "main", var/datum/vgcomponent/vgc, var/target = "main")
	if(!(out in _output))
		return 0

	if(!(target in vgc._input))
		return 0

	if(!_assembly._vgcs.Find(vgc))
		return //how

	_output[out] = list(vgc, target)

datum/vgcomponent/proc/openSettings(var/mob/user)
	to_chat(user, "the component has no settings to configure")
	return

//default input path
datum/vgcomponent/proc/main(var/signal)
	return

/*
Door control
-- maybe let this send out events sometime like ondooropen, ondoorclose
*/
datum/vgcomponent/doorController
	var/list/saved_access = list() //ID.GetAccess()

datum/vgcomponent/doorController/getPhysical()
	return new /obj/item/vgc_obj/door_controller(src)

datum/vgcomponent/doorController/proc/setAccess(var/obj/item/weapon/card/id/ID)
	saved_access = ID.GetAccess()

datum/vgcomponent/doorController/main(var/signal)
	if(!istype(_assembly._parent, /obj/machinery/door))
		return 0 //no parent or not a door, however that happened

	var/obj/machinery/door/D = _assembly._parent
	if(D.check_access_list(saved_access))
		if(signal)
			D.open()
		else
			D.close()
		return 1
	else
		D.denied()
	
	return 0

/*
Debugger
idea shamelessly copied from nexus
*/
/datum/vgcomponent/debugger
	var/spam = 1

/datum/vgcomponent/debugger/getPhysical()
	return new /obj/item/vgc_obj/debugger(src)

/datum/vgcomponent/debugger/main(var/signal)
	if(spam)
		to_chat(world, "received signal:[signal] | <a HREF='?src=\ref[src];pause=1'>\[Toggle Output\]</a>")

/datum/vgcomponent/debugger/Topic(href, href_list)
	. =..()
	if(href_list["pause"])
		spam = !spam

/*
signaler
raw signaler
*/
/datum/vgcomponent/signaler
	var/obj/item/device/assembly/signaler/_signaler

datum/vgcomponent/signaler/New()
	//..() we dont need main here
	_input += list(
		"setFreq" = "setFreq", //receives freq
		"setCode" = "setCode", //receives code
		"send" = "send" //sends
	)
	_output += list(
		"signaled" = null
	)
	_signaler = new ()
	_signaler.fingerprintslast = "VGAssembly" //for the investigation log TODO
	_signaler.vgc = src //so we can hook into receive_signal

/datum/vgcomponent/signaler/getPhysical()
	return new /obj/item/vgc_obj/signaler(src)

/datum/vgcomponent/signaler/proc/setFreq(var/signal)
	if(!isnum(signal))
		signal = text2num(signal)
		if(!signal) //wasn't a number
			return
	if(!(signal in (MINIMUM_FREQUENCY to MAXIMUM_FREQUENCY)))
		return

	_signaler.set_frequency(signal)

/datum/vgcomponent/signaler/proc/setCode(var/signal)
	if(!isnum(signal))
		signal = text2num(signal)
		if(!signal) //wasn't a number
			return

	if(!(signal in (1 to 100)))
		return

	_signaler.code = signal

/datum/vgcomponent/signaler/proc/send()
	_signaler.signal()

//signaled output
/datum/vgcomponent/signaler/proc/signalled()
	handleOutput("signaled", 1)