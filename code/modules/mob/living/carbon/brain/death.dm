/mob/living/carbon/brain/death(gibbed)
	if((status_flags & BUDDHAMODE) || stat == DEAD)
		return
	if(!gibbed && container && istype(container, /obj/item/device/mmi))//If not gibbed but in a container.
		container.OnMobDeath(src)

	stat = DEAD

	change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	tod = worldtime2text() //weasellos time of death patch
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)	//mind. ?

	return ..(gibbed)

/mob/living/carbon/brain/dust()
	var/turf/T = get_turf(loc)
	if(T && client && iscultist(src) && timeofhostdeath >= world.time - DEATH_SHADEOUT_TIMER)
		var/obj/item/organ/internal/brain/B
		var/obj/item/organ/external/head/H
		var/obj/item/device/mmi/M

		if (loc && istype(loc,/obj/item/device/mmi))
			M = loc
		else if (loc && istype(loc,/obj/item/organ/external/head))
			H = loc
		else if(loc && istype(loc,/obj/item/organ/internal/brain))
			B = loc
			if (B.loc && istype(B.loc,/obj/item/organ/external/head))
				H = B.loc

		//Spawning our shade and transfering the mind
		var/mob/living/simple_animal/shade/shade = new (T)
		playsound(T, 'sound/hallucinations/growl1.ogg', 50, 1)
		shade.name = "[real_name] the Shade"
		shade.real_name = "[real_name]"
		mind.transfer_to(shade)
		update_faction_icons()
		to_chat(shade, "<span class='sinister'>Dark energies rip your dying body appart, anchoring your soul inside the form of a Shade. You retain your memories, and devotion to the cult.</span>")

		//Spawning a skull, or just ashes if there was only a brain
		if (H)
			new/obj/item/weapon/skull(T)
		else if (B || M)
			new /obj/effect/decal/cleanable/ash(T)

		//Getting rid of the brain/head objects
		if (B)
			qdel(B)
		if (H)
			qdel(H)
		if (M)
			M.icon_state = "mmi_empty"
			M.name = "\improper Man-Machine Interface"

		//Finally getting rid of the brainmob itself
		qdel(src)
	else
		..()

/mob/living/carbon/brain/gib(animation = FALSE, meat = TRUE)
	if(status_flags & BUDDHAMODE)
		adjustBruteLoss(200)
		return
	if(!isUnconscious())
		forcesay("-")
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	if(container && istype(container, /obj/item/device/mmi))
		qdel(container)//Gets rid of the MMI if there is one
	if(loc)
		if(istype(loc,/obj/item/organ/internal/brain))
			qdel(loc)//Gets rid of the brain item

	anim(target = src, a_icon = 'icons/mob/mob.dmi', /*flick_anim = "gibbed-m"*/, sleeptime = 15)
	gibs(loc, virus2, dna)

	dead_mob_list -= src
	qdel(src)
