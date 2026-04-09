
/obj/item/weapon/implanter/exile
	name = "implanter-exile"
	imp_type = /obj/item/weapon/implant/exile

/obj/item/weapon/implant/exile
	name = "exile"
	desc = "Prevents returning to where you were implanted."
	var/illegalV = null
	var/turf/siteOfImplant = null
	var/beingDeported = FALSE
	var/beenSpaced = FALSE
	var/disablePhrase = ""
	var/list/vlevels = list()

/obj/item/weapon/implant/exile/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Nanotrasen Employee Exile Implant<BR>
<b>Implant Details:</b> The host of this implant will be prevented from returning to the implant location.<BR>
<b>For non-permanent use a disable phrase may be assigned on application.<BR>"}

/obj/item/weapon/implant/exile/implanted(mob/implanter)
	..()
	if(!vlevels.len)
		vlevels = map.vLevels.Copy()
		for(var/datum/virtual_z/vz in vlevels)
			if(vz.teleJammed == VZ_TELEPORTATION_FORBIDDEN || vz.level_type == VZ_TRANSIT || vz.level_type == VZ_PARKING || vz.level_type == VZ_PROTECTED) // Can't visit protected areas but can still end up on a planet or space area
				vlevels.Remove(vz)
	disablePhrase = stripped_input(implanter, "Choose a phrase that disables the implant:")
	var/list/replacechars = list("'" = "", "\"" = "", ">" = "", "<" = "", "(" = "", ")" = "")
	disablePhrase = sanitize_simple(disablePhrase, replacechars)
	addHear()
	siteOfImplant = get_turf(imp_in)
	illegalV = siteOfImplant.get_virtual_z()
	vlevels -= illegalV
	to_chat(imp_in, "<span class='notice'>You shiver as you feel a weak, unsettling film surround you.</span>")
	imp_in.register_event(/event/moved, src, nameof(src::zBan()))

/obj/item/weapon/implant/exile/proc/zBan(atom/movable/mover)
	var/turf/T = get_turf(src)
	var/datum/virtual_z/vz = T.get_virtual_z()
	if(!beenSpaced)
		if(vz != illegalV)
			beenSpaced = TRUE
	else if((vz == illegalV) && (!beingDeported))
		beingDeported = TRUE
		teleDeport()

/obj/item/weapon/implant/exile/proc/teleDeport()
	to_chat(imp_in, "<span class='notice'>Your insides churn and your skin tingles. Something inside your body is emitting a low hum.</span>")
	spawn(10 SECONDS)
		var/turf/T = get_turf(src)
		var/datum/virtual_z/vz = T.get_virtual_z()
		if(vz == illegalV)
			var/datum/virtual_z/warpV = pick(vlevels)
			var/x_low = warpV.x_min + ceil(warpV.size_x / 10)
			var/y_low = warpV.y_min + ceil(warpV.size_y / 10)
			var/x_high = warpV.x_max - ceil(warpV.size_x / 10)
			var/y_high = warpV.y_max - ceil(warpV.size_y / 10)
			var/warpZ = warpV.z()
			var/turf/warpTo = locate(rand(x_low,x_high), rand(y_low,y_high), warpZ)
			do_teleport(imp_in, warpTo, 1)
			imp_in.Knockdown(3)
			imp_in.Stun(3)
			imp_in.adjustBruteLoss(rand(0,5))
			imp_in.adjustCloneLoss(rand(0,5)) //Uh oh it missed a few chromosomes
		else
			to_chat(imp_in, "<span class='notice'>Something inside your body emits a feint chime. The tingling stops.</span>")
		beingDeported = FALSE

/obj/item/weapon/implant/exile/emp_act()
	if(malfunction)
		return
	malfunction = 1
	#define FREEDOM 1
	#define RANDOM_TELEPORT 2
	#define IMPLANTED_SITE_PORT 3
	switch(pick(FREEDOM,RANDOM_TELEPORT,IMPLANTED_SITE_PORT))
		if(FREEDOM)
			freeFromExile()
		if(RANDOM_TELEPORT)
			var/datum/virtual_z/warpV = pick(vlevels)
			var/x_low = warpV.x_min + ceil(warpV.size_x / 10)
			var/y_low = warpV.y_min + ceil(warpV.size_y / 10)
			var/x_high = warpV.x_max - ceil(warpV.size_x / 10)
			var/y_high = warpV.y_max - ceil(warpV.size_y / 10)
			var/warpZ = warpV.z()
			var/turf/empLoc = locate(rand(x_low,x_high), rand(y_low,y_high), warpZ)
			var/W = get_turf(empLoc)
			if(!istype(W, /turf/space))
				empLoc = siteOfImplant
			do_teleport(imp_in, empLoc, 20)
			imp_in.Knockdown(3)
			imp_in.Stun(3)
		if(IMPLANTED_SITE_PORT)
			do_teleport(imp_in, siteOfImplant, 20)
			imp_in.Knockdown(3)
			imp_in.Stun(3)
	spawn(20)
		malfunction = 0
	#undef FREEDOM
	#undef RANDOM_TELEPORT
	#undef IMPLANTED_SITE_PORT


/obj/item/weapon/implant/exile/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(!disablePhrase)
		return
	var/static/list/replacechars = list("'" = "", "\"" = "", ">" = "", "<" = "", "(" = "", ")" = "")
	var/msg = sanitize_simple(speech.message, replacechars)
	if(findtext(msg, disablePhrase))
		freeFromExile()

/obj/item/weapon/implant/exile/proc/freeFromExile()
	playsound(imp_in, "sound/machines/notify.ogg", 100, 1)
	to_chat(imp_in, "<span class='notice'>You feel a sudden shooting pain. The film-like sensation fades. Your implant has jaunted out of your body.</span>" )
	imp_in.unregister_event(/event/moved, src, nameof(src::zBan()))
	src.forceMove(siteOfImplant)
	imp_in = null

/obj/item/weapon/implantcase/exile
	name = "glass case 'Exile'"
	desc = "A case containing an exile implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"


/obj/item/weapon/implantcase/exile/New()
	imp = new /obj/item/weapon/implant/exile(src)
	..()

/obj/structure/closet/secure_closet/exile
	name = "exile implants closet"
	req_access = list(access_armory)

/obj/structure/closet/secure_closet/exile/atoms_to_spawn()
	return list(
		/obj/item/weapon/storage/lockbox/exile = 2
	)
