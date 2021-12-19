/obj/structure/cage/fish_trap
	name = "fish trap"
	desc = ""
	icon = ''
	icon_state = ""
	density = 0
	var/datum/anglerCatch/trappedDatum = null
	var/trappedCatch = null
	var/item/weapon/bait/heldBait = null
	var/adjustedAttraction = 0	//Exists to save re-calculating every tick
	var/adjustedSalvtraction = 0
	var/item/device/gps/attachedGPS = null

/obj/structure/cage/fish_trap/New()
	..()
	processing_objects.Add(src)

/obj/structure/cage/fish_trap/Destroy()
	processing_objects.Remove(src)
	..()

/obj/structure/cage/fish_trap/examine(var/mob/user)
	to_chat(user, "<span class='info'>.</span>") //add thing for bait left/type, and if it contains something. Do a 1 line if thing.

/obj/structure/cage/fish_trap/toggle_door(mob/user)
	if(door_state == C_OPENED)
		if(trappedDatum)
			trappedDatum = null
		if(trappedCatch)
			trappedCatch.forceMove(get_turf(src))
			trappedCatch = null

/obj/structure/cage/fish_trap/attackby(obj/item/W, mob/user)
	..()
	if(isbait(W))
		baitTheTrap(W, user)
	if(istype(W, /obj/item/device/gps))
		trackTheTrap(W, user)
	if(iscrowbar(W) || W.is_screwdriver())
		if(attachedGPS)
			attachedGPS.forceMove(src.loc)
			to_chat(user, "<span class='info'>You use \the [W] to remove \the [attachedGPS].</span>")
			attachedGPS = null

/obj/structure/cage/fish_trap/proc/baitTheTrap(var/obj/item/weapon/bait/baitUsed, mob/user)
	if(heldBait)
		heldBait.forceMove(loc)
		if(user.find_empty_hand_index())
			user.put_in_hands(heldBait)
		to_chat(user, "<span class='info'>You remove \the [heldBait] from \the [src].</span>")
		heldBait = null
	if(user.drop_item(baitUsed))
		heldBait = baitUsed
		heldBait.forceMove(src)
		to_chat(user, "<span class='info'>You insert \the [heldBait] into \the [src].</span>")
		adjustBaitAttraction()

/obj/structure/cage/fish_trap/proc/adjustBaitAttraction()
	adjustedAttraction = round(1, heldBait.catchAttraction/4)
	adjustedSalvtraction = round(1, heldBait.salvageAttraction/4)

/obj/structure/cage/fish_trap/proc/trackTheTrap(var/obj/item/device/gps/fishPS, mob/user)
	if(attachedGPS)
		to_chat(user, "<span class='info'>The [src] already has an attached [fishPS].</span>")
		return
	if(user.drop_item(fishPS))
		fishPS.forcemove(src)
		attachedGPS = fishPS


/obj/structure/cage/fish_trap/process()
	if(!heldBait)
		return
	if(trappedCatch)
		nibbleInTrap()
	if(!trappedCatch && door_state == C_OPENED)	//I think this should be trappedDatum to avoid multiple catches?
		attemptTrapCatch()

/obj/structure/cage/fish_trap/proc/attemptTrapCatch()
	if(prob(adjustedAttraction))
		trappedDatum = anglerFishCalc(baitUsed, loc.Z)
	else if(prob(adjustedSalvtraction))
		trappedDatum = anglerSalvCalc(baitUsed, loc.Z)
	if(trappedDatum)
		toggle_door()
		handleTrapCatch(trappedDatum)

/obj/structure/cage/fish_trap/proc/nibbleInTrap()
	if(prob(heldBait.catchAttraction * 2))	//Not adjusted value
		eatBait()

/obj/structure/cage/fish_trap/proc/eatBait()
	heldBait.portionSize = min(0, heldBait.portionSize - trappedDatum.portionConsume)
	if(!heldBait.portionSize)
		qdel(heldBait)
		heldBait = null

/obj/structure/cage/fish_trap/proc/handleTrapCatch()
	trappedCatch = new trappedDatum.theCatch(src.loc)
	switch(trappedDatum.typeOfCatch)
		if(MOBFISHCATCH)
			catchMobFish(trappedCatch, heldBait)
			add_mob(trappedCatch)
		if(ITEMFISHCATCH)
			var/obj/iFish = trappedCatch
			iFish.angler_effect(heldBait)
	if(!ismob(trappedCatch))
		trappedCatch.forceMove(src)


/obj/structure/cage/fish_trap/syndicate
	var/theMostDangerousGame = TRUE

/obj/structure/cage/fish_trap/syndicate/Crossed(AM)
	if(door_state == C_CLOSED)
		return
	if(ishuman(AM) && theMostDangerousGame)
		toggle_door()

/obj/structure/cage/fish_trap/syndicate/kick_act()
	theMostDangerousGame = !theMostDangerousGame
