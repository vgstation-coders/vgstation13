/obj/machinery/computer/general_air_control/atmos_automation
	icon = 'icons/obj/computer.dmi'
	icon_state = "aac"
	circuit = "/obj/item/weapon/circuitboard/atmos_automation"

	show_sensors = 0
	var/on = 0

	name = "Atmospherics Automations Console"

	var/list/datum/automation/automations=list()

	//Registers, see them as variables for the AAC.
	var/register_amount = 10//Determines the maximal registers you can have.
	var/list/registers = list()//Stores the register values, registers can't be named so this is enough.

	var/list/linked_assemblies = list() //Can have up to 5 assemblies connected. AAC scripts can pulse them
	var/const/max_linked_assembly_amount = 5

/obj/machinery/computer/general_air_control/atmos_automation/New()
	..()
	for(var/i = 1, i <= register_amount, i++)//Fill the registers
		registers.Add(list(0))

	for(var/i = 1 to max_linked_assembly_amount)
		linked_assemblies.Add(null)

/obj/machinery/computer/general_air_control/atmos_automation/Destroy()
	linked_assemblies = null

	..()

/obj/machinery/computer/general_air_control/atmos_automation/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["tag"]
	if(!id_tag)
		return

	sensor_information[id_tag] = signal.data

/obj/machinery/computer/general_air_control/atmos_automation/process()
	if(on)
		for(var/datum/automation/A in automations)
			A.process()

/obj/machinery/computer/general_air_control/atmos_automation/update_icon()
	icon_state = initial(icon_state)
	// Broken
	if(stat & BROKEN)
		icon_state += "b"

	// Powered
	else if(stat & NOPOWER)
		icon_state = initial(icon_state)
		icon_state += "0"
	else if(on)
		icon_state += "_active"

/obj/machinery/computer/general_air_control/atmos_automation/proc/request_device_refresh(var/device)
	send_signal(list("tag"=device, "status"))

/obj/machinery/computer/general_air_control/atmos_automation/proc/send_signal(var/list/data, filter = RADIO_ATMOSIA)
	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.transmission_method = 1 //radio signal
	signal.source = src
	signal.data=data
	signal.data["sigtype"]="command"
	radio_connection.post_signal(src, signal, filter = filter)

/obj/machinery/computer/general_air_control/atmos_automation/proc/selectValidChildFor(var/datum/automation/parent, var/mob/user, var/list/valid_returntypes)
	var/list/choices=list()
	for(var/childtype in automation_types)
		var/datum/automation/A = new childtype(src)
		if(A.returntype == null)
			continue
		if(!(A.returntype in valid_returntypes))
			continue
		choices[A.name]=A
	if (choices.len==0)
		testing("Unable to find automations with returntype in [english_list(valid_returntypes)]!")
		return 0
	var/label=input(user, "Select new automation:", "Automations", "Cancel") as null|anything in choices
	if(!label)
		return 0
	return choices[label]

