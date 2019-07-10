#define INSTRUMENT_MAX_LINE_NUMBER	300
#define INSTRUMENT_MAX_LINE_LENGTH	50

/datum/song
	var/name = "Untitled"
	var/list/lines = new()
	var/tempo = 5			// delay between notes

	var/playing = 0			// if we're playing
	var/repeat = 0			// number of times remaining to repeat
	var/max_repeats = 10	// maximum times we can repeat

	var/instrumentDir = "piano"		// the folder with the sounds
	var/instrumentExt = "ogg"		// the file extension
	var/obj/instrumentObj = null	// the associated obj playing the sound

/datum/song/New(dir, obj)
	tempo = sanitize_tempo(tempo)
	instrumentDir = dir
	instrumentObj = obj

/datum/song/Destroy()
	instrumentObj = null
	..()

// note is a number from 1-7 for A-G
// acc is either "b", "n", or "#"
// oct is 1-8 (or 9 for C)
/datum/song/proc/playnote(note, acc as text, oct, mob/user)
	// handle accidental -> B<>C of E<>F
	if(acc == "b" && (note == 3 || note == 6)) // C or F
		if(note == 3)
			oct--
		note--
		acc = "n"
	else if(acc == "#" && (note == 2 || note == 5)) // B or E
		if(note == 2)
			oct++
		note++
		acc = "n"
	else if(acc == "#" && (note == 7)) //G#
		note = 1
		acc = "b"
	else if(acc == "#") // mass convert all sharps to flats, octave jump already handled
		acc = "b"
		note++

	// check octave, C is allowed to go to 9
	if(oct < 1 || (note == 3 ? oct > 9 : oct > 8))
		return

	// now generate name
	var/soundfile = "sound/instruments/[instrumentDir]/[ascii2text(note+64)][acc][oct].[instrumentExt]"
	soundfile = file(soundfile)
	// make sure the note exists
	if(!fexists(soundfile))
		return
	// and play
	var/turf/source = get_turf(instrumentObj)
	for(var/mob/M in get_hearers_in_view(15, source))
		if(!M.client)
			continue
		if(M.client.prefs.hear_instruments)
			M.playsound_local(source, soundfile, 100, falloff = 5)
		if(istype(instrumentObj,/obj/item/device/instrument))
			var/obj/item/device/instrument/INS = instrumentObj
			INS.OnPlayed(user,M)

/datum/song/proc/shouldStopPlaying(mob/user)
	if(instrumentObj)
		if(!instrumentObj.Adjacent(user) || user.stat)
			return 1
		else if(istype(instrumentObj,/obj/structure/piano))
			var/obj/structure/piano/P = instrumentObj
			if(P.broken)
				return 1
		return !instrumentObj.anchored		// add special cases to stop in subclasses
	else
		return 1

/datum/song/proc/playsong(mob/user)
	while(repeat >= 0)
		var/cur_oct[7]
		var/cur_acc[7]
		for(var/i = 1 to 7)
			cur_oct[i] = 3
			cur_acc[i] = "n"

		var/lineCount = 1;
		for(var/line in lines)
			//world << line
			var/chordCount = 1;
			for(var/beat in splittext(lowertext(line), ","))
				//world << "beat: [beat]"
				var/list/notes = splittext(beat, "/")
				for(var/note in splittext(notes[1], "-"))
					//world << "note: [note]"
					if(!playing || shouldStopPlaying(user))//If the instrument is playing, or special case
						playing = 0
						return
					if(lentext(note) == 0)
						continue
					//world << "Parse: [copytext(note,1,2)]"
					var/cur_note = text2ascii(note) - 96
					if(cur_note < 1 || cur_note > 7)
						continue
					for(var/i=2 to lentext(note))
						var/ni = copytext(note,i,i+1)
						if(!text2num(ni))
							if(ni == "#" || ni == "b" || ni == "n")
								cur_acc[cur_note] = ni
							else if(ni == "s")
								cur_acc[cur_note] = "#" // so shift is never required
						else
							cur_oct[cur_note] = text2num(ni)
					playnote(cur_note, cur_acc[cur_note], cur_oct[cur_note],user)		
				var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "instrument")
				if (ui)
					ui.send_message("activeChord", list2params(list(lineCount, chordCount)))
				//nanomanager.send_message(src, instrumentObj.name, "activeChord", list(lineCount, chordCount))
				if(notes.len >= 2 && text2num(notes[2]))
					sleep(sanitize_tempo(tempo / text2num(notes[2])))
				else
					sleep(tempo)
				chordCount++
				
			lineCount++
		repeat--
	playing = 0
	repeat = 0
	interact(user)

