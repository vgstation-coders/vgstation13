/obj/item/device/radio
	icon = 'icons/obj/radio.dmi'
	name = "station bounced radio"
	suffix = "\[3\]"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"
	autoignition_temperature = AUTOIGNITION_PLASTIC
	var/on = 1 // 0 for off
	var/last_transmission
	var/frequency = 1459
	var/canhear_range = 3 // the range which mobs can hear this radio from
	var/obj/item/device/radio/patch_link = null
	var/datum/wires/radio/wires = null
	var/list/secure_radio_connections
	var/prison_radio = 0
	var/b_stat = 0
	var/broadcasting = 0
	var/listening = 1
	var/freerange = 0 // 0 - Sanitize frequencies, 1 - Full range
	var/list/channels = list() //see communications.dm for full list. First channes is a "default" for :h
	var/subspace_transmission = 0
	var/syndie = 0//Holder to see if it's a syndicate encrpyed radio
	var/raider = 0//same as above but for raiders
	var/maxf = 1499
//			"Example" = FREQ_LISTENING|FREQ_BROADCASTING
	flags = FPRINT | HEAR
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throw_speed = 2
	throw_range = 9
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 75, MAT_GLASS = 25)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC

	var/const/TRANSMISSION_DELAY = 5 // only 2/second/radio
	var/const/FREQ_LISTENING = 1
		//FREQ_BROADCASTING = 2

	var/always_talk=0 // ALWAYS catch signals. Useful for covert listening devices.

/obj/item/device/radio/proc/set_frequency(new_frequency)
	remove_radio(src, frequency)
	frequency = add_radio(src, new_frequency)

/obj/item/device/radio/New()
	wires = new(src)
	radio_list += src
	if(prison_radio)
		wires.CutWireIndex(WIRE_TRANSMIT)

	secure_radio_connections = new
	..()
	if(ticker && ticker.current_state != GAME_STATE_PREGAME) // So that equipped headset during set up are correctly initialized.
		initialize()

/obj/item/device/radio/Destroy()
	wires = null
	radio_list -= src
	remove_radio_all(src) //Just to be sure
	..()

/obj/item/device/radio/initialize()
	. = ..()
	// Mapped radios may have their frequency set.
	// This prevents it from getting reset.
	if(frequency == initial(frequency))
		frequency = COMMON_FREQ //common chat

	if(freerange)
		if(frequency < 1200 || frequency > 1600)
			frequency = sanitize_frequency(frequency, maxf)
	// The max freq is higher than a regular headset to decrease the chance of people listening in, if you use the higher channels.
	else if (frequency < 1441 || frequency > maxf)
		//world.log << "[src] ([type]) has a frequency of [frequency], sanitizing."
		frequency = sanitize_frequency(frequency, maxf)

	set_frequency(frequency)

	for (var/channel_name in channels)
		secure_radio_connections[channel_name] = add_radio(src, radiochannels[channel_name])

/obj/item/device/radio/AltClick()
	if(!usr.incapacitated() && is_holder_of(usr, src))
		attack_self(usr)
	else
		return ..()

