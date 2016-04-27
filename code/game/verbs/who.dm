/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "\n<b>Current Players:</b>\n"

	var/list/Lines = list()

	//for admins
	var/living = 0
	var/ghosts = 0
	var/lobby = 0
	var/livingAntags = 0

	if (holder)
		for (var/client/C in clients)
			var/entry = "\t[C.key]"

			if (C.holder && C.holder.fakekey)
				entry += " <i>(as [C.holder.fakekey])</i>"

			if(C.mob.real_name)
				entry += " - Playing as [C.mob.real_name]"

			switch (C.mob.stat)
				if (UNCONSCIOUS)
					entry += " - <font color='darkgray'><b>Unconscious</b></font>"

				if (DEAD)
					if (isobserver(C.mob))
						ghosts++
						var/mob/dead/observer/O = C.mob

						if (O.started_as_observer)
							entry += " - <font color='gray'>Observing</font>"
						else
							entry += " - <font color='black'><b>DEAD</b></font>"
					else if (isnewplayer(C.mob))
						entry += " - <font color='gray'><i>Lobby</i></font>"
						lobby++
					else
						entry += " - <font color='black'><b>DEAD</b></font>"
						ghosts++
				else
					living++

			if (is_special_character(C.mob))
				entry += " - <b><span class='red'>Antagonist</span></b>"
				if(!(C.mob.isDead()))
					livingAntags++

			entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
			Lines += entry

		log_admin("[key_name(usr)] used who verb advanced (shows OOC key - IC name, status and if antagonist)")
	else
		for (var/client/C in clients)
			if (C.holder && C.holder.fakekey)
				Lines += C.holder.fakekey
			else
				Lines += C.key

	for (var/line in sortList(Lines))
		msg += "[line]\n"
	if(holder)
		msg += "<b>Living: [living] | Dead/Ghosts: [ghosts] | in Lobby: [lobby] | Living Antags: <span class='red'>[livingAntags]</span> | </b>\n"
	msg += "<b>Total Players: [length(Lines)]</b>\n"
	to_chat(src, msg)

/client/verb/adminwho()
	set category = "Admin"
	set name = "Adminwho"

	var/aNames = ""
	var/mNames = ""
	var/numAdminsOnline = 0
	var/numModsOnline = 0

	if (holder)
		for (var/client/C in admins)
			if (R_ADMIN & C.holder.rights || !(R_MOD & C.holder.rights))
				aNames += "\t[C] is a [C.holder.rank]"

				if (C.holder.fakekey)
					aNames += " <i>(as [C.holder.fakekey])</i>"

				if (isobserver(C.mob))
					aNames += " - Observing"
				else if (istype(C.mob,/mob/new_player))
					aNames += " - Lobby"
				else
					aNames += " - Playing"

				if (C.is_afk())
					aNames += " (AFK)"

				aNames += "\n"
				numAdminsOnline++
			else
				mNames += "\t[C] is a [C.holder.rank]"

				if (C.holder.fakekey)
					mNames += " <i>(as [C.holder.fakekey])</i>"

				if (isobserver(C.mob))
					mNames += " - Observing"
				else if (istype(C.mob,/mob/new_player))
					mNames += " - Lobby"
				else
					mNames += " - Playing"

				if (C.is_afk())
					mNames += " (AFK)"

				mNames += "\n"
				numModsOnline++
	else
		for (var/client/C in admins)
			if (R_ADMIN & C.holder.rights || !(R_MOD & C.holder.rights))
				if (!C.holder.fakekey)
					aNames += "\t[C] is a [C.holder.rank]\n"
					numAdminsOnline++
			else
				if (!C.holder.fakekey)
					mNames += "\t[C] is a [C.holder.rank]\n"
					numModsOnline++

	to_chat(src, "\n<b>Current Admins ([numAdminsOnline]):</b>\n" + aNames + "\n<b>Current Moderators ([numModsOnline]):</b>\n" + mNames + "\n")
