/obj/machinery/computer/telecomms/server
	name = "telecommunications server monitor"
	desc = "The ability to see what the command staff was talking about at your fingertips."
	icon_state = "comm_serv"
	circuit = "/obj/item/weapon/circuitboard/comm_server"
	var/obj/machinery/telecomms/server/SelectedServer
	var/universal_translate = FALSE // set to TRUE if it can translate nonhuman speech

/obj/machinery/computer/telecomms/server/Destroy()
	SelectedServer = null
	return ..()

/obj/machinery/computer/telecomms/server/attack_hand(var/mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)

	var/dat = {"
	<div id='logtemp'>
		[temp]
	</div>
	<hr/>
	"}

	switch(screen)
		if (SCREEN_MAIN)
			dat += {"
			<form id='network-form' action="?src\ref[src]" method="get"
				<input type="hidden" name="src" value="\ref[src]"/>
				<input type="hidden" name="scan" value="1"/>
				<label id='network'>
					Current network: <input class='network-input' type="textbox" name="network" value='[network]'/ />
				</label>
				<input type="submit" value="save"/>
				</form>
			"}
			if (machines.len)
				dat += {"
					<b>Detected telecommunication servers:</b>
					<ul>
				"}
				for (var/obj/machinery/telecomms/T in machines)
					var/ref = copytext("\ref[src]", 2, -1) // Cut out brackets.
					dat += {"
						<li>
							<span class="code">[ref]</span>
							<a class='vert' href='?src=\ref[src];viewserver=\ref[T]'>
								[T.name]
							</a>
						</li>
					"}
				dat += {"
					</ul>
					<a id='flush' href='?src=\ref[src];flush=1'>Flush Buffer</a>
				"}
			else
				dat += "<b>No servers detected. Scan for servers:</b> <a href='?src=\ref[src];scan=1'>Scan</a>"

		if (SCREEN_SELECTED)
			var/traffic = ""
			if (SelectedServer.totaltraffic >= 1024)
				traffic = "round(SelectedServer.totaltraffic / 1024) TiB"
			else
				traffic = "[SelectedServer.totaltraffic] GiB"

			dat += {"
				<div id='listcontrols'>
					<a href='?src=\ref[src];mainmenu=1'>Main menu</a>
					<a href='?src=\ref[src];refresh=1'>Refresh</a>
				</div>
				<table>
					<tr>
						<td><b>Current network:</b></td>
						<td class="right"><span class="code">[network]</span></td>
					</tr>
					<tr>
						<td><b>Currently selected server:</b></td>
						<td class="right">[SelectedServer.id]</td>
					</tr>
					<tr>
						<td><b>Total recorded traffic:</b></td>
						<td class="right">[traffic]</td>
					</tr>
				</table>

				<b id="logsmessage">Stored logs:</b><br/>
				<table id="logs">
			"}

			var/i = 0
			for(var/datum/comm_log_entry/C in SelectedServer.log_entries)
				i++
				switch(C.input_type)
					if ("Speech File")
						var/contents = "\"[C.parameters["message"]]\""
						var/source = "[C.parameters["name"]] (Job: [C.parameters["job"]])"
						var/type = C.input_type
						var/race	// The actual race of the mob
						var/language = "Human" // MMis, pAI, Cyborgs and humans all speak human
						var/mobtype = C.parameters["mobtype"]

						var/static/list/humans = typesof(/mob/living/carbon/human, /mob/living/carbon/brain)
						var/static/list/monkeys = typesof(/mob/living/carbon/monkey)
						var/static/list/silicons = typesof(/mob/living/silicon)
						var/static/list/slimes = typesof(/mob/living/carbon/slime)
						var/static/list/animals = typesof(/mob/living/simple_animal)

						// Determine race of orator
						// Jesus Fuck.
						if (mobtype in humans)
							race = "Human"
							language = race
						else if (mobtype in monkeys)
							race = "Monkey"
							language = race
						else if (mobtype in silicons || C.parameters["job"] == "AI")
							race = "Artificial Intelligence"
						else if (mobtype in slimes)
							race = "slimes"
							language = race
						else if (istype(mobtype, /obj))
							race = "Machinery"
							language = race
						else if (mobtype in animals)
							race = "Domestic Animal"
							language = race
						else
							race = "<i>Unidentifiable</i>"
							language = race

						// -- If the orator is a human, or universal translate is active, OR mob has universal speech on --

						if (language != "Human" && !universal_translate && !C.parameters["uspeech"])
							contents = "<i>Unintelligible</i>"
							source = "<i>Unidentifiable</i>"
							type = "Audio File"
						dat += {"
							<tr>
								<td class="messageId">[i].</td>
								<td class="packettype">
									<a href='?src\ref[src];delete=[i]'>X</a>
									<span class="packet">[type]</span>
								</td>
								<td>
									<span class="code">[C.hash]</span>
								</td>
							</tr>
							<tr>
								<td></td>
								<td><b>Source:</b></td>
								<td class="right">[source]</td>
							</tr>
							<tr>
								<td></td>
								<td><b>Class:</b></td>
								<td class="right">[race]</td>
							</tr>

							<tr class="rowspacing">
								<td></td>
								<td><b>Contents:</b></td>
								<td class="right">[contents]</td>
							</tr>
						"}
					if ("Execution Error")
						dat += {"
							<tr>
								<td class="messageid">[i].</td>
								<td class="packettype">
									<a href='?src=\ref[src];delete=[i]'>X</a>
									<span class="error">Execution error</span>
								</td>
								<td>
									<span class="code">[C.hash]</span>
								</td>
							</tr>
							<tr class="rowspacing">
								<td></td>
								<td>
									<b>Output:</b>
								</td>
								<td>
									"DivideByZeroError: \"[C.parameters["message"]]\"
								</td>
							</tr>
						"}
			dat += "</table>"

	var/datum/browser/B = new(user, "\ref[src]", "Telecommunications server monitor", 575, 400, src)
	B.add_stylesheet("server_monitor.css", 'html/browser/telecomms_computer.css')
	B.set_content(dat)
	B.open()
	temp = "&nbsp;"


/obj/machinery/computer/telecomms/server/Topic(href, href_list)
	. = ..()
	if (.)
		return

	add_fingerprint(usr)
	usr.set_machine(src)

	if (href_list["viewserver"])
		var/obj/machinery/telecomms/T = locate(href_list["viewserver"]) in machines
		if (T)
			SelectedServer = T
			screen = SCREEN_SELECTED
		. = TRUE

	if (href_list["flush"])
		machines.Cut()
		screen = SCREEN_MAIN
		. = TRUE

	if (href_list["mainmenu"])
		screen = SCREEN_MAIN
		. = TRUE

	if (href_list["delete"])
		if (!allowed(usr))
			set_temp("<span class='warning'>FAILED: ACCESS DENIED.</span>", BAD)

		else if (SelectedServer)
			var/datum/comm_log_entry/D
			try
				D = SelectedServer.log_entries[text2num(href_list["delete"])]
			catch
				// Could be Out of Bounds, turning it into a float because of href exploits, anything.
				return TRUE
			if (!D)
				return TRUE

			set_temp("DELETED ENTRY: [D.name]", NEUTRAL)

			SelectedServer.log_entries.Remove(D)
			qdel(D)
		else
			set_temp("FAILED: NO SELECTED MACHINE", BAD)
		. = TRUE

	if (href_list["network"])
		var/newnet = reject_bad_text(href_list["network"])
		if (length(newnet) > 15)
			set_temp("FAILED: NETWORK TAG STRING TOO LONG", BAD)
		else
			network = newnet
			machines.Cut()
			screen = SCREEN_MAIN
		. = TRUE

	if (href_list["scan"])
		if (machines.len)
			set_temp("FAILED: CANNOT PROBE WHEN BUFFER FULL", BAD)
		else
			for (var/obj/machinery/telecomms/server/T in range(25, src))
				if (T.network == network)
					machines.Add(T)
			if (!machines.len)
				set_temp("FAILED: UNABLE TO LOCATE SERVERS IN <span class='code'[network]</span", BAD)
			else
				set_temp("[machines.len] SERVERS PROBED & BUFFERED")

			screen = SCREEN_MAIN
		. = TRUE

	if (.)
		updateUsrDialog()

/obj/machinery/computer/telecomms/server/attackby(var/obj/item/weapon/D, var/mob/user)
	if(..())
		return TRUE

	updateUsrDialog()