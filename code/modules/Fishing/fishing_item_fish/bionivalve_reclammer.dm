/obj/structure/closet/crate/reclammer
	name = "nanotech recycler"
	desc = ""
	icon = ''
	icon_state ""
	var/recSpeed = 1
	var/recEfficiency = 50
	var/recProgress = 0
	var/crMatTotal = 0
	var/list/heldMats = list()
	var/obj/item/currentRec = null

/obj/structure/closet/crate/reclammer/angler_effect(obj/item/weapon/bait/baitUsed)
	var/baitToSpeed = 0	//Assuming a bait power of 100 it recycles 5% per tick at 70% efficiency
	baitToClam = baitUsed.catchPower/25
	recSpeed = min(10, recSpeed + baitToClam)
	baitToClam = baitUsed.catchPower/5
	recEfficiency = min(100, recEfficiency + baitToClam)

/obj/structure/closet/crate/reclammer/New()
	processing_objects.Add(src)

/obj/structure/closet/crate/reclammer/open(mob/user)
	..()
	oysterReset()

/obj/structure/closet/crate/reclammer/toggle(mob/user)
	if(currentRec)
		to_chat(user,"<span class='notice'>\The [src] is shut tight.</span>")
		return FALSE
	..()

/obj/structure/closet/crate/reclammer/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iscrowbar(W) && !opened)
		to_chat(user, "<span class='warning'>You begin to pry open \the [src]!</span>")
		if(do_after(2 SECONDS))
			open(user)
	..()

/obj/structure/closet/crate/reclammer/canweld()
	return FALSE

/obj/structure/closet/crate/reclammer/proc/oysterReset()
	recProgress = 0
	crMatTotal = 0
	currentRec = null

/obj/structure/closet/crate/reclammer/process()
	if(contents && !opened)
		oysterRecycle()

/obj/structure/closet/crate/reclammer/proc/oysterRecycle()
	if(!currentRec)
		var/list/toRec = list()
		for(var/obj/item/i in contents)
			if(i.materials)
				toRec += i
			if(toRec.len)
				currentRec = pick(toRec)
				for(var/mat in currentRec.materials.storage)
					crMatTotal += currentRec.materials.getAmount(mat)
	if(currentRec)
		recProgress()

/obj/structure/closet/crate/reclammer/proc/recProgress()
	recProgress += round(crMatTotal * (recSpeed/100), 1)
	if(recProgress >= crMatTotal)
		extractMaterial()

/obj/structure/closet/crate/reclammer/proc/extractMaterial()
	for(var/matType in currentRec.materials.storage)
		var/extractedMat = 0
		extractedMat = currentRec.materials.getAmount(matType) * (recEfficiency/100)
		if(!is_type_in_list(heldMats, matType))
			heldMats += list(matType = extractedMat)
		else
			heldMats[matType] += extractedMat
		if(heldMats[matType] >= get_material_cc_per_sheet(matType))
			makePearl(matType)
	if(currentRec.contents.len)
		for(var/obj/item/i in currentRec.contents)	//No eating the disk
			i.forceMove(src)
	qdel(currentRec)
	oysterReset()

/obj/structure/closet/crate/reclammer/proc/makePearl(var/theMat)
	var/datum/material/mat = material_list[theMat]
	var/obj/item/stack/sheet/matForPearl = theMat.sheettype
	heldMats[theMat] -= get_material_cc_per_sheet(theMat)
	new matForPearl(src)

