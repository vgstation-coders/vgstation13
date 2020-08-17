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
	var/allowed_usage_flags = VGCOMP_USAGE_NONE | VGCOMP_USAGE_MOVEMENT | VGCOMP_USAGE_MANIPULATE_SMALL | VGCOMP_USAGE_MANIPULATE_LARGE
	var/list/output_queue = list() //list of outputs to fire, indexed by \ref[vgc]
	var/timestopped = 0

/datum/vgassembly/New()
	vg_assemblies += src

/datum/vgassembly/Destroy()
	vg_assemblies -= src
	_parent = null
	_vgcs = null
	..()

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
			content += "<dt>Outputs:</dt>"
			for(var/out in vgc._output)
				content += "<dd>[out] "
				if(vgc._output[out])
					var/tar = vgc._output[out][2]
					var/tar_obj = vgc._output[out][1]
					content += "assigned to [tar] of \ref[tar_obj] <a HREF='?src=\ref[src];setO=\ref[vgc];output=[out]'>\[Reassign\]</a> <a HREF='?src=\ref[src];clear=\ref[vgc];output=[out]'>\[Clear\]</a>"
				else
					content += "<a HREF='?src=\ref[src];setO=\ref[vgc];output=[out]'>\[Assign\]</a>"
				content += "</dd>"
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
	else if(href_list["setO"])
		var/datum/vgcomponent/out = locate(href_list["setO"])
		if(!out)
			return

		if(!(href_list["output"] in out._output))
			return

		var/list/refs = list()
		for(var/datum/vgcomponent/vgc in _vgcs)
			if(vgc == out)
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
		if(!locate(target))
			return

		var/input = input("Select which input you want to target.", "Select Target Input", "main") as null|anything in locate(target)._input

		var/datum/vgcomponent/vgc = locate(target)
		to_chat(usr, "You connect \the [out.name]'s [href_list["output"]] with \the [vgc.name]'s [input].")
		out.setOutput(href_list["output"], vgc, input)
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
	else if(href_list["clear"])
		var/datum/vgcomponent/vgc = locate(href_list["clear"])
		if(!vgc)
			return

		if(!(href_list["output"] in vgc._output))
			return

		to_chat(usr, "You clear [href_list["output"]] of [vgc.name].")
		vgc._output[href_list["output"]] = null
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
		var/list/Q = output_queue[output_queue.len]
		output_queue.len--
		var/ref = Q[1]
		var/target = Q[2]
		var/signal = Q[3]

		var/datum/vgcomponent/vgc = locate(ref)
		if(!vgc)
			continue

		if(vgc.timestopped)
			continue

		if(!vgc._output[target])
			continue

		if(vgc._output[target][1]._busy)
			continue

		if(!_vgcs.Find(vgc._output[target][1])) //component no longer in vga apparently
			vgc._output[target] = null
			continue

		var/proc_string = vgc._output[target][1]._input[vgc._output[target][2]]
		call(vgc._output[target][1], proc_string)(signal) //oh boy what a line

/datum/vgassembly/robot_small
/datum/vgassembly/robot_big
/datum/vgassembly/attachable_small
/datum/vgassembly/attachable_big
/datum/vgassembly/handheld
/datum/vgassembly/tablet
/datum/vgassembly/anchored
