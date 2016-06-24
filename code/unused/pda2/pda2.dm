//The advanced pea-green monochrome lcd of tomorrow.


//TO-DO: rearrange all this disk/data stuff so that fixed disks are the parent type
//because otherwise you have carts going into floppy drives and it's ALL MAD
/obj/item/weapon/disk/data/cartridge
	name = "Cart 2.0"
	desc = "A data cartridge for portable microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	file_amount = 80.0
	title = "ROM Cart"

	pda2test
		name = "Test Cart"
		New()
			..()
			root.add_file( new /datum/computer/file/computer_program/arcade(src))
			root.add_file( new /datum/computer/file/pda_program/manifest(src))
			root.add_file( new /datum/computer/file/pda_program/status_display(src))
			root.add_file( new /datum/computer/file/pda_program/signaler(src))
			root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			root.add_file( new /datum/computer/file/pda_program/records/security(src))
			root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			read_only = 1


/obj/item/device/pda2
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by an EEPROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	flags = FPRINT | TABLEPASS
	slow_flags = SLOT_BELT

	var/owner = null
	var/default_cartridge = null // Access level defined by cartridge
	var/obj/item/weapon/disk/data/cartridge/cartridge = null //current cartridge
	var/datum/computer/file/pda_program/active_program = null
	var/datum/computer/file/pda_program/os/host_program = null
	var/datum/computer/file/pda_program/scan/scan_program = null
	var/obj/item/weapon/disk/data/fixed_disk/hd = null
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 3 //Luminosity for the flashlight function
//	var/datum/data/record/active1 = null //General
//	var/datum/data/record/active2 = null //Medical
//	var/datum/data/record/active3 = null //Security
//	var/obj/item/weapon/integrated_uplink/uplink = null //Maybe replace uplink with some remote ~syndicate~ server
	var/frequency = 1149
	var/datum/radio_frequency/radio_connection

	var/setup_default_cartridge = null //Cartridge contains job-specific programs
	var/setup_drive_size = 24.0 //PDAs don't have much work room at all, really.
	var/setup_system_os_path = /datum/computer/file/pda_program/os/main_os //Needs an operating system to...operate!!


/obj/item/device/pda2/pickup(mob/user)
	if (fon)
		sd_SetLuminosity(0)
		user.sd_SetLuminosity(user.luminosity + f_lum)

/obj/item/device/pda2/dropped(mob/user)
	if (fon)
		user.sd_SetLuminosity(user.luminosity - f_lum)
		sd_SetLuminosity(f_lum)

/obj/item/device/pda2/New()
	..()
	spawn(5)
		hd = new /obj/item/weapon/disk/data/fixed_disk(src)
		hd.file_amount = setup_drive_size
		hd.name = "Minidrive"
		hd.title = "Minidrive"

		if(setup_system_os_path)
			host_program = new setup_system_os_path

			hd.file_amount = max(hd.file_amount, host_program.size)

			host_program.transfer_holder(hd)

		if(radio_controller)
			radio_controller.add_object(src, frequency)


	if (default_cartridge)
		cartridge = new setup_default_cartridge(src)
//	if(owner)
//		processing_items.Add(src)

/obj/item/device/pda2/attack_self(mob/user as mob)
	user.machine = src

	var/dat = "<html><head><title>Personal Data Assistant</title></head><body>"

	dat += "<a href='byond://?src=\ref[src];close=1'>Close</a>"

	if (!owner)
		if(cartridge)
			dat += " | <a href='byond://?src=\ref[src];eject_cart=1'>Eject [cartridge]</a>"
		dat += "<br>Warning: No owner information entered.  Please swipe card.<br><br>"
		dat += "<a href='byond://?src=\ref[src];refresh=1'>Retry</a>"
	else
		if(active_program)
			dat += active_program.return_text()
		else
			if(host_program)
				run_program(host_program)
				dat += active_program.return_text()
			else
				if(cartridge)
					dat += " | <a href='byond://?src=\ref[src];eject_cart=1'>Eject [cartridge]</a><br>"
				dat += "<center><font color=red>Fatal Error 0x17<br>"
				dat += "No System Software Loaded</font></center>"
					//To-do: System recovery shit (maybe have a dedicated computer for this kind of thing)


	user << browse(dat,"window=pda2")
	onclose(user,"pda2")
	return