/obj/machinery/computer/general_air_control/atmos_automation/return_text()
	var/out=..()

	if(on)
		out += "<a href=\"?src=\ref[src];on=1\" style=\"font-size:large;font-weight:bold;color:red;\">RUNNING</a>"
	else
		out += "<a href=\"?src=\ref[src];on=1\" style=\"font-size:large;font-weight:bold;color:green;\">STOPPED</a>"

	out += "<p><a href=\"?src=\ref[src];view_assemblies=1\">View connected assemblies</a></p>"

	out += {"
		<h2>Automations</h2>
		<p>\[
		<a href="?src=\ref[src];add=1">
			Add
		</a>
		|
		<a href="?src=\ref[src];reset=*">
			Reset All
		</a>
		|
		<a href="?src=\ref[src];remove=*">
			Clear
		</a>
		\]</p>
		<p>\[
		<a href="?src=\ref[src];dump=1">
			Export
		</a>
		|
		<a href="?src=\ref[src];read=1">
			Import
		</a>
		\]</p>"}
	if(automations.len==0)
		out += "<i>No automations present.</i>"
	else
		for(var/datum/automation/A in automations)
			out += {"
				<fieldset>
					<legend>
						<a href="?src=\ref[src];label=\ref[A]">[A.label]</a>
						(<a href="?src=\ref[src];reset=\ref[A]">Reset</a> |
						<a href="?src=\ref[src];remove=\ref[A]">&times;</a>)
					</legend>
					[A.GetText()]
				</fieldset>
			"}

	out += "<h2>Registers</h2>"
	for(var/i = 1, i <= register_amount, i++)
		out += {"
			<fieldset>
				<legend>
					Register [i]
				</legend>
				<a href="?src=\ref[src];editregister=[i]">[registers[i] == null ? 0 : registers[i]]</a>
			</fieldset>
		"}

	return out

/obj/machinery/computer/general_air_control/atmos_automation/Topic(href,href_list)
	if(..())
		return
	if(href_list["on"])
		on = !on
		updateUsrDialog()
		update_icon()
		investigation_log(I_ATMOS,"was turned [on ? "on" : "off"] by [key_name(usr)]")
		return 1

	if(href_list["add"])
		var/new_child=selectValidChildFor(null,usr,list(0))
		if(!new_child)
			return 1
		automations += new_child
		updateUsrDialog()
		return 1

	if(href_list["label"])
		var/datum/automation/A=locate(href_list["label"])
		if(!A) return 1
		var/nl=input(usr, "Please enter a label for this automation task.") as text|null
		if(!nl) return 1
		nl	= copytext(sanitize(nl), 1, 50)
		A.label=nl
		updateUsrDialog()
		return 1

	if(href_list["reset"])
		if(href_list["reset"]=="*")
			investigation_log(I_ATMOS,"had all automations reset by [key_name(usr)]")
			for(var/datum/automation/A in automations)
				if(!A) continue
				A.OnReset()
		else
			var/datum/automation/A=locate(href_list["reset"])
			if(!A) return 1
			A.OnReset()
			investigation_log(I_ATMOS,"had the [A.name]/[A.desc] automation reset by [key_name(usr)]")
		updateUsrDialog()
		return 1

	if(href_list["remove"])
		if(href_list["remove"]=="*")
			investigation_log(I_ATMOS,"had all automations removed by [key_name(usr)]")
			var/confirm=alert("Are you sure you want to remove ALL automations?","Automations","Yes","No")
			if(confirm == "No") return 0
			for(var/datum/automation/A in automations)
				if(!A) continue
				A.OnRemove()
				automations.Remove(A)
		else
			var/datum/automation/A=locate(href_list["remove"])
			if(!A) return 1
			A.OnRemove()
			automations.Remove(A)
			investigation_log(I_ATMOS,"had the [A.name]/[A.desc] automation removed by [key_name(usr)]")
		updateUsrDialog()
		return 1

	if(href_list["read"])
		var/code = input("Input exported AAC code.","Automations","") as message|null
		if(!code || (!issilicon(usr) && !Adjacent(usr))) return 0
		try // To prevent invalid JSON causing runtimes.
			ReadCode(code)
		catch
			to_chat(usr, "<span class=warning>Invalid JSON.</span>")
			return 1
		updateUsrDialog()
		investigation_log(I_ATMOS,"had an automations list imported by [key_name(usr)]: [code]")
		return 1

	if(href_list["dump"])
		input("Exported AAC code:","Automations",DumpCode()) as message|null
		return 0

	if(href_list["editregister"])
		var/registerid = text2num(href_list["editregister"])//This'll be text by default.
		registerid = sanitize_integer(registerid, min = 1, max = register_amount)//Can't be too sure.

		if(!registerid)//Something wasn't sane.
			return 1

		var/oldreg = registers[registerid]
		registers[registerid] = input("Input register value:", "Register [registerid]", registers[registerid]) as num//Ask the user.
		investigation_log(I_ATMOS,"had the [registerid]\th registerID changed from [oldreg] to [registers[registerid]] by [key_name(usr)]")
		updateUsrDialog()
		return 1

	//Assembly stuff

	if(href_list["connect_assembly"])
		var/id = text2num(href_list["connect_assembly"])

		var/obj/item/device/assembly/A = linked_assemblies[id]

		if(isnull(A)) //Nothing connected in the specified socket - take assembly from hand and connect it
			var/obj/item/device/assembly/to_connect = usr.get_active_hand()

			if(istype(to_connect)) //User's active hand holds an assembly
				if(usr.drop_item(to_connect, src)) //Stick it in and connect it
					linked_assemblies[id] = to_connect
			else
				to_chat(usr, "<span class='info'>Hold the assembly in your hand and press this button to connect it.</span>")

		else //Something connected - eject it
			linked_assemblies[id] = null
			A.forceMove(get_turf(src))

			to_chat(usr, "<span class='info'>You eject \the [A] from socket #[id].</span>")

		href_list["view_assemblies"] = 1 //Update the window!

	if(href_list["view_assemblies"]) //Open a separate window that lists connected assemblies
		var/dat = "<h2>Connected assemblies</h2>"
		for(var/i = 1 to max_linked_assembly_amount)
			dat += "<p>[i]) <a href=\"?src=\ref[src];connect_assembly=[i]\">[isnull(linked_assemblies[i]) ? "-click to insert-" : linked_assemblies[i]]</a></p>"

		var/datum/browser/popup = new(usr, "AAC_assemblies", "[src]", 500, 300, src)
		popup.set_content(dat)
		popup.open()

		onclose(usr, "AAC_assemblies")


/obj/machinery/computer/general_air_control/atmos_automation/proc/MakeCompare(var/datum/automation/a, var/datum/automation/b, var/comparetype)
	var/datum/automation/compare/compare=new(src)
	compare.comparator = comparetype
	compare.children[1] = a
	compare.children[2] = b
	return compare

/obj/machinery/computer/general_air_control/atmos_automation/proc/MakeNumber(var/value)
	var/datum/automation/static_value/val = new(src)
	val.value=value
	return val

/obj/machinery/computer/general_air_control/atmos_automation/proc/MakeGetSensorData(var/sns_tag,var/field)
	var/datum/automation/get_sensor_data/sensor=new(src)
	sensor.sensor=sns_tag
	sensor.field=field
	return sensor

/obj/machinery/computer/general_air_control/atmos_automation/proc/DumpCode()
	var/list/json[0]
	for(var/datum/automation/A in automations)
		json += list(A.Export())
	return list2json(json)

/obj/machinery/computer/general_air_control/atmos_automation/proc/ReadCode(var/jsonStr)
	automations.len = 0
	var/list/json=json2list(jsonStr)
	if(json && json.len > 0)
		for(var/list/cData in json)
			if(isnull(cData) || !("type" in cData))
				testing("AAC: Null cData in root JS array.")
				continue
			var/Atype=text2path(cData["type"])
			if(!(Atype in automation_types))
				testing("AAC: Unrecognized Atype [Atype].")
				continue
			var/datum/automation/A = new Atype(src)
			A.Import(cData)
			automations += A

/obj/machinery/computer/general_air_control/atmos_automation/burnchamber
	var/injector_tag="inc_in"
	var/output_tag="inc_out"
	var/sensor_tag="inc_sensor"
	frequency=1449
	var/temperature=1000
/obj/machinery/computer/general_air_control/atmos_automation/burnchamber/New()
	..()

	// On State
	// Pretty much this:
	/*
		if(get_sensor("inc_sensor","temperature") < 200)
			set_injector_state("inc_in",1)
			set_vent_pump_power("inc_out",0)
		else
			set_vent_pump_power("inc_out",1
	*/

	var/datum/automation/get_sensor_data/sensor=new(src)
	sensor.sensor=sensor_tag
	sensor.field="temperature"

	var/datum/automation/static_value/val = new(src)
	val.value=temperature - 800

	var/datum/automation/compare/compare=new(src)
	compare.comparator = "Less Than"
	compare.children[1] = sensor
	compare.children[2] = val

	var/datum/automation/set_injector_power/inj_on=new(src)
	inj_on.injector=injector_tag
	inj_on.state=1

	var/datum/automation/set_vent_pump_power/vp_on=new(src)
	vp_on.vent_pump=output_tag
	vp_on.state=1

	var/datum/automation/set_vent_pump_power/vp_off=new(src)
	vp_off.vent_pump=output_tag
	vp_off.state=0

	var/datum/automation/if_statement/i = new (src)
	i.label = "Fuel Injector On"
	i.condition = compare
	i.children_then.Add(inj_on)
	i.children_then.Add(vp_off)
	i.children_else.Add(vp_on)

	automations += i

	// Off state
	/*
		if(get_sensor("inc_sensor","temperature") > 1000)
			set_injector_state("inc_in",0)
	*/
	sensor=new(src)
	sensor.sensor=sensor_tag
	sensor.field="temperature"

	val = new(src)
	val.value=temperature

	compare=new(src)
	compare.comparator = "Greater Than"
	compare.children[1] = sensor
	compare.children[2] = val

	var/datum/automation/set_injector_power/inj_off=new(src)
	inj_off.injector=injector_tag
	inj_off.state=0

	i = new (src)
	i.label = "Fuel Injector Off"
	i.condition = compare
	i.children_then.Add(inj_off)

	automations += i

/obj/machinery/computer/general_air_control/atmos_automation/air_mixing
	var/n2_injector_tag="air_n2_in"
	var/o2_injector_tag="air_o2_in"
	var/output_tag="air_out"
	var/sensor_tag="air_sensor"
	frequency=1443
	var/temperature=1000
/obj/machinery/computer/general_air_control/atmos_automation/air_mixing/New()
		..()
		buildO2()
		buildN2()
		buildOutletVent()

/obj/machinery/computer/general_air_control/atmos_automation/air_mixing/proc/buildO2()
	///////////////////////////////////////////////////////////////
	// Oxygen Injection
	///////////////////////////////////////////////////////////////

	var/datum/automation/set_injector_power/inj_on=new(src)
	inj_on.injector=o2_injector_tag
	inj_on.state=1

	var/datum/automation/set_injector_power/inj_off=new(src)
	inj_off.injector=o2_injector_tag
	inj_off.state=0

	var/datum/automation/if_statement/i = new (src)
	i.label = "Oxygen Injection"
	i.condition = MakeCompare(
		MakeGetSensorData(sensor_tag,"oxygen"),
		MakeNumber(20),
		"Less Than or Equal to"
	)
	i.children_then.Add(inj_on)
	i.children_else.Add(inj_off)

	automations += i

/obj/machinery/computer/general_air_control/atmos_automation/air_mixing/proc/buildN2()
	///////////////////////////////////////////////////////////////
	// Nitrogen Injection
	///////////////////////////////////////////////////////////////
	/*
	if(get_sensor_data("pressure") < 100)
		injector_on()
	else
		if(get_sensor_data("pressure") > 5000)
			injector_off()
	*/

	var/datum/automation/set_injector_power/inj_on=new(src)
	inj_on.injector=n2_injector_tag
	inj_on.state=1

	var/datum/automation/set_injector_power/inj_off=new(src)
	inj_off.injector=n2_injector_tag
	inj_off.state=0

	var/datum/automation/if_statement/if_on = new (src)
	if_on.label = "Nitrogen Injection"
	if_on.condition = MakeCompare(
		MakeGetSensorData(sensor_tag,"pressure"),
		MakeNumber(100),
		"Less Than"
	)
	if_on.children_then.Add(inj_on)


	var/datum/automation/if_statement/if_off=new(src)
	if_off.condition=MakeCompare(
		MakeGetSensorData(sensor_tag,"pressure"),
		MakeNumber(5000),
		"Greater Than"
	)
	if_off.children_then.Add(inj_off)

	if_on.children_else.Add(if_off)

	automations += if_on

/obj/machinery/computer/general_air_control/atmos_automation/air_mixing/proc/buildOutletVent()
	///////////////////////////////////////////////////////////////
	// Outlet Management
	///////////////////////////////////////////////////////////////
	/*
		if(get_sensor_data("pressure") >= 5000 && get_sensor_data("oxygen") >= 20)
			vent_on()
		else
			if(get_sensor_data("oxygen") < 20 || get_sensor_data("pressure") < 100)
				vent_off()
	*/

	var/datum/automation/set_vent_pump_power/vp_on=new(src)
	vp_on.vent_pump=output_tag
	vp_on.state=1

	var/datum/automation/set_vent_pump_power/vp_off=new(src)
	vp_off.vent_pump=output_tag
	vp_off.state=0

	var/datum/automation/if_statement/if_on=new(src)
	if_on.label="Air Output"

	var/datum/automation/and/and_on=new(src)
	and_on.children.Add(
		MakeCompare(
			MakeGetSensorData(sensor_tag,"pressure"),
			MakeNumber(5000),
			"Greater Than or Equal to"
		)
	)
	and_on.children.Add(
		MakeCompare(
			MakeGetSensorData(sensor_tag,"oxygen"),
			MakeNumber(20),
			"Greater Than or Equal to"
		)
	)
	if_on.condition=and_on
	if_on.children_then.Add(vp_on)

	//////////////////////////////

	var/datum/automation/if_statement/if_off=new(src)

	var/datum/automation/or/or_off=new(src)
	or_off.children.Add(
		MakeCompare(
			MakeGetSensorData(sensor_tag,"pressure"),
			MakeNumber(100),
			"Less Than"
		)
	)
	or_off.children.Add(
		MakeCompare(
			MakeGetSensorData(sensor_tag,"oxygen"),
			MakeNumber(20),
			"Less Than"
		)
	)
	if_off.condition=or_off
	if_off.children_then.Add(vp_off)

	if_on.children_else.Add(if_off)

	automations += if_on
