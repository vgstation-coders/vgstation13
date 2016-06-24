
/obj/machinery/computer2
	name = "computer"
	desc = "A computer workstation."
	icon = 'icons/obj/computer.dmi'
	icon_state = "aiupload"
	density = 1
	anchored = 1.0
	req_access = list() //This doesn't determine PROGRAM req access, just the access needed to install/delete programs.
	var/base_icon_state = "aiupload" //Assembly creates a new computer2 and not a child typepath, so initial doesn't work!!
	var/datum/radio_frequency/radio_connection
	var/obj/item/weapon/disk/data/fixed_disk/hd = null
	var/datum/computer/file/computer_program/active_program
	var/datum/computer/file/computer_program/host_program //active is set to this when the normal active quits, if available
	var/list/processing_programs = list()
	var/obj/item/weapon/card/id/authid = null //For records computers etc
	var/obj/item/weapon/card/id/auxid = null //For computers that need two ids for some reason.
	var/obj/item/weapon/disk/data/diskette = null
	var/list/peripherals = list()
	//Setup for Starting program & peripherals
	var/setup_starting_program = null //If set to a program path it will start with this one active.
	var/setup_starting_peripheral = null //Spawn with radio card and whatever path is here.
	var/setup_drive_size = 64.0 //How big is the drive (set to 0 for no drive)
	var/setup_id_tag
	var/setup_has_radio = 0 //Does it spawn with a radio peripheral?
	var/setup_radio_tag
	var/setup_frequency = 1411

/obj/item/weapon/disk/data
	var/datum/computer/folder/root = null
	var/file_amount = 32.0
	var/file_used = 0.0
	var/portable = 1
	var/title = "Data Disk"
	New()
		root = new /datum/computer/folder
		root.holder = src
		root.name = "root"

/obj/item/weapon/disk/data/fixed_disk
	name = "Storage Drive"
	icon_state = "harddisk"
	title = "Storage Drive"
	file_amount = 80.0
	portable = 0

	attack_self(mob/user as mob)
		return

/obj/item/weapon/disk/data/computer2test
	name = "Programme Diskette"
	file_amount = 128.0
	New()
		..()
		root.add_file( new /datum/computer/file/computer_program/arcade(src))
		root.add_file( new /datum/computer/file/computer_program/med_data(src))
		root.add_file( new /datum/computer/file/computer_program/airlock_control(src))
		root.add_file( new /datum/computer/file/computer_program/messenger(src))
		root.add_file( new /datum/computer/file/computer_program/progman(src))

/obj/machinery/computer2/medical
	name = "Medical computer"
	icon_state = "dna"
	setup_has_radio = 1
	setup_starting_program = /datum/computer/file/computer_program/med_data
	setup_starting_peripheral = /obj/item/weapon/peripheral/printer

/obj/machinery/computer2/arcade
	name = "arcade machine"
	icon_state = "arcade"
	desc = "An arcade machine."
	setup_drive_size = 16.0
	setup_starting_program = /datum/computer/file/computer_program/arcade
	setup_starting_peripheral = /obj/item/weapon/peripheral/prize_vendor


/obj/machinery/computer2/New()
	..()

	spawn(4)
		if(setup_has_radio)
			var/obj/item/weapon/peripheral/radio/radio = new /obj/item/weapon/peripheral/radio(src)
			radio.frequency = setup_frequency
			radio.code = setup_radio_tag

		if(!hd && (setup_drive_size > 0))
			hd = new /obj/item/weapon/disk/data/fixed_disk(src)
			hd.file_amount = setup_drive_size

		if(ispath(setup_starting_program))
			active_program = new setup_starting_program
			active_program.id_tag = setup_id_tag

			hd.file_amount = max(hd.file_amount, active_program.size)

			active_program.transfer_holder(hd)

		if(ispath(setup_starting_peripheral))
			new setup_starting_peripheral(src)

		base_icon_state = icon_state

	return

