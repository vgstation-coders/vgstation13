/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly. Hold in hand to use."
	icon_state = "megaphone"
	item_state = "radio"
	w_class = W_CLASS_TINY
	flags = FPRINT
	siemens_coefficient = 1

	var/spamcheck = 0
	var/emagged = 0
	var/insults = 0
	var/list/insultmsgs = list("FUCK EVERYONE!", "I'M A TATER!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!")

	var/mask_voice = FALSE

/obj/item/device/megaphone/affect_speech(var/datum/speech/speech, var/mob/living/L)
	if(L.is_holding_item(src))
		speech.message_classes.Add("megaphone")
	if(emagged && insults)
		speech.message = pick(insultmsgs)
		insults--

/obj/item/device/megaphone/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		emagged = 1
		insults = rand(1, 3) //to prevent dickflooding
		return
	return

/obj/item/device/megaphone/madscientist
	name = "mad scientist megaphone"
	desc = "An ominous-sounding megaphone with a built-in radio transmitter and voice scrambler. Use in hand to fiddle with the controls."
	var/frequency = 0
	mask_voice = TRUE
	flags = FPRINT | HEAR

var/list/megaphone_channels = list("DISABLE" = 0) + stationchannels

/obj/item/device/megaphone/madscientist/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker != loc || speech.frequency || !src.frequency)
		return
	var/datum/speech/clone = speech.clone()
	clone.frequency = src.frequency
	clone.as_name = ""
	if(mask_voice)
		clone.name = "A distorted voice"
		clone.job = ""
	Broadcast_Message(clone, level = list(STATION_Z, ASTEROID_Z))
	to_chat(speech.speaker, "\The [src] [pick("creaks", "whines", "crackles", "whirrs", 1;"makes an odd static/popping noise that you kind of recognize as similar to a geiger counter", 1;"squeaks")] \
		as it transmits your voice into the set frequency...") //Since you may not be able to hear your own demands, some feedback that they're getting through

/obj/item/device/megaphone/madscientist/attack_self(mob/living/user as mob)
	show_ui(user)

/obj/item/device/megaphone/madscientist/proc/show_ui(mob/living/user as mob)
	var/dat = "<html><head><title>[src]</title></head><body><TT>"
	dat += {"
		Voice Scrambler: <a href="?src=\ref[src];voicescramble=1">[mask_voice ? "On" : "Off"]</a><BR>
		<BR>
		Broadcast To:<BR>
	"}
	for(var/index in megaphone_channels)
		if(frequency == megaphone_channels[index])
			dat += "[index]"
		else
			dat += "<a href='?src=\ref[src];setfreq=[megaphone_channels[index]]'>[index]</a>"
		dat += "<BR>"
	dat+={"</TT></body></html>"}
	user << browse(dat, "window=megaphone")
	onclose(user, "megaphone")

/obj/item/device/megaphone/madscientist/Topic(href,href_list)
	if(..())
		return 1
	if(!usr.is_holding_item(src))
		return

	if("voicescramble" in href_list)
		mask_voice = !mask_voice
	if("setfreq" in href_list)
		var/newfreq = text2num(href_list["setfreq"])
		//href sanity
		var/found = FALSE
		for(var/index in megaphone_channels)
			if(megaphone_channels[index] == newfreq)
				found = TRUE
				break
		if(!found)
			to_chat(usr, "That's odd. You swear that button used to be there just a second ago...")
			return

		frequency = newfreq

	show_ui(usr)
