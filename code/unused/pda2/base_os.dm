/datum/computer/file/pda_program/os
	proc
		receive_os_command(list/command_list)
			if((!holder) || (!master) || (!command_list) || !(command_list["command"]))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(!(holder in master.contents))
				if(master.active_program == src)
					master.active_program = null
				return 1

			return 0

//Main os program: Provides old pda interface and four programs including file browser, notes, messenger, and atmos scan
	main_os
		name = "ThinkOS 7"
		size = 8.0
		var/mode = 0
		//Note vars
		var/note = "Congratulations, your station has chosen the Thinktronic 5150 Personal Data Assistant!"
		var/note_mode = 0 //0 For note editor, 1 for note browser
		var/datum/computer/file/text/note_file = null //If set, save to this file.
		//Messenger vars
		var/list/detected_pdas = list()
		var/message_on = 1
		var/message_silent = 0 //To beep or not to beep, that is the question
		var/message_mode = 0 //0 for pda list, 1 for messages
		var/message_tone = "beep" //Custom ringtone
		var/message_note = null //Current messages in memory (Store as separate file only later??)
		//File browser vars
		var/datum/computer/folder/browse_folder = null
		var/datum/computer/file/clipboard = null //Current file to copy



		receive_os_command(list/command_list)
			if(..())
				return

