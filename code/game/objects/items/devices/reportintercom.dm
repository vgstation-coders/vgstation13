/obj/item/device/reportintercom
	icon = 'icons/obj/radio.dmi'
	name = "hacked intercom"
	desc = "Looks like a typical intercom. Except for the wires conspiciously hanging out. 'PROPERTY OF NANOTRASEN CENTRAL COMMAND' is stamped on the side."
	icon_state = "intercom-open"
	item_state = "intercom-open"
	w_class = W_CLASS_TINY
	flags = FPRINT
	siemens_coefficient = 1

	var/used = 0

/obj/item/device/reportintercom/attack_self(mob/user) // can create a custom announcement once
	if(used)
		to_chat(user, "<span class='notice'>You press the [src]'s button, but nothing happens.</span>")
		return

	if(!map.linked_to_centcomm)
		var/confirmation = alert("The station is not linked to central command by a relay. Blow your cover?",,"Yes","No")
		if(confirmation == "No")
			return
	var/input = input(user, "Please enter anything you want. Anything.", "What?", "") as message|null
	var/customname = input(user, "Pick a title for the report.", "Title") as text|null
	if(!input)
		return
	if(!customname)
		customname = "Nanotrasen Update"
	for (var/obj/machinery/computer/communications/C in machines)
		if(! (C.stat & (BROKEN|NOPOWER) ) )
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "'[command_name()] Update.'"
			P.info = input
			P.update_icon()
			C.messagetitle.Add("[command_name()] Update")
			C.messagetext.Add(P.info)

	switch(alert("Should this be announced to the general population?",,"Yes","No"))
		if("Yes")
			command_alert(input, customname,1);
		if("No")
			to_chat(world, "<span class='warning'>New Nanotrasen Update available at all communication consoles.</span>")

	world << sound('sound/AI/commandreport.ogg', volume = 60)
	log_admin("[key_name(user)] has created a fake command report: [input]")
	message_admins("[key_name_admin(user)] has created a fake command report", 1)
	feedback_add_details("admin_verb","FAKECCR")

	icon_state = "intercom-p-open"
	desc = "Looks like a typical intercom. The wires look burnt out. 'PROPERTY OF NANOTRASEN CENTRAL COMMAND' is stamped on the side."
	used = 1
	return 1

