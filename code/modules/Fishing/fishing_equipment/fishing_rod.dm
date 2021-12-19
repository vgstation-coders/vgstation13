#define NOTCAST = 0
#define BEENCAST = 1
#define REELING = 3
#define BITEONHOOK = 4

/obj/item/weapon/fishingRod
	name = "space fishing rod"
	desc = "A rod specifically designed for fishing in space. The result is one part fishing rod, one part salvage tech."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fishing_rod_basic"
	item_state = "fishing_rod_basic"
	throwforce = 1
	force = 2
	mech_flags = null
	var/obj/item/spaceFishHook/fHook = null
	var/item/bait/baitType = null
	//var/fishingBonus = 0
	var/tugCooldown = 5 SECONDS
	var/lastTug = 0
	var/cast_force = 3
	var/list/cast_force_amounts = list(1, 2, 5, 10, 16)	//Very slow, slow, moderate, quick, mass driver
	var/castState = NOTCAST

	var/scanTier = 0
	var/hookTier = 0
	var/lineTier = 0

/obj/item/weapon/fishingRod/New()
	/obj/item/spaceFishHook/fHook = new /obj/item/spaceFishHook(src)
	fHook.fRod = src

/obj/item/weapon/fishingRod/verb/set_castForce()
	set name = "Set cast force"
	set category = "Object"
	set src in range(0)
	var/cF = input ("Force to use when casting:", "[src]") as null|anything in cast_force_amounts
	if(cF)
		cast_force = cF	//Used for cast throw_speed, for reference paper has a throw_speed of 1, a boomerang is 5

/obj/item/weapon/fishingRod/attackby(obj/item/weapon/bait/B, mob/user)
	if(isbait(B))
		if(user.drop_item(B, src))
			fHook.baitType = B

/obj/item/weapon/fishingRod/preattack(atom/target, mob/user)
//	if(clumsy_check(user))
//		if(prob(50))
//			make their pants come off or something
	switch(castState)
		if(NOTCAST)
			castTheLine(target)
		if(BEENCAST)
			fHook.reelIn()

/obj/item/weapon/fishingRod/attack_self(mob/user)
	switch(castState)
		if(NOTCAST)
			fHook.removeBait()
		if(BEENCAST)
			tugTheLine()
		if(REELING)

		if(BITEONHOOK)
			fHook.reelBite()

/obj/item/weapon/fishingRod/proc/castTheLine(target)
	castState = BEENCAST
	fHook.forceMove(get_turf(src))
	fHook.throw_at(target, 8, cast_force)
	fHook.castProcess()
	user.delayNextAttack(10)

/obj/item/weapon/fishingRod/proc/tugTheLine()
	if(world.time - lastTug >= tugCooldown)
		to_chat(user, "<span class='info'>You tug at the line.</span>")
		lastTug = world.time
		fHook.tugBait()
	else
		to_chat(user, "<span class='info'>You must wait longer between tugs.</span>")

/obj/item/weapon/fishingRod/proc/alertAngler()
	var/mob/living/user = null
	if(isliving(loc))
		user = loc
	if(!user)
		return
	switch(scanTier)	//to-do: find appropriate span class style
		if(1)
			to_chat(user, "<span class='info'>\The [src] chimes loudly.</span>")
		if(2)
			to_chat(user, "<span class='info'>\The [src] .</span>")



/obj/item/spaceFishHook
	name = "space fishing hook"
	desc = "Mostly called a hook for sake of tradition, this device is more similar to a net covered in a variety of tech."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fishing_hook_basic"
	item_state = "fishing_hook_basic"
	throwforce = 1
	force = 2
	mech_flags = MECH_SCAN_FAIL
	var/item/weapon/bait/baitType = null
	var/obj/item/weapon/fishingRod/fRod = null
	var/datum/anglerCatch/onHook
	var/theCatch = null

/obj/item/spaceFishHook/proc/castProcess()
	processing_objects.Add(src)

/obj/item/spaceFishHook/proc/removeBait(mob/user)
	if(!baitType)
		return
	to_chat(user, "You remove the [baitType] from the [src]")
	baitType.forceMove(src.loc)
	if(user.find_empty_hand_index())
		user.put_in_hands(baitType)
	baitType = null

//YOU ARE HERE///////////////

/obj/item/spaceFishHook/process()
	onHook = anglerCatchChance(baitType, loc.z)
	if(!onHook)
		return
	if(!canHookCheck())
		onHook = null
		return
	processing_objects.Remove(src)
	handleCatch()
	fRod.alertAngler()

/obj/item/spaceFishHook/proc/tugBait()
	forceMove(src.loc)	//Stops it from moving in space
	var/tugChance = baitType.catchChance()
	if(prob(tugChance += hookTierBonus()))
		catchOnHook()

/obj/item/spaceFishHook/proc/canHookCheck()
	var/turf/T = get_turf(src)
	if(!istype(T, /turf/space))
		return FALSE
	for(var/mob/living/carbon/scareTheFish in orange(4))
		return FALSE
	return TRUE

/obj/item/spaceFishHook/proc/handleCatch()
	switch(onHook.typeOfCatch)
		if(MOBFISHCATCH)













/obj/item/spaceFishHook/throw_impact(atom/hit_atom)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		H.knockdown(3)

/obj/item/weapon/storage/belt/fishingBelt
	name = "fishing belt"
	desc = ""
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fishing_belt"
	item_state = "fishing_belt"
	w_class = W_CLASS_LARGE
	storage_slots = 8
	fits_ignoring_w_class = list(
		"/obj/item/device/lightreplacer"
		)
	can_only_hold = list(
		"/obj/item/weapon/fishingRod"
	)

