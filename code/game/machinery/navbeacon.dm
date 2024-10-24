// Navigation beacon for AI robots
// Functions as a transponder: looks for incoming signal matching

var/list/navbeacons = list()

/obj/machinery/navbeacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "navbeacon0-f"
	name = "navigation beacon"
	desc = "A radio beacon used for bot navigation."
	level = 1		// underfloor
	plane = ABOVE_TURF_PLANE
	layer = ABOVE_TILE_LAYER
	anchored = 1

	var/locked = 1		// true if controls are locked
	var/freq = 1445		// radio frequency
	var/location = ""	// location response text
	var/list/codes		// assoc. list of transponder codes
	var/codes_txt = ""	// codes as set on map: "tag1;tag2" or "tag1=value;tag2=value"

	req_access = list(access_engine_minor)

	machine_flags = SCREWTOGGLE

/obj/machinery/navbeacon/New()
	..()

	set_codes()

	var/turf/T = loc
	hide(T.intact)

	navbeacons.Add(src)
	if(ticker && ticker.current_state == GAME_STATE_PLAYING)
		initialize()

/obj/machinery/navbeacon/initialize()
	if(radio_controller)
		radio_controller.add_object(src, freq, RADIO_NAVBEACONS)

/obj/machinery/navbeacon/Destroy()
	navbeacons.Remove(src)

	..()

	// set the transponder codes assoc list from codes_txt
/obj/machinery/navbeacon/proc/set_codes()
	if(!codes_txt)
		return

	codes = new()

	var/list/entries = splittext(codes_txt, ";")	// entries are separated by semicolons

	for(var/e in entries)
		var/index = findtext(e, "=")		// format is "key=value"
		if(index)
			var/key = copytext(e, 1, index)
			var/val = copytext(e, index+1)
			codes[key] = val
		else
			codes[e] = "1"


	// called when turf state changes
	// hide the object if turf is intact
/obj/machinery/navbeacon/hide(var/intact)
	invisibility = intact ? 101 : 0
	updateicon()

	// update the icon_state
/obj/machinery/navbeacon/proc/updateicon()
	var/state="navbeacon[panel_open]"

	if(invisibility)
		icon_state = "[state]-f"	// if invisible, set icon to faded version
									// in case revealed by T-scanner
	else
		icon_state = "[state]"


	// look for a signal of the form "findbeacon=X"
	// where X is any
	// or the location
	// or one of the set transponder keys
	// if found, return a signal
/obj/machinery/navbeacon/receive_signal(datum/signal/signal)
	var/request = signal.data["findbeacon"]
	var/bot = null
	if(signal.data["bot"])
		bot = signal.data["bot"]
	if(request && ((request in codes) || request == "any" || request == location))
		spawn(1)
			astar_debug_mulebots("navbeacons accepted request [request] from [bot] and posted its own location")
			post_signal(request, bot)

	// return a signal giving location and transponder codes

/obj/machinery/navbeacon/proc/post_signal(request, var/mulebot = null)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)
	if(!frequency)
		return

	var/datum/signal/signal = new /datum/signal
	signal.source = src
	signal.transmission_method = 1
	signal.data["beacon"] = location

	if (request == "patrol")
		signal.data["patrol"] = 1

	for(var/key in codes)
		signal.data[key] = codes[key]
		astar_debug_mulebots("Key: [key] - [codes[key]]")

	if(mulebot)
		astar_debug_mulebots("Bot: [mulebot]")
		signal.data["bot"] = mulebot

	astar_debug_mulebots("navbeacon [location] posted signal with request [request] for [mulebot] on freq [freq].")

	frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)

/obj/machinery/navbeacon/attackby(var/obj/item/I, var/mob/user)
	var/turf/T = loc
	if(T.intact)
		return		// prevent intraction when T-scanner revealed

	if(..())
		return

	else if (istype(I, /obj/item/weapon/card/id)||istype(I, /obj/item/device/pda))
		if(panel_open)
			if (src.allowed(user))
				src.locked = !src.locked
				to_chat(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
			updateDialog()
		else
			to_chat(user, "You must open the cover first!")

/obj/machinery/navbeacon/attack_ai(var/mob/user)
	add_hiddenprint(user)
	interact(user, 1)

/obj/machinery/navbeacon/attack_paw()
	return

/obj/machinery/navbeacon/attack_hand(var/mob/user)
	interact(user, 0)

/obj/machinery/navbeacon/interact(var/mob/user, var/ai = 0)
	var/turf/T = loc
	if(T.intact)
		return		// prevent intraction when T-scanner revealed

	if(!panel_open && !ai)	// can't alter controls if not open, unless you're an AI
		to_chat(user, "The beacon's control cover is closed.")
		return


	var/t

	if(locked && !ai)
		t = {"<TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to unlock controls)</i><BR>
Frequency: [format_frequency(freq)]<BR><HR>
Location: [location ? location : "(none)"]</A><BR>
Transponder Codes:<UL>"}

		for(var/key in codes)
			t += "<LI>[key] ... [codes[key]]"
		t+= "<UL></TT>"

	else

		t = {"<TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to lock controls)</i><BR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A>
[format_frequency(freq)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
<HR>
Location: <A href='byond://?src=\ref[src];locedit=1'>[location ? location : "(none)"]</A><BR>
Transponder Codes:<UL>"}

		for(var/key in codes)

			t += {"<LI>[key] ... [codes[key]]
				<small><A href='byond://?src=\ref[src];edit=1;code=[key]'>(edit)</A>
				<A href='byond://?src=\ref[src];delete=1;code=[key]'>(delete)</A></small><BR>"}
			t += "<LI>[key] ... [codes[key]]"

		t += {"<small><A href='byond://?src=\ref[src];add=1;'>(add new)</A></small><BR>
			<UL></TT>"}
	user << browse(t, "window=navbeacon")
	onclose(user, "navbeacon")

/obj/machinery/navbeacon/Topic(href, href_list)
	if(..())
		return 1
	else
		if(panel_open && !locked)
			usr.set_machine(src)

			if (href_list["freq"])
				freq = sanitize_frequency(freq + text2num(href_list["freq"]))
				updateDialog()

			else if(href_list["locedit"])
				var/newloc = copytext(sanitize(input("Enter New Location", "Navigation Beacon", location) as text|null),1,MAX_MESSAGE_LEN)
				if(newloc)
					location = newloc
					updateDialog()

			else if(href_list["edit"])
				var/codekey = href_list["code"]

				var/newkey = copytext(sanitize(input("Enter Transponder Code Key", "Navigation Beacon", codekey) as text|null),1,MAX_NAME_LEN)
				if(!newkey)
					return

				var/codeval = codes[codekey]
				var/newval = copytext(sanitize(input("Enter Transponder Code Value", "Navigation Beacon", codeval) as text|null),1,MAX_NAME_LEN)
				if(!newval)
					newval = codekey
					return

				codes.Remove(codekey)
				codes[newkey] = newval

				updateDialog()

			else if(href_list["delete"])
				var/codekey = href_list["code"]
				codes.Remove(codekey)
				updateDialog()

			else if(href_list["add"])

				var/newkey = copytext(sanitize(input("Enter New Transponder Code Key", "Navigation Beacon") as text|null),1,MAX_NAME_LEN)
				if(!newkey)
					return

				var/newval = copytext(sanitize(input("Enter New Transponder Code Value", "Navigation Beacon") as text|null),1,MAX_NAME_LEN)
				if(!newval)
					newval = "1"
					return

				if(!codes)
					codes = new()

				codes[newkey] = newval

				updateDialog()