/obj/machinery/computer2/attack_hand(mob/user as mob)
	if(..())
		return

	user.machine = src

	var/dat
	if((active_program) && (active_program.master == src) && (active_program.holder in src))
		dat = active_program.return_text()
	else
		dat = "<TT><b>Thinktronic BIOS V1.4</b><br><br>"

		dat += "Current ID: <a href='?src=\ref[src];id=auth'>[authid ? "[authid.name]" : "----------"]</a><br>"
		dat += "Auxiliary ID: <a href='?src=\ref[src];id=aux'>[auxid ? "[auxid.name]" : "----------"]</a><br><br>"

		var/progdat
		if((hd) && (hd.root))
			for(var/datum/computer/file/computer_program/P in hd.root.contents)
				progdat += "<tr><td>[P.name]</td><td>Size: [P.size]</td>"

				progdat += "<td><a href='byond://?src=\ref[src];prog=\ref[P];function=run'>Run</a></td>"

				if(P in processing_programs)
					progdat += "<td><a href='byond://?src=\ref[src];prog=\ref[P];function=unload'>Halt</a></td>"
				else
					progdat += "<td><a href='byond://?src=\ref[src];prog=\ref[P];function=load'>Load</a></td>"

				progdat += "<td><a href='byond://?src=\ref[src];file=\ref[P];function=delete'>Del</a></td></tr>"

				continue

			dat += "Disk Space: \[[hd.file_used]/[hd.file_amount]\]<br>"
			dat += "<b>Programs on Fixed Disk:</b><br>"

			if(!progdat)
				progdat = "No programs found.<br>"
			dat += "<center><table cellspacing=4>[progdat]</table></center>"

		else

			dat += "<b>Programs on Fixed Disk:</b><br>"
			dat += "<center>No fixed disk detected.</center><br>"

		dat += "<br>"

		progdat = null
		if((diskette) && (diskette.root))

			dat += "<font size=1><a href='byond://?src=\ref[src];disk=1'>Eject</a></font><br>"

			for(var/datum/computer/file/computer_program/P in diskette.root.contents)
				progdat += "<tr><td>[P.name]</td><td>Size: [P.size]</td>"
				progdat += "<td><a href='byond://?src=\ref[src];prog=\ref[P];function=run'>Run</a></td>"

				if(P in processing_programs)
					progdat += "<td><a href='byond://?src=\ref[src];prog=\ref[P];function=unload'>Halt</a></td>"
				else
					progdat += "<td><a href='byond://?src=\ref[src];prog=\ref[P];function=load'>Load</a></td>"

				progdat += "<td><a href='byond://?src=\ref[src];file=\ref[P];function=install'>Install</a></td></tr>"

				continue

			dat += "Disk Space: \[[diskette.file_used]/[diskette.file_amount]\]<br>"
			dat += "<b>Programs on Disk:</b><br>"

			if(!progdat)
				progdat = "No data found.<br>"
			dat += "<center><table cellspacing=4>[progdat]</table></center>"

		else

			dat += "<b>Programs on Disk:</b><br>"
			dat += "<center>No diskette loaded.</center><br>"

		dat += "</TT>"

	user << browse(dat,"window=comp2")
	onclose(user,"comp2")
	return

/obj/machinery/computer2/Topic(href, href_list)
	if(..())
		return

	if(!active_program)
		if((href_list["prog"]) && (href_list["function"]))
			var/datum/computer/file/computer_program/newprog = locate(href_list["prog"])
			if(newprog && istype(newprog))
				switch(href_list["function"])
					if("run")
						run_program(newprog)
					if("load")
						load_program(newprog)
					if("unload")
						unload_program(newprog)
		if((href_list["file"]) && (href_list["function"]))
			var/datum/computer/file/newfile = locate(href_list["file"])
			if(!newfile)
				return
			switch(href_list["function"])
				if("install")
					if((hd) && (hd.root) && (allowed(usr)))
						newfile.copy_file_to_folder(hd.root)

				if("delete")
					if(allowed(usr))
						delete_file(newfile)

	//If there is already one loaded eject, or if not and they have one insert it.
	if (href_list["id"])
		switch(href_list["id"])
			if("auth")
				if(!isnull(authid))
					authid.loc = get_turf(src)
					authid = null
				else
					var/obj/item/I = usr.equipped()
					if (istype(I, /obj/item/weapon/card/id))
						usr.drop_item()
						I.loc = src
						authid = I
			if("aux")
				if(!isnull(auxid))
					auxid.loc = get_turf(src)
					auxid = null
				else
					var/obj/item/I = usr.equipped()
					if (istype(I, /obj/item/weapon/card/id))
						usr.drop_item()
						I.loc = src
						auxid = I

	//Same but for a data disk
	else if (href_list["disk"])
		if(!isnull(diskette))
			diskette.loc = get_turf(src)
			diskette = null