//			to_chat(world, "[command_list["command"]]")
			return

		return_text()
			if(..())
				return

			var/dat = return_text_header()

			switch(mode)
				if(0)
					dat += "<h2>PERSONAL DATA ASSISTANT</h2>"
					dat += "Owner: [master.owner]<br><br>"

					dat += "<h4>General Functions</h4>"
					dat += "<ul>"
					dat += "<li><a href='byond://?src=\ref[src];mode=1'>Notekeeper</a></li>"
					dat += "<li><a href='byond://?src=\ref[src];mode=2'>Messenger</a></li>"
					dat += "<li><a href='byond://?src=\ref[src];mode=3'>File Browser</a></li>"
					dat += "</ul>"

					dat += "<h4>Utilities</h4>"
					dat += "<ul>"
					dat += "<li><a href='byond://?src=\ref[src];mode=4'>Atmospheric Scan</a></li>"
					dat += "<li>Scanner: [master.scan_program ? "<a href='byond://?src=\ref[src];scanner=1'>[master.scan_program.name]</a>" : "None loaded"]</li>"
					dat += "<li><a href='byond://?src=\ref[src];flight=1'>[master.fon ? "Disable" : "Enable"] Flashlight</a></li>"

					dat += "</ul>"

				if(1)
					//Note Program.  Can save/load note files.
					dat += "<h4>Notekeeper V2.5</h4>"

					if(!note_mode)
						dat += "<a href='byond://?src=\ref[src];input=note'>Edit</a>"
						dat += " | <a href='byond://?src=\ref[src];note_func=new'>New File</a>"
						dat += " | <a href='byond://?src=\ref[src];note_func=save'>Save</a>"
						dat += " | <a href='byond://?src=\ref[src];note_func=switchmenu'>Load</a><br>"

						dat += note
					else
						dat += " <a href='byond://?src=\ref[src];note_func=switchmenu'>Back</a>"
						dat += " | \[[holding_folder.holder.file_amount - holding_folder.holder.file_used]\] Free<br>"
						dat += "<table cellspacing=5>"

						for(var/datum/computer/file/text/T in holding_folder.contents)
							dat += "<tr><td><a href='byond://?src=\ref[src];target=\ref[T];note_func=load'>[T.name]</a></td>"
							dat += "<td>[T.extension]</td>"
							dat += "<td>Length: [T.data ? (length(T.data)) : "0"]</td></tr>"

						dat += "</table>"

				if(2)
					//Messenger.  Uses Radio.  Is a messenger.
					//TO-DO: ~file sharing~
					master.overlays.len = 0 //Remove existing alerts
					dat += "<h4>SpaceMessenger V4.0.5</h4>"

					if (!message_mode)

						dat += "<a href='byond://?src=\ref[src];message_func=ringer'>Ringer: [message_silent == 1 ? "Off" : "On"]</a> | "
						dat += "<a href='byond://?src=\ref[src];message_func=on'>Send / Receive: [message_on == 1 ? "On" : "Off"]</a> | "
						dat += "<a href='byond://?src=\ref[src];input=tone'>Set Ringtone</a> | "
						dat += "<a href='byond://?src=\ref[src];message_mode=1'>Messages</a><br>"

						dat += "<font size=2><a href='byond://?src=\ref[src];message_func=scan'>Scan</a></font><br>"
						dat += "<b>Detected PDAs</b><br>"

						dat += "<ul>"

						var/count = 0

						if (message_on)
							for (var/obj/item/device/pda2/P in detected_pdas)
								if (!P.owner)
									detected_pdas -= P
									continue
								else if (P == src) //I guess this can happen if somebody copies the system file.
									detected_pdas -= P
									continue

								dat += "<li><a href='byond://?src=\ref[src];input=message;target=\ref[P]'>[P]</a>"

								dat += "</li>"
								count++

						dat += "</ul>"

						if (count == 0)
							dat += "None detected.<br>"

					else
						dat += "<a href='byond://?src=\ref[src];message_func=clear'>Clear</a> | "
						dat += "<a href='byond://?src=\ref[src];message_mode=0'>Back</a><br>"

						dat += "<h4>Messages</h4>"

						dat += message_note
						dat += "<br>"

				if(3)
					//File Browser.
					//To-do(?): Setting "favorite" programs to access straight from main menu
					//Not sure how needed it is, not like they have to go through 500 subfolders or whatever
					if((!browse_folder) || !(browse_folder.holder in master))
						browse_folder = holding_folder

					dat += " | <a href='byond://?src=\ref[src];target=\ref[browse_folder];browse_func=paste'>Paste</a>"
					dat += " | Drive: "
					dat += "\[<a href='byond://?src=\ref[src];browse_func=drive'>[browse_folder.holder == master.hd ? "MAIN" : "CART"]</a>\]<br>"

					dat += "<b>Contents of [browse_folder] | Drive ID:\[[browse_folder.holder.title]]</b><br>"
					dat += "<b>Used: \[[browse_folder.holder.file_used]/[browse_folder.holder.file_amount]\]</b><hr>"

					dat += "<table cellspacing=5>"
					for(var/datum/computer/file/F in browse_folder.contents)
						if(F == src)
							dat += "<tr><td>System</td><td>Size: [size]</td><td>SYSTEM</td></tr>"
							continue
						dat += "<tr><td><a href='byond://?src=\ref[src];target=\ref[F];browse_func=open'>[F.name]</a></td>"
						dat +=  "<td>Size: [F.size]</td>"

						dat += "<td>[F.extension]</td>"

						dat += "<td><a href='byond://?src=\ref[src];target=\ref[F];browse_func=delete'>Del</a></td>"
						dat += "<td><a href='byond://?src=\ref[src];target=\ref[F];input=rename'>Rename</a></td>"

						dat += "<td><a href='byond://?src=\ref[src];target=\ref[F];browse_func=copy'>Copy</a></td>"

						dat += "</tr>"

					dat += "</table>"

				if(4)
					//Atmos Scanner
					dat += "<h4>Atmospheric Readings</h4>"

					var/turf/T = get_turf_or_move(get_turf(master))
					if (isnull(T))
						dat += "Unable to obtain a reading.<br>"
					else
						var/datum/gas_mixture/environment = T.return_air()

						var/pressure = environment.return_pressure()
						var/total_moles = environment.total_moles()

						dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

						if (total_moles())
							var/o2_level = environment.oxygen/total_moles()
							var/n2_level = environment.nitrogen/total_moles()
							var/co2_level = environment.carbon_dioxide/total_moles()
							var/plasma_level = environment.toxins/total_moles()
							var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

							dat += "Nitrogen: [round(n2_level*100)]%<br>"

							dat += "Oxygen: [round(o2_level*100)]%<br>"

							dat += "Carbon Dioxide: [round(co2_level*100)]%<br>"

							dat += "Plasma: [round(plasma_level*100)]%<br>"

							if(unknown_level > 0.01)
								dat += "OTHER: [round(unknown_level)]%<br>"

						dat += "Temperature: [round(environment.temperature-T0C)]&deg;C<br>"

					dat += "<br>"

			return dat

		Topic(href, href_list)
			if(..())
				return

			if(href_list["mode"])
				var/newmode = text2num(href_list["mode"])
				mode = max(newmode, 0)

			else if(href_list["flight"])
				master.toggle_light()

			else if(href_list["scanner"])
				if(master.scan_program)
					master.scan_program = null

			else if(href_list["input"])
				switch(href_list["input"])
					if("tone")
						var/t = input(usr, "Please enter new ringtone", name, message_tone) as text
						if (!t)
							return

						if (!master || !in_range(master, usr) && master.loc != usr)
							return

						if(!(holder in master))
							return

						t = copytext(sanitize(t), 1, 20)
						message_tone = t

					if("note")
						var/t = input(usr, "Please enter note", name, note) as message
						if (!t)
							return

						if (!master || !in_range(master, usr) && master.loc != usr)
							return

						if(!(holder in master))
							return

						t = copytext(adminscrub(t), 1, MAX_MESSAGE_LEN)
						note = t


					if("message")
						var/obj/item/device/pda2/P = locate(href_list["target"])
						if(!P || !istype(P))
							return

						var/t = input(usr, "Please enter message", P.name, null) as text
						if (!t)
							return

						if (!master || !in_range(master, usr) && master.loc != usr)
							return

						if(!(holder in master))
							return


						var/datum/signal/signal = new
						signal.data["command"] = "text message"
						signal.data["message"] = t
						signal.data["sender"] = master.owner
						signal.data["tag"] = "\ref[P]"
						post_signal(signal)
						message_note += "<i><b>&rarr; To [P.owner]:</b></i><br>[t]<br>"
						log_pda("[usr] sent [t] to [P.owner]")

					if("rename")
						var/datum/computer/file/F = locate(href_list["target"])
						if(!F || !istype(F))
							return

						var/t = input(usr, "Please enter new name", name, F.name) as text
						t = copytext(sanitize(t), 1, 16)
						if (!t)
							return
						if (!in_range(master, usr) || !(F.holder in master))
							return
						if(F.holder.read_only)
							return
						F.name = capitalize(lowertext(t))


			else if(href_list["message_func"]) //Messenger specific topic junk
				switch(href_list["message_func"])
					if("ringer")
						message_silent = !message_silent
					if("on")
						message_on = !message_on
					if("clear")
						message_note = null
					if("scan")
						if(message_on)
							detected_pdas = list()
							var/datum/signal/signal = new
							signal.data["command"] = "report pda"
							post_signal(signal)

			else if(href_list["note_func"]) //Note program specific topic junk
				switch(href_list["note_func"])
					if("new")
						note_file = null
						note = null
					if("save")
						if(note_file && note_file.holder in master)
							note_file.data = note
						else
							var/datum/computer/file/text/F = new /datum/computer/file/text
							if(!holding_folder.add_file(F))
								del(F)
							else
								note_file = F
								F.data = note

					if("load")
						var/datum/computer/file/text/T = locate(href_list["target"])
						if(!T || !istype(T))
							return

						note_file = T
						note = note_file.data
						note_mode = 0

					if("switchmenu")
						note_mode = !note_mode

			else if(href_list["browse_func"]) //File browser specific topic junk
				var/datum/computer/target = locate(href_list["target"])
				switch(href_list["browse_func"])
					if("drive")
						if(browse_folder.holder == master.hd && master.cartridge && (master.cartridge.root))
							browse_folder = master.cartridge.root
						else
							browse_folder = holding_folder
					if("open")
						if(!target || !istype(target))
							return
						if(istype(target, /datum/computer/file/pda_program))
							if(istype(target,/datum/computer/file/pda_program/os) && (master.host_program))
								return
							else
								master.run_program(target)
								master.updateSelfDialog()
								return

					if("delete")
						if(!target || !istype(target))
							return
						master.delete_file(target)

					if("copy")
						if(istype(target,/datum/computer/file) && (!target.holder || (target.holder in master.contents)))
							clipboard = target

					if("paste")
						if(istype(target,/datum/computer/folder))
							if(!clipboard || !clipboard.holder || !(clipboard.holder in master.contents))
								return

							if(!istype(clipboard))
								return

							clipboard.copy_file_to_folder(target)


			else if(href_list["message_mode"])
				var/newmode = text2num(href_list["message_mode"])
				message_mode = max(newmode, 0)

			master.add_fingerprint(usr)
			master.updateSelfDialog()
			return

		receive_signal(datum/signal/signal)
			if(..())
				return

			switch(signal.data["command"])
				if("text message")
					if(!message_on || !signal.data["message"])
						return
					var/sender = signal.data["sender"]
					if(!sender)
						sender = "!Unknown!"

					message_note += "<i><b>&larr; From <a href='byond://?src=\ref[src];input=message;target=\ref[signal.source]'>[sender]</a>:</b></i><br>[signal.data["message"]]<br>"
					var/alert_beep = null //Don't beep if set to silent.
					if(!message_silent)
						alert_beep = message_tone

					master.display_alert(alert_beep)
					master.updateSelfDialog()

				if("report pda")
					if(!message_on)
						return

					var/datum/signal/newsignal = new
					newsignal.data["command"] = "reporting pda"
					newsignal.data["tag"] = "\ref[signal.source]"
					post_signal(newsignal)

				if("reporting pda")
					if(!detected_pdas)
						detected_pdas = new()

					if(!(signal.source in detected_pdas))
						detected_pdas += signal.source

					master.updateSelfDialog()

			return

		return_text_header()
			if(!master)
				return

			var/dat

			if(mode)
				dat += " | <a href='byond://?src=\ref[src];mode=0'>Main Menu</a>"

			else if (!isnull(master.cartridge))
				dat += " | <a href='byond://?src=\ref[master];eject_cart=1'>Eject [master.cartridge]</a>"

			dat += " | <a href='byond://?src=\ref[master];refresh=1'>Refresh</a>"

			return dat