//convert this to nanoui
/datum/song/proc/interact(mob/user)
	var/data = list(
		"repeat" = repeat,
		"ticklag" = world.tick_lag,
		"bpm" = round(600 / tempo),
		"lines" = json_encode(lines),
		"src" = "\ref[src]" //needed to create buttons in the js
	)

	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "instrument")
	if (!ui)
		ui = new(user, src, "instrument", "instrument.tmpl", instrumentObj.name, 800, 600, nstatus_proc = /proc/nanoui_instrument_status_proc)
		ui.add_stylesheet("instrument.css")
		ui.set_initial_data(data)
		ui.open()
	else
		ui.push_data(data)

//copypaste but the src_object is the instrument
//constants dont work for some reason
/proc/nanoui_instrument_status_proc(var/datum/nanoui/nano)
	var/datum/song/src_song = nano.src_object
	if(!istype(src_song))
		return 0
	var/obj/instrumentObj = src_song.instrumentObj
	if(!istype(instrumentObj))
		return 0
	var/can_interactive = 0
	if(nano.user.mutations && nano.user.mutations.len)
		if(M_TK in nano.user.mutations)
			can_interactive = 1
	else if(isrobot(nano.user))
		if(instrumentObj in view(7, nano.user))
			can_interactive = 1
	else
		can_interactive = (isAI(nano.user) || !nano.distance_check || isAdminGhost(nano.user))

	if (can_interactive)
		return 2 // interactive (green visibility)
	else
		var/dist = 0
		if(istype(instrumentObj, /atom))
			var/atom/A = instrumentObj
			if(isobserver(nano.user))
				var/mob/dead/observer/O = nano.user
				var/ghost_flags = 0
				if(A.ghost_write)
					ghost_flags |= PERMIT_ALL
				if(canGhostWrite(O,A,"",ghost_flags) || isAdminGhost(O))
					return 2 // interactive (green visibility)
				else if(canGhostRead(O,A,ghost_flags))
					return 1 // update only (orange visibility)
			dist = get_dist(instrumentObj, nano.user)

		if (dist > 4)
			return -1

		if ((nano.allowed_user_stat > -1) && (nano.user.stat > nano.allowed_user_stat))
			return 0 // no updates, completely disabled (red visibility)
		else if (nano.user.restrained() || nano.user.lying)
			return 1 // update only (orange visibility)
		else if (istype(instrumentObj, /obj/item/device/uplink/hidden)) // You know what if they have the uplink open let them use the UI
			return 2 // Will build in distance checks on the topics for sanity.
		else if (!(instrumentObj in view(4, nano.user))) // If the src object is not in visable, set status to 0
			return 0 // no updates, completely disabled (red visibility)
		else if (dist <= 1)
			return 2 // interactive (green visibility)
		else if (dist <= 2)
			return 1 // update only (orange visibility)
		else if (dist <= 4)
			return 0 // no updates, completely disabled (red visibility)

