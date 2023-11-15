/obj/phone_cord
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
	var/list/obj/phone_cord/linked_cord = list()

/obj/landline/New(var/obj/A)
	attached_to = A
	linked_phone = new phone_type (src)
	linked_phone.linked_landline = src
	phone = linked_phone
	
	phone_overlay = image(icon = overlay_icon, icon_state = overlay_iconstate)
	attached_to.overlays.Add(phone_overlay) //TODO make this less shit

/obj/landline/proc/delete_cord()
	for(var/obj/C in linked_cord)
		qdel(C)
	linked_cord = list()

/obj/landline/proc/make_cord()
	if(!linked_phone)
		return
	if(get_dist(src, linked_phone) > tether_length)
		//TODO cut the cord
		message_admins("cord too long, halting")
		return
	var/obj/cable1
	var/obj/cable2
	var/turf/T = attached_to.loc
	cable1 = new /obj/phone_cord (T) //TODO turn depending on console pixel_x and pixel_y
	linked_cord += cable1
	var/list/getstepto = get_steps_to(src.attached_to, linked_phone.loc)
	for(var/D in getstepto)
		cable2 = new /obj/phone_cord (T)
		cable2.dir = D
		T = get_step(T,D)
		cable1 = new /obj/phone_cord (T)
		cable1.dir = turn(D,180)
		linked_cord += cable1
		linked_cord += cable2
		

/obj/landline/proc/start_call(var/obj/landline/destination)
	if(!destination)
		return "critical error"
	if(calling)
		return "you are already calling [calling]"
	if(destination.calling || !destination.phone)
		return "line busy"
	if(phone)
		return "pick up the phone first"
	calling = destination
	destination.calling = src
	destination.ringing = TRUE
	spawn(0)
		while(destination && destination.calling == src && destination.ringing)
			if(phone)
				//TODO destination add message("missed call from [src]")
				last_call_log += text("<B>you hung up.<BR>")
				return
			destination.ring()
			sleep(5 SECONDS)

/obj/landline/proc/ring()
	if(!linked_phone)
		return
	if(!attached_to)
		return
	if(ringer)
		playsound(source=attached_to.loc, soundin=linked_phone.ringtone, vol=100, vary=FALSE, channel=CHANNEL_TELEPHONES)
	//TODO shake phone overlay

/obj/landline/proc/pick_up_phone(mob/user)
	if(!ishuman(user))
		to_chat(user, "You are not capable of such fine manipulation.")
		return
	if(user.incapacitated())
		to_chat(user, "You cannot do this while incapacitated.")
		return
	if(!phone)
		to_chat(user, "\the [src] has no telephone!")
		return
	
	user.put_in_hands(src.phone)
	playsound(source=src, soundin= phone.pickup_sound, vol=100, vary=TRUE, channel=CHANNEL_TELEPHONES, wait=0)
	phone = null //do not delete phone
	attached_to.overlays.Remove(phone_overlay)
	if(ringing && calling)
		last_call_log = text("<B>Last call log:</B><BR><BR>")
		last_call_log += text("picked up call from [calling.attached_to]<BR>")
		calling.last_call_log += text("[attached_to] picked up call<BR>")
	ringing = FALSE

/obj/landline/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(!istype(O, /obj/item/telephone))
		return
	if(phone)
		to_chat(user, "<span class='notice'>There is already a telephone on the hook.</span>")
		return
	if(!user.drop_item(O))
		to_chat(user, "<span class='warning'>It's stuck to your hand!</span>")
		return
	if(calling)
		last_call_log += text("you hung up<BR>")
		calling.last_call_log += text("[attached_to] hung up<BR>")
		calling.calling = null
		calling = null
	
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
	flags = HEAR | FPRINT
	var/mic_range = 3
	var/speaker_range = 3
	var/obj/landline/linked_landline = null
	var/datum/speech/lastmsg
	var/pickup_sound = 'sound/items/telephone_pickup.ogg'
	var/ringtone = 'sound/items/telephone_ring.ogg'
	var/clowned = FALSE
	
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
	pickup_sound = 'sound/items/bikehorn.ogg'
	ringtone = 'sound/items/bananaphone_ring.wav'
	if(linked_landline)
		linked_landline.phone_overlay = image(icon = linked_landline.overlay_icon, icon_state = "phone_overlay_banana")
	update_icon()
	
/obj/item/telephone/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	..()
	if(!linked_landline)
		return
	linked_landline.delete_cord()
	linked_landline.make_cord()
	
/obj/item/telephone/Hear(var/datum/speech/speech, var/rendered_speech="")
	//TODO make it not loop infinitely if you call 2 phones and put them next to each other
	if(get_dist(src, speech.speaker) > mic_range)
		return
	if(!linked_landline)
		return
	if(!linked_landline.calling)
		return
	if(linked_landline.calling.ringing)
		return
	if(!linked_landline.calling.linked_phone)
		return
	var/msg = text("[speech.name]: [speech.message]<BR>")
	linked_landline.last_call_log += msg
	linked_landline.calling.last_call_log += msg
	lastmsg = speech
	speech.name += "(Telephone)"
	var/obj/item/telephone/speaker = linked_landline.calling.linked_phone
	speaker.send_speech(speech, speaker.speaker_range, bubble_type = "")
