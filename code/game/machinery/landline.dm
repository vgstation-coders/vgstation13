/obj/effect/phone_cord
	name = "telephone cord"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "phone_cord"
	anchored = TRUE

/obj/landline
	var/obj/item/telephone/linked_phone = null
	var/obj/item/telephone/phone = null
	var/image/phone_overlay
	var/ringer = TRUE
	var/ringing = FALSE
	var/chosen_department //department we want to call
	var/obj/landline/calling = null	//landline we are in a call with
	var/last_call_log
	var/obj/attached_to
	var/phone_type = "/obj/item/telephone"
	var/overlay_icon = 'icons/obj/terminals.dmi'
	var/overlay_iconstate = "phone_overlay"
	var/tether_length = 4
	var/list/obj/effect/phone_cord/linked_cord = list()
	var/list/obj/item/telephone/switchboard/listening_operators = list()
	var/is_dialtone_looping = FALSE
	var/is_endcall_looping = FALSE

/obj/landline/New(var/obj/A=loc)
	attached_to = A
	linked_phone = new phone_type (src)
	linked_phone.linked_landline = src
	phone = linked_phone
	
	phone_overlay = image(icon = overlay_icon, icon_state = overlay_iconstate)
	attached_to.overlays.Add(phone_overlay) //TODO make this less shit

/obj/landline/proc/delete_cord()
	if(!linked_phone)
		return
	for(var/obj/C in linked_cord)
		qdel(C)
	linked_cord = list()

/obj/landline/proc/make_cord()
	if(!linked_phone)
		return
	if(get_dist(src, linked_phone) > tether_length-1)
		linked_phone.visible_message("\The [src] cord stretches dangerously...")
		if(get_dist(src, linked_phone) > tether_length)
			linked_phone.visible_message("<span class='warning'>The cord snaps!</span>")
			linked_phone.linked_landline = null
			linked_phone = null		
			return
			
	var/obj/cable1
	var/obj/cable2
	var/turf/T = attached_to.loc
	var/first_offset = FALSE
	if(src.attached_to.pixel_x < -15)
		first_offset = WEST
	if(src.attached_to.pixel_x > 15)
		first_offset = EAST
	if(src.attached_to.pixel_y < -15)
		first_offset = SOUTH
	if(src.attached_to.pixel_y > 15)
		first_offset = NORTH
	if(first_offset)
		cable1 = new /obj/effect/phone_cord (T)
		cable1.dir = first_offset
		linked_cord += cable1
	var/list/getstepto = get_steps_to(src.attached_to, linked_phone.loc)
	for(var/D in getstepto)
		cable2 = new /obj/effect/phone_cord (T)
		cable2.dir = D
		T = get_step(T,D)
		cable1 = new /obj/effect/phone_cord (T)
		cable1.dir = turn(D,180)
		linked_cord += cable1
		linked_cord += cable2
		
/obj/landline/proc/reattach_cord(mob/user)
	if(!phone)
		to_chat(user, "<span class='warning'>There's no phone to fix!</span>")
		return 	
	if(phone.linked_landline)
		to_chat(user, "<span class='warning'>\the [phone] is already connected!</span>")
		return
	if(linked_phone)
		to_chat(user, "<span class='warning'>\the [phone] is connected elsewhere!</span>")
		return
	phone.linked_landline = src
	linked_phone = phone
	return TRUE
		
/obj/landline/proc/shake_phone_overlay(amplitude = 2)
	if(!phone)
		return
	spawn(0)
		var/pixel_x_diff = rand(-amplitude, amplitude) * PIXEL_MULTIPLIER
		var/pixel_y_diff = rand(-amplitude, amplitude) * PIXEL_MULTIPLIER
		animate(attached_to, pixel_x = attached_to.pixel_x + pixel_x_diff, pixel_y = attached_to.pixel_y + pixel_y_diff , time = 1, loop = 10,easing = BOUNCE_EASING)
		animate(pixel_x = attached_to.pixel_x - pixel_x_diff, pixel_y = attached_to.pixel_y - pixel_y_diff , time = 1, loop = 10,easing = BOUNCE_EASING)
	