/datum/song/Topic(href, href_list)
	if(!instrumentObj.Adjacent(usr) || usr.stat || href_list["close"])
		var/datum/nanoui/ui = nanomanager.get_open_ui(usr, src, "instrument")
		if (ui)
			ui.close()
		return
	//nanomanager.send_message(src, "instrument", "messageReceived", null, usr)
	instrumentObj.add_fingerprint(usr)
	if(href_list["newsong"])
		lines = new()
		tempo = sanitize_tempo(5) // default 120 BPM
		name = ""
	else if(href_list["import"])
		var/t = ""
		do
			t = html_encode(input(usr, "Please paste the entire song, formatted:", text("[]", name), t)  as message)
			if(!in_range(instrumentObj, usr))
				return
			if(lentext(t) >= INSTRUMENT_MAX_LINE_LENGTH*INSTRUMENT_MAX_LINE_NUMBER)
				var/cont = input(usr, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
				if(cont == "no")
					break
		while(lentext(t) > INSTRUMENT_MAX_LINE_LENGTH*INSTRUMENT_MAX_LINE_NUMBER)
		//split into lines
		spawn()
			lines = splittext(t, "\n")
			if(copytext(lines[1],1,6) == "BPM: ")
				tempo = sanitize_tempo(600 / text2num(copytext(lines[1],6)))
				lines.Cut(1,2)
			else
				tempo = sanitize_tempo(5) // default 120 BPM
			if(lines.len > INSTRUMENT_MAX_LINE_NUMBER)
				alert(usr, "Too many lines! Cutting down...")
				lines.Cut(INSTRUMENT_MAX_LINE_NUMBER+1)
			var/linenum = 1
			for(var/l in lines)
				if(lentext(l) > INSTRUMENT_MAX_LINE_LENGTH)
					alert(usr, "Line [linenum] too long! Removing...")
					lines.Remove(l)
				else
					linenum++
			interact(usr)		// make sure updates when complete
	if(href_list["repeat"]) //Changing this from a toggle to a number of repeats to avoid infinite loops.
		if(playing)
			return //So that people cant keep adding to repeat. If the do it intentionally, it could result in the server crashing.
		repeat += round(text2num(href_list["repeat"]))
		if(repeat < 0)
			repeat = 0
		if(repeat > max_repeats)
			repeat = max_repeats
	else if(href_list["tempo"])
		tempo = sanitize_tempo(tempo + text2num(href_list["tempo"]))
	else if(href_list["play"])
		playing = 1
		spawn()
			playsong(usr)
		return //no need to reload the window
	else if(href_list["newline"])
		var/newline = html_encode(input("Enter your line: ", instrumentObj.name) as text|null)
		if(!newline || !in_range(instrumentObj, usr))
			return
		if(lines.len > INSTRUMENT_MAX_LINE_NUMBER)
			return
		if(lentext(newline) > INSTRUMENT_MAX_LINE_LENGTH)
			newline = copytext(newline, 1, INSTRUMENT_MAX_LINE_LENGTH)
		lines.Add(newline)
	else if(href_list["deleteline"])
		if(alert(usr, "Are you sure you want to delete Line [href_list["deleteline"]]?",  "Delete Line" , "Yes" , "No") != "Yes")
			return
		var/num = round(text2num(href_list["deleteline"]))
		if(num > lines.len || num < 1)
			return
		lines.Cut(num, num+1)
	else if(href_list["modifyline"])
		var/num = round(text2num(href_list["modifyline"]),1)
		var/content = html_encode(input("Enter your line: ", instrumentObj.name, lines[num]) as text|null)
		if(!content || !in_range(instrumentObj, usr))
			return
		if(lentext(content) > INSTRUMENT_MAX_LINE_LENGTH)
			content = copytext(content, 1, INSTRUMENT_MAX_LINE_LENGTH)
		if(num > lines.len || num < 1)
			return
		lines[num] = content
	else if(href_list["stop"])
		playing = 0
	else if(href_list["moveline"] && href_list["dir"])
		var/index = href_list["moveline"]
		if(!isnum(index))
			index = text2num(index)
			if(!isnum(index))
				message_admins("index [index] isn't a number")
				return
		var/dir = href_list["dir"]
		if(!isnum(dir))
			dir = text2num(dir)
			if(!isnum(dir))
				message_admins("dir [dir] isn't a number")
				return

		if(index > lines.len)
			return

		lines.Swap(index, index+dir)
	interact(usr)
	
	return
/datum/song/proc/sanitize_tempo(new_tempo)
	new_tempo = abs(new_tempo)
	return max(round(new_tempo, world.tick_lag), world.tick_lag)
// subclass for handheld instruments, like violin
/datum/song/handheld
/datum/song/handheld/shouldStopPlaying()
	if(instrumentObj)
		return !isliving(instrumentObj.loc)
	else
		return 1
//////////////////////////////////////////////////////////////////////////
/obj/structure/piano
	name = "space piano"
	desc = "This is a space piano; just like a regular piano, but always in tune! Even if the musician isn't."
	icon = 'icons/obj/musician.dmi'
	icon_state = "piano"
	anchored = 1
	density = 1
	var/broken = 0
	var/datum/song/song

/obj/structure/piano/minimoog
	name = "space minimoog"
	icon_state = "minimoog"
	desc = "This is a minimoog; just like a space piano, but more spacey!"

/obj/structure/piano/New()
	..()
	song = new("piano", src)

/obj/structure/piano/random/New()
	..()
	if(prob(50))
		name = "space minimoog"
		desc = "This is a minimoog; just like a space piano, but more spacey!"
		icon_state = "minimoog"

/obj/structure/piano/Destroy()
	qdel(song)
	song = null
	..()

/obj/structure/piano/initialize()
	song.tempo = song.sanitize_tempo(song.tempo) // tick_lag isn't set when the map is loaded
	..()

/obj/structure/piano/attack_hand(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1
	if(broken)
		to_chat(user, "<span class='warning'>\The [src] is broken for good.</span>")
		return 1
	interact(user)

/obj/structure/piano/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/piano/interact(mob/user)
	if(!user || !anchored)
		return

	user.set_machine(src)
	song.interact(user)

/obj/structure/piano/attackby(obj/item/O, mob/user, params)
	if (istype(O, /obj/item/weapon/wrench))
		if (!anchored && !istype(get_turf(src),/turf/space))
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user << "<span class='notice'> You begin to tighten \the [src] to the floor...</span>"
			if (do_after(user, 20, target = src))
				user.visible_message( \
					"[user] tightens \the [src]'s casters.", \
					"<span class='notice'>You tighten \the [src]'s casters. Now it can be played again.</span>", \
					"<span class='italics'>You hear a ratchet.</span>")
				anchored = 1
		else if(anchored)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user << "<span class='notice'> You begin to loosen \the [src]'s casters...</span>"
			if (do_after(user, 40, target = src))
				user.visible_message( \
					"[user] loosens \the [src]'s casters.", \
					"<span class='notice'>You loosen \the [src]. Now it can be pulled somewhere else.</span>", \
					"<span class='italics'>You hear a ratchet.</span>")
				anchored = 0
	else
		..()

/obj/structure/piano/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(broken)
				qdel(src)
			else
				broken = 1
				icon_state += "-broken"
		if(3.0)
			if(!broken && prob(33))
				broken = 1
				icon_state += "-broken"

/obj/structure/piano/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.destroy)
		src.ex_act(2)
	else if(!istype(Proj ,/obj/item/projectile/beam/lasertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
		if(prob(Proj.damage))
			src.ex_act(2)

/obj/structure/piano/xylophone
	name = "xylophone"
	desc = "Is this even a real instrument?"
	icon_state = "xylophone"

/obj/structure/piano/xylophone/New()
	..()
	song = new("xylophone", src)
	song.instrumentExt = "mid"
