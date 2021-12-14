//wrapper
/proc/do_teleport(ateleatom, adestination, aprecision=FALSE, afteleport=TRUE, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null, aijamming=FALSE)
	if (isobserver(ateleatom)) // ghosts teleport without making sounds nor sparks
		new /datum/teleport/instant(ateleatom, adestination, aprecision, afteleport, aeffectin, aeffectout, null, null, aijamming)
	else
		new /datum/teleport/instant/science(arglist(args))
	return

/datum/teleport
	var/atom/movable/teleatom //atom to teleport
	var/atom/destination //destination to teleport to
	var/precision = FALSE //teleport precision
	var/datum/effect/system/effectin //effect to show right before teleportation
	var/datum/effect/system/effectout //effect to show right after teleportation
	var/soundin //soundfile to play before teleportation
	var/soundout //soundfile to play after teleportation
	var/force_teleport = TRUE //if false, teleport will use Move() proc (dense objects will prevent teleportation)
	var/ignore_jamming = FALSE//if true, teleport will ignore area jamming


/datum/teleport/New(ateleatom, adestination, aprecision=FALSE, afteleport=TRUE, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null, aijamming=FALSE)
	..()
	if(!Init(arglist(args)))
		return FALSE
	return TRUE

/datum/teleport/proc/Init(ateleatom,adestination,aprecision,afteleport,aeffectin,aeffectout,asoundin,asoundout,aijamming)
	if(!setTeleatom(ateleatom))
		return FALSE
	if(!setDestination(adestination))
		return FALSE
	if(!setPrecision(aprecision))
		return FALSE
	var/turf/T = get_turf(adestination)
	log_debug("TELEPORTATION: ateleatom: [ateleatom], adestination: [adestination][T ? "([T.x],[T.y],[T.z])" : ""]")
	setEffects(aeffectin,aeffectout)
	setForceTeleport(afteleport)
	setIgnoreJamming(aijamming)
	setSounds(asoundin,asoundout)
	return TRUE

	//must succeed
/datum/teleport/proc/setPrecision(aprecision)
	if(isnum(aprecision))
		precision = aprecision
		return TRUE
	return FALSE

	//must succeed
/datum/teleport/proc/setDestination(atom/adestination)
	if(istype(adestination))
		destination = adestination
		return TRUE
	return FALSE

	//must succeed in most cases
/datum/teleport/proc/setTeleatom(atom/movable/ateleatom)
	if(istype(ateleatom, /obj/effect) && !istype(ateleatom, /obj/effect/dummy/chameleon))
		qdel(ateleatom)
		return FALSE
	if(istype(ateleatom, /atom/movable/light))
		return FALSE
	if(istype(ateleatom))
		teleatom = ateleatom
		return TRUE
	return FALSE

	//custom effects must be properly set up first for instant-type teleports
	//optional
/datum/teleport/proc/setEffects(datum/effect/system/aeffectin=null,datum/effect/system/aeffectout=null)
	effectin = istype(aeffectin) ? aeffectin : null
	effectout = istype(aeffectout) ? aeffectout : null
	return TRUE

	//optional
/datum/teleport/proc/setForceTeleport(afteleport)
	force_teleport = afteleport
	return TRUE

	//optional
/datum/teleport/proc/setIgnoreJamming(aijamming)
	ignore_jamming = aijamming
	return TRUE

	//optional
/datum/teleport/proc/setSounds(asoundin=null,asoundout=null)
	soundin = isfile(asoundin) ? asoundin : null
	soundout = isfile(asoundout) ? asoundout : null
	return TRUE

	//placeholder
/datum/teleport/proc/teleportChecks()
	return TRUE

/datum/teleport/proc/playSpecials(atom/location,datum/effect/system/effect,sound)
	if(location)
		if(effect)
			spawn(-1)
				src = null
				effect.attach(location)
				effect.start()
		if(sound)
			spawn(-1)
				src = null
				playsound(location,sound,60,1)
	return

/datum/teleport/proc/isValidTurf(turf/T)
	if(istype(T, /turf/unsimulated/wall/supermatter))
		return FALSE //Don't teleport into supermatter turfs

	return TRUE

	//do the monkey dance
