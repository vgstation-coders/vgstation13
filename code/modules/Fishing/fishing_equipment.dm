/obj/item/weapon/fishingRod
	name = "space fishing rod"
	desc = "A rod specifically designed for fishing in space. The result is one part fishing rod, one part salvage tech."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fishing_rod_basic"
	item_state = "fishing_rod_basic"
	throwforce = 1
	force = 2
	mech_flags = null
	var/obj/item/spessFishHook/fHook = null
	var/item/bait/baitType = null
	var/fishingBonus = 0
	var/tugCooldown = 100 //10 seconds
	var/lineBeenCast = FALSE
	var/lastTug = 0

/obj/item/weapon/fishingRod/attackby(obj/item/i as obj, mob/user as mob)
	if(istype(i, obj/item/bait))
		if(user.drop_item(i))
			baitType = i
			qdel(i)

/obj/item/weapon/fishingRod/afterattack(atom/target, mob/user)
//	if(clumsy_check(user))
//		if(prob(50))
//			make their pants come off or something
	if(user.is_pacified())
		to_chat(user, "What a relaxing day for fishing.")
		fishingBonus++
	if(!lineBeenCast)
		if(baitType)
			fHook.baitType = baitType
		fHook = new /obj/item/spessFishHook(src.loc)
		fHook.fRod = src
		lineBeenCast = TRUE
		fHook.throw_at(target, 4, 15)
		user.delayNextAttack(10)
		return
	if(lineBeenCast)
		to_chat(user, "You tug at the line.")
		if(world.time - lastTug >= tugCooldown)
			fHook.tugBait()

/obj/item/weapon/fishingRod/attack_self(mob/user)
	if(lineBeenCast)
		fHook.reelIn()
		return
	if((!lineBeenCast)
		removeBait(user)

/obj/item/weapon/fishingRod/proc/removeBait(mob/user)
	if(!baitType)
		to_chat(user, "There's no bait on the rod")
		return
	to_chat(user, "You remove the [baitType] from the [src]")
	var/b = new baitType(src.loc)
	if(user.find_empty_hand_index())
		user.put_in_hands(b)
	baitType = null


/obj/item/spessFishHook
	name = "space fishing hook"
	desc = "Mostly called a hook for sake of tradition, this device is more similar to a net."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fishing_hook_basic"
	item_state = "fishing_hook_basic"
	throwforce = 1
	force = 2
	mech_flags = MECH_SCAN_FAIL
	var/baitType
	var/fishingBonus
	var/fRod = null

/obj/item/spessFishHook/New()
	processing_objects.Add(src)

/obj/item/spessFishHook/process()
	prob(1+fishingBonus)
		catchOnHook()

/obj/item/spessFishHook/proc/tugBait()
	prob(3*fishingBonus)
		catchOnHook()

/obj/item/spessFishHook/proc/catchOnHook()
	var/turf/T = get_turf(src)
	if(!istype(T, /turf/space))
		return
	var/fishZ = T.z
	switch(fishZ)
		if(STATION_Z)
		if(CENTCOMM_Z)
		if(TELECOMM_Z)
		if(DERELICT_Z)
		if(ASTEROID_Z)
		if(SPACEPIRATE_Z)


/obj/item/spessFishHook/throw_impact(atom/hit_atom)
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