/obj/landline/proc/has_power()
	var/obj/machinery/requests_console/RC = attached_to
	if(istype(RC, /obj/machinery/requests_console) && RC.stat)
		return FALSE
	return TRUE //redphones stay powered regardless
	
/obj/landline/proc/end_call_loop()
	if(is_endcall_looping)
		return
	if(is_dialtone_looping)
		return
	is_endcall_looping = TRUE
	spawn(0)
		while(linked_phone && !phone && has_power() && is_endcall_looping)
			playsound(source=linked_phone, soundin=linked_phone.end_call_sound, vol=100, vary=FALSE, channel=0)
			sleep(1 SECONDS)
	
/obj/landline/proc/ring_loop()
	is_endcall_looping = FALSE
	is_dialtone_looping = TRUE
	if(calling && calling.phone)
		calling.ringing = TRUE
	spawn(0)
		while(calling && calling.calling == src && calling.ringing)
			if(!has_power())
				calling.ringing = FALSE
			calling.ring()
			if(linked_phone && !phone)
				playsound(source=linked_phone, soundin=linked_phone.dial_sound, vol=100, vary=FALSE, channel=0)
				//this sound is barely perceptible if you're not right next to the phone
			sleep(5 SECONDS)

/obj/landline/proc/start_call(var/obj/landline/destination)
	if(!destination)
		return "critical error"
	if(calling)
		return "you are already calling [calling.get_department()]"
	if(destination.calling || !destination.phone)
		end_call_loop()
		return "line busy"
	if(phone)
		return "pick up the phone first"
	for (var/obj/machinery/message_server/MS in message_servers)
		if(MS.landlines_functioning())
			calling = destination
			destination.calling = src
			ring_loop()
			return "dialling..."
	return "auto-routing offline. please wait for operator..."
	
			

/obj/landline/proc/ring()
	if(!linked_phone)
		return
	if(!attached_to)
		return
	if(!has_power())
		return
	if(ringer)
		playsound(source=attached_to.loc, soundin=linked_phone.ringtone, vol=100, vary=FALSE, channel=CHANNEL_TELEPHONES)
		shake_phone_overlay()

/obj/landline/proc/pick_up_phone(mob/user)
	if(!iscarbon(user))
		to_chat(user, "<span class='notice'>You are not capable of such fine manipulation.</span>")
		return
	if(user.incapacitated())
		to_chat(user, "<span class='notice'>You cannot do this while incapacitated.</span>")
		return
	if(!phone)
		to_chat(user, "<span class='notice'>\the [src] has no telephone!</span>")
		return
	
	user.put_in_hands(src.phone)
	playsound(source=src, soundin= phone.pickup_sound, vol=100, vary=TRUE, channel=CHANNEL_TELEPHONES, wait=0)
	phone = null //do not delete phone
	attached_to.overlays.Remove(phone_overlay)
	if(ringing && calling)
		calling.is_dialtone_looping = FALSE
		//TODO don't override the "rerouted by operator" line if we got rerouted
		last_call_log = text("<B>Last call log:</B><BR><BR>")
		last_call_log += text("picked up call from [calling.get_department()]<BR>")
		calling.last_call_log += text("[get_department()] picked up call<BR>")
		if(calling.linked_phone)
			playsound(source=calling.linked_phone, soundin=linked_phone.pickup_sound, vol=100, vary=TRUE, channel=CHANNEL_TELEPHONES, wait=0)
	ringing = FALSE
	for(var/obj/machinery/computer/message_monitor/MM in message_monitors)
		MM.updateUsrDialog()

/obj/landline/proc/get_status()
	//orange - operator should plug in and talk to user
	//green - call in progress, operator can stop listening in
	//red - call over, operator should disconnect lines
	//null - idle
	if(calling)
		if(calling.ringing || src.ringing)
			return "green"	//GREEN phone ringing, call about to start
		if(calling.phone && src.phone)
			return "red"	//RED both hung up
		if(calling.phone || src.phone)
			return "orange" //YELLOW one talking other hung up
		return "green"		//GREEN both talking
	else
		if(!phone)
			return "orange"	//YELLOW 2a one phone dialling operator, other not yet defined
				//TODO add an orange variant, for when the thing is still picked up but has already spoken to an operator
		return 				//idle, most machines should be this
	
