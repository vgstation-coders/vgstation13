//needs a way to
//- prevent endless loops

obj
	var/datum/vgassembly/vga = null //component assembly

datum/vgassembly
	var/obj/_parent
	var/list/_vgcs = list() //list of vgcs contained inside
	var/list/windows = list() //list of open uis, indexed with \ref[user]

datum/vgassembly/Destroy()
	..()
	_parent = null
	_vgcs = null

datum/vgassembly/proc/rebuild()
	for(var/datum/vgcomponent/vgc in _vgcs)
		vgc.rebuildOutputs()

datum/vgassembly/proc/showCircuit(var/mob/user)
	//show the circuit via browser, manipulate components via topic
	var/uid = "\ref[user]"
	if(!windows[uid])
		var/datum/browser/W = new (user, "curcuitView", "[src]", nref = src)
		windows[uid] = W
	updateCurcuit(user)

datum/vgassembly/proc/updateCurcuit(var/mob/user)
	var/uid = "\ref[user]"
	if(!windows[uid])
		return

	var/datum/browser/W = windows[uid]
	var/content = "Components:<br>"
	for(var/datum/vgcomponent/vgc in _vgcs)
		content += "[vgc] \ref[vgc]"
		if(vgc.has_settings)
			content += "<a HREF='?src=\ref[src];openC=\ref[vgc]'>\[Open Settings\]</a>"
		content += "<a HREF='?src=\ref[src];detach=\ref[vgc]'>\[Detach\]</a><br>"

		if(vgc._input.len > 0)
			content += "Inputs:<tab id=\ref[vgc]_inputs><br>"
			for(var/vin in vgc._input)
				content += "<tab to=\ref[vgc]_inputs>[vin]<br>"
		else
			content += "No Inputs<br>"

		if(vgc._output.len > 0)
			content += "Outputs:<tab id=\ref[vgc]_outputs><br>"
			for(var/out in vgc._output)
				content += "<tab to=\ref[vgc]_outputs>[out] "
				if(vgc._output[out])
					var/tar = vgc._output[out][2]
					var/tar_obj = vgc._output[out][1]
					content += "assigned to [tar] of \ref[tar_obj] <a HREF='?src=\ref[src];setO=\ref[vgc];output=[out]'>\[Reassign\]</a>"
				else
					content += "<a HREF='?src=\ref[src];setO=\ref[vgc];output=[out]'>\[Assign\]</a>"
				content += "<br>"
		else
			content += "No Outputs<br>"

	if(_parent)
		content += "<a HREF='?src=\ref[src];detach=\ref[src]'>\[Detach From Object\]</a> "
	content += "<a HREF='?src=\ref[src];close=1'>\[Close\]</a>"
	W.set_content(content)
	W.open()

datum/vgassembly/Topic(href,href_list)
	if(href_list["close"]) //close curcuitview
		var/uid = "\ref[usr]"
		if(windows[uid])
			var/datum/browser/W = windows[uid]
			W.close()
			windows["\ref[usr]"] = null
	else if(href_list["detach"]) //detach either obj or whole assembly
		var/target = locate(href_list["detach"])
		if(!target)
			return

		if(target == src) //detach assembly
			_parent.vga = null
			_parent = null
			var/obj/item/vgc_assembly/NewAss = new (src)
			usr.put_in_hands(NewAss)
		else //detach object
			var/datum/vgcomponent/T = target
			var/obj/item/vgc_obj/NewObj = T.Uninstall()
			usr.put_in_hands(NewObj)
		updateCurcuit(usr)
	else if(href_list["openC"]) //open settings of selected obj
		var/datum/vgcomponent/vgc = locate(href_list["openC"])
		if(!vgc)
			return
		vgc.openSettings(usr)
	else if(href_list["setO"])
		var/datum/vgcomponent/out = locate(href_list["setO"])
		if(!out)
			return

		if(!(href_list["output"] in out._output))
			return

		var/list/refs = list()
		for(var/datum/vgc in _vgcs)
			if(vgc == out)
				continue //dont wanna assign to ourself, or do we?
			refs += "\ref[vgc]"
		var/target = input("Select which component you want to output to.", "Select Target Component", 0) in refs
		if(!target || locate(target))
			return
		
		var/input = input("Select which input you want to target.", "Select Target Input", "main") in locate(target)._input

		out.setOutput(href_list["output"], locate(target), input)


datum/vgassembly/proc/touched(var/mob/user)
	//execute touch events for components if they are enabled
	message_admins("[user] touched assembly")
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
	var/name = "VGComponent" //used in the ui
	var/datum/vgassembly/_assembly //obj component is attached to
	var/list/_input //input to select from
	var/list/_output //list of outputs to assign
	var/_busy = 0 //if machine is busy, for components who need time to properly function
	var/list/settings = list() //list of open uis, indexed with \ref[user]
	var/has_settings = 0 //enables openSettings button in assembly ui

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

	
	var/datum/vgassembly/A = _assembly
	_assembly = null //needs to be null for rebuild to work for other components
	A.rebuild()
	A._vgcs -= src //now that we rebuilt, we can remove ourselves
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
		return 0

	if(_output[target][1]._busy)
		return 0

	if(!_assembly._vgcs.Find(_output[target][1])) //component no longer in vga apparently
		_output[target] = null
		return 0

	var/proc_string = _output[target][1]._input[_output[target][2]]
	call(_output[target][1], proc_string)(signal) //oh boy what a line
	return 1

datum/vgcomponent/proc/setOutput(var/out = "main", var/datum/vgcomponent/vgc, var/target = "main")
	if(!(out in _output))
		return 0

	if(!(target in vgc._input))
		return 0

	if(!_assembly._vgcs.Find(vgc))
		return //how

	_output[out] = list(vgc, target)

//opens window to configure settings
datum/vgcomponent/proc/openSettings(var/mob/user)
	return

//default input path
datum/vgcomponent/proc/main(var/signal)
	message_admins("somehow [src]'s default input got called, altough it was never set.'") //yes i know dont judge me, i am working with datums here
	return

/*
Door control
-- maybe let this send out events sometime like ondooropen, ondoorclose
*/
datum/vgcomponent/doorController
	name = "Doorcontroller"
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
	name = "Debugger"
	var/spam = 1

/datum/vgcomponent/debugger/getPhysical()
	return new /obj/item/vgc_obj/debugger(src)

/datum/vgcomponent/debugger/main(var/signal)
	if(spam)
		message_admins("received signal:[signal] | <a HREF='?src=\ref[src];pause=1'>\[Toggle Output\]</a>")

/datum/vgcomponent/debugger/Topic(href, href_list)
	. =..()
	if(href_list["pause"])
		spam = !spam

/*
signaler
raw signaler
*/
/datum/vgcomponent/signaler
	name = "Signaler"
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
/datum/vgcomponent/signaler/proc/was_signaled()
	handleOutput("signaled", 1)