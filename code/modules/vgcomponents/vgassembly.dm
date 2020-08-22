/*
Base Assembly
*/
/datum/vgassembly
	var/name = "VGAssembly"
	var/obj/_parent
	var/list/_vgcs = list() //list of vgcs contained inside, index by their unique name used in the ui
	var/list/windows = list() //list of open uis, indexed with \ref[user]
	var/size = ARBITRARILY_LARGE_NUMBER
	//you can only use one or the other
	var/allowed_usage_flags
	var/list/vgc_output_queue_item/output_queue = list() //list of vgc_output_queue_item
	var/timestopped = 0

/datum/vgassembly/New()
	vg_assemblies += src

/datum/vgassembly/Destroy()
	vg_assemblies -= src
	_parent = null
	_vgcs = null
	..()

/datum/vgassembly/proc/attachTo(var/obj/O)
	O.vga = src
	_parent = O

/datum/vgassembly/proc/rebuild()
	for(var/datum/vgcomponent/vgc in _vgcs)
		vgc.rebuildOutputs()

/datum/vgassembly/proc/showCircuit(var/mob/user)
	//show the circuit via browser, manipulate components via topic
	var/uid = "\ref[user]"
	if(!windows[uid])
		var/datum/browser/W = new (user, "curcuitView", "[src]", nref = src)
		windows[uid] = W
	updateCurcuit(user)

/datum/vgassembly/proc/updateCurcuit(var/mob/user)
	var/uid = "\ref[user]"
	if(!windows[uid])
		return

	var/datum/browser/W = windows[uid]
	var/content = "Components:<br><dl>"
	for(var/datum/vgcomponent/vgc in _vgcs)
		content += "<dt>[vgc] \ref[vgc]"
		if(vgc.has_settings)
			content += "<a HREF='?src=\ref[src];openC=\ref[vgc]'>\[Open Settings\]</a>"
		if(vgc.has_touch)
			content += "<a HREF='?src=\ref[src];touch=\ref[vgc]'>\[[vgc.touch_enabled ? "Disable" : "Enable"] Touch\]</a>"
		content += "<a HREF='?src=\ref[src];detach=\ref[vgc]'>\[Detach\]</a></dt><dd>" //add an ontouch toggle TODO

		content += "<dl>"
		if(vgc._input.len > 0)
			content += "<dt>Inputs:</dt>"
			for(var/vin in vgc._input)
				content += "<dd>[vin] <a HREF=?src=\ref[src];debug=\ref[vgc];input=[vin]>\[Pulse\]</a></dd>"
		else
			content += "<dt>No Inputs</dt>"

		if(vgc._output.len > 0)
			content += "<dt>Outputs:</dt><dl>"
			for(var/out in vgc._output)
				content += "<dt>[out]</dt>"
				if(vgc._output[out].len)
					for(var/vgcomp_output/O in vgc._output[out])
						content += "<dd>\"[O.target]\" of \ref[O.vgc] <a HREF='?src=\ref[src];deleteOutput=\ref[vgc];output=[out];vgc=\ref[O.vgc];target=[O.target]'>\[X\]</a></dd>"
				content += "<dd><a HREF='?src=\ref[src];addOutput=\ref[vgc];output=[out]'>\[Add\]</a></dd></dl>"
		else
			content += "No Outputs<br>"
		content += "</dl></dd>"

	content += "</dl>"
	if(_parent && !istype(_parent, /obj/item/vgc_assembly))
		content += "<a HREF='?src=\ref[src];detach=\ref[src]'>\[Detach From Object\]</a> "
	content += "<a HREF='?src=\ref[src];close=1'>\[Close\]</a>"
	W.set_content(content)
	W.open()