/obj/item/device/reportintercom/emag_act(mob/user) //Please don't do this
	if(!used)
		to_chat(user, "<span class='warning'>You overload the [src] and hear an unearthly noise.</span>")

		world << sound('sound/items/AirHorn.ogg')
		//Attention! Code rainbow!
		//There is an immediate serious lack of threats to the station. The clown may have bananas unholstered at all times. The Head of Personnel may now request additional entertainment staff.
		//This can go ahead and look like shit in darkmode.
		var/dat = {"<font size=4><html><div><span style="color:#ff0000;">A</span><span style="color:#ff1900;">t</span><span style="color:#ff3300;">t</span><span style="color:#ff4c00;">e</span><span style="color:#ff6600;">n</span><span style="color:#ff7f00;">t</span><span style="color:#ff9f00;">i</span><span style="color:#ffbf00;">o</span><span style="color:#ffdf00;">n</span><span style="color:#ffff00;">!</span><span style="color:#ccff00;"> </span><span style="color:#99ff00;">C</span><span style="color:#66ff00;">o</span><span style="color:#33ff00;">d</span><span style="color:#00ff00;">e</span><span style="color:#00ff40;"> </span><span style="color:#00ff80;">r</span><span style="color:#00ffbf;">a</span><span style="color:#00ffff;">i</span><span style="color:#00ccff;">n</span><span style="color:#0099ff;">b</span><span style="color:#0066ff;">o</span><span style="color:#0033ff;">w</span><span style="color:#0000ff;">!</span></div></font>
		<span style="color:#ff0000;">T</span><span style="color:#ff0300;">h</span><span style="color:#ff0700;">e</span><span style="color:#ff0a00;">r</span><span style="color:#ff0e00;">e</span><span style="color:#ff1100;"> </span><span style="color:#ff1500;">i</span><span style="color:#ff1800;">s</span><span style="color:#ff1b00;"> </span><span style="color:#ff1f00;">a</span><span style="color:#ff2200;">n</span><span style="color:#ff2600;"> </span><span style="color:#ff2900;">i</span><span style="color:#ff2d00;">m</span><span style="color:#ff3000;">m</span><span style="color:#ff3300;">e</span><span style="color:#ff3700;">d</span><span style="color:#ff3a00;">i</span><span style="color:#ff3e00;">a</span><span style="color:#ff4100;">t</span><span style="color:#ff4500;">e</span><span style="color:#ff4800;"> </span><span style="color:#ff4c00;">s</span><span style="color:#ff4f00;">e</span><span style="color:#ff5200;">r</span><span style="color:#ff5600;">i</span><span style="color:#ff5900;">o</span><span style="color:#ff5d00;">u</span><span style="color:#ff6000;">s</span><span style="color:#ff6400;"> </span><span style="color:#ff6700;">l</span><span style="color:#ff6a00;">a</span><span style="color:#ff6e00;">c</span><span style="color:#ff7100;">k</span><span style="color:#ff7500;"> </span><span style="color:#ff7800;">o</span><span style="color:#ff7c00;">f</span><span style="color:#ff7f00;"> </span><span style="color:#ff8300;">t</span><span style="color:#ff8600;">h</span><span style="color:#ff8a00;">r</span><span style="color:#ff8d00;">e</span><span style="color:#ff9100;">a</span><span style="color:#ff9400;">t</span><span style="color:#ff9800;">s</span><span style="color:#ff9b00;"> </span><span style="color:#ff9f00;">t</span><span style="color:#ffa300;">o</span><span style="color:#ffa600;"> </span><span style="color:#ffaa00;">t</span><span style="color:#ffad00;">h</span><span style="color:#ffb100;">e</span><span style="color:#ffb400;"> </span><span style="color:#ffb800;">s</span><span style="color:#ffbb00;">t</span><span style="color:#ffbf00;">a</span><span style="color:#ffc300;">t</span><span style="color:#ffc600;">i</span><span style="color:#ffca00;">o</span><span style="color:#ffcd00;">n</span><span style="color:#ffd100;">.</span><span style="color:#ffd400;"> </span><span style="color:#ffd800;">T</span><span style="color:#ffdb00;">h</span><span style="color:#ffdf00;">e</span><span style="color:#ffe300;"> </span><span style="color:#ffe600;">c</span><span style="color:#ffea00;">l</span><span style="color:#ffed00;">o</span><span style="color:#fff100;">w</span><span style="color:#fff400;">n</span><span style="color:#fff800;"> </span><span style="color:#fffb00;">m</span><span style="color:#ffff00;">a</span><span style="color:#f8ff00;">y</span><span style="color:#f1ff00;"> </span><span style="color:#eaff00;">h</span><span style="color:#e3ff00;">a</span><span style="color:#ddff00;">v</span><span style="color:#d6ff00;">e</span><span style="color:#cfff00;"> </span><span style="color:#c8ff00;">b</span><span style="color:#c1ff00;">a</span><span style="color:#baff00;">n</span><span style="color:#b3ff00;">a</span><span style="color:#acff00;">n</span><span style="color:#a5ff00;">a</span><span style="color:#9fff00;">s</span><span style="color:#98ff00;"> </span><span style="color:#91ff00;">u</span><span style="color:#8aff00;">n</span><span style="color:#83ff00;">h</span><span style="color:#7cff00;">o</span><span style="color:#75ff00;">l</span><span style="color:#6eff00;">s</span><span style="color:#67ff00;">t</span><span style="color:#60ff00;">e</span><span style="color:#5aff00;">r</span><span style="color:#53ff00;">e</span><span style="color:#4cff00;">d</span><span style="color:#45ff00;"> </span><span style="color:#3eff00;">a</span><span style="color:#37ff00;">t</span><span style="color:#30ff00;"> </span><span style="color:#29ff00;">a</span><span style="color:#22ff00;">l</span><span style="color:#1cff00;">l</span><span style="color:#15ff00;"> </span><span style="color:#0eff00;">t</span><span style="color:#07ff00;">i</span><span style="color:#00ff00;">m</span><span style="color:#00ff07;">e</span><span style="color:#00ff0e;">s</span><span style="color:#00ff15;">.</span><span style="color:#00ff1c;"> </span><span style="color:#00ff23;">T</span><span style="color:#00ff2b;">h</span><span style="color:#00ff32;">e</span><span style="color:#00ff39;"> </span><span style="color:#00ff40;">H</span><span style="color:#00ff47;">e</span><span style="color:#00ff4e;">a</span><span style="color:#00ff55;">d</span><span style="color:#00ff5c;"> </span><span style="color:#00ff63;">o</span><span style="color:#00ff6a;">f</span><span style="color:#00ff71;"> </span><span style="color:#00ff78;">P</span><span style="color:#00ff7f;">e</span><span style="color:#00ff87;">r</span><span style="color:#00ff8e;">s</span><span style="color:#00ff95;">o</span><span style="color:#00ff9c;">n</span><span style="color:#00ffa3;">n</span><span style="color:#00ffaa;">e</span><span style="color:#00ffb1;">l</span><span style="color:#00ffb8;"> </span><span style="color:#00ffbf;">m</span><span style="color:#00ffc6;">a</span><span style="color:#00ffcd;">y</span><span style="color:#00ffd5;"> </span><span style="color:#00ffdc;">n</span><span style="color:#00ffe3;">o</span><span style="color:#00ffea;">w</span><span style="color:#00fff1;"> </span><span style="color:#00fff8;">r</span><span style="color:#00ffff;">e</span><span style="color:#00f8ff;">q</span><span style="color:#00f1ff;">u</span><span style="color:#00eaff;">e</span><span style="color:#00e3ff;">s</span><span style="color:#00ddff;">t</span><span style="color:#00d6ff;"> </span><span style="color:#00cfff;">a</span><span style="color:#00c8ff;">d</span><span style="color:#00c1ff;">d</span><span style="color:#00baff;">i</span><span style="color:#00b3ff;">t</span><span style="color:#00acff;">i</span><span style="color:#00a5ff;">o</span><span style="color:#009fff;">n</span><span style="color:#0098ff;">a</span><span style="color:#0091ff;">l</span><span style="color:#008aff;"> </span><span style="color:#0083ff;">e</span><span style="color:#007cff;">n</span><span style="color:#0075ff;">t</span><span style="color:#006eff;">e</span><span style="color:#0067ff;">r</span><span style="color:#0060ff;">t</span><span style="color:#005aff;">a</span><span style="color:#0053ff;">i</span><span style="color:#004cff;">n</span><span style="color:#0045ff;">m</span><span style="color:#003eff;">e</span><span style="color:#0037ff;">n</span><span style="color:#0030ff;">t</span><span style="color:#0029ff;"> </span><span style="color:#0022ff;">s</span><span style="color:#001cff;">t</span><span style="color:#0015ff;">a</span><span style="color:#000eff;">f</span><span style="color:#0007ff;">f</span><span style="color:#0000ff;">.</span></html>"}
		to_chat(world, dat)

		icon_state = "intercom-p-open"
		desc = "Looks like a typical intercom. The wires look burnt out. 'PROPERTY OF NANOTRASEN CENTRAL COMMAND' is stamped on the side."
		used = 1

		return
	return