/datum/teleport/proc/doTeleport()
	var/turf/destturf
	var/turf/curturf = get_turf(teleatom)
	var/area/destarea = get_area(destination)
	if(precision)
		var/list/posturfs = circlerangeturfs(destination,precision)
		if(!posturfs || !posturfs.len)
			return FALSE

		do
			destturf = pick_n_take(posturfs)
		while(!isValidTurf(destturf) && posturfs.len)
	else
		destturf = get_turf(destination)

	if(!destturf || !curturf)
		return FALSE

	playSpecials(curturf,effectin,soundin)
	if (!isobserver(teleatom))
		teleatom.unlock_from()

	if(istype(teleatom,/obj/item/projectile))
		var/Xchange = destturf.x - curturf.x
		var/Ychange = destturf.y - curturf.y
		var/obj/item/projectile/P = teleatom
		P.override_starting_X += Xchange
		P.override_starting_Y += Ychange
		P.override_target_X += Xchange
		P.override_target_Y += Ychange
		P.reflected = TRUE//you can now get hit by the projectile you just fired. Careful with portals!

	if(curturf.z != destturf.z)
		INVOKE_EVENT(teleatom, /event/z_transition, "user" = teleatom, "from_z" = curturf.z, "to_z" = destturf.z)
		for(var/atom/movable/AA in recursive_type_check(teleatom))
			INVOKE_EVENT(AA, /event/z_transition, "user" = AA, "from_z" = curturf.z, "to_z" = destturf.z)

	if(force_teleport)
		teleatom.forceMove(destturf, from_tp = TRUE)
		playSpecials(destturf,effectout,soundout)
	else
		if(teleatom.Move(destturf))
			playSpecials(destturf,effectout,soundout)

	teleatom.reset_inertia() //Prevent things from drifting immediately after getting teleported to space
	destarea.Entered(teleatom)

	return TRUE

/datum/teleport/proc/teleport()
	if(teleportChecks(ignore_jamming))
		return doTeleport()
	return FALSE

/datum/teleport/instant //teleports when datum is created

/datum/teleport/instant/New(ateleatom, adestination, aprecision=FALSE, afteleport=TRUE, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null)
	if(..())
		teleport()
	return


/datum/teleport/instant/science

/datum/teleport/instant/science/setEffects(datum/effect/system/aeffectin,datum/effect/system/aeffectout)
	if(!aeffectin || !aeffectout)
		//De-activated sparks by order of Pomf. Too easily exploited to create lag machines.
		/*
		var/datum/effect/system/spark_spread/aeffect = new
		aeffect.set_up(5, TRUE, teleatom)
		effectin = effectin || aeffect
		effectout = effectout || aeffect
		*/
		return TRUE
	else
		return ..()

/datum/teleport/instant/science/setPrecision(aprecision)
	..()
	if(istype(teleatom, /obj/item/weapon/storage/backpack/holding))
		precision = rand(1,100)

	var/list/bagholding = teleatom.search_contents_for(/obj/item/weapon/storage/backpack/holding)
	if(bagholding.len)
		precision = max(rand(1,100)*bagholding.len,100)
		if(istype(teleatom, /mob/living))
			var/mob/living/MM = teleatom
			to_chat(MM, "<span class='warning'>The Bluespace interface on your Bag of Holding interferes with the teleport!</span>")
	return TRUE

/datum/teleport/instant/science/teleportChecks(var/ignore_jamming = FALSE)
	if(istype(teleatom, /obj/effect/sparks)) // Don't teleport sparks or the server dies
		return FALSE

	if(istype(teleatom, /obj/item/weapon/disk/nuclear)) // Don't let nuke disks get teleported --NeoFite
		teleatom.visible_message("<span class='danger'>\The [teleatom] bounces off of the portal!</span>")
		return FALSE
	if(teleatom.locked_to)
		return FALSE

	if(!isemptylist(teleatom.search_contents_for(/obj/item/weapon/disk/nuclear)))
		if(istype(teleatom, /mob/living))
			var/mob/living/MM = teleatom
			MM.visible_message("<span class='danger'>\The [MM] bounces off of the portal!</span>","<span class='warning'>Something you are carrying seems to be unable to pass through the portal. Better drop it if you want to go through.</span>")
		else
			teleatom.visible_message("<span class='danger'>\The [teleatom] bounces off of the portal!</span>")
		return FALSE

	if(destination.z == map.zCentcomm) //centcomm z-level
		if(istype(teleatom, /obj/mecha) && (universe.name != "Supermatter Cascade"))
			var/obj/mecha/MM = teleatom
			to_chat(MM.occupant, "<span class='danger'>The mech would not survive the jump to a location so far away!</span>")//seriously though, why? who wrote that?

			return FALSE
		if(!isemptylist(teleatom.search_contents_for(/obj/item/weapon/storage/backpack/holding)))
			teleatom.visible_message("<span class='danger'>The Bag of Holding bounces off of the portal!</span>")
			return FALSE

	var/datum/zLevel/L = get_z_level(destination)
	if (L.teleJammed && !ignore_jamming)
		return FALSE

	for (var/mob/M in recursive_type_check(teleatom, /mob))
		if(istype(M,/mob/living/carbon/human)) //Tinfoil hats resist teleportation, but only when worn
			var/mob/living/carbon/human/H = M
			if(H.head && istype(H.head,/obj/item/clothing/head/tinfoil))
				to_chat(H, "<span class'info'>Your headgear has 'foiled' a teleport!</span>")
				return FALSE

		if(istype(M, /mob/living))
			var/mob/living/MM = M
			if(MM.locked_to_z != FALSE && destination.z != MM.locked_to_z)
				MM.visible_message("<span class='danger'>\The [teleatom] bounces off the portal!</span>", "<span class='warning'>You're unable to go to that destination!</span>")
				return FALSE

	return TRUE
