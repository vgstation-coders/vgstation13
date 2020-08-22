/obj
	var/datum/vgassembly/vga = null //component assembly

/obj/variable_edited(var_name, old_value, new_value)
	. =..()

	switch(var_name)
		if("timestopped")
			if(vga)
				vga.setTimestop(new_value)

/obj/attackby(obj/item/O, mob/user)
	. = ..()
	if(istype(O, /obj/item/weapon/card/emag))
		vga.onHacked()

/*
Base Component
*/
/datum/vgcomponent
	var/name = "VGComponent" //used in the ui
	var/desc = "used to make logic happen"
	var/datum/vgassembly/_assembly //obj component is attached to
	var/list/_input = list( //can be called by multiple components, save all your procs you want to be accessed here
		"main" = "main"
	)
	var/list/_output = list( //can only point to one component: list(0 => ref to component, 1 => target), as can be seen in setOutput
		"main"
	)
	var/_busy = 0 //if machine is busy, for components who need time to properly function
	var/list/settings = list() //list of open uis, indexed with \ref[user]
	var/has_settings = 0 //enables openSettings button in assembly ui
	var/has_touch = 0 //if the person has the ability to toggle touch behaviour
	var/touch_enabled = 0 //if touch will fire
	var/obj_path = /obj/item/vgc_obj
	var/timestopped = 0 //needed for processingobjs
	var/usage_flags = VGCOMP_USAGE_NONE
	var/hacked = FALSE

/datum/vgcomponent/New()
	..()

	//build outputs
	for(var/tag in _output)
		_output[tag] = list()

/datum/vgcomponent/Destroy()
	..()
	_assembly = null
	_input = null
	_output = null
	settings = null

/datum/vgcomponent/proc/Install(var/datum/vgassembly/A) //dont override
	if(_assembly)
		return 0 //how

	if(!A || !A.canAdd(src))
		return 0 //more plausible

	_assembly = A
	_assembly._vgcs += src
	_assembly.UI_Update()

	OnInstall()

	return 1

/datum/vgcomponent/proc/OnInstall()
	return

/datum/vgcomponent/proc/Uninstall() //don't override
	if(!_assembly)
		return

	var/datum/vgassembly/A = _assembly
	_assembly = null //needs to be null for rebuild to work for other components
	A.rebuild()
	A._vgcs -= src //now that we rebuilt, we can remove ourselves
	A.UI_Update()

	OnUninstall()

	return new obj_path(src)

/datum/vgcomponent/proc/OnUninstall()
	return

//basically removes all assigned outputs which aren't in the assembly anymore
/datum/vgcomponent/proc/rebuildOutputs()
	for(var/tag in _output)
		for(var/vgcomp_output/O in _output[tag])
			if(O.vgc._assembly != src._assembly)
				_output[tag] -= O

/datum/vgcomponent/proc/handleOutput(var/target = "main", var/signal = 1)
	if(!_assembly)
		return

	for(var/vgcomp_output/O in _output[target])
		_assembly.output_queue += new /vgc_output_queue_item(src, O.vgc, O.target, signal)

/datum/vgcomponent/proc/addOutput(var/datum/vgcomponent/vgc, var/out = "main", var/target = "main")
	if(!(out in _output))
		return 0

	if(!(target in vgc._input))
		return 0

	if(!_assembly || _assembly != vgc._assembly)
		return 0

	for(var/vgcomp_output/O in _output[out])
		if(O.vgc == vgc && O.target == target)
			return 0

	_output[out] += new /vgcomp_output(vgc, target)

/datum/vgcomponent/proc/removeOutput(var/datum/vgcomponent/vgc, var/out = "main", var/target = "main")
	for(var/vgcomp_output/O in _output[out])
		if(O.vgc == vgc && O.target == target)
			_output[out] -= O
			return 1
	return 0

//opens window to configure settings
/datum/vgcomponent/proc/openSettings(var/mob/user)
	return

