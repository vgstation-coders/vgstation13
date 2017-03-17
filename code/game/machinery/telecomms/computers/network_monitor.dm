/*
	The network monitor tracks the overall trafficing of a telecommunications network
	and displays a heirarchy of linked machines.
*/

/obj/machinery/computer/telecomms/monitor
	name = "telecommunications network monitor"
	desc = "Shows the network graph of all machinery on a network."
	icon_state = "comm_monitor"
	circuit = "/obj/item/weapon/circuitboard/comm_monitor"
	var/obj/machinery/telecomms/selected = null // Currently selected machine

/obj/machinery/computer/telecomms/monitor/Destroy()
	selected = null
	return ..()

/obj/machinery/computer/telecomms/monitor/attack_hand(var/mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)

	var/dat = {"
		<div id='logtemp'>
			<span class='[(auth ? "good" : "bad")]'>[(auth ? "Authenticated" : "Unauthenticated")]</span>
		</div>
		<hr/>
		<div id='logtemp'>
			[temp]
		</div>
		<hr/>
	"}

	switch(screen)
		if (SCREEN_MAIN)
			dat += {"
				<form id='network-form' action="?src=\ref[src]" method="get">
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
					<b>Detected network entities:</b>
					<ul>
				"}
				for (var/obj/machinery/telecomms/T in machines)
					// Cut out brackets.
					var/ref = copytext("\ref[T]", 2, -1)
					dat += {"
						<li>
							<span class="code">[ref]</span>
							<a class='vert' href='?src=\ref[src];viewmachine=\ref[T]'>
								[T.name]
							</a>
						</li>
					"}
				dat += {"
					</ul>
					<a id='flush' href='?src=\ref[src];flush=1'>Flush buffer</a>
				"}
			else
				dat += "<b>No network entities detected. Scan for entities:</b> <a href='?src=\ref[src];scan=1'>Scan</a>"
		if (SCREEN_SELECTED)
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
						<td><b>Currently selected entity:</b></td>
						<td class="right">[selected.name]</td>
					</tr>
				</table>

				<b id="logsmessage">Linked entities:</b><br/>
				<ol>
			"}

			for (var/obj/machinery/telecomms/T in selected.links)
				if (!T.hide)
					// Cut off brackets
					var/ref = copytext("\ref[T]", 2, -1)
					dat += {"
						<li>
							<span class="code">[ref]</span>
							<a class='vert' href='?src=\ref[src];viewmachine=\ref[T]'>
								[T.name]
							</a>
						</li>
					"}
			dat += "</ol>"

	var/datum/browser/B = new(user, "\ref[src]", "Telecommunications network monitor", 575, 400, src)
	B.add_stylesheet("telecomms_computer.css", 'html/browser/telecomms_computer.css')
	B.set_content(dat)
	B.open()
	temp = "&nbsp;"

/obj/machinery/computer/telecomms/monitor/Topic(href, href_list)
	. = ..()
	if (.)
		return

	add_fingerprint(usr)
	usr.set_machine(src)

	if (href_list["viewmachine"])
		var/obj/machinery/telecomms/T = locate(href_list["viewmachine"]) in machines
		if (T)
			screen = SCREEN_SELECTED
			selected = T
		. = TRUE

	if (href_list["flush"])
		machines.Cut()
		screen = SCREEN_MAIN
		. = TRUE

	if (href_list["mainmenu"])
		screen = SCREEN_MAIN
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
			for (var/obj/machinery/telecomms/T in range(25, src))
				if (T.network == network)
					machines.Add(T)
				if (!machines.len)
					set_temp("FAILED: UNABLE TO LOCATE NETWORK ENTITIES IN <span class='code'>[network]", BAD)
				screen = SCREEN_MAIN
			. = TRUE
	
	if (href_list["refresh"])
		. = TRUE

	if (.)
		updateUsrDialog()

/obj/machinery/computer/telecomms/monitor/attackby(var/obj/item/weapon/D, var/mob/user)
	if(..())
		return TRUE
	updateUsrDialog()