/obj/item/device/radio/interact(mob/user as mob)
	if(!on)
		return

	var/dat = "<html><head><title>[src]</title></head><body><TT>"

	dat += "Microphone: [broadcasting ? "<A href='byond://?src=\ref[src];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];talk=1'>Disengaged</A>"]<BR>"

	dat += {"
				Speaker: [listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
				Frequency:
				<A href='byond://?src=\ref[src];freq=-10'>-</A>
				<A href='byond://?src=\ref[src];freq=-2'>-</A>
				<A href='byond://?src=\ref[src];set_freq=-1'>[format_frequency(frequency)]</a>
				<A href='byond://?src=\ref[src];freq=2'>+</A>
				<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
				"}

	for (var/ch_name in channels)
		dat+=text_sec_channel(ch_name, channels[ch_name])
	dat+={"[text_wires()]</TT></body></html>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/device/radio/proc/text_wires()
	if (b_stat)
		return wires.GetInteractWindow()
	return


/obj/item/device/radio/proc/text_sec_channel(var/chan_name, var/chan_stat)
	var/list = !!(chan_stat&FREQ_LISTENING)!=0
	var/chan_prefix = fetch_prefix(chan_name)
	return {"
			<B>[chan_name][chan_prefix ? " (:[chan_prefix]) " : ""]</B>: <A href='byond://?src=\ref[src];ch_name=[chan_name];listen=[!list]'>[list ? "Engaged" : "Disengaged"]</A><BR>
			"}

//Finds if there is a defined prefix for the channel noted in _DEFINES/communications.dm
//It's ugly but if it was as easy as slapping [chan_name]_PREFIX to call the associated prefix.
//This way it also doesn't cause unforeseen consequences.
/obj/item/device/radio/proc/fetch_prefix(var/chan_name)
	switch(chan_name)
		if("Common")
			return COMMON_PREFIX
		if("Security")
			return SECURITY_PREFIX
		if("Engineering")
			return ENGINEERING_PREFIX
		if("Command")
			return COMMAND_PREFIX
		if("Medical")
			return MEDICAL_PREFIX
		if("Science")
			return SCIENCE_PREFIX
		if("Service")
			return SERVICE_PREFIX
		if("Supply")
			return SUPPLY_PREFIX
		if("Deathsquad")
			return DEATHSQUAD_PREFIX
		if("Response Team")
			return RESPONSE_PREFIX
		if("AI Private")
			return AIPRIVATE_PREFIX
		if("Syndicate")
			return SYNDICATE_PREFIX

/obj/item/device/radio/Topic(href, href_list)
	if (!isAdminGhost(usr) && (usr.stat || !on))
		return 1

	if(!in_range(src,usr) && !isAdminGhost(usr) && !issilicon(usr)) //Not adjacent/have telekinesis/a silicon/an aghost? Close it.
		usr << browse(null, "window=radio")
		return 1
	usr.set_machine(src)
	if (href_list["open"])
		var/mob/target = locate(href_list["open"])
		var/mob/living/silicon/ai/A = locate(href_list["open2"])
		if(A && target)
			A.open_nearest_door(target)
		return 1

	else if("set_freq" in href_list)
		var/new_frequency
		new_frequency = input(usr, "Set a new frequency (1200-1600 kHz).", src, frequency) as null|num
		new_frequency = sanitize_frequency(new_frequency, maxf)
		if(!INVOKE_EVENT(src, /event/radio_new_frequency, "user" = usr, "new_frequency" = new_frequency))
			set_frequency(new_frequency)

	else if (href_list["freq"])
		var/new_frequency
		new_frequency = (frequency + text2num(href_list["freq"]))
		new_frequency = sanitize_frequency(new_frequency, maxf)
		if(!INVOKE_EVENT(src, /event/radio_new_frequency, "user" = usr, "new_frequency" = new_frequency))
			set_frequency(new_frequency)

	else if (href_list["talk"])
		broadcasting = text2num(href_list["talk"])
	else if (href_list["listen"])
		var/chan_name = href_list["ch_name"]
		if (!chan_name)
			listening = text2num(href_list["listen"])
		else
			if (channels[chan_name] & FREQ_LISTENING)
				channels[chan_name] &= ~FREQ_LISTENING
			else
				channels[chan_name] |= FREQ_LISTENING
	if (!( master ))
		if (istype(loc, /mob))
			interact(loc)
		else
			updateDialog()
	else
		if (istype(master.loc, /mob))
			interact(master.loc)
		else
			updateDialog()
	add_fingerprint(usr)

/obj/item/device/radio/proc/isWireCut(var/index)
	return wires.IsIndexCut(index)

/obj/item/device/radio/talk_into(var/datum/speech/speech_orig, var/channel=null)
	say_testing(loc, "\[Radio\] - Got radio/talk_into([html_encode(speech_orig.message)], [channel!=null ? channel : "null"]).")
	if(!on)
		say_testing(loc, "\[Radio\] - Not on.")
		return // the device has to be on
	//  Fix for permacell radios, but kinda eh about actually fixing them.
	if(!speech_orig.speaker || !speech_orig.message)
		say_testing(loc, "\[Radio\] - speech.speaker or speech.message are null. [speech_orig.speaker], [html_encode(speech_orig.message)]")
		return

	//  Uncommenting this. To the above comment:
	// 	The permacell radios aren't suppose to be able to transmit, this isn't a bug and this "fix" is just making radio wires useless. -Giacom
	if(isWireCut(WIRE_TRANSMIT)) // The device has to have all its wires and shit intact
		say_testing(loc, "\[Radio\] - TRANSMIT wire cut.")
		return

	if(!speech_orig.speaker.IsVocal())
		say_testing(loc, "\[Radio\] - Speaker not vocal.")
		return

	/* Quick introduction:
		This new radio system uses a very robust FTL signaling technology unoriginally
		dubbed "subspace" which is somewhat similar to 'blue-space' but can't
		actually transmit large mass. Headsets are the only radio devices capable
		of sending subspace transmissions to the Communications Satellite.
		A headset sends a signal to a subspace listener/receiver elsewhere in space,
		the signal gets processed and logged, and an audible transmission gets sent
		to each individual headset.
	*/

	/*
		be prepared to disregard any comments in all of tcomms code. i tried my best to keep them somewhat up-to-date, but eh
	*/
	var/datum/speech/speech=speech_orig.clone()
	speech.radio=src
	#ifdef SAY_DEBUG
	var/msgclasses  = speech.render_message_classes(", ")
	var/wrapclasses = speech.render_wrapper_classes(", ")
	say_testing(loc, "\[Radio\] - Cloned speech - language=[speech.language], message_classes={[msgclasses]}, wrapper_classes={[wrapclasses]}")
	#endif

	var/skip_freq_search=0
	switch(channel)
		if(MODE_HEADSET,null) // Used for ";" prefix, which always sends to src.frequency.
			say_testing(loc, "\[Radio\] - channel=[channel]; Forcing frequency to be [frequency].")
			speech.frequency = src.frequency
			channel = null
			skip_freq_search=1
		if(MODE_SECURE_HEADSET) // Secure headset (?)
			channel = 1 // Always pick the first channel...?


	if(!skip_freq_search)
		if(channel && channels && channels.len > 0)
			if(channel == "department")
                        // Common channel is the first channel added to headsets, so it needs to be removed (unless it's the only channel available).
				if(channels.len > 1)
					channel = (channels - COMMON)[1]
				else
					channel = channels[1]
			speech.frequency = secure_radio_connections[channel]
			if(!channels[channel])
				say_testing(loc, "\[Radio\] - Unable to find channel \"[channel]\".")
				qdel(speech)
				return
		else
			speech.frequency = frequency
			channel = null

	say_testing(loc, "talk_into(): frequency set to [speech.frequency]")

	var/turf/position = get_turf(src)

	//### Radio jammerer function code ###//
	var/jamming_severity = radio_jamming_severity(position)

	// Completely silences the message if jamming effect is too severe.
	// Otherwise distorts it.
	if (is_completely_jammed(jamming_severity))
		return
	if (jamming_severity > 0)
		speech.message = Gibberish(speech.message, jamming_severity)

	//#### Tagging the signal with all appropriate identity values ####//

	// ||-- The mob's name identity --||
	var/real_name = speech.name // mob's real name
	var/mobkey = "none" // player key associated with mob
	var/voicemask = 0 // the speaker is wearing a voice mask
	var/voice = speech.speaker.GetVoice() // Why reinvent the wheel when there is a proc that does nice things already
	if(ismob(speech.speaker))
		var/mob/speaker = speech.speaker
		real_name = speaker.real_name
		if(speaker.client)
			mobkey = speaker.key // assign the mob's key

	// --- Human: use their actual job ---
	if (ishuman(speech.speaker))
		if(voice != real_name)
			voicemask = 1
		speech.job = speech.speaker:get_assignment()

	// --- Carbon Nonhuman ---
	else if (iscarbon(speech.speaker)) // Nonhuman carbon mob
		speech.job = "No id"

	// --- AI ---
	else if (isAI(speech.speaker))
		speech.job = "AI"

	// --- Cyborg ---
	else if (isrobot(speech.speaker))
		speech.job = "Cyborg"

	// --- Personal AI (pAI) ---
	else if (istype(speech.speaker, /mob/living/silicon/pai))
		speech.job = "Personal AI"

	// --- Cold, emotionless machines. ---
	else if(isobj(speech.speaker) || istype(speech.speaker, /mob/living/simple_animal/spiderbot))
		speech.job = "Machine"

	// --- Unidentifiable mob ---
	else
		speech.job = "Unknown"

	// --- Radio Bugs ---

	if(istype(speech.radio,/obj/item/device/radio/bug))
		var/obj/item/device/radio/bug/R = speech.radio
		if(R.radio_tag)
			speech.message = "\[[R.radio_tag]\] [speech.message]" //hacky solution but it's less invasive than modifying telecomms code

/*
	// --- Modifications to the mob's identity ---

	// The mob is disguising their identity:
	if (ishuman(M) && M.GetVoice() != real_name)
		displayname = M.GetVoice()
		jobname = "Unknown"
		voicemask = 1
*/


  /* ###### Radio headsets can only broadcast through subspace ###### */

	if(subspace_transmission)
		// First, we want to generate a new radio signal
		var/datum/signal/signal = new /datum/signal
		signal.transmission_method = 2 // 2 would be a subspace transmission.
									   // transmission_method could probably be enumerated through #define. Would be neater.

		// --- Finally, tag the actual signal with the appropriate values ---
		signal.data = list(
		  // Identity-associated tags:
			"mob"      = speech.speaker,      // store a reference to the mob
			"mobtype"  = speech.speaker.type, // the mob's type
			"realname" = real_name,           // the mob's real name
			"name"     = voice,               // the mob's voice name
			"job"      = speech.job,          // the mob's job
			"key"      = mobkey,              // the mob's key
			"vmask"    = voicemask,           // 1 if the mob is using a voice gas mask

			// We store things that would otherwise be kept in the actual mob
			// so that they can be logged even AFTER the mob is deleted or something

		  // Other tags:
			"compression" = rand(45,50), // compressed radio signal
			"message" = speech.message, // the actual sent message
			"radio" = src, // stores the radio used for transmission
			"slow" = 0, // how much to sleep() before broadcasting - simulates net lag
			"traffic" = 0, // dictates the total traffic sum that the signal went through
			"type" = 0, // determines what type of radio input it is: normal broadcast
			"server" = null, // the last server to log this signal
			"reject" = 0,	// if nonzero, the signal will not be accepted by any broadcasting machinery
			"level" = position.z, // The source's z level
			"language" = speech.language, //The language M is talking in.

			"r_quote"  = speech.rquote,
			"l_quote"  = speech.lquote,

			"message_classes" = speech.message_classes.Copy(),
			"wrapper_classes" = speech.wrapper_classes.Copy()
		)
		signal.frequency = speech.frequency // Quick frequency set

		say_testing(loc, "talk_into(): subspace signal frequency set to [signal.frequency]")

	  //#### Sending the signal to all subspace receivers ####//

		for(var/obj/machinery/telecomms/receiver/R in telecomms_list)
			R.receive_signal(signal)

		// Allinone can act as receivers.
		for(var/obj/machinery/telecomms/allinone/R in telecomms_list)
			R.receive_signal(signal)

		// Receiving code can be located in Telecommunications.dm
		qdel(speech)
		return


  /* ###### Intercoms and station-bounced radios ###### */

	var/filter_type = 2

	/* --- Intercoms can only broadcast to other intercoms, but bounced radios can broadcast to bounced radios and intercoms --- */
	if(istype(src, /obj/item/device/radio/intercom))
		filter_type = 1


	var/datum/signal/signal = new /datum/signal
	signal.transmission_method = 2


	/* --- Try to send a normal subspace broadcast first */

	signal.data = list(

		"mob"      = speech.speaker,      // store a reference to the mob
		"mobtype"  = speech.speaker.type, // the mob's type
		"realname" = real_name,           // the mob's real name
		"name"     = voice,               // the mob's display name
		"job"      = speech.job,          // the mob's job
		"key"      = mobkey,              // the mob's key
		"vmask"    = voicemask,           // 1 if the mob is using a voice gas mas

		"compression" = 0, // uncompressed radio signal
		"message" = speech.message, // the actual sent message
		"radio" = src, // stores the radio used for transmission
		"slow" = 0,
		"traffic" = 0,
		"type" = 0,
		"server" = null,
		"reject" = 0,
		"level" = position.z,
		"language" = speech.language,

		"r_quote"  = speech.rquote,
		"l_quote"  = speech.lquote,

		"message_classes" = speech.message_classes.Copy(),
		"wrapper_classes" = speech.wrapper_classes.Copy(),
	)
	signal.frequency = speech.frequency // Quick frequency set

	say_testing(loc, "talk_into(): subspace signal frequency set to [signal.frequency]")

	for(var/obj/machinery/telecomms/receiver/R in telecomms_list)
		R.receive_signal(signal)

	spawn(rand(10,25)) // wait a little...

		if(signal.data["done"] && (position.z in signal.data["level"]))
			// we're done here.
			qdel(speech)
			return

		// Oh my god; the comms are down or something because the signal hasn't been broadcasted yet in our level.
		// Send a mundane broadcast with limited targets:
		Broadcast_Message(speech, voicemask, filter_type, signal.data["compression"], list(position.z))
		qdel(speech)

/obj/item/device/radio/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(!speech.speaker || speech.frequency)
		return
	if (broadcasting)
		if(get_dist(src, speech.speaker) <= canhear_range)
			talk_into(speech)
/*
/obj/item/device/radio/proc/accept_rad(obj/item/device/radio/R as obj, message)


	if ((R.frequency == frequency && message))
		return 1
	else if

	else
		return null
	return
*/


/obj/item/device/radio/proc/receive_range(freq, level)
	// check if this radio can receive on the given frequency, and if so,
	// what the range is in which mobs will hear the radio
	// returns: -1 if can't receive, range otherwise

	if (isWireCut(WIRE_RECEIVE))
		return -1
	if(!listening)
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(!position || !(position.z in level))
			return -1
	if(freq == SYND_FREQ)
		if(!(src.syndie))//Checks to see if it's allowed on that frequency, based on the encryption keys
			return -1
	if(freq == RAID_FREQ)
		if(!(src.raider))//Checks to see if it's allowed on that frequency, based on the encryption keys, bird edition
			return -1
	if (!on)
		return -1
	if (!freq) //received on main frequency
		if (!listening)
			return -1
	else
		var/accept = (freq==frequency && listening)
		if (!accept)
			for (var/ch_name in channels)
				if(channels[ch_name] & FREQ_LISTENING)
					if(radiochannels[ch_name] == text2num(freq) || syndie)
						accept = 1
						break
		if (!accept)
			return -1
	return canhear_range

/obj/item/device/radio/proc/send_hear(freq, level)


	var/range = receive_range(freq, level)
	if(range > -1)
		return get_hearers_in_view(canhear_range, src)


/obj/item/device/radio/examine(mob/user)
	..()
	if (b_stat)
		user.show_message("<span class = 'info'>\The [src] can be attached and modified!</span>")
	else
		user.show_message("<span class = 'info'>\The [src] can not be modified or attached!</span>")


/obj/item/device/radio/attack_self(mob/user)
	. = ..()
	if(.)
		return
	user.set_machine(src)
	interact(user)

/obj/item/device/radio/attackby(obj/item/weapon/W as obj, mob/user as mob)
	. = ..()
	if(.)
		return
	user.set_machine(src)
	if (!(W.is_screwdriver(user)))
		return
	b_stat = !(b_stat)
	if (b_stat)
		user.show_message("<span class = 'notice'>\The [src] can now be attached and modified!</span>")
	else
		user.show_message("<span class = 'notice'>\The [src] can no longer be modified or attached!</span>")
	updateDialog()
	update_icon()
	add_fingerprint(user)

/obj/item/device/radio/emp_act(severity)
	broadcasting = 0
	listening = 0
	for (var/ch_name in channels)
		channels[ch_name] = 0
	for(var/mob/living/simple_animal/hostile/pulse_demon/PD in contents)
		PD.emp_act(severity) // Not inheriting so do it here too
	..()

/obj/item/device/radio/phone
	name = "radio phone"
	desc = "A hard line, immobile."
	icon = 'icons/obj/items.dmi'
	icon_state = "brown_phone"
	anchored = TRUE
	w_class = W_CLASS_LARGE
	canhear_range = 1
	channels = list("Response Team" = 1, "Command" = 0)

/obj/item/device/radio/phone/attack_hand(mob/user)
	add_fingerprint(user)
	if(anchored)
		attack_self(user)
	else
		..()

/obj/item/device/radio/phone/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(!speech.speaker || speech.frequency)
		return
	if(broadcasting && (get_dist(src, speech.speaker) <= canhear_range))
		for(var/ch in channels)
			if(channels[ch])
				talk_into(speech, ch)

/obj/item/device/radio/phone/interact(mob/user as mob)
	if(!on)
		return

	var/dat = "<html><head><title>[src]</title></head><body><TT>"

	dat += "Microphone: [broadcasting ? "<A href='byond://?src=\ref[src];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];talk=1'>Disengaged</A>"]<BR>"
	if(channels["Response Team"] == 1)
		dat += "Channel: <b>Responder</b> <A href='byond://?src=\ref[src];toggle_channel=1'>Command</A>"
	else
		dat += "Channel: <A href='byond://?src=\ref[src];toggle_channel=1'>Responder</A> <b>Command</b>"

	dat+={"</TT></body></html>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")

/obj/item/device/radio/phone/Topic(href, href_list)
	if(..())
		return 1
	if("toggle_channel" in href_list)
		channels["Response Team"] = !channels["Response Team"]
		channels["Command"] = !channels["Command"]
		updateDialog()

/obj/item/device/radio/phone/pack
	name = "radio backpack"
	desc = "Although most of the space is taken up by the radio, there's still space for some storage. Use in hand to access radio channels."
	anchored = FALSE
	slot_flags = SLOT_BACK
	icon_state = "radiopack"
	item_state = "radiopack"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/backpacks_n_bags.dmi', "right_hand" = 'icons/mob/in-hand/right/backpacks_n_bags.dmi')
	var/obj/item/weapon/storage/radiopack/ourpack

/obj/item/device/radio/phone/pack/New()
	..()
	ourpack = new /obj/item/weapon/storage/radiopack(src)

/obj/item/device/radio/phone/pack/attack_hand(mob/user)
	if(user.get_inactive_hand() == src)
		ourpack.show_to(user)
	else
		..()

/obj/item/device/radio/phone/pack/AltClick(mob/user)
	ourpack.AltClick(user)

/obj/item/device/radio/phone/pack/attackby(obj/item/I, mob/user)
	ourpack.attackby(I,user)

/obj/item/weapon/storage/radiopack
	name = "radio backpack"
	desc = "Although most of the space is taken up by the radio, there's still space for some storage. Use in hand to access radio channels."
	w_class = W_CLASS_LARGE

/obj/item/weapon/storage/radiopack/distance_interact(mob/user)
	if(istype(loc,/obj/item/device/radio/phone/pack) && in_range(user,loc))
		playsound(loc, rustle_sound, 50, 1, -5)
		return TRUE
	return FALSE

/obj/item/device/radio/phone/surveillance
	name = "\improper DromedaryCo packet"
	desc = "A packet of six imported DromedaryCo cigarettes. A label on the packaging reads: \"Wouldn't a slow death make a change?\""
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "Dpacket"
	item_state = "Dpacket"
	anchored = FALSE
	w_class = W_CLASS_TINY
	channels = list("Radio Bug" = 1)
	var/obj/item/weapon/storage/box/surveillance/cigbox

/obj/item/device/radio/phone/surveillance/New()
	..()
	frequency = BUG_FREQ
	cigbox = new /obj/item/weapon/storage/box/surveillance(src)

/obj/item/device/radio/phone/surveillance/attack_hand(mob/user)
	if(user.get_inactive_hand() == src)
		cigbox.show_to(user)
	else
		..()

/obj/item/device/radio/phone/surveillance/interact(mob/user as mob)
	if(!on)
		return

	var/dat = "<html><head><title>[src]</title></head><body><TT>"

	dat += "Speaker: [listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>"
	dat+={"</TT></body></html>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")

/obj/item/device/radio/phone/surveillance/Topic(href, href_list)
	if(..())
		return 1

/obj/item/device/radio/phone/surveillance/examine(mob/user)
	cigbox.examine(user)

/obj/item/device/radio/phone/surveillance/AltClick(mob/user)
	cigbox.AltClick(user)

/obj/item/device/radio/phone/surveillance/attackby(obj/item/I, mob/user)
	cigbox.attackby(I,user)

/obj/item/device/radio/bug
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = W_CLASS_TINY
	throwforce = 1
	autoignition_temperature = 0 //The filter doesn't burn
	broadcasting = 1
	listening = 0
	always_talk = 1
	var/radio_tag
