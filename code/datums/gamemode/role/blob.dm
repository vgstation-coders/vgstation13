/datum/role/blob_overmind
	name = BLOBOVERMIND
	id = BLOBOVERMIND
	required_pref = BLOBOVERMIND
	logo_state = "blob-logo"
	greets = list(GREET_DEFAULT,GREET_CUSTOM)
	var/countdown = 60

/datum/role/blob_overmind/cerebrate
	name = BLOBCEREBRATE
	id = BLOBCEREBRATE
	logo_state = "cerebrate-logo"

/datum/role/blob_overmind/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id)
	..()
	wikiroute = role_wiki[BLOBOVERMIND]

/datum/role/blob_overmind/OnPostSetup()
	. = ..()
	AnnounceObjectives()

/datum/role/blob_overmind/process()
	..()
	if(!antag || istype(antag.current,/mob/camera/blob) || !antag.current || isobserver(antag.current))
		return
	if (countdown > 0)
		countdown--
		if (countdown == 59)
			to_chat(antag.current, "<span class='alert'>You feel tired and bloated.</span>")
		else if (countdown == 30)
			to_chat(antag.current, "<span class='alert'>You feel like you are about to burst.</span>")
		else if (countdown <= 0)
			burst()
	if (antag && antag.current.hud_used)
		if(antag.current.hud_used.countdown_display)
			antag.current.hud_used.countdown_display.overlays.len = 0
			var/first = round(countdown/10)
			var/second = countdown%10
			var/image/I1 = new('icons/obj/centcomm_stuff.dmi',src,"[first]",30)
			var/image/I2 = new('icons/obj/centcomm_stuff.dmi',src,"[second]",30)
			I1.pixel_x += 10 * PIXEL_MULTIPLIER
			I2.pixel_x += 17 * PIXEL_MULTIPLIER
			I1.pixel_y -= 11 * PIXEL_MULTIPLIER
			I2.pixel_y -= 11 * PIXEL_MULTIPLIER
			antag.current.hud_used.countdown_display.overlays += I1
			antag.current.hud_used.countdown_display.overlays += I2
		else
			antag.current.hud_used.countdown_hud()

/datum/role/blob_overmind/proc/burst()
	if(!antag || istype(antag.current,/mob/camera/blob))
		return

	var/client/blob_client = null
	var/turf/location = null

	if (faction)
		var/datum/faction/blob_conglomerate/the_bleb = faction
		the_bleb.declared = TRUE

	if(iscarbon(antag.current))
		var/mob/living/carbon/C = antag.current
		if(directory[ckey(antag.key)])
			blob_client = directory[ckey(antag.key)]
			location = get_turf(C)
			if(location.z != map.zMainStation || istype(location, /turf/space))
				location = null
			C.gib()

	if(blob_client && location)
		new /obj/effect/blob/core(location, 200, blob_client, 3)
	Drop()

/datum/role/blob_overmind/Greet(var/greeting,var/custom)
	if(!greeting || !antag || istype(antag.current,/mob/camera/blob))
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [custom]")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are infected by the Blob!</br></span>")
			to_chat(antag.current, "<span class='warning'>Your body is ready to give spawn to a new blob core which will eat this station.</span>")
			to_chat(antag.current, "<span class='warning'>Find a good location to spawn the core and then take control and overwhelm the station!</span>")
			to_chat(antag.current, "<span class='warning'>When you have found a location, wait until you spawn; this will happen automatically and you cannot speed up the process.</span>")
			to_chat(antag.current, "<span class='warning'>If you go outside of the station level, or in space, then you will die; make sure your location has lots of ground to cover.</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")