/obj/landline/proc/get_department()
	var/obj/machinery/requests_console/RC = attached_to
	if(istype(RC, /obj/machinery/requests_console))
		return RC.department
	return "ERROR"	

/obj/landline/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(!istype(O, /obj/item/telephone))
		return
	if(phone)
		to_chat(user, "<span class='notice'>There is already a telephone on the hook.</span>")
		return
	if(!user.drop_item(O))
		to_chat(user, "<span class='warning'>It's stuck to your hand!</span>")
		return
	if(linked_phone == O)
		delete_cord()
	is_dialtone_looping = FALSE
	is_endcall_looping = FALSE
	if(calling)
		if(calling.ringing)
			calling.ringing = FALSE
			var/obj/machinery/requests_console/RC = calling.attached_to
			if(istype(RC,/obj/machinery/requests_console))
				RC.messages += "missed call from <A href='?src=\ref[RC];dialConsole=\ref[src.attached_to]'>[get_department()]</A>."
				if(RC.newmessagepriority < 1)
					RC.newmessagepriority = 1
					RC.icon_state = "req_comp1"
		last_call_log += text("you hung up<BR>")
		calling.last_call_log += text("[get_department()] hung up<BR>")
		calling.attached_to.updateUsrDialog()
		attached_to.updateUsrDialog()
		calling.end_call_loop()
		for (var/obj/machinery/message_server/MS in message_servers)
			if(MS.landlines_functioning())
				calling.calling = null
				calling = null
				break
	for(var/obj/machinery/computer/message_monitor/MM in message_monitors)
		MM.updateUsrDialog()
	
	user.visible_message("<span class='notice'>[user] puts \the [O] onto \the [src.attached_to].</span>")
	var/obj/item/telephone/P = O
	playsound(source=O, soundin=P.pickup_sound, vol=100, vary=TRUE, channel=0)
	phone = O
	O.forceMove(src)
	attached_to.overlays.Add(phone_overlay)
	
/obj/landline/red
	overlay_icon = 'icons/obj/items.dmi'
	overlay_iconstate = "red_phone_handset"
	
	
/obj/item/telephone
	name = "telephone"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "phone"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	item_state = "rpb_phone"	
	flags = HEAR | FPRINT
	var/mic_range = 3
	var/speaker_range = 3
	var/soundloops_before_exploding = 3
	var/obj/landline/linked_landline = null
	var/datum/speech/lastmsg
	var/pickup_sound = 'sound/items/telephone_pickup.ogg'
	var/ringtone = 'sound/items/telephone_ring.ogg'
	var/end_call_sound = 'sound/items/telephone_end_call_440hz.mp3'
	var/dial_sound = 'sound/items/telephone_dial_440hz.mp3'
	var/clowned = FALSE 
	var/broken = FALSE
		
/obj/item/telephone/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O,/obj/item/toy/crayon/rainbow) && clowned == FALSE)
		to_chat(user, "<span class = 'notice'>You begin modifying \the [src].</span>")
		if(do_after(user, src, 4 SECONDS))
			to_chat(user, "<span class = 'notice'>You finish modifying \the [src]!</span>")
			honkify()
			clowned = TRUE
			
/obj/item/telephone/proc/honkify()
	name = "Bananaphone"
	icon = 'icons/obj/hydroponics/banana.dmi'
	icon_state = "produce"
	pickup_sound = 'sound/items/bananaphone_pickup.ogg'
	ringtone = 'sound/items/bananaphone_ring.ogg'
	if(linked_landline)
		linked_landline.phone_overlay = image(icon = linked_landline.overlay_icon, icon_state = "phone_overlay_banana")
	update_icon()
	
/obj/item/telephone/proc/make_cord()
	if(!linked_landline)
		return
	linked_landline.delete_cord()
	linked_landline.make_cord()
	
/obj/item/telephone/pickup(var/mob/user)
	..()
	make_cord()
	user?.register_event(/event/after_move, src, /obj/item/telephone/proc/make_cord)	
	
/obj/item/telephone/dropped(var/mob/user)
	..()
	make_cord()
	user?.unregister_event(/event/after_move, src, /obj/item/telephone/proc/make_cord)	

/obj/item/telephone/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	//TODO make this work while in lockers and backpacks and such
	..()
	if(!linked_landline)
		return
	linked_landline.delete_cord()
	linked_landline.make_cord()

