/obj/landline
	var/obj/item/telephone/linked_phone = null
	var/obj/item/telephone/phone = null
	var/image/phone_overlay
	var/ringer = TRUE
	var/ringing = FALSE
	var/chosen_department //department we want to call
	var/obj/landline/calling = null	//landline we are in a call with
	var/last_call_log
	var/attached_to
	var/ringtone = 'sound/items/telephone_ring.ogg'

/obj/landline/New(var/A)
	attached_to = A
	linked_phone = new /obj/item/telephone (src)
	linked_phone.linked_landline = src
	phone = linked_phone
	
	phone_overlay = image(icon = 'icons/obj/terminals.dmi', icon_state = "phone_overlay")
	attached_to.overlays.Add(phone_overlay) //TODO make this less shit
	
/obj/landline/proc/start_call(var/obj/landline/destination)
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
				//TODO source add phonelog ("you hung up")
				return
			destination.ring()
			sleep(5 SECONDS)

/obj/landline/proc/ring()
	if(!linked_phone)
		return
	if(!attached_to)
		return
	if(ringer)
		playsound(source=attached_to.loc, soundin=ringtone, vol=100, vary=FALSE, channel=CHANNEL_TELEPHONES)
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
	ringing = FALSE
	//TODO add phonelog "picked up"
	user.put_in_hands(src.phone)
	phone = null //do not delete phone
	playsound(source=src, soundin= phone.pickup_sound, vol=100, vary=TRUE, channel=CHANNEL_TELEPHONES, wait=0)
	attached_to.overlays.Remove(phone_overlay)

/obj/landline/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(phone)
		to_chat(user, "<span class='notice'>There is already a telephone on the hook.</span>")
		return
	if(!user.drop_item(O))
		to_chat(user, "<span class='warning'>It's stuck to your hand!</span>")
		return
	if(calling)
		//TODO add phonelog ("call end")
		calling.calling = null
		calling = null
	
	user.visible_message("<span class='notice'>[user] puts \the [O] onto \the [src].</span>")
	playsound(source=O, soundin=O.pickup_sound, vol=100, vary=TRUE, channel=0)
	phone = O
	O.forceMove(src)
	attached_to.overlays.Add(phone_overlay)
	
	
	
	
	
	
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
	
/obj/item/telephone/Hear(var/datum/speech/speech, var/rendered_speech="")
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
	lastmsg = speech
	speech.name += "(Telephone)"
	var/obj/item/telephone/speaker = linked_landline.calling.linked_phone
	speaker.send_speech(speech, speaker.speaker_range, bubble_type = "")