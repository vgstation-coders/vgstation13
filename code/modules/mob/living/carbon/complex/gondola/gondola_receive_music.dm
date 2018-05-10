//Basically walking media receivers
/mob/living/carbon/complex/gondola
	var/playing=0
	var/media_url=""
	var/media_start_time=0
	var/area/master_area
	var/media_frequency = 1234 // 123.4 MHz
	var/media_crypto    = null // Crypto key

	var/list/obj/machinery/media/transmitter/hooked = list()
	var/exclusive_hook=null // Disables output to the room

/mob/living/carbon/complex/gondola/New()
	..()
	connect_frequency()

/mob/living/carbon/complex/gondola/death(var/gibbed = FALSE)
	disconnect_media_source()
	..(gibbed)

/mob/living/carbon/complex/gondola/area_entered()
	update_music()

/mob/living/carbon/complex/gondola/proc/connect_frequency()
	// This is basically media_receivers["[media_frequency]"] += src
	var/list/receivers=list()
	var/freq = num2text(media_frequency)
	if(freq in media_receivers)
		receivers = media_receivers[freq]
	receivers.Add(src)
	media_receivers[freq]=receivers

	// Check if there's a broadcast to tune into.
	if(freq in media_transmitters)
		// Pick a random broadcast in that frequency.
		var/obj/machinery/media/transmitter/B = pick(media_transmitters[freq])
		if(B.media_crypto == media_crypto) // Crypto-key check, if needed.
			receive_broadcast(B.media_url,B.media_start_time)

/mob/living/carbon/complex/gondola/proc/receive_broadcast(var/url="", var/start_time=0)
	media_url = url
	media_start_time = start_time
	update_music()

/mob/living/carbon/complex/gondola/proc/disconnect_frequency()
	var/list/receivers=list()
	var/freq = num2text(media_frequency)
	if(freq in media_receivers)
		receivers = media_receivers[freq]
	receivers.Remove(src)
	media_receivers[freq]=receivers

	receive_broadcast()

/mob/living/carbon/complex/gondola/update_music()
	if(isDead(src))
		return
	// Broadcasting shit
	for(var/obj/machinery/media/transmitter/T in hooked)
		testing("[src] Writing media to [T].")
		T.broadcast(media_url,media_start_time)

	if(exclusive_hook)
		disconnect_media_source() // Just to be sure.
		return

	update_media_source()

	// Bail if we lost connection to master.
	if(!master_area)
		return

	// Send update to clients.
	for(var/mob/M in mobs_in_area(master_area))
		if(M == src)
			continue
		if(M && M.client)
			M.update_music()

	..()

/mob/living/carbon/complex/gondola/proc/update_media_source()
	var/area/A = get_area_master(src)
	if(!A)
		return
	// Check if there's a media source already.
	if(A.media_source && A.media_source!=src)	//if it does, the new media source replaces it. basically, the last media source arrived gets played on top.
		A.media_source.disconnect_media_source()//you can turn a media source off and on for it to come back on top.
		A.media_source=src
		master_area=A
		return

	// Update Media Source.
	if(!A.media_source)
		A.media_source=src

	master_area=A


/mob/living/carbon/complex/gondola/proc/disconnect_media_source()
	var/area/A = get_area_master(src)

	// Sanity
	if(!A)
		master_area=null
		return

	// Check if there's a media source already.
	if(A && A.media_source && A.media_source!=src)
		master_area=null
		return

	// Update Media Source.
	A.media_source=null

	// Clients
	for(var/mob/M in mobs_in_area(A))
		if(M && M.client)
			M.update_music()
	master_area=null