//default input path
/datum/vgcomponent/proc/main(var/signal)
	message_admins("somehow [src]'s default input got called, altough it was never set.'")
	return

/datum/vgcomponent/proc/onTouch(var/obj/item/O, var/mob/user)
	return

/datum/vgcomponent/proc/onHacked()
	hacked = TRUE

/*
=============================================
COMPONENTS (the ones i made myself... kinda)
=============================================
*/
/*
Door control
-- maybe let this send out events sometime like ondooropen, ondoorclose
*/
/datum/vgcomponent/doorController
	name = "Doorcontroller"
	desc="controls doors"
	var/list/saved_access = list() //ID.GetAccess()
	obj_path = /obj/item/vgc_obj/door_controller
	_input = list(
		"open" = "open",
		"close" = "close",
		"toggle" = "toggle"
	)
	_output = list()
	usage_flags = VGCOMP_USAGE_MANIPULATE_LARGE

/datum/vgcomponent/doorController/proc/setAccess(var/obj/item/weapon/card/id/ID)
	saved_access = ID.GetAccess()

/datum/vgcomponent/doorController/proc/open(var/signal)
	if(!signal) //we want a 1
		return 0

	if(!istype(_assembly._parent, /obj/machinery/door))
		return 0//no parent or not a door, however that happened

	var/obj/machinery/door/D = _assembly._parent
	if(D.check_access_list(saved_access))
		D.open()
		return 1
	else
		D.denied()
	return 0

/datum/vgcomponent/doorController/proc/close(var/signal)
	if(!signal) //we want a 1
		return 0

	if(!istype(_assembly._parent, /obj/machinery/door))
		return 0//no parent or not a door, however that happened

	var/obj/machinery/door/D = _assembly._parent
	if(D.check_access_list(saved_access))
		D.close()
		return 1
	else
		D.denied()
	return 0

/datum/vgcomponent/doorController/proc/toggle(var/signal)
	if(!signal) //we want a 1
		return 0

	if(!istype(_assembly._parent, /obj/machinery/door))
		return 0//no parent or not a door, however that happened

	var/obj/machinery/door/D = _assembly._parent
	if(D.check_access_list(saved_access))
		if(D.density)
			D.open()
		else
			D.close()
		return 1
	else
		D.denied()
	return 0

/*
== PROCESSING COMPONENTS
*/
/datum/vgcomponent/processor/OnUninstall()
	stop_processing()

/datum/vgcomponent/processor/proc/start_processing()
	if(!(src in processing_objects))
		processing_objects.Add(src)
		return 1
	return 0

/datum/vgcomponent/processor/proc/stop_processing()
	if(src in processing_objects)
		processing_objects.Remove(src)
		return 1
	return 0

/datum/vgcomponent/processor/proc/toggle_processing()
	if(!stop_processing())
		start_processing()
	return 1

/datum/vgcomponent/processor/proc/process()
	return

/*
Cleaner - cleans floortiles below object
*/
/datum/vgcomponent/processor/cleaner
	name = "Cleaner"
	desc="Cleans Tiles"
	obj_path = /obj/item/vgc_obj/cleaner
	_input = list(
		"activate" = "start_processing",
		"deactivate" = "stop_processing",
		"toggle" = "toggle_processing"
	)
	_output = list()
	usage_flags = VGCOMP_USAGE_MANIPULATE_LARGE
	var/list/blacklisted_targets = list()
	var/time_between_cleaning = 1 SECONDS
	var/blocked_until

/datum/vgcomponent/processor/cleaner/process()
	if(world.time < blocked_until)
		return

	var/obj/O = _assembly._parent
	var/turf/T = get_turf(O)

	if(!hacked && prob(95))
		O.visible_message("<span class='warning'>\the [src] cleans up the [T].</span>")
		var/list/c_d = get_cleanable_decals(T)
		if(c_d.len)
			qdel(c_d[1])
	else
		O.visible_message("<span class='warning'>Something flies out of \the [src]! It seems to be acting oddly.</span>")
		new /obj/effect/decal/cleanable/blood/gibs(T)
	blocked_until = world.time + time_between_cleaning

