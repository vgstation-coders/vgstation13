//Eventual plan: Convert all datum/data to datum/computer/file
/datum/computer/file/text
	name = "text"
	extension = "TEXT"
	size = 2.0
	var/data = null

/datum/computer/file/record
	name = "record"
	extension = "REC"

	var/list/fields = list(  )


//base pda program

/datum/computer/file/pda_program
	name = "blank program"
	extension = "PPROG"
	var/obj/item/device/pda2/master = null
	var/id_tag = null

	os
		name = "blank system program"
		extension = "PSYS"

	scan
		name = "blank scan program"
		extension = "PSCAN"

	New(obj/holding as obj)
		if(holding)
			holder = holding

			if(istype(holder.loc,/obj/item/device/pda2))
				master = holder.loc

	proc
		return_text()
			if((!holder) || (!master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(!(holder in master.contents))
//				to_chat(world, "Holder [holder] not in [master] of prg:[src]")
				if(master.active_program == src)
					master.active_program = null
				return 1

			if(!holder.root)
				holder.root = new /datum/computer/folder
				holder.root.holder = src
				holder.root.name = "root"

			return 0

		process() //This isn't actually used at the moment
			if((!holder) || (!master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(!(holder in master.contents))
				if(master.active_program == src)
					master.active_program = null
				return 1

			if(!holder.root)
				holder.root = new /datum/computer/folder
				holder.root.holder = src
				holder.root.name = "root"

			return 0

		//maybe remove this, I haven't found a good use for it yet
		send_os_command(list/command_list)
			if(!master || !holder || master.host_program || !command_list)
				return 1

			if(!istype(master.host_program) || master.host_program == src)
				return 1

			master.host_program.receive_os_command()

			return 0

		return_text_header()
			if(!master || !holder)
				return

			var/dat = " | <a href='byond://?src=\ref[src];quit=1'>Main Menu</a>"
			dat += " | <a href='byond://?src=\ref[master];refresh=1'>Refresh</a>"

			return dat

		post_signal(datum/signal/signal, newfreq)
			if(master)
				master.post_signal(signal, newfreq)
			else
				del(signal)

		transfer_holder(obj/item/weapon/disk/data/newholder,datum/computer/folder/newfolder)

			if((newholder.file_used + size) > newholder.file_amount)
				return 0

			if(!newholder.root)
				newholder.root = new /datum/computer/folder
				newholder.root.holder = newholder
				newholder.root.name = "root"

			if(!newfolder)
				newfolder = newholder.root

			if((holder && holder.read_only) || newholder.read_only)
				return 0

			if((holder) && (holder.root))
				holder.root.remove_file(src)

			newfolder.add_file(src)

			if(istype(newholder.loc,/obj/item/device/pda2))
				master = newholder.loc

//			to_chat(world, "Setting [holder] to [newholder]")
			holder = newholder
			return 1


		receive_signal(datum/signal/signal)
			if((!holder) || (!master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(!(holder in master.contents))
				if(master.active_program == src)
					master.active_program = null
				return 1

			return 0


	Topic(href, href_list)
		if((!holder) || (!master))
			return 1

		if((!istype(holder)) || (!istype(master)))
			return 1

		if(master.active_program != src)
			return 1

		if ((!usr.contents.Find(master) && (!in_range(master, usr) || !istype(master.loc, /turf))) && (!istype(usr, /mob/living/silicon)))
			return 1

		if(!(holder in master.contents))
			if(master.active_program == src)
				master.active_program = null
			return 1

		usr.machine = master

		if (href_list["close"])
			usr.machine = null
			usr << browse(null, "window=pda2")
			return 0

		if (href_list["quit"])
//			master.processing_programs.Remove(src)
			if(master.host_program && master.host_program.holder && (master.host_program.holder in master.contents))
				master.run_program(master.host_program)
				master.updateSelfDialog()
				return 1
			else
				master.active_program = null
			master.updateSelfDialog()
			return 1

		return 0