/obj/item/device/pda2/Topic(href, href_list)
	..()

	if (usr.contents.Find(src) || usr.contents.Find(master) || (istype(loc, /turf) && get_dist(src, usr) <= 1))
		if (usr.stat || usr.restrained())
			return

		add_fingerprint(usr)
		usr.machine = src


		if(href_list["return_to_host"])
			if(host_program)
				active_program = host_program
				host_program = null

		else if (href_list["eject_cart"])
			eject_cartridge()

		else if (href_list["refresh"])
			updateSelfDialog()

		else if (href_list["close"])
			usr << browse(null, "window=pda2")
			usr.machine = null

		updateSelfDialog()
		return

/obj/item/device/pda2/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if (istype(C, /obj/item/weapon/disk/data/cartridge) && isnull(cartridge))
		user.drop_item()
		C.loc = src
		to_chat(user, "<span class='notice'>You insert [C] into [src].</span>")
		cartridge = C
		updateSelfDialog()

	else if (istype(C, /obj/item/weapon/card/id) && !owner && C:registered_name)
		owner = C:registered_name
		name = "PDA-[owner]"
		to_chat(user, "<span class='notice'>Card scanned.</span>")
		updateSelfDialog()

/obj/item/device/pda2/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption || !owner) return

	if(signal.data["tag"] && signal.data["tag"] != "\ref[src]") return

	if(host_program)
		host_program.receive_signal(signal)

	if(active_program && (active_program != host_program))
		host_program.receive_signal(signal)

	return

/obj/item/device/pda2/attack(mob/M as mob, mob/user as mob)
	if(scan_program)
		return
	else
		..()

/obj/item/device/pda2/afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
	var/scan_dat = null
	if(scan_program && istype(scan_program))
		scan_dat = scan_program.scan_atom(A)

	if(scan_dat)
		A.visible_message("<span class='warning'>[user] has scanned [A]!</span>")
		user.show_message(scan_dat, 1)

	return


/obj/item/device/pda2/proc

	post_signal(datum/signal/signal,var/newfreq)
		if(!signal)
			return
		var/freq = newfreq
		if(!freq)
			freq = frequency

		signal.source = src

		var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

		signal.transmission_method = TRANSMISSION_RADIO
		if(frequency)
			return frequency.post_signal(src, signal)
		else
			del(signal)

	eject_cartridge()
		if(cartridge)
			var/turf/T = get_turf(src)

			if(active_program && (active_program.holder == cartridge))
				active_program = null

			if(host_program && (host_program.holder == cartridge))
				host_program = null

			if(scan_program && (scan_program.holder == cartridge))
				scan_program = null

			cartridge.loc = T
			cartridge = null

		return

	//Toggle the built-in flashlight
	toggle_light()
		fon = (!fon)

		if (ismob(loc))
			if (fon)
				loc.sd_SetLuminosity(loc.luminosity + f_lum)
			else
				loc.sd_SetLuminosity(loc.luminosity - f_lum)
		else
			sd_SetLuminosity(fon * f_lum)

		updateSelfDialog()

	display_alert(var/alert_message) //Add alert overlay and beep
		if (alert_message)
			playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
			for (var/mob/O in hearers(3, loc))
				O.show_message(text("[bicon(src)] *[alert_message]*"))

		overlays.len = 0
		overlays += image('icons/obj/pda.dmi', "pda-r")
		return

	run_program(datum/computer/file/pda_program/program)
		if((!program) || (!program.holder))
			return 0

		if(!(program.holder in src))
//			to_chat(world, "Not in src")
			program = new program.type
			program.transfer_holder(hd)

		if(program.master != src)
			program.master = src

		if(!host_program && istype(program, /datum/computer/file/pda_program/os))
			host_program = program

		if(istype(program, /datum/computer/file/pda_program/scan))
			if(program == scan_program)
				scan_program = null
			else
				scan_program = program
			return 1

		active_program = program
		return 1

	delete_file(datum/computer/file/file)
//		to_chat(world, "Deleting [file]...")
		if((!file) || (!file.holder) || (file.holder.read_only))
//			to_chat(world, "Cannot delete :(")
			return 0

		//Don't delete the running program you jerk
		if(active_program == file || host_program == file)
			active_program = null

//		to_chat(world, "Now calling del on [file]...")
		del(file)
		return 1