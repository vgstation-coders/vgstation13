/obj/item/device/taperecorder
	name = "universal recorder"
	desc = "A device that can record to cassette tapes, and play them. It automatically translates the content in playback."
	icon_state = "taperecorder_empty"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = HEAR_1
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=60, MAT_GLASS=30)
	force = 2
	throwforce = 0
	var/recording = 0
	var/playing = 0
	var/playsleepseconds = 0
	var/obj/item/device/tape/mytape
	var/starting_tape_type = /obj/item/device/tape/random
	var/open_panel = 0
	var/canprint = 1


/obj/item/device/taperecorder/Initialize(mapload)
	. = ..()
	if(starting_tape_type)
		mytape = new starting_tape_type(src)
	update_icon()


/obj/item/device/taperecorder/examine(mob/user)
	..()
	to_chat(user, "The wire panel is [open_panel ? "opened" : "closed"].")


/obj/item/device/taperecorder/attackby(obj/item/I, mob/user, params)
	if(!mytape && istype(I, /obj/item/device/tape))
		if(!user.transferItemToLoc(I,src))
			return
		mytape = I
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		update_icon()


/obj/item/device/taperecorder/proc/eject(mob/user)
	if(mytape)
		to_chat(user, "<span class='notice'>You remove [mytape] from [src].</span>")
		stop()
		user.put_in_hands(mytape)
		mytape = null
		update_icon()

/obj/item/device/taperecorder/fire_act(exposed_temperature, exposed_volume)
	mytape.ruin() //Fires destroy the tape
	..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/device/taperecorder/attack_hand(mob/user)
	if(loc == user)
		if(mytape)
			if(!user.is_holding(src))
				return ..()
			eject(user)
	else
		return ..()

/obj/item/device/taperecorder/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return TRUE
	return FALSE


/obj/item/device/taperecorder/verb/ejectverb()
	set name = "Eject Tape"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape)
		return

	eject(usr)


/obj/item/device/taperecorder/update_icon()
	if(!mytape)
		icon_state = "taperecorder_empty"
	else if(recording)
		icon_state = "taperecorder_recording"
	else if(playing)
		icon_state = "taperecorder_playing"
	else
		icon_state = "taperecorder_idle"


/obj/item/device/taperecorder/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, message_mode)
	if(mytape && recording)
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [message]"

/obj/item/device/taperecorder/verb/record()
	set name = "Start Recording"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return

	if(mytape.used_capacity < mytape.max_capacity)
		to_chat(usr, "<span class='notice'>Recording started.</span>")
		recording = 1
		update_icon()
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording started."
		var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
		var/max = mytape.max_capacity
		for(used, used < max)
			if(recording == 0)
				break
			mytape.used_capacity++
			used++
			sleep(10)
		recording = 0
		update_icon()
	else
		to_chat(usr, "<span class='notice'>The tape is full.</span>")


/obj/item/device/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(!can_use(usr))
		return

	if(recording)
		recording = 0
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording stopped."
		to_chat(usr, "<span class='notice'>Recording stopped.</span>")
		return
	else if(playing)
		playing = 0
		var/turf/T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Playback stopped.</font>")
	update_icon()


/obj/item/device/taperecorder/verb/play()
	set name = "Play Tape"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return

	playing = 1
	update_icon()
	to_chat(usr, "<span class='notice'>Playing started.</span>")
	var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used < max, sleep(10 * playsleepseconds))
		if(!mytape)
			break
		if(playing == 0)
			break
		if(mytape.storedinfo.len < i)
			break
		say(mytape.storedinfo[i])
		if(mytape.storedinfo.len < i + 1)
			playsleepseconds = 1
			sleep(10)
			say("End of recording.")
		else
			playsleepseconds = mytape.timestamp[i + 1] - mytape.timestamp[i]
		if(playsleepseconds > 14)
			sleep(10)
			say("Skipping [playsleepseconds] seconds of silence")
			playsleepseconds = 1
		i++

	playing = 0
	update_icon()


/obj/item/device/taperecorder/attack_self(mob/user)
	if(!mytape || mytape.ruined)
		return
	if(recording)
		stop()
	else
		record()


/obj/item/device/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape)
		return
	if(!canprint)
		to_chat(usr, "<span class='notice'>The recorder can't print that fast!</span>")
		return
	if(recording || playing)
		return

	to_chat(usr, "<span class='notice'>Transcript printed.</span>")
	var/obj/item/paper/P = new /obj/item/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i = 1, mytape.storedinfo.len >= i, i++)
		t1 += "[mytape.storedinfo[i]]<BR>"
	P.info = t1
	P.name = "paper- 'Transcript'"
	usr.put_in_hands(P)
	canprint = 0
	sleep(300)
	canprint = 1


//empty tape recorders
/obj/item/device/taperecorder/empty
	starting_tape_type = null


/obj/item/device/tape
	name = "tape"
	desc = "A magnetic tape that can hold up to ten minutes of content."
	icon_state = "tape_white"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL=20, MAT_GLASS=5)
	force = 1
	throwforce = 0
	var/max_capacity = 600
	var/used_capacity = 0
	var/list/storedinfo = list()
	var/list/timestamp = list()
	var/ruined = 0

/obj/item/device/tape/fire_act(exposed_temperature, exposed_volume)
	ruin()
	..()

/obj/item/device/tape/attack_self(mob/user)
	if(!ruined)
		to_chat(user, "<span class='notice'>You pull out all the tape!</span>")
		ruin()


/obj/item/device/tape/proc/ruin()
	//Lets not add infinite amounts of overlays when our fireact is called
	//repeatedly
	if(!ruined)
		add_overlay("ribbonoverlay")
	ruined = 1


/obj/item/device/tape/proc/fix()
	cut_overlay("ribbonoverlay")
	ruined = 0


/obj/item/device/tape/attackby(obj/item/I, mob/user, params)
	if(ruined && istype(I, /obj/item/screwdriver) || istype(I, /obj/item/pen))
		to_chat(user, "<span class='notice'>You start winding the tape back in...</span>")
		if(I.use_tool(src, user, 120))
			to_chat(user, "<span class='notice'>You wound the tape back in.</span>")
			fix()

//Random colour tapes
/obj/item/device/tape/random
	icon_state = "random_tape"

/obj/item/device/tape/random/New()
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"
	..()