/datum/vgcomponent/processor/cleaner/proc/get_cleanable_decals(var/turf/T)
	. = list()
	for(var/obj/effect/decal/cleanable/C in T)
		if(!(is_type_in_list(C,blacklisted_targets)))
			. += C

/datum/vgcomponent/processor/cleaner/openSettings(mob/user)
	. = ..()
	/*todo:
	if(!src.blood)
		blacklisted_targets += (/obj/effect/decal/cleanable/blood)
	if(!src.crayon)
		blacklisted_targets += (/obj/effect/decal/cleanable/crayon)
	*/

/*
Proximity Sensor
*/
/datum/vgcomponent/processor/prox_sensor
	name = "Proximity Sensor"
	desc = "detects fast movement"
	obj_path = /obj/item/vgc_obj/prox_sensor
	_input = list(
		"activate" = "start_processing",
		"deactivate" = "stop_processing",
		"toggle" = "toggle_processing",
		"setRange" = "setRange"
	)
	_output = list(
		"sense"
	)
	var/range = 2
	has_settings = 1

/datum/vgcomponent/processor/prox_sensor/proc/setRange(var/signal)
	if(!isnum(signal))
		signal = text2num(signal)
		if(!signal) //wasn't a number
			return 0

	if(!(signal in 1 to 5))
		return 0

	range = signal
	return 1

/datum/vgcomponent/processor/prox_sensor/process()
	//sense for people
	var/turf/loc = get_turf(_assembly._parent)
	for(var/mob/living/A in range(range,loc))
		if(A.move_speed < 12)
			handleOutput("sense")
			return //to prevent the spam, only output once per process

/*
Debugger
idea shamelessly copied from nexus - and modified
*/
/datum/vgcomponent/debugger
	name = "Debugger"
	desc="you should not have this"
	var/spam = 1
	obj_path = /obj/item/vgc_obj/debugger

/datum/vgcomponent/debugger/main(var/signal)
	if(spam)
		message_admins("received signal:[signal] | <a HREF='?src=\ref[src];pause=1'>\[Toggle Output/Passthrough\]</a>")
		handleOutput()
		return 1
	return 0

/datum/vgcomponent/debugger/Topic(href, href_list)
	. =..()
	if(href_list["pause"])
		spam = !spam

/*
Button
*/
/datum/vgcomponent/button
	name = "Button"
	desc="press to send a signal"
	var/toggle = 0
	var/state = 1
	obj_path = /obj/item/vgc_obj/button
	_input = list()
	touch_enabled = 1

/datum/vgcomponent/button/onTouch(obj/item/O, mob/user)
	handleOutput(signal = state)
	if(toggle)
		state = !state

/*
Togglebutton
*/
/datum/vgcomponent/button/toggle
	name = "Togglebutton"
	toggle = 1
	obj_path = /obj/item/vgc_obj/button/toggle

/*
Gate
*/
/datum/vgcomponent/gate_button
	name = "Gate"
	desc = "Toggle to enable/disable signal passthrough"
	var/state = TRUE
	obj_path = /obj/item/vgc_obj/gate_button
	touch_enabled = 1

/datum/vgcomponent/gate_button/onTouch(obj/item/O, mob/user)
	state = !state

/datum/vgcomponent/gate_button/main(signal)
	if(state)
		handleOutput(signal = signal)

/*
Speaker
*/
/datum/vgcomponent/speaker
	name = "Speaker"
	desc = "speaks"
	obj_path = /obj/item/vgc_obj/speaker
	_output = list()

/datum/vgcomponent/speaker/main(var/signal)
	if(!istext(signal))
		signal = "[signal]"
	_assembly._parent.say(signal)
	return 1

/*
Keyboard
*/
/datum/vgcomponent/keyboard
	name = "Keyboard"
	desc = "used to type stuff"
	obj_path = /obj/item/vgc_obj/keyboard
	_input = list()
	has_touch = 1
	touch_enabled = 1

