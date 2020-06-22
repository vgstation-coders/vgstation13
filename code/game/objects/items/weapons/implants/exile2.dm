

/obj/item/weapon/implanter/exile
	name = "implanter-exile"

/obj/item/weapon/implanter/exile/New()
	src.imp = new /obj/item/weapon/implant/exile(src)
	..()
	update()
	return

/obj/item/weapon/implant/exile
	name = "exile"
	desc = "Prevents returning to where you were implanted."
	var/illegalZ = null
	var/mob/living/theExile = null
	var/siteOfImplant = null
	var/beingDeported = FALSE
	var/beenSpaced = FALSE
	var/disablePhrase = ""
	var/list/zlevels = list(STATION_Z, TELECOMM_Z, DERELICT_Z, ASTEROID_Z, SPACEPIRATE_Z)
	var/zBanishment_key

/obj/item/weapon/implant/exile/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Nanotrasen Employee Exile Implant<BR>
<b>Implant Details:</b> The host of this implant will be prevented from returning to the implant location.<BR>
<b>For non-permanent use a disable phrase may be assigned on application.<BR>"}
	return dat

/obj/item/weapon/implant/exile/implanted(mob/source, mob/user)
	theExile = source
	disablePhrase = stripped_input(user, "Choose phrase to disable:")
	var/list/replacechars = list("'" = "", "\"" = "", ">" = "", "<" = "", "(" = "", ")" = "")
	disablePhrase = sanitize_simple(disablePhrase, replacechars)
	addHear()
	illegalZ = theExile.z
	siteOfImplant = get_turf(theExile)
	zlevels -= illegalZ
	to_chat(theExile, "<span class='notice'>You shiver as you feel a weak, unsettling film surround you.</span>")
	zBanishment_key = theExile.on_moved.Add(src, "zBan")
	return 1

/obj/item/weapon/implant/exile/proc/zBan()
	var/turf/T = get_turf(src)
	switch(beenSpaced)
		if(FALSE)
			if(T.z != illegalZ)
				beenSpaced = TRUE
		if(TRUE)
			if((T.z == illegalZ) && (!beingDeported))
				beingDeported = TRUE
				teleDeport()

/obj/item/weapon/implant/exile/proc/teleDeport()
	to_chat(theExile, "<span class='notice'>Your insides churn and your skin tingles. Your [part] is emitting a low hum.</span>")
	spawn(10 SECONDS)
		var/turf/T = get_turf(src)
		if(T.z == illegalZ)
			var/warpZ = pick(zlevels)
			var/warpTo = locate(rand(5,world.maxx - 10), rand(5, world.maxy - 10), warpZ)
			var/W = get_turf(warpTo)
			if(!istype(W, /turf/space))
				to_chat(theExile, "<span class='notice'>Your [part] buzzes. The tingling stops.</span>")
				sleep(3 SECONDS)
				beingDeported = FALSE
				return
			do_teleport(theExile, warpTo, 1)
			theExile.Knockdown(3)
			theExile.Stun(3)
			theExile.adjustBruteLoss(rand(0,5))
			theExile.adjustCloneLoss(rand(0,5)) //Uh oh it missed a few chromosomes
		else
			to_chat(theExile, "<span class='notice'>Your [part] emits a feint chime. The tingling stops.</span>")
		beingDeported = FALSE

/obj/item/weapon/implant/exile/emp_act()
	if(malfunction)
		return
	malfunction = 1
	var/mob/living/M = imp_in
	#define FREEDOM 1
	#define RANDOM_TELEPORT 2
	#define IMPLANTED_SITE_PORT 3
	switch(pick(1,2,3))
		if(FREEDOM)
			freeFromExile()
		if(RANDOM_TELEPORT)
			var/empLoc = locate(rand(5,world.maxx - 10), rand(5, world.maxy - 10), pick(zlevels))
			var/W = get_turf(empLoc)
			if(!istype(W, /turf/space))
				empLoc = siteOfImplant
			do_teleport(M, empLoc, 20)
			M.Knockdown(3)
			M.Stun(3)
		if(IMPLANTED_SITE_PORT)
			do_teleport(M, siteOfImplant, 20)
			M.Knockdown(3)
			M.Stun(3)
	spawn(20)
		malfunction--

/obj/item/weapon/implant/exile/Hear(var/datum/speech/speech, var/rendered_speech="")
	hear(speech.message)
	return

/obj/item/weapon/implant/exile/hear(var/msg)
	var/list/replacechars = list("'" = "", "\"" = "", ">" = "", "<" = "", "(" = "", ")" = "")
	msg = sanitize_simple(msg, replacechars)
	if(findtext(msg, disablePhrase))
		freeFromExile()

/obj/item/weapon/implant/exile/proc/freeFromExile(var/mob/living/M)
	M = imp_in
	playsound(M, "sound/machines/notify.ogg", 100, 1)
	to_chat(M, "<span class='notice'>You feel a sudden shooting pain. The film-like sensation fades. Your implant has jaunted out of your body.</span>" )
	imp_in = null
	theExile.on_moved.Remove(zBanishment_key)
	src.forceMove(siteOfImplant)

/obj/item/weapon/implantcase/exile
	name = "Glass Case- 'Exile'"
	desc = "A case containing an exile implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"


/obj/item/weapon/implantcase/exile/New()
	src.imp = new /obj/item/weapon/implant/exile( src )
	..()
	return

/obj/structure/closet/secure_closet/exile
	name = "Exile Implants"
	req_access = list(access_armory)

/obj/structure/closet/secure_closet/exile/atoms_to_spawn()
	return list(
		/obj/item/weapon/storage/lockbox/exile = 2
	)
