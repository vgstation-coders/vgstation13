/datum/computer
	var/size = 4.0
	var/obj/item/weapon/disk/data/holder = null
	var/datum/computer/folder/holding_folder = null
	folder
		name = "Folder"
		size = 0.0
		var/gen = 0
		Del()
			for(var/datum/computer/F in contents)
				del(F)
			..()
		proc
			add_file(datum/computer/R)
				if(!holder || holder.read_only || !R)
					return 0
				if(istype(R,/datum/computer/folder) && (gen>=10))
					return 0
				if((holder.file_used + R.size) <= holder.file_amount)
					contents.Add(R)
					R.holder = holder
					R.holding_folder = src
					holder.file_used -= size
					size += R.size
					holder.file_used += size
					if(istype(R,/datum/computer/folder))
						R:gen = (gen+1)
					return 1
				return 0

			remove_file(datum/computer/R)
				if(holder && !holder.read_only || !R)
//					to_chat(world, "Removing file [R]. File_used: [holder.file_used]")
					contents.Remove(R)
					holder.file_used -= size
					size -= R.size
					holder.file_used += size
					holder.file_used = max(holder.file_used, 0)
//					to_chat(world, "Removed file [R]. File_used: [holder.file_used]")
					return 1
				return 0
	file
		name = "File"
		var/extension = "FILE" //Differentiate between types of files, why not
		proc
			copy_file_to_folder(datum/computer/folder/newfolder)
				if(!newfolder || (!istype(newfolder)) || (!newfolder.holder) || (newfolder.holder.read_only))
					return 0

				if((newfolder.holder.file_used + size) <= newfolder.holder.file_amount)
					var/datum/computer/file/newfile = new type

					for(var/V in vars)
						if (issaved(vars[V]) && V != "holder")
							newfile.vars[V] = vars[V]

					if(!newfolder.add_file(newfile))
						del(newfile)

					return 1

				return 0


	Del()
		if(holder && holding_folder)
			holding_folder.remove_file(src)
		..()


/datum/computer/file/computer_program
	name = "blank program"
	extension = "PROG"
	//var/size = 4.0
	//var/obj/item/weapon/disk/data/holder = null
	var/obj/machinery/computer2/master = null
	var/active_icon = null
	var/id_tag = null
	var/list/req_access = list()

	New(obj/holding as obj)
		if(holding)
			holder = holding

			if(istype(holder.loc,/obj/machinery/computer2))
				master = holder.loc

	Del()
		if(master)
			master.processing_programs.Remove(src)
		..()

	proc
		return_text()
			if((!holder) || (!master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(master.stat & (NOPOWER|BROKEN))
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

		process()
			if((!holder) || (!master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(!(holder in master.contents))
				if(master.active_program == src)
					master.active_program = null
				master.processing_programs.Remove(src)
				return 1

			if(!holder.root)
				holder.root = new /datum/computer/folder
				holder.root.holder = src
				holder.root.name = "root"

			return 0

		receive_command(obj/source, command, datum/signal/signal)
			if((!holder) || (!master) || (!source) || (source != master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(master.stat & (NOPOWER|BROKEN))
				return 1

			if(!(holder in master.contents))
				if(master.active_program == src)
					master.active_program = null
				return 1

			return 0

		peripheral_command(command, datum/signal/signal)
			if(master)
				master.send_command(command, signal)
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

			if(istype(newholder.loc,/obj/machinery/computer2))
				master = newholder.loc

//			to_chat(world, "Setting [holder] to [newholder]")
			holder = newholder
			return 1

		//Check access per program.
		allowed(mob/M)
			//check if it doesn't require any access at all
			if(check_access(null))
				return 1
			if(istype(M, /mob/living/silicon))
				//AI can do whatever he wants
				return 1
			else if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				//if they are holding or wearing a card that has access, that works
				if(check_access(H.equipped()) || check_access(H.wear_id))
					return 1
			else if(istype(M, /mob/living/carbon/monkey))
				var/mob/living/carbon/monkey/george = M
				//they can only hold things :(
				if(george.equipped() && istype(george.equipped(), /obj/item/weapon/card/id) && check_access(george.equipped()))
					return 1
			return 0

		check_access(obj/item/weapon/card/id/I)
			if(!req_access) //no requirements
				return 1
			if(!istype(req_access, /list)) //something's very wrong
				return 1

			var/list/L = req_access
			if(!L.len) //no requirements
				return 1
			if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
				return 0
			for(var/req in req_access)
				if(!(req in I.access)) //doesn't have this access
					return 0
			return 1

	Topic(href, href_list)
		if((!holder) || (!master))
			return 1

		if((!istype(holder)) || (!istype(master)))
			return 1

		if(master.stat & (NOPOWER|BROKEN))
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
			usr << browse(null, "window=comp2")
			return 0

		if (href_list["quit"])
//			master.processing_programs.Remove(src)
			if(master.host_program && master.host_program.holder && (master.host_program.holder in master.contents))
				master.run_program(master.host_program)
				master.updateUsrDialog()
				return 1
			else
				master.active_program = null
			master.updateUsrDialog()
			return 1

		return 0