/datum/vgcomponent/keyboard/onTouch(var/obj/item/O, var/mob/user)
	if(!user)
		return

	var/output = input("What do you want to type?", "Write Message", null) as null|text
	if(!output)
		return

	handleOutput("main", output)

/*
Algorithmic components
*/
/datum/vgcomponent/algorithmic
	_input = list(
		"setNum" = "setNum",
		"calculate" = "doCalc"
	)
	_output = list(
		"result"
	)
	var/num = 0

/datum/vgcomponent/algorithmic/proc/setNum(var/signal)
	if(!isnum(signal))
		signal = text2num(signal)
		if(!signal)
			return//wasn't a number

	num = signal

/datum/vgcomponent/algorithmic/proc/doCalc(var/signal)
	if(!isnum(signal))
		signal = text2num(signal)
		if(!signal)
			return//wasn't a number

	calc(signal)

/datum/vgcomponent/algorithmic/proc/calc(var/signal)
	return

// ADD
/datum/vgcomponent/algorithmic/add
	name = "Add"
	desc = "adds onto numbers"
	obj_path = /obj/item/vgc_obj/add

/datum/vgcomponent/algorithmic/add/calc(var/signal)
	handleOutput("result", signal+num)

//SUBTRACT
/datum/vgcomponent/algorithmic/sub
	name = "Subtract"
	desc = "subtracts of numbers"
	obj_path = /obj/item/vgc_obj/sub

/datum/vgcomponent/algorithmic/sub/calc(var/signal)
	handleOutput("result", signal-num)

//MULTIPLY
/datum/vgcomponent/algorithmic/mult
	name = "Multiply"
	desc = "multiply numbers"
	obj_path = /obj/item/vgc_obj/mult

/datum/vgcomponent/algorithmic/mult/calc(var/signal)
	handleOutput("result", signal*num)

//DIVIDE X/NUM
/datum/vgcomponent/algorithmic/div1
	name = "Divide 1"
	desc = "divide numbers with X/NUM"
	obj_path = /obj/item/vgc_obj/div1

/datum/vgcomponent/algorithmic/div1/calc(var/signal)
	if(!signal)
		return
	handleOutput("result", signal/num)

//DIVIDE NUM/X
/datum/vgcomponent/algorithmic/div2
	name = "Divide 2"
	desc = "divide numbers with NUM/X"
	obj_path = /obj/item/vgc_obj/div2

/datum/vgcomponent/algorithmic/div2/calc(var/signal)
	handleOutput("result", num/signal)

/*
String Appender
*/
/datum/vgcomponent/appender
	name = "Appender"
	desc = "appends to string"
	obj_path = /obj/item/vgc_obj/appender
	_input = list(
		"setPhrase" = "setPhrase",
		"append" = "append"
	)
	var/phrase = ""
	var/dir = 1
	has_settings = 1 //for setting the phrase, and dir

/datum/vgcomponent/appender/proc/setPhrase(var/signal)
	if(!istext(signal))
		signal = "[signal]"

	phrase = signal

/datum/vgcomponent/appender/proc/append(var/signal)
	if(dir)
		handleOutput(signal = "[signal][phrase]")
	else
		handleOutput(signal = "[phrase][signal]")

/*
LIST OPERATORS
*/
/*
Index getter
*/
/datum/vgcomponent/index_getter
	name = "List Index Grabber"
	desc = "grabs specified index from list"
	obj_path = /obj/item/vgc_obj/index_getter
	_input = list(
		"setIndex" = "setIndex",
		"grab" = "grab"
	)
	_output = list(
		"element"
	)
	var/index = 1
	has_settings = 1 //for setting the index

/datum/vgcomponent/index_getter/proc/setIndex(var/signal)
	if(!isnum(signal))
		signal = text2num(signal)
		if(!signal)
			return//wasn't a number

	index = signal

