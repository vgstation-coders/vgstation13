
//TODO: For a supposed "helper datum", this is not very helpful.
//It obscures and complicates this code without any good reason.
//Not that that's strange for code that hasn't been touched in 4
//years or so, but this file needs to be taken to the woodshed.

//wrapper
/proc/do_teleport(ateleatom, adestination, aprecision=0, afteleport=1, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null)
	new /datum/teleport/instant/science(arglist(args))
	return

/datum/teleport
	var/atom/movable/teleatom //atom to teleport
	var/atom/destination //destination to teleport to
	var/precision = 0 //teleport precision
	var/datum/effect/effect/system/effectin //effect to show right before teleportation
	var/datum/effect/effect/system/effectout //effect to show right after teleportation
	var/soundin //soundfile to play before teleportation
	var/soundout //soundfile to play after teleportation
	var/force_teleport = 1 //if false, teleport will use Move() proc (dense objects will prevent teleportation)

/datum/teleport/New(ateleatom, adestination, aprecision=0, afteleport=1, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null)
	..()
	if(!initTeleport(arglist(args)))
		return 0
	return 1

/datum/teleport/proc/initTeleport(ateleatom,adestination,aprecision,afteleport,aeffectin,aeffectout,asoundin,asoundout)
	if(!setTeleatom(ateleatom))
		return 0
	if(!setDestination(adestination))
		return 0
	if(!setPrecision(aprecision))
		return 0
	setEffects(aeffectin,aeffectout)
	setForceTeleport(afteleport)
	setSounds(asoundin,asoundout)
	return 1

//must succeed
/datum/teleport/proc/setPrecision(aprecision)
	if(isnum(aprecision))
		precision = aprecision
		return 1
	return 0

//must succeed
/datum/teleport/proc/setDestination(atom/adestination)
	if(istype(adestination))
		destination = adestination
		return 1
	return 0

//must succeed in most cases
/datum/teleport/proc/setTeleatom(atom/movable/ateleatom)
	if(istype(ateleatom, /obj/effect) && !istype(ateleatom, /obj/effect/dummy/chameleon))
		del(ateleatom)
		return 0
	if(istype(ateleatom))
		teleatom = ateleatom
		return 1
	return 0

//custom effects must be properly set up first for instant-type teleports
//optional
/datum/teleport/proc/setEffects(datum/effect/effect/system/aeffectin=null,datum/effect/effect/system/aeffectout=null)
	effectin = istype(aeffectin) ? aeffectin : null
	effectout = istype(aeffectout) ? aeffectout : null
	return 1

//optional
/datum/teleport/proc/setForceTeleport(afteleport)
	force_teleport = afteleport
	return 1

//optional
/datum/teleport/proc/setSounds(asoundin=null,asoundout=null)
	soundin = isfile(asoundin) ? asoundin : null
	soundout = isfile(asoundout) ? asoundout : null
	return 1

//placeholder
/datum/teleport/proc/teleportChecks()
	return 1

/datum/teleport/proc/playSpecials(atom/location,datum/effect/effect/system/effect,sound)
	if(location)
		if(effect)
			effect.attach(location)
			effect.start()
		if(sound) playsound(location,sound,60,1)
	return

//do the monkey dance
/datum/teleport/proc/doTeleport()

	var/turf/destturf
	var/turf/curturf = get_turf(teleatom)
	var/area/destarea = get_area(destination)
	if(precision)
		var/list/posturfs = circlerangeturfs(destination,precision)
		destturf = safepick(posturfs)
	else
		destturf = get_turf(destination)

	if(!destturf || !curturf)
		return 0

	playSpecials(curturf,effectin,soundin)

	if(force_teleport)
		teleatom.forceMove(destturf)
		playSpecials(destturf,effectout,soundout)
	else
		if(teleatom.Move(destturf))
			playSpecials(destturf,effectout,soundout)

	destarea.Entered(teleatom)

	return 1

/datum/teleport/proc/teleport()
	if(teleportChecks())
		return doTeleport()
	return 0

/datum/teleport/instant //teleports when datum is created

/datum/teleport/instant/New(ateleatom, adestination, aprecision=0, afteleport=1, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null)
	if(..())
		teleport()
	return


/datum/teleport/instant/science

/datum/teleport/instant/science/setEffects(datum/effect/effect/system/aeffectin,datum/effect/effect/system/aeffectout)
	if(!aeffectin || !aeffectout)
		var/datum/effect/effect/system/spark_spread/aeffect = new
		aeffect.set_up(5, 1, teleatom)
		effectin = effectin || aeffect
		effectout = effectout || aeffect
		return 1
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
			MM << "<span class='danger'>The Bluespace interface on your Bag of Holding interferes with the teleport!</span>"
	return 1

/datum/teleport/instant/science/teleportChecks()
	if(istype(teleatom, /obj/item/weapon/disk/nuclear)) // Don't let nuke disks get teleported --NeoFite
		teleatom.visible_message("<span class='danger'>\The [teleatom] bounces off of the portal!</span>")
		return 0

	if(!isemptylist(teleatom.search_contents_for(/obj/item/weapon/disk/nuclear)))
		if(istype(teleatom, /mob/living))
			var/mob/living/MM = teleatom
			MM.visible_message("<span class='danger'>\The [MM] bounces off of the portal!</span>","<span class='danger'>Something you are carrying seems to be unable to pass through the portal. Better drop it if you want to go through.</span>")
		else
			teleatom.visible_message("<span class='danger'>\The [teleatom] bounces off of the portal!</span>")
		return 0

	var/datum/zLevel/zTarget = map.zLevels[destination.z]
	if(zTarget.teleJammed)
		if(teleatom) teleatom.visible_message("<span class='warning'>The Bag of Holding bounces off of the portal!</span>")
		return 0

	if(istype(teleatom, /mob/living))
		var/mob/living/MM = teleatom
		if(MM.locked_to_z && (destination.z != MM.locked_to_z))
			MM.visible_message(
				"<span class='warning'>[MM] bounces off the portal!</span>",
				"<span class='warning'>The portal seems blocked!</span>")
			return 0
	return 1
