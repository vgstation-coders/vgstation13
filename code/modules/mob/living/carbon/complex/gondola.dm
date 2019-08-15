/mob/living/carbon/complex/gondola
	name = "gondola"
	desc = "A calming presence in this strange land."
	icon = 'icons/mob/gondola.dmi'

	icon_state_standing = "gondola"
	icon_state_lying = "gondola_lying"
	icon_state_dead = "gondola_dead"

	maxHealth = 75
	health = 75

	held_items = list()

	size = SIZE_NORMAL
	status_flags = CANSTUN|CANKNOCKDOWN|CANPARALYSE|CANPUSH
	mob_bump_flag = HUMAN
	mob_push_flags = ALLMOBS
	mob_swap_flags = ALLMOBS

/mob/living/carbon/complex/gondola/New()
	icon_state_standing = pick("gondola","gondola_2")
	icon_state_lying = "[icon_state_standing]_lying"
	icon_state_dead = "[icon_state_dead]_dead"
	..()

/mob/living/carbon/complex/gondola/say()
	return

//Basically walking media receivers
/mob/living/carbon/complex/gondola/radio
	var/playing=0
	var/media_url=""
	var/media_start_time=0
	var/area/master_area
	var/media_frequency = 1234 // 123.4 MHz
	var/media_crypto    = null // Crypto key

	var/list/obj/machinery/media/transmitter/hooked = list()
	var/exclusive_hook=null // Disables output to the room

/mob/living/carbon/complex/gondola/radio/New()
	..()
	connect_frequency()

/mob/living/carbon/complex/gondola/radio/death(var/gibbed = FALSE)
	disconnect_media_source()
	..(gibbed)

/mob/living/carbon/complex/gondola/radio/area_entered()
	update_music()

/mob/living/carbon/complex/gondola/radio/proc/connect_frequency()
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

/mob/living/carbon/complex/gondola/radio/proc/receive_broadcast(var/url="", var/start_time=0)
	media_url = url
	media_start_time = start_time
	update_music()

/mob/living/carbon/complex/gondola/radio/proc/disconnect_frequency()
	var/list/receivers=list()
	var/freq = num2text(media_frequency)
	if(freq in media_receivers)
		receivers = media_receivers[freq]
	receivers.Remove(src)
	media_receivers[freq]=receivers

	receive_broadcast()

/mob/living/carbon/complex/gondola/radio/update_music()
	if(isDead(src))
		return
	// Broadcasting shit
	for(var/obj/machinery/media/transmitter/T in hooked)
//		testing("[src] Writing media to [T].")
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

/mob/living/carbon/complex/gondola/radio/proc/update_media_source()
	var/area/A = get_area(src)
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


/mob/living/carbon/complex/gondola/radio/proc/disconnect_media_source()
	var/area/A = get_area(src)

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
