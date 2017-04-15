/obj/machinery/computer/telecomms/traffic
	name = "telecommunications traffic control"
	desc = "Controls the telecommunication servers' software."
	icon_state = "computer_generic"
	circuit = "/obj/item/weapon/circuitboard/comm_traffic"
	var/obj/machinery/telecomms/server/selected = null // Currently selected machine
	var/allservers = FALSE // Are all servers being edited at the same time?

	var/mob/editingcode
	var/mob/lasteditor
	var/list/viewingcode = list()

	var/result_text =  "" // Compilation results

	var/storedcode = ""
	var/compilingerrors
	var/obj/item/weapon/card/id/auth = null
	var/list/access_log = list()

/obj/machinery/computer/telecomms/traffic/Destroy()
	selected = null
	return ..()

/obj/machinery/computer/telecomms/traffic/attack_hand(var/mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)

	if (!editingcode || editingcode && editingcode.machine != src)
		editingcode = user
		lasteditor = user
	
	var/dat = {"
		<div id='logtemp'>
			<span class='[(auth ? "good" : "bad")]'>[(auth ? "Authenticated" : "Unauthenticated")]</span>
			<a href='?src=\ref[src];auth=1'>[(auth ? auth.registered_name : "Insert ID")]</a>
		</div>
		<hr/>
		<div id='logtemp'>
			[temp]
		</div>
		<hr/>
	"}
	switch (screen)
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
					<b>Detected telecommunication servers:</b>
					<ul>
				"}
				if (machines.len > 1)
					dat += {"
						<li>
							<a class='vert' href='?src=\ref[src];viewserver=all'>
								Modify all detected servers
							</a>
						</li>
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
						<td class="right">[allservers ? "All servers" : selected.id]</td>
					</tr>
					<tr>
						<td><b>Actions:</b></td>
						<td class="right">
							<a href='?src=\ref[src];editcode=1'>
								Edit code
							</a>
						</td>
					</tr>
					<tr>
						<td><b>Signal execution:</b></td>
			"}
			if (allservers)
				dat += {"
					<td>
						<a href='?src=\ref[src];runon=1'>ALWAYS</a>
						<a href='?src=\ref[src];runoff=1'>NEVER</a>
					</td>
				"}
			else
				dat += {"
					<td>
						<a href='?src=\ref[src];togglerun=1'>[selected.autoruncode ? "ALWAYS" : "NEVER"]</a>
					</td>
				"}
			
			dat += "</tr></table>"
		if (SCREEN_EDITOR)
			if (editingcode == user)
				dat += {"
					<div id='listcontrols'>
						<a href='?src=\ref[src];codeback=1'>Back</a>
						<a href='?src=\ref[src];mainmenu=1'>Main menu</a>
						<a href='?src=\ref[src];refresh=1'>Refresh</a>
					</div>

					<style type="text/css">
						.CodeMirror {
						  height: auto;
						}
						button {
							color: #ffffff;
							text-decoration: none;
							background: #40628a;
							border: 1px solid #161616;
							padding: 1px 4px 1px 4px;
							margin: 0 2px 0 0;
							cursor:default;
						}
						button:hover {
							color: #40628a;
							background: #ffffff;
						}
					</style>

					<div class="statusDisplay">
						<textarea id="fSubmit" name="cMirror">[storedcode]</textarea>
					</div>
					<script type="text/javascript">
						var cMirror_fSubmit = CodeMirror.fromTextArea(document.getElementById("fSubmit"),
						{
							lineNumbers: true,
							indentUnit: 4,
							indentWithTabs: true,
							mode: "NTSL",
							theme: "lesser-dark",
							viewportMargin: Infinity
						}
						);
						function compileCode() {
							var codeText = cMirror_fSubmit.getValue();
							document.getElementById("cMirrorPost").value = codeText;
							document.getElementById("theform").submit();
						}
						function clearCode() {
							window.location = "byond://?src=\ref[src];choice=Clear;";
						}
					</script>
					<a href="javascript:compileCode()">Compile</a>
					<a href="javascript:clearCode()">Clear</a>
					<div class="item">
						[result_text]
					</div>
					<form action="byond://" method="POST" id="theform">
						<input type="hidden" name="choice" value="Compile">
						<input type="hidden" name="src" value="\ref[src]">
						<input type="hidden" id="cMirrorPost" name="cMirror" value="">
					</form>
				"}
			else
				dat += {"
					<div id='listcontrols'>
						<a href='?src=\ref[src];refresh=1'>Refresh</a>
					</div>
					<div class="item" style="width:80%">
						<textarea id="fSubmit" name="cMirror">
							[storedcode]
						</textarea>
						<script>
							var editor = CodeMirror.fromTextArea(document.getElementById("fSubmit"),
							{
							lineNumbers: true,
							indentUnit: 4,
							indentWithTabs: true,
							mode: "NTSL",
							theme: "lesser-dark",
							viewportMargin: Infinity
							}
							);
						</script>
					</div>
					<div class="item">
						[result_text]
					</div>
				"} //anything typed will be overridden anyways by the one who is editing the code
			
	var/datum/browser/B = new(user, "\ref[src]", "Telecommunications traffic control", 700, 500, src)
	B.add_script("codemirror-compressed", 'nano/codemirror/codemirror-compressed.js') // A custom minified JavaScript file of CodeMirror, with the following plugins: CSS Mode, NTSL Mode, CSS-hint addon, Search addon, Sublime Keymap.
	B.add_stylesheet("codemirror", 'nano/codemirror/codemirror.css')                  // A CSS sheet containing the basic stylings and formatting information for CodeMirror.
	B.add_stylesheet("lesser-dark", 'nano/codemirror/lesser-dark.css')                // A theme for CodeMirror to use, which closely resembles the rest of the NanoUI style.
	B.add_stylesheet("telecomms_computer.css", 'html/browser/telecomms_computer.css')
	B.set_content(dat)
	B.open()
	temp = "&nbsp;"

/obj/machinery/computer/telecomms/traffic/proc/create_log(var/entry, var/mob/user)
	var/id = null
	if(issilicon(user))
		id = "System Administrator"
	else
		if(auth)
			id = "[auth.registered_name] ([auth.assignment])"
		else
			error("There is a null auth while the user isn't a silicon! ([user.name], [user.type])")
			return
	access_log += "\[[get_timestamp()]\] [id] [entry]"

/obj/machinery/computer/telecomms/traffic/proc/print_logs()
	. = "<center><h2>Traffic Control Telecomms System Log</h2></center><HR>"
	for(var/entry in access_log)
		. += entry + "<BR>"
	return .

/obj/machinery/computer/telecomms/traffic/Topic(href, href_list)
	. = ..()
	if (.)
		return

	var/mob/user = usr

	if (!istype(user) || !user.client)
		return

	if (user != editingcode)
		return

	var/code = href_list["cMirror"]
	if (code)
		storedcode = code
	
	add_fingerprint(usr)
	usr.set_machine(src)

	if (href_list["viewserver"])
		if (href_list["viewserver"] == "all")
			allservers = TRUE
			screen = SCREEN_SELECTED
		else
			allservers = FALSE
			var/obj/machinery/telecomms/server/T = locate(href_list["viewserver"]) in machines
			if (T)
				selected = T
				screen = SCREEN_SELECTED
		. = TRUE

	if (href_list["flush"])
		machines.Cut()
		screen = SCREEN_MAIN
		. = TRUE

	if (href_list["mainmenu"])
		screen = SCREEN_MAIN
		. = TRUE

	if (href_list["refresh"])
		. = TRUE

	if (href_list["auth"])
		if (iscarbon(usr))
			var/mob/living/carbon/C = usr
			if (!auth)
				var/obj/item/weapon/card/id/I = C.get_active_hand()
				if (istype(I))
					if (check_access(I))
						if (C.drop_item(I, src))
							auth = I
							set_temp("LOGGED IN")
			else
				auth.forceMove(src.loc)
				C.put_in_hands(auth)
				auth = null
				screen = SCREEN_MAIN
				set_temp("LOGGED OUT")
			updateUsrDialog()
			return

	if (!auth && !issilicon(usr) && !emagged)
		set_temp("ACCESS DENIED", BAD)
		return

	if(href_list["print"])
		usr << browse(print_logs(), "window=traffic_logs")
		return

	switch(href_list["choice"])
		if ("Compile")
			if (!code)
				return
			if (user != editingcode)
				return
			var/list/obj/machinery/telecomms/server/target_servers = list()
			if (selected)
				target_servers.Add(selected)
			else if (allservers)
				target_servers = machines
			spawn(0)
				result_text = "Please wait, compiling..."
				updateUsrDialog()
				for (var/obj/machinery/telecomms/server/server in target_servers)
					server.setcode(code)
					var/list/compileerrors = server.compile(user)
					if (!telecomms_check(user))
						return
					if (compileerrors.len)
						result_text = "<b>Compilation errors:</b><br>"
						for (var/datum/scriptError/e in compileerrors)
							result_text += "[e.message]<br>"
						result_text += "([compileerrors.len] errors)"
						updateUsrDialog()
				result_text = "TCS compilation successful!<br>"
				result_text += "(0 errors)"
				updateUsrDialog()
		if ("Clear")
			if (!telecomms_check(user) || user != editingcode)
				return
			var/list/var/obj/machinery/telecomms/server/target_servers
			if (selected)
				target_servers = list(selected)
			else if (allservers)
				target_servers = machines
			for (var/obj/machinery/telecomms/server/server in target_servers)
				server.memory.Cut()
				result_text = "Server memory cleared!"
				storedcode = null
				. = TRUE
	
	if (href_list["codeback"])
		if (allservers || selected)
			screen = SCREEN_SELECTED
		. = TRUE

	if (href_list["editcode"])
		screen = SCREEN_EDITOR
		. = TRUE

	if (href_list["togglerun"])
		selected.autoruncode = !(selected.autoruncode)
		. = TRUE
	
	if (href_list["runon"])
		for (var/obj/machinery/telecomms/server/server in machines)
			server.autoruncode = TRUE
		. = TRUE
	
	if (href_list["runoff"])
		for (var/obj/machinery/telecomms/server/server in machines)
			server.autoruncode = FALSE
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

/obj/machinery/computer/telecomms/traffic/attackby(var/obj/item/weapon/D, var/mob/user)
	return ..()
	updateUsrDialog()

/obj/machinery/computer/telecomms/traffic/proc/canAccess(var/mob/user)
	if(issilicon(user) || in_range(src,user))
		return 1
	return 0

/proc/telecomms_check(var/mob/mob)
	if(mob && istype(mob.machine, /obj/machinery/computer/telecomms/traffic) && in_range(mob.machine, mob) || issilicon(mob) && istype(mob.machine, /obj/machinery/computer/telecomms/traffic))
		return 1
	return 0