/obj/item/telephone/proc/explode()
	explosion_effect(get_turf(src),-1,-1,-1) //fake boom, doesn't alert bhangmetersž
	linked_landline.delete_cord()
	linked_landline.linked_phone = null
	linked_landline = null
	broken = TRUE
	visible_message("<span class='warning'>\the [src] releases its magic smoke!</span>")
	spawn(1)
		flashbangprime()

/obj/item/telephone/send_speech(var/datum/speech/speech, var/range=7, var/bubble_type)
	if(broken)
		return
	
	if(speech && speech.wrapper_classes["spoken_into_telephone"])
		if(speech.wrapper_classes["spoken_into_telephone"] > 3)
			speech.message_classes.Add("verybig")
		else if(speech.wrapper_classes["spoken_into_telephone"] > 2)
			speech.message_classes.Add("big")
	if(speech && speech.wrapper_classes["spoken_into_telephone"] > soundloops_before_exploding && prob(75))
		var/randomlen = rand(1,length(speech.message))
		speech.message = copytext(speech.message, 1, randomlen)
		speech.message += "-"
		explode()
	..()

/obj/item/telephone/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(get_dist(src, speech.speaker) > mic_range)
		return
	if(!linked_landline)
		return
	if(linked_landline.phone)
		return
	if(broken)
		return
	var/msg = text("[speech.name]: [speech.message]<BR>")
	linked_landline.last_call_log += msg
	linked_landline.attached_to.updateUsrDialog()
	lastmsg = speech.clone()
	lastmsg.name += " (Telephone)"
	lastmsg.wrapper_classes["spoken_into_telephone"] += 1
	if(linked_landline.calling && linked_landline.calling.linked_phone)
		if(!linked_landline.calling.ringing && !linked_landline.calling.phone)
			var/obj/item/telephone/P = linked_landline.calling.linked_phone
			P.send_speech(lastmsg, P.speaker_range, bubble_type = "")
			linked_landline.calling.last_call_log += msg
			linked_landline.calling.attached_to.updateUsrDialog()
	for(var/obj/item/telephone/switchboard/ST in linked_landline.listening_operators)
		ST.send_speech(lastmsg, ST.speaker_range, bubble_type = "")
	
/obj/item/telephone/switchboard
	name = "switchboard operator headset"
	desc = "you shouldn't ever see this."
	mic_range = 1
	
/obj/item/telephone/switchboard/explode()
	explosion_effect(get_turf(src),-1,-1,-1) //fake boom, doesn't alert bhangmeters
	var/obj/machinery/computer/message_monitor/MM = loc
	if(MM)
		MM.switchboard_headset = null
	linked_landline.listening_operators -= src
	linked_landline = null
	broken = TRUE
	visible_message("<span class='warning'>\the [src] releases its magic smoke!</span>")
	spawn(1)
		flashbangprime()

//TODO add multi-person phonecalls so i don't need to do this shit and instead just add the operator into the phonecallers list
/obj/item/telephone/switchboard/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(get_dist(src, speech.speaker) > mic_range)
		return
	if(!linked_landline)
		return
	if(broken)
		return
	var/msg = text("[speech.name]: [speech.message]<BR>")
	lastmsg = speech.clone()
	lastmsg.name += " (Telephone operator)"
	lastmsg.wrapper_classes["spoken_into_telephone"] += 1
	if(linked_landline.linked_phone)
		var/obj/item/telephone/P = linked_landline.linked_phone
		P.send_speech(lastmsg, P.speaker_range, bubble_type = "")
		linked_landline.last_call_log += msg
		linked_landline.attached_to.updateUsrDialog()
	if(linked_landline.calling && linked_landline.calling.linked_phone)
		var/obj/item/telephone/P = linked_landline.calling.linked_phone
		P.send_speech(lastmsg, P.speaker_range, bubble_type = "")
		linked_landline.calling.last_call_log += msg
		linked_landline.calling.attached_to.updateUsrDialog()
		
	for(var/obj/item/telephone/switchboard/ST in linked_landline.listening_operators)
		if(ST == src)
			continue
		ST.send_speech(lastmsg, ST.speaker_range, bubble_type = "")