/datum/vgcomponent/index_getter/proc/grab(var/signal)
	if(!istype(signal, /list))
		return

	var/list/L = signal

	if(index > L.len)
		return

	handleOutput("element", L[index])

/*
List iterator
*/
/datum/vgcomponent/list_iterator
	name = "List iterator"
	desc = "iterates over the list given to it"
	obj_path = /obj/item/vgc_obj/list_iterator

datum/vgcomponent/list_iterator/main(var/signal)
	if(!istype(signal, /list))
		return

	for(var/E in signal)
		handleOutput(signal = E)

/*
Typecheck
*/
#define TYPE_NUM 1
#define TYPE_TEXT 2
#define TYPE_LIST 3
#define TYPE_MOB 4
#define TYPE_COSTUM 5

/datum/vgcomponent/typecheck
	name = "Typechecker"
	desc = "checks types"
	obj_path = /obj/item/vgc_obj/typecheck
	has_settings = 1 //type setting set over well... settings
	var/costum_type
	var/type_check = TYPE_NUM
	var/waitingForType = 0

/datum/vgcomponent/typecheck/main(var/signal)
	switch(type_check)
		if(TYPE_NUM)
			if(isnum(signal))
				handleOutput()
		if(TYPE_TEXT)
			if(istext(signal))
				handleOutput()
		if(TYPE_LIST)
			if(istype(signal, /list))
				handleOutput()
		if(TYPE_MOB)
			if(istype(signal, /mob))
				handleOutput()
		if(TYPE_COSTUM)
			if(!costum_type || waitingForType)
				return

			if(istype(signal, costum_type))
				handleOutput()


#undef TYPE_NUM
#undef TYPE_TEXT
#undef TYPE_LIST
#undef TYPE_MOB
#undef TYPE_COSTUM
/*
===================================================================
ASSEMBLY WRAPPERS (just components that use the current assembly objs)
===================================================================
*/
/*
signaler
raw signaler
*/
/obj/item/device/assembly/signaler/vgc
	var/datum/vgcomponent/signaler/vgc = null //we need this to hook into receive_update, only used for the internal signaller of /datum/vgcomponent/signaller

/obj/item/device/assembly/signaler/vgc/receive_signal(datum/signal/signal)
	if(..() && vgc)
		vgc.was_signaled()


/datum/vgcomponent/signaler
	name = "Signaler"
	desc="receives and sends signals"
	var/obj/item/device/assembly/signaler/vgc/_signaler
	has_touch = 1
	touch_enabled = 0
	obj_path = /obj/item/vgc_obj/signaler
	_input = list(
		"setFreq" = "setFreq", //receives freq
		"setCode" = "setCode", //receives code
		"send" = "send" //sends
	)
	_output = list(
		"signaled"
	)
	has_settings = 1

/datum/vgcomponent/signaler/onTouch(var/obj/item/O, var/mob/user)
	send()

/datum/vgcomponent/signaler/New()
	..()
	_signaler = new ()
	_signaler.fingerprintslast = "VGAssembly" //for the investigation log TODO
	_signaler.vgc = src //so we can hook into receive_signal

/datum/vgcomponent/signaler/proc/setFreq(var/signal)
	if(!isnum(signal))
		signal = text2num(signal)
		if(!signal) //wasn't a number
			return 0

	if(!(signal in MINIMUM_FREQUENCY to MAXIMUM_FREQUENCY))
		return 0

	_signaler.set_frequency(signal)
	return 1

/datum/vgcomponent/signaler/proc/setCode(var/signal)
	if(!isnum(signal))
		signal = text2num(signal)
		if(!signal) //wasn't a number
			return 0

	if(!(signal in 1 to 100))
		return 0

	_signaler.code = signal
	return 1

/datum/vgcomponent/signaler/proc/send()
	_signaler.signal()
	return 1


//signaled output
/datum/vgcomponent/signaler/proc/was_signaled()
	handleOutput("signaled", 1)