/datum/vgassembly/Topic(href,href_list)
	if(href_list["close"]) //close curcuitview
		var/uid = "\ref[usr]"
		if(windows[uid])
			var/datum/browser/W = windows[uid]
			W.close()
			windows["\ref[usr]"] = null
		return
	else if(href_list["detach"]) //detach either obj or whole assembly
		var/target = locate(href_list["detach"])
		if(!target)
			return

		if(target == src) //detach assembly
			to_chat(usr, "You detach \the [src.name] from \the [_parent.name].")
			_parent.vga = null
			_parent = null
			var/obj/item/vgc_assembly/NewAss = new (src)
			usr.put_in_hands(NewAss)
			return
		else //uninstall component
			var/datum/vgcomponent/T = target
			to_chat(usr, "You uninstall \the [T.name] from \the [src.name].")
			var/obj/item/vgc_obj/NewObj = T.Uninstall()
			usr.put_in_hands(NewObj)
	else if(href_list["openC"]) //open settings of selected obj
		var/datum/vgcomponent/vgc = locate(href_list["openC"])
		if(!vgc)
			return
		to_chat(usr, "You open \the [vgc.name]'s settings.")
		vgc.openSettings(usr)
		return
	else if(href_list["addOutput"])
		var/datum/vgcomponent/V = locate(href_list["addOutput"])
		if(!V)
			return
		var/output = href_list["output"]

		var/list/refs = list()
		for(var/datum/vgcomponent/vgc in _vgcs)
			if(vgc == V)
				continue //dont wanna assign to ourself, or do we?
			var/i = 1
			while(1)
				if(!refs["[vgc.name]_[i]"])
					refs["[vgc.name]_[i]"] = "\ref[vgc]"
					break
				i++
		var/target = input(usr, "Select which component you want to output to.", "Select Target Component", 0) as null|anything in refs
		if(!target)
			return

		target = refs["[target]"]
		var/datum/vgcomponent/T = locate(target)
		if(!T)
			return

		var/input = input("Select which input you want to target.", "Select Target Input", "main") as null|anything in T._input

		to_chat(usr, "You connect \the [V.name]'s [output] with \the [T.name]'s [input].")
		V.addOutput(T, output, input)
	else if(href_list["touch"])
		var/datum/vgcomponent/vgc = locate(href_list["touch"])
		if(!vgc || !vgc.has_touch)
			return

		vgc.touch_enabled = !vgc.touch_enabled
	else if(href_list["debug"])
		var/datum/vgcomponent/vgc = locate(href_list["debug"])
		if(!vgc)
			return

		if(!href_list["input"] || !(href_list["input"] in vgc._input))
			return

		to_chat(usr, "You pulse [href_list["input"]] of [vgc.name].")
		call(vgc, vgc._input[href_list["input"]])(1)
		return
	else if(href_list["deleteOutput"])
		var/datum/vgcomponent/S = locate(href_list["deleteOutput"])
		var/datum/vgcomponent/T = locate(href_list["vgc"])
		if(!S || !T)
			return
		var/target = href_list["target"]
		var/output = href_list["output"]
		if(!S.removeOutput(T, output, target))
			return
	updateCurcuit(usr)


/datum/vgassembly/proc/touched(var/obj/item/O, var/mob/user)
	//execute touch events for components if they are enabled
	var/list/touchables = list()
	for(var/datum/vgcomponent/vgc in _vgcs)
		if(!vgc.has_touch && !vgc.touch_enabled)
			continue
		touchables += list("[vgc.name]" = vgc)

	var/input = input("What component do you want to interact with?", "Select Component", null) as null|anything in touchables
	if(!input)
		return

	touchables[input].onTouch(O, user)
	return

/datum/vgassembly/proc/UI_Update()
	for(var/ref in windows)
		var/mob/user = locate(ref)
		if(!user)
			windows[ref] = null
			continue

		updateCurcuit(user)

/datum/vgassembly/proc/hasSpace()
	return ((size - _vgcs.len) > 0)

/datum/vgassembly/proc/canAdd(var/datum/vgcomponent/vgc)
	if(!hasSpace())
		return 0

	if(!vgc)
		return 0

	if(!(vgc.usage_flags & allowed_usage_flags))
		return 0
	return 1

/datum/vgassembly/proc/setTimestop(var/timestop)
	timestopped = timestop
	for(var/datum/vgcomponent/vgc in _vgcs)
		vgc.timestopped = timestop

/datum/vgassembly/proc/fireOutputs()
	if(timestopped)
		return

	while(output_queue.len)
		var/vgc_output_queue_item/Q = output_queue[1]

		if(!Q.target || !Q.source || Q.target.timestopped || Q.target._busy || !_vgcs.Find(Q.target) || !_vgcs.Find(Q.source) )
			output_queue.len-- //remove item
			continue

		if(Q.source.timestopped)
			continue

		Q.fire()
		output_queue -= Q

/datum/vgassembly/proc/onHacked()
	for(var/datum/vgcomponent/C in _vgcs)
		C.onHacked()

/datum/vgassembly/robot_small
	allowed_usage_flags = VGCOMP_USAGE_NONE | VGCOMP_USAGE_MOVEMENT | VGCOMP_USAGE_MANIPULATE_SMALL

/datum/vgassembly/robot_big
	allowed_usage_flags = VGCOMP_USAGE_NONE | VGCOMP_USAGE_MOVEMENT | VGCOMP_USAGE_MANIPULATE_SMALL | VGCOMP_USAGE_MANIPULATE_LARGE

/datum/vgassembly/attachable_small
	allowed_usage_flags = VGCOMP_USAGE_NONE | VGCOMP_USAGE_MANIPULATE_SMALL

/datum/vgassembly/attachable_big
	allowed_usage_flags = VGCOMP_USAGE_NONE | VGCOMP_USAGE_MANIPULATE_SMALL | VGCOMP_USAGE_MANIPULATE_LARGE

/datum/vgassembly/handheld
	allowed_usage_flags = VGCOMP_USAGE_NONE | VGCOMP_USAGE_MANIPULATE_SMALL

/datum/vgassembly/tablet
	allowed_usage_flags = VGCOMP_USAGE_NONE

/datum/vgassembly/anchored
	allowed_usage_flags = VGCOMP_USAGE_NONE | VGCOMP_USAGE_MANIPULATE_SMALL | VGCOMP_USAGE_MANIPULATE_LARGE
