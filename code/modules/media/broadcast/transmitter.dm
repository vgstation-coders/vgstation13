var/global/media_transmitters=list()

///////////////////////
// BROADCASTERS
///////////////////////

/obj/machinery/media/transmitter
	var/media_frequency = 1234 // 123.4 MHz
	var/media_crypto    = null // No crypto keys.

/obj/machinery/media/transmitter/New()
	..()
	connect_frequency()

/obj/machinery/media/transmitter/proc/broadcast(var/url="", var/start_time=0, var/finish_time=0, var/datum/song_info/song_info=null)
	media_url = url
	media_start_time = start_time
	media_finish_time = finish_time
	current_song_info = song_info
	update_music()

/obj/machinery/media/transmitter/proc/connect_frequency()
	var/list/transmitters=list()
	var/freq = num2text(media_frequency)
	if(freq in media_transmitters)
		transmitters = media_transmitters[freq]
	transmitters.Add(src)
	media_transmitters[freq]=transmitters
	update_music()

/obj/machinery/media/transmitter/update_music()
	//..()
	var/freq = num2text(media_frequency)
	if(freq in media_receivers)
		for(var/obj/machinery/media/receiver/R in media_receivers[freq])
			if(R.media_crypto == media_crypto)
				R.receive_broadcast(media_url,media_start_time,media_finish_time,current_song_info)
				//testing("[src]: Sending music to [R]")
		for(var/mob/living/carbon/complex/gondola/radio/G in media_receivers[freq])
			if(G.media_crypto == media_crypto)
				G.receive_broadcast(media_url,media_start_time,media_finish_time)

/obj/machinery/media/transmitter/proc/clear_music()
	var/freq = num2text(media_frequency)
	if(freq in media_receivers)
		for(var/obj/machinery/media/receiver/R in media_receivers[freq])
			if(R.media_crypto == media_crypto)
				R.receive_broadcast()
		for(var/mob/living/carbon/complex/gondola/radio/G in media_receivers[freq])
			if(G.media_crypto == media_crypto)
				G.receive_broadcast()

/obj/machinery/media/transmitter/proc/disconnect_frequency()
	var/list/transmitters=list()
	var/freq = num2text(media_frequency)
	if(freq in media_transmitters)
		transmitters = media_transmitters[freq]
	transmitters.Remove(src)
	media_transmitters[freq]=transmitters
	clear_music()