/*		else
			var/obj/item/I = usr.equipped()
			if (istype(I, /obj/item/weapon/disk/data))
				usr.drop_item()
				I.loc = src
				diskette = I
*/
	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer2/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(250)

	for(var/datum/computer/file/computer_program/P in processing_programs)
		P.process()

	return

/obj/machinery/computer2/power_change()
	if(stat & BROKEN)
		icon_state = base_icon_state
		icon_state += "b"

	else if(powered())
		icon_state = base_icon_state
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			icon_state = base_icon_state
			icon_state += "0"
			stat |= NOPOWER


/obj/machinery/computer2/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if ((!diskette) && W:portable)
			user.machine = src
			user.drop_item()
			W.loc = src
			diskette = W
			to_chat(user, "You insert [W].")
			updateUsrDialog()
			return

	else if (istype(W, /obj/item/weapon/screwdriver))
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, src, 20))
			var/obj/computer2frame/A = new /obj/computer2frame( loc )
			A.created_icon_state = base_icon_state
			if (stat & BROKEN)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				new /obj/item/weapon/shard( loc )
				A.state = 3
				A.icon_state = "3"
			else
				to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				A.state = 4
				A.icon_state = "4"

			for (var/obj/item/weapon/peripheral/C in peripherals)
				C.loc = A
				A.peripherals.Add(C)

			if(diskette)
				diskette.loc = loc

			//TO-DO: move card reading to peripheral cards instead
			if(authid)
				authid.loc = loc

			if(auxid)
				auxid.loc = loc

			if(hd)
				hd.loc = A
				A.hd = hd

			A.mainboard = new /obj/item/weapon/motherboard(A)
			A.mainboard.created_name = name


			A.anchored = 1
			del(src)

	else
		attack_hand(user)
	return

/obj/machinery/computer2/proc/send_command(command, datum/signal/signal)
	for(var/obj/item/weapon/peripheral/P in peripherals)
		P.receive_command(src, command, signal)

	del(signal)

/obj/machinery/computer2/proc/receive_command(obj/source, command, datum/signal/signal)
	if(source in contents)

		for(var/datum/computer/file/computer_program/P in processing_programs)
			P.receive_command(src, command, signal)

		del(signal)

	return


/obj/machinery/computer2/proc/run_program(datum/computer/file/computer_program/program,datum/computer/file/computer_program/host)
	if(!program)
		return 0

//	unload_program(active_program)

	if(load_program(program))
		if(host && istype(host))
			host_program = host
		else
			host_program = null

		active_program = program
		return 1

	return 0

/obj/machinery/computer2/proc/load_program(datum/computer/file/computer_program/program)
	if((!program) || (!program.holder))
		return 0

	if(!(program.holder in src))
//		to_chat(world, "Not in src")
		program = new program.type
		program.transfer_holder(hd)

	if(program.master != src)
		program.master = src

	if(program in processing_programs)
		return 1
	else
		processing_programs.Add(program)
		return 1

	return 0

/obj/machinery/computer2/proc/unload_program(datum/computer/file/computer_program/program)
	if((!program) || (!hd))
		return 0

	if(program in processing_programs)
		processing_programs.Remove(program)
		return 1

	return 0

/obj/machinery/computer2/proc/delete_file(datum/computer/file/file)
//	to_chat(world, "Deleting [file]...")
	if((!file) || (!file.holder) || (file.holder.read_only))
//		to_chat(world, "Cannot delete :(")
		return 0

	if(file in processing_programs)
		processing_programs.Remove(file)

	if(active_program == file)
		active_program = null

//	file.holder.root.remove_file(file)

//	to_chat(world, "Now calling del on [file]...")
	del(file)
	return 1